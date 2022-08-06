CargoType5              DB $00                         ; Number of cargo canisters released when destroyed
                        DW 20 * 20                     ; Ship's targetable area LoHi
                        DW CargoType5Edges             ; Edge Data 
                        DB CargoType5EdgesSize         ; Size of Edge Data
                        DB $00                         ; Gun Vertex Byte offset
                        DB $12                         ; Explosion Count 
                        DB CargoType5VertSize /6       ; Vertex Count /6
                        DB CargoType5VertSize          ; Vertex Count
                        DB CargoType5EdgesCnt          ; Edges Count
                        DW $0000                       ; Bounty LoHi
                        DB CargoType5NormalsSize       ; Face (Normal) Count
                        DB $0C                         ; Range when it turns to a dot
                        DB $11                         ; Energy Max
                        DB $0F                         ; Speed Max
                        DW CargoType5Normals           ; Normals
                        DB $02                         ; Q scaling
                        DB $00                         ; Laser power and Nbr Missiles
                        DW CargoType5Vertices          ; Verticles Address
                        DB ShipTypeScoopable           ; Ship Type
                        DB 0                           ; NewB Tactics                        
                        DB 0                           ; AI Flags
                        DB $0                          ; chance of ECM module
; So cargo is               Edge offset $0050  Face Offset $008C, Verices will alwys be +20, LineMax 31 -> 4  EdgeCnt 15  VertexCnt 60 -> 10     FaceCn 28 -> 7
CargoType5Vertices		DB $18,$10,$00,$1F,$10,$55 	; 60 bytes in total for data
                        DB $18,$05,$0F,$1F,$10,$22 
                        DB $18,$0D,$09,$5F,$20,$33 
                        DB $18,$0D,$09,$7F,$30,$44 
                        DB $18,$05,$0F,$3F,$40,$55   ; end of left pentagon
                        DB $18,$10,$00,$9F,$51,$66   ; start of right pentagon
                        DB $18,$05,$0F,$9F,$21,$66 
                        DB $18,$0D,$09,$DF,$32,$66 
                        DB $18,$0D,$09,$FF,$43,$66 
                        DB $18,$05,$0F,$BF,$54,$66 
CargoType5VertSize      equ $  - CargoType5Vertices                    
CargoType5Edges			DB $1F,$10,$00,$04,$1F,$20,$04,$08 	; 8 x 7 = 60 bytes
                        DB $1F,$30,$08,$0C,$1F,$40,$0C,$10 
                        DB $1F,$50,$00,$10,$1F,$51,$00,$14 
                        DB $1F,$21,$04,$18,$1F,$32,$08,$1C 
                        DB $1F,$43,$0C,$20,$1F,$54,$10,$24 
                        DB $1F,$61,$14,$18,$1F,$62,$18,$1C 
                        DB $1F,$63,$1C,$20,$1F,$64,$20,$24 
                        DB $1F,$65,$24,$14 
CargoType5EdgesSize     equ $  - CargoType5Edges
CargoType5EdgesCnt      equ CargoType5EdgesSize / 4
CargoType5Normals    	DB $1F,$60,$00,$00 			
                        DB $1F,$00,$29,$1E,$5F,$00,$12,$30 
                        DB $5F,$00,$33,$00,$7F,$00,$12,$30 
                        DB $3F,$00,$29,$1E,$9F,$60,$00,$00   ; end Cargo cannister
CargoType5NormalsSize   equ $  - CargoType5Normals 
CargoType5Len           equ $  - CargoType5