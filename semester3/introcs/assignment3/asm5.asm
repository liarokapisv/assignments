.ORIG x3000

    LD R0, array_start
    LD R1, length
 
    ADD R2, R0, #1 
    
    LDR R0, R0, #0

PROG_LOOP 

    ADD R1, R1, #-1
    BRz PROG_END

    LDR R3, R2, #0
    NOT R3, R3
    ADD R3, R3, #1
    ADD R3, R3, R0
    BRzp END_IF_1

    LDR R0, R2, #0

END_IF_1

    ADD R2, R2, #1

    BR PROG_LOOP

PROG_END 

    HALT

length .FILL #20
array_start .FILL x4000

.END
