 DEVICE ZXSPECTRUMNEXT

 CSPECTMAP keyTst.map
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

;----------------------------------------------------------------------------------------------------------------------------------

                        INCLUDE "./Hardware/register_defines.asm"
                        INCLUDE "./Layer2Graphics/layer2_defines.asm"
                        INCLUDE	"./Hardware/memory_bank_defines.asm"
                        INCLUDE "./Hardware/screen_equates.asm"
                        INCLUDE "./Data/ShipModelEquates.asm"
                        INCLUDE "./Menus/clear_screen_inline_no_double_buffer.asm"	
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
                        INCLUDE "./Tables/message_queue_macros.asm"
                        INCLUDE "./Variables/general_variables_macros.asm"
                        INCLUDE "./Variables/UniverseSlot_macros.asm"
                        
                        INCLUDE "./Data/ShipIdEquates.asm"

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
                        call		l2_cls
                        call        init_keyboard
MainLoop:               call        scan_keyboard
                        
                        call        displayKeyStatus
                        jp MainLoop

XX20                DS 20

CurrentX            DB 0
CurrentY            DB 0
                        
displayKeyStatus:       xor         a
                        ld          (CurrentX),a
                        ld          hl,RawKeys
                        ld          a,(hl)
                        and         %00011111
                        ld          b,5
.displayLoop:           push        bc,,hl
                        rra
                        jr          c,.displayNoPress
.displayPress:          push        af
                        ld          a,(CurrentX)
                        ld          e,a
                        ld          a,(CurrentY)
                        ld          d,a
                        ld          a,'*'
                        MMUSelectLayer1
                        call        l1_print_char
                        ld          a,(CurrentX)
                        add         a,8
                        ld          (CurrentX),a
                        pop         af
                        pop         bc,,hl                        
                        djnz        .displayLoop
                        ret
.displayNoPress:        push        af
                        ld          a,(CurrentX)
                        ld          e,a
                        ld          a,(CurrentY)
                        ld          d,a
                        ld          a,'O'
                        MMUSelectLayer1
                        call        l1_print_char
                        ld          a,(CurrentX)
                        add         a,8
                        ld          (CurrentX),a
                        pop         af
                        pop         bc,,hl                        
                        djnz        .displayLoop
                        ret
;..................................................................................................................................
	;call		keyboard_main_loop

    INCLUDE	"./Hardware/memfill_dma.asm"
    INCLUDE	"./Hardware/memcopy_dma.asm"
    INCLUDE "./Hardware/keyboard.asm"
    
    INCLUDE "./Variables/constant_equates.asm"
    INCLUDE "./Variables/general_variables.asm"

; Include all maths libraries to test assembly


;--------------------------------------------------------------------------------------------------------
; Goes through each edge in to determine if they are on a visible face, if so load start and end to line array as clipped lines

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


    SAVENEX OPEN "keyTst.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    