Bushmaster:	            DB $00, $10, $9A
                        DW BushmasterEdges
                        DB BushmasterEdgesSize
                        DB $00, $1E
                        DB BushmasterVertSize
                        DB BushmasterEdgesCnt
                        DB $00, $96
                        DB BushmasterNormalsSize
                        DB $14, $4A, $23
                        DW BushmasterNormals
                        DB $02, $21
                        DW BushmasterVertices
                        DB 0,0                      ; Type and Tactics
                        DB ShipCanAnger
BushmasterVertices:	    DB $00, $00, $3C, $1F, $23, $01
                        DB $32, $00, $14, $1F, $57, $13
                        DB $32, $00, $14, $9F, $46, $02
                        DB $00, $14, $00, $1F, $45, $01
                        DB $00, $14, $28, $7F, $FF, $FF
                        DB $00, $0E, $28, $3F, $88, $45
                        DB $28, $00, $28, $3F, $88, $57
                        DB $28, $00, $28, $BF, $88, $46
                        DB $00, $04, $28, $2A, $88, $88
                        DB $0A, $00, $28, $2A, $88, $88
                        DB $00, $04, $28, $6A, $88, $88
                        DB $0A, $00, $28, $AA, $88, $88
BushmasterVertSize:     equ $ - BushmasterVertices
BushmasterEdges:	    DB $1F, $13, $00, $04
                        DB $1F, $02, $00, $08
                        DB $1F, $01, $00, $0C
                        DB $1F, $23, $00, $10
                        DB $1F, $45, $0C, $14
                        DB $1F, $04, $08, $0C
                        DB $1F, $15, $04, $0C
                        DB $1F, $46, $08, $1C
                        DB $1F, $57, $04, $18
                        DB $1F, $26, $08, $10
                        DB $1F, $37, $04, $10
                        DB $1F, $48, $14, $1C
                        DB $1F, $58, $14, $18
                        DB $1F, $68, $10, $1C
                        DB $1F, $78, $10, $18
                        DB $0A, $88, $20, $24
                        DB $0A, $88, $24, $28
                        DB $0A, $88, $28, $2C
                        DB $0A, $88, $2C, $20
BushmasterEdgesSize:    equ $ - BushmasterEdges
BushmasterEdgesCnt:     equ BushmasterEdgesSize/4
BushmasterNormals:	    DB $9F, $17, $58, $1D
                        DB $1F, $17, $58, $1D
                        DB $DF, $0E, $5D, $12
                        DB $5F, $0E, $5D, $12
                        DB $BF, $1F, $59, $0D
                        DB $3F, $1F, $59, $0D
                        DB $FF, $2A, $55, $07
                        DB $7F, $2A, $55, $07
                        DB $3F, $00, $00, $60
BushmasterNormalsSize:  equ $ - BushmasterNormals
BushmasterLen:          equ $ - Bushmaster
