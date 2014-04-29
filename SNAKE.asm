/*
 * SNAKE.asm
 *
 *  Created: 2014-04-25 08:02:33
 *   Author: b13petha
 *   Slaves: Simon, Henrik och that (gay retarded) guy...
 */ 
 .DSEG
	//Fuck all.
	matrix:
		.byte	8

	portArray:
		
	matricCounter:
		//Tar det som det kommer. Like she said.
.CSEG
	.list
		rjmp      main

main:
	/*
    in	r22, TIFR	// Flag register
	sbrs	r22, TOV0	// Skip shit

	ldi	r23, (1<<CS02)|(1<<CS00)	// Dafuq?!
	out	TCCR0, r23	// Set to system clock 1024
	*/

    ldi      r16,0xFF
    out      DDRB,r16
	out      DDRC,r16
	// #crackbaby
	out      DDRD,r16

	
	ldi		r21, 255

	ldi		r20 , 127
	ldi		r19 , 0

	ldi		ZL , low(matrix)
	ldi		ZH , high(matrix)
	
	ldi		r18, 0b00000010
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z, r18

	ldi		ZL , low(matrix)
	ldi		ZH , high(matrix)
	ld		r23 , Z

updateDisplay:

	ldi	r16 , 0b00000001
	ldi	r17 , 0b01000000
	ldi	r18 , 0b00000000

	out PORTC , r23
	out PORTD , r17
	out PORTB , r18


jmp updateDisplay

	ldi	r24 , 0
	//Z+ här ngnstans
	rowloop:
		bitloop:



		rjmp bitloop

	cpi		r24 , 4
	brge	portD

	PortCnnnn:


		jmp endPort

	PortDnnnn:


endPort:

	subi	r22 , -1
	subi	r24 , -1
	rjmp rowloop

	ret


swagMaster:
	subi	r21, 1
	cpi		r21, 1
	brge	swagMaster
	ret	
