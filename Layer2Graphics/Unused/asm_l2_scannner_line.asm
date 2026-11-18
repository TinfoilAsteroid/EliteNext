; "l2_draw_scan_line bc=rowcol, de=col2,color)
l2_draw_scan_line:      push    bc,,de
                        ld		d,3
                        call	l2_draw_horz_line
                        pop     bc,,de
.testy1lty2:            ld		a,c
                        cp		d
                        jr		nc, .calclinelen
.y1lty2:			    ld		a,d; swap col and col2 before calc
                        ld		d,b
                        ld		d,ab
.calclinelen:           ld		h,b				; d = (col - col2) + 1 (note that above may have preswapped col1 and col2)
                        ld		a,d
                        sub		h
                        inc		h
                        ld		d,h
.drawnbothlines:        push    bc,,de
                        call	l2_draw_vert_line
.drawlineatxplus1:      pop     bc,,de
                        inc		c
                        call	l2_draw_vert_line
                        ret
	