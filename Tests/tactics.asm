;.. Missile Tactics test code

                        DEVICE ZXSPECTRUMNEXT
                        DEFINE  DOUBLEBUFFER 1
                        CSPECTMAP tactics.map
                        OPT --zxnext=cspect --syntax=a --reversepop
                        INCLUDE "../Macros/carryFlagMacros.asm"
                        INCLUDE "../Macros/jumpMacros.asm"
                        INCLUDE "../Macros/ldCopyMacros.asm"
                        INCLUDE "../Macros/ShiftMacros.asm"
                        INCLUDE "../Macros/signBitMacros.asm"
                        INCLUDE "../Macros/NegateMacros.asm" 
                        INCLUDE "../Macros/returnMacros.asm" 
                        INCLUDE "../Macros/MathsMacros.asm" 
                        ;INCLUDE "../Variables/constant_equates.asm"
SignMask8Bit		equ %01111111
SignMask16Bit		equ %0111111111111111
SignOnly8Bit		equ $80
SignOnly16Bit		equ $8000
                        
testStartup:            ORG         $8000
                        ld      a, $80
                        ld      hl,1500
                        ld      (UBnKxlo),hl
                        ld      hl,2000
                        ld      (UBnKylo),hl
                        ld      (UBnKysgn),a
                        ld      hl,1000
                        ld      (UBnKzlo),hl
                        ld      a,$F9
                        ld      (UBnkrotmatSidevX),a
                        ld      (UBnkrotmatRoofvY),a
                        ld      (UBnkrotmatNosevZ),a

                        call    UpdateTargetingShipX
.EndLoop:               jp      .EndLoop                        

UpdateTargetingShipX : break
                        ld      de,(TargetKxlo)                        ; get target ship X
                        ld      a,(TargetKxsgn)                        ; and flip sign so we have missile - target
                        FlipSignBitA
                        ld      c,a                                 ; get target ship x sign but * -1 as we are subtracting
                        ld      hl,(UBnKxlo)                        ; get missile x
                        ld      a,(UBnKxsgn)                        ; get missile x sign
                        ld      b,a
                        call    ADDHLDESignBC                       ;AHL = BHL + CDE i.e. missile - target x
                        ld      (TacticsVectorX),hl
                        ld      (TacticsVectorX+2),a
.UpdateTargetingShipY:  ld      de,(TargetKylo)                        ; get target ship X
                        ld      a,(TargetKysgn)
                        FlipSignBitA
                        ld      c,a                                 ; get target ship x sign but * -1 as we are subtracting
                        ld      hl,(UBnKylo)                        ; get missile x
                        ld      a,(UBnKysgn)                        ; get missile x sign
                        ld      b,a
                        call    ADDHLDESignBC                       ;AHL = BHL + CDE i.e. missile - target x
                        ld      (TacticsVectorY),hl
                        ld      (TacticsVectorY+2),a
.UpdateTargetingShipZ:  ld      de,(TargetKzlo)                        ; get target ship X
                        ld      a,(TargetKzsgn)
                        FlipSignBitA
                        ld      c,a                                 ; get target ship x sign but * -1 as we are subtracting
                        ld      hl,(UBnKzlo)                        ; get missile x
                        ld      a,(UBnKzsgn)                        ; get missile x sign
                        ld      b,a
                        call    ADDHLDESignBC                       ;AHL = BHL + CDE i.e. missile - target x
                        ld      (TacticsVectorZ),hl
                        ld      (TacticsVectorZ+2),a
;--- Now we can actually update the missile AI                      
.UpdateMissilePos:      
.NormaliseDirection:    call    NormalizeTactics                    ; Normalise vector down to 7 bit + sign byte
.NoseDotProduct:        call    XX12EquTacticsDotNosev              ; SA = nose . XX15
                        ld      (TacticsDotProduct1),a               ; CNT = A (high byte of dot product)
                        ld      a,(varS)                            ; get sign from dot product
.FlipDirectionSign:     xor     SignOnly8Bit                        ; and flip the sign bit
                        and     SignOnly8Bit                        ; and save the sign into Dot product
                        ld      (TacticsDotProduct1+1),a             ; negate value of CNT so +ve if facing or -ve if facing same way
