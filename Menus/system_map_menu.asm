;----------------------------------------------------------------------------------------------------------------------------------
; The system map (the extended keyboard's EDIT key, in flight): a flat top down map of the local system round us, x across
; and z up the screen (ahead is up, as we always look along z), y (height) left out of the plot and shown as a + / - number
; of units beside each body. The sun, the planet and the space station are marked and named, other ships are dots (red if
; hostile). The scale is a power of 2 chosen so the sun, planet and station all fit; ships further out are left off.
; Positions come from SystemMapGather (main memory, as the sun, planet and ship banks page into slot 6, where this code
; is). It is redrawn twice a second (loop_system_map), erasing only what it drew the time before, so it doesn't flicker.
; In BankMenuSystem with the system data screen.
;----------------------------------------------------------------------------------------------------------------------------------
SMapCentreX             equ 160                     ; us
SMapCentreY             equ 134
SMapRadius              equ 104                     ; the furthest a mark is drawn from us on either axis
SMapRefreshFrames       equ FramesPerSecond / 2
SMapLabelRight          equ 180                     ; a body's label goes on its right unless its column is this or more
SMapPrevSize            equ 8                       ; per mark drawn: in use, row, column (2), label row, label column (2), label length
SMapAxisColour          equ L2ColourGREY_4
SMapTextRow             equ 244

smap_title              DB "SYSTEM MAP",0
smap_ahead              DB "UP = AHEAD",0
smap_scale_text         DB "1 PIXEL = ",0
smap_units_text         DB " UNITS",0
smap_sun_name           DB "SUN",0
smap_planet_name        DB "PLANET",0
smap_station_name       DB "STATION",0
smap_spaces             DB "                ",0  ; (16)
; per kind (SystemMapKind 1 to 5): mark size, colour, name (0: no label)
smap_kinds              DB 5, L2ColourYELLOW_1 : DW smap_sun_name
                        DB 5, L2ColourGREEN_1  : DW smap_planet_name
                        DB 3, L2ColourCYAN_1   : DW smap_station_name
                        DB 3, L2ColourWHITE_2  : DW 0
                        DB 3, L2ColourRED_1    : DW 0
smap_powers             DW 10000, 1000, 100, 10, 1

smap_next_refresh       DW 0
smap_shift              DB 0
smap_max                DW 0
smap_obj                DW 0                        ; this object in SystemMapObjects
smap_prv                DW 0                        ; this mark's entry in smap_prev
smap_kind               DB 0
smap_px                 DW 0                        ; x and z on the map (pixels from us, signed)
smap_pz                 DW 0
smap_yint               DW 0                        ; |y| integer part, and its sign byte
smap_ysgn               DB 0
smap_row                DB 0                        ; the mark's centre
smap_col                DW 0
smap_msize              DB 0
smap_mcolour            DB 0
smap_name               DW 0
smap_brow               DB 0                        ; smap_box
smap_bcol               DW 0
smap_bsize              DB 0
smap_bcolour            DB 0
smap_bcount             DB 0
smap_label              DS 32
smap_prev               DS SystemMapMaxObjects * SMapPrevSize
SMapPrevLen             equ $ - smap_prev

;----------------------------------------------------------------------------------------------------------------------------------
draw_system_map:        MMUSelectLayer1
                        call    l1_cls
                        ld      a,7
                        call    l1_attr_cls_to_a
                        MMUSelectLayer2
                        call    asm_l2_double_buffer_off
                        call    l2_320_initialise
                        call    l2_320_cls
                        MMUSelectSpriteBank
                        call    sprite_cls_all
                        MMUSelectLayer2
                        call    l2_draw_menu_border
                        ld      b,2
                        ld      hl,(320 - 10 * 8) / 2
                        ld      de,smap_title
                        ld      c,L2ColourWHITE_1
                        call    l2_print_at_320
                        ld      b,SMapTextRow
                        ld      hl,320 - 8 - 10 * 8
                        ld      de,smap_ahead
                        ld      c,SMapAxisColour
                        call    l2_print_at_320
                        ld      hl,smap_prev                ; nothing drawn yet
                        ld      de,smap_prev+1
                        ld      bc,SMapPrevLen-1
                        ld      (hl),0
                        ldir
                        jp      smap_refresh

; the main loop update: redraw every SMapRefreshFrames frames
loop_system_map:        ld      hl,(FrameCounter16)
                        ld      de,(smap_next_refresh)
                        or      a
                        sbc     hl,de
                        bit     7,h                         ; now - next < 0: not yet
                        ret     nz
;----------------------------------------------------------------------------------------------------------------------------------
smap_refresh:           ld      hl,(FrameCounter16)
                        ld      de,SMapRefreshFrames
                        add     hl,de
                        ld      (smap_next_refresh),hl
                        call    SystemMapGather             ; positions into SystemMapObjects (and this bank back in slot 6)
                        MMUSelectLayer2
                        call    smap_erase
                        call    smap_scale
                        call    smap_draw_axes
                        call    smap_draw_objects
                        call    smap_draw_us                ; (after the marks: the station is often where we are)
                        jp      smap_draw_scale

;----------------------------------------------------------------------------------------------------------------------------------
; the marks and labels drawn last time, in black
smap_erase:             ld      hl,smap_prev
                        ld      (smap_prv),hl
                        ld      b,SystemMapMaxObjects
.Loop:                  push    bc
                        ld      ix,(smap_prv)
                        ld      a,(ix+0)
                        and     a
                        jr      z,.Next
                        ld      (ix+0),0
                        ld      b,(ix+1)
                        ld      l,(ix+2)
                        ld      h,(ix+3)
                        ld      c,L2ColourBLACK
                        ld      a,5
                        call    smap_box
                        ld      ix,(smap_prv)
                        ld      a,(ix+7)                    ; label length
                        and     a
                        jr      z,.Next
                        ld      hl,smap_spaces+16           ; that many spaces
                        neg
                        add     hl,a                        ; (add hl,a is unsigned: a = 256 - length)
                        dec     h
                        ex      de,hl
                        ld      b,(ix+4)
                        ld      l,(ix+5)
                        ld      h,(ix+6)
                        ld      c,L2ColourBLACK
                        call    l2_print_at_320
.Next:                  ld      hl,(smap_prv)
                        ld      de,SMapPrevSize
                        add     hl,de
                        ld      (smap_prv),hl
                        pop     bc
                        djnz    .Loop
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
; smap_shift: the fewest halvings that bring the largest |x| or |z| (integer part) of the sun, planet and station within
; SMapRadius
smap_scale:             ld      hl,0
                        ld      (smap_max),hl
                        ld      ix,SystemMapObjects
.Loop:                  ld      a,(ix+0)
                        and     a
                        jr      z,.Done
                        cp      SystemMapKindStation+1
                        jr      nc,.Next                    ; (ships don't set the scale)
                        ld      l,(ix+2)                    ; |x|
                        ld      a,(ix+3)
                        and     $7F
                        ld      h,a
                        call    .Max
                        ld      l,(ix+8)                    ; |z|
                        ld      a,(ix+9)
                        and     $7F
                        ld      h,a
                        call    .Max
.Next:                  ld      de,SystemMapObjectSize
                        add     ix,de
                        jr      .Loop
.Max:                   ld      de,(smap_max)
                        or      a
                        sbc     hl,de
                        add     hl,de
                        ret     c
                        ld      (smap_max),hl
                        ret
.Done:                  ld      hl,(smap_max)
                        ld      b,0
.Halve:                 ld      de,SMapRadius+1
                        or      a
                        sbc     hl,de
                        add     hl,de
                        jr      c,.Fits
                        srl     h
                        rr      l
                        inc     b
                        jr      .Halve
.Fits:                  ld      a,b
                        ld      (smap_shift),a
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
smap_draw_axes:         ld      b,SMapCentreY
                        ld      hl,SMapCentreX - SMapRadius
                        ld      de,SMapRadius * 2 + 1
                        ld      c,SMapAxisColour
                        call    l2_draw_horz_line_320
                        ld      b,SMapCentreY - SMapRadius
                        ld      hl,SMapCentreX
                        ld      e,SMapRadius * 2 + 1
                        ld      c,SMapAxisColour
                        jp      l2_draw_vert_line_320

; us: an arrow pointing up (ahead) at the centre
smap_draw_us:           ld      b,SMapCentreY - 5
                        ld      hl,SMapCentreX
                        ld      e,11
                        ld      c,L2ColourWHITE_1
                        call    l2_draw_vert_line_320
                        ld      d,SMapCentreY - 4
                        ld      hl,SMapCentreX - 1
                        ld      e,L2ColourWHITE_1
                        call    l2_plot_pixel_320
                        ld      d,SMapCentreY - 4
                        ld      hl,SMapCentreX + 1
                        ld      e,L2ColourWHITE_1
                        call    l2_plot_pixel_320
                        ld      d,SMapCentreY - 3
                        ld      hl,SMapCentreX - 2
                        ld      e,L2ColourWHITE_1
                        call    l2_plot_pixel_320
                        ld      d,SMapCentreY - 3
                        ld      hl,SMapCentreX + 2
                        ld      e,L2ColourWHITE_1
                        jp      l2_plot_pixel_320

;----------------------------------------------------------------------------------------------------------------------------------
smap_draw_objects:      ld      hl,SystemMapObjects
                        ld      (smap_obj),hl
                        ld      hl,smap_prev
                        ld      (smap_prv),hl
.Loop:                  ld      ix,(smap_obj)
                        ld      a,(ix+0)
                        and     a
                        ret     z
                        ld      (smap_kind),a
                        ld      e,(ix+2)                    ; x
                        ld      d,(ix+3)
                        call    smap_coord
                        ld      (smap_px),hl
                        ld      ix,(smap_obj)
                        ld      e,(ix+8)                    ; z
                        ld      d,(ix+9)
                        call    smap_coord
                        ld      (smap_pz),hl
                        ld      ix,(smap_obj)
                        ld      e,(ix+5)                    ; y, unscaled, for the label
                        ld      a,(ix+6)
                        ld      (smap_ysgn),a
                        and     $7F
                        ld      d,a
                        ld      (smap_yint),de
                        ld      hl,(smap_px)
                        call    smap_off_map
                        jr      c,.Next
                        ld      hl,(smap_pz)
                        call    smap_off_map
                        jr      c,.Next
                        ld      hl,SMapCentreX
                        ld      de,(smap_px)
                        add     hl,de
                        ld      (smap_col),hl
                        ld      a,(smap_pz)                 ; (within SMapRadius, so the low byte will do)
                        ld      b,a
                        ld      a,SMapCentreY
                        sub     b                           ; ahead (z > 0) is up the screen
                        ld      (smap_row),a
                        call    smap_draw_mark
.Next:                  ld      hl,(smap_obj)
                        ld      de,SystemMapObjectSize
                        add     hl,de
                        ld      (smap_obj),hl
                        jr      .Loop

; d = sign byte, e = hi byte: hl = the integer part halved smap_shift times, negated if the sign bit is set
smap_coord:             ld      a,d
                        and     $7F
                        ld      h,a
                        ld      l,e
                        ld      a,(smap_shift)
                        and     a
                        jr      z,.Signed
                        ld      b,a
.Halve:                 srl     h
                        rr      l
                        djnz    .Halve
.Signed:                bit     7,d
                        ret     z
                        NegHL
                        ret

; carry if hl (signed) is further than SMapRadius from 0
smap_off_map:           bit     7,h
                        jr      z,.Positive
                        NegHL
.Positive:              ld      de,SMapRadius+1
                        or      a
                        sbc     hl,de
                        ccf
                        ret

; the mark for smap_kind at smap_row, smap_col, its label for a body, both noted in smap_prev to erase next time
smap_draw_mark:         ld      a,(smap_kind)
                        dec     a
                        add     a,a
                        add     a,a
                        ld      hl,smap_kinds
                        add     hl,a
                        ld      a,(hl)
                        ld      (smap_msize),a
                        inc     hl
                        ld      a,(hl)
                        ld      (smap_mcolour),a
                        inc     hl
                        ld      e,(hl)
                        inc     hl
                        ld      d,(hl)
                        ld      (smap_name),de
                        ld      ix,(smap_prv)
                        ld      (ix+0),1
                        ld      a,(smap_row)
                        ld      (ix+1),a
                        ld      hl,(smap_col)
                        ld      (ix+2),l
                        ld      (ix+3),h
                        ld      (ix+7),0
                        ld      b,a
                        ld      a,(smap_mcolour)
                        ld      c,a
                        ld      a,(smap_msize)
                        call    smap_box
                        ld      de,(smap_name)
                        ld      a,d
                        or      e
                        jr      z,.Done
                        call    smap_make_label             ; a = its length
                        ld      ix,(smap_prv)
                        ld      (ix+7),a
                        ld      e,a                         ; de = length * 8
                        ld      d,8
                        mul     de
                        ld      hl,(smap_col)
                        ld      bc,SMapLabelRight
                        or      a
                        sbc     hl,bc
                        add     hl,bc
                        jr      nc,.OnTheLeft
                        ld      bc,5                        ; on the right
                        add     hl,bc
                        jr      .Place
.OnTheLeft:             or      a
                        sbc     hl,de
                        ld      bc,5
                        or      a
                        sbc     hl,bc
.Place:                 ld      (ix+5),l
                        ld      (ix+6),h
                        ld      a,(smap_row)
                        sub     4
                        ld      (ix+4),a
                        ld      b,a
                        ld      a,(smap_mcolour)
                        ld      c,a
                        ld      de,smap_label
                        call    l2_print_at_320
.Done:                  ld      hl,(smap_prv)
                        ld      de,SMapPrevSize
                        add     hl,de
                        ld      (smap_prv),hl
                        ret

; smap_label = the name at smap_name, a space, + or - and the height |y| (integer part, as the console's distances);
; a = its length
smap_make_label:        ld      hl,(smap_name)
                        ld      de,smap_label
.Name:                  ld      a,(hl)
                        and     a
                        jr      z,.Height
                        ld      (de),a
                        inc     hl
                        inc     de
                        jr      .Name
.Height:                ld      a," "
                        ld      (de),a
                        inc     de
                        ld      hl,(smap_yint)
                        ld      a,h
                        or      l
                        ld      a,"+"
                        jr      z,.Sign                     ; (0 is +)
                        ld      a,(smap_ysgn)
                        and     $80
                        ld      a,"+"
                        jr      z,.Sign
                        ld      a,"-"
.Sign:                  ld      (de),a
                        inc     de
                        call    smap_utoa
                        xor     a
                        ld      (de),a
                        ex      de,hl
                        ld      de,smap_label
                        or      a
                        sbc     hl,de
                        ld      a,l
                        ret

; hl = a number: its digits at de without leading zeros (at least one), de after them
smap_utoa:              push    iy
                        ld      iy,smap_powers
                        ld      b,5
                        ld      c,0                         ; 1 once a digit is written
.Digit:                 push    bc
                        ld      c,(iy+0)
                        ld      b,(iy+1)
                        ld      a,"0"-1
.Count:                 inc     a
                        or      a
                        sbc     hl,bc
                        jr      nc,.Count
                        add     hl,bc
                        pop     bc
                        cp      "0"
                        jr      nz,.Write
                        bit     0,c
                        jr      nz,.Write
                        ld      a,b                         ; a leading 0: only the last digit is written
                        cp      1
                        jr      nz,.Skip
                        ld      a,"0"
.Write:                 ld      (de),a
                        inc     de
                        ld      c,1
.Skip:                  inc     iy
                        inc     iy
                        djnz    .Digit
                        pop     iy
                        ret

; a size x size square centred on b = row, hl = column, in colour c
smap_box:               ld      (smap_bsize),a
                        ld      (smap_bcount),a
                        srl     a
                        ld      e,a
                        ld      d,0
                        or      a
                        sbc     hl,de
                        ld      (smap_bcol),hl
                        ld      a,b
                        sub     e
                        ld      (smap_brow),a
                        ld      a,c
                        ld      (smap_bcolour),a
.Row:                   ld      a,(smap_brow)
                        ld      b,a
                        ld      hl,(smap_bcol)
                        ld      a,(smap_bsize)
                        ld      e,a
                        ld      d,0
                        ld      a,(smap_bcolour)
                        ld      c,a
                        call    l2_draw_horz_line_320
                        ld      hl,smap_brow
                        inc     (hl)
                        ld      hl,smap_bcount
                        dec     (hl)
                        jr      nz,.Row
                        ret

; "1 PIXEL = n UNITS" (n = 2 ^ smap_shift, in the console's distance units), padded so a shorter one covers a longer
smap_draw_scale:        ld      hl,smap_scale_text
                        ld      de,smap_label
.Copy:                  ld      a,(hl)
                        and     a
                        jr      z,.Number
                        ld      (de),a
                        inc     hl
                        inc     de
                        jr      .Copy
.Number:                ld      a,(smap_shift)
                        ld      b,a
                        ld      hl,1
                        and     a
                        jr      z,.HaveN
.Double:                add     hl,hl
                        djnz    .Double
.HaveN:                 call    smap_utoa
                        ld      hl,smap_units_text
.Units:                 ld      a,(hl)
                        ld      (de),a
                        inc     hl
                        inc     de
                        and     a
                        jr      nz,.Units
                        dec     de
                        ld      b,4                         ; room for the number to shrink by up to 4 digits
.Pad:                   ld      a," "
                        ld      (de),a
                        inc     de
                        djnz    .Pad
                        xor     a
                        ld      (de),a
                        ld      b,SMapTextRow
                        ld      hl,8
                        ld      de,smap_label
                        ld      c,L2ColourWHITE_2
                        jp      l2_print_at_320
