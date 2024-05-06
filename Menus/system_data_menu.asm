system_data_page_marker DB "System      PG53"      

GovernmentIndexOffset	EQU 75
SDM_system_pos_row      EQU $08
SDM_distance_pos_row    EQU $1B
SDM_Economy_pos_row     EQU $23
SDM_gov_pos_row         EQU $2B
SDM_tech_level_pos_row	EQU $33
SDM_population_pos_row  EQU $3B
SDM_species_pos_row     EQU $43
SDM_UoM_pos_row         EQU $2B
SDM_prod_pos_row        EQU $53
SDM_radius_pos_row      EQU $5B
SDM_desc_pos_row        EQU $6B
SDM_dtxt_pos_row        EQU $7B

SDM_system_pos_col      EQU $0008
SDM_distance_pos_col    EQU $0060
SDM_gov_pos_col	        EQU $0060
SDM_tech_level_pos_col	EQU $0060
SDM_species_pos_col     EQU $0060
SDM_population_pos_col  EQU $0060
SDM_prod_pos_col        EQU $00A0
SDM_radius_pos_col      EQU $00A0
SDM_desc_pos_col        EQU $0008
SDM_economy_pos_col     EQU $0060

plant_boiler_text		DW $0040 : DB $02 : DW TextBuffer
						DW $0080 : DB $02 : DW name_expanded
						DW $0008 : DB $1B : DW WordDistance
						DW $0008 : DB $23 : DW WordEconomy
						DW $0008 : DB $2B : DW WordGovernment
						DW $0008 : DB $33 : DW WordTechLevel
						DW $0008 : DB $3B : DW WordPopulation
                        DW $0008 : DB $43 : DW WordSpecies
						DW $0008 : DB SDM_prod_pos_row : DW WordGross
						DW $0038 : DB SDM_prod_pos_row : DW WordProductivity
						DW $0008 : DB SDM_radius_pos_row : DW WordAverage	
						DW $0048 : DB SDM_radius_pos_row : DW WordRadius
                        DW $0008 : DB SDM_desc_pos_row   : DW WordDescription
                        
planet_zero_dist		DW $0B60,TextBuffer
planet_economy_disp		DW $1360,TextBuffer
techlevel_value			DB 10,0
distance_value          DS 20,0
distance_uom            DB " Light Years",0
radius_value            DS 20
                        DB 0
radius_uom              DB " km",0
population_value        DS 20
                        DB 0
population_uom          DB " Billion",0
productivity_value      DS 20
                        DB 0
productivity_uom        DB " M CR",0



system_present_or_target DB 0
saved_present			 DW 0


SD_present_name         DS  30
                        DB  0
SD_target_name          DS  30
                        DB  0
SD_species              DS 30
                        DB 0                      
SD_planet_description   DS 300,0

SDDisplayGovernment     DB 0
SDDisplayEconomy        DB 0
SDDisplayTekLevel       DB 0
SDDisplayPopulation     DB 0
SDDisplayProductivity   DW 0
SDDisplayRadius         DW 0
SDDataLength            EQU $ - SDDisplayEconomy
                        
SD_copy_system_data:    ld      hl,GalaxyDisplayGovernment
                        ld      de,SDDisplayGovernment
                        ld      bc,SDDataLength 
                        ldir
.DisplayTechPlus1:      ld     hl,SDDisplayTekLevel
                        inc    (hl)
                        ret

SD_copy_to_name:        ld      hl,GalaxyExpandedName
                        ld      bc,30
                        ldir
                        ret
    
SD_copy_species:        ld      hl,GalaxySpecies
                        ld      de,SD_species
                        ld      bc,30
                        ldir
                        ret
    
SD_copy_description:    ld      hl,GalaxyPlanetDescription
                        ld      de,SD_planet_description
SDCopyLoop:             ld      a,(hl)
                        cp      0
                        jr      z,.SD_Copy_Done
                        ldi
                        jp      SDCopyLoop
.SD_Copy_Done:          ld      (de),a
                        ret
    
