
traingleColor           DB     $CF

; ">l2_draw_any_line, bc = y0,x0 de=y1,x1,a=color: determines if its horizontal, vertical or diagonal then hands off the work"
; b - y0 c - x0, d - y1 e - x1 a - colour
l2_draw_any_line:       ex		af,af'              ; save colour into a'
                        ld		a,c                 ; if x and e are the same its horizontal
                        cp		e
                        jr		z,.HorizontalLineCheck
                        ld		a,b                 ; if b and d are the same its vertica;
                        cp		d
                        jr		z,.VerticalLine
; use jp and get a free ret instruction optimisation                        
.DiagonalLine:		    ex		af,af'			     ; get colour back into a
                        jp		l2_draw_diagonal

.HorizontalLineCheck:   ld      a,b
                        cp      d
                        jr      z, .SinglePixel
.HorizontalLine:        ex		af,af'              ; get colour back into a
                        ld		d,e				    ; set d as target right pixel
                        ld		e,a				    ; e holds colour on this call
                        jp		l2_draw_horz_line_to
.VerticalLine:          ex		af,af'
                        ld		e,a				    ; e holds colour on this call
                        jp		l2_draw_vert_line_to
.SinglePixel:           ex		af,af'              ; get colour back into a
                        l2_plot_macro; jp      l2_plot_pixel
                        ret

x1                      dw 0
y1                      dw 0
x2                      dw 0
y2                      dw 0
longest:                DB 0
x1Work:                 DW 0
y1Work:                 DW 0
x2Work:                 DW 0
y2Work:                 DW 0
sign_y                  DB 0
delta_x                 DW 0
delta_y                 DW 0
linetemp                DW 0
error                   DW 0
set_exit                DB 0
InstrDECBC              equ $0B
InstrINCBC              equ $03
InstrDECIY              equ $2B
InstrINCIY              equ $23

;--- Swaps point 1 and point 2 around (i.e x1 y1 <--> x2 y2)
SwapCoords:             ld      hl,(y1)                         ;       then swap point 1 and point 2
                        ld      de,(y2)                         ;       .
                        ld      (y1),de                         ;       .
                        ld      (y2),hl                         ;       .
                        ld      hl,(x1)                         ;       .
                        ld      de,(x2)                         ;       .
                        ld      (x1),de                         ;       .
                        ld      (x2),hl                         ;       .
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
; l2_draw_6502_line - clip and draw a line in the Layer 2 upper two thirds (256x128, rows 0-63 bank 0, rows 64-127 bank 1)
; In : x1,y1,x2,y2 16 bit signed, nominally -1024..+1024 (any value within +/-2047 is safe)
;      colour from line_gfx_colour, Layer 2 code bank paged in (MMUSelectLayer2)
; Out: carry set   - line wholly outside the window, nothing drawn
;      carry clear - line drawn, x1,y1,x2,y2 hold the clipped end points (high bytes 0)
;      AF, BC, DE, HL, AF' destroyed, IX and IY preserved
; y1 = y2           horizontal, clamped without any maths, P1 = P2 plots a single pixel, long spans are a DMA fill
; x1 = x2           vertical, clamped without any maths, column fill split at the bank 0/1 boundary
; otherwise         Cohen-Sutherland outcodes for trivial accept/reject, edge intersections via 12x12 multiply and
;                   24/16 divide (rounded), then the clipped line is re-checked for pixel/horz/vert before an 8 bit Bresenham
;----------------------------------------------------------------------------------------------------------------------------------
L2L_OC_LEFT_BIT         equ     0
L2L_OC_RIGHT_BIT        equ     1
L2L_OC_TOP_BIT          equ     2
L2L_OC_BOTTOM_BIT       equ     3
L2L_OC_LEFT             equ     1 << L2L_OC_LEFT_BIT            ; x < 0
L2L_OC_RIGHT            equ     1 << L2L_OC_RIGHT_BIT           ; x > 255
L2L_OC_TOP              equ     1 << L2L_OC_TOP_BIT             ; y < 0
L2L_OC_BOTTOM           equ     1 << L2L_OC_BOTTOM_BIT          ; y > 127
L2L_CLIP_MAX_X          equ     255
L2L_CLIP_MAX_Y          equ     127
L2L_CLIP_MAX_PASSES     equ     8                               ; Cohen-Sutherland needs at most 4, guards against a rounding loop
L2L_DMA_MIN             equ     20                              ; spans this long or longer use DMA, the program upload costs ~20 pixels of CPU loop
L2L_OPCODE_INC_L        equ     $2C
L2L_OPCODE_DEC_L        equ     $2D
L2L_DMA_WR1_FIXED_TIMED equ     $64                             ; WR1 port A memory, fixed address, timing byte follows
L2L_DMA_WR2_INC_TIMED   equ     $50                             ; WR2 port B memory, incrementing, timing byte follows
L2L_DMA_CYCLE_2T        equ     $02                             ; timing byte, 2 T state cycle length

