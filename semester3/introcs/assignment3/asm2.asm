.ORIG x3000

LD R1, NUMBER1
LD R2, NUMBER2

ADD R3, R1, #0
NOT R3, R3
AND R3, R3, R2
NOT R3, R3

NOT R2, R2
AND R2, R2, R1
NOT R2, R2

AND R3, R3, R2
NOT R3, R3

HALT

NUMBER1 .FILL #123
NUMBER2 .FILL #234


.END