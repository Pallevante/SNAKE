/*
 * SNAKE.asm
 *
 *  Created: 2014-04-25 08:02:33
 *   Author: b13petha
 */ 
 /*

.DEF rTemp         = r16
.DEF rDirection    = r23

.EQU NUM_COLUMNS   = 8
.EQU MAX_LENGTH    = 25

.DSEG
matrix:   .BYTE 8
snake:    .BYTE MAX_LENGTH+1

.CSEG
// Interrupt vector table
.ORG 0x0000
     jmp init // Reset vector
//... fler interrupts
.ORG INT_VECTORS_SIZE
init:
     // Sätt stackpekaren till högsta minnesadressen
     ldi rTemp, HIGH(RAMEND)
     out SPH, rTemp
     ldi rTemp, LOW(RAMEND)
     out SPL, rTemp*/


 /*.DSEG
matrix:	.BYTE 8 

.CSEG
init:
	ldi	r16 , 0

loop:


	out	PORTC0 , r16
	out PORTD6 , r16

	jmp loop*/
                  // use them by their names rather than addresses (not fun).
.list                  // We DO want to include the following code in our listing //D

      rjmp      main       // You usually place these two lines after all your
main:                  // directives. They make sure that resets work correctly.

    ldi      r16,0xFF // LoaD Immediate. This sets r16 = 0xFF (255)
    out      DDRB,r16
	out      DDRC,r16
	out      DDRD,r16

loop:
	ldi	r16 , 0b00000001
	ldi	r17 , 0b01000000

    out      PORTC,r16
    out      PORTD,r17         //1/2 /



    rjmp      loop