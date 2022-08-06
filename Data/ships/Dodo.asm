Dodo:	                DB $00                        ; Number of cargo canisters released when destroyed
                        DW $7E90                      ; Ship's targetable area LoHi
                        DW DodoEdges                  ; Edge Data 
                        DB DodoEdgesSize              ; Size of Edge Data
                        DB $00                        ; Gun Vertex Byte offset
                        DB $36                        ; Explosion Count 
                        DB DodoVertSize /6            ; Vertex Count /6
                        DB DodoVertSize               ; Vertex Count
                        DB DodoEdgesCnt               ; Edges Count
                        DW $0000                      ; Bounty LoHi
                        DB DodoNormalsSize            ; Face (Normal) Count
                        DB $7D                        ; Range when it turns to a dot
                        DB $F0                        ; Energy Max
                        DB $00                        ; Speed Max
                        DW DodoNormals                ; Normals
                        DB $00                        ; Q scaling
                        DB $00                        ; Laser power and Nbr Missiles
                        DW DodoVertices               ; Verticles Address
                        DB ShipTypeStation            ; Ship Type
                        DB 0                          ; NewB Tactics 
                        DB 0                          ; AI Flags            
                        DB $FF                        ; chance of ECM module                                  
DodoVertices:	        DB $00, $96, $C4, $1F, $01, $55
                        DB $8F, $2E, $C4, $1F, $01, $22
                        DB $58, $79, $C4, $5F, $02, $33
                        DB $58, $79, $C4, $DF, $03, $44
                        DB $8F, $2E, $C4, $9F, $04, $55
                        DB $00, $F3, $2E, $1F, $15, $66
                        DB $E7, $4B, $2E, $1F, $12, $77
                        DB $8F, $C4, $2E, $5F, $23, $88
                        DB $8F, $C4, $2E, $DF, $34, $99
                        DB $E7, $4B, $2E, $9F, $45, $AA
                        DB $8F, $C4, $2E, $3F, $16, $77
                        DB $E7, $4B, $2E, $7F, $27, $88
                        DB $00, $F3, $2E, $7F, $38, $99
                        DB $E7, $4B, $2E, $FF, $49, $AA
                        DB $8F, $C4, $2E, $BF, $56, $AA
                        DB $58, $79, $C4, $3F, $67, $BB
                        DB $8F, $2E, $C4, $7F, $78, $BB
                        DB $00, $96, $C4, $7F, $89, $BB
                        DB $8F, $2E, $C4, $FF, $9A, $BB
                        DB $58, $79, $C4, $BF, $6A, $BB
                        DB $10, $20, $C4, $9E, $00, $00
                        DB $10, $20, $C4, $DE, $00, $00
                        DB $10, $20, $C4, $17, $00, $00
                        DB $10, $20, $C4, $57, $00, $00
DodoVertSize:           equ $ - DodoVertices	
DodoEdges:	            DB $1F, $01, $00, $04
                        DB $1F, $02, $04, $08
                        DB $1F, $03, $08, $0C
                        DB $1F, $04, $0C, $10
                        DB $1F, $05, $10, $00
                        DB $1F, $16, $14, $28
                        DB $1F, $17, $28, $18
                        DB $1F, $27, $18, $2C
                        DB $1F, $28, $2C, $1C
                        DB $1F, $38, $1C, $30
                        DB $1F, $39, $30, $20
                        DB $1F, $49, $20, $34
                        DB $1F, $4A, $34, $24
                        DB $1F, $5A, $24, $38
                        DB $1F, $56, $38, $14
                        DB $1F, $7B, $3C, $40
                        DB $1F, $8B, $40, $44
                        DB $1F, $9B, $44, $48
                        DB $1F, $AB, $48, $4C
                        DB $1F, $6B, $4C, $3C
                        DB $1F, $15, $00, $14
                        DB $1F, $12, $04, $18
                        DB $1F, $23, $08, $1C
                        DB $1F, $34, $0C, $20
                        DB $1F, $45, $10, $24
                        DB $1F, $67, $28, $3C
                        DB $1F, $78, $2C, $40
                        DB $1F, $89, $30, $44
                        DB $1F, $9A, $34, $48
                        DB $1F, $6A, $38, $4C
                        DB $1E, $00, $50, $54
                        DB $14, $00, $54, $5C
                        DB $17, $00, $5C, $58
                        DB $14, $00, $58, $50
DodoEdgesSize:          equ $ - DodoEdges	
DodoEdgesCnt:           equ DodoEdgesSize/4	
DodoNormals:	        DB $1F, $00, $00, $C4
                        DB $1F, $67, $8E, $58
                        DB $5F, $A9, $37, $59
                        DB $5F, $00, $B0, $58
                        DB $DF, $A9, $37, $59
                        DB $9F, $67, $8E, $58
                        DB $3F, $00, $B0, $58
                        DB $3F, $A9, $37, $59
                        DB $7F, $67, $8E, $58
                        DB $FF, $67, $8E, $58
                        DB $BF, $A9, $37, $59
                        DB $3F, $00, $00, $C4
DodoNormalsSize:        equ $ - DodoNormals	
DodoLen:                equ $ - Dodo	
