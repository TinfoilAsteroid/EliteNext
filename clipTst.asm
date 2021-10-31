 DEVICE ZXSPECTRUMNEXT
 DEVICE ZXSPECTRUMNEXT
 CSPECTMAP eliteNext.map
 OPT --zxnext=cspect --syntax=a

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
    INCLUDE "./Macros/GeneralMacros.asm"
    INCLUDE "./Macros/ldCopyMacros.asm"
    INCLUDE "./Macros/ldIndexedMacros.asm"

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
                        call        l2_set_border                        
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
    
    
LineList:               dw       10,10,20,20
                        dw       50,50,20,20
                        dw       10,50,20,20
                        dw       50,10,20,20
                        dw       50,10,20,20
                        dw       15,10,20,20
                        dw       15,15,20,20
                        dw       10,15,20,20
                        dw       50,20,20,20
                        dw       20,10,20,20                        
                        dw       50,20,20,20
                        dw       10,20,20,20                        
                        dw       20,10,20,20
                        dw       20,50,20,20  
                        dw       000,100,100,100            ; Horizonal left to right on screen         - Loosed first pixel top
                        dw       100,000,100,100            ; Veritcal  down on screen                  - Loosed first pixel left
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
                        dw       500,200,100,100 ; looks OK
                  dw       200,100,100,100                        
                  dw       500,200,100,100
                  dw       100,200,100,100                        
                  dw       200,100,100,100
                  dw       200,500,100,100  
             
                 dw       20,20,10,10
                 dw       -10,10,20,20
                 dw       10,-10,20,20
                 dw       10,10,-20,20
                 dw       10,10,20,-20
                 dw       -10,10,-20,20
                 dw       10,-10,20,-20
                 dw       -10,-10,-20,-20
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

clipDx                  DB      0           ; also XX12+2
clipDxHigh              DB      0           ; also XX12+3
clipDxHighNonABS        DB      0           ; also XX12+3
clipDy                  DB      0           ; also XX12+4
clipDyHigh              DB      0           ; also XX12+5
clipGradient            DB      0
clipDxySign             DB      0
varX12p3                equ     clipDxySign
clipXGTY                DB      0
clipFlags               DB      0
SWAP                    DB      0
varYX                   DW      0
varRegX                 DB      0
varXX12p2               DB      0
clipXX13                 DB      0

CLIP:
; bounds check and the start to avoid dxy calcs if off screen, eliminating off screens first saves a lot of uncessary mul/div
ClipXX15XX12Line:

ClipV2:                 ld      bc,(UbnkPreClipY1)
                        ld      ix,(UbnkPreClipY2)
                        ld      hl,(UbnkPreClipX1)
                        ld      de,(UbnkPreClipX2)
                        break

                        xor     a
                        ld      (SWAP),a                    ; SWAP = 0
                        ld      a,d                         ; A = X2Hi
.LL147:                 ld      iyh,191                     ; we need to be 191 as its 128 + another bit set from 0 to 6, we are using iyh as regX
                                push    af
                                ld      a,iyh
                                ld      (regX),a
                                pop     af
                        or      ixh                         ; if (X2Hi L-OR Y2 Hi <> 0) or (Y2 > 191) set XX13 to 191, goto LL107             -- X2Y2 off screen
                        jr      nz, .LL107
                        ld      a,ixh
                        test    $80
                        jr      nz,.LL107
                        ld      iyh, 0                      ; regX = 0                                                                        -- X2Y2 on screen                                
                                push    af
                                ld      a,iyh
                                ld      (regX),a
                                pop     af
; XX13 = regX (i.e. iyh)      ( if XX13 = XX13 is 191 if (x2, y2) is off-screen else 0) we bin XX13 as not needed
; so XX13 = 0 if x2_hi = y2_hi = 0, y2_lo is on-screen,  XX13 = 191 if x2_hi or y2_hi are non-zero or y2_lo is off the bottom of the screen                       
.LL107                  ld      a,h                         ; If (X1 hi L-OR Y1) hi  goto LL83                   -- X1Y1 off screen and maybe X2Y2
                        or      b
                        jr      nz,.LL83
                        ld      a,c                         ; or (y1 lo > bottom of screen)
                        test    $80
                        jr      nz,.LL83
