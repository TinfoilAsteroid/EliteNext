ShuttleType9:	            DB $0F                       ; Number of cargo canisters released when destroyed
                            DW $09C4                     ; Ship's targetable area LoHi
                            DW ShuttleType9Edges         ; Edge Data 
                            DB ShuttleType9EdgesSize     ; Size of Edge Data
                            DB $00                       ; Gun Vertex Byte offset
                            DB $26                       ; Explosion Count 
                            DB ShuttleType9VertSize /6   ; Vertex Count /6
                            DB ShuttleType9VertSize      ; Vertex Count
                            DB ShuttleType9EdgesCnt      ; Edges Count
                            DW $0000                     ; Bounty LoHi
                            DB ShuttleType9NormalsSize   ; Face (Normal) Count
                            DB $16                       ; Range when it turns to a dot
                            DB $20                       ; Energy Max
                            DB $08                       ; Speed Max
                            DW ShuttleType9Normals       ; Normals
                            DB $02                       ; Q scaling
                            DB $00                       ; Laser power and Nbr Missiles
                            DW ShuttleType9Vertices      ; Verticles Address
	                        DB ShipTypeNormal            ; Ship Type
                            DB 0                         ; NewB Tactics 
                            DB 0                         ; AI Flags            
                            DB $80                       ; chance of ECM module
                        DB $FF                              ; Supports Solid Fill = false
                        DW $0000                            ; no solid data
                        DB $00                              ; no solid data
                        


ShuttleType9Vertices:	DB $00, $11, $17, $5F, $FF, $FF ; 01
                        DB $11, $00, $17, $9F, $FF, $FF ; 02
                        DB $00, $12, $17, $1F, $FF, $FF ; 03
                        DB $12, $00, $17, $1F, $FF, $FF ; 04
                        DB $14, $14, $1B, $FF, $12, $39 ; 05
                        DB $14, $14, $1B, $BF, $34, $59 ; 06
                        DB $14, $14, $1B, $3F, $56, $79 ; 07
                        DB $14, $14, $1B, $7F, $17, $89 ; 08
                        DB $05, $00, $1B, $30, $99, $99 ; 09
                        DB $00, $02, $1B, $70, $99, $99 ; 10
                        DB $05, $00, $1B, $A9, $99, $99 ; 11
                        DB $00, $03, $1B, $29, $99, $99 ; 12
                        DB $00, $09, $23, $50, $0A, $BC ; 13
                        DB $03, $01, $1F, $47, $FF, $02 ; 14
                        DB $04, $0B, $19, $08, $01, $F4 ; 15
                        DB $0B, $04, $19, $08, $A1, $3F ; 16
                        DB $03, $01, $1F, $C7, $6B, $23 ; 17
                        DB $03, $0B, $19, $88, $F8, $C0 ; 18
                        DB $0A, $04, $19, $88, $4F, $18 ; 19

ShuttleType9VertSize: equ $ - ShuttleType9Vertices	
	
	
	
ShuttleType9Edges:	DB $1F, $02, $00, $04
	DB $1F, $4A, $04, $08
	DB $1F, $6B, $08, $0C
	DB $1F, $8C, $00, $0C
	DB $1F, $18, $00, $1C
	DB $18, $12, $00, $10
	DB $1F, $23, $04, $10
	DB $18, $34, $04, $14
	DB $1F, $45, $08, $14
	DB $0C, $56, $08, $18
	DB $1F, $67, $0C, $18
	DB $18, $78, $0C, $1C
	DB $1F, $39, $10, $14
	DB $1F, $59, $14, $18
	DB $1F, $79, $18, $1C
	DB $1F, $19, $10, $1C
	DB $10, $0C, $00, $30
	DB $10, $0A, $04, $30
	DB $10, $AB, $08, $30
	DB $10, $BC, $0C, $30
	DB $10, $99, $20, $24
	DB $07, $99, $24, $28
	DB $09, $99, $28, $2C
	DB $07, $99, $20, $2C
	DB $05, $BB, $34, $38
	DB $08, $BB, $38, $3C
	DB $07, $BB, $34, $3C
	DB $05, $AA, $40, $44
	DB $08, $AA, $44, $48
	DB $07, $AA, $40, $48
ShuttleType9EdgesSize: equ $ - ShuttleType9Edges	
ShuttleType9EdgesCnt: equ ShuttleType9EdgesSize/4	

ShuttleType9Normals:	DB $DF, $37, $37, $28
	DB $5F, $00, $4A, $04
	DB $DF, $33, $33, $17
	DB $9F, $4A, $00, $04
	DB $9F, $33, $33, $17
	DB $1F, $00, $4A, $04
	DB $1F, $33, $33, $17
	DB $1F, $4A, $00, $04
	DB $5F, $33, $33, $17
	DB $3F, $00, $00, $6B
	DB $9F, $29, $29, $5A
	DB $1F, $29, $29, $5A
	DB $5F, $37, $37, $28

	
ShuttleType9NormalsSize: equ $ - ShuttleType9Normals	
ShuttleType9Len: equ $ - ShuttleType9	
