Cougar:	                DB $03, $13, $24
                        DW CougarEdges
                        DB CougarEdgesSize
                        DB $00, $2A
                        DB CougarVertSize
                        DB CougarEdgesCnt
                        DB $00, $00
                        DB CougarNormalsSize
                        DB $22, $FC, $28
                        DW CougarNormals
                        DB $02, $34
                        DW CougarVertices
CougarVertices:	        DB $00, $05, $43, $1F, $02, $44
                        DB $14, $00, $28, $9F, $01, $22
                        DB $28, $00, $28, $BF, $01, $55
                        DB $00, $0E, $28, $3E, $04, $55
                        DB $00, $0E, $28, $7E, $12, $35
                        DB $14, $00, $28, $1F, $23, $44
                        DB $28, $00, $28, $3F, $34, $55
                        DB $24, $00, $38, $9F, $01, $11
                        DB $3C, $00, $14, $BF, $01, $11
                        DB $24, $00, $38, $1F, $34, $44
                        DB $3C, $00, $14, $3F, $34, $44
                        DB $00, $07, $23, $12, $00, $44
                        DB $00, $08, $19, $14, $00, $44
                        DB $0C, $02, $2D, $94, $00, $00
                        DB $0C, $02, $2D, $14, $44, $44
                        DB $0A, $06, $28, $B4, $55, $55
                        DB $0A, $06, $28, $F4, $55, $55
                        DB $0A, $06, $28, $74, $55, $55
                        DB $0A, $06, $28, $34, $55, $55
CougarVertSize:         equ $ - CougarVertices	
CougarEdges:	        DB $1F, $02, $00, $04
                        DB $1F, $01, $04, $1C
                        DB $1F, $01, $1C, $20
                        DB $1F, $01, $20, $08
                        DB $1E, $05, $08, $0C
                        DB $1E, $45, $0C, $18
                        DB $1E, $15, $08, $10
                        DB $1E, $35, $10, $18
                        DB $1F, $34, $18, $28
                        DB $1F, $34, $28, $24
                        DB $1F, $34, $24, $14
                        DB $1F, $24, $14, $00
                        DB $1B, $04, $00, $0C
                        DB $1B, $12, $04, $10
                        DB $1B, $23, $14, $10
                        DB $1A, $01, $04, $08
                        DB $1A, $34, $14, $18
                        DB $14, $00, $30, $34
                        DB $12, $00, $34, $2C
                        DB $12, $44, $2C, $38
                        DB $14, $44, $38, $30
                        DB $12, $55, $3C, $40
                        DB $14, $55, $40, $48
                        DB $12, $55, $48, $44
                        DB $14, $55, $44, $3C
CougarEdgesSize:        equ $ - CougarEdges	
CougarEdgesCnt:         equ CougarEdgesSize/4	
CougarNormals:	        DB $9F, $10, $2E, $04
                        DB $DF, $10, $2E, $04
                        DB $5F, $00, $1B, $05
                        DB $5F, $10, $2E, $04
                        DB $1F, $10, $2E, $04
                        DB $3E, $00, $00, $A0
CougarNormalsSize:      equ $ - CougarNormals	
CougarLen:              equ $ - Cougar	
