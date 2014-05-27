/*
 * SNAKE.asm
 *
 *  Created: 2014-04-25 08:02:33
 *   Authors: Henrik Smedberg, Peter H�kanson, Mattias Andersson, Simon Hedstr�m
 */
 .include "m328Pdef.inc"

 .DSEG
 // Utritningsmatris
	matrix:
		.byte	8
// array med riktningar f�r kroppsdelar
	wormbodydir:
		.byte	63

.def	ROW			= r16	// rad f�r rita ut matrisen
.def	COL			= r17	// kollumn f�r rita ut matrisen
.def	DIR			= r24	// maskens huvuds riktning
.def	LASTDIR		= r5	// senaste riktningen
.def	SNAKEX		= r22	// maskens huvuds x-kordinat
.def	SNAKEY		= r27	// maskens huvuds y-kordinat
.def	BODYX		= r21	// kroppens x-kordinat
.def	BODYY		= r19	// kroppens y-kordinat
.def	LENGTH		= r10	// maskens l�ngd
.def	APPLEX		= r8	// �pplets x-kordinat
.def	APPLEY		= r9	// �pplets y-kordinat
.def	RAND		= r11	// slump

.CSEG
	
	.list
		rjmp      main
	// timer 1 avbrottsvektor
.ORG 0x0020
	jmp supermegatimer
	nop

	supermegatimer:
// r�knare f�r positionsuppdatering
	subi	r26 , -1
	add		RAND , r26	// �ndrar slumpen
	
// �terst�ller timer
	ldi	 r16 , 0b00000001
	sts  TIMSK0, r16

// fyller utritningsmatrisen
	call	moveDot
	call	moveApple
	call	movebody

// kollar r�knaren
	cpi		r26 , 0b00011110
	breq	supermove	// uppdaterar position

	reti

	supermove:
		call	joyXMovement	// uppdaterar riktningen
		ldi		r26 , 0b00000000
		ldi		r16 , 0

// hoppar till att flytta huvudet �t r�tt h�ll 
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
			lsl		SNAKEX				// flyttar positionen �r r�tt h�ll
			cpi		SNAKEX , 0			// kollar ifall den �r utanf�r kanten
			brne	moveComplete		// hoppar ut om den inte �r det
		// flyttar positionen till andra sidan om man �kt utanf�r kanten
			ldi		SNAKEX , 0b00000001
			jmp		moveComplete

		moveLeft:
			lsr		SNAKEX
			cpi		SNAKEX , 0
			brne	moveComplete
			ldi		SNAKEX , 0b10000000
			jmp		moveComplete

		moveUp:
			lsr		SNAKEY
			cpi		SNAKEY , 0
			brne	moveComplete
			ldi		SNAKEY , 0b10000000
			jmp		moveComplete

		moveDown:
			lsl		SNAKEY
			cpi		SNAKEY , 0
			brne	moveComplete
			ldi		SNAKEY , 0b000000001
			jmp		moveComplete

		moveComplete:
		call	moveBodyDir	// flyttar kroppen
			reti

// flyttar huvudet till utritningsmatrisen
	moveDot:
		ldi		r18, 0b00000001	// r�knar upp genom matrisen
			// �terst�ller pekaren
		ldi		ZL , low(matrix)
		ldi		ZH , high(matrix)

	call	checkApple	// kollar kollision mellan �pplet och huvudet

	// g�r igenom matrisen i y-led
		moveDotUpdate:
			mov		r16 , SNAKEY
			and		r16 , r18
		// om huvudet har hittats ska det flyttas till matrisen
			cpi		r16 , 0b00000000
			brne	enterthematrix	

			jmp pastenter	// hoppar �ver
			enterthematrix:

				st		Z+, SNAKEX	// skriver ut huvudet i matrisen

			jmp pastpast	// hoppar �ver

		// rensar matrisen
			pastenter:
				ldi		r16, 0b00000000
				st		Z+, r16

			pastpast:
		// r�knar upp r�knaren, ifall den r�knat f�rbi 8 (r�knat igenom matrisen) �r loopen klar
			lsl		r18
			cpi		r18, 0b00000000
			brne	moveDotUpdate

		call	checkApple	// kollar ifall �pplet har plockats upp
		ret

