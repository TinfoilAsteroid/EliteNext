short_range_page_marker  DB "ShortRange  PG50"
                            ;0123456780ABCDEF
draw_s_chart:               jp SRM_galactic_chart

close_s_chart:              ret

update_s_chart:             ret
cursors_s_chart:            jp  SRM_cursors
;----------------------------------------------------------------------------------------------------------------------------------
copy_str_hl_to_de:          ld      a,(hl)
                            ld      (de),a
                            inc     hl
                            inc     de
                            and     a                               ; check if we wrote a \0 if so then done
                            jp      nz,copy_str_hl_to_de
                            ret
;----------------------------------------------------------------------------------------------------------------------------------
; draws chart and keeps a local cache of pixel position to chart position
SRM_galactic_chart:         MMUSelectLayer1                         ; initialise display
                            call  l1_cls                            ; .
                            ld      a,7                             ; .
                            call    l1_attr_cls_to_a                ; .
                            MMUSelectLayer2                         ; .
                            call    l2_320_initialise               ; .
                            call    asm_l2_double_buffer_off        ; .
                            call    l2_320_cls                      ; .
                            MMUSelectSpriteBank                     ; .
                            call    sprite_cls_cursors              ; .
                            ld      a,SRM_cursor_dampen
                            ld      (SRM_cursor_dampen_timer),a
.selectPresentSystem:       call    SRM_get_current_name
;                            call    SRM_get_present_system
.drawOuterBorder:           MMUSelectLayer2                         ; draw chart background graphics
                            call    l2_draw_menu_border
.drawTextAreas:             ld      b,192
                            ld      hl,2
                            ld      de,316
                            ld      c,$C0
                            call    l2_draw_horz_line_320           ;b = row; hl = col, de = length, c = color"
.generateHeaderText:        ld      b,1                             ; only 1 line to print og boiler text
                            ld      ix,SRM_boiler_text              ; .
                            call    SRM_print_boiler_text           ; .
                            call    SRM_fuel_circle
.plot_stars:                call    SRM_plot_stars                         
.CircleandCrosshair:        ld      hl,srm_star_x_centre -15
                            ld      (SRM_cursor_x),hl
                            ld      hl,srm_star_y_centre -15
                            ld      (SRM_cursor_y),hl
                            call    SRM_draw_cursor
                        ; srm_position sthingsy
;                            call    SRM_target_cursor
;                            call    SRM_get_current_name
;.getTargetName:             call    SRM_get_target_name
                            ret
;----------------------------------------------------------------------------------------------------------------------------------
SRM_get_current_name:       ld      a,(Galaxy)
                            MMUSelectGalaxyA
                            ld      bc,(PresentSystemX)
                            ld      (GalaxyTargetSystem),bc
                            call    galaxy_system_under_cursor          ; TODO for some reason this bit
                            call    srm_get_seed_name
                            ld      de,short_rg_chart_current_name
                            call    copy_str_hl_to_de
                            ret
; bc = seed position, iy = present position, sets carry if too far away
SRM_bc_in_range_iy:         ClearCarryFlag
                            ld      a,b
                            sbc     a,iyh
                            jp      nc,.PositiveY
                            neg
.PositiveY:                 cp      local_max_range_y
                            ccf
                            ret     c                               ; set carry flag on failure
                            ld      a,c
                            sbc     a,iyl
                            jp      nc,.PositiveX
                            neg
.PositiveX:                 cp      local_max_range_x
                            ccf
                            ret                                     ; set carry flag on failure
;----------------------------------------------------------------------------------------------------------------------------------
SRM_plot_stars:             xor     a                               ; intiailise
                            ;break
                            ld      (srm_star_cache_size),a         ; local copy of stars rendered
                            ld      (XSAV),a                        ; .
                            ld      ix,galaxy_data                  ; .
                            ld      (srm_buffer_size),a             ; .
                            ld      hl,srm_star_cache
                            ld      (.StarCacheAddress+2),hl         ; set intial value needs to be +2 as its IY not HL
.CClearNameList:            ld      hl,srm_printed_text             ; .
                            ld      de,srm_fill_buffer_size         ; .
                            call    memfill_dma:                    ; .
.CounterLoop:               xor     a                               ; clear carry
                            ld      a,(Galaxy)                      ; select galaxy
                            MMUSelectGalaxyA                        ; .
                            push    ix                              ; . sp + 1
                            ld      hl,ix
                            ld      de,SystemSeed                   ; and loop through seeds
                            call    copy_seed                       ; copy 6 bytes at hl to de via ldi x 6
                            ld      a,(SystemSeed+1)                ; c = Ycoord of star seed
                            ld      c,a                             ;
.srmcalcLocaldy:            ld      a,(PresentSystemY)              ; b = Current system Y (i.e. initiall Lave)
                            ld      iyh,a             ; iyh = col iyl = row
                            ld      a,(PresentSystemX)
                            ld      iyl,a
                            ld      a,(SystemSeed+3)                ; seed Xcoord of star
                            ld      c,a
                            ld      a,(SystemSeed+1)                ; seed Ycoord of star
                            ld      b,a
                            push    bc
                            call    SRM_bc_in_range_iy
                            pop     bc
                            jp      c,.srmtoofar
