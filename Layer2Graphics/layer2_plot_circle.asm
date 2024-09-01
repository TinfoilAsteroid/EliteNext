
l2_circle_pos		DW 0
l2_circle_colour	DB 0
l2_circle_radius	DB 0
l2_circle_x			DB 0
l2_circle_y			DB 0
l2_circle_d			DB 0

l2_circle_xHeap 	DS 2*66
l2_circle_yHeap     DS 2*66
l2_circle_heap_size DB 0
l2_circle_clip_y    DW 0
l2_circle_clip_x    DW 0
l2_circle_flag      DB 0
l2_circle_counter   DB 0

;---------------------------------------------------------------------------------------------------------------------------------
; ">l2_draw_circle BC = center row col, d = radius, e = colour"
l2_draw_circle:     ld		a,e
                    ld		(.PlotPixel+1),a
                    ld		a,d								; get radius
                    and		a
                    ret		z
                    cp		1
                    jp		z,CircleSinglepixel
                    ld		(.Plot1+1),bc	        ; save origin into cXcY reg in code
                    ld		ixh,a			        ; ixh =  x = raidus
                    ld		ixl,0			        ; iyh =  y = 0
.calcd:	            ld		h,0     
                    ld		l,a     
                    add		hl,hl			        ; hl = r * 2
                    ex		de,hl			        ; de = r * 2
                    ld		hl,3        
                    and		a       
                    sbc		hl,de			        ; hl = 3 - (r * 2)
                    ld		b,h     
                    ld		c,l				        ; bc = 3 - (r * 2)
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
.Plot1:             ld		de,0                    ; de = cXcY
                    ld		a,e                     ; c = cY + error
                    add		a,ixl                   ;
                    ld		c,a                     ;
                    ld		a,d                     ; b = xY+radius
                    add		a,ixh                   ;
                    ld		b,a                     ;
                    call	.PlotPixel			    ;CX+X,CY+Y
.Plot2:             ld 		a,e
                    sub 	ixl
                    ld 		c,a
                    ld 		a,d
                    add 	a,ixh
                    ld		b,a
                    call	.PlotPixel			    ;CX-X,CY+Y
.Plot3:             ld 		a,e
                    add		a,ixl
                    ld 		c,a
                    ld 		a,d
                    sub 	ixh
                    ld 		b,a
                    call	.PlotPixel			    ;CX+X,CY-Y
.Plot4:             ld 		a,e
                    sub 	ixl
                    ld 		c,a
                    ld 		a,d
                    sub 	ixh
                    ld 		b,a
                    call	.PlotPixel			    ;CX-X,CY-Y
.Plot5:	            ld 		a,d
                    add 	a,ixl
                    ld 		b,a
                    ld 		a,e
                    add 	a,ixh
                    ld 		c,a
                    call	.PlotPixel			    ;CY+X,CX+Y
.Plot6:	            ld 		a,d
                    sub 	ixl
                    ld 		b,a
                    ld 		a,e
                    add 	a,ixh
                    ld 		c,a
                    call	.PlotPixel			    ;CY-X,CX+Y
.Plot7:	            ld 		a,d
                    add 	a,ixl
                    ld 		b,a
                    ld 		a,e
                    sub 	ixh
                    ld 		c,a
                    call	.PlotPixel			    ;CY+X,CX-Y
.Plot8:	            ld 		a,d
                    sub 	ixl
                    ld		b,a
                    ld 		a,e
                    sub 	ixh
                    ld 		c,a
                    call	.PlotPixel			    ;CY-X,CX-Y
                    exx
.IncrementCircle:	bit     7,h				        ; Check for Hl<=0
                    jr z,   .draw_circle_1
                    add hl,de			            ; Delta=Delta+D1
                    jr      .draw_circle_2		; 
.draw_circle_1:		add     hl,bc			        ; Delta=Delta+D2
                    inc     bc
                    inc     bc				        ; D2=D2+2
                    dec     ixh				        ; Y=Y-1
.draw_circle_2:		inc bc				            ; D2=D2+2
                    inc bc          
                    inc de				            ; D1=D1+2
                    inc de	            
                    inc ixl				            ; X=X+1
                    jp      .CircleLoop
.PlotPixel:         ld		a,0                     ; This was originally indirect, where as it neeed to be value
                    push	de,,bc,,hl
                    l2_plot_macro; call 	l2_plot_pixel_y_test
                    pop		de,,bc,,hl
                    ret
CircleSinglepixel:  ld		a,e
                    l2_plot_macro; call	l2_plot_pixel_y_test
                    ret

