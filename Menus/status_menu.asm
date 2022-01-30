status_page_marker  DB "Status      PG63"    

status_boiler_text		DW $0240,txt_commander
						DW $0290,CommanderName
						DW $0B08,txt_present_system
						DW $1308,txt_hyperspace_system
						DW $1B08,txt_condition
						DW $2308,txt_fuel
						DW $2B08,txt_cash
						DW $3308,txt_legal_status
						DW $3B08,txt_rating
						DW $4B08,txt_equipment	

equipment_cursor		DW  $0000
present_position		equ	$0B98
hyperspace_position		equ	$1398
condition_position		equ	$1B70
fuel_position			equ	$2370
cash_position			equ	$2B70
legal_status_position	equ $3370
rank_position			equ $3B70
equipment_position		equ $5340
equipment_position2		equ $5378
equipmax_row			equ $FF

STAT_selected_row       DB 0
STAT_current_topItem    DB 0
STAT_current_end        DB 0
STAT_buffer_rows         EQU     128
STAT_buffer_row_len      EQU     24
STAT_eqip_window_len    EQU 10
STAT_display_buff_len    EQU     STAT_buffer_rows *   STAT_buffer_row_len
STAT_display_buffer:     DS      STAT_display_buff_len                     ; maxium of 128 items can be coded for
STAT_position			equ $5840 
STAT_cash_amount    	DS 10
STAT_cash_UoM           DB " Cr",0

stat_present_name       DS  30
                        DB  0
stat_target_name        DS  30
                        DB  0
                        
stat_copy_to_name:
    ld      hl,GalaxyExpandedName
    ld      bc,30
    ldir
    ret

STAT_print_boiler_text: INCLUDE "Menus/l2print_boiler_text_inlineInclude.asm"

;----------------------------------------------------------------------------------------------------------------------------------
STAT_DispDEIXtoIY:      ld (.STATclcn32z),ix
                        ld (.STATclcn32zIX),de
                        ld ix,.STATclcn32t+36
                        ld b,9
                        ld c,0
.STATclcn321:           ld a,'0'
                        or a
.STATclcn322:           ld e,(ix+0)
                        ld d,(ix+1)
                        ld hl,(.STATclcn32z)
                        sbc hl,de
                        ld (.STATclcn32z),hl
                        ld e,(ix+2)
                        ld d,(ix+3)
                        ld hl,(.STATclcn32zIX)
                        sbc hl,de
                        ld (.STATclcn32zIX),hl
                        jr c,.STATclcn325
                        inc c
                        inc a
                        jr .STATclcn322
.STATclcn325:           ld e,(ix+0)
                        ld d,(ix+1)
                        ld hl,(.STATclcn32z)
                        add hl,de
                        ld (.STATclcn32z),hl
                        ld e,(ix+2)
                        ld d,(ix+3)
                        ld hl,(.STATclcn32zIX)
                        adc hl,de
                        ld (.STATclcn32zIX),hl
                        ld de,-4
                        add ix,de
                        inc c
                        dec c
                        jr z,.STATclcn323
                        ld (iy+0),a
                        inc iy
.STATclcn323:           djnz .STATclcn321
                        ld a,(.STATclcn32z)
                        add A,'0'
                        ld (iy+0),a
                        ld (iy+2),0
                        ld      a,(IY+0)
                        ld      (IY+1),a
                        ld      a,"."
                        ld      (IY+0),a
                        inc     IY
                        inc     IY
                        ret
.STATclcn32t            dw 1,0,     10,0,     100,0,     1000,0,       10000,0
                        dw $86a0,1, $4240,$0f, $9680,$98, $e100,$05f5, $ca00,$3b9a
