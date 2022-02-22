Thargoid:	            DB $00, $26, $49
                        DW ThargoidEdges
                        DB ThargoidEdgesSize
                        DB $3C, $26
                        DB ThargoidVertSize
                        DB ThargoidEdgesCnt
                        DB $01, $F4
                        DB ThargoidNormalsSize
                        DB $37, $F0, $27
                        DW ThargoidNormals
                        DB $02, $16
                        DW ThargoidVertices
                        DB 0,0                      ; Type and Tactics
                        DB ShipCanAnger

ThargoidVertices:	    DB $20, $30, $30, $5F, $40, $88
                        DB $20, $44, $00, $5F, $10, $44
                        DB $20, $30, $30, $7F, $21, $44
                        DB $20, $00, $44, $3F, $32, $44
                        DB $20, $30, $30, $3F, $43, $55
                        DB $20, $44, $00, $1F, $54, $66
                        DB $20, $30, $30, $1F, $64, $77
                        DB $20, $00, $44, $1F, $74, $88
                        DB $18, $74, $74, $DF, $80, $99
                        DB $18, $A4, $00, $DF, $10, $99
                        DB $18, $74, $74, $FF, $21, $99
                        DB $18, $00, $A4, $BF, $32, $99
                        DB $18, $74, $74, $BF, $53, $99
                        DB $18, $A4, $00, $9F, $65, $99
                        DB $18, $74, $74, $9F, $76, $99
                        DB $18, $00, $A4, $9F, $87, $99
                        DB $18, $40, $50, $9E, $99, $99
                        DB $18, $40, $50, $BE, $99, $99
                        DB $18, $40, $50, $FE, $99, $99
                        DB $18, $40, $50, $DE, $99, $99

ThargoidVertSize: equ $ - ThargoidVertices	
	
	
	
ThargoidEdges:	DB $1F, $84, $00, $1C           ;01
                DB $1F, $40, $00, $04           ;02
                DB $1F, $41, $04, $08           ;03
                DB $1F, $42, $08, $0C           ;04
                DB $1F, $43, $0C, $10           ;05
                DB $1F, $54, $10, $14           ;06
                DB $1F, $64, $14, $18           ;07
                DB $1F, $74, $18, $1C           ;08
                DB $1F, $80, $00, $20           ;09
                DB $1F, $10, $04, $24           ;10
                DB $1F, $21, $08, $28           ;11
                DB $1F, $32, $0C, $2C           ;12
                DB $1F, $53, $10, $30           ;13
                DB $1F, $65, $14, $34           ;14
                DB $1F, $76, $18, $38           ;15
                DB $1F, $87, $1C, $3C           ;16
                DB $1F, $98, $20, $3C           ;17
                DB $1F, $90, $20, $24           ;18
                DB $1F, $91, $24, $28
                DB $1F, $92, $28, $2C
                DB $1F, $93, $2C, $30
                DB $1F, $95, $30, $34
                DB $1F, $96, $34, $38
                DB $1F, $97, $38, $3C
                DB $1E, $99, $40, $44
                DB $1E, $99, $48, $4C

ThargoidEdgesSize: equ $ - ThargoidEdges	

ThargoidEdgesCnt: equ ThargoidEdgesSize/4	

ThargoidNormals:	DB $5F, $67, $3C, $19
	DB $7F, $67, $3C, $19
	DB $7F, $67, $19, $3C
	DB $3F, $67, $19, $3C
	DB $1F, $40, $00, $00
	DB $3F, $67, $3C, $19
	DB $1F, $67, $3C, $19
	DB $1F, $67, $19, $3C
	DB $5F, $67, $19, $3C
	DB $9F, $30, $00, $00

	
ThargoidNormalsSize: equ $ - ThargoidNormals	
ThargoidLen: equ $ - Thargoid	
