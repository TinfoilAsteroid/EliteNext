;   For divide
;   Split BHL/CDE into 
;         BCDE.HL = HL/CD + BCDE.HL = BHL*1/E
;         ; for 24 bit divide
;         ; if both BC are non zero, to BH.0/CD.0
;         ; if CD = 0 do BH.L/00.L
;         ; if B = 0 & C != 0 then result is B*256/C >> 8
; Table B   H   L   C   D   E                                    HLD.E
;       !   !   !   !   !   !       BH.0/CD.0 (16/16) => HL/DE  =>00D.0
;       !   !   !   0   !   !       BH.0/D.0 (16/8)      BHL/DE =>0LD.0 (result << 8)
;       0   !   !   !   !   !       0  
;       0   !   !   0   !   !       H.L/D.E (16 bit)  => HL/DE  =>00D.E (result >> 8)
;       0   !   !   0   0   !       H.L/0.E (16 bit)  => HL/DE  =>00D.E (result >> 8)
;       0   0   !   !   !   !       0
;       0   0   !   0   !   !       0
;       0   0   !   0   0   !       00.L/00.E
;       0   0   0   X   X   X       0
;       X   X   X   0   0   0       carry set
; Fixed  24 bit maths S48.16 = BDE * AHL where A=S BCDE=48 HL=16, used by other routines which drop unneeded bytes
;  X 2 1 0 Y 2 1 0
;    B H L   C D E                   
; 24 bit multiply
; start with lower and help with add sequence           ; all with carry flag (as lower case target reg)
;        L *     E   X0mulY0 1>> 1>>  shift >> 16       ;     HL = L * E
;        L *   D     Y1mulX0 0   1>>  shift >> 8        ;   DEHL = 00HL  + 0[L*D]0
;      H   *     E   X1mulY0 0   1>>  shift >> 8        ;   DEHL = DEHL  + 0[H*E]0 = DEH + 0[H*E]
;    B     *     E   X2mulY0 1<< 1>>  shift 0           ;  CDE   = 0DE   + 0[B*E]
;        L * C       Y2mulX0 1<< 1>>  shift 0           ;  CDE   = CDE   + 0[L*C]
;      H   *   D     X1mulY1 0   0    shift 0           ;  CDE   = CDE   + 0[H*D]
;    B     *   D     X2mulY1 1<< 0<<  shift << 8        ; BCD    = 0CD   + 0[B*D]
;      H   * C       Y2mulX1 1<< 0    shift << 8        ; BCD    = 0CD   + 0[H*C]
;    B     * C       X2mulY2 1<< 1<<  shift <<16        ; BC     = BC    + [B*C]
; 16 bit multiply
; start with lower and help with add sequence           ; all with carry flag (as lower case target reg)
;        L *     E   X0mulY0 1>> 1>>  shift >> 16       ;     HL = L * E
;        L *   D     Y1mulX0 0   1>>  shift >> 8        ;   DEHL = 00HL  + 0[L*D]0
;      H   *     E   X1mulY0 0   1>>  shift >> 8        ;   DEHL = DEHL  + 0[H*E]0 = DEH + 0[H*E]
;      H   *   D     X1mulY1 0   0    shift 0           ;  CDE   = CDE   + 0[H*D]
;                                                       ; Result BCDE.HL

; so in our calcs we have
;     bhl  *  cde
;     HLD1    HLD2    
; which maps to bytes 5 4 3 2 1 0
;  D1 * D2                    X X  1    de = l * e   (D1 * D2)
;  L1 * D2                  X X    2    hl = h * e   (L1 * D2)  e = d, d = 0 add hl,de and move carry to a (result ahl)
;  D1 * L2                  X X    3    de = l * d   (D1 * L2)  add hl,de and adc a,0                      (result ahl) with l being final ".h" A is starter for e so we now have l spare 
;  D1 * H2                X X      4    de = l * c   (D1 * H2)
;  L1 * L2                X X      5    hl = h * d   (L1 * L2)
;  H1 * D2                X X      6    bc = b * e   (H1 * D2)  add hl,de,bc, a (from previous carry)      (result ahl) with l being final "e." h is starter for d and a is starter for c
;  L1 * H2              X X        7    de = h * c   (L1 * H2)
;  H1 * L2              X X        8    bc = b * d   (H1 * L2)  add de,bc, ah                              (result ahl) with l being final "d"  h is starter for c and a is starter for b
;  H1 * H2            X X          9    bc = b * c   (H1 * H2)  add bc,ah,c                                (result ahl) with hl being
;                     b c d e h l for result we only care about cde.h
;signed muliply 
    DISPLAY "TO DO - add leading sign to mul24"
    DISPLAY "TO DO - Optimisae mul24 for leading 0's to do 8.8 x 8.8"
    DISPLAY "NOT BANK0 SAFE"
