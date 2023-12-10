                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"
                DISPLAY "3D Test Code"
                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"

    DEVICE ZXSPECTRUMNEXT
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION


    DEFINE  SHIP_DRAW_FULL_SCREEN 1
 CSPECTMAP 3DTest.map
 OPT --zxnext=cspect --syntax=a --reversepop
;-- Key Definitions                        
;   Q/A pitch       O/P roll        W/A Thrust
;   T/G ship pitch, F/H ship roll   U/J Ship Thrust
;   P   Cycle through ships
;----------------------------------------------------------------------------------------------------------------------------------
; Game Defines
;----------------------------------------------------------------------------------------------------------------------------------
; Colour Defines
                        INCLUDE "../../Hardware/L2ColourDefines.asm"
                        INCLUDE "../../Hardware/L1ColourDefines.asm"
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

MessageAt:              MACRO   x,y,message
                        MMUSelectLayer1
                        ld      d,y
                        ld      e,x
                        ld      hl,message
                        call    l1_print_at_wrap
                        ENDM
                        
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
.InitialiseLayerOrder:  
                        DISPLAY "Starting Assembly At ", EliteNextStartup
                        ; "STARTUP"
                        ; Make sure  rom is in page 0 during load
                        MMUSelectLayer2
                        call        asm_disable_l2_readwrite
                        MMUSelectROMS
                        MMUSelectLayer1
                        call		l1_cls
                        ld			a,7
                        call		l1_attr_cls_to_a
                        SetBorder   $FF
.InitialiseL2:          MMUSelectLayer2
                        call 		l2_initialise
                        call        asm_l2_double_buffer_on
                        call        l2_cls     
                        call        l2_flip_buffers
                        call        l2_cls                         
.InitialisingMessage:   MMUSelectUniverseN  0
InitialiseMainLoop:     call        ClearUnivSlotList
                        call        SelectShip
                        MMUSelectKeyboard
                        call        init_keyboard
                        ZeroA
                        ld          (JSTX),a
                        ld          (JSTY),a
                        jp          MainLoop
TestNormalise:          MMUSelectMathsBankedFns
                        ld          ix,TestVec1
                        call        NormaliseIXVector
                        ld          ix,TestVec2
                        call        NormaliseIXVector
                        ld          ix,TestVec3
                        call        NormaliseIXVector
                        ld          ix,TestVec4
                        call        NormaliseIXVector
                        ld          ix,TestVec5
                        call        NormaliseIXVector
                        ld          ix,TestVec6
                        call        NormaliseIXVector
.SpinKeyboard:          break
                        jp          TestTidy
TestVec1:               DW  $6000, $0000, $0000, $0, $0, $0, $0, $0
TestVec2:               DW  $3000, $2000, $0000, $0, $0, $0, $0, $0
TestVec3:               DW  $0000, $0000, $E000, $0, $0, $0, $0, $0
TestVec4:               DW  $6000, $6000, $0000, $0, $0, $0, $0, $0
TestVec5:               DW  $0000, $0000, $1000, $0, $0, $0, $0, $0
TestVec6:               DW  $3450, $2450, $3E00, $0, $0, $0, $0, $0
TestTidy:               MMUSelectMathsBankedFns
                        MMUSelectUniverseN 0
                        ld          hl,TestMatrix1: ld de, UBnkrotmatSidevX : ld bc, 2 * 9 : ldir
                        call        TidyVectorsIX
                        break
                        ld          hl,TestMatrix2: ld de, UBnkrotmatSidevX : ld bc, 2 * 9 : ldir
                        call        TidyVectorsIX
                        break
                        ld          hl,TestMatrix3: ld de, UBnkrotmatSidevX : ld bc, 2 * 9 : ldir
                        call        TidyVectorsIX
                        break
                        ld          hl,TestMatrix4: ld de, UBnkrotmatSidevX : ld bc, 2 * 9 : ldir
                        call        TidyVectorsIX
                        break
                        ld          hl,TestMatrix5: ld de, UBnkrotmatSidevX : ld bc, 2 * 9 : ldir
                        call        TidyVectorsIX
                        break
                        ld          hl,TestMatrix6: ld de, UBnkrotmatSidevX : ld bc, 2 * 9 : ldir
                        call        TidyVectorsIX
                        break
                        jp          MainLoop
                        ;   SIDEV                ROOFV                NOSEV
