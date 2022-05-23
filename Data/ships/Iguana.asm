Iguana:	                DB $01
                        DW $0DAC
                        DW IguanaEdges
                        DB IguanaEdgesSize
                        DB $00, $1A
                        DB IguanaVertSize /6 
                        DB IguanaVertSize
                        DB IguanaEdgesCnt
                        DB $00, $96
                        DB IguanaNormalsSize
                        DB $0A, $5A, $21
                        DW IguanaNormals
                        DB $01, $23
                        DW IguanaVertices
                        DB 0,0                      ; Type and Tactics
                        DB ShipCanAnger
                        DB $80                      ; chance of ECM module

	
IguanaVertices:	DB $00, $00, $5A, $1F, $23, $01
                DB $00, $14, $1E, $1F, $46, $02
                DB $28, $00, $0A, $9F, $45, $01
                DB $00, $14, $1E, $5F, $57, $13
                DB $28, $00, $0A, $1F, $67, $23
                DB $00, $14, $28, $3F, $89, $46
                DB $28, $00, $1E, $BF, $88, $45
                DB $00, $14, $28, $7F, $89, $57
                DB $28, $00, $1E, $3F, $99, $67
                DB $28, $00, $28, $9E, $11, $00
                DB $28, $00, $28, $1E, $33, $22
                DB $00, $08, $28, $2A, $99, $88
                DB $10, $00, $24, $AA, $88, $88
                DB $00, $08, $28, $6A, $99, $88
                DB $10, $00, $24, $2A, $99, $99

IguanaVertSize: equ $ - IguanaVertices	
	
	
	
IguanaEdges:	DB $1F, $02, $00, $04
                DB $1F, $01, $00, $08
                DB $1F, $13, $00, $0C
                DB $1F, $23, $00, $10
                DB $1F, $46, $04, $14
                DB $1F, $45, $08, $18
                DB $1F, $57, $0C, $1C
                DB $1F, $67, $10, $20
                DB $1F, $48, $14, $18
                DB $1F, $58, $18, $1C
                DB $1F, $69, $14, $20
                DB $1F, $79, $1C, $20
                DB $1F, $04, $04, $08
                DB $1F, $15, $08, $0C
                DB $1F, $26, $04, $10
                DB $1F, $37, $0C, $10
                DB $1F, $89, $14, $1C
                DB $1E, $01, $08, $24
                DB $1E, $23, $10, $28
                DB $0A, $88, $2C, $30
                DB $0A, $88, $34, $30
                DB $0A, $99, $2C, $38
                DB $0A, $99, $34, $38

IguanaEdgesSize: equ $ - IguanaEdges	
	
	
IguanaEdgesCnt: equ IguanaEdgesSize/4	
	
	
IguanaNormals:	DB $9F, $33, $4D, $19
	DB $DF, $33, $4D, $19
	DB $1F, $33, $4D, $19
	DB $5F, $33, $4D, $19
	DB $9F, $2A, $55, $00
	DB $DF, $2A, $55, $00
	DB $1F, $2A, $55, $00
	DB $5F, $2A, $55, $00
	DB $BF, $17, $00, $5D
	DB $3F, $17, $00, $5D

	
IguanaNormalsSize: equ $ - IguanaNormals	
IguanaLen: equ $ - Iguana	