.NegateDirection:       FlipSignMem TacticsVectorX+2                ; negate vector in XX15 so it points opposite direction
                        FlipSignMem TacticsVectorY+2                ; we have already negated the dot product above
                        FlipSignMem TacticsVectorZ+2                ; .  
.RoofDotProduct:        break
                        call    XX12EquTacticsDotRoofv              ; Now tran the roof for rotation        
                        ld      (TacticsDotProduct2),a              ; so if its +ve then the roof is similar so pull up to head towards it
                        ld      a,(varS)                            ; .                                       
                        ld      (TacticsDotProduct2+1),a            ; .                                       
                        call    calcNPitch                          ; work out pitch return with a holding z counter
                        sla     a                                   ; strip off sign (also doubling it)
                        JumpIfAGTENusng 32, .AlreadyRolling
.SideDotProduct:        call    XX12EquTacticsDotSidev              ; get dot product of xx15. sidev
                        ld      (TacticsDotProduct3),a              ; This will be positive if XX15 is pointing in the same direction
                        ld      a,(varS)                            ;  
                        xor     SignOnly8Bit                        ; and flip the sign bit
                        and     SignOnly8Bit                        ; and save the sign into Dot product                        
                        ld      (TacticsDotProduct3+1),a            ;
                        call    calcNRoll                           ; a = rotx signed
.AlreadyRolling:        ld      a,(TacticsDotProduct1+1)            ; Fetch the dot product of nosev back
                        JumpIfAIsNotZero    .SlowDown               ; if it's negative jump to slow down routine
                        ld      a,(TacticsDotProduct1)
                        JumpIfALTNusng  22, .SlowDown
.Accellerate:           ld      a,3                                 ; full accelleration
                        ld      (UBnKAccel),a
                        ret
.SlowDown:              ld      a,(TacticsDotProduct2)              ; this is already abs so no need to do abs
                        ReturnIfALTNusng  18                        ; If A < 18 then the ship is way off the XX15 vector, so return without slowing down, as it still has quite a bit ofturning to do to get on course
                        ld      a,$FE                               ; A = -3 as missiles are more nimble and can brake more quickly
                        ld      (UBnKAccel),a
                        ret

                        INCLUDE "../GameEngine/TacticsWorkingData.asm"
                        INCLUDE "../Universe/Ships/XX12Vars.asm"
                        INCLUDE "../Universe/Ships/XX15Vars.asm"
                        INCLUDE "../Universe/Ships/XX16Vars.asm"
                        ;INCLUDE "../Universe/Ships/AIRuntimeData.asm"
                        INCLUDE "../Maths/asm_add.asm"
                        INCLUDE "../Maths/Utilities/badd_ll38.asm"
                        INCLUDE "../Maths/Utilities/AequAdivQmul96-TIS2.asm"
                        INCLUDE "../Maths/asm_sqrt.asm"
varQ                           DB  0
varR                           DB  0
varS                           DB  0
varT                           DB  0
TargetKxlo                     DB  198 
TargetKxhi                     DB  0 
TargetKxsgn                    DB  0 
TargetKylo                     DB  60 
TargetKyhi                     DB  0 
TargetKysgn                    DB  $80 
TargetKzlo                     DB  $B8 
TargetKzhi                     DB  $0B 
TargetKzsgn                    DB  0 
Padding1                       DS 7
UBnKxlo                     DB  0                       ; INWK+0
UBnKxhi                     DB  0                       ; there are hi medium low as some times these are 24 bit
UBnKxsgn                    DB  0                       ; INWK+2
UBnKylo                     DB  0                       ; INWK+3 \ ylo
UBnKyhi                     DB  0                       ; INWK+4 \ yHi
UBnKysgn                    DB  0                       ; INWK +5
UBnKzlo                     DB  0                       ; INWK +6
UBnKzhi                     DB  0                       ; INWK +7
UBnKzsgn                    DB  0                       ; INWK +8
Padding1B                       DS 7
;-Rotation Matrix of Ship----------------------------------------------------------------------------------------------------------
; Rotation data is stored as lohi, but only 15 bits with 16th bit being  a sign bit. Note this is NOT 2'c compliment
; Note they seem to have to be after camera position not quite found why yet, can only assume it does an iy or ix indexed copy? Bu oddly does not affect space station.
UBnkrotmatSidevX            DW  0                       ; INWK +21
UBnkrotmatSidev             equ UBnkrotmatSidevX
UBnkrotmatSidevY            DW  0                       ; INWK +23
UBnkrotmatSidevZ            DW  0                       ; INWK +25
Padding2                    DS  10
UBnkrotmatRoofvX            DW  0                       ; INWK +15
UBnkrotmatRoofv             equ UBnkrotmatRoofvX
UBnkrotmatRoofvY            DW  0                       ; INWK +17
UBnkrotmatRoofvZ            DW  0                       ; INWK +19
Padding3                    DS  10
UBnkrotmatNosevX            DW  0                       ; INWK +9
UBnkrotmatNosev             EQU UBnkrotmatNosevX
UBnkrotmatNosevY            DW  0                       ; INWK +11
UBnkrotmatNosevZ            DW  0                       ; INWK +13
Padding4                    DS  10
UBnKSpeed                   DB  0                       ; INWK +27
UBnKAccel                   DB  0                       ; INWK +28
UBnKRotXCounter             DB  0                       ; INWK +29
UBnKRotZCounter             DB  0                       ; INWK +30
Padding5                    DS  10

