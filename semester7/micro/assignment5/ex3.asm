#include "m16def.inc"

.section .text
.global main
.cseg

.org 0x00
rjump reset
.org 0x02
rjump handle_lights_on_signal
.org 0x10
rjump handle_lights_off_signal

reset:
//set stack pointer
    ldi r26, HIGH(RAMEND)
    out SPH, r26
    ldi r26, LOW(RAMEND)
    out SPL, r26
// set A pins as input
    clr r26
    out DDRA, r26
// set B pins as output
    ser r26
    out DDRA, r26
// enable interupts
    sei

main:
    in r26, PINA
    bst r26, 7
    brts turn_lights_on
    rjump main

handle_lights_on_signal:
    rcall turn_lights_on
    reti

handle_lights_off_signal:
    clr r26
    out PORTB, r26
    sei
    reti

turn_lights_on:
    cli
    ser r26
    out PORTB, r26
    rcall setup_timer
    rcall wait_hsec
    ldi r26, 0b1000000
    out PORTB, r26
    sei
    ret
     
setup_timer:
    ldi r26, 0b00000100
    out TIMSK, r26
    ldi r26, 0b00000101
    out TCCRIB
    ldi r26, 0x7a
    out TCNTIH, r26
    ldi r26, 0x12
    out TCNTIL, r26
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
    ldi r24 , 0xe6 
    ldi r25 , 0x03 
    rcall wait_usec 
    pop r25     
    pop r24          
    sbiw r24 , 1      
    brne wait_msec     
    ret                 

wait_hsec:
    push r24
    push r25
    ldi r24, 0xf4
    ldi r25, 0x01
    rcall wait_msec
    pop r25
    pop r24
    sbiw r24, 1
    brne wait_hsec
    ret
