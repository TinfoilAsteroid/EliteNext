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

; most likley optimisation will be the value is 8.8 so we can quickly eliminate this
; then will be a 0.8 when we are doing things like docking so objects will be close and large
; 8.0 will be unlikley so we will just optimise on 78.8, 8.8, 0.8 
; we can also optimise code size if only one side is 08.8 etc by swapping over BHL and CDE as needed
BCDEHLequBHLmulCDEs:    ld      a,b
                        xor     c
                        and     0x80
                        res     7,b                     ; clear sign bits
                        res     7,c                     ; res does not affect flags
                        jp      z,BCDEHLequBHLmulCDEu   ; can just jp as is also sets A to 0 for sign
.BCDEHLNegative:        call    BCDEHLequBHLmulCDEu     ; do unsigned maths
                        ld      a,0x80                  ; set a = sign bit
                        set     7,b                     ; and set sign bit on b
                        ret

BCDEHLequBHLmulCDEu:    ZeroA
                        or      b
                        jp      z,.X2Zero               ; first pass check X2 = 0?
.X2checkY2:             ZeroA                           ; now check Y2 = 0?
                        or      c
                        jp      z,BCDEHLequ24mul24u     ;  fro nwo ignore optimsation X2 is non 0, Y2 is zero eliminating 3 mulitplies
.Do24BitMul:            jp      BCDEHLequ24mul24u       ; X2 and Y2 are non zero so in most cases it will be a regular 78.8 x 78.8 so just do 24 bit mul
.X2Zero:                or      c
                        jp      z,.checkFor8BitMul      ; X2 and Y2 are both 0 eliminating 5 multiplies with 8.8 now check for 0.8                      
.Do16Bitmul24Bit:       jp      BCDEHLequ24mul24u       ; for now ignore optimisation X2 is zero Y2 is non zero eliminating 3 muliplies                 
.checkFor8BitMul:       or      h
.Do16BitMul:            jp      nz, BCHLDEequ16mul16u   ; X1 is non zero so we will assume Y1 is also non zero and do a 16 bit muliply
.X2X1Zero:              or      d                           
.Do8BitMul              jp      z, BCHLDEequ8mul8u      ; X1 and Y1 are both zero so its now just a simple mul de
                        ; else we fall into a 16 bit multiply
BCHLDEequ16mul16u:         
.PrepSelfModifying:     ld      a,l
                        ld      (.Y1mulX0L+1),a         ; Y1mulX0 L (we can skip X0mulY0 as we will already have L)
                        ld      a,d
                        ld      (.Y1mulX0D+1),a         ; Y1mulX0 D
                        ld      (.X1mulY1D+1),a         ; X1mulY1 D
                        ld      a,e
                        ld      (.X1mulY0E+1),a         ; X1mulY0 E (we can skip X0mulY0 as we will already have E)
                        ld      a,b
                        ld      a,h
                        ld      (.X1mulY0+1),a          ; X1mulY0 H
                        ld      (.X1mulY1H+1),a         ; X1mulY1 H
                        ; now we don't have to worry about setting up multiplies, just the adds and result
                        ; we can freely use AF, BC, HL, IX, IY and alternate registers
.X0mulY0 :              ld      d,l                     ; HL = L * E
                        mul     de                      ; .
                        ex      de,hl                   ; .
.Y1mulX0:                                               ; [L*D]
.Y1mulX0D:              ld      d,0x00
.Y1mulX0L:              ld      e,0x00                  ; DE = L * D
                        mul     de                      ;
                        ; DEHL = 00HL  + 0[L*D]0        ; as 0FF+FF0 is a 3 byte result + carry bit
