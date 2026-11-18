; Routines moved out of MathsFPS78/asm_multiply_S78.asm as nothing in the eliteNext.asm build references them.
; Not included in the game build; INCLUDE this after asm_multiply_S78.asm to use them again.

fixedS158_muls:
;HL.0 = BH.L * CD.E, does this by scaling down to BH * CD then scaled result up by a word
                    ld      l,h
                    ld      h,b
                    ld      e,d
                    ld      d,c
                    jp      fixedS78_muls

AequAmulEdiv256u:   ld      d,a
                    mul     de
                    ld      a,d
                    ret   

; DE.LC = HL.E by .D leading Sign (replaces mulHLEbyDSigned)
DELCequHLEmulDs:    call    DEHLequHLEmulDs     ; Retained for backwards compatibility until swapped 
                    ld      c,l                 ; to DEHLequHLEmulDs in all code
                    ld      l,h
                    ret

; DE.HL = HL.E by .D leading Sign (replaces mulHLEbyDSigned)
DEHLequHLEmulDs:    ld      a,d                 ; get sign from d
                    xor     h                   ; xor with h to get resultant sign
                    and     SignOnly8Bit        ; .
                    ld      iyh,a               ; iyh = copy of sign
                    res     7,h                 ; clear sign bit to get ABS values
                    res     7,d                 ;
.ChecForZero:       ld      a,d                 ; quick test for d
                    and     a
                    jr      z,.ResultZero       ; now test HLE
                    ld      a,h                 ;
                    or      l                   ;
                    or      e                   ;
                    jr      z,.ResultZero       ;
.LoadForDEHLmulAu:  ld      a,d                 ; we now have divisor set
                    ld      d,e
                    ld      e,h
                    ld      h,l
                    ld      l,d                    
                    call    DEHLequEHLmulAu     
                    ld      a,d
                    or      iyh                 ;
                    ld      d,a                 ; d is set , now need to shift about HL into LC (later we will change calls)
                    ret
.ResultZero:        ZeroA
                    ld      d,a
                    ld      e,a
                    ld      l,a
                    ld      c,a
                    ret

; adehl = ehl * a , we will simplify this down to ehl * a (or d?)      
DEHLequEHLmulAu:    ;ld      b,0 ; N/A ld      b,d                       ; relocate DE
                    ld      c,e                 ; x2
                    ld      e,l                 ; x0
                    ld      d,a                 ; y0
                    mul     de                  ; de = y0*x0
                    ex      af,af               ; save y0 'accumulator
                    ld      l,e                 ; l = p0
                    ld      a,d                 ; a = p1 carry
                    ex      af,af               ; get back y0
                    ld      e,h                 ; x1
                    ld      d,a                 ; y0
                    mul     de                  ; y0*x1
                    ex      af,af               ; get back carry
                    add     a,e                 ; h = carry + LSW of y0 & x1
                    ld      h,a                 ; .
                    ld      a,d                 ; a = p2 carry
                    ex      af,af               ; get back y0
                    ld      e,c                 ; y0*x2
                    ld      d,a                 ; .
                    mul     de                  ; .
                    ex      af,af               ; get back p2 carry
                    adc     a,e                 ; and add LWS of y0*x2
                    ld      e,a                 ; e = p3 so its set
                    ld      a,d
                    adc     a,0                 ; and set d to the carry bit if there was one
                    ld      d,a                 ; d = carry, so the result is DEHL
                    ret

; ahl = hl * e simplified 16x8 muliplication
AHLequHLmulE:       ld      d,h                 ; x1
                    ld      h,e                 ; y0
                    mul     de                  ; x1*y0
                    ex      de,hl
                    mul     de                  ; y0*xl, hl = x1*y0l
                    ld      a,d                 ; sum products
                    add     a,l
                    ld      d,a
                    ex      de,hl
                    ld      a,d
                    adc     a,0
                    ret


                    DISPLAY "TO DO TEST IF this gets D correct"

; AHL = HL * E unsigned, in effect X1 X0 * Y0                  
AHLequHLmulEu:      xor     e                       ; .
                    and     SignOnly8Bit            ; .
                    ld      b,a                     ; .
                    ld      a,d                     ; now clear d sign bit
                    and     SignMask8Bit            ; .
                    ld      d,a                     ; .
                    ld      a,e                     ; now clear e sign bit
                    and     SignMask8Bit            ; .
                    ld      e,a                     ; .
                    mul     de                      ; do mulitply
                    ld      a,d                     ; get sign bit from b and re0introduce it
                    or      b                       ; .
                    ld      d,a                     ; .
                    ret
