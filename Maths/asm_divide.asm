


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

DVIDT:                  ld      d,a                     ; D = var P+1
                        ld      a,(varQ)            
                        ld      c,a                     ; C = var Q
                        ld      a,(varP)            
                        ld      e,a                     ; E = var P
                        ; Need fast exists on ABS values 
BAequDEdivC:            ld      a,d                     ; Fast exit is value is 0
                        or      e                       ; .
                        jr      z,.ResultIsZero         ; .
                        ld      a,c                     ; Fast exit is divide by 0 
                        and     a                       ;
                        jr      z,.ResultIsFFFF         ;
.SavSign:               ld      a,d                     ; preserve sign of result in var T
                        xor     c                       ;                        
                        and     $80
                        ld      l,a                     ; l = var T
                        ld      a,0
                        ld      b,16
                        ShiftDELeft1
                        sla     c                       ; c = abs c
                        srl     c
.DivideLoop:            rl      a
                        JumpIfALTNusng c, .SkipSubtract
                        ClearCarryFlag
                        sbc     c
                        ClearCarryFlag
.SkipSubtract:          ccf
                        rl      e
                        rl      d
                        dec     b
                        jr      nz,.DivideLoop
                        ld      a,e
                        or      l
                        ld      b,d
                        ret
.ResultIsZero:          ZeroA
                        ld      b,a
                        ret
.ResultIsFFFF:          ld      a,$FF
                        ld      b,a
                        ret

DIV96:                  ld      d,a                     ; D = var P+1
                        ld      a,(varQ)            
                        ld      c,96                    ; C = var Q
                        ld      a,(varP)            
                        ld      e,a                     ; E = var P
                        ; Need fast exists on ABS values 
BAequDEdiv96            ld      a,d                     ; Fast exit is value is 0
                        or      e                       ; .
                        jr      z,.ResultIsZero         ; .
.SavSign:               ld      a,d                     ; preserve sign of result in var T
                        xor     c                       ;                        
                        and     $80
                        ld      l,a                     ; l = var T
                        ld      a,0
                        ld      b,16
                        ShiftDELeft1
                        sla     c                       ; c = abs c
                        srl     c
.DivideLoop:            rl      a
                        JumpIfALTNusng c, .SkipSubtract
                        ClearCarryFlag
                        sbc     c
                        ClearCarryFlag
.SkipSubtract:          ccf
                        rl      e
                        rl      d
                        dec     b
                        jr      nz,.DivideLoop
                        ld      a,e
                        or      l
                        ld      b,d
                        ret
.ResultIsZero:          ZeroA
                        ld      b,a
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

;DIVD4 P-R=A/Qunsg  \P.R = A/Q unsigned called by Hall
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
HLDivC_Iteration: 	    MACRO
                        add	hl,hl		; unroll 16 times
                        rla				; ...
                        cp	c			; ...
                        jr	1F
                        sub	c			; ...
1:					
                        inc	l			; ...
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
; BC = BC / DE
; HL = BC % DE
; if HL > 0 BC -= 1
Floor_DivQ:             ld      a,d
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

