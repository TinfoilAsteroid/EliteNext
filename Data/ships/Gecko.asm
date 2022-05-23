Gecko:	                DB $00
                        DW $2649
                        DW GeckoEdges
                        DB GeckoEdgesSize
                        DB $00, $1A
                        DB GeckoVertSize /6 
                        DB GeckoVertSize
                        DB GeckoEdgesCnt
                        DB $00, $37
                        DB GeckoNormalsSize
                        DB $12, $46, $1E
                        DW GeckoNormals
                        DB $03, $10
                        DW GeckoVertices
                        DB 0,0                      ; Type and Tactics
                        DB ShipCanAnger
                        DB $60                      ; chance of ECM module
GeckoVertices:	        DB $0A, $04, $2F, $DF, $03, $45
                        DB $0A, $04, $2F, $5F, $01, $23
                        DB $10, $08, $17, $BF, $05, $67
                        DB $10, $08, $17, $3F, $01, $78
                        DB $42, $00, $03, $BF, $45, $66
                        DB $42, $00, $03, $3F, $12, $88
                        DB $14, $0E, $17, $FF, $34, $67
                        DB $14, $0E, $17, $7F, $23, $78
                        DB $08, $06, $21, $D0, $33, $33
                        DB $08, $06, $21, $51, $33, $33
                        DB $08, $0D, $10, $F0, $33, $33
                        DB $08, $0D, $10, $71, $33, $33
GeckoVertSize:          equ $ - GeckoVertices	
GeckoEdges:	            DB $1F, $03, $00, $04
                        DB $1F, $12, $04, $14
                        DB $1F, $18, $14, $0C
                        DB $1F, $07, $0C, $08
                        DB $1F, $56, $08, $10
                        DB $1F, $45, $10, $00
                        DB $1F, $28, $14, $1C
                        DB $1F, $37, $1C, $18
                        DB $1F, $46, $18, $10
                        DB $1D, $05, $00, $08
                        DB $1E, $01, $04, $0C
                        DB $1D, $34, $00, $18
                        DB $1E, $23, $04, $1C
                        DB $14, $67, $08, $18
                        DB $14, $78, $0C, $1C
                        DB $10, $33, $20, $28
                        DB $11, $33, $24, $2C
GeckoEdgesSize:             equ $ - GeckoEdges	
GeckoEdgesCnt:          equ GeckoEdgesSize/4	
GeckoNormals:	        DB $1F, $00, $1F, $05
                        DB $1F, $04, $2D, $08
                        DB $5F, $19, $6C, $13
                        DB $5F, $00, $54, $0C
                        DB $DF, $19, $6C, $13
                        DB $9F, $04, $2D, $08
                        DB $BF, $58, $10, $D6
                        DB $3F, $00, $00, $BB
                        DB $3F, $58, $10, $D6
GeckoNormalsSize:       equ $ - GeckoNormals	
GeckoLen:               equ $ - Gecko	
