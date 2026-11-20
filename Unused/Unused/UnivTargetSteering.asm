; Not in the build: the old planet / sun steering, which worked on data nothing set (NormalseUnivTarget stripped the
; signs off UBnKTargetXPos..Z but scaled TacticsVector, TacticsDotHL read UBnKTargetVectorX..Z which nothing wrote,
; TacticsDotNosev's copy went to TacticsRotMatX while it read UBnKTacticsRotMatX). Replaced by UnivBodyVector and
; UnivSteerToBody in GameEngine/NormalAI.asm, which use TacticsVector, NormalizeTactics and ShipSeekingLogic as the
; missile does. UnivSeekingLogic (NormalAI.asm) called TacticsDotNosev then UnivPitchToTarget / Roll / Speed.

; ---- from Maths/MathsBankedFns.asm
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

; ---- from Maths/MathsBankedFns.asm (was IFNDEF DEBUG_NO_TACTICS_CODE)
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

; ---- from Maths/normalise96.asm
;------------------------------------------------------------
; To normalise the 24 bit version, bring out sign into TargetVectorxsgn
; and make UBnKTargetXpos = abs (UBnKTargetXPos)
; set up UBnKTarget[XYZ]Pos with 7 bit version of vector normalised
; set up UBnKTargetpXYZ]Sgn with the sign bit
NormalseUnivTarget:     ld      a,(UBnKTargetXPos+2)
                        ld      b,a
                        and     $80
                        ld      (UBnKTargetXPosSgn),a        ; Split out the sign into byte 3
                        ld      a,b
                        and     $7F
                        ld      (UBnKTargetXPos+2),a  
.ABSYComponenet:        ld      a,(UBnKTargetYPos+2)
                        ld      b,a
                        and     $80
                        ld      (UBnKTargetYPosSgn),a        ; Split out the sign into byte 3
                        ld      a,b
                        and     $7F
                        ld      (UBnKTargetYPos+2),a                          
.ABSXZomponenet:        ld      a,(UBnKTargetZPos+2)
                        ld      b,a
                        and     $80
                        ld      (UBnKTargetZPosSgn),a        ; Split out the sign into byte 3
                        ld      a,b
                        and     $7F
                        ld      (UBnKTargetZPos+2),a                          
;.. When we hit here the UBnKTargetX,Y and Z are 24 bit abs values to simplify scaling                        
.Scale:                 ld      hl, (TacticsVectorX)        ; pull 24 bit into registers
                        ld      a,(TacticsVectorX+2)        ; h l ixH = X
                        ld      ixh,a                       ;
                        ld      de, (TacticsVectorY)        ; d e iyH = Y
                        ld      a,(TacticsVectorY+2)        ;
                        ld      iyh,a                       ;
                        ld      bc, (TacticsVectorZ)        ; b c iyL = Y
                        ld      a,(TacticsVectorZ+2)        ;
                        ld      iyl,a                       ;
.ScaleLoop1:            ld      a,ixh                       ; first pass get to 16 bit
                        or      iyh
                        or      iyl
                        or      iyh
                        jp      z,.DoneScaling1
                        ShiftIXhHLRight1
                        ShiftIYhDERight1
                        ShiftIYlBCRight1
.DoneScaling1:          ;-- Now we have got here hl = X, de = Y, bc = Z
                        ;-- we cal just jump into the Normalize Tactics code
.ScaleLoop2:            ld      a,h
                        or      d
                        or      b
                        jr      z,.DoneScaling2
                        ShiftHLRight1
                        ShiftDERight1
                        ShiftBCRight1
                        jp      .ScaleLoop2
;-- Now we are down to 8 bit values, so we need to scale again to get S7         
.DoneScaling2:          ShiftHLRight1
                        ShiftDERight1
                        ShiftBCRight1
