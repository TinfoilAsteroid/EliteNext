Rattler:	            DB $02
                        DW $1770
                        DW RattlerEdges
                        DB RattlerEdgesSize
                        DB $00, $2A
                        DB RattlerVertSize /6 
                        DB RattlerVertSize
                        DB RattlerEdgesCnt
                        DB $00, $96
                        DB RattlerNormalsSize
                        DB $0A, $71, $1F
                        DW RattlerNormals
                        DB $01, $22
                        DW RattlerVertices
                        DB 0,0                      ; Type and Tactics
                        DB ShipCanAnger
                        DB $90                      ; chance of ECM module


RattlerVertices:	    DB $00, $00, $3C, $1F, $89, $23
                        DB $28, $00, $28, $1F, $9A, $34
                        DB $28, $00, $28, $9F, $78, $12
                        DB $3C, $00, $00, $1F, $AB, $45
                        DB $3C, $00, $00, $9F, $67, $01
                        DB $46, $00, $28, $3F, $CC, $5B
                        DB $46, $00, $28, $BF, $CC, $06
                        DB $00, $14, $28, $3F, $FF, $FF
                        DB $00, $14, $28, $7F, $FF, $FF
                        DB $0A, $06, $28, $AA, $CC, $CC
                        DB $0A, $06, $28, $EA, $CC, $CC
                        DB $14, $00, $28, $AA, $CC, $CC
                        DB $0A, $06, $28, $2A, $CC, $CC
                        DB $0A, $06, $28, $6A, $CC, $CC
                        DB $14, $00, $28, $2A, $CC, $CC

RattlerVertSize: equ $ - RattlerVertices	

	
RattlerEdges:	DB $1F, $06, $10, $18
	DB $1F, $17, $08, $10
	DB $1F, $28, $00, $08
	DB $1F, $39, $00, $04
	DB $1F, $4A, $04, $0C
	DB $1F, $5B, $0C, $14
	DB $1F, $0C, $18, $1C
	DB $1F, $6C, $18, $20
	DB $1F, $01, $10, $1C
	DB $1F, $67, $10, $20
	DB $1F, $12, $08, $1C
	DB $1F, $78, $08, $20
	DB $1F, $23, $00, $1C
	DB $1F, $89, $00, $20
	DB $1F, $34, $04, $1C
	DB $1F, $9A, $04, $20
	DB $1F, $45, $0C, $1C
	DB $1F, $AB, $0C, $20
	DB $1F, $5C, $14, $1C
	DB $1F, $BC, $14, $20
	DB $0A, $CC, $24, $28
	DB $0A, $CC, $28, $2C
	DB $0A, $CC, $2C, $24
	DB $0A, $CC, $30, $34
	DB $0A, $CC, $34, $38
	DB $0A, $CC, $38, $30

RattlerEdgesSize: equ $ - RattlerEdges	
	
	
RattlerEdgesCnt: equ RattlerEdgesSize/4	
	
	
RattlerNormals:	DB $9F, $1A, $5C, $06
	DB $9F, $17, $5C, $0B
	DB $9F, $09, $5D, $12
	DB $1F, $09, $5D, $12
	DB $1F, $17, $5C, $0B
	DB $1F, $1A, $5C, $06
	DB $DF, $1A, $5C, $06
	DB $DF, $17, $5C, $0B
	DB $DF, $09, $5D, $12
	DB $5F, $09, $5D, $12
	DB $5F, $17, $5C, $0B
	DB $5F, $1A, $5C, $06
	DB $3F, $00, $00, $60

RattlerNormalsSize: equ $ - RattlerNormals	
RattlerLen: equ $ - Rattler	
