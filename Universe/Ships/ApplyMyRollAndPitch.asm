
; Full version
; 1. K2 = y - alpha * x
; 2. z = z + beta * K2
; 3. y = K2 - beta * z
; 4. x = x + alpha * y


APPequPosPlusAPP:       MACRO    Position, PositionSign
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


APPequXPosPlusAPP:     APPequPosPlusAPP UBnKxlo, UBnKxsgn

APPequYPosPlusAPP:     APPequPosPlusAPP UBnKylo, UBnKysgn
                        
APPequZPosPlusAPP:     APPequPosPlusAPP UBnKzlo, UBnKzsgn

; rollWork holds Alpha intermidate results              
rollWork      DS 3
rollWorkp1    equ rollWork
rollWorkp2    equ rollWork+1
rollWorkp3    equ rollWork+2

;----------------------------------------------------------------------------------------------------------------------------------
; based on MVEIT part 4 of 9
ApplyMyRollAndPitch:    ld      a,(ALP1)                    ; get roll magnitude
                        ld      hl,BET1                     ; and pitch
                        or      (hl)
                        jp      z,.NoRotation               ; if both zero then don't compute
; If the xsgn,ysng or zsng are not 0 or $80 then we use 24 bit routines
; else we can just continue to use 16 bit                        
                       ;jp      ApplyMyRollAndPitch24Bit

.CheckFor24Bit:         ld      a,(UBnKxsgn)
                        ld      hl,UBnKysgn
                        or      (hl)
                        ld      hl,UBnKzsgn
                        or      (hl)
                        and     $7F
                        jp      nz,ApplyMyRollAndPitch24Bit
                        ;break
