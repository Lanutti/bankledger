       IDENTIFICATION DIVISION.
       PROGRAM-ID. TRANSFER.

       DATA DIVISION.

       LINKAGE SECTION.

       01 LK-SOURCE-BALANCE      PIC S9(09)V99.
       01 LK-DESTINATION-BALANCE PIC S9(09)V99.
       01 LK-AMOUNT              PIC S9(09)V99.
       01 LK-SUCCESS             PIC X.

       PROCEDURE DIVISION USING
           LK-SOURCE-BALANCE
           LK-DESTINATION-BALANCE
           LK-AMOUNT
           LK-SUCCESS.

           MOVE "N" TO LK-SUCCESS

           IF LK-AMOUNT > ZERO
               AND LK-SOURCE-BALANCE >= LK-AMOUNT

               SUBTRACT LK-AMOUNT
                   FROM LK-SOURCE-BALANCE

               ADD LK-AMOUNT
                   TO LK-DESTINATION-BALANCE

               MOVE "Y" TO LK-SUCCESS

           END-IF

           GOBACK.
           