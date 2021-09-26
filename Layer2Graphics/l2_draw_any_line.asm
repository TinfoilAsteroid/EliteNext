; ">l2_draw_any_line, bc = y0,x0 de=y1,x1,a=color: determines if its horizontal, vertical or diagonal then hands off the work"
l2_draw_any_line:       ex		af,af'
                        ld		a,c
                        cp		e
                        jr		z,.HorizontalLine
                        ld		a,b
                        cp		d
                        jr		z,.VerticalLine
; use jp and get a free ret instruction optimisation                        
.DiagonalLine:		    ex		af,af'			; get colour back into a
                        jp		l2_draw_diagonal

.HorizontalLine:        ex		af,af'
                        ld		d,e				; set d as target right pixel
                        ld		e,a				; e holds colour on this call
                        jp		l2_draw_horz_line_to
.VerticalLine:          ex		af,af'
                        ld		e,a				; e holds colour on this call
                        jp		l2_draw_vert_line_to
	
