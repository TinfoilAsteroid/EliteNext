print_msg_at_de_macrostatus_page_marker  DB "Status      PG63"    

draw_stat_menu:               jp draw_status_menu

close_stat_data:              ret

update_stat_data:             ret
;----------------------------------------------------------------------------------------------------------------------------------
STAT_copy_str_hl_to_de: ld      a,(hl)
                        ld      (de),a
                        inc     hl
                        inc     de
                        and     a                               ; check if we wrote a \0 if so then done
                        jp      nz,STAT_copy_str_hl_to_de
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
STAT_get_current_name:  ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        call    GalaxyDigramWorkings       ; we have galaxy working seed populated now
                        ld      hl,GalaxyExpandedName
                        call    CapitaliseString
                        ld      hl, GalaxyExpandedName
                        ld      a,$FF                        
                        ld      de,sdm_system_title
                        call    STAT_copy_str_hl_to_de
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
;">print_boilder_text ix = text structure, b = message count"
STAT_print_boiler_text:  
.BoilerTextLoop:        push        bc          ; Save Message Count loop value
                        ld          b,(ix+0)    ; get row into b
                        ld          de,(ix+1)   ; get column into hl (as we can't load direct to hl from ix)
                        ex          de,hl       ;
                        ld          c,(ix+3)    ; c = colour
                        ld          de,(ix+4)   ; de = address of message
                        push        ix
                        MMUSelectLayer2
                        call        l2_print_at_320
                        pop         hl          ; move ix on to next string if needed
                        ld          a,6         ;
                        add         hl,a        ;
                        ld          ix,hl       ;
                        pop         bc          ; remainder of lines in loop
                        djnz        .BoilerTextLoop
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
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

;----------------------------------------------------------------------------------------------------------------------------------	
    DISPLAY "TODO GetStatMissileCount:    ld      a,("
;----------------------------------------------------------------------------------------------------------------------------------	
GetStatFuelLevel:       ld		a,(Fuel)
                        ld		de,txt_fuel_level
                        ld	c, -100
                        call	.Num1
                        ld	c,-10
                        call	.Num1
                        ld	c,-1
.Num1:	                ld	b,'0'-1
.Num2:	                inc		b
                        add		a,c
                        jr		c,.Num2
                        sub 	c
                        push	bc
                        push	af
                        ld		a,c
                        cp		-1
                        call	z,.InsertDot
                        ld		a,b
                        ld		(de),a
                        inc		de
                        pop		af
                        pop		bc
                        ret 
.InsertDot:             ld		a,'.'
                        ld		(de),a
                        inc		de
                        ret
;----------------------------------------------------------------------------------------------------------------------------------	
draw_STAT_maintext:    	
.PresentSystem:         ld      a,(Galaxy)       ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      bc, (PresentSystemX)
                        call    galaxy_name_at_bc
                        ld      de,stat_present_name
                        call    stat_copy_to_name
.HyperspaceSystem:      ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      bc, (TargetSystemX)
                        call    galaxy_name_at_bc
                        ld      de,stat_target_name
                        call    stat_copy_to_name:
.StatusText:	        call	get_cmdr_condition
                        ld		hl, ConditionNameIdx
                        call	getTableText
                        ld      de,txt_stat_condition_val
                        call    STAT_copy_str_hl_to_de
.DisplayFuel:           call	GetStatFuelLevel
                        ld		hl, txt_fuel_level
                        ld		a,(hl)
                        cp		'0'
                        jr		nz,.DoneFuel
.SkipLeadingZero:	    inc		hl
                        ex      de,hl
.DoneFuel:
.DisplayCash:           call	STAT_GetCash
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
.DisplayLegalStatus:    ld      de,txt_stat_legal_status_val
                        call    STAT_copy_str_hl_to_de
.DisplayRating:         ld      a,(CurrentRank)
                        ; now cached ld		de,(KillTally)
                        ; now cached call	getRankIndex
                        ld		hl, RankingNameIdx
                        call	getTableText
                        ld      de,txt_stat_rank_val
                        call    STAT_copy_str_hl_to_de
                        ld      b,17
                        ld      ix,status_boiler_text
                        call    STAT_print_boiler_text
                        ret
; Draw items on 320 mode, max 28 items 14 per column
STAT_First_Item         EQU     EQ_CARGO_BAY
STAT_buffer_list:       ld      hl,txt_equipment_01                         ; hl - target buffer
.ZeroBuffer:            ld      a,0                                         ; so it will still skip them on printing
                        ld      de, 20*19
                        call    memfill_dma                                 ; full buffer with ASCII 1 (unprintable character)
                        MMUSelectEquipmentTables                            ; bring in equipment tables for lookups
.StartFetching:         ld      iy,txt_equipment_01                         ; Target to copy to
                        ld      ix,EquipmentFitted + STAT_First_Item        ; ix = equipment master table, ignore missiles
                        ld      b,EQ_ITEM_COUNT - EQ_CARGO_BAY              ; we do not include Fuel and Missile counts
.ProcessRow:            ld      a,(ix+0)                                    ; Do we own one? (if so a will be non 0)
                        JumpIfAIsZero .NotFitted                            ; optimised check for EquipmentItemNotFitted
.OwnItem:               push    bc
                        ld      hl,EquipNameIndex                           ; look up equipment name
                        ld      a,b                                         ; hl += index * 2 for address
                        sla     a                                           ;
                        add     hl,a                                        ;
                        ld      a,(hl)                                      ; hl = pointer to name
                        inc     hl
                        ld      h,(hl)                                      ;
                        ld      l,a                                         ;
                        ld      de,iy                                       ; de = target buffer
                        call    STAT_copy_str_hl_to_de
                        DISPLAY "TODO - rewrite for all weapon types and set colour as per status"
                        ld      de,txt_equipment_len                        ; move to next output slot
                        add     iy,de                                       ;
                        pop     bc                        
.NotFitted:
.DoneFittedCheck:       inc     ix                                          ; move to next equipment slot
                        djnz    .ProcessRow
                        ret

; Loop through invetory displaying all items equipped
;draw_STAT_items:        
;
;
;MMUSelectLayer2
;                        ld      hl,STAT_display_buffer                      ; hl = pointer to first item in display
;.ReadyToPrint:          ex      de,hl                                       ; de = message to print
;                        ld      hl,equipment1_pos_col                       ; hl = column
;                        ld      b,equipment1_pos_row                        ; b = row for first line
;.CheckIfPrintable:      ld      a,(de)                                      ; if its not a lead ">" then we have run out
;                        cp      '>'
;                        ret     nz
;.DrawARow:              push    de,,hl,,bc                                  ; Save vars 
;                        print_msg_at_de_at_b_hl_macro txt_status_colour     ; Print text at row b col hl
;                        pop     de,,hl,,bc                                  ; get back row and column, we don't change column for now
;                        ld      a,l
;                        cp      equipment1_pos_col
;                        jp      z,.MoveRight
;.DownOneLeft:           ld      hl,equipment1_pos_col
;                        ld      a,8
;                        add     a,b
;                        ld      b,a
;                        jp      .nextBufferItem
;.MoveRight:             ld      hl,equipment2_pos_col      
;.nextBufferItem:        ld      a,STAT_buffer_row_len                       ; nbr characters per message
;                        ex      de,hl
;                        add     hl,a 
;                        ex      de,hl
;                        jp      .CheckIfPrintable


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
                        call    asm_l2_double_buffer_off    
                        call    l2_320_initialise
                        call    l2_320_cls
                        MMUSelectSpriteBank
                        call    sprite_cls_all
                        MMUSelectLayer2
.Drawbox:               call    l2_draw_menu_border
                        ld		a,8
                        ld		(MenuIdMax),a	
                        ld      b,$17
                        ld      hl,1
                        ld      de,320-4
                        ld      c,$C0
                       ; call    l2_draw_horz_line_320           ;b = row; hl = col, de = length, c = color"
                        ld      b,$6C
                        ld      hl,1
                        ld      de,320-4
                        ld      c,$C0
                        call    l2_draw_horz_line_320           ;b = row; hl = col, de = length, c = color"
                        call    draw_STAT_maintext
                        break
.equipment              call    STAT_buffer_list
                        ld      b,19
                        ld      ix,status_equipment_list
                        break
                        ;call    draw_STAT_items
                        call    STAT_print_boiler_text
                        ret

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

present_pos_row         equ 16
hyperspace_pos_row		equ	present_pos_row       +10
condition_pos_row		equ	+hyperspace_pos_row	  +10
fuel_pos_row			equ	condition_pos_row	  +10
cash_pos_row			equ	fuel_pos_row		  +10
legal_status_pos_row	equ cash_pos_row		  +10
rank_pos_row			equ legal_status_pos_row  +10
missile_type_row        equ rank_pos_row		  +10
missile_count_row       equ missile_type_row      +10
equipment_pos_row		equ missile_count_row     +10
equipment_list_row      equ equipment_pos_row	  +10
equipment1_pos_row		equ equipment_list_row    +10
equipment2_pos_row      equ equipment1_pos_row    + 8
equipment3_pos_row      equ equipment2_pos_row    + 8
equipment4_pos_row      equ equipment3_pos_row    + 8
equipment5_pos_row      equ equipment4_pos_row    + 8
equipment6_pos_row      equ equipment5_pos_row    + 8
equipment7_pos_row      equ equipment6_pos_row    + 8
equipment8_pos_row      equ equipment7_pos_row    + 8
equipment9_pos_row      equ equipment8_pos_row    + 8
equipment10_pos_row     equ equipment9_pos_row    + 8

status_boiler_text		DB $02                  , low $0050, high $0050, $FF, low txt_stat_commander         , high txt_stat_commander            
						DB $02                  , low $00A0, high $00A0, $FF, low CommanderName              , high CommanderName
						DB present_pos_row      , low $0008, high $0008, $FF, low txt_stat_present_system    , high txt_stat_present_system
						DB hyperspace_pos_row   , low $0008, high $0008, $FF, low txt_stat_hyperspace_system , high txt_stat_hyperspace_system
						DB condition_pos_row    , low $0008, high $0008, $FF, low txt_stat_condition         , high txt_stat_condition
						DB fuel_pos_row         , low $0008, high $0008, $FF, low txt_stat_fuel              , high txt_stat_fuel
						DB cash_pos_row         , low $0008, high $0008, $FF, low txt_stat_cash              , high txt_stat_cash
						DB legal_status_pos_row , low $0008, high $0008, $FF, low txt_stat_legal_status      , high txt_stat_legal_status
						DB rank_pos_row         , low $0008, high $0008, $FF, low txt_stat_rating            , high txt_stat_rating
						DB missile_type_row     , low $0008, high $0008, $FF, low txt_stat_missle_type       , high txt_stat_missle_type
						DB missile_count_row    , low $0008, high $0008, $FF, low txt_stat_missle_count      , high txt_stat_missle_count
						DB condition_pos_row    , low $00A0, high $00A0, $FF, low txt_stat_condition_val     , high txt_stat_condition_val
                        DB fuel_pos_row         , low $00A0, high $00A0, $FF, low txt_stat_fuel_level        , high txt_stat_fuel_level
                        DB cash_pos_row         , low $00A0, high $00A0, $FF, low STAT_cash_amount           , high STAT_cash_amount    
                        DB legal_status_pos_row , low $00A0, high $00A0, $FF, low txt_stat_legal_status_val  , high txt_stat_legal_status_val
                        DB rank_pos_row         , low $00A0, high $00A0, $FF, low txt_stat_rank_val          , high txt_stat_rank_val
                        DB equipment_list_row   , low 008, high 008, $FF, low txt_stat_equipment	     , high txt_stat_equipment
status_equipment_list:  DB equipment1_pos_row   , low 008, high 008, $FF, low txt_equipment_01           , high txt_equipment_01
                        DB equipment1_pos_row   , low 160, high 160, $FF, low txt_equipment_02           , high txt_equipment_02
                        DB equipment2_pos_row   , low 008, high 008, $FF, low txt_equipment_03           , high txt_equipment_03
                        DB equipment2_pos_row   , low 160, high 160, $FF, low txt_equipment_04           , high txt_equipment_04
                        DB equipment3_pos_row   , low 008, high 008, $FF, low txt_equipment_05           , high txt_equipment_05
                        DB equipment3_pos_row   , low 160, high 160, $FF, low txt_equipment_06           , high txt_equipment_06
                        DB equipment4_pos_row   , low 008, high 008, $FF, low txt_equipment_07           , high txt_equipment_07
                        DB equipment4_pos_row   , low 160, high 160, $FF, low txt_equipment_08           , high txt_equipment_08
                        DB equipment5_pos_row   , low 008, high 008, $FF, low txt_equipment_09           , high txt_equipment_09
                        DB equipment5_pos_row   , low 160, high 160, $FF, low txt_equipment_10           , high txt_equipment_10
                        DB equipment6_pos_row   , low 008, high 008, $FF, low txt_equipment_11           , high txt_equipment_11
                        DB equipment6_pos_row   , low 160, high 160, $FF, low txt_equipment_12           , high txt_equipment_12
                        DB equipment7_pos_row   , low 008, high 008, $FF, low txt_equipment_13           , high txt_equipment_13
                        DB equipment7_pos_row   , low 160, high 160, $FF, low txt_equipment_14           , high txt_equipment_14
                        DB equipment8_pos_row   , low 008, high 008, $FF, low txt_equipment_15           , high txt_equipment_15
                        DB equipment8_pos_row   , low 160, high 160, $FF, low txt_equipment_16           , high txt_equipment_16
                        DB equipment9_pos_row   , low 008, high 008, $FF, low txt_equipment_17           , high txt_equipment_17
                        DB equipment9_pos_row   , low 160, high 160, $FF, low txt_equipment_18           , high txt_equipment_18
                        DB equipment10_pos_row  , low 008, high 008, $FF, low txt_equipment_19           , high txt_equipment_19
                        
    DISPLAY "TODO - IN ALL MENUS INITIALISE BOILER TEXT TO BLANKS IN CASE REDISPLAY IS POST A STATUS CHANGE"                        
status_boiler_count     equ 12

txt_stat_commander 			DB "COMMANDER",0
txt_stat_inventory 			DB "INVENTORY",0
txt_stat_present_system		DB "Present System   : "
stat_present_name           DS  30, 0
txt_stat_hyperspace_system	DB "Hyperspace System: "
stat_target_name            DS  30, 0
txt_stat_condition			DB "Condition        :",0
txt_stat_fuel				DB "Fuel             :",0
txt_stat_cash				DB "Cash             :",0
txt_stat_legal_status		DB "Legal Status     :",0
txt_stat_rating				DB "Rating           :",0
txt_stat_missle_type        DB "Missile Type     :",0
txt_stat_missle_type_val    DS 20,0
txt_stat_missle_count       DB "Missile Count    :",0
txt_stat_missle_count_val   DS 20,0
txt_stat_equipment			DB "EQUIPMENT:",0

txt_stat_fuel_level			DB "00.0 Light Years",0
txt_stat_cash_amount		DB "XXXXXXXXXX",0
txt_stat_cash_decimal       DB "."
txt_stat_cash_fraction      DB "X Cr",0
txt_stat_condition_val       DS 20,0
txt_stat_legal_status_val   DS 20,0
txt_stat_rank_val           DS 20,0

txt_equipment_01            DS 20,0
txt_equipment_len           EQU $ - txt_equipment_01
txt_equipment_02            DS 20,0
txt_equipment_03            DS 20,0
txt_equipment_04            DS 20,0
txt_equipment_05            DS 20,0
txt_equipment_06            DS 20,0
txt_equipment_07            DS 20,0
txt_equipment_08            DS 20,0
txt_equipment_09            DS 20,0
txt_equipment_10            DS 20,0
txt_equipment_11            DS 20,0
txt_equipment_12            DS 20,0
txt_equipment_13            DS 20,0
txt_equipment_14            DS 20,0
txt_equipment_15            DS 20,0
txt_equipment_16            DS 20,0
txt_equipment_17            DS 20,0
txt_equipment_18            DS 20,0
txt_equipment_19            DS 20,0


STAT_buffer_rows        EQU     128
STAT_buffer_row_len     EQU     20
STAT_eqip_window_len    EQU     26
STAT_display_buff_len   EQU     STAT_buffer_rows *   STAT_buffer_row_len
STAT_display_buffer:    DS      STAT_display_buff_len                     ; maxium of 128 items can be coded for
STAT_pos_row    		equ $58 
STAT_pos_col			equ $0040 
STAT_cash_amount    	DS 10
STAT_cash_UoM           DB " Cr",0

                        
stat_copy_to_name:      ld      hl,GalaxyExpandedName
                        ld      bc,30
                        ldir
                        ret
                        
menu_box_colour         equ $C0                        




	