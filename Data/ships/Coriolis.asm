Coriolis:	            DB $00                                      ; Number of cargo canisters released when destroyed
                        DW $6400                                    ; Ship's targetable area LoHi
                        DW CoriolisEdges                            ; Edge Data 
                        DB CoriolisEdgesSize                        ; Size of Edge Data
                        DB $00                                      ; Gun Vertex Byte offset
                        DB $36                                      ; Explosion Count 
                        DB CoriolisVertSize /6                      ; Vertex Count /6
                        DB CoriolisVertSize                         ; Vertex Count
                        DB CoriolisEdgesCnt                         ; Edges Count
                        DW $0000                                    ; Bounty LoHi
                        DB CoriolisNormalsSize                      ; Face (Normal) Count
                        DB $78                                      ; Range when it turns to a dot
                        DB $F0                                      ; Energy Max
                        DB $00                                      ; Speed Max
                        DW CoriolisNormals                          ; Normals
                        DB $00                                      ; Q scaling
                        DB $06                                      ; Laser power and Nbr Missiles
                        DW CoriolisVertices                         ; Verticles Address
                        DB ShipTypeStation                          ; Ship Type
                        DB 0                                        ; NewB Tactics     
                        DB ShipFighterBaySize | ShipFighterViper    ; AI Flags            
                        DB $FF                                      ; chance of ECM module
                        DB $FF                              ; Supports Solid Fill = false
                        DW $0000                            ; no solid data
                        DB $00                              ; no solid data

CoriolisVertices:	    DB $A0, $00, $A0, $1F, $10, $62
                        DB $00, $A0, $A0, $1F, $20, $83
                        DB $A0, $00, $A0, $9F, $30, $74
                        DB $00, $A0, $A0, $5F, $10, $54
                        DB $A0, $A0, $00, $5F, $51, $A6
                        DB $A0, $A0, $00, $1F, $62, $B8
                        DB $A0, $A0, $00, $9F, $73, $C8
                        DB $A0, $A0, $00, $DF, $54, $97
                        DB $A0, $00, $A0, $3F, $A6, $DB
                        DB $00, $A0, $A0, $3F, $B8, $DC
                        DB $A0, $00, $A0, $BF, $97, $DC
                        DB $00, $A0, $A0, $7F, $95, $DA
                        DB $0A, $1E, $A0, $5E, $00, $00
                        DB $0A, $1E, $A0, $1E, $00, $00
                        DB $0A, $1E, $A0, $9E, $00, $00
                        DB $0A, $1E, $A0, $DE, $00, $00
CoriolisVertSize:       equ $ - CoriolisVertices	
CoriolisEdges:	        DB $1F, $10, $00, $0C
                        DB $1F, $20, $00, $04
                        DB $1F, $30, $04, $08
                        DB $1F, $40, $08, $0C
                        DB $1F, $51, $0C, $10
                        DB $1F, $61, $00, $10
                        DB $1F, $62, $00, $14
                        DB $1F, $82, $14, $04
                        DB $1F, $83, $04, $18
                        DB $1F, $73, $08, $18
                        DB $1F, $74, $08, $1C
                        DB $1F, $54, $0C, $1C
                        DB $1F, $DA, $20, $2C
                        DB $1F, $DB, $20, $24
                        DB $1F, $DC, $24, $28
                        DB $1F, $D9, $28, $2C
                        DB $1F, $A5, $10, $2C
                        DB $1F, $A6, $10, $20
                        DB $1F, $B6, $14, $20
                        DB $1F, $B8, $14, $24
                        DB $1F, $C8, $18, $24
                        DB $1F, $C7, $18, $28
                        DB $1F, $97, $1C, $28
                        DB $1F, $95, $1C, $2C
                        DB $1E, $00, $30, $34
                        DB $1E, $00, $34, $38
                        DB $1E, $00, $38, $3C
                        DB $1E, $00, $3C, $30
CoriolisEdgesSize:      equ $ - CoriolisEdges	
CoriolisEdgesCnt:       equ CoriolisEdgesSize/4	
CoriolisNormals:	    DB $1F, $00, $00, $A0
                        DB $5F, $6B, $6B, $6B
                        DB $1F, $6B, $6B, $6B
                        DB $9F, $6B, $6B, $6B
                        DB $DF, $6B, $6B, $6B
                        DB $5F, $00, $A0, $00
                        DB $1F, $A0, $00, $00
                        DB $9F, $A0, $00, $00
                        DB $1F, $00, $A0, $00
                        DB $FF, $6B, $6B, $6B
                        DB $7F, $6B, $6B, $6B
                        DB $3F, $6B, $6B, $6B
                        DB $BF, $6B, $6B, $6B
                        DB $3F, $00, $00, $A0
CoriolisNormalsSize:    equ $ - CoriolisNormals
CoriolisLen:            equ $ - Coriolis	
