Iguana:	                DB $01                      ; Number of cargo canisters released when destroyed
                        DW $0DAC                    ; Ship's targetable area LoHi
                        DW IguanaEdges              ; Edge Data
                        DB IguanaEdgesSize          ; Size of Edge Data
                        DB $00                      ; Gun Vertex Byte offset
                        DB $1A                      ; Explosion Count
                        DB IguanaVertSize /6        ; Vertex Count /6
                        DB IguanaVertSize           ; Vertex Count
                        DB IguanaEdgesCnt           ; Edges Count
                        DW $0096                    ; Bounty LoHi
                        DB IguanaNormalsSize        ; Face (Normal) Count
                        DB $0A                      ; Range when it turns to a dot
                        DB $5A                      ; Energy Max
                        DB $21                      ; Speed Max
                        DW IguanaNormals            ; Normals
                        DB $02                      ; Q scaling
                        DB $20 | ShipMissiles3      ; Laser power and Nbr Missiles
                        DW IguanaVertices           ; Verticles Address
                        DB ShipTypeNormal           ; Ship Type
                        DB 0                        ; NewB Tactics
                        DB ShipCanAnger             ; AI Flags
                        DB $80                      ; chance of ECM module
                        DB $FF                              ; Supports Solid Fill = false (faces 0, 1, 2, 3 don't close: wireframe)
                        DW $0000                            ; no solid data
                        DB $00                              ; no solid data


IguanaVertices:	DB $00, $00, $5A, $1F, $23, $01
                DB $00, $14, $1E, $1F, $46, $02
                DB $28, $00, $0A, $9F, $45, $01
                DB $00, $14, $1E, $5F, $57, $13
                DB $28, $00, $0A, $1F, $67, $23
                DB $00, $14, $28, $3F, $89, $46
                DB $28, $00, $1E, $BF, $88, $45
                DB $00, $14, $28, $7F, $89, $57
                DB $28, $00, $1E, $3F, $99, $67
                DB $28, $00, $28, $9E, $11, $00
                DB $28, $00, $28, $1E, $33, $22
                DB $00, $08, $28, $2A, $99, $88
                DB $10, $00, $24, $AA, $88, $88
                DB $00, $08, $28, $6A, $99, $88
                DB $10, $00, $24, $2A, $99, $99

IguanaVertSize: equ $ - IguanaVertices



IguanaEdges:	DB $1F, $02, $00, $04
                DB $1F, $01, $00, $08
                DB $1F, $13, $00, $0C
                DB $1F, $23, $00, $10
                DB $1F, $46, $04, $14
                DB $1F, $45, $08, $18
                DB $1F, $57, $0C, $1C
                DB $1F, $67, $10, $20
                DB $1F, $48, $14, $18
                DB $1F, $58, $18, $1C
                DB $1F, $69, $14, $20
                DB $1F, $79, $1C, $20
                DB $1F, $04, $04, $08
                DB $1F, $15, $08, $0C
                DB $1F, $26, $04, $10
                DB $1F, $37, $0C, $10
                DB $1F, $89, $14, $1C
                DB $1E, $01, $08, $24
                DB $1E, $23, $10, $28
                DB $0A, $88, $2C, $30
                DB $0A, $88, $34, $30
                DB $0A, $99, $2C, $38
                DB $0A, $99, $34, $38

IguanaEdgesSize: equ $ - IguanaEdges


IguanaEdgesCnt: equ IguanaEdgesSize/4


IguanaNormals:          DB $9F, $37, $53, $1B    ;00
                        DB $DF, $37, $53, $1B    ;01
                        DB $1F, $37, $53, $1B    ;02
                        DB $5F, $37, $53, $1B    ;03
                        DB $9F, $20, $40, $00    ;04
                        DB $DF, $20, $40, $00    ;05
                        DB $1F, $20, $40, $00    ;06
                        DB $5F, $20, $40, $00    ;07
                        DB $BF, $2E, $00, $BA    ;08
                        DB $3F, $2E, $00, $BA    ;09


IguanaNormalsSize: equ $ - IguanaNormals
IguanaLen: equ $ - Iguana
