 DEVICE ZXSPECTRUMNEXT

 CSPECTMAP TriangleTst.map
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
MainLoop:               call        asm_l2_double_buffer_off
                        ld		b, 20
                        ld		c, 20
                        ld		d, 50
                        ld		e, 50
                        ld		h, 30
                        ld		l, 70
                        ld		a,  $D3
                        ld		(l2linecolor),a
                        ld      (line_gfx_colour),a
                       
                 ;       call	l2_draw_triangle
                        
                        ld		b, 60
                        ld		c, 60
                        ld		d, 80
                        ld		e, 120
                        ld		h, 70
                        ld		a, $B8
                        ld		(l2linecolor),a
                        ld      (line_gfx_colour),a
                        ;break
                  ;      call l2_fillBottomFlatTriangle
                        ld		b, 80
                        ld		c, 30
                        ld		d, 10
                        ld		e, 50
                        ld		h, 30
                        ld		a, $F3
                        ld		(l2linecolor),a
                        ld      (line_gfx_colour),a
                              ;                 x  y     x  y         x  y     x  y
                        ;break ; Line 1 bc -> de 10,30 to 30,80 line 2 50,30 to 30,80
                  ;      call l2_fillTopFlatTriangle
                        ;break
                        ld		b, 40    ;28
                        ld		c, 10    ;0A
                        ld		d, 75    ;4B
                        ld		e, 110   ;6E
                        ld		h, 90    ;5A
                        ld      l, 60    ;3C
                        ld		a, $C4
                        ld		(l2linecolor),a
                        ld      (line_gfx_colour),a                        
                  ;      call l2_fillAnyTriangle ; so X? = 2D n
                        break   
                        ld      hl,50        ; $14
                        ld      (l2_X0),hl   ; 
                        ld      hl,10        ; $28
                        ld      (l2_X1),hl   ; 
                        ld      hl,20        ; 
                        ld      (l2_Y0),hl   ; 
                        ld      hl,50        ; 1E
                        ld      (l2_Y1),hl   ; 
                        call    int_bren_save_Array1Low
                        ld      hl,55        ; $14
                        ld      (l2_X0),hl   ; 
                        ld      hl,100        ; $28
                        ld      (l2_X1),hl   ; 
                        ld      hl,20        ; 
                        ld      (l2_Y0),hl   ; 
                        ld      hl,50        ; 1E
                        ld      (l2_Y1),hl   ; 
                        call    int_bren_save_Array2High                       
                        ld      hl,l2targetArray1+20
                        ld      b,30
                        ld      ixl,30
.LineLoop:              push    bc,,hl,,ix
                        ld      a,(hl)          ; x0
                        ld      c,a
                        inc     h
                        ld      a,(hl)          ; x1
                        sub     c
                        ld      d,a
                        ld      e,$C5
                        ld      b,ixl
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        pop     bc,,hl,,ix
                        inc     ixl
                        inc     hl
                        djnz    .LineLoop


;;#optmisation to try
;;sort all 3 coordinates y ascending
;;if y0 and y1 == then simple flat top
;;if y1 aand y2 == then simple flat bottom
;;else
;;  start drawing flat bottom traingle from x0,y0
;;  when y line calulation reaches row y1 we switch to doinig a flat top triangle from xcurrycurr to x1y1 ad x2y2
;;  saves all the precalculating

LargerTriangle:         ld      hl, 100         ; 64
                        ld      (l2_X0),hl
                        ld      hl, 100
                        ld      (l2_Y0),hl
                        ld      hl, 300
                        ld      (l2_X1),hl
                        ld      hl, 145
                        ld      (l2_Y1),hl
                        ld      hl,120
                        ld      (ld_YMid),hl
                        break
                        call    HLEquMidX
                                                
PausePoint:             break     
                        jp PausePoint

XX20                DS 20

CurrentX            DB 0
CurrentY            DB 0
 ;..................................................................................................................................
	;call		keyboard_main_loop

    INCLUDE	"./Hardware/memfill_dma.asm"
    INCLUDE	"./Hardware/memcopy_dma.asm"
    INCLUDE "./Hardware/keyboard.asm"
    INCLUDE "./Maths/compare16.asm"
    INCLUDE "./Maths/asm_divide.asm"
    INCLUDE "./Maths/multiply.asm"
    
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


    SAVENEX OPEN "TriangleTst.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    