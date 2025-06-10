;
; Created: 23-Oct-24 10:18:35 AM
; Author : Muqueet Chowdhury
;


; Replace with your application code
.include "m2560def.inc"

; Define LCD macros for command and data
.macro do_lcd_command
	ldi r16, @0
	rcall lcd_command
	rcall lcd_wait
.endmacro
.macro do_lcd_data
	ldi r16, @0
	rcall lcd_data
	rcall lcd_wait
.endmacro

; Define registers and constants
.def row    = r16  ; current row number
.def col    = r17  ; current column number
.def rmask  = r18  ; mask for current row
.def cmask  = r19  ; mask for current column
.def temp1  = r20
.def temp2  = r21

.equ PORTFDIR = 0xF0  ; use PortF for keypad input/output: PF7-4 output, PF3-0 input
.equ INITCOLMASK = 0xEF  ; scan from the leftmost column
.equ INITROWMASK = 0x01  ; scan from the bottom row
.equ ROWMASK = 0x0F      ; mask for the row part of the keypad
.equ F_CPU = 16000000
.equ DELAY_1MS = F_CPU / 4 / 1000 - 4

RESET:
	; Set up stack pointer
	ldi r16, low(RAMEND)
	out SPL, r16
	ldi r16, high(RAMEND)
	out SPH, r16

	; Initialize LCD
	ser r16
	out DDRF, r16
	out DDRA, r16
	clr r16
	out PORTF, r16
	out PORTA, r16

	; LCD commands to initialize it
	do_lcd_command 0b00111000 ; 2x5x7
	rcall sleep_5ms
	do_lcd_command 0b00111000 ; 2x5x7
	rcall sleep_1ms
	do_lcd_command 0b00111000 ; 2x5x7
	do_lcd_command 0b00001000 ; display off
	do_lcd_command 0b00000001 ; clear display
	do_lcd_command 0b00000110 ; increment, no display shift
	do_lcd_command 0b00001110 ; cursor on, no blink

	; Keypad initialization
	ldi temp1, PORTFDIR  ; columns are outputs, rows are inputs
	;out DDRL, temp1
	sts		DDRL, temp1
	ser temp1            ; PORTC is outputs (for testing with LEDs)
	out DDRC, temp1

main:
	ldi cmask, INITCOLMASK  ; initial column mask
	clr col                 ; initial column value
colloop:
	cpi col, 4
	breq main
	;out PORTL, cmask        ; set column mask
	sts		PORTL, cmask
	ldi temp1, 0xFF

delay:
	dec temp1
	brne delay

	;in temp1, PINL          ; read keypad rows
	lds		temp1, PINL
	andi temp1, ROWMASK     ; mask out unused bits
	cpi temp1, 0xF          ; check if any row is pressed
	breq nextcol

	; Row detection
	ldi rmask, INITROWMASK
	clr row
rowloop:
	cpi row, 4
	breq nextcol
	mov temp2, temp1
	and temp2, rmask        ; check if the current row bit is set
	breq convert            ; if row bit is set, convert it to a character
	inc row
	lsl rmask               ; shift mask to next row
	jmp rowloop

nextcol:
	lsl cmask               ; shift column mask
	inc col                 ; increment column index
	jmp colloop             ; check the next column

convert:
	; Handle numbers 1-9
	cpi col, 3
	breq letters
	cpi row, 3
	breq symbols

	mov temp1, row
	lsl temp1
	add temp1, row
	add temp1, col
	subi temp1, -'1'  ; get ASCII value of the number
	jmp convert_end

letters:
	ldi temp1, 'A'
	add temp1, row  ; get corresponding letter (A-D)
	jmp convert_end

symbols:
	cpi col, 0
	breq star
	cpi col, 1
	breq zero
	ldi temp1, '#'  ; if neither star nor zero, it's hash
	jmp convert_end

star:
	ldi temp1, '*'  ; star symbol
	jmp convert_end

zero:
	ldi temp1, '0'  ; zero symbol

convert_end:
	; Send the converted character to the LCD
	mov r16, temp1
	rcall lcd_data
	jmp main  ; repeat the process

.equ LCD_RS = 7
.equ LCD_E = 6
.equ LCD_RW = 5
.equ LCD_BE = 4

.macro lcd_set
	sbi PORTA, @0
.endmacro

.macro lcd_clr
	cbi PORTA, @0
.endmacro

; --- LCD routines from the first code ---
lcd_command:
	out PORTF, r16
	nop
	lcd_set LCD_E
	nop
	nop
	nop
	lcd_clr LCD_E
	nop
	nop
	nop
	ret

lcd_data:
	out PORTF, r16
	lcd_set LCD_RS
	nop
	nop
	nop
	lcd_set LCD_E
	nop
	nop
	nop
	lcd_clr LCD_E
	nop
	nop
	nop
	lcd_clr LCD_RS
	ret

lcd_wait:
	push r16
	clr r16
	out DDRF, r16
	out PORTF, r16
	lcd_set LCD_RW
lcd_wait_loop:
	nop
	lcd_set LCD_E
	nop
	nop
	nop
	in r16, PINF
	lcd_clr LCD_E
	sbrc r16, 7
	rjmp lcd_wait_loop
	lcd_clr LCD_RW
	ser r16
	out DDRF, r16
	pop r16
	ret

sleep_1ms:
	push r24
	push r25
	ldi r25, high(DELAY_1MS)
	ldi r24, low(DELAY_1MS)
delayloop_1ms:
	sbiw r25:r24, 1
	brne delayloop_1ms
	pop r25
	pop r24
	ret

sleep_5ms:
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	rcall sleep_1ms
	ret
