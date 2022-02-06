Thargon:	            DB $F0, $06, $40
                        DW ThargonEdges
                        DB ThargonEdgesSize
                        DB $00, $12
                        DB ThargonVertSize
                        DB ThargonEdgesCnt
                        DB $00, $32
                        DB ThargonNormalsSize
                        DB $14, $14, $1E
                        DW ThargonNormals
                        DB $02, $10
                        DW ThargonVertices
                        DB 0,0                      ; Type and Tactics
                        DB ShipCanAnger

	
ThargonVertices:	    DB $09, $00, $28, $9F, $01, $55
                        DB $09, $26, $0C, $DF, $01, $22
                        DB $09, $18, $20, $FF, $02, $33
                        DB $09, $18, $20, $BF, $03, $44
                        DB $09, $26, $0C, $9F, $04, $55
                        DB $09, $00, $08, $3F, $15, $66
                        DB $09, $0A, $0F, $7F, $12, $66
                        DB $09, $06, $1A, $7F, $23, $66
                        DB $09, $06, $1A, $3F, $34, $66
                        DB $09, $0A, $0F, $3F, $45, $66

ThargonVertSize:        equ $ - ThargonVertices	
	
	
ThargonEdges:	        DB $1F, $10, $00, $04
                        DB $1F, $20, $04, $08
                        DB $1F, $30, $08, $0C
                        DB $1F, $40, $0C, $10
                        DB $1F, $50, $00, $10
                        DB $1F, $51, $00, $14
                        DB $1F, $21, $04, $18
                        DB $1F, $32, $08, $1C
                        DB $1F, $43, $0C, $20
                        DB $1F, $54, $10, $24
                        DB $1F, $61, $14, $18
                        DB $1F, $62, $18, $1C
                        DB $1F, $63, $1C, $20
                        DB $1F, $64, $20, $24
                        DB $1F, $65, $24, $14

ThargonEdgesSize:       equ $ - ThargonEdges	
	
	
ThargonEdgesCnt:        equ ThargonEdgesSize/4	
	
	
ThargonNormals:	        DB $9F, $24, $00, $00
                        DB $5F, $14, $05, $07
                        DB $7F, $2E, $2A, $0E
                        DB $3F, $24, $00, $68
                        DB $3F, $2E, $2A, $0E
                        DB $1F, $14, $05, $07
                        DB $1F, $24, $00, $00

	
ThargonNormalsSize:     equ $ - ThargonNormals	
ThargonLen:             equ $ - Thargon	
