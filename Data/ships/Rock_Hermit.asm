Rock_Hermit:	        DB $07
                        DW $1900
                        DW Rock_HermitEdges
                        DB Rock_HermitEdgesSize
                        DB $00, $32
                        DB Rock_HermitVertSize /6 
                        DB Rock_HermitVertSize
                        DB Rock_HermitEdgesCnt
                        DB $00, $00
                        DB Rock_HermitNormalsSize
                        DB $32, $B4, $1E
                        DW Rock_HermitNormals
                        DB $01, $02
                        DW Rock_HermitVertices
                        DB 0,0                      ; Type and Tactics
                        DB ShipCanAnger
                        DB $30                      ; chance of ECM module

	
Rock_HermitVertices:	DB $00, $50, $00, $1F, $FF, $FF
                        DB $50, $0A, $00, $DF, $FF, $FF
                        DB $00, $50, $00, $5F, $FF, $FF
                        DB $46, $28, $00, $5F, $FF, $FF
                        DB $3C, $32, $00, $1F, $65, $DC
                        DB $32, $00, $3C, $1F, $FF, $FF
                        DB $28, $00, $46, $9F, $10, $32
                        DB $00, $1E, $4B, $3F, $FF, $FF
                        DB $00, $32, $3C, $7F, $98, $BA

	
Rock_HermitVertSize: equ $ - Rock_HermitVertices	
	
	
	
Rock_HermitEdges:	DB $1F, $72, $00, $04
	DB $1F, $D6, $00, $10
	DB $1F, $C5, $0C, $10
	DB $1F, $B4, $08, $0C
	DB $1F, $A3, $04, $08
	DB $1F, $32, $04, $18
	DB $1F, $31, $08, $18
	DB $1F, $41, $08, $14
	DB $1F, $10, $14, $18
	DB $1F, $60, $00, $14
	DB $1F, $54, $0C, $14
	DB $1F, $20, $00, $18
	DB $1F, $65, $10, $14
	DB $1F, $A8, $04, $20
	DB $1F, $87, $04, $1C
	DB $1F, $D7, $00, $1C
	DB $1F, $DC, $10, $1C
	DB $1F, $C9, $0C, $1C
	DB $1F, $B9, $0C, $20
	DB $1F, $BA, $08, $20
	DB $1F, $98, $1C, $20

Rock_HermitEdgesSize: equ $ - Rock_HermitEdges	
	
	
Rock_HermitEdgesCnt: equ Rock_HermitEdgesSize/4	
	
	
Rock_HermitNormals:	DB $1F, $09, $42, $51
	DB $5F, $09, $42, $51
	DB $9F, $48, $40, $1F
	DB $DF, $40, $49, $2F
	DB $5F, $2D, $4F, $41
	DB $1F, $87, $0F, $23
	DB $1F, $26, $4C, $46
	DB $BF, $42, $3B, $27
	DB $FF, $43, $0F, $50
	DB $7F, $42, $0E, $4B
	DB $FF, $46, $50, $28
	DB $7F, $3A, $66, $33
	DB $3F, $51, $09, $43
	DB $3F, $2F, $5E, $3F

	
Rock_HermitNormalsSize: equ $ - Rock_HermitNormals	
Rock_HermitLen: equ $ - Rock_Hermit	
