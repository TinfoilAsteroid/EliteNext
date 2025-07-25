
starty                  DW     $FFFF
endy                    DW     $FFFF
traingleColor           DB     $CF
        IFDEF SOLIDTRIANGLES
SaveArrayS1             DS     128*2
SaveArrayS2             DS     128*2
        ENDIF
        IFDEF Add_l2_drawHorzClipY
l2_drawHorzClipY:       
.ClipY:                 ex      de,hl                       ; get X1 into de
.ClipDE:                bit     7,d
                        jr      z,.DEPositive
.DENegative:            ld      de,0
                        jp      .ClipDEDone
.DEPositive:            ld      a,d
                        and     a
                        jp      z,.ClipDE127
.ClipDE256:             ld      de,127
                        jp      .ClipDEDone
.ClipDE127:             bit     7,e
                        jp      z,.ClipDEDone
                        ld      de,127
.ClipDEDone:
.AdjustStartY:          ld      hl,(starty)
                        call    CompareHLDESgn           ; if de < HL
                        jr      z,.AdjustEndY               ; 
                        jr      c,.AdjustEndY               ; 
.ClipStartY:            ld      (starty),de                 ; .
.AdjustEndY:            ld      hl,(endy)                   ; is endy still uninitialised
.InitEndY:              ld      a,h                         ;
                        and     l                           ;
                        cp      $FF                         ;
                        jr      z,.ForceEndYSet
.CheckEndY:             call    CompareHLDESgn           ; if de < HL
                        ret     z
                        ret     nc
.ForceEndYSet:          ld      (endy),de
                        ret
        ENDIF

        
l2_drawVertClip:        ld      hl,(y1)
                        ld      de,(y2)
                        call    CompareHLDESgn
                        jr      nc,.y1ltey2
                        ex      de,hl
.y1ltey2:               bit     7,h
                        jp      z,.y1Positive
                        ld      hl,0
.y1Positive             ld      a,d
                        and     a
                        jp      z,.y2lt255
                        ld      e,127
                        jp      .y2Clipped
.y2lt255:               bit     7,e
                        jp      z,.y2Clipped
                        ld      e,127
.y2Clipped:             ld      bc,(x1)
                        ld      b,l
                        ld      d,e
                        ld      e,$BF
                        jp      l2_draw_vert_line_to                ; ">bc = row col d = to position, e = color"

            DISPLAY "TODO: May be able to optimise as x1 and x2 should already be 8 bit"
l2_drawHorzClip:        ld      hl,(x1)
                        ld      de,(x2)
                        call    CompareHLDESgn
                        jr      nc,.x1ltex2
                        ex      de,hl
.x1ltex2:               bit     7,h
                        jp      z,.x1Positive
                        ld      hl,0
.x1Positive             ld      a,d
                        and     a
                        jp      z,.x2Clipped
                        ld      e,255
.x2Clipped:             ld      bc,(y1)
                        ld      b,c
                        ld      c,l
                        ld      d,e
                        ld      e,$BF
                        jp      l2_draw_horz_line_to                ; "bc = left side row,col, d right pixel, e = color"

        IFDEF Add_l2_drawVertClipY
l2_drawVertClipY:       bit     7,d                     ; i = (py1<0?0:py1);
                        jr      z,.PYIsOK
.SetPYTo0:              ld      de,0
.PYIsOK:                ld      hl,(starty)
                        IsHLEqu255
                        jp      z,.UpdateStartY
                        call    CompareHLDESgn       ; or starty > py
                        jr      nc,.UpdateStartY        ;
                        jp      .PrepareUpdateArray
.UpdateStartY:          ld      (starty),de
.PrepareUpdateArray:    JumpIfRegLTE c, 127, .UpdateCounters ; we loop from 
                        ld      c,127
.UpdateEndY:            ld      (endy),bc               ; save BC to endy y as its now clamped, thsi frees up BC regsiters
.UpdateCounters:        ld      hl,ix                   ; get target array index and set it to 
                        add     hl,de                   ; targetArray[de]
                        add     hl,de                   ; .
                        ld      a,c                     ; now set up B as an iterator 
                        sub     b                       ; for py2 - py1 + 1 entries
                        inc     a                       ; .
                        ld      b,a                     ; .
                        ld      de,ix                   ; we don't need de anymore to move ix for faster instructions
.UpdateArray:           ld      (hl),de                 ; use sjasm fake as it does (hl)=e,inc hl, (hl)=d,inc hl
                        inc     a                       ; use a as a counter for the end when we update EndY
                        djnz    .UpdateArray            ; .
                        ret                             ; we are now done
        ENDIF


; ">l2_draw_any_line, bc = y0,x0 de=y1,x1,a=color: determines if its horizontal, vertical or diagonal then hands off the work"
; b - y0 c - x0, d - y1 e - x1 a - colour
l2_draw_any_line:       ex		af,af'              ; save colour into a'
                        ld		a,c                 ; if x and e are the same its horizontal
                        cp		e
                        jr		z,.HorizontalLineCheck
                        ld		a,b                 ; if b and d are the same its vertica;
                        cp		d
                        jr		z,.VerticalLine
; use jp and get a free ret instruction optimisation                        
.DiagonalLine:		    ex		af,af'			     ; get colour back into a
                        jp		l2_draw_diagonal

.HorizontalLineCheck:   ld      a,b
                        cp      d
                        jr      z, .SinglePixel
.HorizontalLine:        ex		af,af'              ; get colour back into a
                        ld		d,e				    ; set d as target right pixel
                        ld		e,a				    ; e holds colour on this call
                        jp		l2_draw_horz_line_to
.VerticalLine:          ex		af,af'
                        ld		e,a				    ; e holds colour on this call
                        jp		l2_draw_vert_line_to
.SinglePixel:           ex		af,af'              ; get colour back into a
                        l2_plot_macro; jp      l2_plot_pixel
                        ret

x1                      dw 0
y1                      dw 0
x2                      dw 0
y2                      dw 0
savex1                  dw 0
savey1                  dw 0
savex2                  dw 0
savey2                  dw 0
temp                    dw 0
longest:                DB 0
x1Work:                 DW 0
y1Work:                 DW 0
x2Work:                 DW 0
y2Work:                 DW 0
x_pos:                  DW 0
y_pos:                  DW 0
x_pos_end:              DW 0
y_pos_end:              DW 0
clip_xmax:              DW 0
clip_xmin:              DW 0
sign_x                  DW 0
sign_y                  DB 0
delta_x                 DW 0
delta_y                 DW 0
delta_y_x               DW 0 ; holds the compressed version for elite line draw
delta_x_step            DW 0
delta_y_step            DW 0
linetemp                DW 0
gradient                DW 0
tSlope                  DW 0
msd                     DW 0
error                   DW 0
set_exit                DB 0
rem                     DW 0
InstrDECBC              equ $0B
InstrINCBC              equ $03
InstrDECIY              equ $2B
InstrINCIY              equ $23

MACROAequBMinusC16:     MACRO   pA, pB, pC
                        ld      hl,(pB)                         ;       error = delta_y_step - delta_x;
                        ld      de,(pC)                         ; .
                        ClearCarryFlag                          ; .
                        sbc     hl,de                           ; .
                        ld      (pA),hl    
                        ENDM                      
;--- Swaps point 1 and point 2 around (i.e x1 y1 <--> x2 y2)
SwapCoords:             ld      hl,(y1)                         ;       then swap point 1 and point 2
                        ld      de,(y2)                         ;       .
                        ld      (y1),de                         ;       .
                        ld      (y2),hl                         ;       .
                        ld      hl,(x1)                         ;       .
                        ld      de,(x2)                         ;       .
                        ld      (x1),de                         ;       .
                        ld      (x2),hl                         ;       .
                        ret

        ; DEFINE SPLITLINE 1
    
        ;DEFINE CLIPPED_LINEX 1
        DEFINE SPLITORLINEX  1
        IFDEF SPLITLINE:
