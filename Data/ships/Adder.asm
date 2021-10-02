Adder:	                DB $00, $09, $C4
                        DW AdderEdges
                        DB AdderEdgesSize
                        DB $00, $16
                        DB AdderVertSize
                        DB AdderEdgesCnt
                        DB $00, $28
                        DB AdderNormalsSize
                        DB $17, $48, $18
                        DW AdderNormals
                        DB $02, $21
                        DW AdderVertices
AdderVertices:	        DB $12, $00, $28, $9F, $01, $BC
                        DB $12, $00, $28, $1F, $01, $23
                        DB $1E, $00, $18, $3F, $23, $45
                        DB $1E, $00, $28, $3F, $45, $66
                        DB $12, $07, $28, $7F, $56, $7E
                        DB $12, $07, $28, $FF, $78, $AE
                        DB $1E, $00, $28, $BF, $89, $AA
                        DB $1E, $00, $18, $BF, $9A, $BC
                        DB $12, $07, $28, $BF, $78, $9D
                        DB $12, $07, $28, $3F, $46, $7D
                        DB $12, $07, $0D, $9F, $09, $BD
                        DB $12, $07, $0D, $1F, $02, $4D
                        DB $12, $07, $0D, $DF, $1A, $CE
                        DB $12, $07, $0D, $5F, $13, $5E
                        DB $0B, $03, $1D, $85, $00, $00
                        DB $0B, $03, $1D, $05, $00, $00
                        DB $0B, $04, $18, $04, $00, $00
                        DB $0B, $04, $18, $84, $00, $00
AdderVertSize:          equ $ - AdderVertices	
AdderEdges:	            DB $1F, $01, $00, $04
                        DB $07, $23, $04, $08
                        DB $1F, $45, $08, $0C
                        DB $1F, $56, $0C, $10
                        DB $1F, $7E, $10, $14
                        DB $1F, $8A, $14, $18
                        DB $1F, $9A, $18, $1C
                        DB $07, $BC, $1C, $00
                        DB $1F, $46, $0C, $24
                        DB $1F, $7D, $24, $20
                        DB $1F, $89, $20, $18
                        DB $1F, $0B, $00, $28
                        DB $1F, $9B, $1C, $28
                        DB $1F, $02, $04, $2C
                        DB $1F, $24, $08, $2C
                        DB $1F, $1C, $00, $30
                        DB $1F, $AC, $1C, $30
                        DB $1F, $13, $04, $34
                        DB $1F, $35, $08, $34
                        DB $1F, $0D, $28, $2C
                        DB $1F, $1E, $30, $34
                        DB $1F, $9D, $20, $28
                        DB $1F, $4D, $24, $2C
                        DB $1F, $AE, $14, $30
                        DB $1F, $5E, $10, $34
                        DB $05, $00, $38, $3C
                        DB $03, $00, $3C, $40
                        DB $04, $00, $40, $44
                        DB $03, $00, $44, $38
AdderEdgesSize:         equ $ - AdderEdges	
AdderEdgesCnt:          equ AdderEdgesSize/4	
AdderNormals:	        DB $1F, $00, $27, $0A
                        DB $5F, $00, $27, $0A
                        DB $1F, $45, $32, $0D
                        DB $5F, $45, $32, $0D
                        DB $1F, $1E, $34, $00
                        DB $5F, $1E, $34, $00
                        DB $3F, $00, $00, $A0
                        DB $3F, $00, $00, $A0
                        DB $3F, $00, $00, $A0
                        DB $9F, $1E, $34, $00
                        DB $DF, $1E, $34, $00
                        DB $9F, $45, $32, $0D
                        DB $DF, $45, $32, $0D
                        DB $1F, $00, $1C, $00
                        DB $5F, $00, $1C, $00
                        
AdderNormalsSize:       equ $ - AdderNormals	
AdderLen:                equ $ - Adder	
