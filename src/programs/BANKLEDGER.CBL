       IDENTIFICATION DIVISION.
       PROGRAM-ID. BANKLEDGER.

       ENVIRONMENT DIVISION.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT TRANSACTION-FILE
               ASSIGN TO "data/input/transactions.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT REJECTED-FILE
               ASSIGN TO "data/output/rejected_transactions.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT ACCOUNT-FILE
               ASSIGN TO "data/input/accounts.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT PROCESSED-FILE
               ASSIGN TO "data/output/processed_transactions.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT UPDATED-ACCOUNT-FILE
               ASSIGN TO "data/output/accounts_updated.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD TRANSACTION-FILE.
       01 TRANSACTION-INPUT-RECORD         PIC X(100).

       FD REJECTED-FILE.
       01 REJECTED-RECORD                  PIC X(150).

       FD ACCOUNT-FILE.
       01 ACCOUNT-INPUT-RECORD             PIC X(100).

       FD PROCESSED-FILE.
       01 PROCESSED-RECORD
           PIC X(150).

       FD UPDATED-ACCOUNT-FILE.
       01 UPDATED-ACCOUNT-RECORD
           PIC X(150).

       WORKING-STORAGE SECTION.

       01 WS-END-OF-FILE                   PIC X VALUE "N".
          88 END-OF-FILE                   VALUE "Y".

       01 WS-TRANSACTION-STATUS            PIC X VALUE "I".
          88 TRANSACTION-VALID             VALUE "V".
          88 TRANSACTION-INVALID           VALUE "I".

       01 WS-TRANSACTION-COUNT             PIC 9(05) VALUE ZERO.
       01 WS-VALID-RECORDS                 PIC 9(05) VALUE ZERO.
       01 WS-INVALID-RECORDS               PIC 9(05) VALUE ZERO.

       01 WS-TRANSACTION-INPUT.
           05 WS-INPUT-TRANSACTION-ID      PIC X(08).
           05 WS-INPUT-ACCOUNT-ID          PIC X(06).
           05 WS-INPUT-TYPE                PIC X(10).
           05 WS-INPUT-AMOUNT              PIC X(20).

       01 WS-TRANSACTION-PARSED.
           05 TRANSACTION-ID               PIC 9(08) VALUE ZERO.
           05 ACCOUNT-ID                   PIC 9(06) VALUE ZERO.
           05 TRANSACTION-TYPE             PIC X(10) VALUE SPACES.
           05 TRANSACTION-AMOUNT           PIC 9(13)V99 VALUE ZERO.

       01 WS-VALIDATION-ERROR              PIC X(30) VALUE SPACES.
       01 WS-REJECTED-RECORD               PIC X(150) VALUE SPACES.

       01 WS-ACCOUNT-INPUT.
           05 WS-ACC-ID-IN                 PIC X(06).
           05 WS-CUST-ID-IN                PIC X(05).
           05 WS-ACC-TYPE-IN               PIC X(10).
           05 WS-ACC-BAL-IN                PIC X(20).
           05 WS-ACC-STAT-IN               PIC X(10).

       01 WS-ACCOUNT-TABLE.
           05 WS-ACCOUNT-ENTRY OCCURS 100 TIMES.
               10 WS-TABLE-ACCOUNT-ID      PIC 9(06).
               10 WS-TABLE-CUSTOMER-ID     PIC 9(05).
               10 WS-TABLE-ACCOUNT-TYPE    PIC X(10).
               10 WS-TABLE-ACCOUNT-BALANCE PIC 9(11)V99.
               10 WS-TABLE-ACCOUNT-STATUS  PIC X(10).

       01 WS-ACCOUNT-INDEX                 PIC 9(03) VALUE ZERO.
       01 WS-ACCOUNTS-LOADED               PIC 9(03) VALUE ZERO.
       01 WS-ACCOUNT-EOF                   PIC X VALUE "N".

       01 WS-SEARCH-ACCOUNT-ID             PIC 9(06).

       01 WS-ACCOUNT-FOUND                 PIC X VALUE "N".
          88 ACCOUNT-FOUND                 VALUE "Y".
          88 ACCOUNT-NOT-FOUND             VALUE "N".

       01 WS-FOUND-ACCOUNT-INDEX           PIC 9(03) VALUE ZERO.

       01 WS-TRANSFER-ACCOUNT-ID
           PIC 9(06).

       01 WS-TRANSFER-ACCOUNT-INDEX
           PIC 9(03).

       01 WS-PROCESSED-RECORD
           PIC X(150).

       01 WS-UPDATED-ACCOUNT-RECORD
           PIC X(150).

       PROCEDURE DIVISION.

       MAIN-PROCEDURE.

           DISPLAY "========================================".
           DISPLAY "             BANKLEDGER                 ".
           DISPLAY "========================================".

      *    1. Carga inicial das contas em memoria
           OPEN INPUT ACCOUNT-FILE.

           PERFORM LOAD-ACCOUNTS.

           CLOSE ACCOUNT-FILE.

      *    2. Processamento principal das transacoes
           OPEN INPUT TRANSACTION-FILE
                OUTPUT PROCESSED-FILE
                OUTPUT REJECTED-FILE.
           OPEN OUTPUT UPDATED-ACCOUNT-FILE.

           PERFORM UNTIL END-OF-FILE

               READ TRANSACTION-FILE
                   AT END
                       SET END-OF-FILE TO TRUE

                   NOT AT END
                       ADD 1 TO WS-TRANSACTION-COUNT

                       PERFORM PARSE-TRANSACTION
                       PERFORM VALIDATE-TRANSACTION

                       IF TRANSACTION-VALID
                           PERFORM PROCESS-TRANSACTION
                       ELSE
                           PERFORM REJECT-TRANSACTION
                       END-IF

               END-READ

           END-PERFORM.

           PERFORM WRITE-UPDATED-ACCOUNTS.

           CLOSE TRANSACTION-FILE
                 REJECTED-FILE
                 PROCESSED-FILE.

           CLOSE UPDATED-ACCOUNT-FILE.

           DISPLAY "----------------------------------------".
           DISPLAY "TOTAL TRANSACTIONS:    "
                   WS-TRANSACTION-COUNT.

           DISPLAY "VALID TRANSACTIONS:    "
                   WS-VALID-RECORDS.

           DISPLAY "REJECTED TRANSACTIONS: "
                   WS-INVALID-RECORDS.

           DISPLAY "----------------------------------------".

           STOP RUN.


       LOAD-ACCOUNTS.

           MOVE ZERO TO WS-ACCOUNT-INDEX.
           MOVE ZERO TO WS-ACCOUNTS-LOADED.
           MOVE "N" TO WS-ACCOUNT-EOF.

           PERFORM UNTIL WS-ACCOUNT-EOF = "Y"
               OR WS-ACCOUNT-INDEX >= 100

               READ ACCOUNT-FILE

                   AT END
                       MOVE "Y" TO WS-ACCOUNT-EOF

                   NOT AT END
                       ADD 1 TO WS-ACCOUNT-INDEX

                       PERFORM PARSE-ACCOUNT
                       PERFORM STORE-ACCOUNT

               END-READ

           END-PERFORM.


       PARSE-ACCOUNT.

           INITIALIZE WS-ACCOUNT-INPUT.

           UNSTRING ACCOUNT-INPUT-RECORD
               DELIMITED BY "|"
               INTO
                   WS-ACC-ID-IN
                   WS-CUST-ID-IN
                   WS-ACC-TYPE-IN
                   WS-ACC-BAL-IN
                   WS-ACC-STAT-IN
           END-UNSTRING.


       STORE-ACCOUNT.

           IF WS-ACC-ID-IN NUMERIC

               MOVE FUNCTION NUMVAL(WS-ACC-ID-IN)
                 TO WS-TABLE-ACCOUNT-ID(
                     WS-ACCOUNT-INDEX
                 )

           END-IF.

           IF WS-CUST-ID-IN NUMERIC

               MOVE FUNCTION NUMVAL(WS-CUST-ID-IN)
                 TO WS-TABLE-CUSTOMER-ID(
                     WS-ACCOUNT-INDEX
                 )

           END-IF.

           MOVE WS-ACC-TYPE-IN
             TO WS-TABLE-ACCOUNT-TYPE(
                 WS-ACCOUNT-INDEX
             ).

           IF WS-ACC-BAL-IN NUMERIC

               MOVE FUNCTION NUMVAL(WS-ACC-BAL-IN)
                 TO WS-TABLE-ACCOUNT-BALANCE(
                     WS-ACCOUNT-INDEX
                 )

           END-IF.

           MOVE WS-ACC-STAT-IN
             TO WS-TABLE-ACCOUNT-STATUS(
                 WS-ACCOUNT-INDEX
             ).

           ADD 1 TO WS-ACCOUNTS-LOADED.


       FIND-ACCOUNT.

           SET ACCOUNT-NOT-FOUND TO TRUE.

           MOVE ZERO TO WS-FOUND-ACCOUNT-INDEX.

           PERFORM VARYING WS-ACCOUNT-INDEX
               FROM 1 BY 1
               UNTIL WS-ACCOUNT-INDEX > WS-ACCOUNTS-LOADED

               IF WS-TABLE-ACCOUNT-ID(
                   WS-ACCOUNT-INDEX
               ) = WS-SEARCH-ACCOUNT-ID

                   SET ACCOUNT-FOUND TO TRUE

                   MOVE WS-ACCOUNT-INDEX
                     TO WS-FOUND-ACCOUNT-INDEX

                   EXIT PERFORM

               END-IF

           END-PERFORM.


       PARSE-TRANSACTION.

           INITIALIZE WS-TRANSACTION-INPUT.

           UNSTRING TRANSACTION-INPUT-RECORD
               DELIMITED BY "|"
               INTO
                   WS-INPUT-TRANSACTION-ID
                   WS-INPUT-ACCOUNT-ID
                   WS-INPUT-TYPE
                   WS-INPUT-AMOUNT
           END-UNSTRING.


       VALIDATE-TRANSACTION.

           SET TRANSACTION-INVALID TO TRUE.

           MOVE SPACES TO WS-VALIDATION-ERROR.

           IF WS-INPUT-TRANSACTION-ID NOT NUMERIC

               MOVE "INVALID_TRANSACTION_ID"
                 TO WS-VALIDATION-ERROR

               EXIT PARAGRAPH

           END-IF.

           IF WS-INPUT-ACCOUNT-ID NOT NUMERIC

               MOVE "INVALID_ACCOUNT_ID"
                 TO WS-VALIDATION-ERROR

               EXIT PARAGRAPH

           END-IF.

           IF WS-INPUT-AMOUNT NOT NUMERIC

               MOVE "INVALID_AMOUNT"
                 TO WS-VALIDATION-ERROR

               EXIT PARAGRAPH

           END-IF.

           MOVE FUNCTION NUMVAL(
               WS-INPUT-TRANSACTION-ID
           ) TO TRANSACTION-ID.

           MOVE FUNCTION NUMVAL(
               WS-INPUT-ACCOUNT-ID
           ) TO ACCOUNT-ID.

           MOVE WS-INPUT-TYPE
             TO TRANSACTION-TYPE.

           MOVE FUNCTION NUMVAL(
               WS-INPUT-AMOUNT
           ) TO TRANSACTION-AMOUNT.

           IF TRANSACTION-ID = ZERO

               MOVE "INVALID_TRANSACTION_ID"
                 TO WS-VALIDATION-ERROR

               EXIT PARAGRAPH

           END-IF.

           IF ACCOUNT-ID = ZERO

               MOVE "INVALID_ACCOUNT_ID"
                 TO WS-VALIDATION-ERROR

               EXIT PARAGRAPH

           END-IF.

           IF TRANSACTION-AMOUNT <= ZERO

               MOVE "INVALID_AMOUNT"
                 TO WS-VALIDATION-ERROR

               EXIT PARAGRAPH

           END-IF.

           IF TRANSACTION-TYPE NOT = "DEPOSIT"
              AND TRANSACTION-TYPE NOT = "WITHDRAWAL"
              AND TRANSACTION-TYPE NOT = "TRANSFER"

               MOVE "INVALID_TRANSACTION_TYPE"
                 TO WS-VALIDATION-ERROR

               EXIT PARAGRAPH

           END-IF.

      *    Valida se a conta existe na memoria
           MOVE ACCOUNT-ID
             TO WS-SEARCH-ACCOUNT-ID.

           PERFORM FIND-ACCOUNT.

           IF ACCOUNT-NOT-FOUND

               MOVE "ACCOUNT_NOT_FOUND"
                 TO WS-VALIDATION-ERROR

               EXIT PARAGRAPH

           END-IF.

      *    Valida se a conta encontrada esta ativa
           IF WS-TABLE-ACCOUNT-STATUS(
               WS-FOUND-ACCOUNT-INDEX
           ) NOT = "ACTIVE"

               MOVE "ACCOUNT_NOT_ACTIVE"
                 TO WS-VALIDATION-ERROR

               EXIT PARAGRAPH

           END-IF.

           SET TRANSACTION-VALID TO TRUE.


       PROCESS-TRANSACTION.

           EVALUATE TRANSACTION-TYPE

               WHEN "DEPOSIT"
                   PERFORM PROCESS-DEPOSIT

               WHEN "WITHDRAWAL"
                   PERFORM PROCESS-WITHDRAWAL

               WHEN "TRANSFER"
                   PERFORM PROCESS-TRANSFER

           END-EVALUATE.


       PROCESS-DEPOSIT.

           ADD TRANSACTION-AMOUNT
               TO WS-TABLE-ACCOUNT-BALANCE(
                   WS-FOUND-ACCOUNT-INDEX
               ).

           ADD 1 TO WS-VALID-RECORDS.
           PERFORM WRITE-PROCESSED-TRANSACTION.


       PROCESS-WITHDRAWAL.

           IF WS-TABLE-ACCOUNT-BALANCE(
               WS-FOUND-ACCOUNT-INDEX
           ) < TRANSACTION-AMOUNT

               MOVE "INSUFFICIENT_FUNDS"
                   TO WS-VALIDATION-ERROR

               PERFORM REJECT-TRANSACTION

               EXIT PARAGRAPH

           END-IF.

           SUBTRACT TRANSACTION-AMOUNT
               FROM WS-TABLE-ACCOUNT-BALANCE(
                   WS-FOUND-ACCOUNT-INDEX
               ).

           ADD 1 TO WS-VALID-RECORDS.

           PERFORM WRITE-PROCESSED-TRANSACTION.


       PROCESS-TRANSFER.

           MOVE "TRANSFER_DESTINATION_REQUIRED"
               TO WS-VALIDATION-ERROR.

           PERFORM REJECT-TRANSACTION.


       REJECT-TRANSACTION.

           ADD 1 TO WS-INVALID-RECORDS.

           PERFORM WRITE-REJECTED-TRANSACTION.


       WRITE-REJECTED-TRANSACTION.

           INITIALIZE WS-REJECTED-RECORD.

           STRING
               WS-INPUT-TRANSACTION-ID DELIMITED BY SIZE
               "|"                      DELIMITED BY SIZE
               WS-INPUT-ACCOUNT-ID      DELIMITED BY SIZE
               "|"                      DELIMITED BY SIZE
               WS-VALIDATION-ERROR      DELIMITED BY SPACES
               "|"                      DELIMITED BY SIZE
               WS-INPUT-AMOUNT          DELIMITED BY SPACES
               INTO WS-REJECTED-RECORD
           END-STRING.

           WRITE REJECTED-RECORD
               FROM WS-REJECTED-RECORD.

       WRITE-PROCESSED-TRANSACTION.

           INITIALIZE WS-PROCESSED-RECORD.

           STRING
               WS-INPUT-TRANSACTION-ID
               "|"
               WS-INPUT-ACCOUNT-ID
               "|"
               WS-INPUT-TYPE
               "|"
               WS-INPUT-AMOUNT
               DELIMITED BY SIZE
               INTO WS-PROCESSED-RECORD
           END-STRING.

           WRITE PROCESSED-RECORD
               FROM WS-PROCESSED-RECORD.

       WRITE-UPDATED-ACCOUNTS.

           PERFORM VARYING WS-ACCOUNT-INDEX
               FROM 1 BY 1
               UNTIL WS-ACCOUNT-INDEX > WS-ACCOUNTS-LOADED

               MOVE SPACES
                   TO WS-UPDATED-ACCOUNT-RECORD

               STRING
                   WS-TABLE-ACCOUNT-ID(
                       WS-ACCOUNT-INDEX
                   )
                   "|"
                   WS-TABLE-CUSTOMER-ID(
                       WS-ACCOUNT-INDEX
                   )
                   "|"
                   WS-TABLE-ACCOUNT-TYPE(
                       WS-ACCOUNT-INDEX
                   )
                   "|"
                   WS-TABLE-ACCOUNT-BALANCE(
                       WS-ACCOUNT-INDEX
                   )
                   "|"
                   WS-TABLE-ACCOUNT-STATUS(
                       WS-ACCOUNT-INDEX
                   )
                   DELIMITED BY SIZE
                   INTO WS-UPDATED-ACCOUNT-RECORD
               END-STRING

               WRITE UPDATED-ACCOUNT-RECORD

           END-PERFORM.