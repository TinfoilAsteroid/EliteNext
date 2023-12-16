 DEVICE ZXSPECTRUMNEXT

 CSPECTMAP sunDrawTst.map
 OPT --zxnext=cspect --syntax=a --reversepop

DEBUGSEGSIZE   equ 1
DEBUGLOGSUMMARY equ 1
;DEBUGLOGDETAIL equ 1

;----------------------------------------------------------------------------------------------------------------------------------
; Game Defines
ScreenLocal     EQU 0
ScreenGalactic  EQU ScreenLocal + 1
ScreenMarket    EQU ScreenGalactic + 1
ScreenMarketDsp EQU ScreenMarket + 1
ScreenStatus    EQU ScreenMarketDsp + 1
ScreenInvent    EQU ScreenStatus + 1
ScreenPlanet    EQU ScreenInvent + 1
ScreenEquip     EQU ScreenPlanet + 1
ScreenLaunch    EQU ScreenEquip + 1
ScreenFront     EQU ScreenLaunch + 1
ScreenAft       EQU ScreenFront+1
ScreenLeft      EQU ScreenAft+2
ScreenRight     EQU ScreenLeft+3
;----------------------------------------------------------------------------------------------------------------------------------
; Colour Defines
    INCLUDE "./Hardware/L2ColourDefines.asm"
    INCLUDE "./Hardware/L1ColourDefines.asm"
; Just to make assmebly work 
UBnKxlo         DW 0
UBnKxsgn         DW 0
UBnKzlo         DW 0
UBnKzsgn         DW 0
;----------------------------------------------------------------------------------------------------------------------------------

N0equN1byN2div256:      MACRO param1,param2,param3
                        ld      a,param3                        ; 
                        ld      e,a                         ; use e as var Q = value of XX15 [n] lo
                        ld      a,param2                        ; A = XX16 element
                        ld      d,a
                        mul
                        ld      a,d                         ; we get only the high byte which is like doing a /256 if we think of a as low                
                        ld      (param1),a                      ; Q         ; result variable = XX16[n] * XX15[n]/256
                        ENDM

AequN1xorN2:            MACRO  param1,param2
                        ld      a,(param1)
                        xor     param2
                        ENDM                        
    INCLUDE "./Hardware/register_defines.asm"
    INCLUDE "./Layer2Graphics/layer2_defines.asm"
    INCLUDE	"./Hardware/memory_bank_defines.asm"
    INCLUDE "./Hardware/screen_equates.asm"
    
                        INCLUDE "./Macros/graphicsMacros.asm"
                        INCLUDE "./Macros/callMacros.asm"
                        INCLUDE "./Macros/carryFlagMacros.asm"
                        INCLUDE "./Macros/CopyByteMacros.asm"
                        INCLUDE "./Macros/ldCopyMacros.asm"
                        INCLUDE "./Macros/ldIndexedMacros.asm"
                        INCLUDE "./Macros/jumpMacros.asm"
                        INCLUDE "./Macros/MathsMacros.asm"
                        INCLUDE "./Macros/MMUMacros.asm"
                        INCLUDE "./Macros/NegateMacros.asm"
                        INCLUDE "./Macros/returnMacros.asm"
                        INCLUDE "./Macros/ShiftMacros.asm"
                        INCLUDE "./Macros/signBitMacros.asm"
    INCLUDE "./Variables/general_variables_macros.asm"

charactersetaddr		equ 15360
STEPDEBUG               equ 1


                        ORG         $8000
                        di
                        ; "STARTUP"
                        MMUSelectLayer1
                        call		l1_cls
                        ld			a,7
                        call		l1_attr_cls_to_a
                        ld          a,$FF
                        call        l1_set_border                        
Initialise:             MMUSelectLayer2
                        call 		l2_initialise
                        call        asm_l2_double_buffer_on
;..................................................................................................................................
SunLoop:                MMUSelectLayer2
                        call		l2_cls
                        MMUSelectSun
                        ld          hl,$0081
                        ld          (SBnKxlo),hl
                        ld          hl,$0001
                        ld          (SBnKylo),hl
                        ld          hl,$0160
                        ld          (SBnKzlo),hl
                        ld          a,$80
                        ld          (SBnKxsgn),a
                        ZeroA
                        ld          (SBnKysgn),a
                        ld          (SBnKzsgn),a
                        call        SunUpdateAndRender
                       ; ld          hl, 300
                       ; ld          (SunScrnX),hl
                       ; ld          hl, 170
                       ; ld          (SunScrnY),hl
                        MMUSelectLayer2
                      ;  call        SunCalculateRadius
                       ; call        YOnScreen
                        call        l2_flip_buffers
                        jp          SunLoop
