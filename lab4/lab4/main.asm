;
; lab4.asm
;
; Created: 2024/11/6 1:59:06
; Author : 10164
;


; Replace with your application code
; Function :  measures the speed of the motor (based on the number of holes that
;             are detected by the shaft encoder connected to PC4 via pin change interrupt) and displays the speed on LCD.
;             Adjusted to new board configuration.
; Connect way:
;              Opo --> PC4 (Pin Change Interrupt PCINT20)
;              Ope --> any +5v
;              Mot --> Not controlled by code (As turn the POT, the speed of the motor changes accordingly.)
;              D0-7 --> PF0-7 (LCD data lines)
;              BE-RS --> PA4-7 (LCD control lines)
.include "m2560def.inc"
.def temp = r17
.def count = r18
.def zero = r19
.def four_times = r23        ; 将 four_times 定义为 r23

.def hundred = r20      ; stored 3 different position of count
.def ten = r21
.def one = r22

.def count_H = r25      ; count 2 bytes
.def count_L = r24

.def prev_state = r16   ; Previous state of PC4
.equ PCINT2addr = 0x0016

.cseg
	jmp RESET              ; 地址 0x0000
	      ; 按照中断向量表的顺序，依次定义各个中断向量
.org OVF0addr
	jmp Timer0OVF

.org PCINT2addr
	jmp PCINT2_ISR

          ; 中断向量表结束后，不使用 .org 指令，直接编写程序代码
.macro do_lcd_command           ; transfer command to LCD
    ldi r16, @0                 ; load data @0 to r16
    rcall lcd_command           ; rcall lcd_command
    rcall lcd_wait              ; rcall lcd_wait
.endmacro

.macro do_lcd_data              ; transfer data to LCD
    mov r16, @0                 ; move data @0 to r16
    rcall lcd_data              ; rcall lcd_data
    rcall lcd_wait              ; rcall lcd_wait
.endmacro

.macro lcd_set
    sbi PORTA, @0                   ; set pin @0 of port A to 1
.endmacro
.macro lcd_clr
    cbi PORTA, @0                   ; clear pin @0 of port A to 0
.endmacro

.equ LCD_RS = 7                     ; LCD_RS equal to PA7
.equ LCD_E = 6                      ; LCD_E equal to PA6
.equ LCD_RW = 5                     ; LCD_RW equal to PA5
.equ LCD_BE = 4                     ; LCD_BE equal to PA4

.equ F_CPU = 16000000
.equ DELAY_1MS = F_CPU / 4 / 1000 - 4
; 4 cycles per iteration - setup/call-return overhead

.org 0x0050

RESET:
    clr four_times              ; clear four_times
    clr count                   ; clear count

    ldi r16, low(RAMEND)         ; RAMEND : 0x21FF
    out SPL, r16                 ; initial stack pointer Low 8 bits
    ldi r16, high(RAMEND)        ; RAMEND: 0x21FF
    out SPH, r16                 ; initial High 8 bits of stack pointer

                                 ; LCD initialization
    ser r16                      ; set r16 to 0xFF
    out DDRF, r16                ; set PORT F as outputs (LCD data lines)
    out DDRA, r16                ; set PORT A as outputs (LCD control lines)
    clr r16                      ; clear r16
    out PORTF, r16               ; clear PORT F outputs
    out PORTA, r16               ; clear PORT A outputs

    do_lcd_command 0b00111000 ; 2x5x7
    rcall sleep_5ms
    do_lcd_command 0b00111000 ; 2x5x7
    rcall sleep_1ms
    do_lcd_command 0b00111000 ; 2x5x7
    do_lcd_command 0b00111000 ; 2x5x7
    do_lcd_command 0b00001001 ; display off
    do_lcd_command 0b00000001 ; clear display
    do_lcd_command 0b00000110 ; increment, no display shift
    do_lcd_command 0b00001111 ; Cursor on, bar, no blink

    ; Configure PC4 as input
    cbi DDRC, 4                 ; Clear bit 4 of DDRC to set PC4 as input

    ; Enable pin change interrupt on PCINT20 (PC4)
    ldi temp, (1<<PCIE2)        ; Enable PCIE2 for PCINT23..16
    sts PCICR, temp

    ldi temp, (1<<PCINT20)      ; Enable PCINT20 (PC4) in PCMSK2
    sts PCMSK2, temp

    ; Initialize prev_state
    in temp, PINC
    sbrc temp, 4
    ldi prev_state, 1           ; If PC4 is high
    sbrs temp, 4
    clr prev_state              ; If PC4 is low

    ; Timer0 setup
    ldi temp, 0b00000000
    out TCCR0A, temp
    ldi temp, 0b00000011
    out TCCR0B, temp            ; Prescaling value=64
    ldi temp, 1<<TOIE0          ; Enable Timer0 overflow interrupt
    sts TIMSK0, temp

    sei                         ; enable the global interrupt
    jmp main

