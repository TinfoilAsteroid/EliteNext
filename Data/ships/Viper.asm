; Mapping Orginal to new
; 0    => 0
; 1-2  => 1-2
; 3    => EQU Edges
; 4    => EQU Normals
; 5    => EQU EdgesCnt
; 6    => 6
; 7    => 7
; 8    => EQU VertSize
; 9    => EQU EdgesCnt
; 10-11=> 10-11
; 12   => EQU  NormalsSize
; 13   => 13
; 14   => 14
; 15   => 15
; 16   => EQU Edges
; 17   => EQU Normals
; 18   => 18
; 19   => 19
;\ -> &5C93  \ Viper = Type 16
Viper:                  DB $00
                        DW $15F9
                        DW ViperEdges
                        DB ViperEdgesSize
                        DB $00,$2A
                        DB ViperVertSize /6 
                        DB ViperVertSize
                        DB ViperEdgesCnt
                        DB $00,$00
                        DB ViperNormalsSize
                        DB $17, $64, $20 
                        DW ViperNormals
                        DB $01, $11 
                        DW ViperVertices
                        DB 0,0                      ; Type and Tactics
                        DB ShipCanAnger
                        
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
