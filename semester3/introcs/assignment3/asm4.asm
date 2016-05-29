.ORIG x3000

string .STRINGZ "hello world!"
exnum1 .FILL #11
exnum2 .FILL #3
exnum3 .FILL x000F
exnum4 .FILL x000A

;------ example -----

LD R0, exnum1
LD R1, exnum2
JSR DIVIDE

LD R0, exnum3
LD R1, exnum4
JSR XOR

LEA R0, string
JSR LENGTH

HALT

;------ subroutines ----

DIVIDE ; R0 : numerator, R1 : denumerator -> R0 : div, R1 : mod, R2 : valid

divide_r7 .BLKW 1

    ST R7, divide_r7

    AND R2, R2, #0 
    AND R1, R1, R1
    BRz DIVIDE_END

    NOT R1, R1     
    ADD R1, R1, #1 

DIVIDE_LOOP
   
    ADD R2, R2, #1
    ADD R0, R0, R1
    BRzp DIVIDE_LOOP

    NOT R1, R1
    ADD R1, R1, #1
    ADD R1, R1, R0

    ADD R0, R2, #-1


DIVIDE_END
    LD R7, divide_r7
    RET


XOR ; R0 : NUM1, R1 : NUM2 -> R0 : result

xor_r7 .BLKW 1
xor_r2 .BLKW 1

    ST R7, xor_r7
    ST R2, xor_r2
  
    ADD R2, R0, #0
    NOT R2, R2
    AND R2, R2, R1
    NOT R2, R2

    NOT R1, R1
    AND R1, R1, R0
    NOT R1, R1

    AND R2, R2, R1
    NOT R2, R2

    ADD R0, R2, #0
  
    LD R2, xor_r2
    LD R7, xor_r7
    RET


LENGTH ; R0 : address -> R0 : length

length_r7 .BLKW 1
length_r1 .BLKW 1
length_r2 .BLKW 1

    ST R7, length_r7
    ST R1, length_r1
    ST R2, length_r2

    AND R1, R1, #0
    
    LDR R2, R0, #0
    BRz LENGTH_END

LENGTH_LOOP
   
    ADD R1, R1, #1
    ADD R0, R0, #1
    LDR R2, R0, #0
    BRnp LENGTH_LOOP

LENGTH_END

    ADD R0, R1, #0
    
    LD R2, length_r2
    LD R1, length_r1
    LD R7, length_r7
    RET

.END