SDM_DispAtoDE:          ld h,0
                        ld l,a
                        ld	bc,-10000
                        call	.Num1
                        ld	bc,-1000
                        call	.Num1
                        ld	bc,-100
                        call	.Num1
                        ld	c,-10
                        call	.Num1
                        ld	c,-1
.Num1:	                ld	a,'0'-1
.Num2:	                inc	a
                        add	hl,bc
                        jr	c,.Num2
                        sbc	hl,bc
                        ld	(de),a
                        inc	de
                        ret 


sdm_calc_distance:      ld      a,(Galaxy)
                        MMUSelectGalaxyA 
                        ld      bc,(PresentSystemX)
                        ld      (GalaxyPresentSystem),bc
                        ld      bc,(SD_working_cursor)
                        ld      (GalaxyDestinationSystem),bc
                        call    galaxy_find_distance            ; get distance into HL
.done_number:           ret

;----------------------------------------------------------------------------------------------------------------------------------
;">print_boilder_text ix = text structure, b = message count"
SDM_print_boiler_text:  ld		b,13
                        ld		ix,plant_boiler_text
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

PlanetLeftJustifyLoop:  ld      a,(hl)
                        cp      "0"
                        ret      nz
                        inc     hl
                        djnz    PlanetLeftJustifyLoop
                        ret
    
SD_working_cursor       DW   0    

sd_copy_of_seed         DS 6
    
draw_system_data_menu:  MMUSelectLayer1
                        call	l1_cls
                        ld		a,7
                        call	l1_attr_cls_to_a
                        MMUSelectLayer2
                        call    asm_l2_double_buffer_off    
                        call    l2_320_initialise
                        call    l2_320_cls
                        MMUSelectSpriteBank
                        call    sprite_cls_cursors
                        MMUSelectLayer2
.Drawbox:               call    l2_draw_menu_border
                        ld      b,$17
                        ld      hl,1
                        ld      de,320-4
                        ld      c,$C0
                        call    l2_draw_horz_line_320           ;b = row; hl = col, de = length, c = color"
.DescHorzLine:          ld      b,SDM_desc_pos_row -4
                        ld      hl,1
                        ld      de,320-4
                        ld      c,$C0
                        call    l2_draw_horz_line_320 
.PrintBoiler:           call	SDM_print_boiler_text
                        ZeroA
                        ld      (system_present_or_target),a
                        ld		a,8
                        ld		(MenuIdMax),a	
.SelectGalaxy:          ld      a,(Galaxy)
                        MMUSelectGalaxyA
.CheckCursorOrHome:     ld      bc,(TargetSystemX)              ; Find out if we have to work on hyperspace or normal cursor
                        ld      (SD_working_cursor),bc
                        ld      (GalaxyTargetSystem),bc
                        call    galaxy_system_under_cursor
.IsCursorOnSystem:      cp      $FF                               ; if a = 0 then failed
                        jr      z,.FoundASystem
.UsePresentSystem:      ld      bc,(PresentSystemX)
                        ld      (SD_working_cursor),bc
                        ld      (GalaxyTargetSystem),bc
                        call    galaxy_system_under_cursor
.FoundASystem:          ld      bc,(TargetSystemX)
                        ld      hl,(PresentSystemX)
                        ld      a,b
                        cp      h
                        jr      nz,.DiffCoord
                        ld      a,c
                        cp      l
                        jr      z,.SameCoord
.DiffCoord:             ld      a,$FF
                        ld      (system_present_or_target),a
.SameCoord:             ld      hl,WorkingSeeds            ; found a system so save it
                        ld      de,sd_copy_of_seed
                        call    galaxy_copy_seed
.GetSystemName:         call    GalaxyDigramWorkings       ; we have galaxy working seed populated now
.ExpandStatic:          ld		a,14
                        call	expandTokenToString
