

short_range_page_marker  DB "ShortRange  PG50"

short_range_boiler_text	DW $0030 : DB $02 : DW TextBuffer
short_range_header		equ 12
src_xy_centre			equ $6080
src_x_centre			equ 160
src_y_centre			equ $60
src_star_x_centre		equ 160 - 8 ; adjusted for sprite centre
src_star_y_centre		equ $60 - 8 ; adjusted for sprite centre
local_chart_star_colour	equ 216
local_dx				dw 0
local_dy				dw 0
local_max_range_x		equ 20
local_max_range_y		equ $26
local_name_row			db	0
local_name_col			dw	0   ; Moved to 320 mode
local_label_shift_x		equ	3 ; Incluing offset for 320 mode in charactres
local_label_shift_y		equ	32-5 ; Incluing offset for 320 mode in pixels

src_distance            DB "Distance: "
src_dist_amount         DB "000"
src_decimal             DB "."
src_fraction            DB "0"
src_dis_ly              DB " Light Years",0
src_default_dist        DB "  0.0"

src_distance_val        DS  6
src_fill_buffer_len     EQU 32
src_fill_buffer_size    EQU 4 * src_fill_buffer_len                          ; up to 32 labels topx topy lengthx spare
            DISPLAY "TODO: space for occupied cells may mvoe to bit flags"
src_printed_text        DS  src_fill_buffer_size                             ; space for occupied cells may move to bit flags later TODO
src_buffer_size         DB  0
;----------------------------------------------------------------------------------------------------------------------------------
; Change to display
; now 320 mode, will hold 32 lines by 40 columns (not all can hold text)
; buffer row will have row, col, length as number of characters occupied
; when drawing text, will now draw a line from the star to the text, )poss underline?)
; up to 32 stars in local chart (this will be overkill)
; each entry will be row (pixel), col (pixel), col to (pixel)
src_320_label_buffer    DS  32 * 4
;----------------------------------------------------------------------------------------------------------------------------------
SRM_print_boiler_text:  ld		b,1
                        ld		ix,short_range_boiler_text
.BoilerTextLoop:        push	bc			; Save Message Count loop value
                        ld		l,(ix+0)	; Get col into hl
                        ld		h,(ix+1)	;
                        ld		b,(ix+2)	; get row into b
                        ld		e,(ix+3)	; Get text address into hl
                        ld		d,(ix+4)	; .
                        push    ix          ; save ix and prep for add via hl
                        MMUSelectLayer2
                        print_msg_at_de_at_b_hl_macro txt_status_colour
                        pop     hl          ; add 5 to ix
                        ld      a,5         ; .
                        add     hl,a        ; .
                        ld      ix,hl       ; .
                        pop		bc
                        djnz	.BoilerTextLoop
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; Initially we'll just do it as before then work out an offset/scaling
SRM_draw_chart_circle_and_crosshair:
                        ld		bc,(PresentSystemX)				; bc = present system?????
                        MMUSelectSpriteBank
                        call	sprite_local_cursor
                        MMUSelectLayer2
                        ;ld      bc,src_xy_centre
                        ;call    l2_draw_circle
                        ld		bc,src_xy_centre				; must be ordered x y in data
                        ld      hl,src_x_centre
                        ld		a,(Fuel)
                        ld		d,a
                        ld		e,$FF
                        call	l2_draw_circle_320
                        ret
                                        DISPLAY "TODO:  move cursor code"
; TODO MOVE CURSOR CODE
;----------------------------------------------------------------------------------------------------------------------------------
SRM_draw_hyperspace_cross_hair:
                        ld		bc,(TargetSystemX)              ; bc = selected jump
                        ld		de,(PresentSystemX)
                        ld		c,src_x_centre
                        ld		b,src_y_centre
                        MMUSelectSpriteBank
                        call	sprite_local_hyper_cursor
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_get_name:           ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld      bc,(TargetSystemX)
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
                        ld		bc,(TargetSystemX)              ; bc = selected jump
                        ld		de,(PresentSystemX)
                        ld		a,c                             ; a = target x pos
                        sub		e                               ; a = target x - present x
                        jp      p,.NoFlipX                      ; if > 0 skip next bit
                        neg                                     ; c = a = abs a * 4
                        sla		a                               ; .
                        sla		a                               ; .
                        ld      c,a                             ;  .
                        ld      a,src_x_centre                  ; c = a = centre screen - c
                        sub     c                               ; .
                        ld      c,a                             ; .
                        jp      .fixY                           ;. now do Y
.NoFlipX:               sla		a
                        sla		a
                        add		a,src_x_centre
                        ld      c,a
