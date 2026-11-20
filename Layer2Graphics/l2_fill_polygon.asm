;----------------------------------------------------------------------------------------------------------------------------------
; l2_fill_convex_polygon: a convex polygon filled in the 256 x 128 view (256 x 192 Layer 2, rows 0 to 127), for solid ships
; (SOLID_HULL, Documentation/SolidHulls.md). Assembled in every build so it can be tested on its own.
;   in:  ix = points, b of them (3 to PolyMaxPoints): x lo, x hi, y lo, y hi each, 16 bit 2's complement (off screen is
;        fine), a = colour
;   out: nothing; uses every register
; Each edge is walked row by row from its top to its bottom (rows clipped to the view first), with x exact:
; x(y) = xa + sign(dx) * floor((y - ya) * |dx| / dy), stepped as q = |dx| / dy, r = |dx| mod dy per row (one divide an
; edge, and a 32 / 16 divide to start an edge that begins above the view). Each row keeps its smallest and largest x
; (16 bit, so a polygon partly off the side is right), then each row's span is clipped to columns 0 to 255 and drawn with
; l2_draw_horz_line. Both ends of every span are drawn, so faces that share an edge meet with no gap. No winding needed.
; A flat polygon (every point on one row) is that row from its smallest to its largest x.
; Tools/test_lines.py test_fill_convex_polygon checks it pixel for pixel against the same rules in Python
PolyMaxPoints           equ 8
PolyViewRows            equ 128

PolyColour              DB 0
PolyCount               DB 0
PolyPoints              DW 0
PolyTop                 DB 0                        ; rows top to bottom touched, clipped to the view
PolyBottom              DB 0
PolyYMin                DW 0                        ; 16 bit, before clipping
PolyYMax                DW 0
PolyEdgeIndex           DB 0
PolyXA                  DW 0                        ; the edge, ya < yb
PolyYA                  DW 0
PolyXB                  DW 0
PolyYB                  DW 0
PolyDY                  DW 0
PolyQ                   DW 0
PolyR                   DW 0
PolyErr                 DW 0
PolyX                   DW 0
PolyStepNeg             DB 0                        ; non zero: x goes down the edge
PolyRow                 DB 0
PolyEndRow              DB 0
PolyLeft                DS PolyViewRows * 2         ; per row: the smallest x, then
PolyRight               DS PolyViewRows * 2         ; the largest

; carry set if hl < de, both 16 bit signed; hl, de kept, uses a
PolySignedLess:         ld      a,h
                        xor     d
                        jp      m,.SignsDiffer
                        push    hl
                        or      a
                        sbc     hl,de                       ; same signs: unsigned compare is right
                        pop     hl
                        ret
.SignsDiffer:           bit     7,h                         ; hl negative, de not: hl < de
                        scf
                        ret     nz
                        or      a
                        ret

; hl = quotient, de = remainder of de:hl (32 bit) / bc (16 bit, de < bc so the quotient fits 16 bits); uses a
PolyDivide32:           ld      a,16
.Loop:                  add     hl,hl                       ; de:hl << 1
                        rl      e
                        rl      d
                        jr      c,.Subtract                 ; over 16 bits: certainly >= bc
                        push    hl
                        ld      h,d
                        ld      l,e
                        or      a
                        sbc     hl,bc
                        jr      c,.NoSubtract
                        ld      d,h
                        ld      e,l
                        pop     hl
                        inc     l                           ; quotient bit (bit 0 is 0 after the shift)
                        jr      .Next
.NoSubtract:            pop     hl
                        jr      .Next
.Subtract:              ex      de,hl
                        or      a
                        sbc     hl,bc
                        ex      de,hl
                        inc     l
.Next:                  dec     a
                        jr      nz,.Loop
                        ret

l2_fill_convex_polygon: ld      (PolyColour),a
                        ld      a,b
                        cp      3
                        ret     c                           ; not a polygon
                        cp      PolyMaxPoints+1
                        ret     nc
                        ld      (PolyCount),a
                        ld      (PolyPoints),ix
;-- the top and bottom, clipped to the view ......................................................................................
                        ld      hl,$7FFF
                        ld      (PolyYMin),hl
                        ld      hl,$8000
                        ld      (PolyYMax),hl
.YLoop:                 ld      e,(ix+2)
                        ld      d,(ix+3)                    ; de = y
                        ld      hl,(PolyYMin)
                        call    PolySignedLess              ; ymin < y?
                        jr      c,.NotMin
                        ld      (PolyYMin),de
.NotMin:                ld      hl,(PolyYMax)
                        call    PolySignedLess              ; ymax < y?
                        jr      nc,.NotMax
                        ld      (PolyYMax),de
