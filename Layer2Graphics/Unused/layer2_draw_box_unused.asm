; Moved out of Layer2Graphics/layer2_draw_box.asm as nothing in the eliteNext.asm build uses it
; (unreferenced routines, and IFDEF blocks whose flag is never defined). Not included in the game build.

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