; If we get here, (x1, y1) is on-screen
                        ld      a,iyh                       ; iyh = xx13 at this point if  XX13 <> 0 goto LL108                                                        -- X1Y1 on screen, if we flagged X2Y2 off screen goto LL108 
                        cp      0
                        jr      nz, .LL108
.ClipDone:              ld      a,c                         ; LL146 (Clip Done)               Y1 = y1 lo, x2 = x2 lo, x1 = x1 lo y1 = y1 lo                                   -- Nothing off screen
                        ld      (UBnkNewY1),a
                        ld      a,ixl
                        ld      (UBnkNewY2),a
                        ld      a,l
                        ld      (UBnkNewX1),a
                        ld      a,e
                        ld      (UBnkNewX2),a
                        ClearCarryFlag                      ; carry is clear so valid to plot is in XX15(0to3)
                        ret                                 ; 2nd pro different, it swops based on swop flag around here.                       
.PointsOutofBounds:     scf                                 ; LL109 (ClipFailed) carry flag set as not visible
                        ret      
.LL108:                 ld      a,iyh
                        or      a
                        rra
                        ld      iyh,a                       ; (X2Y2 Off Screen)         XX13 = 95 (i.e. divide it by 2)                                                 -- X1Y1 on screen X2Y2 off screen
                                push    af
                                ld      a,iyh
                                ld      (regX),a
                                pop     af
.LL83:                  ld      a,iyh                       ; (Line On screen Test)      if XX13 < 128 then only 1 point is on screen so goto LL115                      -- We only need to deal with X2Y2                                
                        test    $80
                        jr      z, .LL115
                        ld      a,h                         ; If both x1_hi and x2_hi have bit 7 set, jump to LL109  to return from the subroutine with the C flag set, as the entire line is above the top of the screen
                        and     d
                        jr      nz, .PointsOutofBounds
                        ld      a,b                         ; If both y1_hi and y2_hi have bit 7 set, jump to LL109  to return from the subroutine with the C flag set, as the entire line is above the top of the screen
                        or      ixh
                        jr      nz, .PointsOutofBounds
                        ld      a,h                         ; If neither (x1_hi - 1) or (x2_hi - 1) have bit 7 set, jump to LL109 to return from the subroutine with the C  flag set, as the line doesn't fit on-screen
                        dec     a
                        ld      iyl,a                       ; using iyl as XX12+2 var
                                push    af
                                ld      a,iyl
                                ld      (varXX12p2),a
                                pop     af                        
                        ld      a,d
                        dec     a
                        or      iyl                         ; using iyl as XX12+2 var
                        jp      p, .PointsOutofBounds       
                        ld      a,c                         ; If y1_lo < y-coordinate of screen bottom, clear the C flag, otherwise set it
                        and     ixl
                        test    $80
                        jp      nz, .PointsOutofBounds      ;Both are positive but are they both > 127
;                        cp      $80
;                        ccf                                 ; flip carry flag for the sbc
;                        ld      a,b                         ; We do this subtraction because we are only interested in trying to move the points up by a screen if that might move the point into the space view portion of the screen, i.e. if y1_lo is on-screen
;                        sbc     0
;                        or      ixl                         ; If neither XX12+1 (ixk or Y2 low) or XX12+2 (ixh or Y2 high) have bit 7 set, jump to If neither XX12+1 or XX12+2 have bit 7 set, jump to If neither XX12+1 or XX12+2 have bit 7 set, jump to
;                        jp      p, .PointsOutofBounds
; Clip line: calulate the line's gradient                   
; here as an optimisation we make sure X1 is always < X2  later on  
.LL115:                 break
                        ClearCarryFlag
                        ld      a,e
                        sbc     a,l
                        ld      (clipDx),a
                        ld      a,d
                        sbc     a,h
                        ld      (clipDxHigh),a                ; later we will just move to sub hl,de
                        ld      (clipDxHighNonABS),a          ; it looks liek we need this later post scale loop
                        ClearCarryFlag
                        ld      a,ixl
                        sbc     c
                        ld      (clipDy),a
                        ld      a,ixh
                        sbc     a,b
                        ld      (clipDyHigh),a              ; so A = sign of deltay in effect
