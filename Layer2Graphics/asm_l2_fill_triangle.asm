; ">l2_fillBottomFlatTriangle BC y0x0 DE x1x2, H YCommon, L Colour"
; "note >l2_draw_diagonal_save, bc = y0,x0 de=y1,x1,a=array nbr ESOURCE LL30 or LION"
; "note line to   bc = left side row,col, d right pixel, e = color"
l2_fillBottomFlatTriangle:;break
                        ld		a,l
                        ld		(l2linecolor),a
                        ld		a,c
                        cp		e
                        jr		nc, .x2gtex1
.x1ltx2:                ld		ixh,1                           ; list 1 holds x0 down to x1
                        ld		ixl,2                           ; list 2 hols  x0 down to x2
                        jr		.storepoints
.x2gtex1:               ld		ixh,2
                        ld		ixl,1
.storepoints:           push	bc,,de,,hl
                        ld		a,ixh
                        ld		e,d                             ; we alreay have bc so its now bc -> hd
                        ld		d,h
                        call	l2_draw_diagonal_save			;l2_store_diagonal(x0,y0,x1,ycommon,l2_LineMinX);
                        pop		bc,,de,,hl
                        push	bc,,hl
                        ld		d,h                             ; now its bc -> he
                        ld		a,ixl
                        call	l2_draw_diagonal_save			;l2_store_diagonal(x0,y0,x2,ycommon,l2_LineMaxX);
                        pop		bc,,hl
.SaveForLoop:           ld		d,b
                        ld		e,h								; save loop counters
                        push	de								; de = y0ycommon
.GetFirstHorizontalRow:	ld		hl,l2targetArray1               ; get first row for loop
                        ld		a,b
                        add		hl,a							; hl = l2targetArray1 row b
                        ld		a,(hl)							;
                        ld		c,a								; c = col1 i.e. l2targetarray1[b]
                        ld      hl,l2targetArray2
                        ld      a,b
                        add     hl,a
;                        inc		h								; hl = l2targetArray2 row b if we interleave
                        ld		a,(hl)							
                        ld		d,a								; d = col2 i.e. l2targetarray2[b]
.SetColour:             ld		a,(l2linecolor)
                        ld		e,a								; de = to colour
.SavePoints:            push	bc								; bc = rowcol			
                        dec		h
                        push	hl								; hl = l2targetArray1[b]
.DoLine:	            call	l2_draw_horz_line_to
                        pop		hl
                        pop		bc
                        inc		b								; down a rowc
                        pop		de								; de = from to (and b also = current)
                        inc		d
                        ld		a,e								; while e >= d
                        cp		d
                        jr 		nc,.SaveForLoop					; Is this the right point??
                        ret