L2LClipPasses           DB      0
L2LDx                   DB      0
L2LDy                   DB      0
L2LOrigX1               DW      0                               ; original line, all clip intersections are taken from this
L2LOrigY1               DW      0
L2LOrigDx               DW      0
L2LOrigDy               DW      0
L2LOrigAbsDx            DW      0
L2LOrigAbsDy            DW      0

; zxnDMA fill, port A = fixed colour byte, port B = incrementing layer 2 address, continuous mode with 2T cycles
L2LDmaProg:             DB      DMA_DISABLE, DMA_RESET
                        DB      DMA_WRO_BLOCK_PORTA_A2B_XFR     ; WR0 A->B, port A address and length follow
                        DW      L2LDmaColour
L2LDmaLen:              DW      0                               ; zxnDMA mode (port $6B) so this is the exact byte count
                        DB      L2L_DMA_WR1_FIXED_TIMED, L2L_DMA_CYCLE_2T
                        DB      L2L_DMA_WR2_INC_TIMED,   L2L_DMA_CYCLE_2T
                        DB      DMA_WR4_CONT_MODE               ; WR4 continuous, port B address follows
L2LDmaDest:             DW      0
                        DB      DMA_LOAD, DMA_ENABLE
L2LDmaProgLen           equ     $ - L2LDmaProg
L2LDmaColour:           DB      0

l2_draw_6502_line:      ld      hl,(y1)                         ; y1 = y2 -> horizontal or single point
                        ld      de,(y2)
                        or      a
                        sbc     hl,de
                        jp      z,.Horizontal
                        ld      hl,(x1)                         ; x1 = x2 -> vertical
                        ld      de,(x2)
                        or      a
                        sbc     hl,de
                        jp      z,.Vertical
;.......................General case, clip P1 against one edge per pass until both points are inside
                        ld      a,L2L_CLIP_MAX_PASSES
                        ld      (L2LClipPasses),a
.ClipLoop:              ld      hl,(x2)                         ; b = outcode P2
                        ld      de,(y2)
                        call    L2LOutcode
                        ld      b,a
                        ld      hl,(x1)                         ; c = outcode P1, hl = x1 and de = y1 kept for the edge clips
                        ld      de,(y1)
                        call    L2LOutcode
                        ld      c,a
                        or      b                               ; both inside, accept
                        jp      z,.Accept
                        ld      a,c                             ; both outside the same edge, reject
                        and     b
                        jp      nz,L2LNoDraw
                        ld      a,(L2LClipPasses)
                        cp      L2L_CLIP_MAX_PASSES
                        call    z,L2LSaveOriginal               ; first clip needed, remember the original line
                        ld      a,(L2LClipPasses)
                        dec     a
                        jp      z,L2LNoDraw
                        ld      (L2LClipPasses),a
                        ld      a,c                             ; always clip P1, so if P1 is inside swap the points
                        or      a
                        jr      nz,.P1Outside
                        call    SwapCoords
                        ld      c,b