TestMatrix1:            DW  $0000, $0000, $E000, $0000, $6000, $0000, $6000, $0000, $0000 
TestMatrix2:            DW  $0000, $0000, $E000, $0000, $5EEC, $0000, $6000, $0000, $0000 
TestMatrix3:            DW  $0000, $0000, $E000, $0000, $5EEC, $0000, $3000, $3000, $3000 
TestMatrix4:            DW  $0000, $0000, $E000, $0000, $6000, $0000, $5000, $0000, $0000 
TestMatrix5:            DW  $0000, $0000, $E000, $0000, $5500, $0000, $6000, $0000, $0000 
TestMatrix6:            DW  $0000, $0000, $E100, $0000, $6000, $0000, $6000, $0000, $0000 
;...................................................................................................................................
MainLoop:	            MMUSelectMathsBankedFns                                         ; make sure we are in maths routines in case a save paged out
                        call    doRandom                                                ; redo the seeds every frame
;.. Check if keyboard scanning is allowed by screen. If this is set then skip all keyboard and AI..................................
InputBlockerCheck:      MMUSelectKeyboard
                        call    scan_keyboard
;-- Key Definitions                        
; Player Pitcn and Roll
;   Q/A pitch       O/P roll        W/A Thrust
                        ld      a,VK_Q
                        call    is_vkey_held
                        call    nz, PressedPitchPlus
                        
                        ld      a,VK_A
                        call    is_vkey_held
                        call    nz, PressedPitchMinus

                        ld      a,VK_O
                        call    is_vkey_held
                        call    nz, PressedRollPlus
                        
                        ld      a,VK_P
                        call    is_vkey_held
                        call    nz, PressedRollMinus
   
;   N   Cycle through ships
                        ld      a,VK_N
                        call    is_vkey_pressed
                        call    z, SelectShip
; Tidy and Normalise Vector    
                        ld      a,VK_V
                        call    is_vkey_pressed
                        call    z, TidyVectorsIX
; Ship Pitch and Roll T/G ship pitch, F/H ship roll   U/J Ship Thrust
                        MMUSelectKeyboard
                        ld      a,VK_T
                        call    is_vkey_held
                        call    nz, PressedSPitchPlus
                        
                        ld      a,VK_G
                        call    is_vkey_held
                        call    nz, PressedSPitchMinus

                        ld      a,VK_F
                        call    is_vkey_held
                        call    nz, PressedSRollPlus
                        
                        ld      a,VK_H
                        call    is_vkey_held
                        call    nz, PressedSRollMinus

; PanKeys 1 + y  2 -y  3 +x 4 -x 5 +z 6 -z                     
                        ld      a,VK_5
                        call    is_vkey_held
                        call    nz, PressedZPlus

                        ld      a,VK_6
                        call    is_vkey_held
                        call    nz, PressedZMinus

                        ld      a,VK_3
                        call    is_vkey_held
                        call    nz, PressedXPlus

                        ld      a,VK_4
                        call    is_vkey_held
                        call    nz, PressedXMinus

                        ld      a,VK_1
                        call    is_vkey_held
                        call    nz, PressedYPlus

                        ld      a,VK_2
                        call    is_vkey_held
                        call    nz, PressedYMinus                        
;.. Update values based on movekey keys, may likley need damping as this coudl be very fast
UpdateShipsControl:     call    UpdateUniverseObjects
.JustViewPortCLS:       MMUSelectLayer2
                        call    l2_cls
;.. Render Ship ...................................................................................................................
DrawForwardsShips:
DrawShip:               xor     a
.DrawShipLoop:          ld      (CurrentShipUniv),a
                        call    GetTypeAtSlotA
.SelectShipToDraw:      MMUSelectUniverseN 0
.ProcessUnivShip:       call    ProcessShip          ; The whole explosion logic is now encapsulated in process ship ;TODO TUNE THIS   ;; call    ProcessUnivShip
;.. Flip Buffer ...................................................................................................................
DoubleBufferCheck:      MMUSelectLayer2
                        call    l2_flip_buffers
                        jp MainLoop
;.. Keyboard Routines .............................................................................................................
PressedZPlus:           MMUSelectUniverseN 0
                        ld      ix,UBnKzlo
                        ld      iy,Plus20
                        MMUSelectMathsBankedFns : call    AddAtIXtoAtIY24Signed
                        ret

PressedZMinus:          MMUSelectUniverseN 0
                        ld      ix,UBnKzlo
                        ld      iy,Minus20
                        MMUSelectMathsBankedFns : call    AddAtIXtoAtIY24Signed
                        ret
                        
