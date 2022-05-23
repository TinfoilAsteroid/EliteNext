Anaconda:	            DB $07
                        DW $2710
                        DW AnacondaEdges
                        DB AnacondaEdgesSize
                        DB $30, $2E
                        DB AnacondaVertSize / 6
                        DB AnacondaVertSize
                        DB AnacondaEdgesCnt
                        DB $00, $00
                        DB AnacondaNormalsSize
                        DB $24, $FC, $0E
                        DW AnacondaNormals
                        DB $01, $3F
                        DW AnacondaVertices
                        DB 0,0                      ; Type and Tactics
                        DB ShipCanAnger
                        DB $D0                      ; chance of ECM module
AnacondaVertices:	    DB $00, $07, $3A, $3E, $01, $55 ;01
                        DB $2B, $0D, $25, $FE, $01, $22 ;02
                        DB $1A, $2F, $03, $FE, $02, $33 ;03
                        DB $1A, $2F, $03, $7E, $03, $44 ;04
                        DB $2B, $0D, $25, $7E, $04, $55 ;05
                        DB $00, $30, $31, $3E, $15, $66 ;06
                        DB $45, $0F, $0F, $BE, $12, $77 ;07
                        DB $2B, $27, $28, $DF, $23, $88 ;08
                        DB $2B, $27, $28, $5F, $34, $99 ;09
                        DB $45, $0F, $0F, $3E, $45, $AA ;10
                        DB $2B, $35, $17, $BF, $FF, $FF ;11
                        DB $45, $01, $20, $DF, $27, $88 ;12
                        DB $00, $00, $FE, $1F, $FF, $FF ;13
                        DB $45, $01, $20, $5F, $49, $AA ;14
                        DB $2B, $35, $17, $3F, $FF, $FF ;15
AnacondaVertSize:       equ $ - AnacondaVertices        
AnacondaEdges:	        DB $1E, $01, $00, $04           ;01
                        DB $1E, $02, $04, $08           ;02
                        DB $1E, $03, $08, $0C           ;03
                        DB $1E, $04, $0C, $10           ;04
                        DB $1E, $05, $00, $10           ;05
                        DB $1D, $15, $00, $14           ;06
                        DB $1D, $12, $04, $18           ;07
                        DB $1D, $23, $08, $1C           ;08
                        DB $1D, $34, $0C, $20           ;09
                        DB $1D, $45, $10, $24           ;10
                        DB $1E, $16, $14, $28           ;11
                        DB $1E, $17, $18, $28           ;12
                        DB $1E, $27, $18, $2C           ;13
                        DB $1E, $28, $1C, $2C           ;14
                        DB $1F, $38, $1C, $30           ;15
                        DB $1F, $39, $20, $30           ;16
                        DB $1E, $49, $20, $34           ;17
                        DB $1E, $4A, $24, $34           ;18
                        DB $1E, $5A, $24, $38
                        DB $1E, $56, $14, $38
                        DB $1E, $6B, $28, $38
                        DB $1F, $7B, $28, $30
                        DB $1F, $78, $2C, $30
                        DB $1F, $9A, $30, $34
                        DB $1F, $AB, $30, $38
AnacondaEdgesSize:      equ $ - AnacondaEdges	
AnacondaEdgesCnt:       equ AnacondaEdgesSize/4	
AnacondaNormals:	    DB $7E, $00, $33, $31           ;01
                        DB $BE, $33, $12, $57           ;02
                        DB $FE, $4D, $39, $13           ;03
                        DB $5F, $00, $5A, $10           ;04
                        DB $7E, $4D, $39, $13           ;05
                        DB $3E, $33, $12, $57           ;06
                        DB $3E, $00, $6F, $14           ;07
                        DB $9F, $61, $48, $18           ;08
                        DB $DF, $6C, $44, $22           ;09
                        DB $5F, $6C, $44, $22           ;10
                        DB $1F, $61, $48, $18           ;11
                        DB $1F, $00, $5E, $12           ;12
AnacondaNormalsSize:    equ $ - AnacondaNormals	        
AnacondaLen:            equ $ - Anaconda	            
                                                        
                                                        
                                                        
                                                        