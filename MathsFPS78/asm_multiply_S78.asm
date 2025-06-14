; asm_mulitply_S78
; Multiplcation routines for Lead sign 7.8 format, adapted based on Q88 format but only respresents negatives by sign bit 

; replaces all maths multplication

; DE = D (S7) * E (S7)
; Optimised mulitploy routines S7 by S7 signed
; muliptiply S7.0 bu ny S7e signed
; used A and B registers
; result in DE
; This replaces DEequDmulEs
; 16 bit HL * DE 
; start with lower and help with add sequence           ; all with carry flag (as lower case target reg)
;        L *     E   X0mulY0 1>> 1>>  shift >> 16       ;     HL = L * E
;        L *   D     Y1mulX0 0   1>>  shift >> 8        ;   DEHL = 00HL  + 0[L*D]0
;      H   *     E   X1mulY0 0   1>>  shift >> 8        ;   DEHL = DEHL  + 0[H*E]0 = DEH + 0[H*E]
;      H   *   D     X1mulY1 0   0    shift 0           ;  CDE   = CDE   + 0[H*D]
; 16 bit HL *  E 
; start with lower and help with add sequence           ; all with carry flag (as lower case target reg)
;        L *     E   X0mulY0 1>> 1>>  shift >> 16       ;     HL = L * E
;        L *   D     Y1mulX0 0   1>>  shift >> 8        ;   DEHL = 00HL  + 0[L*D]0
;      H   *     E   X1mulY0 0   1>>  shift >> 8        ;   DEHL = DEHL  + 0[H*E]0 = DEH + 0[H*E]
;      H   *   D     X1mulY1 0   0    shift 0           ;  CDE   = CDE   + 0[H*D]



DEequDmulEs:        ld      a,d                     ; work out resultant sign and load into b
                    xor     e                       ; .
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
                    
AequAmulQdiv256u:   ld      d,a
                    ld      a,(varQ)
                    ld      e,a
                    mul     de
                    ld      a,d
                    ret

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
    DISPLAY "TODO replace this with non memory access version"
HLequSRmulQdiv256:  ;X.Y=x1 lo.S*M/256  	\ where M/256 is gradient replaces HLequSRmulQdiv256
                    ld      hl,(varRS)
                    ld      a,(varQ)
HLeqyHLmulAdiv256:  push    bc,,de
                    ld      de,0        ; de = XY
                    ld      b,a         ; b = Q
                    ShiftHLRight1
                    sla     b
                    jr      nc,.LL126
.LL125:             ex      de,hl
                    add     hl,de       
                    ex      de,hl       ; de = de + rs
.LL126:             ShiftHLRight1
                    sla b
                    jr      c,.LL125
                    jr      nz,.LL126
                    ex      de,hl   ; hl = result
                    pop     bc,,de                        
                    ret
                        
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
; hl = de * hl where de & hl are small enough to always ne 16 bit result, replaces mulDEbyHL
HLequDEmulHL:       push    bc
                    ld      a,d                     ; a = x1
                    ld      d,h                     ; d = y1
                    ld      h,a                     ; h = x1
                    ld      c,e                     ; c = x0
                    ld      b,l                     ; b = y0
                    mul     de                      ; y1 * y0
                    ex      de,hl    
                    mul     de                      ; x1 * y0
                    add     hl,de                   ; add cross products
                    ld      e,c  
                    ld      d,b  
                    mul     de                      ; y0 * x0
                    ld      a,l                     ; cross products lsb
                    add     a,d                     ; add to msb final
                    ld      h,a  
                    ld      l,e                     ; hl = final
                    ; 83 cycles, 19 bytes   
                    xor     a                       ; reset carry
                    pop     bc
                    ret
HLequHLmulDEu:      
;H.L = H.L * D.E unsigned S7.8 format, just skips signed bit check
                    call    fixedS78_mulu
                    ld      l,h
                    ld      h,a
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
;DE.HL = D.E * H.L as  7.8 Fixed Point unsigned maths, when doing 24 bit maths scale down to 8.8 as its accurate enough
fixedS78_mulu:      ;            
.checkZeroMul:      ld      a,d
                    or      e
                    jp      z,.resultIsZero
                    ld      a,h
                    or      l
                    jp      z, .resultIsZero
.performMultiplyU:  ld      b,l                 ; b = x0
                    ld      c,e                 ; c =  y0
                    ld      e,l                 ; e = x0
                    ld      l,d                 ; l = y1 d is already y1
                    push    hl                  ; save x1 y1 to stack
                    ld      l,c                 ; l = y0
                    mul     de                  ; hl  = y1 * x0
                    ex      de,hl               ; . also setting de to x1 y0 as we prepped them in advance
                    mul     de                  ; x1*y0
                    ZeroA
                    add     hl,de               ; sum cross products of y1*x0, x1 * y0 as they require no shifting
                    adc     a,a                 ; and capture carry bit ready for p3
                    ld      e,c                 ; de = x0 * y0
                    ld      d,b                 ; .
                    mul     de                  ; .
                    ld      b,a                 ; carry from cross products setting bc to <c>h  (where <c> is carry flag)
                    ld      c,h                 ; .
                    ld      a,d                 ; h = high byte of x0 * y 0 _ lower byte of cross product of y1 * x0
                    add     a,l                 ; .
                    ld      h,a                 ; .)
                    ld      l,e                 ; so now we have lower btwo bytes of result in HL (p1 p0)                    
                    pop de                      ; get x1 and y1 back from stack into de ready for multiply
                    mul de                      ; hl = x1*y1 and de = p1 p0
                    ex de,hl                    ; .
                    adc hl,bc                   ; hl = (x1 * y1) + <c>h (where h is upper byte of cross product from above)
                    ex de,hl                    ; swap over de and hl for final result
                    ret
.resultIsZero:      ld      de,0
                    ld      hl,0
                    ret
