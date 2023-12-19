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
; BHL = BHL+CDE where signs are held in B and C
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
                        DISPLAY "TODO: don't bother with overflow for now"
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
    DISPLAY "TODO: Check if ADDHLDESignedV4 is deprecated by AddDEtoHLSigned"
ADDHLDESignedV4:        ld      a,h
                        and     SignOnly8Bit
                        ld      b,a                         ;save sign bit in b
                        xor     d                           ;if h sign and d sign were different then bit 7 of a will be 1 which means 
                        JumpIfNegative .ADDHLDEOppSGN       ;Signs are opposite there fore we can subtract to get difference
.ADDHLDESameSigns:      ld      a,b
                        or      d
                        JumpIfNegative .ADDHLDESameNeg      ; optimisation so we can just do simple add if both positive
                        add     hl,de
                        ret
.ADDHLDESameNeg:        ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a
                        add     hl,de
                        ld      a,SignOnly8Bit
                        DISPLAY "TODO:  dont bother with overflow for now"
                        or      h                           ; now set bit for negative value, we won't bother with overflow for now TODO
                        ld      h,a
                        ret
.ADDHLDEOppSGN:         ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit                     ; here HL and DE are opposite 
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a
                        ClearCarryFlag
                        sbc     hl,de
                        jr      c,.ADDHLDEOppInvert
.ADDHLDEOppSGNNoCarry:  ld      a,b                         ; we got here so hl > de therefore we can just take hl's previous sign bit
                        or      h
                        ld      h,a                         ; set the previou sign value
                        ret
.ADDHLDEOppInvert:      NegHL                                                   ; we need to flip the sign and 2'c the Hl result
                        ld      a,b
                        xor     SignOnly8Bit                ; flip sign bit
                        or      h
                        ld      h,a                         ; recover sign
                        ret 
 
;------------------------------------------------------------
; extension to AddBCHtoDELsigned
; takes ix as the address of the values to load into DEL
;       iy as the address of the values to load into BCH
AddAtIXtoAtIY24Signed:  ld      l,(ix+0)            ; del = ix (sign hi lo)
                        ld      e,(ix+1)            ; .
                        ld      d,(ix+2)            ; .
                        ld      h,(iy+0)            ; bch = iy (sign, hi, lo)
                        ld      c,(iy+1)            ; .
                        ld      b,(iy+2)            ; .
                        push    iy                  ; save iy as add function changes is
                        call    AddBCHtoDELsigned   ; Perform del += bch
                        pop     iy                  ; get iy back
                        ld      (ix+0),l            ; put result into (ix)
                        ld      (ix+1),e            ; .
                        ld      (ix+2),d            ; .
                        ret                       
;------------------------------------------------------------
; DEL = @IX + @IY 24 bit signed
AddDELequAtIXPlusIY24Signed:   
                        ld      l,(ix+0)            ; del = ix (sign hi lo)
                        ld      e,(ix+1)            ; .
                        ld      d,(ix+2)            ; .
                        ld      h,(iy+0)            ; bch = iy (sign, hi, lo)
                        ld      c,(iy+1)            ; .
                        ld      b,(iy+2)            ; .
                        push    iy                  ; save iy as add function changes is
                        call    AddBCHtoDELsigned   ; Perform del += bch
                        pop     iy                  ; get iy back
                        ret                   
;------------------------------------------------------------
; extension to AddBCHtoDELsigned
; takes ix as the address of the values to load into DEL
;       iy as the address of the values to load into BCH
; subtracts iy from ix putting result in ix
; DEL = @IX - @IY 24 bit signed
SubAtIXtoAtIY24Signed:  ld      l,(ix+0)            ; del = ix (sign hi lo)
                        ld      e,(ix+1)            ; .
                        ld      d,(ix+2)            ; .
                        ld      h,(iy+0)            ; bch = -iy (sign, hi, lo)
                        ld      c,(iy+1)            ; .
                        ld      a,(iy+2)            ; .
                        xor     SignOnly8Bit        ; . this is where we flip sign to make add subtract
                        ld      b,a                 ; .
                        push    iy                  ; save iy as add function changes is
                        call    AddBCHtoDELsigned   ; perform del += bch which as we flipped bch sign means (ix [210] -= iy [210])
                        pop     iy                  ; get iy back
                        ld      (ix+0),l            ; put result into (ix)
                        ld      (ix+1),e            ; .
                        ld      (ix+2),d            ; .
                        ret
