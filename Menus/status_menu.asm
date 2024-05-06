status_page_marker  DB "Status      PG63"    

    DEFINE  LARGE_MENUS 1

txt_stat_commander 			DB "COMMANDER",0
txt_stat_inventory 			DB "INVENTORY",0
txt_stat_present_system		DB "Present System   :",0
txt_stat_hyperspace_system	DB "Hyperspace System:",0
txt_stat_condition			DB "Condition        :",0
txt_stat_fuel				DB "Fuel             :",0
txt_stat_cash				DB "Cash             :",0
txt_stat_legal_status		DB "Legal Status     :",0
txt_stat_rating				DB "Rating           :",0
txt_stat_missle_type        DB "Missile Type     :",0
txt_stat_missle_count       DB "Missile Count    :",0
txt_stat_equipment			DB "EQUIPMENT:",0

txt_stat_fuel_level			DB "00.0 Light Years",0
txt_stat_cash_amount		DB "XXXXXXXXXX",0
txt_stat_cash_decimal       DB "."
txt_stat_cash_fraction      DB "X Cr",0

; 01234567890123456789012345678901234567890
;0 
;1          COMMANDER <Comdr name>
;2
;3 
;4 Present System    :
;5 Hyperspace System :
;6 Condition         :
;7 Fuel              :
;8 Cash              :
;9 Legal Status      :
;0 Rating            :
;1
;2 Equipment:         
;3 >1:                 >2:
;4 >3:                 >4:
;5 >5:                 >6:
;6 >7:                 >8:
;7 >9:                 >10:
;8 >11:                >12:
;9 >13:                >14:
;0 >15:                >15:
;1 >17:                >18:
;2 >19:                >19:
;3 >21:                >20:
;4 >22:                >23:
;5 >23:                >24:
;6 >25:                >26:
;7 >25:                >26:
;8 >25:                >26:
;9 >27:                >28:

present_pos_row         equ $20
hyperspace_pos_row		equ	$28
condition_pos_row		equ	$30
fuel_pos_row			equ	$38
cash_pos_row			equ	$40
legal_status_pos_row	equ $48
rank_pos_row			equ $50
missile_type_row        equ $58
missile_count_row       equ $60 
equipment_pos_row		equ $68
equipment_list_row      equ $70
equipment1_pos_row		equ $78

present_pos_col         equ $00A0
hyperspace_pos_col    	equ	$00A0
hyperspace_position	    equ	$131B
condition_pos_col		equ	$00A0
fuel_pos_col			equ	$00A0
cash_pos_col			equ	$00A0
legal_status_pos_col	equ $00A0
rank_pos_col			equ $00A0
equipment1_pos_col		equ $0008
equipment2_pos_col		equ $0090

status_boiler_text		DW $0050: DB $08                 : DW txt_stat_commander             ; row
						DW $00A0: DB $08                 : DW CommanderName
						DW $0008: DB present_pos_row     : DW txt_stat_present_system
						DW $0008: DB hyperspace_pos_row  : DW txt_stat_hyperspace_system
						DW $0008: DB condition_pos_row   : DW txt_stat_condition
						DW $0008: DB fuel_pos_row        : DW txt_stat_fuel
						DW $0008: DB cash_pos_row        : DW txt_stat_cash
						DW $0008: DB legal_status_pos_row: DW txt_stat_legal_status
						DW $0008: DB rank_pos_row        : DW txt_stat_rating
						DW $0008: DB missile_type_row    : DW txt_stat_missle_type
						DW $0008: DB missile_count_row   : DW txt_stat_missle_count
						DW $0008: DB equipment_list_row  : DW txt_stat_equipment	
status_boiler_count     equ 12
equipment_cursor		DW  $0000

STAT_buffer_rows        EQU     128
STAT_buffer_row_len     EQU     20
STAT_eqip_window_len    EQU     26
STAT_display_buff_len   EQU     STAT_buffer_rows *   STAT_buffer_row_len
STAT_display_buffer:    DS      STAT_display_buff_len                     ; maxium of 128 items can be coded for
STAT_pos_row    		equ $58 
STAT_pos_col			equ $0040 
STAT_cash_amount    	DS 10
STAT_cash_UoM           DB " Cr",0

stat_present_name       DS  30
                        DB  0
stat_target_name        DS  30
                        DB  0
                        
stat_copy_to_name:      ld      hl,GalaxyExpandedName
                        ld      bc,30
                        ldir
                        ret
                        
menu_box_colour         equ $C0                        



	
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
                        ld      a,0                                         ; so it will still skip them on printing
                        ld      de, STAT_display_buff_len
                        call    memfill_dma                                 ; full buffer with ASCII 1 (unprintable character)
                        ld      hl,STAT_display_buffer+STAT_buffer_row_len-1
                        ld      de,STAT_buffer_row_len
                        ld      b,STAT_buffer_rows
                        ZeroA
