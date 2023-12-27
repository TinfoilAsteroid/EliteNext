                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"
                DISPLAY "3D Test Code"
                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"
                DISPLAY "TODO: Odd Single pixel bug "
    DEVICE ZXSPECTRUMNEXT
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION


    DEFINE  SHIP_DRAW_FULL_SCREEN 1
    DEFINE  USE_NORMALISE_IX  1
    DEFINE  INTERRUPS_DISABLE 1
    DEFINE  DEBUG_NO_TACTICS_CODE 1
 CSPECTMAP VecTest.map
 OPT --zxnext=cspect --syntax=a --reversepop
;-- Key Definitions                        
;   Q/A pitch       O/P roll        W/A Thrust
;   T/G ship pitch, F/H ship roll   U/J Ship Thrust
;   P   Cycle through ships
;----------------------------------------------------------------------------------------------------------------------------------
; Game Defines
;----------------------------------------------------------------------------------------------------------------------------------
; Colour Defines
                        INCLUDE "../../Hardware/L1ColourDefines.asm"
                        INCLUDE "../../Hardware/L2ColourDefines.asm"
                        INCLUDE "../../Hardware/register_defines.asm"
                        INCLUDE "../../Layer2Graphics/layer2_defines.asm"
                        INCLUDE	"../../Hardware/memory_bank_defines.asm"
                        INCLUDE "../../Hardware/screen_equates.asm"
                        INCLUDE "../../Data/ShipModelEquates.asm"
                        INCLUDE "../../Macros/graphicsMacros.asm"
                        INCLUDE "../../Macros/callMacros.asm"
                        INCLUDE "../../Macros/carryFlagMacros.asm"
                        INCLUDE "../../Macros/CopyByteMacros.asm"
                        INCLUDE "../../Macros/ldCopyMacros.asm"
                        INCLUDE "../../Macros/ldIndexedMacros.asm"
                        INCLUDE "../../Macros/jumpMacros.asm"
                        INCLUDE "../../Macros/MathsMacros.asm"
                        INCLUDE "../../Macros/MMUMacros.asm"
                        INCLUDE "../../Macros/NegateMacros.asm"
                        INCLUDE "../../Macros/returnMacros.asm"
                        INCLUDE "../../Macros/ShiftMacros.asm"
                        INCLUDE "../../Macros/signBitMacros.asm"
                        INCLUDE "../../Macros/KeyboardMacros.asm"
                        INCLUDE "../../Universe/UniverseMacros/asm_linedraw.asm"
                        INCLUDE "../../Universe/UniverseMacros/UniverseVarsDefineMacro.asm"
                        INCLUDE "../../Variables/general_variables_macros.asm"
                        INCLUDE "../../Variables/UniverseSlot_macros.asm"
                        INCLUDE "../../Data/ShipIdEquates.asm"
                        
SetBorder:              MACRO   value 
                        MMUSelectLayer1
                        ld          a,value
                        call        l1_set_border
                        ENDM
                        
charactersetaddr		equ 15360
STEPDEBUG               equ 1

TopOfStack              equ $5CCB ;$6100

                        ORG $5DCB;      $6200
EliteNextStartup:       di
.InitialiseClockSpeed:  nextreg     TURBO_MODE_REGISTER,Speed_28MHZ
.InitialiseLayerOrder:  nextreg     DISPLAY_CONTROL_1_REGISTER, 0   ; no layer 2
                        DISPLAY "Starting Assembly At ", EliteNextStartup
                        ; "STARTUP"
                        ; Make sure  rom is in page 0 during load
                        MMUSelectROMS
                        MMUSelectLayer1
                        call		l1_cls
                        ld			a,L1ColourInkBlack | L1ColourPaperWhite
                        call		l1_attr_cls_to_a
                        SetBorder   $FF
.InitialisingMessage:   MMUSelectUniverseN  0
                        call        ResetUniv
InitialiseMainLoop:     call        ClearUnivSlotList
                        MMUSelectKeyboard
                        call        init_keyboard
                        ZeroA
                        ld          (JSTX),a
                        ld          (JSTY),a
.CreateMissle:          call        CreateMissile
.CreateTarget:          call        CreateTarget
;...................................................................................................................................
                        call        DisplayBoiler
;...................................................................................................................................
InitMainLoop:           ZeroA
                        ld      (ALPHA),a
                        ld      (BETA),a                       
MainLoop:	            MMUSelectMathsBankedFns                                         ; make sure we are in maths routines in case a save paged out
;                        break
;TestAdd:                ld      hl, 20
;                        ld      de, 20
;                        ld      bc, $00
;                        call    ADDHLDESignBC
;                        ld      hl, 10
;                        ld      de, 20
;                        ld      bc, $8000
;                        call    ADDHLDESignBC
;                        ld      hl, 20
;                        ld      de, 10
;                        ld      bc, $0080
;                        call    ADDHLDESignBC
;                        ld      hl, 10
;                        ld      de, 10
;                        ld      bc, $8080
;                        call    ADDHLDESignBC
;                        ld      hl, 20
;                        ld      de, 10
;                        ld      bc, $8000
;                        call    ADDHLDESignBC
;                        ld      hl, 10
;                        ld      de, 20
;                        ld      bc, $0080
;                        call    ADDHLDESignBC
;                        break
                        call    doRandom
                                                ; redo the seeds every frame
;.. Check if keyboard scanning is allowed by screen. If this is set then skip all keyboard and AI..................................
InputBlockerCheck:      MMUSelectKeyboard
                        call    scan_keyboard
;-- Key Definitions                        
; Player Pitcn and Roll
;   Q/A pitch       O/P roll        W/A Thrust
;  Kill Missile and launch from 0,0,0
                        ld      a,VK_H
                        call    is_vkey_pressed
                        call    z, HomeMissile
;  Kill Missile and launch new one
                        ld      a,VK_N
                        call    is_vkey_pressed
                        call    z, RandomMissile
; Reset missile to identity matrix
                        ld      a,VK_I
                        call    is_vkey_pressed
                        call    z, IdentityMissile
; Tidy and Normalise Vector    
                        ld      a,VK_V
                        call    is_vkey_pressed
                        call    z, TidyMissile
; Randomise Target Position
                        ld      a,VK_T
                        call    is_vkey_pressed
                        call    z, RandomTarget
; Run or pause missile                        
                        ld      a,VK_P
                        call    is_vkey_pressed
                        call    z, ToggleMissileState
;.. Update values based on movekey keys, may likley need damping as this coudl be very fast
CalcValues:             call    UpdateTacticsVars
UpdateShipsControl:     ld      a,(MissileState)
                        and     a
                        jp      z,.NotRunning