.P1Outside:             bit     L2L_OC_TOP_BIT,c
                        jr      nz,.ClipTop
                        bit     L2L_OC_BOTTOM_BIT,c
                        jr      nz,.ClipBottom
                        bit     L2L_OC_RIGHT_BIT,c
                        jr      nz,.ClipRight
.ClipLeft:              ld      hl,0                            ; x1 = 0
                        jr      .ClipXEdge
.ClipRight:             ld      hl,L2L_CLIP_MAX_X               ; x1 = 255
.ClipXEdge:             ld      (x1),hl                         ; y1 = oy1 + dy * |edge - ox1| / |dx|
                        ld      de,(L2LOrigX1)
                        or      a
                        sbc     hl,de
                        call    L2LAbsHL
                        ex      de,hl
                        ld      bc,(L2LOrigAbsDx)
                        ld      hl,(L2LOrigDy)
                        call    L2LInterp
                        ld      de,(L2LOrigY1)
                        add     hl,de
                        ld      (y1),hl
                        jp      .ClipLoop
.ClipTop:               ld      hl,0                            ; y1 = 0
                        jr      .ClipYEdge
.ClipBottom:            ld      hl,L2L_CLIP_MAX_Y               ; y1 = 127
.ClipYEdge:             ld      (y1),hl                         ; x1 = ox1 + dx * |edge - oy1| / |dy|
                        ld      de,(L2LOrigY1)
                        or      a
                        sbc     hl,de
                        call    L2LAbsHL
                        ex      de,hl
                        ld      bc,(L2LOrigAbsDy)
                        ld      hl,(L2LOrigDx)
                        call    L2LInterp
                        ld      de,(L2LOrigX1)
                        add     hl,de
                        ld      (x1),hl
                        jp      .ClipLoop
.Accept:                ld      a,(x1)
                        ld      c,a
                        ld      a,(y1)
                        ld      b,a
                        ld      a,(x2)
                        ld      e,a
                        ld      a,(y2)
                        ld      d,a
                        jp      L2LDrawClipped
;.......................Horizontal, de = y
.Horizontal:            ld      a,d                             ; y must be 0-127
                        or      a
                        jp      nz,L2LNoDraw
                        ld      a,e
                        cp      L2L_CLIP_MAX_Y+1
                        jp      nc,L2LNoDraw
                        ld      b,a                             ; b = row
                        ld      hl,(x1)
                        ld      de,(x2)
                        or      a
                        sbc     hl,de
                        jr      z,.SinglePoint                  ; P1 = P2
                        add     hl,de                           ; hl = x1 again, add hl leaves S from the sbc
                        jp      m,.HOrdered                     ; x1 < x2
                        ex      de,hl
.HOrdered:              bit     7,d                             ; hl = left, de = right; right end < 0 so all off left
                        jp      nz,L2LNoDraw
                        ld      a,h
                        or      a
                        jr      z,.HLeftIn
                        jp      p,L2LNoDraw                     ; left end > 255 so all off right
                        ld      l,0                             ; clamp left to 0
.HLeftIn:               ld      a,d
                        or      a
                        jr      z,.HRightIn
                        ld      e,L2L_CLIP_MAX_X                ; clamp right to 255
.HRightIn:              ld      c,l
                        ld      d,b
                        jp      L2LDrawClipped
.SinglePoint:           add     hl,de                           ; hl = x
                        ld      a,h
                        or      a
                        jp      nz,L2LNoDraw
                        ld      c,l
                        ld      e,l
                        ld      d,b
                        jp      L2LDrawClipped
;.......................Vertical, de = x
.Vertical:              ld      a,d                             ; x must be 0-255
                        or      a
                        jp      nz,L2LNoDraw
                        ld      c,e                             ; c = column
                        ld      hl,(y1)
                        ld      de,(y2)
                        or      a
                        sbc     hl,de
                        add     hl,de
                        jp      m,.VOrdered                     ; y1 < y2
                        ex      de,hl
.VOrdered:              bit     7,d                             ; hl = top, de = bottom; bottom < 0 so all above
                        jp      nz,L2LNoDraw
                        ld      a,h
                        or      a
                        jr      z,.VTopHiZero
                        jp      p,L2LNoDraw                     ; top > 255 so all below
                        ld      l,0                             ; clamp top to 0
                        jr      .VTopIn