// flyttar �ver kroppen till matrisen
	movebody:
		ldi		r25 , 0

	// pekare till riktningsmatrisen
		ldi		YL , low(wormbodydir)
		ldi		YH , high(wormbodydir)
		ld		r18, Y+

		mov		r6 , BODYX
		mov		r7 , BODYY

		bodyloop:
		ldi		r23, 0b00000001	// r�knare
	// pekare till utritningsmatrisen
		ldi		ZL , low(matrix)
		ldi		ZH , high(matrix)

		supermovebodyloop:
		// kollar nuvarande kroppsdelsrad mot utritningsmatrisen
			mov		r16 , BODYY
			and		r16 , r23

		// om det finns n�got d�r, l�gg det i matrisen 
			cpi		r16 , 0b00000000
			brne	enterthebodymatrix	
			jmp pastbodyenter
		// flyttar kroppsdelen till matrisen
			enterthebodymatrix:
				ld		r16 , Z
				or		r16 , BODYX
				st		Z+, r16
			jmp pastbodypast	// hoppar f�rbi

			pastbodyenter:
			
				ld		r16 , Z
				st		Z+, r16

		// stegar upp
			pastbodypast:
			// ifall den �r 0 (stegat klart) bryt loop
			lsl		r23
			cpi		r23, 0b00000000
			brne	supermovebodyloop

		// flyttar till n�sta kroppsdels position
			call updateBodyDir

		// g�r igenom hela kroppen
			subi	r25 , -1
			cp		r25 , LENGTH
			brne	bodyloop
			
	// �terst�ller kroppvariablerna till ursprunget
		mov		BODYX , r6
		mov		BODYY , r7
	ret


	updateBodyDir:
// koll f�r ifall man krockat i sig sj�lv
	cp		BODYX , SNAKEX
	brne	cleared
	cp		BODYY , SNAKEY
	brne	cleared
	call ded
	cleared:
	
	// kollar ifall �pplet har hamnat p� en kroppsdel
		// ifall det �r s� ska des position slumpas p� nytt
		aplleloop:

			cp		BODYX , APPLEX
			brne	endchek
			cp		BODYY , APPLEY
			brne	endchek
			call	getApple
			jmp		aplleloop

		endchek:

		// l�ser in n�sta riktning
		ld		r18 , Y+
	// j�mf�r riktningen och hoppar till l�mplig lable		
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
			lsr		BODYX				// flyttar positionen �r r�tt h�ll
			cpi		BODYX , 0			// kollar ifall den �r utanf�r kanten
			brne	end2				// hoppar ut om den inte �r det
		// flyttar positionen till andra sidan om man �kt utanf�r kanten
			mov		r18 , BODYX
			ldi		r18 , 0b10000000
			mov		BODYX , r18
			jmp		end2

		moveBodyLeft:
			lsl		BODYX
			cpi		BODYX , 0
			brne	end2
			mov		r18 , BODYX
			ldi		r18 , 0b00000001
			mov		BODYX , r18
			jmp		end2

		moveBodyUp:
			lsl		BODYY
			cpi		BODYY , 0
			brne	end2
			mov		r18 , BODYY
			ldi		r18 , 0b00000001
			mov		BODYY , r18
			jmp		end2

		moveBodyDown:
			lsr		BODYY
			cpi		BODYY , 0
			brne	end2
			mov		r18 , BODYY
			ldi		r18 , 0b10000000
			mov		BODYY , r18
			jmp		end2

		end2:

	ret

//flyttar kroppen till utritningsmatrisen
	moveBodyDir:
		ldi		YL , low(wormbodydir)
		ldi		YH , high(wormbodydir)
		ld		r18, Y+
		ld		r18, Y+

	// kollar n�sta riktnign 
		cpi		r18, 0b00000001
		breq	moveBodyRight2

		cpi		r18, 0b00000010
		breq	moveBodyLeft2

		cpi		r18, 0b00001000
		breq	moveBodyUp2

		cpi		r18, 0b00000100
		breq	moveBodyDown2

	// flyttar kroppsdel efter riktning
		moveBodyRight2:
			lsl		BODYX
			cpi		BODYX , 0
			brne	moveBodyComplete
			mov		r18 , BODYX
			ldi		r18 , 0b00000001
			mov		BODYX , r18
			ret

		moveBodyLeft2:
			lsr		BODYX
			cpi		BODYX , 0
			brne	moveBodyComplete
			mov		r18 , BODYX
			ldi		r18 , 0b10000000
			mov		BODYX , r18
			ret

		moveBodyUp2:
			lsr		BODYY
			cpi		BODYY , 0
			brne	moveBodyComplete
			mov		r18 , BODYY
			ldi		r18 , 0b10000000
			mov		BODYY , r18
			ret

		moveBodyDown2:
			lsl		BODYY
			cpi		BODYY , 0
			brne	moveBodyComplete
			mov		r18 , BODYY
			ldi		r18 , 0b00000001
			mov		BODYY , r18
			ret

	moveBodyComplete:
	ret