;------------------------------------------------------------
; extension to AddBCHtoDELsigned
; takes ix as the address of the values to load into DEL
;       iy as the address of the values to load into BCH
; subtracts iy from ix leaving result in del
SubDELequAtIXMinusAtIY24Signed:
                        ld      l,(ix+0)            ; del = ix (sign hi lo)
                        ld      e,(ix+1)            ; .
                        ld      d,(ix+2)            ; .
                        ld      h,(iy+0)            ; bch = -iy (sign, hi, lo)
                        ld      c,(iy+1)            ; .
                        ld      a,(iy+2)            ; .
                        xor     SignOnly8Bit        ; . this is where we flip sign to make add subtract
                        ld      b,a                 ; .
                        push    iy                  ; save iy as add function changes is
                        call    AddBCHtoDELsigned   ; perform del += bch which as we flipped bch sign means (ix [210] -= iy [210])
                        pop     iy                  ; get iy back
                        ret
;------------------------------------------------------------
;tested mathstestsun2
; DEL = DEL - BCH signed, uses BC, DE, HL, IY, A
; Just flips sign on b then performs add
SubBCHfromDELsigned:    ld      a,b
                        xor     SignOnly8Bit
                        ld      b,a
; DEL = DEL + BCH signed, uses BC, DE, HL, IY, A
AddBCHtoDELsigned:      ld      a,b                 ; Are the values both the same sign?
                        xor     d                   ; .
                        and     SignOnly8Bit        ; .
                        jr      nz,.SignDifferent   ; .
.SignSame:              ld      a,b                 ; if they are then we only need 1 signe
                        and     SignOnly8Bit        ; so store it in iyh
                        ld      iyh,a               ;
                        ld      a,b                 ; bch = abs bch
                        and     SignMask8Bit        ; .
                        ld      b,a                 ; .
                        ld      a,d                 ; del = abs del
                        and     SignMask8Bit        ; .
                        ld      d,a                 ; .
                        ld      a,h                 ; l = h + l
                        add     l                   ; .
                        ld      l,a                 ; . 
                        ld      a,c                 ; e = e + c + carry
                        adc     e                   ; .
                        ld      e,a                 ; .
                        ld      a,b                 ; d = b + d + carry (signed)
                        adc     d                   ; 
                        or      iyh                 ; d = or back in sign bit
                        ld      d,a                 ; 
                        ret                         ; done
.SignDifferent:         ld      a,b                 ; bch = abs bch
                        ld      iyh,a               ; iyh = b sign
                        and     SignMask8Bit        ; .
                        ld      b,a                 ; .
                        ld      a,d                 ; del = abs del
                        ld      iyl,a               ; iyl = d sign
                        and     SignMask8Bit        ; .
                        ld      d,a                 ; .
                        push    hl                  ; save hl
                        ld      hl,bc               ; hl = bc - de, if bc < de then there is a carry
                        sbc     hl,de               ;
                        pop     hl                  ;
                        jr      c,.BCHltDEL
                        jr      nz,.DELltBCH        ; if the result was not zero then DEL > BCH
.BCeqDE:                ld      a,h                 ; if the result was zero then check lowest bits
                        JumpIfALTNusng l,.BCHltDEL
                        jr      nz,.DELltBCH
; The same so its just zero
.BCHeqDEL:              xor     a                  ; its just zero
                        ld      d,a                ; .
                        ld      e,a                ; .
                        ld      l,a                ; .
                        ret                        ; .
;BCH is less than DEL so its DEL - BCH the sort out sign
.BCHltDEL:              ld      a,l                ; l = l - h                      ; ex
                        sub     h                  ; .                              ;   01D70F DEL
                        ld      l,a                ; .                              ;  -000028 BCH
                        ld      a,e                ; e = e - c - carry              ;1. 
                        sbc     c                  ; .                              ;
                        ld      e,a                ; .                              ;
                        ld      a,d                ; d = d - b - carry              ;
                        sbc     b                  ; .                              ;
                        ld      d,a                ; .                              ;
                        ld      a,iyl              ; as d was larger, take d sign
                        and     SignOnly8Bit       ;
                        or      d                  ;
                        ld      d,a                ;
                        ret
.DELltBCH:              ld      a,h                ; l = h - l
                        sub     l                  ;
                        ld      l,a                ;
                        ld      a,c                ; e = c - e - carry
                        sbc     e                  ;
                        ld      e,a                ;
                        ld      a,b                ; d = b - d - carry
                        sbc     d                  ;
                        ld      d,a                ;
                        ld      a,iyh              ; as b was larger, take b sign into d
                        and     SignOnly8Bit       ;
                        or      d                  ;
                        ld      d,a                ;
                        ret
;-----------------------------------------------------------------------------------------------------------
; Subtract Functions
;...subtract routines
; we could cheat, flip the sign of DE and just add but its not very optimised
subHLDES15:             ld      a,h
                        and     SignOnly8Bit
                        ld      b,a                         ;save sign bit in b
                        xor     d                           ;if h sign and d sign were different then bit 7 of a will be 1 which means 
                        JumpIfNegative .SUBHLDEOppSGN        ;Signs are opposite therefore we can add