.STATclcn32z            ds 2
.STATclcn32zIX          ds 2
;----------------------------------------------------------------------------------------------------------------------------------
STAT_GetCash:           ld		hl,(Cash+2)
                        ex      de,hl
                        ld      ix,(Cash)
                        ld		iy,STAT_cash_amount
                        call 	STAT_DispDEIXtoIY
                        push    iy
                        pop     de
                        ld      hl,STAT_cash_UoM
                        ld      bc,4
                        ldir
                        ret
;----------------------------------------------------------------------------------------------------------------------------------	
STAT_expand_word:       ld      a,(hl)
                        cp      0
                        ret     z
                        ld      (de),a
                        inc     hl
                        inc     de
                        jr      STAT_expand_word

; hl = list of words
; de = adress to expand to
STAT_expand_name:       ld      a,(hl)
                        ld      b,a             
                        inc     hl
                        ld      a,(hl)              ; its a 16 bit
                        dec     hl                  ; move back one for now, need to optimise laters
                        or      b
                        jr      nz,.MoreToDo
;                        ld      (de),a we dont want the null marker now
                        ret     
.MoreToDo:              push    hl,,de
                        ld      a,(hl)              ; bodge for now no optimise
                        ld      e,a
                        inc     hl
                        ld      a,(hl)
                        ld      d,a
                        ex      hl,de               ; hl is now Word... address
                        pop     de                  ; de back to pointer to buffer
.ProcessWord:           call    STAT_expand_word
                        ld      a," "               ; speculative space
                        ld      (de),a
                        inc     de
                        pop     hl                  ; get string pointer back
                        inc     hl
                        inc     hl                  ; on to next word
                        jr      STAT_expand_name

STAT_First_Item         EQU     EQ_CARGO_BAY
STAT_buffer_list:       ld      a,(Galaxy)       ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      hl,STAT_display_buffer                      ; hl - target buffer
                        ld      a,1                                         ; so it will still skip them on printing
                        ld      de, STAT_display_buff_len
                        call    memfill_dma                                 ; full buffer with ASCII 1 (unprintable character)
                        ld      hl,STAT_display_buffer+STAT_buffer_row_len-1
                        ld      de,STAT_buffer_row_len
                        ld      b,EQ_ITEM_COUNT - EQ_CARGO_BAY
                        xor     a
.EoLLoop:               ld      (hl),a                                      ; fix all buffer lines with a null
                        add     hl,de
                        djnz    .EoLLoop
                        ld      b,EQ_ITEM_COUNT - EQ_CARGO_BAY              ; CurrentGameMaxEquipment but minus fuel and missiles
                        ld      ix,EquipmentFitted + STAT_First_Item        ; ix = equipment master table, ignore missiles
                        ld      iy,STAT_display_buffer                      ; iy = target buffer
                        ld      c,0                                         ; Current Row
                        ld      e,STAT_First_Item
.ProcessRow:            ld      a,(ix+0)                                    ; Do we own one?
                        cp      0
                        jr      z,.DoneFittedCheck
.OwnItem:               push    de,, iy,, ix,, bc
                        ld      hl,ShipEquipNameTable                       ; look up equipment name
                        ld      d,EquipNameTableRowLen                       ; ship equip name row length, e = current equip row
                        mul
                        add     hl,de                                       ; hl = dword list of work pointers
                        ld      de,iy                                       ; de = 0 column at current display buffer row
                        call    STAT_expand_name                           ; expand name
                        pop     iy,,ix,,bc
                        ld      de,STAT_buffer_row_len
                        add     iy,de                                       ; now iy = start of next column
                        pop     de
                        inc     c
.DoneFittedCheck:       inc     ix                        
                        inc     e
                        djnz    .ProcessRow
.DoneProcess:           ld      a,c
                        ld      (STAT_current_end),a
                        ret
;----------------------------------------------------------------------------------------------------------------------------------	
draw_STAT_maintext:    	ld		b,10
                        ld		hl,status_boiler_text
                        call	STAT_print_boiler_text
