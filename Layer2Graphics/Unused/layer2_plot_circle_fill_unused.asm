; Moved out of Layer2Graphics/layer2_plot_circle_fill.asm as nothing in the eliteNext.asm build uses it
; (unreferenced routines, and IFDEF blocks whose flag is never defined). Not included in the game build.

l2_draw_circle_fill_320: break
                    ld		a,e                     ; set self mo
                    ld      (.PlotPixelColor1+1),a   ; set color
                    ld      (.PlotPixelColor2+1),a   ; set color
                    ld      (.PlotPixelColor3+1),a   ; set color
                    ld      (.PlotPixelColor4+1),a   ; set color             
                    ld		a,d						; get radius
                    and		a
                    ret		z
                   ; cp		1
                   ; jp		z,.Circle1Pixel320
                    ld      a,b      
                    ; hl = column (cX), a = row (cY)
.PrepPoint1:        ld      (.PlotcX1+1),hl        ; Prep X1:CX-X, 
                    ld      (.PlotcY1+1),a         ;      Y1:CY+Y                      
.PrepPoint2:        ld      (.PlotcY2+1),a         ;       Y1:CY-Y
.PrepPoint3:        ld      (.PlotcX3+1),a         ; Prep X1:CY-X,
                    ld      (.PlotcY3+1),hl        ;      Y1:CX-Y
.PlotPoint4:        ld      (.PlotcY4+1),hl        ; Prep Y1:CX+Y                  
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
;                        hl    de        hl    de
;                         C=radius Y = error        G = generate R = read 
; OPTIMISATION:        1)CX-X, CY+Y  for X*2        G>write to 2a. G>read only  : G>Write to 2c,3c,4c
;                      2)CX-X, CY-Y  for X*2        R>read only,   G>read only  : R>read only
;                      3)CY-X, CX-Y  for X*2        G>write to ,   G>read only  : R>read only
;                      4)CY-X, CX+Y  for X*2        R>read only,   G>read only  : R>read only
; radius must be under 127 so we can use Add hl,a and Add de,a to optimise and preload everying with self modifying code
; *** can we optimise by swapping de and hl after step 4? does it actually improve anything, likley not
; This sequence shoudl minimise the amount of adds or subtracts to do                    
.PlotcY1:           ld      de,0                    ; center Y
.PlotcX1:           ld      hl,0                    ; center X
                    ld      a,ixh                   ; radius
                    sla     a                       ; raduis * 2
                    ld      (.PlotcR1+1),a          ; write out Radius for the other 3 lines
                    ld      (.PlotcR2+1),a          ; write out Radius for the other 3 lines
                    ld      (.PlotcR3+1),a          ; .
                    ld      (.PlotcR4+1),a          ; .
;...................CX-X, CY+Y  for X*2.............. G>write to 2a. G>read only  : G>Write to 2c,3c,4c
.Plot1CalcX:        ld      b,0                     ; hl = cX - radius
                    ld      c,ixh                   ; .
                    ClearCarryFlag                  ; .
                    sbc     hl,bc                   ; .
                    ld      (.PlotcX2+1),hl         ; write to plot line 2 Coordiante X1
.Plot1CalcY:        ld      a,ixl                   ; de = cY + error
                    add     de,a                    ; . 
                    ld      b,e                     ; b = Coordinate Y1
.PlotcR1:           ld      de,0                    ; de = radius (self modifying) * 2 or length
.PlotPixelColor1:   ld      c,0                     ; c = colour
                    call    l2_draw_horz_line_320   ; ">b = row; hl = col, de = length, c = color"
;...................CX-X, CY-Y  for X*2.............. R>read only,   G>read only  : R>read only
.PlotcY2:           ld      hl,0                    ; center Y
                    ld      b,0                     ; for now force b until we confirm b never changes
                    ld      c,ixl                   ; bc = y (error)
                    ClearCarryFlag                  ; .
                    sbc     hl,bc                   ; .
                    ld      b,l                     ; . b row
.PlotcX2:           ld      hl,0                    ; center X
.PlotcR2:           ld      de,0                    ; de = radius (self modifying) * 2 or length
.PlotPixelColor2:   ld      c,0                     ; c = colour
                    call    l2_draw_horz_line_320   ; ">b = row; hl = col, de = length, c = color"
                    jp      .PlotIterDone
;...................3)CY-X, CX-Y  for X*2............ G>write to ,   G>read only  : R>read only
.PlotcY3:           ld      hl,0                    ; center Y (loading center X to Y)
                    ld      b,0                     ; de = CY-Y
                    ld      c,ixl                   ; . = d(0) e (CY-Y)
                    ClearCarryFlag                  ; . 
                    sbc     hl,bc                   ; . 
                    ex      de,hl                   ; . 
.PlotcX3:           ld      hl,0                    ; center X
                    ld      c,ixh                   ; hl = cX - radius
                    ClearCarryFlag                  ; .
                    sbc     hl,bc                   ; .
                    ld      (.PlotcX4+1),hl         ; write to 2a (or Coordiante X1)
                    ld      b,e                     ; b = row
.PlotPixelColor3:   ld      c,0                     ; c = colour
.PlotcR3:           ld      de,0                    ; de = radius (self modifying) * 2 or length
                    call    l2_draw_horz_line_320   ; ">b = row; hl = col, de = length, c = color"
;...................4)CY-X, CX+Y  for X*2............ R>read only,   G>read only  : R>read only
.PlotcY4:           ld      de,0                    ; self modifying CX+Y
                    ld      a,iyl
                    add     de,a                    ; Y1 = CX+Y
.PlotcX4:           ld      hl,0                    ; center X
                    ld      b,0
                    ld      c,ixh                   ; hl = cX - radius
                    ClearCarryFlag                  ; .
                    sbc     hl,bc                   ; .
                    ld      b,e                     ; b = row
.PlotcR4:           ld      de,0                    ; de = radius (self modifying) * 2 or length
.PlotPixelColor4:   ld      c,0                     ; c = colour
                    call    l2_draw_horz_line_320   ; ">b = row; hl = col, de = length, c = color"
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
