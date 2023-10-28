

; Draws line in (triangleColor) from e to l on row c
; Tested within bounds, works OK
l2_draw_horz_saved:     ld      b,c
                        ld      a,l
                        JumpIfALTNusng e ,.DrawEToL
.DrawLtoE:              ld      c,l
                        ld      d,e
                        ld      a,(traingleColor)
                        ld      e,a
                        jp      l2_draw_horz_line
.DrawEToL:              ld      c,e
                        ld      d,l
                        ld      a,(traingleColor)
                        ld      e,a
                        jp      l2_draw_horz_line
;..................................................................................................................................                        
; void l2_drawhorzClipy(int px1, int px2, int py2, int int16_t* targetArray)
; hl'hl = x1y1 de'de = x2y2 ix = targetarray a=longest flag (ff means longest)
; This will set up starty and end y to hl
; Need to consider setting starty to lower of current value and Hl
;                  setting endy   to larger of current value and hl (if already intiailised) else hl

                        
;l2_drawHorzClipYOLD:
;                        ld      a,h                         ; fast exit if h <0 or > 255
;                        and     a
;                        ret     nz
;                        bit     7,l                         ; fast exit if hl > 127
;                        ret     nz
;                        ex      de,hl                       ; save Y to de
;.IsStartY255:           ld      hl,(starty)                 ; if start Y is not initialised then do it
;                        bit     7,l
;                        jp      z,.DoneStartY
;                        ld      (starty),de
;.DoneStartY:            ld      hl,(endy)                   ; set up endy
;                        bit     7,l
;                        ret     z
;                        ld      (endy),de
;                        ret
                        
;; this is only relevant if we were plotting pixels .ClipX1X2:              exx                                 ; now wget hl' and de' in for x clipping
;; this is only relevant if we were plotting pixels                         call    CompareHLDESigned           ; make sure we are going left to right HL to DE
;; this is only relevant if we were plotting pixels                         jp      c,.HLltDE                   ; .
;; this is only relevant if we were plotting pixels .HLgtDE:                ex      de,hl                       ; .
;; this is only relevant if we were plotting pixels .HLltDE:                bit     7,h                         ; if hl is negative, set to 0
;; this is only relevant if we were plotting pixels                         jr      z,.NoLeftClipRequired
;; this is only relevant if we were plotting pixels .ClipNegativeHL:        bit     7,d                         ; before we clip hl, if de was also negative then off screen
;; this is only relevant if we were plotting pixels                         ret     nz
;; this is only relevant if we were plotting pixels                         ld      hl,0                        ; set HL
;; this is only relevant if we were plotting pixels .NoLeftClipRequired:    ld      a,h                         ; if hl > 255 then we exit also as its all off screen
;; this is only relevant if we were plotting pixels                         and     a
;; this is only relevant if we were plotting pixels                         ret     nz
;; this is only relevant if we were plotting pixels .ClipDE:                ld      d,0                         ; we can just set it to 0 as if its less than 255 it makes no difference and we have already eliminated DE being negative
;; this is only relevant if we were plotting pixels .CalcLineLength:        ClearCarryFlag                      ; b = x2 - x1 (x2 must be < 256 & x1 >= 0)
;; this is only relevant if we were plotting pixels                         ex      de,hl                       ; .
;; this is only relevant if we were plotting pixels                         push    hl                          ; .
;; this is only relevant if we were plotting pixels                         sbc     hl,de                       ; .
;; this is only relevant if we were plotting pixels                         ld      b,h                         ; .
;; this is only relevant if we were plotting pixels                         pop     hl                          ; .
;; this is only relevant if we were plotting pixels                         ex      de,hl                       ; .
;; this is only relevant if we were plotting pixels ;                       for loop = x1, for length b         ;
;; this is only relevant if we were plotting pixels .PlotPrep:              ld      a,iyl                            
                        



; draw vertical clipy  IX = px1 DE = py1, BC=py2 IX targetArray
; hl'hl = x1y1 de'de = x2y2 ix = targetarray a=longest flag (ff means longest)



;..................................................................................................................................                        
;void layer2_save_clipy_line(int16_t px1, int16_t py1, int16_t px2, int16_t py2 , int16_t *targetArray,  _Bool  longest)
; hl'hl = x1y1 de'de = x2y2 ix = targetarray a=longest flag (ff means longest)
; returns carry set if failed
    
Layer2_Save_ClipY_Line: ld      (longest),a     
;                       Eliminte totally off screen first
.Y1HighTest:            IsHLGT127                       ; if y1 and y2 > 127
                        jr      nz,.Y1HighLTE127        ; .
.Y2HighTest:            IsDEGT127                       ; .
                        ret     nz                       ;   return
.Y1HighLTE127:
.Y1LowTest:             bit     7,h                     ; if y1 and y2 < 0
                        jr      z,.YTestPass            ; .
                        bit     7,d                     ; .
                        ret     nz                      ;   return
.YTestPass:             exx                             ; hl hl' = x1y1 de de' = x2y2
                        ld      a,h                     ; if x1 and x2 < 0 or > 255
                        and     a                       ; then in either scenario high
                        jr      z,.XTestPass            ; byte will not be zero
                        ld      a,d                     ; .
                        and     a                       ; .
                        ret     nz                      ;   return
