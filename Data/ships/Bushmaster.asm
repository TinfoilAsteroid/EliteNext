Bushmaster:	            DB $00                          ; 00 scoop debris
                        DW $109A                        ; 01 missile lock radius
                        DW BushmasterEdges              ; 03 edge address
                        DB BushmasterEdgesSize          ; 05 edge data length
                        DB $00                          ; 06 gun vertex
                        DB $1E                          ; 07 explosion count
                        DB BushmasterVertSize /6        ; 08 vertex count
                        DB BushmasterVertSize           ; 09 vertex data length
                        DB BushmasterEdgesCnt           ; 10 edge count
                        DB $00, $96                     ; 11 bounty hi lo
                        DB BushmasterNormalsSize        ; 13 normal data length
                        DB $14                          ; 14 dot range
                        DB $4A                          ; 15 energy
                        DB $23                          ; 16 speed
                        DW BushmasterNormals            ; 17 normal data address
                        DB $02, $21                     ; 19 scaling factor, laser type 
                        DW BushmasterVertices           ; 21 Verticies adddress
                        DB 0,0                          ; 23 type, new bits
                        DB ShipCanAnger                 ; 25 ai flags
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
