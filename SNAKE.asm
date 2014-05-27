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

.def	ROW			= r16	// rad för rita ut matrisen
.def	COL			= r17	// kollumn för rita ut matrisen
.def	DIR			= r24	// maskens huvuds riktning
.def	LASTDIR		= r5	// senaste riktningen
.def	SNAKEX		= r22	// maskens huvuds x-kordinat
.def	SNAKEY		= r27	// maskens huvuds y-kordinat
.def	BODYX		= r21	// kroppens x-kordinat
.def	BODYY		= r19	// kroppens y-kordinat
.def	LENGTH		= r10	// maskens längd
.def	APPLEX		= r8	// äpplets x-kordinat
.def	APPLEY		= r9	// äpplets y-kordinat
.def	RAND		= r11	// slump

.CSEG
	
	.list
		rjmp      main
	// timer 1 avbrottsvektor
.ORG 0x0020
	jmp supermegatimer
	nop

	supermegatimer:
// räknare för positionsuppdatering
	subi	r26 , -1
	add		RAND , r26	// ändrar slumpen
	
// återställer timer
	ldi	 r16 , 0b00000001
	sts  TIMSK0, r16

// fyller utritningsmatrisen
	call	moveDot
	call	moveApple
	call	movebody

// kollar räknaren
	cpi		r26 , 0b00011110
	breq	supermove	// uppdaterar position

	reti

	supermove:
		call	joyXMovement	// uppdaterar riktningen
		ldi		r26 , 0b00000000
		ldi		r16 , 0

// hoppar till att flytta huvudet åt rätt håll 
		cpi		DIR, 0b00000001
		breq	moveRight

		cpi		DIR, 0b00000010
		breq	moveLeft

		cpi		DIR, 0b00001000
		breq	moveUp

		cpi		DIR, 0b00000100
		breq	moveDown

// flyttar huvudet
		moveRight:
			lsl		SNAKEX
			cpi		SNAKEX , 0
			brne	moveComplete
			ldi		SNAKEX , 0b00000001
			jmp		moveComplete

		moveLeft:
			lsr		SNAKEX
			brne	moveComplete
			ldi		SNAKEX , 0b10000000
			jmp		moveComplete

		moveUp:
			lsr		SNAKEY
			brne	moveComplete
			ldi		SNAKEY , 0b10000000
			jmp		moveComplete

		moveDown:
			lsl		SNAKEY
			brne	moveComplete
			ldi		SNAKEY , 0b000000001
			jmp		moveComplete

		moveComplete:
		call	moveBodyDir	// flyttar kroppen
			reti

// flyttar huvudet till utritningsmatrisen
	moveDot:
		ldi		r18, 0b00000001	// räknar upp genom matrisen
			// återställer pekaren
		ldi		ZL , low(matrix)
		ldi		ZH , high(matrix)

	call	checkApple	// kollar kollision mellan äpplet och huvudet

	// går igenom matrisen i y-led
		moveDotUpdate:
			mov		r16 , SNAKEY
			and		r16 , r18
		// om huvudet har hittats ska det flyttas till matrisen
			cpi		r16 , 0b00000000
			brne	enterthematrix	

			jmp pastenter	// hoppar över
			enterthematrix:

				st		Z+, SNAKEX	// skriver ut huvudet i matrisen

			jmp pastpast	// hoppar över

		// rensar matrisen
			pastenter:
				ldi		r16, 0b00000000
				st		Z+, r16

			pastpast:
		// räknar upp räknaren, ifall den räknat förbi 8 (räknat igenom matrisen) är loopen klar
			lsl		r18
			cpi		r18, 0b00000000
			brne	moveDotUpdate

		call	checkApple	// kollar ifall äpplet har plockats upp
		ret