;BH.L by CD.E putting result in BCDE.HL and put the resullt in MulitplyResults then puyll teh actual result to BCDE.HL
mul24Signed:            ld      a,b
                        xor     c
                        and     $80
                        push    af
                        res     7,b
                        res     7,c
.TestForZero:           ld      a,b
                        or      h
                        or      l
                        jp      z,.resultIsZero
                        ld      a,c
                        or      d
                        or      e
                        jp      z,.resultIsZero
                        call    mul24
                        pop     af
                        or      d
                        ld      d,a
                        ret
.resultIsZero:          pop     af
                        ld      de,0
                        ld      h,0
                        ret
                        
mul24:                  ld      a,d                 ; preserve L2 for later
                        ld      d,l
                        ld      (.mul24_1+1),de     ; write to D1 * D2 calc 1
                        ld      d,h
                        ld      (.mul24_2+1),de     ; write to L1 * D2 calc 2
                        ld      d,b
                        ld      (.mul24_6+1),de     ; write to H1 * D2 calc 6
                        ld      d,a                 ; get back L2
                        ld      e,l
                        ld      (.mul24_3+1),de     ; (D1 * L2)   3
                        ld      e,h
                        ld      (.mul24_5+1),de     ; (L1 * L2)   5
                        ld      e,b
                        ld      (.mul24_8+1),de     ; (H1 * L2)   8
                        ld      de,bc
                        ld      (.mul24_9+1),de     ; (H1 * H2)   9
                        ld      d,l
                        ld      (.mul24_4+1),de     ; (D1 * H2)   4
                        ld      d,h
                        ld      (.mul24_7+1),de     ; (L1 * H2)   7
.mul24_1:               ld      de,$0000            ; D1 * D2 for lowest 16 bites
                        mul     de
                        ld      (MultiplyResult),de ; save result as we have a completed byte 0 of result
                        ld      l,d                 ; now we have thbe shifed result for step 2
                        ld      h,0                 ;
                        ZeroA                       ; clear accumulator for carry bit
.mul24_2:               ld      de,$0000            ; L1 * D2 
                        mul     de
                        add     hl,de               ; hl = (L1 * D2) + (D1*D2)high byte with a carry
                        adc     a,0                 ; a holds carry incase of any overflow
.mul24_3:               ld      de,$0000            ; now add in D1 * L2
                        mul     de                  ; so we have a completed byte 1 of result
                        add     hl,de               ;
                        adc     a,a                 ; So now we hbave byte 1 complete and ahl holding current bytes 321
                        ld      (MultiplyResult+1),hl; save byte 1 (in l) of result
                        ld      l,h                 ; prep carry over for step 4
                        ld      h,a                 ; .
.mul24_4:               ld      de,$0000            ; now (D1 * H2)
                        mul     de                  ; .
                        ZeroA
                        add     hl,de               ; and bring in carry over from step 3
                        adc     a,a                 ; so ahl is the result
.mul24_5:               ld      de,$0000            ; now (D1 * H2)
                        mul     de                  ; .
                        or      a                   ; clear carry flag
                        add     hl,de               ; and bring in carry over from step 4
                        adc     a,a                 ; so ahl is the result                        
.mul24_6:               ld      de,$0000            ; now (D1 * H2)
                        mul     de                  ; .
                        or      a                   ; clear carry flag
                        add     hl,de               ; and bring in carry over from step 5
                        adc     a,a                 ; so ahl is the result of bytes 654               
                        ld      (MultiplyResult+2),hl; save byte 2 (in l) of result
                        ld      l,h                 ; prep carry over for step 7
                        ld      h,a                 ; .    
.mul24_7:               ld      de,$0000            ; now (D1 * H2)
                        mul     de                  ; .
                        or      a                   ; clear carry flag
                        add     hl,de               ; and bring in carry over from step 6
                        adc     a,a                 ; so ahl is the result 
.mul24_8:               ld      de,$0000            ; now (D1 * H2)
                        mul     de                  ; .
                        or      a                   ; clear carry flag
                        add     hl,de               ; and bring in carry over from step 7
                        adc     a,a                 ; so ahl is the result  
                        ld      (MultiplyResult+3),hl; save byte 3 (in l) of result
                        ld      l,h                 ; prep carry over for step 8
                        ld      h,a                 ; .    
.mul24_9:               ld      de,$0000            ; now (D1 * H2)
                        mul     de                  ; .
                        add     hl,de               ; and bring in carry over from step 7
                        adc     a,a                 ; so ahl is the result 
                        ld      (MultiplyResult+4),hl; save bytes 4 5 of result
                        ld      hl,(MultiplyResult)
                        ld      de,(MultiplyResult+2)
                        ld      bc,(MultiplyResult+4)
                        ret
