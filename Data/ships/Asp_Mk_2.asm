Asp_Mk_2:	            DB $00
                        DW $0E10
                        DW Asp_Mk_2Edges
                        DB Asp_Mk_2EdgesSize
                        DB $20, $1A
                        DB Asp_Mk_2VertSize /6 
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
                        DB $80                      ; chance of ECM module
Asp_Mk_2Vertices:	    DB $00, $12, $00, $56, $01, $22 ;01
                        DB $00, $09, $2D, $7F, $12, $BB ;02
                        DB $2B, $00, $2D, $3F, $16, $BB ;03
                        DB $45, $03, $00, $5F, $16, $79 ;04
                        DB $2B, $0E, $1C, $5F, $01, $77 ;05
                        DB $2B, $00, $2D, $BF, $25, $BB ;06
                        DB $45, $03, $00, $DF, $25, $8A ;07
                        DB $2B, $0E, $1C, $DF, $02, $88 ;08
                        DB $1A, $07, $49, $5F, $04, $79 ;09
                        DB $1A, $07, $49, $DF, $04, $8A ;10
                        DB $2B, $0E, $1C, $1F, $34, $69 ;11
                        DB $2B, $0E, $1C, $9F, $34, $5A ;12
                        DB $00, $09, $2D, $3F, $35, $6B ;13
                        DB $11, $00, $2D, $AA, $BB, $BB ;14
                        DB $11, $00, $2D, $29, $BB, $BB ;15
                        DB $00, $04, $2D, $6A, $BB, $BB ;16
                        DB $00, $04, $2D, $28, $BB, $BB ;17
                        DB $00, $07, $49, $4A, $04, $04 ;18
                        DB $00, $07, $53, $4A, $04, $04 ;19
Asp_Mk_2VertSize:       equ $ - Asp_Mk_2Vertices	
Asp_Mk_2Edges:	        DB $16, $12, $00, $04           ;01
                        DB $16, $01, $00, $10           ;02
                        DB $16, $02, $00, $1C           ;03
                        DB $1F, $1B, $04, $08           ;04
                        DB $1F, $16, $08, $0C           ;05
                        DB $10, $79, $0C, $20           ;06
                        DB $1F, $04, $20, $24           ;07
                        DB $10, $8A, $18, $24           ;08
                        DB $1F, $25, $14, $18           ;09
                        DB $1F, $2B, $04, $14           ;10
                        DB $1F, $17, $0C, $10           ;11
                        DB $1F, $07, $10, $20           ;12
                        DB $1F, $28, $18, $1C           ;13
                        DB $1F, $08, $1C, $24           ;14
                        DB $1F, $6B, $08, $30           ;15
                        DB $1F, $5B, $14, $30           ;16
                        DB $16, $36, $28, $30           ;17
                        DB $16, $35, $2C, $30           ;18
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
Asp_Mk_2Normals:	    DB $5F, $00, $23, $05           ;01
                        DB $7F, $08, $26, $07           ;02
                        DB $FF, $08, $26, $07           ;03
                        DB $36, $00, $18, $01           ;04
                        DB $1F, $00, $2B, $13           ;05
                        DB $BF, $06, $1C, $02           ;06
                        DB $3F, $06, $1C, $02           ;07
                        DB $5F, $3B, $40, $1F           ;08
                        DB $DF, $3B, $40, $1F           ;09
                        DB $1F, $50, $2E, $32           ;10
                        DB $9F, $50, $2E, $32           ;11
                        DB $3F, $00, $00, $5A           ;12
Asp_Mk_2NormalsSize:    equ $ - Asp_Mk_2Normals	        
Asp_Mk_2Len:            equ $ - Asp_Mk_2	            
                                                        
                                                        
                                                        
                                                        