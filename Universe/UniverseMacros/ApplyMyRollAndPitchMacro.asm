
; Full version
; 1. K2 = y - p?_ALPha * x
; 2. z = z + p?_BETA * K2
; 3. y = K2 - p?_BETA * z
; 4. x = x + p?_ALPha * y



; p?_rollWork holds p?_ALPha intermidate results              


ApplyMyRollAndPitchMacro        MACRO p?


p?_APPequXPosPlusAPP:    APPequPosPlusAPP p?_Bnkxlo, p?_Bnkxsgn

p?_APPequYPosPlusAPP:    APPequPosPlusAPP p?_Bnkylo, p?_Bnkysgn
                        
p?_APPequZPosPlusAPP:    APPequPosPlusAPP p?_Bnkzlo, p?_Bnkzsgn


p?_rollWork               DS 3
p?_rollWorkp1             equ p?_rollWork
p?_rollWorkp2             equ p?_rollWork+1
p?_rollWorkp3             equ p?_rollWork+2
;----------------------------------------------------------------------------------------------------------------------------------
; based on MVEIT part 4 of 9
p?_ApplyMyRollAndPitch:   ld      a,(p?_ALP1)                    ; get roll magnitude
                                ld      hl,p?_BET1                     ; and pitch
                                or      (hl)
                                jp      z,.NoRotation               ; if both zero then don't compute
                                ;break