// flyttar över kroppen till matrisen
	movebody:
		ldi		r25 , 0

	// pekare till riktningsmatrisen
		ldi		YL , low(wormbodydir)
		ldi		YH , high(wormbodydir)
		ld		r18, Y+

		mov		r6 , BODYX
		mov		r7 , BODYY

		bodyloop:
		ldi		r23, 0b00000001	// räknare
	// pekare till utritningsmatrisen
		ldi		ZL , low(matrix)
		ldi		ZH , high(matrix)

		supermovebodyloop:
		// kollar nuvarande kroppsdelsrad mot utritningsmatrisen
			mov		r16 , BODYY
			and		r16 , r23

		// om det finns något där, lägg det i matrisen 
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

			lsl		r23
			cpi		r23, 0b00000000
			brne	supermovebodyloop
			
			call drawBodyDir


			subi	r25 , -1
			cp		r25 , LENGTH

			brne	bodyloop
			
		mov		BODYX , r6
		mov		BODYY , r7
	ret


	drawBodyDir:

	cp		BODYX , SNAKEX
	brne	cleared

	cp		BODYY , SNAKEY
	brne	cleared

	call ded

	cleared:
	
	aplleloop2:
			
		cp		BODYX , APPLEX
		brne	endchek2
		
		cp		BODYY , APPLEY
		brne	endchek2

		call	getApple
		jmp		aplleloop2

		endchek2:
		
		ld		r18 , Y+
		// Check last direction		
		cpi		r18, 0b00000001
		breq	moveBodyRight

		cpi		r18, 0b00000010
		breq	moveBodyLeft

		cpi		r18, 0b00001000
		breq	moveBodyUp

		cpi		r18, 0b00000100
		breq	moveBodyDown

		// Move snake head
		moveBodyRight:
			lsr		BODYX
			cpi		BODYX , 0
			brne	aplleloop
			mov		r18 , BODYX
			ldi		r18 , 0b10000000
			mov		BODYX , r18
			jmp		aplleloop

		moveBodyLeft:
			lsl		BODYX
			cpi		BODYX , 0
			brne	aplleloop
			mov		r18 , BODYX
			ldi		r18 , 0b00000001
			mov		BODYX , r18
			jmp		aplleloop

		moveBodyUp:
			lsl		BODYY
			cpi		BODYY , 0
			brne	aplleloop
			mov		r18 , BODYY
			ldi		r18 , 0b00000001
			mov		BODYY , r18
			jmp		aplleloop

		moveBodyDown:
			lsr		BODYY
			cpi		BODYY , 0
			brne	aplleloop
			mov		r18 , BODYY
			ldi		r18 , 0b10000000
			mov		BODYY , r18
			jmp		aplleloop



		aplleloop:
		/*	
		cp		BODYX , APPLEX
		brne	endchek
		
		cp		BODYY , APPLEY
		brne	endchek

		call	getApple
		jmp		aplleloop
		*/
		endchek:

	ret

	moveBodyDir:
		ldi		YL , low(wormbodydir)
		ldi		YH , high(wormbodydir)
		ld		r18, Y+
		ld		r18, Y+

		// Check last direction		
		cpi		r18, 0b00000001
		breq	moveBodyRight2

		cpi		r18, 0b00000010
		breq	moveBodyLeft2

		cpi		r18, 0b00001000
		breq	moveBodyUp2

		cpi		r18, 0b00000100
		breq	moveBodyDown2

		// Move snake head
		moveBodyRight2:
			lsl		BODYX
			cpi		BODYX , 0
			brne	aplleloop
			mov		r18 , BODYX
			ldi		r18 , 0b00000001
			mov		BODYX , r18
			ret

		moveBodyLeft2:
			lsr		BODYX
			cpi		BODYX , 0
			brne	aplleloop
			mov		r18 , BODYX
			ldi		r18 , 0b10000000
			mov		BODYX , r18
			ret

		moveBodyUp2:
			lsr		BODYY
			cpi		BODYY , 0
			brne	aplleloop
			mov		r18 , BODYY
			ldi		r18 , 0b10000000
			mov		BODYY , r18
			ret

		moveBodyDown2:
			lsl		BODYY
			cpi		BODYY , 0
			brne	aplleloop
			mov		r18 , BODYY
			ldi		r18 , 0b00000001
			mov		BODYY , r18
			ret

	moveBodyComplete:
	ret

	getApple:

		lds		r18, ADMUX
	
		cbr		r18 , 0b00001111
		sbr		r18 , 0b00000100
		//sbr		r18, 1<<5
		sbr		r18, 1<<7

		sts		ADMUX, r18
	
		// Start conversion
		lds		r28, ADCSRA

		sbr		r28, 1<<6
		sbr		r28, 1<<7

		sts		ADCSRA, r28

		tempY5:
		// Wait for convertion
		lds		r28, ADCSRA
		sbrc	r28, 6
		jmp		tempY5
		// Output result
		lds		r28 , ADCL
		lds		r20, ADCH

		add		RAND , r28
		lsr		RAND

		mov		r28 , RAND
		andi	r28 , 0b00001111
		//or		r28 , r20
		mov		RAND , r28

		// gör om till bit
		ldi		r20 , 0
		ldi		r18 , 1
		mov		r28 , RAND
		subi	r28 , -1
		cpi		r28 , 0
		brne	valuetobit
		ldi		r28 , 1

		valuetobit:

			lsl		r18
			subi	r20 , -1
			cp		r20 , r28
			brne	valuetobit
			cpi		r18 , 0

		brne	skipnoll

		ldi		r18 , 1

		skipnoll:

		mov		APPLEX , r18

		call	swagmaster

		starty:
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

		tempY55:
		// Wait for convertion
		lds		r28, ADCSRA
		sbrc	r28, 6
		jmp		tempY55
		// Output result
		lds		r28 , ADCL
		lds		r20, ADCH

		add		RAND , r28
		lsr		r28

		mov		r28 , RAND
		andi	r28 , 0b00001111
		//or		r28 , r20
		mov		RAND , r28

		ldi		r20 , 0
		ldi		r18 , 1

		mov		r28 , RAND
		subi	r28 , -1
		mul		r28 , RAND
		add		r28 , r1
		add		r28 , APPLEY
		
		cpi		r28 , 0
		brne	valuetobit5
		ldi		r28 , 1

		valuetobit5:

		lsl		r18

		subi	r20 , -1
		cp		r20 , r28
		brne	valuetobit5

		cpi		r18 , 0
		brne	skipnoll5

		ldi		r18 , 1

		skipnoll5:
		mov		APPLEY , r18

	ret

	moveApple:

		ldi		r18, 0b00000001
		ldi		ZL , low(matrix)
		ldi		ZH , high(matrix)


		moveAppleUpdate:
			mov		r16 , APPLEY
			and		r16 , r18

			cpi		r16 , 0b00000000
			brne	entertheapplematrix	

			jmp pastappleenter
			entertheapplematrix:

				ld		r16 , Z
				or		r16 , APPLEX
				st		Z+, r16

			jmp pastapplepast
			pastappleenter:
			
				ld		r16, Z
				st		Z+, r16
				
			pastapplepast:

			lsl		r18
			cpi		r18, 0b00000000
			brne	moveAppleUpdate
	ret

	checkApple:
		
		cp		APPLEX , SNAKEX
		brne	noapple
		cp		APPLEY , SNAKEY
		brne	noapple

		mov		r18 , LENGTH
		subi	r18 , -1
		mov		LENGTH , r18
		
		appleloop:
		call	swagmaster

		call	getApple
		
		cp		APPLEX , SNAKEX
		brne	noapple
		cp		APPLEY , SNAKEY
		breq	appleloop

		noapple:
	ret