.PresentSystem:         ld      a,(Galaxy)       ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      bc, (PresentSystemX)
                        call    galaxy_name_at_bc
                        ld      de,stat_present_name
                        call    stat_copy_to_name:
                        ld      bc,present_position
                        ld      hl,stat_present_name
                        MMUSelectLayer2
                        ld      e,txt_status_colour
                        call    l2_print_at
.HyperspaceSystem:      ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      bc, (TargetPlanetX)
                        call    galaxy_name_at_bc
                        ld      de,stat_target_name
                        call    stat_copy_to_name:
                        ld      bc,hyperspace_position
                        ld      hl,stat_target_name
                        MMUSelectLayer2
                        ld      e,txt_status_colour
                        call    l2_print_at
.StatusText:	        call	get_cmdr_condition
                        ld		hl, ConditionNameIdx
                        call	getTableText
                        ld		bc,condition_position
                        MMUSelectLayer2
                        ld      e,txt_status_colour
                        call    l2_print_at
.DisplayFuel:           call	GetFuelLevel
                        ld		hl, txt_fuel_level
                        ld		a,(hl)
                        cp		'0'
                        jr		nz,.PrintFuel
.SkipLeadingZero:	    inc		hl
.PrintFuel:             ld		bc,fuel_position
                        MMUSelectLayer2
                        ld      e,txt_status_colour
                        call    l2_print_at
.DisplayCash:           call	STAT_GetCash
                        ld		bc,cash_position
                        ld		hl,STAT_cash_amount
                        MMUSelectLayer2
                        ld      e,txt_status_colour
                        call    l2_print_at
.PrintLegalStatus:      ld		a,(FugitiveInnocentStatus)
                        cp		0
                        jr		nz,.Naughty
                        ld		hl,WordClean
                        jr		.DisplayLegalStatus
.Naughty:               cp		50
                        jr		c,.JustOffender
.VeryNaughty:           ld		hl,WordFugitive
                        jr		.DisplayLegalStatus
.JustOffender:          ld		hl,WordOffender
.DisplayLegalStatus:    ld		bc,legal_status_position
                        MMUSelectLayer2
                        ld      e,txt_status_colour
                        call    l2_print_at
.DisplayRating:         ld		de,(KillTally)
                        call	getRankIndex
                        ld		hl, RankingNameIdx
                        call	getTableText
                        ld		bc,rank_position
                        MMUSelectLayer2
                        ld      e,txt_status_colour
                        call    l2_print_at
                        ret


draw_STAT_items:        MMUSelectLayer1
                        call    l1_cls
                        ; add in all the status stuff later
                        ld      a,(STAT_current_topItem)
                        ld      d,STAT_buffer_row_len
                        ld      e,a
                        mul
                        ld      hl,STAT_display_buffer
                        add     hl,de
                        ld      a,(STAT_current_topItem)
                        ld      b,a
                        ld      a,(STAT_current_end)
                        sub     b
                        JumpIfALTNusng  STAT_eqip_window_len, .FillScreen
.JustWindowing:         ld      b,STAT_eqip_window_len
                        jr      .ReadyToPrint
.FillScreen:            ld      b,a         ; the mumber of rows to display
.ReadyToPrint:          ld      de,STAT_position
.DrawARow:              push    de,, hl,, bc                  ; "l1 PrintAt, pixel row, whole char col, DE = yx, HL = message Addr"
                        call    l1_print_at:
                        pop     hl,,bc                      ; get mesage addr back and move down one line
                        ld      de,STAT_buffer_row_len
                        add     hl,de
                        pop     de                          ; get output row back
                        ld      a,8
                        add     a,d
                        ld      d,a
                        djnz    .DrawARow
                        ret

;----------------------------------------------------------------------------------------------------------------------------------	

get_cmdr_condition:     ld			a,(DockedFlag)
                        cp			PlayerDocked
                        jr			z,.PlayerIsDocked
