/*
 * SNAKE.asm
 *
 *  Created: 2014-04-25 08:02:33
 *   Author: b13petha
 */ 
 
.list

      rjmp      main
main:

    ldi      r16,0xFF
    out      DDRB,r16
	out      DDRC,r16
	out      DDRD,r16

	ldi		r19 , 0
	ldi		r20 , 127

loop:

	subi	r19 , -1
	cp		r19 , r20
	brge	loop2

loop1:
	ldi	r16 , 0b00001000
	ldi	r17 , 0b00000000
	ldi r18 , 0b00000001

    out     PORTC , r16
    out     PORTD , r17
	out		PORTB , r18

	jmp loop

loop2:
	
	ldi	r16 , 0b00000000
	ldi	r17 , 0b00100000
	ldi r18 , 0b00000100

    out     PORTC , r16
    out     PORTD , r17
	out		PORTB , r18

	jmp		loop