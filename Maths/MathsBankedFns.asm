;------------------------------------------------------------
; HL Signed = HL - DE
SubDEfromHLSigned:      ld      a,d
                        xor     $80
                        ld      d,a
;------------------------------------------------------------
; Adds DE to HL, in form S15 result will also be S15 rather than 2's C                
AddDEtoHLSigned:        ld      a,h                         ; extract h sign to b
                        and     $80                         ; hl = abs (hl)
                        ld      b,a
                        ld      a,h
                        and     $7F
                        ld      h,a
                        ld      a,d                         ; extract d sign to c
                        and     $80                         ; de = abs (de)
                        ld      c,a
                        ld      a,d
                        and     $7F
                        ld      d,a
                        ld      a,b
                        xor     c
                        jp      nz,.OppositeSigns
.SameSigns              add     hl,de                       ; same signs so just add
                        ld      a,b                         ; and bring in the sign from b
                        or      h                           ; note this has to be 15 bit result
                        ld      h,a                         ; but we can assume that
                        ret
.OppositeSigns:         ClearCarryFlag
                        sbc     hl,de
                        jr      c,.OppsiteSignInvert
.OppositeSignNoInvert:  ld      a,b                         ; we got here so hl > de therefore we can just take hl's previous sign bit
                        or      h
                        ld      h,a                         ; set the previou sign value
                        ret
.OppsiteSignInvert:     NegHL                              ; we need to flip the sign and 2'c the Hl result
                        ld      a,b
                        xor     SignOnly8Bit               ; flip sign bit
                        or      h
                        ld      h,a                         ; recover sign
                        ret 
                        
;------------------------------------------------------------
; AHL = BHL+CDE where signs are held in B and C
ADDHLDESignBC:          ld      a,b
                        and     SignOnly8Bit
                        xor     c                           ;if b sign and c sign were different then bit 7 of a will be 1 which means 
                        JumpIfNegative .ADDHLDEsBCOppSGN     ;Signs are opposite there fore we can subtract to get difference
.ADDHLDEsBCSameSigns:   ld      a,b
                        or      c
                        JumpIfNegative .ADDHLDEsBCSameNeg    ; optimisation so we can just do simple add if both positive
                        add     hl,de                       ; both positive so a will already be zero
                        ret
.ADDHLDEsBCSameNeg:      add     hl,de
                        ld      a,b
                        or      c                           ; now set bit for negative value, we won't bother with overflow for now TODO
                        ret
.ADDHLDEsBCOppSGN:      ClearCarryFlag
                        sbc     hl,de
                        jr      c,.ADDHLDEsBCOppInvert
.ADDHLDEsBCOppSGNNoCarry:ld      a,b                         ; we got here so hl > de therefore we can just take hl's previous sign bit
                        ret
.ADDHLDEsBCOppInvert:   NegHL                               ; if result was zero then set sign to zero (which doing h or l will give us for free)
                        ld      a,b
                        xor     SignOnly8Bit                ; flip sign bit
                        ret   

;-- checks to see if a postition is in range of another, e.g. missile hit
;-- ix = ship position    - pointer to S15.8 xyz vector as 3 bytes per element (lo, hi, sign)
;-- iy = missile position - pointer to S15.8 xyz vector as 3 bytes per element
;-- sets carry if |ix - iy| < CurrentMissileBlastRange (1/256ths, 0.0 to 0.996) on every axis, else not carry
;-- AddBCHtoDELsigned does not detect overflow: with opposite signs |ix| + |iy| >= 32768.0 carries into the sign bit and
;-- could look close. That needs one of them >= 16384.0 (sign byte bit 6) and the distance is then far beyond any blast
;-- range, so opposite signs with bit 6 set in either is treated as out of range. ix and iy are advanced by 9 on a hit
CheckInCollisionRange:  ld      b,3
.AxisLoop:              push    bc
                        ld      a,(ix+2)            ; opposite signs?
                        xor     (iy+2)              ; .
                        jp      p,.NoOverflow       ; .
                        ld      a,(ix+2)            ; and either >= 16384.0
                        or      (iy+2)              ; .
                        and     $40                 ; .
                        jr      nz,.NoCollisionPop  ; then too far apart (and the subtract could overflow)
