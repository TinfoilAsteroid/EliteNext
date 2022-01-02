
; Full version
; 1. K2 = y - alpha * x
; 2. z = z + beta * K2
; 3. y = K2 - beta * z
; 4. x = x + alpha * y



SAPPequPosPlusAPP:       MACRO    Position, PositionSign
                        push    bc
                        ld      c,a                         ; save original value of a into c
                        ld      a,(PositionSign)
                        ld      b,a
                        ld      a,c
                        xor     b                           ; a = a xor x postition sign
                        jp      m,.MV50                     ; if the sign is negative then A and X are both opposite signs
; Signs are the same to we just add and take which ever sign 
                        ld      de,(varPp1)                  ; Note we take p+2,p+1 we we did a previous 24 bit mulitple
                        ld      hl,(Position)
                        add     hl,de
                        ld      (varPp1),hl                  ; now we have P1 and p2 with lo hi and
                        ld      a,c                         ; and a = original sign as they were both the same
                        pop     bc
                        ret
; Signs are opposite so we subtract
.MV50:                  ld      de,(varPp1)
                        ld      hl,(Position)
                        or      a
                        sbc     hl,de
                        jr      c,.MV51                     ; if the result was negative then negate result
                        ld      a,c                         ; get back the original sign
                        ld      (varPp1),hl                 ; and save result to P[2][1]
                        xor     SignOnly8Bit                ; flip sign and exit A = flip of a
                        pop     bc
                        ret
.MV51:                  NegHL
                        ld      (varPp1),hl
                        ld      a,c                         ; the original sign will still be good
                        pop     bc
                        ret
                        ENDM


SAPPequXPosPlusAPP:     SAPPequPosPlusAPP SBnKxlo, SBnKxsgn

SAPPequYPosPlusAPP:     SAPPequPosPlusAPP SBnKylo, SBnKysgn
                        
SAPPequZPosPlusAPP:     SAPPequPosPlusAPP SBnKzlo, SBnKzsgn

; SunrollWork holds Alpha intermidate results              
SunrollWork      DS 3
SunrollWorkp1    equ SunrollWork
SunrollWorkp2    equ SunrollWork+1
SunrollWorkp3    equ SunrollWork+2

;----------------------------------------------------------------------------------------------------------------------------------
; based on MVEIT part 4 of 9
SunApplyMyRollAndPitch: ld      a,(ALP1)                    ; get roll magnitude
                        ld      hl,BET1                     ; and pitch
                        or      (hl)
                        jp      z,.NoRotation               ; if both zero then don't compute
                        ;break
