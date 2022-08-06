Bushmaster:	            DB $00                           ; Number of cargo canisters released when destroyed
                        DW $109A                         ; Ship's targetable area LoHi
                        DW BushmasterEdges               ; Edge Data 
                        DB BushmasterEdgesSize           ; Size of Edge Data
                        DB $00                           ; Gun Vertex Byte offset
                        DB $1E                           ; Explosion Count 
                        DB BushmasterVertSize /6         ; Vertex Count /6
                        DB BushmasterVertSize            ; Vertex Count
                        DB BushmasterEdgesCnt            ; Edges Count
                        DW $0096                         ; Bounty LoHi
                        DB BushmasterNormalsSize         ; Face (Normal) Count
                        DB $14                           ; Range when it turns to a dot
                        DB $4A                           ; Energy Max
                        DB $23                           ; Speed Max
                        DW BushmasterNormals             ; Normals
                        DB $02                           ; Q scaling
                        DB $20 | ShipMissiles1           ; Laser power and Nbr Missiles
                        DW BushmasterVertices            ; Verticles Address
                        DB ShipTypeNormal                ; Ship Type
                        DB 0                             ; NewB Tactics                        
                        DB ShipCanAnger                  ; AI Flags
                        DB $70                           ; chance of ECM module
BushmasterVertices:	    DB $00, $00, $3C, $1F, $23, $01  ; 01
                        DB $32, $00, $14, $1F, $57, $13  ; 02
                        DB $32, $00, $14, $9F, $46, $02  ; 03
                        DB $00, $14, $00, $1F, $45, $01  ; 04
                        DB $00, $14, $28, $7F, $FF, $FF  ; 05
                        DB $00, $0E, $28, $3F, $88, $45  ; 06
                        DB $28, $00, $28, $3F, $88, $57  ; 07
                        DB $28, $00, $28, $BF, $88, $46  ; 08
                        DB $00, $04, $28, $2A, $88, $88  ; 09
                        DB $0A, $00, $28, $2A, $88, $88  ; 10
                        DB $00, $04, $28, $6A, $88, $88  ; 11
                        DB $0A, $00, $28, $AA, $88, $88  ; 12           ; 12 * 6 = 72
BushmasterVertSize:     equ $ - BushmasterVertices
BushmasterEdges:	    DB $1F, $13, $00, $04            ; 01
                        DB $1F, $02, $00, $08            ; 02
                        DB $1F, $01, $00, $0C            ; 03
                        DB $1F, $23, $00, $10            ; 04
                        DB $1F, $45, $0C, $14            ; 05
                        DB $1F, $04, $08, $0C            ; 06
                        DB $1F, $15, $04, $0C            ; 07
                        DB $1F, $46, $08, $1C            ; 08
                        DB $1F, $57, $04, $18            ; 09
                        DB $1F, $26, $08, $10            ; 10
                        DB $1F, $37, $04, $10            ; 11
                        DB $1F, $48, $14, $1C            ; 12
                        DB $1F, $58, $14, $18            ; 13
                        DB $1F, $68, $10, $1C            ; 14
                        DB $1F, $78, $10, $18            ; 15
                        DB $0A, $88, $20, $24            ; 16
                        DB $0A, $88, $24, $28            ; 17
                        DB $0A, $88, $28, $2C            ; 18
                        DB $0A, $88, $2C, $20            ; 19           ; 19 * 4 = 76
BushmasterEdgesSize:    equ $ - BushmasterEdges
BushmasterEdgesCnt:     equ BushmasterEdgesSize/4        ; 
BushmasterNormals:	    DB $9F, $17, $58, $1D            ; 01
                        DB $1F, $17, $58, $1D            ; 02
                        DB $DF, $0E, $5D, $12            ; 03
                        DB $5F, $0E, $5D, $12            ; 04
                        DB $BF, $1F, $59, $0D            ; 05
                        DB $3F, $1F, $59, $0D            ; 06
                        DB $FF, $2A, $55, $07            ; 07
                        DB $7F, $2A, $55, $07            ; 08
                        DB $3F, $00, $00, $60            ; 09           ; 9 * 4 = 36
BushmasterNormalsSize:  equ $ - BushmasterNormals
BushmasterLen:          equ $ - Bushmaster
