TestVector:             DB $03                      ; Number of cargo canisters released when destroyed
                        DW $4123                    ; Ship's targetable area LoHi
                        DW TestVectorEdges          ; Edge Data 
                        DB TestVectorEdgesSize      ; Size of Edge Data
                        DB $54                      ; Gun Vertex Byte offset
                        DB $2A                      ; Explosion Count 
                        DB TestVectorVertSize /6    ; Vertex Count /6
                        DB TestVectorVertSize       ; Vertex Count
                        DB TestVectorEdgesCnt       ; Edges Count
                        DW $0000                    ; Bounty LoHi
                        DB TestVectorNormalsSize    ; Face (Normal) Count
                        DB $32                      ; Range when it turns to a dot
                        DB $96                      ; Energy Max
                        DB $1C                      ; Speed Max
                        DW TestVectorNormals        ; Normals
                        DB $04                      ; Q scaling
                        DB $01                      ; Laser power and Nbr Missiles
                        DW TestVectorVertices       ; Verticles Address
                        DB ShipTypeDebug            ; Ship Type
                        DB 0                        ; NewB Tactics 
                        DB 0                        ; AI Flags            
                        DB $00                      ; chance of ECM module

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