.AHLequ0HLaddDE0:       ex      de,hl                   ; AHL = [L*D][0], DE = [0][L*E]
                        ZeroA                           ; A = 0 and clear carry Flag 
                        ld      a,h                     ; .
                        ld      h,l                     ; .
                        ld      l,0                     ; .
                        adc     hl,de                   ; carryHL  = L0 + DE
                        adc     a,0                     ; <cary>A = H+carry so <carry>AHL = [L*D][0] + [0][L*E]
                        ld      e,a                     ; .
                        ld      a,0                     ; .
                        adc     a,a                     ; . *as a is 0 we can do this and save 3 T states
                        ld      d,0                     ; now DEHL = [L*D][0] + [0][L*E]
                        exx                             ; now 'DEHL = [L*D][0] + [0][L*E]
.X1mulY0:               ; [H*E]
.X1mulY0H:              ld      d,0x00
.X1mulY0E:              ld      e,0x00
                        mul     de                      ; DE = [H * E]
                        ;break
                        ; DEHL = DEHL + 0[H*E]0 = DEH + 0[H*E] or  <carry>HL += E0 <carry?> DE += 0H + carry
                        push    de                      ; Stack + 1
                        exx                             ; DEHL = previous [0][L*D][0] + [00][L*E]
                        pop     bc                      ; Stack + 0
                        ClearCarryFlag                  ; 'DEHL = DEHL + [00]BC (or [0][H*E][0]
                        ld      a,b                     ; copy b as we need it again
                        ld      b,c                     ; now bc = E[0] from calc above
                        ld      c,0                     ; .
                        adc     hl,bc                   ; HL += E[0] from calc above
                        ld      b,0                     ; bc = [0]D from calc above
                        ld      c,a                     ; 
                        ex      de,hl                   ; get de into HL for add
                        adc     hl,bc                   ;
                        ex      de,hl                   ; get DEHL back into correct order
                        ld      bc,0                    ; as we don't have X2Y2 we just set BC to 0
                        exx                             ; now P3 P2 are loaded with working values, 'HL holds P1 P0 that are now fixed values
.X1mulY1:               ; [H*D]
.X1mulY1H:              ld      d,0x00                  ; X2mulY0 H
.X1mulY1D:              ld      e,0x00                  ; X2mulY0 E
                        mul     de
                        ;  CDE   = CDE   + [H*D]
                        push    de                      ; Stack + 1 swap in results
                        exx                             ; BC = [H*D]
                        pop     bc                      ; Stack + 0
                        ex      de,hl                   ; DE = DE + [H*D]
                        ZeroA                           ; A = 0 and clear carry Flag
                        adc     hl,bc                   ; .
                        ex      de,hl                   ; get HL and DE back to correct positions (we may leave them like this later for optimisation but debug first)
                        adc     a,c                     ; a += c + carry
                        ld      c,a                     ; so now we have 'CDE.HL as results
                        ZeroA                           ; assume sign in A is positive
                        ld      b,0                     ; and we need b to be 0
                        ret

                        ; 8 bit multiply
BCHLDEequ8mul8u:        ld      d,l                     ; so now BCHLDE = 00L * 00D 
                        mul     de                      ; so we just do L*D which loads de
                        ex      de,hl
                        ZeroA                           ; and set BCHL to 0
                        ld      b,a
                        ld      c,a
                        ld      d,a
                        ld      e,a
                        ret

BCDEHLequ24mul24u:    
.PrepSelfModifying:     ld      a,l
                        ld      (.Y1mulX0L+1),a         ; Y1mulX0 L (we can skip X0mulY0 as we will already have L)
                        ld      (.Y2mulX0L+1),a         ; Y2mulX0 L
                        ld      a,d
                        ld      (.Y1mulX0D+1),a         ; Y1mulX0 D
                        ld      (.X1mulY1D+1),a         ; X1mulY1 D
                        ld      (.X2mulY1D+1),a         ; X2mulY1 D
                        ld      a,e
                        ld      (.X1mulY0E+1),a         ; X1mulY0 E (we can skip X0mulY0 as we will already have E)
                        ld      (.X2mulY0E+1),a         ; X2mulY0 E
                        ld      a,b
                        ld      (.X2mulY0B+1),a         ; X2mulY0 B
                        ld      (.X2mulY1B+1),a         ; X2mulY1 B
                        ld      (.X2mulY2B+1),a         ; X2mulY2 B
                        ld      a,h
                        ld      (.X1mulY0+1),a          ; X1mulY0 H
                        ld      (.Y2mulX1H+1),a         ; Y2mulX1 H
                        ld      (.X1mulY1H+1),a         ; X1mulY1 H
                        ld      a,c
                        ld      (.Y2mulX0C+1),a         ; Y2mulX0 C
                        ld      (.Y2mulX1C+1),a         ; Y2mulX1 C
                        ld      (.X2mulY2C+1),a         ; X2mulY2 C
                        ; now we don't have to worry about setting up multiplies, just the adds and result
                        ; we can freely use AF, BC, HL, IX, IY and alternate registers
