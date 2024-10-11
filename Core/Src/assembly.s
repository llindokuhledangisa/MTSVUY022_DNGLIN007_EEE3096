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

    LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b11111111    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #40]

	@ Check if SW0 (PA0) is pressed
	LDR R0, GPIOA_BASE      @ Load GPIOA base address into R0
	LDR R1, [R0, #0x10]     @ Read GPIOA_IDR (input data register)
	LSLS R1, R1, #31        @ Test if bit 0 (PA0) is low (SW0 pressed)
	BEQ increament_by_2     @ If pressed, branch to set_long_delay

	@ Check if SW1 (PA1) is pressed
	LDR R0, GPIOA_BASE      @ Load GPIOA base address into R0
	LDR R1, [R0, #0x10]     @ Read GPIOA_IDR (input data register)
	LSLS R1, R1, #30        @ Shift left by 30 to move bit 1 (PA1) to the MSB
	LSRS R1, R1, #31        @ Shift right by 31 to move MSB (original bit 1) to the LSB
	BEQ set_shot_delay     @ If SW1 is pressed (PA1 == 0), branch to increment_by_2

	@ Check if SW2 (PA2) is pressed
	LDR R0, GPIOA_BASE      @ Load GPIOA base address into R0
	LDR R1, [R0, #0x10]     @ Read GPIOA_IDR (input data register)
	LSLS R1, R1, #29        @ Shift left by 29 to move bit 2 (PA2) to the MSB
	LSRS R1, R1, #31        @ Shift right by 31 to move MSB (original bit 2) to the LSB
	BEQ sw2_pattern     @ If SW2 is pressed (PA2 == 0), branch to increment_by_2

	@ If SW0 is not pressed, set short delay
	LDR R3, LONG_DELAY_CNT
	B set_delay

set_shot_delay:
	@ Set long delay (5 seconds)
	LDR R3, SHORT_DELAY_CNT

set_delay:
	@ Turn LEDs on
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b00000001    @ Set all LEDs (GPIOB Pins 0-7) to on
	STR R1, [R0, #24]
	MOV R2, R3
	BL delay

	@ Check if SW3 (PA3) is pressed
	LDR R0, GPIOA_BASE      @ Load GPIOA base address into R0
	LDR R1, [R0, #0x10]     @ Read GPIOA_IDR (input data register)
	LSLS R1, R1, #28        @ Shift left by 28 to move bit 3 (PA3) to the MSB
	LSRS R1, R1, #31        @ Shift right by 31 to move MSB (original bit 3) to the LSB
	CMP R1, #0              @ Compare bit 3 to 0 (pressed)
	BL freeze               @ If SW3 is pressed (PA3 == 0), call increament_by_2 subroutine

	@ Turn LEDs off
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b00000011    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #24]
	MOV R2, R3
	BL delay              	@ Call delay

	BL freeze               @ If SW3 is pressed (PA3 == 0), call increament_by_2 subroutine

	@ Turn LEDs off
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b00000111    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #24]
	MOV R2, R3
	BL delay              	@ Call delay

	BL freeze               @ If SW3 is pressed (PA3 == 0), call increament_by_2 subroutine

	@ Turn LEDs off
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b00001111    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #24]
	MOV R2, R3
	BL delay              	@ Call delay

	BL freeze               @ If SW3 is pressed (PA3 == 0), call increament_by_2 subroutine

	@ Turn LEDs off
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b00011111    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #24]
	MOV R2, R3
	BL delay              	@ Call delay

	BL freeze               @ If SW3 is pressed (PA3 == 0), call increament_by_2 subroutine

	@ Turn LEDs off
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b00111111    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #24]
	MOV R2, R3
	BL delay              	@ Call delay

	BL freeze               @ If SW3 is pressed (PA3 == 0), call increament_by_2 subroutine

	@ Turn LEDs off
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b01111111    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #24]
	MOV R2, R3
	BL delay              	@ Call delay

	BL freeze               @ If SW3 is pressed (PA3 == 0), call increament_by_2 subroutine


	@ Turn LEDs off
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b11111111    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #24]
	MOV R2, R3
	BL delay              	@ Call delay

	BL freeze               @ If SW3 is pressed (PA3 == 0), call increament_by_2 subroutine

	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b11111111    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #40]
	MOV R2, R3
	BL delay

	BL freeze               @ If SW3 is pressed (PA3 == 0), call increament_by_2 subroutine

	B main_loop          	@ Infinite loop

increament_by_2:

	@ Turn LEDs on
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b00000011
	STR R1, [R0, #24]
	MOV R2, R3
	BL delay

	BL freeze               @ If SW3 is pressed (PA3 == 0), call increament_by_2 subroutine

	@ Turn LEDs off
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b00001111    @ Reset all LEDs (GPIOB Pins 0-7) to of
	STR R1, [R0, #24]
	MOV R2, R3
	BL delay              	@ Call delay

	BL freeze               @ If SW3 is pressed (PA3 == 0), call increament_by_2 subroutine

	@ Turn LEDs off
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b00111111    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #24]
	MOV R2, R3
	BL delay              	@ Call delay

	BL freeze               @ If SW3 is pressed (PA3 == 0), call increament_by_2 subroutine

	@ Turn LEDs off
	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b11111111    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #24]
	MOV R2, R3
	BL delay

	BL freeze               @ If SW3 is pressed (PA3 == 0), call increament_by_2 subroutine

	LDR R0, GPIOB_BASE   	@ Load GPIOB base address into R0
	MOVS R1, #0b11111111    @ Reset all LEDs (GPIOB Pins 0-7) to off
	STR R1, [R0, #40]
	MOV R2, R3
	BL delay

	BL freeze               @ If SW3 is pressed (PA3 == 0), call increament_by_2 subroutine

	B main_loop          	@ Infinite loop

sw2_pattern:

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

delay:
delay_loop:
	SUBS R2, R2, #1         @ Decrement delay counter
	BNE delay_loop          @ If not zero, keep looping
	BX LR                   @ Return from delay

write_leds:
	STR R2, [R1, #0x14]
	B main_loop

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 1400000
SHORT_DELAY_CNT: 	.word 600000