.NoOverflow:            call    SubDELequAtIXMinusAtIY24Signed ; del = ix - iy, S15.8
                        ld      a,d                 ; integer bits 8-14 set
                        and     SignMask8Bit        ; .
                        or      e                   ; or integer bits 0-7
                        jr      nz,.NoCollisionPop  ; then no collision
                        ld      a,l                 ; fraction
                        ld      hl,CurrentMissileBlastRange
                        cp      (hl)
                        jr      nc,.NoCollisionPop  ; >= range so no collision
                        pop     bc
                        ld      de,3                ; next axis
                        add     ix,de               ; .
                        add     iy,de               ; .
                        djnz    .AxisLoop
.CollisionDetected:     SetCarryFlag                ; collision in blast range
                        ret
.NoCollisionPop:        pop     bc
.NoCollision:           ClearCarryFlag              ; no collision in blast range
                        ret

;------------------------------------------------------------------------------------------------
; -- Checks if 24 bit value at ix > iy and returns ix pointing to the correct value
; -- Sets carryflag if a swap occured as part of the Jump If A LessThan check
CompareAtIXtoIYABS:     ld      a,(iy+2)
.CheckSignByte:         and     SignMask8Bit
                        ld      b,a
                        ld      a,(ix+2)
                        and     SignMask8Bit
                        JumpIfALTNusng b,.SwapIXIY
.CheckHighByte:         ld      a,(ix+1)
                        cp      (iy+1)
                        JumpIfALTNusng b,.SwapIXIY
.CheckLowByte:          ld      a,(ix+0)
                        cp      (iy+0)
                        JumpIfALTNusng b,.SwapIXIY
                        ret
.SwapIXIY               push    ix                  ; swap over ix and iy
                        push    iy                  ; this means that ix is always larger of two or ix if they are the same value
                        pop     ix                  ; iy is a smaller of the two values, or untouched in the same value
                        pop     iy                  ; Thsi means we can do a compare and pick which one we preferr after, carry says if swap occured if we need that
                        ret
;------------------------------------------------------------------------------------------------
; -- Manhattan distance
; -- very quick distance calculation based on a cube
; -- ix = pointer to vector of 3x3, iy = distance to check
; simploy done by ABS (ix) 
; returns z if outside box, nz if inside box
ManhattanDistanceIXIY:  ld      l,(ix+0)            ; del = abs ix (sign hi lo)
.checkX:                ld      e,(ix+1)            ; .
                        ld      a,(ix+2)            ; .
                        and     SignMask8Bit        ;
                        ld      d,a                 ;
                        ld      h,(iy+0)            ; bch = distiance to check
                        ld      c,(iy+1)            ; .
                        ld      a,(iy+2)            ; .
                        xor     SignOnly8Bit        ; . this is where we flip sign to make add subtract
                        ld      b,a                 ; .
                        push    bc,,hl              ; save this for 2nd and 3rd test
                        push    iy                  ; save iy as add function changes is
                        call    AddBCHtoDELsigned   ; perform del += bch which as we flipped bch sign means (ix [210] -= iy [210])
                        pop     iy                  ; get iy back
                        ld      a,d
                        and     SignOnly8Bit
                        jp      z,.ClearUp          ; so if its positive then outside boundary
.checkY:                pop     bc,,hl
                        push    bc,,hl
                        ld      l,(ix+3)            ; del = abs ix (sign hi lo)
                        ld      e,(ix+4)            ; .
                        ld      a,(ix+5)            ; .
                        and     SignMask8Bit        ;
                        ld      d,a                 ;
                        push    iy                  ; save iy as add function changes is
                        call    AddBCHtoDELsigned   ; perform del += bch which as we flipped bch sign means (ix [210] -= iy [210])
                        pop     iy                  ; get iy back
                        ld      a,d
                        and     SignOnly8Bit
                        jp      z,.ClearUp          ; so if its positive then outside boundary
