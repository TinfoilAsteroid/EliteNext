                            ;0123456780ABCDEF
system_data_page_marker DB "System      PG53"      

draw_s_data:                jp draw_system_data_menu

close_s_data:              ret

update_s_data:             ret


SDM_copy_system_data:   ld      hl,GalaxyDisplayGovernment
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
;----------------------------------------------------------------------------------------------------------------------------------
SDM_copy_str_hl_to_de:  ld      a,(hl)
                        ld      (de),a
                        inc     hl
                        inc     de
                        and     a                               ; check if we wrote a \0 if so then done
                        jp      nz,SDM_copy_str_hl_to_de
                        ret
;------------------------------------------------------------------------------------------------------
SDM_get_current_name:   ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        call    GalaxyDigramWorkings       ; we have galaxy working seed populated now
                        ld      hl,GalaxyExpandedName
                        call    CapitaliseString
                        ld      hl, GalaxyExpandedName
                        ld      a,$FF                        
                        ld      de,sdm_system_title
                        call    SDM_copy_str_hl_to_de
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
SD_copy_species:        ld      hl,GalaxySpecies
                        ld      de,sdm_species_type
                        call    SDM_copy_str_hl_to_de
                        ret
;---------------------------------------------------------------------------------------------------------------------------------- 
SD_copy_description:    ld      hl,GalaxyPlanetDescription
                        ld      de,SD_planet_description
SDCopyLoop:             ld      a,(hl)
                        cp      0
                        jr      z,.SD_Copy_Done
                        ldi
                        jp      SDCopyLoop
.SD_Copy_Done:          ld      (de),a
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
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
;----------------------------------------------------------------------------------------------------------------------------------
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
SDM_print_boiler_text:  
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

; As per display but shifts final digit by 1 and puts in "." for 1 decimal place
SDM_DispDEIXtoIY1DP:        call    SDM_DispDEIXtoIY
                        ld      a,(IY+0)
                        ld      (IY+1),a
                        ld      a,"."
                        ld      (IY+0),a
                        ret
;----------------------------------------------------------------------------------------------------------------------------------	
SDM_DispDEIXtoIY:   ld (.SDMclcn32z),ix
                        ld (.SDMclcn32zIX),de
                        ld ix,.SDMclcn32t+36
                        ld b,9
                        ld c,0
.SDMclcn321:            ld a,'0'
                        or a
.SDMclcn322:            ld e,(ix+0)
                        ld d,(ix+1)
                        ld hl,(.SDMclcn32z)
                        sbc hl,de
                        ld (.SDMclcn32z),hl
                        ld e,(ix+2)
                        ld d,(ix+3)
                        ld hl,(.SDMclcn32zIX)
                        sbc hl,de
                        ld (.SDMclcn32zIX),hl
                        jr c,.SDMclcn325
                        inc c
                        inc a
                        jr .SDMclcn322
.SDMclcn325:            ld e,(ix+0)
                        ld d,(ix+1)
                        ld hl,(.SDMclcn32z)
                        add hl,de
                        ld (.SDMclcn32z),hl
                        ld e,(ix+2)
                        ld d,(ix+3)
                        ld hl,(.SDMclcn32zIX)
                        adc hl,de
                        ld (.SDMclcn32zIX),hl
                        ld de,-4
                        add ix,de
                        inc c
                        dec c
                        jr z,.SDMclcn323
                        ld (iy+0),a
                        inc iy
.SDMclcn323:            djnz .SDMclcn321
                        ld a,(.SDMclcn32z)
                        add A,'0'
                        ld (iy+0),a
                        ld (iy+1),0
                        ret
.SDMclcn32t             dw 1,0,     10,0,     100,0,     1000,0,       10000,0
                        dw $86a0,1, $4240,$0f, $9680,$98, $e100,$05f5, $ca00,$3b9a
.SDMclcn32z             ds 2
.SDMclcn32zIX           ds 2                            
;----------------------------------------------------------------------------------------------------------------------------------
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
                        call    sprite_cls_all;sprite_cls_cursors
                        MMUSelectLayer2
.Drawbox:               call    l2_draw_menu_border
                        ld      b,115
                        ld      hl,8
                        ld      de,86
                        ld      c,$C0
                        call    l2_draw_horz_line_320
                        ZeroA
                        ld      (system_present_or_target),a
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
                        call    galaxy_planet_data          ; Geneate galaxy data from working seed 
                        call    SDM_copy_system_data        ; populate local copy of system details
.FillInData:            call    SDM_get_current_name
.PrintDistance:         ld		a,(system_present_or_target)
                        cp		0
                        jr		z,.ZeroDistance
