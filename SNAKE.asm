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

.def	ROW = r16
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

		// så att vi kan använda portarna
    ldi		r16,0xFF
    out		DDRB,r16
	out		DDRC,r16
	out		DDRD,r16
	
		// till swagmaster
	ldi		r21, 255

		// matris
	ldi		ZL , low(matrix)
	ldi		ZH , high(matrix)
	ldi		r18, 0b00000001
	st		Z+, r18
	ldi		r18, 0b00000001
	st		Z+, r18
	ldi		r18, 0b00000001
	st		Z+, r18
	ldi		r18, 0b00000001
	st		Z+, r18
	ldi		r18, 0b00000001
	st		Z+, r18
	ldi		r18, 0b00000001
	st		Z+, r18
	ldi		r18, 0b00000001
	st		Z+, r18
	ldi		r18, 0b00000001
	st		Z+, r18
	ldi		ZL , low(matrix)
	ldi		ZH , high(matrix)
	ld		r23 , Z		// värdet i matris ligger i r23

	ldi		r20 , 0
	
	ldi		ROW , 0b00000001

update:

	ld		r23 , Z+	// värdet i matris ligger i r23
	
	cpi		ROW , 0b00000000
	breq	reset
	cpi		r23	, 1
	brlt	blank

// fyller hela raden
	ldi		r17 , 0b11000000
	ldi		r18 , 0b00111111
	
	// går förbi gränsen för port D
	cpi		ROW , 0b00010000
	brge	printD
	// skippar denna annars
	cpi		ROW , 0b10000000
	breq	printD

		// print c
			out		PORTC , ROW
			out		PORTD , r17
			out		PORTB , r18
		jmp pastD

		printD:
			lsr		ROW
			lsr		ROW
			or		r17 , ROW
			out		PORTD , r17
			out		PORTB , r18
			lsl		ROW
			lsl		ROW

	pastD:
	lsl		ROW
	
	cpi		ROW , 0b00000000
	breq	reset

	jmp	update

	reset:
			// återställer
		ldi		ROW , 0b00000001
		
		ldi		ZL , low(matrix)
		ldi		ZH , high(matrix)
	jmp update
	blank:
		lsl		ROW
	jmp update

jmp main

swagMaster:
	subi	r21, 1
	cpi		r21, 1
	brge	swagMaster
	ret	