.SUBHLDESameSigns:      ld      a,b
                        or      d
                        JumpIfNegative .SUBHLDESameNeg       ; optimisation so we can just do simple add if both positive
                        ClearCarryFlag
                        sbc     hl,de
                        JumpIfNegative .SUBHLDESameOvrFlw            
                        ret
.SUBHLDESameNeg:        ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a
                        ClearCarryFlag
                        sbc     hl,de
                        JumpIfNegative .SUBHLDESameOvrFlw            
                                            DISPLAY "TODO:  don't bother with overflow for now"
                        ld      a,h                         ; now set bit for negative value, we won't bother with overflow for now TODO
                        or      SignOnly8Bit
                        ld      h,a
                        ret
.SUBHLDESameOvrFlw:     NegHL
                        ld      a,b
                        xor     SignOnly8Bit                ; flip sign bit
                        or      h
                        ld      h,a                         ; recover sign
                        ret         
.SUBHLDEOppSGN:         or      a
                        ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a     
                        add     hl,de
                        ld      a,b                         ; we got here so hl > de therefore we can just take hl's previous sign bit
                        or      h
                        ld      h,a                         ; set the previou sign value
                        ret
;------------------------------------------------------------------------------------------------
;-- checks to see if a postition is in range of another, e.g. missile hit
;-- ix = ship position    - pointer to xyz vector as 3 bytes per element
;-- oy = misisle position - pointer to xyz vector as 3 bytes per element
;-- sets carry if in blast range, else not carry
;-- blast range will always be an 8 bit value
CheckInCollisionRange:  
.CheckXDistance:        call    SubDELequAtIXMinusAtIY24Signed ; get distance between x coordinates
                        ld      a,d                 ; check abs distance
                        and     SignMask8Bit        ; if high bytes are set
                        or      e                   ; then no hit
                        jp      nz,.NoCollision     ; if high bytes are set no collision
                        ld      a,l
                        JumpIfAGTEMemusng  CurrentMissileBlastRange ,.NoCollision
.CheckYDistance:        ld      bc,3                ; move ix and iy
                        add     ix,bc               ; on 3 bytes
                        add     iy,bc               ;
                        call    SubDELequAtIXMinusAtIY24Signed ; get distance between x coordinates
                        ld      a,d                 ; check abs distance
                        and     SignMask8Bit        ; if high bytes are set
                        or      e                   ; then no hit
                        jp      nz,.NoCollision     ; if high bytes are set no collision
                        ld      a,l
                        JumpIfAGTEMemusng  CurrentMissileBlastRange ,.NoCollision
.CheckZDistance:        ld      bc,3                ; move ix and iy
                        add     ix,bc               ; on 3 bytes
                        add     iy,bc               ;
                        call    SubDELequAtIXMinusAtIY24Signed ; get distance between x coordinates
                        ld      a,d                 ; check abs distance
                        and     SignMask8Bit        ; if high bytes are set
                        or      e                   ; then no hit
                        jp      nz,.NoCollision     ; if high bytes are set no collision
                        ld      a,l
                        JumpIfAGTEMemusng  CurrentMissileBlastRange ,.NoCollision
.CollisionDetected:     SetCarryFlag                ; collision in blast range
                        ret
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
                        call    mulDbyESigned               ; calcualte DE = Vector * angle /256
                        ld      hl,(iy+0)                   ; hl = vector 2
                        call    SubDEfromHLSigned           ; hl = vector 2 - (vector 1 * angle / 256)
                        ld      (iy+0),hl                   ; .
.processVector2:        pop     af
                        ld      e,a                         ; e = angle
                        ld      d,(iy+1)                    ; d = vector 2 / 256
                        call    mulDbyESigned               ; de = vector 2 * angle /256
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
                        call    mulDbyESigned               ; d = X Vector * alpha / 256
                        ld      l,(ix+2)                    ; hl = Y Vector component
                        ld      h,(ix+3)                    ;
                        call    SubDEfromHLSigned           ; hl = Y - (alpha * nosev x hi)
                        ld      (ix+2),l                    ; dont round Y up yet
                        ld      (ix+3),h
;-- x Vector = x Vector + alpha * y_hi
                        ld      e,(ix+3)                    ; e = y component hi
                        ld      a,(ALPHA)                   ; alpha S7
                        ld      d,a
                        call    mulDbyESigned               ; d = y Vector * alpha / 256
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
                        call    mulDbyESigned               ; d = Z Vector * beta / 256
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
                        call    mulDbyESigned               ; d = y Vector * beta / 256
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
UnivDistanceToTarget:DISPLAY "TODO : WRITE CODE FOR UnivDistanceToTarget"
                    ClearCarryFlag                              ; for now clear carry flag so its not at target
                    ret
;------------------------------------------------------------
; Takes the UBnKTarget position and works out if its ready for a docking routine or jump



TacticsVarResult        DW 0      
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