.NotZero:               call    sdm_calc_distance
.CalcDistance:          ld      ix,(Distance)
                        ld      de,0
                        ld      iy,distance_value
                        call    SDM_DispDEIXtoIY1DP
.AddDistUoM             push    iy
                        pop     hl
                        inc     hl
                        ld      de,distance_uom
                        call    SDTackOnUOMtoHL
.ZeroDistance:          ld      hl,sdm_distance_default
                        ld      de,distance_value
                        call    SDM_copy_str_hl_to_de
.DisplayEconomy:        ld		a,(SDDisplayEconomy)
                        add     a,TextEconomyOffset
                        call	expandTokenToString
                        ld      hl,TextBuffer
                        ld      de,sdm_economy_value
                        call    SDM_copy_str_hl_to_de
.DisplayGovernment:     ld		a,(SDDisplayGovernment)
                        add     a,TextGovOffset
                        call	WordIndexToAddress
                        ld      de,sdm_govername_value
                        call    SDM_copy_str_hl_to_de
.DisplayTechLevel:      ld		a,(SDDisplayTekLevel)
                        ld		de,techlevel_value
                        call    SDM_DispAtoDE
                        xor     a
                        ld      (de),a
                        ld      hl,techlevel_value
                        ld      b,5
                        call    PlanetLeftJustifyLoop

.DisplayPopulation:     ld      a,(SDDisplayPopulation)
                        ld      ixh,0
                        ld      ixl,a
                        ld      de,0
                        ld      iy,population_value
                        call    SDM_DispDEIXtoIY1DP
.AddUoM:                push    iy
                        pop     hl
                        inc     hl
                        ld      de,population_uom
                        call    SDTackOnUOMtoHL
                        ld      de,$2B60
                        ld      hl,population_value
.DisplayPopulationType: ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        call    galaxy_get_species
                        call    SD_copy_species
                        ld      de,sdm_species_type
.DisplayProductivity:   ld      hl,(SDDisplayProductivity)
                        push    hl
                        pop     ix
                        ld      de,0
                        ld      iy,productivity_value
                        call    SDM_DispDEIXtoIY
.AddProdUoM:            push    iy
                        pop     hl
                        ld      de,productivity_uom
                        call    SDTackOnUOMtoHL
                        ld      de,$3BA0
                        ld      hl,productivity_value
.DisplayRadius:         ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        ld      hl,(GalaxyDisplayRadius)
                        push    hl
                        pop     ix
                        ld      de,0
                        ld      iy,radius_value
                        call    SDM_DispDEIXtoIY
.AddRadiusUoM:          push    iy
                        pop     hl
                        ld      de,radius_uom
                        call    SDTackOnUOMtoHL  
.PrintBoiler:           ld		b,10
                        ld		ix,SDM_boiler_text
                        call	SDM_print_boiler_text
.PrintDescription:      ld      bc,(SD_working_cursor)
.DisplayDescription:    ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        MMUSelectGalaxyA
                        call     GalaxyGenerateDesc 
                        call    SD_copy_description
                        MMUSelectLayer2
                        ld      c,$FF
                        ld      b,120
                        ld      hl,32
                        ld      de,SD_planet_description
.PrintWrappedDesc:      ld      a,(de)                  ; intial trap null char at ptr <> 0
                        and     a                       ; .
                        ret     z                       ; .
                        ld      iyl,c                   ; iyl = color
                        push    hl                      ; save pixel column address
                        ex      de,hl                   ; hl = hl / 8
                        ld      iyh,b                   ; save b register
                        ld      b,3                     ; .
                        bsrl    de,b                    ; .
                        ex      de,hl                   ; .
                        ld      c,l                     ; c = current column in characters rather than pixels
                        ld      ixl,c                   ; ixl = colum in characters for new line
                        pop     hl                      ; get back pixel column address
