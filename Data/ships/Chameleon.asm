Chameleon:	            DB $03, $0F, $A0
                        DW ChameleonEdges
                        DB ChameleonEdgesSize
                        DB $00, $1A
                        DB ChameleonVertSize
                        DB ChameleonEdgesCnt
                        DB $00, $C8
                        DB ChameleonNormalsSize
                        DB $0A, $64, $1D
                        DW ChameleonNormals
                        DB $01, $23
                        DW ChameleonVertices
                        DB 0,0                      ; Type and Tactics
                        DB ShipCanAnger
ChameleonVertices:	    DB $12, $00, $6E, $9F, $25, $01
                        DB $12, $00, $6E, $1F, $34, $01
                        DB $28, $00, $00, $9F, $8B, $25
                        DB $08, $18, $00, $9F, $68, $22
                        DB $08, $18, $00, $1F, $69, $33
                        DB $28, $00, $00, $1F, $9A, $34
                        DB $08, $18, $00, $5F, $7A, $44
                        DB $08, $18, $00, $DF, $7B, $55
                        DB $00, $18, $28, $1F, $36, $02
                        DB $00, $18, $28, $5F, $57, $14
                        DB $20, $00, $28, $BF, $BC, $88
                        DB $00, $18, $28, $3F, $9C, $68
                        DB $20, $00, $28, $3F, $AC, $99
                        DB $00, $18, $28, $7F, $BC, $7A
                        DB $08, $00, $28, $AA, $CC, $CC
                        DB $00, $08, $28, $2A, $CC, $CC
                        DB $08, $00, $28, $2A, $CC, $CC
                        DB $00, $08, $28, $6A, $CC, $CC
ChameleonVertSize:      equ $ - ChameleonVertices
ChameleonEdges:	        DB $1F, $01, $00, $04
                        DB $1F, $02, $00, $20
                        DB $1F, $15, $00, $24
                        DB $1F, $03, $04, $20
                        DB $1F, $14, $04, $24
                        DB $1F, $34, $04, $14
                        DB $1F, $25, $00, $08
                        DB $1F, $26, $0C, $20
                        DB $1F, $36, $10, $20
                        DB $1F, $75, $1C, $24
                        DB $1F, $74, $18, $24
                        DB $1F, $39, $10, $14
                        DB $1F, $4A, $14, $18
                        DB $1F, $28, $08, $0C
                        DB $1F, $5B, $08, $1C
                        DB $1F, $8B, $08, $28
                        DB $1F, $9A, $14, $30
                        DB $1F, $68, $0C, $2C
                        DB $1F, $7B, $1C, $34
                        DB $1F, $69, $10, $2C
                        DB $1F, $7A, $18, $34
                        DB $1F, $8C, $28, $2C
                        DB $1F, $BC, $28, $34
                        DB $1F, $9C, $2C, $30
                        DB $1F, $AC, $30, $34
                        DB $0A, $CC, $38, $3C
                        DB $0A, $CC, $3C, $40
                        DB $0A, $CC, $40, $44
                        DB $0A, $CC, $44, $38
ChameleonEdgesSize:     equ $ - ChameleonEdges
ChameleonEdgesCnt:      equ ChameleonEdgesSize/4
ChameleonNormals:	    DB $1F, $00, $5A, $1F
                        DB $5F, $00, $5A, $1F
                        DB $9F, $39, $4C, $0B
                        DB $1F, $39, $4C, $0B
                        DB $5F, $39, $4C, $0B
                        DB $DF, $39, $4C, $0B
                        DB $1F, $00, $60, $00
                        DB $5F, $00, $60, $00
                        DB $BF, $39, $4C, $0B
                        DB $3F, $39, $4C, $0B
                        DB $7F, $39, $4C, $0B
                        DB $FF, $39, $4C, $0B
                        DB $3F, $00, $00, $60
ChameleonNormalsSize:   equ $ - ChameleonNormals
ChameleonLen:           equ $ - Chameleon