.performMultiplyU:  ld      d,h                     ; de = x1 y0
                    ld      h,e                     ; save y0 into h
                    mul     de                      ; de = x1 * y0
                    ex      de,hl                   ; de = y0 x0, hl = x1 * y0 (p2 p1)
                    mul     de                      ; de = y0 * x0
                    ld      a,d                     ; sum products y0 * x0 upper byte + x1 * y0 lower byte
                    add     a,l                     ; .
                    ld      d,a                     ; d = result (p1)
                    ex      de,hl                   ; hl = p1 p0
                    ld      a,d                     ; a = p2 + carry from add above
                    adc     a,0                     ;
                    ex      de,hl                   ; now result is in ADE
                    ret

fixedS78_muls:      
;H.L = D.E * H.L as S7.8 Fixed Point maths, when doing 24 bit maths scale down to 8.8 as its accurate enough
HL_Mul_DE_88:       
.checkSigns:        ld      a,d
                    xor     h
                    and     $80
                    ld      iyl,a               ; sign bit is the result sign bit held in iy as we want to optimise                    
.forcePositiveOnly: res     7,d                 ; de = abs de
                    res     7,h                 ; hl = abs hl
                    call    fixedS78_mulu       ; DEHL = DE * HL, 
.getS88Result:      ld      l,h                 ; we want to lose D and L as part of return so put EH into HL
                    ld      h,e                 ; .
                    ld      a,h                 ; now return result with sign bit, if the result over flowed into S88 then it will be out
                    or      iyl                 ;
                    ld      h,a                 ;
                    ret                         ;
; Commented-out code that originally followed AHLequHLmulE
                    ;ld      c,a                 ; c = p2
                    ;ld      a,d                 ; a = p3 carry
                    ;ex      af,af
                    ;ld e,b                     we don;t have x3
                    ;ld d,a
                    ;mul de                       ; y*x3
                    ;ex af,af
                    ;adc a,e
                    ;ld b,a                       ;'p3
                    ;ld a,d                       ;'p4 carry
                    ;adc a,0                      ;'final carry
                    
                    ;ld d,b                       ; return DE
                    ;ld e,c
                    
; kept for now but think its good to delete
;                    
;                    ld      b,d                 ; save Quotient y0
;.mul1:              mul     de                  ; [IYL]C = E * D    (p1) (p0) x0 * y0
;                    ld      c,e                 ; .
;                    ld      iyl,d               ; .
;.mul2:              ld      e,l                 ; de = x1 * y0
;                    ld      d,b                 ; .
;                    mul     de                  ; .
;                    ld      a,iyl               ; get back p1 (carry)
;.carrybyte1:        add     a,e                 ; l = p1 = p1 + LSW of x1 * y0 and we are doen with carry
;                    ld      l,a                 ; .
;                    ld      iyl,d               ; save new carry byte MSW of x1 * y0
;.mul3:              ld      e,h                 ; E = H * D
;                    ld      d,b                 ; .
;                    mul     de                  ; .
;                    ld      a,iyl
;                    adc     a,e                 ; .
;                    ld      e,a                 ; .
;.ItsNotZero:        ld      a,d                 ;
;                    adc     a,0                 ; final carry bit
;                    or      iyh                 ; bring back sign
;                    ld      d,a                 ; s = sign
;                    ret
;.ResultZero:        ld      de,0
;                    ZeroA
;                    ld      c,a
;                    ld      l,a
;                    ret

; Only used by the legacy line code (now in Layer2Graphics/Unused/l2_draw_any_line_unused.asm).
; NOTE: HLequHLmulDE2sc has no final ret, a negative result falls through into AequDmulEdiv256u (keep them together).
;HL = HL * DE in 2's compliment                    
HLequHLmulDE2sc:        ld      a,d
                        xor     h
                        and     SignOnly8Bit
                        ld      iyh,a               ; save sign bit for result
                        ld      a,h
                        and     SignOnly8Bit
                        jr      z,.HLPositive
.HLNegative:            NegHL
.HLPositive:            ld      a,d
                        and     SignOnly8Bit
                        jr      z,.DEPositive
.DENegative:            NegDE
.DEPositive:            call    HLequHLmulDEu         ; now do calc
                        ld      a,iyh
                        and     a                   ; if its 0 then we are good
                        ret     z
                                            
; "ASM_FMUTKL .FMLTU	\ -> &2847  \ A=D*E/256unsg  Fast multiply"
AequDmulEdiv256u:   mul     de
                    ld	a,d				; we get only the high byte which is like doing a /256 if we think of a as low
                    ret