.X0mulY0 :              ld      d,l                     ; HL = L * E
                        mul     de                      ; .
                        ex      de,hl                   ; .
.Y1mulX0:                                               ; [L*D]
.Y1mulX0D:              ld      d,0x00
.Y1mulX0L:              ld      e,0x00                  ; DE = L * D
                        mul     de                      ;
                        ; DEHL = 00HL  + 0[L*D]0        ; as 0FF+FF0 is a 3 byte result + carry bit
.AHLequ0HLaddDE0:       ex      de,hl                   ; AHL = [L*D][0], DE = [0][L*E]
                        ZeroA                           ; A = 0 and clear carry Flag 
                        ld      a,h                     ; .
                        ld      h,l                     ; .
                        ld      l,0                     ; .
                        adc     hl,de                   ; carryHL  = L0 + DE
                        adc     a,0                     ; <cary>A = H+carry so <carry>AHL = [L*D][0] + [0][L*E]
                        ld      e,a                     ; .
                        ld      a,0                     ; .
                        adc     a,a                     ; . *as a is 0 we can do this and save 3 T states
                        ld      d,0                     ; now DEHL = [L*D][0] + [0][L*E]
                        exx                             ; now 'DEHL = [L*D][0] + [0][L*E]
.X1mulY0:               ; [H*E]
.X1mulY0H:              ld      d,0x00
.X1mulY0E:              ld      e,0x00
                        mul     de                      ; DE = [H * E]
                        ;break
                        ; DEHL = DEHL + 0[H*E]0 = DEH + 0[H*E] or  <carry>HL += E0 <carry?> DE += 0H + carry
                        push    de                      ; Stack + 1
                        exx                             ; DEHL = previous [0][L*D][0] + [00][L*E]
                        pop     bc                      ; Stack + 0
                        ClearCarryFlag                  ; 'DEHL = DEHL + [00]BC (or [0][H*E][0]
                        ld      a,b                     ; copy b as we need it again
                        ld      b,c                     ; now bc = E[0] from calc above
                        ld      c,0                     ; .
                        adc     hl,bc                   ; HL += E[0] from calc above
                        ld      b,0                     ; bc = [0]D from calc above
                        ld      c,a                     ; 
                        ex      de,hl                   ; get de into HL for add
                        adc     hl,bc                   ;
                        ex      de,hl                   ; get DEHL back into correct order
                        exx                             ; now P3 P2 are loaded with working values, 'HL holds P1 P0 that are now fixed values
.X2mulY0                ; [B*E]
.X2mulY0B:              ld      d,0x00                  ; X2mulY0 B
.X2mulY0E:              ld      e,0x00                  ; X2mulY0 E
                        mul     de
                        ;  CDE   = DE   + [B*E]
                        push    de                      ; swap in results Stack + 1
                        exx                             ; BC = [B*E]
                        pop     bc                      ; Stack + 0
                        ex      de,hl                   ; DE = DE + [B*E]
                        ZeroA                           ; A = 0 and clear carry Flag
                        adc     hl,bc                   ; .
                        ex      de,hl                   ; get HL and DE back to correct positions (we may leave them like this later for optimisation but debug first)
                        adc     a,a                     ; a += 0 + carry
                        ld      c,a                     ; so now we have 'CDE.HL as results
                        exx                             ; .
