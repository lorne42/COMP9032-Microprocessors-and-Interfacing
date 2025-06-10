; AVR assembly code to calculate a/4 + a^2

; Register usage:
; r16 - Input value a
; r17 - Temporary register for a/4
; r18:r19 - Temporary registers for a^2
; r20 - Result register

    .org 0x00         ; Program start at address 0x00
        ; Jump to start of the program

start:
    ; Assume that r16 contains the value of a
	ldi r16, 6
    mov r17, r16      ; Copy a into r17
    lsr r17           ; Logical shift right once (a / 2)
    

    mov r19, r16      ; Copy a into r19 (low byte of a^2 result)
    mul r16, r16      ; Multiply a * a (result stored in r1:r0)
    mov r18, r0       ; Move low byte of a^2 result into r18
	lsr r18
	lsr r18
    clr r19           ; Clear r19 since high byte of a^2 is zero for 8-bit values
    add r18, r17      ; Add a/4 to low byte of a^2
    clr r19           ; Clear r19 since we won't overflow with 8-bit addition


    mov r20, r18      ; Move the result into r20
	END1: RJMP END1


