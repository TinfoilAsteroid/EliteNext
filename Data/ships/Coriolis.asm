Coriolis:	            DB $00                                      ; Number of cargo canisters released when destroyed
                        DW $6400                                    ; Ship's targetable area LoHi
                        DW CoriolisEdges                            ; Edge Data
                        DB CoriolisEdgesSize                        ; Size of Edge Data
                        DB $00                                      ; Gun Vertex Byte offset
                        DB $36                                      ; Explosion Count
                        DB CoriolisVertSize /6                      ; Vertex Count /6
                        DB CoriolisVertSize                         ; Vertex Count
                        DB CoriolisEdgesCnt                         ; Edges Count
                        DW $0000                                    ; Bounty LoHi
                        DB CoriolisNormalsSize                      ; Face (Normal) Count
                        DB $78                                      ; Range when it turns to a dot
                        DB $F0                                      ; Energy Max
                        DB $00                                      ; Speed Max
                        DW CoriolisNormals                          ; Normals
                        DB $00                                      ; Q scaling
                        DB $06                                      ; Laser power and Nbr Missiles
                        DW CoriolisVertices                         ; Verticles Address
                        DB ShipTypeStation                          ; Ship Type
                        DB 0                                        ; NewB Tactics
                        DB ShipFighterBaySize | ShipFighterViper    ; AI Flags
                        DB $FF                                      ; chance of ECM module
                        DB $00                              ; Supports Solid Fill = true (Tools/ship_faces.py)
                        DW CoriolisFaces                  ; face polygons (SOLID_HULL)
                        DB CoriolisFacesSize              ; face table length
;Need to do a debug cube and test that, even better a debug square only
; a debug cube would be -160, 160, 160  to -160,160,-160    top left forward     to top left rear         TLF   $A0, $A0, $A0, $9F, $14, $50
;                       -160, 160, 160  to -160,-160,160    top left forward     to bottom left forward   TLR   $A0, $A0, $A0, $BF, $45, $60
;                       -160, 160,-160  to  160,160,-160    top left rear        to top right rear        BLF   $A0, $A0, $A0, $DF, $12, $40
;                       -160, 160,-160  to -160,-160,-160   top left rear        to bottom left rear      TRR   $A0, $A0, $A0, $3F, $35, $60
;                       -160,-160,-160  to -160,-160,-160   bottom left forward  to bottom left rear      BLR   $A0, $A0, $A0, $FF, $24, $60
;                       -160, 160, 160  to  160, 160, 160   top left forward     to top right forward     TRF   $A0, $A0, $A0, $1F, $13, $60
;                       -160,-160, 160  to  160,-160, 160   bottom left forward  to bottom right forward  BRF   $A0, $A0, $A0, $5F, $12, $30
;                       -160,-160,-160  to  160,-160,-160   bottom left rear     to bottom right rear     BRR   $A0, $A0, $A0, $7F, $23, $50
;                        160, 160, 160  to  160, 160,-160   top right forward    to top right rear
;                        160,-160, 160  to  160,-160,-160   bottom right forward to bottom right rear
;                        160, 160, 160  to  160,-160, 160   top right forward    to bottom right forward
;                        160, 160,-160  to  160,-160,-160   top right rear       to bottom right rear
CoriolisVertices:	    ; DB $A0, $A0, $A0, $9F, $14, $50    ; TLF 1
                         DB $A0, $00, $A0, $1F, $10, $62     ; 160,   0 , 160
                         DB $00, $A0, $A0, $1F, $20, $83     ;   0, 160 , 160
                         DB $A0, $00, $A0, $9F, $30, $74     ;-160,   0 , 160
                         DB $00, $A0, $A0, $5F, $10, $54     ;   0,-160 , 160
                         DB $A0, $A0, $00, $5F, $51, $A6     ; 160,-160 ,   0
                         DB $A0, $A0, $00, $1F, $62, $B8     ; 160, 160 ,   0
                         DB $A0, $A0, $00, $9F, $73, $C8     ;-160, 160 ,   0
                         DB $A0, $A0, $00, $DF, $54, $97     ;-160,-160 ,   0
                         DB $A0, $00, $A0, $3F, $A6, $DB     ; 160,   0 ,-160
                         DB $00, $A0, $A0, $3F, $B8, $DC     ;   0, 160 ,-160
                         DB $A0, $00, $A0, $BF, $97, $DC     ;-160,   0 ,-160
                         DB $00, $A0, $A0, $7F, $95, $DA     ;   0,-160 ,-160
                         DB $0A, $1E, $A0, $5E, $00, $00     ; 160, -30 , 160
                         DB $0A, $1E, $A0, $1E, $00, $00     ; 160,  30 , 160
                         DB $0A, $1E, $A0, $9E, $00, $00     ;-160,  30 , 160
                        DB $0A, $1E, $A0, $DE, $00, $00     ;-160, -30 , 160
