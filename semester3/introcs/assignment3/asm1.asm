.orig x3000
     
     ld r0, number0 
     and r2, r2, #0 
     ld r1, number1
     brz end

     not r1, r1     
     add r1, r1, #1 

loop add r2, r2, #1
     add r0, r0, r1
     brzp loop

     not r1, r1
     add r1, r1, #1
     add r1, r1, r0

     add r0, r2, #-1

end  halt
     
     number0 .fill #4
     number1 .fill #0

.end