main:
	
	ldi		r16, HIGH(RAMEND)
	out		SPH, r16
	ldi		r16, LOW(RAMEND)
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

	ldi		r16 , 3
	mov		LENGTH , r16

	// äpple
	ldi		r16 , 0b01000000
	mov		APPLEX , r16
	ldi		r16 , 0b01000000
	mov		APPLEY , r16
	call getapple
	
	ldi		SNAKEX, 0b00001000
	ldi		SNAKEY, 0b00001000
	
	ldi		BODYX, 0b00000100
	ldi		BODYY, 0b00001000

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

	ldi		ZL , low(wormbodydir)
	ldi		ZH , high(wormbodydir)

	mov	    r18, r26
	st		Z+, r18
	ldi		r18, 0b00000100
	st		Z+, r18
	ldi		r18, 0b00000001
	st		Z+, r18
	ldi		r18, 0b00000010
	st		Z+, r18
	ldi		r18, 0b00000100
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18
	ldi		r18, 0b00000000
	st		Z+, r18


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

		jmp updateColD

joyXMovement:
	mov		LASTDIR , DIR

	ldi		YL , low(wormbodydir)
	ldi		YH , high(wormbodydir)
	
	st		Y, DIR
	
	ldi		r18, 0
	iteratePositionLoop:
		
		ld		r16, Y+

		push	r16
		subi	r18, -1

		mov		r16 , LENGTH
		subi	r16 , -1
		cp		r18, r16

	brne	iteratePositionLoop
	
		pop		r18
		ldi		r18, 0

	iteratePositionLoop2:
		
		pop		r16
		st		-Y, r16
		

		subi	r18, -1
		
		cp		r18, LENGTH

		brne	iteratePositionLoop2
	
	st		Y, DIR


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

	add		RAND , r20

	cpi		r20, 0b00000100
	brlo	right
	cpi		r20, 0b00001000
	brsh	left

	//ldi		DIR, 0b00000000
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
	
	add		RAND , r20

	cpi		r20, 0b00000100
	brlo	down
	cpi		r20, 0b00010000
	brsh	up

	jmp		pastup

	down:
	cpi		DIR , 0b00001000
	breq	pastup
	ldi		DIR , 0b00000100
	jmp		pastup
	up:
	mov		DIR , LASTDIR
	cpi		DIR , 0b00000100
	breq	pastup
	ldi		DIR , 0b00001000
	pastup:

	cpi		DIR , 0b000000000
	breq	last
	jmp	pastlast
	last:
	mov		DIR , LASTDIR
	pastlast:

	mov		LASTDIR , DIR

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

ded:
	ldi	SNAKEX , 0
	ldi	SNAKEY , 0

jmp ded
ret