CalcNewPointMacro:  MACRO reg1, oper, reg2
                    ClearCarryFlag
                    ld      b,0
                    ld      c,reg2
                    oper    hl,bc
                    ENDM

; ">l2_draw_clipped_circle HL = Center X 2's c, DE = Center Y 2's , c = radius, b = colour"
l2_draw_clipped_circle:     
                    ld      a,b                     ; save Colour
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
;--- CX+X,CY+Y ---------------------------------------------;
.Plot1Y:            ld		de,0                            ; this is Y coord
.Plot1X:            ld      hl,0                            ; this is x coord
                    push    hl,,de
                    CalcNewPointMacro hl, adc, ixh          ;
                    ex      de,hl                           ; de = x coord calculated, hl =y center Y
                    CalcNewPointMacro hl, adc, ixl          ;
                    call	.PlotPixel	            		; CX+X,CY+Y using DE = x and hl = y *** Note if we order plot 1 to 8 we can selectivley jump past many on elimiation check
.Plot1Done:         pop     hl,,de                          ; get de (y) and hl (x) back but reversed as the next plot expected the to be reversed from the ex de,hl above  + 0
;--- CX+X,CY-Y ---------------------------------------------;
.Plot2:             push    hl,,de                          ; e.g  do all CX + X first, so plot1, plot3 and just one check for cx + x off screen                    
                    CalcNewPointMacro hl, adc, ixh          ;
                    JumpIfRegIsNotZero  h,.Plot2Done        ;
                    ex      de,hl                           ; de = calculated x
                    CalcNewPointMacro hl, sbc, ixl          ;
                    call	.PlotPixel	                    ; CX-X,CY+Y                                     
.Plot2Done:         pop     hl,,de
;--- CX-X,CY-Y ---------------------------------------------; bollocksC
.Plot3:             push    hl,,de
                    CalcNewPointMacro hl, sbc, ixh          ;
                    JumpIfRegIsNotZero  h,.Plot3Done        ; 
                    ex      de,hl                           ; de = calculated x
                    CalcNewPointMacro hl, sbc, ixl          ;
                    call	.PlotPixel	                    ; CX+X,CY-Y                      
.Plot3Done:         pop     hl,,de
;--- CX-X,CY+Y ---------------------------------------------; bollocks
.Plot4:             push    hl,,de
                    CalcNewPointMacro hl, sbc, ixh          ;
                    JumpIfRegIsNotZero  h,.Plot4Done     
                    ex      de,hl                    
                    CalcNewPointMacro hl, adc, ixl          ;
                    call	.PlotPixel	                    ; CX-X,CY-Y                  
.Plot4Done:         pop     hl,,de
;--- CX+Y,CY+X ---------------------------------------------; bollocks
.Plot5:             push    hl,,de
                    CalcNewPointMacro hl, adc, ixl          ;
                    JumpIfRegIsNotZero  h,.Plot5Done     
                    ex      de,hl                    
                    CalcNewPointMacro hl, adc, ixh          ;
                    call	.PlotPixel	                    ;CY+X,CX+Y
.Plot5Done:         pop     hl,,de
;--- CX+Y,CX-X ---------------------------------------------;bollocks
.Plot6:             push    hl,,de
                    CalcNewPointMacro hl, adc, ixl          ;
                    JumpIfRegIsNotZero  h,.Plot6Done     
                    ex      de,hl                    
                    CalcNewPointMacro hl, sbc, ixh          ;
                    call	.PlotPixel	                    ; CY-X,CX+Y                
.Plot6Done:         pop     hl,,de
;--- CX-Y,CY-X ---------------------------------------------;bollocksC
.Plot7:             push    hl,,de
                    CalcNewPointMacro hl, sbc, ixl          ;
                    JumpIfRegIsNotZero  h,.Plot7Done     
                    ex      de,hl                    
                    CalcNewPointMacro hl, sbc, ixh          ;
                    call	.PlotPixel	                    ; CY+X,CX-Y                
.Plot7Done:         pop     hl,,de
;--- CX-Y,CY+X ---------------------------------------------; bollocks
.Plot8:             push    hl,,de
                    CalcNewPointMacro hl, sbc, ixl          ;
                    JumpIfRegIsNotZero  h,.Plot8Done     
                    ex      de,hl                    
                    CalcNewPointMacro hl, adc, ixh          ;
                    call	.PlotPixel	                    ; CY-X,CX-Y                 