;So we now have delta_x in XX12(3 2), delta_y in XX12(5 4)  where the delta is (x1, y1) - (x2, y2))
                        push    hl                          ; Set S = the sign of delta_x * the sign of delta_y, so if bit 7 of S is set, the deltas have different signs
                        ld      hl,clipDxHigh
                        xor     (hl)                        ; now a = sign dx xor sign dy
                        ld      (varS),a                    ; DEBGU putting it in var S too for now
                        ld      (clipDxySign),a
.AbsDy:                 ld      a,(clipDyHigh)
                        test    $80
                        jr      z,.LL110                    ; If delta_y_hi is positive, jump down to LL110 to skip the following
                        ld      hl,(clipDy)                 
                        macronegate16hl                     ; Otherwise flip the sign of delta_y to make it  positive, starting with the low bytes
                        ld      (clipDy),hl                 
.LL110:                 ld      a,(clipDxHigh)
                        test    $80                         ; is it a negative X
                        jr      z,.LL111                    ; If delta_x_hi is positive, jump down to LL110 to skip the following
                        ld      hl,(clipDx)                 
                        macronegate16hl                     ; Otherwise flip the sign of delta_y to make it  positive, starting with the low bytes
                        ld      (clipDx),hl                 ; we still retain the old sign in NonABS version
.LL111:                 push    de
                        ld      hl,(clipDx)
                        ld      de,(clipDy)
.ScaleLoop:             ld      a,h                         ; At this point DX and DY are ABS values
                        or      d
                        jr      z,.CalculateDelta:
                        ShiftDERight1
                        ShiftHLRight1
                        jr      .ScaleLoop                  ; scaled down Dx and Dy to 8 bit, Dy may have been negative
.CalculateDelta:        ld      (clipDx),hl
                        ld      (clipDy),de     
; By now, the high bytes of both |delta_x| and |delta_y| are zero We know that h and d are both = 0 as that's what we tested with a BEQ
.LL113:                 xor     a
                        ld      (varT),a                    ; t = 0
                        ld      a,(clipDx)                  ; If delta_x_lo < delta_y_lo, so our line is more vertical than horizontal, jump to LL114
                        ld      hl,clipDy
                        JumpIfALTNusng  (hl), .LL114
; Here Dx >= Dy (we need an optimisation for pure horizontal and vert adding back in again)                        
.DxGTEDy:               ld      (varQ),a                    ; Set Q = delta_x_lo
                        ld      d,a                         ; d = also Q for calc
                        ld      a,(clipDy)                  ; Set A = delta_y_lo
                        call    LL28Amul256DivD             ; Call LL28 to calculate:  R (actually a reg) = 256 * A / Q   = 256 * delta_y_lo / delta_x_lo
                        ld      (varR),a                    ;
                        jr      .LL116                      ; Jump to LL116, as we now have the line's gradient in R
.LL114:                 ld      a,(clipDy)                  ; Set Q = delta_y_lo
                        ld      d,a
                        ld      (varQ),a
                        ld      a,(clipDx)                  ; Set A = delta_x_lo
                        call    LL28Amul256DivD             ; Call LL28 to calculate: R = 256 * A / Q  = 256 * delta_x_lo / delta_y_lo
                        ld      (varR),a                    ;
                        ld      hl,varT                     ; T was set to 0 above, so this sets T = &FF
                        dec     (hl)
.LL116:                 pop     de                          ; get back X2
                        pop     hl                          ; get back X1 into hl,
                        ld      a,(varR)                    ; Store the gradient in XX12+2 this can be optimised later
                        ld      (clipGradient),a
                        ld      iyl,a   
                                push    af
                                ld      a,iyl
                                ld      (varXX12p2),a
                                pop     af
                        ld      a,(varS)
                        ld      (clipDxySign),a             ;  Store the type of slope in XX12+3, bit 7 clear means ?Not needed as clipDxySign is used for varS earlier?
                                                            ; top left to bottom right, bit 7 set means top right to bottom left **CODE IS WRONG HERE A TEST IS BL to TR
                        ld      a,iyh                       ; iyh was XX13 from earlier 
                        cp      0                           ; If XX13 = 0, skip the following instruction
                        jr      z,.LL138                    ;
                        test    $80                         ; If XX13 is positive, it must be 95. This means (x1, y1) is on-screen but (x2, y2) isn't, so we jump to LLX117 to swap the (x1, y1) and (x2, y2)                       
                        jr      z,.LLX117                   ; coordinates around before doing the actual clipping, because we need to clip (x2, y2) but the clipping routine at LL118 only clips (x1, y1)
