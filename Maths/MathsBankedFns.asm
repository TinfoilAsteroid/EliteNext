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
; AHL = BHL+CDE where signs are held in B and C (sign only, HL and DE 16 bit magnitudes)
; Same sign sums over 65535 are not detected: every caller adds 8 bit products (the tactics and XX12 dot products)
; so the sum is never more than 3 * 255 (CalcTargetVector would, but nothing calls it)
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
                        or      c                           ; now set bit for negative value (no overflow, see above)
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
; Takes TacticsVector (ship - body from UnivBodyVector, S15.8 lo, hi, sign per axis, before it is normalised) and works
; out if the ship is ready for a docking routine or jump: carry set if it is inside the cube that is the space station
; safe zone in the original, i.e. on every axis the sign byte has no integer bits and the hi byte is below
; UnivTargetZone, else carry clear
UnivTargetZone      EQU     $C0
UnivDistanceToTarget:
                    ld      a,(TacticsVectorX+2)            ; any distance >= 256.0 * 256 on an axis?
                    ld      hl,TacticsVectorY+2             ; .
                    or      (hl)                            ; .
                    ld      hl,TacticsVectorZ+2             ; .
                    or      (hl)                            ; .
                    and     SignMask8Bit                    ; . (and clears carry)
                    ret     nz                              ; then too far
                    ld      a,(TacticsVectorX+1)            ; hi bytes all < UnivTargetZone?
                    cp      UnivTargetZone                  ; .
                    ret     nc                              ; .
                    ld      a,(TacticsVectorY+1)            ; .
                    cp      UnivTargetZone                  ; .
                    ret     nc                              ; .
                    ld      a,(TacticsVectorZ+1)            ; .
                    cp      UnivTargetZone                  ; carry set if inside the zone
                    ret