.XTestPass:                                             ;
;                       Check for horizontal and vertical exceptions
.CheckForVertical:      call    CompareHLDESigned       ; if x1 = x2 then vertical line 
                        jp      z, l2_drawVertClipY     ;    goto vertical and use its ret as a free exit
.CheckForHorizontal:    exx                             ; hl'hl = x1y1 de'de = x2y2
                        call    CompareHLDESigned       ; if y1 = y2 then horizonal line
                        jp      z, l2_drawHorzClipY     ; goto  horizontal and use its ret as a free exit
                        exx                             ; hl hl' = x1y1 de de' = x2y2
;                       Now we can draw diagnoal, note we are pre-sorting Y so no need to do sort logic                       
;                       Check if X1 > X2 and set sign, X1 x2 and clip accordingly
.SetupMinMaxX:          call    CompareHLDESigned       ; If x1 > x2
                        jr      c, .x1LTx2              ; . (else jump to x1 < x2 as we have already handled x1 = x2)
.x1GTEx2:               ld      a,$FF                   ;   sign_x = -1 (also iyh)
                        ld      (sign_x),a              ;   .
                        ld      iyh,a
                        NegHL                           ;   x1 = - x1
                        NegDE                           ;   x2 = - x2
                        xor     a                       ;   xmax = 0
                        ld      (clip_xmax),a           ;   .
                        ld      (clip_xmax+1),a         ;   .
                        inc     a                       ;   xmin = -255 ($FF01)
                        ld      (clip_xmin),a           ;   .
                        ld      a,$FF
                        ld      (clip_xmin+1),a         ;   .
                        jp      .DoneSignSetup          ; else
;                       if X1<X2 then set up sign as 1, clip, we don't need to change X1 and X2
.x1LTx2:                ld      a,1                     ;   sign_x = 1 (also iyh)
                        ld      (sign_x),a              ;   .
                        ld      iyh,a                   ;   .
                        ZeroA                           ;   clip_xmin = 0
                        ld      (clip_xmin),a           ;   .
                        ld      (clip_xmin+1),a         ;   .
                        ld      (clip_xmax+1),a         ;   clip_xmax = 255
                        dec     a                       ;   .
                        ld      (clip_xmax),a           ;   .
.DoneSignSetup:         
;                       Set up Delta x = x2 - x1
.CalcDeltas:            ex      de,hl                   ; de = x1 hl = x2
                        push    hl                      ; save x2                       Stack+1
                        ClearCarryFlag                  ; delta_x = x2 - x1
                        sbc     hl,de                   ; .
                        ld      (delta_x),hl            ; .
;                       Set up Delta X step
                        ClearCarryFlag                  ; multiply by 2
                        adc     hl,hl                   ; .
                        ld      (delta_x_step),hl       ; delta_x_step = delta x * 2
                        pop     hl                      ; Restore X2                     Stack+0
                        ; now hl = x2 and de = x1
;                       Set up Delta y = y2 - y1
.CalcDeltaY:            exx                             ; hl = y1 de = y2, we don't save hl,de as we will load later
                        ld      (y1Work),hl             ; y1Work = y1
                        push    hl                      ; save y1 so that it can be loaded to HL later
                        ld      (y2Work),de             ; y2Work = y2
                        ex      de,hl                   ; set de to y2Work and hl to y1Work
                        ClearCarryFlag                  ; delta_y = y2 - y1
                        sbc     hl,de                   ; .
                        ld      (delta_y),hl            ; .
;                       Set up Delta Y step
                        ClearCarryFlag                  ; multiply by 2
                        adc     hl,hl                   ; .
                        ld      (delta_y_step),hl       ; delta_y_step = delta y * 2
                        ; now hl = y1 de = y2
;                       x_pos = x1, y_pos = y1
.SavePositions:         exx                             ; de = x1 hl = x2
                        ld      (x1Work),de             ; x1Work = x1
                        ld      (x2Work),hl             ; x2Work = x2
                        ;ex      de,hl                   ; hl = x1 de = x2
                        pop     hl                      ; y_pos = hl = y1   = y_pos     Stack+0
                        ld      (x_pos),de              ; . 
                        ld      (y_pos),hl              ; .
;                       Check for Delta X >= Delta Y and do respective code version
.CheckDeltaXGTEDeltaY:  ld      hl,(delta_x)            ; hl = delta x
                        ld      de,(delta_y)            ; de = delta y
                        call    CompareHLDESigned       ; if data x < deltay
                        jp      c, DeltaXltDeltaY
;..................................................................................................................................                        
;                       this is where dx >= dy
;--- Delta X >= DeltaY ---------------------------------;    error = delta y_step - delta x
;                       Error = delta Y Step - Delta X and set Exit false
DeltaXgteDeltaY:        ErrorEquStepMinusDelta delta_y_step, delta_x ; this also sets de to delta x
                        SetExitFalse                    ;    set exit = false
;---                    if y < 0 then set y = 0 & save X pos to targetArray[0]..;                            
.IsY1TL0:               IsAxisLT0 (y1Work)              ;    if y1 < 0
                        jp     z,.Y1IsNotLT0           ;    .