; If we get here, XX13 = 0 or 191, so (x1, y1) is off-screen and needs clipping
.LL138                  call    ClipPointHLBC               ; Call LL118 to move (x1, y1) along the line onto the screen, i.e. clip the line at the (x1, y1) end
                        ld      a,iyh                       ; If XX13 = 0, i.e. (x2, y2) is on-screen, jump down to LL124 to return with a successfully clipped line
                        test    $80
                        jr      z,.LL124
; If we get here, XX13 = 191 (both coordinates are off-screen)
.LL117:                 ld      a,h                         ; If either of x1_hi or y1_hi are non-zero, jump to
                        or      c                           ; LL137 to return from the subroutine with the C flag
                        jp      nz, .PointsOutofBounds      ; set, as the line doesn't fit on-screen
                        ld      a,ixl                       ; If y1_lo > y-coordinate of the bottom of the screen
                        test    $80                         ; jump to LL137 to return from the subroutine with the
                        jp      nz,.PointsOutofBounds       ; C flag set, as the line doesn't fit on-screen
; If we get here, XX13 = 95 or 191, and in both cases (x2, y2) is off-screen, so we now need to swap the (x1, y1) and (x2, y2) coordinates around before doing
; the actual clipping, because we need to clip (x2, y2) but the clipping routine at LL118 only clips (x1, y1)
.LLX117:                ex      de,hl                       ;  swap X1 and X2
                        push    ix                          ;  swap Y1 and Y2
                        push    bc
                        pop     ix
                        pop     bc
                        call    .LL138                       ;  Call LL118 to move (x1, y1) along the line onto the screen, i.e. clip the line at the (x1, y1) end
                        ld      a,(SWAP)
                        dec     a
                        ld      (SWAP),a                    ; Set SWAP = &FF to indicate that we just clipped the line at the (x2, y2) end by swapping the coordinates (the DEC does this as we set SWAP to 0 at the start of this subroutine)
.LL124:                 jp      .ClipDone                    ; now put points in place

; Move a point along a line until it is on-screen point is held in HL(X) BC(Y) LL118
; iyh still holds XX13 iyl still holds gradient
ClipPointHLBC:          ld      a,h                         ; If x1_hi is positive, jump down to LL119 to skip the following
                        test    $80
                        jr      z,.LL119
.X1isNegative:          ld      (varS),a                    ;  Otherwise x1_hi is negative, i.e. off the left of the screen, so set S = x1_hi
                        push    hl,,de,,bc
                        call    LL120                       ;  Call LL120 to calculate:   (Y X) = (S x1_lo) * XX12+2      if T = 0   = x1 * gradient
                                                            ;                             (Y X) = (S x1_lo) / XX12+2      if T <> 0  = x1 / gradient
                                                            ;  with the sign of (Y X) set to the opposite of the line's direction of slope
                        pop    hl,,de,,bc                   ;  get coordinates back
                        ld      hl,(varYX)
;                        ex      hl,de
                    ;    ld      hl,bc                       
                        add     hl,bc                       ; y1 = y1 + varYX
                        ld      bc,hl
                        ld      hl,0                        ; Set x1 = 0
 ;                       pop     de
                        jr      .LL134                      ; in BBC is set x to 0 to force jump, we will just jump