.CalculateLength:       push    hl,,de,,bc                  ; save vecrtor x y and z nwo they are scaled to 1 byte
                        ld      d,e                         ; hl = y ^ 2
                        mul     de                          ; .
                        ex      de,hl                       ; .
                        ld      d,e                         ; de = x ^ 2
                        mul     de                          ; .
                        add     hl,de                       ; hl = y^ 2 + x ^ 2
                        ld      d,c
                        ld      e,c
                        mul     de
                        add     hl,de                       ; hl =  y^ 2 + x ^ 2 + z ^ 2
                        ex      de,hl                       ; fix as hl was holding square
                        call    asm_sqrt                    ; hl = sqrt (de) = sqrt (x ^ 2 + y ^ 2 + z ^ 2)
                        ; add in logic if h is low then use lower bytes for all 
.NormaliseZ:            ld      a,l                         ; save length into iyh
                        ld      iyh,a                       ; .
                        ld      d,a                         ;
                        pop     bc                          ; retrive z scaled
                        ld      a,c                         ; a = scaled byte
                        call    AequAdivDmul967Bit          
                        ld      (TacticsVectorZ),a          ; now Tactics Vector Z byte 1 is value
.NormaliseY:            pop     de
                        ld      a,e
                        ld      d,iyh                        
                        call    AequAdivDmul967Bit
                        ld      (TacticsVectorY),a
.NormaliseX:            pop     hl
                        ld      a,l
                        ld      d,iyh                        
                        call    AequAdivDmul967Bit
                        ld      (TacticsVectorX),a          ;
                        ret


; ---- from Universe/Ships/univ_ship_data.asm
UnivPitchToTarget:      ld      hl,( UBnKTargetDotProduct2)        ; pitch counter sign = opposite sign to roofdir sign
                        ld      a,h                                ; .
                        xor     $80                                ; .
                        and     $80                                ; .
                        ld      h,a                                ; h  = flipped sign
                        ld      a,l                                ; a = value * 2
                        sla     a                                  ; 
                        JumpIfAGTENusng 16, .skipPitchZero         ; if its > 16 then update pitch
                        ZeroA                                      ; else we zero pitch but
                        or      h                                  ; we need to retain the sign
                        ld      (UBnKRotZCounter),a                ; .
                        ret
.skipPitchZero:         ld      a,2
                        or      h
                        ld      (UBnKRotZCounter),a
                        ret

;Direct on dot product nose is $24
; Position                  Pitch   Roll    Speed
; Top left forwards         up      -ve     +
; Top right forwards        up      +ve     +
; Bottom left forwards      down    -ve     +
; Bottom right forwards     down    +ve     +
; Top left rear             up      -ve     -
; Top right rear            up      +ve     -
; Bottom left rear          down    -ve     -
; Bottom right rear         down    +ve     -
                        
UnivRollToTarget:       call    TacticsDotSidev             ; calculate side dot protuct
                        ld      ( UBnKTargetDotProduct3),a             ; .
                        ld      l,a                                ; .
                        ld      a,(varS)                           ; .
                        ld      ( UBnKTargetDotProduct3+1),a           ; .
                        ld      h,a                                ; h = sign sidev
                        ld      a,( UBnKTargetDotProduct2+1)           ; get flipped pitch counter sign
                        ld      b,a                                ; b = roof product
                        ld      a,l                                ; a = abs sidev  * 2
                        sla     a                                  ;
                        JumpIfAGTENusng 16,.skipRollZero           ;
                        ZeroA                                      ; if its zoer then set rotx to zero
                        or      b
                        ld      (UBnKRotXCounter),a
                        ret
.skipRollZero:          ld      a,2
                        or      h
                        xor     b
                        ld      (UBnKRotXCounter),a
                        ret

UnivSpeedToTarget:      ld      hl,( UBnKTargetDotProduct1)
                        ld      a,h
                        and     a
                        jr      nz,.SlowDown
                        ld      de,( UBnKTargetDotProduct2)             ; dot product is +ve so heading at each other
                        ld      a,l 
                        JumpIfALTNusng  22,.SlowDown                                  ; nose dot product < 
.Accelerate:            ld      a,3                                 ; else
                        ld      (UBnKAccel),a                       ;  accelleration = 3
                        ret                                         ;  .
.SlowDown:              JumpIfALTNusng 18, .NoSpeedChange
.Deccelerate:           ld      a,-2
                        ld      (UBnKAccel),a
                        ret
.NoSpeedChange:         ZeroA                                       ; else no change
                        ld      (UBnKAccel),a
                        ret                        
