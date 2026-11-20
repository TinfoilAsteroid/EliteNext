;----------------------------------------------------------------------------------------------------------------------------------
; Solid ships (SOLID_HULL, Documentation/SolidHulls.md): SolidHullDraw, from ProcessShip after CullV2 with the ship's
; universe bank in slot 6 and this (the Layer 2) bank in slot 7.
;   carry set: drawn solid. In order: the hull's faces (sorted), the phase 2 polygons (ports: engines, later entrances
;   and view ports), with SOLID_OUTLINES lines over it (ALL every visible edge, DECORATION only the decoration edges),
;   then the table's lone lines (nose sensor / gun port lines, unless ALL drew them); carry clear: the caller draws the
;   wireframe
; Drawn solid when the model has a face table (Tools/ship_faces.py: ShipSolidFlag $00, copied to UBnkHullSolid), no vertex
; is at or behind the camera (its z from ProcessNodes, in UBnkNodeArray2), and with WIREFRAME_FALLBACK its z is not less
; than WIREFRAME_DISTANCE (eliteNext.asm). The table's polygons are the faces plus any fins (a fin is seen when any face
; its edges are on faces us). The visible ones are painted furthest first (painter's algorithm), each one's depth its
; furthest vertex, so on a hull that isn't convex a nearer face covers a further one. Colours, for now: a batch of 4 per
; ship (by model id), alternating through the faces so each can be seen
    IFDEF SOLID_HULL
SolidMaxFaces           equ 16
SolidFaceList           DS SolidMaxFaces * 5        ; per visible face: depth (16 bit), face table record (16 bit), face nbr
SolidFaceCount          DB 0
SolidPoints             DS PolyMaxPoints * 4        ; a face's screen points for l2_fill_convex_polygon
SolidFaceNbr            DB 0                        ; the record being looked at
SolidVisMask            DW 0                        ; bit f: face f faces us
SolidLinesAt            DW 0                        ; the face table's lone lines
SolidLateAt             DW 0                        ; its phase 2 polygons (ports)
SolidPortColours        DB $49                      ; PortEngine: dark grey (later a thrust colour while manoeuvring)
                        DB $00                      ; PortEntrance: black
SolidColour             DB 0
; RGB 332, 4 a ship, never $E3 (the transparent colour)
SolidColours            DB $E0, $A0, $E4, $80       ; reds
                        DB $1C, $14, $3C, $0C       ; greens
                        DB $03, $02, $27, $01       ; blues
                        DB $FC, $D8, $F4, $B4       ; yellows
                        DB $1F, $17, $3F, $0E       ; cyans
                        DB $C3, $A2, $E7, $82       ; magentas
                        DB $F0, $D0, $EC, $B0       ; oranges
                        DB $B6, $92, $DB, $6D       ; greys

SolidHullDraw:          ld      a,(ShipSolidFlagAddr)       ; a face table?
                        and     a
                        ret     nz                          ; (carry clear: wireframe)
                    IFDEF WIREFRAME_FALLBACK
                        ld      a,(UBnKzsgn)                ; z of 256.0 or more (the sign byte's magnitude): far enough
                        and     SignMask8Bit
                        jr      nz,.FarEnough
                        ld      hl,(UBnKzlo)                ; z (hi.lo) < WIREFRAME_DISTANCE: wireframe
                        ld      de,WIREFRAME_DISTANCE
                        or      a
                        sbc     hl,de
                        jr      nc,.FarEnough
                        or      a                           ; (carry clear: wireframe)
                        ret
.FarEnough:
                    ENDIF
;-- any vertex at or behind the camera: wireframe (its projection means nothing). TransposeXX12ByShipToXX15 clamps such a
;   z to 4, so z < 5 is treated as behind ..........................................................................................
                        ld      a,(VertexCountAddr)
                        ld      b,a
                        ld      hl,UBnkNodeArray2
.BehindLoop:            ld      e,(hl)                      ; z lo
                        inc     hl
                        ld      a,(hl)                      ; z hi (sign magnitude, never negative after the clamp)
                        inc     hl
                        inc     hl
                        inc     hl
                        and     a
                        jr      nz,.InFrontOfCamera
                        ld      a,e
                        cp      5
                        jr      c,.Behind
.InFrontOfCamera:       djnz    .BehindLoop
                        jr      .InFront
.Behind:                or      a                           ; carry clear: wireframe
                        ret
;-- the faces facing us (CullV2's UbnkFaceVisArray) as a mask, bit f = face f ....................................................
.InFront:               ld      hl,0
                        ld      a,(FaceCtX4Addr)
                        srl     a
                        srl     a
                        and     a
                        jr      z,.MaskDone
                        ld      b,a
                        ld      de,UbnkFaceVisArray-1       ; from the last face down, each shifted up one
                        add     de,a
.MaskLoop:              add     hl,hl
                        ld      a,(de)
                        and     a
                        jr      z,.MaskNext
                        inc     l                           ; (bit 0 is clear after the shift)
.MaskNext:              dec     de
                        djnz    .MaskLoop
.MaskDone:              ld      (SolidVisMask),hl
;-- the visible polygons and their depths: each record is DW mask, DB n, n vertex offsets (x4), visible if any face in its
;   mask faces us (a face's mask is its own bit; a fin's, the faces its edges are on) .................................................
                        xor     a
                        ld      (SolidFaceCount),a
                        ld      (SolidFaceNbr),a
                        ld      ix,UBnkHullSolid+1          ; the records (UBnkHullSolid: how many)
                        ld      iy,SolidFaceList
.FaceLoop:              ld      a,(SolidFaceNbr)            ; done every record?
                        ld      hl,UBnkHullSolid
                        cp      (hl)
                        jp      nc,.Sort
                        ld      hl,(SolidVisMask)           ; visible?
                        ld      a,(ix+0)
                        and     l
                        ld      c,a
                        ld      a,(ix+1)
                        and     h
                        or      c
                        jr      z,.NextFace
                        ld      a,(ix+2)                    ; a polygon? (n = 0: a face with no edges)
                        cp      3
                        jr      c,.NextFace
                        ld      a,(SolidFaceCount)          ; room?
                        cp      SolidMaxFaces
                        jr      nc,.NextFace
                        ld      b,(ix+2)                    ; depth = the largest vertex z
                        push    ix
                        pop     hl
                        inc     hl
                        inc     hl
                        inc     hl
                        ld      de,0
.DepthLoop:             push    hl
                        ld      a,(hl)                      ; vertex offset (x4) into the node arrays
                        ld      hl,UBnkNodeArray2
                        add     hl,a
                        ld      a,(hl)
                        inc     hl
                        ld      h,(hl)
                        ld      l,a                         ; hl = z (positive: checked above)
                        or      a
                        sbc     hl,de
                        jr      c,.NotDeeper
                        add     hl,de
                        ex      de,hl                       ; de = the deepest so far
.NotDeeper:             pop     hl
                        inc     hl
                        djnz    .DepthLoop
                        ld      (iy+0),e
                        ld      (iy+1),d
                        push    ix
                        pop     hl
                        ld      (iy+2),l
                        ld      (iy+3),h
                        ld      a,(SolidFaceNbr)
                        ld      (iy+4),a
                        ld      de,5
                        add     iy,de
                        ld      hl,SolidFaceCount
                        inc     (hl)
.NextFace:              ld      a,(ix+2)                    ; next record: 3 + n bytes
                        add     a,3
                        ld      e,a
                        ld      d,0
                        add     ix,de
                        ld      hl,SolidFaceNbr
                        inc     (hl)
                        jp      .FaceLoop
;-- furthest first: insertion sort on the depth, largest first ....................................................................
.Sort:                  ld      (SolidLateAt),ix            ; (past the last record: the phase 2 polygons)
                        ld      a,(SolidFaceCount)
                        cp      2
                        jr      c,.Draw
                        ld      c,1                         ; c = the entry being placed
.SortOuter:             ld      a,c
                        ld      hl,SolidFaceCount
                        cp      (hl)
                        jr      nc,.Draw
                        ld      b,c                         ; b = its position, moving down
.SortInner:             ld      a,b                         ; ix = entry b - 1, iy = entry b
                        dec     a
                        ld      e,a
                        ld      d,5
                        mul     de
                        ld      ix,SolidFaceList
                        add     ix,de
                        ld      de,5
                        push    ix
                        pop     iy
                        add     iy,de
                        ld      l,(ix+0)                    ; in order if depth[b - 1] >= depth[b]
                        ld      h,(ix+1)
                        ld      e,(iy+0)
                        ld      d,(iy+1)
                        or      a
                        sbc     hl,de
                        jr      nc,.Placed
                        push    bc                          ; swap the two entries
                        ld      b,5
.Swap:                  ld      a,(ix+0)
                        ld      e,(iy+0)
                        ld      (ix+0),e
                        ld      (iy+0),a
                        inc     ix
                        inc     iy
                        djnz    .Swap
                        pop     bc
                        dec     b
                        jr      nz,.SortInner
.Placed:                inc     c
                        jr      .SortOuter
;-- each face: its points, its colour, fill ......................................................................................
.Draw:                  ld      a,(SolidFaceCount)
                        and     a
                        jr      z,.Done
                        ld      b,a
                        ld      iy,SolidFaceList
.DrawLoop:              push    bc
                        push    iy
                        ld      l,(iy+2)                    ; hl = the face's record
                        ld      h,(iy+3)
                        ld      a,(iy+4)                    ; colour = SolidColours[(model id & 7) * 4 + (face & 3)]
                        and     3
                        ld      c,a
                        ld      a,(UBnKShipModelId)
                        and     7
                        add     a,a
                        add     a,a
                        add     a,c
                        ld      de,SolidColours
                        add     de,a
                        ld      a,(de)
                        ld      (SolidColour),a
                        inc     hl                          ; (past the mask)
                        inc     hl
                        ld      b,(hl)                      ; n
                        inc     hl
                        push    bc
                        ld      de,SolidPoints              ; copy each vertex's screen x, y (4 bytes)
.PointLoop:             push    bc
                        push    hl
                        ld      a,(hl)                      ; vertex offset (x4)
                        ld      hl,UBnkNodeArray
                        add     hl,a
                        ld      bc,4
                        ldir
                        pop     hl
                        inc     hl
                        pop     bc
                        djnz    .PointLoop
                        pop     bc                          ; b = n
                        ld      ix,SolidPoints
                        ld      a,(SolidColour)
                        call    l2_fill_convex_polygon
                        pop     iy
                        ld      de,5
                        add     iy,de
                        pop     bc
                        djnz    .DrawLoop
.Done:                  call    .LatePolygons               ; the ports, over the hull (and finds the lone lines)
                    IFDEF SOLID_OUTLINES
                      IF SolidOutlinesMode == SolidOutlines_ALL
                        call    PrepLines                   ; every visible edge over the fill (the wireframe's lines)
                      ELSE
                        call    PrepDecorationLines         ; only the visible decoration edges (both faces the same)
                      ENDIF
                        call    DrawLinesLateClipping
                    ENDIF
                    IFDEF SOLID_OUTLINES                    ; the lone lines (ALL has drawn every edge already)
                      IF SolidOutlinesMode != SolidOutlines_ALL
                        call    .LoneLines
                      ENDIF
                    ELSE
                        call    .LoneLines
                    ENDIF
                        scf                                 ; drawn
                        ret
;-- phase 2 (Tools/ship_faces.py PORTS: engine ports, later entrances and view ports): after the records, DB p, then p
;   records: DW mask, DB type, n, n vertex offsets x4. Each is filled when its face faces us, in table order after every
;   hull face, so the hull never paints over them, in SolidPortColours[type]. Leaves SolidLinesAt at the lone lines .........
.LatePolygons:          ld      ix,(SolidLateAt)
                        ld      a,(ix+0)
                        inc     ix
                        and     a
                        jr      z,.LateDone
                        ld      b,a
.LateLoop:              push    bc
                        ld      hl,(SolidVisMask)           ; visible?
                        ld      a,(ix+0)
                        and     l
                        ld      c,a
                        ld      a,(ix+1)
                        and     h
                        or      c
                        jr      z,.LateNext
                        ld      a,(ix+3)                    ; a polygon?
                        cp      3
                        jr      c,.LateNext
                        ld      b,a
                        push    ix
                        pop     hl
                        ld      de,4
                        add     hl,de                       ; hl = its vertices
                        ld      de,SolidPoints              ; each vertex's screen x, y (4 bytes)
.LatePoint:             push    bc
                        push    hl
                        ld      a,(hl)
                        ld      hl,UBnkNodeArray
                        add     hl,a
                        ld      bc,4
                        ldir
                        pop     hl
                        inc     hl
                        pop     bc
                        djnz    .LatePoint
                        ld      a,(ix+2)                    ; the colour by its type (PortEngine, PortEntrance)
                        ld      hl,SolidPortColours
                        add     hl,a
                        ld      a,(hl)
                        push    ix
                        ld      b,(ix+3)
                        ld      ix,SolidPoints
                        call    l2_fill_convex_polygon
                        pop     ix
.LateNext:              ld      a,(ix+3)                    ; next record: 4 + n bytes
                        add     a,4
                        ld      e,a
                        ld      d,0
                        add     ix,de
                        pop     bc
                        djnz    .LateLoop
.LateDone:              ld      (SolidLinesAt),ix
                        ret
;-- the lone lines (Tools/ship_faces.py LONE_LINES: a nose sensor / gun port line, on no face) over the fill: after the
;   records, DB l, then per line DW mask, DB v0 x4, v1 x4; drawn when either of its faces faces us, as the wireframe ......
.LoneLines:             ld      ix,(SolidLinesAt)
                        ld      a,(ix+0)
                        and     a
                        ret     z
                        ld      b,a
                        inc     ix
                        xor     a
                        ld      (UbnkLineArrayLen),a
                        ld      de,UbnkLineArray            ; the line list DrawLinesLateClipping draws: x1, y1, x2, y2
.LineLoop:              ld      hl,(SolidVisMask)           ; visible?
                        ld      a,(ix+0)
                        and     l
                        ld      c,a
                        ld      a,(ix+1)
                        and     h
                        or      c
                        jr      z,.NextLine
                        push    bc                          ; (its ldi count bc down)
                        ld      a,(ix+2)
                        call    getVertexNodeAtAToDE        ; the ends' screen x, y to the list
                        ld      a,(ix+3)
                        call    getVertexNodeAtAToDE
                        pop     bc
                        ld      hl,UbnkLineArrayLen
                        inc     (hl)
.NextLine:              inc     ix
                        inc     ix
                        inc     ix
                        inc     ix
                        djnz    .LineLoop
                        jp      DrawLinesLateClipping       ; (nothing to draw: it returns)
    ENDIF
