.include "m16def.inc"

.def temp = r30
.def r24_flag = r29
.def r25_flag = r28
.def counter = r27

.org 0x00 

reset:
    ldi temp,(1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4)
    out DDRC, temp

    ser temp
    out DDRB, temp

    clr temp
    out PORTB, temp

    clr counter
    clr r24_flag
    clr r25_flag

initial_state:
    call scan_downpress_keypad
    cpi r25, 0b00000000
    brneq incorrect_key_pressed
    cpi r24, 0b00000000
    breq initial_state
    cpi r24, 0b00001000
    breq first_correct_key_pressed
    jmp incorrect_key_pressed

first_correct_key_pressed:
    call scan_downpress_keypad
    cpi r24, 0b00000000
    brneq incorrect_key_pressed
    cpi r25, 0b00000000
    breq first_correct_key_pressed
    cpi r25, 0b00000001
    breq second_correct_key_pressed
    jmp incorrect_key_pressed

incorrect_key_pressed:
    ldi counter, 8
loop:
    ser temp
    out PORTB, temp
    ldi r24, LOW(250)
    ldi r25, HIGH(250)
    call wait_msec
    
    clr temp
    out PORTB, temp
    ldi r24, LOW(250)
    ldi r25, HIGH(250)
    call wait_msec

    dec counter
    brne loop

    jmp initial_state

second_correct_key_pressed:
    ser temp
    out PORTB, temp
    ldi r24, LOW(4000)
    ldi r25, HIGH(4000)
    call wait_msec
    clr temp
    out PORTB, temp
    jmp initial_state

scan_row:
    ldi r25 , 0x08 
back_: 
    lsl r25 
    dec r24 
    brne back_
    out PORTC , r25 
    nop
    nop 
    in r24 , PINC 
    andi r24 ,0x0f 
    ret 

scan_keypad:
    ldi r24 , 0x01 
    rcall scan_row 
    swap r24 
    mov r27 , r24 
    ldi r24 ,0x02 
    rcall scan_row
    add r27 , r24 
    ldi r24 , 0x03 
    rcall scan_row
    swap r24 
    mov r26 , r24 
    ldi r24 ,0x04 
    rcall scan_row
    add r26 , r24 
    movw r24 , r26 
    ret

wait_usec:
    sbiw r24 ,1        
    nop                 
    nop                 
    nop                 
    nop                 
    brne wait_usec      
    ret                 

wait_msec:
    push r24    
    push r25   
    ldi r24 , LOW(998) 
    ldi r25 , HIGH(998)
    rcall wait_usec 
    pop r25     
    pop r24          
    sbiw r24 , 1      
    brne wait_msec     
    ret                 

scan_downpress_keypad:
    mov r22 ,r24 
    rcall scan_keypad 
    push r24 
    push r25
    mov r24 ,r22 
    ldi r25 ,0 
    rcall wait_msec
    rcall scan_keypad 
    pop r23 
    pop r22
    and r24 ,r22
    and r25 ,r23
    ldi r26 ,low(_tmp_) 
    ldi r27 ,high(_tmp_) 
     ld r23 ,X+
    ld r22 ,X
    st X ,r24 
    st -X ,r25 
    com r23
    com r22 
    and r24 ,r22
    and r25, r23
    ret
