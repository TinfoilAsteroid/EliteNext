 DEVICE ZXSPECTRUMNEXT

 CSPECTMAP clipTst.map
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
    
    INCLUDE "./Macros/MMUMacros.asm"
    INCLUDE "./Macros/ShiftMacros.asm"
    INCLUDE "./Macros/CopyByteMacros.asm"
    INCLUDE "./Macros/generalMacros.asm"
    INCLUDE "./Macros/ldCopyMacros.asm"
    INCLUDE "./Macros/ldIndexedMacros.asm"
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
                        call		l2_cls
fillLineBuffer:         ld          hl,LineList
                        ld          de,UBnkNodeArray
                        ld          bc,LineListLen
                        ldir
setToLineHead:          xor         a
                        ld          (currentLine),a                   
;..................................................................................................................................
                        MMUSelectLayer2
                        call    PrepLines                   ; LL72, process lines and clip, ciorrectly processing face visibility now
MainLoop:               call    DrawLines                   ; Need to plot all lines
                        ld      hl,currentLine
                        inc     (hl)
                        jp MainLoop
;..................................................................................................................................
	;call		keyboard_main_loop
    
    
LineList:             ;dw 145,49,109,-31
; clip Y1 or Y2 only testing shallow
                      dw 109,-31,206,13     ; pass
                      dw 109,0,206,44
                      dw 109,13,206,-31     ; pass
                      dw 109,44,206,0
                      dw 109,97,206,160      ; pass
                      dw 109,65,206,127      ; pass
                      dw 109,160,206,87      ; pass
                      dw 109,127,206,65      ; pass
; clip Y1 or Y2 only testing steep
                      dw 109,-31,125,13     ; pass near poss rounding
                      dw 109,0,125,44        ; pass near poss rounding
                      dw 109,13,125,-31     ; pass near poss rounding
                      dw 109,44,125,0        ; pass near poss rounding
                      dw 109,97,125,160      ; pass
                      dw 109,65,125,127      ; pass
                      dw 109,97,125,160     ; pass 
                      dw 109,65,125,127        ; pass 
; clip X1 or X1 testig shallow
                      dw -50,10,115,40      ; pass 
                      dw 00,10,165,40       ; pass 
                      dw 115,10,-50,40      ; pass near poss rounding
                      dw 165,10,1,40       ; pass near poss rounding
                      dw 300,10,115,40      ; pass            
                      dw 255,10,70,40       ; pass 
                      dw 115,10,300,40      ; pass 
                      dw 70,10,255,40       ; pass                    
; clip X1 or X1 testig steep
                      dw -20,10,35,80      ; pass 
                      dw 00,10,55,80       ; pass 
                      dw -20,80,35,10     
                      dw 00,80,55,10       
                      dw 270,10,235,80      ; pass            
                      dw 255,10,220,80       ; pass 
; span screen shallow                   
                      dw -20,10,270,80      ; pass 
                      dw 00,14,255,77       ; pass 
                    
                      dw 270,10,-20,80      ; pass 
                      dw 255,14,0,77       ; pass 
                      dw 10,-20,80,270      ; pass 
                      dw 10,270,80,-20      ; pass 
                      dw 80,-20,10,270      ; pass 
                      dw 80,270,10,-20      ; pass 
                      dw 00,14,255,77       ; pass 
                   
                   
                      dw 123,0,206,13
                      dw 125,-12,172,10
                      dw 145,49,125,-12
                      dw 145,10,145,100
                      dw 135,10,135,100
                      dw 125,10,125,100
                      dw 115,10,115,100
                      dw 105,10,105,100
                      ; dw       10,10,20,20
                      ; dw       50,50,20,20
                      ; dw       10,50,20,20
                      ; dw       50,10,20,20
                      ; dw       50,10,20,20
                      ; dw       15,10,20,20
                      ; dw       15,15,20,20
                      ; dw       10,15,20,20
                      ; dw       50,20,20,20
                      ; dw       20,10,20,20                        
                      ; dw       50,20,20,20
                      ; dw       10,20,20,20                        
                      ; dw       20,10,20,20
                      ; dw       20,50,20,20  
                      ; dw       000,100,100,100            ; Horizonal left to right on screen         - Loosed first pixel top
                      ; dw       100,000,100,100            ; Veritcal  down on screen                  - Loosed first pixel left
                       ;dw      0,100,255,100
                       ;dw      0,110,255,110
                       ;dw      0,127,255,127
                       ;dw      0,90,255,90
                       ;dw      90,0,90,127
                       ;dw      100,0,100,127           
                       ;dw      110,0,110,127
                       ;dw      90,-10,100,100              ; look better
                       ;dw      110,-10,100,100             ; look better
                       ;dw      90,300,100,100              ; fail upside down?
                       ;dw      110,300,100,100             ; fail
                       ;dw      90,200,100,100              ; loooks beeter
                       ;dw      110,200,100,100             ; loooks beeter
                       ;dw       500,110,100,100            ; Horzontal right to left clip right         - nwo good clips to 255,110      horizontal
                       ;dw       -10,110,100,100            ; Horzontal left to right clip left          - now good clips 0, 110          horizontal
                       ;dw       -10,90,100,100            ; Horzontal left to right clip left          -  now good clips  0, 90          horizontal
                      ; dw       260,110,100,100            ; Horzontal left to right clip left          - now good clips to 255,110      horizontal
                      ; dw       260,90,100,100            ; Horzontal left to right clip left          - now good clips to 255,90        horizontal
                      ; dw       100,100,550,100            ;  looks OK
                      ; dw       100,100,-10,100            ;     looks OK                                         - Total loss of line
                      ; dw        100,500,100,100           ;  now ood ends up vertical
                      ; dw        105,500,100,100           ;                                           - loss of part line, go steep optmisation
                      ; dw        -5,105,100,100            ; loooks beeter                                           - Loosed first pixel left
                      ; dw         10,-5,100,100            ;  loooks beeter                                          - Loosed first pixel top
                      ; dw        300,105,100,100            ;  loooks beeter                                            - large x looses the plot
                      ; dw        300,-105,100,100            ;loooks beeter                                              - Loosed first pixel left
                      ; dw         10,180,100,100            ;  loooks beeter                                            - Loosed first pixel top
                      ; dw       100,105,100,100          
                ;        dw       500,200,100,100 ; looks OK
                ;  dw       200,100,100,100                        
                ;  dw       500,200,100,100
                ;  dw       100,200,100,100                        
                ;  dw       200,100,100,100
                ;  dw       200,500,100,100  
                ;
                ; dw       20,20,10,10
                ; dw       -10,10,20,20
                ; dw       10,-10,20,20
                ; dw       10,10,-20,20
                ; dw       10,10,20,-20
                ; dw       -10,10,-20,20
                ; dw       10,-10,20,-20
                ; dw       -10,-10,-20,-20
