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
                        call    doRandom                                                ; redo the seeds every frame
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
; Replacement for MVEIT routine
UpdateUniverseObjects:  call    LoadTargetData
                        call    CalculateRelativePos
                        
                        MMUSelectUniverseN      1
                        ld      a,3
                        ld      (UBnKAccel),a
                        call    ApplyShipRollAndPitch
                        call    ApplyShipSpeed
                        call    UpdateSpeedAndPitch                             ; update based on rates of speed roll and pitch accelleration/decelleration
                        ret

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
                        
Plus10:                 DB 10,0,0
Minus10:                DB 10,0,$80

Plus20:                 DB 20,0,0
Minus20:                DB 20,0,$80

SaveUBNK:               DS 3*3

SavePosition:           push    hl,,de,,bc,,af
                        ld      a,(CurrentShipUniv)
                        cp      2
                        jr      nz,.DoneSave
                        ;break
                        ld      hl, UBnKxlo
                        ld      de, SaveUBNK
                        ld      bc, 3*3
                        ldir
                        ld      a,0
                        ld      (UBnKyhi)  ,a
                        ld      (UBnKxhi)  ,a
                        ld      (UBnKzhi)  ,a                        
                        ld      (UBnKxsgn) ,a
                        ld      (UBnKysgn) ,a
                        ld      (UBnKzhi)  ,a
                        ld      (UBnKzsgn) ,a
                        ld      a, $5
                        ld      (UBnKylo)  ,a
                        ld      a, $5
                        ld      (UBnKxlo)  ,a
                        ld      a, $6E
                        ld      (UBnKzlo)  ,a
.DoneSave:              pop     hl,,de,,bc,,af
                        ret
                        
RestorePosition:        push    hl,,de,,bc,,af
                        ld      a,(CurrentShipUniv)
                        cp      2
                        jr      nz,.DoneSave
                        ;break
                        ld      hl, SaveUBNK
                        ld      de, UBnKxlo
                        ld      bc, 3*3
                        ldir
.DoneSave:              pop     hl,,de,,bc,,af
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
BoilerPlate12:          DB      00 ,16,  "Dot Product",0
BoilerPlate13:          DB      00 ,17,  "Actions",0
ActionTextSlow:         DB      00 ,18,  "Slow",0
ActionTextFast:         DB      06 ,18,  "Fast",0
ActionTextTurn:         DB      12 ,18,  "Turn",0
ActionTextBehind:       DB      00 ,19,  "Behind",0
ActionTextForward:      DB      10 ,19,  "Forward",0
ActionTextHit:          DB      20 ,20,  "Hit",0
ClearTextSlow:          DB      00 ,18,  "    ",0
ClearTextFast:          DB      06 ,18,  "    ",0
ClearTextTurn:          DB      12 ,18,  "    ",0
ClearTextBehind:        DB      00 ,19,  "      ",0
ClearTextForward:       DB      10 ,19,  "       ",0
ClearTextHit:           DB      20 ,20,  "   ",0

StatusSlow              DB      0
StatusFast              DB      0
StatusTurn              DB      0
StatusBehind            DB      0
StatusForward           DB      0
StatusHit               DB      0
;                                         0123456789ABCDEF0123456789AB
XPosX                   equ     $06 * 8
XPosY                   equ     $0F * 8
XPosZ                   equ     $18 * 8
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

DisplayActionStatus:    call    UpdateStatusSlow         
                        call    UpdateStatusFast         
                        call    UpdateStatusTurn         
                        call    UpdateStatusBehind       
                        call    UpdateStatusForward      
                        call    UpdateStatusHit
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
                        ld      ix,UBnKDirection
                        call    DisplayS16
                        ld      d,RowDirection
                        ld      e,XPosY
                        ld      ix,UBnKDirection+3
                        call    DisplayS16
                        ld      d,RowDirection
                        ld      e,XPosZ
                        ld      ix,UBnKDirection+6
                        call    DisplayS16
                        ret

DisplayDotProduct:      ld      d,RowDotProduct
                        ld      e,XPosY
                        ld      ix,UBnKDotProduct
                        call    DisplayS8
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
                        call    DisplayU8
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

