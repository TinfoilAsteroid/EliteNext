Adder:	                DB $00                              ; Number of cargo canisters released when destroyed
                        DW 50 * 50                          ; Ship's targetable area LoHi
                        DW AdderEdges                       ; Edge Data 
                        DB AdderEdgesSize                   ; Size of Edge Data
                        DB $00                              ; Gun Vertex Byte offset
                        DB $16                              ; Explosion Count 
                        DB AdderVertSize / 6                ; Vertex Count /6
                        DB AdderVertSize                    ; Vertex Count
                        DB AdderEdgesCnt                    ; Edges Count
                        DW $0028                            ; Bounty LoHi
                        DB AdderNormalsSize                 ; Face (Normal) Count
                        DB $17                              ; Range when it turns to a dot
                        DB $48                              ; Energy Max
                        DB $18                              ; Speed Max
                        DW AdderNormals                     ; Normals
                        DB $12                              ; Q scaling
                        DB $21                              ; Laser power and Nbr Missiles
                        DW AdderVertices                    ; Verticles Address
                        DB ShipTypeNormal                   ; Ship Type
                        DB 0                                ; NewB Tactics 
                        DB ShipCanAnger                     ; AI Flags            
                        DB $80                              ; chance of ECM module
                        DB $FF                              ; Supports Solid Fill = false
                        DW $0000                            ; no solid data
                        DB $00                              ; no solid data
                        
                                       ; chance of ECM module
AdderVertices:	        DB $12, $00, $28, $9F, $01, $BC     ;01
                        DB $12, $00, $28, $1F, $01, $23     ;02
                        DB $1E, $00, $18, $3F, $23, $45     ;03
                        DB $1E, $00, $28, $3F, $45, $66     ;04
                        DB $12, $07, $28, $7F, $56, $7E     ;05
                        DB $12, $07, $28, $FF, $78, $AE     ;06
                        DB $1E, $00, $28, $BF, $89, $AA     ;07
                        DB $1E, $00, $18, $BF, $9A, $BC     ;08
                        DB $12, $07, $28, $BF, $78, $9D     ;09
                        DB $12, $07, $28, $3F, $46, $7D     ;10
                        DB $12, $07, $0D, $9F, $09, $BD     ;11
                        DB $12, $07, $0D, $1F, $02, $4D     ;12
                        DB $12, $07, $0D, $DF, $1A, $CE     ;13
                        DB $12, $07, $0D, $5F, $13, $5E     ;14
                        DB $0B, $03, $1D, $85, $00, $00     ;15
                        DB $0B, $03, $1D, $05, $00, $00     ;16
                        DB $0B, $04, $18, $04, $00, $00     ;17
                        DB $0B, $04, $18, $84, $00, $00     ;18
AdderVertSize:          equ $ - AdderVertices	
AdderEdges:	            DB $1F, $01, $00, $04               ;01
                        DB $07, $23, $04, $08               ;02
                        DB $1F, $45, $08, $0C               ;03
                        DB $1F, $56, $0C, $10               ;04
                        DB $1F, $7E, $10, $14               ;05
                        DB $1F, $8A, $14, $18               ;06
                        DB $1F, $9A, $18, $1C               ;07
                        DB $07, $BC, $1C, $00               ;08
                        DB $1F, $46, $0C, $24               ;09
                        DB $1F, $7D, $24, $20               ;10
                        DB $1F, $89, $20, $18               ;11
                        DB $1F, $0B, $00, $28               ;12
                        DB $1F, $9B, $1C, $28               ;13
                        DB $1F, $02, $04, $2C               ;14
                        DB $1F, $24, $08, $2C               ;15
                        DB $1F, $1C, $00, $30               ;16
                        DB $1F, $AC, $1C, $30               ;17
                        DB $1F, $13, $04, $34               ;18
                        DB $1F, $35, $08, $34               ;19
                        DB $1F, $0D, $28, $2C               ;20
                        DB $1F, $1E, $30, $34               ;21
                        DB $1F, $9D, $20, $28               ;22
                        DB $1F, $4D, $24, $2C               ;23
                        DB $1F, $AE, $14, $30               ;24
                        DB $1F, $5E, $10, $34               ;25
                        DB $05, $00, $38, $3C               ;26
                        DB $03, $00, $3C, $40               ;27
                        DB $04, $00, $40, $44               ;28
                        DB $03, $00, $44, $38               ;29
AdderEdgesSize:         equ $ - AdderEdges	                
AdderEdgesCnt:          equ AdderEdgesSize/4	            
AdderNormals:	        DB $1F, $00, $27, $0A               ;01
                        DB $5F, $00, $27, $0A               ;02
                        DB $1F, $45, $32, $0D               ;03
                        DB $5F, $45, $32, $0D               ;04
                        DB $1F, $1E, $34, $00               ;05
                        DB $5F, $1E, $34, $00               ;06
                        DB $3F, $00, $00, $A0               ;07
                        DB $3F, $00, $00, $A0               ;08
                        DB $3F, $00, $00, $A0               ;09
                        DB $9F, $1E, $34, $00               ;10
                        DB $DF, $1E, $34, $00               ;11
                        DB $9F, $45, $32, $0D               ;12
                        DB $DF, $45, $32, $0D               ;13
                        DB $1F, $00, $1C, $00               ;14
                        DB $5F, $00, $1C, $00               ;15
                                                            
AdderNormalsSize:       equ $ - AdderNormals	            
AdderLen:                equ $ - Adder	                    
                                                            
                                                            
                                                            
                                                            
                                                            
                                                            
                                                            
                                                            
                                                            
                                                            
                                                            