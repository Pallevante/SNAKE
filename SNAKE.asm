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
.def	COL = r17
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

		// s� att vi kan anv�nda portarna
    ldi		r16,0xFF
    out		DDRB,r16
	out		DDRC,r16
	out		DDRD,r16
	
		// till swagmaster
	ldi		r21, 255

		// matris
	ldi		ZL , low(matrix)
	ldi		ZH , high(matrix)
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		r18, 0b00110110
	st		Z+, r18
	ldi		r18, 0b01111111
	st		Z+, r18
	ldi		r18, 0b01111111
	st		Z+, r18
	ldi		r18, 0b00111110
	st		Z+, r18
	ldi		r18, 0b00011100
	st		Z+, r18
	ldi		r18, 0b00001000
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

	
	blank:
		lsl		ROW
	jmp update
	reset:
			// �terst�ller
		ldi		ROW , 0b00000001
		ldi		COL , 0b00000001
		
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
			rjmp	pastColD

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
				call swagmaster
				call swagmaster
				call swagmaster
				call swagmaster
				call swagmaster
				call swagmaster

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



			rjmp	pastColDD

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
				call swagmaster
				call swagmaster
				call swagmaster
				call swagmaster
				call swagmaster
				call swagmaster

		jmp updateColD

	jmp pastD

jmp main

swagMaster:
	subi	r21, 1
	cpi		r21, 1
	brge	swagMaster
	ret	