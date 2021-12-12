Fer_De_Lance:	        DB $00, $06, $40
                        DW Fer_De_LanceEdges
                        DB Fer_De_LanceEdgesSize
                        DB $00, $1A
                        DB Fer_De_LanceVertSize
                        DB Fer_De_LanceEdgesCnt
                        DB $00, $00
                        DB Fer_De_LanceNormalsSize
                        DB $28, $A0, $1E
                        DW Fer_De_LanceNormals
                        DB $01, $12
                        DW Fer_De_LanceVertices
                        DB 0,0                      ; Type and Tactics
Fer_De_LanceVertices:	DB $00, $0E, $6C, $5F, $01, $59
                        DB $28, $0E, $04, $FF, $12, $99
                        DB $0C, $0E, $34, $FF, $23, $99
                        DB $0C, $0E, $34, $7F, $34, $99
                        DB $28, $0E, $04, $7F, $45, $99
                        DB $28, $0E, $04, $BC, $01, $26
                        DB $0C, $02, $34, $BC, $23, $67
                        DB $0C, $02, $34, $3C, $34, $78
                        DB $28, $0E, $04, $3C, $04, $58
                        DB $00, $12, $14, $2F, $06, $78
                        DB $03, $0B, $61, $CB, $00, $00
                        DB $1A, $08, $12, $89, $00, $00
                        DB $10, $0E, $04, $AB, $00, $00
                        DB $03, $0B, $61, $4B, $00, $00
                        DB $1A, $08, $12, $09, $00, $00
                        DB $10, $0E, $04, $2B, $00, $00
                        DB $00, $0E, $14, $6C, $99, $99
                        DB $0E, $0E, $2C, $CC, $99, $99
                        DB $0E, $0E, $2C, $4C, $99, $99
Fer_De_LanceVertSize:   equ $ - Fer_De_LanceVertices	
Fer_De_LanceEdges:	    DB $1F, $19, $00, $04
                        DB $1F, $29, $04, $08
                        DB $1F, $39, $08, $0C
                        DB $1F, $49, $0C, $10
                        DB $1F, $59, $00, $10
                        DB $1C, $01, $00, $14
                        DB $1C, $26, $14, $18
                        DB $1C, $37, $18, $1C
                        DB $1C, $48, $1C, $20
                        DB $1C, $05, $00, $20
                        DB $0F, $06, $14, $24
                        DB $0B, $67, $18, $24
                        DB $0B, $78, $1C, $24
                        DB $0F, $08, $20, $24
                        DB $0E, $12, $04, $14
                        DB $0E, $23, $08, $18
                        DB $0E, $34, $0C, $1C
                        DB $0E, $45, $10, $20
                        DB $08, $00, $28, $2C
                        DB $09, $00, $2C, $30
                        DB $0B, $00, $28, $30
                        DB $08, $00, $34, $38
                        DB $09, $00, $38, $3C
                        DB $0B, $00, $34, $3C
                        DB $0C, $99, $40, $44
                        DB $0C, $99, $40, $48
                        DB $08, $99, $44, $48
Fer_De_LanceEdgesSize:  equ $ - Fer_De_LanceEdges	
Fer_De_LanceEdgesCnt:   equ Fer_De_LanceEdgesSize/4	
Fer_De_LanceNormals:	DB $1C, $00, $18, $06
                        DB $9F, $44, $00, $18
                        DB $BF, $3F, $00, $25
                        DB $3F, $00, $00, $68
                        DB $3F, $3F, $00, $25
                        DB $1F, $44, $00, $18
                        DB $BC, $0C, $2E, $13
                        DB $3C, $00, $2D, $16
                        DB $3C, $0C, $2E, $13
                        DB $5F, $00, $1C, $00
Fer_De_LanceNormalsSize:equ $ - Fer_De_LanceNormals	
Fer_De_LanceLen:        equ $ - Fer_De_Lance	
