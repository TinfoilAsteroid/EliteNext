Escape_Pod:             DB $20                          ; Number of cargo canisters released when destroyed
                        DW $0100                        ; Ship's targetable area LoHi
                        DW Escape_PodEdges              ; Edge Data 
                        DB Escape_PodEdgesSize          ; Size of Edge Data
                        DB $00                          ; Gun Vertex Byte offset
                        DB $16                          ; Explosion Count 
                        DB Escape_PodVertSize /6        ; Vertex Count /6
                        DB Escape_PodVertSize           ; Vertex Count
                        DB Escape_PodEdgesCnt           ; Edges Count
                        DW $0000                        ; Bounty LoHi
                        DB Escape_PodNormalsSize        ; Face (Normal) Count
                        DB $08                          ; Range when it turns to a dot
                        DB $11                          ; Energy Max
                        DB $08                          ; Speed Max
                        DW Escape_PodNormals            ; Normals
                        DB $04                          ; Q scaling
                        DB $00                          ; Laser power and Nbr Missiles
                        DW Escape_PodVertices           ; Verticles Address
                        DB 0                            ; Ship Type
                        DB 0                            ; NewB Tactics 
                        DB 0                            ; AI Flags            
                        DB $FF                          ; chance of ECM module
                        DB $FF                              ; Supports Solid Fill = false
                        DW $0000                            ; no solid data
                        DB $00                              ; no solid data

Escape_PodVertices:	    DB $07, $00, $24, $9F, $12, $33
                        DB $07, $0E, $0C, $FF, $02, $33
                        DB $07, $0E, $0C, $BF, $01, $33
                        DB $15, $00, $00, $1F, $01, $22
Escape_PodVertSize:     equ $ - Escape_PodVertices	
Escape_PodEdges:	    DB $1F, $23, $00, $04
                        DB $1F, $03, $04, $08
                        DB $1F, $01, $08, $0C
                        DB $1F, $12, $0C, $00
                        DB $1F, $13, $00, $08
                        DB $1F, $02, $0C, $04
Escape_PodEdgesSize:    equ $ - Escape_PodEdges	
Escape_PodEdgesCnt:     equ Escape_PodEdgesSize/4	
Escape_PodNormals:	    DB $3F, $34, $00, $7A
                        DB $1F, $27, $67, $1E
                        DB $5F, $27, $67, $1E
                        DB $9F, $70, $00, $00
Escape_PodNormalsSize:  equ $ - Escape_PodNormals	
Escape_PodLen:          equ $ - Escape_Pod	