.NotMax:                ld      de,4
                        add     ix,de
                        djnz    .YLoop
                        ld      hl,(PolyYMax)               ; all above the view?
                        bit     7,h
                        ret     nz
                        ld      hl,(PolyYMin)               ; all below it?
                        ld      de,PolyViewRows
                        call    PolySignedLess
                        ret     nc
                        ld      a,h                         ; top = max(ymin, 0)
                        and     a
                        ld      a,l
                        jp      p,.TopOK
                        xor     a
.TopOK:                 ld      (PolyTop),a
                        ld      hl,(PolyYMax)               ; bottom = min(ymax, 127)
                        ld      de,PolyViewRows
                        call    PolySignedLess
                        ld      a,l
                        jr      c,.BottomOK
                        ld      a,PolyViewRows-1
.BottomOK:              ld      (PolyBottom),a
;-- empty rows: left = 32767, right = -32768 ......................................................................................
                        ld      a,(PolyTop)
                        ld      b,a
                        ld      a,(PolyBottom)
                        sub     b
                        inc     a
                        ld      c,a                         ; c = rows
                        ld      l,b
                        ld      h,0
                        add     hl,hl
                        ld      de,PolyLeft
                        add     hl,de                       ; hl = &left[top]
                        ld      de,PolyViewRows*2           ; right[y] is left[y] + 256
.InitLoop:              ld      (hl),$FF
                        inc     hl
                        ld      (hl),$7F
                        dec     hl
                        add     hl,de
                        ld      (hl),$00
                        inc     hl
                        ld      (hl),$80
                        dec     hl
                        or      a
                        sbc     hl,de
                        inc     hl
                        inc     hl
                        dec     c
                        jr      nz,.InitLoop
;-- flat (every point on one row): every edge is horizontal, so skipped, and the row is from the smallest to the largest x
;   (a ship a pixel high, small or edge on, would otherwise vanish) ....................................................................
                        ld      hl,(PolyYMin)
                        ld      de,(PolyYMax)
                        or      a
                        sbc     hl,de
                        jr      nz,.Edges
                        ASSERT  PolyViewRows*2 == 256               ; (right[y] is inc h from left[y])
                        ld      ix,(PolyPoints)
                        ld      a,(PolyCount)
                        ld      b,a
                        ld      a,(PolyTop)                 ; the row (in the view: checked above)
                        ld      l,a
                        ld      h,0
                        add     hl,hl
                        ld      de,PolyLeft
                        add     hl,de                       ; hl = &left[row]
.FlatLoop:              ld      e,(ix+0)
                        ld      d,(ix+1)                    ; de = x
                        push    hl
                        ld      a,(hl)
                        inc     hl
                        ld      h,(hl)
                        ld      l,a                         ; hl = left
                        ex      de,hl
                        call    PolySignedLess              ; x < left?
                        ex      de,hl                       ; de = x
                        pop     hl
                        jr      nc,.NotLeft
                        ld      (hl),e
                        inc     hl
                        ld      (hl),d
                        dec     hl
.NotLeft:               inc     h                           ; &right[row]
                        push    hl
                        ld      a,(hl)
                        inc     hl
                        ld      h,(hl)
                        ld      l,a                         ; hl = right
                        call    PolySignedLess              ; right < x?
                        pop     hl
                        jr      nc,.NotRight
                        ld      (hl),e
                        inc     hl
                        ld      (hl),d
                        dec     hl
.NotRight:              dec     h
                        ld      de,4
                        add     ix,de
                        djnz    .FlatLoop
                        jp      .Spans
;-- the edges ....................................................................................................................
.Edges:                 xor     a
                        ld      (PolyEdgeIndex),a
.EdgeLoop:              ld      ix,(PolyPoints)             ; ix = point i, iy = point i + 1 (wrapping)
                        ld      a,(PolyEdgeIndex)
                        add     a,a
                        add     a,a
                        ld      e,a
                        ld      d,0
                        add     ix,de
                        ld      iy,(PolyPoints)
                        ld      a,(PolyEdgeIndex)
                        inc     a
                        ld      hl,PolyCount
                        cp      (hl)
                        jr      nz,.NoWrap
                        xor     a
.NoWrap:                add     a,a
                        add     a,a
                        ld      e,a
                        add     iy,de
                        call    PolyEdge
                        ld      hl,PolyEdgeIndex
                        inc     (hl)
                        ld      a,(PolyCount)
                        cp      (hl)
                        jr      nz,.EdgeLoop
;-- the spans ....................................................................................................................
.Spans:                 ld      a,(PolyTop)
                        ld      (PolyRow),a
