

ShipPlotPoint:
SHPPT:	                                    ; ship plot as point from LL10
    call    EraseOldLines                   ; EE51	\ if bit3 set draw to erase lines in XX19 heap
SHPPT_ProjectToK3K4:
    call    Project                         ; PROJ	\ Project K+INWK(x,y)/z to K3,K4 for craft center
SHPTOnScreenTest:    
	ld		hl,(varK3)						; get X Y ccords from K3 and K4
	ld		de,(varK4)
	ld		a,h
	or		d								;
	jr		nz,SHPTFinishup					; quick test to see if K3 or K4 hi are populated , if they are its too big (or negative coord)
	ld		a,e								; k4 or Y lo
	JumpIfAGTENusng ViewHeight,SHPTFinishup	; off view port?
SHPTInjectFalseLine:						; it will always be 1 line only
	ld		a,1
	ld		(UbnkLineArrayLen),a
	ld		a,4
	ld		(UbnkLineArrayLen),a
	ld		d,l                             ; de = Y lo X hi
	ld		hl,UbnkLineArray				; head of array
	ld		(hl),d
	inc		hl
	ld		(hl),e
	inc		hl
	ld		(hl),d
	inc		hl
	ld		(hl),e
	inc		hl								; write out point as a line for clean up later
SHPTIsOnScreen:	
	ld		b,e
	ld		c,d								; bc = XY
	ld		a,ShipColour
	MMUSelectLayer2
    call    l2_plot_pixel
SHPTFinishup:
    ld      a,(UBnkexplDsp)
    and     $F7                             ;  clear bit3
    ld      (UBnkexplDsp),a                 ; set bit3 (to erase later) and plot as Dot display|missiles explosion state
    ret                                     ; now it will return to the caller of 
    
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
;;DEBUGTEST        push bc
;;DEBUGTEST        push hl
;;DEBUGTEST        push de
;;DEBUGTEST        ld  a,$3F
;;DEBUGTEST        MMUSelectLayer2
;;DEBUGTEST        call    l2_plot_pixel
;;DEBUGTEST        pop de
;;DEBUGTEST        pop hl
;;DEBUGTEST        pop bc
                        ld      e,(hl)                          ; c = varX1
                        inc     hl
                        ld      d,(hl)                          ; de = point2 Y,X
;;DEBUGTEST       push bc
;;DEBUGTEST       push hl
;;DEBUGTEST       push de
;;DEBUGTEST       push de
;;DEBUGTEST       pop  bc
;;DEBUGTEST       ld  a,$3F
;;DEBUGTEST       MMUSelectLayer2
;;DEBUGTEST       call    l2_plot_pixel
;;DEBUGTEST       pop de
;;DEBUGTEST       pop hl
;;DEBUGTEST       pop bc
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
; ---------------------------------------------------------------------------------------------------------------------------------

;
;DrawLineBCtoDE:
;LIONBCDE:
;    -- Set colour etc
;    call    l2_draw_diagonal:
;; ">l2_draw_diagonal, bc = y0,x0 de=y1,x1,a=color) Thsi version performs a pre sort based on y axis"
