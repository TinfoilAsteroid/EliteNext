; "l2_draw_thick_box bc=rowcol, de=heightwidth h=color"
; TODO DMA Optimise
                DISPLAY "TODO: dma optimise"
l2_draw_fill_box:       push    bc,,de,,hl
                        ld      d,e
                        ld      e,h
                        call    l2_draw_horz_line           ; "bc = left side row,col, d = length, e = color"
                        pop     bc,,de,,hl
                        inc     b
                        dec     d
                        ret     z
                        jr      l2_draw_fill_box

; "l2_draw_box bc=rowcol, de=heightwidth a=color"
l2_draw_box:            push	bc,,de,,af
                        ld		d,e
                        ld		e,a
                        inc		d
                        call	l2_draw_horz_line
                        pop		bc,,de,,af
.bottomhorzline:	    push	bc,,de,,af
                        ld		h,a							;save color whilst b = row + height
                        ld		a,b
                        add		a,d
                        ld		b,a
                        ld		d,e							; d = width
                        inc		d							; Extra pixel for width
                        ld		e,h							; e = colour
                        call	l2_draw_horz_line
                        pop		bc,,de,,af
.leftvertline:          push	bc,,de,,af
                        inc		b							; save 2 pixles
                        dec		d
                        ld		e,a							; e = color
                        call	l2_draw_vert_line
                        pop		bc,,de,,af
.rightvertline:         inc		b							; save 2 pixles
                        dec		d
                        ld		h,a							;save color whilst c = col + width
                        ld		a,c
                        add		a,e
                        ld		c,a
                        ld		e,h							; e = color
                        call	l2_draw_vert_line
                        ret

; "b = row, hl = col, c = height, de = width, a = colour"
l2_draw_box_320:        push    bc,,de,,hl,,af	
                        ;TODOcall    l2_draw_horz_line_320       ; b = row, hl = col, e = width a = colour
                        pop     bc,,de,,hl,,af	
                        push    bc,,de,,hl,,af	
                        ex      af,af'
                        ld      a,b
                        dec     a
                        add     a,c
                        ld      b,c
                        ex      af,af'
                        ;TODOcall    l2_draw_horz_line_320       ; b = row, hl = col, e = width a = colour
.leftVertLine:          pop     bc,,de,,hl,,af	
                        push    bc,,de,,hl,,af	
                        ld      d,0                             ; de = height 
                        ld      e,c
                        ld      c,a                             ; set colour
                        call    l2_draw_vert_line_320
                        pop     bc,,de,,hl,,af	
                        add     hl,de                           ; hl = right column
                        dec     hl
                        ld      d,0                             ; de = length
                        ld      e,c
                        ld      c,a                             ; set colour
                        call    l2_draw_vert_line_320
                        ret

l2_draw_menu_border:    ld      b,1
                        ld      hl,1
                        ld      e,255-2
                        ld      c,$C0
                        call    l2_draw_vert_line_320           ;b = row; hl = col, de = length, c = color"
                        ld      b,1
                        ld      hl,320-2
                        ld      e,255-2
                        ld      c,$C0
                        call    l2_draw_vert_line_320           ;b = row; hl = col, de = length, c = color"
                        ld      b,1
                        ld      hl,1
                        ld      de,320-4
                        ld      c,$C0
                        call    l2_draw_horz_line_320
                        ld      b,253
                        ld      hl,2
                        ld      de,320-4
                        ld      c,$C0
                        call    l2_draw_horz_line_320
                        ld      b,11
                        ld      hl,2
                        ld      de,320-4
                        ld      c,$C0
                        call    l2_draw_horz_line_320
                        ret