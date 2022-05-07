
galactic_chart_page_marker  DB "GalacticChrtPG51"
galactic_chart_boiler_text	DW $0240,TextBuffer
galactic_chart_header		equ 13
galactic_star_colour		equ 216
galactic_star_colour2		equ 108
galactic_chart_y_offset		equ $18
galactic_chart_hyper_offset equ 4
galactic_chart_hyper_x_offset equ 32 - 4
galactic_chart_hyper_y_offset equ 32 - 4 + 24
galactic_chart_distance     DB "Distance: "
galactic_chart_dist_amount  DB "000"
galactic_chart_decimal      DB "."
galactic_chart_fraction     DB "0"
galactic_chart_dis_ly       DB " Light Years",0
galactic_default_dist       DB "  0.0",0

galactic_distance           DS  6

galactic_find_position      equ $B008
galactic_find_message       DB "Find: ",0
galactic_find_text          equ $B038
galactic_blank_message      DB  "                    ",0
galactic_find_no_match      DB "**-- System Not Found --**",0
galactic_find_match         DB "  **-- System Found --**  ",0

GCM_print_boiler_text:
    INCLUDE "Menus/print_boiler_text_inlineInclude.asm"
GCM_draw_chart_circle_and_crosshair:
	ld		bc,(PresentSystemX)				; bc = present system
.OnGalacticChart:
	srl		b								; but row is row / 2
	push  	bc
	MMUSelectSpriteBank
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
	MMUSelectLayer2
	call	l2_draw_circle
	ret
; TODO MOVE CURSOR CODE

GCM_draw_hyperspace_cross_hair: ld		bc,(TargetSystemX)              ; bc = selected jump
                                push    bc
                                srl		b								; but row is row / 2
                                MMUSelectSpriteBank
                                call	sprite_galactic_hyper_cursor
                                pop     bc
                                call	sprite_ghc_move
                                ret


plot_gc_stars:          xor		a
                        ld		(XSAV),a
                        ld      ix,galaxy_data
.CounterLoop:           ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        push    ix
                        pop     hl
                        ld      de,SystemSeed
                        call    copy_seed
                        ld		a,(SystemSeed+3)				; QQ15+3 \ seed w1_h is Xcoord of star
                        ld		c,a								; c = X Coord
                        ld		a,(SystemSeed+1)
                        srl		a								; Ycoord /2
                        add		a,galactic_chart_y_offset		; add offset to Y coord of star
                        ld		b,a								; b = row
                        push	bc
                        ld		a,galactic_star_colour
                        MMUSelectLayer2
                        call	l2_plot_pixel
                        pop		bc
                        ld		a,(SystemSeed+4)
                        or		$50								; minimum distance away
                        cp		$90
                        jr		nc,.NoSecondPixel
.SecondPixel:           inc		c
                        ld		a,galactic_star_colour2
                        MMUSelectLayer2
                        call	l2_plot_pixel
.NoSecondPixel:         push    ix
                        pop     hl
                        add     hl,8
                        push    hl
                        pop     ix
                        ld		a,(XSAV)
                        dec		a
                        cp		0
                        ret		z
                        ld		(XSAV),a
                        jr		.CounterLoop

GALDP       DB "********++++++++"
draw_galactic_chart_menu:   InitNoDoubleBuffer
                            ld      ixl,$DC
                            ld      a,$40
                            ld      (MenuIdMax),a
                            ld      hl,(PresentSystemX)
;                            ld      (TargetSystemX),hl
                            call    gc_present_system               ; Set up the seed for present system
.Drawbox:                   ld		bc,$0101
                            ld		de,$BEFD
                            ld		a,$C0
                            MMUSelectLayer2
                            call	l2_draw_box
                            ld		bc,$0A01
                            ld		de,$FEC0
                            call	l2_draw_horz_line
.StaticText:                ld		a,galactic_chart_header
                            call	expandTokenToString
                            ld		b,1
                            ld		hl,galactic_chart_boiler_text
                            call	GCM_print_boiler_text
.CircleandCrosshair:        call	GCM_draw_chart_circle_and_crosshair
                            call	GCM_draw_hyperspace_cross_hair
                            call	plot_gc_stars
                            ld      a,(Galaxy)
                            MMUSelectGalaxyA
                            ld      bc,(TargetSystemX)
                            call    galaxy_system_under_cursor          ; TODO for some reason this bit
                            cp      0                                   ; does not reset cursor on a miss
                            jr      nz,.CurrentTargetIsValid
.CurrentTargetIsInvalid:    CopyPresentSystemToTarget
                            ld      bc,(TargetSystemX)
                            MMUSelectSpriteBank
                            call	sprite_ghc_move
