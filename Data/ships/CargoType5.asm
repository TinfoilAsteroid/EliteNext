;	\ Transporter hull data header info 37 vertices  6*37  = &DE
; Corrected pointers
;                      0    1    2  3  4  5   6   7   8   9   10  11  12   13  14  15   16 17 18 19    20    21               
;					   Scp  Missile Edge  Lin Gun Exp Vtx Edg Bounty  Face              Face           Vertices
;                      Deb  Lock    Lo Hi x4  Vtx Cnt x6  X1  lo  hi  x4   Dot Erg Spd  Lo Hi Q  Laser Lo    hi
;;;				 Example of cargo	
;;;					
;;;		Points (nodes, vetices)		6 bytes per vertex	
;;;     Byte 0 = X magnitide with origin at middle of ship
;;;		Byte 1 = Y magnitide with origin at middle of ship		
;;;		Byte 2 = Z magnitide with origin at middle of ship			
;;;		Byte 3 = Sign Bits of Vertex 7=X 6=Y 5 = Z 4 - 0 = visibility beyond which vertix is not shown
;;;		Byte 4 = High 4 bits Face 2 Index Low 4 bits = Face 1 Index
;;;		Byte 5 = High 4 bits Face 4 Index Low 4 bits = Face 3 Index
;;;		Edges			
;;;		Byte 0 = Edge visbility Distance if > XX4 distance then won't show	
;;;		Byte 1 = High 4 bits Face 2 Index Low 4 bits = Face 1 Index			
;;;		Byte 2 = Byte offset to Point 1 (divide by 4 for index)			
;;;		Byte 3 = Byte offset to Point 2 (divide by 4 for index)	
;;;	  	Normals (Faces)
;;;		Byte 0 = Sign Bits of Vertex 7=X 6=Y 5 = Z, bits 4 to 0 are distance for always visible 			
;;;		Byte 1 = X Lo			
;;;		Byte 2 = Y Lo			
;;;		Byte 3 = Z Lo			

CargoType5              DB $00, $90, $01
                        DW CargoType5Edges
                        DB CargoType5EdgesSize
                        DB $00,$12,CargoType5VertSize,CargoType5EdgesCnt
                        DB $00,$00,$1C,$0C,$11,$0F
                        DW CargoType5Normals
                        DB $02,$00
                        DW CargoType5Vertices
                        DB 0,0                      ; Type and Tactics                        
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