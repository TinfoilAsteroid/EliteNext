

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
    INCLUDE "./ModelRender/DrawLines.asm"

;
;DrawLineBCtoDE:
;LIONBCDE:
;    -- Set colour etc
;    call    l2_draw_diagonal:
;; ">l2_draw_diagonal, bc = y0,x0 de=y1,x1,a=color) Thsi version performs a pre sort based on y axis"
