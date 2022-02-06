Ghavial:	            DB $03, $26, $00
                        DW GhavialEdges
                        DB GhavialEdgesSize
                        DB $00, $22
                        DB GhavialVertSize
                        DB GhavialEdgesCnt
                        DB $00, $64
                        DB GhavialNormalsSize
                        DB $0A, $72, $10
                        DW GhavialNormals
                        DB $00, $27
                        DW GhavialVertices
                        DB 0,0                      ; Type and Tactics
                        DB ShipCanAnger

GhavialVertices:	DB $1E, $00, $64, $1F, $67, $01
	DB $1E, $00, $64, $9F, $6B, $05
	DB $28, $1E, $1A, $3F, $23, $01
	DB $28, $1E, $1A, $BF, $45, $03
	DB $3C, $00, $14, $3F, $78, $12
	DB $28, $00, $3C, $3F, $89, $23
	DB $3C, $00, $14, $BF, $AB, $45
	DB $28, $00, $3C, $BF, $9A, $34
	DB $00, $1E, $14, $7F, $FF, $FF
	DB $0A, $18, $00, $09, $00, $00
	DB $0A, $18, $00, $89, $00, $00
	DB $00, $16, $0A, $09, $00, $00

GhavialVertSize: equ $ - GhavialVertices	
	

GhavialEdges:	DB $1F, $01, $00, $08
	DB $1F, $12, $10, $08
	DB $1F, $23, $14, $08
	DB $1F, $30, $0C, $08
	DB $1F, $34, $1C, $0C
	DB $1F, $45, $18, $0C
	DB $1F, $50, $0C, $04
	DB $1F, $67, $00, $20
	DB $1F, $78, $10, $20
	DB $1F, $89, $14, $20
	DB $1F, $9A, $1C, $20
	DB $1F, $AB, $18, $20
	DB $1F, $B6, $04, $20
	DB $1F, $06, $04, $00
	DB $1F, $17, $00, $10
	DB $1F, $28, $10, $14
	DB $1F, $39, $14, $1C
	DB $1F, $4A, $1C, $18
	DB $1F, $5B, $18, $04
	DB $09, $00, $24, $28
	DB $09, $00, $28, $2C
	DB $09, $00, $2C, $24

GhavialEdgesSize: equ $ - GhavialEdges	
	
	
GhavialEdgesCnt: equ GhavialEdgesSize/4	
	
	
GhavialNormals:	DB $1F, $00, $3E, $0E
	DB $1F, $33, $24, $0C
	DB $3F, $33, $1C, $19
	DB $3F, $00, $30, $2A
	DB $BF, $33, $1C, $19
	DB $9F, $33, $24, $0C
	DB $5F, $00, $3E, $0F
	DB $5F, $1C, $38, $07
	DB $7F, $1B, $37, $0D
	DB $7F, $00, $33, $26
	DB $FF, $1B, $37, $0D
	DB $DF, $1C, $38, $07

GhavialNormalsSize: equ $ - GhavialNormals	
GhavialLen: equ $ - Ghavial	
