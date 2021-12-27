
l2_circle_pos		DW 0
l2_circle_colour	DB 0
l2_circle_radius	DB 0
l2_circle_x			DB 0
l2_circle_y			DB 0
l2_circle_d			DB 0

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
                    call	.PlotPixel			;CY+X,CX-Y
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
                    call	.PlotPixel			;CX+X,CY-Y
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
                    call 	l2_plot_pixel_y_test
                    pop		de,,bc,,hl
                    ret
CircleSinglepixel:  ld		a,e
                    call	l2_plot_pixel_y_test
                    ret
