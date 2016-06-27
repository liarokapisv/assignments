.orig x3000

ld r1, number1
ld r2, number2

add r3, r1, #0
not r3, r3
and r3, r3, r2
not r3, r3

not r2, r2
and r2, r2, r1
not r2, r2

and r3, r3, r2
not r3, r3

halt

number1 .fill #123
number2 .fill #234


.end
