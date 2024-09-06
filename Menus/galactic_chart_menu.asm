
galactic_chart_page_marker  DB "GalacticChrtPG51"
                               ;0123456780ABCDEF
;--- Each menu fuction will have the same structure
;    draw_ entry point which jumps to the initial display on selection
;    close_ which handles any special close display events
;    update_ that handles each game loop/frame iteration
draw_g_chart:               jp GCM_galactic_chart

close_g_chart:              ret

update_g_chart:             jp  GCM_update_loop

cursors_g_chart:            jp  GCM_cursors


;..................................................................................................................................
GCM_galactic_chart:         MMUSelectLayer1                         ; initialise display
                            call  l1_cls                            ; .
                            ld      a,7                             ; .
                            call    l1_attr_cls_to_a                ; .
                            MMUSelectLayer2                         ; .
                            call    l2_320_initialise               ; .
                            call    asm_l2_double_buffer_off        ; .
                            call    l2_320_cls                      ; .
                            MMUSelectSpriteBank                     ; .
                            call    sprite_cls_all; sprite_cls_cursors              ; .
                            ld      a,GCM_cursor_dampen
                            ld      (GCM_cursor_dampen_timer),a
.selectPresentSystem:       ld      hl,(PresentSystemX)             ; load present galaxy and system               
                            call    GCM_get_present_system
.drawOuterBorder:           MMUSelectLayer2                         ; draw chart background graphics
                            call    l2_draw_menu_border
.drawTextAreas:             ld      de, 243
                            ld      hl,265
                            ld      b,11
                            ld      c,$C0
                            call    l2_draw_vert_line_320           ;b = row; hl = col, de = length, c = color"
                            ld      b,153
                            ld      hl,2
                            ld      de,262
                            ld      c,$C0
                            call    l2_draw_horz_line_320           ;b = row; hl = col, de = length, c = color"
.generateHeaderText:        ld      a,(Galaxy)                      ; Now print header text
                            sub     91-'0'
                            ld      (galactic_chart_header_nbr),a   ; set chart number
                            ld      b,1                             ; only 1 line to print og boiler text
                            ld      ix,GCM_boiler_text              ; .
                            ;add additional border aroudn stars so we have a column for system info and border at bottom for more 
                            ;system info
                            call    GCM_print_boiler_text           ; .
.plot_stars:                call    GCM_plot_stars                         
.CircleandCrosshair:        call    GCM_chart_postion
                            call    GCM_target_cursor
                            call    GCM_get_current_name
.getTargetName:             call    GCM_get_target_name
                            ret

GCM_get_current_name:       ld      a,(Galaxy)
                            MMUSelectGalaxyA
                            ld      bc,(PresentSystemX)
                            ld      (GalaxyTargetSystem),bc
                            call    galaxy_system_under_cursor          ; TODO for some reason this bit
                            call    GetDigramWorkingSeed
                            ld      hl,name_expanded
                            call    CapitaliseString
                            ld      hl, name_expanded
                            ld      de,galactic_chart_current_name
.copy_target_loop:          ld      a,(hl)
                            ld      (de),a
                            inc     hl
                            inc     de
                            and     a
                            jp      nz,.copy_target_loop
                            ret
;---------------------------------------------------------------------------------------------------------------------------------
GCM_get_target_name:        ld      a,(Galaxy)
                            MMUSelectGalaxyA
                            ld      bc,(TargetSystemX)
                            ld      (GalaxyTargetSystem),bc
                            call    galaxy_system_under_cursor          ; TODO for some reason this bit
                            cp      0                                   ; does not reset cursor on a miss
                            ret     z
.CurrentTargetIsValid:      call    GCM_print_name_if_poss
                            SetMemFalse TextInputMode
                            ret