.SpanLoop:              ld      a,(PolyRow)
                        ld      l,a
                        ld      h,0
                        add     hl,hl
                        ld      de,PolyLeft
                        add     hl,de
                        ld      e,(hl)
                        inc     hl
                        ld      d,(hl)                      ; de = left
                        dec     hl
                        ld      bc,PolyViewRows*2
                        add     hl,bc
                        ld      a,(hl)
                        inc     hl
                        ld      h,(hl)
                        ld      l,a                         ; hl = right
                        bit     7,h                         ; right < 0: nothing on screen (also an empty row)
                        jr      nz,.NextSpan
                        ld      a,h                         ; right > 255: 255
                        and     a
                        jr      z,.RightOK
                        ld      hl,255
.RightOK:               bit     7,d                         ; left < 0: 0
                        jr      z,.LeftPositive
                        ld      de,0
.LeftPositive:          ld      a,d                         ; left > 255: nothing on screen
                        and     a
                        jr      nz,.NextSpan
                        ld      a,l                         ; length = right - left + 1, 1 to 256
                        sub     e
                        jr      c,.NextSpan                 ; (left > right: an empty row)
                        inc     a
                        ld      c,e                         ; c = left column
                        jr      z,.FullRow                  ; 256: in two halves (the length is 8 bit)
                        ld      d,a
                        ld      a,(PolyRow)
                        ld      b,a
                        ld      a,(PolyColour)
                        ld      e,a
                        call    l2_draw_horz_line           ; b = row, c = column, d = length, e = colour
                        jr      .NextSpan
.FullRow:               ld      a,(PolyRow)
                        ld      b,a
                        ld      c,0
                        ld      d,128
                        ld      a,(PolyColour)
                        ld      e,a
                        push    bc
                        call    l2_draw_horz_line
                        pop     bc
                        ld      c,128
                        ld      d,128
                        ld      a,(PolyColour)
                        ld      e,a
                        call    l2_draw_horz_line
.NextSpan:              ld      hl,PolyRow
                        ld      a,(PolyBottom)
                        cp      (hl)
                        ret     z
                        inc     (hl)
                        jp      .SpanLoop

;----------------------------------------------------------------------------------------------------------------------------------
; one edge, ix = one end, iy = the other: each of its rows in the view gets its x into PolyLeft / PolyRight
PolyEdge:               ld      l,(ix+2)                    ; order the ends so ya < yb (equal: a horizontal edge, its
                        ld      h,(ix+3)                    ; ends are on the edges either side)
                        ld      e,(iy+2)
                        ld      d,(iy+3)
                        call    PolySignedLess
                        jr      c,.Ordered                  ; ya < yb
                        or      a
                        sbc     hl,de
                        ret     z                           ; horizontal
                        push    ix                          ; swap the ends
                        push    iy
                        pop     ix
                        pop     iy
.Ordered:               ld      l,(ix+0)
                        ld      h,(ix+1)
                        ld      (PolyXA),hl
                        ld      l,(ix+2)
                        ld      h,(ix+3)
                        ld      (PolyYA),hl
                        ld      l,(iy+0)
                        ld      h,(iy+1)
                        ld      (PolyXB),hl
                        ld      l,(iy+2)
                        ld      h,(iy+3)
                        ld      (PolyYB),hl
;-- its rows in the view: ys = max(ya, top), ye = min(yb, bottom) ................................................................
                        ld      a,(PolyTop)                 ; yb < top: above
                        ld      e,a
                        ld      d,0
                        call    PolySignedLess              ; hl = yb
                        ret     c
                        ld      a,(PolyBottom)              ; ye = min(yb, bottom)
                        ld      e,a
                        call    PolySignedLess
                        ld      a,l
                        jr      c,.EndOK
                        ld      a,(PolyBottom)
.EndOK:                 ld      (PolyEndRow),a
                        ld      hl,(PolyYA)                 ; ya > bottom: below
                        ld      a,(PolyBottom)
                        ld      e,a
                        ld      d,0
                        ex      de,hl
                        call    PolySignedLess              ; bottom < ya?
                        ret     c
                        ex      de,hl                       ; hl = ya
                        ld      a,(PolyTop)                 ; ys = max(ya, top)
                        ld      e,a
                        ld      d,0
                        call    PolySignedLess
                        ld      a,l
                        jr      nc,.StartOK
                        ld      a,(PolyTop)