// slumpar ut position f�r �pplet
	getApple:

	// aktivera inl�sning fr�n spaken
		lds		r18, ADMUX
		cbr		r18 , 0b00001111
		sbr		r18 , 0b00000100
		sbr		r18, 1<<7
		sts		ADMUX, r18
	
	// b�rja konvertera fr�n analog signal
		lds		r28, ADCSRA
		sbr		r28, 1<<6
		sbr		r28, 1<<7
		sts		ADCSRA, r28

	// v�ntar tills konverteringen �r klar
		tempY5:
		lds		r28, ADCSRA
		sbrc	r28, 6
		jmp		tempY5

	// l�ser av resultat fr�n konverteringen
		lds		r28 , ADCL
		lds		r20 , ADCH

	// slumpar fram ett v�rde baserat p� RAND och spaken
		add		RAND , r28
		lsr		RAND
		mov		r28 , RAND
		andi	r28 , 0b00001111
		mov		RAND , r28

	// g�r om till v�rde med bara en bit
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
	
	// koll f�r om slumpv�rdet var noll
		cpi		r18 , 0
		brne	skipnoll
		ldi		r18 , 1	// s�tts till ett

	skipnoll:

		mov		APPLEX , r18	// lagrar det nya v�rdet

		call	waitmaster	// v�r v�ntfunktion, f�r spaken ska hinna f� ett nytt v�rde

	starty:
		lds		r18, ADMUX
		cbr		r18 , 0b00001111
		sbr		r18 , 0b00000100
		sbr		r18, 1<<6
		sts		ADMUX, r18

		lds		r28, ADCSRA
		sbr		r28, 1<<6
		sbr		r28, 1<<7
		sts		ADCSRA, r28

		tempY55:
		lds		r28, ADCSRA
		sbrc	r28, 6
		jmp		tempY55
		lds		r28 , ADCL
		lds		r20, ADCH

		add		RAND , r28
		lsr		r28

		mov		r28 , RAND
		andi	r28 , 0b00001111
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

// flyttar �pplet till matrisen
	moveApple:

		ldi		r18, 0b00000001		// r�knare
		ldi		ZL , low(matrix)
		ldi		ZH , high(matrix)

	// g�r igenom matrisen och flyttar in �pplet
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

// kollar ifall masken �ter upp �pplet
	checkApple:
	
	// j�mf�r �pplets position med huvudets
		cp		APPLEX , SNAKEX
		brne	noapple
		cp		APPLEY , SNAKEY
		brne	noapple

	// �kar maskens l�ngd om man �tit �pplet
		mov		r18 , LENGTH
		subi	r18 , -1
		mov		LENGTH , r18

	//	slumpar nytt �pple som inte f�r vara lika med huvudets position
		appleloop:
			call	waitmaster
			call	getApple

			cp		APPLEX , SNAKEX
			brne	noapple
			cp		APPLEY , SNAKEY
			breq	appleloop

		noapple:
	ret

main:
// stacken
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

// s� att vi kan anv�nda portarna f�r led
    ldi		r16,0xFF
    out		DDRB,r16
	out		DDRC,r16
	out		DDRD,r16

// styrspak
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

// l�ngd p� kroppen i b�rjan
	ldi		r16 , 3
	mov		LENGTH , r16
// ursprungsriktning
	ldi		DIR , 0b00000001

// �pple
	ldi		r16 , 0b01000000
	mov		APPLEX , r16
	ldi		r16 , 0b01000000
	mov		APPLEY , r16
	call getapple
//ursprungsposition
	ldi		SNAKEX, 0b00001000
	ldi		SNAKEY, 0b00001000
	ldi		BODYX, 0b00000100
	ldi		BODYY, 0b00001000

	ldi		r26 , 2

// n�llst�ll utritningsmatrisen
	ldi		ZL , low(matrix)
	ldi		ZH , high(matrix)
	ldi	    r18, 0b00000000
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
	ld		r23 , Z

// riktningsarrayen
	ldi		ZL , low(wormbodydir)
	ldi		ZH , high(wormbodydir)
	ldi	    r18, 0b00000000
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


// b�rjar kolla fr�n f�rsta raden och kollumnen
	ldi		ROW , 0b00000001
	ldi		COL , 0b00000001

// om raden �r tom
	blank:
		lsl		ROW
	jmp update

	reset:
	// �terst�ller utritningsmatrisen
		ldi		ROW , 0b00000001
		ldi		COL , 0b00000001
		ldi		ZL , low(matrix)
		ldi		ZH , high(matrix)

	jmp update
	
	pastD:
// byter rad
	lsl		ROW
	jmp	update

// ritar ut matrisen
update:
// �terst�ller kollumnr�knaren
	ldi		COL , 0b00000001
	ld		r23 , Z+