.checkZ:                pop     bc,,hl
                        ld      l,(ix+6)            ; del = abs ix (sign hi lo)
                        ld      e,(ix+7)            ; .
                        ld      a,(ix+8)            ; .
                        and     SignMask8Bit        ;
                        ld      d,a                 ;
                        push    iy                  ; save iy as add function changes is
                        call    AddBCHtoDELsigned   ; perform del += bch which as we flipped bch sign means (ix [210] -= iy [210])
                        pop     iy                  ; get iy back
                        ld      a,d
                        and     SignOnly8Bit
                        ret
.ClearUp:               pop     bc,,hl
                        ret
                       

;------------------------------------------------------------
; Note vectors are 2 byte lead sign, angle is 8 bit lead sign
ApplyMyAngleAToIXIY:    ;break
                        push    af                          ; save angle
; Calculate Angle * vector /256, i.e take angle and mutiple by high byte of vector
.processVector1:        ld      e,a                         ; e = angle
                        ld      d,(ix+1)                    ; d = vector 1 / 256
                        call    DEequDmulEs               ; calcualte DE = Vector * angle /256
                        ld      hl,(iy+0)                   ; hl = vector 2
                        call    SubDEfromHLSigned           ; hl = vector 2 - (vector 1 * angle / 256)
                        ld      (iy+0),hl                   ; .
.processVector2:        pop     af
                        ld      e,a                         ; e = angle
                        ld      d,(iy+1)                    ; d = vector 2 / 256
                        call    DEequDmulEs               ; de = vector 2 * angle /256
                        ld      hl,(ix+0)                   ; hl = vector 1
                        call    AddDEtoHLSigned             ; hl = hl + de
                        ld      (ix+0),hl                   ; .
                        ret
;------------------------------------------------------------           
; Applies Roll Alpha and Pitch Beta to vector at IX
ApplyRollAndPitchToIX:  
;-- y Vector = y - alpha * nosev_x_hi
                        ld      e,(ix+1)                    ; e = X component hi
                        ld      a,(ALPHA)                   ; alpha S7
                        ld      d,a
                        call    DEequDmulEs               ; d = X Vector * alpha / 256
                        ld      l,(ix+2)                    ; hl = Y Vector component
                        ld      h,(ix+3)                    ;
                        call    SubDEfromHLSigned           ; hl = Y - (alpha * nosev x hi)
                        ld      (ix+2),l                    ; dont round Y up yet
                        ld      (ix+3),h
;-- x Vector = x Vector + alpha * y_hi
                        ld      e,(ix+3)                    ; e = y component hi
                        ld      a,(ALPHA)                   ; alpha S7
                        ld      d,a
                        call    DEequDmulEs               ; d = y Vector * alpha / 256
                        ld      l,(ix+0)                    ; hl = x Vector component
                        ld      h,(ix+1)                    ;
                        call    AddDEtoHLSigned             ; hl = x + (alpha * nosev x hi)
                    IFDEF ROUND_ROLL_AND_PITCH
                        ld      l,0                         ; round up x
                    ENDIF
                        ld      (ix+0),l
                        ld      (ix+1),h
;-- nosev_y = nosev_y - beta * nosev_z_hi
                        ld      e,(ix+5)                    ; e = z component hi
                        ld      a,(BETA)                    ; beta S7
                        ld      d,a
                        call    DEequDmulEs               ; d = Z Vector * beta / 256
                        ld      l,(ix+2)                    ; hl = y Vector component
                        ld      h,(ix+3)                    ;
                        call    SubDEfromHLSigned           ; hl = Y - (beta * nosev z hi)
                    IFDEF ROUND_ROLL_AND_PITCH
                        ld      l,0                         ; round up Y
                    ENDIF
                        ld      (ix+2),l
                        ld      (ix+3),h
