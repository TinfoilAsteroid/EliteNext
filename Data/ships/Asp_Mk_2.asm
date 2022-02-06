Asp_Mk_2:	           DB $00, $0E, $10
                        DW Asp_Mk_2Edges
                        DB Asp_Mk_2EdgesSize
                        DB $20, $1A
                        DB Asp_Mk_2VertSize
                        DB Asp_Mk_2EdgesCnt
                        DB $00, $C8
                        DB Asp_Mk_2NormalsSize
                        DB $28, $96, $28
                        DW Asp_Mk_2Normals
                        DB $01, $29
                        DW Asp_Mk_2Vertices
                        DB 0,0                      ; Type and Tactics
                        DB ShipCanAnger
Asp_Mk_2Vertices:	    DB $00, $12, $00, $56, $01, $22
                        DB $00, $09, $2D, $7F, $12, $BB
                        DB $2B, $00, $2D, $3F, $16, $BB
                        DB $45, $03, $00, $5F, $16, $79
                        DB $2B, $0E, $1C, $5F, $01, $77
                        DB $2B, $00, $2D, $BF, $25, $BB
                        DB $45, $03, $00, $DF, $25, $8A
                        DB $2B, $0E, $1C, $DF, $02, $88
                        DB $1A, $07, $49, $5F, $04, $79
                        DB $1A, $07, $49, $DF, $04, $8A
                        DB $2B, $0E, $1C, $1F, $34, $69
                        DB $2B, $0E, $1C, $9F, $34, $5A
                        DB $00, $09, $2D, $3F, $35, $6B
                        DB $11, $00, $2D, $AA, $BB, $BB
                        DB $11, $00, $2D, $29, $BB, $BB
                        DB $00, $04, $2D, $6A, $BB, $BB
                        DB $00, $04, $2D, $28, $BB, $BB
                        DB $00, $07, $49, $4A, $04, $04
                        DB $00, $07, $53, $4A, $04, $04
Asp_Mk_2VertSize:       equ $ - Asp_Mk_2Vertices	
Asp_Mk_2Edges:	        DB $16, $12, $00, $04
                        DB $16, $01, $00, $10
                        DB $16, $02, $00, $1C
                        DB $1F, $1B, $04, $08
                        DB $1F, $16, $08, $0C
                        DB $10, $79, $0C, $20
                        DB $1F, $04, $20, $24
                        DB $10, $8A, $18, $24
                        DB $1F, $25, $14, $18
                        DB $1F, $2B, $04, $14
                        DB $1F, $17, $0C, $10
                        DB $1F, $07, $10, $20
                        DB $1F, $28, $18, $1C
                        DB $1F, $08, $1C, $24
                        DB $1F, $6B, $08, $30
                        DB $1F, $5B, $14, $30
                        DB $16, $36, $28, $30
                        DB $16, $35, $2C, $30
                        DB $16, $34, $28, $2C
                        DB $1F, $5A, $18, $2C
                        DB $1F, $4A, $24, $2C
                        DB $1F, $69, $0C, $28
                        DB $1F, $49, $20, $28
                        DB $0A, $BB, $34, $3C
                        DB $09, $BB, $3C, $38
                        DB $08, $BB, $38, $40
                        DB $08, $BB, $40, $34
                        DB $0A, $04, $48, $44
Asp_Mk_2EdgesSize:      equ $ - Asp_Mk_2Edges	
Asp_Mk_2EdgesCnt:       equ Asp_Mk_2EdgesSize/4	
Asp_Mk_2Normals:	    DB $5F, $00, $23, $05
                        DB $7F, $08, $26, $07
                        DB $FF, $08, $26, $07
                        DB $36, $00, $18, $01
                        DB $1F, $00, $2B, $13
                        DB $BF, $06, $1C, $02
                        DB $3F, $06, $1C, $02
                        DB $5F, $3B, $40, $1F
                        DB $DF, $3B, $40, $1F
                        DB $1F, $50, $2E, $32
                        DB $9F, $50, $2E, $32
                        DB $3F, $00, $00, $5A
Asp_Mk_2NormalsSize:    equ $ - Asp_Mk_2Normals	
Asp_Mk_2Len:            equ $ - Asp_Mk_2	
