Asteroid:	            DB $00                          ; Number of cargo canisters released when destroyed
                        DW 80 * 80                      ; Ship's targetable area LoHi
                        DW AsteroidEdges                ; Edge Data 
                        DB AsteroidEdgesSize            ; Size of Edge Data
                        DB $00                          ; Gun Vertex Byte offset
                        DB $22                          ; Explosion Count 
                        DB AsteroidVertSize /6          ; Vertex Count /6
                        DB AsteroidVertSize             ; Vertex Count
                        DB AsteroidEdgesCnt             ; Edges Count
                        DW $0005                        ; Bounty LoHi
                        DB AsteroidNormalsSize          ; Face (Normal) Count
                        DB $32                          ; Range when it turns to a dot
                        DB $3C                          ; Energy Max
                        DB $1E                          ; Speed Max
                        DW AsteroidNormals              ; Normals
                        DB $01                          ; Q scaling
                        DB $00                          ; Laser power and Nbr Missiles
                        DW AsteroidVertices             ; Verticles Address
                        DB ShipTypeJunk                 ; Ship Type
                        DB 0                            ; NewB Tactics                        
                        DB 0                            ; AI Flags
                        DB $00                          ; chance of ECM module
                        DB $FF                              ; Supports Solid Fill = false
                        DW $0000                            ; no solid data
                        DB $00                              ; no solid data

AsteroidVertices:	    DB $00, $50, $00, $1F, $FF, $FF ;01
                        DB $50, $0A, $00, $DF, $FF, $FF ;02
                        DB $00, $50, $00, $5F, $FF, $FF ;03
                        DB $46, $28, $00, $5F, $FF, $FF ;04
                        DB $3C, $32, $00, $1F, $65, $DC ;05
                        DB $32, $00, $3C, $1F, $FF, $FF ;06
                        DB $28, $00, $46, $9F, $10, $32 ;07
                        DB $00, $1E, $4B, $3F, $FF, $FF ;08
                        DB $00, $32, $3C, $7F, $98, $BA ;09
AsteroidVertSize:       equ $ - AsteroidVertices        
AsteroidEdges:	        DB $1F, $72, $00, $04           ;01 
                        DB $1F, $D6, $00, $10           ;02
                        DB $1F, $C5, $0C, $10           ;03
                        DB $1F, $B4, $08, $0C           ;04
                        DB $1F, $A3, $04, $08           ;05
                        DB $1F, $32, $04, $18           ;06
                        DB $1F, $31, $08, $18           ;07
                        DB $1F, $41, $08, $14           ;08
                        DB $1F, $10, $14, $18           ;09
                        DB $1F, $60, $00, $14           ;10
                        DB $1F, $54, $0C, $14           ;11
                        DB $1F, $20, $00, $18           ;12
                        DB $1F, $65, $10, $14           ;13
                        DB $1F, $A8, $04, $20           ;14
                        DB $1F, $87, $04, $1C           ;15
                        DB $1F, $D7, $00, $1C           ;16
                        DB $1F, $DC, $10, $1C           ;17
                        DB $1F, $C9, $0C, $1C           ;18
                        DB $1F, $B9, $0C, $20
                        DB $1F, $BA, $08, $20
                        DB $1F, $98, $1C, $20

AsteroidEdgesSize:      equ $ - AsteroidEdges
AsteroidEdgesCnt:       equ AsteroidEdgesSize/4
AsteroidNormals:	    DB $1F, $09, $42, $51           ;01
                        DB $5F, $09, $42, $51           ;02
                        DB $9F, $48, $40, $1F           ;03
                        DB $DF, $40, $49, $2F           ;04
                        DB $5F, $2D, $4F, $41           ;05
                        DB $1F, $87, $0F, $23           ;06
                        DB $1F, $26, $4C, $46           ;07
                        DB $BF, $42, $3B, $27           ;08
                        DB $FF, $43, $0F, $50           ;09
                        DB $7F, $42, $0E, $4B           ;10
                        DB $FF, $46, $50, $28           ;11
                        DB $7F, $3A, $66, $33           ;12
                        DB $3F, $51, $09, $43           ;13
                        DB $3F, $2F, $5E, $3F           ;14
AsteroidNormalsSize:    equ $ - AsteroidNormals         
AsteroidLen:            equ $ - Asteroid                
                                                        
                                                        