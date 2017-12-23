.include "m16def.inc"

.def flag = r31
.def pressed = r30

.org 0x00
rjmp reset
.org INT1addr
rjmp handle_lights_on_signal
.org OVF1addr
rjmp handle_lights_off_signal

reset:
	clr flag
	clr pressed
    clr r26
	ldi r26,(1 << ISC11) | (1 << ISC10) 
	out MCUCR,r26					
	ldi r26,(1 << INT1)			
	out GICR,r26
						
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
    out DDRB, r26
// set D pins as input
	clr r26
	out DDRD, r26
// enable interupts
    sei
	rcall enable_timer_intr

main:
    in r26, PINA
    bst r26, 7
    brtc main_pc
	brts main_ps
main_ps:
	cpi pressed, 0x01
	breq main
	rcall turn_lights_on
	ldi pressed, 0x01
	rjmp main
main_pc:
	ldi pressed, 0x00
    rjmp main

handle_lights_on_signal:
	rcall turn_lights_on
    reti

handle_lights_off_signal:
	clr r26
    out PORTB, r26
    rcall disable_timer_intr
	ldi flag, 0x00
	sei
    reti

turn_lights_on:
    cli
    rcall setup_timer
	cpi flag, 0x00
	breq tlol
    ser r26
    out PORTB, r26
    rcall wait_hsec
tlol:
	ldi flag, 0x01
    ldi r26, 0b0000001
    out PORTB, r26
    sei
    ret
     
setup_timer:
    ldi r26, 0b00000101
    out TCCR1B,r26
    ldi r26, 0x85
    out TCNT1H, r26
    ldi r26, 0xee
    out TCNT1L, r26
	rcall enable_timer_intr
    ret

enable_timer_intr:
	ldi r26, 0b00000100
    out TIMSK, r26
	ret

disable_timer_intr:
	ldi r26, 0b00000000
    out TIMSK, r26
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

wait_hsec:
    push r24
    push r25
    ldi r24, LOW(500)
    ldi r25, HIGH(500)
    rcall wait_msec
    pop r25
    pop r24
    ret


spitha_safty:
	push r24
	push r25
	ldi r26,0x80
	out GIFR,r26
	ldi r24,0x05
	clr r25
	rcall wait_msec
	in r26,GIFR
	sbrc r26,7
	rjmp spitha_safty 
	pop r25
	pop r24
	ret