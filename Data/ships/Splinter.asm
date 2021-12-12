Splinter:	            DB $B0, $01, $00
                        DW SplinterEdges
                        DB SplinterEdgesSize
                        DB $00, $16
                        DB SplinterVertSize
                        DB SplinterEdgesCnt
                        DB $00, $00
                        DB SplinterNormalsSize
                        DB $08, $14, $0A
                        DW SplinterNormals
                        DB $05, $00
                        DW SplinterVertices
                        DB 0,0                      ; Type and Tactics

SplinterVertices:	    DB $18, $19, $10, $DF, $12, $33
                        DB $00, $0C, $0A, $3F, $02, $33
                        DB $0B, $06, $02, $5F, $01, $33
                        DB $0C, $2A, $07, $1F, $01, $22
SplinterVertSize:       equ $ - SplinterVertices
SplinterEdges:	        DB $1F, $23, $00, $04
                        DB $1F, $03, $04, $08
                        DB $1F, $01, $08, $0C
                        DB $1F, $12, $0C, $00
                        DB $1F, $13, $00, $08
                        DB $1F, $02, $0C, $04
SplinterEdgesSize:      equ $ - SplinterEdges
SplinterEdgesCnt:       equ SplinterEdgesSize/4
SplinterNormals:	    DB $1F, $23, $00, $04
                        DB $1F, $03, $04, $08
                        DB $1F, $01, $08, $0C
                        DB $1F, $12, $0C, $00
SplinterNormalsSize:    equ $ - SplinterNormals
SplinterLen:            equ $ - Splinter