.Plot8Done:         pop     hl,,de
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
.PlotPixel:         ld      a,d             ; filter x> 256 or negative
                    and     a
                    ret     nz
                    ld      a,h             ; filter y > 256 or negative
                    and     a
                    ret     nz
                    ld      a,l             ; filter y > 127
                    and     $80
                    ret     nz
.PlotColour:        ld		a,0             ; This was originally indirect, where as it neeed to be value
                    push	de,,bc,,hl
                    ld      b,l             ; At this point de = x and hl = y
                    ld      c,e
                    l2_plot_macro; call 	l2_plot_pixel_y_test
                    pop		de,,bc,,hl
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
                    
;---------------------------------------------------------------------------------------------------------------------------------
; ">l2_draw_circle_320 B = center row, hl = col, d = radius, e = colour"
;  draws circle in 320 mode
; self modifying set colur in code below TODO 
l2_draw_circle_39990: ld		a,e                     ; set self mo
                    ld      (.PlotPixelColor+1),a   ; set color
                    ld      (.PlotCircleColor+1),a  ; set color                  
                    ld		a,d						; get radius
                    and		a
                    ret		z
                    cp		1
                    jp		z,.Circle1Pixel320
                    ld      a,b        
.PrepPoint1:        ld      (.PlotcY1+1),a           ; save origin row into xY
                    ld		(.PlotcX1+1),hl	        ; save origin into cY reg in code
.PrepPoint2:        ld      (.PlotcY2+1),a          ;                   we only need to recalulate plotY
.PrepPoint3:        ld      (.PlotcX3+1),hl         ;                   we only need to recalulate plotX
;                   now cX and xY are swapped for points 5 to 8
.PrepPoint5:        ld      (.PlotcY5+1),hl         ; save origin row into xY
                    ld		(.PlotcX5+1),a	        ; save origin into cY reg in code
.PrepPoint6:        ld      (.PlotcY6+1),hl         ;                   we only need to recalulate plotY
.PrePoint7:         ld      (.PlotcX7+1),a          ;                   we only need to recalulate plotX             
;                   now process radius                    
                    ld		ixh,d			        ; ixh =  x = raidus
                    ld		ixl,0			        ; iyh =  y = 0
;.                    
.calcd:	            ld		h,0                     ; bc = hl = 3 - (r * 2) 
                    ld		l,d                     ; . de = radius * 2
                    add		hl,hl			        ; . hl = r * 2
                    ex		de,hl			        ; . de = r * 2, l = 2
                    ld		hl,3                    ; . hl = 3
                    and		a                       ; .
                    sbc		hl,de			        ; . hl = hl - (r*2)
                    ld		b,h                     ; . bc = hl
                    ld		c,l				        ; .
.calcdelta:         ld		hl,1                    ; hl = 1 - y
                    ld		d,0                     ; . d = 0
                    ld		e,ixl                   ; . e = y (ixl)
                    and		a                       ; .
                    sbc		hl,de                   ; . hl = hl - de
.Setde1:            ld		de,1                    ; de = 1
.CircleLoop:        ld		a,ixh                   ; while radius >= y (also error)
                    cp		ixl                     ;
                    ret		c                       ;
.ProcessLoop:	    exx                             ;   save all current registers
;Total plot combos are               Optimisation
;                        hl    de
;                      1)CX+X, CY+Y  Calc push, Calc write to 4
;                      2)CX+X, CY-Y  pop,       Calc push
;                      3)CX-X, CY-Y  Calc push, pop
;                      4)CX-X, CY+Y  pop,       written by 1
;                      5)CY+X, CX+Y  Calc push, Calc write to 8
;                      6)CY+X, CX-Y  pop,       Calc push
;                      7)CY-X, CX-Y  calc push, pop
;                      8)CY-X, CX+Y  pop,       written by 4
; note if we have radius < 255 then we can use ADD hl,A and ADD DE,a to optimise and preload everying with self modifying code
; *** can we optimise by swapping de and hl after step 4? does it actually improve anything, likley not
; This sequence shoudl minimise the amount of adds or subtracts to do                    
.PlotcY1:           ld      de,0                    ; center Y
.PlotcX1:           ld      hl,0                    ; center X
                    jp      .PlotcY5
;...................CX+X, CY+Y....................... Calc push, Calc write to 4
.Plot1:             ld      a,ixh                   ; hl = cX + radius
                    add     hl,a                    ; .
                    ld      a,ixl                   ; de = cY + error
                    add     de,a                    ; . 
                    ld      (.PlotcY4+1),de         ; write cY+Y for plot section 4
                    push    hl                      ; push CX+X                                 Stack + 1
                    call	.PlotPixel			    ;   