DisplayU8:              MMUSelectLayer1
                        ld      a,(ix+0)
                        call    l1_print_u8_hex_at_char
                        ret

SetStatusSlow:          ld      a,$FF : ld      (StatusSlow),a : ret
SetStatusFast:          ld      a,$FF : ld      (StatusFast),a : ret
SetStatusTurn:          ld      a,$FF : ld      (StatusTurn),a : ret
SetStatusBehind:        ld      a,$FF : ld      (StatusBehind),a : ret
SetStatusForward:       ld      a,$FF : ld      (StatusForward),a : ret
SetStatusHit:           ld      a,$FF : ld      (HideHit),a : ret

ClearStatusSlow:        ld      a,$00 : ld      (StatusSlow),a : ret
ClearStatusFast:        ld      a,$00 : ld      (StatusFast),a : ret
ClearStatusTurn:        ld      a,$00 : ld      (StatusTurn),a : ret
ClearStatusBehind:      ld      a,$00 : ld      (StatusBehind),a : ret
ClearStatusForward:     ld      a,$00 : ld      (StatusForward),a : ret
ClearStatusHit:         ld      a,$00 : ld      (HideHit),a : ret

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
UpdateStatusTurn:       ld      a,(StatusTurn)
                        and     a
                        jp      z,HideTurn
                        jp      DisplayTurn
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

DisplayTurn             MMUSelectLayer1
                        ld      hl,ActionTextTurn
                        call    DisplayBoilerLine
                        ret

HideTurn                MMUSelectLayer1
                        ld      hl,ClearTextTurn
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
    ;NCLUDE "../../Variables/general_variablesRoutines.asm"
    INCLUDE "../../Variables/UniverseSlotRoutines.asm"
    ;NCLUDE "../../Variables/EquipmentVariables.asm"
    INCLUDE "../../Variables/random_number.asm"
;INCLUDE "Tables/inwk_table.asm" This is no longer needed as we will write to univer object bank
; Include all maths libraries to test assembly   
    ;INCLUDE "../../Maths/asm_add.asm"
    ;INCLUDE "../../Maths/asm_subtract.asm"
    ;NCLUDE "../../Maths/DIVD3B2.asm"
    INCLUDE "../../Maths/asm_multiply.asm"
    INCLUDE "../../Maths/asm_square.asm"
    INCLUDE "../../Maths/asm_sine.asm"
    INCLUDE "../../Maths/asm_sqrt.asm"
    INCLUDE "../../Maths/asm_arctan.asm"
    INCLUDE "../../Maths/SineTable.asm"
    INCLUDE "../../Maths/ArcTanTable.asm"
    INCLUDE "../../Maths/negate16.asm"
    INCLUDE "../../Maths/asm_divide.asm"
    INCLUDE "../../Maths/asm_unitvector.asm"
    INCLUDE "../../Maths/compare16.asm"
    INCLUDE "../../Maths/normalise96.asm"
    INCLUDE "../../Maths/binary_to_decimal.asm"
    INCLUDE "../../Maths/asm_AequAdivQmul96.asm" ; AequAdivDmul96
    INCLUDE "../../Maths/Utilities/AequAmulQdiv256-FMLTU.asm"
    ;INCLUDE "../../Maths/Utilities/PRequSpeedDivZZdiv8-DV42-DV42IYH.asm"
    INCLUDE "../../Maths/Utilities/APequQmulA-MULT1.asm"
    INCLUDE "../../Maths/Utilities/badd_ll38.asm"
 ;   INCLUDE "../../Maths/Utilities/RequAmul256divQ-BFRDIV.asm"
 ;   INCLUDE "../../Maths/Utilities/RequAdivQ-LL61.asm"
 ;   INCLUDE "../../Maths/Utilities/RSequQmulA-MULT12.asm"
    include "../../Universe/Ships/CopyRotMattoXX15.asm"
    include "../../Universe/Ships/CopyXX15toRotMat.asm"
    INCLUDE "../../Maths/asm_tidy.asm"
 ;   INCLUDE "../../Maths/Utilities/LL28AequAmul256DivD.asm"    
 ;   INCLUDE "../../Maths/Utilities/XAequMinusXAPplusRSdiv96-TIS1.asm"
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
    