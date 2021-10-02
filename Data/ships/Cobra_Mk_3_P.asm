Cobra_Mk_3_P:	DB $01, $23, $41
	DW Cobra_Mk_3_PEdges
	DB Cobra_Mk_3_PEdgesSize
	DB $54, $2A
	DB Cobra_Mk_3_PVertSize
	DB Cobra_Mk_3_PEdgesCnt
	DB $00, $AF
	DB Cobra_Mk_3_PNormalsSize
	DB $32, $96, $1C
	DW Cobra_Mk_3_PNormals
	DB $01, $12
	DW Cobra_Mk_3_PVertices

Cobra_Mk_3_PVertices:	DB $20, $00, $4C, $1F, $FF, $FF
	DB $20, $00, $4C, $9F, $FF, $FF
	DB $00, $1A, $18, $1F, $FF, $FF
	DB $78, $03, $08, $FF, $73, $AA
	DB $78, $03, $08, $7F, $84, $CC
	DB $58, $10, $28, $BF, $FF, $FF
	DB $58, $10, $28, $3F, $FF, $FF
	DB $80, $08, $28, $7F, $98, $CC
	DB $80, $08, $28, $FF, $97, $AA
	DB $00, $1A, $28, $3F, $65, $99
	DB $20, $18, $28, $FF, $A9, $BB
	DB $20, $18, $28, $7F, $B9, $CC
	DB $24, $08, $28, $B4, $99, $99
	DB $08, $0C, $28, $B4, $99, $99
	DB $08, $0C, $28, $34, $99, $99
	DB $24, $08, $28, $34, $99, $99
	DB $24, $0C, $28, $74, $99, $99
	DB $08, $10, $28, $74, $99, $99
	DB $08, $10, $28, $F4, $99, $99
	DB $24, $0C, $28, $F4, $99, $99
	DB $00, $00, $4C, $06, $B0, $BB
	DB $00, $00, $5A, $1F, $B0, $BB
	DB $50, $06, $28, $E8, $99, $99
	DB $50, $06, $28, $A8, $99, $99
	DB $58, $00, $28, $A6, $99, $99
	DB $50, $06, $28, $28, $99, $99
	DB $58, $00, $28, $26, $99, $99
	DB $50, $06, $28, $68, $99, $99

Cobra_Mk_3_PVertSize: equ $ - Cobra_Mk_3_PVertices	


Cobra_Mk_3_PEdges:	DB $1F, $B0, $00, $04
	DB $1F, $C4, $00, $10
	DB $1F, $A3, $04, $0C
	DB $1F, $A7, $0C, $20
	DB $1F, $C8, $10, $1C
	DB $1F, $98, $18, $1C
	DB $1F, $96, $18, $24
	DB $1F, $95, $14, $24
	DB $1F, $97, $14, $20
	DB $1F, $51, $08, $14
	DB $1F, $62, $08, $18
	DB $1F, $73, $0C, $14
	DB $1F, $84, $10, $18
	DB $1F, $10, $04, $08
	DB $1F, $20, $00, $08
	DB $1F, $A9, $20, $28
	DB $1F, $B9, $28, $2C
	DB $1F, $C9, $1C, $2C
	DB $1F, $BA, $04, $28
	DB $1F, $CB, $00, $2C
	DB $1D, $31, $04, $14
	DB $1D, $42, $00, $18
	DB $06, $B0, $50, $54
	DB $14, $99, $30, $34
	DB $14, $99, $48, $4C
	DB $14, $99, $38, $3C
	DB $14, $99, $40, $44
	DB $13, $99, $3C, $40
	DB $11, $99, $38, $44
	DB $13, $99, $34, $48
	DB $13, $99, $30, $4C
	DB $1E, $65, $08, $24
	DB $06, $99, $58, $60
	DB $06, $99, $5C, $60
	DB $08, $99, $58, $5C
	DB $06, $99, $64, $68
	DB $06, $99, $68, $6C
	DB $08, $99, $64, $6C

Cobra_Mk_3_PEdgesSize: equ $ - Cobra_Mk_3_PEdges	
	
	
Cobra_Mk_3_PEdgesCnt: equ Cobra_Mk_3_PEdgesSize/4	
	
	
Cobra_Mk_3_PNormals:	DB $1F, $00, $3E, $1F
	DB $9F, $12, $37, $10
	DB $1F, $12, $37, $10
	DB $9F, $10, $34, $0E
	DB $1F, $10, $34, $0E
	DB $9F, $0E, $2F, $00
	DB $1F, $0E, $2F, $00
	DB $9F, $3D, $66, $00
	DB $1F, $3D, $66, $00
	DB $3F, $00, $00, $50
	DB $DF, $07, $2A, $09
	DB $5F, $00, $1E, $06
	DB $5F, $07, $2A, $09

Cobra_Mk_3_PNormalsSize: equ $ - Cobra_Mk_3_PNormals	
Cobra_Mk_3_PLen: equ $ - Cobra_Mk_3_P	