;-Rotation Matrix of Ship----------------------------------------------------------------------------------------------------------
; Rotation data is stored as lohi, but only 15 bits with 16th bit being  a sign bit. Note this is NOT 2'c compliment
; Note they seem to have to be after camera position not quite found why yet, can only assume it does an iy or ix indexed copy? Bu oddly does not affect space station.

; In A = sign of dot product
calcNPitch:             xor     SignOnly8Bit                    ; c = sign flipped of dot product only
                        and     SignOnly8Bit                    ; .
                        ld      c,a                             ; . (varT in effect)
                        ld      a,(UBnKRotZCounter)             ; b = abs (currentz pitch)
                        and     SignMask8Bit                    ; . which will initially be 0
                        ld      b,a                             ; .
                        ld      a,(TacticsDotProduct2)          ; a = abs roof dot product
                        JumpIfALTNusng 4, .calcNPitch2          ; if a >= roll threshold
                        ld      a,3                             ;    z rot = z rot * dot product flipped sign
                        or      c                               ;    i.e. zrot = current magnitude but dot product sign flipped
                        ld      (UBnKRotZCounter),a             ;    .
                        ret                                     ; else (a LT current abs z)
.calcNPitch2:           or      c                               ;     rot z = dot product with sign flipped
                        ld      (UBnKRotZCounter),a             ;
                        ret                                     ;
                        
calcNRoll:              xor     SignOnly8Bit                    ; flip sign of dot product
                        and     SignOnly8Bit
                        ld      c,a
                        ld      a,(UBnKRotXCounter)
                        and     SignMask8Bit                    ; get ABS value
                        ld      b,a
                        ld      a,(TacticsDotProduct2)          ; now we have the dot product abs value
                        JumpIfALTNusng 4, .calcNRoll2
                        ld      a,3
                        or      c
                        ld      (UBnKRotXCounter),a
                        ret
.calcNRoll2:            or      c                               ;     rot z = dot product with sign flipped
                        ld      (UBnKRotXCounter),a
                        ret
                        
XX12EquTacticsDotNosev: IFDEF TACTICSDEBUG
                            ld      hl,(UBnkrotmatSidevX)
                            ld      a,(UBnkrotmatSidevX+2)
                            ld      (TacticsSideX),hl
                            ld      (TacticsSideX+2),a
                            ld      hl,(UBnkrotmatSidevY)
                            ld      a,(UBnkrotmatSidevY+2)
                            ld      (TacticsSideY),hl
                            ld      (TacticsSideY+2),a
                            ld      hl,(UBnkrotmatSidevZ)
                            ld      a,(UBnkrotmatSidevZ+2)
                            ld      (TacticsSideZ),hl
                            ld      (TacticsSideZ+2),a
                        
                            ld      hl,(UBnkrotmatRoofvX)
                            ld      a,(UBnkrotmatRoofvX+2)
                            ld      (TacticsRoofX),hl
                            ld      (TacticsRoofX+2),a
                            ld      hl,(UBnkrotmatRoofvY)
                            ld      a,(UBnkrotmatRoofvY+2)
                            ld      (TacticsRoofY),hl
                            ld      (TacticsRoofY+2),a
                            ld      hl,(UBnkrotmatRoofvZ)
                            ld      a,(UBnkrotmatRoofvZ+2)
                            ld      (TacticsRoofZ),hl
                            ld      (TacticsRoofZ+2),a

                            ld      hl,(UBnkrotmatNosevX)
                            ld      a,(UBnkrotmatNosevX+2)
                            ld      (TacticsNoseX),hl
                            ld      (TacticsNoseX+2),a
                            ld      hl,(UBnkrotmatNosevY)
                            ld      a,(UBnkrotmatNosevY+2)
                            ld      (TacticsNoseY),hl
                            ld      (TacticsNoseY+2),a
                            ld      hl,(UBnkrotmatNosevZ)
                            ld      a,(UBnkrotmatNosevZ+2)
                            ld      (TacticsNoseZ),hl
                            ld      (TacticsNoseZ+2),a
                        ENDIF

                        ld      hl,UBnkrotmatNosevX