l2_draw_clipped_line:
        ENDIF
        IFDEF SPLITORLINEX
l2_draw_clipped_line:
        ENDIF
        IFDEF CLIPPED_LINEX:
l2_draw_clipped_lineX:        
        ENDIF
        IFDEF SPLITORLINEX
                        ld      hl,(y1)                         ; if (y1 > y2)
                        ld      de,(y2)                         ; .
                        call    CompareHLDESgn                  ; .
                        jp      c,.NoSwapCoords
.SwapCoords:            call    SwapCoords
.NoSwapCoords:
.CalcDX:                ld      de,(y1)                         ; Calculate |dy|
                        ld      hl,(y2)                         ; .
                        ClearCarryFlag                          ; .
                        sbc     hl,de                           ; .
                        ld      iy,hl                           ; iy = |dy|
.CalcDy:                ld      de,(x1)                         ; Calculate |dx|
                        ld      hl,(x2)                         ; .
                        ld      b,0                             ; assume x1 < x2 and assume no negate needed
                        call    CompareHLDESgn                  ;
                        jp      nc,.DxNoSwap                     ;
.DxSwap:                ex      de,hl                           ; swap just x over
                        inc     b                               ; and flag that we had to do it
.DxNoSwap:              ClearCarryFlag                          ;
                        sbc     hl,de                           ;
                        ld      ix,hl                           ; ix = |dx|
.CheckForHuge:          ld      a,ixh                           ; if either dx or dy > 255 then split line
                        or      iyh                             ; .
                        jp      nz, .BreakNeeded                ; .
.ChecktGT180:           ld      a,ixl
                        cp      180
                        jp      nc,.BreakNeeded
                        ld      a,iyl                        
                        cp      180
                        jp      nc,.BreakNeeded
                        jp      .noBreakNeeded
.BreakNeeded:           ldCopy2Byte y1, savey1                  ;       savey1 = y1                     create savey1 (y1) to savey2 (y break)
                        ShiftIYRight1                           ;       savey2 = y1 + (work_dy/2)
                        ld      hl,(y1)                         ;       .   
                        ClearCarryFlag                          ;       .
                        ld      de,iy
                        adc     hl,de                           ;       .
                        ld      (savey2),hl                     ;       .
                        ld      (y1),hl                         ;       y1     = savey2, y2 untouched   create y1 (break) to y2
                        dec     b                               ;       if b was 1 then decb would set z flag so we know that x1 > x2
                        jp      nz,.X1gtX2
.X1lteX2:               call    SwapCoords
.X1gtX2:                ldCopy2Byte x1, savex1                  ;       savex1 = x1                     create savex1 (x1) to savex2 (x break)
                        ShiftIXRight1                           ;       savex2 = x1 + (work_dx/2)
                        ld      hl,(x1)                         ;       .   
                        ClearCarryFlag                          ;       .
                        ld      de,ix
                        adc     hl,de                           ;       .
                        ld      (savex2),hl                     ;       .
                        ld      (x1),hl                         ;       x1     = savex1, x2 untouched  create x1 (break to x2)
        ENDIF
        IFDEF SPLITLINE
                        call    l2_draw_short_line              ;       drawshortLine
        ENDIF
        IFDEF CLIPPED_LINEX
                        call    l2_draw_clipped_line
        ENDIF
        IFDEF SPLITORLINEX
                        ldCopyWord savex1,x1
                        ldCopyWord savey1,y1
                        ldCopyWord savex2,x2
                        ldCopyWord savey2,y2
.noBreakNeeded:         // Falls straight into l2_draw_short_line
        ENDIF
        IFDEF SPLITLINE:
l2_draw_short_line:     ; check out of bounds     
        ENDIF
        IFDEF CLIPPED_LINEX
l2_draw_clipped_line:        
        ENDIF
        IFDEF SPLITORLINEX
CheckForOnScreen:       ld      hl,(x1)
                        ld      de,(x2)
.X1X2NegativeCheck:     bit     7,h                             ; if they are both negative then bail out
                        jr      z,.X1X2NotNegative
                        bit     7,d
.X1X2IsNegative:        ret     nz
.X1X2NotNegative:       ld      a,h                             ; if they are both not negative then if one is negative that is good
                        xor     d
                        jp      m,.X1X2SpanScreen
.X1X2BothPositive:      ld      a,h                             ; if x1 or x2 high is zero then at least one pixel is on screen
                        and     a
                        jp      z,.X1X2SpanScreen
                        ld      a,d                             ; if x1 was > 255 then if x2 > 255 bail out
                        and     a
                        ret     nz
.X1X2SpanScreen:        ld      hl,(y1)
                        ld      de,(y2)
.Y1Y2NegativeCheck:     bit     7,h                             ; if they are both negative then bail out
                        jr      z,.Y1Y2NotNegative
                        bit     7,d
.Y1Y2IsNegative:        ret     nz
.Y1Y2NotNegative:       ld      a,h                             ; if they are both not negative then if one is negative that is good
                        xor     d
                        jp      m,.Y1Y2SpanScreen
.Y1Y2BothPositive:      ld      bc,128                          ; if they are both positive and at least one is < 128 then carry on
                        call    CompareHLBC
                        jr      c,.Y1Y2SpanScreen
                        ex      de,hl                           ; save y1 into de
                        call    CompareHLBC
                        jr      c,.Y1Y2SpanScreen
                        ret
.Y1Y2SpanScreen:        
CheckForHorizontal:     call    CompareHLDESame                 ; de = saved y1 , hl = y2
                        jp      z, l2_drawVertClip
CheckForVertical:       ld      hl,(x1)
                        ld      de,(x2)
                        call    CompareHLDESame
                        jp      z, l2_drawHorzClip
                        ; Need horizontal and vertical optimisation code in at thispoint
CheckForSwap:           ld      hl,(y1)                         ; if (y1 > y2)
                        ld      de,(y2)                         ; .
                        call    CompareHLDESgn                  ; .
                        jp      c,.NoSwapCoords
.SwapCoords:            call    SwapCoords
                        ; Default in sign and clip ranges, sign 16 bit for now
.NoSwapCoords:          ld      hl,0                            ; clip_xmin = 0; 
                        ld      (clip_xmin),hl                  ; .
                        ld      l,255                           ; clip xmax = 255;
                        ld      (clip_xmax),hl                  ; .
                        ld      hl,1                            ; sign_x = 1
                        ld      (sign_x),hl                     ; .
                        ; if moving right to left then swap signs and clip
                        ld      hl,(x1)                         ; if x1 > x2 
                        ld      de,(x2)                         ; .
                        call    CompareHLDESgn                  ; .
                        jr      c,.X1tlX2                       ; .
.X1gteX2:               ld      hl, -1                          ;        sign_x = 01
                        ld      (sign_x),hl                     ;        .                      
                        ld      hl,(x1)                         ;        x1 = -x1;
                        macronegate16hl                         ;        .
                        ld      (x1),hl                         ;        .
                        ld      de,(x2)                         ;        x2 = -x2;
                        macronegate16de                         ;        .
                        ld      (x2),de                         ;        .
                        ld      hl,-255                         ;        clip_xmin =-255;
                        ld      (clip_xmin),hl                  ;        .
                        ld      hl,0                            ;        clip_xmax = 0;
                        ld      (clip_xmax),hl                  ;        .
.X1tlX2:                                                        ; 
                        ; calculate deltas
.DxEquX2MinusX1:        ld      hl,(x2)                         ; delta_x = x2 - x1;
                        ld      de,(x1)                         ; .
                        ClearCarryFlag                          ; .
                        sbc     hl,de                           ; .
                        ld      (delta_x),hl                    ; .  
