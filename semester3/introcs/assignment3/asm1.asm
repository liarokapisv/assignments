.ORIG x3000

     NUMBER0 .FILL #4
     NUMBER1 .FILL #0
     
     LD R0, NUMBER0 
     AND R2, R2, #0 
     LD R1, NUMBER1
     BRz End

     NOT R1, R1     
     ADD R1, R1, #1 

Loop ADD R2, R2, #1
     ADD R0, R0, R1
     BRzp Loop

     NOT R1, R1
     ADD R1, R1, #1
     ADD R1, R1, R0

     ADD R0, R2, #-1

End  HALT

.END