.CurrentTargetIsValid:      ld      a,(Galaxy)
                            MMUSelectGalaxyA
                            ld      (GalaxyTargetSystem),bc
                            call    galaxy_system_under_cursor
                            call    gc_name_if_possible
                            SetMemFalse TextInputMode
                            ret

gcDelayVal                  equ $0A
gcBlinkVal                  equ $10
            

gcCursorBlink               DB  gcBlinkVal
gcCursorChar                DB  " "
gcEndOfString               DB  0
gcInputText                 DS  31
                            DB  0,0,0,0,0
gcBlank                     DS  32

;----------------------------------------------------------------------------------------------------------------------------------
gc_display_find_text:   ld		de,galactic_find_position   ; Wipe input area on screen
                        ld      hl,galactic_find_message
                        MMUSelectLayer1
                        call	l1_print_at
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_display_find_string: ld      de,gcInputText
                        call    keyboard_copy_input_to_de
                        ld      hl,gcCursorChar         ; Now just copy cursor char too
                        ldi                             ; Copy cursor to local
                        ld      a,(InputCursor)
                        inc     a
                        ld      b,a
                        ld      a,20
                        sub     b
                        ld      b,a
                        ld      a," "
.SpacePad:              ld      (de),a
                        inc     de
                        djnz    .SpacePad
                        xor     a
                        ld      (de),a
                        ld		de,galactic_find_text    ; Display text
                        ld      hl,gcInputText
                        MMUSelectLayer1
                        call	l1_print_at
                        ret

blink_cursor:           ld      a,(gcCursorBlink)
                        dec     a
                        ld      (gcCursorBlink),a
                        ret     nz
.FlashCursor:           ld      a,gcBlinkVal
                        ld      (gcCursorBlink),a
                        ld      a,(gcCursorChar)
                        cp      " "
                        jr      z,.ChangeToStar
                        ld      a," "
                        ld      (gcCursorChar),a
                        ret
.ChangeToStar:          ld      a,"*"
                        ld      (gcCursorChar),a
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; The main loop handles the find key
loop_gc_menu:           JumpIfMemTrue TextInputMode,AlreadyInInputMode  ;if we are in input mode then go directly there
.StartFindCheck:        ld      a,c_Pressed_Find                        ;Is F pressed
                        call    is_key_pressed
                        ret     nz                                      ;the main loop handles find key 
                        call    initInputText                           ;Initialise find input
                        SetMemTrue TextInputMode                        ;Set input mode to true
                        SetMemToN gcCursorBlink, gcBlinkVal             ; set up blink
.DisplayInputbar:       call    gc_display_find_text                    ; now prep the boiler plate input text
                        ret                                             ; and exit so next interation handles new input as we have to rescan keyboard
;Already in input mode post pressing find
AlreadyInInputMode:     call    InputName                               ; Call input routine to parse a key
                        JumpIfMemFalse InputChanged, .blinkNoDelay      ; no key they bypass rest of input
.WasItEnter:            JumpIfMemTrue EnterPressed, .FindEnterPressed   ; if enter was pressed then find
                        call    gc_display_find_string                  ; update string
.blinkNoDelay:          call    blink_cursor
                        CallIfMemEqNusng    gcCursorBlink, gcBlinkVal, gc_display_find_string ; on blink we get a double update but we can live with that
                        ret
.FindEnterPressed:      SetMemFalse EnterPressed                        ; reset enter
                        SetMemFalse TextInputMode                       ; leave input mode
                        ld      a,(Galaxy)                              ; Fetch correct galaxy seed bank into memory
                        MMUSelectGalaxyA
                        ld      hl,InputString
                        ld      de,GalaxySearchString
                        call    GalaxyCopyLoop
                        call    find_system_by_name
                        cp      $FF                                     ; 0 denotes found FF, failure
                        jr      z,.FindNoMatch
                        ld      a,(GalaxyWorkingSeed+3)
                        ld      c,a
                        ld      a,(GalaxyWorkingSeed+1)
                        ld      b,a
                        ld      (TargetSystemX),bc
                        call    UpdateGalacticCursor
                        ld		de,galactic_find_position               ; Wipe input area on screen
                        ld      hl,galactic_find_match
                        MMUSelectLayer1
                        call	l1_print_at                        
                        ret
.FindNoMatch:           ; if not found display "Not found"
                        ; move curor if found
                        ld		de,galactic_find_position   ; Wipe input area on screen
                        ld      hl,galactic_find_no_match
                        MMUSelectLayer1
                        call	l1_print_at
                        ret; DOSTUFFHERE
