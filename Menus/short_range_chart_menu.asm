
short_range_page_marker  DB "ShortRange  PG50"

short_range_boiler_text	DW $0230,TextBuffer
short_range_header		equ 12
src_xy_centre			equ $6080
src_x_centre			equ $80
src_y_centre			equ $60
local_chart_star_colour	equ 216
local_dx				dw 0
local_dy				dw 0
local_max_range_x		equ 20
local_max_range_y		equ $26
local_name_row			db	0
local_name_col			db	0
local_label_shift_x		equ	3
local_label_shift_y		equ	5

src_distance            DB "Distance: "
src_dist_amount         DB "000"
src_decimal             DB "."
src_fraction            DB "0"
src_dis_ly              DB " Light Years",0
src_default_dist        DB "  0.0"

src_distance_val        DS  6
src_fill_buffer_len     EQU 32
src_fill_buffer_size    EQU 4 * src_fill_buffer_len                          ; up to 32 labels topx topy lengthx spare
src_printed_text        DS  src_fill_buffer_size                             ; space for occupied cells may move to bit flags later TODO
src_buffer_size         DB  0
;----------------------------------------------------------------------------------------------------------------------------------
SRM_print_boiler_text:  INCLUDE "Menus/print_boiler_text_inlineInclude.asm"
;----------------------------------------------------------------------------------------------------------------------------------
SRM_draw_chart_circle_and_crosshair:
                        ld		bc,(PresentSystemX)				; bc = present system
                        ld		bc,src_xy_centre					; must be ordered x y in data
                        MMUSelectSpriteBank
                        call	sprite_local_cursor
                        ld		a,(Fuel)
                        ld		d,a
                        ld		e,$FF
                        MMUSelectLayer2
                        call	l2_draw_circle
                        ret
; TODO MOVE CURSOR CODE
;----------------------------------------------------------------------------------------------------------------------------------
SRM_draw_hyperspace_cross_hair:
                        ld		bc,(TargetPlanetX)              ; bc = selected jump
                        ld		de,(PresentSystemX)
                        ld		c,src_x_centre
                        ld		b,src_y_centre
                        MMUSelectSpriteBank
                        call	sprite_local_hyper_cursor
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_get_name:           ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld      bc,(TargetPlanetX)
                        ld      (GalaxyTargetSystem),bc
                        call    galaxy_system_under_cursor
                        cp      0
                        ret     z
                        call	GetDigramWorkingSeed
                        ld		hl,name_expanded
                        call	CapitaliseString
                        ld		hl, name_expanded
                        ld      a,$FF
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
SRM_update_hyperspace_cross_hair:
                        ld		bc,(TargetPlanetX)              ; bc = selected jump
                        ld		de,(PresentSystemX)
                        ld		a,c
                        sub		e
                        jp      p,.NoFlipX
                        neg
                        sla		a
                        sla		a
                        ld      c,a
                        ld      a,src_x_centre
                        sub     c
                        ld      c,a
                        jp      .fixY
.NoFlipX:               sla		a
                        sla		a
                        add		a,src_x_centre
                        ld      c,a
.fixY:                  ld		a,b
                        sub		d
                        jp      p,.NoFlipY
                        neg
                        sla     a
                        ld      b,a
                        ld      a,src_y_centre
                        sub     b
                        ld      b,a
                        jp      .RedrawSprite
.NoFlipY                sla		a
                        add		a,src_y_centre
                        ld		b,a
.RedrawSprite:          MMUSelectSpriteBank
                        call	sprite_lhc_move
                        call    src_name_current
                        ret

src_clear_name_area:    ld      h,8
                        ld      de,$A000 | COLOUR_TRANSPARENT
                        ld      bc,$A80A
.ClearLoop:             push    hl
                        push    de
                        push    bc
                        MMUSelectLayer2
                        call	l2_draw_horz_line
                        pop     bc
                        pop     de
                        pop     hl
                        inc     b
                        dec     h
                        jr      nz,.ClearLoop
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_system_undercursor: ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld      bc,(TargetPlanetX)
                        ld      (GalaxyTargetSystem),bc
                        call    galaxy_system_under_cursor
                        cp      0
                        ret     z
