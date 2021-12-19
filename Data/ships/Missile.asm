Missile:	DB $00, $06, $40
	DW MissileEdges
	DB MissileEdgesSize
	DB $00, $0A
	DB MissileVertSize
	DB MissileEdgesCnt
	DB $00, $00
	DB MissileNormalsSize
	DB $0E, $02, $2C
	DW MissileNormals
	DB $02, $00
	DW MissileVertices
    DB ShipTypeMissile,0                      ; Type and Tactics

MissileVertices:	DB $00, $00, $44, $1F, $10, $32
	DB $08, $08, $24, $5F, $21, $54
	DB $08, $08, $24, $1F, $32, $74
	DB $08, $08, $24, $9F, $30, $76
	DB $08, $08, $24, $DF, $10, $65
	DB $08, $08, $2C, $3F, $74, $88
	DB $08, $08, $2C, $7F, $54, $88
	DB $08, $08, $2C, $FF, $65, $88
	DB $08, $08, $2C, $BF, $76, $88
	DB $0C, $0C, $2C, $28, $74, $88
	DB $0C, $0C, $2C, $68, $54, $88
	DB $0C, $0C, $2C, $E8, $65, $88
	DB $0C, $0C, $2C, $A8, $76, $88
	DB $08, $08, $0C, $A8, $76, $77
	DB $08, $08, $0C, $E8, $65, $66
	DB $08, $08, $0C, $28, $74, $77
	DB $08, $08, $0C, $68, $54, $55

MissileVertSize: equ $ - MissileVertices	
	
	
	
MissileEdges:	DB $1F, $21, $00, $04
	DB $1F, $32, $00, $08
	DB $1F, $30, $00, $0C
	DB $1F, $10, $00, $10
	DB $1F, $24, $04, $08
	DB $1F, $51, $04, $10
	DB $1F, $60, $0C, $10
	DB $1F, $73, $08, $0C
	DB $1F, $74, $08, $14
	DB $1F, $54, $04, $18
	DB $1F, $65, $10, $1C
	DB $1F, $76, $0C, $20
	DB $1F, $86, $1C, $20
	DB $1F, $87, $14, $20
	DB $1F, $84, $14, $18
	DB $1F, $85, $18, $1C
	DB $08, $85, $18, $28
	DB $08, $87, $14, $24
	DB $08, $87, $20, $30
	DB $08, $85, $1C, $2C
	DB $08, $74, $24, $3C
	DB $08, $54, $28, $40
	DB $08, $76, $30, $34
	DB $08, $65, $2C, $38

MissileEdgesSize: equ $ - MissileEdges	
	
	
MissileEdgesCnt: equ MissileEdgesSize/4	
	
	
MissileNormals:	DB $9F, $40, $00, $10
	DB $5F, $00, $40, $10
	DB $1F, $40, $00, $10
	DB $1F, $00, $40, $10
	DB $1F, $20, $00, $00
	DB $5F, $00, $20, $00
	DB $9F, $20, $00, $00
	DB $1F, $00, $20, $00
	DB $3F, $00, $00, $B0

	
MissileNormalsSize: equ $ - MissileNormals	
MissileLen: equ $ - Missile	
