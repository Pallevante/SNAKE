/*
 * SNAKE.asm
 *
 *  Created: 2014-04-25 08:02:33
 *   Author: b13petha
 *   Slaves: Simon, Henrik och Von Thundercunt af Twatsylvania
 */
 .include "m328Pdef.inc"

 .DSEG
	//Fuck all.
	matrix:
		.byte	8

	wormbodydir:
		.byte	63

.def	ROW			= r16
.def	COL			= r17
.def	DIR			= r24
.def	LASTDIR		= r25
.def	SNAKEX		= r22
.def	SNAKEY		= r27
.def	BODYX		= r21
.def	BODYY		= r19

.CSEG
	
	.list
		rjmp      main
		
.ORG 0x0020
	jmp supermegatimer
	nop

	supermegatimer:
	call swagmaster
	call swagmaster
	call swagmaster
	call swagmaster
	call swagmaster
	subi	r26 , -1
	
	lds  r16, TIMSK0     // start timer
	ldi	 r16 , 0b00000001
	sts  TIMSK0, r16

	call	moveDot
	call	movebody

	cpi		r26 , 0b00111110
	breq	mklmkl

	reti

	mklmkl:
		call	joyXMovement
		ldi		r26 , 0b00000000

		// Check last direction
		
		cpi		DIR, 0b00000001
		breq	moveRight

		cpi		DIR, 0b00000010
		breq	moveLeft

		cpi		DIR, 0b00001000
		breq	moveUp

		cpi		DIR, 0b00000100
		breq	moveDown

		// Move snake head
		moveRight:
			lsl		SNAKEX
			jmp		moveComplete

		moveLeft:
			lsr		SNAKEX
			jmp		moveComplete

		moveUp:
			lsr		SNAKEY
			jmp		moveComplete

		moveDown:
			lsl		SNAKEY
			jmp		moveComplete

			//call moveBodyDir

		moveComplete:
		call moveBodyDir
			reti

	moveDot:
		ldi		r18, 0b00000001
		ldi		ZL , low(matrix)
		ldi		ZH , high(matrix)


		moveDotUpdate:
			mov		r16 , SNAKEY
			and		r16 , r18

			cpi		r16 , 0b00000000
			brne	enterthematrix	

			jmp pastenter
			enterthematrix:

				st		Z+, SNAKEX

			jmp pastpast
			pastenter:
			
				ldi		r16, 0b00000000
				st		Z+, r16

			pastpast:

			lsl		r18
			cpi		r18, 0b00000000
			brne	moveDotUpdate

		ret

	movebody:
		
		ldi		r18, 0b00000001
		ldi		ZL , low(matrix)
		ldi		ZH , high(matrix)


		superdupermega:
			mov		r16 , BODYY
			and		r16 , r18

			cpi		r16 , 0b00000000
			brne	enterthebodymatrix	

			jmp pastbodyenter
			enterthebodymatrix:
				ld		r16 , Z
				or		r16 , BODYX
				st		Z+, r16

			jmp pastbodypast
			pastbodyenter:
			
				ld		r16 , Z
				st		Z+, r16

			pastbodypast:

			lsl		r18
			cpi		r18, 0b00000000
			brne	superdupermega

	ret

	moveBodyDir:
		// Check last direction		
		cpi		LASTDIR, 0b00000001
		breq	moveBodyRight

		cpi		LASTDIR, 0b00000010
		breq	moveBodyLeft

		cpi		LASTDIR, 0b00001000
		breq	moveBodyUp

		cpi		LASTDIR, 0b00000100
		breq	moveBodyDown

		// Move snake head
		moveBodyRight:
			lsl		BODYX
			jmp		moveBodyComplete

		moveBodyLeft:
			lsr		BODYX
			jmp		moveBodyComplete

		moveBodyUp:
			lsr		BODYY
			jmp		moveBodyComplete

		moveBodyDown:
			lsl		BODYY
			jmp		moveBodyComplete

	jmp moveBodyComplete

	moveBodyComplete:
	ret


