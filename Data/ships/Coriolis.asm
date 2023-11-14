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
                        DB $FF                                      ; Supports Solid Fill = false
                        DW $0000                                    ; no solid data
                        DB $00                                      ; no solid data
;Need to do a debug cube and test that, even better a debug square only 
; a debug cube would be -160, 160, 160  to -160,160,-160    top left forward     to top left rear         TLF   $A0, $A0, $A0, $9F, $14, $50 
;                       -160, 160, 160  to -160,-160,160    top left forward     to bottom left forward   TLR   $A0, $A0, $A0, $BF, $45, $60
;                       -160, 160,-160  to  160,160,-160    top left rear        to top right rear        BLF   $A0, $A0, $A0, $DF, $12, $40
;                       -160, 160,-160  to -160,-160,-160   top left rear        to bottom left rear      TRR   $A0, $A0, $A0, $3F, $35, $60
;                       -160,-160,-160  to -160,-160,-160   bottom left forward  to bottom left rear      BLR   $A0, $A0, $A0, $FF, $24, $60
;                       -160, 160, 160  to  160, 160, 160   top left forward     to top right forward     TRF   $A0, $A0, $A0, $1F, $13, $60
;                       -160,-160, 160  to  160,-160, 160   bottom left forward  to bottom right forward  BRF   $A0, $A0, $A0, $5F, $12, $30
;                       -160,-160,-160  to  160,-160,-160   bottom left rear     to bottom right rear     BRR   $A0, $A0, $A0, $7F, $23, $50
;                        160, 160, 160  to  160, 160,-160   top right forward    to top right rear        
;                        160,-160, 160  to  160,-160,-160   bottom right forward to bottom right rear
;                        160, 160, 160  to  160,-160, 160   top right forward    to bottom right forward
;                        160, 160,-160  to  160,-160,-160   top right rear       to bottom right rear
CoriolisVertices:	    ; DB $A0, $A0, $A0, $9F, $14, $50    ; TLF 1
                        ; DB $A0, $A0, $A0, $BF, $45, $60    ; TLR 2
                        ; DB $A0, $A0, $A0, $DF, $12, $40    ; BLF 3
                        ; DB $A0, $A0, $A0, $3F, $35, $60    ; TRR 4
                        ; DB $A0, $A0, $A0, $FF, $24, $60    ; BLR 5
                        ; DB $A0, $A0, $A0, $1F, $13, $60    ; TRF 6
                        ; DB $A0, $A0, $A0, $5F, $12, $30    ; BRF 7
                        ; DB $A0, $A0, $A0, $7F, $23, $50    ; BRR 8
                         DB $A0, $00, $A0, $1F, $10, $62     ; 160,   0 , 160   
                         DB $00, $A0, $A0, $1F, $20, $83     ;   0, 160 , 160
                         DB $A0, $00, $A0, $9F, $30, $74     ;-160,   0 , 160
                         DB $00, $A0, $A0, $5F, $10, $54     ;   0,-160 , 160
                         DB $A0, $A0, $00, $5F, $51, $A6     ; 160,-160 ,   0
                         DB $A0, $A0, $00, $1F, $62, $B8     ; 160, 160 ,   0
                         DB $A0, $A0, $00, $9F, $73, $C8     ;-160, 160 ,   0
                         DB $A0, $A0, $00, $DF, $54, $97     ;-160,-160 ,   0
                         DB $A0, $00, $A0, $3F, $A6, $DB     ; 160,   0 ,-160
                         DB $00, $A0, $A0, $3F, $B8, $DC     ;   0, 160 ,-160
                         DB $A0, $00, $A0, $BF, $97, $DC     ;-160,   0 ,-160
                         DB $00, $A0, $A0, $7F, $95, $DA     ;   0,-160 ,-160
                         DB $0A, $1E, $A0, $5E, $00, $00     ; 160, -30 , 160
                         DB $0A, $1E, $A0, $1E, $00, $00     ; 160,  30 , 160
                         DB $0A, $1E, $A0, $9E, $00, $00     ;-160,  30 , 160
                        DB $0A, $1E, $A0, $DE, $00, $00     ;-160, -30 , 160
CoriolisVertSize:       equ $ - CoriolisVertices	
CoriolisEdges:	        ; DB $1F, $46, $01, $02
                        ; DB $1F, $56, $02, $04
                        ; DB $1F, $36, $06, $04
                        ; DB $1F, $16, $01, $06
                        ; DB $1F, $14, $01, $03
                        ; DB $1F, $46, $02, $05
                        ; DB $1F, $35, $04, $08
                        ; DB $1F, $23, $06, $07
                        ; DB $1F, $24, $03, $05
                        ; DB $1F, $25, $05, $08
                        ; DB $1F, $23, $07, $08
                        ; DB $1F, $12, $03, $07

                        DB $1F, $10, $00, $0C
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
CoriolisNormals:	    ; DB $1F, $6B, $00, $00
                        ; DB $5F, $00, $6B, $00
                        ; DB $1F, $6B, $00, $00
                        ; DB $9F, $6B, $00, $00
                        ; DB $3F, $00, $00, $6B
                        ; DB $1F, $00, $6B, $00

                        DB $1F, $00, $00, $A0
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
