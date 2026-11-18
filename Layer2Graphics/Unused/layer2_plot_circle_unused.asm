; Moved out of Layer2Graphics/layer2_plot_circle.asm as nothing in the eliteNext.asm build uses it
; (unreferenced routines, and IFDEF blocks whose flag is never defined). Not included in the game build.

        IFDEF CIRCLE_39990_ENABLED            
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
        ENDIF
