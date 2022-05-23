Escape_Pod:             DB $20
                        DW $0100
                        DW Escape_PodEdges
                        DB Escape_PodEdgesSize
                        DB $00, $16
                        DB Escape_PodVertSize /6 
                        DB Escape_PodVertSize
                        DB Escape_PodEdgesCnt
                        DB $00, $00
                        DB Escape_PodNormalsSize
                        DB $08, $11, $08
                        DW Escape_PodNormals
                        DB $04, $00
                        DW Escape_PodVertices
                        DB 0,0                      ; Type and Tactics
                        DB 0
                        DB $FF                      ; chance of ECM module
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