src_name_current:       call    src_get_name
                        cp      0
                        ret     z
                        push    hl
                        push    af
                        call    src_clear_name_area
                        pop     af
                        pop     hl
                        ld      bc,$A80A
                        ld		e,$FF
                        MMUSelectLayer2
                        call	l2_print_7at
                        call    src_calc_distance
                        ld      hl,src_distance
                        ld      bc,$B00A
                        ld		e,$FF
                        MMUSelectLayer2
                        call	l2_print_7at
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_calc_distance:      ld      a,(Galaxy)                                      ; Default in 0 distance
                        MMUSelectGalaxyA
                        ld      de,src_dist_amount
                        ld      hl,src_default_dist
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ld      bc,(PresentSystemX)
                        ld      (GalaxyPresentSystem),bc
                        ld      bc,(TargetPlanetX)
                        ld      (GalaxyDestinationSystem),bc
                        call    galaxy_find_distance                            ; get distance into HL
                        ld      ix,(Distance)
                        ld      de,0
                        ld      iy,src_distance_val
                        call    DispDEIXtoIY                                    ; use DEIX as distance and write to string at location IY
                        push    iy
                        pop     hl                                              ; hl = iy
                        ld      de,src_distance_val
                        ld		a,(hl)				                            ;Push last digit to post decimal
                        ld		(src_fraction),a    
                        dec     hl
                        call    compare16HLDE                                   
                        jr      c,.done_number
                        ld      a,(hl)
                        ld      (src_dist_amount+2),a
                        dec     hl
                        call    compare16HLDE
                        jr      c,.done_number
                        ld      a,(hl)
                        ld      (src_dist_amount+1),a
                        dec     hl
                        call    compare16HLDE
                        jr      c,.done_number
                        ld      a,(hl)
                        ld      (src_dist_amount),a
.done_number:           ret

PosScan1                DW      0
PosScan2                DW      0
; bc = row col, d = xlength e = y length
; Check logic simplies to , if 1 = bc and 2 = de:
; 12   X1            X2    OK         2 LT X1
; 1    X1  2         X2    FAIL       1 LT X1 && 2 GT X1 && 2 LT X2
;      X1  12        X2    FAIL       1 GT X1 && 1 LT X2 && 2 GT X1 && 2 LT X2
;      X1  1         X2 2  FAIL       1 GT X1 && 1 LT X2 && 2 GT X2
;      X1            X2 12 OK         1 GT X2
FreeSlotCheck:          ld      d,7
                        mul
                        ld      a,c
                        add     e
                        jr      nc,.NoOverflow
.Overflow:              ld      a,$FF
.NoOverflow:            ld      e,a                     ; e now equals max length in pixels
                        ld      a,b
                        add     8
                        ld      d,a                     ; e = max height
                        ld      (PosScan1),bc
                        ld      (PosScan2),de
.CheckBoxes:            ld      ix,src_printed_text
                        ld      a,(src_buffer_size)
                        cp      0
                        jr      z,.SafeToPrint
                        ld      h,b                     ; h will substite for row b as b is used in dnjz
                        ld      b,a
.CheckBoxLoop:          ld      a,(ix+2)
                        cp      0                       ; zerolength, not applicable
                        jr      z,.NoBox
.CheckRow:              ld      a,(PosScan1)
                        inc     a
                        JumpIfAGTENusng (ix+2), .NoBox  ; X1 >= BottomLeftX
                        ld      a,(PosScan2)
                        JumpIfALTNusng (ix+0),  .NoBox   ; X2 <= TopRightX
.SafeToPrintX:          ld      a,(PosScan1+1)
                        inc     a
                        JumpIfAGTENusng (ix+3), .NoBox  ; Y1 >= BottomLeftY
                        ld      a,(PosScan2+1)
                        JumpIfALTNusng (ix+1),  .NoBox  ; Y2 <= TopRightY
.MatchedBox:            ld      a,$FF
                        ret
.NoBox:                 inc     ix
                        inc     ix
                        inc     ix
                        inc     ix
                        djnz    .CheckBoxLoop
.SafeToPrint:           ld      hl,src_printed_text
                        ld      a,(src_buffer_size)
                        ld      d,a
                        ld      e,4
                        mul
                        add     hl,de
                        ld      de,(PosScan1)
                        ld      (hl),de
                        inc     hl
                        inc     hl
                        ld      de,(PosScan2)
                        ld      (hl),de
                        ld      hl,src_buffer_size
                        inc     (hl)
                        xor     a
                        ret
                        
