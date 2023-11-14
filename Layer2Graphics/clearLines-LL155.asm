; ClearLines (LL155)
;   y = 0
; 	XX20 = UbnkEdgeHeapSize
;   exit if XX20 < 4
;   ++y
;   do
;		X1 = XX19(Y) ;	Y1 = XX19(++Y) ;	X2 = XX19(++Y);	Y2 = XX19(++Y)
;   	call DrawLine (x1,y1 to x2,y2) two's compliment (we will do 0)
;		++y
;	until Y > XX20	

clearLines:
layer2_clearLines:
LL155cl:                ld		a,(UbnkLineArrayLen)
                        ld		b,a
                        ld		hl,UbnkLineArray
clearLinesLoop:         push	bc
                        ld		a,(hl)
                        inc		hl
                        ld		c,a
                        ld		a,(hl)
                        inc		hl
                        ld		b,a
                        ld		a,(hl)
                        inc		hl
                        ld		e,a
                        ld		a,(hl)
                        inc		hl
                        ld		d,a
                        ld		a,COLOUR_TRANSPARENT		; we erase here
                        push	hl
                        call    l2_draw_any_line
                        pop		hl
                        pop		bc
                        djnz	clearLinesLoop
                        ret
	