LineListLen             equ $ - LineList
                     db "XXXXXXXX"


TestQuit:               call    scan_keyboard
                        ld      a,c_Pressed_Quit
                        call    is_key_pressed
                        jr      nz,TestQuit
                        ret
currentLine:            DB 0

    INCLUDE	"./Hardware/memfill_dma.asm"
    INCLUDE	"./Hardware/memcopy_dma.asm"
    INCLUDE "./Hardware/keyboard.asm"
    
    INCLUDE "./Variables/constant_equates.asm"
    INCLUDE "./Variables/general_variables.asm"
    INCLUDE "./Maths/Utilities/LL28AequAmul256DivD.asm"

; Include all maths libraries to test assembly

    INCLUDE "./Maths/multiply.asm"
    INCLUDE "./Maths/asm_square.asm"
    INCLUDE "./Maths/asm_sqrt.asm"
    INCLUDE "./Maths/asm_divide.asm"
    INCLUDE "./Maths/asm_unitvector.asm"
    INCLUDE "./Maths/compare16.asm"
    INCLUDE "./Maths/negate16.asm"
;    INCLUDE "./Maths/normalise96.asm"
    INCLUDE "./Maths/binary_to_decimal.asm"


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
UbnKDrawAsDot               DB  0               ; if 0 then OK, if 1 then just draw dot of line heap
UBnkProjectedY              DB  0
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

FaceArraySize               equ 30
EdgeHeapSize                equ 40
NodeArraySize               equ 40
LineArraySize               equ LineListLen
; Storage arrays for data
; Structure of arrays
; Visibility array  - 1 Byte per face/normal on ship model Bit 7 (or FF) visible, 0 Invisible
; Node array corresponds to a processed vertex from the ship model transformed into world coordinates and tracks the node list from model
; NodeArray         -  4 bytes per element      0           1            2          3
;                                               X Coord Lo  Y Coord Lo   Z CoordLo  Sign Bits 7 6 5 for X Y Z Signs (set = negative)
; Line Array        -  4 bytes per eleement     0           1            2          3
;                                               X1          Y1           X2         Y2
UbnkFaceVisArray            DS FaceArraySize            ; XX2 Up to 16 faces this may be normal list, each entry is controlled by bit 7, 1 visible, 0 hidden
UBnkNodeArray               DS NodeArraySize * 4        ; XX3 Holds the points as an array, its an array not a heap
UBnkNodeArray2              DS NodeArraySize * 4        ; XX3 Holds the points as an array, its an array not a heap
UbnkLineArray               DS LineArraySize * 4        ; XX19 Holds the clipped line details
UBnkLinesHeapMax            EQU $ - UbnkLineArray
UbnkEdgeProcessedList DS EdgeHeapSize
; Array current Lengths
UbnkFaceVisArrayLen         DS 1
UBnkNodeArrayLen            DS 1
UbnkLineArrayLen            DS 1                        ; total number of lines loaded to array 
UbnkLineArrayBytes          DS 1                        ; total number of bytes loaded to array  = array len * 4
XX20                        equ UbnkLineArrayLen
varXX20                     equ UbnkLineArrayLen


