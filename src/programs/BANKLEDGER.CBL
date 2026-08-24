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
           88 END-OF-FILE      VALUE "Y".

       01 WS-ACCOUNT-COUNT     PIC 9(05) VALUE ZERO.

       PROCEDURE DIVISION.

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
                       DISPLAY "ACCOUNT RECORD READ: "
                           ACCOUNT-INPUT-RECORD
               END-READ

           END-PERFORM.

           CLOSE ACCOUNT-FILE.

           DISPLAY "----------------------------------------".
           DISPLAY "ACCOUNT RECORDS READ: "
               WS-ACCOUNT-COUNT.
           DISPLAY "----------------------------------------".

           STOP RUN.