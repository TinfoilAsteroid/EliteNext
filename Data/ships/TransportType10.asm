TransportType10:	DB $00, $09, $C4
	DW TransportType10Edges
	DB TransportType10EdgesSize
	DB $30, $1A
	DB TransportType10VertSize
	DB TransportType10EdgesCnt
	DB $00, $00
	DB TransportType10NormalsSize
	DB $10, $20, $0A
	DW TransportType10Normals
	DB $02, $00
	DW TransportType10Vertices

TransportType10Vertices:	DB $00, $0A, $1A, $3F, $06, $77
	DB $19, $04, $1A, $BF, $01, $77
	DB $1C, $03, $1A, $FF, $01, $22
	DB $19, $08, $1A, $FF, $02, $33
	DB $1A, $08, $1A, $7F, $03, $44
	DB $1D, $03, $1A, $7F, $04, $55
	DB $1A, $04, $1A, $3F, $05, $66
	DB $00, $06, $0C, $13, $FF, $FF
	DB $1E, $01, $0C, $DF, $17, $89
	DB $21, $08, $0C, $DF, $12, $39
	DB $21, $08, $0C, $5F, $34, $5A
	DB $1E, $01, $0C, $5F, $56, $AB
	DB $0B, $02, $1E, $DF, $89, $CD
	DB $0D, $08, $1E, $DF, $39, $DD
	DB $0E, $08, $1E, $5F, $3A, $DD
	DB $0B, $02, $1E, $5F, $AB, $CD
	DB $05, $06, $02, $87, $77, $77
	DB $12, $03, $02, $87, $77, $77
	DB $05, $07, $07, $A7, $77, $77
	DB $12, $04, $07, $A7, $77, $77
	DB $0B, $06, $0E, $A7, $77, $77
	DB $0B, $05, $07, $A7, $77, $77
	DB $05, $07, $0E, $27, $66, $66
	DB $12, $04, $0E, $27, $66, $66
	DB $0B, $05, $07, $27, $66, $66
	DB $05, $06, $03, $27, $66, $66
	DB $12, $03, $03, $27, $66, $66
	DB $0B, $04, $08, $07, $66, $66
	DB $0B, $05, $03, $27, $66, $66
	DB $10, $08, $0D, $E6, $33, $33
	DB $10, $08, $10, $C6, $33, $33
	DB $11, $08, $0D, $66, $33, $33
	DB $11, $08, $10, $46, $33, $33
	DB $0D, $03, $1A, $E8, $00, $00
	DB $0D, $03, $1A, $68, $00, $00
	DB $09, $03, $1A, $25, $00, $00
	DB $08, $03, $1A, $A5, $00, $00

TransportType10VertSize: equ $ - TransportType10Vertices	
	
	
	
TransportType10Edges:	DB $1F, $07, $00, $04
	DB $1F, $01, $04, $08
	DB $1F, $02, $08, $0C
	DB $1F, $03, $0C, $10
	DB $1F, $04, $10, $14
	DB $1F, $05, $14, $18
	DB $1F, $06, $00, $18
	DB $10, $67, $00, $1C
	DB $1F, $17, $04, $20
	DB $0B, $12, $08, $24
	DB $1F, $23, $0C, $24
	DB $1F, $34, $10, $28
	DB $0B, $45, $14, $28
	DB $1F, $56, $18, $2C
	DB $11, $78, $1C, $20
	DB $11, $19, $20, $24
	DB $11, $5A, $28, $2C
	DB $11, $6B, $1C, $2C
	DB $13, $BC, $1C, $3C
	DB $13, $8C, $1C, $30
	DB $10, $89, $20, $30
	DB $1F, $39, $24, $34
	DB $1F, $3A, $28, $38
	DB $10, $AB, $2C, $3C
	DB $1F, $9D, $30, $34
	DB $1F, $3D, $34, $38
	DB $1F, $AD, $38, $3C
	DB $1F, $CD, $30, $3C
	DB $07, $77, $40, $44
	DB $07, $77, $48, $4C
	DB $07, $77, $4C, $50
	DB $07, $77, $48, $50
	DB $07, $77, $50, $54
	DB $07, $66, $58, $5C
	DB $07, $66, $5C, $60
	DB $07, $66, $60, $58
	DB $07, $66, $64, $68
	DB $07, $66, $68, $6C
	DB $07, $66, $64, $6C
	DB $07, $66, $6C, $70
	DB $06, $33, $74, $78
	DB $06, $33, $7C, $80
	DB $08, $00, $84, $88
	DB $05, $00, $88, $8C
	DB $05, $00, $8C, $90
	DB $05, $00, $90, $84

TransportType10EdgesSize: equ $ - TransportType10Edges	
	
	
TransportType10EdgesCnt: equ TransportType10EdgesSize/4	
	
	
TransportType10Normals:	DB $3F, $00, $00, $67
	DB $BF, $6F, $30, $07
	DB $FF, $69, $3F, $15
	DB $5F, $00, $22, $00
	DB $7F, $69, $3F, $15
	DB $3F, $6F, $30, $07
	DB $1F, $08, $20, $03
	DB $9F, $08, $20, $03
	DB $93, $08, $22, $0B
	DB $9F, $4B, $20, $4F
	DB $1F, $4B, $20, $4F
	DB $13, $08, $22, $0B
	DB $1F, $00, $26, $11
	DB $1F, $00, $00, $79

	
TransportType10NormalsSize: equ $ - TransportType10Normals	
TransportType10Len: equ $ - TransportType10	
