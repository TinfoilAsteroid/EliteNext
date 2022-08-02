    DEFINE DEBUGMODEL 1
Missile:	            DB $00
                        DW $0640
                        DW MissileEdges
                        DB MissileEdgesSize
                        DB $00, $0A
                        DB MissileVertSize /6 
                        DB MissileVertSize
                        DB MissileEdgesCnt
                        DB $00, $00
                        DB MissileNormalsSize
                        DB $0E, $02, $2C
                        DW MissileNormals
                        DB $02, $00
                        DW MissileVertices
                        DB ShipTypeMissile,0                      ; Type and Tactics
                        DB 0
                        DB $00                      ; chance of ECM module

;;;     Byte 0 = X magnitide with origin at middle of ship
;;;		Byte 1 = Y magnitide with origin at middle of ship		
;;;		Byte 2 = Z magnitide with origin at middle of ship			
;;;		Byte 3 = Sign Bits of Vertex 7=X 6=Y 5 = Z 4 - 0 = visibility beyond which vertix is not shown
;;;		Byte 4 = High 4 bits Face 2 Index Low 4 bits = Face 1 Index
;;;		Byte 5 = High 4 bits Face 4 Index Low 4 bits = Face 3 Index
MissileVertices:    IFDEF DEBUGMODEL	               
                        DB $00,$50,$00,$1F,$00,$00  ; 00 00 Y Tip (Roof)
                        DB $00,$00,$00,$1F,$00,$00  ; 01 04 Y base for all nodes
                        DB $50,$00,$00,$1F,$01,$01  ; 02 08 X Tip (Side)
                        DB $00,$00,$00,$1F,$01,$01  ; 03 0C X Base
                        DB $00,$00,$30,$1F,$02,$02  ; 04 10 Z Tip (Nose1)
                        DB $00,$00,$00,$1F,$02,$03  ; 05 14 Z base
                        DB $04,$00,$25,$9F,$03,$03  ; 06 18 Z Trangle point 1
                        DB $04,$00,$25,$1F,$03,$03  ; 07 1C Z Trangle point 2
                        DB $05,$10,$00,$9F,$00,$00  ; 08 20 Y Cross Member 1
                        DB $05,$10,$00,$1F,$00,$00  ; 09 24 Y Cross Member 2
                        DB $10,$05,$00,$1F,$00,$00  ; 10 28 X Cross Member 1
                        DB $20,$00,$00,$1F,$00,$00  ; 11 2C X Cross Member 2
                        DB $10,$05,$00,$5F,$00,$00  ; 12 30 X Cross Member 3
                    ELSE
                        DB $00, $00, $44, $1F, $10, $32
                        DB $08, $08, $24, $5F, $21, $54
                        DB $08, $08, $24, $1F, $32, $74
                        DB $08, $08, $24, $9F, $30, $76
                        DB $08, $08, $24, $DF, $10, $65
                        DB $08, $08, $2C, $3F, $74, $88
                        DB $08, $08, $2C, $7F, $54, $88
                        DB $08, $08, $2C, $FF, $65, $88
                        DB $08, $08, $2C, $BF, $76, $88
                        DB $0C, $0C, $2C, $28, $74, $88
                        DB $0C, $0C, $2C, $68, $54, $88
                        DB $0C, $0C, $2C, $E8, $65, $88
                        DB $0C, $0C, $2C, $A8, $76, $88
                        DB $08, $08, $0C, $A8, $76, $77
                        DB $08, $08, $0C, $E8, $65, $66
                        DB $08, $08, $0C, $28, $74, $77
                        DB $08, $08, $0C, $68, $54, $55
                    ENDIF
MissileVertSize: equ $ - MissileVertices	
	
;;;     Byte 0 = Edge visbility Distance if > XX4 distance then won't show	
;;;		Byte 1 = High 4 bits Face 2 Index Low 4 bits = Face 1 Index			
;;;		Byte 2 = Byte offset to Point 1 (divide by 4 for index)			
;;;		Byte 3 = Byte offset to Point 2 (divide by 4 for index)		
	
MissileEdges:	    IFDEF DEBUGMODEL	
                        DB $1F,$00,$00,$04 ; Y
                        DB $1F,$00,$08,$0C ; X
                        DB $1F,$00,$10,$14 ; Z
                        DB $1F,$00,$10,$18 ; Z Tip Traingle 1
                        DB $1F,$00,$10,$1C ; Z Tip Traingle 2
                        DB $1F,$00,$1C,$18 ; Z Tip Traingle 2
                        DB $1F,$00,$20,$24 ; Y Cross memeber
                        DB $1F,$00,$28,$2C ; X Triangle
                        DB $1F,$00,$2C,$30 ; X Triangle
                        ;DB $1F,$00,$18,$1C  
                    ELSE
                        DB $1F, $21, $00, $04
                        DB $1F, $32, $00, $08
                        DB $1F, $30, $00, $0C
                        DB $1F, $10, $00, $10
                        DB $1F, $24, $04, $08
                        DB $1F, $51, $04, $10
                        DB $1F, $60, $0C, $10
                        DB $1F, $73, $08, $0C
                        DB $1F, $74, $08, $14
                        DB $1F, $54, $04, $18
                        DB $1F, $65, $10, $1C
                        DB $1F, $76, $0C, $20
                        DB $1F, $86, $1C, $20
                        DB $1F, $87, $14, $20
                        DB $1F, $84, $14, $18
                        DB $1F, $85, $18, $1C
                        DB $08, $85, $18, $28
                        DB $08, $87, $14, $24
                        DB $08, $87, $20, $30
                        DB $08, $85, $1C, $2C
                        DB $08, $74, $24, $3C
                        DB $08, $54, $28, $40
                        DB $08, $76, $30, $34
                        DB $08, $65, $2C, $38
                    ENDIF
MissileEdgesSize: equ $ - MissileEdges	
	
	
MissileEdgesCnt: equ MissileEdgesSize/4	
	
;;;		Byte 0 = Sign Bits of Vertex 7=X 6=Y 5 = Z, bits 4 to 0 are distance for always visible 			
;;;		Byte 1 = X Lo			
;;;		Byte 2 = Y Lo			
;;;		Byte 3 = Z Lo		
MissileNormals:	    IFDEF DEBUGMODEL
                        DB $1F,$00,$10,$00
                        DB $1F,$10,$00,$00
                        DB $1F,$00,$00,$10
                        DB $1F,$00,$00,$10
                    ELSE
                        DB $9F, $40, $00, $10
                        DB $5F, $00, $40, $10
                        DB $1F, $40, $00, $10
                        DB $1F, $00, $40, $10
                        DB $1F, $20, $00, $00
                        DB $5F, $00, $20, $00
                        DB $9F, $20, $00, $00
                        DB $1F, $00, $20, $00
                        DB $3F, $00, $00, $B0
                    ENDIF
	
MissileNormalsSize: equ $ - MissileNormals	
MissileLen: equ $ - Missile	