;                       ... temp = 2 * (-y1) -1 * delta X
.Y1IsLT0:               ex      de,hl                   ;       de = delta x
                        ld      hl,(y1Work)             ;       temp = (2 * (0 - y1) - 1) * delta_x; Note from entering de = delta_x
                        NegHL                        ;       .      (0-y1 also equals negate y1)
                        ClearCarryFlag                  ;       .      
                        adc     hl,hl                   ;       .      (y1 = y1 * 2)
                        dec     hl                      ;       .      (y1 = y1 -1)
                        call    mulHLbyDE2sc            ;       .      (multiply by de which is delta x)                       
                        ld      (linetemp),hl           ;       .      (and save to linetemp)
                        ld      de,(delta_y_step)       ;       .  (set BC to divq floor bc/de)
                        ex      de,hl                   ;       msd = floor_divq (temp, delta_y_step)
;                       ... msd = floor (temp , delta y step)
                        FloorHLdivDETarget msd          ;       .
;                       ... xpos += msd
                        ex      hl,de                   ;       x pos += msd (move msd to de)
                        ld      hl,(x_pos)              ;       .            (pull in x1temp and add de)
                        add     hl,de                   ;       .
                        ld      (x_pos),hl              ;       .            (store result in x_pos)
;                       ... if x_pos > clip_xmax then return
.IsXposGTClipXMax:      ld      de,(clip_xmax)          ;       if x_pos > clip_xmax then return
                        call    CompareHLDESigned               ;       .
                        jr      z,.XPosLTEXMax         ;       .
                        ret     nc                      ;       .
.XPosLTEXMax:
;                       ... if x_pos > clip_xmin
.IsXposGTEClipXmin:     ld      de,(clip_xmin)          ;       if x_pos >= clip_xmin
                        call    CompareHLDESigned               ;       .
                        jr      z,.XposLTClipXmin       ;       .
                        jr      c,.XposLTClipXmin       ; 
;                       ... ... then rem = temp - msd * delta y step
.XposGTEClipXMin:       ld      hl,(msd)                ;          rem = temp - msd * delta_y_step
                        ld      de,(delta_y_step)       ;          .     (de =  delta_y_step)
                        call    mulHLbyDE2sc            ;          .     (hl = msd * delta y step)
                        ex      de,hl                   ;          .     (de = hl)
                        ld      hl,(linetemp)           ;          .     (hl = linetemp)
                        ClearCarryFlag                  ;          .     
                        sbc     hl,de                   ;          .     (hl = hl = de)
                        ld      (rem),hl                ;          .     (rem = result)
;                       ... ... y pos = 0                        
                        xor     a                       ;          y_pos = 0
                        ld      (y_pos),a               ;          .
                        ld      (y_pos+1),a             ;          .
;                       ... ... error = error - (rem + delta x)
                        ld      de,(delta_x)            ;          error -= rem + delta_x
                        add     hl,de                   ;          .      (hl = (rem still) (de = delta x) )
                        ex      de,hl                   ;          .      (move result into de)
                        ld      hl,(error)              ;          .      (get error into hl)
                        ClearCarryFlag                  ;          .      (error - de)
                        sbc     hl,de                   ;          .
                        ld      (error),hl              ;          .      (save in hl)
;                       ... ... if rem > 0                        
                        IsMem16GT0JumpFalse rem, .remNotGT0 ;      if (rem > 0)
;                       ... ... ... xpos ++
.remGT0:                ld      hl,x_pos                ;              x_pos += 1
                        inc     (hl)                    ;              .
;                       ... ... ... error += delta y step
                        ErrorPlusStep delta_y_step      ;              error += delta_y_step
;                       ... ... set exit true                        
.remNotGT0:             ld      a,$FF                   ;          set_exit = true
                        ld      (set_exit),a            ;          .
;                       ... ...  set target array [0] to xpos
                        ld      hl,(x_pos)              ;          targetArray[0] = x_pos
                        ld      (ix+0),l                ;          .  (targetArray is pointed to by ix)
                        ld      (ix+1),h                ;          .
.Y1IsNotLT0:             
;                       x pos end = x2                                    
.XposLTClipXmin:        ld      hl,(x2Work)             ;    x_pos_end = x2
                        ld      (x_pos_end),hl          ;    .
;                       if y2 > 127
.IsY2GT127:             ld      hl,(y2Work)             ;    if (y2 > 127)
                        IsHLGT127                       ;    .
                        jr      nz,.Y2LTE127            ;    .
;                       ... temp = delta x step * (127 - y1) + delta x
.Y2GT127:               ld      de,(y1Work)             ;       temp = delta_x_step * (127 - y1) + delta_x
                        ld      hl,127                  ;       .      (de = y1work)
                        ClearCarryFlag                  ;       .      (hl = 127 )
                        sbc     hl,de                   ;       .      (hl - de)
                        ld      de,(delta_x_step)       ;       .      (de = delta x step)
                        call    mulHLbyDE2sc                    ;       .      (hl = hl * de)
                        ld      de,(delta_x)            ;       .      (de = delta x)
                        add     hl,de                   ;       .      (hl + de)
                        ld      (linetemp),hl           ;       .      (and save to line temp)
                        ld      de,(delta_y_step)       ;       de = delta y step
                        ex      de,hl                   ;       de = linetemp hl = delta y step
