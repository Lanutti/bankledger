IDENTIFICATION DIVISION.
       PROGRAM-ID. BANKLEDGER.

       ENVIRONMENT DIVISION.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT ACCOUNT-FILE
               ASSIGN TO "data/input/accounts.dat"
               ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.

       FILE SECTION.

       FD ACCOUNT-FILE.
       01 ACCOUNT-INPUT-RECORD PIC X(100).

       WORKING-STORAGE SECTION.

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

       PROCEDURE DIVISION.

       MAIN-PROCEDURE.
           DISPLAY "========================================".
           DISPLAY "             BANKLEDGER".
           DISPLAY "========================================".

           OPEN INPUT ACCOUNT-FILE.

           PERFORM UNTIL END-OF-FILE
               READ ACCOUNT-FILE
                   AT END
                       SET END-OF-FILE TO TRUE
                   NOT AT END
                       ADD 1 TO WS-ACCOUNT-COUNT

                       INITIALIZE WS-ACCOUNT-INPUT

                       UNSTRING ACCOUNT-INPUT-RECORD
                           DELIMITED BY "|"
                           INTO
                               WS-ACCOUNT-ID
                               WS-CUSTOMER-ID
                               WS-ACCOUNT-TYPE
                               WS-ACCOUNT-BALANCE
                               WS-ACCOUNT-STATUS
                       END-UNSTRING

                       PERFORM VALIDATE-ACCOUNT
               END-READ
           END-PERFORM.

           CLOSE ACCOUNT-FILE.

           DISPLAY "----------------------------------------".
           DISPLAY "TOTAL RECORDS:   " WS-ACCOUNT-COUNT.
           DISPLAY "VALID RECORDS:   " WS-VALID-RECORDS.
           DISPLAY "INVALID RECORDS: " WS-INVALID-RECORDS.
           DISPLAY "----------------------------------------".

           STOP RUN.

       VALIDATE-ACCOUNT.
           IF WS-ACCOUNT-ID IS NUMERIC
              AND WS-CUSTOMER-ID IS NUMERIC
              AND WS-ACCOUNT-BALANCE NOT = SPACES
              AND WS-ACCOUNT-TYPE NOT = SPACES
              AND WS-ACCOUNT-STATUS NOT = SPACES
               ADD 1 TO WS-VALID-RECORDS
           ELSE
               ADD 1 TO WS-INVALID-RECORDS
           END-IF.