src_label_ssytem:       call	copy_system_to_working
                        ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        call	GetDigramWorkingSeed
                        ld		hl,name_expanded
                        call	CapitaliseString
                        ld		a,(local_name_row)
                        sub		local_label_shift_y
                        ld		b,a					    ; b = effective pixel row
                        ld		a,(local_name_col)
                        add		a,local_label_shift_x
                        ld		c,a                     ; c = effective pixel col
.GetStringName:         ld      e,0
                        ld      hl,name_expanded                   
.getStringLoop:         ld      a,(hl)
                        inc     hl
                        inc     e
                        cp      0                       ; String must have a terminator to work
                        jr      nz,.getStringLoop
                        ld      d,8
                        push    bc
                        call    FreeSlotCheck           ; first attemps
                        pop     bc
                        cp      0
                        jr      z,.OKToPrint
                        ld      a,b
                        add     8
                        ld      b,a
                        push    bc
                        call    FreeSlotCheck           ; attempt down 8 pixels attemps
                        pop     bc
                        cp      0
                        jr      z,.OKToPrint
                        ld      a,b
                        sub     16
                        ld      b,a
                        push    bc
                        call    FreeSlotCheck           ; attempt down 8 pixels attemps
                        pop     bc
                        cp      0
                        ret     nz
.OKToPrint:             ld		e,$FF
                        ld		hl,name_expanded
                        MMUSelectLayer2
                        call	l2_print_7at
                        ret

name_if_possible:       
SRCpixelRowToRefRow:    ld		a,(local_name_row)
                        sub		local_label_shift_y
                        ld		b,a					; b = effective pixel row
                        srl		a
                        srl		a
                        srl		a					; divide by 8 to get character row
                    ;	sub		2					; don;t write over header TODO tweaks
                        ld		hl,IndexedWork
                        add		hl,a
                        ld		a,(hl)
                        cp		0
                        jr		nz, SRCtryAbove		; if its not empty don't print *(need to test +-1 row TODO)
                        ld		(hl),1				; flag as in use
                        jr		SRCFoundRow
SRCtryAbove:            dec		hl
                        ld		a,(hl)
                        cp		0
                        jr		nz, SRCtryBelow		; if its not empty don't print *(need to test +-1 row TODO)
                        ld		(hl),1				; flag as in use
                        jr		SRCFoundRow
SRCtryBelow:            inc		hl
                        inc		hl
                        ld		a,(hl)
                        cp		0
                        ret		z
                        ld		(hl),1				; flag as in use
SRCFoundRow:            call	copy_system_to_working
SRCSmallSizeName:       ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        call	GetDigramWorkingSeed
SRCCapitaliseName:      ld		hl,name_expanded
                        call	CapitaliseString
SRCPrintName:           ld		hl, name_expanded
                        ld		a,(local_name_row)
                        sub		local_label_shift_y
                        ld		b,a					; b = effective pixel row
                        ld		a,(local_name_col)
                        add		a,local_label_shift_x
                        ld		c,a
                        ld		e,$FF
                        MMUSelectLayer2
                        call	l2_print_7at
                        ret

plot_local_stars:       xor		a
                        ld		(XSAV),a
                        ld      ix,galaxy_data
                        ld      (src_buffer_size),a
SRCClearNameList:       ld		hl,src_printed_text
                        ld		de,src_fill_buffer_size
                        call	memfill_dma:
SRCCounterLoop:         xor		a
                        ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        push    ix
                        push    ix
                        pop     hl
                        ld      de,SystemSeed
                        call    copy_seed
                        ld		a,(SystemSeed+1)				; QQ15+1 \ seed Ycoord of star
                        ld		c,a
SRCcalcLocaldy:         ld		a,(PresentSystemY)
                        ld		b,a								; so b holds Y ccord
                        ld		a,c
                        sub		b
                        bit		7,a
                        jr		z,SRCpositivedy
SRCnegativedy:          neg
SRCpositivedy:          cp		local_max_range_y
                        jr		nc,SRCtoofar
