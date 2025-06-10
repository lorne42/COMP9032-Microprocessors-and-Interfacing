; AssemblerApplication1.asm
.include "m2560def.inc"

; Created: 2024/9/18 13:15:57
; Author : 10164
;

rjmp main           ; Jump to main

main:
    ldi r16, -2          ; Load the signed number into R16
    ldi r19, 48         ; Load the ASCII offset for '0' into R19
    mov r3, r16         ; Move the number into R3
    tst r3              ; Test if R3 is zero
    brmi negative       ; If zero, branch to positive handling

    ; Handle negative case
                 ; Negate R3 to make it positive
    ldi r17, '+'        ; Set sign in R17 for negative
    mov r4, r17         ; Move the sign to R4
    add r16, r19         ; Convert the number to its ASCII representation
    mov r5, r16          ; Move the result to R5 for later use
    rjmp end            ; Jump to end

negative:
	neg r3 
    ldi r18, '-'        ; Set sign in R18 for positive
    mov r4, r18         ; Move the sign to R4
    add r3, r19        ; Convert the number to its ASCII representation
    mov r5, r3         ; Move the result to R5

end: 
    rjmp end            ; Loop indefinitely