.EoLLoop:               ld      (hl),a                                      ; fix all buffer lines with a null
                        add     hl,de
                        djnz    .EoLLoop
                        ld      ix,EquipmentFitted + STAT_First_Item        ; ix = equipment master table, ignore missiles
                        ld      iy,STAT_display_buffer                      ; iy = target buffer
                        ld      b,EQ_ITEM_COUNT - EQ_CARGO_BAY              ; we do not include Fuel and Missile counts
                        ld      c,0                                         ; Current Row
                        ld      e,STAT_First_Item
.ProcessRow:            ld      a,(ix+0)                                    ; Do we own one?
                        JumpIfAIsZero .NotFitted                            ; optimised check for EquipmentItemNotFitted
.OwnItem:               push    de,, iy,, ix,, bc
                        ld      hl,ShipEquipNameTable                       ; look up equipment name
                        ld      d,EquipNameTableRowLen                      ; ship equip name row length, e = current equip row
                        mul
                        add     hl,de                                       ; hl = dword list of work pointers
                        ld      de,iy                                       ; de = 0 column at current display buffer row
                        ld      a,'>'                                       ; all items are prefixed ">"
                        ld      (de),a                                      ; .
                        inc     de                                          ; .
                        call    STAT_expand_name                            ; expand name
                        pop     iy,,ix,,bc
                        ld      de,STAT_buffer_row_len
                        add     iy,de                                       ; now iy = start of next column
                        pop     de
                        inc     c
.NotFitted:
.DoneFittedCheck:       inc     ix                        
                        inc     e
                        djnz    .ProcessRow
                        ret
                        
;----------------------------------------------------------------------------------------------------------------------------------
;">print_boilder_text ix = text structure, b = message count"
draw_STAT_boilertext:   ld		b,status_boiler_count
                        ld		ix,status_boiler_text
.BoilerTextLoop:        push	bc			; Save Message Count loop value
                        ld		l,(ix+0)	; Get col into hl
                        ld		h,(ix+1)	; 
                        ld		b,(ix+2)	; get row into b
                        ld		e,(ix+3)	; Get text address into hl
                        ld		d,(ix+4)	; .
                        push    ix          ; save ix and prep for add via hl
                        print_msg_at_de_at_b_hl_macro txt_status_colour
                        pop     hl          ; add 5 to ix
                        ld      a,5         ; .
                        add     hl,a        ; .
                        ld      ix,hl       ; .
                        pop		bc
                        djnz	.BoilerTextLoop
                        ret
                          
GetStatFuelLevel:       INCLUDE "Menus/get_fuel_level_inlineinclude.asm"

;----------------------------------------------------------------------------------------------------------------------------------	
draw_STAT_maintext:    	call    draw_STAT_boilertext
.PresentSystem:         ld      a,(Galaxy)       ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      bc, (PresentSystemX)
                        call    galaxy_name_at_bc
                        ld      de,stat_present_name
                        call    stat_copy_to_name
                        MMUSelectLayer2
                        print_msg_macro txt_status_colour,  present_pos_row,  present_pos_col,  stat_present_name
.HyperspaceSystem:      ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      bc, (TargetSystemX)
                        call    galaxy_name_at_bc
                        ld      de,stat_target_name
                        call    stat_copy_to_name:
                        MMUSelectLayer2
                        print_msg_macro txt_status_colour,  hyperspace_pos_row,  hyperspace_pos_col,  stat_target_name
.StatusText:	        call	get_cmdr_condition
                        ld		hl, ConditionNameIdx
                        call	getTableText
                        ex      hl,de
                        print_msg_at_de_macro txt_status_colour,  condition_pos_row,  condition_pos_col
.DisplayFuel:           call	GetStatFuelLevel
                        ld		hl, txt_fuel_level
                        ld		a,(hl)
                        cp		'0'
                        jr		nz,.PrintFuel
.SkipLeadingZero:	    inc		hl
                        ex      de,hl
.PrintFuel:             print_msg_at_de_macro txt_status_colour,  fuel_pos_row,  fuel_pos_col
.DisplayCash:           call	STAT_GetCash
                        print_msg_macro txt_status_colour,  cash_pos_row,  cash_pos_col,  STAT_cash_amount
.PrintLegalStatus:      ld		a,(FugitiveInnocentStatus)
                        cp		0
                        jr		nz,.Naughty
                        ld		de,WordClean
                        jr		.DisplayLegalStatus
.Naughty:               cp		50
                        jr		c,.JustOffender
.VeryNaughty:           ld		de,WordFugitive
                        jr		.DisplayLegalStatus
.JustOffender:          ld		de,WordOffender
.DisplayLegalStatus:    print_msg_at_de_macro txt_status_colour,  legal_status_pos_row,  legal_status_pos_col
.DisplayRating:         ld      a,(CurrentRank)
                        ; now cached ld		de,(KillTally)
                        ; now cached call	getRankIndex
                        ld		hl, RankingNameIdx
                        call	getTableText
                        ex      de,hl
                        print_msg_at_de_macro txt_status_colour,  rank_pos_row,  rank_pos_col
                        ret
