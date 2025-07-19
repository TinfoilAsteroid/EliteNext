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
; BC = BC/DE (ceheck this is correctg wording)                       
BCDIVDE_Iteration:      MACRO 
                        rla
                        adc	    hl,hl
                        add	    hl,de
                        jr	    c,1F
                        sbc	    hl,de
1:				        
                        ENDM
                        
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
; BC = A0 / C
div_a256_div_c:         ld      d,0
                        ld      e,c
                        ld      b,a
                        ld      c,0
                        call    BC_Div_DE
                        ret

;Inputs: DE is the numerator, BC is the divisor
;;Outputs: DE is the result
;;         A is a copy of E
;;         HL is the remainder
;;         BC is not changed
;; so DE = DE /BC
;140 bytes
;145cc	
; DE = DE/BC
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
                    
; ">asm_div16: HL_Div_C: HL is the numerator,  C is the denominator, output A is the remainder, B is 0, C,DE is not changedHL is the quotient"
div_hl_div_c:           ld b,16
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
                        