PressedXPlus:           MMUSelectUniverseN 0
                        ld      ix,UBnKxlo
                        ld      iy,Plus20
                        MMUSelectMathsBankedFns : call    AddAtIXtoAtIY24Signed
                        ret

PressedXMinus:          MMUSelectUniverseN 0
                        ld      ix,UBnKxlo
                        ld      iy,Minus20
                        MMUSelectMathsBankedFns : call    AddAtIXtoAtIY24Signed
                        ret

PressedYPlus:           MMUSelectUniverseN 0
                        ld      ix,UBnKylo
                        ld      iy,Plus20
                        MMUSelectMathsBankedFns : call    AddAtIXtoAtIY24Signed
                        ret

PressedYMinus:          MMUSelectUniverseN 0
                        ld      ix,UBnKylo
                        ld      iy,Minus20
                        MMUSelectMathsBankedFns : call    AddAtIXtoAtIY24Signed
                        ret

PressedSPitchPlus:      MMUSelectUniverseN 0
                        ld      a,10
                        ld      (UBnKRotZCounter),a
                        ret

PressedSPitchMinus:     MMUSelectUniverseN 0
                        ld      a,$80+10
                        ld      (UBnKRotZCounter),a
                        ret

PressedSRollPlus:       MMUSelectUniverseN 0
                        ld      a,10
                        ld      (UBnKRotXCounter),a
                        ret

PressedSRollMinus:      MMUSelectUniverseN 0
                        ld      a,$80+10
                        ld      (UBnKRotXCounter),a
                        ret
                        
PressedPitchPlus:       MMUSelectUniverseN 0
                        ld      a,20
                        ld      (JSTY),a
                        call    draw_front_calc_beta
                        ret

PressedPitchMinus:      MMUSelectUniverseN 0
                        ld      a,-20
                        ld      (JSTY),a
                        call    draw_front_calc_beta
                        ret

PressedRollPlus:        MMUSelectUniverseN 0
                        ld      a,60
                        ld      (JSTX),a
                        call    draw_front_calc_alpha
                        ret

PressedRollMinus:       MMUSelectUniverseN 0
                        ld      a,-60
                        ld      (JSTX),a
                        call    draw_front_calc_alpha
                        ret                        
                        
draw_front_calc_alpha:  ld      b,a
                        and     $80
                        ld      (ALP2),a                            ; set sign 
                        ld      c,a                                 ; save sign
                        xor     $80
                        ld      (ALP2FLIP),a                        ; and oppsite sign
                        ld      a,(JSTX)
                        test    $80
                        jr      z,  .PositiveRoll
.NegativeRoll:          neg
.PositiveRoll           srl     a                                   ; divide sign by 4
                        srl     a                                  
                        cp      8
                        jr      c,.NotIncreasedDamp                 ; if a < 8 divide by 2 again
.IncreasedDamp          srl     a
.NotIncreasedDamp:      ld      (ALP1),a
                        or      c
                        ld      (ALPHA),a                           ; a = signed bit alph1
                        ret
                        
; Do the same for pitch                        
draw_front_calc_beta:   ld      b,a
                        and     $80
                        ld      (BET2),a                            ; set sign 
                        ld      c,a                                 ; save sign
                        xor     $80
                        ld      (BET2FLIP),a                        ; and oppsite sign
                        ld      a,(JSTY)
                        test    $80
                        jr      z,  .PositivePitch
.NegativePitch:         neg
.PositivePitch:         srl     a                                   ; divide sign by 4
                        srl     a                                  
                        cp      8
                        jr      c,.NotIncreasedDamp                 ; if a < 8 divide by 2 again
.IncreasedDamp          srl     a
.NotIncreasedDamp:      ld      (BET1),a
                        or      c
                        ld      (BETA),a                            ; a = signed bit bet1
                        ret
                        
;..Update Universe Objects.........................................................................................................
;..................................................................................................................................                        
;                           DEFINE ROTATIONDEBUG 1
;                           DEFINE CLIPDEBUG 1
CurrentShipUniv:        DB      0
;..................................................................................................................................                        
; if ship is destroyed or exploding then z flag is clear, else z flag is set
;..................................................................................................................................                        
; Replacement for MVEIT routine
UpdateUniverseObjects:  xor     a
                        ld      (SelectedUniverseSlot),a
                        call    GetTypeAtSlotA
                        xor     a
                        MMUSelectUniverseA                                      ; and we apply roll and pitch
