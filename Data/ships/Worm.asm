Worm:	DB $00, $26, $49
	DW WormEdges
	DB WormEdgesSize
	DB $00, $12
	DB WormVertSize
	DB WormEdgesCnt
	DB $00, $00
	DB WormNormalsSize
	DB $13, $1E, $17
	DW WormNormals
	DB $03, $08
	DW WormVertices
	
	
	
	
	
	
	
	
	
WormVertices:	DB $0A, $0A, $23, $5F, $02, $77
	DB $0A, $0A, $23, $DF, $03, $77
	DB $05, $06, $0F, $1F, $01, $24
	DB $05, $06, $0F, $9F, $01, $35
	DB $0F, $0A, $19, $5F, $24, $77
	DB $0F, $0A, $19, $DF, $35, $77
	DB $1A, $0A, $19, $7F, $46, $77
	DB $1A, $0A, $19, $FF, $56, $77
	DB $08, $0E, $19, $3F, $14, $66
	DB $08, $0E, $19, $BF, $15, $66

WormVertSize: equ $ - WormVertices	
	
	
WormEdges:	DB $1F, $07, $00, $04
	DB $1F, $37, $04, $14
	DB $1F, $57, $14, $1C
	DB $1F, $67, $1C, $18
	DB $1F, $47, $18, $10
	DB $1F, $27, $10, $00
	DB $1F, $02, $00, $08
	DB $1F, $03, $04, $0C
	DB $1F, $24, $10, $08
	DB $1F, $35, $14, $0C
	DB $1F, $14, $08, $20
	DB $1F, $46, $20, $18
	DB $1F, $15, $0C, $24
	DB $1F, $56, $24, $1C
	DB $1F, $01, $08, $0C
	DB $1F, $16, $20, $24

WormEdgesSize: equ $ - WormEdges	
	
	
WormEdgesCnt: equ WormEdgesSize/4	
	
	
WormNormals:	DB $1F, $00, $58, $46
	DB $1F, $00, $45, $0E
	DB $1F, $46, $42, $23
	DB $9F, $46, $42, $23
	DB $1F, $40, $31, $0E
	DB $9F, $40, $31, $0E
	DB $3F, $00, $00, $C8
	DB $5F, $00, $50, $00

	
WormNormalsSize: equ $ - WormNormals	
WormLen: equ $ - Worm	