.LL119:                 cp      0
                        jr      z,.LL134                    ;  If x1_hi = 0 then jump down to LL134 to skip the following, as the x-coordinate is already on-screen (as 0 <= (x_hi x_lo) <= 255)
                        dec     a
                        ld      (varS),a                    ;  Otherwise x1_hi is positive, i.e. x1 >= 256 and off the right side of the screen, so set S = x1_hi - 1
                        push    hl,,de,,bc
                        call    LL120                      ;  Call LL120 to calculate: (Y X) = (S x1_lo) * XX12+2      if T = 0  = (x1 - 256) * gradient
                                                            ;                           (Y X) = (S x1_lo) / XX12+2      if T <> 0 = (x1 - 256) / gradient
                                                            ;  with the sign of (Y X) set to the opposite of theline's direction of slope
                        pop     hl,,de,,bc
                        push    de                          ; Set y1 = y1 + (Y X)
                        ld      hl,(varYX)
                        ex      hl,de
                        ld      hl,bc                       
                        add     hl,bc                       ; y1 = y1 + varYX
                        ld      hl,255                      ; Set x1 = 255
                        pop     de
; We have moved the point so the x-coordinate is on screen (i.e. in the range 0-255), so now for they-coordinate
.LL134:                 ld      a,b                         ; If y1_hi is positive, jump down to LL119 to skip the following
                        test    $80
                        jr      z,.LL135
                        ld      a,b
                        ld      (varS),a                    ;  Otherwise y1_hi is negative, i.e. off the top of the screen, so set S = y1_hi
                        ld      a,c                         ;  Set R = y1_lo
                        ld      (varR),a                    
                        push    hl,,de,,bc
                        call    LL123                       ;  Call LL123 to calculate: (Y X) = (S R) / XX12+2      if T = 0  = y1 / gradient
                                                            ;                           (Y X) = (S R) * XX12+2      if T <> 0 = y1 * gradient
                                                            ;  with the sign of (Y X) set to the opposite of the line's direction of slope
                        pop     hl,,de,,bc
                        push    de                                    
                        ex      hl,de
                        ld      hl,(varYX)
                        add     hl,de                       ; we don't need to swap back as its an add, Set x1 = x1 + (Y X)
                        pop     de
                        ld      bc,0                        ; Set y1 = 0
.LL135:                 ld      a,c                         ; if bc < 128 then no work to do
                        and     $80
                        or      b                           ; here we see if c bit 8 is set or anything in b as we know if its 0 this would mean there is no need to clip
                        ret     z
                        push    hl                          
                        ld      hl,bc
                        ld      bc,128
                        or      a
                        sbc     hl,bc                       ; hl =  (S R) = (y1_hi y1_lo) - 128
                        ld      (varRS), hl                 ; and now RS (or SR)
                        ld      a,h
                        pop     hl
                        test    $80                         ; If the subtraction underflowed, i.e. if y1 < 192, then y1 is already on-screen, so jump to LL136 to return from the subroutine, as we are done
                        ret     nz
; If we get here then y1 >= 192, i.e. off the bottom of the screen 
.LL139:                 push    hl,,de,,bc
                        call    LL123                       ;  Call LL123 to calculate: (Y X) = (S R) / XX12+2      if T = 0  = y1 / gradient
                                                            ;                           (Y X) = (S R) * XX12+2      if T <> 0 = y1 * gradient
                                                            ;  with the sign of (Y X) set to the opposite of the line's direction of slope
                        pop     hl,,de,,bc
                        push    de
                        ex      hl,de
                        ld      hl,(varYX)
                        add     hl,de                       ; we don't need to swap back as its an add, Set x1 = x1 + (Y X)
                        ld      bc,128                      ; set bc to 128 bottom of screen
                        pop     de
.LL136:                 ret                                 ;  Return from the subroutine


; Calculate the following:   * If T = 0  (more vertical than horizontal), (Y X) = (S x1_lo) * XX12+2
;                            * If T <> 0 (more horizontal than vertical), (Y X) = (S x1_lo) / XX12+2
;                              giving (Y X) the opposite sign to the slope direction in XX12+3.
; Other entry points        LL122                Calculate (Y X) = (S R) * Q and set the sign to the opposite of the top byte on the stack
LL120:                  break
                        ld      a,l                          ; Set R = x1_lo
                        ld      (varR),a
                        call    LL129                        ;  Call LL129 to do the following:  Q = XX12+2   = line gradient  A = S EOR XX12+3 = S EOR slope direction (S R) = |S R| So A contains the sign of S * slope direction
                        push    af                           ;  Store A on the stack so we can use it later
                        push    bc
                        ld      b,a
                        ld      a,(varT)                     ; instead : (Y X) = (S R ) / Q
                        cp      0
                        ld      a,b
                        pop     bc                           ; we can't use af as that would disrupt the flags
                        jr      nz, LL121