; Draw items on 320 mode, max 28 items 14 per column

draw_STAT_items:        MMUSelectLayer2
                        ld      hl,STAT_display_buffer                      ; hl = pointer to first item in display
.ReadyToPrint:          ex      de,hl                                       ; de = message to print
                        ld      hl,equipment1_pos_col                       ; hl = column
                        ld      b,equipment1_pos_row                        ; b = row for first line
.CheckIfPrintable:      ld      a,(de)                                      ; if its not a lead ">" then we have run out
                        cp      '>'
                        ret     nz
.DrawARow:              push    de,,hl,,bc                                  ; Save vars 
                        print_msg_at_de_at_b_hl_macro txt_status_colour     ; Print text at row b col hl
                        pop     de,,hl,,bc                                  ; get back row and column, we don't change column for now
                        ld      a,l
                        cp      equipment1_pos_col
                        jp      z,.MoveRight
.DownOneLeft:           ld      hl,equipment1_pos_col
                        ld      a,8
                        add     a,b
                        ld      b,a
                        jp      .nextBufferItem
.MoveRight:             ld      hl,equipment2_pos_col      
.nextBufferItem:        ld      a,STAT_buffer_row_len                       ; nbr characters per message
                        ex      de,hl
                        add     hl,a 
                        ex      de,hl
                        jp      .CheckIfPrintable


;----------------------------------------------------------------------------------------------------------------------------------	

get_cmdr_condition:     ld			a,(DockedFlag)
                        cp			StatePlayerDocked
                        jr			z,.PlayerIsDocked
.PlayerNotDocked:	    ReturnIfMemTrue    SpaceStationSafeZone
                        call        AreShipsPresent
                        jr          c,.NoShipsAround
                        ld          a,1
                        ret
.NoShipsAround:         ld			a,(PlayerEnergy)
                        cp			$80
                        ld          a,1
                        adc         1                                       ; add 1 + carry, if a < 128 then carry set so goes red
                        ret
.PlayerIsDocked:        xor			a
                        ret

draw_status_menu:       MMUSelectLayer1
                        call	l1_cls
                        ld		a,7
                        call	l1_attr_cls_to_a
                        MMUSelectLayer2
                        call    l2_320_initialise
                        call    asm_l2_double_buffer_off    
                        call    l2_320_cls
                        MMUSelectSpriteBank
                        call    sprite_cls_cursors
                        MMUSelectLayer2
.Drawbox:               call    l2_draw_menu_border
                        ld		a,8
                        ld		(MenuIdMax),a	
                        ld      b,$17
                        ld      hl,1
                        ld      de,320-4
                        ld      c,$C0
                        call    l2_draw_horz_line_320           ;b = row; hl = col, de = length, c = color"
                        ld      b,$6C
                        ld      hl,1
                        ld      de,320-4
                        ld      c,$C0
                        call    l2_draw_horz_line_320           ;b = row; hl = col, de = length, c = color"
                        call    draw_STAT_maintext
                        
.equipment              call    STAT_buffer_list
                        call    draw_STAT_items
                        
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
; Handles all the input whilst in the market menu
loop_STAT_menu:         ;MacroIsKeyPressed c_Pressed_CursorUp  
                        ;call    z,STAT_UpPressed
                        ;MacroIsKeyPressed c_Pressed_CursorDown
                        ;call    z,STAT_DownPressed
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
;STAT_UpPressed:         xor     a
;                        ld      (STAT_selected_row),a
;.check_scroll_up:       ld      a,(STAT_current_topItem)
;                        cp      0
;                        ret     z
;                        dec     a           ; chjange later to buffering step back 1
;                        ld      (STAT_current_topItem),a
;                        call    draw_STAT_items
;                        call    draw_STAT_boilertext
;                        ret
;----------------------------------------------------------------------------------------------------------------------------------
;STAT_DownPressed:       ld      a,STAT_eqip_window_len-1
;                        ld      (STAT_selected_row),a
;                        ld      a,(STAT_current_end)
;                        ld      b,a                             ; This check is if the current list is < one screen
;                        dec     b
;                        ld      a,(STAT_selected_row)
;                        cp      b
;                        ret     z
;                        cp      STAT_eqip_window_len-1
;                        jr      z, .check_scroll_down
;                        ld      hl,STAT_selected_row
;                        inc     (hl)                        
;                        ret
;.check_scroll_down:     ld      b,a
;                        ld      a,(STAT_current_topItem)                      
;                        add     b
;                        inc     a
;                        ld      hl,STAT_current_end
;                        ReturnIfAGTEusng      (hl)
;.can_scroll_down:       ld      hl,STAT_current_topItem
;                        inc     (hl)
;                        call    draw_STAT_items
;                        call    draw_STAT_boilertext
;                        ret
    
