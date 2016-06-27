.orig x3000

    ld r0, array_start
    ld r1, length
 
    add r2, r0, #1 
    
    ldr r0, r0, #0

prog_loop 

    add r1, r1, #-1
    brz prog_end

    ldr r3, r2, #0
    not r3, r3
    add r3, r3, #1
    add r3, r3, r0
    brzp end_if

    ldr r0, r2, #0

end_if

    add r2, r2, #1

    br prog_loop

prog_end 

    halt

length .fill #20
array_start .fill x4000

.end
