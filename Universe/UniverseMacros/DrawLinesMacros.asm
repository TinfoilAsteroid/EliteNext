

; ---------------------------------------------------------------------------------------------------------------------------------    
DrawLinesLateClippingMacro:         MACRO p?
p?_DrawLinesLateClipping:     ld	    a,$65 ; DEBUG
                                    ld      iyl,a					      ; set ixl to colour (assuming we come in here with a = colour to draw)
                                    ld	    a,(p?_BnkLineArrayLen)			; get number of lines
                                    ReturnIfAIsZero   				; No lines then bail out.
                                    ld	    iyh,a			                  ; number of lines still to draw
                                    ld	    hl,p?_BnkLineArray
                                    MMUSelectLayer2
                                    ld      a,$BF
                                    ld      (line_gfx_colour),a
.LateDrawLinesLoop:                 ld      de,x1
                                    FourLDIInstrunctions
                                    FourLDIInstrunctions
                                    push  hl,,iy
                                    call    l2_draw_6502_line
                                    jp      c,.LateNoLineToDraw
.PreLate:                           push    hl,,bc,,de,,iy
                                    ld      a,(x1)
                                    ld      c,a
                                    ld      a,(y1)
                                    ld      b,a
                                    ld      a,(x2)
                                    ld      e,a
                                    ld      a,(y2)
                                    ld      d,a
                                    ; bc = y0,x0 de=y1,x1,a=color)
                                    ld	    a, $D5 ; colour
                                    MMUSelectLayer2
.LateLine:                          call    l2_draw_elite_line; l2_draw_diagonal
                                    pop     hl,,bc,,de,,iy
.LateNoLineToDraw:                  pop   hl,,iy
                                    dec   iyh
                                    jr	nz, .LateDrawLinesLoop
                                    ret                                     ; --- Wireframe end  \ LL118-1
                                    ENDM
                                    