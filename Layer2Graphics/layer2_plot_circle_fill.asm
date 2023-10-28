
l2_circle_dblx		DB 0
l2_circle_dbly		DB 0

; ">l2_draw_circle_fill BC = center row col, d = radius, e = colour"
; Note this code currently does not process BC
l2_draw_circle_fill:    ld		a,e
                        ld		(.LineColour+1),a
                        ld		a,d								; get radius
                        and		a
                        ret		z
                        cp		1
                        jp		z,CircleSinglepixel
                        ld		(.Line1+1),bc					; save origin into DE reg in code
                        ld		ixh,a							; ixh = raidus (x)
                        ld		ixl,0							; ihy = y
.calcd:	                ld		h,0
                        ld		l,a
                        add		hl,hl							; hl = r * 2
                        ex		de,hl							; de = r * 2
                        ld		hl,3
                        and		a
                        sbc		hl,de							; hl = 3 - (r * 2)
                        ld		b,h
                        ld		c,l								; bc = 3 - (r * 2)
.calcdelta              ld		hl,1
                        ld		d,0
                        ld		e,ixl
                        and		a
                        sbc		hl,de
.Setde1	                ld		de,1
.CircleLoop:            ld		a,ixh
                        cp		ixl
                        ret		c
.ProcessLoop:	        exx
.Line1:                 ld		de,0
                        ld 		a,e
                        sub 	ixl
                        ld 		c,a
                        ld 		a,d
                        add 	a,ixh
                        ld		b,a
                                    DISPLAY "TODO: add double x calc"
                        ;; TODO ADD DOUBLE X CALC
                        push	de
                        ld		d,ixl
                        sla		d
                        call	.PlotLine			;CX-X,CY+Y
                        pop		de
.Line2:                 ld 		a,e
                        sub		ixl
                        ld 		c,a
                        ld 		a,d
                        sub 	ixh
                        ld 		b,a
                        ;; TODO ADD DOUBLE X CALC
                        push	de
                        ld		d,ixl
                        sla		d
                        call	.PlotLine			;CX-X,CY-Y
                        pop		de
.Line3:	                ld 		a,e
                        sub		ixh
                        ld 		c,a
                        ld 		a,d
                        add 	a,ixl
                        ld 		b,a
                        ;; TODO ADD DOUBLE Y CALC
                        push	de	
                        ld		d,ixh
                        sla		d
                        call	.PlotLine			;CX-Y,CY+x
                        pop		de
.Line4:	                ld 		a,e
                        sub		ixh
                        ld 		c,a
                        ld 		a,d
                        sub 	ixl
                        ld 		b,a
                        ;; TODO ADD DOUBLE Y CALC
                        push	de	
                        ld		d,ixh
                        sla		d
                        call	.PlotLine			;CX-Y,CY+x
                        pop		de
                        exx
.IncrementCircle:	    bit 7,h				; Check for Hl<=0
                        jr z,.draw_circle_1
                        add hl,de			; Delta=Delta+D1
                        jr .draw_circle_2		; 
.draw_circle_1:		    add hl,bc			; Delta=Delta+D2
                        inc bc
                        inc bc				; D2=D2+2
                        dec ixh				; Y=Y-1
.draw_circle_2:		    inc bc				; D2=D2+2
                        inc bc
                        inc de				; D1=D1+2
                        inc de	
                        inc ixl				; X=X+1
                        jp .CircleLoop
.PlotLine:              push	de,,bc,,hl,,af
.LineColour:	        ld		a,0         ; circle colur
                        ld      e,a
                        call 	l2_draw_horz_line
                        pop     de,,bc,,hl,,af
                        ret

; ">l2_draw_clipped_circle HL = Center X 2's c, DE = Center Y 2's , c = radius, b = colour"
l2_draw_clipped_circle_filled:     
                    ld      a,b                             ; save Colour
                    ld		(.PlotColour+1),a
                    ld		a,c								; get radius
                    ReturnIfAIsZero
                    JumpIfAEqNusng  1, .circleSinglepixel
                    ld		(.Plot1Y+1),de					; save origin into DE and HL
                    ld      (.Plot1X+1),hl                  ; .
                    DISPLAY "TODO : IXH and IXL need to be 16 bit and in IX and IY"
                    ld		ixh,a							; ixh = x = raidus 
                    ld		ixl,0						    ; ixl = y = error 