main:
	
	ldi		r16, HIGH(RAMEND)
	out		SPH, r16
	ldi		r16, LOW(RAMMEND)
	out		SPL, r16

	timer: 
		lds  r16, TCCR0B     // timer prescaling
		ori	 r16, 0b00000101
		out  TCCR0B, r16
		sei
		lds  r16, TIMSK0     // start timer
		ldi	 r16, 0b00000001
		sts  TIMSK0, r16

		// så att vi kan använda portarna
    ldi		r16,0xFF
    out		DDRB,r16
	out		DDRC,r16
	out		DDRD,r16

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
	
	ldi		SNAKEX, 0b00001000
	ldi		SNAKEY, 0b00001000
	
	ldi		BODYX, 0b00000100
	ldi		BODYY, 0b00001000

	ldi		LASTDIR , 0b00000100
	ldi		r26 , 2

		// matris
	ldi		ZL , low(matrix)
	ldi		ZH , high(matrix)

	mov	    r18, r26
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
	ld		r23 , Z		// värdet i matris ligger i r23
	

		// börjar kolla från första raden
	ldi		ROW , 0b00000001
	ldi		COL , 0b00000001
	joyupdate:
	ldi		ZL , low(matrix)
	ldi		ZH , high(matrix)
	
	jmp		reset
	
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
		//call	joyXMovement	
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
			ldi		r29 , 0b00000000

			cpi		COL , 0b00000010
			breq	printColD
			cpi		COL , 0b00000001
			breq	printColD
			// printColB
			lsr		r18
			lsr		r18
			out		PORTC , ROW
			out		PORTD , r29
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
				out		PORTB , r29

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
			ldi		r29 , 0b00000000

			cpi		COL , 0b00000010
			breq	printColDD
			cpi		COL , 0b00000001
			breq	printColDD
			// printColB
			lsr		r18
			lsr		r18

			lsr		ROW
			lsr		ROW
			out		PORTC , r29
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
			mov		r28 , ROW
			or		r28 , r18
			out		PORTC , r29
			out		PORTD , r28
			out		PORTB , r29
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
mov		LASTDIR , DIR

		ldi		ZL , low(matrix)
		ldi		ZH , high(matrix)

	// Set source
	lds		r18, ADMUX
	
	cbr		r18 , 0b00001111
	sbr		r18 , 0b00000101
	sbr		r18, 1<<5
	sbr		r18, 1<<7

	sts		ADMUX, r18
	
	// Start conversion
	lds		r28, ADCSRA

	sbr		r28, 1<<6
	sbr		r28, 1<<7

	sts		ADCSRA, r28

	tempX:
	// Wait for convertion
	lds		r28, ADCSRA
	sbrc	r28, 6
	jmp		tempX


	// Output result
	lds		r28 , ADCL
	lds		r20, ADCH

	cpi		r20, 0b00000100
	brlo	right
	cpi		r20, 0b00001000
	brsh	left

	ldi		DIR, 0b00000000
	jmp		pastleft

	/*
		Comparen innan ldi i dessa subrutiner kollar
		ifall snakey redan går åt motsatta håll. 
		Detta för att man inte ska kunna gå igenom
		ormen igen och direkt förlora.
	*/
	right:
	cpi		DIR	, 0b0000010
	breq	pastleft
	ldi		DIR , 0b0000001
	jmp		pastleft

	left:
	cpi		DIR , 0b0000001
	breq	pastleft
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
	lds		r28, ADCSRA

	sbr		r28, 1<<6
	sbr		r28, 1<<7

	sts		ADCSRA, r28

	tempY:
	// Wait for convertion
	lds		r28, ADCSRA
	sbrc	r28, 6
	jmp		tempY
	// Output result
	lds		r28 , ADCL
	lds		r20, ADCH
	/*
		Comparen nedan i dessa subrutiner kollar
		ifall snakey redan går åt något av dessa håll. 
		Detta för att man inte ska kunna gå igenom
		ormen igen och direkt förlora.
	*/
	cpi		r20, 0b00000100
	sbrs	DIR , 3
	brlo	down
	cpi		r20, 0b00010000
	sbrs	DIR , 2
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
	
	
	//st		Z , DIR

return:
	ret
	
	swagMaster:

	call swagmaster2
	call swagmaster2
	call swagmaster2
	call swagmaster2
	call swagmaster2
	call swagmaster2
	call swagmaster2
	call swagmaster2
	ret


	swagmaster2:
	
	subi	r18, 1
	cpi		r18, 1
	breq	swagMaster2

	ret