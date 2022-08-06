Boulder:	            DB $00                               ; Number of cargo canisters released when destroyed
                        DW 30 * 30                           ; Ship's targetable area LoHi
                        DW BoulderEdges                      ; Edge Data 
                        DB BoulderEdgesSize                  ; Size of Edge Data
                        DB $00                               ; Gun Vertex Byte offset
                        DB $0E                               ; Explosion Count 
                        DB BoulderVertSize /6                ; Vertex Count /6
                        DB BoulderVertSize                   ; Vertex Count
                        DB BoulderEdgesCnt                   ; Edges Count
                        DW $0001                             ; Bounty LoHi
                        DB BoulderNormalsSize                ; Face (Normal) Count
                        DB $14                               ; Range when it turns to a dot
                        DB $14                               ; Energy Max
                        DB $1E                               ; Speed Max
                        DW BoulderNormals                    ; Normals
                        DB $02                               ; Q scaling
                        DB $00                               ; Laser power and Nbr Missiles
                        DW BoulderVertices                   ; Verticles Address
                        DB ShipTypeJunk                      ; Ship Type
                        DB 0                                 ; NewB Tactics                        
                        DB 0                                 ; AI Flags
                        DB $A0                               ; chance of ECM module
BoulderVertices:	    DB $12, $25, $0B, $BF, $01, $59
                        DB $1E, $07, $0C, $1F, $12, $56
                        DB $1C, $07, $0C, $7F, $23, $67
                        DB $02, $00, $27, $3F, $34, $78
                        DB $1C, $22, $1E, $BF, $04, $89
                        DB $05, $0A, $0D, $5F, $FF, $FF
                        DB $14, $11, $1E, $3F, $FF, $FF
BoulderVertSize:        equ $ - BoulderVertices
BoulderEdges:	        DB $1F, $15, $00, $04
                        DB $1F, $26, $04, $08
                        DB $1F, $37, $08, $0C
                        DB $1F, $48, $0C, $10
                        DB $1F, $09, $10, $00
                        DB $1F, $01, $00, $14
                        DB $1F, $12, $04, $14
                        DB $1F, $23, $08, $14
                        DB $1F, $34, $0C, $14
                        DB $1F, $04, $10, $14
                        DB $1F, $59, $00, $18
                        DB $1F, $56, $04, $18
                        DB $1F, $67, $08, $18
                        DB $1F, $78, $0C, $18
                        DB $1F, $89, $10, $18
BoulderEdgesSize:       equ $ - BoulderEdges
BoulderEdgesCnt:        equ BoulderEdgesSize/4
BoulderNormals:	        DB $DF, $0F, $03, $08
                        DB $9F, $07, $0C, $1E
                        DB $5F, $20, $2F, $18
                        DB $FF, $03, $27, $07
                        DB $FF, $05, $04, $01
                        DB $1F, $31, $54, $08
                        DB $3F, $70, $15, $15
                        DB $7F, $4C, $23, $52
                        DB $3F, $16, $38, $89
                        DB $3F, $28, $6E, $26
BoulderNormalsSize:     equ $ - BoulderNormals
BoulderLen:             equ $ - Boulder