; P[210] = x * alph (we use P[2]P[1] later as result/256
.Not24BitCalcs:         ld      e,a                         ; e = roll magnitude
                        ld      hl,(UBnKxlo)                ; hl = ship x pos
                        call    AHLequHLmulE                ; MULTU2-2 AHL = UbnkXlo * Alp1 both unsigned
                        ld      (varPhi2),a                 ; set P[2] to high byte to help with ./256
                        ld      (varP),hl                   ; P (2 1 0) = UbnkXlo * Alph1
; A = Flip sign                         
                        ld      a,(ALP2)                ; flip the current roll angle alpha and xor with x sign
                        ld      hl,UBnKxsgn                 ; and xor with x pos sign
                        xor     (hl)                        ; so now  (A P+2 P+1) = - (x_sign x_hi x_lo) * alpha / 256
; AP[2]P[1] =Y + AP[2]P[1] (i.e. Previous APP/256)
                        call    APPequYPosPlusAPP           ; MVT6 calculate APP = y - (x * alpha / 256)
; K2 = AP[2][1] K2(3 2 1) = (A P+2 P+1) = y - x * alpha / 256
                        ld      (rollWorkp3),a               ; k2+3 = sign of result
                        ld      (rollWorkp1),hl             ; k2+1,2 = result
; P[210] = K2[2 1] * Beta  = (A ~P) * X
                        ld      a,(BET1)                    ; a = magnitude of pitch
                        ld      e,a
                        call    AHLequHLmulE                ; MLTU2-2 AHL = (P+2 P+1) * BET1 or by now ((UbnkXlo * Alph1)/256 * Bet1)
                        ld      (varPp2),a                   ; save highest byte in P2
                        ld      (varP),hl
; Fetch sign of previosu cal and xor with BETA inverted
                        ld      a,(rollWorkp3)
                        ld      e,a
                        ld      a,(BET2)
                        xor     e                           ; so we get the sign of K3 and xor with pitch sign
; Z = P[210] =Z + APP
                        call    APPequZPosPlusAPP           ; MVT6
                        ld      (UBnKzsgn),a                ; save result back into z
                        ld      (UBnKzlo),hl       
; A[P1]P[0] = z * Beta                      
                        ld      a,(BET1)                    ; get pitch back again for mulitply in original it was kept in Q so no fetch needed
                        ld      e,a
                        call    AHLequHLmulE                ; MULTU2 P2 P1 was already in hl (A P+1 P) = (z_hi z_lo) * beta
                        ld      (varPp2),a                  ; P2 = high byte of result
                        ld      (varP),hl                   ; P (2 1 0) = UbnkXlo & Alph1
; A xor BET2,Zsign
                        ld      a,(rollWorkp3)               ; get K3 (sign of y) and store it in y pos
                        ld      (UBnKysgn),a                ; save result back into y
                        ld      e,a                         ; a = y sign Xor pitch rate sign
                        ld      a,(BET2)                    ;
                        xor     e                           ;
                        ld      e,a                         ; now xor it with z sign too
                        ld      a,(UBnKzsgn)                ;
                        xor     e                           ; so now a = sign of y * beta * sign y * sign z
                        jp      p,.MV43                     ; if result is pve beta * z and y have differetn signs
                        ld      hl,(varPp1)
                        ld      de,(rollWorkp1)
                        or      a
                        add     hl,de
                        jp      .MV44
.MV43:                  ld      hl,(rollWorkp1)
                        ld      de,(varPp1)
                        or      a
                        sbc     hl,de                       ; (y_hi y_lo) = K2(2 1) - P(2 1)
                        jr      nc,.MV44                    ; if there was no over flow carry on
                        NegHL
                        ld      a,(UBnKysgn)                ; flip sign bit TODO, we may have to remove xor as planets and Univs are sign + 23 bit xpos
                        xor     SignOnly8Bit
                        ld      (UBnKysgn),a                
; by here we have (y_sign y_hi y_lo) = K2(2 1) - P(2 1) = K2 - beta * z
.MV44:                  ld      (UBnKylo),hl                ; we do save here to avoid two writes if MV43 ended up with a 2s'c conversion
                        ld      a,(ALP1)                    ; get roll magnitude
                        ld      e,a
                        ld      hl,(UBnKylo)
                        call    AHLequHLmulE                ; MLTU2-2 AHL = (y_hi y_lo) * alpha
                        ld      (varPp2),a                  ; store high byte P(2 1 0) = (y_hi y_lo) * alpha
                        ld      (varP),hl  
                        ld      a,(ALP2FLIP)
                        ld      e,a
                        ld      a,(UBnKysgn)
                        xor     e                           ; a = sign of roll xor y so now we have (A P+2 P+1) = (y_sign y_hi y_lo) * alpha / 256
                        call    APPequXPosPlusAPP           ; MVT6 Set (A P+2 P+1) = (x_sign x_hi x_lo) + (A P+2 P+1) = x + y * alpha / 256   
                        ld      (UBnKxsgn),a                ; save resutl stright into X pos
                        ld      (UBnKxlo),hl                
                        ;break
                        call    ApplyMyRollToOrientation
                        call    ApplyMyPitchToOrientation
                        ; if its not a Univ then apply to local orientation
.NoRotation:            ld      a,(DELTA)                   ; get speed
                        ld      d,0
                        ld      e,a                         ; de = speed in low byte
                        ld      hl,(UBnKzlo)                ; hl = z position
                        ld      a,(UBnKzsgn)                ; b = z sign
                        ld      b,a                         ; 
                        ld      c,$80                       ; c = -ve as we are always moving forwards
                        call    ADDHLDESignBC               ; update speed
                        ld      (UBnKzlo),hl                ; write back to zpos
                        ld      (UBnKzsgn),a                ;
                        ret

               DISPLAY "TODO: Looks like pitch is always being applied as positive"
ApplyMyRollToOrientation:MMUSelectMathsBankedFns
                        ld      a,(ALPHA) : ld ix,UBnkrotmatNosevX : ld iy,UBnkrotmatNosevY : call ApplyMyAngleAToIXIY ; ApplyMyRollToNosev:
                        ld      a,(ALPHA) : ld ix,UBnkrotmatSidevX : ld iy,UBnkrotmatSidevY : call ApplyMyAngleAToIXIY ; ApplyMyRollToSidev:
                        ld      a,(ALPHA) : ld ix,UBnkrotmatRoofvX : ld iy,UBnkrotmatRoofvY : call ApplyMyAngleAToIXIY ; ApplyMyRollToRoofv:
                        ret

ApplyMyPitchToOrientation:
                        ld      a,(BETA)  : ld ix,UBnkrotmatNosevZ : ld iy,UBnkrotmatNosevY : call ApplyMyAngleAToIXIY ; ApplyMyPitchToNosev:
                        ld      a,(BETA)  : ld ix,UBnkrotmatSidevZ : ld iy,UBnkrotmatSidevY : call ApplyMyAngleAToIXIY ; ApplyMyPitchToSidev:
                        ld      a,(BETA)  : ld ix,UBnkrotmatRoofvZ : ld iy,UBnkrotmatRoofvY : call ApplyMyAngleAToIXIY ; ApplyMyPitchToRoofv:
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; 24 bit version of pitch and roll is a 24 bit calculation 1 bit sign + 23 bit value
; Need to write a test routine for roll and pitchs
; Minsky Roll       Minsky Pitch
;  y -= alpha * x    y -= beta * z          
;  x += alpha * y    z += beta * y
; or once combined
;   1. K2 = y - alpha * x
;   2. z = z + beta * K2
;   3. y = K2 - beta * z
;   4. x = x + alpha * y
;----------------------------------------------------------------------------------------------------------------------------------
; Based on non optimised version of Planet pitch and roll is a 24 bit calculation 1 bit sign + 23 bit value
; Now at least rolls the correct direction
UnivAlphaMulX               DB $00,$00, $00, $00
UnivAlphaMulY               DB $00,$00, $00, $00
UnivAlphaMulZ               DB $00,$00, $00, $00
UnivBetaMulZ                DB $00,$00, $00, $00
UnivBetaMulY                DB $00,$00, $00, $00
UnivK2                      DS 3

ApplyMyRollAndPitch24Bit: 	 ld     a,(ALPHA)                   ; no roll or pitch, no calc needed
                             ld     hl,BETA
                             or     (hl)
                             call   nz, Univ_Roll_And_Pitch
;.CheckForRoll:              and		a
;							call	nz,Univ_Roll
;.CheckForPitch:				ld		a,(BETA)
;							and		a
;							call	nz,Univ_Pitch
.ApplySpeed:            	ld      a,(DELTA)                   ; BCH = - Delta
							ReturnIfAIsZero
							ld      c,0                         ;
							ld      h,a                         ; 
							ld      b,$80                       ;
							ld      de,(UBnKzhi)                ; DEL = z position
							ld      a,(UBnKzlo)                 ; .
							ld      l,a                         ; .
							call    AddBCHtoDELsigned           ; update speed
							ld      (UBnKzhi),DE                ; write back to zpos
							ld      a,l
							ld      (UBnKzlo),a                ;
							ret
; Performs minsky rotation
; Joystick left          Joystick right
; ---------------------  ---------------------
; x :=  x      + y / 64  x :=  x -  y / 64  so rather than /64  is z * alpha / 256
; y :=  y      - x /64   y :=  y +  x / 64     
;
; Joystick down          Joystick up
; ---------------------  ---------------------
; y :=  y      + z / 64  y :=  y - z / 64
; z :=  z      - y / 64  z :=  z + y / 64      
; 
; get z, multiply by alpha, pick top 3 bytes with sign
; get x, multiply by alpha, pick top 3 bytes with sign
; if alpha +ve subtract x = x - z adj, z =z + x adj , else x += z adj z -= z adj 
; so we can assume 24 bit maths and just do 16 bit multiply of say HL = nosev x [sgn][hi] and de = [0][alpha] by calling AHLequHLmulE
; for roll
; nosev_y = nosev_y - alpha * nosev_x_hi
; nosev_x = nosev_x + alpha * nosev_y_hi
; and for pitch
; nosev_y = nosev_y - beta * nosev_z_hi
; nosev_z = nosev_z + beta * nosev_y_hi
;  1. K2 = y - alpha * x
;   2. z = z + beta * K2
;   3. y = K2 - beta * z
;   4. x = x + alpha * y
;   
;   1a. K [3 2 1 0] = -alpha * (x sign hi lo)
;   1b. K [3 2 1]   = y sign hi lo + K [321] (in effect y minus (alpha * x / 256)
;   1c. K2 [3 2 1]  = k [3 2 1 ]
;   2a. K[3 2 1 0]  = k2 [3 2 1] * beta
;   2b. z sign hi lo += K[3 2 1] ( in effect z += (beta * K2)/256
;   3a. K [3 2 1 0] = z sign hi lo * -beta
;   3b. y sign hi lo = K2 [3 2 1] - K [3 2 1] ( in effect K2 - (beta * z) /256
;   
;   4. x = x + alpha * y



;-- Q = - ALPHA            
;-- A P[1 0] = xsign xhi xlo
;-- call K[3 2 1 0] = A P[1 0] * Q which means  K(3 2 1) = (A P+1 P) * Q / 256 = x * -alpha / 256 = - alpha * x / 256
;-- call K[3 2 1] = ysign hi lo + K[3 2 1] (= y - alpha * x / 256)
;-- K2 [3 2 1 ] = K [ 3 2 1 ]
;-- A P [1 0]   = K [3 2 1]
;-- Q = BETA 
;-- K[3 2 1 0] = A P[1 0] * Q
;-- K3[3 2 1] = z sign hi lo + K[3 2 1]
;-- A P [1 0] = -K [3 2 1]
;-- z sign hi lo = K[3 2 1]
;-- K[3 2 1 0] = A P[1 0] * Q
;-- T = K[3] sign bit     
;-- A = K[3] sign bit xor K2[3]
;-- if positive A yhi lo - = K [3 2 1 0] + K2[3 2 1 0] so A yhi ylo = K + K2 /256 as we abandon low byte
;-- if negative A yhi lo = (K - k2 )/256
;-- A = A xor T   
;-- y sign = A 
;-- Q = alpha
;-- A P(1 0) = y sign hi lo
;-- K[3 2 1 0 ] A P[1 0] * Q
;-- x sign hi lo = K[3 2 1] = xsign hi lo * K[3 2 1]

K2      DS  3

Univ_Roll_And_Pitch:	    ld      a,(ALPHA)                   ; get roll value
;** 1. K2 = y - alpha * x **************************************
;-- DEL = alpha * (x sign hi lo) /256
							ld      d,a                         ; d = alpha
							ld      a,(UBnKxlo)                 ; HLE = x sgn, hi, lo
							ld      e,a                         ; .
							ld      hl,(UBnKxhi)                ; hl = UBnKchi sgn
							call    mulHLEbyDSigned             ; DELC = x * alpha, so DEL = X * alpha / 256 
;-- DEL = K2 = y - alpha * x
                            ld      bc,de                       ; transfer to BCH for now
                            ld      h,l
                            ld      de,(UBnKyhi)
                            ld      a,(UBnKylo)
                            ld      l,a
                            call    SubBCHfromDELsigned                
                            ld      (K2+1),de
                            ld      a,l
                            ld      (K2),a
;** 2. z = z + beta * K2 ***************************************
;-- HLE = DEL ..................................................
                            ex      de,hl                       ; will set hl to de and e to l in one go
;-- DELC = beta * HLE, i.e. beta * K2
                            ld      a,(BETA)
                            ld      d,a
                            call    mulHLEbyDSigned             ; DELC = beta * K2
;-- DEL = z + DEL, i.e. z + Beta * K2 /256
                            ld      bc,(UBnKzhi)                ; BCH = z
                            ld      a,(UBnKzlo)                 ; .
                            ld      h,a                         ; .
                            call    AddBCHtoDELsigned           ; DEL =z + (beta * K2)/256
                            ld      (UBnKzhi),de                ; and save to Z
                            ld      a,l                         ; .
                            ld      (UBnKzlo),a                 ; .
;** 3. y = K2 - beta * z ***************************************
;-- DEL = beta * z / 256    
                            ld      a,(BETA)                    ; get pitch value
							ld      d,a                         ; d = pitch
							ld      a,(UBnKzlo)                 ; HLE = z sgn, hi, lo
							ld      e,a                         ; .
							ld      hl,(UBnKzhi)                ; hl = UBnKchi sgn
							call    mulHLEbyDSigned             ; DELC = z * beta, so DEL = z * beta / 256 
;-- BCH = DEL ..................................................
                            ld      bc,de                       ; transfer to BCH for now
                            ld      h,l
;-- y = DEL = K2 - beta * z = DEL - BCH
                            ld      de,(K2+1)                   ; del = K2
                            ld      a,(K2)                      ; .
                            ld      l,a                         ; .
                            call    SubBCHfromDELsigned         ; .    
                            ld      (UBnKyhi),de                ; and save to y
                            ld      a,l                         ; .
                            ld      (UBnKylo),a                 ; .
;** 4. x = x + alpha * y ***************************************                            
;-- DEL = alpha * y
                            ld      a,(ALPHA)                   ; get roll value
;-- DEL = alpha * (y sign hi lo) /256
							ld      d,a                         ; d = alpha
							ld      a,(UBnKylo)                 ; HLE = y sgn, hi, lo
							ld      e,a                         ; .
							ld      hl,(UBnKyhi)                ; hl = UBnKyhi sgn
							call    mulHLEbyDSigned             ; DELC = y * alpha, so DEL = Y * alpha / 256 
;-- DEL = x + alpha * y
                            ld      bc,de                       ; transfer to BCH for now
                            ld      h,l                         ; .
                            ld      de,(UBnKxhi)                ; del = x
                            ld      a,(UBnKxlo)                 ; .
                            ld      l,a                         ; .
                            call    AddBCHtoDELsigned           ; del = del + bch = x + alpha * y    
                            ld      (UBnKxhi),de                ; and save to x
                            ld      a,l                         ; .
                            ld      (UBnKxlo),a                 ; .
.ApplyRollToRight:          ;call    ApplyMyRollToOrientation                            
.ApplyPitchToClimb:         call    ApplyMyPitchToOrientation
                          ;  call    TidyVectorsIX ; doesn't work
							ret                        