;-- nosev_z = nosev_z + beta * nosev_y_hi
                        ld      e,(ix+3)                    ; e = y component hi
                        ld      a,(BETA)                    ; beta S7
                        ld      d,a
                        call    DEequDmulEs               ; d = y Vector * beta / 256
                        ld      l,(ix+4)                    ; hl = z Vector component
                        ld      h,(ix+5)                    ;
                        call    AddDEtoHLSigned             ; hl = z + (beta * nosev z hi)
                    IFDEF ROUND_ROLL_AND_PITCH
                        ld      l,0                         ; round up zwd
                    ENDIF
                        ld      (ix+4),l
                        ld      (ix+5),h
                        ret
;------------------------------------------------------------
; Calculates the following:
; loads UBnKTargetVector from UBnkPostion to IY as IY - position
VectorUnivtoIY:     ld      ix,UBnKxlo                      ; target x = iy [x] - Univ XPos
                    call    SubDELequAtIXMinusAtIY24Signed  ; .
                    ld      a,l                             ; .
                    ld      (UBnKTargetXPos),a              ; .
                    ld      (UBnKTargetXPos+1),de           ; .
                    ld      ix,UBnKylo                      ; move to y component
                    ld      bc,3                            ; .
                    add     iy,bc                           ; .
                    call    SubDELequAtIXMinusAtIY24Signed  ; target y = iy [y] - Univ YPos
                    ld      a,l                             ; .
                    ld      (UBnKTargetYPos),a              ; .
                    ld      (UBnKTargetYPos+1),de           ; .         
                    ld      ix,UBnKzlo                      ; move to y component
                    ld      bc,3                            ; move to z component
                    add     iy,bc                           ; .
                    call    SubDELequAtIXMinusAtIY24Signed  ; target z = iy [z] - Univ ZPos
                    ld      a,l                             ; .
                    ld      (UBnKTargetZPos),a              ; .
                    ld      (UBnKTargetZPos+1),de           ; .
                    ret
;------------------------------------------------------------
; Takes the UBnKTarget position and works out if its ready for a docking routine or jump
; returns carry flag if move to docking else leaves carry unset
UnivDistanceToTarget:
                    ClearCarryFlag                              ; for now clear carry flag so its not at target
                    ret
;------------------------------------------------------------
; Takes the UBnKTarget position and works out if its ready for a docking routine or jump


        IFNDEF  DEBUG_NO_TACTICS_CODE

; TacticsVarResult is in general_variables.asm: this bank is in slot 0 where writes can be going to layer 2
TacticsDotRoofv:        ld      hl,UBnkrotmatRoofvX
                        jp      TacticsDotHL
                        
TacticsDotSidev:        ld      hl,UBnkrotmatSidevX
                        jp      TacticsDotHL
                                          
TacticsDotNosev:        call    CopyRotNoseToUBnKTacticsMat
TacticsDotHL:           ld      hl,UBnKTacticsRotMatX; UBnkTransmatNosevX    ; ROTMATX HI
.CalcXValue:            ld      a,(hl)                              ; DE = RotMatX & Vect X
                        ld      e,a                                 ; .
                        ld      a,(UBnKTargetVectorX)                  ; .
                        ld      d,a                                 ; .
                        mul                                         ; .
                        ld      a,d                                 ; S = A = Hi (RotMatX & Vect X)
                        ld      (varS),a                            ; .
                        inc     hl                                  ; move to sign byte
.CalcXSign:             ld      a,(UBnKTargetVectorX+2)                ; B  = A = Sign VecX xor sign RotMatX
                        xor     (hl)                                ; .
                        ld      b,a                                 ; .