;----------------------------------------------------------------------------------------------------------------------------------
UpdateGalacticCursor:       ld      bc,(TargetSystemX)              ; bc = selected jump
OnGalacticChart:            call    GCM_target_cursor
                            ld      a,(Galaxy)
                            MMUSelectGalaxyA
                            ld      bc,(TargetSystemX)
                            ld      (GalaxyTargetSystem),bc
                            call    galaxy_system_under_cursor
                            cp      0
                            ret     z
GCM_print_name_if_poss:     call    GetDigramWorkingSeed
                            ; TODOcall    GCM_clear_name_area
                            ld      hl,name_expanded
                            call    CapitaliseString
                            ld      hl, name_expanded
                            ld      de,galactic_chart_target_name
.copy_target_loop:          ld      a,(hl)
                            ld      (de),a
                            inc     hl
                            inc     de
                            and     a
                            jp      nz,.copy_target_loop
                            ld      (de),a
                            call    GCM_calc_distance
                            ld      hl,galactic_chart_distance
                            ld      b,3                             ; 3 lines of system distance
                            ld      ix,GCM_selected_system_block    ; .
                            call    GCM_print_boiler_text           ; .
                            ret

;---------------------------------------------------------------------------------------------------------------------------------
; prints text based on message data
GCM_print_boiler_text:      
.BoilerTextLoop:            push        bc          ; Save Message Count loop value
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
;---------------------------------------------------------------------------------------------------------------------------------
GCM_plot_stars:             xor     a                               ; loop through all stars in galaxy
                            ld      (XSAV),a
                            ld      ix,galaxy_data
.CounterLoop:               ld      a,(Galaxy)                      ; select the current galaxy
                            MMUSelectGalaxyA
                            push    ix
                            pop     hl
                            ld      de,SystemSeed                   ; copy over the System seed
                            call    copy_seed
                            ld      a,(SystemSeed+3)                ; QQ15+3 \ seed w1_h is Xcoord of star
                            ld      c,a                             ; c = X Coord
                            ld      a,(SystemSeed+1)
                            srl     a                               ; Ycoord /2
                            add     a,galactic_chart_y_offset       ; add offset to Y coord of star
                            ld      d,a                             ; d = row on 320 mode call
                            push    bc
                            ld      a,galactic_star_colour
                            MMUSelectLayer2
                            push    hl
                            ld      h,0
                            ld      l,c
                            ld      a,galactic_chart_x_offset
                            add     hl,a
                            ld      a,(SystemSeed+4)
                            or      $50
                            cp      $90
                            jr      nc,.TwoPixles
.OnePixel:                  call    l2_plot_pixel_320               ; d= row number, hl = column number, e = pixel col
                            jp      .DonePixels
.TwoPixles:                 push    de,,hl
                            ld      e,galactic_star_colour
                            call    l2_plot_pixel_320
                            pop     de,,hl
                            inc     hl
                            ld      e,galactic_star_colour2
                            call    l2_plot_pixel_320
.DonePixels:                pop     hl
                            pop     bc
                            push    ix
                            pop     hl
                            add     hl,8
                            push    hl
                            pop     ix
                            ld      a,(XSAV)
                            dec     a
                            cp      0
                            ret     z
                            ld      (XSAV),a
                            jr      .CounterLoop
;---------------------------------------------------------------------------------------------------------------------------------
GCM_chart_postion:          ld      bc,(PresentSystemX)             ; bc = present system row col
.OnGalacticChart:           srl     b                               ; b =  row is row / 2
                            push    bc
.CursorSprite:              MMUSelectSpriteBank                     ;
                            call    GCM_position_cursor
                            pop     bc
.CalculateCircle:           ld      a,b
                            add     a,galactic_chart_y_offset
                            ld      b,a
                            ld      a,c
                            add     a,galactic_chart_x_offset
                            ld      c,a
                            ld      a,(Fuel)
                            srl     a
                            srl     a                               ; divide range of fuel by 4 for galactic chart
                            ld      d,a
                            ld      e,$FF
                            MMUSelectLayer2
                            call    GCM_fuel_circle
                            ret
