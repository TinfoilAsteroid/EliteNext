
Krait:                  DB $01                         ; Number of cargo canisters released when destroyed
                        DW $100E                       ; Ship's targetable area LoHi
                        DW KraitEdges                  ; Edge Data 
                        DB KraitEdgesSize              ; Size of Edge Data
                        DB $00                         ; Gun Vertex Byte offset
                        DB $12                         ; Explosion Count 
                        DB KraitVertSize /6            ; Vertex Count /6
                        DB KraitVertSize               ; Vertex Count
                        DB KraitEdgesCnt               ; Edges Count
                        DW $0064                       ; Bounty LoHi
                        DB KraitNormalsSize            ; Face (Normal) Count
                        DB $14                         ; Range when it turns to a dot
                        DB $50                         ; Energy Max
                        DB $1E                         ; Speed Max
                        DW KraitNormals                ; Normals
                        DB $02                         ; Q scaling
                        DB $10 | ShipMissiles4         ; Laser power and Nbr Missiles
                        DW KraitVertices               ; Verticles Address
                        DB ShipTypeNormal              ; Ship Type
                        DB 0                           ; NewB Tactics 
                        DB ShipCanAnger                ; AI Flags            
                        DB $D0                         ; chance of ECM module
                        DB $FF                              ; Supports Solid Fill = false
                        DW $0000                            ; no solid data
                        DB $00                              ; no solid data
                        
KraitVertices:          DB $00, $00, $60, $1F, $01, $23 
                        DB $00, $12, $30, $3F, $03, $45 
                        DB $00, $12, $30, $7F, $12, $45 
                        DB $5A, $00, $03, $3F, $01, $44 
                        DB $5A, $00, $03, $BF, $23, $55 
                        DB $5A, $00, $57, $1C, $01, $11 
                        DB $5A, $00, $57, $9C, $23, $33 
                        DB $00, $05, $35, $09, $00, $33 
                        DB $00, $07, $26, $06, $00, $33 
                        DB $12, $07, $13, $89, $33, $33 
                        DB $12, $07, $13, $09, $00, $00 
                        DB $12, $0B, $27, $28, $44, $44 
                        DB $12, $0B, $27, $68, $44, $44 
                        DB $24, $00, $1E, $28, $44, $44 
                        DB $12, $0B, $27, $A8, $55, $55 
                        DB $12, $0B, $27, $E8, $55, $55 
                        DB $24, $00, $1E, $A8, $55, $55 
KraitVertSize           equ $  - KraitVertices
KraitEdges:             DB $1F, $03, $00, $04, $1F, $12, $00, $08 
                        DB $1F, $01, $00, $0C, $1F, $23, $00, $10 
                        DB $1F, $35, $04, $10, $1F, $25, $10, $08 
                        DB $1F, $14, $08, $0C, $1F, $04, $0C, $04 
                        DB $1C, $01, $0C, $14, $1C, $23, $10, $18 
                        DB $05, $45, $04, $08, $09, $00, $1C, $28 
                        DB $06, $00, $20, $28, $09, $33, $1C, $24 
                        DB $06, $33, $20, $24, $08, $44, $2C, $34 
                        DB $08, $44, $34, $30, $07, $44, $30, $2C 
                        DB $07, $55, $38, $3C, $08, $55, $3C, $40 
                        DB $08, $55, $40, $38
KraitEdgesSize          equ $  - KraitEdges
KraitEdgesCnt           equ KraitEdgesSize/4
KraitNormals            DB $1F, $07, $30, $06 
                        DB $5F, $07, $30, $06, $DF, $07, $30, $06 
                        DB $9F, $07, $30, $06, $3F, $4D, $00, $9A 
                        DB $BF, $4D, $00, $9A 
KraitNormalsSize        equ $  - KraitNormals                    
KraitLen                equ $  - Krait