.MoveToY:               inc     hl                                  ; Move on to Y component
.CalcYValue:            ld      a,(hl)                              ; D = 0, E = Hi (RotMatY & Vect Y)
                        ld      e,a                                 ; .
                        ld      a,(UBnKTargetVectorY)                  ; .
                        ld      d,a                                 ; .
                        mul     de                                  ; .
                        ld      e,d                                 ; .
                        ld      d,0                                 ; .
                        inc     hl                                  ; move to sign byte
.CalcYSign:             ld      a,(UBnKTargetVectorY+2)                ; c = sign of y_sign * sidev_y
                        xor     (hl)                                ; 
                        ld      c,a                                 ; 
.MoveToZ:               inc     hl                                  ; Move on to Z component
.AddXandY:              push    hl                                  ; but save HL as we need that
                        ld      a,(varS)                            ; hl = Hi (RotMatX & Vect X) b= sign
                        ld      h,0                                 ; de = Hi (RotMatY & Vect Y) c= sign
                        ld      l,a                                 ;
                        call    ADDHLDESignBC                       ; a(sign) hl = sum
                        ld      b,a                                 ; b = sign of result
                        ld      (TacticsVarResult),hl               ; save sub in TacticsVarResult
.CalcZValue:            pop     hl                                  ; get back to the rotation mat z
                        ld      a,(hl)                              ; D = 0, E = Hi (RotMatZ & Vect Z)
                        ld      e,a                                 ; .
                        ld      a,(UBnKTargetVectorZ)                  ; .
                        ld      d,a                                 ; .
                        mul     de                                  ; .
                        ld      e,d                                 ; .
                        ld      d,0                                 ; .
                        inc     hl                                  ; move to sign byte
.CalcZSign:             ld      a,(UBnKTargetVectorZ+2)
                        xor     (hl)
                        ld      c,a                                 ; Set C to the sign of z_sign * sidev_z
                        ld      hl, (TacticsVarResult)              ; CHL = x + y, BDE = z products
                        call    ADDHLDESignBC                       ; so AHL = X y z products
                        ld      (varS),a                            ; for backwards compatibility
                        ld      a,l                                  ; .
                        ret

CopyRotSideToUBnKTacticsMat:ld      hl,UBnkrotmatSidevX+1
                        jp      CopyRotmatToTacticsMat
                        
CopyRotNoseToUBnKTacticsMat:ld      hl,UBnkrotmatNosevX+1
                        jp      CopyRotmatToTacticsMat
                        
CopyRotRoofToBnKTacticsMat:ld      hl,UBnkrotmatRoofvX+1
; Coy rotation matrix high byte to trans rot mat, strip off sign and separate to rotmat byte 2
CopyRotmatToUBnKTacticsMat: ld      de,UBnKTacticsRotMatX
                        ld      a,(hl)              ; matrix high byte of x
                        ld      b,a
                        and     SignMask8Bit
                        ld      (de),a              ; set rot mat value
                        inc     de
                        ld      a,b
                        and     SignOnly8Bit
                        ld      (de),a              ; set rot mat sign
                        inc     de                  ; move to next rot mat element
                        inc     hl                  
                        inc     hl                  ; matrix high byte of y
.processYElement:       ld      a,(hl)              ; matrix high byte of y
                        ld      b,a
                        and     SignMask8Bit
                        ld      (de),a              ; set rot mat value
                        inc     de
                        ld      a,b
                        and     SignOnly8Bit
                        ld      (de),a              ; set rot mat sign
                        inc     de                  ; move to next rot mat element
                        inc     hl                  
                        inc     hl                  ; matrix high byte of z
.ProcessZElement:       ld      a,(hl)              ; matrix high byte of z
                        ld      b,a
                        and     SignMask8Bit
                        ld      (de),a              ; set rot mat value
                        inc     de
                        ld      a,b
                        and     SignOnly8Bit
                        ld      (de),a              ; set rot mat sign
                        ret
        ENDIF


