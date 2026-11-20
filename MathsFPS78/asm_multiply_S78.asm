; asm_mulitply_S78
; Multiplcation routines for Lead sign 7.8 format, adapted based on Q88 format but only respresents negatives by sign bit 

; replaces all maths multplication

; (DEequDmulEs, D (S7) * E (S7) = DE, had no callers: moved to Unused/Unused/DEequDmulEs.asm)
; A = A * Q / 256 unsigned is the AequAmulCdiv256u macro in Macros/MathsMacros.asm, with Q in C
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
;H.L = H.L * D.E unsigned 8.8 (bits 8-23 of the 32 bit product, so truncated), no sign handling
                    call    fixedS78_mulu       ; DE.HL = product
                    ld      l,h                 ; l = bits 8-15
                    ld      h,e                 ; h = bits 16-23
                    ret
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
