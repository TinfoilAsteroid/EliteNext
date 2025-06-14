;   K(3 2 1 0)           The result of the division
;   X                    X is preserved

; Calculate K(3 2 1 0) = (A P+1 P) / (z_sign z_hi z_lo) where zsign hi lo is in DE with zsign leading hi
varQRS                 DS      4
varAPP                 DS     3
RvarDiv                DS     1

                    DISPLAY "TODO:  neds rewrite of whoel DIDV3B2"
;; NEEDS REWRITE TODO OF WHOLE DIVD3B2
;; NEEDS REWRITE TODO

; b = varR, c= varQ
Requ256mulAdivQ_6502:
.LL31_6502:             sla     a                       ; ASL A                   \ Shift A to the left
                        jp      c,.LL29_6502            ; BCS LL29               \ If bit 7 of A was set, then jump straight to the subtraction
                        FlipCarryFlag                   ;                          If A < N, then C flag is set.
                        JumpIfALTNusng c, .LL31_SKIPSUB_6502 ; CMP Q              \ If A < Q, skip the following subtraction
                                                        ; BCC P%+4
                        sub     c                       ; SBC Q                  \ A >= Q, so set A = A - Q
                        ClearCarryFlag
.LL31_SKIPSUB_6502:     FlipCarryFlag
                        rl      b                       ; ROL R                  \ Rotate the counter in R to the left, and catch the result bit into bit 0 (which will be a 0 if we didn't do the subtraction, or 1 if we did)
                        jp      c, .LL31_6502            ; BCS LL31               \ If we still have set bits in R, loop back to LL31 to do the next iteration of 7
                        ld      a,b
                        ld      (RvarDiv),a
                        ret                             ; RTS                    \ R left with remainder of division
.LL29_6502:             sub     c                       ; SBC Q                  \ A >= Q, so set A = A - Q
                        SetCarryFlag                    ; SEC                    \ Set the C flag to rotate into the result in R
                        rl      b                       ; ROL R                  \ Rotate the counter in R to the left, and catch the result bit into bit 0 (which will be a 0 if we didn't do the subtraction, or 1 if we did)
                        jp      c, .LL31_6502            ; BCS LL31               \ If we still have set bits in R, loop back to LL31 to do the next iteration of 7
                        ld      a,b                     ; RTS                    \ Return from the subroutine with R containing the
                        ld      (RvarDiv),a                ; .
                        ret                             ; .                      \ remainder of the division
.LL2_6502:              ld      a,$FF                   ; LDA #255               \ The division is very close to 1, so return the closest
                        ld      (varR),a                ; STA R                  \ possible answer to 256, i.e. R = 255
                        ld      b,a                     ; as we are using b as varR
                        SetCarryFlag                    ; we failed so need carry flag set
                        ret                             ; RTS                    \ Return from the subroutine
               DISPLAY "TODO : Merge Requ256mulAdivQ_6502  RequAmul256divQ"
; Entry point if varQ is populated with demoninator
RequAmul256divQ:	    
BFRDIV:                 push	af
                        ld		a,(varQ)
                        ld		c,a
                        pop		af
                        cp		0
                        jp		z, HLDIVC_0_BY	; fast exit if numerator is 0
RequAmul256divC:        ld		l,0
                        ld		h,a
HL_Div_Cold:			ld b,16			; fast entry point if C and HL are already set
                        xor a
LOOPPOINT:	            add hl,hl
                        rla
                        cp c
                        jr c,SKIPINCSUB
                        inc l
                        sub c
SKIPINCSUB:             djnz LOOPPOINT
                        ld		a,l
                        ld 		(varR),a
                        ret
HLDIVC_0_BY:            ld		(varR),a
                        ret
        

Amul256DivQ:            ld      hl,varQ                 ; CMP Q                  \ If A >= Q, then the answer will not fit in one byte,
                        ld      c,(hl)                  ; using c as Q var
                        cp      c
                        FlipCarryFlag
                        jp      c, .LL2_6502            ; BCS LL2                \ so jump to LL2 to return 255
                        ld      b,$FE                   ; LDX #%11111110         \ Set R to have bits 1-7 set, so we can rotate through 7 loop iterations, getting a 1 each time, and then we use b as Rvar
.LL31_6502:             sla     a                       ; ASL A                  \ Shift A to the left
                        jp      c,.LL29_6502            ; BCS LL29               \ If bit 7 of A was set, then jump straight to the subtraction
                        FlipCarryFlag                   ;                          If A < N, then C flag is set.
                        JumpIfALTNusng c, .LL31_SKIPSUB_6502 ; CMP Q              \ If A < Q, skip the following subtraction
                                                        ; BCC P%+4
                        sub     c                       ; SBC Q                  \ A >= Q, so set A = A - Q
                        ClearCarryFlag
.LL31_SKIPSUB_6502:     FlipCarryFlag
                        rl      b                       ; ROL R                  \ Rotate the counter in R to the left, and catch the result bit into bit 0 (which will be a 0 if we didn't do the subtraction, or 1 if we did)
                        jp      c, .LL31_6502           ; BCS LL31               \ If we still have set bits in R, loop back to LL31 to do the next iteration of 7
                        ld      a,b
                        ld      (varR),a
                        ret                             ; RTS                    \ R left with remainder of division
.LL29_6502:             sub     c                       ; SBC Q                  \ A >= Q, so set A = A - Q
                        SetCarryFlag                    ; SEC                    \ Set the C flag to rotate into the result in R
                        rl      b                       ; ROL R                  \ Rotate the counter in R to the left, and catch the result bit into bit 0 (which will be a 0 if we didn't do the subtraction, or 1 if we did)
                        jp      c, .LL31_6502           ; BCS LL31               \ If we still have set bits in R, loop back to LL31 to do the next iteration of 7
                        ld      a,b                     ; RTS                    \ Return from the subroutine with R containing the
                        ld      (varR),a                ; .
                        ret                             ; .                      \ remainder of the division
.LL2_6502:              ld      a,$FF                   ; LDA #255               \ The division is very close to 1, so return the closest
                        ld      (varR),a                ; STA R                  \ possible answer to 256, i.e. R = 255
                        SetCarryFlag                    ; we failed so need carry flag set
                        ret                             ; RTS                    \ Return from the subroutine


DIVD3B_SHIFT_REG:       DB      0

DIV3B2DE:               ld      a,e                         ; load QRS with Z sign hi lo
                        ld      (varQRS+2),a
                        ld      a,d
                        and     $7F
                        ld      (varQRS+1),a
                        ld      a,d
                        and     $80
                        ld      (varQRS),a
                        jp      DVID3B
; Calculate K(3 2 1 0) = (A P+1 P) / (z_sign z_hi z_lo) = A P[1 0 ] / (SRQ)
; We don't use zlo and assume its already loaded into SRQ
DVID3B2:                ld      (varP+2),a                  ;STA P+2                \ Set P+2 = A
                                                            ; LDA INWK+6             \ Set Q = z_lo
                                                            ; STA Q
                                                            ; LDA INWK+7             \ Set R = z_hi
                                                            ; STA R
                                                            ; LDA INWK+8             \ Set S = z_sign
                                                            ; STA S
;  Given the above assignments, we now want to calculate K(3 2 1 0) = P(2 1 0) / (S R Q)
DVID3B:                 ld      a,(varP)                    ; LDA P                 \ Make sure P(2 1 0) is at least 1
                        or      1                           ; ORA #1
                        ld      (varP),a                    ; STA P
;--- t = sign of P2 xor S (i.e. sign of result) ------------;
                        ld      a,(varP+2)                  ; LDA P+2                \ Set T to the sign of P+2 * S (i.e. the sign of the
                        ld      hl, varS                    ; EOR S                  \ result) and store it in T
                        xor     (hl)
                        and     $80                         ; AND #%10000000
                        ld      (varT),a                    ; STA T
;--- New bit added to aviod a divde by 0 -------------------;
.CheckQRSAtLeast1:      ld      a,(varQ)                    ;
                        ld      hl,varR                     ;
                        or      (hl)                        ;
                        jp      nz,.DVL9Prep                ;
                        ld      a,1                         ;
                        ld      (varQ),a                    ;
; A P(1) P(0) = ABS P(2 1 0)
.DVL9Prep:              ld      b,0                         ; LDY #0                 \ Set Y = 0 to store the scale factor (use b as Y)
                        ld      a,(varP+2)                  ; LDA P+2                \ Clear the sign bit of P+2, so the division can be done
                        and     $7F                         ; AND #%01111111         \ with positive numbers and we'll set the correct sign below, once all the maths is done
; We now shift (A P+1 P) left until A >= 64, counting the number of shifts in Y. This makes the top part of the division as large as possible, thus retaining as
; much accuracy as we can.  When we come to return the final result, we shift the result by the number of places in Y, and in the correct direction
                        DISPLAY "TODO DVL9 and DVL6 move P and QRS into registers for faster shift"
;-- while A < 64 shift A P(1) P(0) -------------------------;
.DVL9:                  cp      64                          ; CMP #64                \ If A >= 64, jump down to DV14
                        jp      nc, .DV14                   ; BCS DV14
                        ld      hl,varP                     ; ASL P                  \ Shift (A P+1 P) to the left
                        sla     (hl)
                        inc     hl                          ; ROL P+1
                        rl      (hl)
                        rl      a                           ; ROL A
                        inc     b                           ; INY                    \ Increment the scale factor in Y
                        jp      .DVL9                       ; BNE DVL9               \ Loop up to DVL9 (this BNE is effectively a JMP, as Y will never be zero)
; If we get here, A >= 64 and contains the highest byte of the numerator, scaled up by the number of left shifts in Y (b in our code)
.DV14:                  ld      (varP+2),a                  ; Store A in P+2, so we now have the scaled value of the numerator in P(2 1 0)
                        ld      a,(varS)                    ; LDA S                  \ Set A = |S|
                        and     $7F                         ; AND #%01111111
                        ;nop                                ;  BMI DV9               \ If bit 7 of A is set, jump down to DV9 (which can never happen)
; We now shift (S R Q) left until bit 7 of S is set, reducing Y by the number of shifts. This makes the bottom part of the division as large as possible, thus
; retaining as much accuracy as we can. When we come to return the final result, we shift the result by the total number of places in Y, and in the correct
; direction, to give us the correct result
; We set A to |S| above, so the following actually shifts (A R Q)
.DVL6:                  dec     b                           ; DEY                    \ Decrement the scale factor in Y (b)
                        ld      hl,varQ                     ; ASL Q                  \ Shift (A R Q) to the left
                        sla     (hl)                        ; .
                        ld      hl,varR                     ; ROL R
                        rl      (hl)                        ; .
                        rl      a                           ; ROL A
                        jp      p,.DVL6                     ; BPL DVL6               \ Loop up to DVL6 to do another shift, until bit 7 of A is set and we can't shift left any further
; We have now shifted both the numerator and denominator left as far as they will go, keeping a tally of the overall scale factor of the various shifts in Y. We
; can now divide just the two highest bytes to get our result
.DV9:                   ld      (varQ),a                    ; STA Q                  \ Set Q = A, the highest byte of the denominator
                        ld      c,a                         ; for Requ256mulAdivQ_6502 as it uses c as Q
                        ld      a,b                         ; preserve shift register in DEVD3B_SHIFT_REG
                        ld      (DIVD3B_SHIFT_REG),a
; Note in Requ256mulAdivQ_6502 we use B as R Var for shift register
                        ld      b,254                       ; LDA #254               \ Set R to have bits 1-7 set, so we can pass this to
                        ld      (varR),a                    ; STA R                  \ LL31 to act as the bit counter in the division
                        ld      a,(varP+2)                  ; LDA P+2                \ Set A to the highest byte of the numerator
                        call    Requ256mulAdivQ_6502        ; JSR LL31               \ Call LL31 to calculate: R = 256 * A / Q which means result is in b
; The result of our division is now in R, so we just need to shift it back by the scale factor in Y
                        ZeroA                               ; LDA #0                \ Set K(3 2 1) = 0 to hold the result (we populate K)
                        ld      (varK+1),a                  ; STA K+1               \ next)
                        ld      (varK+2),a                  ; STA K+2
                        ld      (varK+3),a                  ; STA K+3
                        ld      a,(DIVD3B_SHIFT_REG)        ; TYA                   \ If Y (shift counter in b) is positive, jump to DV12
                        or      a                           ; .                      we want to check the sign or if its zero
                        jp      z,.DV13                     ; Optimisation to save a second jump from DV12 to DV13
                        jp      p,.DV12                     ; BPL DV12
; If we get here then Y is negative, so we need to shift the result R to the left by Y places, and then set the correct sign for the result
                        DISPLAY "TODO check oprimisation here for var r  in b"
                        ld      c,b
                        ld      a,(DIVD3B_SHIFT_REG)
                        ld      b,a
                        ld      a,c
                        ; OPTIM ld      a,(varR)                    ; LDA R                  \ Set A = R
.DVL8:                  sla     a                           ; ASL A                  \ Shift (K+3 K+2 K+1 A) left
                        ld      hl,varK+1                   ; ROL K+1
                        rl      (hl)                        ; .                  
                        inc     hl                          ; ROL K+2
                        rl      (hl)                        ; .
                        inc     hl                          ; ROL K+3
                        rl      (hl)                        ; .
                        inc     b                           ; INY                    \ Increment the scale factor in Y
                        jp      nz,.DVL8                    ; BNE DVL8               \ Loop back to DVL8 until we have shifted left by Y places
                        ld      (varK),a                    ; STA K                  \ Store A in K so the result is now in K(3 2 1 0)
                        ld      a,(varK+3)                  ; LDA K+3                \ Set K+3 to the sign in T, which we set above to the
                        ld      hl,varT                     ; ORA T                  \ correct sign for the result
                        or      (hl)                        ; .
                        ld      (varK+3),a                  ; STA K+3
                        ret                                 ; RTS                    \ Return from the subroutine
; If we get here then Y is zero, so we don't need to shift the result R, we just need to set the correct sign for the result
.DV13:                  ld      a,b; varR)                  ; LDA R                  \ Store R in K so the result is now in K(3 2 1 0)
                        ld      (varK),a                    ; STA K
                        ld      a,(varT)                    ; LDA T                  \ Set K+3 to the sign in T, which we set above to the
                        ld      (varK+3),a                  ; STA K+3                \ correct sign for the result
                        ret                                 ; RTS                    \ Return from the subroutine
; if we get here U is positive but still could be zero, now this is handled in DV9                        
.DV12:                  ; nop                               ; BEQ DV13               \ We jumped here having set A to the scale factor in Y, so this jumps up to DV13 if Y = 0
; If we get here then Y is positive and non-zero, so we need to shift the result R to the right by Y places and then set the correct sign for the result. We also
; know that K(3 2 1) will stay 0, as we are shifting the lowest byte to the right, so no set bits will make their way into the top three bytes
                        ;ld      a,(varR)                    ; LDA R                  \ Set A = R
                        ld      c,b
                        ld      a,(DIVD3B_SHIFT_REG)
                        ld      b,a
                        ld      a,c
.DVL10:                 srl     a                           ; LSR A                  \ Shift A right
                        dec     b                           ; DEY                    \ Decrement the scale factor in Y
                        jp      nz,.DVL10                   ; BNE DVL10              \ Loop back to DVL10 until we have shifted right by Y places
                        ld      (varK),a                    ; STA K                  \ Store the shifted A in K so the result is now in K(3 2 1 0)
                        ld      a,(varT)                    ; LDA T                  \ Set K+3 to the sign in T, which we set above to the
                        ld      (varK+3),a                  ; STA K+3                \ correct sign for the result
                        ret                                 ; RTS                    \ Return from the subroutine
;
;   Set flags E to 11111110
;   Loop:   A << 2
;           if carry was 0
;               if a >= D
;                   A = A - D
;                   clear carry (probably irrelevant really)
;           else

;               sla flags << bringing in carry of 1
;               if bit 7 of flag was set then loop
;                                        elase a = e and exit
;
; ">BC_Div_DE: BC = BC / DE. HL = remainder fast divide with unrolled loop BC/DE ==> BC, remainder in HL
;
;INPUTS: hl = dividend dbc = divisor
;OUTPUTS: hl/de -> AHL = quotient CDE = remainder, Carryflag set if divide by 0

;;;DVIDT:                  ld      d,a                     ; D = var P+1
;;;                        ld      a,(varQ)            
;;;                        ld      c,a                     ; C = var Q
;;;                        ld      a,(varP)            
;;;                        ld      e,a                     ; E = var P
;;;                        ; Need fast exists on ABS values 
;;;BAequDEdivC:            ld      a,d                     ; Fast exit is value is 0
;;;                        or      e                       ; .
;;;                        jr      z,.ResultIsZero         ; .
;;;                        ld      a,c                     ; Fast exit is divide by 0 
;;;                        and     a                       ;
;;;                        jr      z,.ResultIsFFFF         ;
;;;.SavSign:               ld      a,d                     ; preserve sign of result in var T
;;;                        xor     c                       ;                        
;;;                        and     $80
;;;                        ld      l,a                     ; l = var T
;;;                        ld      a,0
;;;                        ld      b,16
;;;                        ShiftDELeft1
;;;                        sla     c                       ; c = abs c
;;;                        srl     c
;;;.DivideLoop:            rl      a
;;;                        JumpIfALTNusng c, .SkipSubtract
;;;                        ClearCarryFlag
;;;                        sbc     c
;;;                        ClearCarryFlag
;;;.SkipSubtract:          ccf
;;;                        rl      e
;;;                        rl      d
;;;                        dec     b
;;;                        jr      nz,.DivideLoop
;;;                        ld      a,e
;;;                        or      l
;;;                        ld      b,d
;;;                        ret
;;;.ResultIsZero:          ZeroA
;;;                        ld      b,a
;;;                        ret
;;;.ResultIsFFFF:          ld      a,$FF
;;;                        ld      b,a
;;;                        ret

;;;DIV96:                  ld      d,a                     ; D = var P+1
;;;                        ld      a,(varQ)            
;;;                        ld      c,96                    ; C = var Q
;;;                        ld      a,(varP)            
;;;                        ld      e,a                     ; E = var P
;;;                        ; Need fast exists on ABS values 
;;;BAequDEdiv96            ld      a,d                     ; Fast exit is value is 0
;;;                        or      e                       ; .
;;;                        jr      z,.ResultIsZero         ; .
;;;.SavSign:               ld      a,d                     ; preserve sign of result in var T
;;;                        xor     c                       ;                        
;;;                        and     $80
;;;                        ld      l,a                     ; l = var T
;;;                        ld      a,0
;;;                        ld      b,16
;;;                        ShiftDELeft1
;;;                        sla     c                       ; c = abs c
;;;                        srl     c
;;;.DivideLoop:            rl      a
;;;                        JumpIfALTNusng c, .SkipSubtract
;;;                        ClearCarryFlag
;;;                        sbc     c
;;;                        ClearCarryFlag
;;;.SkipSubtract:          ccf
;;;                        rl      e
;;;                        rl      d
;;;                        dec     b
;;;                        jr      nz,.DivideLoop
;;;                        ld      a,e
;;;                        or      l
;;;                        ld      b,d
;;;                        ret
;;;.ResultIsZero:          ZeroA
;;;                        ld      b,a
;;;                        ret
                        
Div16by24usgn:          inc     d                           ; can we fast retu
                        dec     d
                        jr      nz,.ResultZero
                        ld      de,bc                       ; so prep for bc/de
                        ld      bc,hl
.div16by16usng:         ld      a,d
                        or      e
                        jr      z,.DivideByZero
                        inc     d
                        dec     d
                        call    BC_Div_DE
                        ZeroA
                        ex      de,hl                       ; de = remainder (need to fix c after hl = nothing of worth)
                        ld      hl,bc                       ; hl = result (a is zero from above)
                        ld      c,a                         ; now fix c
                        ret 
.ResultZero:            xor     a                           ; set AHL to 0 as d was 0 so h is zero
                        ld      c,a                         ; c = 0
                        ld      h,a
                        ld      l,a
                        ret
.DivideByZero:          ld      a,$FF
                        ld      h,a
                        ld      l,a
                        SetCarryFlag
                        ret

;DIVD4 P-R=A/Qunsg  \P.R = A/Q unsigned called by Hall
            IFDEF HLEquAmul256DivD_Used
HLEquAmul256DivD:       ld		b,8							; counter
                        sla		a							; 
                        ld		h,a							; r a * 2 we will build result in hl
.DivideLoop:            rl		a							; a = a * 2
                        jr      c,.StraightToSubtraction    ; jump on carry to subtraction
                        cp      d                           ; what was var Q
                        jr		c,.SkipSubtraction	        ; if a < d skip subtraction, note this will come to skip subtraction with carry the wrong way round
.StraightToSubtraction: ClearCarryFlag                      ; in 6502 the borrow flag is inverted carry, z80 just uses carry so we need to clear it
                        sbc     a,d                         ; a = a - q
                        ClearCarryFlag                      ; set carry so it gets shifted into bit 0 of b. we do this as we have to flip carry due to jr c from earlier cp d
.SkipSubtraction:       ccf                                 ; we need to do this as 6502 does opposite on carry, i.e. if we jumped direct here then carry would be set in z80
                        rl      h                           ; roll d left bringing in carry if there was an sbc performed
                        djnz    .DivideLoop                 ; 8 cycles
.CalculateRemainder:    cp      d                           ; calulate 256 * a / d if q >= q then answer will not fit in one byte d is still set, a holds remainder to be subtracted
                        jr      nc, .RemainderTooBig
                        ClearCarryFlag                      ; remove carry as the previous cp will have set it and mess up the sla in the remainder loop
.InitRemainderLoop:     ld      b,%11111110                 ; loop for bits 1 to 7
                        ld      l,b                         ; and set l to capture result bits (R)
.RemainderLoop:         sla     a                           ; shift a left
                        jr      c, .RemainderSubtraction    ; if there was a carry go to subtraction
                        cp      d                           ; if a < d then skip subtraction
                        jr      c,.RemainderSkipSubtract    ; .
                        sbc     d                           ; a > q so a = a - q, carry will be clear here
.RemainderSkipSubtract: ccf                                 ; as the jr used z80 we need to flip the carry to behave like 6502
                        rl      l                           ; rotate counter to the left
                        jr      c, .RemainderLoop           ; if there was a bit pushed to carry then loop
                        ret
.RemainderSubtraction:  sbc     d                           ; as the carry came from an sla we want to retain it
                        SetCarryFlag                        ; roll in a carry bit to result
                        rl      l                           ;
                        jr      c, .RemainderLoop           ; and loop if there was a carry bit that came out
                        ret                       
.RemainderTooBig:       ld      l,$FF                       ; now hl = result
                        ret
            ENDIF

AEquAmul256DivD:        cp      d
                        jr      z,.BothSame
                        jr      nc,.DgtA
                        ld      e,%11111110                 ; Set R to have bits 1-7 set, so we can rotate through 7
.DivideLoop:            sla     a                        
                        jr      c,.LL29
                        JumpIfALTNusng  d, .SkipSub         ; will jump if carry set, so we need to reset on the rol
                        sub     d
                        ClearCarryFlag                      ; reset clarry as it will be complimented for rotate as 6502 does carry flags inverted
.SkipSub:               FlipCarryFlag                       ; if we did the subtract the carry will be clear so we need to invert to roll in.
                        rl      e
                        jr      c,.DivideLoop
                        ld      a,e
                        ret
.LL29:                  sub     d                           ; A >= Q, so set A = A - Q
                        SetCarryFlag                        ; Set the C flag to rotate into the result in R
                        rl      e                           ; rotate counter e left
                        jr      c,.DivideLoop               ; if a bit was spat off teh end then loop
                        ld      a,e                         ; stick result in a
                        ret
.BothSame:              ld  a,1
                        ret
.DgtA:                  ld  a,255                           ; Fail with FF as result
                        ret

; Divide 8-bit values
; In: Divide E by divider C
; Out: A = result, B = rest
;
;;;Div8:
;;;    xor a
;;;    ld b,8
;;;Div8_Loop:
;;;    rl e
;;;    rla
;;;    sub c
;;;    jr nc,Div8_NoAdd
;;;    add a,c
;;;Div8_NoAdd:
;;;    djnz Div8_Loop
;;;    ld b,a0
;;;    ld a,e
;;;    rla
;;;    cpl
;;;    ret

;;Inputs: DE is the numerator, BC is the divisor
;;Outputs: DE is the result
;;         A is a copy of E
;;         HL is the remainder
;;         BC is not changed
;; so DE = DE /BC
;140 bytes
;145cc	

MacroDEDivBC:       MACRO
                    rla
                    adc     hl,hl
                    sbc     hl,bc
                    jr      nc,$+3
                    add     hl,bc
                    ENDM

DEequDEDivBC:       xor a 
                    sbc hl,hl
                    ld a,d
                    MacroDEDivBC
                    MacroDEDivBC
                    MacroDEDivBC
                    MacroDEDivBC
                    MacroDEDivBC
                    MacroDEDivBC
                    MacroDEDivBC
                    MacroDEDivBC
                    rla 
                    cpl 
                    ld d,a

                    ld a,e
                    MacroDEDivBC
                    MacroDEDivBC
                    MacroDEDivBC
                    MacroDEDivBC
                    MacroDEDivBC
                    MacroDEDivBC
                    MacroDEDivBC
                    MacroDEDivBC
                    rla
                    cpl 
                    ld e,a
                    ret
;divdide by 16 using undocumented instrunctions
;Input: BC = Dividend, DE = Divisor, HL = 0
;Output: BC = Quotient, HL = Remainder
; Our use
; BC = A0
; DE = 0C
; so BC = a * 256 / C
DIV16Amul256dCUNDOC:    JumpIfAGTENusng	  c,DEV16ATooLarge                                          ; first off if a > c ten return 255
                        ld      b,a
                        ld      e,c
                        ld      c,0
                        ld      d,0
                        jp      DIV16UNDOC
DIV16Amul256dQUNDOC:    ld      b,a
                        ld      c,0
                        ld      hl,varQ
                        ld      a,(hl)
                        ld      d,0
                        ld      e,a
DIV16BCDivDEUNDOC:
DIV16UNDOC:             ld      hl,0
                        ld      a,b 
                        ld      b,16
DIV16UNDOCLOOP:         sll	c		; unroll 16 times
                        rla			; ...
                        adc	hl,hl		; ...
                        sbc	hl,de		; ...
                        jr	nc,DIV16UNDOCSKIP		; ...
                        add	hl,de		; ...
                        dec	c		; ...
DIV16UNDOCSKIP:         djnz DIV16UNDOCLOOP
                        ld   b,a
                        ret
DEV16ATooLarge:         ld     bc,$00FF
                        ret
; switch to logarithm version
; "> asm_div8 C_Div_D - C is the numerator, D is the denominator, A is the remainder, B is 0, C is the result of C/D,D,E,H,L are not changed"
asm_div8:               ld b,8
                        xor a
.div8_loop:	            sla c
                        rla
                        cp d
                        jr c,.div8_skip:
                        inc c
                        sub d
.div8_skip:	            djnz .div8_loop
                        ret
; ">asm_div16: HL_Div_C: HL is the numerator,  C is the denominator, output A is the remainder, B is 0, C,DE is not changedHL is the quotient"
asm_div16:              ld b,16
                        xor a
div16_loop:	            sla l
                        rl	h
;    add hl,hl
                        rla
                        cp c
                        jr c,div16_skip
                        inc l
                        sub c
div16_skip:		        djnz div16_loop
                        ret
;
; Divide 16-bit values (with 16-bit result)
; In: Divide BC by divider DE
; Out: BC = result, HL = rest
;
HLDivC_MACRO: 	        MACRO
                        add	    hl,hl		; unroll 16 times
                        rla				; ...
                        jr      c,      .DoSubInc
                        cp	    c			; ...
                        jr      c,      .NoSubInc
.DoSubInc:              sub	c			; ...			
                        inc	l			; ...
.NoSubInc:                        
                        ENDM

EDivC_Iteration:        MACRO
                        rl  e
                        rla
                        sub c
                        jr  nc,.Div8_NoAdd
                        add a,c
.Div8_NoAdd:            
                        ENDM

; Switch to a logarithm version
; Divide E by divider C Out: A = result, B = rest
E_Div_C:                ZeroA
                        EDivC_Iteration
                        EDivC_Iteration
                        EDivC_Iteration
                        EDivC_Iteration
                        EDivC_Iteration
                        EDivC_Iteration
                        EDivC_Iteration
                        EDivC_Iteration
                        ld      b,a
                        ld      a,e
                        rla
                        cpl
                        ret
                        
	
BCDIVDE_Iteration:      MACRO 
                        rla
                        adc	    hl,hl
                        add	    hl,de
                        jr	    c,1F
                        sbc	    hl,de
1:				        
                        ENDM
				   
	
; ">BC_Div_DE: BC = BC / DE. HL = remainder fast divide with unrolled loop"
;BC/DE ==> BC, remainder in HL
;NOTE: BC/0 returns 0 as the quotient.
;min: 738cc
;max: 898cc
;avg: 818cc
;144 bytes
BC_Div_DE:              xor a
                        ld h,a
                        ld l,a
                        sub e
                        ld e,a
                        sbc a,a
                        sub d
                        ld d,a
                        ld a,b
                        BCDIVDE_Iteration 
                        BCDIVDE_Iteration 
                        BCDIVDE_Iteration 
                        BCDIVDE_Iteration 
                        BCDIVDE_Iteration 
                        BCDIVDE_Iteration 
                        BCDIVDE_Iteration 
                        BCDIVDE_Iteration 
                        rla
                        ld b,a
                        ld a,c
                        BCDIVDE_Iteration 
                        BCDIVDE_Iteration 
                        BCDIVDE_Iteration 
                        BCDIVDE_Iteration 
                        BCDIVDE_Iteration 
                        BCDIVDE_Iteration 
                        BCDIVDE_Iteration 
                        BCDIVDE_Iteration 
                        rla
                        ld c,a
                        ret	
Floor_DivQSigned:       ld      a,b             ; save resultant sign
                        xor     d               ;
                        and     $80             ;
                        ld      ixh,a           ;
                        ld      a,b
                        and     $7F
                        ld      b,a
                        ld      a,d
                        and     $7F
                        ld      d,a
                        call    Floor_DivQ
                        ld      a,b
                        or      ixh
                        ld      b,a
                        ret
                        
                        
                            
; BC = BC / DE
; HL = BC % DE
; if HL > 0 BC -= 1
Floor_DivQ:             ld      a,b
                        or      c
                        jr      z, .divide0By   ; if bc is zero just return as result will be zero
                        ld      a,d
                        or      e
                        jr      z, .divideBy0
                        push    de
.DoDivide:              call    BC_Div_DE       ; bc(q0) = bc / de , hl(r0) = bc %de
                        pop     de              ; get divisor back to test
                        bit     7,d             ; if divisor <0 or = 0 goto else branch
                        jp      nz,.deLTE0
                        ld      a,d
                        or      e
                        jp      z,.deLTE0
.deGT0:                 bit     7,h             ; if remainder >=0 return with no adjustment
                        ret     z               ; if remainder was not negative then all done
                        dec     bc              ; else q --
                        ClearCarryFlag          ;      r += b
                        adc     hl,de           ;      .
                        ret
.deLTE0:                bit     7,h             ; if remainder <= 0 retun with no adjustment
                        ret     z               ; (return if negative)
                        ld      a,h
                        or      l               ; (return if zero)
                        ret     z
                        dec     bc              ; else q --
                        ClearCarryFlag          ;      r += b
                        adc     hl,de           ;      .
                        ret
.divide0By:             ld      hl,0            ; hl = 0, bc is already 0
                        ret      
.divideBy0:             ld      hl,0
                        ld      bc,1
                        ret      


L_DIV_0_ITERATION:      MACRO
                        rl      de              ;left shift dividend + quotient carry
                        ex      de,hl
                        rl      de              ;left shift remainder + dividend carry
                        ex      de,hl
                        sub     hl,bc           ;substract divisor from remainder
                        jp      nc,.skip_revert0 ;if remainder < divisor, add back divisor
                        add     hl,bc           ;revert subtraction of divisor
.skip_revert0:          ccf                     ;complement carry
                        rl      de              ;left shift dividend + quotient carry
                        ex      de,hl
                        rl      de              ;left shift remainder + dividend carry
                        ex      de,hl
                        sub     hl,bc           ;substract divisor from remainder
                        jp      NC,.skip_revert1 ;if remainder < divisor, add back divisor
                        add     hl,bc           ;revert subtraction of divisor
.skip_revert1:          ccf                     ;complement carry
                        ENDM

; HL = DE / BC, DE = DE % BC
l_div_0:                ld      hl,0            ;clear remainder
                        L_DIV_0_ITERATION
                        L_DIV_0_ITERATION
                        L_DIV_0_ITERATION
                        L_DIV_0_ITERATION
                        L_DIV_0_ITERATION
                        L_DIV_0_ITERATION
                        L_DIV_0_ITERATION
                        L_DIV_0_ITERATION
                        rl      de              ;left shift dividend + quotient carry
                        ex      de,hl           ;dividend<>remainder
                        ret



 
LLHLdivC:               ld      de,$FFFE                    ; set XY to &FFFE at start, de holds XY                        
.LL130:                 ShiftHLLeft1                        ; RS *= 2
                        ld      a,h
                        jr      c,.LL131                    ; if S overflowed skip Q test and do subtractions
                        JumpIfALTNusng c, .LL132            ; if S <  Q = 256/gradient skip subtractions
.LL131:                 ccf                                 ; compliment carry
                        sbc     a,c                         ; q
                        ld      h,a                         ; h (s)
                        ld      a,l                         ; r
                        sbc     a,0                         ; 0 - so in effect SR - Q*256
                        scf                                 ; set carry for next rolls
                        ccf
.LL132:                 RollDELeft1                         ; Rotate de bits left
                        jr      c,.LL130                    ; 
                        ex      de,hl                       ; hl = result
                        ret
                        
                        
div_hl_c:               xor	a
                        ld	b, 16           
.loop:                  add	hl, hl
                        rla
                        jr	c, $+5
                        cp	c
                        jr	c, $+4
                        sub	c
                        inc	l                      
                        djnz	.loop
                        ret
;l_div, signed division
; comes in with DE and HL
; HL = DE / HL, DE = DE % HL                       
l_div:                  ld      c,d             ;sign of dividend
                        ld      b,h             ;sign of divisor
                        push    bc              ;save signs
                        ld      c,l             ;divisor to bc
                        ld      a,d
                        or      a
                        jp      p,.NotDENeg
.DeNegate:              macronegate16de
.NotDENeg:              ld      a,b
                        or      a
                        jp      p,.NotBCNeg     ; if signs are opposite them flip
                        macronegate16bc
.NotBCNeg:              call    l_div_0         ;unsigned HL = DE / BC, DE = DE % BC
                        ; C standard requires that the result of division satisfy a = (a/b)*b + a%b emainder takes sign of the dividend
                        pop     bc              ;restore sign info
                        ld      a,b
                        xor     c               ;quotient, sign of dividend^divisor
                        jp      p,.NotHLNeg
                        macronegate16hl
.NotHLNeg:              ld      a,c
                        or      a,a             ;remainder, sign of dividend
                        ret     p
                        macronegate16de
                        ret

