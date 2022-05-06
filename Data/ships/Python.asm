;\ -> &5BA1 \ Python = Type 12
Python:                 DB $05
                        DW $1900
                        DW PythonEdges
                        DB PythonEdgesSize
                        DB $00,$2A
                        DB PythonVertSize /6 
                        DB PythonVertSize
                        DB PythonEdgesCnt
                        DB $00,$00
                        DB PythonNormalsSize
                        DB $28,$FA,$14
                        DW PythonNormals
                        DB $00, $1B
                        DW PythonVertices
                        DB 0,0                      ; Type and Tactics
                        DB ShipCanAnger

PythonVertices:         DB $00, $00, $E0, $1F, $10, $32 
                        DB $00, $30, $30, $1E, $10, $54 
                        DB $60, $00, $10, $3F, $FF, $FF 
                        DB $60, $00, $10, $BF, $FF, $FF 
                        DB $00, $30, $20, $3E, $54, $98 
                        DB $00, $18, $70, $3F, $89, $CC 
                        DB $30, $00, $70, $BF, $B8, $CC 
                        DB $30, $00, $70, $3F, $A9, $CC 
                        DB $00, $30, $30, $5E, $32, $76 
                        DB $00, $30, $20, $7E, $76, $BA 
                        DB $00, $18, $70, $7E, $BA, $CC 
PythonVertSize          equ $  - PythonVertices
PythonEdges:            DB $1E, $32, $00, $20, $1F, $20, $00, $0C 
                        DB $1F, $31, $00, $08, $1E, $10, $00, $04 
                        DB $1D, $59, $08, $10, $1D, $51, $04, $08 
                        DB $1D, $37, $08, $20, $1D, $40, $04, $0C 
                        DB $1D, $62, $0C, $20, $1D, $A7, $08, $24 
                        DB $1D, $84, $0C, $10, $1D, $B6, $0C, $24 
                        DB $05, $88, $0C, $14, $05, $BB, $0C, $28 
                        DB $05, $99, $08, $14, $05, $AA, $08, $28 
                        DB $1F, $A9, $08, $1C, $1F, $B8, $0C, $18 
                        DB $1F, $C8, $14, $18, $1F, $C9, $14, $1C 
                        DB $1D, $AC, $1C, $28, $1D, $CB, $18, $28 
                        DB $1D, $98, $10, $14, $1D, $BA, $24, $28 
                        DB $1D, $54, $04, $10, $1D, $76, $20, $24
PythonEdgesSize         equ $  - PythonEdges
PythonEdgesCnt          equ PythonEdgesSize/4
PythonNormals           DB $9E, $1B, $28, $0B, $1E, $1B, $28, $0B 
                        DB $DE, $1B, $28, $0B, $5E, $1B, $28, $0B 
                        DB $9E, $13, $26, $00, $1E, $13, $26, $00 
                        DB $DE, $13, $26, $00, $5E, $13, $26, $00 
                        DB $BE, $19, $25, $0B, $3E, $19, $25, $0B 
                        DB $7E, $19, $25, $0B, $FE, $19, $25, $0B 
                        DB $3E, $00, $00, $70
PythonNormalsSize       equ $  - PythonNormals                    
PythonLen               equ $  - Python
