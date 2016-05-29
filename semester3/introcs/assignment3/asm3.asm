.ORIG x3000

LEA R0, string
AND R1, R1, #0


LOOP LDR R2, R0, #0
     BRz END
     ADD R1, R1, #1
     ADD R0, R0, #1
     BR LOOP

END HALT

string .STRINGZ "hello world!"


.END