.fixY:                  ld		a,b                             ; for Y its * 2
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
                        ld      bc,(TargetSystemX)
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
                        ;ld      bc,$A80A
                        ;ld		e,$FF
                        ex      de,hl
                        ld      b,$A0
                        ld      hl, $00A0
                        ld      c,$FF
                        MMUSelectLayer2
                        call    l2_print_at_320         ;b = row, hl = col, de = addr of message, c = color
                        ;call	l2_print_7at            ; bc= colrow, hl = addr of message, e = colour"
                        pop     af
                        pop     hl
                        call    src_calc_distance
                        ld      de,src_distance
                        ld      bc,$B0
                        ld      hl,$0A
                        ld		c,$FF
                        MMUSelectLayer2
                        call	l2_print_at_320
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
                        ld      bc,(TargetSystemX)
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
; Checks to see if we have enough room to print text. src_printed_text holds the buffer
; Carry flag is set on failure
FreeSlotCheck:          ld      a,c                     ;
                        ld      (.CheckStartX+1),a       ; Top Left X (get it in now whilst its in a
                        add     a,e                     ;
                        jr      nc,.NoOverflow          ;
.Overflow:              ld      a,$FF                   ; Make length max
.NoOverflow:            ld      (.CheckEndX+1),a         ; Bottom Right X
                        ld      a,b                     ; d = height in pixels
                        ld      (.CheckStartY+1),a       ; Top Left Y
                        add     a,8                     ; Bottom Right Y
                        ld      (.CheckEndY+1),a
.CheckBoxes:            ld      a,(src_buffer_size)     ; If buffer is empty no check
                        cp      0                       ; .
                        jr      z,.SafeToPrint          ; .
                        ld      ix,src_printed_text     ; Buffer list                    
                        ld      b,a
.CheckBoxLoop:          ld      a,(ix+3)                ; zero length buffer entry gets skipped
                        cp      0                       ; .
                        jr      z,.NoMatch              ; .                                          .Example $5D,$0C to $65,$11 93,12 to 101,17
.CheckStartY:           ld      a,$00                   ; get start row                              .Compare $52,$0D to $62,$0F 82,13 to 98,15
                        inc     a                       ; as we do GTE not GT                        .$5D < $62 so potential hit
                        JumpIfAGTENusng (ix+2), .NoMatch; Start Y > BottomRightY then not applicable .$0C < $0F so potential hit
.CheckStartX:           ld      a,$00                   ; get start col                              .$65 > $52 so potential hit
                        inc     a                       ; as we do GTE not GT                        .$11 < $0D so potential hit
                        JumpIfAGTENusng (ix+3), .NoMatch; Start X > BottomRightX then not applicable .
.CheckEndY:             ld      a,$00                   ;                                            .
                        JumpIfALTNusng  (ix+0), .NoMatch; End Y < TopLeft Y then not applicable      .
.CheckEndX:             ld      a,$00                   ;                                            .
                        JumpIfALTNusng (ix+1),  .NoMatch; End X < TopLeft X then not applicable      .
;.......................If we get here then there is an overlap so fails                        
.MatchedBox:            SetCarryFlag ; changed from a holding result ld      a,$FF
                        ret
;.......................If we get here then there was no overlap so check next box                        
.NoMatch:               inc     ix
                        inc     ix
                        inc     ix
                        inc     ix
                        djnz    .CheckBoxLoop
;.......................If we get here then there was no overlap in the entire buffer so good                        
.NoBoxMatched:          ld      b,h                     ; restore bc
.SafeToPrint:           ld      hl,src_printed_text
                        ld      a,(src_buffer_size)     ; now we have to work on buffer size as 1 per 4 byte group
                        ld      d,a                     ; but move the pointer on by 4 before writing out next entry
                        inc     a                       ;
                        ld      (src_buffer_size),a     ; write out now as we have it in a reg
                        ld      e,4                     ; hl moves on 4 bytes
                        mul     de                      ; .
                        add     hl,de                   ; .
                        ld      a,(.CheckStartY+1)       ; Copy from modified code
                        ld      (hl),a                  ;
                        inc     hl                      ;
                        ld      a,(.CheckStartX+1)       ;
                        ld      (hl),a                  ;
                        inc     hl                      ;
                        ld      a,(.CheckEndY+1)         ;
                        ld      (hl),a                  ;
                        inc     hl                      ;
                        ld      a,(.CheckEndX+1)         ;
                        ld      (hl),a                  ;
                        ClearCarryFlag; changed from a holing result xor     a
                        ret

                        
; takes memorty location local_name_col and local_name_row as character positions of text                        
src_label_system:       call	copy_system_to_working                      ; set up working seed
                        ld      a,(Galaxy)                                  ; and name
                        MMUSelectGalaxyA                                    ;
                        call	GetDigramWorkingSeed                        ;
                        ld		hl,name_expanded                            ; so hl points to name string
                        call	CapitaliseString                            ; .
                        ld		a,(local_name_row)                          ; row position in characters
                        add		a,3
                        ld		b,a					                        ; b = effective pixel row
                        ld      a,(local_name_col)                          ; column position in characters
                        ld      c,local_label_shift_x
                        add     a,c
                        ld      (local_name_col),a                     
                        ld		c,a                                         ; c = effective char col
.GetStringName:         ld      e,0
                        ld      hl,name_expanded                   
.getStringLoop:         ld      a,(hl)
                        inc     hl
                        inc     e
                        cp      0                                           ; String must have a terminator to work
                        jr      nz,.getStringLoop
                        ld      d,8
;.......................first attempt bc = row col e = chars                        
.attempt1:              push    bc,,de
                        call    FreeSlotCheck    
                        pop     bc,,de
                        jr      nc,.OKToPrint
;.......................attempt 2 left of star name
.attempt2:              ld      a,c                     ; col = col - (e+1)
                        ClearCarryFlag                  ;
                        sbc     a,e                     ; move to the left
                        jp      m,.attempt3             ; but negative X is bad
                        sbc     a, 3                    ; 3 characters + half star width
                        jp      m,.attempt3             ; but negative X is bad
                        ld      c,a                     ; we can load to col as its good
                        push    bc,,de
                        call    FreeSlotCheck 
                        pop     bc,,de
                        jr      nc,.OKToPrint
.recoverattempt2:       ld      a,c                     ; if it failed then we adjust col back to original value
                        inc     a
                        add     e                  
;.......................attempt 3 down 8 pixels                        
.attempt3:              ld      a,b
                        add     a,8
                        ld      b,a
                        push    bc,,de
                        call    FreeSlotCheck           
                        pop     bc,,de
                        jr      nc,.OKToPrint
;.......................attempt 4 down 16 pixels
.attempt4:              ld      a,b
                        sub     16
                        ld      b,a
                        push    bc,,de
                        call    FreeSlotCheck           ; attempt down 8 pixels attemps
                        pop     bc,,de
                        ret     c                       ; give up on attempt 3
.OKToPrint:             ld      d,8                     ; de = c = column in characters
                        ld      e,c                     ; .
                        mul     de                      ; hl = de = hl in pixles
                        ex      de,hl                   ; .
                        ld		de,name_expanded
                        ld		c,$FF
                        MMUSelectLayer2
                        call	l2_print_at_320_precise         ;b = row, hl = col, de = addr of message, c = color
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
                        ld		b,a								; so b holds Y ccord of present system
                        ld		a,c                             ; a = seed1 Y ccoord
                        sub		b
                        bit		7,a                             ; check range
                        jr		z,SRCpositivedy                 
SRCnegativedy:          neg
SRCpositivedy:          cp		local_max_range_y               ; ignore too far away
                        jr		nc,SRCtoofar
SRCcalcLocaldx:         ld		a,(SystemSeed+3)				; QQ15+3 \ seed Xcoord of star
                        ld		c,a                             ; c= X coord
                        ld		a,(PresentSystemX)              ; b= current system X coord
                        ld		b,a								; . so b holds Y ccord
                        ld		a,c                             ; a= X coord - present X
                        sub		b                               ;
                        bit		7,a                             ; check distance
                        jr		z,SRCpositivedx                 ;
SRCnegativedx:          neg                                     ;
SRCpositivedx:          cp		local_max_range_x               ;
                        jr		nc,SRCtoofar
SRCOKToPlot             ld		a,(SystemSeed+1)                ; OK so its in range, calc again (need to optimise this)
                        ld		hl,PresentSystemY               ;
                        sub		(hl)                            ;
                        sla		a								; b = local_name_row = a =  (delta Y * 2) + screen center
                        add		src_star_y_centre                    ; .
                        ld		(.SystemPlotY+1),a              ; .
                        ld      (local_name_row),a              ; local name row will be in pixels
                        ld		a,(SystemSeed+3)                ; hl = a = (deltaX * 4) 
                        ld      h,0
                        ld      l,a
                        ld      a,(PresentSystemX)
                        ld      d,0
                        ld      e,a
                        ClearCarryFlag
                        sbc     hl,de
                        ex      hl,de                           ; put the result in de
                        ld      b,2                             ; multiply by 2
                        bsla    de,b                            ;
                        ld      a,src_star_x_centre             ; .
                        add     de,a                            ; .
                        ld      (.SystemPlotX+1),de             ; .
                        ld      b,3                             ; now divide by 8 to get char column
                        bsra    de,b
                        ld      (local_name_col),de             ; colum for local name will be in characters
                        ld		a,(SystemSeed+5)                ; radius = seed 5 & 3 + 2 (for now)
                        and		%00000011                       ; .
                        add		a,2                             ; .
                        ld		c,a                             ; .
.SystemPlotX:           ld      hl,$0000                        ; colum number as pixels
.SystemPlotY:           ld      b,$00                           ; row number as pixels
                        MMUSelectSpriteBank
                        call	sprite_local_chart_show         ; B = row, hl = col, d = radius, e = colour
                       ; call    src_get_name
                        MMUSelectLayer2
                        call	src_label_system
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
draw_local_chart_menu:  MMUSelectLayer1
                        call	l1_cls
                        ld		a,7
                        call	l1_attr_cls_to_a
                        MMUSelectLayer2
                        call    asm_l2_double_buffer_off
                        call    l2_320_initialise
                        call    l2_320_cls
                        MMUSelectSpriteBank
                        call    sprite_cls_cursors
                        call    init_sprites_l2_prity
                        MMUSelectLayer2
.Drawbox:               call    l2_draw_menu_border
                        ld		bc,$0AC0 
                        ld      hl,$0001
                        ld		de,320-4
                        call	l2_draw_horz_line_320       ;b = row; hl = col, de = length, c = color"
                        ld      a,$80
                        ld      (MenuIdMax),a
                        CopyPresentSystemToTarget               ; for short range we always start at present and cusor on present
SRCStaticText:          ld		a,short_range_header
                        call	expandTokenToString
                        call	SRM_print_boiler_text
SRCSetUpChart:          call	copy_galaxy_to_system
                        break
                        call	plot_local_stars
.CircleandCrosshair:    break
                        call	SRM_draw_chart_circle_and_crosshair
                        call	SRM_draw_hyperspace_cross_hair
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
local_chart_cursors:    ld     a,(CursorKeysPressed)
                        ReturnIfAIsZero
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
src_UpPressed:          ld     a,(TargetSystemY)
                        JumpIfAIsZero   src_BoundsLimit 
                        ld      b,a                         ; save target as we will need it
                        ld      a,(PresentSystemY)
                        sub     b                           ; get the difference between present and target
                        jp      m,.SkipBoundsTest           ; if target is right of present, we can go left
                        JumpIfAGTENusng 40,src_BoundsLimit  ; if no more than 20 then OK
.SkipBoundsTest:        ld      a,b
                        dec     a
                        ld      (TargetSystemY),a
                        call    SRM_update_hyperspace_cross_hair
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_DownPressed:        ld     a,(PresentSystemY)
                        ld      b,a
                        ld      a,(TargetSystemY)
                        ld      c,a
                        JumpIfAEqNusng 128,src_BoundsLimit
                        sub     b
                        jp      m,.SkipBoundsTest
                        JumpIfAGTENusng 40,src_BoundsLimit
.SkipBoundsTest:        ld      a,c
                        inc    a
                        ld      (TargetSystemY),a
                        call    SRM_update_hyperspace_cross_hair
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_LeftPressed:        ld      a,(TargetSystemX)           ; we can't move left if target is zero
                        JumpIfAIsZero   src_BoundsLimit 
                        ld      b,a                         ; save target as we will need it
                        ld      a,(PresentSystemX)
                        sub     b                           ; get the difference between present and target
                        jp      m,.SkipBoundsTest           ; if target is right of present, we can go left
                        JumpIfAGTENusng 20,src_BoundsLimit  ; if no more than 20 then OK
.SkipBoundsTest:        ld      a,b
                        dec     a
                        ld      (TargetSystemX),a
                        call    SRM_update_hyperspace_cross_hair
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_RightPressed:       ld      a,(PresentSystemX)
                        ld      b,a
                        ld      a,(TargetSystemX)
                        ld      c,a
                        JumpIfAEqNusng 255,src_BoundsLimit
                        sub     b
                        jp      m,.SkipBoundsTest
                        JumpIfAGTENusng 20,src_BoundsLimit
.SkipBoundsTest:        ld      a,c
                        inc    a
                        ld      (TargetSystemX),a
                        call    SRM_update_hyperspace_cross_hair
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_HomePressed:        ld      hl,(PresentSystemX)
                        ld      (TargetSystemX),hl
                        call    SRM_update_hyperspace_cross_hair
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_RecenterPressed:    ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      bc,(TargetSystemX)
                        call    find_nearest_to_bc
                        ld      (TargetSystemX),bc
                        call    SRM_update_hyperspace_cross_hair
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
src_BoundsLimit:        xor     a
                        ret