.ProperUpdate:          call    ApplyMyRollAndPitchTest
;call    ApplyMyRollAndPitch24Bit                             ; todo , make all 4 of these 1 call
                        ld      a,(UBnKRotZCounter)
                        cp      0
                        call    ApplyShipRollAndPitch
                        call    ApplyShipSpeed
                        call    UpdateSpeedAndPitch                             ; update based on rates of speed roll and pitch accelleration/decelleration
.TotalDampen:           ld      a,0
                        ld      (UBnKRotZCounter),a             ; no pitch
                        ld      (UBnKRotXCounter),a                              
                        ld      (JSTX),a
                        ld      (JSTY),a
                        call    draw_front_calc_alpha
                        call    draw_front_calc_beta                        
                        ret
;..................................................................................................................................
ApplyMyRollAndPitchTest:ld      a,(ALPHA)                   ; no roll or pitch, no calc needed
.CheckForRoll:          and		a
						call	nz,Test_Roll
.CheckForPitch:			ld		a,(BETA)
						and		a
						call	nz,Test_Pitch
.ApplySpeed:            ld      a,(DELTA)                   ; BCH = - Delta
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
                        ld      a,(ALPHA)
                        ld      hl,BETA
                        or      (hl)
                        ret     z
                        ld      ix,UBnkrotmatSidevX
                        call    ApplyRollAndPitchToIX
                        ld      ix,UBnkrotmatRoofvX
                        call    ApplyRollAndPitchToIX
                        ld      ix,UBnkrotmatNosevX
                        call    ApplyRollAndPitchToIX
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
; Planet version of pitch and roll is a 24 bit calculation 1 bit sign + 23 bit value
; Need to write a test routine for roll and pitchs
TestAlphaMulX            DB $00,$00, $00, $00
TestAlphaMulY            DB $00,$00, $00, $00
TestAlphaMulZ            DB $00,$00, $00, $00
TestBetaMulZ             DB $00,$00, $00, $00
TestBetaMulY             DB $00,$00, $00, $00
TestK2                   DS 3
                        
Test_Roll:				ld      a,(ALPHA)                   ; get roll value
						and 	$7F
						ld      d,a                         ; .
						ld      a,(UBnKylo)                ; HLE = x sgn, hi, lo
						ld      e,a                         ; .
						ld      hl,(UBnKyhi)               ; .
						call    mulHLEbyDSigned             ; DELC = x * alpha, so DEL = X * -alpha / 256 
						ld		a,l
						ld		(TestAlphaMulY),a			; save result
						ld		(TestAlphaMulY+1),de		; save result
						ld      a,(ALPHA)                   ; get roll value
						and 	$7F
						ld      d,a                         ; .
						ld      a,(UBnKxlo)                ; HLE = x sgn, hi, lo
						ld      e,a                         ; .
						ld      hl,(UBnKxhi)               ; .
						call    mulHLEbyDSigned             ; DELC = x * alpha, so DEL = X * -alpha / 256 
						ld		a,l
						ld		(TestAlphaMulX),a			; save result
						ld		(TestAlphaMulX+1),de		; save result							
						ld		a,(ALPHA)
						and		$80
						jp		z,.RollingRight
.RollingLeft:			ld		ix,UBnKxlo
						ld		iy,TestAlphaMulY
						call	AddAtIXtoAtIY24Signed
						ld		ix,UBnKylo
						ld		iy,TestAlphaMulX
						call	SubAtIXtoAtIY24Signed
						ret
.RollingRight:			ld		ix,UBnKxlo
						ld		iy,TestAlphaMulY
						call	SubAtIXtoAtIY24Signed
						ld		ix,UBnKylo
						ld		iy,TestAlphaMulX
						call	AddAtIXtoAtIY24Signed
						ret

