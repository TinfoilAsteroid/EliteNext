Boa:	                DB $05
                        DW $1324
                        DW BoaEdges
                        DB BoaEdgesSize
                        DB $00, $26
                        DB BoaVertSize /6 
                        DB BoaVertSize
                        DB BoaEdgesCnt
                        DB $00, $00
                        DB BoaNormalsSize
                        DB $28, $FA, $18
                        DW BoaNormals
                        DB $00, $1C
                        DW BoaVertices
                        DB 0,0                      ; Type and Tactics
                        DB ShipCanAnger
                        DB $A0                      ; chance of ECM module
BoaVertices:	        DB $00, $00, $5D, $1F, $FF, $FF ; 01
                        DB $00, $28, $57, $38, $02, $33 ; 02
                        DB $26, $19, $63, $78, $01, $44 ; 03
                        DB $26, $19, $63, $F8, $12, $55 ; 04
                        DB $26, $28, $3B, $BF, $23, $69 ; 05
                        DB $26, $28, $3B, $3F, $03, $6B ; 06
                        DB $3E, $00, $43, $3F, $04, $8B ; 07
                        DB $18, $41, $4F, $7F, $14, $8A ; 08
                        DB $18, $41, $4F, $FF, $15, $7A ; 09
                        DB $3E, $00, $43, $BF, $25, $79 ; 10
                        DB $00, $07, $6B, $36, $02, $AA ; 11
                        DB $0D, $09, $6B, $76, $01, $AA ; 12
                        DB $0D, $09, $6B, $F6, $12, $CC ; 13
BoaVertSize:            equ $ - BoaVertices	
BoaEdges:	            DB $1F, $6B, $00, $14
                        DB $1F, $8A, $00, $1C
                        DB $1F, $79, $00, $24
                        DB $1D, $69, $00, $10
                        DB $1D, $8B, $00, $18
                        DB $1D, $7A, $00, $20
                        DB $1F, $36, $10, $14
                        DB $1F, $0B, $14, $18
                        DB $1F, $48, $18, $1C
                        DB $1F, $1A, $1C, $20
                        DB $1F, $57, $20, $24
                        DB $1F, $29, $10, $24
                        DB $18, $23, $04, $10
                        DB $18, $03, $04, $14
                        DB $18, $25, $0C, $24
                        DB $18, $15, $0C, $20
                        DB $18, $04, $08, $18
                        DB $18, $14, $08, $1C
                        DB $16, $02, $04, $28
                        DB $16, $01, $08, $2C
                        DB $16, $12, $0C, $30
                        DB $0E, $0C, $28, $2C
                        DB $0E, $1C, $2C, $30
                        DB $0E, $2C, $30, $28
BoaEdgesSize:           equ $ - BoaEdges	
BoaEdgesCnt:            equ BoaEdgesSize/4	
BoaNormals:	            DB $3F, $2B, $25, $3C
                        DB $7F, $00, $2D, $59
                        DB $BF, $2B, $25, $3C
                        DB $1F, $00, $28, $00
                        DB $7F, $3E, $20, $14
                        DB $FF, $3E, $20, $14
                        DB $1F, $00, $17, $06
                        DB $DF, $17, $0F, $09
                        DB $5F, $17, $0F, $09
                        DB $9F, $1A, $0D, $0A
                        DB $5F, $00, $1F, $0C
                        DB $1F, $1A, $0D, $0A
BoaNormalsSize:         equ $ - BoaNormals	
BoaLen:                 equ $ - Boa	
