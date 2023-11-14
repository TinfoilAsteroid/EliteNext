CargoType5              DB $00                                     ; Number of cargo canisters released when destroyed
                        DW 20 * 20                                 ; Ship's targetable area LoHi
                        DW CargoType5Edges                         ; Edge Data 
                        DB CargoType5EdgesSize                     ; Size of Edge Data
                        DB $00                                     ; Gun Vertex Byte offset
                        DB $12                                     ; Explosion Count 
                        DB CargoType5VertSize /6                   ; Vertex Count /6
                        DB CargoType5VertSize                      ; Vertex Count
                        DB CargoType5EdgesCnt                      ; Edges Count
                        DW $0000                                   ; Bounty LoHi
                        DB CargoType5NormalsSize                   ; Face (Normal) Count
                        DB $0C                                     ; Range when it turns to a dot
                        DB $11                                     ; Energy Max
                        DB $0F                                     ; Speed Max
                        DW CargoType5Normals                       ; Normals
                        DB $02                                     ; Q scaling
                        DB $00                                     ; Laser power and Nbr Missiles
                        DW CargoType5Vertices                      ; Verticles Address
                        DB ShipTypeScoopable                       ; Ship Type
                        DB 0                                       ; NewB Tactics                        
                        DB 0                                       ; AI Flags
                        DB $0                                      ; chance of ECM module
                        DB $00                                     ; Supports Solid Fill
                        DW CargoType5Traingles                  ;
                        DB CargoType5TrainglesSize
; So cargo is               Edge offset $0050  Face Offset $008C, Verices will alwys be +20, LineMax 31 -> 4  EdgeCnt 15  VertexCnt 60 -> 10     FaceCn 28 -> 7
;                                       Faces
;                            X  Y    Z  12 34  Vis
CargoType5Vertices		DB $18,$10,$00,$1F,$10,$55 	               ;00  Top Right
                        DB $18,$05,$0F,$1F,$10,$22                 ;01  Mid Right Near
                        DB $18,$0D,$09,$5F,$20,$33                 ;02  Bottom right Near
                        DB $18,$0D,$09,$7F,$30,$44                 ;03  Bottom Right Rear
                        DB $18,$05,$0F,$3F,$40,$55                 ;04  Mid Right Rear
                        DB $18,$10,$00,$9F,$51,$66                 ;05  Left versions
                        DB $18,$05,$0F,$9F,$21,$66                 ;06 
                        DB $18,$0D,$09,$DF,$32,$66                 ;07 
                        DB $18,$0D,$09,$FF,$43,$66                 ;08 
                        DB $18,$05,$0F,$BF,$54,$66                 ;09 
CargoType5VertSize      equ $  - CargoType5Vertices     
;                          Vis  FacVert Offset (4 bytexVertnbr)
;                               12  01 02              
CargoType5Edges			DB $1F,$10,$00,$04 	       ;00 Face  0,1
                        DB $1F,$20,$04,$08         ;01       
                        DB $1F,$30,$08,$0C         ;02
                        DB $1F,$40,$0C,$10         ;03
                        DB $1F,$50,$00,$10         ;04
                        DB $1F,$51,$00,$14         ;05
                        DB $1F,$21,$04,$18         ;06
                        DB $1F,$32,$08,$1C         ;07
                        DB $1F,$43,$0C,$20         ;08
                        DB $1F,$54,$10,$24         ;19
                        DB $1F,$61,$14,$18         ;10
                        DB $1F,$62,$18,$1C         ;11
                        DB $1F,$63,$1C,$20         ;12
                        DB $1F,$64,$20,$24         ;13
                        DB $1F,$65,$24,$14         ;14
CargoType5EdgesSize     equ $  - CargoType5Edges
CargoType5EdgesCnt      equ CargoType5EdgesSize / 4
;                           x  y    z   vis
CargoType5Normals    	DB $1F,$60,$00,$00 			               ;00 Right side
                        DB $1F,$00,$29,$1E                         ;01
                        DB $5F,$00,$12,$30                         ;02
                        DB $5F,$00,$33,$00                         ;03
                        DB $7F,$00,$12,$30                         ;04
                        DB $3F,$00,$29,$1E                         ;05 Left
                        DB $9F,$60,$00,$00   ; end Cargo cannister ;06 right side
CargoType5NormalsSize   equ $  - CargoType5Normals 
CargoType5Len           equ $  - CargoType5
                        ; Triangles is made of a list of edges
; Ideal is pointers have a DW at the end to the list of triangles and count
; for testing we will do a simple search
;                          Nrm NodeOffset X 1
;                                0    1    2
CargoType5Traingles     DB $00,$00*4, $01*4, $04*4
                        DB $00,$01*4, $02*4, $04*4
                        DB $00,$02*4, $03*4, $04*4
                        DB $01,$00*4, $04*4, $05*4
                        DB $01,$04*4, $05*4, $06*4
                    ;   DB $02,
                    ;   DB $03,
                    ;   DB $03,
                    ;   DB $04,
                    ;   DB $04,
                    ;   DB $01,
                    ;   DB $01,
                    ;   DB $01,
                    ;   DB $01,
                        DB $06,$05*4, $06*4, $09*4 ; its we store UBNkNodeArray + this offset it will save one memroy ready
                        DB $06,$06*4, $07*4, $09*4
                        DB $06,$07*4, $08*4, $09*4  
                        DB $FF ; Very important end of traingle list marker
CargoType5TrainglesSize:equ $  -  CargoType5Traingles                     
                        
                        
                        