// �terst�ller om sista raden �r n�dd
	cpi		ROW , 0b00000000
	breq	reset
// tom rad
	cpi		r23	, 0
	breq	blank
	
// g�r f�rbi gr�nsen f�r port D
	cpi		ROW , 0b00010000
	brge	printD
	cpi		ROW , 0b10000000
	breq	printD
	// print c
		updateCol:
		// g�r ur om den g�tt igenom alla colummner
			cpi		COL , 0b00000000
			breq	pastD
		// ifall positionen ska upplysas
			mov		r18 , COL
			and		r18 , r23

			ldi		r29 , 0b00000000	// l�gger noll i r29

		// portD
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
				lsl		COL	// stegar upp genom kollumn
		// ju fler waitmasters, destu ljusare
				call waitMaster
				call waitMaster
				call waitMaster
				call waitMaster
				call waitMaster

		jmp updateCol

		printD:

		updateColD:
			cpi		COL , 0b00000000
			breq	pastD

			mov		r18 , COL
			and		r18 , r23
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
			//	ju fler waitmasters, destu ljusare
				call waitMaster
				call waitMaster
				call waitMaster
				call waitMaster
				call waitMaster

		jmp updateColD

// uppdaterar riktningen fr�n spaken
joyXMovement:

// l�gger f�rra riktningen i arrayen
	mov		LASTDIR , DIR
	ldi		YL , low(wormbodydir)
	ldi		YH , high(wormbodydir)
	st		Y, DIR

// l�gger alla riktningar fr�n arrayen p� stacken
	ldi		r18, 0
	iterateDirLoop:
		
		ld		r16, Y+
		push	r16
		subi	r18, -1
		mov		r16 , LENGTH
		subi	r16 , -1
		cp		r18, r16

	brne	iterateDirLoop
	
	// kastar sista v�rdet 
		pop		r18
		ldi		r18, 0

//	flyttar in alla riktningar fr�n stacken tillbaka till arrayen
	iterateDirLoop2:
		
		pop		r16
		st		-Y, r16
		subi	r18, -1	
		cp		r18, LENGTH

	brne	iterateDirLoop2
	
	st		Y, DIR
// startar inl�sning
	lds		r18, ADMUX
	cbr		r18 , 0b00001111
	sbr		r18 , 0b00000101
	sbr		r18, 1<<5
	sbr		r18, 1<<7
	sts		ADMUX, r18

// startar konvertering 
	lds		r28, ADCSRA
	sbr		r28, 1<<6
	sbr		r28, 1<<7
	sts		ADCSRA, r28

	// v�ntar p� konverteringen
	tempX:
	lds		r28, ADCSRA
	sbrc	r28, 6
	jmp		tempX


// resultat fr�n konverteringen
	lds		r28 , ADCL
	lds		r20, ADCH

	add		RAND , r20	// l�gger till slumpv�rdet

// kollar ifall v�rdet g�r f�rbi gr�nsen f�r spakens riktningn �t n�got h�ll
	cpi		r20, 0b00000100
	brlo	right
	cpi		r20, 0b00001000
	brsh	left

	ldi		DIR, 0b00000000
	jmp		pastleft

	/*
		Comparen innan ldi i dessa subrutiner kollar
		ifall snakey redan g�r �t motsatta h�ll. 
		Detta f�r att man inte ska kunna g� igenom
		ormen igen och direkt f�rlora.
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
	lds		r18, ADMUX
	cbr		r18 , 0b00001111
	sbr		r18 , 0b00000100
	sbr		r18, 1<<6
	sts		ADMUX, r18
	lds		r28, ADCSRA
	sbr		r28, 1<<6
	sbr		r28, 1<<7
	sts		ADCSRA, r28

	tempY:
	lds		r28, ADCSRA
	sbrc	r28, 6
	jmp		tempY
	lds		r28 , ADCL
	lds		r20, ADCH
	/*
		Comparen nedan i dessa subrutiner kollar
		ifall snakey redan g�r �t n�got av dessa h�ll. 
		Detta f�r att man inte ska kunna g� igenom
		ormen igen och direkt f�rlora.
	*/
	
	add		RAND , r20

	cpi		r20, 0b00000100
	brlo	down
	cpi		r20, 0b00010000
	brsh	up

	jmp		pastup

	down:
	mov		r20 , LASTDIR
	cpi		r20 , 0b00001000
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
	
	waitMaster:
	
	subi	r18, 1
	cpi		r18, 1
	breq	waitMaster

	ret

// n�r man d�r
ded:
	ldi	SNAKEX , 0
	ldi	SNAKEY , 0

jmp ded
ret

//The end