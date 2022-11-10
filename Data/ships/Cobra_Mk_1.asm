Cobra_Mk_1:	            DB $03                              ; Number of cargo canisters released when destroyed
                        DW $2649                            ; Ship's targetable area LoHi
                        DW Cobra_Mk_1Edges                  ; Edge Data 
                        DB Cobra_Mk_1EdgesSize              ; Size of Edge Data
                        DB $28                              ; Gun Vertex Byte offset
                        DB $1A                              ; Explosion Count 
                        DB Cobra_Mk_1VertSize /6            ; Vertex Count /6
                        DB Cobra_Mk_1VertSize               ; Vertex Count
                        DB Cobra_Mk_1EdgesCnt               ; Edges Count
                        DW $4B00                            ; Bounty LoHi
                        DB Cobra_Mk_1NormalsSize            ; Face (Normal) Count
                        DB $13                              ; Range when it turns to a dot
                        DB $51                              ; Energy Max
                        DB $1A                              ; Speed Max
                        DW Cobra_Mk_1Normals                ; Normals
                        DB $02                              ; Q scaling
                        DB $20 | ShipMissiles3              ; Laser power and Nbr Missiles
                        DW Cobra_Mk_1Vertices               ; Verticles Address
                        DB ShipTypeNormal                   ; Ship Type
                        DB 0                                ; NewB Tactics                        
                        DB ShipCanAnger                     ; AI Flags
                        DB $30                              ; chance of ECM module
                        DB $FF                              ; Supports Solid Fill = false
                        DW $0000                            ; no solid data
                        DB $00                              ; no solid data

Cobra_Mk_1Vertices:	    DB $12, $01, $32, $DF, $01, $23
                        DB $12, $01, $32, $5F, $01, $45
                        DB $42, $00, $07, $9F, $23, $88
                        DB $42, $00, $07, $1F, $45, $99
                        DB $20, $0C, $26, $BF, $26, $78
                        DB $20, $0C, $26, $3F, $46, $79
                        DB $36, $0C, $26, $FF, $13, $78
                        DB $36, $0C, $26, $7F, $15, $79
                        DB $00, $0C, $06, $34, $02, $46
                        DB $00, $01, $32, $42, $01, $11
                        DB $00, $01, $3C, $5F, $01, $11
Cobra_Mk_1VertSize:     equ $ - Cobra_Mk_1Vertices
Cobra_Mk_1Edges:	    DB $1F, $01, $04, $00
                        DB $1F, $23, $00, $08
                        DB $1F, $38, $08, $18
                        DB $1F, $17, $18, $1C
                        DB $1F, $59, $1C, $0C
                        DB $1F, $45, $0C, $04
                        DB $1F, $28, $08, $10
                        DB $1F, $67, $10, $14
                        DB $1F, $49, $14, $0C
                        DB $14, $02, $00, $20
                        DB $14, $04, $20, $04
                        DB $10, $26, $10, $20
                        DB $10, $46, $20, $14
                        DB $1F, $78, $10, $18
                        DB $1F, $79, $14, $1C
                        DB $14, $13, $00, $18
                        DB $14, $15, $04, $1C
                        DB $02, $01, $28, $24
Cobra_Mk_1EdgesSize:    equ $ - Cobra_Mk_1Edges
Cobra_Mk_1EdgesCnt:     equ Cobra_Mk_1EdgesSize/4
Cobra_Mk_1Normals:	    DB $1F, $00, $29, $0A
                        DB $5F, $00, $1B, $03
                        DB $9F, $08, $2E, $08
                        DB $DF, $0C, $39, $0C
                        DB $1F, $08, $2E, $08
                        DB $5F, $0C, $39, $0C
                        DB $1F, $00, $31, $00
                        DB $3F, $00, $00, $9A
                        DB $BF, $79, $6F, $3E
                        DB $3F, $79, $6F, $3E
Cobra_Mk_1NormalsSize:  equ $ - Cobra_Mk_1Normals
Cobra_Mk_1Len:          equ $ - Cobra_Mk_1