.PrintLoop:             ld      a,(de)                  ; while char at ptr <> 0
                        and     a                       ; .
                        ret     z   
                        call    L2LenWordAtDE           ; b = length of string
                        ld      ixh,b                   ; save string length
                        ld      a,c                     ; a= total character length
                        add     a,b                     ; a= projected end character position of string
                        ld      c,a                     ; c=total character length (needed to keep track of string length so far
                        ld      b,iyh                   ; restore b saved in iyh above for row 
                        JumpIfALTNusng 33,.printWord    ; if calcualted length > 38 chars then word wrap
.wrapText:              ld      c,ixl                   ; start column
                        ex      de,hl                   ; update hl to be pixel start column
                        ld      d,ixl                   ;
                        ld      e,8                     ;
                        mul     de                      ;
                        ex      de,hl                   ;
                        ld      a,8                     ; down one row
                        add     a,b                     ; .
                        ld      b,a                     ; .
                        ld      iyh,a                   ; update iyh copy of b
; now bc = pxiel row, character column after string printed, de = start of string, hl = pixel col, iyl = color, ixl = column for start of line, iyh = original pixel row
.printWord:             push    bc,,de,,hl,,ix          ; stack all registgers
                        ;break
.CalculateColum:        ld      a,(de)                  ; get ascii code
                        ld      c,iyl                   ; get colour back
                        call    l2_print_char_at_320    ; b = row, hl = col, a = code for charater, c = color
                        pop     bc,,de,,hl,,ix          ;
                        inc     de                      ; move to next character
                        ld      a,8                     ; move column 8 pixles
                        add     hl,a                    ; loop until we get a space
                        dec     ixh
                        ld      a,ixh
                        and     a
                        jp      nz,.printWord
                        jp      .PrintLoop
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

SDM_boiler_text:		DB 002, low 08 , high 08 , $FF, low sdm_header       , high sdm_header    
						DB 016, low 08 , high 08 , $FF, low sdm_economy      , high sdm_economy   
						DB 026, low 08 , high 08 , $FF, low sdm_government   , high sdm_government
						DB 036, low 08 , high 08 , $FF, low sdm_tech_level   , high sdm_tech_level 
						DB 046, low 08 , high 08 , $FF, low sdm_population   , high sdm_population
                        DB 056, low 08 , high 08 , $FF, low sdm_species      , high sdm_species   
						DB 066, low 08 , high 08 , $FF, low sdm_productivity , high sdm_productivity   
						DB 076, low 08 , high 08 , $FF, low sdm_radius       , high sdm_radius   
						DB 086, low 08 , high 08 , $FF, low sdm_distance     , high sdm_distance  
						DB 106, low 08 , high 08 , $FF, low sdm_description  , high sdm_description
;----------------------------------------------------------------------------------------------------------------------
planet_zero_dist		DW $0B60,TextBuffer
planet_economy_disp		DW $1360,TextBuffer
sdm_header              DB "System Data : "
sdm_system_title        DB "                ",0
;----------------------------------------------------------------------------------------------------------------------
sdm_header_system       DS 20,0 ;HERE


;srm_distance            DB "Distance: "
;srm_dist_amount         DB "000"
;srm_decimal             DB "."
;srm_fraction            DB "0"
;srm_dis_ly              DB " Light Years",0
;srm_default_dist        DB "  0.0"

;----------------------------------------------------------------------------------------------------------------------
sdm_economy             DB "Economy     : "
sdm_economy_value       DS 20,0
;----------------------------------------------------------------------------------------------------------------------
sdm_government          DB "Government  : "
sdm_govername_value     DS 20,0
;----------------------------------------------------------------------------------------------------------------------
sdm_tech_level          DB "Tech Level  : "
techlevel_value			DS 20,0
;----------------------------------------------------------------------------------------------------------------------
sdm_population          DB "Population  : "
population_value        DS 20
                        DB 0
population_uom          DB " Billion",0
;----------------------------------------------------------------------------------------------------------------------
sdm_species             DB "Species     : " 
sdm_species_type        DB "                     ",0      
;----------------------------------------------------------------------------------------------------------------------
sdm_productivity        DB "Gross Productivity : ":  
productivity_value      DS 20
                        DB 0
productivity_uom        DB " M CR",0
;----------------------------------------------------------------------------------------------------------------------
sdm_radius              DB "Average Radius     : "
radius_value            DS 20
                        DB 0
radius_uom              DB " km",0
;----------------------------------------------------------------------------------------------------------------------
sdm_distance            DB "Distance           : "
distance_value          DS 20,0
distance_uom            DB " Light Years",0

sdm_distance_default:   DB "0.0 Light Years",0

;----------------------------------------------------------------------------------------------------------------------
sdm_description         DB "Description",0

system_present_or_target DB 0
saved_present			 DW 0


SD_present_name         DS  30
                        DB  0
SD_target_name          DS  30
                        DB  0                  
SD_planet_description   DS 300,0

SDDisplayGovernment     DB 0
SDDisplayEconomy        DB 0
SDDisplayTekLevel       DB 0
SDDisplayPopulation     DB 0
SDDisplayProductivity   DW 0
SDDisplayRadius         DW 0
SDDataLength            EQU $ - SDDisplayEconomy
                        