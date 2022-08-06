Viper:                  DB $00                         ; Number of cargo canisters released when destroyed
                        DW $15F9                       ; Ship's targetable area LoHi
                        DW ViperEdges                  ; Edge Data 
                        DB ViperEdgesSize              ; Size of Edge Data
                        DB $00                         ; Gun Vertex Byte offset
                        DB $2A                         ; Explosion Count 
                        DB ViperVertSize /6            ; Vertex Count /6
                        DB ViperVertSize               ; Vertex Count
                        DB ViperEdgesCnt               ; Edges Count
                        DW $0000                       ; Bounty LoHi
                        DB ViperNormalsSize            ; Face (Normal) Count
                        DB $17                         ; Range when it turns to a dot
                        DB $64                         ; Energy Max
                        DB $20                         ; Speed Max
                        DW ViperNormals                ; Normals
                        DB $01                         ; Q scaling
                        DB $11                         ; Laser power and Nbr Missiles
                        DW ViperVertices               ; Verticles Address
                        DB ShipTypeNormal              ; Ship Type
                        DB 0                           ; NewB Tactics 
                        DB ShipCanAnger                ; AI Flags            
                        DB $FF                         ; chance of ECM module
                        
ViperVertices:          DB $00, $00, $48, $1F, $21, $43 
                        DB $00, $10, $18, $1E, $10, $22 
                        DB $00, $10, $18, $5E, $43, $55 
                        DB $30, $00, $18, $3F, $42, $66 
                        DB $30, $00, $18, $BF, $31, $66 
                        DB $18, $10, $18, $7E, $54, $66 
                        DB $18, $10, $18, $FE, $35, $66 
                        DB $18, $10, $18, $3F, $20, $66 
                        DB $18, $10, $18, $BF, $10, $66 
                        DB $20, $00, $18, $B3, $66, $66 
                        DB $20, $00, $18, $33, $66, $66 
                        DB $08, $08, $18, $33, $66, $66 
                        DB $08, $08, $18, $B3, $66, $66 
                        DB $08, $08, $18, $F2, $66, $66 
                        DB $08, $08, $18, $72, $66, $66 
ViperVertSize           equ $  - ViperVertices
ViperEdges:             DB $1F, $42, $00, $0C, $1E, $21, $00, $04 
                        DB $1E, $43, $00, $08, $1F, $31, $00, $10 
                        DB $1E, $20, $04, $1C, $1E, $10, $04, $20 
                        DB $1E, $54, $08, $14, $1E, $53, $08, $18 
                        DB $1F, $60, $1C, $20, $1E, $65, $14, $18 
                        DB $1F, $61, $10, $20, $1E, $63, $10, $18 
                        DB $1F, $62, $0C, $1C, $1E, $46, $0C, $14 
                        DB $13, $66, $24, $30, $12, $66, $24, $34 
                        DB $13, $66, $28, $2C, $12, $66, $28, $38 
                        DB $10, $66, $2C, $38, $10, $66, $30, $34 
ViperEdgesSize          equ $  - ViperEdges
ViperEdgesCnt           equ ViperEdgesSize/4
ViperNormals            DB $1F, $00, $20, $00, $9F, $16, $21, $0B 
                        DB $1F, $16, $21, $0B, $DF, $16, $21, $0B 
                        DB $5F, $16, $21, $0B, $5F, $00, $20, $00 
                        DB $3F, $00, $00, $30
ViperNormalsSize        equ $  - ViperNormals                    
ViperLen                equ $  - Viper