; P[210] = x * p?_ALPh (we use P[2]P[1] later as result/256
                                ld      e,a                         ; e = roll magnitude
                                ld      hl,(p?_Bnkxlo)                ; hl = ship x pos
                                call    AHLequHLmulE                ; MULTU2-2 AHL = p?_BnkXlo * p?_ALP1 both unsigned
                                ld      (varPhi2),a                 ; set P[2] to high byte to help with ./256
                                ld      (varP),hl                   ; P (2 1 0) = p?_BnkXlo * p?_ALPh1
; A = Flip sign                         
                                ld      a,(p?_ALP2)                ; flip the current roll angle p?_ALPha and xor with x sign
                                ld      hl,p?_Bnkxsgn                 ; and xor with x pos sign
                                xor     (hl)                        ; so now  (A P+2 P+1) = - (x_sign x_hi x_lo) * p?_ALPha / 256
; AP[2]P[1] =Y + AP[2]P[1] (i.e. Previous APP/256)
                                call    p?_APPequYPosPlusAPP           ; MVT6 calculate APP = y - (x * p?_ALPha / 256)
; K2 = AP[2][1] K2(3 2 1) = (A P+2 P+1) = y - x * p?_ALPha / 256
                                ld      (p?_rollWorkp3),a               ; k2+3 = sign of result
                                ld      (p?_rollWorkp1),hl             ; k2+1,2 = result
; P[210] = K2[2 1] * p?_BETA  = (A ~P) * X
                                ld      a,(p?_BET1)                    ; a = magnitude of pitch
                                ld      e,a
                                call    AHLequHLmulE                ; MLTU2-2 AHL = (P+2 P+1) * p?_BET1 or by now ((p?_BnkXlo * p?_ALPh1)/256 * p?_BET1)
                                ld      (varPp2),a                   ; save highest byte in P2
                                ld      (varP),hl
; Fetch sign of previosu cal and xor with p?_BETA inverted
                                ld      a,(p?_rollWorkp3)
                                ld      e,a
                                ld      a,(p?_BET2)
                                xor     e                           ; so we get the sign of K3 and xor with pitch sign
; Z = P[210] =Z + APP
                                call    p?_APPequZPosPlusAPP           ; MVT6
                                ld      (p?_Bnkzsgn),a                ; save result back into z
                                ld      (p?_Bnkzlo),hl       
; A[P1]P[0] = z * p?_BETA                      
                                ld      a,(p?_BET1)                    ; get pitch back again for mulitply in original it was kept in Q so no fetch needed
                                ld      e,a
                                call    AHLequHLmulE                ; MULTU2 P2 P1 was already in hl (A P+1 P) = (z_hi z_lo) * p?_BETA
                                ld      (varPp2),a                  ; P2 = high byte of result
                                ld      (varP),hl                   ; P (2 1 0) = p?_BnkXlo & p?_ALPh1
; A xor p?_BET2,Zsign
                                ld      a,(p?_rollWorkp3)               ; get K3 (sign of y) and store it in y pos
                                ld      (p?_Bnkysgn),a                ; save result back into y
                                ld      e,a                         ; a = y sign Xor pitch rate sign
                                ld      a,(p?_BET2)                    ;
                                xor     e                           ;
                                ld      e,a                         ; now xor it with z sign too
                                ld      a,(p?_Bnkzsgn)                ;
                                xor     e                           ; so now a = sign of y * p?_BETA * sign y * sign z
                                jp      p,.MV43                     ; if result is pve p?_BETA * z and y have differetn signs
                                ld      hl,(varPp1)
                                ld      de,(p?_rollWorkp1)
                                or      a
                                add     hl,de
                                jp      .MV44
.MV43:                          ld      hl,(p?_rollWorkp1)
                                ld      de,(varPp1)
                                or      a
                                sbc     hl,de                       ; (y_hi y_lo) = K2(2 1) - P(2 1)
                                jr      nc,.MV44                    ; if there was no over flow carry on
                                NegHL
                                ld      a,(p?_Bnkysgn)                ; flip sign bit TODO, we may have to remove xor as planets and suns are sign + 23 bit xpos
                                xor     SignOnly8Bit
                                ld      (p?_Bnkysgn),a                
; by here we have (y_sign y_hi y_lo) = K2(2 1) - P(2 1) = K2 - p?_BETA * z
.MV44:                          ld      (p?_Bnkylo),hl                ; we do save here to avoid two writes if MV43 ended up with a 2s'c conversion
                                ld      a,(p?_ALP1)                    ; get roll magnitude
                                ld      e,a
                                ld      hl,(p?_Bnkylo)
                                call    AHLequHLmulE                ; MLTU2-2 AHL = (y_hi y_lo) * p?_ALPha
                                ld      (varPp2),a                  ; store high byte P(2 1 0) = (y_hi y_lo) * p?_ALPha
                                ld      (varP),hl  
                                ld      a,(p?_ALP2FLIP)
                                ld      e,a
                                ld      a,(p?_Bnkysgn)
                                xor     e                           ; a = sign of roll xor y so now we have (A P+2 P+1) = (y_sign y_hi y_lo) * p?_ALPha / 256
                                call    p?_APPequXPosPlusAPP           ; MVT6 Set (A P+2 P+1) = (x_sign x_hi x_lo) + (A P+2 P+1) = x + y * p?_ALPha / 256   
                                ld      (p?_Bnkxsgn),a                ; save resutl stright into X pos
                                ld      (p?_Bnkxlo),hl                
                        ;break
                        ; if its not a sun then apply to local orientation
                                ApplyMyRollToVector p?_ALPHA, p?_BnkrotmatNosevX, p?_BnkrotmatNosevY   ; ApplyMyRollToNosev:
                                ApplyMyRollToVector p?_ALPHA, p?_BnkrotmatSidevX, p?_BnkrotmatSidevY   ; ApplyMyRollToSidev:
                                ApplyMyRollToVector p?_ALPHA, p?_BnkrotmatRoofvX, p?_BnkrotmatRoofvY   ; ApplyMyRollToRoofv:
                                ApplyMyRollToVector p?_BETA,  p?_BnkrotmatNosevZ, p?_BnkrotmatNosevY    ; ApplyMyPitchToNosev:
                                ApplyMyRollToVector p?_BETA,  p?_BnkrotmatSidevZ, p?_BnkrotmatSidevY    ; ApplyMyPitchToSidev:    
                                ApplyMyRollToVector p?_BETA,  p?_BnkrotmatRoofvZ, p?_BnkrotmatRoofvY    ; ApplyMyPitchToRoofv:    
.NoRotation:                    ld      a,(p?_DELTA)                   ; get speed
                                ld      d,0
                                ld      e,a                         ; de = speed in low byte
                                ld      hl,(p?_Bnkzlo)                ; hl = z position
                                ld      a,(p?_Bnkzsgn)                ; b = z sign
                                ld      b,a                         ; 
                                ld      c,$80                       ; c = -ve as we are always moving forwards
                                MMUSelectMathsBankedFns
                                call    ADDHLDESignBC               ; update speed
                                ld      (p?_Bnkzlo),hl                ; write back to zpos
                                ld      (p?_Bnkzsgn),a                ;
                                ret
                                ENDM