;..................................................................................................................................


    INCLUDE	"./Hardware/memfill_dma.asm"
    INCLUDE	"./Hardware/memcopy_dma.asm"
    INCLUDE "./Hardware/keyboard.asm"
    INCLUDE "./Data/EquipmentEquates.asm"
    INCLUDE "./Variables/constant_equates.asm"
    INCLUDE "./Variables/general_variables.asm"
    INCLUDE "./Variables/UniverseSlotRoutines.asm"
    INCLUDE "./Variables/EquipmentVariables.asm"
    INCLUDE "./Variables/random_number.asm"
    INCLUDE "./Variables/galaxy_seed.asm"
    INCLUDE "./Tables/text_tables.asm"
    INCLUDE "./Tables/dictionary.asm"
    INCLUDE "./Tables/name_digrams.asm"
    INCLUDE "./Maths/addhldesigned.asm"
    INCLUDE "./Maths/asm_add.asm"
    INCLUDE "./Maths/asm_AddDEToCash.asm"
    INCLUDE "./Maths/DIVD3B2.asm"
    INCLUDE "./Maths/multiply.asm"
    INCLUDE "./Maths/asm_square.asm"
    INCLUDE "./Maths/asm_sqrt.asm"
    INCLUDE "./Maths/asm_divide.asm"
    INCLUDE "./Maths/asm_unitvector.asm"
    INCLUDE "./Maths/compare16.asm"
    INCLUDE "./Maths/negate16.asm"
    INCLUDE "./Maths/normalise96.asm"
    INCLUDE "./Maths/binary_to_decimal.asm"
    include "./Maths/ADDHLDESignBC.asm"   
    INCLUDE "./Maths/Utilities/AequAdivQmul96-TIS2.asm"
    INCLUDE "./Maths/Utilities/AequAmulQdiv256-FMLTU.asm"
    INCLUDE "./Maths/Utilities/PRequSpeedDivZZdiv8-DV42-DV42IYH.asm"
    INCLUDE "./Maths/Utilities/AequDmulEdiv256usgn-DEFMUTL.asm"
    INCLUDE "./Maths/Utilities/APequQmulA-MULT1.asm"
    INCLUDE "./Maths/Utilities/badd_ll38.asm"
    INCLUDE "./Maths/Utilities/moveship4-MVS4.asm"   
    INCLUDE "./Maths/Utilities/RequAmul256divQ-BFRDIV.asm"
    INCLUDE "./Maths/Utilities/RequAdivQ-LL61.asm"    
    INCLUDE "./Maths/Utilities/RSequQmulA-MULT12.asm"
    INCLUDE "./Maths/Utilities/LL28AequAmul256DivD.asm"    
    INCLUDE "./Maths/Utilities/XAequMinusXAPplusRSdiv96-TIS1.asm"


;--------------------------------------------------------------------------------------------------------------------
    INCLUDE "./ModelRender/CLIP-LL145.asm"


; Repurposed XX15 when plotting lines
; Repurposed XX15 before calling clip routine
UBnkX1                      equ XX15
UBnKx1Lo                    equ XX15
UBnKx1Hi                    equ XX15+1
UBnkY1                      equ XX15+2
UbnKy1Lo                    equ XX15+2
UBnkY1Hi                    equ XX15+3
UBnkX2                      equ XX15+4
UBnkX2Lo                    equ XX15+4
UBnkX2Hi                    equ XX15+5
; Repurposed XX12 when plotting lines
UBnkY2                      equ XX12+0
UbnKy2Lo                    equ XX12+0
UBnkY2Hi                    equ XX12+1
UBnkDeltaXLo                equ XX12+2
UBnkDeltaXHi                equ XX12+3
UBnkDeltaYLo                equ XX12+4
UBnkDeltaYHi                equ XX12+5
UbnkGradient                equ XX12+2
UBnkTemp1                   equ XX12+2
UBnkTemp1Lo                 equ XX12+2
UBnkTemp1Hi                 equ XX12+3
UBnkTemp2                   equ XX12+3
UBnkTemp2Lo                 equ XX12+3
UBnkTemp2Hi                 equ XX12+4
;-- XX15 --------------------------------------------------------------------------------------------------------------------------
UBnkXScaled                 DB  0               ; XX15+0Xscaled
UBnkXScaledSign             DB  0               ; XX15+1xsign
UBnkYScaled                 DB  0               ; XX15+2yscaled
UBnkYScaledSign             DB  0               ; XX15+3ysign
UBnkZScaled                 DB  0               ; XX15+4zscaled
UBnkZScaledSign             DB  0               ; XX15+5zsign

XX15                        equ UBnkXScaled
XX15VecX                    equ XX15
XX15VecY                    equ XX15+1