;---------------------------------------------------------------------------------------------------------------------------------
; Lave is AD14 (row col)
GCM_position_cursor:        ld      e,c; temp holding to preserve c
                            ld      hl,galactic_chart_y_offset -15  ; adjust for menu and offset of cursor
                            ld      a,b
                            add     hl,a
                            ld      bc,hl
                            ld      hl,galactic_chart_x_offset -15  ; adjust for menu and offset of cursor
                            ld      a,e
                            add     hl,a
                            ld      d,galactic_cursor_sprite
                            ld      e,0
                            MMUSelectSpriteBank
                            call    sprite_big_full_screen
                            ret
;---------------------------------------------------------------------------------------------------------------------------------
GCM_target_cursor:          ld      bc,(TargetSystemX)              ; bc = present system row col
.OnGalacticChart:           srl     b 
                            ld      e,c; temp holding to preserve c
                            ld      hl,galactic_chart_y_offset - 4  ; adjust for menu and offset of cursor
                            ld      a,b
                            add     hl,a
                            ld      bc,hl
                            ld      hl,galactic_chart_x_offset -4  ; adjust for menu and offset of cursor
                            ld      a,e
                            add     hl,a
                            ld      d,galactic_hyper_sprite         ; d = sprite number
                            ld      e,3                             ; e - pattern
                            MMUSelectSpriteBank
                            call    sprite_single_full_screen
                            ret
;---------------------------------------------------------------------------------------------------------------------------------
GCM_fuel_circle:
; ">l2_draw_circle BC = center row col, d = radius, e = colour"
l2_GCM_circle_320:          ld      a,e
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
                            ld      e,$FF
                            call    l2_plot_pixel_320       ;d= row number, hl = column number, e = pixel col
                            pop     de,,bc,,hl
                            ret

    ;INCLUDE "Menus/print_boiler_text_inlineInclude.asm"
                DISPLAY "TODO: move cursor code"
; TODO MOVE CURSOR CODE

;----------------------------------------------------------------------------------------------------------------------------------
GCM_refresh_input_text: call    GCM_input_to_display
;----------------------------------------------------------------------------------------------------------------------------------
GCM_input_text:         ld      b,1                             ; only 1 line to print og boiler text
                        ld      ix,GCM_find_text                ; .
                        call    GCM_print_boiler_text           ; . 
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
GCM_input_to_display:   MMUSelectKeyboard
                        ld      hl,InputString
                        ld      de,galactic_find_text
.copyLoop:              ld      a,(hl)
                        ld      (de),a
                        and     a
                        ret     z
                        inc     de
                        inc     hl
                        jp      .copyLoop
;----------------------------------------------------------------------------------------------------------------------------------
GCM_input_not_found:    ld      b,1                             ; only 1 line to print og boiler text
                        ld      ix,GCM_not_found_text           ; .
                        call    GCM_print_boiler_text           ; . 
                        ld      hl,GCM_message_timer
                        ld      (GCM_message_clear_counter),hl
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
GCM_input_found:        ld      b,1                             ; only 1 line to print og boiler text
                        ld      ix,GCM_found_text               ; .
                        call    GCM_print_boiler_text           ; . 
                        ld      hl,GCM_message_timer
                        ld      (GCM_message_clear_counter),hl
                        ret
GCM_clear_find_message: ld      b,2                             ; only 1 line to print og boiler text
                        ld      ix,GCM_found_clear              ; .
                        call    GCM_print_boiler_text           ; . 
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
GCM_input_clear:        ld      hl,galactic_find_text  
                        xor     a
                        ld      b,20
.clear_loop:            ld      (hl),a
                        djnz    .clear_loop
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; The main loop handles the find key
GCM_update_loop:        ld      hl,(GCM_message_clear_counter)
                        ld      a,h
                        or      l
                        jp      z,.NoMessage
                        dec     hl
                        ld      a,h
                        or      l
                        jp      nz,.NoMessageUpdate