.PlayerNotDocked:	    ld          a,(SpaceStationSafeZone)
                        cp          0
                        ret         z
                        ld          hl,UniverseSlotCount
                        ld          c,1
.CheckForShipsLoop:     ld          b,UniverseListSize
                        ld          a,(hl)
                        cp          0
                        jr          nz,.PlayerColour        ; TODO Need to refine to remove cargo, exploding ships and hull plate
                        inc         hl
                        djnz        .CheckForShipsLoop
.countShipsLoop:	    add			a,(hl)
                        inc			hl
                        djnz		.countShipsLoop
                        cp			0
                        ld          c,1
                        jr			z,.PlayerColour
.NoShipsAround:         ld			a,(PlayerEnergy)
                        cp			$80
                        ld          a,1
                        adc         1                                       ; add 1 + carry, if a < 128 then carry set so goes red
                        ret
.PlayerColour:          ld          a,c
                        ret
.PlayerIsDocked:        xor			a
                        ret

;;;PrintEquipment:         ld		a,(hl)
;;;                        cp		0
;;;                        ret		z
;;;                        ld		a,b
;;;PrintEquipmentDirect:	call	expandTokenToString
;;;                        ld		hl,TextBuffer
;;;                        ld		de,(equipment_cursor)
;;;                        call	l1_print_at
;;;                        ld		bc,(equipment_cursor)
;;;                        ld		a,b
;;;                        add		a,8
;;;                        ld		b,a
;;;                        ld		(equipment_cursor),bc
;;;                        cp		equipmax_row
;;;                        jr		c,.SkipColUpdate
;;;.ColUpdate:             ld		hl,equipment_position2
;;;                        ld		(equipment_cursor),hl
;;;                        ret
;;;.SkipColUpdate:	        ld		a,b
;;;                        ld		(equipment_cursor+1), a
;;;                        ret

draw_status_menu:       INCLUDE "Menus/clear_screen_inline_no_double_buffer.asm"	
                        ld		a,8
                        ld		(MenuIdMax),a	
.Drawbox:               ld		bc,$0101
                        ld		de,$BEFD
                        ld		a,$C0
                        MMUSelectLayer2    
                        call	l2_draw_box
                        ld		bc,$0A01
                        ld		de,$FEC0
                        call	l2_draw_horz_line
.equipment              call    STAT_buffer_list
                        call    draw_STAT_items
                        call    draw_STAT_maintext
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
; Handles all the input whilst in the market menu
loop_STAT_menu:         ld      a,c_Pressed_CursorUp  
                        call    is_key_pressed
                        call    z,STAT_UpPressed
                        ld      a,c_Pressed_CursorDown
                        call    is_key_pressed
                        call    z,STAT_DownPressed
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
STAT_UpPressed:         xor     a
                        ld      (STAT_selected_row),a
.check_scroll_up:       ld      a,(STAT_current_topItem)
                        cp      0
                        ret     z
                        dec     a           ; chjange later to buffering step back 1
                        ld      (STAT_current_topItem),a
                        call    draw_STAT_items
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
STAT_DownPressed:       ld      a,STAT_eqip_window_len-1
                        ld      (STAT_selected_row),a
                        ld      a,(STAT_current_end)
                        ld      b,a                             ; This check is if the current list is < one screen
                        dec     b
                        ld      a,(STAT_selected_row)
                        cp      b
                        ret     z
                        cp      STAT_eqip_window_len-1
                        jr      z, .check_scroll_down
                        ld      hl,STAT_selected_row
                        inc     (hl)                        
                        ret
.check_scroll_down:     ld      b,a
                        ld      a,(STAT_current_topItem)                      
                        add     b
                        inc     a
                        ld      hl,STAT_current_end
                        ReturnIfAGTEusng      (hl)
.can_scroll_down:       ld      hl,STAT_current_topItem
                        inc     (hl)
                        call    draw_STAT_items
                        ret
