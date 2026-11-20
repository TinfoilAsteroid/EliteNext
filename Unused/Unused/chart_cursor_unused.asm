; Chart cursor code moved out of the build (2026-11-20): nothing reached any of it. Kept for reference.

; ---- from short_range_chart_menu.asm: srm_get_name, an entry point nothing called (it fell into srm_get_seed_name)
srm_get_name:           ld      a,(Galaxy)
                        MMUSelectGalaxyA
                        ld      bc,(TargetSystemX)
                        ld      (GalaxyTargetSystem),bc
                        call    galaxy_system_under_cursor
                        cp      0
                        ret     z

; ---- from short_range_chart_menu.asm: SRM_update_cursor after its early ret (unreachable)
SRM_update_cursor_unreachable:
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

; ---- from short_range_chart_menu.asm: srm_clear_name_area, only called by srm_name_current
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

; ---- from short_range_chart_menu.asm: srm_system_undercursor / srm_name_current, only reached from SRM_update_cursor's unreachable code
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

; ---- from sprite_routines.asm: sprite_lhc_move, only called from SRM_update_cursor's unreachable code
sprite_lhc_move:            ld      a,local_hyper_sprite
                            nextreg SPRITE_PORT_INDEX_REGISTER,a        ; set up sprite id
; write out X position bits 1 to 8
                            ld      a,c
                            ld      hl,spritecursoroffset
                            add     hl,a                                ; hl = full x position
                            ld      a,l
                            nextreg SPRITE_PORT_ATTR0_REGISTER,a        ; Set up lower x cc
; write out Y position bits 1 to 8
                            ex      de,hl                               ; de = full x position
                            ld      a,b
                            ld      hl,spritecursoroffset
                            add     hl,a
                            ld      a,l                                 ; hl = full y position
                            nextreg SPRITE_PORT_ATTR1_REGISTER,a        ; lower y coord on screen
; write out MSB of X as its an anchor  
                            ld      a,d                                 ; de = MSB of X (hl bit 0)
                            nextreg SPRITE_PORT_ATTR2_REGISTER,a        ; lower y
; write out msb of y in h must be bit 0 only
                            ld      a,%00000000                         ; big unified composite
                            or      d                                   ; MSB Y
                            nextreg SPRITE_PORT_ATTR4_REGISTER,a        ; visible 5 bytes pattern e
                            ret
