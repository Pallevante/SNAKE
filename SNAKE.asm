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
.def	joystickX	= r24
.def	joystickY	= r25
.def	rTemp		= r26

.CSEG
	.list
		rjmp      main

.ORG 0x0020
//Trooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooor detta fungerar... kanske
	timer: 
		lds  rTemp, TCCR0B     // timer prescaling
		sbr  rTemp, ((1 << CS02) | (0 << CS01) | (1 << CS00))
		cbr  rTemp, (1 << CS01)
		sts  TCCR0B, rTemp
		lds  rTemp, TIMSK0     // start timer
		sbr  rTemp, (1 << TOIE0)
		sts  TIMSK0, rTemp
		sei



main:
	
		// så att vi kan använda portarna
    ldi		r16,0xFF
    out		DDRB,r16
	out		DDRC,r16
	out		DDRD,r16

	ldi		r21 , 0x00

	out		REFS0 , r16
	out		REFS1 , r21
	out		ADPS0 , r16
	out		ADPS1 , r16
	out		ADPS2 , r16
	out		ADEN , r16

	
		// till swagmaster
	ldi		r21, 255

		// matris
	ldi		ZL , low(matrix)
	ldi		ZH , high(matrix)

	ldi		r18, 0b01000010
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		r18, 0b11111111
	st		Z+, r18
	ldi		r18, 0b10000001
	st		Z+, r18
	ldi		r18, 0b01000010
	st		Z+, r18
	ldi		r18, 0b00111100
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		ZL , low(matrix)
	ldi		ZH , high(matrix)
	ld		r23 , Z		// värdet i matris ligger i r23
	
	ldi		r21 , 0b00000000

		// börjar kolla från första raden
	ldi		ROW , 0b00000001
	ldi		COL , 0b00000001

	
	blank:
		lsl		ROW
	jmp update
	reset:
			// återställer
		ldi		ROW , 0b00000001
		ldi		COL , 0b00000001
		
		ldi		ZL , low(matrix)
		ldi		ZH , high(matrix)

		//Anroppar joyMovement som kollar om man rör joysticken
		call	joyXMovement

		
			// återställer
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
	ld		r23 , Z+	// värdet i matris ligger i r23
// sista raden
	cpi		ROW , 0b00000000
	breq	reset
// tom rad
	cpi		r23	, 0
	breq	blank
	
	// går förbi gränsen för port D
	cpi		ROW , 0b00010000
	brge	printD
	// fixar bugg, har med signed att göra tror jag
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
				call swagMaster
				call swagMaster
				call swagMaster
				call swagMaster
				call swagMaster
				call swagMaster

		jmp updateColD

	jmp pastD

jmp main

joyXMovement:
	lds		r18 , ADMUX
	andi	r18 , 0xF0
	ori		r18 , 5		//x
	sts		ADMUX , r18

	lds		r18 , ADCSRA
	sbr		r18 , 1<<6
	sts		ADCSRA , r18

	lds		r18 , ADCSRA
	sbrc	r18 , 6
	lds		r19 , ADCL
	lds		r18 , ADCH

	ldi		r21 , 0b01010101
	st		Z , r19

	jmp		return
	/*
JoyYMovement:
	in		r25, PORTC
	ldi		r18, 0b00000000
	st		Z+, r18
	cpi		r25, 0
	breq	return
	ldi		r18, 0b00001101
	st		Z+, r18
	jmp		return	*/

return:
	ret

swagMaster:
	subi	r21, 1
	cpi		r21, 1
	brge	swagMaster
	ret	