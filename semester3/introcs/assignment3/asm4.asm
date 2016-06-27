.orig x3000

;------ example -----

ld r0, exnum1
ld r1, exnum2
jsr divide

ld r0, exnum3
ld r1, exnum4
jsr xor

lea r0, string
jsr length

halt

;------ subroutines ----

divide ; r0 : numerator, r1 : denumerator -> r0 : div, r1 : mod, r2 : valid

divide_r7 .blkw 1

    st r7, divide_r7

    and r2, r2, #0 
    and r1, r1, r1
    brz divide_end

    not r1, r1     
    add r1, r1, #1 

divide_loop
   
    add r2, r2, #1
    add r0, r0, r1
    brzp divide_loop

    not r1, r1
    add r1, r1, #1
    add r1, r1, r0

    add r0, r2, #-1


divide_end
    ld r7, divide_r7
    ret


xor ; r0 : num1, r1 : num2 -> r0 : result

xor_r7 .blkw 1
xor_r2 .blkw 1

    st r7, xor_r7
    st r2, xor_r2
  
    add r2, r0, #0
    not r2, r2
    and r2, r2, r1
    not r2, r2

    not r1, r1
    and r1, r1, r0
    not r1, r1

    and r2, r2, r1
    not r2, r2

    add r0, r2, #0
  
    ld r2, xor_r2
    ld r7, xor_r7
    ret


length ; r0 : address -> r0 : length

length_r7 .blkw 1
length_r1 .blkw 1
length_r2 .blkw 1

    st r7, length_r7
    st r1, length_r1
    st r2, length_r2

    and r1, r1, #0
    
    ldr r2, r0, #0
    brz length_end

length_loop
   
    add r1, r1, #1
    add r0, r0, #1
    ldr r2, r0, #0
    brnp length_loop

length_end

    add r0, r1, #0
    
    ld r2, length_r2
    ld r1, length_r1
    ld r7, length_r7
    ret

string .stringz "hello world!"
exnum1 .fill #11
exnum2 .fill #3
exnum3 .fill x000f
exnum4 .fill x000a


.end
