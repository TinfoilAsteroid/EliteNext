


l2trianglebc	        DW 0
l2trianglede	        DW 0
l2trianglehl	        DW 0

; "l2_draw_triangle, BC = y1x1, DE=y2x2, HL=y3x3 a = Color"
l2_draw_triangle:       push	bc,,de,,hl,,af
                        call	l2_draw_diagonal		; BC to DE
                        pop		af
                        pop		de						; swap DE and HL
                        pop		hl						; so BC to DE is really to HL
                        pop		bc
                        push    de,,hl                    ; which is pushing original hl then original de
                        push	af
                        call	l2_draw_diagonal		; BC to HL (leaving DE and HL swapped)
                        pop		af
                        pop		bc						; Now bc = original de
                        pop		de						; de = original hl
                        call	l2_draw_diagonal		; BC to HL (leaving DE and HL swapped)
                        ret
	
	

	
