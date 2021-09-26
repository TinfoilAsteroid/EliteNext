draw_chart_circle_and_crosshair:
	ld		bc,(PresentSystemX)				; bc = present system
	ld		a,(MenuIdMax)
	bit		7,a
	jr		nz,.OnShortRangeChart			;  if bit7 set up, Short range chart default.
.OnGalacticChart:
	srl		b								; but row is row / 2
	push  	bc
	call	sprite_galactic_cursor
	pop		bc
	ld		a,b
	add		a,galactic_chart_y_offset
	ld		b,a		
	ld		a,(Fuel)
	srl		a
	srl		a								; divide range of fuel by 4 for galactic chart
	ld		d,a
	ld		e,$FF
	call	l2_draw_circle
	ret
.OnShortRangeChart:
	ld		bc,src_xy_centre					; must be ordered x y in data
	call	sprite_local_cursor
	ld		a,(Fuel)
	ld		d,a
	ld		e,$FF
	call	l2_draw_circle
	ret
; TODO MOVE CURSOR CODE
	
draw_hyperspace_cross_hair:
	ld		bc,(TargetPlanetX)              ; bc = selected jump 
	ld		a,(MenuIdMax)
	bit		7,a
	jr		nz,.OnShortRangeChart			;  if bit7 set up, Short range chart default.
.OnGalacticChart:
	srl		b								; but row is row / 2
	call	sprite_galactic_hyper_cursor
	ret
.OnShortRangeChart:
	ld		de,(PresentSystemX)
	ld		a,e
	sub		c
	sla		a
	sla		a
	add		a,src_x_centre
	ld		c,a
	ld		a,d
	sub		b
	sla		a
	sla		a
	add		a,src_y_centre
	ld		b,a
	call	sprite_local_hyper_cursor
	ret