.StartOK:               ld      (PolyRow),a
;-- dy, the x direction, q and r .................................................................................................
                        ld      hl,(PolyYB)
                        ld      de,(PolyYA)
                        or      a
                        sbc     hl,de
                        ld      (PolyDY),hl                 ; dy > 0 (unsigned: the ends can be 32768 apart)
                        ld      hl,(PolyXB)                 ; |dx| and its sign
                        ld      de,(PolyXA)
                        call    PolySignedLess              ; xb < xa?
                        ld      a,0
                        jr      nc,.Right
                        ex      de,hl
                        dec     a
.Right:                 ld      (PolyStepNeg),a
                        or      a
                        sbc     hl,de                       ; hl = |dx|
                        push    hl                          ; (for the start below)
                        ld      de,0
                        ld      bc,(PolyDY)
                        call    PolyDivide32                ; q, r = |dx| / dy
                        ld      (PolyQ),hl
                        ld      (PolyR),de
;-- x and the error at the first row: k = ys - ya, x = xa +- floor(k |dx| / dy), err = k |dx| mod dy ..........................
                        ld      a,(PolyRow)
                        ld      l,a
                        ld      h,0
                        ld      de,(PolyYA)
                        or      a
                        sbc     hl,de                       ; hl = k
                        pop     de                          ; de = |dx|
                        ld      a,h
                        or      l
                        jr      nz,.StartsAbove
                        ld      hl,(PolyXA)                 ; k = 0: x = xa, err = 0
                        ld      (PolyX),hl
                        ld      (PolyErr),hl
                        ld      hl,0
                        ld      (PolyErr),hl
                        jr      .RowLoop
.StartsAbove:           call    mul16                       ; de:hl = k * |dx|
                        ld      bc,(PolyDY)
                        call    PolyDivide32                ; hl = floor(k |dx| / dy), de = the remainder
                        ld      (PolyErr),de
                        call    PolyApplyStep               ; x = xa +- hl
                        ld      (PolyX),hl
;-- each row ...................................................................................................................
.RowLoop:               ld      a,(PolyRow)                 ; hl = &left[row]
                        ld      l,a
                        ld      h,0
                        add     hl,hl
                        ld      de,PolyLeft
                        add     hl,de
                        push    hl
                        ld      e,(hl)
                        inc     hl
                        ld      d,(hl)                      ; de = left
                        ld      hl,(PolyX)
                        call    PolySignedLess              ; x < left?
                        pop     de                          ; de = &left[row]
                        jr      nc,.NotLeft
                        ex      de,hl
                        ld      (hl),e
                        inc     hl
                        ld      (hl),d
                        dec     hl
                        ex      de,hl
.NotLeft:               ld      hl,PolyViewRows*2           ; de = &right[row]
                        add     hl,de
                        push    hl
                        ld      e,(hl)
                        inc     hl
                        ld      d,(hl)                      ; de = right
                        ex      de,hl                       ; hl = right, de = ?
                        ld      de,(PolyX)
                        call    PolySignedLess              ; right < x?
                        pop     hl
                        jr      nc,.NotRight
                        ld      (hl),e
                        inc     hl
                        ld      (hl),d
.NotRight:              ld      hl,PolyRow                  ; done the last row?
                        ld      a,(PolyEndRow)
                        cp      (hl)
                        ret     z
                        inc     (hl)
                        ld      hl,(PolyErr)                ; err += r, x +- q, and +- 1 more when err >= dy
                        ld      de,(PolyR)
                        add     hl,de
                        ld      bc,(PolyDY)
                        jr      c,.Carry                    ; over 65535: >= dy
                        or      a
                        sbc     hl,bc
                        jr      nc,.Carry2                  ; >= dy
                        add     hl,bc
                        ld      (PolyErr),hl
                        ld      hl,(PolyQ)
                        jr      .Step
.Carry:                 or      a
                        sbc     hl,bc
.Carry2:                ld      (PolyErr),hl
                        ld      hl,(PolyQ)
                        inc     hl
.Step:                  push    hl
                        ld      hl,(PolyX)
                        ex      de,hl
                        pop     hl
                        ex      de,hl                       ; hl = x, de = the step
                        ld      a,(PolyStepNeg)
                        and     a
                        jr      nz,.StepLeft
                        add     hl,de
                        jr      .Stepped
.StepLeft:              or      a
                        sbc     hl,de
.Stepped:               ld      (PolyX),hl
                        jp      .RowLoop

; hl = xa + hl (or xa - hl when PolyStepNeg)
PolyApplyStep:          ex      de,hl
                        ld      hl,(PolyXA)
                        ld      a,(PolyStepNeg)
                        and     a
                        jr      nz,.Minus
                        add     hl,de
                        ret
.Minus:                 or      a
                        sbc     hl,de
                        ret
