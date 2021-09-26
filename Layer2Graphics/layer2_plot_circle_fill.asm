
l2_circle_dblx		DB 0
l2_circle_dbly		DB 0

; ">l2_draw_circle_fill BC = center row col, d = radius, e = colour"
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
.LineColour:	        ld		a,(l2_circle_colour)
                        ld      e,a
                        call 	l2_draw_horz_line
                        pop     de,,bc,,hl,,af
                        ret