.DyEquY2MinusY1:        ld      hl,(y2)                         ; delta_y = y2 - y1;
                        ld      de,(y1)                         ; .
                        ClearCarryFlag                          ; .
                        sbc     hl,de                           ; .
                        ld      (delta_y),hl                    ; .
.ScaleDeltaXY:          ld      de,(delta_x)                    ; we already have delta y but x could be negative
                        ld      b,0
                        bit     7,d
                        jp      z,.DeltaYABSDone                ; de = | de |, b = 1 to denote negative needs resetting
                        inc     b
                        macronegate16de                     
.DeltaYABSDone:
/*.ScaleHighLoop:         ld      a,d
                        or      h
                        jr      z,.HighScaleDone
                        ShiftDERight1
                        ShiftHLRight1
                        jp      .ScaleHighLoop
.HighScaleDone:
.LowScaleLoop:          ld      a,e
                        or      l
                        and     $80
                        jr      z,.LowScaleDone
                        ShiftDERight1
                        ShiftHLRight1
                        jp      .LowScaleLoop
.LowScaleDone:          bit     0,b
                        jr      z,.DeltaDone
.SortDXSign:            macronegate16de
.DeltaDone:             ld      (delta_x),de
                        ld      (delta_y),hl*/
.DeltaXStepCalc:        ld     hl, (delta_x) 
                        ClearCarryFlag                          ; delta_x_step = 2 * delta_x;
                        adc     hl,hl                           ; .
                        ld      (delta_x_step),hl               ; .
.DeltaYStepCalc:        ld     hl, (delta_y)
                        ClearCarryFlag                          ; delta_y_step = 2 * delta_y;
                        adc     hl,hl                           ; .
                        ld      (delta_y_step),hl               ; .
                        ld      hl,(x1)                         ; x_pos = x1;
                        ld      (x_pos),hl                      ; .
                        ld      de,(y1)                         ; y_pos = y1;
                        ld      (y_pos),de                      ; .
                        ; check if we are workign on dx or dy
.CompareDxDy:           ld      hl,(delta_x)                    ; if (delta_x >= delta_y)
                        ld      de,(delta_y)
                        call    CompareHLDESgn
                        jp      c, LineDrawDxLTDy
;.......................DxGteDy branch.............................................................................................
LineDrawDxGteDy:        ld      hl,(delta_y_step)               ;       error = delta_y_step - delta_x;
                        ld      de,(delta_x)                    ;       .
                        ClearCarryFlag                          ;       .
                        sbc     hl,de                           ;       .
                        ld      (error),hl                      ;       .
                        ZeroA                                   ;       set exit false (0 == false)
                        ld      (set_exit),a                    ;       .
                        ; clipping of negative y1
                        ld      hl,(y1)                         ;       if (y1 < 0)
                        bit     7,h                             ;       .
                        jp      z,.y1GTE0                       ;       .
.y1LT0:                 ld      hl,(y1)                         ;           temp = (2 * (0 - y1) - 1) * delta_x;
                        macronegate16hl                         ;               hl = |y1|
                        ClearCarryFlag
                        adc     hl,hl                           ;               hl = (2 * |y1|)
                        dec     hl                              ;               hl = (2 * |y1| - 1)
                        ld      de,(delta_x)                    ;               hl = hl * delta_x
                        call    HLequHLmulDE2sc; replaces mulHLbyDE2sc                    ;               .
                        ld      (temp),hl                       ;               save to temp
                        ld      bc,hl                           ;            msd = temp / delta_y_step
                        ld      de,(delta_y_step)               ;               BC = BC / DE, HL = BC % DE
                        call    Floor_DivQ                      ;               .
                        ld      (msd),bc                        ;               .
                        ld      hl,(x_pos)                      ;            x_pos += msd
                        ClearCarryFlag
                        adc     hl,bc                           ;            .
                        ld      (x_pos),hl                      ;            .
                        ld      de,(clip_xmax)                  ;            if (x_pos >= clip_xmax)
                        call    CompareHLDESame                 ;            .
                        jp      z,.xposLTEClipxmax              ;            .
                        call    CompareHLDESgn                  ;            .
                        ret     nc                              ;               return
.xposLTEClipxmax:       ld      hl,(x_pos)                      ;            if (x_pos >= clip_xmin)  
                        ld      de,(clip_xmin)                  ;            .
                        call    CompareHLDESgn                  ;            .
                        jp      c,.xposLTxmin                   ;            .
.xposGTExmin:           ld      hl,(msd)                        ;               rem = temp - (msd * delta_y_step) (its really IY from floor_divq)
                        ld      de,(delta_y_step)               ;                   de = msd * delta_y_step
                        call    HLequHLmulDE2sc; replaces mulHLbyDE2sc                    ;                   .
                        ex      de,hl                           ;                   .
                        ld      hl,(temp)                       ;                   hl = temp - de
                        ClearCarryFlag                          ;                   .
                        sbc     hl,de                           ;                   .
                        ld      (rem),hl                        ;                   .
                        ld      de,0                            ;               y_pos = 0
                        ld      (y_pos),de                      ;               .
                        ld      de,(rem)                        ;               error -= rem + delta_x
                        ClearCarryFlag
                        adc     hl,de                           ;                   de = rem+delta_x
                        ex      de,hl                           ;                   .  
                        ld      hl,(error)                      ;                   hl = error - de
                        ClearCarryFlag                          ;                   .
                        sbc     hl,de                           ;                   .
                        ld      (error),hl                      ;                   write to error
                        ld      hl,(rem)                        ;               if (rem > 0)
                        ld      a,h                             ;               .
                        or      l                               ;               .
                        jp      z,.remLte0                      ;               .
.remGT0:                ld      hl,(x_pos)                      ;                   x_pos += 1;
                        inc     hl                              ;                   .
                        ld      (x_pos),hl                      ;                   .
                        ld      hl,(error)                      ;                   error += delta_y_step;
                        ld      de,(delta_y_step)               ;                   .
                        ClearCarryFlag                          ;                   .
                        adc     hl,de                           ;                   .
                        ld      (error),hl                      ;                   .
.remLte0:               ld      a,1                             ;               set exit = true
                        ld      (set_exit),a                    ;               .                        
.xposLTxmin:                                                    
.y1GTE0:                ld      a,(set_exit)                    ;           if (!set_exit && x1 < clip_xmin)
                        and     a                               ;           .
                        jp      nz,.exit_false                  ;           .   Exit if set_exit is true
                        ld      hl,(x1)                         ;           .
                        ld      de,(clip_xmin)                  ;           .   Exit if x1 > xmin
                        call    CompareHLDESgn                  ;           .
                        jp      nc,.exit_false                  ;           .
                        ex      de,hl                           ;               temp = delta_y_step * (clip_xmin - x1)
                        ld      de,(x1)                         ;                   (clip_xmin - x1) (already have clip_xmin in de)
                        ClearCarryFlag                          ;                   .
                        sbc     hl,de                           ;                   .
                        ld      de,(delta_y_step)               ;                   hl = delta_y_step * (clip_xmin - x1)
                        call    HLequHLmulDE2sc; repalces mulHLbyDE2sc                    ;                   .
                        ld      (temp),hl                       ;                   .