Test_Pitch:				ld      a,(BETA)                   ; get roll value
						and 	$7F
						ld      d,a                         ; .
						ld      a,(UBnKylo)                ; HLE = x sgn, hi, lo
						ld      e,a                         ; .
						ld      hl,(UBnKyhi)               ; .
						call    mulHLEbyDSigned             ; DELC = x * alpha, so DEL = X * -alpha / 256 
						ld		a,l
						ld		(TestBetaMulY),a			; save result
						ld		(TestBetaMulY+1),de		; save result
						ld      a,(BETA)                   ; get roll value
						and 	$7F
						ld      d,a                         ; .
						ld      a,(UBnKzlo)                ; HLE = x sgn, hi, lo
						ld      e,a                         ; .
						ld      hl,(UBnKzhi)               ; .
						call    mulHLEbyDSigned             ; DELC = x * alpha, so DEL = X * -alpha / 256 
						ld		a,l
						ld		(TestBetaMulZ),a			; save result
						ld		(TestBetaMulZ+1),de		; save result							
						ld		a,(BETA)
						and		$80
						jp		z,.Climbing
.Diving:				ld		ix,UBnKylo
						ld		iy,TestBetaMulZ
						call	AddAtIXtoAtIY24Signed
						ld		ix,UBnKzlo
						ld		iy,TestBetaMulY
						call	SubAtIXtoAtIY24Signed
						ret
.Climbing:		     	ld		ix,UBnKylo
						ld		iy,TestBetaMulZ
						call	SubAtIXtoAtIY24Signed
						ld		ix,UBnKzlo
						ld		iy,TestBetaMulY
						call	AddAtIXtoAtIY24Signed	
						ret                        
;..................................................................................................................................

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
                         
currentDemoShip:        DB      0;$12 ; 13 - corirollis 


SelectShip:             MMUSelectUniverseN  0
                        ld      b,0
                        MMUSelectShipBank1
                        ld      iyh, 1
.SelectRandom:          ld      a,(currentDemoShip)
                        ld      iyl,a
                        call    GetShipBankId                       ; find actual memory location of data
                        MMUSelectShipBankA
                        ld      a,b
                        call    CopyShipToUniverse
                        ld      a,(ShipTypeAddr)
                        ld      a,1                                 ; slot 1, iyh and iyl already set
                        call    UnivInitRuntime                       
                        call    UnivSetDemoPostion
                        ld      a,(currentDemoShip)
                        inc     a
                        JumpIfALTNusng  16, .OKInc
.ResetInc:              ZeroA
.OKInc:                 ld      (currentDemoShip),a                        
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

            include "../../Maths/Utilities/XX12EquNodeDotOrientation.asm"
            include "../../ModelRender/CopyXX12ToXX15.asm"	
            include "../../Maths/Utilities/ScaleXX16Matrix197.asm"
		    
            include "../../Universe/StarDust/StarRoutines.asm"
            
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
    INCLUDE "../../Maths/multiply.asm"
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
    INCLUDE "../../Maths/Utilities/AequAdivQmul96-TIS2.asm" ; AequAdivDmul96
    INCLUDE "../../Maths/Utilities/AequAmulQdiv256-FMLTU.asm"
    ;INCLUDE "../../Maths/Utilities/PRequSpeedDivZZdiv8-DV42-DV42IYH.asm"
    INCLUDE "../../Maths/Utilities/APequQmulA-MULT1.asm"
    INCLUDE "../../Maths/Utilities/badd_ll38.asm"
    INCLUDE "../../Maths/Utilities/RequAmul256divQ-BFRDIV.asm"
    INCLUDE "../../Maths/Utilities/RequAdivQ-LL61.asm"
    INCLUDE "../../Maths/Utilities/RSequQmulA-MULT12.asm"
    include "../../Universe/Ships/CopyRotMattoXX15.asm"
    include "../../Universe/Ships/CopyXX15toRotMat.asm"
    INCLUDE "../../Maths/Utilities/tidy.asm"
    INCLUDE "../../Maths/Utilities/LL28AequAmul256DivD.asm"    
    INCLUDE "../../Maths/Utilities/XAequMinusXAPplusRSdiv96-TIS1.asm"
    INCLUDE "../../Menus/common_menu.asm"
MainNonBankedCodeEnd:
    DISPLAY "Main Non Banked Code Ends at ",$