.srmSystemInRange:          ld      a,(SystemSeed+5)                ; radius = seed 5 & 3 + 2 (for now)
                            and     %00000011                       ; .
                            add     a,2                             ; .
                            ld      e,a                             ; .
                            push    de
                            ld      a,(SystemSeed+3)
                            ld      c,a
                            ld      a,(SystemSeed+1)
                            ld      b,a
.StarCacheAddress:          ld      iy,$0000
                            ld      (iy+4),bc                       ; save chart pos at offset + 4
                            ld      a,(srm_star_cache_size)         ; .
                            inc     a                               ; .
                            ld      (srm_star_cache_size),a         ; .
                            call    SRM_star_to_screen              ; note this means star offset in cache will be -7,-7 rather than cursor -15,-15
                            ld      (local_name_row),bc
                            ld      (local_name_col),hl
                            push    bc
                            push    hl
                            push    bc
                            ld      de,8                            ; an extra 8 for cursor position offset
                            ClearCarryFlag
                            sbc     hl,de                           ; adjust to cursor col position
                            ld      (iy+0),hl                       ; .
                            pop     hl                              ; pull row into hl
                            sbc     hl,de                           ; adjust to cursor row position
                            ld      (iy+2),hl                       ; .
                            pop     hl
                            pop     bc
                            inc     iy                              ; move + 6 bytes
                            inc     iy                              ; .
                            inc     iy                              ; .
                            inc     iy                              ; .
                            inc     iy                              ; .
                            inc     iy                              ; .
                            ld      (.StarCacheAddress+2),iy        ; .
                            pop     de
                            call    SRM_show_star_sprite            ; B = row, hl = col, d = radius, e = colour
                       ; call    srm_get_name
                            MMUSelectLayer2
                            call    srm_label_system8bit
.srmtoofar:                 pop     hl                              ; next seed
                            add     hl,8                            ; .
                            push    hl                              ; .
                            pop     ix                              ; .
                            ld      a,(XSAV)                        ; if we have looped back to 0 on counter
                            dec     a                               ; its done
                            cp      0                               ; .
                            ret     z                               ; .
                            ld      (XSAV),a                        ; else loop
                            jp      .CounterLoop                     ; .
;----------------------------------------------------------------------------------------------------------------------------------
; bc = row hl = col
SRM_show_star_sprite:       MMUSelectSpriteBank                   
                            ld      a,(spr_nextStar)                    ; select next sprite slot in queue
                            nextreg   SPRITE_PORT_INDEX_REGISTER,a      ;
                            inc     a                                   ; mark next free slot
                            ld      (spr_nextStar),a                    ;
.SetXLSB:                   ld      a,l                                 ; LSB of X coordinate
                            nextreg   SPRITE_PORT_ATTR0_REGISTER,a      ; .
.SetY                       ld      a,c                                 ; Y coordinate LSB
                            nextreg   SPRITE_PORT_ATTR1_REGISTER,a      ; .
.SetXMSB:                   ld      a,h                                 ; get MSB bit of X coordinate
                            and     $01                                 ; and ensure other bits are clear
                            nextreg   SPRITE_PORT_ATTR2_REGISTER,a      ; .
.SetVisPattern:             ld      a, (star_size_1 - 1) | $80          ; base pattern and visible bit
                            add     a,e                                 ; select correct star from 1 to 5
                            nextreg   SPRITE_PORT_ATTR3_REGISTER,a      ; .
; write out extended attribute
                            ld      a,%00000000                         ; its a single sprite
                            or      h
                            nextreg SPRITE_PORT_ATTR4_REGISTER,a
                            ret
;---------------------------------------------------------------------------------------------------------------------------------
SRM_draw_cursor:            ;SRM_draw_hyperspace_cross_hair:
                            ld      bc,(SRM_cursor_y)              ; bc = selected jump
                            ld      hl,(SRM_cursor_x)
                            ld      d,local_hyper_sprite
                            ld      e,local_hyper_pattern
                            MMUSelectSpriteBank
                            call    sprite_big_full_screen          ; bc = row hl = col D = sprite nbr , E= , pattern"
                            ret
;-----------------------------------------------------------------------------------------------
SRM_fuel_circle:            ld      bc,((srm_star_y_centre) << 8) + srm_star_x_centre
                            ld      a,(Fuel)
                            ld      d,a
                            ld      e,204
; ">l2_draw_circle BC = center row col, d = radius, e = colour"
                            ld      a,e
                            ld      (.PlotPixel+1),a
                            ld      a,d                             ; get radius
                            and     a
                            ret     z
                            cp      1
                            jp      z,CircleSinglepixel
                            ld      (.Plot1+1),bc           ; save origin into cXcY reg in code
                            ld      ixh,a                   ; ixh =  x = raidus
                            ld      ixl,0                   ; iyh =  y = 0
.calcd:                     ld      h,0     
                            ld      l,a     
                            add     hl,hl                   ; hl = r * 2
                            ex      de,hl                   ; de = r * 2
                            ld      hl,3        
                            and     a       
                            sbc     hl,de                   ; hl = 3 - (r * 2)
                            ld      b,h     
                            ld      c,l                     ; bc = 3 - (r * 2)
.calcdelta:                 ld      hl,1
                            ld      d,0
                            ld      e,ixl
                            and     a
                            sbc     hl,de
.Setde1:                    ld      de,1
.CircleLoop:                ld      a,ixh
                            cp      ixl
                            ret     c