;                       ... msd = floor_divq (temp, delta y step)
                        FloorHLdivDETarget msd          ;       msd = floor_divq(temp,delta_y_step); (hl=de/hl)
                        ld      bc,hl                   ;       save off msd as we will need it again
                        ld      de,(x1Work)             ;
;                       ... xpos_end = x1 + msd
                        add     hl,de                   ;       x_pos_end = x1 + msd;
                        ld      (x_pos_end),hl          ;
;                       ... if (temp - msd * delta y step)) == 0                        
                        ld      hl,bc                   ;       if ((temp - msd * delta_y_step) == 0) --x_pos_end;
                        ld      de,(delta_y_step)       ;       .    (hl = msd * delta_y_step)
                        call    mulHLbyDE2sc            ;       . 
                        ex      hl,de                   ;       .    (hl = linetemp - hl
                        ld      hl,(linetemp)           ;       .
                        ClearCarryFlag                  ;       .
                        sbc     hl,de                   ;       .
                        jr      nz,.Calc1NotZero        ;       .
;                       ... ... x pos end minus 1
                        ld      hl,x_pos_end            ;           then -- x_pos_end
                        dec     (hl)                    ;           .
.Calc1NotZero:          
;                       if sign_x == -1
.Y2LTE127:              break
                        IsMemNegative8JumpFalse sign_x, .SignXNotNegative ; just check if its negative
;                       ... xpos = - xpos
.SignXNegative:         ld      hl,(x_pos)              ;       x_pos = -x_pos
                        NegHL                           ;       .
                        ld      (x_pos),hl              ;       .
;                       ... xpos end = - xpos end
                        ld      hl,(x_pos_end)          ;       x_pos_end = -x_pos_end
                        NegHL                           ;       .
                        ld      (x_pos_end),hl          ;       .
                        dec     (hl)                    ;       .
;                       delta x step = delta x step - delta y step
.SignXNotNegative:      ld      hl,(delta_x_step)       ;    delta_x_step -= delta_y_step
                        ld      de,(delta_y_step)       ;    .  
                        ClearCarryFlag                  ;    .  
                        sbc     hl,de                   ;    .  
                        ld      (delta_x_step),hl       ;    .  
.IsLongest:             ld      a,(longest)             ;    if (not longest)
                        and     a                       ;    . 
                        jp      z,DxGTEDy               ;       goto Dx > Dy Not Longest
                                                        ;    else fall into Dx >=Dy Longest
;..................................................................................................................................
;--- Dx >= Dy Longest while loop -----------------------;    
DxGTEDyLongest:         ld      hl,(y_pos)              ;       starty=y_pos
                        ld      (starty),hl             ;       .
;--- Version where longest issaved ---------------------;    
                        ld      iy,(y_pos)              ;       Fetch in yPos to IY
.LoadAlternateRegs:     ld      bc,(x_pos)              ;       we already have IY so just need xpos and end
                        ld      de,(x_pos_end)
                        ld      hl,ix                   ;    load hl as target array
                        ld      a,iyl                   ;    by this point y pos must be 8 bit
                        add     hl,a                    ;    So we are setting up hl as targetArray pointer
                        add     hl,a     
                        exx                             ;       switch to alternate registers
                        ld      hl,(error)              ;       load up stepping into alternate registers
                        ld      de,(delta_x_step)       ;       and error
                        ld      bc,(delta_y_step)       ;
                        exx                             ;       and then switch back to main registers
                        ld      a,(sign_x)              ;       if Sign x is -1
                        and     $80                     ;       .
                        jr      z,.SetWhileInc          ;       .
.SetWhileDec:           ld      a,InstrDECBC
                        ld      (.WhileIncInstuction), a; set self modifying to dec 
                        jp      .WhileLoop:         ;           .
.SetWhileInc:           ld      a, InstrINCBC
                        ld      (.WhileIncInstuction), a; else set to inc
;--- Update Loop ---------------------------------------;
; In loop hl  = target array pointer bc = x_pos,       de = x_pos_end,  iy = y pos
;         hl' = error                bc'= delta_y_step de'=delta_x_step
;--- Version where longest is saved --------------------;
.WhileLoop:             call    CompareBCDESigned       ;       while x_pos != x_pos_end
                        jp      z,.DoneLoop             ;       .
                        ld (hl),bc                      ;          targetArray[y_pos] = x_pos and update index
                        exx                             ;          if error >= 0
                        bit     7,h                     ;          .
                        jr      nz,.ErrorNegative       ;          .
.ErrorPositive:         ClearCarryFlag                  ;               error -= delta_x_step
                        sbc     hl,de                   ;               .
                        exx                             ;               back to main regsters
                        inc     iy                      ;                ++y_pos
                        inc     hl                      ;                y pos for target Array index +2
                        inc     hl                      ;                as its 16 bit
                        jp      .WhileIncInstuction     ;               .
.ErrorNegative:         add     hl,bc                   ;          else error += delta y step
                        exx                             ;               back to main regsters
.WhileIncInstuction:    inc     bc                      ;          x_pos += sign_x (doneas self modifying to inc or dec)
                        jp      .WhileLoop              ;       Loop      
.DoneLoop:              ld      (endy),iy               ;       Set endy to rolling y loop
                        ret                             ;
;..................................................................................................................................
;--- DxFTEDyNotLongest while loop ----------------------;                        
DxGTEDy:                ld      bc,(x_pos)              ;    while (x_pos != x_pos_end) loading bc with xppos an de as x_pos_end
                        ld      de,(x_pos_end)          ;    .
                        ld      hl,ix                   ;    load hl as target array
                        ld      a,(y_pos)               ;    by this point y pos must be 8 bit
                        add     hl,a                    ;    So we are setting up hl as targetArray pointer
                        add     hl,a                    ;    .
;..................................................................................................................................
;--- Version where longest is not saved ----------------;
                        exx                             ;      switch to alternate registers
                        ld      hl,(error)              ;      load up stepping into alternate registers
                        ld      de,(delta_x_step)       ;      .
                        ld      bc,(delta_y_step)       ;      .
                        exx                             ;      .
                        ld      a,(sign_x)              ;      Self modify inc of y_pos
                        and     $80                     ;
                        jr      z,.SetWhileInc          ;
.SetWhileDec:           ld      a,InstrDECBC
                        ld      (.WhileIncInstuction), a
                        jp      .WhileLoop
.SetWhileInc:           ld      a,InstrINCBC
                        ld      (.WhileIncInstuction), a
;--- Update Loop ---------------------------------------;
; In loop hl  = target array pointer bc = x_pos,       de = x_pos_end, (we don't need to reatin Y_pos)
;         hl' = error                bc'= delta_y_step de'=delta_x_step
.WhileLoop:             call    CompareBCDESigned       ;      while x_pos != x_pos_end
                        ret     z                       ;      .
                        ld (hl),bc                      ;        targetArray[y_pos] = x_pos
                        exx                             ;        if error >= 0
                        bit     7,h                     ;        .
                        jr      nz,.ErrorNegative       ;        .
.ErrorPositive:         ClearCarryFlag                  ;             error -= delta_x_step
                        sbc     hl,de                   ;             .
                        exx                             ;             back to main regsters
                        inc     hl                      ;             y pos for target Array index +2
                        inc     hl                      ;             as its 16 bit
                        jp      .WhileIncInstuction     ;             .
.ErrorNegative:         add     hl,bc                   ;        else error += delta y step
                        exx                             ;             back to main regsters
.WhileIncInstuction:    inc     bc                      ;       x_pos += sign_x (doneas self modifying to inc or dec)
                        jp      .WhileLoop
;..................................................................................................................................;--- Delta X < DeltaY ----------------------------------;         
;--- ELSE ----------------------------------------------;
;--- DX < DY -------------------------------------------;
;..................................................................................................................................;--- Delta X < DeltaY ----------------------------------;         
;                       error = delta x_step - delta y
DeltaXltDeltaY:         ErrorEquStepMinusDelta delta_x_step, delta_y 
;                       set exit false
                        SetExitFalse                    ; set exit = false
;                       if x1 < xmin && y pos > 127 then exit early
.IsY1TL0:               ld      hl,(x1Work)             ; if x1 < clip xmin
                        ld      de,(clip_xmin)          ; .
                        call    CompareHLDESigned               ; .
                        jp      z, .X1gteClipMin        ; .
                        jp      c, .X1ltClipMin         ; and y_pos > 127
                        ld      hl,(y1Work)             ;
.X1gteClipMin:          ReturnIfHLGT127                 ;    then return
;                       if y1 work < 0
.X1ltClipMin:           IsAxisLT0 (y1Work)              ; if y1 < 0             ;
                        jr      z,.Y1IsNotLT0           ; .
;                       ... temp = delta x step * (-y1)
.Y1IsLT0:               ld      hl,(y1Work)             ;    temp = (0 - y1) * delta_x_step;
                        NegHL                        ;    . (0 - y1 also equals negate HL)
                        ClearCarryFlag                  ;    .
                        ld      de,(delta_x_step)       ;    .
                        call    mulHLbyDE2sc            ;    .
                        ld      (linetemp),hl           ;    .
;                       ... msd = floor_divq (temp, delta y step)
                        ld      de,(delta_y_step)       ;    msd = floor_divq (temp, delta_y_step);
;                       ... rem calculation now done in floor macro above into de
                        FloorHLdivDETarget msd          ;    .
                        ld      (rem),de                ;    As DE = reminder we can do rem = temp % delta_y_step; for free
;                       ... xpos = xpos + msd
                        ex      hl,de                   ;    x pos += msd (move msd to de)
                        ld      hl,(x_pos)              ;    .            (pull in x1temp and add de)
                        add     hl,de                   ;    .
                        ld      (x_pos),hl              ;    .            (store result in x_pos) 
;                       ... if xpos > xmax
.IsXposGTClipXMax:      ld      de,(clip_xmax)          ;    if x_pos > clip_xmax then return
                        call      CompareHLDESigned               ;    .
;                       ...    or (pos = xmax && rem >= delta y) then return
                        jr      z,.XPosLTEXMax          ;    .
                        ret     nc                      ;    .
.XPosLTEXMax:           ld      de,(clip_xmin)          ;    if x_pos == clip_xmin
                        call      CompareHLDESigned               ;    .
                        jr      nz,.XneClipMax          ;    and rem >= deltay
                        ld      hl,(rem)                ;    .
                        ld      de,(delta_y)            ;    .
                        call      CompareHLDESigned               ;    .
                        ret     c                       ;    then return
;                       ... save rem and set y pos to 0
                        ex      de,hl                   ;    save rem
                        ld      hl,0                    ;    y_pos = 0
;                       ... error = error + rem
                        ld      (y_pos),hl              ;    error += rem
                        ld      hl,(error)              ;    .
                        add     hl,de                   ;    .
                        ld      (error),hl              ;    .
;                       ... if rem >= delta y
                        ex      de,hl                   ;    if (rem >= delta_y)
                        ld      de,(delta_y)            ;    .
                        call      CompareHLDESigned               ;    .
                        jr      z,.RemGTEDeltaY         ;    .
                        jr      nc,.RemGTEDeltaY        ;    .
;                       ... ... x pos = x pos + 1                        
                        ld      hl,x_pos                ;       ++x_pos
                        inc     (hl)                    ;       .
                        ld      hl,(error)              ;       error += delta_y_step
                        ld      de,(delta_y_step)       ;       .
                        add     hl,de                   ;       .
                        ld      (error),hl              ;       .
.RemGTEDeltaY:                        
.Y1IsNotLT0:
.XneClipMax:            ld      hl,(y2Work)             ;  y_pos_end = y2
                        ld      (y_pos_end),hl          ;  .
                        ld      de,127                  ;  y_pos_end = (y_pos_end < 127)?y_pos_end+1:128
                        call      CompareHLDESigned               ;  .
                        jr      nc,.YPosEndlt127        ;  .
                        ld      hl,128                  ;  .
                        jp      .DoneXneClipMax         ;  .
.YPosEndlt127:          inc     hl                      ;  .
.DoneXneClipMax:        ld      (y_pos_end),hl          ;  .
                                                        ; if sign_x == -1
.Y2LTE127:              IsMemNegative8JumpFalse sign_x, .SignXNotNegative
.SignXNegative:         ld      hl,(x_pos)              ;    x_pos = -x_pos
                        NegHL                        ;    .
                        ld      (x_pos),hl              ;    .
                        ld      hl,(y2Work)             ;    x_pos_end = -x_pos_end
.SignXNotNegative:      ld      hl,(delta_y_step)       ; delta_y_step -= delta_x_step
                        ld      de,(delta_x_step)       ; .  
                        ClearCarryFlag                  ; .  
                        sbc     hl,de                   ; .  
                        ld      hl,(delta_x_step)       ; .                          
.IsLongest:             ld      a,(longest)             ;    if (not longest)
                        and     a                       ;    . 
                        jp      z,DxLTDy                ;       goto Dx < Dy Not Longest
                                                        ;    else fall into Dx < Dy Longest
;..................................................................................................................................
;--- Dx < Dy Longest while loop ------------------------;    
DxLTDyLongest:          ld      hl,(y_pos)              ;       starty=y_pos
                        ld      (starty),hl             ;       .
;--- Version where longest issaved ---------------------;    
.LoadAlternateRegs:     ld      bc,(y_pos)              ;       we already have IY so just need xpos and end
                        ld      de,(y_pos_end)
                        ld      iy,(x_pos)
                        ld      hl,ix                   ;    load hl as target array
                        ld      a,c                     ;    by this point y pos must be 8 bit
                        add     hl,a                    ;    So we are setting up hl as targetArray pointer
                        add     hl,a     
                        exx                             ;       switch to alternate registers
                        ld      hl,(error)              ;       load up stepping into alternate registers
                        ld      de,(delta_x_step)       ;       and error
                        ld      bc,(delta_y_step)       ;
                        exx                             ;       and then switch back to main registers
                        ld      a,(sign_x)              ;       if Sign x is -1
                        and     $80                     ;       .
                        jr      z,.SetWhileInc          ;       .
                        ld      a,InstrDECIY
.SetWhileDec:           ld      (.WhileIncInstuction+1), a; set self modifying to dec and 2 byte instruction
                        jp      .WhileLoop:         ;           .
.SetWhileInc:           ld      a,InstrDECIY
                        ld      (.WhileIncInstuction+1), a; else set to inc
;--- Update Loop ---------------------------------------;
; In loop hl  = target array pointer bc = x_pos,       de = x_pos_end, (we don't need to reatin Y_pos)
;         hl' = error                bc'= delta_y_step de'=delta_x_step
;-- we coudl optimise by setting bc to y_pos_end - y_pos +1 and just doing djnz
.WhileLoop:             call    CompareBCDESigned       ;      while y_pos != y_pos_end
                        jp      z,.DoneWrite            ;      .
                        ld      a,iyl
                        ld      (hl),a                  ;        targetArray[y_pos] = x_pos
                        inc     hl
                        ld      a,iyh
                        ld      (hl),a
                        inc     hl
                        exx                             ;        if error >= 0
                        bit     7,h                     ;        .
                        jr      nz,.ErrorNegative       ;        .
.WhileIncInstuction:    inc     iy                      ;             x_pos += sign_x (doneas self modifying to inc or dec)
.ErrorPositive:         ClearCarryFlag                  ;             error -= delta_y_step
                        sbc     hl,bc                   ;             .
                        jp      .LoopEnd                ;             .
.ErrorNegative:         add     hl,de                   ;        else error += delta x step
.LoopEnd:               exx                             ;             back to main regsters
                        inc     bc                      ;        ++y_pos
                        jp      .WhileLoop              ;
.DoneWrite:             ld      (endy),bc               ;       endy = y_pos
                        ret                             ;
;..................................................................................................................................
;--- Dx < Dy Longest while loop ------------------------;    
DxLTDy:                 ld      hl,(y_pos)              ;       starty=y_pos
                        ld      (starty),hl             ;       .
;--- Version where longest issaved ---------------------;    
.LoadAlternateRegs:     ld      bc,(y_pos)              ;       we already have IY so just need xpos and end
                        ld      de,(y_pos_end)
                        ld      iy,(x_pos)
                        ld      hl,ix                   ;    load hl as target array
                        ld      a,c                     ;    by this point y pos must be 8 bit
                        add     hl,a                    ;    So we are setting up hl as targetArray pointer
                        add     hl,a     
                        exx                             ;       switch to alternate registers
                        ld      hl,(error)              ;       load up stepping into alternate registers
                        ld      de,(delta_x_step)       ;       and error
                        ld      bc,(delta_y_step)       ;
                        exx                             ;       and then switch back to main registers
                        ld      a,(sign_x)              ;       if Sign x is -1
                        and     $80                     ;       .
                        jr      z,.SetWhileInc          ;       .
.SetWhileDec:           ld      a,InstrDECIY
                        ld      (.WhileIncInstuction+1),a; set self modifying to dec and 2 byte instruction
                        jp      .WhileLoop:             ;       .
.SetWhileInc:           ld      a,InstrINCIY
                        ld      (.WhileIncInstuction+1),a; else set to inc
;--- Update Loop ---------------------------------------;
; In loop hl  = target array pointer bc = x_pos,       de = x_pos_end, (we don't need to reatin Y_pos)
;         hl' = error                bc'= delta_y_step de'=delta_x_step
;- we coudl optimise by setting bc to y_pos_end - y_pos +1 and just doing djnz
.WhileLoop:             call    CompareBCDESigned       ;      while y_pos != y_pos_end
                        ret     z                       ;      .
                        ld      a,iyl
                        ld      (hl),a                ;        targetArray[y_pos] = x_pos
                        inc     hl
                        ld      a,iyh
                        ld      (hl),a
                        inc     hl
                        exx                             ;        if error >= 0
                        bit     7,h                     ;        .
                        jr      nz,.ErrorNegative       ;        .
.WhileIncInstuction:    inc     iy                      ;             x_pos += sign_x (doneas self modifying to inc or dec)
.ErrorPositive:         ClearCarryFlag                  ;             error -= delta_y_step
                        sbc     hl,bc                   ;             .
                        jp      .LoopEnd                ;             .
.ErrorNegative:         add     hl,de                   ;        else error += delta x step
.LoopEnd:               exx                             ;             back to main regsters
                        inc     bc                      ;        ++y_pos
                        jp      .WhileLoop

saveP1X            DW 0
saveP2X            DW 0
saveP3X            DW 0
saveP1Y            DW 0
saveP2Y            DW 0
saveP3Y            DW 0
;---------------------------------------------------------------------------------------------
;HL'HL = x1y1, DE'DE = x2y2 BC'BC = x3y3
l2_draw_fillclip_tri:   push    hl
                        ld      hl,$FFFF
                        ld      (starty),hl
                        ld      (endy),hl
                        pop     hl
;   sort order y ascending
                        call    CompareHLBCSigned       ; y registers are in main
                        jr      z,.HLlteBC
                        jr      c,.HLlteBC
.HLgtBC:                push    bc                      ; swap x1y1 with x3y3
                        ld      bc,hl
                        pop     hl
                        exx                             ; x registers are in main
                        push    bc
                        ld      bc,hl
                        pop     hl
                        exx                             ; y registers are in main
.HLlteBC:               call    CompareHLDESigned
                        jr      z,.HLlteDE
                        jr      c,.HLlteDE
.HLgtDE:                ex      de,hl                   ; swap x1y1 with x2y2
                        exx                             ; x registers are in main
                        ex      de,hl
                        exx                             ; y registers are in main
.HLlteDE:               call    CompareDEBCSigned
                        jr      z,.DElteBC
                        jr      c,.DElteBC
.DEgtBC:                push    bc                      ; swap x2y2 with x3y3
                        ld      bc,hl
                        pop     hl
                        exx                             ; x registers are in main
                        push    bc
                        ld      bc,hl
                        pop     hl
;                       layer2_save_clipy_line(lx1, ly1, lx3, ly3, SaveArrayS1, true)
.DElteBC:
.LineP1toP3Save:        ld      (saveP1Y),hl            ;                                       T 20
                        ld      (saveP2Y),de            ;                                       T 20
                        ld      (saveP3Y),bc            ;                                       T 20
                        ld      de,bc                   ;                                       T  8
                        exx                             ;                                       T  4
                        ld      (saveP1X),hl            ;                                       T 20
                        ld      (saveP2X),de            ;                                       T 20
                        ld      (saveP3X),bc            ;                                       T 20
                        ld      de,bc                   ;                                       T  8
                        ld      ix,SaveArrayS1          ; SaveArrayS1                           T 14
                        ld      a,$FF                   ; and Longest is True                   T  7
                        break                                                                   
                        call    Layer2_Save_ClipY_Line  ; hl'hl = x1y1 de'de = x3y3             
.LineP1toP2Save:        ld      hl,(saveP2X)            ;                                       T 20
                        ld      de,(saveP3X)            ;                                       T 20
                        exx                             ;                                       T  4
                        ld      hl,(saveP2Y)            ;                                       T 20
                        ld      de,(saveP3Y)            ;                                       T 20
                        ld      ix,SaveArrayS2          ; SaveArrayS2                           T 14
                        ZeroA                           ;                                       T  4
                        break
                        call    Layer2_Save_ClipY_Line  ; hl'hl = x1y1 de'de = x2y2             T
                        ld      hl,(saveP1X)            ;                                       T 20
                        ld      de,(saveP2X)            ;                                       T 20
                        exx                             ;                                       T  4
                        ld      hl,(saveP1Y)            ;                                       T 20
                        ld      de,(saveP2Y)            ;                                       T 20
                        ld      ix,SaveArrayS2          ; SaveArrayS2                           T 14
                        ZeroA                           ;                                       T  4
                        break
                        call    Layer2_Save_ClipY_Line  ; hl'hl = x1y1 de'de = x2y2             T
.LineP2toP3Save:        ld      hl,(saveP2X)            ;                                       T 20
                        ld      de,(saveP3X)            ;                                       T 20
                        exx                             ;                                       T  4
                        ld      hl,(saveP2Y)            ;                                       T 20
                        ld      de,(saveP3Y)            ;                                       T 20
                        ld      ix,SaveArrayS2          ; SaveArrayS2                           T 14
                        ZeroA                           ;                                       T  4
                        break
                        call    Layer2_Save_ClipY_Line  ; hl'hl = x1y1 de'de = x2y2
.PrepareForLoop:        ld      hl,(endy)               ; bc = number of iterations
                        ld      de,(starty)             ; de = starting y coordinate
                        ClearCarryFlag                  ;
                        sbc     hl,de                   ;
                        inc     hl                      ;
                        ld      b,l                     ; as it should now be 8 bit
                        ld      c,e                     ; c = starty 8 bit
.PrepSaveArrayS1Ptr:    ld      hl,SaveArrayS1          ; hl = pointer to SaveArrayS1[starty]
                        add     hl,de                   ;
                        add     hl,de                   ;
                        push    hl                      ; save to get back later
.PrepSaveArrayS2Ptr:    ld      hl,SaveArrayS2          ; de = pointer to SaveArrayS1[starty]
                        add     hl,de                   ;
                        add     hl,de                   ;
                        ex      de,hl                   ; 
                        pop     hl                      ; hl = pointer to SaveArrayS1[starty]
.IsLineOffScreen:       inc     hl                      ; move hl and de on for consistency
                        inc     de
                        ld      a,(hl)                  ; If SAS1 and SAS2 are Negative
                        bit     7,a                     ; .
                        jr      z,.S1XPositive          ; 
.S1XNegative:           ld      a,(de)                  ; .      
                        bit     7,a                     ; .
                        jp      nz,.S1S2OutOfBounds     ;    then out of bounds
                        jp      .OKToDraw               ; as S1 is negative and S2 positive we draw
.S1XPositive:           and     a                       ; If SAS1 and SAS2 > 255
                        jr      z,.OKToDraw             ; (if SAS1 <=255, always OK to draw)
                        ld      a,(de)                  ; (check SAS2 for negative)
                        bit     7,a                     ;
                        jp      nz,.OKToDraw            ; (neagtive SAS2 positive SAS1)
                        and     a                       ; (Check SAS2 > 255)
                        jp      nz,.S1S2OutOfBounds     ; if > 255 then don't draw
.OKToDraw:              push    hl,,de,,bc              ; save pointers
                        ld      a,(hl)                  ; hl = (hl)
                        dec     hl                      ;
                        ld      l,(hl)                  ;
                        ld      h,a                     ;
                        ex      de,hl                   ; de = (SaveArrayS1)
                        ld      a,(hl)                  ; hl = (hl)
                        dec     hl                      ;
                        ld      l,(hl)                  ;
                        ld      h,a                     ; de = (SaveArrayS2)
.ClipX1X2:              ld      a,d
                        bit     7,a
                        jr      z,.ClipX2
                        ld      e,0
                        jr      .ClipX2
.ClipX2:                ld      a,h
                        bit     7,a
                        jr      z,.ClipDone
                        ld      l,0
.ClipDone:              call    l2_draw_horz_saved      ; draw d to h at Y=c (sort d and h in the draw routine)
.Iterate:               pop     hl,,de,,bc
                        inc     hl                      ; if draw is successful we inc a word
                        inc     de
                        inc     hl
                        inc     de
                        inc     c
                        djnz    .IsLineOffScreen        ; optimise with only one inc
                        ret 
.S1S2OutOfBounds:       inc     hl                      ; handle loop for out of bounds
                        inc     de                      ; we do this as we can 
                        inc     c
                        djnz    .IsLineOffScreen        ; optimise with only one inc
                        ret 
                        
                        
