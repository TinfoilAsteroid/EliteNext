Ophidian:	            DB $02, $0E, $88
                        DW OphidianEdges
                        DB OphidianEdgesSize
                        DB $00, $3C
                        DB OphidianVertSize
                        DB OphidianEdgesCnt
                        DB $00, $32
                        DB OphidianNormalsSize
                        DB $14, $40, $22
                        DW OphidianNormals
                        DB $01, $1A
                        DW OphidianVertices
OphidianVertices:	    DB $14, $00, $46, $9F, $68, $02
                        DB $14, $00, $46, $1F, $67, $01
                        DB $00, $0A, $28, $1F, $22, $01
                        DB $1E, $00, $1E, $9F, $8A, $24
                        DB $1E, $00, $1E, $1F, $79, $13
                        DB $00, $10, $0A, $1F, $FF, $FF
                        DB $14, $0A, $32, $3F, $9B, $35
                        DB $14, $0A, $32, $BF, $AB, $45
                        DB $1E, $00, $32, $BF, $BB, $4A
                        DB $28, $00, $32, $B0, $FF, $FF
                        DB $1E, $00, $1E, $B0, $FF, $FF
                        DB $1E, $00, $32, $3F, $BB, $39
                        DB $28, $00, $32, $30, $FF, $FF
                        DB $1E, $00, $1E, $30, $FF, $FF
                        DB $00, $0A, $32, $7F, $BB, $9A
                        DB $00, $10, $14, $5F, $FF, $FF
                        DB $0A, $04, $32, $30, $BB, $BB
                        DB $0A, $02, $32, $70, $BB, $BB
                        DB $0A, $02, $32, $F0, $BB, $BB
                        DB $0A, $04, $32, $B0, $BB, $BB

OphidianVertSize:       equ $ - OphidianVertices
OphidianEdges:	        DB $1F, $06, $00, $04
                        DB $1F, $01, $04, $08
                        DB $1F, $02, $00, $08
                        DB $1F, $12, $08, $14
                        DB $1F, $13, $10, $14
                        DB $1F, $24, $0C, $14
                        DB $1F, $35, $14, $18
                        DB $1F, $45, $14, $1C
                        DB $1F, $28, $00, $0C
                        DB $1F, $17, $04, $10
                        DB $1F, $39, $10, $2C
                        DB $1F, $4A, $0C, $20
                        DB $1F, $67, $04, $3C
                        DB $1F, $68, $00, $3C
                        DB $1F, $79, $10, $3C
                        DB $1F, $8A, $0C, $3C
                        DB $1F, $9A, $38, $3C
                        DB $1F, $5B, $18, $1C
                        DB $1F, $3B, $18, $2C
                        DB $1F, $4B, $1C, $20
                        DB $1F, $9B, $2C, $38
                        DB $1F, $AB, $20, $38
                        DB $10, $BB, $40, $44
                        DB $10, $BB, $44, $48
                        DB $10, $BB, $48, $4C
                        DB $10, $BB, $4C, $40
                        DB $10, $39, $30, $34
                        DB $10, $39, $2C, $30
                        DB $10, $4A, $28, $24
                        DB $10, $4A, $24, $20
OphidianEdgesSize:      equ $ - OphidianEdges
OphidianEdgesCnt:       equ OphidianEdgesSize/4

OphidianNormals:	    DB $1F, $00, $25, $0C
                        DB $1F, $0B, $1C, $05
                        DB $9F, $0B, $1C, $05
                        DB $1F, $10, $22, $02
                        DB $9F, $10, $22, $02
                        DB $3F, $00, $25, $03
                        DB $5F, $00, $1F, $0A
                        DB $5F, $0A, $14, $02
                        DB $DF, $0A, $14, $02
                        DB $7F, $12, $20, $02
                        DB $FF, $12, $20, $02
                        DB $3F, $00, $00, $25

OphidianNormalsSize:    equ $ - OphidianNormals
OphidianLen:            equ $ - Ophidian