.ProcessLoop:               exx
.Plot1:                     ld      de,0                    ; de = cXcY
                            ld      a,e                     ; c = cY + error
                            add     a,ixl                   ;
                            ld      c,a                     ;
                            ld      a,d                     ; b = xY+radius
                            add     a,ixh                   ;
                            ld      b,a                     ;
                            call    .PlotPixel              ;CX+X,CY+Y
.Plot2:                     ld      a,e
                            sub     ixl
                            ld      c,a
                            ld      a,d
                            add     a,ixh
                            ld      b,a
                            call    .PlotPixel              ;CX-X,CY+Y
.Plot3:                     ld      a,e
                            add     a,ixl
                            ld      c,a
                            ld      a,d
                            sub     ixh
                            ld      b,a
                            call    .PlotPixel              ;CX+X,CY-Y
.Plot4:                     ld      a,e
                            sub     ixl
                            ld      c,a
                            ld      a,d
                            sub     ixh
                            ld      b,a
                            call    .PlotPixel              ;CX-X,CY-Y
.Plot5:                     ld      a,d
                            add     a,ixl
                            ld      b,a
                            ld      a,e
                            add     a,ixh
                            ld      c,a
                            call    .PlotPixel              ;CY+X,CX+Y
.Plot6:                     ld      a,d
                            sub     ixl
                            ld      b,a
                            ld      a,e
                            add     a,ixh
                            ld      c,a
                            call    .PlotPixel              ;CY-X,CX+Y
.Plot7:                     ld      a,d
                            add     a,ixl
                            ld      b,a
                            ld      a,e
                            sub     ixh
                            ld      c,a
                            call    .PlotPixel              ;CY+X,CX-Y
.Plot8:                     ld      a,d
                            sub     ixl
                            ld      b,a
                            ld      a,e
                            sub     ixh
                            ld      c,a
                            call    .PlotPixel              ;CY-X,CX-Y
                            exx
.IncrementCircle:           bit     7,h                     ; Check for Hl<=0
                            jr z,   .draw_circle_1
                            add hl,de                       ; Delta=Delta+D1
                            jr      .draw_circle_2      ; 
.draw_circle_1:             add     hl,bc                   ; Delta=Delta+D2
                            inc     bc
                            inc     bc                      ; D2=D2+2
                            dec     ixh                     ; Y=Y-1
.draw_circle_2:             inc bc                          ; D2=D2+2
                            inc bc          
                            inc de                          ; D1=D1+2
                            inc de              
                            inc ixl                         ; X=X+1
                            jp      .CircleLoop
.PlotPixel:                 ld      a,0                     ; This was originally indirect, where as it neeed to be value
                            push    de,,bc,,hl
                            ; ">l2_plot_pixel d= row number, hl = column number, e = pixel col"
                            ld      h,0
                            ld      l,c
                            ld      d,b
                            ld      e,204
                            MMUSelectLayer2
                            call    l2_plot_pixel_320       ;d= row number, hl = column number, e = pixel col
                            pop     de,,bc,,hl
                            ret

;----------------------------------------------------------------------------------------------------------------------------------
srm_get_name:           ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld      bc,(TargetSystemX)
                        ld      (GalaxyTargetSystem),bc
                        call    galaxy_system_under_cursor
                        cp      0
                        ret     z
srm_get_seed_name:      call    GetDigramWorkingSeed            ; entry point if we have already got the target system
                        ld      hl,name_expanded
                        call    CapitaliseString
                        ld      hl, name_expanded
                        ld      a,$FF
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
SRM_update_cursor:      call    SRM_draw_cursor
                        ret
                        ld      bc,(TargetSystemX)              ; bc = selected jump
                        ld      de,(PresentSystemX)
                        ld      a,c                             ; a = target x pos
                        sub     e                               ; a = target x - present x
                        jp      p,.NoFlipX                      ; if > 0 skip next bit
                        neg                                     ; c = a = abs a * 4
                        sla     a                               ; .
                        sla     a                               ; .
                        ld      c,a                             ;  .
                        ld      a,srm_x_centre                  ; c = a = centre screen - c
                        sub     c                               ; .
                        ld      c,a                             ; .
                        jp      .fixY                           ;. now do Y
.NoFlipX:               sla     a
                        sla     a
                        add     a,srm_x_centre
                        ld      c,a
.fixY:                  ld      a,b                             ; for Y its * 2
                        sub     d
                        jp      p,.NoFlipY
                        neg
                        sla     a
                        ld      b,a
                        ld      a,srm_y_centre
                        sub     b
                        ld      b,a
                        jp      .RedrawSprite
.NoFlipY                sla     a
                        add     a,srm_y_centre
                        ld      b,a
.RedrawSprite:          MMUSelectSpriteBank
                        call    sprite_lhc_move
                        call    srm_name_current
                        ret

srm_clear_name_area:    ld      h,8
                        ld      de,$A000 | COLOUR_TRANSPARENT
                        ld      bc,$A80A
.ClearLoop:             push    hl
                        push    de
                        push    bc
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        pop     bc
                        pop     de
                        pop     hl
                        inc     b
                        dec     h
                        jr      nz,.ClearLoop
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
srm_display_target_details:
                        ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld      bc,(TargetSystemX)
                        ld      (GalaxyTargetSystem),bc
                        call    galaxy_system_under_cursor
                        cp      0
                        ret     z
                        call    srm_get_seed_name
                        ld      de,srm_system_title
                        call    copy_str_hl_to_de
                        call    srm_calc_distance
                        ld      b,3
                        ld      ix,SRM_detail_text
                        call    SRM_print_boiler_text
                        ret
                        