.msdEQtempDIVdxstep:    ld      bc,hl                           ;               msd = temp / delta_x_step
                        ld      de,(delta_x_step)               ;                  BC = BC / DE, HL = BC % DE
                        call    Floor_DivQ                      ;                  .
                        ld      (msd),bc                        ;                  .
                        ld      iy,hl                           ;                  save BC%DE into HL (temp % delta x step0
.yposPlusmsd:           ld      hl,(y_pos)                      ;               y_pos += msd
                        ClearCarryFlag                          ;                   bc already is msd
                        adc     hl,bc                           ;                   hl += bc
                        ld      (y_pos),hl                      ;                   .
                        ld      hl,iy                           ;               rem = temp % delta_x_step (which is in IY)
                        ld      (rem),hl                        ;               .
                        ld      hl,(y_pos)                      ;           if ((y_pos > 127) || (y_pos == 127 && rem >= delta_x))
                        ld      de,127                          ;           .
                        call    CompareHLDESame                 ;           .    if y_pos != clipxmax skip the abort test
                        jr      nz,.YPosNotClipymax             ;           .
                        ld      hl,(rem)                        ;           .    if rem < delta_y  skip the abort test
                        ld      de,(delta_x)                    ;           .
                        call    CompareHLDESgn                  ;           .
                        ret     c                               ;           .
.YPosNotClipymax:       ex      de,hl                           ;           .    swap over xpos and max to compare xpos > xmax                      
                        call    CompareHLDESgn                  ;           .    if xpos > clipxmax then return (i.e clipxmax - xpos had a carry)
                        ret     c
.yposLT127:             ld      hl,(clip_xmin)                  ;               x_pos = clip_xmin;
                        ld      (x_pos),hl                      ;               .
                        ld      hl,(error)                      ;               error += rem
                        ld      de,(rem)                        ;               .
                        ClearCarryFlag                          ;               .
                        adc     hl,de                           ;               .
                        ld      (error),hl                      ;               .
                        ld      hl,(rem)                        ;               if (rem >= delta_x)
                        ld      de,(delta_x)                    ;               .
                        call    CompareHLDESgn                  ;               .
                        jp      c,.remLTDeltaX                  ;               .
.remGTEDeltaX:          ld      hl,(y_pos)                      ;                   y_pos++
                        inc     hl
                        ld      (y_pos),hl
                        ld      hl,(error)                      ;                    error -= delta_x_step;
                        ld      de,(delta_x_step)               ;                    .
                        ClearCarryFlag                          ;                    .
                        sbc     hl,de                           ;                    .
                        ld      (error),hl                      ;                    .
.remLTDeltaX:
.exit_false:            ld      hl,(x2)                         ;           x_pos_end = x2;
                        ld      (x_pos_end),hl                  ;           .
                        ld      hl,(y2)                         ;           if (y2 > 127)
                        ld      de,127                          ;           .
                        call    CompareHLDESame                 ;           .   if y2 is zero fails check
                        jp      z,.y2LTE127                     ;           .
                        call    CompareHLDESgn                  ;           .   if y2 < 127 then there is carry so fails check
                        jp      c,.y2LTE127                      ;           .
.y2GT127:               ld      hl,127                          ;               temp = delta_x_step * (127 - y1) + delta_x;
                        ld      de,(y1)                         ;                   hl = 127-y1
                        ClearCarryFlag                          ;
                        sbc     hl,de
                        ld      de,(delta_x_step)               ;                   hl = delta_x_step * (127-y1)
                        call    HLequHLmulDE2sc; replacesmulHLbyDE2sc                    ;                   .
                        ld      de,(delta_x)                    ;                   hl += delta_x
                        ClearCarryFlag                          ;                   .
                        adc     hl,de                           ;                   .
                        ld      (temp),hl
                        ld      bc,hl
                        ld      de,(delta_y_step)               ;               msd = temp / delta y step
                        call    Floor_DivQ                      ;               .
                        ld      (msd),bc                        ;               .
                        ld      hl,(x1)                         ;               x_pos_end = x1 + msd;
                        ClearCarryFlag                          ;               .
                        adc     hl,bc                           ;               .
                        ld      (x_pos_end),hl                  ;               .
                        ld      hl,(msd)                        ;               if ((temp - msd * delta_y_step) == 0) --x_pos_end
                        ld      de,(delta_y_step)               ;               .
                        call    HLequHLmulDE2sc; replacesmulHLbyDE2sc                    ;               .
                        ex      de,hl                           ;               .
                        ld      hl,(temp)                       ;               .
                        ClearCarryFlag                          ;               .
                        sbc     hl,de                           ;               .
                        ld      a,h                             ;               .
                        or      l                               ;               .
                        jp      nz,.NotTheSame                  ;               .
.IsTheSame:             ld      hl,(x_pos_end)                  ;                   --x_pos_end
                        dec     hl                              ;                   .
                        ld      (x_pos_end),hl                  ;                   .
.NotTheSame:                        
.y2LTE127:              ld      hl,(x_pos_end)                  ;           x_pos_end = min (x_pos_end,clip_xmax) + 1
                        ld      de,(clip_xmax)                  ;           .
                        call    CompareHLDESgn                  ;           .
                        jp      nc,.xposgtexmax                 ;           .
.xposltxmax:            ld      hl,(x_pos_end)                  ;           .
                        inc     hl                              ;               x_pos_end+1
                        ld      (x_pos_end),hl                  ;               .
                        jp      .DoneXposAdjust                 ;               .
.xposgtexmax:           inc     de                              ;               else
                        ld      (x_pos_end),de                  ;               clip_xmax+1
.DoneXposAdjust:        ld      a,(sign_x)                      ;           if (sign_x == -1)
                        inc     a
                        jp      nz,.SignNotMinus1
.SignEquMinus1:         ld      hl,(x_pos)                      ;               x_pos = -x_pos;
                        macronegate16hl
                        ld      (x_pos),hl
                        ld      hl,(x_pos_end)                  ;               x_pos_end = -x_pos_end;
                        macronegate16hl
                        ld      (x_pos_end),hl
.y2LTE27:
.SignNotMinus1:
                        ld      de,(delta_y_step)               ;        delta_x_step -= delta_y_step;
                        ld      hl,(delta_x_step)               ;        .
                        ClearCarryFlag                          ;        .
                        sbc     hl,de                           ;        .
                        ld      (delta_x_step),hl               ;        .
.PlottingLoop:          ld      hl,(x_pos)                      ;        while (x_pos != x_pos_end)
                        ld      de,(x_pos_end)                  ;        .
                        call    CompareHLDESame                 ;        .
                        ret     z                               ;        .
                        ld      hl,(x_pos)                      ;               drawpixel at xpos, ypos, Colour
                        ld      c,l                             ;               .
                        ld      hl,(y_pos)                      ;               .
                        ld      b,l                             ;               .
                        ld      a,$BF                           ;               .
.PlotPixel:             call    l2_plot_pixel                   ;               .
                        ld      hl,(error)                      ;               if (error >= 0)
                        bit     7,h                             ;               .
                        jp      nz,.errorLT0                    ;               .
.errorGTE0:             ld	    hl,(y_pos)                      ;                   ++y_pos;             
                        inc	    hl                              ;                   .
                        ld	    (y_pos),hl                      ;                   .
                        ld	    hl,(error)                      ;                   error -= delta_x_step;
                        ld	    de,(delta_x_step)               ;                   .
                        ClearCarryFlag                          ;                   .
                        sbc	    hl,de                           ;                   .
                        ld	    (error),hl                      ;                   .
                        jp      .DoneErrorAdjust                ;                   .
.errorLT0:              ld	    hl,(error)                      ;                   error += delta_y_step;
                        ld	    de,(delta_y_step)
                        ClearCarryFlag
                        adc	    hl,de
                        ld	    (error),hl
.DoneErrorAdjust:       ld      de,(sign_x)
                        ld      hl,(x_pos)
                        ClearCarryFlag
                        adc     hl,de
                        ld      (x_pos),hl
                        jp      .PlottingLoop
;.......................DxGltDy branch.............................................................................................
LineDrawDxLTDy:         ;ret
                        ld      hl,(delta_x_step)               ;       error = delta_x_step - delta_y;
                        ld      de,(delta_y)
                        ClearCarryFlag
                        sbc     hl,de
                        ld      (error),hl
                        ZeroA                                   ;        set exit false (0 == false)
                        ld      (set_exit),a
                        ld      hl,(x1)                         ;        if (x1 < clip_xmin)
                        ld      de,(clip_xmin)                  ;        .
                        call    CompareHLDESgn                  ;        .
                        jp      nc,.x1GTEClipXmin               ;        .
.x1LTClipXmin:          ld      de,(x1)                         ;           temp = (2 * (cllp_xmin - x1) - 1) * delta_y;
                        ld      hl,(clip_xmin)                  ;               hl = clip_xmin - x1
                        ClearCarryFlag                          ;               .
                        sbc     hl,de                           ;               .
                        ClearCarryFlag
                        adc     hl,hl                           ;               hl = (2* hl)
                        dec     hl                              ;               hl = (2 *  hl - 1)
                        ld      de,(delta_y)                    ;               hl = hl  * delta_y
                        call    HLequHLmulDE2sc; replacesmulHLbyDE2sc                    ;               .
                        ld      (temp),hl                       ;               .
                        ld      bc,hl                           ;            msd = temp / delta_x_step
                        ld      de,(delta_x_step)               ;               BC = BC / DE, HL = BC % DE
                        call    Floor_DivQ                      ;               .
                        ld      (msd),bc                        ;               .
                        ld      hl,(y_pos)                      ;            y_pos += msd
                        ClearCarryFlag
                        adc     hl,bc                           ;            .
                        ld      (y_pos),hl                      ;            .
                        ld      de,127                          ;            if (y_pos >= 127)
                        call    CompareHLDESame                 ;            .
                        jp      z,.yposGT127                    ;            .
                        call    CompareHLDESgn                  ;            .
                        ret     nc                              ;               return
.yposGT127:             ld      hl,(y_pos)                      ;            if (y_pos >= 0)  
                        bit     7,h
                        jp      nz,.yposLT0
.yposGT0:               ld      hl,(msd)                        ;               rem = temp - (msd * delta_x_step)
                        ld      de,(delta_x_step)               ;                   de = msd * delta_x_step
                        call   HLequHLmulDE2sc; replaces mulHLbyDE2sc                    ;                   .
                        ex      de,hl                           ;                   .
                        ld      hl,(temp)                       ;                   hl = temp - de
                        ClearCarryFlag                          ;                   .
                        sbc     hl,de                           ;                   .
                        ld      (rem),hl                        ;                   .
                        ld      de,(clip_xmin)                  ;               x_pos = clip_xmin
                        ld      (x_pos),de                      ;               .
                        ld      de,(rem)                        ;               error -= rem + delta_y
                        ClearCarryFlag                          ;               .
                        adc     hl,de                           ;                   de = rem+delta_x
                        ex      de,hl                           ;                   .  
                        ld      hl,(error)                      ;                   hl = error - de
                        ClearCarryFlag                          ;                   .
                        sbc     hl,de                           ;                   .
                        ld      (error),hl                      ;                   .
                        ld      hl,(rem)                        ;               if (rem > 0)
                        ld      a,h                             ;               .
                        or      l                               ;               .
                        jp      z,.remLte0                      ;               .
.remGT0:                ld      hl,(y_pos)                      ;                   y_pos += 1;
                        inc     hl
                        ld      (y_pos),hl
                        ld      hl,(error)                      ;                   error += delta_x_step;
                        ld      de,(delta_x_step)
                        ClearCarryFlag
                        adc     hl,de
                        ld      (error),hl
.remLte0:               ld      a,1                             ;               set exit = true
                        ld      (set_exit),a                    ;               .
                        
.yposLT0:                                                    
.x1GTEClipXmin:         ld      a,(set_exit)                    ;        if (!set_exit && y1 < 0)
                        and     a                               ;        .
                        jp      nz,.exit_false                  ;        .  if exit is 1 then its true so exit branch
                        ld      hl,(y1)                         ;        .  if y1 is positive (including 0) then exit branch
                        bit     7,h                             ;        .
                        jp      z,.exit_false                   ;        .
                        ld      hl,(y1)                         ;           temp = delta_x_step * (0 - y1)
                        macronegate16hl                         ;           .
                        ld      de,(delta_x_step)               ;           .       hl = delta_x_step * (- y1)
                        call    HLequHLmulDE2sc; replacesmulHLbyDE2sc                    ;           .
                        ld      (temp),hl                       ;           .
.msdEQtempDIVdxstep:    ld      bc,hl                           ;           msd = temp / delta_y_step
                        ld      de,(delta_y_step)               ;               BC = BC / DE, HL = BC % DE
                        call    Floor_DivQ                      ;               .
                        ld      (msd),bc                        ;               .
                        ld      iy,hl                           ;               same remainders (which is also mod result)
                        ld      (rem),hl                        ;           rem = temp % delta_y_step (swapped from being after x_pos += msd)
.yposPlusmsd:           ld      hl,(x_pos)                      ;           x_pos += msd
                        ClearCarryFlag                          ;           .   bc already is msd
                        adc     hl,bc                           ;           .   hl += bc
                        ld      (x_pos),hl                      ;           .
                        ld      hl,(x_pos)                      ;           if ((x_pos > clip_xmax) || (x_pos == clip_xmax && rem >= delta_y))
                        ld      de,(clip_xmax)                  ;           .
                        call    CompareHLDESame                 ;           .    if xpos != clipxmax skip the abort test
                        jr      nz,.XPosNotClipxmax             ;           .
                        ld      hl,(rem)                        ;           .    if rem < delta_y  skip the abort test
                        ld      de,(delta_y)                    ;           .
                        call    CompareHLDESgn                  ;           .
                        ret     c                               ;           .
.XPosNotClipxmax:       ex      de,hl                           ;           .    swap over xpos and max to compare xpos > xmax                      
                        call    CompareHLDESgn                  ;           .    if xpos > clipxmax then return (i.e clipxmax - xpos had a carry)
                        ret     c
.xposLT127:             ld      hl,0                            ;           y_pos = 0;
                        ld      (y_pos),hl                      ;           .
                        ld      hl,(error)                      ;           error += rem
                        ld      de,(rem)                        ;           .
                        ClearCarryFlag                          ;           .
                        adc     hl,de                           ;           .
                        ld      (error),hl                      ;           .
                        ld      hl,(rem)                        ;           if (rem >= delta_y)
                        ld      de,(delta_y)                    ;           .
                        call    CompareHLDESgn                  ;           .
                        jp      c,.remLTDeltaY                  ;           .
.remGTEDeltaY:          ld      hl,(x_pos)                      ;                x_pos++
                        inc     hl
                        ld      (x_pos),hl
                        ld      hl,(error)                      ;                error -= delta_y_step;
                        ld      de,(delta_y_step)               ;                .
                        ClearCarryFlag                          ;                .
                        sbc     hl,de                           ;                .
                        ld      (error),hl                      ;                .
.remLTDeltaY:                        
.exit_false:            ld      hl,(y2)                         ;           y_pos_end = y2;
                        ld      (y_pos_end),hl                  ;           .
                        ld      hl,(x2)                         ;           if (x2 > clip_xmax)
                        ld      de,(clip_xmax)                  ;           .
                        call    CompareHLDESame                 ;           .
                        jp      z,.x2LTEclipxmax                ;           .
                        call    CompareHLDESgn                  ;           .
                        jp      c,.x2LTEclipxmax                ;           .
.x2GTclipxmax:          ld      hl,(clip_xmax)                  ;               temp = delta_y_step * (clip_xmax - x1) + delta_y;
                        ld      de,(x1)                         ;                   hl = 127-y1
                        ClearCarryFlag                          ;
                        sbc     hl,de
                        ld      de,(delta_y_step)               ;                   hl = delta_x_step * (clip_xmax - x1)
                        call    HLequHLmulDE2sc; replacesmulHLbyDE2sc                    ;                   .
                        ld      de,(delta_y)                    ;                   hl += delta_y
                        ClearCarryFlag                          ;                   .
                        adc     hl,de                           ;                   .
                        ld      (temp),hl
                        ld      bc,hl
                        ld      de,(delta_x_step)               ;               msd = temp / delta x step
                        call    Floor_DivQ                      ;               .
                        ld      (msd),bc                        ;               .
                        ld      hl,(y1)                         ;               y_pos_end = y1 + msd;
                        ClearCarryFlag                          ;               .
                        adc     hl,bc                           ;               .
                        ld      (y_pos_end),hl                  ;               .
                        ld      hl,(msd)                        ;               if ((temp - msd * delta_x_step) == 0) --y_pos_end
                        ld      de,(delta_x_step)               ;               .
                        call    HLequHLmulDE2sc; replacesmulHLbyDE2sc                    ;               .
                        ex      de,hl                           ;               .
                        ld      hl,(temp)                       ;               .
                        ClearCarryFlag                          ;               .
                        sbc     hl,de                           ;               .
                        ld      a,h                             ;               .
                        or      l                               ;               .
                        jp      nz,.NotTheSame                  ;               .
.IsTheSame:             ld      hl,(y_pos_end)                  ;                   --x_pos_end
                        dec     hl                              ;                   .
                        ld      (y_pos_end),hl                  ;                   .
.NotTheSame:                        
.x2LTEclipxmax:         ld      hl,(y_pos_end)                  ;           y_pos_end = min(y_pos_end, clip_ymax) + 1
                        ld      de,127                          ;           .
                        call    CompareHLDESgn                  ;           .
                        jp      nc,.yposgteymax                 ;           .
.yposltymax:            ld      hl,(y_pos_end)                  ;           .
                        inc     hl                              ;           .
                        ld      (y_pos_end),hl                  ;           .
                        jp      .DoneYposAdjust                 ;           .
.yposgteymax:           inc     de                              ;           .
                        ld      (y_pos_end),de                  ;           .
.DoneYposAdjust:        ld      a,(sign_x)                      ;           if (sign_x == -1)
                        inc     a
                        jp      nz,.SignNotMinus1
.SignEquMinus1:         ld      hl,(x_pos)                      ;               x_pos = -x_pos;
                        macronegate16hl
                        ld      (x_pos),hl
                        ld      hl,(x_pos_end)                  ;               x_pos_end = -x_pos_end;
                        macronegate16hl
                        ld      (x_pos_end),hl
.SignNotMinus1:         ld      de,(delta_x_step)               ;        delta_y_step -= delta_x_step;
                        ld      hl,(delta_y_step)               ;        .
                        ClearCarryFlag                          ;        .
                        sbc     hl,de                           ;        .
                        ld      (delta_y_step),hl               ;        .
.PlottingLoop:          ld      hl,(y_pos)                      ;        while (y_pos != y_pos_end)
                        ld      de,(y_pos_end)
                        call    CompareHLDESame
                        ret     z
.PlotPixel:             ld      hl,(x_pos)
                        ld      c,l
                        ld      hl,(y_pos)
                        ld      b,l
                        ld      a,$BF                        
                        call    l2_plot_pixel                   ;               drawpixel at xpos, ypos, Colour
                        ld      hl,(error)                      ;               if (error >= 0)
                        bit     7,h
                        jp      nz,.errorLT0
.errorGTE0:             ld	    hl,(x_pos)                      ;                   ++x_pos
                        ld      de,(sign_x)
                        ClearCarryFlag
                        adc     hl,de
                        ld	    (x_pos),hl
                        ld	    hl,(error)                      ;                   error -= delta_y_step;
                        ld	    de,(delta_y_step)
                        ClearCarryFlag
                        sbc	    hl,de
                        ld	    (error),hl
                        jp      .DoneErrorAdjust
.errorLT0:              ld	    hl,(error)                      ;                   error += delta_x_step;
                        ld	    de,(delta_x_step)
                        ClearCarryFlag
                        adc	    hl,de
                        ld	    (error),hl
.DoneErrorAdjust:       ld      hl,(y_pos)
                        inc     hl
                        ld      (y_pos),hl
                        jp      .PlottingLoop
        ENDIF


l2_draw_6502_line:      ld      hl,x1                           ; copy from currnet position to 6502 variables
                        ld      de,XX1510
                        ld      bc,4*2
                        ldir        
                        call    LL145_6502                      ; perform 6502 version
                        ret     c                               ; returns if carry is set as its a no draw
.CopyBackResults:       ld      hl,0                            ; Clear out high bytes
                        ld      (x1),hl
                        ld      (y1),hl
                        ld      (x2),hl
                        ld      (y2),hl
                        ld      a,(XX1510)                      ; write low bytes with actual values to plot from XX1510
                        ld      (x1),a
                        ld      c,a
                        ld      a,(XX1510+1)
                        ld      (y1),a
                        ld      b,a
                        ld      a,(XX1510+2)
                        ld      (x2),a
                        ld      e,a
                        ld      a,(XX1510+3)
                        ld      (y2),a
                        ld      d,a
                        ld      a,$FF
                        ClearCarryFlag
                        ret
                   ;     call    l2_draw_clipped_line
;                        call    l2_draw_diagonal                ; ">l2_draw_diagonal, bc = y0,x0 de=y1,x1,a=color) Thsi version performs a pre sort based on y axis"
;................................................................
result                  dw      0
;    swap = 0;
;    if (y1 > y2)
;    draws line from x1,y1 to x2,y2 memory locations in colour held in a
l2_draw_elite_line:     ;............................................................  
                        ld      hl,(UBnKzlo)
                        ld      a,h
                        and     a
                        jp      nz,.noBreak
.DoBreak:               ;break
.noBreak:                       
                        ld      hl,(y1)                         ; if (y1 > y2)
                        ld      de,(y2)                         ; .
                        call    CompareHLDESgn                  ; .
                        jp      c,.NoSwapCoords                 ; 
;        swapp1p2();                        
.SwapCoords:            call    SwapCoords                      ;       swap them so y1 <= y2
.NoSwapCoords:          ld      hl,(x1)                         ; hl = x1
                        ld      de,(x2)                         ; de = x2
                        ld      bc,(y1)                         ; bc = y1
                        ld      ix,(y2)                         ; ix = y2
.CheckForVertical:
.CheckForHorizontal:                        
                        ld      iyh,128                         ; iyh = xx13 = 128
;    xx13 = 128;                        
;    if (x2 >= 0 && x2 <= 255 && y2 >= 0 && y2 <= 127)
                        ld      a,d                             ; if (x2 >= 0 && x2 <= 255 && y2 >= 0 && y2 <= 127)
                        or      ixh                             ; .  [if x2 and y2 > 255 goto point2clip]
                        jr      nz,.Point2Clip                  ; .  .
                        ld      a,ixl                           ; .  [if y2 low > 127 goto point2clip]
                        bit     7,a                             ; .  .
                        jr      nz,.Point2Clip                  ; .  .
;        xx13 = 0;
.Point2NoClip:          ld      iyh,0                           ;       iyh = xx13 = 0
;    if (x1 >= 0 && x1 <= 255 && y1 >= 0 && y1 <= 127)
.Point2Clip:            ld      a,h                             ; if (x1 >= 0 && x1 <= 255 && y1 >= 0 && y1 <= 127)
                        or      b                               ; . [ if x1 or y1 > 255 goto clip needed]
                        jp      nz,.ClipNeeded                  ; .
                        bit     7,c                             ; . [ if y1 low > 127 goto clip needed]
                        jp      nz,.ClipNeeded                  ; .
;        if (xx13 != 0)                        
.ClipPoint1:            ld      a,iyh                           ;       if (xx13 = 0)
                        and     a                               ;       .
                        jp      z,.ClipComplete                 ;               clipping not needed so treat as done an ddraw the line
                        ld      iyh,64                          ;       else xx13 = 64 (xx13 /2 but if xx13 is 0 it never hits here so can just set to 64)
;.......................LL138
.ClipNeeded:            ld      a,iyh                           ; if (xx13 == 128)
                        bit     7,a                             ; . [ jump if bit 7 is not set so <> 128]
                        jp      z,.xx13Not128                   ; .
.xx13Is128:             ld      a,h                             ;       if (x1 < 0 && x2 < 0) 
                        and     d                               ;       . [ x1 and x2 high bits 7 are both set then its off to the left]
                        ret     m                               ;               return
                        ld      a,b                             ;       if (y1 < 0 && y2 < 0)
                        and     ixh                             ;       . [ y1 and y2 high bits 7 are both set then its off the top]
                        ret     m                               ;               return
                        ld      a,h                             ;       if (x1 > 255  && x2 > 255)
                        bit     7,a                             ;       . [test if x1 is negative and if so skip]
                        jp      nz,.x1x2LessThan256             ;       .
                        and     a                               ;       . [ if x1 is not negative then if high has any value its > 256]
                        jp      z,.x1x2LessThan256              ;       .
                        ld      a,d                             ;       . [test if x2 is negative]
                        bit     7,a                             ;       .
                        jp      nz,.x1x2LessThan256             ;       . < can simplify with with an xor test to detect if opposite signs first >
                        and     a                               ;       . [ if x2 is not negative then if high has any value its > 256]
                        ret     nz                              ;               return
.x1x2LessThan256:       ld      a,b                             ;       if (y1 > 127  && y2 > 127)
                        bit     7,a                             ;       . [test if y1 is negative]
                        jp      nz,.y1y2LessThan128             ;       .
                        and     a                               ;       . [ if y1 is not negative then if high has any value its > 256]
                        jp      z,.y1y2LessThan128              ;       .
                        bit     7,c                             ;       . [ if y1 low bit 7 is set then its > 127]
                        jp      z,.y1y2LessThan128              ;       .
                        ld      a,ixh                           ;       . [test if y2 is negative]
                        and     a                               ;       .
                        jp      m,.y1y2LessThan128              ;       .
                        and     a                               ;       . [ if y2 is not negative then if high has any value its > 256]
                        jp      z,.y1y2LessThan128              ;       .
                        ld      a,ixl                           ;       .
                        and     a                               ;       . [ if y2 low bit 7 is set then its > 127]
                        ret     m                               ;               return
;.......................LL115
.xx13Not128:                        // check right point
.y1y2LessThan128:       ex      de,hl                           ; delta_x = x2 - x1;
                        ClearCarryFlag                          ; .
                        sbc     hl,de                           ; .
                        ld      (delta_x),hl                    ; redundant as its in DE TODO OPTIMISE
                        ex      de,hl                           ; de = delta_x for next bit
.DyEquY2MinusY1:        ld      hl,ix                           ; delta_y = y2 - y1;
                        ClearCarryFlag                          ; .
                        sbc     hl,bc                           ; .
                        ld      (delta_y),hl                    ; . [ so now de = dx and hl = dy]
                        ld      iyl,128                         ; assuming sign is iyl is positive dx dy
.SignDeltaXY:           bit     7,d                             ; if delta x is negative (delta y will always be positive)
                        jp      z,.DeltaXPositive               ; .
.DeltaXNegative:        ld      iyl,0                           ;       so we set sign to 0
                        macronegate16de                         ;       and set delta x to |delta x|
.DeltaXPositive:        ld      (delta_x),de                    ;       .
;.......................Scale down DY and DY to 7 bit                                
.ScaleDXDY:             ld      a,h                             ; scale down so that dx and dx are < 256
                        or      d                               ; .
                        jp      z,.ScaleDXDYHighDone            ; .
                        ShiftDERight1                           ; .
                        ShiftHLRight1                           ; .
                        jp      .ScaleDXDY                      ; .
.ScaleDXDYHighDone:     ld      a,e                             ; because of signed maths we will scale down to 7 bits to be safe
                        or      l                               ; .
                        jp      p,.LowScaleDone                 ; .
                        ShiftDERight1                           ; .
                        ShiftHLRight1                           ; .
;.......................Work out slope and gradient - later on we will work with deltax beign abs
.LowScaleDone:          ld      (delta_x),de                    ; save adjusted dx and dy back
                        ld      (delta_y),hl                    ; .
                        ld      d,l                             ; now d = dy e = dx
                        ld      (delta_y_x),de                  ; save for diagnostics
.SetUpTSlope:           ZeroA                                   ; Initialise tSlope to 0
                        ld      (tSlope),a                      ; .
                        ld      a,e                             ; a = dx
                        JumpIfAGTENusng d, .deltaxGTEdeltaY     ; if dx < dy
.deltaXLTdeltaY:        ld      b,e                             ;       bc = dx $00
                        ld      c,0                             ;       .
                        ld      e,d                             ;       de = $00 dy
                        ld      d,0                             ;       .
                        call    Floor_DivQ                      ;       bc = bc / de  (dx * 256 / dy)
                        ld      (gradient),bc                   ;       in reality this is 8 bit little endian
                        jp      .donedxdycheck                  ;       .
                                                                ; else
.deltaxGTEdeltaY:       ld      b,d                             ;       bc = dy << 0
                        ld      c,0                             ;       .
                        ld      d,0                             ;       de = 0dx
                        call    Floor_DivQ                      ;       bc = bc / de (dy * 256 / dx)
                        ld      (gradient),bc                   ;       in reality this is 8 bit little endian
                        ld      a,255                           ;       set tslope to -1
                        ld      (tSlope),a                      ;       .
.donedxdycheck:                 // CHECK CORRECT POINT
;.......................Clipping point 1
                        ;break
                        ld      a,iyh                           ; if xx13 = 0 or xx13 = 128 (values can be 0, 128, 64 later we can optimise to see if its <> 64)
                        and     a                               ; . [xx13 = 0  enter the block]
                        jp      z,.xx13is0or128                 ; .
                        jp      p,.xx13not0or128                ; . [xx13 <> 128 then skip block]
.xx13is0or128:          call    ClipLL118Elite                  ;       clip point 1
                        ld      a,iyh                           ;       if xx13 <> 0
                        and     a                               ;       .
                        jp      z,.ImmediateDraw                ;       .
                        ld      a,(x1+1)                        ;               if (if (x1 <0 || x1 > 255 || y1 <0 || y1 > 127)) return
                        and     a                               ;               . 
                        ret     m                               ;               . [x1 high is negative then return]
                        ret     nz                              ;               . [if x1 high is not zero, x1 > 255 return (above will have sorted negative test on bit 7)]
                        ld      a,(y1+1)                        ;               . [a = x1 high]
                        and     a                               ;               .
                        ret     m                               ;               . [if y1 negative return]
                        ret     nz                              ;               . [if y1 > 255 return (above will have sorted negative test on bit 7)]
                        ld      a,(y1)                          ;               . [a = y1 low]
                        and     a                               ;               .
                        ret     m                               ;               . [if y1 > 127 then low byte would appear as negative in bit 7]
                        jp      .SkipCheckP1OnScreen            ;               else goto SkipCheckP1OnScreen 
.ImmediateDraw:         IFDEF SPLITORLINEX
                        call    l2_draw_clipped_line            ;        else if we get here we only needed to clip one point so draw the line
                        ENDIF
                        ret                                     ;             and we are done
.xx13not0or128:                        
.SkipCheckP1OnScreen:   call    SwapCoords                      ; swap point 1 and point 2 so we can now process P2
                        call    ClipLL118Elite                  ; clip P2
                        ld      a,(x1+1)                        ; if (x1 <0 || x1 > 255 || y1 <0 || y1 > 127) return
                        and     a                               ; .
                        ret     m                               ; . [if x1 negative return]
                        ret     nz                              ; . [if x1 > 255 return (above will have sorted negative test on bit 7)]
                        ld      a,(y1+1)                        ; . [a = y1 high]
                        and     a                               ;
                        ret     m                               ; . [if y1 negative return]
                        ret     nz                              ; . [if y1 > 255 return (above will have sorted negative test on bit 7)]
                        ld      a,(y1)                          ; . [a = y1 low]
                        and     a                               ; .
                        ret     m                               ; . [if y1 low > 127 then low byte would appear as negative in bit 7]
.ClipComplete:
.xx13is0or128Draw:      IFDEF SPLITORLINEX
                        call    l2_draw_clipped_line            ; if we get here we only needed to clip one point/have done all slipping needed
                        ENDIF
                        ret
;................................................................
ClipSign                dw      0
ClipLL118Elite:        ;break
.checkX1IsNegative      ld      hl,(x1)                         ; if x1 is negative
                        bit     7,h                             ; .
                        jp      z,.x1GTE0                       ; .
.x1LT0:                 ld      a,255                           ;       clip sign = -1
                        ld      (ClipSign),a                    ;       .
                        call    CalcLL120                       ;       calc ll120
                        ld      hl,0                            ;       x1 = 0
                        ld      (x1),hl                         ;       .
                        ld      hl,(y1)                         ;       y1 = y1 + result
                        ld      de,(result)                     ;       . [and save in hl for optimisation processing y1]
                        add     hl,de                           ;       .
                        ld      (y1),hl                         ;       .
                        jp      .checkY1IsNegative              ;       .
.x1GTE0:                ld      a,h                             ; else
                        and     a                               ;       if x1 > 255
                        jp      z,.checkY1IsNegative            ;       .
                        ZeroA                                   ;               sign must be 0 for postive adjustment
                        ld      (ClipSign),a                    ;               .
                        call    CalcLL120                       ;               Calc LL120
                        ld      hl,255                          ;               x1 = 255
                        ld      (x1),hl                         ;               .
                        ld      hl,(y1)                         ;               y1 = y1 + result
                        ld      de,(result)                     ;               . [and save in hl for optimisation processing y1]
                        add     hl,de                           ;               .
                        ld      (y1),hl                         ;               .
                                                                ; end if
.checkY1IsNegative:     ld      hl,(y1)                         ; if (y1 <0) [if we don;t need to clip x1 then we need to load hl with y1 as it never got loaded]
                        bit     7,h                             ; .
                        jp      z,.checkY1LT128                 ; .
                        ld      a,255                           ;       set sign to -1 for calc
                        ld      (ClipSign),a                    ;       .
                        call    CalcLL123                       ;       calc LL123
                        ld      hl,(x1)                         ;       x1 = x1 + result
                        ld      de,(result)                     ;       .
                        add     hl,de                           ;       .
                        ld      (x1),hl                         ;       .
                        ld      hl,0                            ;       y1 = 0
                        ld      (y1),hl                         ;       .
.checkY1LT128:          ld      a,h                             ; finished if y < 128
                        and     a                               ; .
                        jp      nz,.mopUpY1                     ; . [jump to mop up if y1 high <> 0, wehave already dealt with negatvies so don't need to consider that]
                        ld      a,l                             ; . [now check y1 low and return if y1 low > 127]
                        and     a                               ; .
                        ret     p                               ; . [ if y1 low was positive then we are done as it means y1 < 128]
.mopUpY1:               ld      de,128                          ; y1 = y1 - 128
                        ClearCarryFlag                          ; .
                        sbc     hl,de                           ; .
                        ld      (y1),hl                         ; .
                        ZeroA                                   ; set clip sign to 0
                        ld      (ClipSign),a                    ; to get to here if y1 < 0, y is set to 0, if its < 128 then it never reaches here, so y1 must be > 128 to get here
                        call    CalcLL123                       ; calc LL123
                        ld      hl,(x1)                         ; x1 = x1 + result
                        ld      de,(result)                     ; .
                        add     hl,de                           ; .
                        ld      (x1),hl                         ; .
                        ld      hl,127                          ; y1 = 127
                        ld      (y1),hl                         ; .
                        ret

CalcLL120:              ld      hl,(x1)                         ; x1= |x1|
                        macroAbsHL                              ; .
                        ld      a,(tSlope)                      ; if (tslope == 0)
                        and     a                               ; .
                        jp      nz,.tSlopeNonZero               ; .
.tSlopeZero:            ld      d,l                             ;       d = x1 & 255
                        ld      a,(gradient)                    ;       e = gradient
                        ld      e,a                             ;
                        mul     de                              ;       de = x1 & 255 * gradient
                        ld      e,d                             ;       de = x1 * gradient /256
                        ld      d,0                             ;       .
                        ld      a,(ClipSign)                    ;       if clipsign != 0
                        and     a                               ;       .
                        jp      z,.tSlopeZeroDone               ;       .
.tSlopeZeroNegate:      macronegate16de                         ;               result = - result
.tSlopeZeroDone:        ld      (result),de                     ;
                        ret                                     ;
.tSlopeNonZero:         ;ld      a,(gradient)                    ; else  c = gradient
                        ;ld      c,a                             ;       .
                        ;ld      a,l                             ;       a = x1 & 255
                        ;call    DIV16Amul256dCUNDOC             ;       bc = a * 256/c

                        ld      de,(gradient)                   ; BC = BC / DE
                        ld      b,l
                        ld      c,0
                        ;; CORRECTED TO LADO INTO B ld      bc,hl                           ; HL = BC % DE
                        call    Floor_DivQ

                        ld      a,(ClipSign)                    ;       if clipsign != 0
                        and     a                               ;       .
                        jp      z,.tSlopeNonZeroDone            ;       .
.tSlopeNonZeroNegate:   macronegate16bc                         ;               result = - result
.tSlopeNonZeroDone:     ld      (result),bc
                        ret
;.......................LL123
CalcLL123:              ;break
                        ld      hl,(y1)                         ; hl = |y1|
                        macroAbsHL                              ; .
                        ld      a,(tSlope)                      ; if tSlope = 0
                        and     a                               ; .
                        jp      nz,.tSlopeNonZero               ; .
.tSlopeZero:           ; ld      a,(gradient)                    ;       c = gradient
;                        ld      c,a                             ;       .
;                        ld      a,l                             ;       hl = y1 (which is now abs and < 256)
;                        call    DIV16Amul256dCUNDOC             ;       bc = A * 256 / c
                        ld      de,(gradient)                   ; BC = BC / DE
                        ld      bc,hl                           ; HL = BC % DE
                        call    Floor_DivQ
                        ld      a,(ClipSign)                    ;       if clipsign != 0
                        and     a                               ;       .
                        jp      z, .tSlopeZeroDone              ;       .
.tSlopeZeroNegate:      macronegate16bc                         ;               result = -result
.tSlopeZeroDone:        ld      (result),bc                     ;       . save result in either case
                        ret                                     ;       .
.tSlopeNonZero:         ld      d,l                             ; else  d = |y1| low
                        ld      a,(gradient)                    ;       e = gradient
                        ld      e,a                             ;       .
                        mul     de                              ;       de = l * gradient
                        ld      e,d                             ;       de = l * gradient /256
                        ld      d,0                             ;       .
                        ld      a,(ClipSign)                    ;       if clipsign != 0
                        and     a                               ;       
                        jp      z,.tSlopeNonZeroDone            ;               
.tSlopeNonZeroNegate:   macronegate16de                         ;               result = -result
.tSlopeNonZeroDone:     ld      (result),de                     ;       . save result in either case
                        ret                                     ;       .