.Running:               call    UpdateUniverseObjects
.NotRunning:
;.. Render Ship ...................................................................................................................
RenderPositions:        DISPLAY "TODO Copy missile and target to buffers to print"
                        MMUSelectUniverseN 2
                        ld      d,RowTarget
                        call    DisplayPosition
                        MMUSelectUniverseN 1
                        ld      d,RowMissle
                        call    DisplayPosition
                        call    DisplayMatrix
                        call    DisplayAccellSpeed
                        call    DisplayRollPitch
                        call    DisplayRelative
                        call    DisplayDirection
                        call    DisplayDotProduct
                        call    DisplayActionStatus
;.. Flip Buffer ..................................................................................................................
                        jp MainLoop

IdentityMissile:        MMUSelectUniverseN 1
                        call    InitialiseOrientation
                        ret

MissileState            DB      0
                        
ToggleMissileState:     ld      a,(MissileState)
                        xor     $80
                        ld      (MissileState),a
                        ret

;-- Home Missile Position ---------------------------------------------------------------------------------------------------------
HomeMissile:            MMUSelectUniverseN 1
                        ld      hl,UBnKxlo
                        ld      (hl),0
                        ld      de,UBnKxlo+1
                        ld      bc,8
                        ldir
                        ret

RandomPosition:         ld      ix,UBnKxlo
                        call    SetS24Random
                        ld      ix,UBnKylo
                        call    SetS24Random
                        ld      ix,UBnKzlo
SetS24Random:           call    doRandomS24
                        ld      (ix+0),a
                        ld      (ix+1),e
                        ld      (ix+2),d
                        ret
;-- Random Missile Position -------------------------------------------------------------------------------------------------------
RandomMissile:          MMUSelectUniverseN 1
                        jp      RandomPosition
;-- Tidy Missile Vectors ---------------------------------------------------------------------------------------------------------
TidyMissile:            MMUSelectUniverseN 1
                        call    TidyVectorsIX
                        ret
;-- Random Target Position --------------------------------------------------------------------------------------------------------
RandomTarget:           MMUSelectUniverseN 2
                        jp      RandomPosition
                        ret
;.. Keyboard Routines .............................................................................................................

                        
;..Update Universe Objects.........................................................................................................
;..................................................................................................................................                        
;                           DEFINE ROTATIONDEBUG 1
;                           DEFINE CLIPDEBUG 1
CurrentShipUniv:        DB      0
;..................................................................................................................................                        
; if ship is destroyed or exploding then z flag is clear, else z flag is set
;..................................................................................................................................                        
; calculate details of direction and dot products
UpdateTacticsVars:      MMUSelectUniverseN      1
                        call    LoadTargetData              ; Target position to UBnKTarget Pos
                        call    CalculateRelativePos        ; Target - missile to UBnKOffset
                        call    CheckDistance               ; Calculate distance, near far
                        call    CopyOffsetToDirection       ; Copy UBnKOffset to UBnKDirection
                        call    NormaliseDirection          ; Normalise Direction into UBnKDirNorm
                        ld      hl,UBnkrotmatNosev          ; Copy nose to tactics matrix and calculate dot product in a
                        call    CalculateDotProducts        ; AHL = dot product of missile pos and nose
                        ld      (UBnKDotProductNose),hl     ; .
                        ld      (UBnKDotProductNoseSign),a  ; .
                        and     $80
                        jp      z,.PositiveNose
.NegativeNose:          call    SetStatusBehind
                        call    ClearStatusForward
                        jp      .DoRoofDot
.PositiveNose:          call    ClearStatusBehind
                        call    SetStatusForward
.DoRoofDot:             ld      hl,UBnkrotmatRoofv          ; Copy roof to tactics matrix and calculate dot product in a
                        call    CalculateDotProducts        ; AHL = dot product of missile pos and roof
                        ld      (UBnKDotProductRoof),hl     ; .
                        ld      (UBnKDotProductRoofSign),a  ; .
                        ; as we calculate target - missile the signs are already reversed
                        ;call    FlipDirectionSigns          ; Now the target is looking at the missile rather than missile at target
;.. Missile Tactics ...............................................................................................................                        
                        call    SeekingLogic
                        ret
;..................................................................................................................................                        
; Replacement for MVEIT routine
UpdateUniverseObjects:  MMUSelectUniverseN      1
;.. Update Position ................................................................................................................................                        
                        call    ApplyShipRollAndPitch
                        call    ApplyShipSpeed
                        call    UpdateSpeedAndPitch                             ; update based on rates of speed roll and pitch accelleration/decelleration
                        ret
;..................................................................................................................................                        
; For now no random numbers
;  later random < 16 do nothing
; if dot product for nose is negative then its over 90 degrees off