; Bank 57  ------------------------------------------------------------------------------------------------------------------------
    SLOT    LAYER2Addr
    PAGE    BankLAYER2
    ORG     LAYER2Addr
     
    INCLUDE "../../Layer2Graphics/layer2_bank_select.asm"
    INCLUDE "../../Layer2Graphics/layer2_cls.asm"
    INCLUDE "../../Layer2Graphics/layer2_initialise.asm"
    INCLUDE "../../Layer2Graphics/l2_flip_buffers.asm"
    INCLUDE "../../Layer2Graphics/layer2_plot_pixel.asm"
    INCLUDE "../../Layer2Graphics/layer2_print_character.asm"
    INCLUDE "../../Layer2Graphics/layer2_draw_box.asm"
    INCLUDE "../../Layer2Graphics/asm_l2_plot_horizontal.asm"
    INCLUDE "../../Layer2Graphics/asm_l2_plot_vertical.asm"
    INCLUDE "../../Layer2Graphics/layer2_plot_diagonal.asm"
    INCLUDE "../../Layer2Graphics/int_bren_save.asm"
    INCLUDE "../../Layer2Graphics/layer2_plot_circle.asm"
    INCLUDE "../../Layer2Graphics/layer2_plot_circle_fill.asm"
    INCLUDE "../../Layer2Graphics/BBCEliteDirectMappingLL118.asm"    
    INCLUDE "../../Layer2Graphics/l2_draw_any_line.asm"
    INCLUDE "../../Layer2Graphics/l2_draw_line_v2.asm"
    DISPLAY "Bank ",BankLAYER2," - Bytes free ",/D, $2000 - ($-LAYER2Addr), " - BankLAYER2"
; Bank 58  ------------------------------------------------------------------------------------------------------------------------
    SLOT    LAYER1Addr
    PAGE    BankLAYER1
    ORG     LAYER1Addr, BankLAYER1
Layer1Header:  DB "Bank L1 Utils--"

    INCLUDE "../../Layer1Graphics/layer1_attr_utils.asm"
    INCLUDE "../../Layer1Graphics/layer1_cls.asm"
    INCLUDE "../../Layer1Graphics/layer1_print_at.asm"
    DISPLAY "Bank ",BankLAYER1," - Bytes free ",/D, $2000 - ($-LAYER1Addr), " - BankLAYER1"
; Bank 59  ------------------------------------------------------------------------------------------------------------------------
; In the first copy of the banks the "Non number" labels exist. They will map directly in other banks
; as the is aligned and data tables are after that
; need to make the ship index tables same size in each to simplify further    
    SLOT    ShipModelsAddr
    PAGE    BankShipModels1
	ORG     ShipModelsAddr, BankShipModels1

MShipBankTable          MACRO 
                        DW      BankShipModels1
                        DW      BankShipModels2
                        DW      BankShipModels3
                        DW      BankShipModels4
                        ENDM
; For ship number A fetch 
;           the adjusted ship number in B , C = original number
;           bank number in A for the respective ship based on the ship table
MGetShipBankId:         MACRO   banktable
                        ld      b,0
                        ld      c,a                                 ; c= original ship id
.ShiftLoop:             srl     a
                        srl     a
                        srl     a
                        srl     a                                   ; divide by 16
                        ld      b,a                                 ; b = bank nbr
                        ld      a,c
                        ld      d,b
                        ld      e,16
                        mul                                         ; de = 16 * bank number (max is about 15 banks)
                        sub     e                                   ; a= actual model id now
.SelectedBank:          ld      d,b                                 ; save current bank number
                        ld      b,a                                 ; b = adjusted ship nbr 
                        ld      a,d                                 ; a = bank number
;.. Now b = bank and a = adjusted ship nbr                     
                        ld      hl,banktable                        ; a= bank index
                        add     hl,a
                        add     hl,a
                        ld      a,(hl)                              ; a = actual bank now
                        ClearCarryFlag
                        ret
                        ENDM

McopyVertsToUniverse:   MACRO 
                        ld          hl,(VerticesAddyAddr)       ; now the pointers are in Ubnk its easy to read
                        ld          de,UBnkHullVerticies
                        ld          b,0
                        ld			a,(VertexCtX6Addr)
                        ld          c,a
                        ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
                        call        memcopy_dma
                        ret
                        ENDM

McopyEdgesToUniverse:   MACRO
                        ld          hl,(EdgeAddyAddr)          ; now the pointers are in Ubnk its easy to read
                        ld          de,UBnkHullEdges
                        ld          b,0
                        ld			a,(LineX4Addr)
                        ld          c,a
                        ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
                        call        memcopy_dma
                        ret
                        ENDM
                        
McopyNormsToUniverse:   MACRO
                        ld          hl,(FaceAddyAddr)          ; now the pointers are in Ubnk its easy to read
                        ld          de,UBnkHullNormals
                        ld          b,0
                        ld          a,(FaceCtX4Addr)
                        ld          c,a
                        ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
                        call        memcopy_dma
                        ret
                        ENDM
                        