.calcd:	            ld		h,0                             ; hl = radius
                    ld		l,a                             ; raidius is still in a at this point
                    add		hl,hl							; hl = r * 2
                    ex		de,hl							; de = r * 2
                    ld		hl,3                            ; hl = 3 - (r * 2)
                    ClearCarryFlag                          ; .
                    sbc		hl,de							; .
                    ld      bc,hl                           ; bc = 3 - (r * 2)
.calcdelta:         ld		hl,1                            ; hl = 1
                    ld		d,0                             ; de = ixl (error)
                    ld		e,ixl                           ; 
                    ClearCarryFlag                          ;
                    sbc		hl,de                           ; hl = 1 - error
.Setde1:            ld		de,1                            ; de = 1
.CircleLoop:        ReturnIfRegLTNusng ixh, ixl             ; if radius > ixl counter
.ProcessLoop:	    exx                                     ; save all bc,de,hl registers
; For line drawing we can go from left to right in a single call
;--- from CX-X to CX+X, CY+Y -------------------------------;
.Plot1Y:            ld		de,0                            ; this is Y coord
.Plot1X:            ld      hl,0                            ; this is x coord
.Plot1:             push    hl,,de                          ; push X then Y  on top Stack+2
                    CalcNewPointMacro hl, sbc, ixh          ; hl = CX - X
                    ex      de,hl                           ; de = CX - X
                    ld      (.LoadDEXStart1+1),de           ; save it for Plot 2 as well
                    CalcNewPointMacro hl, adc, ixl          ; hl = CY + Y
                    ld      b,0                             ; Now we have calculated D is bc
                    ld      c,ixh                           ;
                    ShiftBCLeft1                            ;
                    ld      (.LoadBCLength1+1),bc            ; self modifying to optimise laod on line 2
                    call	.PlotLine               		; de = start X, hl= Y line, bc = length
.Plot1Done:         pop     hl                              ; Stack+1 get cy from stack into hl to save an ex as we have pre calculated x positions
;--- from CX-X to CX+X, CY-Y -------------------------------;
.Plot2:             push    hl                              ; Stack+2 put cy back on stack so it holds cy stack already holds cx
                    CalcNewPointMacro hl, sbc, ixl          ; now we have CY-Y in hl
.LoadDEXStart1:     ld      de,0                            ; de is loaded from above via self modiying code with start X
.LoadBCLength1:     ld      bc,0                            ; bc is loaded from above via self modifying code with length
                    call	.PlotLine                       ; 
.Plot2Done:         pop     hl,,de                          ; Stack+0 now hl = cx, de = cy
;--- from CX-Y to CX+Y, CY+X -------------------------------;
.Plot3:             push    de                              ; Stack + 1 we need cy for final plot calculation
                    CalcNewPointMacro hl, sbc, ixl          ; hl = CX - Y
                    ex      de,hl                           ; de = CX - Y
                    ld      (.LoadDEXStart2+1),de             ; save it for Plot 2 as well
                    CalcNewPointMacro hl, adc, ixh          ; hl = CY + X
                    ld      b,0                             ; Now we have calculated D is bc
                    ld      c,ixl                           ;
                    ShiftBCLeft1                            ;
                    ld      (.LoadBCLength2+1),bc            ; self modifying to optimise laod on line 2
                    call	.PlotLine               		; de = start X, hl= Y line, bc = length
.Plot3Done:         pop     hl                              ; Stack + 0 get cy from stack into hl to save an ex as we have pre calculated x positions
;--- from CX-X to CX+X, CY-Y -------------------------------;
.Plot4a:            CalcNewPointMacro hl, sbc, ixh          ; now we have CY-X in hl
.LoadDEXStart2:     ld      de,0                            ; de is loaded from above via self modiying code with start X
.LoadBCLength2:     ld      bc,0                            ; bc is loaded from above via self modifying code with length
                    call	.PlotLine                       ; 