; The following calculates:  (Y X) = (S R) * Q using the same shift-and-add algorithm that's documented in MULT1
LL122:                  ld      a,(clipGradient)
                        ld      (varQ),a; optimise
                        call    HLequSRmulQdiv256
                        ld      (varYX),hl
                        pop     af
                        test    $80
                        jp      z,LL133
                        ret
; Calculate the following: * If T = 0,  calculate (Y X) = (S R) / XX12+2 (actually SR & XX12+2 /256)
;                          * If T <> 0, calculate (Y X) = (S R) * XX12+2
;                          giving (Y X) the opposite sign to the slope direction in XX12+3.
;
; Other entry points:      LL121                Calculate (Y X) = (S R) / Q and set the sign to the opposite of the top byte on the stack
;                          LL133                Negate (Y X) and return from the subroutine
;                          LL128                Contains an RTS

LL123:                  break
                        call    LL129           ;  Call LL129 to do the following: Q = XX12+2   = line gradient  A = S EOR XX12+3 = S EOR slope direction (S R) = |S R| So A contains the sign of S * slope direction
                        push    af                           ;  Store A on the stack so we can use it later
                        push    bc                          ; If T is non-zero, so it's more horizontal than vertical, jump down to LL121 to calculate this
                        ld      b,a
                        ld      a,(varT)                     ; instead : (Y X) = (S R) * Q
                        cp      0
                        ld      a,b
                        pop     bc
                        jr      nz, LL122
; The following calculates: (Y X) = (S R) / Q using the same shift-and-subtract algorithm that's documented in TIS2, its actually X.Y=R.S*256/Q
;LL121:                  ld      hl,(varRS)
;                        ex      hl,de
;                        ld      a,(varQ)
;                        ld      b,0
;                        ld      c,a
;                        call    DEequDEDivBC
;                        ex      de,hl
;                        ld      (varYX),hl      ; write out XY
LL121:                 ld      de,$FFFE                    ;   set XY to &FFFE at start, de holds XY                        
                        ld      hl,(varRS)                  ; hl = RS
                        ld      a,(varQ)
                        ld      b,a                         ; b = q
.LL130:                 ShiftHLLeft1                        ; RS *= 2
                        ld      a,h
                        jr      c,.LL131                    ; if S overflowed skip Q test and do subtractions
                        JumpIfALTNusng b, .LL132            ; if S <  Q = 256/gradient skip subtractions
.LL131:                 ccf                                 ; clear carry
                        sbc     a,b                         ; q
                        ld      h,a                         ; h (s)
                        ld      a,l                         ; r
                        sbc     a,0                         ; 0 - so in effect SR - Q*256
                        scf                                 ; set carry for next rolls
.LL132:                 ShiftDELeft1                        ; Rotate de bits left
                        jr      c,.LL130                    ; 
                        pop     af              ; get back sign
                        test    $80
                        ret     z               ; if negative then return with value as is reversed sign
LL133:                  ld      hl,(varYX)      ; may not actually need this?
                        NegHL
                        ld      (varYX),hl
LL128:                  ret







; Do the following, in this order:  Q = XX12+2
;                                   A = S EOR XX12+3
;                                   (S R) = |S R|
; This sets up the variables required above to calculate (S R) / XX12+2 and give the result the opposite sign to XX13+3.
LL129:                  ld      a,(clipGradient)
                        ld      (varQ),a                    ;Set Q = XX12+2
                        ld      a,(varS)                    ; If S is positive, jump to LL127
                        push    hl,,af
                        test    $80
                        jr      z,.LL127
                        ld      hl,(varRS)                  ; else SR = | SR|
                        NegHL
                        ld      (varRS),hl
.LL127:                 ld      hl,clipDxySign
                        pop     af
                        xor     (hl)                        ; a = S XOR clipDxySign
                        pop     hl
                        ret


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
      ;break                                                                             ; ObjectInFront:
DrawLines:              ld	a,$65 ; DEBUG
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
                        call        CLIP
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
    