SRCcalcLocaldx:         ld		a,(SystemSeed+3)				; QQ15+3 \ seed Xcoord of star
                        ld		c,a
                        ld		a,(PresentSystemX)
                        ld		b,a								; so b holds Y ccord
                        ld		a,c
                        sub		b
                        bit		7,a
                        jr		z,SRCpositivedx
SRCnegativedx:          neg
SRCpositivedx:          cp		local_max_range_x
                        jr		nc,SRCtoofar
SRCOKToPlot             ld		a,(SystemSeed+1)
                        ld		hl,PresentSystemY
                        sub		(hl)
                        sla		a								; * 2
                        add		src_y_centre
                        ld		(local_name_row),a
                        ld		b,a
                        ld		a,(SystemSeed+3)
                        ld		hl,PresentSystemX
                        sub		(hl)
                        sla		a
                        sla		a								; * 4
                        add		src_x_centre
                        ld		(local_name_col),a
                        ld		c,a
                        ld		a,(SystemSeed+5)
                        and		$01
                        add		a,2
                        ld		d,a
                        ld		e,local_chart_star_colour
                        MMUSelectLayer2
                        call	l2_draw_circle_fill
                       ; call    src_get_name
                        call	src_label_ssytem
SRCtoofar:              pop     hl
                        add     hl,8
                        push    hl
                        pop     ix
                        ld		a,(XSAV)
                        dec		a
                        cp		0
                        ret		z
                        ld		(XSAV),a
                        jp		SRCCounterLoop
;----------------------------------------------------------------------------------------------------------------------------------
draw_local_chart_menu:  INCLUDE "Menus/clear_screen_inline_no_double_buffer.asm"
                        ld      a,$80
                        ld      (MenuIdMax),a
                        ld		hl,(PresentSystemX)
                        ld		(TargetPlanetX),hl              ; bc = selected jump
SRCDrawbox:             ld		bc,$0101
                        ld		de,$BEFD
                        ld		a,$C0
                        MMUSelectLayer2
                        call	l2_draw_box
                        ld		bc,$0A01
                        ld		de,$FEC0
                        MMUSelectLayer2
                        call	l2_draw_horz_line
SRCStaticText:          ld		a,short_range_header
                        call	expandTokenToString
                        ld		b,1
                        ld		hl,short_range_boiler_text
                        call	SRM_print_boiler_text
SRCSetUpChart:          call	copy_galaxy_to_system
                        call	plot_local_stars
.CircleandCrosshair:    call	SRM_draw_chart_circle_and_crosshair
                        call	SRM_draw_hyperspace_cross_hair
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
local_chart_cursors:    ld     a,(CursorKeysPressed)
                        cp      0
                        ret     z
                        rla
                        call   c,src_UpPressed
                        rla
                        call   c,src_DownPressed
                        rla
                        call   c,src_LeftPressed
                        rla
                        call   c,src_RightPressed
                        rla
                        call   c,src_HomePressed
                        rla
                        call   c,src_RecenterPressed
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_UpPressed:          ld     a,(TargetPlanetY)
                        JumpIfAEqNusng 1,src_BoundsLimit
                        dec     a
                        ld      (TargetPlanetY),a
                        call    SRM_update_hyperspace_cross_hair
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_DownPressed:        ld     a,(TargetPlanetY)
                        JumpIfAEqNusng 255,src_BoundsLimit
                        inc    a
                        ld      (TargetPlanetY),a
                        call    SRM_update_hyperspace_cross_hair
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_LeftPressed:        ld     a,(TargetPlanetX)
                        JumpIfAEqNusng 2,src_BoundsLimit
                        dec    a
                        ld      (TargetPlanetX),a
                        call    SRM_update_hyperspace_cross_hair
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_RightPressed:       ld     a,(TargetPlanetX)
                        JumpIfAEqNusng 253,src_BoundsLimit
                        inc    a
                        ld      (TargetPlanetX),a
                        call    SRM_update_hyperspace_cross_hair
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_HomePressed:        ld      hl,(PresentSystemX)
                        ld      (TargetPlanetX),hl
                        call    SRM_update_hyperspace_cross_hair
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_RecenterPressed:    ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      bc,(TargetPlanetX)
                        call    find_nearest_to_bc
                        ld      (TargetPlanetX),bc
                        call    SRM_update_hyperspace_cross_hair
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_BoundsLimit:        xor     a
                        ret