; Passes in ship nbr in A and bank is part of MACRO
MCopyShipToUniverse:    MACRO       banklabel
                        ld          hl,UBnkShipModelBank
                        ld          (hl),banklabel
                        push        af
                        ld          a,iyl
                        ld          (UBnKShipModelId),a
                        pop         af
                        ld          (UBnKShipModelNbr),a
.GetHullDataLength:     ld          hl,ShipModelSizeTable
                        add         hl,a
                        add         hl,a                        ; we won't multiply by 2 as GetInfo is a general purpose routines so would end up x 4
                        ld          c,(hl)
                        inc         hl
                        ld          b,(hl)                      ; bc now equals length of data set
.GetHullDataAddress:    ld          hl,ShipModelTable
                        add         hl,a
                        add         hl,a                        ; now hl = address of ship data value
                        ld          a,(hl)
                        inc         hl
                        ld          h,(hl)
                        ld          l,a                         ; now hl = address of ship hull data
                        ld          de,UBnkHullCopy             ; Universe bank
                        ld          bc,ShipDataLength           
                        ldir                                    
                        call        CopyVertsToUniv
                        call        CopyEdgesToUniv
                        call        CopyNormsToUniv
.ClearName:             ld          hl,StartOfUnivName
                        ld          a," "
                        ld          b,16
.fillLoop:              ld          (hl),a
                        inc         hl
                        djnz        .fillLoop
                        ret
                        ENDM
                        
MCopyBodyToUniverse:    MACRO       copyRoutine
                        ld          a,13
                        call        copyRoutine
                        ret
                        ENDM
                        
                        
MCopyShipIdToUniverse:  MACRO
                        call        GetShipModelId
                        MMUSelectShipBankA
                        ld          a,b
                        jp          CopyShipToUniverse
                        ENDM    
    
    
    
    
    INCLUDE "../../Data/ShipBank1Label.asm"
GetShipBankId:
GetShipBank1Id:         MGetShipBankId ShipBankTable
CopyVertsToUniv:
CopyVertsToUniv1:       McopyVertsToUniverse
CopyEdgesToUniv:
CopyEdgesToUniv1:       McopyEdgesToUniverse
CopyNormsToUniv:        
CopyNormsToUniv1:       McopyNormsToUniverse
ShipBankTable:
ShipBankTable1:         MShipBankTable
CopyShipToUniverse:
CopyShipToUniverse1     MCopyShipToUniverse     BankShipModels1
CopyBodyToUniverse:
CopyBodyToUniverse1:    MCopyBodyToUniverse     CopyShipToUniverse1
ShipModelTable:
ShipModelTable1:         DW Adder                                   ;00 $00
                         DW Anaconda                                ;01 $01
                         DW Asp_Mk_2                                ;02 $02
                         DW Boa                                     ;03 $03
                         DW CargoType5                              ;04 $04
                         DW Boulder                                 ;05 $05
                         DW Asteroid                                ;06 $06                       
                         DW Bushmaster                              ;07 $07
                         DW Chameleon                               ;08 $08
                         DW CobraMk3                                ;09 $09
                         DW Cobra_Mk_1                              ;10 $0A
                         DW Cobra_Mk_3_P                            ;11 $0B
                         DW Constrictor                             ;12 $0C
                         DW Coriolis                                ;13 $0D
                         DW Cougar                                  ;14 $0E
                         DW Dodo                                    ;15 $0F
ShipVertexTable:
ShipVertexTable1:        DW AdderVertices                           ;00 $00
                         DW AnacondaVertices                        ;01 $01
                         DW Asp_Mk_2Vertices                        ;02 $02
                         DW BoaVertices                             ;03 $03
                         DW CargoType5Vertices                      ;04 $04
                         DW BoulderVertices                         ;05 $05
                         DW AsteroidVertices                        ;06 $06
                         DW BushmasterVertices                      ;07 $07
                         DW ChameleonVertices                       ;08 $08
                         DW CobraMk3Vertices                        ;09 $09
                         DW Cobra_Mk_1Vertices                      ;10 $0A
                         DW Cobra_Mk_3_PVertices                    ;11 $0B
                         DW ConstrictorVertices                     ;12 $0C
                         DW CoriolisVertices                        ;13 $0D
                         DW CougarVertices                          ;14 $0E
                         DW DodoVertices                            ;15 $0F
