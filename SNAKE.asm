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

.def	ROW			= r16
.def	COL			= r17
.def	DIR			= r24
.def	LASTDIR		= r25

.CSEG
	
	.list
		rjmp      main

		
.ORG 0x0020
//Trooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooor detta fungerar... kanske
	jmp test
	nop

	test:
	
	ldi		r18, 0b01111000
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		r18, 0b00011000
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		r18, 0b11111000
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		ZL , low(matrix)
	ldi		ZH , high(matrix)
	ld		r23 , Z		// v�rdet i matris ligger i r23
	jmp update
main:
	timer: 
		lds  r21, TCCR0B     // timer prescaling
		sbr  r21, ((1 << CS02) | (1 << CS00))
		cbr  r21, (1 << CS01)
		sts  TCCR0B, r21
		lds  r21, TIMSK0     // start timer
		sbr  r21, (1 << TOIE0)
		
		ori	 r21 , 0b00000001
		sts  TIMSK0, r21
		sei

		// s� att vi kan anv�nda portarna
    ldi		r16,0xFF
    out		DDRB,r16
	out		DDRC,r16
	out		DDRD,r16

	ldi		r21 , 0x00
	//ldi		rtemp , 0

	
	lds		r16 , ADMUX
	sbr		r16 , 1<<6
	sbr		r16 , 0<<7
	sts		ADMUX , r16
	lds		r16 , ADCSRA
	sbr		r16 , 1<<0
	sbr		r16 , 1<<1
	sbr		r16 , 1<<2
	sbr		r16 , 1<<7
	sts		ADCSRA , r16
	
	
		// till swagmaster
	ldi		r21, 255

	ldi		LASTDIR , 0b00000001

		// matris
	ldi		ZL , low(matrix)
	ldi		ZH , high(matrix)

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
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		ZL , low(matrix)
	ldi		ZH , high(matrix)
	ld		r23 , Z		// v�rdet i matris ligger i r23
	
	ldi		r21 , 0b00000000

		// b�rjar kolla fr�n f�rsta raden
	ldi		ROW , 0b00000001
	ldi		COL , 0b00000001
	joyupdate:
	ldi		ZL , low(matrix)
	ldi		ZH , high(matrix)

	//Anroppar joyMovement som kollar om man r�r joysticken
	call	joyXMovement
	jmp		reset
	
	blank:
		lsl		ROW
	jmp update
	reset:
			// �terst�ller
		ldi		ROW , 0b00000001
		ldi		COL , 0b00000001
		ldi		ZL , low(matrix)
		ldi		ZH , high(matrix)

		//Anroppar joyMovement som kollar om man r�r joysticken
		call	joyXMovement	
		ldi		ZL , low(matrix)
		ldi		ZH , high(matrix)

	jmp update
	
	pastD:
		// byter rad
	lsl		ROW
	jmp	update

update:

	ldi		COL , 0b00000001
	ld		r23 , Z+	// v�rdet i matris ligger i r23
// sista raden
	cpi		ROW , 0b00000000
	breq	reset