XX15VecZ                    equ XX15+2
UbnkXPoint                  equ XX15
UbnkXPointLo                equ XX15+0
UbnkXPointHi                equ XX15+1
UbnkXPointSign              equ XX15+2
UbnkYPoint                  equ XX15+3
UbnkYPointLo                equ XX15+3
UbnkYPointHi                equ XX15+4
UbnkYPointSign              equ XX15+5
; Repurposed XX15 pre clip plines
UbnkPreClipX1               equ XX15+0
UbnkPreClipY1               equ XX15+2
UbnkPreClipX2               equ XX15+4
UbnkPreClipY2               equ XX15+6
; Repurposed XX15 post clip lines
UBnkNewX1                   equ XX15+0
UBnkNewY1                   equ XX15+1
UBnkNewX2                   equ XX15+2
UBnkNewY2                   equ XX15+3
; Repurposed XX15
regXX15fx                   equ UBnkXScaled
regXX15fxSgn                equ UBnkXScaledSign
regXX15fy                   equ UBnkYScaled
regXX15fySgn                equ UBnkYScaledSign
regXX15fz                   equ UBnkZScaled
regXX15fzSgn                equ UBnkZScaledSign
; Repurposed XX15
varX1                       equ UBnkXScaled       ; Reused, verify correct position
varY1                       equ UBnkXScaledSign   ; Reused, verify correct position
varZ1                       equ UBnkYScaled       ; Reused, verify correct position
; After clipping the coords are two 8 bit pairs
UBnkPoint1Clipped           equ UBnkXScaled
UBnkPoint2Clipped           equ UBnkYScaled
;-- transmat0 --------------------------------------------------------------------------------------------------------------------------
; Note XX12 comes after as some logic in normal processing uses XX15 and XX12 combines
UBnkXX12xLo                 DB  0               ; XX12+0
UBnkXX12xSign               DB  0               ; XX12+1
UBnkXX12yLo                 DB  0               ; XX12+2
UBnkXX12ySign               DB  0               ; XX12+3
UBnkXX12zLo                 DB  0               ; XX12+4
UBnkXX12zSign               DB  0               ; XX12+5
XX12Save                    DS  6
XX12Save2                   DS  6
XX12                        equ UBnkXX12xLo
varXX12                     equ UBnkXX12xLo
; Post clipping the results are now 8 bit
UBnkVisibility              DB  0               ; replaces general purpose xx4 in rendering
;UBnkProjectedY              DB  0
UBnkProjectedX              DB  0
UBnkProjected               equ UBnkProjectedY  ; resultant projected position
XX15Save                    DS  8
XX15Save2                   DS  8
VarBackface                 DB 0
; Heap (or array) information for lines and normals
; Coords are stored XY,XY,XY,XY
; Normals
; This needs re-oprganising now.
; Runtime Calculation Store


;--------------------------------------------------------------------------------------------------------

; Bank 58  ------------------------------------------------------------------------------------------------------------------------
    SLOT    LAYER1Addr
    PAGE    BankLAYER1
    ORG     LAYER1Addr, BankLAYER1

    INCLUDE "./Layer1Graphics/layer1_attr_utils.asm"
    INCLUDE "./Layer1Graphics/layer1_cls.asm"
    INCLUDE "./Layer1Graphics/layer1_print_at.asm"

    SLOT    LAYER2Addr
    PAGE    BankLAYER2
    ORG     LAYER2Addr
     
    INCLUDE "./Layer2Graphics/layer2_bank_select.asm"
    INCLUDE "./Layer2Graphics/layer2_cls.asm"
    INCLUDE "./Layer2Graphics/layer2_initialise.asm"
    INCLUDE "./Layer2Graphics/l2_flip_buffers.asm"
    INCLUDE "./Layer2Graphics/layer2_plot_pixel.asm"
    INCLUDE "./Layer2Graphics/layer2_print_character.asm"
    INCLUDE "./Layer2Graphics/layer2_draw_box.asm"
    INCLUDE "./Layer2Graphics/asm_l2_plot_horizontal.asm"
    INCLUDE "./Layer2Graphics/asm_l2_plot_vertical.asm"
    INCLUDE "./Layer2Graphics/layer2_plot_diagonal.asm"
    INCLUDE "./Layer2Graphics/asm_l2_plot_triangle.asm"
    INCLUDE "./Layer2Graphics/asm_l2_fill_triangle.asm"
    INCLUDE "./Layer2Graphics/layer2_plot_circle.asm"
    INCLUDE "./Layer2Graphics/layer2_plot_circle_fill.asm"
    INCLUDE "./Layer2Graphics/l2_draw_any_line.asm"
    INCLUDE "./Layer2Graphics/l2_draw_line_v2.asm"

; Bank 83  ------------------------------------------------------------------------------------------------------------------------
    SLOT    SunBankAddr
    PAGE    BankSunData
	ORG	    SunBankAddr,BankSunData
    INCLUDE "./Universe/Sun/sun_data.asm"

    SAVENEX OPEN "sunDrawTst.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    