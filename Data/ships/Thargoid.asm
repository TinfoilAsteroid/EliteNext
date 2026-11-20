Thargoid:	            DB $00                                                      ; Number of cargo canisters released when destroyed
                        DW $2649                                                    ; Ship's targetable area LoHi
                        DW ThargoidEdges                                            ; Edge Data
                        DB ThargoidEdgesSize                                        ; Size of Edge Data
                        DB $3C                                                      ; Gun Vertex Byte offset
                        DB $26                                                      ; Explosion Count
                        DB ThargoidVertSize /6                                      ; Vertex Count /6
                        DB ThargoidVertSize                                         ; Vertex Count
                        DB ThargoidEdgesCnt                                         ; Edges Count
                        DW $01F4                                                    ; Bounty LoHi
                        DB ThargoidNormalsSize                                      ; Face (Normal) Count
                        DB $37                                                      ; Range when it turns to a dot
                        DB $F0                                                      ; Energy Max
                        DB $27                                                      ; Speed Max
                        DW ThargoidNormals                                          ; Normals
                        DB $02                                                      ; Q scaling
                        DB $16                                                      ; Laser power and Nbr Missiles
                        DW ThargoidVertices                                         ; Verticles Address
                        DB 0                                                        ; Ship Type
                        DB 0                                                        ; NewB Tactics
                        DB ShipCanAnger | ShipFighterBaySize  | ShipFighterThargon  ; AI Flags
                        DB $FF                                                      ; chance of ECM module
                        DB $00                              ; Supports Solid Fill = true (Tools/ship_faces.py)
                        DW ThargoidFaces                  ; face polygons (SOLID_HULL)
                        DB ThargoidFacesSize              ; face table length


ThargoidVertices:	    DB $20, $30, $30, $5F, $40, $88 ; 01
                        DB $20, $44, $00, $5F, $10, $44 ; 02
                        DB $20, $30, $30, $7F, $21, $44 ; 03
                        DB $20, $00, $44, $3F, $32, $44 ; 04
                        DB $20, $30, $30, $3F, $43, $55 ; 05
                        DB $20, $44, $00, $1F, $54, $66 ; 06
                        DB $20, $30, $30, $1F, $64, $77 ; 07
                        DB $20, $00, $44, $1F, $74, $88 ; 08
                        DB $18, $74, $74, $DF, $80, $99 ; 09
                        DB $18, $A4, $00, $DF, $10, $99 ; 10
                        DB $18, $74, $74, $FF, $21, $99 ; 11
                        DB $18, $00, $A4, $BF, $32, $99 ; 12
                        DB $18, $74, $74, $BF, $53, $99 ; 13
                        DB $18, $A4, $00, $9F, $65, $99 ; 14
                        DB $18, $74, $74, $9F, $76, $99 ; 15
                        DB $18, $00, $A4, $9F, $87, $99 ; 16
                        DB $18, $40, $50, $9E, $99, $99 ; 17
                        DB $18, $40, $50, $BE, $99, $99 ; 18
                        DB $18, $40, $50, $FE, $99, $99 ; 19
                        DB $18, $40, $50, $DE, $99, $99 ; 20

ThargoidVertSize: equ $ - ThargoidVertices



ThargoidEdges:	DB $1F, $84, $00, $1C           ;01
                DB $1F, $40, $00, $04           ;02
                DB $1F, $41, $04, $08           ;03
                DB $1F, $42, $08, $0C           ;04
                DB $1F, $43, $0C, $10           ;05
                DB $1F, $54, $10, $14           ;06
                DB $1F, $64, $14, $18           ;07
                DB $1F, $74, $18, $1C           ;08
                DB $1F, $80, $00, $20           ;09
                DB $1F, $10, $04, $24           ;10
                DB $1F, $21, $08, $28           ;11
                DB $1F, $32, $0C, $2C           ;12
                DB $1F, $53, $10, $30           ;13
                DB $1F, $65, $14, $34           ;14
                DB $1F, $76, $18, $38           ;15
                DB $1F, $87, $1C, $3C           ;16
                DB $1F, $98, $20, $3C           ;17
                DB $1F, $90, $20, $24           ;18
                DB $1F, $91, $24, $28
                DB $1F, $92, $28, $2C
                DB $1F, $93, $2C, $30
                DB $1F, $95, $30, $34
                DB $1F, $96, $34, $38
                DB $1F, $97, $38, $3C
                DB $1E, $99, $40, $44
                DB $1E, $99, $48, $4C

ThargoidEdgesSize: equ $ - ThargoidEdges

ThargoidEdgesCnt: equ ThargoidEdgesSize/4

ThargoidNormals:        DB $5F, $CD, $77, $32    ;00
                        DB $7F, $CD, $77, $32    ;01
                        DB $7F, $CD, $32, $77    ;02
                        DB $3F, $CD, $32, $77    ;03
                        DB $1F, $80, $00, $00    ;04
                        DB $3F, $CD, $77, $32    ;05
                        DB $1F, $CD, $77, $32    ;06
                        DB $1F, $CD, $32, $77    ;07
                        DB $5F, $CD, $32, $77    ;08
                        DB $9F, $60, $00, $00    ;09


ThargoidNormalsSize: equ $ - ThargoidNormals
ThargoidLen: equ $ - Thargoid

; --- SOLID_HULL face table: generated by Tools/ship_faces.py from the edges above, do not edit ---
ThargoidFaces:          DB 10                     ; records: DW visible mask, DB n, n vertices x4
                        DW $0001 : DB 4, $00, $04, $24, $20    ; face 0
                        DW $0002 : DB 4, $04, $08, $28, $24    ; face 1
                        DW $0004 : DB 4, $08, $0C, $2C, $28    ; face 2
                        DW $0008 : DB 4, $0C, $10, $30, $2C    ; face 3
                        DW $0010 : DB 8, $00, $1C, $18, $14, $10, $0C, $08, $04    ; face 4
                        DW $0020 : DB 4, $10, $14, $34, $30    ; face 5
                        DW $0040 : DB 4, $14, $18, $38, $34    ; face 6
                        DW $0080 : DB 4, $18, $1C, $3C, $38    ; face 7
                        DW $0100 : DB 4, $00, $1C, $3C, $20    ; face 8
                        DW $0200 : DB 8, $20, $3C, $38, $34, $30, $2C, $28, $24    ; face 9
                        DB 0                        ; phase 2 polygons, drawn after the hull: DW mask, DB type, n, vertices
                        DB 0                        ; lone lines: DW visible mask, DB v0, v1 x4
ThargoidFacesSize       equ $ - ThargoidFaces
; --- end of generated face table ---