.ClearMessage:          call    GCM_clear_find_message
                        ld      hl,0
.NoMessageUpdate:       ld      (GCM_message_clear_counter),hl
.NoMessage:             JumpIfMemTrue TextInputMode,GCM_AlreadyInInputMode  ;if we are in input mode then go directly there
.StartFindCheck:        MacroIsKeyPressed c_Pressed_Find                ;Is F pressed
                        ret     nz                                      ;the main loop handles find key 
.FindPressed:           call    GCM_clear_find_message
                        call    GCM_input_clear
                        MMUSelectKeyboard
                        call    initInputText                           ;Initialise find input
                        SetMemTrue TextInputMode                        ;Set input mode to true
.DisplayInputbar:       call    GCM_input_text                          ; now prep the boiler plate input text
                        ret                                             ; and exit so next interation handles new input as we have to rescan keyboard
;Already in input mode post pressing find
GCM_AlreadyInInputMode: MMUSelectKeyboard
                        call    InputName                               ; Call input routine to parse a key
                        CallIfMemTrue InputChanged, GCM_refresh_input_text     ; if keypress or blink refresh
.WasItEnter:            JumpIfMemTrue EnterPressed, .FindEnterPressed   ; if enter was pressed then find
                        ret
.FindEnterPressed:      SetMemFalse EnterPressed                        ; reset enter
                        SetMemFalse TextInputMode                       ; leave input mode
                        ld      a,(Galaxy)                              ; Fetch correct galaxy seed bank into memory
                        MMUSelectGalaxyA
                        ld      hl,galactic_chart_target_name
                        ld      a,(InputCursor)
                        add     hl,a
                        dec     hl
                        ld      (hl),0
                        ld      hl,galactic_find_text
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
                        call    GCM_input_found
                        ret
.FindNoMatch:           ; if not found display "Not found"
                        ; move curor if found
                        call    GCM_input_not_found
                        ret; DOSTUFFHERE
;----------------------------------------------------------------------------------------------------------------------------------
GCM_cursors:            ReturnIfMemTrue TextInputMode
                        ld      a,(GCM_cursor_dampen_timer)             ; if timer has reached zero 
                        or      a                                       ; else carry on with 
                        jp      z,.timerZero                            ; count down of timer
                        dec     a
                        ld      (GCM_cursor_dampen_timer),a
                        ret                                             ; .
.timerZero:             ld      a,(CursorKeysPressed)                   ; Once it gets to zero
                        ReturnIfAIsZero                                 ; it holds that until another eky is pressed
                        ld      b,a
                        ld      a,GCM_cursor_dampen
                        ld      (GCM_cursor_dampen_timer),a
                        ld      a,b
                        rla
                        call   c,gc_DownPressed;gc_UpPressed
                        rla
                        call   c,gc_UpPressed;gc_DownPressed
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
gc_UpPressed:           push    af
                        ld     a,(TargetSystemX+1)
                        JumpIfAEqNusng 1,gc_BoundsLimit
                        dec     a
                        ld      (TargetSystemX+1),a
                        call    UpdateGalacticCursor
                        pop     af
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_DownPressed:         push    af
                        ld     a,(TargetSystemX+1)
                        JumpIfAEqNusng 255,gc_BoundsLimit
                        inc    a
                        ld      (TargetSystemX+1),a
                        call    UpdateGalacticCursor
                        pop     af
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_LeftPressed:         push    af
                        ld     a,(TargetSystemX)
                        JumpIfAEqNusng 1,gc_BoundsLimit
                        dec    a
                        ld      (TargetSystemX),a
                        call    UpdateGalacticCursor
                        pop     af
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_RightPressed:        push    af
                        ld     a,(TargetSystemX)
                        JumpIfAEqNusng 254,gc_BoundsLimit
                        inc    a
                        ld      (TargetSystemX),a
                        call    UpdateGalacticCursor
                        pop     af
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_HomePressed:         push    af
                        ld      hl,(PresentSystemX)
                        ld      (TargetSystemX),hl
                        call    UpdateGalacticCursor
                        pop     af
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_RecenterPressed:     push    af
                        ld      a,(Galaxy)       
                        MMUSelectGalaxyA
                        ld      bc,(TargetSystemX)
                        call    find_nearest_to_bc
                        ld      (TargetSystemX),bc
                        call    UpdateGalacticCursor
                        pop     af
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
gc_BoundsLimit          xor     a
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
GCM_calc_distance:      ld      a,(Galaxy)
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
                        ld      a,(hl)              ;Push last digit to post decimal
                        ld      (galactic_chart_fraction),a
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
GCM_get_present_system: xor     a
                        ld      (XSAV),a                        
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
                        ld  a,(XSAV)
                        dec     a
                        ld      (XSAV),a
                        cp  0
                        ret     z
                        jr      GCCounterLoop

                            ; This section holds constants which are located after the code

