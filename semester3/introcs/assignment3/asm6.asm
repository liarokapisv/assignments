.orig x3000

;---------------------------
; r0 = 0
; r1 = &data
; while true
; {
;   if (*r1) == \0 return
;   r6 = find_num(r1)
;   r5 = find_non_num(r6)
;   r0 = r0 + make_number(r6, r5)
;   r1 = r5
; }

data .stringz "aasdasd474asdasd4566asd"
    
    and r0, r0, #0
    lea r1, data

loop    

    ;r2 = *r1
    ldr r2, r1, #0
    ;if r2 == \0 go to end
    brz prog_end

    ;r6 = r1
    add r6, r1, #0
    ;r6 = find_num(r6)
    jsr find_num
    ;r4 = r6 
    add r4, r6, #0
    ;r6 = find_non_num(r6)
    jsr find_non_num
    ;r5 = r6
    add r5, r6, #0
    ;r6 = r4
    add r6, r4, #0
    ;r6 = make_number(r6,r5)
    jsr make_number
    
    ;r0 = r0 + r6
    add r0, r0, r6
    ;r1 = r5 
    add r1, r5, #0
    ;repeat
    br loop

prog_end 

    halt

;--------------------------------------------
; find_num(r6) -> r6
; {
;   while true
;   {
;     r1 = *r6
;     if r1 == \0 return r6
;     if r1 >= '0'
;     {
;       if r1 <= '9' return r6
;     }
;     r6 = r6 + 1
;   }
; }

find_num_r0 .blkw 1
find_num_r1 .blkw 1
find_num ; input: start in r6.
         ; output: position in r6

    st r0, find_num_r0
    st r1, find_num_r1

    ;r0 = -48
    and r0, r0, #0
    add r0, r0, #-15
    add r0, r0, #-15
    add r0, r0, #-15
    add r0, r0, #-3
     
find_num_loop

    ;r1 = *r6
    ldr r1, r6, #0
    ;if r1 == \0 go to end
    brz find_num_end
    ;r1 = r1 - 48
    add r1, r1, r0
    ;if r1 < 48 go after if
    brn find_num_after_if
    ;r1 = r1 - 9
    add r1, r1, #-9
    ;else if r1 <= 57 go to end
    brnz find_num_end

find_num_after_if
    ;otherwise r6 = r6 + 1
    add r6, r6, #1
    ;repeat
    br find_num_loop

find_num_end

    ld r0, find_num_r0
    ld r1, find_num_r1
    ret 

; ---------------------------
; find_non_num(r6) -> r6
; {
;   while true
;   { 
;     r1 = *r6
;     if r1 == \0 return r6
;     if r1 < '0' return r6
;     if r1 > '9' return r6
;     r6 = r6 + 1
;   }
; }

find_non_num_r0 .blkw 1
find_non_num_r1 .blkw 1

find_non_num; input: start in r6
            ; output: position in r6

    st r0, find_non_num_r0
    st r1, find_non_num_r1

    ;r0 = -48
    and r0, r0, #0
    add r0, r0, #-15
    add r0, r0, #-15
    add r0, r0, #-15
    add r0, r0, #-3



find_non_num_loop
    ;r1 = *r6
    ldr r1, r6, #0
    ;if r1 == \0 go to end
    brz find_non_num_end
    ;r1 = r1 - 48
    add r1, r1, r0
    ;
    brn find_non_num_end
    add r1, r1, #-9
    brp find_non_num_end

    add r6, r6, #1
    
    br find_non_num_loop

find_non_num_end

    ld r1, find_non_num_r1
    ld r0, find_non_num_r0
    ret    

;-------------------------
; make_number(r6 : start, r5 : end) -> r6
; {
;   r0 = r5 - 1
;   r4 = r6
;   r2 = 0
;   r1 = 1
;   while true
;   {
;     if r0 < r4 return r2
;     r3 = asciitoint(*r0) * r1
;     r2 = r2 + r3
;     r1 = r1 * 10
;     r0 = r0 - 1
;   } 
;   return r2
; }

make_number_r7 .blkw 1
make_number_r0 .blkw 1
make_number_r1 .blkw 1
make_number_r2 .blkw 1
make_number_r3 .blkw 1
make_number_r4 .blkw 1
make_number_r5 .blkw 1


make_number;input: start in r6
           ;       end in r5
           ;output: number in r6

    
    st r7, make_number_r7
    st r0, make_number_r0
    st r1, make_number_r1
    st r2, make_number_r2
    st r3, make_number_r3
    st r4, make_number_r4
    st r5, make_number_r5

    ; r0 = r5 -1
    add r0, r5, #-1
    ; r4 = r6
    add r4, r6, #0

    ; r1 = 1
    and r1, r1, #0
    add r1, r1, #1

    ;r2 = 0
    and r2, r2, #0
 
make_number_loop

    ; if r0 < r4 go to end
    add r3, r4, #0
    not r3, r3
    add r3, r3, #1
    add r3, r3, r0
    BRn make_number_end

    ; r3 = *r3
    ldr r3, r0, #0
    
    ; r3 = r3 - 48
    add r3, r3, #-15
    add r3, r3, #-15
    add r3, r3, #-15
    add r3, r3, #-3

    ;r5 = r1
    add r5, r1, #0
    
    ;r6 = mult(r3, r5)
    add r6, r3, #0 
    jsr mult

    ;r2 = r2 + r6
    add r2, r2, r6

    ;r6 = mult(10, r5)
    and r6, r6, #0
    add r6, r6, #10
    jsr mult

    ;r1 = r6
    add r1, r6, #0

    ;r0 = r0 - 1
    add r0, r0, #-1
    ;repeat
    br make_number_loop
     
make_number_end

   ;r6 = r2
   add r6, r2, #0

   ld r7, make_number_r7
   ld r5, make_number_r5
   ld r4, make_number_r4
   ld r3, make_number_r3
   ld r2, make_number_r2
   ld r1, make_number_r1
   ld r0, make_number_r0
   ret

;--------------------------------------------------
; mult(r6 : num1, r5 : num2) -> r6
; {
;   r1 = 0
;   r0 = r5
;   while true
;   {
;     if r0 <= 0 return r1
;     r1 = r1 + r6
;     r0 = r0 - 1
;   }
; }

mult_r7 .blkw 1
mult_r0 .blkw 1
mult_r1 .blkw 1

mult ; input: numbers in r6 and r5
     ; output: result in r6

   st r7, mult_r7
   st r0, mult_r0
   st r1, mult_r1
   
   ;r1 = 0
   and r1, r1, #0

   ;r0 = r5
   add r0, r5, #0

mult_loop

   ;if r0 <= 0 go to end
   brnz mult_end

   ;r1 = r1 + r6
   add r1, r1, r6
   
   ;r0 = r0 - 1
   add r0, r0, #-1
   
   ;repeat
   br mult_loop

mult_end

   ;r6 = r1
   add r6, r1, #0

   ld r0, mult_r0
   ld r1, mult_r1
   ld r7, mult_r7

   ret

.end
