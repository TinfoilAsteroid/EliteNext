
l2_elipse_pos		DW 0
l2_elipse_colour	DB 0
l2_elipse_radius	DB 0
l2_elipse_x			DB 0
l2_elipse_y			DB 0
l2_elipse_d			DB 0

l2_elipse_xHeap 	DS 2*66
l2_elipse_yHeap     DS 2*66
l2_elipse_heap_size DB 0
l2_elipse_clip_y    DW 0
l2_elipse_clip_x    DW 0
l2_elipse_flag      DB 0
l2_elipse_counter   DB 0
;Sine table
;FOR I%, 0, 31
;
; N = ABS(SIN((I% / 64) * 2 * PI))
;
; IF N >= 1
;  EQUB 255
; ELSE
;  EQUB INT(256 * N + 0.5)
; ENDIF
;
;NEXT

;---------------------------------------------------------------------------------------------------------------------------------
; in HL = xPixelPos, DE = yPixelPos, A = Radius
;IFDEF   CIRCLE2
;;;;+l2_circle_clipped:	ld		(l2_circle_radius),a
;;;;+					ld		(l2_circle_clip_y),de
;;;;+					ld		(l2_circle_clip_x),hl
;;;;+					ZeroA
;;;;+					ld		(l2_circle_heap_size),a
;;;;+					ld		(l2_circle_counter),a
;;;;+					dec		a
;;;;+					ld		(l2_circle_flag),a
;;;;+.CircleLoop:		call	SinCounter						; a = sin (counter) * 256
;;;;+					ld		d,a
;;;;+					ld		a,(l2_circle_radius)
;;;;+					ld		e,a
;;;;+					mul										; de = k * sin (counter) so d = k * sin (counter) / 256
;;;;+					ld		e,d								; using de as TA
;;;;+					ld		d,0
;;;;+					ld		a,(l2_circle_counter)
;;;;+					JumpIfALTNusng 33,.RightHalf
;;;;+.LeftHalf:			NegateDE								; if >= 33 then DE = de * -1 (2's c)
;;;;+					K6 = de + l2_circle_clip_x
;;;;+					call	CosCounter
;;;;+					ld		d,a
;;;;+					ld		a,(l2_circla_radius)
;;;;+					mul		de
;;;;+					ld		e,d
;;;;+					ld		d,0
;;;;+					a 		= l2_counter + 15 mod 64
;;;;+					JumpIfALTNusng	33, .BottomHalf
;;;;+.TopHalf:			NegateDE
;;;;+					K62 = de + l2_circle_clip_y
;;;;+					ld		a,(l2_circle_flag)
;;;;+					JumpIfAIsZZero		.SkipFlagUpdate
;;;;+					inc		a
;;;;+					ld		(l2_circle_flag),a
;;;;+.SkipFlagUpdate:	
;;;;+					
;;;;+                X = K * SIN (CNT + 16) (i.e X = K * COS (CNT)
;;;;+                A = (CNT + 15) mod 64
;;;;+                if  A >= 33     ; top half of circle
;;;;+                    X = neg X
;;;;+                    T = negative
;;;;+                call    Bline (draw segment)
;;;;+                        K6(32) = TX + K4(10) = y corrc of center + new point
;;;;+                        if flag <> 0
;;;;+                            flag ++ (as flag initially will be $FF so go to 0)
;;;;+                        BL5:    
;;;;+                        if LSY2[LSP-1] <> $FF and LSY2 [LSP1] <> $FF    (BL5)
;;;;+                            X15 [0 1] = K5(10)                      (BL1)
;;;;+                            X15 [2 3] = K5(32)
;;;;+                            X15 [4 5] = K6(10)
;;;;+                            X15 [6 7] = K6(32)
;;;;+                            call clip X1Y1 to X2Y2
;;;;+                            if Line off scren goto BL5
;;;;+                            IF swap <> 0
;;;;+                                swap X1Y1 with X2Y2
;;;;+                            Y = LAP                                 (BL9)
;;;;+                            A = LSY2-1 [Y]
;;;;+                            if A = $FF
;;;;+                                LSX2[Y] = X1
;;;;+                                LSY2[Y] = Y1
;;;;+                                Y++
;;;;+                                
;;;;+                            Store X2 in LSX2(Y)                     (BL8)
;;;;+                            Store Y2 in lSY2(y)
;;;;+                            call    DrawLine from (X1 Y1 to X2 Y2)
;;;;+                            if  XX13 <> 0 goto BL5
;;;;+                                                                (BL7)
;;;;+                        Copy data for K6(3210) into K5(3210) for next call (K5(10) = x  K5(32) = y)
;;;;+                        CNT = CNT + STP
;;;;+            while CNT < 65
;ENDIF
;---------------------------------------------------------------------------------------------------------------------------------
; ">l2_draw_circle BC = center row col, d = radius, e = colour"
l2_draw_circle:     ld		a,e
                    ld		(.PlotPixel+1),a
                    ld		a,d								; get radius
                    and		a
                    ret		z
                    cp		1
                    jp		z,CircleSinglepixel
                    ld		(.Plot1+1),bc					; save origin into DE reg in code
                    ld		ixh,a							; ixh = raidus
                    ld		ixl,0						
.calcd:	            ld		h,0
                    ld		l,a
                    add		hl,hl							; hl = r * 2
                    ex		de,hl							; de = r * 2
                    ld		hl,3
                    and		a
                    sbc		hl,de							; hl = 3 - (r * 2)
                    ld		b,h
                    ld		c,l								; bc = 3 - (r * 2)
.calcdelta:         ld		hl,1
                    ld		d,0
                    ld		e,ixl
                    and		a
                    sbc		hl,de
.Setde1:            ld		de,1
.CircleLoop:        ld		a,ixh
                    cp		ixl
                    ret		c
.ProcessLoop:	    exx
.Plot1:             ld		de,0
                    ld		a,e
                    add		a,ixl
                    ld		c,a
                    ld		a,d
                    add		a,ixh
                    ld		b,a
                    call	.PlotPixel			;CX+X,CY+Y
.Plot2:             ld 		a,e
                    sub 	ixl
                    ld 		c,a
                    ld 		a,d
                    add 	a,ixh
                    ld		b,a
                    call	.PlotPixel			;CX-X,CY+Y
.Plot3:             ld 		a,e
                    add		a,ixl
                    ld 		c,a
                    ld 		a,d
                    sub 	ixh
                    ld 		b,a
                    call	.PlotPixel			;CX+X,CY-Y
.Plot4:             ld 		a,e
                    sub 	ixl
                    ld 		c,a
                    ld 		a,d
                    sub 	ixh
                    ld 		b,a
                    call	.PlotPixel			;CX-X,CY-Y
.Plot5:	            ld 		a,d
                    add 	a,ixl
                    ld 		b,a
                    ld 		a,e
                    add 	a,ixh
                    ld 		c,a
                    call	.PlotPixel			;CY+X,CX+Y
.Plot6:	            ld 		a,d
                    sub 	ixl
                    ld 		b,a
                    ld 		a,e
                    add 	a,ixh
                    ld 		c,a
                    call	.PlotPixel			;CY-X,CX+Y
.Plot7:	            ld 		a,d
                    add 	a,ixl
                    ld 		b,a
                    ld 		a,e
                    sub 	ixh
                    ld 		c,a
                    call	.PlotPixel			;CY+X,CX-Y
.Plot8:	            ld 		a,d
                    sub 	ixl
                    ld		b,a
                    ld 		a,e
                    sub 	ixh
                    ld 		c,a
                    call	.PlotPixel			;CY-X,CX-Y
                    exx
.IncrementCircle:	bit     7,h				; Check for Hl<=0
                    jr z,   .draw_circle_1
                    add hl,de			; Delta=Delta+D1
                    jr      .draw_circle_2		; 
.draw_circle_1:		add     hl,bc			; Delta=Delta+D2
                    inc     bc
                    inc     bc				; D2=D2+2
                    dec     ixh				; Y=Y-1
.draw_circle_2:		inc bc				; D2=D2+2
                    inc bc
                    inc de				; D1=D1+2
                    inc de	
                    inc ixl				; X=X+1
                    jp      .CircleLoop
.PlotPixel:         ld		a,0                  ; This was originally indirect, where as it neeed to be value
                    push	de,,bc,,hl
                    l2_plot_macro; call 	l2_plot_pixel_y_test
                    pop		de,,bc,,hl
                    ret
CircleSinglepixel:  ld		a,e
                    l2_plot_macro; call	l2_plot_pixel_y_test
                    ret

; ">l2_draw_clipped_circle HL = Center X 2's c, DE = Center Y 2's c = center , c = radius, b = colour"
l2_draw_clipped_circle:     ld		b,e                     ; save Colour
                    ld		(.PlotPixel+1),a
                    ld		a,c								; get radius
                    ReturnIfAIsZero
                    JumpIfAEqNusng  1, .circleSinglepixel
                    ld		(.Plot1Y+1),de					; save origin into DE and HL
                    ld      (.Plot1X+1),hl                  ; .
                    ld		ixh,a							; ixh = raidus
                    ld		ixl,0						    ; ixl = 0
.calcd:	            ld		h,0                             ; hl = radius
                    ld		l,a                             ; .
                    add		hl,hl							; hl = r * 2
                    ex		de,hl							; de = r * 2
                    ld		hl,3                            ; hl = 3 - (r * 2)
                    and		a                               ; .
                    sbc		hl,de							; .
                    ld		b,h                             ; bc = 3 - (r * 2)
                    ld		c,l								; .
.calcdelta:         ld		hl,1                            ; hl = 1
                    ld		d,0                             ; de = ixl
                    ld		e,ixl                           ; 
                    and		a                               ;
                    sbc		hl,de                           ; hl = 1 - radius
.Setde1:            ld		de,1                            ; de = 1
.CircleLoop:        ReturnIfRegLTNusng ixh, ixl             ; if radius > ixl counter
.ProcessLoop:	    exx                                     ; save all bc,de,hl registers
.Plot1Y:            ld		de,0                            ; this is Y coord
.Plot1X:            ld      hl,0                            ; this is x coord
                    push    hl,,de,,bc                      ; save bc +3
                    ld      b,0
                    ld      c,ixl
                    ClearCarryFlag
                    adc     hl,bc
                    pop     bc                              ; can optimise, perhaps use iy instead of bc or just optimise push pop and jump to an overall .Plot1Done and minimise push pops + 2
                    JumpIfRegIsNotZero  h,.Plot1Done        ; if h <> 0 then hl < 0 or hl > 255
                    ex      de,hl                           ; now de = x coord calculated
                    push    bc                              ; + 3
                    ClearCarryFlag
                    ld      b,0
                    ld      c,ixl
                    adc     hl,bc
                    pop     bc                              ; + 2
                    JumpIfRegIsNotZero  h,.Plot1Done        ; if h <> 0 then hl < 0 or hl > 255
                    call	.PlotPixel	            		;CX+X,CY+Y using DE = x and hl = y *** Note if we order plot 1 to 8 we can selectivley jump past many on elimiation check
.Plot1Done:         pop     hl,,de                          ; get de (y) and hl (x) back but reversed as the next plot expected the to be reversed from the ex de,hl above  + 0
.Plot2:             push    hl,,de,,bc                      ; e.g  do all CX + X first, so plot1, plot3 and just one check for cx + x off screen                    
                    ld      b,0                             ;                              plot2, plot8 for cx - x                     
                    ld      c,ixl                           ;                              plot4, plot5 for cy + x  ** Need to check the comments on each plot are correct      
                    ClearCarryFlag                          ;                              plot6        for cy - x                     
                    sbc     hl,bc                           ;                              plot7 is last one
                    pop     bc                              ;
                    JumpIfRegIsNotZero  h,.Plot2Done        ;
                    ex      de,hl                    
                    push    bc
                    ld      b,0
                    ld      c,ixl
                    ClearCarryFlag
                    adc     hl,bc
                    pop     bc                    
                    JumpIfRegIsNotZero  h,.Plot2Done 
                    call	.PlotPixel	                    ; CX-X,CY+Y                 
.Plot2Done:         pop     de,,hl
.Plot3:             push    hl,,de,,bc                   
                    ld      b,0                          
                    ld      c,ixl                        
                    ClearCarryFlag                       
                    adc     hl,bc                        
                    pop     bc                           
                    JumpIfRegIsNotZero  h,.Plot3Done     
                    ex      de,hl                    
                    push    bc
                    ld      b,0
                    ld      c,ixl
                    ClearCarryFlag
                    sbc     hl,bc
                    pop     bc                    
                    JumpIfRegIsNotZero  h,.Plot3Done 
                    call	.PlotPixel	                    ; CX+X,CY-Y                      
.Plot3Done:         pop     de,,hl
.Plot4:             push    hl,,de,,bc                   
                    ld      b,0                          
                    ld      c,ixl                        
                    ClearCarryFlag                       
                    sbc     hl,bc                        
                    pop     bc                           
                    JumpIfRegIsNotZero  h,.Plot4Done     
                    ex      de,hl                    
                    push    bc
                    ld      b,0
                    ld      c,ixl
                    ClearCarryFlag
                    sbc     hl,bc
                    pop     bc                    
                    JumpIfRegIsNotZero  h,.Plot4Done 
                    call	.PlotPixel	                    ; CX-X,CY-Y                  
.Plot4Done:         pop     de,,hl
.Plot5:             ex      de,hl                        
                    push    hl,,de,,bc                   
                    ld      b,0                          
                    ld      c,ixl                        
                    ClearCarryFlag                       
                    adc     hl,bc                        
                    pop     bc                           
                    JumpIfRegIsNotZero  h,.Plot5Done     
                    ex      de,hl                    
                    push    bc
                    ld      b,0
                    ld      c,ixl
                    ClearCarryFlag
                    adc     hl,bc
                    pop     bc                    
                    JumpIfRegIsNotZero  h,.Plot5Done 
                    call	.PlotPixel	                    ;CY+X,CX+Y
.Plot5Done:         pop     de,,hl
.Plot6:             ex      de,hl                        
                    push    hl,,de,,bc                   
                    ld      b,0                          
                    ld      c,ixl                        
                    ClearCarryFlag                       
                    sbc     hl,bc                        
                    pop     bc                           
                    JumpIfRegIsNotZero  h,.Plot6Done     
                    ex      de,hl                    
                    push    bc
                    ld      b,0
                    ld      c,ixl
                    ClearCarryFlag
                    adc     hl,bc
                    pop     bc                    
                    JumpIfRegIsNotZero  h,.Plot6Done 
                    call	.PlotPixel	                    ; CY-X,CX+Y                
.Plot6Done:         pop     de,,hl
.Plot7:             ex      de,hl                        
                    push    hl,,de,,bc                   
                    ld      b,0                          
                    ld      c,ixl                        
                    ClearCarryFlag                       
                    adc     hl,bc                        
                    pop     bc                           
                    JumpIfRegIsNotZero  h,.Plot7Done     
                    ex      de,hl                    
                    push    bc
                    ld      b,0
                    ld      c,ixl
                    ClearCarryFlag
                    sbc     hl,bc
                    pop     bc                    
                    JumpIfRegIsNotZero  h,.Plot7Done 
                    call	.PlotPixel	                    ; CY+X,CX-Y                
.Plot7Done:         pop     de,,hl
.Plot8:             ex      de,hl                        
                    push    hl,,de,,bc                   
                    ld      b,0                          
                    ld      c,ixl                        
                    ClearCarryFlag                       
                    sbc     hl,bc                        
                    pop     bc                           
                    JumpIfRegIsNotZero  h,.Plot8Done     
                    ex      de,hl                    
                    push    bc
                    ld      b,0
                    ld      c,ixl
                    ClearCarryFlag
                    sbc     hl,bc
                    pop     bc                    
                    JumpIfRegIsNotZero  h,.Plot8Done 
                    call	.PlotPixel	                    ; CY-X,CX-Y                 
.Plot8Done:         pop     de,,hl
.PlotDone:          exx
.IncrementCircle:	bit     7,h				; Check for Hl<=0
                    jr z,   .draw_circle_1
                    add hl,de			; Delta=Delta+D1
                    jr      .draw_circle_2		; 
.draw_circle_1:		add     hl,bc			; Delta=Delta+D2
                    inc     bc
                    inc     bc				; D2=D2+2
                    dec     ixh				; Y=Y-1
.draw_circle_2:		inc     bc				; D2=D2+2
                    inc     bc
                    inc     de				; D1=D1+2
                    inc     de	
                    inc     ixl				; X=X+1
                    jp      .CircleLoop
.PlotPixel:         ld		a,0                  ; This was originally indirect, where as it neeed to be value
                    push	de,,bc,,hl
                    ld      b,l                     ; At this point de = x and hl = y
                    ld      c,e
                    l2_plot_macro; call 	l2_plot_pixel_y_test
                    pop		de,,bc,,hl
                    ret
.circleSinglepixel:  ld		a,e
                    l2_plot_macro; call	l2_plot_pixel_y_test
                    ret