; This section holds variables which are now located after the code
data_galactic_chart:          ;row  column low high  colr text address low high
GCM_boiler_text             DB 002, low 096, high 096, $FF, low galactic_chart_header,   high galactic_chart_header
GCM_selected_system_block:
GCM_selected_system_1       DB 168, low 016, high 016, $FF, low galactic_chart_current,  high galactic_chart_current
GCM_selected_system_2       DB 184, low 016, high 016, $FF, low galactic_chart_target,   high galactic_chart_target
GCM_selected_system_3       DB 200, low 016, high 016, $FF, low galactic_chart_distance, high galactic_chart_distance
GCM_find_text:
GCM_find_prompt:            DB 216, low 016, high 016, $FF, low galactic_find_message,   high galactic_find_message
GCM_not_found_text:         DB 232, low 016, high 064, $FF, low galactic_find_no_match,  high galactic_find_no_match
GCM_found_text:             DB 232, low 016, high 064, $FF, low galactic_find_match,     high galactic_find_match
GCM_found_clear:            DB 216, low 016, high 064, $FF, low galactic_find_clear,     high galactic_find_clear
GCM_found_clear2:           DB 232, low 016, high 064, $FF, low galactic_find_clear,     high galactic_find_clear



GCM_message_timer           EQU 2500
GCM_message_clear_counter   dw  0

GCM_cursor_dampen           equ 125
GCM_cursor_dampen_timer:    DB  0

gcEndOfString               DB  0
gcInputText                 DS  31
                            DB  0,0,0,0,0
gcBlank                     DS  32
galactic_star_colour        equ 216
galactic_star_colour2       equ 108
galactic_chart_y_offset     equ 17
galactic_chart_x_offset     equ 5
galactic_chart_hyper_offset equ 4
galactic_chart_hyper_x_offset equ 32 - 4
galactic_chart_hyper_y_offset equ 32 - 4 + 24
galactic_chart_header       DB "Galactic Chart "
galactic_chart_header_nbr   DB  "X",0
galactic_chart_current      DB "Current System:"
galactic_chart_current_name DB "               ",0
galactic_chart_target       DB "Target System :"
galactic_chart_target_name  DB "               ",0
galactic_chart_nofuel       DB "Insuffient Fuel",0
galactic_chart_distance     DB "Distance: "
galactic_chart_dist_amount  DB "000"
galactic_chart_decimal      DB "."
galactic_chart_fraction     DB "0"
galactic_chart_dis_ly       DB " Light Years",0
galactic_default_dist       DB "  0.0",0

galactic_distance           DS  6

galactic_find_message       DB "Find:"
galactic_find_text          DS InputLimit+1,0
galactic_blank_message      DB  "                    ",0
galactic_find_no_match      DB "**-- System Not Found --**",0
galactic_find_match         DB "  **-- System Found --**  ",0
galactic_find_clear         DB "                              ",0