.TargetSystem:          ld      a,(Galaxy)                  ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      bc, (SD_working_cursor)
                        ld      hl,sd_copy_of_seed
                        ld      de,GalaxyWorkingSeed
                        call    galaxy_copy_seed
                        call    galaxy_planet_data                              ; Geneate galaxy data from working seed 
                        call    SD_copy_system_data
                        ld      de,name_expanded
                        call    SD_copy_to_name:
                        ld      de,hyperspace_position
                        ld      hl,name_expanded
                        MMUSelectLayer2
                        print_msg_macro txt_status_colour,  SDM_system_pos_row,  SDM_system_pos_col,  name_expanded
                        
.CalcDistance:          ld		a,(system_present_or_target)
                        cp		0
                        jr		z,.ZeroDistance
.NotZero:               call    sdm_calc_distance
.DisplayDistance:       ld      ix,(Distance)
                        ld      de,0
                        ld      iy,distance_value
                        call    DispDEIXtoIY1DP
.AddDistUo              push    iy
                        pop     hl
                        inc     hl
                        ld      de,distance_uom
                        call    SDTackOnUOMtoHL
.displayDistance:       MMUSelectLayer2
                        print_msg_macro txt_status_colour,  SDM_distance_pos_row,  SDM_distance_pos_col,  TextBuffer
                        jp      .DisplayEconomy
.ZeroDistance:          ld		a,24						; print literal zero dist
                        call	expandTokenToString
                        MMUSelectLayer2
                        print_msg_macro txt_status_colour,  SDM_distance_pos_row,  SDM_distance_pos_col,  TextBuffer
.DisplayEconomy:        ld		a,(SDDisplayEconomy)
                        add     a,TextEconomyOffset
                        call	expandTokenToString
                        ex      de,hl
                        MMUSelectLayer2
                        print_msg_macro txt_status_colour,  SDM_Economy_pos_row,  SDM_economy_pos_col,  TextBuffer; ,  planet_economy_disp
.DisplayGovernment:     ld		a,(SDDisplayGovernment)
                        add		a,TextGovOffset
                        call	WordIndexToAddress
                        ex      de,hl
                        MMUSelectLayer2
                        print_msg_at_de_macro txt_status_colour,  SDM_gov_pos_row,  SDM_gov_pos_col;,  GovernmentScreenPos
.DisplayTechLevel:      ld		a,(SDDisplayTekLevel)
                        ld		de,techlevel_value
                        call    SDM_DispAtoDE
                        xor     a
                        ld      (de),a
                        ld      hl,techlevel_value
                        ld      b,5
                        call    PlanetLeftJustifyLoop
                        MMUSelectLayer2
                        print_msg_macro txt_status_colour,  SDM_tech_level_pos_row,  SDM_tech_level_pos_col,  techlevel_value
.DisplayPopulation:     ld      a,(SDDisplayPopulation)
                        ld      ixh,0
                        ld      ixl,a
                        ld      de,0
                        ld      iy,population_value
                        call    DispDEIXtoIY1DP
.AddUoM:                push    iy
                        pop     hl
                        inc     hl
                        ld      de,population_uom
                        call    SDTackOnUOMtoHL
                        ld      de,$2B60
                        ld      hl,population_value
                        MMUSelectLayer2
                        print_msg_macro txt_status_colour,  SDM_population_pos_row,  SDM_population_pos_col,  population_value
;SDDisplayPopulation     DB 0
.DisplayPopulationType: ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        call    galaxy_get_species
                        call    SD_copy_species
                        MMUSelectLayer2
                        print_msg_macro txt_status_colour,  SDM_species_pos_row,  SDM_species_pos_col,  SD_species
.DisplayProductivity:   ld      hl,(SDDisplayProductivity)
                        push    hl
                        pop     ix
                        ld      de,0
                        ld      iy,productivity_value
                        call    DispDEIXtoIY
.AddProdUoM:            ;break
                        push    iy
                        pop     hl
                        ;inc     hl
                        ld      de,productivity_uom
                        call    SDTackOnUOMtoHL
                        ld      de,$3BA0
                        ld      hl,productivity_value
                        MMUSelectLayer2
                        print_msg_macro txt_status_colour,  SDM_prod_pos_row,  SDM_prod_pos_col,  productivity_value
