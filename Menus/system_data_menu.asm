system_data_page_marker DB "System      PG53"      

plant_boiler_text		DW $0240,TextBuffer
						DW $0280,name_expanded
						DW $0B08,WordDistance
						DW $1308,WordEconomy
						DW $1B08,WordGovernment
						DW $2308,WordTechLevel
						DW $2B08,WordPopulation
						DW $3B08,WordGross
						DW $3B38,WordProductivity
						DW $4308,WordAverage	
						DW $4348,WordRadius
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

GovernmentIndexOffset	EQU 75
DistanceScreenPos       EQU $0B60
GovernmentScreenPos		EQU $1B60
TechLevelScreenPos		EQU $2360
SpeciesScreenPos        EQU $3308

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


SDM_print_boiler_text:
    INCLUDE "Menus/print_boiler_text_inlineInclude.asm"

PlanetLeftJustifyLoop:  ld      a,(hl)
                        cp      "0"
                        ret      nz
                        inc     hl
                        djnz    PlanetLeftJustifyLoop
                        ret
    
SD_working_cursor       DW   0    

sd_copy_of_seed         DS 6
    
draw_system_data_menu:  INCLUDE "Menus/clear_screen_inline_no_double_buffer.asm"	
                        xor     a
                        ld      (system_present_or_target),a
                        ld		a,8
                        ld		(MenuIdMax),a	
.SelectGalaxy:          ld      a,(Galaxy)
                        MMUSelectGalaxyA
.CheckCursorOrHome:     ld      bc,(TargetPlanetX)              ; Find out if we have to work on hyperspace or normal cursor
                        ld      (SD_working_cursor),bc
                        ld      (GalaxyTargetSystem),bc
                        call    galaxy_system_under_cursor
.IsCursorOnSystem:      cp      $FF                               ; if a = 0 then failed
                        jr      z,.FoundASystem
.UsePresentSystem:      ld      bc,(PresentSystemX)
                        ld      (SD_working_cursor),bc
                        ld      (GalaxyTargetSystem),bc
                        call    galaxy_system_under_cursor
.FoundASystem:          ld      bc,(TargetPlanetX)
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
.Drawbox:               ld		bc,$0101
                        ld		de,$BEFD
                        ld		a,$C0
                        MMUSelectLayer2
                        call	l2_draw_box
                        ld		bc,$0A01
                        ld		de,$FEC0
                        call	l2_draw_horz_line
.ExpandStatic:          ld		a,14
                        call	expandTokenToString
.TargetSystem:          ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      bc, (SD_working_cursor)
 ;   call    galaxy_name_at_bc
  ;  cp      $FF               ; if we didn't get a 
                        ld      hl,sd_copy_of_seed
                        ld      de,GalaxyWorkingSeed
                        call    galaxy_copy_seed
                        call    galaxy_planet_data                              ; Geneate galaxy data from working seed 
                        call    SD_copy_system_data
                        ld      de,name_expanded
                        call    SD_copy_to_name:
                        ld      de,hyperspace_position
                        ld      hl,name_expanded
.StaticText:	        ld		b,11
                        ld		hl,plant_boiler_text
                        call	SDM_print_boiler_text
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
                        ld      de,DistanceScreenPos
                        ld      hl,distance_value
                        MMUSelectLayer1	
                        call	l1_print_at                         
                        jp      .DisplayEconomy
.ZeroDistance:          ld		a,24						; print literal zero dist
                        call	expandTokenToString
                        ld		b,1
                        ld		hl,planet_zero_dist
                        call	SDM_print_boiler_text	
.DisplayEconomy:        ld		a,(SDDisplayEconomy)
                        add     a,TextEconomyOffset
                        call	expandTokenToString
                        ld		b,1
                        ld		hl,planet_economy_disp
                        call	SDM_print_boiler_text	
.DisplayGovernment:     ld		a,(SDDisplayGovernment)
                        add		a,TextGovOffset
                        call	WordIndexToAddress
                        ld		de,GovernmentScreenPos
                        MMUSelectLayer1	
                        call	l1_print_at
.DisplayTechLevel:      ld		a,(SDDisplayTekLevel)
                        ld		de,techlevel_value
                        call    SDM_DispAtoDE
                        xor     a
                        ld      (de),a
                        ld      hl,techlevel_value
                        ld      b,5
                        call    PlanetLeftJustifyLoop
                        ld		de,TechLevelScreenPos
                        MMUSelectLayer1	
                        call	l1_print_at
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
                        MMUSelectLayer1	
                        call	l1_print_at 
;SDDisplayPopulation     DB 0
.DisplayPopulationType: ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        call    galaxy_get_species
                        call    SD_copy_species
                        ld		hl,SD_species
                        ld		de,SpeciesScreenPos
                        MMUSelectLayer1	
                        call	l1_print_at
.DisplayProductivity:   ld      hl,(SDDisplayProductivity)
                        push    hl
                        pop     ix
                        ld      de,0
                        ld      iy,productivity_value
                        call    DispDEIXtoIY
.AddProdUoM:            push    iy
                        pop     hl
                        inc     hl
                        ld      de,productivity_uom
                        call    SDTackOnUOMtoHL
                        ld      de,$3BA0
                        ld      hl,productivity_value
                        MMUSelectLayer1	
                        call	l1_print_at 
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
                        inc     hl
                        ld      de,radius_uom
                        call    SDTackOnUOMtoHL                        
                        ld      hl,radius_value
                        ld      de,$43A0
                        MMUSelectLayer1	
                        call	l1_print_at                       
.DisplayDescription:    ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
.CopySaveToGal:         ld      de,GalaxyWorkingSeed
                        ld      hl,sd_copy_of_seed
                        call    galaxy_copy_seed  
                        ld      bc,(SD_working_cursor)
                        call     GalaxyGenerateDesc 
                        call    SD_copy_description
                        ld      de,$5708
                        ld      hl,SD_planet_description  
                        MMUSelectLayer1	
                        call	l1_print_at_wrap
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