// tom rad
	cpi		r23	, 0
	breq	blank
	
	// g�r f�rbi gr�nsen f�r port D
	cpi		ROW , 0b00010000
	brge	printD
	// fixar bugg, har med signed att g�ra tror jag
	cpi		ROW , 0b10000000
	breq	printD
		// print c
		updateCol:
			cpi		COL , 0b00000000
			breq	pastD

			mov		r18 , COL
			and		r18 , r23
				// r0 verkar bugga
			ldi		r21 , 0b00000000

			cpi		COL , 0b00000010
			breq	printColD
			cpi		COL , 0b00000001
			breq	printColD
			// printColB
			lsr		r18
			lsr		r18
			out		PORTC , ROW
			out		PORTD , r21
			out		PORTB , r18
			jmp	pastColD

		printColD:
				lsl		r18
				lsl		r18
				lsl		r18
				lsl		r18
				lsl		r18
				lsl		r18
				out		PORTC , ROW
				out		PORTD , r18
				out		PORTB , r21

		pastColD:
				lsl		COL
				//	ju fler swagmasters, destu ljusare
				call swagMaster
				call swagMaster
				call swagMaster
				call swagMaster
				call swagMaster
				call swagMaster
				call swagMaster
				call swagMaster
				call swagMaster

		jmp updateCol

		printD:

		updateColD:
			cpi		COL , 0b00000000
			breq	pastD

			mov		r18 , COL
			and		r18 , r23
				// r0 verkar bugga
			ldi		r21 , 0b00000000

			cpi		COL , 0b00000010
			breq	printColDD
			cpi		COL , 0b00000001
			breq	printColDD
			// printColB
			lsr		r18
			lsr		r18

			lsr		ROW
			lsr		ROW
			out		PORTC , r21
			out		PORTD , ROW
			out		PORTB , r18
			lsl		ROW
			lsl		ROW

			jmp	pastColDD

		printColDD:
				lsl		r18
				lsl		r18
				lsl		r18
				lsl		r18
				lsl		r18
				lsl		r18

			lsr		ROW
			lsr		ROW
			mov		r19 , ROW
			or		r19 , r18
			out		PORTC , r21
			out		PORTD , r19
			out		PORTB , r21
			lsl		ROW
			lsl		ROW

		pastColDD:
				lsl		COL
				//	ju fler swagmasters, destu ljusare
				call swagMaster
				call swagMaster
				call swagMaster
				call swagMaster
				call swagMaster
				call swagMaster
				call swagMaster
				call swagMaster
				call swagMaster

		jmp updateColD

joyXMovement:

	// Set source
	lds		r18, ADMUX
	
	cbr		r18 , 0b00001111
	sbr		r18 , 0b00000101
	sbr		r18, 1<<5
	sbr		r18, 1<<7

	sts		ADMUX, r18
	
	// Start conversion
	lds		r19, ADCSRA

	sbr		r19, 1<<6
	sbr		r19, 1<<7

	sts		ADCSRA, r19

	tempX:
	// Wait for convertion
	lds		r19, ADCSRA
	sbrc	r19, 6
	jmp		tempX


	// Output result
	lds		r19 , ADCL
	lds		r20, ADCH

	cpi		r20, 0b00000010
	brlo	right
	cpi		r20, 0b00001000
	brsh	left

	ldi		DIR, 0b00000000
	jmp		pastleft

	right:
	ldi		DIR , 0b0000001
	jmp		pastleft
	left:
	ldi		DIR , 0b0000010
	pastleft:

JoyYMovement:
	// Set source
	lds		r18, ADMUX
	
	cbr		r18 , 0b00001111
	sbr		r18 , 0b00000100
	//sbr		r18, 1<<5
	sbr		r18, 1<<6

	sts		ADMUX, r18
	
	// Start conversion
	lds		r19, ADCSRA

	sbr		r19, 1<<6
	sbr		r19, 1<<7

	sts		ADCSRA, r19

	tempY:
	// Wait for convertion
	lds		r19, ADCSRA
	sbrc	r19, 6
	jmp		tempY
	// Output result
	lds		r19 , ADCL
	lds		r20, ADCH


	cpi		r20, 0b00000100
	brlo	down
	cpi		r20, 0b00010000
	brsh	up

	jmp		pastup

	down:
	ldi		DIR , 0b0000100
	jmp		pastup
	up:
	ldi		DIR , 0b0001000
	pastup:

	cpi		DIR , 0b00000000
	breq	last
	jmp	pastlast
	last:
	mov		DIR , LASTDIR
	pastlast:
	
	mov		LASTDIR , DIR

	st		Z , DIR

return:
	ret
	
	swagMaster:

	call swagmaster2
	call swagmaster2
	ret


	swagmaster2:
	
	subi	r21, 1
	cpi		r21, 1
	breq	swagMaster2

	ret