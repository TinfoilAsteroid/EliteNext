Thargon:	            DB $F0                          ; Number of cargo canisters released when destroyed
                        DW $0640                        ; Ship's targetable area LoHi
                        DW ThargonEdges                 ; Edge Data 
                        DB ThargonEdgesSize             ; Size of Edge Data
                        DB $00                          ; Gun Vertex Byte offset
                        DB $12                          ; Explosion Count 
                        DB ThargonVertSize /6           ; Vertex Count /6
                        DB ThargonVertSize              ; Vertex Count
                        DB ThargonEdgesCnt              ; Edges Count
                        DW $0032                        ; Bounty LoHi
                        DB ThargonNormalsSize           ; Face (Normal) Count
                        DB $14                          ; Range when it turns to a dot
                        DB $14                          ; Energy Max
                        DB $1E                          ; Speed Max
                        DW ThargonNormals               ; Normals
                        DB $02                          ; Q scaling
                        DB $10                          ; Laser power and Nbr Missiles
                        DW ThargonVertices              ; Verticles Address
                        DB 0                            ; Ship Type
                        DB 0                            ; NewB Tactics 
                        DB ShipCanAnger                 ; AI Flags            
                        DB $00                          ; chance of ECM module
                        DB $FF                              ; Supports Solid Fill = false
                        DW $0000                            ; no solid data
                        DB $00                              ; no solid data
                        

	
ThargonVertices:	    DB $09, $00, $28, $9F, $01, $55
                        DB $09, $26, $0C, $DF, $01, $22
                        DB $09, $18, $20, $FF, $02, $33
                        DB $09, $18, $20, $BF, $03, $44
                        DB $09, $26, $0C, $9F, $04, $55
                        DB $09, $00, $08, $3F, $15, $66
                        DB $09, $0A, $0F, $7F, $12, $66
                        DB $09, $06, $1A, $7F, $23, $66
                        DB $09, $06, $1A, $3F, $34, $66
                        DB $09, $0A, $0F, $3F, $45, $66

ThargonVertSize:        equ $ - ThargonVertices	
	
	
ThargonEdges:	        DB $1F, $10, $00, $04
                        DB $1F, $20, $04, $08
                        DB $1F, $30, $08, $0C
                        DB $1F, $40, $0C, $10
                        DB $1F, $50, $00, $10
                        DB $1F, $51, $00, $14
                        DB $1F, $21, $04, $18
                        DB $1F, $32, $08, $1C
                        DB $1F, $43, $0C, $20
                        DB $1F, $54, $10, $24
                        DB $1F, $61, $14, $18
                        DB $1F, $62, $18, $1C
                        DB $1F, $63, $1C, $20
                        DB $1F, $64, $20, $24
                        DB $1F, $65, $24, $14

ThargonEdgesSize:       equ $ - ThargonEdges	
	
	
ThargonEdgesCnt:        equ ThargonEdgesSize/4	
	
	
ThargonNormals:	        DB $9F, $24, $00, $00
                        DB $5F, $14, $05, $07
                        DB $7F, $2E, $2A, $0E
                        DB $3F, $24, $00, $68
                        DB $3F, $2E, $2A, $0E
                        DB $1F, $14, $05, $07
                        DB $1F, $24, $00, $00

	
ThargonNormalsSize:     equ $ - ThargonNormals	
ThargonLen:             equ $ - Thargon	