UbnkEdgeHeapSize            DS 1
UbnkEdgeHeapBytes           DS 1
UBnkLinesHeapLen            DS 1
UbnKEdgeHeapCounter         DS 1
UbnKEdgeRadius              DS 1
UbnKEdgeShipType            DS 1
UbnKEdgeExplosionType       DS 1

;--------------------------------------------------------------------------------------------------------
; ---------------------------------------------------------------------------------------------------------------------------------    
DrawLinesCounter		db	0
; Initial tests look OK    
LL155:;
ClearLine:                                  ; CLEAR LINEstr visited by EE31 when XX3 heap ready to draw/erase lines in XX19 heap.
                                                                           ; ObjectInFront:
DrawLines:              ld	    a,$65 ; DEBUG
                        ld		iyl,a							; set ixl to colour (assuming we come in here with a = colour to draw)
                        ld		a,(UbnkLineArrayLen)			; get number of lines
                        ReturnIfAIsZero   						; No lines then bail out.
                        ld		iyh,a			                ; number of lines still to draw
                        ld		hl,UbnkLineArray
;LL27:                                       ; counter Y, Draw clipped lines in XX19 ship lines heap
DrawXX19ClippedLines:   ld      c,(hl)                          ; (XX19),Y c = varX1
                        inc     hl
                        ld      b,(hl)                          ; bc = point1 Y,X
                        inc     hl

                        ld      e,(hl)                          ; c = varX1
                        inc     hl
                        ld      d,(hl)                          ; de = point2 Y,X
                        inc     hl
                        push	hl
                        push    iy
                        ld      h,b
                        ld      l,c
  ;  call    l2_draw_any_line                ; call version of LOIN that used BCDE
                        ld		a,iyl							; get colour back before calling line draw
                        MMUSelectLayer2
                        call    LineHLtoDE
                        pop     iy
                        pop	    hl
                        dec     iyh
                        jr		nz,DrawXX19ClippedLines
                        ret                                     ; --- Wireframe end  \ LL118-1


;--------------------------------------------------------------------------------------------------------
    INCLUDE "./ModelRender/getVertexNodeAtAToX1Y1.asm"
    INCLUDE "./ModelRender/getVertexNodeAtAToX2Y2.asm"
    INCLUDE "./ModelRender/GetFaceAtA.asm"
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
    INCLUDE "./Layer2Graphics/clearLines-LL155.asm"
    INCLUDE "./Layer2Graphics/l2_draw_line_v2.asm"

;--------------------------------------------------------------------------------------------------------
PLEDGECTR           DB          0

PrepLines:              ldWriteZero UbnkLineArrayLen                    ; current line array index = 0
                        ldWriteZero UbnkLineArrayBytes                  ; UbnkLineArrayBytes= nbr of bytes of lines laoded = array len * 4
                        ldWriteZero PLEDGECTR
                        ld          hl,UbnkLineArray
                        ld          (varU16),hl
;LL79--Visible edge--------------------------------------
.PrepLoop:              ld          a,(PLEDGECTR)
                        sla         a
                        sla         a
                        call        getVertexNodeAtAToX1Y1              ; get the points X1Y1 from node
                        ld          a,(PLEDGECTR)
                        inc         a
                        ld          (PLEDGECTR),a
                        sla         a
                        sla         a
                        call        getVertexNodeAtAToX2Y2              ; get the points X2Y2 from node
                        call        ClipLine
                        jr          c,.LL78EdgeNotVisible                ; LL78 edge not visible
                        ld          de,(varU16)                         ; clipped edges heap address
                        ld          hl,UBnkNewX1
                        FourLDIInstrunctions
                        ld          (varU16),de                         ; update U16 with current address
                        ld          hl,UbnkLineArrayLen                 ; we have loaded one line
                        inc         (hl)
                        ld          a,(hl)
                        JumpIfAGTENusng LineArraySize,CompletedLineGeneration   ; have we hit max lines for a model hop over jmp to Exit edge data loop
; If we hit here we skip the write of line arryay u16
.LL78EdgeNotVisible:    ld          hl,PLEDGECTR                        ;
                        inc         (hl)                                ;
                        ld          a,(hl)                              ; current edge index ++
                        JumpIfANENusng LineListLen/4, .PrepLoop       ; compare with total number of points which is edges * 2
CompletedLineGeneration:ld          a,(UbnkLineArrayLen)                ; UbnkLineArrayLen = nbr of lines loaded 
                        sla         a
                        sla         a                                   ; multiple by 4 to equal number of bytes
                        ld          (UbnkLineArrayBytes),a              ; UbnkLineArrayBytes= nbr of bytes of lines laoded = array len * 4
ExitEdgeDataLoop:       ret
   
    SAVENEX OPEN "clipTst.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    