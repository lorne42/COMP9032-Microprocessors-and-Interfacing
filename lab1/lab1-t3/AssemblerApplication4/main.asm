        .CSEG
        .ORG 0x00

        

        ; Load the four unsigned integers
        LDI R16, 70      ; R16 = first integer
        LDI R17, 30      ; R17 = second integer
        LDI R18, 45      ; R18 = third integer
        LDI R19, 25     ; R19 = fourth integer

GCD_R16_R17:
        CP  R16, R17       ; Compare R16 and R17
        BRNE GCD_LOOP1     ; If R16 != R17, continue GCD algorithm
        RJMP GCD_DONE1     ; If R16 == R17, we have found GCD of R16 and R17

GCD_LOOP1:
        BRGE R16_GT_R17    ; 
        SUB R17, R16       ; 
        RJMP GCD_R16_R17   ; Repeat until they are equal

R16_GT_R17:
        SUB R16, R17       ; 
        RJMP GCD_R16_R17   ; Repeat until they are equal

GCD_DONE1:
        MOV R17, R16       ; R16 now holds the GCD of first two numbers


GCD_R16_R18:
        CP  R16, R18       ; Compare R16 and R18
        BRNE GCD_LOOP2     ; If R16 != R18, continue GCD algorithm
        RJMP GCD_DONE2     ; If R16 == R18, we have found GCD of R16 and R18

GCD_LOOP2:
        BRGE R16_GT_R18    ; 
        SUB R18, R16       ; 
        RJMP GCD_R16_R18   ; Repeat until they are equal

R16_GT_R18:
        SUB R16, R18       ;
        RJMP GCD_R16_R18   ; Repeat until they are equal

GCD_DONE2:
        MOV R18, R16       ; R16 now holds the GCD of first three numbers

GCD_R16_R19:
        CP  R16, R19       ; Compare R16 and R19
        BRNE GCD_LOOP3     ; If R16 != R19, continue GCD algorithm
        RJMP GCD_DONE3     ; If R16 == R19, we have found GCD of all numbers

GCD_LOOP3:
        BRGE R16_GT_R19    ; 
        SUB R19, R16       ; 
        RJMP GCD_R16_R19   ; Repeat until they are equal

R16_GT_R19:
        SUB R16, R19       ; 
        RJMP GCD_R16_R19   ; Repeat until they are equal

GCD_DONE3:
        MOV R20, R16       ; R20 now holds the GCD of all four numbers


		END1: RJMP END1