.VTopHiZero:            bit     7,l                             ; top 128-255 so all below
                        jp      nz,L2LNoDraw
.VTopIn:                ld      a,d
                        or      a
                        jr      nz,.VClampBottom
                        bit     7,e
                        jr      z,.VBottomIn
.VClampBottom:          ld      e,L2L_CLIP_MAX_Y
.VBottomIn:             ld      b,l
                        ld      d,e
                        ld      e,c
                        jp      L2LDrawClipped

L2LNoDraw:              scf
                        ret

; c = x1, b = y1, e = x2, d = y2, all inside the window
L2LDrawClipped:         ld      h,0                             ; publish the clipped points
                        ld      l,c
                        ld      (x1),hl
                        ld      l,b
                        ld      (y1),hl
                        ld      l,e
                        ld      (x2),hl
                        ld      l,d
                        ld      (y2),hl
                        ld      a,b
                        cp      d
                        jr      nz,.NotHorizontal
                        ld      a,c
                        cp      e
                        jr      z,.Pixel
                        call    L2LHorizontal
                        or      a
                        ret
.NotHorizontal:         ld      a,c
                        cp      e
                        jr      nz,.Diagonal
                        call    L2LVertical
                        or      a
                        ret
.Diagonal:              call    L2LDiagonal
                        or      a
                        ret
.Pixel:                 ld      l,c
                        ld      a,b
                        call    asm_l2_row_bank_select
                        ld      h,a
                        ld      a,(line_gfx_colour)
                        ld      (hl),a
                        or      a
                        ret

; b = row, c and e = end columns in either order
L2LHorizontal:          ld      a,e
                        sub     c
                        jr      nc,.Ordered
                        neg
                        ld      c,e                             ; c = left column
.Ordered:               ld      e,a                             ; e = pixels - 1
                        ld      l,c
                        ld      a,b
                        call    asm_l2_row_bank_select
                        ld      h,a                             ; hl = left pixel
                        ld      a,e
                        cp      L2L_DMA_MIN-1
                        jr      nc,.DMAFill
                        ld      b,e
                        inc     b
                        ld      a,(line_gfx_colour)
.Loop:                  ld      (hl),a
                        inc     l
                        djnz    .Loop
                        ret
.DMAFill:               ld      (L2LDmaDest),hl
                        ld      d,0
                        inc     de                              ; 1-256 pixels
                        ld      (L2LDmaLen),de
                        ld      a,(line_gfx_colour)
                        ld      (L2LDmaColour),a
                        ld      hl,L2LDmaProg
                        ld      bc,L2LDmaProgLen*256 + IO_DATAGEAR_DMA_PORT
                        otir                                    ; continuous mode, CPU resumes when the fill is done
                        ret

; c = column, b and d = end rows in either order
L2LVertical:            ld      a,d
                        sub     b
                        jr      nc,.Ordered
                        neg
                        ld      b,d                             ; b = top row
.Ordered:               inc     a
                        ld      e,a                             ; e = pixels 1-128
                        ld      l,c
                        ld      a,b
                        ld      d,b                             ; bank select destroys bc
                        call    asm_l2_row_bank_select
                        ld      h,a                             ; hl = top pixel
                        ld      a,d
                        cp      64
                        jr      nc,.LastRun                     ; starts in bank 1 so can't cross
                        ld      a,64
                        sub     h                               ; a = rows left in bank 0
                        cp      e
                        jr      nc,.LastRun                     ; fits in bank 0
                        ld      b,a
                        ld      a,e
                        sub     b
                        ld      e,a                             ; e = rows in bank 1
                        ld      a,(line_gfx_colour)
.Bank0Run:              ld      (hl),a
                        inc     h
                        djnz    .Bank0Run
                        ld      a,64
                        call    asm_l2_row_bank_select
                        ld      h,a
.LastRun:               ld      b,e
                        ld      a,(line_gfx_colour)