;----------------------------------------------------------------------------------------------------------------------------------
srm_system_undercursor: ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld      bc,(TargetSystemX)
                        ld      (GalaxyTargetSystem),bc
                        call    galaxy_system_under_cursor  ; local position to workingseeds
                        cp      0                           ; or exit if non found
                        ret     z
srm_name_current:       call    srm_get_seed_name
                        push    hl
                        push    af
                        call    srm_clear_name_area
                        ld      hl,name_expanded            ; we are writing name
                        ld      b,$A0
                        ld      hl, $00A0
                        ld      c,$FF
                        MMUSelectLayer2
                        call    l2_print_at_320         ;b = row, hl = col, de = addr of message, c = color
                        pop     af
                        pop     hl
                        call    srm_calc_distance
                        ld      de,srm_distance
                        ld      bc,$B0
                        ld      hl,$0A
                        ld      c,$FF
                        MMUSelectLayer2
                        call    l2_print_at_320
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
srm_calc_distance:      ld      a,(Galaxy)                                      ; Default in 0 distance
                        MMUSelectGalaxyA
                        ld      de,srm_dist_amount
                        ld      hl,srm_default_dist
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
                        ld      iy,srm_distance_val
                        call    DispDEIXtoIY                                    ; use DEIX as distance and write to string at location IY
                        push    iy
                        pop     hl                                              ; hl = iy
                        ld      de,srm_distance_val
                        ld      a,(hl)                                          ;Push last digit to post decimal
                        ld      (srm_fraction),a    
                        dec     hl
                        call    compare16HLDE                                   
                        jr      c,.done_number
                        ld      a,(hl)
                        ld      (srm_dist_amount+2),a
                        dec     hl
                        call    compare16HLDE
                        jr      c,.done_number
                        ld      a,(hl)
                        ld      (srm_dist_amount+1),a
                        dec     hl
                        call    compare16HLDE
                        jr      c,.done_number
                        ld      a,(hl)
                        ld      (srm_dist_amount),a
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
; Checks to see if we have enough room to print text. srm_printed_text holds the buffer
; Carry flag is set on failure
;                 cache left   between

;   h =top row, l = bottom row <not needed now>, d = left, e = right, ix = pointer to data
;   If A == N, then Z flag is set.
;   If A != N, then Z flag is reset.
;   If A < N, then C flag is set.
;   If A >= N, then C flag is reset.
;----------------------------------------------------------------------------------------------------------------------------------
;-- Performs a search for the box within a single cache entry pointed to by ix, carry is set if there is a collision
FreeNameIXTest8Bit:     ld      a,(ix+0)                  ;test collision box top
.TestRow:               cp      h                         ;if ct >= local t
                        jp      nz,.MissOnRow             ;   (else ct < local so miss)
.HitOnRow:                                                ;.
.TestLeftAndRight:      ld      a,(ix+2)                  ;test collision box bottom
                        cp      d                         ;if cl >= local l
                        jp      c,.MissOnLft              ;   (else cl < local l so miss)
                        cp      e                         ;   if cl <= local r
                        jp      z,.HitOnLft               ;      jp collisiononrow-starttestingcol
                        jp      c,.HitOnLft               ;      (else cl > local r so miss)
.MissOnLft:             ld      a,(ix+3)                  ; a now holds bottom row as we are doing 8 bit
                        cp      e                         ;if cr >= local l
                        jp      c,.MissOnRgt              ;   (else ct < local so miss)
                        cp      d                         ;   if cb <= local r
                        jp      z,.HitOnRgt               ;      jp collisiononrow-starttestingcol
                        jp      c,.HitOnRgt               ;      (else ce > local r so miss)
                        jp      .MissOnRgt                ;OR
.HitOnLft:
.HitOnRgt:
.Collision:             SetCarryFlag
                        ret
.MissOnRow:
.MissOnRgt:
.NoCollision:           ClearCarryFlag
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
;-- Performs picking up of local data for the search box then calls FreeNameIXTest8Bit to find if the space is already used up
TestBoxAgainstCache:    ld      a,(local_name_row8bit)  ; row will hold row only as its character based, we can scrap l
                        ld      h,a
                        ld      de,(local_name_col8bit) ; e now = left side, d = right side
TestLoop:               ld      ix,srm_printed_text     ; ix pointer to cache list
                        ld      a,(srm_buffer_size)     ; number of entries present in cache
                        ld      b,a                     ; .
                        ld      c,0                     ; count of collisions
.CompareTopRow:         call    FreeNameIXTest8Bit      ; perform collision test
                        ret     c                       ; failure means exit
                        inc     ix
                        inc     ix
                        inc     ix
                        djnz    .CompareTopRow
                        ClearCarryFlag
                        ret