; dot product of 36 is direct facing (96*96/256)
; Angle table    +                  -
;             36 =  0 (head on)  36 = 180
;             35 = 15            35 = 166
;             31 = 30            31 = 149
;             27 = 41            27 = 138
;             25 = 45            25 = 133
;             22 = 52            22 = 127
;             18 = 60            18 = 120
;             15 = 65            15 = 114
;             10 = 73            10 = 106
;              8 = 77             8 = 102
;              7 = 78             7 = 101
;              3 = 85             3 = 94
;              0 = 90             0 = 90
; Using nose dot product (in original CNT is nose dot product
; it nose is pointing at target then accellerate to max speed
; if nose is pointing > +/- 45 then then slow down slightly
; if nose is pointing > +/- 90 then then slow down hard
; Note impact is 0000.XX on all points
SeekingLogic:           ld      a,(UBnKRotZCounter)
                        and     a
                        call    z, AdjustPitch              ; only call if there are no existing pitch orders
                        ld      a,(UBnKRotXCounter)
                        and     a
                        call    z, AdjustRoll               ; only call if there are no existing roll orders
                        ld      a,(UBnKAccel)
                        and     a
                        call    z, AdjustSpeed
                        ret
;..................................................................................................................................                        
AdjustPitch:            ld      a,(UBnKDotProductRoofSign)  ; if its negative then its over 90 degrees
                        ld      h,a                         ; .
                        and     a                           ; .
                        jp      z,.Over90Degrees            ; .
.Under90Degrees:        ld      a,(UBnKDotProductRoof+1)    ; get High byte of dot product
                        JumpIfAGTENusng   35, .pitchZero    ; within 13 degees don't steer as proximity blast will do
                        JumpIfAGTENusng   22, .pitchBySmall
                        jp      .pitchNormal
.pitchZero:             ZeroA
                        ld      (UBnKRotZCounter),a
                        call    ClearStatusPitch
                        ret
.pitchNormal:           ld      a,2
                        ld      (UBnKRotZCounter),a     ; max climb (we will randomly choose +/- later but need to consider stick bit 8)
                        call    SetStatusPitch
                        ret                     
.pitchBySmall:          ld      a,1
                        ld      (UBnKRotZCounter),a     ; max climb (we will randomly choose +/- later but need to consider stick bit 8)
                        call    SetStatusPitch
                        ret
.Over90Degrees:         ld      a,5
                        ld      (UBnKRotZCounter),a     ; max climb (we will randomly choose +/- later but need to consider stick bit 8)
                        call    SetStatusPitch
                        ret
;..................................................................................................................................                        
AdjustRoll:             ld      a,(UBnKDotProductNoseSign)  ; if its negative then its over 90 degrees
                        ld      h,a                         ; .
                        and     a                           ; .
                        jp      z,.Over90Degrees            ; .
.Under90Degrees:        ld      a,(UBnKDotProductNose+1)    ; get High byte of dot product
                        JumpIfAGTENusng   30, .rollZero    ; within 13 degees don't steer as proximity blast will do
                        JumpIfAGTENusng   22, .rollBySmall
                        jp      .rollNormal
.rollZero:              ZeroA
                        ld      (UBnKRotXCounter),a
                        call    ClearStatusRoll
                        ret
.rollNormal:            ld      a,2
                        ld      (UBnKRotXCounter),a     ; max climb (we will randomly choose +/- later but need to consider stick bit 8)
                        call    SetStatusRoll
                        ret                     
.rollBySmall:           ld      a,1
                        ld      (UBnKRotXCounter),a     ; max climb (we will randomly choose +/- later but need to consider stick bit 8)
                        call    SetStatusRoll
                        ret
.Over90Degrees:         ld      a,5
                        ld      (UBnKRotXCounter),a     ; max climb (we will randomly choose +/- later but need to consider stick bit 8)
                        call    SetStatusRoll
                        ret
;..................................................................................................................................                        
AdjustSpeed:            ld      a,(UBnKDotProductNoseSign)          ; if negative facing away so slow
                        and     a
                        jr      nz,.SlowDown
                        ld      a,(UBnKDotProductNose+1)
                        JumpIfAGTENusng   30, .Accelerate           ; close enough to accellerate
                        JumpIfALTNusng  22,.SmallSlow               ; if nose < 22  (over 50 degrees ) then small slow down
                        jp      .NoSpeedChange                      ; between 22 and 30 coast
.Accelerate :           ld      a,3                                 ; else on target so power on
                        ld      (UBnKAccel),a                       ;  accelleration = 3
                        call    SetStatusFast
                        call    ClearStatusSlow
                        ret
.SlowDown:              JumpIfALTNusng 18, .SmallSlow              ; if its < 18 then its within 120 degrees so small slow
.Deccelerate:           ld      a,-5                               ; else faster Slow
                        ld      (UBnKAccel),a
                        call    ClearStatusFast
                        call    SetStatusSlow
                        ret
.SmallSlow:             ld      a,-2
                        ld      (UBnKAccel),a
                        call    ClearStatusFast
                        call    SetStatusSlow
                        ret                     
.NoSpeedChange:         ZeroA                                       ; else no change
                        ld      (UBnKAccel),a
                        call    ClearStatusFast
                        call    ClearStatusSlow
                        ret

;..................................................................................................................................                        
FlipDirectionSigns:     ld      a,(UBnKDirNormXSign)
                        xor     $80
                        ld      (UBnKDirNormXSign),a
                        ld      a,(UBnKDirNormYSign)
                        xor     $80
                        ld      (UBnKDirNormYSign),a
                        ld      a,(UBnKDirNormZSign)
                        xor     $80
                        ld      (UBnKDirNormZSign),a
                        ret
                        ld      a,(UBnKDotProductNoseSign)
                        xor     $80
                        ld      (UBnKDotProductNoseSign),a
                        ld      a,(UBnKDotProductRoofSign)
                        xor     $80
                        ld      (UBnKDotProductRoofSign),a
                        ret
;..................................................................................................................................                        
CopyOffsetToDirection:  MMUSelectUniverseN 1
                        ld      hl,UBnKOffset
                        ld      de,UBnKDirection
                        ld      bc,9
                        ldir
                        ret
;..................................................................................................................................                        
; Normalises UBnKDirection into UBnKDirNorm with Sign byte and 7 bit normal
; result of 36 means they are directly in align + at - away
NormaliseDirection:     MMUSelectUniverseN 1
                        ld      a,(UBnKDirectionXSign)      ; Direction x = abs Direction X , b bit 7 = sign of X
                        ld      c,a                         ; .
                        and     $80                         ; .
                        ld      (UBnKDirNormXSign),a        ; Save sign into NormSign
                        ld      a,c                         ; .
                        and     $7F                         ; .
                        ld      (UBnKDirectionXSign),a      ; .
.ABSYComponenet:        ld      a,(UBnKDirectionYSign)      ; Direction y = abs Direction y , b bit 6 = sign of y
                        ld      c,a                         ; .
                        and     $80                         ;  get sign bit from a
                        ld      (UBnKDirNormYSign),a        ; Save sign into NormSign
                        ld      a,c
                        and     $7F                         ; .
                        ld      (UBnKDirectionYSign),a      ; .                 
.ABSXZomponenet:        ld      a,(UBnKDirectionZSign)      ; Direction y = abs Direction y , b bit 6 = sign of y
                        ld      c,a                         ; .
                        and     $80                         ;  get sign bit from a
                        ld      (UBnKDirNormZSign),a        ; Save sign into NormSign
                        ld      a,c
                        and     $7F                         ; .
                        ld      (UBnKDirectionZSign),a      ; .
;.. When we hit here the UBnKTargetX,Y and Z are 24 bit abs values to simplify scaling                        
.Scale:                 ld      hl, (UBnKDirectionX)        ; [ixh h l]  = X
                        ld      a,(UBnKDirectionXSign)      ; .
                        ld      ixh,a                       ; .
                        ld      de, (UBnKDirectionY)        ; [iyh d e ] = Y
                        ld      a,(UBnKDirectionYSign)      ; .
                        ld      iyh,a                       ; .
                        ld      bc, (UBnKDirectionZ)        ; [iyl b c ] = Z
                        ld      a,(UBnKDirectionZSign)      ; .
                        ld      iyl,a                       ; .
.ScaleLoop1:            ld      a,ixh                       ; first pass get to 16 bit leaving hl = X de = Y bc = Z 
                        or      iyh                         ;                          
                        or      iyl                         ;                          
                        jp      z,.DoneScaling1             ; .
                        ShiftIXhHLRight1                    ; .
                        ShiftIYhDERight1                    ; .
                        ShiftIYlBCRight1                    ; .
                        jp      .ScaleLoop1
.DoneScaling1:          ;-- Now we have got here hl = X, de = Y, bc = Z
                        ;-- we cal just jump into the Normalize Tactics code
.ScaleLoop2:            ld      a,h                         ; Now scale down to 8 bit
                        or      d                           ; so l = X e = Y c = Z
                        or      b                           ; .
                        jr      z,.DoneScaling2             ; .
                        ShiftHLRight1                       ; .
                        ShiftDERight1                       ; .
                        ShiftBCRight1                       ; .
                        jp      .ScaleLoop2                 ; .
;-- Now we are down to 8 bit values, so we need to scale again to get S7         
.DoneScaling2:          ShiftHLRight1                       ; Scale once again to 7 bit with no sign
                        ShiftDERight1                       ; l = X e = Y c = Z
                        ShiftBCRight1                       ; .
.CalculateLength:       push    hl,,de,,bc                  ; save vector x y and z nwo they are scaled to 1 byte
                        ld      d,e                         ; hl = y ^ 2
                        mul     de                          ; .
                        ex      de,hl                       ; .
                        ld      d,e                         ; de = x ^ 2
                        mul     de                          ; .
                        add     hl,de                       ; hl = y^ 2 + x ^ 2
                        ld      d,c                         ; de = z * 2
                        ld      e,c                         ; .
                        mul     de                          ; .
                        add     hl,de                       ; hl =  y^ 2 + x ^ 2 + z ^ 2
                        ex      de,hl                       ; fix as hl was holding square
                        call    asm_sqrt                    ; hl = sqrt (de) = sqrt (x ^ 2 + y ^ 2 + z ^ 2)
                        ; add in logic if h is low then use lower bytes for all 
;.RetrieveSignBits:      ld      a,(UBnKDirectionSignPacked) ; load sign bits to iyl
;                        ld      iyl,a                       ; 
.NormaliseZ:            ld      a,l                         ; save length into iyh
                        ld      iyh,a                       ; .
                        ld      d,a                         ; and also into d
                        pop     bc                          ; retrive z scaled
                        ld      a,c                         ; a = scaled byte
                        call    AequAdivDmul967Bit          ; a = z*96/Length
                        ld      (UBnKDirNormZ),a            ; now Tactics Vector Z byte 1 is value
.NormaliseY:            pop     de                          ; retrive y scaled
                        ld      a,e                         ; a = scaled byte
                        ld      d,iyh                       ; d = length
                        call    AequAdivDmul967Bit          ; a = z*96/Length
                        ld      (UBnKDirNormY),a            ; now Tactics Vector Y byte 1 is value
.NormaliseX:            pop     hl                          ; retrive x scaled
                        ld      a,l                         ; a = scaled byte
                        ld      d,iyh                       ; d = length 
                        call    AequAdivDmul967Bit          ; a = z*96/Length
                        ld      (UBnKDirNormX),a            ; now Tactics Vector X byte 1 is value
                        ret
;..................................................................................................................................                        
; copy nose and side rotation matricies                        
CopyRotmatToTactics:    inc     hl                                  ; optimise later by starting at x hi
                        ld      a,(hl)
                        ld      b,a
                        and     $80
                        ld      (UBnKTacticsRotMatXSign),a
                        ld      a,b
                        and     $7F
                        ld      (UBnKTacticsRotMatX),a
                        inc     hl
                        inc     hl
                        ld      a,(hl)
                        ld      b,a
                        and     $80
                        ld      (UBnKTacticsRotMatYSign),a
                        ld      a,b
                        and     $7F
                        ld      (UBnKTacticsRotMatY),a
                        inc     hl
                        inc     hl
                        ld      a,(hl)
                        ld      b,a
                        and     $80
                        ld      (UBnKTacticsRotMatZSign),a
                        ld      a,b
                        and     $7F
                        ld      (UBnKTacticsRotMatZ),a
                        ret
                        
;..................................................................................................................................                        
; Calculate dot products of roof and side against UBnKDirNorm
; UBnKDotProductNose = nose . direction = nose.x * dir x + nose.y * diry + nose.z * dirz
; UBnKDotProductSide = side . direction = side.x * dir x + side.y * diry + side.z * dirz
CalculateDotProducts:   call    CopyRotmatToTactics                 ; get matrix to work area
.CalcXValue:            ld      a,(UBnKTacticsRotMatX)              ; stack value of rotmatx & dir x
                        ld      d,a                                 ; .
                        ld      a,(UBnKDirNormX)                    ; .
                        ld      e,a                                 ; .
                        mul     de                                  ; .
                        push    de                                  ; save to stack for pulling into hl
.CalcYValue:            ld      a,(UBnKTacticsRotMatY)              ; de = rotmaty & dir y
                        ld      d,a                                 ; .
                        ld      a,(UBnKDirNormY)                    ; .
                        ld      e,a                                 ; .
                        mul     de                                  ; .
.CalcXSign:             ld      a,(UBnKDirNormXSign)                ; B  = A = Sign VecX xor sign RotMatX
                        ld      hl,UBnKTacticsRotMatXSign           ; .
                        xor     (hl)                                ; .
                        ld      b,a                                 ; .
.CalcYSign:             ld      a,(UBnKDirNormYSign)                ; B  = C = Sign VecY xor sign RotMatY
                        ld      hl,UBnKTacticsRotMatYSign           ; .
                        xor     (hl)                                ; .
                        ld      c,a                                 ; .
.SumSoFar:              pop     hl                                  ; hl = vecx * dirx
                        call    ADDHLDESignBC                       ; AHL = vecx*dirx + vecy*diry
                        ld      b,a                                 ; BHL = AHL
.CalcZValue:            ld      a,(UBnKTacticsRotMatZ)              ; de = rotmatz & dir z
                        ld      d,a                                 ; .
                        ld      a,(UBnKDirNormZ)                    ; .
                        ld      e,a                                 ; .
                        mul     de                       
.CalcZSign:             push    hl
                        ld      a,(UBnKDirNormZSign)                ; B  = C = Sign VecY xor sign RotMatY
                        ld      hl,UBnKTacticsRotMatZSign           ; .
                        xor     (hl)                                ; .
                        ld      c,a                                 ; so now CDE = z
                        pop     hl
.SumUp:                 call    ADDHLDESignBC                       ; AHL = vecx*dirx + vecy*diry + vecz*dirz
                        ret
;..................................................................................................................................                        
CheckDistance:          ld      hl,(UBnKOffsetXHi)                 ; test if high bytes are set (value is assumed to be 24 bit, though calcs are only 16 so this is uneeded)
                        ld      de,(UBnKOffsetYHi)                 ; .
                        ld      bc,(UBnKOffsetZHi)                 ; .
                        ld      a,h                                ; sign bytes only ignoring sign bit
                        or      d                                  ; .
                        or      b                                  ; .
                        ClearSignBitA                              ; .
                        JumpIfNotZero       .FarAway               ; if upper byte is non zero then very far away
                        or      l                                  ; test for low byte bit 7, i.e high of 16 bit values
                        or      e                                  ; .
                        or      c                                  ; .
                        JumpIfZero          .Hit                   ; if mid byte is non zero then in near distance
.Near:                  call    SetStatusNear
.Hit                    call    SetStatusHit                       ; which means if all mid bytes are zero then hit
                        call    ClearStatusFar
                        ret
.FarAway:               call    SetStatusFar
                        call    ClearStatusNear
                        call    ClearStatusHit
                        ret
;..................................................................................................................................
LoadTargetData:         MMUSelectUniverseN 2                        ;
                        ld      hl,UBnKxlo
                        ld      de,CurrentTargetXpos
                        ld      bc,9
                        ldir
                        MMUSelectUniverseN 1
                        ld      hl,CurrentTargetXpos
                        ld      de,UBnKTargetXPos
                        ld      bc,9
                        ldir
                        ret
;..................................................................................................................................
CalculateRelativePos:   ld      iy,UBnKxlo
                        ld      ix,UBnKTargetXPos
                        call    SubDELequAtIXMinusAtIY24Signed
                        ld      a,l
                        ld      (UBnKOffset),a
                        ld      (UBnKOffset+1),de
.RelativeY:             ld      iy,UBnKylo
                        ld      ix,UBnKTargetYPos
                        call    SubDELequAtIXMinusAtIY24Signed
                        ld      a,l
                        ld      (UBnKOffset+3),a
                        ld      (UBnKOffset+4),de
.RelativeZ:             ld      iy,UBnKzlo
                        ld      ix,UBnKTargetZPos
                        call    SubDELequAtIXMinusAtIY24Signed
                        ld      a,l
                        ld      (UBnKOffset+6),a
                        ld      (UBnKOffset+7),de
                        ret
;..................................................................................................................................
CreateMissile:          MMUSelectUniverseN  1
                        ld      a,2
                        ld      (UBnKMissileTarget),a               ; load target Data
                        call    UnivSetPlayerMissile                ; .
                        ld          a,$1F
                        ld          (SpeedAddr),a
                        ret

CreateTarget:           MMUSelectUniverseN  2
                        call    UnivInitRuntime
                        call    UnivSetSpawnPosition
                        ret

;----------------------------------------------------------------------------------------------------------------------------------                    
; Display Stats - go for 320 mode to test code
; Left side                         Right Side
;0123456789012345678901234567890123456789
;1Missile
;2     X        Y       Z
;3+FFFF.FF +FFFF.FF +FFFF.FF
;4Matrix    X        Y        Z
;5Side +FFFF.FF +FFFF.FF +FFFF.FF
;6Roof +FFFF.FF +FFFF.FF +FFFF.FF
;7Nose +FFFF.FF +FFFF.FF +FFFF.FF
;8
;9Speed Roll Pitch
;0+FF   +FF  +FF
;1Target
;2     X        Y       Z
;3+FFFF.FF +FFFF.FF +FFFF.FF
;4Dot Product
;5+FFFF
;6Actions
;7
;8
;9
BoilerPlate1:           DB      00 ,01,  "Missile   X        Y        Z",0
BoilerPlate2:           DB      00 ,03,  "Matrix    X        Y        Z",0
BoilerPlate3:           DB      00 ,04,  "Side",0
BoilerPlate4:           DB      00 ,05,  "Roof",0
BoilerPlate5:           DB      00 ,06,  "Nose",0
BoilerPlate6:           DB      00 ,07,  "Accell             Speed",0
BoilerPlate7:           DB      00 ,08,  "Roll               Pitch",0
BoilerPlate8:           DB      00 ,09,  "Target    X        Y        Z",0
BoilerPlate9:           DB      00 ,11,  "Tactics",0
BoilerPlate10:          DB      00, 12,  "Relative  X        Y        Z",0
BoilerPlate11           DB      00 ,14,  "Direction X        Y        Z",0
BoilerPlate12:          DB      00 ,16,  "Dot Product Nose      Roof",0
BoilerPlate13:          DB      00 ,17,  "    Degrees Nose      Roof",0
BoilerPlate14:          DB      00 ,18,  "Actions",0
ActionTextSlow:         DB      00 ,19,  "Slow",0
ActionTextFast:         DB      08 ,19,  "Fast",0
ActionTextRoll:         DB      16 ,19,  "Roll",0
ActionTextPitch:        DB      24 ,19,  "Pitch",0
ActionTextBehind:       DB      00 ,20,  "Behind",0
ActionTextForward:      DB      10 ,20,  "Forward",0
ActionTextNear          DB      00 ,21,  "Near",0
ActionTextFar           DB      10 ,21,  "Far",0
ActionTextHit:          DB      20 ,21,  "Hit",0
ClearTextSlow:          DB      00 ,19,  "    ",0
ClearTextFast:          DB      08 ,19,  "    ",0
ClearTextRoll:          DB      16 ,19,  "    ",0
ClearTextPitch:         DB      24 ,19,  "     ",0
ClearTextBehind:        DB      00 ,20,  "      ",0
ClearTextForward:       DB      10 ,20,  "       ",0
ClearTextHit:           DB      20 ,21,  "   ",0
ClearTextNear           DB      00 ,21,  "    ",0
ClearTextFar            DB      10 ,21,  "   ",0

StatusSlow              DB      0
StatusFast              DB      0
StatusRoll              DB      0
StatusPitch             DB      0
StatusBehind            DB      0
StatusForward           DB      0
StatusNear              DB      0
StatusFar               DB      0
StatusHit               DB      0
;                                         0123456789ABCDEF0123456789AB
XPosX                   equ     $06
XPosY                   equ     $0F
XPosZ                   equ     $18
RowMissle               equ     02
RowMatrix1              equ     04
RowMatrix2              equ     05
RowMatrix3              equ     06
RowAccellSpeed          equ     07
RowPitchRoll            equ     08
RowTarget               equ     10
RowRelative             equ     13
RowDirection            equ     15
RowDotProduct           equ     16
RowDotDegrees           equ     17

DisplayActionStatus:    call    UpdateStatusSlow         
                        call    UpdateStatusFast         
                        call    UpdateStatusRoll         
                        call    UpdateStatusPitch
                        call    UpdateStatusBehind       
                        call    UpdateStatusForward      
                        call    UpdateStatusHit
                        call    UpdateStatusNear
                        call    UpdateStatusFar
                        ret                        

DisplayPosition:        push    de
                        ld      e,XPosX
                        ld      ix,UBnKxlo
                        call    DisplayS24
                        pop     de
                        push    de
                        ld      e,XPosY
                        ld      ix,UBnKylo
                        call    DisplayS24
                        pop     de
                        ld      e,XPosZ
                        ld      ix,UBnKzlo
                        call    DisplayS24
                        ret

DisplayMatrixRow:       push    de
                        ld      e,XPosX
                        push    ix
                        call    DisplayS16
                        pop     ix
                        pop     de
                        push    de
                        ld      e,XPosY
                        inc     ix
                        inc     ix
                        push    ix
                        call    DisplayS16
                        pop     ix
                        pop     de
                        ld      e,XPosZ
                        inc     ix
                        inc     ix
                        call    DisplayS16
                        ret

DisplayRelative:        ld      d,RowRelative
                        ld      e,XPosX
                        ld      ix,UBnKOffset
                        call    DisplayS24
                        ld      d,RowRelative
                        ld      e,XPosY
                        ld      ix,UBnKOffset+3
                        call    DisplayS24
                        ld      d,RowRelative
                        ld      e,XPosZ
                        ld      ix,UBnKOffset+6
                        call    DisplayS24
                        ret

DisplayDirection:       ld      d,RowDirection
                        ld      e,XPosX
                        ld      ix,UBnKDirNormX
                        call    DisplayS08
                        ld      d,RowDirection
                        ld      e,XPosY
                        ld      ix,UBnKDirNormY
                        call    DisplayS08
                        ld      d,RowDirection
                        ld      e,XPosZ
                        ld      ix,UBnKDirNormZ
                        call    DisplayS08
                        ret



DisplayDotProduct:      ld      a,(UBnKDotProductNoseSign)
                        ld      d,RowDotProduct
                        ld      e,XPosY+2
                        call    l1_printSignByte
                        ld      a,(UBnKDotProductRoofSign)
                        ld      d,RowDotProduct
                        ld      e,XPosZ+2
                        call    l1_printSignByte
                        ld      d,RowDotProduct
                        ld      e,XPosY+3
                        ld      ix,UBnKDotProductNose+1
                        call    DisplayU8
                        ld      d,RowDotProduct
                        ld      e,XPosZ+3
                        ld      ix,UBnKDotProductRoof+1
                        call    DisplayU8      

                        ld      a,(UBnKDotProductNoseSign)
                        and     a
                        ld      a,(UBnKDotProductNose+1)
                        jp      p,.PositiveNoseProd
.NegativeNoseProd:      neg          
.PositiveNoseProd:      call    ArcCos
                        ld      d,RowDotDegrees
                        ld      e,XPosY+2
                        cp      $FF
                        jp      z,.NaNNose
                        call    l1_print_u8_hex_at_char
                        jp      .PrintRoofDegrees
.NaNNose:               call    l1_print_u8_nan_at_char
.PrintRoofDegrees:      ld      a,(UBnKDotProductRoofSign)
                        and     a
                        ld      a,(UBnKDotProductRoof+1)
                        jp      p,.PositiveRoofProd
.NegativeRoofProd:      neg
.PositiveRoofProd:      call    ArcCos
                        ld      d,RowDotDegrees
                        ld      e,XPosZ+2
                        cp      $FF
                        jp      z,.NaNRoof
                        call    l1_print_u8_hex_at_char
                        ret
.NaNRoof:               call    l1_print_u8_nan_at_char
                        ret
                        
DisplayMatrix:          ld      d,  RowMatrix1
                        ld      ix, UBnkrotmatSidevX
                        call    DisplayMatrixRow
                        ld      d,  RowMatrix2
                        ld      ix, UBnkrotmatRoofvX
                        call    DisplayMatrixRow
                        ld      d,  RowMatrix3
                        ld      ix, UBnkrotmatNosevX
                        call    DisplayMatrixRow
                        ret
                        
DisplayAccellSpeed:     ld      ix,UBnKAccel
                        ld      d, RowAccellSpeed
                        ld      e,XPosX
                        call    DisplayS8
                        ld      ix,UBnKSpeed
                        ld      d, RowAccellSpeed
                        ld      e,XPosZ
                        call    DisplayS8
                        ret

DisplayRollPitch:       ld      ix,UBnKRotXCounter
                        ld      d, RowPitchRoll
                        ld      e,XPosX
                        call    DisplayS8
                        ld      ix,UBnKRotZCounter
                        ld      d, RowPitchRoll
                        ld      e,XPosZ
                        call    DisplayS8
                        ret

DisplayBoilerLine:      MMUSelectLayer1
                        ld      a,(hl)
                        ld      e,a
                        inc     hl
                        ld      a,(hl)
                        ld      d,a
                        inc     hl
                        call    l1_print_at_char
                        ret

; Display S24 value at address IX at position DE
DisplayS24:             MMUSelectLayer1
                        ld      a,(ix+2)
                        ld      h,a
                        ld      a,(ix+1)
                        ld      l,a
                        ld      a,(ix+0)
                        call    l1_print_s24_hex_at_char
                        ret
                        
DisplayS16:             MMUSelectLayer1
                        ld      a,(ix+1)
                        ld      h,a
                        ld      a,(ix+0)
                        ld      l,a
                        call    l1_print_s16_hex_at_char
                        ret
                        
DisplayS8:              MMUSelectLayer1
                        ld      a,(ix+0)
                        call    l1_print_s8_hex_at_char
                        ret
; As per S8 but sign is a separate lead byte
DisplayS08:             MMUSelectLayer1
                        ld      a,(ix+0)
                        ld      l,a
                        ld      a,(ix+1)
                        ld      h,a
                        call    l1_print_s08_hex_at_char
                        ret

DisplayU8:              MMUSelectLayer1
                        ld      a,(ix+0)
                        call    l1_print_u8_hex_at_char
                        ret

SetStatusSlow:          ld      a,$FF : ld      (StatusSlow),a : ret
SetStatusFast:          ld      a,$FF : ld      (StatusFast),a : ret
SetStatusRoll:          ld      a,$FF : ld      (StatusRoll),a : ret
SetStatusPitch:         ld      a,$FF : ld      (StatusPitch),a : ret
SetStatusBehind:        ld      a,$FF : ld      (StatusBehind),a : ret
SetStatusForward:       ld      a,$FF : ld      (StatusForward),a : ret
SetStatusHit:           ld      a,$FF : ld      (StatusHit),a : ret
SetStatusNear:          ld      a,$FF : ld      (StatusNear),a : ret
SetStatusFar:           ld      a,$FF : ld      (StatusFar),a : ret

ClearStatusSlow:        ld      a,$00 : ld      (StatusSlow),a : ret
ClearStatusFast:        ld      a,$00 : ld      (StatusFast),a : ret
ClearStatusRoll:        ld      a,$00 : ld      (StatusRoll),a : ret
ClearStatusPitch:       ld      a,$00 : ld      (StatusPitch),a : ret
ClearStatusBehind:      ld      a,$00 : ld      (StatusBehind),a : ret
ClearStatusForward:     ld      a,$00 : ld      (StatusForward),a : ret
ClearStatusHit:         ld      a,$00 : ld      (StatusHit),a : ret
ClearStatusNear:        ld      a,$00 : ld      (StatusNear),a : ret
ClearStatusFar:         ld      a,$00 : ld      (StatusFar),a : ret

UpdateStatusSlow:       ld      a,(StatusSlow)
                        and     a
                        jp      z,HideSlow
                        jp      DisplaySlow
                        ; Implicit Return
UpdateStatusFast:       ld      a,(StatusFast)
                        and     a
                        jp      z,HideFast
                        jp      DisplayFast
                        ; Implicit Return
UpdateStatusRoll:       ld      a,(StatusRoll)
                        and     a
                        jp      z,HideRoll
                        jp      DisplayRoll
                        ; Implicit Return
UpdateStatusPitch:      ld      a,(StatusPitch)
                        and     a
                        jp      z,HidePitch
                        jp      DisplayPitch
                        ; Implicit Return
UpdateStatusBehind:     ld      a,(StatusBehind)
                        and     a
                        jp      z,HideBehind
                        jp      DisplayBehind
                        ; Implicit Return
UpdateStatusForward:    ld      a,(StatusForward)
                        and     a
                        jp      z,HideForward
                        jp      DisplayForward
                        ; Implicit Return
UpdateStatusHit:        ld      a,(StatusHit)
                        and     a
                        jp      z,HideHit
                        jp      DisplayHit
                        ; Implicit Return
UpdateStatusNear:       ld      a,(StatusNear)
                        and     a
                        jp      z,HideNear
                        jp      DisplayNear
                        ; Implicit Return
UpdateStatusFar:        ld      a,(StatusFar)
                        and     a
                        jp      z,HideFar
                        jp      DisplayFar
                        ; Implicit Return

DisplaySlow             MMUSelectLayer1
                        ld      hl,ActionTextSlow
                        call    DisplayBoilerLine
                        ret

HideSlow                MMUSelectLayer1
                        ld      hl,ClearTextSlow
                        call    DisplayBoilerLine
                        ret

DisplayFast             MMUSelectLayer1
                        ld      hl,ActionTextFast
                        call    DisplayBoilerLine
                        ret

HideFast                MMUSelectLayer1
                        ld      hl,ClearTextFast
                        call    DisplayBoilerLine
                        ret

DisplayRoll             MMUSelectLayer1
                        ld      hl,ActionTextRoll
                        call    DisplayBoilerLine
                        ret

HideRoll                MMUSelectLayer1
                        ld      hl,ClearTextRoll
                        call    DisplayBoilerLine
                        ret

DisplayPitch            MMUSelectLayer1
                        ld      hl,ActionTextPitch
                        call    DisplayBoilerLine
                        ret

HidePitch               MMUSelectLayer1
                        ld      hl,ClearTextPitch
                        call    DisplayBoilerLine
                        ret

DisplayBehind           MMUSelectLayer1
                        ld      hl,ActionTextBehind
                        call    DisplayBoilerLine
                        ret

HideBehind              MMUSelectLayer1
                        ld      hl,ClearTextBehind
                        call    DisplayBoilerLine
                        ret                      

DisplayForward          MMUSelectLayer1
                        ld      hl,ActionTextForward
                        call    DisplayBoilerLine
                        ret

HideForward             MMUSelectLayer1
                        ld      hl,ClearTextForward
                        call    DisplayBoilerLine
                        ret   

DisplayHit:             MMUSelectLayer1
                        ld      hl,ActionTextHit
                        call    DisplayBoilerLine
                        ret

HideHit:                MMUSelectLayer1
                        ld      hl,ClearTextHit
                        call    DisplayBoilerLine
                        ret   
                        
DisplayNear:            MMUSelectLayer1
                        ld      hl,ActionTextNear
                        call    DisplayBoilerLine
                        ret

HideNear:               MMUSelectLayer1
                        ld      hl,ClearTextNear
                        call    DisplayBoilerLine
                        ret   
                        
DisplayFar:             MMUSelectLayer1
                        ld      hl,ActionTextFar
                        call    DisplayBoilerLine
                        ret

HideFar:                MMUSelectLayer1
                        ld      hl,ClearTextFar
                        call    DisplayBoilerLine
                        ret   
                        
DisplayBoiler:          ld      hl, BoilerPlate1
                        call    DisplayBoilerLine
                        ld      hl, BoilerPlate2
                        call    DisplayBoilerLine
                        ld      hl, BoilerPlate3
                        call    DisplayBoilerLine
                        ld      hl, BoilerPlate4
                        call    DisplayBoilerLine
                        ld      hl, BoilerPlate5
                        call    DisplayBoilerLine
                        ld      hl, BoilerPlate6
                        call    DisplayBoilerLine
                        ld      hl, BoilerPlate7
                        call    DisplayBoilerLine
                        ld      hl, BoilerPlate8
                        call    DisplayBoilerLine
                        ld      hl, BoilerPlate9
                        call    DisplayBoilerLine
                        ld      hl, BoilerPlate10
                        call    DisplayBoilerLine
                        ld      hl, BoilerPlate11
                        call    DisplayBoilerLine
                        ld      hl, BoilerPlate12
                        call    DisplayBoilerLine
                        ld      hl, BoilerPlate13
                        call    DisplayBoilerLine                        
                        ld      hl, BoilerPlate14
                        call    DisplayBoilerLine                        
                        ret
                        
;----------------------------------------------------------------------------------------------------------------------------------                    
; Set initial ship position as X,Y,Z 000,000,03B4
SetInitialShipPosition: ld      hl,$0000
                        ld      (UBnKxlo),hl
                        ld      hl,$0000
                        ld      (UBnKylo),hl
                        ld      hl,$03B4
                        ld      (UBnKzlo),hl
                        xor     a
                        ld      (UBnKxsgn),a
                        ld      (UBnKysgn),a
                        ld      (UBnKzsgn),a
                        call	InitialiseOrientation            ;#00;
                        ld      a,1
                        ld      (DELTA),a
                        ld      hl,4
                        ld      (DELTA4),hl
                        ret    
                        
; Use bank 0 as source and bank 7 as write target
ResetUniv:              MMUSelectCpySrcN BankUNIVDATA0	         ; master universe def in bank 0
                        ld		a,1             				 ; we can read bank 0 as if it was rom
                        ld		b,12
.ResetCopyLoop:         push	bc,,af
                        MMUSelectUniverseA			             ; copy from bank 0 to 71 to 12
                        ld		hl,UniverseBankAddr
                        ld		de,dmaCopySrcAddr
                        ld		bc,UnivBankSize
                        call	memcopy_dma
                        pop		bc,,af
                        ld      d,a
                        add     "A"
                        ld      (StartOfUnivN),a
                        ld      a,d
                        inc		a
                        djnz	.ResetCopyLoop
                        ret

            DISPLAY "../../Maths/Utilities/XX12EquNodeDotOrientation.asm"
            include "../../Maths/Utilities/XX12EquNodeDotOrientation.asm"
            DISPLAY "../../ModelRender/CopyXX12ToXX15.asm"
            include "../../ModelRender/CopyXX12ToXX15.asm"	
            DISPLAY "../../Maths/Utilities/ScaleXX16Matrix197.asm"
            include "../../Maths/Utilities/ScaleXX16Matrix197.asm"
		    
            ;nclude "../../Universe/StarDust/StarRoutines.asm"
            
            INCLUDE	"../../Hardware/memfill_dma.asm"
            INCLUDE	"../../Hardware/memcopy_dma.asm"
XX12PVarQ			DW 0
XX12PVarR			DW 0
XX12PVarS			DW 0
XX12PVarResult1		DW 0
XX12PVarResult2		DW 0
XX12PVarResult3		DW 0
XX12PVarSign2		DB 0
XX12PVarSign1		DB 0								; Note reversed so BC can do a little endian fetch
XX12PVarSign3		DB 0
    INCLUDE "../../Variables/constant_equates.asm"
    INCLUDE "../../Variables/general_variables.asm"
    INCLUDE "../../Variables/UniverseSlotRoutines.asm"
    INCLUDE "../../Variables/random_number.asm"
    INCLUDE "../../Maths/asm_multiply.asm"
    INCLUDE "../../Maths/asm_square.asm"
    INCLUDE "../../Maths/asm_sine.asm"
    INCLUDE "../../Maths/asm_sqrt.asm"
    INCLUDE "../../Maths/asm_arctan.asm"
    INCLUDE "../../Maths/asm_arccos.asm"
    INCLUDE "../../Maths/SineTable.asm"
    INCLUDE "../../Maths/ArcTanTable.asm"
    INCLUDE "../../Maths/ArcCosTable.asm"
    INCLUDE "../../Maths/negate16.asm"
    INCLUDE "../../Maths/asm_divide.asm"
    INCLUDE "../../Maths/asm_unitvector.asm"
    INCLUDE "../../Maths/compare16.asm"
    INCLUDE "../../Maths/normalise96.asm"
    INCLUDE "../../Maths/binary_to_decimal.asm"
    INCLUDE "../../Maths/asm_AequAdivQmul96.asm"
    INCLUDE "../../Maths/Utilities/AequAmulQdiv256-FMLTU.asm"
    INCLUDE "../../Maths/Utilities/APequQmulA-MULT1.asm"
    INCLUDE "../../Maths/Utilities/badd_ll38.asm"
    include "../../Universe/Ships/CopyRotMattoXX15.asm"
    include "../../Universe/Ships/CopyXX15toRotMat.asm"
    INCLUDE "../../Maths/asm_tidy.asm"
    INCLUDE "../../Menus/common_menu.asm"
MainNonBankedCodeEnd:
    DISPLAY "Main Non Banked Code Ends at ",$

; Bank 58  ------------------------------------------------------------------------------------------------------------------------
    SLOT    LAYER1Addr
    PAGE    BankLAYER1
    ORG     LAYER1Addr, BankLAYER1
Layer1Header:  DB "Bank L1 Utils--"

    INCLUDE "../../Layer1Graphics/layer1_attr_utils.asm"
    INCLUDE "../../Layer1Graphics/layer1_cls.asm"
    INCLUDE "../../Layer1Graphics/layer1_print_at.asm"
    DISPLAY "Bank ",BankLAYER1," - Bytes free ",/D, $2000 - ($-LAYER1Addr), " - BankLAYER1"

    DISPLAY "Bank ",BankShipModels1," - Bytes free ",/D, $2000 - ($-ShipModelsAddr), " - BankShipModels1"
; Bank 70  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    UniverseBankAddr
                    PAGE    BankUNIVDATA0
                    ORG	    UniverseBankAddr,BankUNIVDATA0
                    INCLUDE "../../Tests/Vectors/univ_ship_data.asm"
                    DISPLAY "Sizing Bank ",BankUNIVDATA0," - Start ",UniverseBankAddr," End - ",$, "- Universe Data A"
                    DISPLAY "Bank ",BankUNIVDATA0," - Bytes free ",/D, $2000 - ($-UniverseBankAddr), "- Universe Data A"
                    ASSERT $-UniverseBankAddr <8912, Bank code leaks over 8K boundary
; Bank 99  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    MathsTablesAddr
                    PAGE    BankMathsTables
                    ORG     MathsTablesAddr,BankMathsTables
                    INCLUDE "../../Maths/logmaths.asm"
                    INCLUDE "../../Tables/antilogtable.asm"
                    INCLUDE "../../Tables/logtable.asm"
                    DISPLAY "Bank ",BankMathsTables," - Bytes free ",/D, $2000 - ($-MathsTablesAddr), " - BankMathsTables"
                    ASSERT $-MathsTablesAddr <8912, Bank code leaks over 8K boundary
; Bank 100  -----------------------------------------------------------------------------------------------------------------------
                    SLOT    KeyboardAddr
                    PAGE    BankKeyboard
                    ORG SoundAddr, BankKeyboard             
                    INCLUDE "../../Hardware/keyboard.asm"
                    DISPLAY "Keyboard ",BankKeyboard," - Bytes free ",/D, $2000 - ($-KeyboardAddr), " - BankKeyboard"
                    ASSERT $-KeyboardAddr <8912, Bank code leaks over 8K boundary
 ; Bank 102  -----------------------------------------------------------------------------------------------------------------------
                    SLOT    MathsBankedFnsAddr
                    PAGE    BankMathsBankedFns
                    ORG     MathsBankedFnsAddr,BankMathsBankedFns
                    INCLUDE "../../Maths/MathsBankedFns.asm"
                    DISPLAY "Bank ",MathsBankedFnsAddr," - Bytes free ",/D, $2000 - ($-MathsBankedFnsAddr), " - BankMathsBankedAdd"
                    ASSERT $-MathsBankedFnsAddr <8912, Bank code leaks over 8K boundary
    
    SAVENEX OPEN "VecTest.nex", EliteNextStartup , TopOfStack
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    DISPLAY "Main Non Banked Code End ", MainNonBankedCodeEnd , " Bytes free ", 0B000H - MainNonBankedCodeEnd
    ASSERT MainNonBankedCodeEnd < 0B000H, Program code leaks intot interrup vector table
    