;                      0    1    2    3   4   5   6   7   8   9   10  11  12  13  14  15   16                    17                  18  19     20                     21 
;					   Scp  Missile   Edg Edg Lin Gun Exp Vtx Edg Bounty  Face             Edg                   Face                           Vertices
;                      Deb  Lock      Lo  Hi  x4  Vtx Cnt x6  X1  lo  hi  x4  Dot Erg Spd  hi                    Hi                  Q   Laser  Lo                     hi                
Constrictor:    	    DB $F3, $49, $26
                        DW ConstrictorEdges
                        DB ConstrictorEdgesSize
                        DB $00,$2E
                        DB ConstrictorVertSize
                        DB ConstrictorEdgesCnt
                        DB $18,$00
                        DB ConstrictorNormalsSize
                        DB $2D,$C8,$37
                        DW ConstrictorNormals
                        DB $02,$2F
                        DW ConstrictorVertices
                    ; missiles = 3             
ConstrictorVertices     DB $14, $07, $50, $5F, $02, $99 
                        DB $14, $07, $50, $DF, $01, $99 
                        DB $36, $07, $28, $DF, $14, $99 
                        DB $36, $07, $28, $FF, $45, $89 
                        DB $14, $0D, $28, $BF, $56, $88 
                        DB $14, $0D, $28, $3F, $67, $88 
                        DB $36, $07, $28, $7F, $37, $89 
                        DB $36, $07, $28, $5F, $23, $99 
                        DB $14, $0D, $05, $1F, $FF, $FF 
                        DB $14, $0D, $05, $9F, $FF, $FF 
                        DB $14, $07, $3E, $52, $99, $99 
                        DB $14, $07, $3E, $D2, $99, $99 
                        DB $19, $07, $19, $72, $99, $99 
                        DB $19, $07, $19, $F2, $99, $99 
                        DB $0F, $07, $0F, $6A, $99, $99 
                        DB $0F, $07, $0F, $EA, $99, $99 
                        DB $00, $07, $00, $40, $9F, $01 
ConstrictorVertSize     equ $  - ConstrictorVertices
ConstrictorEdges        DB $1F, $09, $00, $04, $1F, $19, $04, $08 
                        DB $1F, $01, $04, $24, $1F, $02, $00, $20
                        DB $1F, $29, $00, $1C, $1F, $23, $1C, $20 
                        DB $1F, $14, $08, $24, $1F, $49, $08, $0C 
                        DB $1F, $39, $18, $1C, $1F, $37, $18, $20 
                        DB $1F, $67, $14, $20, $1F, $56, $10, $24 
                        DB $1F, $45, $0C, $24, $1F, $58, $0C, $10 
                        DB $1F, $68, $10, $14, $1F, $78, $14, $18 
                        DB $1F, $89, $0C, $18, $1F, $06, $20, $24 
                        DB $12, $99, $28, $30, $05, $99, $30, $38 
                        DB $0A, $99, $38, $28, $0A, $99, $2C, $3C 
                        DB $05, $99, $34, $3C, $12, $99, $2C, $34
ConstrictorEdgesSize    equ $  - ConstrictorEdges
ConstrictorEdgesCnt     equ ConstrictorEdgesSize/4
ConstrictorNormals      DB $1F, $00, $37, $0F, $9F, $18, $4B, $14 
                        DB $1F, $18, $4B, $14, $1F, $2C, $4B, $00 
                        DB $9F, $2C, $4B, $00, $9F, $2C, $4B, $00 
                        DB $1F, $00, $35, $00, $1F, $2C, $4B, $00 
                        DB $3F, $00, $00, $A0, $5F, $00, $1B, $00
ConstrictorNormalsSize  equ $  - ConstrictorNormals                    
ConstrictorLen          equ $  - Constrictor
