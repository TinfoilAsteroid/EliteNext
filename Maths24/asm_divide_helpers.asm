;----------------------------------------------------------------------------------------------------------------------------------
; Floor_DivQ: BC = BC / DE (unsigned), HL = BC % DE
; DE is preserved. BC = 0 gives BC = 0, HL = 0. DE = 0 gives BC = 1, HL = 0.
; (The name comes from a signed floor divide; BC_Div_DE is unsigned so the result is always the plain quotient.
;  The old signed adjustment wrongly decremented BC whenever the remainder was 32768 or more.)
Floor_DivQ:             ld      a,b
                        or      c
                        jr      z, .divide0By   ; if bc is zero just return as result will be zero
                        ld      a,d
                        or      e
                        jr      z, .divideBy0
                        push    de
                        call    BC_Div_DE       ; bc = bc / de , hl = bc % de
                        pop     de
                        ret
.divide0By:             ld      hl,0            ; hl = 0, bc is already 0
                        ret
.divideBy0:             ld      hl,0
                        ld      bc,1
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; BCDIVDE_Iteration: one bit of BC_Div_DE, shifts the next dividend bit from A into the remainder HL and subtracts
; the divisor (DE holds -divisor), the inverted quotient bit is left in carry for the next rla
BCDIVDE_Iteration:      MACRO
                        rla
                        adc	    hl,hl
                        add	    hl,de
                        jr	    c,1F
                        sbc	    hl,de
1:
                        ENDM
;----------------------------------------------------------------------------------------------------------------------------------
; BC_Div_DE: BC = BC / DE, HL = BC % DE, all unsigned 16 bit. DE must not be 0.
; Destroys A and DE (DE is left as -DE)
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
;----------------------------------------------------------------------------------------------------------------------------------
; div_a256_div_c: BC = (A * 256) / C, unsigned, HL = remainder. C must not be 0.
; Destroys A and DE
div_a256_div_c:         ld      d,0
                        ld      e,c
                        ld      b,a
                        ld      c,0
                        call    BC_Div_DE
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; div_de_div_bc_signed: DE = DE / BC with DE, BC as 16 bit lead sign values (bit 15 = sign, 15 bit magnitude).
; Magnitude = |DE| / |BC| truncated, sign = sign DE xor sign BC, a zero result is always +0. BC = 0 divides by 1.
; Destroys A, BC (sign bit cleared), HL
div_de_div_bc_signed:   ld      a,d                     ; result sign = sign de xor sign bc
                        xor     b
                        and     $80
                        ex      af,af'          ; save sign bit
                        res     7,d
                        res     7,b
                        ld      a,d
                        or      e
                        jp      z,  .ResultIsZero
                        ld      a,b
                        or      c
                        jp      nz, .OKtoDivide
                        ld      c,1
.OKtoDivide:            call    DEequDEDivBC    ; de = |de| / |bc|
                        ld      a,d
                        or      e
                        jr      z,.ResultIsZero ; never return -0
                        ex      af,af'          ; get back sign and set as needed
                        or      d               ;
                        ld      d,a             ;
                        ret
.ResultIsZero:          ex      af,af'          ; restore the caller's af'
                        ld      de,0
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; MacroDEDivBC: one bit of DEequDEDivBC, shifts the next dividend bit from A into the remainder HL and subtracts BC,
; restoring if it went negative; the inverted quotient bit is left in carry for the next rla
MacroDEDivBC:       MACRO
                    rla
                    adc     hl,hl
                    sbc     hl,bc
                    jr      nc,$+3
                    add     hl,bc
                    ENDM
;----------------------------------------------------------------------------------------------------------------------------------
; DEequDEDivBC: DE = DE / BC, HL = DE % BC, all unsigned 16 bit. BC must not be 0.
; A = copy of E (the quotient low byte), BC is not changed. 140 bytes, 145cc
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
;----------------------------------------------------------------------------------------------------------------------------------
; div_hl_div_c: HL = HL / C, A = HL % C, unsigned 16 by 8 bit. C must not be 0.
; B = 0 on exit, C and DE are not changed. Works for any C (1-255): when the shifted remainder overflows 8 bits
; it is always >= C so the subtract is forced (previously C >= 128 gave wrong results).
div_hl_div_c:           ld b,16
                        xor a
div16_loop:	            sla l
                        rl	h
                        rla
                        jr  c,.Subtract                 ; remainder went past 255 so it is >= c
                        cp c
                        jr c,div16_skip
.Subtract:              inc l
                        sub c