XX12EquTacticsDotHL:    N0equN1byN2div256 varT, (hl), (TacticsVectorX)       ; T = (hl) * regXX15fx /256 
                        inc     hl                                  ; move to sign byte
.XX12CalcXSign:         AequN1xorN2 TacticsVectorX+2, (hl) ;UBnkXScaledSign,(hl)             ;
                        ld      (varS),a                            ; Set S to the sign of x_sign * sidev_x
                        inc     hl
.XX12CalcY:              N0equN1byN2div256 varQ, (hl),(TacticsVectorY)       ; Q = XX16 * XX15 /256 using varQ to hold regXX15fx
                        ldCopyByte varT,varR                        ; R = T =  |sidev_x| * x_lo / 256
                        inc     hl
                        AequN1xorN2 TacticsVectorY+2,(hl)             ; Set A to the sign of y_sign * sidev_y
; (S)A = |sidev_x| * x_lo / 256  = |sidev_x| * x_lo + |sidev_y| * y_lo
.STequSRplusAQ           push    hl
                        call    baddll38                            ; JSR &4812 \ LL38   \ BADD(S)A=R+Q(SA) \ 1byte add (subtract)
                        pop     hl
                        ld      (varT),a                            ; T = |sidev_x| * x_lo + |sidev_y| * y_lo
                        inc     hl
.XX12CalcZ:              N0equN1byN2div256 varQ,(hl),(TacticsVectorZ)       ; Q = |sidev_z| * z_lo / 256
                        ldCopyByte varT,varR                        ; R = |sidev_x| * x_lo + |sidev_y| * y_lo
                        inc     hl
                        AequN1xorN2 TacticsVectorY+2,(hl)             ; A = sign of z_sign * sidev_z
; (S)A= |sidev_x| * x_lo + |sidev_y| * y_lo + |sidev_z| * z_lo        
                        call    baddll38                            ; JSR &4812 \ LL38   \ BADD(S)A=R+Q(SA)   \ 1byte add (subtract)
; Now we exit with A = result S = Sign        
                        ret

XX12EquTacticsDotRoofv: ld      hl,UBnkrotmatRoofvX
                        jp      XX12EquTacticsDotHL
                        
XX12EquTacticsDotSidev: ld      hl,UBnkrotmatSidevX
                        jp      XX12EquTacticsDotHL
                        
                        
;NormalizeTactics:       ld      hl, (TacticsVectorX)        ; pull XX15 into registers
;                        ld      de, (TacticsVectorY)        ; .
;                        ld      bc, (TacticsVectorZ)        ; .
;.SetMinZ1:              ld      a,c
;                        or      1
;                        ld      c,a
;.CalcShift:             ld      a,h                         ; Chceck if any high bytes overflowed
;                        or      d                           ;
;                        or      b                           ;
;                        rl      a                           ;
;                        jr      c.ShiftDone
;.Perform.PerformShift:  ShiftBCLeft1                        ; now shift vectors 
;                        ShiftDELeft1                        ; by 
;                        ShiftHLLeft1                        ; left 1 bit
;                        jp      .CalcShift
;.ShiftDone:             srl     h                           ; here x y z are made 7 bit values
;.SignY:                 srl     d
;                        ld      l,d                         ; set l to y
;.SignZ:                 srl     b
;                        ld      e,d                         ; d = y e = y
;                        mul     de                          ' 
;                        

    