.Run:                   ld      (hl),a
                        inc     h
                        djnz    .Run
                        ret

; c = x1, b = y1, e = x2, d = y2, x1 <> x2 and y1 <> y2; drawn top to bottom
L2LDiagonal:            ld      a,d
                        sub     b
                        jr      nc,.YOrdered
                        ld      a,b                             ; swap P1 and P2
                        ld      b,d
                        ld      d,a
                        ld      a,c
                        ld      c,e
                        ld      e,a
                        ld      a,d
                        sub     b
.YOrdered:              ld      (L2LDy),a
                        ld      a,e
                        sub     c
                        ld      e,L2L_OPCODE_INC_L
                        jr      nc,.XRight
                        neg
                        ld      e,L2L_OPCODE_DEC_L
.XRight:                ld      (L2LDx),a
                        ld      a,e                             ; patch x step and colour into both loops
                        ld      (L2LXMajor.Step),a
                        ld      (L2LYMajor.Step),a
                        ld      a,(line_gfx_colour)
                        ld      (L2LXMajor+1),a
                        ld      (L2LYMajor+1),a
                        ld      l,c
                        ld      a,b
                        call    asm_l2_row_bank_select
                        ld      h,a                             ; hl = top pixel
                        ld      a,(L2LDx)
                        ld      d,a                             ; d = dx
                        ld      a,(L2LDy)
                        ld      e,a                             ; e = dy
                        cp      d
                        jr      nc,.YMajor
                        ld      b,d                             ; dx + 1 pixels, dx = 255 gives b = 0 = 256
                        inc     b
                        ld      a,d
                        srl     a
                        ld      c,a                             ; error = dx / 2
                        jp      L2LXMajor
.YMajor:                ld      b,e                             ; dy + 1 pixels
                        inc     b
                        ld      a,e
                        srl     a
                        ld      c,a                             ; error = dy / 2
                        jp      L2LYMajor

; hl = pixel, b = count, c = error, d = dx, e = dy
L2LXMajor:              ld      (hl),0                          ; colour patched
.Step:                  inc     l                               ; inc l / dec l patched
                        ld      a,c
                        sub     e
                        jr      nc,.NoY
                        add     a,d
                        inc     h
                        bit     6,h
                        jr      nz,.NextBank
.NoY:                   ld      c,a
                        djnz    L2LXMajor
                        ret
.NextBank:              call    L2LNextBank
                        jr      .NoY

L2LYMajor:              ld      (hl),0                          ; colour patched
                        inc     h
                        bit     6,h
                        jr      nz,.NextBank
.BankDone:              ld      a,c
                        sub     d
                        jr      nc,.NoX
                        add     a,e
.Step:                  inc     l                               ; inc l / dec l patched
.NoX:                   ld      c,a
                        djnz    L2LYMajor
                        ret
.NextBank:              call    L2LNextBank
                        jr      .BankDone

; row 63 -> 64, the window only spans banks 0 and 1 so the next bank is always 1; preserves af, bc, de, l
L2LNextBank:            push    af
                        push    bc
                        asm_l2_bank_1_macro
                        pop     bc
                        pop     af
                        ld      h,0
                        ret

; hl = x, de = y (16 bit signed) -> a = outcode; bc, de, hl preserved
L2LOutcode:             ld      a,h
                        or      a
                        jr      z,.CheckY                       ; a = 0, x in 0-255
                        ld      a,L2L_OC_LEFT
                        jp      m,.CheckY                       ; flags still from or a
                        ld      a,L2L_OC_RIGHT
.CheckY:                bit     7,d
                        jr      nz,.Top
                        inc     d
                        dec     d
                        jr      nz,.Bottom                      ; y > 255
                        bit     7,e
                        ret     z                               ; y 0-127
.Bottom:                or      L2L_OC_BOTTOM
                        ret
.Top:                   or      L2L_OC_TOP
                        ret