ShipEdgeTable:
ShipEdgeTable1:          DW AdderEdges                              ;00 $00
                         DW AnacondaEdges                           ;01 $01
                         DW Asp_Mk_2Edges                           ;02 $02
                         DW BoaEdges                                ;03 $03
                         DW CargoType5Edges                         ;04 $04
                         DW BoulderEdges                            ;05 $05
                         DW AsteroidEdges                           ;06 $06
                         DW BushmasterEdges                         ;07 $07
                         DW ChameleonEdges                          ;08 $08
                         DW CobraMk3Edges                           ;09 $09
                         DW Cobra_Mk_1Edges                         ;10 $0A
                         DW Cobra_Mk_3_PEdges                       ;11 $0B
                         DW ConstrictorEdges                        ;12 $0C
                         DW CoriolisEdges                           ;13 $0D
                         DW CougarEdges                             ;14 $0E
                         DW DodoEdges                               ;15 $0F
ShipNormalTable:
ShipNormalTable1:        DW AdderNormals                            ;00 $00
                         DW AnacondaNormals                         ;01 $01
                         DW Asp_Mk_2Normals                         ;02 $02
                         DW BoaNormals                              ;03 $03
                         DW CargoType5Normals                       ;04 $04
                         DW BoulderNormals                          ;05 $05
                         DW AsteroidNormals                         ;06 $06
                         DW BushmasterNormals                       ;07 $07
                         DW ChameleonNormals                        ;08 $08
                         DW CobraMk3Normals                         ;09 $09
                         DW Cobra_Mk_1Normals                       ;10 $0A
                         DW Cobra_Mk_3_PNormals                     ;11 $0B
                         DW ConstrictorNormals                      ;12 $0C
                         DW CoriolisNormals                         ;13 $0D
                         DW CougarNormals                           ;14 $0E
                         DW DodoNormals                             ;15 $0F
ShipModelSizeTable:
ShipModelSizeTable1:     DW AdderLen                                ;00 $00
                         DW AnacondaLen                             ;01 $01
                         DW Asp_Mk_2Len                             ;02 $02
                         DW BoaLen                                  ;03 $03
                         DW CargoType5Len                           ;04 $04
                         DW BoulderLen                              ;05 $05
                         DW AsteroidLen                             ;06 $06
                         DW BushmasterLen                           ;07 $07
                         DW ChameleonLen                            ;08 $08
                         DW CobraMk3Len                             ;09 $09
                         DW Cobra_Mk_1Len                           ;10 $0A
                         DW Cobra_Mk_3_PLen                         ;11 $0B
                         DW ConstrictorLen                          ;12 $0C
                         DW CoriolisLen                             ;13 $0D
                         DW CougarLen                               ;14 $0E
                         DW DodoLen                                 ;15 $0F
                         
                        include "../../Data/ships/Adder.asm"
                        include "../../Data/ships/Anaconda.asm"
                        include "../../Data/ships/Asp_Mk_2.asm"
                        include "../../Data/ships/Boa.asm"
                        include "../../Data/ships/CargoType5.asm"
                        include "../../Data/ships/Boulder.asm"
                        include "../../Data/ships/Asteroid.asm"
                        include "../../Data/ships/Bushmaster.asm"
                        include "../../Data/ships/Chameleon.asm"
                        include "../../Data/ships/CobraMk3.asm"
                        include "../../Data/ships/Cobra_Mk_1.asm"
                        include "../../Data/ships/Cobra_Mk_3_P.asm"
                        include "../../Data/ships/Constrictor.asm"
                        include "../../Data/ships/Coriolis.asm"
                        include "../../Data/ships/Cougar.asm"
                        include "../../Data/ships/Dodo.asm"


    DISPLAY "Bank ",BankShipModels1," - Bytes free ",/D, $2000 - ($-ShipModelsAddr), " - BankShipModels1"
; Bank 70  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    UniverseBankAddr
                    PAGE    BankUNIVDATA0
                    ORG	    UniverseBankAddr,BankUNIVDATA0
                    INCLUDE "../../Tests/3DTest/univ_ship_data.asm"
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
    
    SAVENEX OPEN "3DTest.nex", EliteNextStartup , TopOfStack
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    DISPLAY "Main Non Banked Code End ", MainNonBankedCodeEnd , " Bytes free ", 0B000H - MainNonBankedCodeEnd
    ASSERT MainNonBankedCodeEnd < 0B000H, Program code leaks intot interrup vector table
    