div16_skip:		        djnz div16_loop
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; EDivC_Iteration: one bit of div_e_div_c, shifts the next bit of E into the remainder A and subtracts C, restoring
; if it borrowed; the inverted quotient bit is left in carry and rotated into E by the next iteration
EDivC_Iteration:        MACRO
                        rl  e
                        rla
                        sub c
                        jr  nc,.Div8_NoAdd
                        add a,c
.Div8_NoAdd:
                        ENDM
;----------------------------------------------------------------------------------------------------------------------------------
; div_e_div_c: A = E / C, B = E % C, unsigned 8 bit. C must not be 0. Destroys E.
div_e_div_c:            ZeroA
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
;----------------------------------------------------------------------------------------------------------------------------------
; RequAmul256divQ / BFRDIV: varR = A = (A * 256) / varQ, unsigned, 255 if A >= Q (as the 6502 LL28/BFRDIV).
; RequAmul256divC: the same with the divisor already in C, HL_Div_Cold: the same with HL = A * 256 already set.
; Q/C must not be 0. Destroys B, C, HL. (Previously Q >= 128 gave wrong results and A >= Q returned the low
; byte of the quotient instead of 255.)
RequAmul256divQ:
BFRDIV:                 push	af
                        ld		a,(varQ)
                        ld		c,a
                        pop		af
                        cp		0
                        jp		z, HLDIVC_0_BY	; fast exit if numerator is 0
RequAmul256divC:        cp      c
                        jr      nc,HLDIVC_TooBig ; A >= C so the result will not fit in a byte
                        ld		l,0
                        ld		h,a
HL_Div_Cold:			ld b,16			; fast entry point if C and HL are already set
                        xor a
LOOPPOINT:	            add hl,hl
                        rla
                        jr  c,.Subtract         ; remainder went past 255 so it is >= c
                        cp c
                        jr c,SKIPINCSUB
.Subtract:              inc l
                        sub c
SKIPINCSUB:             djnz LOOPPOINT
                        ld		a,l
                        ld 		(varR),a
                        ret
HLDIVC_TooBig:          ld      a,255
HLDIVC_0_BY:            ld		(varR),a
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; AEquAmul256DivD: A = (A * 256) / D, unsigned, 255 if A >= D (6502 LL28 style). D must not be 0.
; Destroys E
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
.BothSame:              ld  a,255
                        ret
.DgtA:                  ld  a,255                           ; Fail with FF as result
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; DIV16Amul256dCUNDOC: BC = (A * 256) / C, unsigned, BC = $00FF if A >= C. HL = remainder. C must not be 0.
; Destroys A, DE. Uses the undocumented sll instruction through DIV16UNDOC.
DIV16Amul256dCUNDOC:    JumpIfAGTENusng	  c,DEV16ATooLarge                                          ; first off if a > c ten return 255
                        ld      b,a
                        ld      e,c
                        ld      c,0
                        ld      d,0
                        jp      DIV16UNDOC
;----------------------------------------------------------------------------------------------------------------------------------
; DIV16BCDivDEUNDOC / DIV16UNDOC: BC = BC / DE, HL = BC % DE, all unsigned 16 bit. DE must not be 0.
; DE is not changed, destroys A. Uses the undocumented sll instruction to shift the quotient bit in.
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
;----------------------------------------------------------------------------------------------------------------------------------
; asm_div8: C = C / D, A = C % D, unsigned 8 bit. D must not be 0.
; B = 0 on exit, D, E, H, L are not changed
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
;----------------------------------------------------------------------------------------------------------------------------------
; Div16by24usgn: AHL = HL / DBC, unsigned, HL 16 bit dividend and D:B:C a 24 bit divisor (D = top byte).
; A = 0 and C = 0 on exit, DE = remainder. D <> 0 means the divisor is > 65535 so the result is 0.
; Divisor 0 returns AHL = $FFFFFF with carry set.
Div16by24usgn:          inc     d                           ; if the divisor top byte is non zero
                        dec     d                           ; then divisor > dividend so the result is 0
                        jr      nz,.ResultZero
                        ld      de,bc                       ; so prep for bc/de
                        ld      bc,hl
.div16by16usng:         ld      a,d
                        or      e
                        jr      z,.DivideByZero
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
;----------------------------------------------------------------------------------------------------------------------------------
; Amul256DivQ: varR = A = (A * 256) / varQ, unsigned (6502 LL28 port). If A >= Q, R = 255 and carry is set.
; Q must not be 0. Destroys B, C, HL
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
