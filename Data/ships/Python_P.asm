Python_P:	DB $02, $19, $00
	DW Python_PEdges
	DB Python_PEdgesSize
	DB $00, $2A
	DB Python_PVertSize
	DB Python_PEdgesCnt
	DB $00, $C8
	DB Python_PNormalsSize
	DB $28, $FA, $14
	DW Python_PNormals
	DB $00, $1B
	DW Python_PVertices
                        DB 0,0                      ; Type and Tactics

Python_PVertices:	DB $00, $00, $E0, $1F, $10, $32
	DB $00, $30, $30, $1F, $10, $54
	DB $60, $00, $10, $3F, $FF, $FF
	DB $60, $00, $10, $BF, $FF, $FF
	DB $00, $30, $20, $3F, $54, $98
	DB $00, $18, $70, $3F, $89, $CC
	DB $30, $00, $70, $BF, $B8, $CC
	DB $30, $00, $70, $3F, $A9, $CC
	DB $00, $30, $30, $5F, $32, $76
	DB $00, $30, $20, $7F, $76, $BA
	DB $00, $18, $70, $7F, $BA, $CC

Python_PVertSize: equ $ - Python_PVertices	
	
	
	
Python_PEdges:	DB $1F, $32, $00, $20
	DB $1F, $20, $00, $0C
	DB $1F, $31, $00, $08
	DB $1F, $10, $00, $04
	DB $1F, $59, $08, $10
	DB $1F, $51, $04, $08
	DB $1F, $37, $08, $20
	DB $1F, $40, $04, $0C
	DB $1F, $62, $0C, $20
	DB $1F, $A7, $08, $24
	DB $1F, $84, $0C, $10
	DB $1F, $B6, $0C, $24
	DB $07, $88, $0C, $14
	DB $07, $BB, $0C, $28
	DB $07, $99, $08, $14
	DB $07, $AA, $08, $28
	DB $1F, $A9, $08, $1C
	DB $1F, $B8, $0C, $18
	DB $1F, $C8, $14, $18
	DB $1F, $C9, $14, $1C
	DB $1F, $AC, $1C, $28
	DB $1F, $CB, $18, $28
	DB $1F, $98, $10, $14
	DB $1F, $BA, $24, $28
	DB $1F, $54, $04, $10
	DB $1F, $76, $20, $24

Python_PEdgesSize: equ $ - Python_PEdges	
	
	
Python_PEdgesCnt: equ Python_PEdgesSize/4	
	
	
Python_PNormals:	DB $9F, $1B, $28, $0B
	DB $1F, $1B, $28, $0B
	DB $DF, $1B, $28, $0B
	DB $5F, $1B, $28, $0B
	DB $9F, $13, $26, $00
	DB $1F, $13, $26, $00
	DB $DF, $13, $26, $00
	DB $5F, $13, $26, $00
	DB $BF, $19, $25, $0B
	DB $3F, $19, $25, $0B
	DB $7F, $19, $25, $0B
	DB $FF, $19, $25, $0B
	DB $3F, $00, $00, $70

	
Python_PNormalsSize: equ $ - Python_PNormals	
Python_PLen: equ $ - Python_P	