; comming in bc = column, row of star (note nor the usual row col for bc
srm_cache_star_pos:     push    af,,de,,hl              ;
                        ld      hl,srm_printed_text     ; find next slot in cache
                        ld      d,srm_fill_buffer_record  ; .
                        ld      a,(srm_buffer_size)     ; .
                        ld      e,a                     ; .
                        mul     de                      ; .
                        add     hl,de                   ; .
                        ld      (hl),c                  ; now save row
                        inc     hl                      ; then col
                        ld      (hl),b                  ;
                        inc     b                       ; width is 2 characters
                        inc     hl                      ; then col end
                        ld      (hl),b                  ;
                        ld      hl,srm_buffer_size
                        inc     (hl)
                        pop     af,,de,,hl              ;
                        ret                             ;
srm_cachelabel:         push    af,,bc,,de,,hl          ; 
                        ld      hl,srm_printed_text     ; find next slot in cache
                        ld      d,srm_fill_buffer_record; .
                        ld      a,(srm_buffer_size)     ; .
                        ld      e,a                     ; .
                        mul     de                      ; .
                        add     hl,de                   ; .
                        ex      de,hl                   ; de = target as we are doing ldi to copy
                        ld      hl,local_name_row8bit   ; now save row
                        ldi                             ; .
                        ldi                             ; .
                        ldi                             ; .
                        ld      hl,srm_buffer_size
                        inc     (hl)
                        pop     af,,bc,,de,,hl          ; 
                        ret
                        
;----------------------------------------------------------------------------------------------------------------------------------
;-- Takes the pixel lable details and converts to char positions
srm_scale_label_pos:    ld      de,(local_name_row)     ; convert pixels to char positions
                        ld      b,3                     ; by dividing by 8
                        bsra    de,b                    ;
                        ld      a,e                     ; c = local_name_row8bit = a = e = row
                        ld      (local_name_row8bit),a  ; .
                        ld      c,a                     ; .
                        ld      de,(local_name_col)     ; convert pixels to char positions
                        ld      b,3                     ; by dividing by 8
                        bsra    de,b                    ; .
                        ld      b,e                     ; b holds column for start of text (which is actual star position)
                        call    srm_cache_star_pos      ; Save star position
                        inc     c
                        call    srm_cache_star_pos
                        dec     c
.CheckLeftorRight:      ld      a,b
                        cp      srm_star_x_centre_char
                        jp      c,.LeftSideText
.RightSideText:         inc     a                       ; On the right 1 characters from star
                        ld      (local_name_col8bitLeft),a; save left edge
                        ld      a,(local_name_len)      ; now a holds actual end 
                        add     b
                        ld      (local_name_col8bitRght),a  ; save right edge
                        ret
.LeftSideText:          ld      a,(local_name_len)      ; c = length - 1
                        dec     a                       ; .
                        ld      c,a                     ; .
                        ld      a,b                     ; a = star position - (len - 1) to be left side
                        sbc     a,c                     ; .
                        dec     a                       ; and an additional 2 chars. position will never be off left 
                        dec     b                       ;
                        ld      (local_name_col8bitLeft),a  ; for reading into e
                        ld      a,b
                        ld      (local_name_col8bitRght),a; right most side for reading into d
                        ret
; takes memorty location local_name_col and local_name_row as character positions of text                        
srm_label_system8bit:   call    copy_system_to_working  ; set up working seed
                        ld      a,(Galaxy)              ; and name
                        MMUSelectGalaxyA                ;
                        call    srm_get_seed_name     
                        call    srm_string_len          ; gets length of string at hl into b
                        ld      a,b                     
                        inc     a
                        ld      (local_name_len),a      
                        call    srm_scale_label_pos     ; now local 8 bit holds direct position
 ;.......................first attempt                  
.attempt1:              call    TestBoxAgainstCache     ; hl = row de = col bc = col right col e = chars
                        jr      nc,.OKToPrint
;.......................attempt 2 up one row
.attempt2:              ld      hl,local_name_row8bit
                        dec     (hl)
                        call    TestBoxAgainstCache     ; hl = row de = col bc = col right col e = chars
                        jr      nc,.OKToPrint
;.......................attempt 3 down one row
.attempt3:              ld      hl,local_name_row8bit
                        inc     (hl)
                        inc     (hl)
                        call    TestBoxAgainstCache     ; hl = row de = col bc = col right col e = chars
                        jr      nc,.OKToPrint
.OKToPrint:             call    srm_cachelabel
                        ld      a,(local_name_col8bit)  ; hl = pixel columns ( * 8 to get pixel address) which also means its on character boundary
                        ld      d,8                     ; .
                        ld      e,a                     ; .
                        mul     de                      ; . 
                        ex      de,hl                   ; .
                        ld      a,(local_name_row8bit)
                        sla     a
                        sla     a
                        sla     a                       
                        ld      b,a                     ; now in pixels
                        ld      de,name_expanded
                        ld      c,$FF
                        MMUSelectLayer2
                        call    l2_print_at_320         ;b = row, hl = col, de = addr of message, c = color
                        ret

                        
                        
; hl = string pointer, returns b with length
srm_string_len:         ld      b,a
.FindLoop:              ld      a,(hl)
                        and     a
                        ret     z
                        inc     hl
                        inc     b
                        jp      .FindLoop
                       
SRM_cursor_to_chart:    ld      hl,(SRM_cursor_x)               ; compensate for screen venter and pixel adjustment
                        ld      a,15                            ; adjust as SRM_cursor_x holds top left
                        add     hl,a                            ;
                        ld      de,srm_star_x_centre            ; a +=  screen center
                        ClearCarryFlag                          ;
                        sbc     hl,de                           ; hl = dx in screen pixels / 4
                        ld      b,2                             ; .
                        ex      de,hl                           ; .
                        bsra    de,b                            ; .
                        ex      de,hl                           ; .
                        ld      d,0                             ; de = center of screen system x pos
                        ld      a,(PresentSystemX)              ;
                        ld      e,a                             ;
                        add     hl,de                           ; de = dx + center star chart x
                        ex      de,hl                           ; 
                        ld      hl,(SRM_cursor_y)               ; hl = dy in pixels / 2
                        ld      a,15                            ; adjust as SRM_cursor_y holds top left
                        add     hl,a                            ; .
                        ld      bc,srm_star_y_centre            ; .
                        ClearCarryFlag                          ; .
                        sbc     hl,bc                           ; .
                        SRAHLRight1                             ; .
                        ld      b,0                             ; hl = dy + center star chart y
                        ld      a,(PresentSystemY)              ; .
                        ld      c,a                             ; .
                        add     hl,bc                           ; .
                        ld      b,l                             ; 
                        ld      c,e                             ; b = ypos c = xpos
                        ;ld      bc,hl                          ; bc = (y on chart / 2)
                        ret

                        ; bc = chart row col absolute returns bc = screen row, hl = screen col
SRM_chart_to_cursor:    ld      a,(PresentSystemY)              ; hl = center system Y (in de) - b (chart Y)
                        ld      e,a                             ; .
                        ld      d,0                             ; .
                        ld      h,0                             ; .
                        ld      l,b                             ; .
                        ClearCarryFlag                          ; .
                        sbc     hl,de                           ; .
                        ShiftHLLeft1                            ; hl = (cy - b) * 2
                        ld      de,srm_star_y_centre -15        ; de = ((cy - b) * 2) + (srm_star_y_centre offset by cursor home)
                        add     hl,de                           ; .
                        ex      de,hl                           ; .
                        ld      h,0                             ; hl = c (chart x) - present X
                        ld      l,c                             ; .
                        ld      a,(PresentSystemX)              ; .
                        ld      b,0                             ; .
                        ld      c,a                             ; .
                        ClearCarryFlag                          ; .
                        sbc     hl,bc                           ; .
                        ex      de,hl                           ; de = c - cx, hl = adjusted y position
                        ld      b,2                             ; de = de * 4 
                        bsla    de,b                            ; .
                        ex      de,hl                           ; hl = ( c - cx) * 4, de = adjusted y position
                        ld      bc,srm_star_x_centre -15        ; hl += (srm_star_x_centre offset by cursor home)
                        add     hl,bc                           ; .
                        ld      bc,de                           ; bc = adjusted y position
                        ret
; takes present system x y and convers to bc = row, hl = column                        
SRM_star_to_screen:     ld      a,(PresentSystemY)              ; hl = center system Y (in de) - b (chart Y)
                        ld      e,a                             ; .
                        ld      d,0                             ; .
                        ld      h,0                             ; .
                        ld      l,b                             ; .
                        ClearCarryFlag                          ; .
                        sbc     hl,de                           ; .
                        ShiftHLLeft1                            ; hl = (cy - b) * 2
                        ld      de,srm_star_y_centre -7         ; de = ((cy - b) * 2) + (srm_star_y_centre offset by cursor home)
                        add     hl,de                           ; .
                        ex      de,hl                           ; .
                        ld      h,0                             ; hl = c (chart x) - present X
                        ld      l,c                             ; .
                        ld      a,(PresentSystemX)              ; .
                        ld      b,0                             ; .
                        ld      c,a                             ; .
                        ClearCarryFlag                          ; .
                        sbc     hl,bc                           ; .
                        ex      de,hl                           ; de = c - cx, hl = adjusted y position
                        ld      b,2                             ; de = de * 4 
                        bsla    de,b                            ; .
                        ex      de,hl                           ; hl = ( c - cx) * 4, de = adjusted y position
                        ld      bc,srm_star_x_centre -7         ; hl += (srm_star_x_centre offset by cursor home)
                        add     hl,bc                           ; .
                        ld      bc,de                           ; bc = adjusted y position
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
SRM_cursors:
local_chart_cursors:    ld      a,(SRM_cursor_dampen_timer)             ; if timer has reached zero 
                        or      a                                       ; else carry on with 
                        jp      z,.timerZero                            ; count down of timer
                        dec     a
                        ld      (SRM_cursor_dampen_timer),a
                        ret                                             ; .
.timerZero:             ld      a,(CursorKeysPressed)                   ; Once it gets to zero
                        ReturnIfAIsZero                                 ; it holds that until another eky is pressed
                        ld      b,a
                        ld      a,SRM_cursor_dampen
                        ld      (SRM_cursor_dampen_timer),a
                        ld      a,b
                        rla
                        call   c,srm_UpPressed
                        rla
                        call   c,srm_DownPressed
                        rla
                        call   c,srm_LeftPressed
                        rla
                        call   c,srm_RightPressed
                        rla
                        call   c,srm_HomePressed
                        rla
                        call   c,srm_RecenterPressed
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
srm_UpPressed:          push    af
                        ld     a,(SRM_cursor_y)
                        JumpIfAEqNusng   168, srm_BoundsLimit 
                        ;break
                        inc    a
                        ld      (SRM_cursor_y),a
                        call    SRM_update_cursor
                        pop     af
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
srm_DownPressed:        push    af
                        ld     a,(SRM_cursor_y)
                        JumpIfAEqNusng   8, srm_BoundsLimit 
                        ;break
                        dec    a
                        ld      (SRM_cursor_y),a
                        call    SRM_update_cursor
                        pop     af
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
srm_LeftPressed:        push    af
                        ld      a,(SRM_cursor_x)           ; can cheat and do 8 bit as we will never go beyond 80 and 240
                        JumpIfAEqNusng   64, srm_BoundsLimit 
                        ;break
                        dec    a
                        ld      (SRM_cursor_x),a
                        call    SRM_update_cursor
                        pop     af
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
srm_RightPressed:       push    af
                        ld      a,(SRM_cursor_x)           ; can cheat and do 8 bit as we will never go beyond 80 and 240
                        JumpIfAEqNusng   224, srm_BoundsLimit 
                        ;break
                        inc    a
                        ld      (SRM_cursor_x),a
                        call    SRM_update_cursor
                        pop     af
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
srm_HomePressed:        push    af
                        ;break
                        ld      hl,srm_star_x_centre -15
                        ld      (SRM_cursor_x),hl
                        ld      hl,srm_star_y_centre -15
                        ld      (SRM_cursor_y),hl
                        call    SRM_update_cursor
                        pop     af
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
srm_RecenterPressed:    push    af
                        ;break
.GetCursorDistance:     call    srm_calc_cur_jumpable
                        jp      c,.TooFar
                        ;ld      a,(Galaxy)      ; DEBUG as galaxy n is not working
                        ;MMUSelectGalaxyA
                        ;call    SRM_cursor_to_chart ; Convert cursor position to galactic chart position
                        ;ld      (TargetSystemX),bc
                        ;ld      bc,(TargetSystemX)
                        call    find_nearest_cache  ; find nearest system to galactic chart position
                        jp      c,.TooFar
                        ld      (TargetSystemX),bc  ; save galatic position to TargetSystemX
                        call    SRM_chart_to_cursor ; convert back to on screen cursor position
                        ld      (SRM_cursor_y),bc
                        ld      (SRM_cursor_x),hl
                        call    SRM_update_cursor
                        
                        call    srm_display_target_details
                        pop     af
                        ret
.TooFar:                ld      b,2
                        ld      ix,SRM_system_too_far
                        call    SRM_print_boiler_text
                        pop     af
                        ret
; Cache is pre adjusted to cursor positions
found_distance:         dw      9000                        ; assume starting 9000 as crazy high    
found_system            dw      0           
find_nearest_cache:     ld      a,(srm_star_cache_size)     ; if there are no stars then forget it
                        and     a                           ; .
                        jp      z,.NoHit                    ; .
                        ld      ixl,a
.SearchCache:           ld      hl,9000                     ; assume starting 9000 as crazy high  
                        ld      (found_distance),hl         ; .
                        ld      iy,srm_star_cache           ; for each star in the cache
.SearchLoop:            ld      hl,(iy+0)                   ; check abs distance from target cusor
                        ld      bc,(SRM_cursor_x)          ; .
                        ClearCarryFlag                      ; .
                        sbc     hl,bc                       ; .
                        jp      p,.distXPos                 ; .
.distXNeg:              NegHL                               ; .
.distXPos:              ld      a,h                         ; we can never have > 255 so skip
                        and     a                           ; .
                        jp      nz,.Miss                    ; .
                        ex      de,hl                       ; and put the result in de
                        ld      hl,(iy+2)                   ; check star y in cache
                        ld      bc,(SRM_cursor_y)
                        ClearCarryFlag
                        sbc     hl,bc
                        jp      p,.distYPos                 ; .
.distYNeg:              NegHL                               ; .
.distYPos:              ld      a,h                         ; we can never have > 255 so skip
                        and     a                           ; .
                        jp      nz,.Miss                    ; .
                        ld      d,e                         ; so dist hl = sqrt(x^2 + y^2)
                        mul     de                          ; .
                        ex      de,hl                       ; .
                        ld      d,e                         ; .
                        mul     de                          ; .
                        ClearCarryFlag                      ; .
                        add     hl,de                       ; .
                        ex      de,hl                       ; .
                        call    asm_sqrt                    ; .
                        ld      de,(found_distance)
                        call    CompareHLDEunsigned
                        jp      nc,.Miss
.HitOnDistance:         ld      (found_distance),hl         ; closer system so cache distance and galaxy position
                        ld      hl,(iy+4)                   ; .
                        ld      (found_system),hl           ; .
.Miss                   inc     iy
                        inc     iy
                        inc     iy
                        inc     iy
                        inc     iy
                        inc     iy
                        dec     ixl
                        jp      nz,.SearchLoop
                        ClearCarryFlag
                        ld      bc,(found_system)
                        ret
.NoHit:                 SetCarryFlag
                        ret
                        ; X14YAD cur 91 => -1 => -4 (needs to be ABS shift in cursor to chart)

;----------------------------------------------------------------------------------------------------------------------------------
srm_calc_cur_jumpable:  ld      hl,(SRM_cursor_x)
                        ld      bc, srm_star_x_centre + 15
                        ClearCarryFlag
                        sbc     hl,bc
                        jp      p,.PositiveX
.NegativeX:             NegHL                           ; we want ABS
.PositiveX:             ld      a,h                     ; if its > 256 then stupid distance and abort
                        and     a
                        jp      nz,.tooFar
                        ld      a,l
                        and     %10000000               ; elimiate further than 127
                        jp      nz,.tooFar
                        ex      hl,de
                        ld      hl,(SRM_cursor_y)
                        ld      bc, srm_star_y_centre - 15
                        ClearCarryFlag
                        sbc     hl,bc
                        jp      p,.PositiveY
.NegativeY:             NegHL
.PositiveY:             ld      a,h
                        and     a
                        jp      nz,.tooFar
                        ld      a,l
                        and     %10000000               ; elimiate further than 127
                        jp      nz,.tooFar
.CalcDist:              ld      d,e                     ; de = y^2
                        mul     de                      ; .
                        ex      de,hl                   ; move to hl
                        ld      d,e                     ; de = x^2
                        mul     de                      ; .
                        add     hl,de                   ; . = x^2 + y^2
                        ex      de,hl                   ; .
                        call    asm_sqrt                ; hl = de, i.e. sqrt(x^2 + y^2)
                        ld      a,h
                        and     a
                        jp      nz,.tooFar
                        ld      a,l
                        JumpIfAGTENusng 0x96,.tooFar
                        ClearCarryFlag
                        ret
.tooFar:                SetCarryFlag
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
srm_BoundsLimit:        pop     af
                        xor     a
                        ret
;---------------------------------------------------------------------------------------------------------------------------------
; prints text based on message data
SRM_print_boiler_text:      
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


SRM_message_timer           EQU 2500
SRM_message_clear_counter   dw  0

SRM_cursor_dampen           equ 75
SRM_cursor_dampen_timer:    DB  0

data_short_range_chart:     ;row  column low high  colr text address low high
SRM_boiler_text             DB 002, low 064, high 064, $FF, low short_rg_chart_header,   high short_rg_chart_header



short_rg_chart_header       DB "Galactic Chart:"
short_rg_chart_current_name DS 20,0

SRM_detail_text:            DB 208, low 16, high 16, $FF, low srm_system_name,     high srm_system_name
SRM_detail_name:            DB 208, low 96, high 96, $FF, low srm_system_title,    high srm_system_title
SRM_detail_dist:            DB 220, low 16, high 16, $FF, low srm_distance,        high srm_distance
SRM_detail_dist_blank:      DB 220, low 16, high 16, $FF, low srm_distance_blank,  high srm_distance_blank

SRM_system_too_far:         DB 208, low 16, high 16, $FF, low srm_system_too_far_txt,  high srm_system_too_far_txt
SRM_detail_dist_blank2:     DB 220, low 16, high 16, $FF, low srm_distance_blank,  high srm_distance_blank

short_range_boiler_text DW $0030 : DB $02 : DW TextBuffer
short_range_header      equ 12
srm_xy_centre           equ $6080
srm_x_centre            equ 160
srm_y_centre            equ $60
srm_star_x_centre       equ 160 ;- 8 ; adjusted for sprite centre
srm_star_y_centre       equ $68 ;- 8 ; adjusted for sprite centre
srm_star_x_centre_char  equ 20 ; (160/2)
local_chart_star_colour equ 216
local_dx                dw 0
local_dy                dw 0
local_max_range_x       equ 20
local_max_range_y       equ $26
local_name_row          dw  0
local_name_col          dw  0   ; Moved to 320 mode
local_name_row_bottom   dw  0
local_name_col_right    dw  0   ; Moved to 320 mode
local_name_len          db  0
local_label_shift_x     equ 3 ; Incluing offset for 320 mode in charactres
local_label_shift_y     equ 32-5 ; Incluing offset for 320 mode in pixels
local_name_row8bit      db 0
local_name_col8bit      dw 0
local_name_col8bitLeft  equ local_name_col8bit
local_name_col8bitRght  equ local_name_col8bit+1
srm_system_too_far_txt  DB "     *** No System in Range ***",0
srm_distance_blank      DB "                                   ",0
srm_system_name         DB "System  : "
srm_system_blank        DB "                     ",0
srm_system_title        DB "                ",0
srm_distance            DB "Distance: "
srm_dist_amount         DB "000"
srm_decimal             DB "."
srm_fraction            DB "0"
srm_dis_ly              DB " Light Years",0
srm_default_dist        DB "  0.0"
SRM_cursor_x            DW  0
SRM_cursor_y            DW  0
srm_distance_val        DS  6
srm_fill_buffer_len     EQU 64
srm_fill_buffer_record  EQU 3
srm_fill_buffer_size    EQU srm_fill_buffer_record * srm_fill_buffer_len                          ; up to 32 labels topx topy lengthx spare
            DISPLAY "TODO: space for occupied cells may mvoe to bit flags"
srm_printed_text        DS  srm_fill_buffer_size                             ; space for occupied cells may move to bit flags later TODO
srm_buffer_size         DB  0
srm_star_cache          DS  (2+2+2)*30    ; Keeps a list of screen xy and chart xy
srm_star_cache_size     DB  0
;----------------------------------------------------------------------------------------------------------------------------------
; Change to display
; now 320 mode, will hold 32 lines by 40 columns (not all can hold text)
; buffer row will have row, col, length as number of characters occupied
; when drawing text, will now draw a line from the star to the text, )poss underline?)
; up to 32 stars in local chart (this will be overkill)
; each entry will be row (pixel), col (pixel), col to (pixel)
srm_320_label_buffer    DS  32 * 4