Mamba:	DB $01, $13, $24
	DW MambaEdges
	DB MambaEdgesSize
	DB $00, $22
	DB MambaVertSize
	DB MambaEdgesCnt
	DB $00, $96
	DB MambaNormalsSize
	DB $19, $5A, $1E
	DW MambaNormals
	DB $02, $12
	DW MambaVertices
                        DB 0,0                      ; Type and Tactics

MambaVertices:	DB $00, $00, $40, $1F, $10, $32
	DB $40, $08, $20, $FF, $20, $44
	DB $20, $08, $20, $BE, $21, $44
	DB $20, $08, $20, $3E, $31, $44
	DB $40, $08, $20, $7F, $30, $44
	DB $04, $04, $10, $8E, $11, $11
	DB $04, $04, $10, $0E, $11, $11
	DB $08, $03, $1C, $0D, $11, $11
	DB $08, $03, $1C, $8D, $11, $11
	DB $14, $04, $10, $D4, $00, $00
	DB $14, $04, $10, $54, $00, $00
	DB $18, $07, $14, $F4, $00, $00
	DB $10, $07, $14, $F0, $00, $00
	DB $10, $07, $14, $70, $00, $00
	DB $18, $07, $14, $74, $00, $00
	DB $08, $04, $20, $AD, $44, $44
	DB $08, $04, $20, $2D, $44, $44
	DB $08, $04, $20, $6E, $44, $44
	DB $08, $04, $20, $EE, $44, $44
	DB $20, $04, $20, $A7, $44, $44
	DB $20, $04, $20, $27, $44, $44
	DB $24, $04, $20, $67, $44, $44
	DB $24, $04, $20, $E7, $44, $44
	DB $26, $00, $20, $A5, $44, $44
	DB $26, $00, $20, $25, $44, $44

MambaVertSize: equ $ - MambaVertices	
	
	
	
MambaEdges:	DB $1F, $20, $00, $04
	DB $1F, $30, $00, $10
	DB $1F, $40, $04, $10
	DB $1E, $42, $04, $08
	DB $1E, $41, $08, $0C
	DB $1E, $43, $0C, $10
	DB $0E, $11, $14, $18
	DB $0C, $11, $18, $1C
	DB $0D, $11, $1C, $20
	DB $0C, $11, $14, $20
	DB $14, $00, $24, $2C
	DB $10, $00, $24, $30
	DB $10, $00, $28, $34
	DB $14, $00, $28, $38
	DB $0E, $00, $34, $38
	DB $0E, $00, $2C, $30
	DB $0D, $44, $3C, $40
	DB $0E, $44, $44, $48
	DB $0C, $44, $3C, $48
	DB $0C, $44, $40, $44
	DB $07, $44, $50, $54
	DB $05, $44, $50, $60
	DB $05, $44, $54, $60
	DB $07, $44, $4C, $58
	DB $05, $44, $4C, $5C
	DB $05, $44, $58, $5C
	DB $1E, $21, $00, $08
	DB $1E, $31, $00, $0C

MambaEdgesSize: equ $ - MambaEdges	

		
MambaEdgesCnt: equ MambaEdgesSize/4	
	
	
MambaNormals:	DB $5E, $00, $18, $02
	DB $1E, $00, $18, $02
	DB $9E, $20, $40, $10
	DB $1E, $20, $40, $10
	DB $3E, $00, $00, $7F

MambaNormalsSize: equ $ - MambaNormals	
MambaLen: equ $ - Mamba	
