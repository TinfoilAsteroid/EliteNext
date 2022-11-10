Shuttle_Mk_2:	        DB $0F                         ; Number of cargo canisters released when destroyed
                        DW $09C4                       ; Ship's targetable area LoHi
                        DW Shuttle_Mk_2Edges           ; Edge Data 
                        DB Shuttle_Mk_2EdgesSize       ; Size of Edge Data
                        DB $00                         ; Gun Vertex Byte offset
                        DB $26                         ; Explosion Count 
                        DB Shuttle_Mk_2VertSize /6     ; Vertex Count /6
                        DB Shuttle_Mk_2VertSize        ; Vertex Count
                        DB Shuttle_Mk_2EdgesCnt        ; Edges Count
                        DW $0000                       ; Bounty LoHi
                        DB Shuttle_Mk_2NormalsSize     ; Face (Normal) Count
                        DB $0A                         ; Range when it turns to a dot
                        DB $20                         ; Energy Max
                        DB $09                         ; Speed Max
                        DW Shuttle_Mk_2Normals         ; Normals
                        DB $02                         ; Q scaling
                        DB $00                         ; Laser power and Nbr Missiles
                        DW Shuttle_Mk_2Vertices        ; Verticles Address
                        DB ShipTypeNormal              ; Ship Type
                        DB 0                           ; NewB Tactics 
                        DB 0                           ; AI Flags            
                        DB $80                         ; chance of ECM module
                        DB $FF                              ; Supports Solid Fill = false
                        DW $0000                            ; no solid data
                        DB $00                              ; no solid data
                        

	
Shuttle_Mk_2Vertices:	DB $00, $00, $28, $1F, $23, $01
	DB $00, $14, $1E, $1F, $34, $00
	DB $14, $00, $1E, $9F, $15, $00
	DB $00, $14, $1E, $5F, $26, $11
	DB $14, $00, $1E, $1F, $37, $22
	DB $14, $14, $14, $9F, $58, $04
	DB $14, $14, $14, $DF, $69, $15
	DB $14, $14, $14, $5F, $7A, $26
	DB $14, $14, $14, $1F, $7B, $34
	DB $00, $14, $28, $3F, $BC, $48
	DB $14, $00, $28, $BF, $9C, $58
	DB $00, $14, $28, $7F, $AC, $69
	DB $14, $00, $28, $3F, $BC, $7A
	DB $04, $04, $28, $AA, $CC, $CC
	DB $04, $04, $28, $EA, $CC, $CC
	DB $04, $04, $28, $6A, $CC, $CC
	DB $04, $04, $28, $2A, $CC, $CC

Shuttle_Mk_2VertSize: equ $ - Shuttle_Mk_2Vertices	
	
	
	
Shuttle_Mk_2Edges:	DB $1F, $01, $00, $08
	DB $1F, $12, $00, $0C
	DB $1F, $23, $00, $10
	DB $1F, $30, $00, $04
	DB $1F, $04, $04, $14
	DB $1F, $05, $08, $14
	DB $1F, $15, $08, $18
	DB $1F, $16, $0C, $18
	DB $1F, $26, $0C, $1C
	DB $1F, $27, $10, $1C
	DB $1F, $37, $10, $20
	DB $1F, $34, $04, $20
	DB $1F, $48, $14, $24
	DB $1F, $58, $14, $28
	DB $1F, $59, $18, $28
	DB $1F, $69, $18, $2C
	DB $1F, $6A, $1C, $2C
	DB $1F, $7A, $1C, $30
	DB $1F, $7B, $20, $30
	DB $1F, $4B, $20, $24
	DB $1F, $8C, $24, $28
	DB $1F, $9C, $28, $2C
	DB $1F, $AC, $2C, $30
	DB $1F, $BC, $30, $24
	DB $0A, $CC, $34, $38
	DB $0A, $CC, $38, $3C
	DB $0A, $CC, $3C, $40
	DB $0A, $CC, $40, $34

Shuttle_Mk_2EdgesSize: equ $ - Shuttle_Mk_2Edges	
	
	
Shuttle_Mk_2EdgesCnt: equ Shuttle_Mk_2EdgesSize/4	
	
	
Shuttle_Mk_2Normals:	DB $9F, $27, $27, $4E
	DB $DF, $27, $27, $4E
	DB $5F, $27, $27, $4E
	DB $1F, $27, $27, $4E
	DB $1F, $00, $60, $00
	DB $9F, $60, $00, $00
	DB $5F, $00, $60, $00
	DB $1F, $60, $00, $00
	DB $BF, $42, $42, $16
	DB $FF, $42, $42, $16
	DB $7F, $42, $42, $16
	DB $3F, $42, $42, $16
	DB $3F, $00, $00, $60

	
Shuttle_Mk_2NormalsSize: equ $ - Shuttle_Mk_2Normals	
Shuttle_Mk_2Len: equ $ - Shuttle_Mk_2	
