/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns

main_loop:

    @ set delay to long as default
	LDR R3, LONG_DELAY_CNT
	MOVS R4, 0

	//Turn off all LEDs
    LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b11111111    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #40]

	BL sw1_handler			@ Check if SW1 (PA1) is pressed to change delay

    B continue  @ If SW1 is not pressed, skip the BL

continue: //handles the two other buttons

	BL sw0_handler
	BL sw2_handler

increment_by_1: //increment by one branch
	@ Turn LEDs on
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOV R1, R4
	STR R1, [R0, #24]
	MOV R2, R3
	BL delay

	//handlers to check all buttons
	BL sw0_handler
	BL sw1_handler
	BL sw2_handler
	BL freeze

	MOV R5, R4
	MOVS R7, 255
	SUBS R6, R5, R7
	BEQ main_loop
	ADDS R4, #1
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b11111111    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #40]

	B increment_by_1

set_long_delay:          @ Subroutine to set long delay
    LDR R3, LONG_DELAY_CNT  @ Set short delay to 0.7s
    BX LR

set_short_delay:          @ Subroutine to set short delay
    LDR R3, SHORT_DELAY_CNT  @ Set short delay to 0.3s
    BX LR

increment_by_2: //increment by two branch

	@ Turn LEDs on
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOV R1, R4
	STR R1, [R0, #24]
	MOV R2, R3
	BL delay

	//increment by one branch
	BL sw1_handler
	BL sw2_handler
	BL freeze

	MOV R5, R4
	MOVS R7, 254
	SUBS R6, R5, R7
	BEQ main_loop
	ADDS R4, #2

	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b11111111    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #40]

	@ Check if SW0 (PA0) is pressed
	LDR R0, GPIOA_BASE      @ Load GPIOA base address into R0
	LDR R1, [R0, #0x10]     @ Read GPIOA_IDR (input data register)
	LSLS R1, R1, #31        @ Test if bit 0 (PA0) is low (SW0 pressed)
	BNE main_loop

	B increment_by_2

sw2_pattern:
	//Turn off all LEDs
    LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b11111111    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #40]

	@ Turn LEDs on
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0xAA    @ Set all LEDs (GPIOB Pins 0-7) to on
	STR R1, [R0, #24]
    MOV R2, R3
	BL delay

	B main_loop          	@ Infinite loop

freeze:
   @ Check if SW3 (PA3) is pressed
	LDR R0, GPIOA_BASE      @ Load GPIOA base address into R0
	LDR R1, [R0, #0x10]     @ Read GPIOA_IDR (input data register)
	LSLS R1, R1, #28        @ Shift left by 28 to move bit 3 (PA3) to the MSB
	LSRS R1, R1, #31        @ Shift right by 31 to move MSB (original bit 3) to the LSB
	BEQ freeze              @ If SW3 is pressed (PA3 == 0), branch to increment_by_2
	BX LR

sw0_handler: //increment by 2

	@ Check if SW0 (PA0) is pressed
	LDR R0, GPIOA_BASE      @ Load GPIOA base address into R0
	LDR R1, [R0, #0x10]     @ Read GPIOA_IDR (input data register)
	LSLS R1, R1, #31        @ Test if bit 0 (PA0) is low (SW0 pressed)
	BEQ increment_by_2     @ If pressed, branch to increment by 2
	BX LR

sw1_handler: //change frequency to 0.3s

	@ Check if SW1 (PA1) is pressed
	LDR R0, GPIOA_BASE      @ Load GPIOA base address into R0
	LDR R1, [R0, #0x10]     @ Read GPIOA_IDR (input data register)
	LSLS R1, R1, #30        @ Shift left by 30 to move bit 1 (PA1) to the MSB
	LSRS R1, R1, #31        @ Shift right by 31 to move MSB (original bit 1) to the LSB
	CMP R1, #0              @ Compare R1 with 0 to check if SW1 is pressed
	BEQ set_short_delay
	BNE set_long_delay
	BX LR

sw2_handler: //change pattern to 0xAA

	@ Check if SW2 (PA2) is pressed
	LDR R0, GPIOA_BASE      @ Load GPIOA base address into R0
	LDR R1, [R0, #0x10]     @ Read GPIOA_IDR (input data register)
	LSLS R1, R1, #29        @ Shift left by 29 to move bit 2 (PA2) to the MSB
	LSRS R1, R1, #31        @ Shift right by 31 to move MSB (original bit 2) to the LSB
	BEQ sw2_pattern         @ If SW2 is pressed (PA2 == 0), branch to 0xAA pattern
	BX LR

delay:
delay_loop:
	SUBS R2, R2, #1         @ Decrement delay counter
	BNE delay_loop          @ If not zero, keep looping
	BX LR                   @ Return from delay

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 1400000
SHORT_DELAY_CNT: 	.word 300000