;----------------------------------------------------------------------------------------------------------------------------------
galctic_chart_cursors:  ReturnIfMemTrue TextInputMode
                        ld      a,(CursorKeysPressed)
                        cp      0
                        ret     z
                        rla
                        call   c,gc_UpPressed
                        rla
                        call   c,gc_DownPressed
                        rla
                        call   c,gc_LeftPressed
                        rla
                        call   c,gc_RightPressed
                        rla
                        call   c,gc_HomePressed
                        rla
                        call   c,gc_RecenterPressed
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_UpPressed:           ld     a,(TargetSystemX+1)
                        JumpIfAEqNusng 1,gc_BoundsLimit
                        dec     a
                        ld      (TargetSystemX+1),a
                        call    UpdateGalacticCursor
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_DownPressed:         ld     a,(TargetSystemX+1)
                        JumpIfAEqNusng 255,gc_BoundsLimit
                        inc    a
                        ld      (TargetSystemX+1),a
                        call    UpdateGalacticCursor
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_LeftPressed:         ld     a,(TargetSystemX)
                        JumpIfAEqNusng 2,gc_BoundsLimit
                        dec    a
                        ld      (TargetSystemX),a
                        call    UpdateGalacticCursor
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_RightPressed:        ld     a,(TargetSystemX)
                        JumpIfAEqNusng 253,gc_BoundsLimit
                        inc    a
                        ld      (TargetSystemX),a
                        call    UpdateGalacticCursor
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_HomePressed:         ld      hl,(PresentSystemX)
                        ld      (TargetSystemX),hl
                        call    UpdateGalacticCursor
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_RecenterPressed:     ld      a,(Galaxy)       ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      bc,(TargetSystemX)
                        call    find_nearest_to_bc
                        ld      (TargetSystemX),bc
                        call    UpdateGalacticCursor
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_BoundsLimit          xor     a
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
UpdateGalacticCursor:   ld		bc,(TargetSystemX)              ; bc = selected jump
OnGalacticChart:        MMUSelectSpriteBank
                        call	sprite_ghc_move
                        ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld      bc,(TargetSystemX)
                        ld      (GalaxyTargetSystem),bc
                        call    galaxy_system_under_cursor
                        cp      0
                        ret     z
; just fall into gc_name_if_possible
gc_name_if_possible:    call	GetDigramWorkingSeed
                        call    gc_clear_name_area
                        ld		hl,name_expanded
                        call	CapitaliseString
                        ld		hl, name_expanded
                        ld      bc,$A00A
                        ld		e,$FF
                        MMUSelectLayer2
                        call	l2_print_7at
                        call    gc_calc_distance
                        ld      hl,galactic_chart_distance
                        ld      bc,$A80A
                        ld		e,$FF
                        MMUSelectLayer2
                        call	l2_print_7at
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_clear_name_area:     ld      h,8
                        ld      de,$A000 | COLOUR_TRANSPARENT
                        ld      bc,$A00A
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
gc_calc_distance:       ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld      de,galactic_chart_dist_amount
                        ld      hl,galactic_default_dist
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ld      bc,(PresentSystemX)
                        ld      (GalaxyPresentSystem),bc
                        ld      bc,(TargetSystemX)
                        ld      (GalaxyDestinationSystem),bc
                        call    galaxy_find_distance            ; get distance into HL
                        ld      ix,(Distance)
                        ld      de,0
                        ld      iy,galactic_distance
                        call    DispDEIXtoIY
                        push    iy
                        pop     hl
                        ld      de,galactic_distance
                        ld		a,(hl)				;Push last digit to post decimal
                        ld		(galactic_chart_fraction),a
                        dec     hl
                        call    compare16HLDE
                        jr      c,.done_number
                        ld      a,(hl)
                        ld      (galactic_chart_dist_amount+2),a
                        dec     hl
                        call    compare16HLDE
                        jr      c,.done_number
                        ld      a,(hl)
                        ld      (galactic_chart_dist_amount+1),a
                        dec     hl
                        call    compare16HLDE
                        jr      c,.done_number
                        ld      a,(hl)
                        ld      (galactic_chart_dist_amount),a
.done_number:           ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_present_system:      xor     a
                        ld		(XSAV),a
                        ld      ix,galaxy_data
GCCounterLoop:          ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld      hl,(PresentSystemX)
                        push    ix
                        ld      a,l
                        cp      (ix+3)                          ; seed x
                        jr      nz,.ItsNotThisX
                        ld      a,h
                        cp      (ix+1)                          ; seed x
.FoundSystem:           jr      nz,.ItsNotThisX
                        push    ix
                        pop     hl
                        ld      de,PresentSystemSeeds
                        call    copy_seed
                        ld      a,$FF
                        pop     ix
                        ret
.ItsNotThisX:           pop     hl
                        add     hl,8
                        push    hl
                        pop     ix
                        ld		a,(XSAV)
                        dec		a
                        ld      (XSAV),a
                        cp		0
                        ret		z
                        jr		GCCounterLoop

