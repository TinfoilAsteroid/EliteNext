Moray:	                DB $01, $03, $84
                        DW MorayEdges
                        DB MorayEdgesSize
                        DB $00, $1A
                        DB MorayVertSize
                        DB MorayEdgesCnt
                        DB $00, $32
                        DB MorayNormalsSize
                        DB $28, $59, $19
                        DW MorayNormals
                        DB $02, $2A
                        DW MorayVertices
MorayVertices:	        DB $0F, $00, $41, $1F, $02, $78
                        DB $0F, $00, $41, $9F, $01, $67
                        DB $00, $12, $28, $31, $FF, $FF
                        DB $3C, $00, $00, $9F, $13, $66
                        DB $3C, $00, $00, $1F, $25, $88
                        DB $1E, $1B, $0A, $78, $45, $78
                        DB $1E, $1B, $0A, $F8, $34, $67
                        DB $09, $04, $19, $E7, $44, $44
                        DB $09, $04, $19, $67, $44, $44
                        DB $00, $12, $10, $67, $44, $44
                        DB $0D, $03, $31, $05, $00, $00
                        DB $06, $00, $41, $05, $00, $00
                        DB $0D, $03, $31, $85, $00, $00
                        DB $06, $00, $41, $85, $00, $00
MorayVertSize:          equ $ - MorayVertices
MorayEdges:	            DB $1F, $07, $00, $04
                        DB $1F, $16, $04, $0C
                        DB $18, $36, $0C, $18
                        DB $18, $47, $14, $18
                        DB $18, $58, $10, $14
                        DB $1F, $28, $00, $10
                        DB $0F, $67, $04, $18
                        DB $0F, $78, $00, $14
                        DB $0F, $02, $00, $08
                        DB $0F, $01, $04, $08
                        DB $11, $13, $08, $0C
                        DB $11, $25, $08, $10
                        DB $0D, $45, $08, $14
                        DB $0D, $34, $08, $18
                        DB $05, $44, $1C, $20
                        DB $07, $44, $1C, $24
                        DB $07, $44, $20, $24
                        DB $05, $00, $28, $2C
                        DB $05, $00, $30, $34
MorayEdgesSize:         equ $ - MorayEdges
MorayEdgesCnt:          equ MorayEdgesSize/4
MorayNormals:	        DB $1F, $00, $2B, $07
                        DB $9F, $0A, $31, $07
                        DB $1F, $0A, $31, $07
                        DB $F8, $3B, $1C, $65
                        DB $78, $00, $34, $4E
                        DB $78, $3B, $1C, $65
                        DB $DF, $48, $63, $32
                        DB $5F, $00, $53, $1E
                        DB $5F, $48, $63, $32

MorayNormalsSize:       equ $ - MorayNormals
MorayLen:               equ $ - Moray