; P[210] = x * alph (we use P[2]P[1] later as result/256
                        ld      e,a                         ; e = roll magnitude
                        ld      hl,(SBnKxlo)                ; hl = ship x pos
                        call    AHLequHLmulE                ; MULTU2-2 AHL = SBnKXlo * Alp1 both unsigned
                        ld      (varPhi2),a                 ; set P[2] to high byte to help with ./256
                        ld      (varP),hl                   ; P (2 1 0) = SBnKXlo * Alph1
; A = Flip sign                         
                        ld      a,(ALP2FLIP)                ; flip the current roll angle alpha and xor with x sign
                        ld      hl,SBnKxsgn                 ; and xor with x pos sign
                        xor     (hl)                        ; so now  (A P+2 P+1) = - (x_sign x_hi x_lo) * alpha / 256
; AP[2]P[1] =Y + AP[2]P[1] (i.e. Previous APP/256)
                        call    SAPPequYPosPlusAPP           ; MVT6 calculate APP = y - (x * alpha / 256)
; K2 = AP[2][1] K2(3 2 1) = (A P+2 P+1) = y - x * alpha / 256
                        ld      (SunrollWorkp3),a               ; k2+3 = sign of result
                        ld      (SunrollWorkp1),hl             ; k2+1,2 = result
; P[210] = K2[2 1] * Beta  = (A ~P) * X
                        ld      a,(BET1)                    ; a = magnitude of pitch
                        ld      e,a
                        call    AHLequHLmulE                ; MLTU2-2 AHL = (P+2 P+1) * BET1 or by now ((SBnKXlo * Alph1)/256 * Bet1)
                        ld      (varPp2),a                   ; save highest byte in P2
                        ld      (varP),hl
; Fetch sign of previosu cal and xor with BETA inverted
                        ld      a,(SunrollWorkp3)
                        ld      e,a
                        ld      a,(BET2)
                        xor     e                           ; so we get the sign of K3 and xor with pitch sign
; Z = P[210] =Z + APP
                        call    SAPPequZPosPlusAPP           ; MVT6
                        ld      (SBnKzsgn),a                ; save result back into z
                        ld      (SBnKzlo),hl       
; A[P1]P[0] = z * Beta                      
                        ld      a,(BET1)                    ; get pitch back again for mulitply in original it was kept in Q so no fetch needed
                        ld      e,a
                        call    AHLequHLmulE                ; MULTU2 P2 P1 was already in hl (A P+1 P) = (z_hi z_lo) * beta
                        ld      (varPp2),a                  ; P2 = high byte of result
                        ld      (varP),hl                   ; P (2 1 0) = SBnKXlo & Alph1
; A xor BET2,Zsign
                        ld      a,(SunrollWorkp3)               ; get K3 (sign of y) and store it in y pos
                        ld      (SBnKysgn),a                ; save result back into y
                        ld      e,a                         ; a = y sign Xor pitch rate sign
                        ld      a,(BET2)                    ;
                        xor     e                           ;
                        ld      e,a                         ; now xor it with z sign too
                        ld      a,(SBnKzsgn)                ;
                        xor     e                           ; so now a = sign of y * beta * sign y * sign z
                        jp      p,.MV43                     ; if result is pve beta * z and y have differetn signs
                        ld      hl,(varPp1)
                        ld      de,(SunrollWorkp1)
                        or      a
                        add     hl,de
                        jp      .MV44
.MV43:                  ld      hl,(SunrollWorkp1)
                        ld      de,(varPp1)
                        or      a
                        sbc     hl,de                       ; (y_hi y_lo) = K2(2 1) - P(2 1)
                        jr      nc,.MV44                    ; if there was no over flow carry on
                        NegHL
                        ld      a,(SBnKysgn)                ; flip sign bit TODO, we may have to remove xor as planets and suns are sign + 23 bit xpos
                        xor     SignOnly8Bit
                        ld      (SBnKysgn),a                
; by here we have (y_sign y_hi y_lo) = K2(2 1) - P(2 1) = K2 - beta * z
.MV44:                  ld      (SBnKylo),hl                ; we do save here to avoid two writes if MV43 ended up with a 2s'c conversion
                        ld      a,(ALP1)                    ; get roll magnitude
                        ld      e,a
                        ld      hl,(SBnKylo)
                        call    AHLequHLmulE                ; MLTU2-2 AHL = (y_hi y_lo) * alpha
                        ld      (varPp2),a                  ; store high byte P(2 1 0) = (y_hi y_lo) * alpha
                        ld      (varP),hl  
                        ld      a,(ALP2)
                        ld      e,a
                        ld      a,(SBnKysgn)
                        xor     e                           ; a = sign of roll xor y so now we have (A P+2 P+1) = (y_sign y_hi y_lo) * alpha / 256
                        call    SAPPequXPosPlusAPP           ; MVT6 Set (A P+2 P+1) = (x_sign x_hi x_lo) + (A P+2 P+1) = x + y * alpha / 256   
                        ld      (SBnKxsgn),a                ; save resutl stright into X pos
                        ld      (SBnKxlo),hl                
                        ;break
                        ; if its not a sun then apply to local orientation

.NoRotation:            ld      a,(DELTA)                   ; get speed
                        ld      d,0
                        ld      e,a                         ; de = speed in low byte
                        ld      hl,(SBnKzlo)                ; hl = z position
                        ld      a,(SBnKzsgn)                ; b = z sign
                        ld      b,a                         ; 
                        ld      c,$80                       ; c = -ve as we are always moving forwards
                        call    ADDHLDESignBC               ; update speed
                        ld      (SBnKzlo),hl                ; write back to zpos
                        ld      (SBnKzsgn),a                ;
                        ret