CoriolisVertSize:       equ $ - CoriolisVertices
CoriolisEdges:	        ; DB $1F, $46, $01, $02

                        DB $1F, $10, $00, $0C
                        DB $1F, $20, $00, $04
                        DB $1F, $30, $04, $08
                        DB $1F, $40, $08, $0C
                        DB $1F, $51, $0C, $10
                        DB $1F, $61, $00, $10
                        DB $1F, $62, $00, $14
                        DB $1F, $82, $14, $04
                        DB $1F, $83, $04, $18
                        DB $1F, $73, $08, $18
                        DB $1F, $74, $08, $1C
                        DB $1F, $54, $0C, $1C
                        DB $1F, $DA, $20, $2C
                        DB $1F, $DB, $20, $24
                        DB $1F, $DC, $24, $28
                        DB $1F, $D9, $28, $2C
                        DB $1F, $A5, $10, $2C
                        DB $1F, $A6, $10, $20
                        DB $1F, $B6, $14, $20
                        DB $1F, $B8, $14, $24
                        DB $1F, $C8, $18, $24
                        DB $1F, $C7, $18, $28
                        DB $1F, $97, $1C, $28
                        DB $1F, $95, $1C, $2C
                        DB $1E, $00, $30, $34
                        DB $1E, $00, $34, $38
                        DB $1E, $00, $38, $3C
                        DB $1E, $00, $3C, $30
CoriolisEdgesSize:      equ $ - CoriolisEdges
CoriolisEdgesCnt:       equ CoriolisEdgesSize/4
CoriolisNormals:	    ; DB $1F, $6B, $00, $00

                        DB $1F, $00, $00, $A0
                        DB $5F, $6B, $6B, $6B
                        DB $1F, $6B, $6B, $6B
                        DB $9F, $6B, $6B, $6B
                        DB $DF, $6B, $6B, $6B
                        DB $5F, $00, $A0, $00
                        DB $1F, $A0, $00, $00
                        DB $9F, $A0, $00, $00
                        DB $1F, $00, $A0, $00
                        DB $FF, $6B, $6B, $6B
                        DB $7F, $6B, $6B, $6B
                        DB $3F, $6B, $6B, $6B
                        DB $BF, $6B, $6B, $6B
                        DB $3F, $00, $00, $A0
CoriolisNormalsSize:    equ $ - CoriolisNormals
CoriolisLen:            equ $ - Coriolis

; --- SOLID_HULL face table: generated by Tools/ship_faces.py from the edges above, do not edit ---
CoriolisFaces:          DB 14                     ; records: DW visible mask, DB n, n vertices x4
                        DW $0001 : DB 4, $00, $0C, $08, $04    ; face 0
                        DW $0002 : DB 3, $00, $0C, $10    ; face 1
                        DW $0004 : DB 3, $00, $04, $14    ; face 2
                        DW $0008 : DB 3, $04, $08, $18    ; face 3
                        DW $0010 : DB 3, $08, $0C, $1C    ; face 4
                        DW $0020 : DB 4, $0C, $10, $2C, $1C    ; face 5
                        DW $0040 : DB 4, $00, $10, $20, $14    ; face 6
                        DW $0080 : DB 4, $08, $18, $28, $1C    ; face 7
                        DW $0100 : DB 4, $14, $04, $18, $24    ; face 8
                        DW $0200 : DB 3, $28, $2C, $1C    ; face 9
                        DW $0400 : DB 3, $20, $2C, $10    ; face 10
                        DW $0800 : DB 3, $20, $24, $14    ; face 11
                        DW $1000 : DB 3, $24, $28, $18    ; face 12
                        DW $2000 : DB 4, $20, $2C, $28, $24    ; face 13
                        DB 1                        ; phase 2 polygons, drawn after the hull: DW mask, DB type, n, vertices
                        DW $0001 : DB PortEntrance, 4, $30, $34, $38, $3C    ; port on face 0
                        DB 0                        ; lone lines: DW visible mask, DB v0, v1 x4
CoriolisFacesSize       equ $ - CoriolisFaces
; --- end of generated face table ---
