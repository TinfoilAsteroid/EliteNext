TestVector:             DB $03, $41, $23
                        DW TestVectorEdges
                        DB TestVectorEdgesSize
                        DB $54,$2A
                        DB TestVectorVertSize
                        DB TestVectorEdgesCnt
                        DB $00,$00
                        DB TestVectorNormalsSize
                        DB $32,$96,$1C
                        DW TestVectorNormals
                        DB $04,$01
                        DW TestVectorVertices
TestVectorVertices	    DB $00,$40,$00,$1F,$00,$00 
                        DB $00,$20,$00,$1F,$00,$00 
                        DB $40,$00,$00,$1F,$01,$01 
                        DB $20,$00,$00,$1F,$01,$01 
                        DB $00,$00,$40,$1F,$02,$02 
                        DB $00,$00,$20,$1F,$02,$02 
                        DB $00,$00,$00,$1F,$03,$03 
TestVectorVertSize      equ $  - TestVectorVertices
TestVectorEdges		    DB $1F,$00,$00,$04
                        DB $1F,$00,$08,$0C
                        DB $1F,$00,$10,$14
                        DB $1F,$00,$18,$18                    
TestVectorEdgesSize     equ $  - TestVectorEdges
TestVectorEdgesCnt      equ TestVectorEdgesSize/4
; start normals #0 = top f,$on,$ p,$at,$ o,$ C,$br,$ Mk III
TestVectorNormals	    DB $1F,$00,$10,$00
                        DB $1F,$10,$00,$00
                        DB $1F,$00,$00,$10
                        DB $1F,$00,$00,$10
TestVectorNormalsSize   equ $  - TestVectorNormals                    
TestVectorLen           equ $  - TestVector   