; Intersections always interpolate along the original line, not the part clipped one, so rounding can't
; build up across passes (each clipped point is within 1/2 pixel). Only called once a clip is needed; bc preserved
L2LSaveOriginal:        ld      hl,(x2)                         ; dx = x2 - x1
                        ld      de,(x1)
                        ld      (L2LOrigX1),de
                        or      a
                        sbc     hl,de
                        ld      (L2LOrigDx),hl
                        call    L2LAbsHL
                        ld      (L2LOrigAbsDx),hl
                        ld      hl,(y2)                         ; dy = y2 - y1
                        ld      de,(y1)
                        ld      (L2LOrigY1),de
                        or      a
                        sbc     hl,de
                        ld      (L2LOrigDy),hl
                        call    L2LAbsHL
                        ld      (L2LOrigAbsDy),hl
                        ret

; hl = |hl|, only a and flags otherwise changed
L2LAbsHL:               bit     7,h
                        ret     z
                        xor     a
                        sub     l
                        ld      l,a
                        sbc     a,a
                        sub     h
                        ld      h,a
                        ret

; hl = signed delta, de = numerator, bc = denominator, 0 < numerator <= denominator, |delta| and denominator <= 4095
; -> hl = delta * numerator / denominator rounded to nearest, signed
L2LInterp:              ld      a,h
                        push    af                              ; keep sign of delta
                        or      a
                        jp      p,.DeltaPositive
                        xor     a                               ; hl = |delta|
                        sub     l
                        ld      l,a
                        sbc     a,a
                        sub     h
                        ld      h,a
.DeltaPositive:         push    bc
                        ld      b,h
                        ld      c,l
                        call    L2LMul12                        ; a:hl = |delta| * numerator
                        pop     bc
                        ld      d,b                             ; + denominator / 2 to round
                        ld      e,c
                        srl     d
                        rr      e
                        add     hl,de
                        adc     a,0
;.......................24/16 divide, quotient fits in 12 bits so remainder starts as dividend >> 12
                        ld      d,h                             ; de = low 16 bits
                        ld      e,l
                        ld      l,h                             ; hl = dividend >> 8
                        ld      h,a
                        srl     h                               ; hl = dividend >> 12
                        rr      l
                        srl     h
                        rr      l
                        srl     h
                        rr      l
                        srl     h
                        rr      l
                        ex      de,hl                           ; de = low 12 bits left aligned
                        add     hl,hl
                        add     hl,hl
                        add     hl,hl
                        add     hl,hl
                        ex      de,hl
                        DUP     12
                        rl      e                               ; shift in last (inverted) quotient bit, next dividend bit out
                        rl      d
                        adc     hl,hl                           ; remainder * 2 + bit, < 8192 so carry ends clear
                        sbc     hl,bc
                        jr      nc,$+3
                        add     hl,bc                           ; restore, carry set = quotient bit 0
                        EDUP
                        rl      e
                        rl      d
                        ld      a,e                             ; quotient = ~de & $0FFF
                        cpl
                        ld      l,a
                        ld      a,d
                        cpl
                        and     $0F
                        ld      h,a
                        pop     af
                        or      a
                        ret     p
                        xor     a                               ; negate for a negative delta
                        sub     l
                        ld      l,a
                        sbc     a,a
                        sub     h
                        ld      h,a
                        ret

; bc * de, both <= $0FFF -> a:hl (24 bit), using four 8x8 mul
L2LMul12:               push    de
                        ld      d,c                             ; lo = c * e
                        mul     de
                        ex      de,hl
                        pop     de
                        push    hl
                        ld      a,d                             ; a = d
                        ld      d,b                             ; mid = b * e + c * d
                        mul     de
                        ld      h,d
                        ld      l,e
                        ld      d,c
                        ld      e,a
                        mul     de
                        add     hl,de
                        ld      d,b                             ; hi = b * d
                        ld      e,a
                        mul     de
                        ld      a,e
                        add     a,h
                        ld      b,a                             ; b = hi + mid >> 8
                        ld      c,l
                        pop     hl
                        ld      a,h                             ; result = lo + mid << 8 + hi << 16
                        add     a,c
                        ld      h,a
                        ld      a,b
                        adc     a,0
                        ret