.DisplayRadius:         ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      hl,(GalaxyDisplayRadius)
                        push    hl
                        pop     ix
                        ld      de,0
                        ld      iy,radius_value
                        call    DispDEIXtoIY
.AddRadiusUoM:          push    iy
                        pop     hl
                        ;inc     hl
                        ld      de,radius_uom
                        call    SDTackOnUOMtoHL  
                        MMUSelectLayer2                        
                        print_msg_macro txt_status_colour,  SDM_radius_pos_row,  SDM_radius_pos_col,  radius_value
.DisplayDescription:    ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
.CopySaveToGal:         ld      de,GalaxyWorkingSeed
                        ld      hl,sd_copy_of_seed
                        call    galaxy_copy_seed  
                        ld      bc,(SD_working_cursor)
                        call     GalaxyGenerateDesc 
                        call    SD_copy_description
                        ld      iyl,38          ; wrap length
                        MMUSelectLayer2
                        print_msg_wrap_macro txt_status_colour,  SDM_dtxt_pos_row,  SDM_desc_pos_col,  SD_planet_description
                        ret

; HL = value to add on
; de = Unit of Measure
SDAddUoMtoHL:           ld      a,(hl)
                        cp      0
                        jr      z,.FoundEnd
                        inc     hl
                        jr      SDAddUoMtoHL
.FoundEnd:              ex      de,hl
                        call    SDCopyLoop
                        ret
                  
; works on HL already being at end
; de = Unit of Measure
SDTackOnUOMtoHL:        inc     hl
                        ex      hl,de
                        call    SDCopyLoop
                        ret
;
;    
;    SDDisplayEconomy        DB 0
;SDDisplayGovernment     DB 0
;SDDisplayEcononmy       DB 0
;SDDisplayTekLevel       DB 0
;
;SDDisplayProductivity   DW 0
;SDDisplayRadius         DW 0
;SDDataLength            EQU $ - SDDisplayEconomy
;                        





;; PREsent ssytem
;; hyperspace systrem
;.StatusText:	
;	; get closet ssytem to cursor
;	call	get_cmdr_condition
;	ld		hl, ConditionNameIdx
;	call	getTableText
;	ld		de,condition_position
;	call	l1_print_at
;.DisplayFuel:
;	call	GetFuelLevel
;	ld		hl, txt_fuel_level
;	ld		a,(hl)
;	cp		'0'
;	jr		nz,.PrintFuel
;.SkipLeadingZero:	
;	inc		hl
;.PrintFuel:
;	ld		de,fuel_position
;	call	l1_print_at
;.DisplayCash:
;	call	GetCash
;	ld		hl,txt_cash_amount
;	ld		de,cash_position
;	call	l1_print_at						; now we have the correct integer
;	ld		bc,cash_position
;	ld		hl,txt_cash_amount
;.CorrectPosition:
;	ld		a,(hl)
;	cp		0
;	jr		z,.DoneCorrection
;.StillDigits:
;	ld		a,c
;	add		a,8								; its 1 character forwards
;	ld		c,a
;	inc		hl
;	jr		.CorrectPosition
;.DoneCorrection:
;	ld		hl,txt_cash_decimal
;	ld		d,b
;	ld		e,c
;	call	l1_print_at	
;.PrintLegalStatus:
;	ld		a,(FugitiveInnocentStatus)
;	cp		0
;	jr		nz,.Naughty
;	ld		hl,WordClean
;	jr		.DisplayLegalStatus
;.Naughty:
;	cp		50
;	jr		c,.JustOffender
;.VeryNaughty:
;	ld		hl,WordFugitive
;	jr		.DisplayLegalStatus
;.JustOffender:
;	ld		hl,WordOffender
;.DisplayLegalStatus:
;	ld		de,legal_status_position
;	call	l1_print_at						; now we have the correct integer
;
	ret