; Pin Change Interrupt 2 Service Routine for PCINT23..16
PCINT2_ISR:
    push temp
    push prev_state
    push count                  ; count
    push four_times             ; four_times
    in temp, PINC
    sbrc temp, 4
    ldi temp, 1                 ; temp = 1 if PC4 is high
    sbrs temp, 4
    clr temp                    ; temp = 0 if PC4 is low
    cp temp, prev_state
    breq PCINT2_EXIT            ; If same state, exit
    ; State changed
    tst prev_state
    brne PC4_falling_edge
    ; Rising edge
    mov prev_state, temp
    rjmp PCINT2_EXIT
PC4_falling_edge:
    ; Falling edge detected
    inc four_times
    cpi four_times, 4
    brne not_increase_ISR
    inc count                   ; increase the count
    clr four_times
not_increase_ISR:
    mov prev_state, temp
PCINT2_EXIT:
    pop four_times              
    pop count
    pop prev_state
    pop temp
    reti                        ; return from interrupt

Timer0OVF:                      ; interrupt subroutine for Timer0
    adiw r25:r24, 1             ; Increase the temporary counter by one.
    cpi r24, low(1000)          ; Check if (r25:r24)=1000
    brne NotSecond
    cpi r25, high(1000)         ; 1000 = 1 sec at current timer settings
    brne NotSecond
    ; operation is here
    do_lcd_command 0b00000001   ; clear and return to first place in the first line
    ldi zero, '0'

    clr hundred
    clr ten
    clr one
cal_hundred:
    cpi count, 100
    brlo cal_ten
    inc hundred
    subi count, 100
    rjmp cal_hundred
cal_ten:
    cpi count, 10
    brlo cal_one
    subi count, 10
    inc ten
    rjmp cal_ten
cal_one:
    mov one, count

    add hundred, zero
    add ten, zero
    add one, zero
    do_lcd_data hundred             ; display hundred in LCD
    do_lcd_data ten                 ; display ten in LCD
    do_lcd_data one                 ; display one in LCD

    clr count                       ; clear count
    clr count_H
    clr count_L
    ; end operation
NotSecond:
    reti                            ; Return from the interrupt.

main:
    rjmp main





;
; Send a command to the LCD (r16)
;

lcd_command:                        ; send a command to LCD IR
    out PORTF, r16
    nop
    lcd_set LCD_E                   ; set E high
    nop
    nop
    nop
    lcd_clr LCD_E                   ; set E low
    nop
    nop
    nop
    ret

lcd_data:                           ; send a data to LCD DR
    out PORTF, r16                  ; output r16 to port F
    lcd_set LCD_RS                  ; set RS high
    nop
    nop
    nop
    lcd_set LCD_E                   ; set E high
    nop
    nop
    nop
    lcd_clr LCD_E                   ; set E low
    nop
    nop
    nop
    lcd_clr LCD_RS                  ; set RS low
    ret

lcd_wait:                            ; LCD busy wait
    push r16                         ; push r16 into stack
    clr r16                          ; clear r16
    out DDRF, r16                    ; set port F to input mode
    out PORTF, r16                   ; output 0x00 to port F
    lcd_set LCD_RW                   ; set RW high
lcd_wait_loop:
    nop
    lcd_set LCD_E                    ; set E high
    nop
    nop
    nop
    in r16, PINF                     ; read data from port F to r16
    lcd_clr LCD_E                    ; set E low
    sbrc r16, 7                      ; Skip if Bit 7 in R16 is Cleared
    rjmp lcd_wait_loop               ; rjmp to lcd_wait_loop
    lcd_clr LCD_RW                   ; set RW low
    ser r16                          ; set r16 to 0xFF
    out DDRF, r16                    ; set port F to output mode
    pop r16                          ; pop r16 from stack
    ret

sleep_1ms:                                   ; sleep 1ms
    push r24                                 ; push r24 to stack
    push r25                                 ; push r25 to stack
    ldi r25, high(DELAY_1MS)                 ; load high 8 bits of DELAY_1MS to r25
    ldi r24, low(DELAY_1MS)                  ; load low 8 bits of DELAY_1MS to r24
delayloop_1ms:
    sbiw r25:r24, 1                          ; r25:r24 = r25:r24 - 1
    brne delayloop_1ms                       ; branch to delayloop_1ms
    pop r25                                  ; pop r25 from stack
    pop r24                                  ; pop r24 from stack
    ret

sleep_5ms:                                    ; sleep 5ms
    rcall sleep_1ms                           ; 1ms
    rcall sleep_1ms                           ; 1ms
    rcall sleep_1ms                           ; 1ms
    rcall sleep_1ms                           ; 1ms
    rcall sleep_1ms                           ; 1ms
    ret
