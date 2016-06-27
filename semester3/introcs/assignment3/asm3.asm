.orig x3000

lea r0, string
and r1, r1, #0


loop ldr r2, r0, #0
     brz end
     add r1, r1, #1
     add r0, r0, #1
     br loop

end halt

string .stringz "hello world!"

.end