.PlotDone:          exx                                     ; get back data from alternate registers
.IncrementCircle:	bit     7,h			                  	; Check for Hl<=0
                    jr z,   .draw_circle_1
                    add hl,de			                    ; Delta=Delta+D1
                    jr      .draw_circle_2		            ; 
.draw_circle_1:		add     hl,bc		                    ; Delta=Delta+D2
                    inc     bc                              
                    inc     bc			                    ; D2=D2+2
                    dec     ixh			                    ; Y=Y-1
.draw_circle_2:		inc     bc			                    ; D2=D2+2
                    inc     bc                              
                    inc     de			                    ; D1=D1+2
                    inc     de	                            
                    inc     ixl			                    ; X=X+1
                    jp      .CircleLoop
;-- PERFORM THE LINE DRAW ----------------------------------;
; comes in with de = left x , hl = y, bc = length
; Note bc must be +ve < 32768
.PlotLine:          
.IsYOnScreen:       ld      a,h                             ; if y > 255 or < 0 then no line to draw
                    and     a                               ;
                    ret     nz                              ;
                    ld      a,l                             ;
                    and     a                               ;
                    ret     m                               ; if m set then y must be > 127
;-- now check X coordinate, if X < 256 then skip x position clip
.IsXOffRight:       ld      a,d                             ; if x >255
                    and     a
                    jr      z,.NoLeftClip                   ; if high is not set then no X clip
;-- if X > 255 then off screen so just skip line
.LeftClip:          ret     p                               ; if its > 255 then no line        
;-- if its off the left then add distance, if this is < 0 then off screen skip
.IsTotallyOffLeft:  push    hl                              ; if X pos + length <0 then no line
                    ld      hl,de                           ; .
                    ClearCarryFlag                          ; .
;    but also this calculation gives us the line length if x is clipped to 90            
                    adc     hl,bc                           ; .
                    ld      bc,hl                           ; save the result in HL as this is also line length from hl = 0
                    pop     hl                              ; .
                    ret     m                               ; if x + distance < 0 then off screen skip
;-- now as its on screen but clipped x < 0 we can just draw a line from 0 to x+d, maxed at x+d = 255
.ClippedSpanX:      ld      de,0                            ; if off left X = 0, bc already calcualted above in ADC
                    ld      a,b                             ; if bc < 255 then good
                    and     a   
                    jp      z,.NoPopPlotColour              ;
                    ld      bc,255                          ; max length
                    jp      .NoPopPlotColour                ; we can now just draw
;-- No left side clipping needed so we just need to work out if x + d > 255
.NoLeftClip:        push    hl                              ; STACK+1 if corrected x + length < 256 then 
                    ld      hl,de                           ; just plot
                    add     hl,bc
                    ld      a,h
                    or      a
                    pop     hl
                    jp      z,.NoPopPlotColour
;-- x + d > 255 so we plot from x to distance 255 - x                    
.LengthClip:        push    hl                              
                    ld      hl,255
                    ClearCarryFlag
                    sbc     hl,de                           ; now hl = corrected length
                    ld      bc,hl
;-- This entry point is if there is hl on the stack
.PopHLPlotColour:   pop     hl                    
.NoPopPlotColour:   ld      d,c             ; d = length
                    ld      c,e             ; c = start X
                    ld      b,l             ; b = row Y
.PlotColour:        ld		e,0             ; This was originally indirect, where as it neeed to be value
                    call    l2_draw_horz_dma_bank
                    ClearCarryFlag
                    ret
.circleSinglepixel: ld      a,h             ; as its 1 pixel if h or d are non zero then its off screen
                    or      d
                    ret     nz
                    bit     7,e             ; and if Y is > 127 then off screen , bit is 8 states like ld a,e and a
                    ret     nz
                    ld      a,b             ; a = colour
                    ld      b,e             ; b = y
                    ld      c,l             ; c = x
                    call    l2_plot_pixel
                    ret