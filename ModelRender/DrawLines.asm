
; ---------------------------------------------------------------------------------------------------------------------------------    
DrawLinesCounter		db	0
; Initial tests look OK    
LL155:;
ClearLine:                                  ; CLEAR LINEstr visited by EE31 when XX3 heap ready to draw/erase lines in XX19 heap.
      ;break                                                                             ; ObjectInFront:
DrawLines:              ld	a,$65 ; DEBUG
                        ld		iyl,a							; set ixl to colour (assuming we come in here with a = colour to draw)
                        ld		a,(UbnkLineArrayLen)			; get number of lines
                        ReturnIfAIsZero   						; No lines then bail out.
                        ld		iyh,a			                ; number of lines still to draw
                        ld		hl,UbnkLineArray
;LL27:                                       ; counter Y, Draw clipped lines in XX19 ship lines heap
DrawXX19ClippedLines:   ld      c,(hl)                          ; (XX19),Y c = varX1
                        inc     hl
                        ld      b,(hl)                          ; bc = point1 Y,X
                        inc     hl
                        ld      e,(hl)                          ; c = varX1
                        inc     hl
                        ld      d,(hl)                          ; de = point2 Y,X
                        inc     hl
                        push	hl
                        push    iy
                        ld      h,b
                        ld      l,c
  ;  call    l2_draw_any_line                ; call version of LOIN that used BCDE
                        ld		a,iyl							; get colour back before calling line draw
                        MMUSelectLayer2
                        call    LineHLtoDE
                        pop     iy
                        pop	    hl
                        dec     iyh
                        jr		nz,DrawXX19ClippedLines
                        ret                                     ; --- Wireframe end  \ LL118-1
