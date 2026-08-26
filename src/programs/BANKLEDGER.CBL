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

       DATA DIVISION.

       FILE SECTION.

       FD TRANSACTION-FILE.
       01 TRANSACTION-INPUT-RECORD         PIC X(100).

       FD REJECTED-FILE.
       01 REJECTED-RECORD                  PIC X(150).

       WORKING-STORAGE SECTION.

      * COPY ACCOUNT.
      * COPY TRANSACT.
      * COPY TRXVALID.

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

                       PERFORM PARSE-TRANSACTION
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

      * 1. Validação de formato alfanumérico/numérico
           IF WS-INPUT-TRANSACTION-ID NOT NUMERIC
               MOVE "INVALID_TRANSACTION_ID" TO WS-VALIDATION-ERROR
               EXIT PARAGRAPH
           END-IF.

           IF WS-INPUT-ACCOUNT-ID NOT NUMERIC
               MOVE "INVALID_ACCOUNT_ID" TO WS-VALIDATION-ERROR
               EXIT PARAGRAPH
           END-IF.

           IF WS-INPUT-AMOUNT NOT NUMERIC
               MOVE "INVALID_AMOUNT" TO WS-VALIDATION-ERROR
               EXIT PARAGRAPH
           END-IF.

      * 2. Conversão segura para os campos numéricos/estruturados
           MOVE FUNCTION NUMVAL(WS-INPUT-TRANSACTION-ID)
               TO TRANSACTION-ID.

           MOVE FUNCTION NUMVAL(WS-INPUT-ACCOUNT-ID)
               TO ACCOUNT-ID.

           MOVE WS-INPUT-TYPE
               TO TRANSACTION-TYPE.

           MOVE FUNCTION NUMVAL(WS-INPUT-AMOUNT)
               TO TRANSACTION-AMOUNT.

      * 3. Validação de regras de negócio
           IF TRANSACTION-ID = ZERO
               MOVE "INVALID_TRANSACTION_ID" TO WS-VALIDATION-ERROR
               EXIT PARAGRAPH
           END-IF.

           IF ACCOUNT-ID = ZERO
               MOVE "INVALID_ACCOUNT_ID" TO WS-VALIDATION-ERROR
               EXIT PARAGRAPH
           END-IF.

           IF TRANSACTION-AMOUNT <= ZERO
               MOVE "INVALID_AMOUNT" TO WS-VALIDATION-ERROR
               EXIT PARAGRAPH
           END-IF.

           IF TRANSACTION-TYPE NOT = "DEPOSIT"
              AND TRANSACTION-TYPE NOT = "WITHDRAWAL"
              AND TRANSACTION-TYPE NOT = "TRANSFER"
               MOVE "INVALID_TRANSACTION_TYPE" TO WS-VALIDATION-ERROR
               EXIT PARAGRAPH
           END-IF.

           SET TRANSACTION-VALID TO TRUE.


       PROCESS-TRANSACTION.

           ADD 1 TO WS-VALID-RECORDS.
           DISPLAY "TRANSACTION VALID: " TRANSACTION-ID.


       REJECT-TRANSACTION.

           ADD 1 TO WS-INVALID-RECORDS.
           PERFORM WRITE-REJECTED-TRANSACTION.


       WRITE-REJECTED-TRANSACTION.

           INITIALIZE WS-REJECTED-RECORD.

           STRING
               WS-INPUT-TRANSACTION-ID DELIMITED BY SIZE
               "|"                      DELIMITED BY SIZE
               WS-INPUT-ACCOUNT-ID     DELIMITED BY SIZE
               "|"                      DELIMITED BY SIZE
               WS-VALIDATION-ERROR     DELIMITED BY SPACES
               "|"                      DELIMITED BY SIZE
               WS-INPUT-AMOUNT         DELIMITED BY SPACES
               INTO WS-REJECTED-RECORD
           END-STRING.

           WRITE REJECTED-RECORD FROM WS-REJECTED-RECORD.