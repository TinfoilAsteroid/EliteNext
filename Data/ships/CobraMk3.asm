; Corrected pointers
;                      0    1    2  3  4  5   6   7   8   9   10  11  12   13  14  15   16 17 18 19    20    21               
;					   Scp  Missile Edge  Lin Gun Exp Vtx Edg Bounty  Face              Face           Vertices
;                      Deb  Lock    Lo Hi x4  Vtx Cnt x6  X1  lo  hi  x4   Dot Erg Spd  Lo Hi Q  Laser Lo    hi
CobraMk3    		    DB $03, $41, $23
                        DW CobraMk3Edges
                        DB CobraMkEdgesSize
                        DB $54,$2A
                        DB CobraMkVertSize
                        DB CobraMkEdgesCnt
                        DB $00,$00
                        DB CobraMk3NormalsSize
                        DB $32,$96,$1C
                        DW CobraMk3Normals
                        DB $01,$13
                        DW CobraMk3Vertices
                    ; missiles = 3             
CobraMk3Vertices	    DB $20,$00,$4C,$1F,$FF,$FF 
                        DB $20,$00,$4C,$9F,$FF,$FF 
                        DB $00,$1A,$18,$1F,$FF,$FF 
                        DB $78,$03,$08,$FF,$73,$AA 
                        DB $78,$03,$08,$7F,$84,$CC 
                        DB $58,$10,$28,$BF,$FF,$FF 
                        DB $58,$10,$28,$3F,$FF,$FF 
                        DB $80,$08,$28,$7F,$98,$CC 
                        DB $80,$08,$28,$FF,$97,$AA 
                        DB $00,$1A,$28,$3F,$65,$99 
                        DB $20,$18,$28,$FF,$A9,$BB 
                        DB $20,$18,$28,$7F,$B9,$CC 
                        DB $24,$08,$28,$B4,$99,$99 
                        DB $08,$0C,$28,$B4,$99,$99 
                        DB $08,$0C,$28,$34,$99,$99 
                        DB $24,$08,$28,$34,$99,$99 
                        DB $24,$0C,$28,$74,$99,$99 
                        DB $08,$10,$28,$74,$99,$99 
                        DB $08,$10,$28,$F4,$99,$99 
                        DB $24,$0C,$28,$F4,$99,$99 
                        DB $00,$00,$4C,$06,$B0,$BB 
                        DB $00,$00,$5A,$1F,$B0,$BB 
                        DB $50,$06,$28,$E8,$99,$99 
                        DB $50,$06,$28,$A8,$99,$99 
                        DB $58,$00,$28,$A6,$99,$99 
                        DB $50,$06,$28,$28,$99,$99 
                        DB $58,$00,$28,$26,$99,$99 
                        DB $50,$06,$28,$68,$99,$99
CobraMkVertSize         equ $  - CobraMk3Vertices
CobraMk3Edges		    DB $1F,$B0,$00,$04,$1F,$C4,$00,$10
                        DB $1F,$A3,$04,$0C,$1F,$A7,$0C,$20 
                        DB $1F,$C8,$10,$1C,$1F,$98,$18,$1C 
                        DB $1F,$96,$18,$24,$1F,$95,$14,$24 
                        DB $1F,$97,$14,$20,$1F,$51,$08,$14 
                        DB $1F,$62,$08,$18,$1F,$73,$0C,$14 
                        DB $1F,$84,$10,$18,$1F,$10,$04,$08 
                        DB $1F,$20,$00,$08,$1F,$A9,$20,$28 
                        DB $1F,$B9,$28,$2C,$1F,$C9,$1C,$2C 
                        DB $1F,$BA,$04,$28,$1F,$CB,$00,$2C 
                        DB $1D,$31,$04,$14,$1D,$42,$00,$18 
                        DB $06,$B0,$50,$54,$14,$99,$30,$34 
                        DB $14,$99,$48,$4C,$14,$99,$38,$3C 
                        DB $14,$99,$40,$44,$13,$99,$3C,$40 
                        DB $11,$99,$38,$44,$13,$99,$34,$48 
                        DB $13,$99,$30,$4C,$1E,$65,$08,$24 
                        DB $06,$99,$58,$60,$06,$99,$5C,$60 
                        DB $08,$99,$58,$5C,$06,$99,$64,$68 
                        DB $06,$99,$68,$6C,$08,$99,$64,$6C 
CobraMkEdgesSize        equ $  - CobraMk3Edges
CobraMkEdgesCnt         equ CobraMkEdgesSize/4
; start normals #0 = top f,$on,$ p,$at,$ o,$ C,$br,$ Mk III
CobraMk3Normals		    DB $1F,$00,$3E,$1F
                        DB $9F,$12,$37,$10 
                        DB $1F,$12,$37,$10
                        DB $9F,$10,$34,$0E 
                        DB $1F,$10,$34,$0E
                        DB $9F,$0E,$2F,$00 
                        DB $1F,$0E,$2F,$00
                        DB $9F,$3D,$66,$00 
                        DB $1F,$3D,$66,$00
                        DB $3F,$00,$00,$50 
                        DB $DF,$07,$2A,$09
                        DB $5F,$00,$1E,$06 
                        DB $5F,$07,$2A,$09 		;end of Cobra Mk III
CobraMk3NormalsSize     equ $  - CobraMk3Normals                    
CobraMk3Len             equ $  - CobraMk3
