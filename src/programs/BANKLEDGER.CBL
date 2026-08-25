       IDENTIFICATION DIVISION.
       PROGRAM-ID. BANKLEDGER.

       ENVIRONMENT DIVISION.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT ACCOUNT-FILE
               ASSIGN TO "data/input/accounts.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

           SELECT REJECTED-FILE
               ASSIGN TO "data/output/rejected_transactions.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

       

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT ACCOUNT-FILE
               ASSIGN TO "data/input/accounts.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD ACCOUNT-FILE.
       01 ACCOUNT-INPUT-RECORD PIC X(100).

       FD REJECTED-FILE.
       01 REJECTED-RECORD       PIC X(150).

       FILE SECTION.

       FD ACCOUNT-FILE.
       01 ACCOUNT-INPUT-RECORD PIC X(100).

       WORKING-STORAGE SECTION.

       01 WS-REJECTED-RECORD PIC X(150).

       COPY TRXVAL.CPY.

       01 WS-REJECTED-RECORD.
           05 WS-REJ-TRANSACTION-ID  PIC 9(06).
           05 FILLER                 PIC X(01) VALUE "|".
           05 WS-REJ-ACCOUNT-ID      PIC X(06).
           05 FILLER                 PIC X(01) VALUE "|".
           05 WS-REJ-ERROR-CODE      PIC X(30).
           05 FILLER                 PIC X(01) VALUE "|".
           05 WS-REJ-AMOUNT          PIC 9(13)V99.

       01 WS-END-OF-FILE       PIC X VALUE "N".
          88 END-OF-FILE       VALUE "Y".

       01 WS-ACCOUNT-COUNT     PIC 9(05) VALUE ZERO.
       01 WS-VALID-RECORDS     PIC 9(05) VALUE ZERO.
       01 WS-INVALID-RECORDS   PIC 9(05) VALUE ZERO.

       01 WS-ACCOUNT-INPUT.
           05 WS-ACCOUNT-ID       PIC X(06).
           05 WS-CUSTOMER-ID      PIC X(05).
           05 WS-ACCOUNT-TYPE     PIC X(10).
           05 WS-ACCOUNT-BALANCE  PIC X(20).
           05 WS-ACCOUNT-STATUS   PIC X(10).

       01 WS-SEARCH-ACCOUNT-ID PIC 9(06).
       01 WS-ACCOUNT-FOUND     PIC X VALUE "N".
          88 ACCOUNT-FOUND     VALUE "Y".
          88 ACCOUNT-NOT-FOUND VALUE "N".

       PROCEDURE DIVISION.

       MAIN-PROCEDURE.
           DISPLAY "========================================".
           DISPLAY "             BANKLEDGER                 ".
           DISPLAY "========================================".

           OPEN INPUT TRANSACTION-FILE
                OUTPUT REJECTED-FILE.

           PERFORM UNTIL END-OF-FILE
               READ TRANSACTION-FILE
                   AT END
                       SET END-OF-FILE TO TRUE
                   NOT AT END
                       ADD 1 TO WS-TRANSACTION-COUNT

                       PERFORM VALIDATE-TRANSACTION

                       IF TRANSACTION-VALID
                           PERFORM PROCESS-TRANSACTION
                       ELSE
                           PERFORM REJECT-TRANSACTION
                       END-IF
               END-READ
           END-PERFORM.

           CLOSE TRANSACTION-FILE
                 REJECTED-FILE.

           DISPLAY "----------------------------------------".
           DISPLAY "TOTAL TRANSACTIONS:    " WS-TRANSACTION-COUNT.
           DISPLAY "VALID TRANSACTIONS:    " WS-VALID-RECORDS.
           DISPLAY "REJECTED TRANSACTIONS: " WS-INVALID-RECORDS.
           DISPLAY "----------------------------------------".

           STOP RUN.

       VALIDATE-TRANSACTION.
           SET TRANSACTION-INVALID TO TRUE
           MOVE SPACES TO WS-VALIDATION-ERROR

           IF WS-TRANSACTION-ID = ZERO
               MOVE "INVALID_TRANSACTION_ID" TO WS-VALIDATION-ERROR
               EXIT PARAGRAPH
           END-IF

           IF WS-ACCOUNT-ID = ZERO
               MOVE "INVALID_ACCOUNT_ID" TO WS-VALIDATION-ERROR
               EXIT PARAGRAPH
           END-IF

           IF WS-TRANSACTION-AMOUNT <= ZERO
               MOVE "INVALID_AMOUNT" TO WS-VALIDATION-ERROR
               EXIT PARAGRAPH
           END-IF

           IF WS-TRANSACTION-TYPE NOT = "DEPOSIT"
              AND WS-TRANSACTION-TYPE NOT = "WITHDRAWAL"
              AND WS-TRANSACTION-TYPE NOT = "TRANSFER"
               MOVE "INVALID_TRANSACTION_TYPE" TO WS-VALIDATION-ERROR
               EXIT PARAGRAPH
           END-IF

           SET TRANSACTION-VALID TO TRUE.

       PROCESS-TRANSACTION.
           ADD 1 TO WS-VALID-RECORDS
      *    Lógica para processar a transação válida (ex: debitar/creditar)
           CONTINUE.

       REJECT-TRANSACTION.
           ADD 1 TO WS-INVALID-RECORDS
           PERFORM WRITE-REJECTED-TRANSACTION.

       WRITE-REJECTED-TRANSACTION.
           STRING
               WS-TRANSACTION-ID
               "|"
               WS-ACCOUNT-ID
               "|"
               WS-VALIDATION-ERROR
               "|"
               WS-TRANSACTION-AMOUNT
               DELIMITED BY SIZE
               INTO WS-REJECTED-RECORD
           END-STRING.

           WRITE REJECTED-RECORD
               FROM WS-REJECTED-RECORD.