;...................CX+X, CY-Y....................... pop,       Calc push
.PlotcY2:           ld      de,0                    ; center Y
.Plot2:             pop     hl                      ; retrieve CX+X                             Stack + 0
                    ld      b,0                     ; for now force b until we confirm b never changes
                    ld      c,ixl                   ; bc = y (error)
                    ex      de,hl                   ; de = de - bc
                    ClearCarryFlag                  ; .
                    sbc     hl,bc                   ; .
                    ex      de,hl                   ; .
                    push    de                      ; cY-Y                                      Stack + 1
                    call	.PlotPixel			    ;
;...................CX-X, CY-Y....................... Calc push, pop
.PlotcX3:           ld      hl,0                    ; center X
.Plot3:             pop     de                      ; cY-Y                                      Stack + 0
                    ld      b,0                     ; bc = radius
                    ld      c,ixh                   ; hl = cX - radius
                    ClearCarryFlag                  ; .
                    sbc     hl,bc                   ; .
                    push    hl                      ; cX-X                                      Stack + 1
                    call	.PlotPixel			    ;
;...................CX-X, CY+Y....................... pop,       written by 1
.PlotcY4:           ld      de,0                    ; self modifying cY+Y
.Plot4:             pop     hl                      ; get back cX-X                             Stack + 0
                    call	.PlotPixel			    ; all pre-calculated
                    
;...................CY+X, CX+Y....................... Calc push, Calc write to 8
.PlotcY5:           ld      de,0                    ; center Y (load with cX at this point)
.PlotcX5:           ld      hl,0                    ; center X (load with cY at this point)
                    ld      a,ixh                   ; hl = cX + radius (note we have swapped during load to de and hl so comments reflect this)
                    add     hl,a                    ; .
                    ld      a,ixl                   ; de = cY + error
                    add     de,a                    ;                   
                    ld      (.PlotcY8+1),de         ; write cY+Y for plot section 4
                    push    hl                      ; push CX+X                                 Stack + 2
                    call	.PlotPixel			    ;  
;...................CY+X, CX-Y....................... pop,       Calc push
.PlotcY6:           ld      de,0                    ; self modifying cY
.Plot6:	            pop     hl                      ; retrieve CX+X                             Stack + 0
                    ld      b,0
                    ld      c,ixl                   ; de = cY - y (error)
                    ex      de,hl                   ; .
                    ClearCarryFlag                  ; .
                    sbc     hl,bc                   ; .
                    ex      de,hl                   ; .
                    push    de                      ; cY-Y                                      Stack + 1
                    call	.PlotPixel			    ;
;...................CY-X, CX-Y....................... calc push, pop
.PlotcX7:           ld      hl,0                    ; center X
                    pop     de                      ; cY-Y                                      Stack + 0
                    ld      b,0                     ; bc = radius
                    ld      c,ixh                   ; hl = cX - radius
                    ClearCarryFlag                  ; .
                    sbc     hl,bc                   ; .
                    push    hl                      ; cX-X                                      Stack + 1
                    call	.PlotPixel			    ;
;...................CY-X, CX+Y....................... pop,       written by 4
.PlotcY8:           ld      de,0                    ; self modifying cY+Y
.Plot8:	            pop     hl
                    call	.PlotPixel			    ; CY-X,CX-Y
;                   End of plot iteration
.PlotIterDone:      exx                             ; get back saved vars
.IncrementCircle:	bit     7,h				        ; Check for Hl<=0
                    jr      z, .draw_circle_1
                    add     hl,de			        ; Delta=Delta+D1
                    jr      .draw_circle_2		    ; 
.draw_circle_1:		add     hl,bc			        ; Delta=Delta+D2
                    inc     bc
                    inc     bc				        ; D2=D2+2
                    dec     ixh				        ; Y=Y-1
.draw_circle_2:		inc     bc				        ; D2=D2+2
                    inc     bc                      
                    inc     de				        ; D1=D1+2
                    inc     de	                    
                    inc     ixl				        ; X=X+1
                    jp      .CircleLoop
.PlotPixel:         push	ix
                    ld      d,e                     ; move row from d to b
.PlotPixelColor:    ld      e,0                    
                    call    l2_plot_pixel_320       ; d= row number, hl = column number, e = pixel col
                    pop		ix
                    ret
.Circle1Pixel320:   ld		d,b
.PlotCircleColor:   ld      e,0                    
                    call    l2_plot_pixel_320       ; d= row number, hl = column number, e = pixel col
                    ret    