.Y2mulX0:               ; [L*C]
.Y2mulX0C:              ld      d,0x00                  ; X2mulY0 C
.Y2mulX0L:              ld      e,0x00                  ; X2mulY0 L
                        mul     de
                        ;  CDE   = CDE   + [L*C]
                        push    de                      ; Stack + 1 swap in results
                        exx                             ; BC = [L*C]
                        pop     bc                      ; Stack + 0
                        ex      de,hl                   ; DE = DE + [L*C]
                        ZeroA                           ; A = 0 and clear carry Flag
                        adc     hl,bc                   ; .
                        ex      de,hl                   ; get HL and DE back to correct positions (we may leave them like this later for optimisation but debug first)
                        adc     a,c                     ; a += c + carry
                        ld      c,a                     ; so now we have 'CDE.HL as results
                        exx                             ; .
.X1mulY1:               ; [H*D]
.X1mulY1H:              ld      d,0x00                  ; X2mulY0 H
.X1mulY1D:              ld      e,0x00                  ; X2mulY0 E
                        mul     de
                        ;  CDE   = CDE   + [H*D]
                        push    de                      ; Stack + 1 swap in results
                        exx                             ; BC = [H*D]
                        pop     bc                      ; Stack + 0
                        ex      de,hl                   ; DE = DE + [H*D]
                        ZeroA                           ; A = 0 and clear carry Flag
                        adc     hl,bc                   ; .
                        ex      de,hl                   ; get HL and DE back to correct positions (we may leave them like this later for optimisation but debug first)
                        adc     a,c                     ; a += c + carry
                        ld      c,a                     ; so now we have 'CDE.HL as results
                        exx                             ; .
.X2mulY1:               ; [B*D]
.X2mulY1B               ld      d,0x00                  ; X2mulY2 B
.X2mulY1D:              ld      e,0x00                  ; X2mulY0 E    
                        mul     de
                        ; BCD    = CD   + [B*D]         now is startes to get more tricky as we are spanning register pairs
                        push    de                      ; Stack + 1 swap in results
                        exx                             ; BC = [H*D]
                        ld      ix,hl                   ; preserve HL during calculations
                        ld      h,c                     ;
                        ld      l,d                     ;
                        pop     bc                      ;
                        ZeroA                           ; A = 0 and clear carry Flag
                        adc     hl,bc                   ; .
                        ld      c,h
                        ld      d,l
                        adc     a,a                     ; a += c + carry
                        ld      b,a                     ; so now we have 'BCDE.HL as results
                        exx                             ; .                     
.Y2mulX1:               ; [H*C]
.Y2mulX1C:              ld      d,0x00                  ; X2mulY0 E
.Y2mulX1H:              ld      e,0x00                  ; X2mulY0 E
                        mul     de
                        ; BCD    = CD   + [H*C]
                        push    de                      ; Stack + 1 swap in results
                        exx                             ; BC = [H*C]
                        ld      h,c
                        ld      l,d
                        pop     bc                      ; Stack + 0
                        ZeroA                           ; A = 0 and clear carry Flag
                        adc     hl,bc                   ; .
                        ld      c,h
                        ld      d,l
                        adc     a,a                     ; a += c + carry
                        ld      b,a                     ; so now we have 'BCDE.HL as results
                        push    bc                      ; get bc on stack for final add Stack + 1
                        exx                             ; .
.X2mulY2:               ; [B*C]
.X2mulY2B               ld      d,0x00                  ; X2mulY2 B
.X2mulY2C               ld      e,0x00                  ; X2mulY2 C
                        mul     de
                        ; BC     = BC   + [B*C]
                        pop     hl                      ; Get Saved BC into HL
                        add     hl,de                   ; hl = bc + [B*C]
                        push    hl                      ; and save on stack to read into bc
                        exx                             ; get back result
                        ld      hl,ix                   ; restore hl we saved earlier
                        pop     bc                      ; now we have 'BCDE.HL as final result
                        ZeroA                           ; assume sign in A is positive
                        ret

