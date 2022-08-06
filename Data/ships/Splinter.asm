Splinter:	            DB $B0                      ; Number of cargo canisters released when destroyed
                        DW $0100                    ; Ship's targetable area LoHi
                        DW SplinterEdges            ; Edge Data 
                        DB SplinterEdgesSize        ; Size of Edge Data
                        DB $00                      ; Gun Vertex Byte offset
                        DB $16                      ; Explosion Count 
                        DB SplinterVertSize /6      ; Vertex Count /6
                        DB SplinterVertSize         ; Vertex Count
                        DB SplinterEdgesCnt         ; Edges Count
                        DW $0000                    ; Bounty LoHi
                        DB SplinterNormalsSize      ; Face (Normal) Count
                        DB $08                      ; Range when it turns to a dot
                        DB $14                      ; Energy Max
                        DB $0A                      ; Speed Max
                        DW SplinterNormals          ; Normals
                        DB $05                      ; Q scaling
                        DB $00                      ; Laser power and Nbr Missiles
                        DW SplinterVertices         ; Verticles Address
                        DB ShipTypeNormal           ; Ship Type
                        DB 0                        ; NewB Tactics 
                        DB 0                        ; AI Flags            
                        DB $00                      ; chance of ECM module

SplinterVertices:	    DB $18, $19, $10, $DF, $12, $33
                        DB $00, $0C, $0A, $3F, $02, $33
                        DB $0B, $06, $02, $5F, $01, $33
                        DB $0C, $2A, $07, $1F, $01, $22
SplinterVertSize:       equ $ - SplinterVertices
SplinterEdges:	        DB $1F, $23, $00, $04
                        DB $1F, $03, $04, $08
                        DB $1F, $01, $08, $0C
                        DB $1F, $12, $0C, $00
                        DB $1F, $13, $00, $08
                        DB $1F, $02, $0C, $04
SplinterEdgesSize:      equ $ - SplinterEdges
SplinterEdgesCnt:       equ SplinterEdgesSize/4
SplinterNormals:	    DB $1F, $23, $00, $04
                        DB $1F, $03, $04, $08
                        DB $1F, $01, $08, $0C
                        DB $1F, $12, $0C, $00
SplinterNormalsSize:    equ $ - SplinterNormals
SplinterLen:            equ $ - Splinter
