launchship_page_marker  DB "LaunchShipPG65"

launchdraw_table        DB $7E,$3F, $04,$02, $66
launchdraw_rowsize      equ $-launchdraw_table
                        DB $7C,$3E, $08,$04, $66
                        DB $7A,$3D, $0C,$06, $66
                        DB $78,$3C, $10,$08, $66
                        DB $76,$3B, $14,$0A, $66
                        DB $74,$3A, $18,$0C, $66
                        DB $70,$38, $20,$10, $66
                        DB $6C,$36, $28,$14, $05
                        DB $68,$34, $30,$18, $05
                        DB $64,$32, $38,$1C, $05
                        DB $60,$30, $40,$20, $05
                        DB $5C,$2E, $48,$24, $05
                        DB $58,$2C, $50,$28, $02
                        DB $54,$2A, $58,$2C, $02
                        DB $50,$28, $60,$30, $02
                        DB $4C,$26, $68,$34, $02
                        DB $46,$23, $74,$3A, $02
                        DB $40,$20, $80,$40, $02
                        DB $38,$1C, $90,$48, $01
                        DB $30,$18, $A0,$50, $01
                        DB $26,$13, $B4,$5A, $01
                        DB $1C,$0E, $C8,$64, $01
                        DB $10,$08, $E0,$70, $00
                        DB $02,$01, $FC,$7E, $00
                        DB $FF

launchtablesize         EQU ($ - launchdraw_table)/launchdraw_rowsize

init_countdown          EQU $FF
launch_countdown        DB  $0000
launch_table_idx        DW launchdraw_table
current_offsetX         db 0
current_offsetY         db 0


LaunchTubeEdges         MMUSelectLayer2
                        ld      bc,$0000
                        ld      de,$0192
.drawLoop1              ld      a,b
                        cp      128
                        jr      z,.DoneEdge
                        push    af
                        push    bc,,de,,bc,,de
                        call    l2_draw_horz_dma_bank
                        pop     bc,,de
                        ld      a,$FF
                        sub     d
                        ld      c,a
                        inc     c
                        call    l2_draw_horz_dma_bank
                        pop     bc,,de
                        ld      a,b
                        cp      64
                        jr      nc,.ReduceLoop
                        inc     d
                        inc     d
                        pop     af
                        inc     b
                        jr      .drawLoop1
.ReduceLoop:            dec     d
                        dec     d
                        pop     af
                        inc     b
                        jr      .drawLoop1
.DoneEdge:              ld      a,$80
                        ld      bc,$0000                        ; Top Left
                        ld      de,$80FF                        ; Bottom Right
                        call    l2_draw_diagonal
                        ld      a,$80
                        ld      bc,$8000                        ; Botom Left
                        ld      de,$00FF                        ; Top Right
                        call    l2_draw_diagonal
                        
                        ld      bc,$0000
                        ld      DE,$0080
                        ld      h,$60
                        ld      l,$55
                        ret

LaunchConsole:          MMUSelectConsoleBank                    ; Draw Console
                        ld      hl,ScreenL1Bottom       
                        ld      de,ConsoleImageData
                        ld      bc, ScreenL1BottomLen
                        call    memcopy_dma
                        ld      hl,ScreenL1AttrBtm       ; now the pointers are in Ubnk its easy to read
                        ld      de,ConsoleAttributes
                        ld      bc, ScreenL1AttrBtmLen
                        call    memcopy_dma
                        ret

draw_launch_ship:       MMUSelectLayer1
                        call    l1_cls
                        call    l1_attr_cls
                        MMUSelectSpriteBank
                        call    sprite_cls_cursors
                        MMUSelectLayer2
                        call    asm_l2_double_buffer_on     
.CurrentBuffer:         ld      a,$FF                           ; Clear upper 2 thirds to white
                        ld      (l2_cls_byte),a
                        call    l2_set_color_upper2
                        ld      a,COLOUR_TRANSPARENT            ; Lower third transparent
                        ld      (l2_cls_byte),a
                        call    l2_cls_lower_third
                        call    LaunchTubeEdges
                        call    LaunchConsole
.NextBuffer:            MMUSelectLayer2
                        call    l2_flip_buffers       
                        ld      a,$FF                           ; Clear upper 2 thirds to white
                        ld      (l2_cls_byte),a
                        call    l2_set_color_upper2
                        ld      a,COLOUR_TRANSPARENT            ; Lower third transparent
                        ld      (l2_cls_byte),a
                        call    l2_cls_lower_third
                        call    LaunchTubeEdges
                        call    LaunchConsole
.SetUpTimers:           ld      a,init_countdown
                        ld      (launch_countdown),a
                        ld      hl,launchdraw_table
                        ld      (launch_table_idx),hl
                        xor     a
                        ld      (current_offsetX),a
                        ld      (current_offsetY),a
.SetupGalaxy:           xor     a ; palcehodler as it would cause next macro to fail re initialise all universe banks
                        
                        MaxThrottle
                        ret

loop_launch_ship:       call    LaunchTubeEdges
                        ld      a,init_countdown
                        ld      (launch_countdown),a
                        ld      hl,(launch_table_idx)
                        ld      c,(hl)
                        ld      a,c
                        cp      $FF
                        jr      z,.FinishedLaunch
                        inc     hl
                        ld      b,(hl)                 ; bc = top left
                        inc     hl
                        ld      e,(hl)
                        inc     hl
                        ld      d,(hl)                 ;de = width and height
                        inc     hl
                        ld      a,(hl)
                        inc     hl
                        ld      (launch_table_idx),hl
                        ld      h,a
                        push    bc,,de
                        MMUSelectLayer2
                        call    l2_draw_fill_box
                        pop     bc,,de
                        ld      a,$80
                        call    l2_draw_box
                        ret 
.FinishedLaunch:        ld      a,ScreenFront
                        ld      (ScreenTransitionForced),a
                        ret

  
