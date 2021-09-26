


    
ScoopDebrisOffset	    equ	0
MissileLockLoOffset	    equ 1
MissileLockHiOffset	    equ 2
EdgeAddyOffset		    equ 3
;   
LineX4Offset		    equ 5
GunVertexOffset		    equ 6
ExplosionCtOffset	    equ 7
VertexCtX6Offset	    equ 8
EdgeCountOffset		    equ 9
BountyLoOffset		    equ 10
BountyHiOffset		    equ 11
FaceCtX4Offset		    equ 12
DotOffset			    equ 13
EnergyOffset		    equ 14
SpeedOffset			    equ 15
;EdgeHiOffset		    equ	16
FaceAddyOffset		    equ 16
;   
QOffset				    equ 18
LaserOffset			    equ 19
VerticiesAddyOffset     equ 20
;

; TODO Later reorg these offsets for better 16 bit read - Done
; TODO Add in roll max rates and data to allow ship replacement, reference to custom console


; -> &565D	\ Start Hull Data. For each hull, first 20 bytes give header info.
; hull byte#0 high nibble is scoop info, lower nibble is debris spin info
; Scoop: 0 = no scoop 1= scoop , anything more?
; hull byte#1-2 area for missile lock, lo, hi
; hull byte#3   edges data info offset lo
; hull byte#4   faces data info offset lo
; hull byte#5   4*maxlines+1 for ship lines stack   
; hull byte#6   gun vertex*4   
; hull byte#7   explosion count e.g. &2A = 4*n+6
; hull byte#8   vertices*6		
; hull byte#9	edge Count
; hull bytes#10-11 bounty lo hi
; hull byte#12  faces*4
; hull byte#13  dot beyond distance	
; hull byte#14  energy
; hull byte#15  speed (end of 4th row)
; hull byte#16  edges offset hi (goes -ve to use other's edge net).
; hull byte#17  faces offset hi
; hull byte#18  Q% scaling of normals to make large objects' normals flare out further away
; hull byte#19  laser|missile(=lower 3 bits)
; hull byte#20  Added Vertices for 20,21

; Optimised version to be applied to add data brought in to here:
; hull byte#0 high nibble is scoop info, lower nibble is debris spin info
; hull byte#1-2 area for missile lock, lo, hi
; hull byte#3   edges data info offset lo
; hull byte#4   edges offset hi (goes -ve to use other's edge net). (was 16)
; hull byte#5   4*maxlines+1 for ship lines stack   
; hull byte#6   gun vertex*4   
; hull byte#7   explosion count e.g. &2A = 4*n+6
; hull byte#8   vertices*6		
; hull byte#9	edge Count
; hull bytes#10-11 bounty lo hi
; hull byte#12  faces*4
; hull byte#13  dot beyond distance	
; hull byte#14  energy
; hull byte#15  speed (end of 4th row)
; hull byte#16  faces data info offset lo (was 4)
; hull byte#17  faces offset hi
; hull byte#18  Q% scaling of normals to make large objects' normals flare out further away
; hull bute#19  laser|missile(=lower 3 bits)
; hull byte#20  Added Vertices for 20,21
;
; Vertex Data Structure
; Byte 0 X1Lo
; Byte 1 X1Hi
; Byte 2 Y1Lo
; Byte 3 Y1Hi
; Byte 4 High 4 bits Face 2 Index Low 4 bits = Face 1 Index
; Byte 5 High 4 bits Face 4 Index Low 4 bits = Face 3 Index
;
;
; Edge Data Structure
; Byte 0 
; Byte 1 - Face 1 Index (uppernibble), Face 2 Index (lowernibble)
; Byte 2 - Index to Vertex 1
; Byte 3 - Index to Vertex 2
;
; Normal/Faces Data Structure
;
;
;
; Original Data:
;	\ -> &565D	\ Start Hull Data. For each hull, first 20 bytes give header info.
;		\ hull byte#0 high nibble is scoop info, lower nibble is debris spin info
;		\ hull byte#1-2 area for missile lock, lo, hi
;		\ hull byte#3   edges data info offset lo
;		\ hull byte#4   faces data info offset lo
;		\ hull byte#5   4*maxlines+1 for ship lines stack   
;		\ hull byte#6   gun vertex*4   
;		\ hull byte#7   explosion count e.g. &2A = 4*n+6
;		\ hull byte#8   vertices*6		
;		\ hull bytes#10-11 bounty lo hi
;		\ hull byte#12  faces*4
;		\ hull byte#13  dot beyond distance	
;		\ hull byte#14  energy
;		\ hull byte#15  speed (end of 4th row)
;		\ hull byte#16  edges offset hi (goes -ve to use other's edge net).
;		\ hull byte#17  faces offset hi
;		\ hull byte#18  Q% scaling of normals to make large objects' normals flare out further away
;		\ hull bute#19  laser|missile(=lower 3 bits)
; Corrected pointers
; &565D \ Cargo cannister = Type 5
;                      0    1    2    3               4               5             6   7     8            9             10  11  12  13  14  15   16                17                 18  19     20                 21
;					   Scp  Missile   Edg             Edg             Lin           Gun Exp   Vtx          Edg           Bounty  Face             Edg               Face                          Vertices
;                      Deb  Lock      Lo              Hi              x4            Vtx Cnt   x6           X1            lo  hi  x4  Dot Erg Spd  hi                Hi                 Q   Laser  Lo                 hi
; Mapping Orginal to new
; 0    => 0
; 1-2  => 1-2
; 3    => EQU Edges
; 4    => EQU Normals
; 5    => EQU EdgesCnt
; 6    => 6
; 7    => 7
; 8    => EQU VertSize
; 9    => EQU EdgesCnt
; 10-11=> 10-11
; 12   => EQU  NormalsSize
; 13   => 13
; 14   => 14
; 15   => 15
; 16   => EQU Edges
; 17   => EQU Normals
; 18   => 18
; 19   => 19


CargoType5              DB $00, $90, $01
                        DW CargoEdges
                        DB CargoEdgesSize
                        DB $00,$12,CargoVertSize,CargoEdgesCnt
                        DB $00,$00,$1C,$0C,$11,$0F
                        DW CargoNormals
                        DB $02,$00
                        DW CargoVertices
; So cargo is               Edge offset $0050  Face Offset $008C, Verices will alwys be +20, LineMax 31 -> 4  EdgeCnt 15  VertexCnt 60 -> 10     FaceCn 28 -> 7
CargoVertices		    DB $18,$10,$00,$1F,$10,$55 	; 60 bytes in total for data
                        DB $18,$05,$0F,$1F,$10,$22 
                        DB $18,$0D,$09,$5F,$20,$33 
                        DB $18,$0D,$09,$7F,$30,$44 
                        DB $18,$05,$0F,$3F,$40,$55   ; end of left pentagon
                        DB $18,$10,$00,$9F,$51,$66   ; start of right pentagon
                        DB $18,$05,$0F,$9F,$21,$66 
                        DB $18,$0D,$09,$DF,$32,$66 
                        DB $18,$0D,$09,$FF,$43,$66 
                        DB $18,$05,$0F,$BF,$54,$66 
CargoVertSize           equ $  - CargoVertices                    
CargoEdges			    DB $1F,$10,$00,$04,$1F,$20,$04,$08 	; 8 x 7 = 60 bytes
                        DB $1F,$30,$08,$0C,$1F,$40,$0C,$10 
                        DB $1F,$50,$00,$10,$1F,$51,$00,$14 
                        DB $1F,$21,$04,$18,$1F,$32,$08,$1C 
                        DB $1F,$43,$0C,$20,$1F,$54,$10,$24 
                        DB $1F,$61,$14,$18,$1F,$62,$18,$1C 
                        DB $1F,$63,$1C,$20,$1F,$64,$20,$24 
                        DB $1F,$65,$24,$14 
CargoEdgesSize          equ $  - CargoEdges
CargoEdgesCnt           equ CargoEdgesSize / 4
CargoNormals    	    DB $1F,$60,$00,$00 			
                        DB $1F,$00,$29,$1E,$5F,$00,$12,$30 
                        DB $5F,$00,$33,$00,$7F,$00,$12,$30 
                        DB $3F,$00,$29,$1E,$9F,$60,$00,$00   ; end Cargo cannister
CargoNormalsSize        equ $  - CargoNormals 					
;;;				 Example of cargo	
;;;					
;;;		Points (nodes, vetices)		6 bytes per vertex	
;;;     Byte 0 = X magnitide with origin at middle of ship
;;;		Byte 1 = Y magnitide with origin at middle of ship		
;;;		Byte 2 = Z magnitide with origin at middle of ship			
;;;		Byte 3 = Sign Bits of Vertex 7=X 6=Y 5 = Z 4 - 0 = visibility beyond which vertix is not shown
;;;		Byte 4 = High 4 bits Face 2 Index Low 4 bits = Face 1 Index
;;;		Byte 5 = High 4 bits Face 4 Index Low 4 bits = Face 3 Index
;;;
;;;		Q scaling is equivalent of Dist
;;;     0:  X=024 Y=16 Z=00 $1F>SX=+ SY=+ SZ=+ F1=5 F2=5
;;;		1:  X=024 Y=05 Z=15 $1F>SX=+ SY=+ SZ=+ F1=2 F2=2
;;;     2:  X=024 Y=13 Z=09 $5F>SX=+ SY=- SZ=+ F1=3 F2=3
;;;     3:  X=024 Y=13 Z=09 $7F>SX=+ SY=- SZ=- F1=4 F2=4
;;;     4:  X=024 Y=05 Z=15 $3F>SX=+ SY=+ SZ=- F1=5 F2=5
;;;     5:  X=024 Y=10 Z=00 $9F>SX=- SY=+ SZ=+ F1=6 F2=6
;;;     6:  X=024 Y=05 Z=15 $9F>SX=- SY=+ SZ=+ F1=6 F2=6
;;;     7:  X=024 Y=13 Z=09 $DF>SX=- SY=- SZ=+ F1=6 F2=6
;;;     8:  X=024 Y=13 Z=09 $FF>SX=- SY=- SZ=- F1=6 F2=6
;;;     9:  X=024 Y=05 Z=15 $BF>SX=- SY=+ SZ=- F1=6 F2=6
;;;
;;;		Edges			
;;;		Byte 0 = Edge visbility Distance if > XX4 distance then won't show	
;;;		Byte 1 = High 4 bits Face 2 Index Low 4 bits = Face 1 Index			
;;;		Byte 2 = Byte offset to Point 1 (divide by 4 for index)			
;;;		Byte 3 = Byte offset to Point 2 (divide by 4 for index)	
;;;		Is Q scaling equivalent of Dist?				
;;;     0: Vis=31  F1=1  F2=0 P1=00(0) P2=04 (1)     $1F,$10,$00,$04
;;;		1: Vis=31  F1=2  F2=0 P1=04(1) P2=04 (1)     $1F,$20,$04,$08
;;;     2: Vis=31  F1=3  F2=0 P1=08(2) P2=12 (3)     $1F,$30,$08,$0C
;;;     3: Vis=31  F1=4  F2=0 P1=12(3) P2=16 (4)     $1F,$40,$0C,$10 
;;;     4: Vis=31  F1=5  F2=0 P1=00(0) P2=16 (4)     $1F,$50,$00,$10
;;;     5: Vis=31  F1=5  F2=0 P1=00(0) P2=20 (5)     $1F,$51,$00,$14
;;;     6: Vis=31  F1=2  F2=0 P1=04(1) P2=24 (6)     $1F,$21,$04,$18
;;;     7: Vis=31  F1=3  F2=0 P1=08(2) P2=28 (7)     $1F,$32,$08,$1C  Doesn';t make sense there are only 10 edges
;;;		$1F,$43,$0C,$20			
;;;		$1F,$54,$10,$24			
;;;		$1F,$61,$14,$18			
;;;		$1F,$62,$18,$1C			
;;;		$1F,$63,$1C,$20			
;;;		$1F,$64,$20,$24			
;;;		$1F,$65,$24,$14			


;;;	  	Normals (Faces)
;;;		Byte 0 = Sign Bits of Vertex 7=X 6=Y 5 = Z, bits 4 to 0 are distance for always visible 			
;;;		Byte 1 = X Lo			
;;;		Byte 2 = Y Lo			
;;;		Byte 3 = Z Lo			
;;;		Is Q scaling equivalent of Dist?				
;;;		0: $1F>SX=+ SY=+ SZ=+ X=96 Y=00 Z=00	$1F,$60,$00,$00
;;;		1: $1F>SX=+ SY=+ SZ=+ X=00 Y=41 Z=30	$1F,$00,$29,$1E
;;;		2: $5F>SX=+ SY=- SZ=+ X=00 Y=18 Z=48	$5F,$00,$12,$30
;;;		3: $5F>SX=+ SY=- SZ=+ X=00 Y=51 Z=00	$5F,$00,$33,$00
;;;		4: $7F>SX=+ SY=- SZ=- X=00 Y=18 Z=00	$7F,$00,$12,$30 
;;;		5: $3F>SX=+ SY=+ SZ=- X=00 Y=41 Z=30 	$3F,$00,$29,$1E
;;;     6: $9F>SX=- SY=+ SZ=+ X=96 Y=00 Z=00	$9F,$60,$00,$00

TestVector:             DB $03, $41, $23
                        DW TestVectorEdges
                        DB TestVectorEdgesSize
                        DB $54,$2A
                        DB TestVectorVertSize
                        DB TestVectorEdgesCnt
                        DB $00,$00
                        DB TestVectorNormalsSize
                        DB $32,$96,$1C
                        DW TestVectorNormals
                        DB $04,$01
                        DW TestVectorVertices
TestVectorVertices	    DB $00,$40,$00,$1F,$00,$00 
                        DB $00,$20,$00,$1F,$00,$00 
                        DB $40,$00,$00,$1F,$01,$01 
                        DB $20,$00,$00,$1F,$01,$01 
                        DB $00,$00,$40,$1F,$02,$02 
                        DB $00,$00,$20,$1F,$02,$02 
                        DB $00,$00,$00,$1F,$03,$03 
TestVectorVertSize      equ $  - TestVectorVertices
TestVectorEdges		    DB $1F,$00,$00,$04
                        DB $1F,$00,$08,$0C
                        DB $1F,$00,$10,$14
                        DB $1F,$00,$18,$18                    
TestVectorEdgesSize     equ $  - TestVectorEdges
TestVectorEdgesCnt      equ TestVectorEdgesSize/4
; start normals #0 = top f,$on,$ p,$at,$ o,$ C,$br,$ Mk III
TestVectorNormals	    DB $1F,$00,$10,$00
                        DB $1F,$10,$00,$00
                        DB $1F,$00,$00,$10
                        DB $1F,$00,$00,$10
TestVectorNormalsSize   equ $  - TestVectorNormals                    
TestVectorLen           equ $  - TestVector                
; -> &5705  \ Shuttle = Type 9 	\ Shuttle hull data header info \ 19 vertices  6*19  = &72
;                      0    1  2     3    4    5   6   7   8   9   10  11  12  13  14  15  16  17  18  19
;					   Scp  Missile  Edg  Face Lin Gun Exp Vtx Edg Bounty  Face            Edg Face  
;                      Deb  Lock     Lo   Lo   x4  Vtx Cnt x6  X1  lo  hi  x4  Dot Erg Spd hi  Hi  Q   Laser
CargoType5Len           equ $  - CargoType5

; Corrected pointers
;                      0    1    2    3                 4                 5   6   7   8   9   10  11  12  13  14  15   16                  17                 18  19    20                    21
;					   Scp  Missile   Edg               Edg               Lin Gun Exp Vtx Edg Bounty  Face             Edg                 Face                         Vertices
;                      Deb  Lock      Lo                Hi                x4  Vtx Cnt x6  X1  lo  hi  x4  Dot Erg Spd  hi                  Hi                 Q   Laser Lo                    hi
ShuttleType9            DB $0F, $C4, $09, low ShuttleEdges, high ShuttleEdges, $6D,$00,$26,$72,$1E,$00,$00,$34,$16,$20,$08, low ShuttleNormals, high ShuttleNormals,$02,$00,  low ShuttleVertices, high ShuttleVertices                
; So cargo is               Edge offset $0050  Face Offset $008C, Verices will alwys be +20, LineMax 31 -> 4  EdgeCnt 15  VertexCnt 60 -> 10     FaceCn 28 -> 7
ShuttleVertices 	    DB $00,$23,$2F,$5F,$FF,$FF 
                        DB $23,$00,$2F,$9F,$FF,$FF 
                        DB $00,$23,$2F,$1F,$FF,$FF 
                        DB $23,$00,$2F,$1F,$FF,$FF 
                        DB $28,$28,$35,$FF,$12,$39 
                        DB $28,$28,$35,$BF,$34,$59 
                        DB $28,$28,$35,$3F,$56,$79 
                        DB $28,$28,$35,$7F,$17,$89 
                        DB $0A,$00,$35,$30,$99,$99 
                        DB $00,$05,$35,$70,$99,$99 
                        DB $0A,$00,$35,$A8,$99,$99 
                        DB $00,$05,$35,$28,$99,$99 
                        DB $00,$11,$47,$50,$0A,$BC 
                        DB $05,$02,$3D,$46,$FF,$02 
                        DB $07,$17,$31,$07,$01,$F4 
                        DB $15,$09,$31,$07,$A1,$3F 
                        DB $05,$02,$3D,$C6,$6B,$23 
                        DB $07,$17,$31,$87,$F8,$C0 
                        DB $15,$09,$31,$87,$4F,$18 
ShuttleEdges    	    DB $1F,$02,$00,$04,$1F,$4A,$04,$08 
                        DB $1F,$6B,$08,$0C,$1F,$8C,$00,$0C 
                        DB $1F,$18,$00,$1C,$18,$12,$00,$10 
                        DB $1F,$23,$04,$10,$18,$34,$04,$14 
                        DB $1F,$45,$08,$14,$0C,$56,$08,$18 
                        DB $1F,$67,$0C,$18,$18,$78,$0C,$1C 
                        DB $1F,$39,$10,$14,$1F,$59,$14,$18 
                        DB $1F,$79,$18,$1C,$1F,$19,$10,$1C 
                        DB $10,$0C,$00,$30,$10,$0A,$04,$30 
                        DB $10,$AB,$08,$30,$10,$BC,$0C,$30 
                        DB $10,$99,$20,$24,$06,$99,$24,$28 
                        DB $08,$99,$28,$2C,$06,$99,$20,$2C 
                        DB $04,$BB,$34,$38,$07,$BB,$38,$3C 
                        DB $06,$BB,$34,$3C,$04,$AA,$40,$44 
                        DB $07,$AA,$44,$48,$06,$AA,$40,$48 
ShuttleNormals		    DB $DF,$6E,$6E,$50,$5F,$00,$95,$07 
                        DB $DF,$66,$66,$2E,$9F,$95,$00,$07 
                        DB $9F,$66,$66,$2E,$1F,$00,$95,$07 
                        DB $1F,$66,$66,$2E,$1F,$95,$00,$07 
                        DB $5F,$66,$66,$2E,$3F,$00,$00,$D5 
                        DB $9F,$51,$51,$B1,$1F,$51,$51,$B1 
                        DB $5F,$6E,$6E,$50 			; End of shuttle
ShuttleType9Len         equ $  - ShuttleType9

;	\ Transporter hull data header info 37 vertices  6*37  = &DE
; Corrected pointers
;                      0    1    2    3                   4                   5   6   7   8   9   10  11  12  13  14  15   16                    17                  18  19     20                     21 
;					   Scp  Missile   Edg                 Edg                 Lin Gun Exp Vtx Edg Bounty  Face             Edg                   Face                           Vertices
;                      Deb  Lock      Lo                  Hi                  x4  Vtx Cnt x6  X1  lo  hi  x4  Dot Erg Spd  hi                    Hi                  Q   Laser  Lo                     hi                
TransportType10		    DB $00, $C4, $09, low TransportEdges, high TransportEdges ,$91,$30,$1A,$DE,$2E,$00,$00,$38,$10,$20,$0A, low TransportNormals, high TransportNormals,$01,$00,  low TransportVertices, high TransportVertices
TransportVertices 	    DB $00,$13,$33,$3F,$06,$77 
                        DB $33,$07,$33,$BF,$01,$77 
                        DB $39,$07,$33,$FF,$01,$22 
                        DB $33,$11,$33,$FF,$02,$33 
                        DB $33,$11,$33,$7F,$03,$44 
                        DB $39,$07,$33,$7F,$04,$55 
                        DB $33,$07,$33,$3F,$05,$66 
                        DB $00,$0C,$18,$12,$FF,$FF 
                        DB $3C,$02,$18,$DF,$17,$89 
                        DB $42,$11,$18,$DF,$12,$39 
                        DB $42,$11,$18,$5F,$34,$5A 
                        DB $3C,$02,$18,$5F,$56,$AB 
                        DB $16,$05,$3D,$DF,$89,$CD 
                        DB $1B,$11,$3D,$DF,$39,$DD 
                        DB $1B,$11,$3D,$5F,$3A,$DD 
                        DB $16,$05,$3D,$5F,$AB,$CD 
                        DB $0A,$0B,$05,$86,$77,$77 
                        DB $24,$05,$05,$86,$77,$77 
                        DB $0A,$0D,$0E,$A6,$77,$77 
                        DB $24,$07,$0E,$A6,$77,$77 
                        DB $17,$0C,$1D,$A6,$77,$77 
                        DB $17,$0A,$0E,$A6,$77,$77 
                        DB $0A,$0F,$1D,$26,$66,$66 
                        DB $24,$09,$1D,$26,$66,$66 
                        DB $17,$0A,$0E,$26,$66,$66 
                        DB $0A,$0C,$06,$26,$66,$66 
                        DB $24,$06,$06,$26,$66,$66 
                        DB $17,$07,$10,$06,$66,$66 
                        DB $17,$09,$06,$26,$66,$66 
                        DB $21,$11,$1A,$E5,$33,$33 
                        DB $21,$11,$21,$C5,$33,$33 
                        DB $21,$11,$1A,$65,$33,$33 
                        DB $21,$11,$21,$45,$33,$33 
                        DB $19,$06,$33,$E7,$00,$00 
                        DB $1A,$06,$33,$67,$00,$00 
                        DB $11,$06,$33,$24,$00,$00 
                        DB $11,$06,$33,$A4,$00,$00 
TransportEdges		    DB $1F,$07,$00,$04,$1F,$01,$04,$08 ;
                        DB $1F,$02,$08,$0C,$1F,$03,$0C,$10 ;
                        DB $1F,$04,$10,$14,$1F,$05,$14,$18 ;
                        DB $1F,$06,$00,$18,$0F,$67,$00,$1C ;
                        DB $1F,$17,$04,$20,$0A,$12,$08,$24 ;
                        DB $1F,$23,$0C,$24,$1F,$34,$10,$28 ;
                        DB $0A,$45,$14,$28,$1F,$56,$18,$2C ;
                        DB $10,$78,$1C,$20,$10,$19,$20,$24 ;
                        DB $10,$5A,$28,$2C,$10,$6B,$1C,$2C ;
                        DB $12,$BC,$1C,$3C,$12,$8C,$1C,$30 ;
                        DB $10,$89,$20,$30,$1F,$39,$24,$34 ;
                        DB $1F,$3A,$28,$38,$10,$AB,$2C,$3C ;
                        DB $1F,$9D,$30,$34,$1F,$3D,$34,$38 ;
                        DB $1F,$AD,$38,$3C,$1F,$CD,$30,$3C ;
                        DB $06,$77,$40,$44,$06,$77,$48,$4C ; I.B. on roof
                        DB $06,$77,$4C,$50,$06,$77,$48,$50 ;
                        DB $06,$77,$50,$54,$06,$66,$58,$5C ;
                        DB $06,$66,$5C,$60,$06,$66,$60,$58 ; D.B. on roof
                        DB $06,$66,$64,$68,$06,$66,$68,$6C ;
                        DB $06,$66,$64,$6C,$06,$66,$6C,$70 ;
                        DB $05,$33,$74,$78,$05,$33,$7C,$80 ; skids
                        DB $07,$00,$84,$88,$04,$00,$88,$8C ; thruster
                        DB $04,$00,$8C,$90,$04,$00,$90,$84 ; end of transporter edges
TransportNormals	    DB $3F,$00,$00,$67,$BF,$6F,$30,$07 ;
                        DB $FF,$69,$3F,$15,$5F,$00,$22,$00 ;
                        DB $7F,$69,$3F,$15,$3F,$6F,$30,$07 ;
                        DB $1F,$08,$20,$03,$9F,$08,$20,$03 ;
                        DB $92,$08,$22,$0B,$9F,$4B,$20,$4F ;
                        DB $1F,$4B,$20,$4F,$12,$08,$22,$0B ;
                        DB $1F,$00,$26,$11,$1F,$00,$00,$79 ; end of Transporter
TransportType10Len      equ $  - TransportType10


;	\ Transporter hull data header info 37 vertices  6*37  = &DE
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

;\ -> &5BA1 \ Python = Type 12
Python:                 DB $05, $00, $19
                        DW PythonEdges
                        DB PythonEdgesSize
                        DB $00,$2A
                        DB PythonVertSize
                        DB PythonEdgesCnt
                        DB $00,$00
                        DB PythonNormalsSize
                        DB $28,$FA,$14
                        DW PythonNormals
                        DB $00, $1B
                        DW PythonVertices
PythonVertices:         DB $00, $00, $E0, $1F, $10, $32 
                        DB $00, $30, $30, $1E, $10, $54 
                        DB $60, $00, $10, $3F, $FF, $FF 
                        DB $60, $00, $10, $BF, $FF, $FF 
                        DB $00, $30, $20, $3E, $54, $98 
                        DB $00, $18, $70, $3F, $89, $CC 
                        DB $30, $00, $70, $BF, $B8, $CC 
                        DB $30, $00, $70, $3F, $A9, $CC 
                        DB $00, $30, $30, $5E, $32, $76 
                        DB $00, $30, $20, $7E, $76, $BA 
                        DB $00, $18, $70, $7E, $BA, $CC 
PythonVertSize          equ $  - PythonVertices
PythonEdges:            DB $1E, $32, $00, $20, $1F, $20, $00, $0C 
                        DB $1F, $31, $00, $08, $1E, $10, $00, $04 
                        DB $1D, $59, $08, $10, $1D, $51, $04, $08 
                        DB $1D, $37, $08, $20, $1D, $40, $04, $0C 
                        DB $1D, $62, $0C, $20, $1D, $A7, $08, $24 
                        DB $1D, $84, $0C, $10, $1D, $B6, $0C, $24 
                        DB $05, $88, $0C, $14, $05, $BB, $0C, $28 
                        DB $05, $99, $08, $14, $05, $AA, $08, $28 
                        DB $1F, $A9, $08, $1C, $1F, $B8, $0C, $18 
                        DB $1F, $C8, $14, $18, $1F, $C9, $14, $1C 
                        DB $1D, $AC, $1C, $28, $1D, $CB, $18, $28 
                        DB $1D, $98, $10, $14, $1D, $BA, $24, $28 
                        DB $1D, $54, $04, $10, $1D, $76, $20, $24
PythonEdgesSize         equ $  - PythonEdges
PythonEdgesCnt          equ PythonEdgesSize/4
PythonNormals           DB $9E, $1B, $28, $0B, $1E, $1B, $28, $0B 
                        DB $DE, $1B, $28, $0B, $5E, $1B, $28, $0B 
                        DB $9E, $13, $26, $00, $1E, $13, $26, $00 
                        DB $DE, $13, $26, $00, $5E, $13, $26, $00 
                        DB $BE, $19, $25, $0B, $3E, $19, $25, $0B 
                        DB $7E, $19, $25, $0B, $FE, $19, $25, $0B 
                        DB $3E, $00, $00, $70
PythonNormalsSize       equ $  - PythonNormals                    
PythonLen               equ $  - Python

; Mapping Orginal to new
; 0    => 0
; 1-2  => 1-2
; 3    => EQU Edges
; 4    => EQU Normals
; 5    => EQU EdgesCnt
; 6    => 6
; 7    => 7
; 8    => EQU VertSize
; 9    => EQU EdgesCnt
; 10-11=> 10-11
; 12   => EQU  NormalsSize
; 13   => 13
; 14   => 14
; 15   => 15
; 16   => EQU Edges
; 17   => EQU Normals
; 18   => 18
; 19   => 19
;\ -> &5C93  \ Viper = Type 16
Viper:                  DB $00, $F9, $15
                        DW PythonEdges
                        DB PythonEdgesSize
                        DB $00,$2A
                        DB PythonVertSize
                        DB PythonEdgesCnt
                        DB $00,$00
                        DB PythonNormalsSize
                        DB $17, $64, $20 
                        DW PythonNormals
                        DB $01, $11 
                        DW PythonVertices
ViperVertices:          DB $00, $00, $48, $1F, $21, $43 
                        DB $00, $10, $18, $1E, $10, $22 
                        DB $00, $10, $18, $5E, $43, $55 
                        DB $30, $00, $18, $3F, $42, $66 
                        DB $30, $00, $18, $BF, $31, $66 
                        DB $18, $10, $18, $7E, $54, $66 
                        DB $18, $10, $18, $FE, $35, $66 
                        DB $18, $10, $18, $3F, $20, $66 
                        DB $18, $10, $18, $BF, $10, $66 
                        DB $20, $00, $18, $B3, $66, $66 
                        DB $20, $00, $18, $33, $66, $66 
                        DB $08, $08, $18, $33, $66, $66 
                        DB $08, $08, $18, $B3, $66, $66 
                        DB $08, $08, $18, $F2, $66, $66 
                        DB $08, $08, $18, $72, $66, $66 
ViperVertSize           equ $  - ViperVertices
ViperEdges:             DB $1F, $42, $00, $0C, $1E, $21, $00, $04 
                        DB $1E, $43, $00, $08, $1F, $31, $00, $10 
                        DB $1E, $20, $04, $1C, $1E, $10, $04, $20 
                        DB $1E, $54, $08, $14, $1E, $53, $08, $18 
                        DB $1F, $60, $1C, $20, $1E, $65, $14, $18 
                        DB $1F, $61, $10, $20, $1E, $63, $10, $18 
                        DB $1F, $62, $0C, $1C, $1E, $46, $0C, $14 
                        DB $13, $66, $24, $30, $12, $66, $24, $34 
                        DB $13, $66, $28, $2C, $12, $66, $28, $38 
                        DB $10, $66, $2C, $38, $10, $66, $30, $34 
ViperEdgesSize          equ $  - ViperEdges
ViperEdgesCnt           equ ViperEdgesSize/4
ViperNormals            DB $1F, $00, $20, $00, $9F, $16, $21, $0B 
                        DB $1F, $16, $21, $0B, $DF, $16, $21, $0B 
                        DB $5F, $16, $21, $0B, $5F, $00, $20, $00 
                        DB $3F, $00, $00, $30
ViperNormalsSize        equ $  - ViperNormals                    
ViperLen                equ $  - Viper


;\ -> &5D6D \ Krait = Type 19
;
;01 10 0E 7A  	\ Krait hull data header info
;CE 55 00 12 
;66 15 64 00  	\ 17 vertices  6*17  = &66
;18 14 50 1E 
;00 00 02 10  	\ Q% different, normals different to Elite-A
;	\ Krait vertices data
;00 00 60 1F 01 23 
;00 12 30 3F 03 45 
;00 12 30 7F 12 45 
;5A 00 03 3F 01 44 
;5A 00 03 BF 23 55 
;5A 00 57 1C 01 11 
;5A 00 57 9C 23 33 
;00 05 35 09 00 33 
;00 07 26 06 00 33 
;12 07 13 89 33 33 
;12 07 13 09 00 00 
;12 0B 27 28 44 44 
;12 0B 27 68 44 44 
;24 00 1E 28 44 44 
;12 0B 27 A8 55 55 
;12 0B 27 E8 55 55 
;24 00 1E A8 55 55 
;	\ Krait edges and face data
;1F 03 00 04 1F 12 00 08 
;1F 01 00 0C 1F 23 00 10 
;1F 35 04 10 1F 25 10 08 
;1F 14 08 0C 1F 04 0C 04 
;1C 01 0C 14 1C 23 10 18 
;05 45 04 08 09 00 1C 28 
;06 00 20 28 09 33 1C 24 
;06 33 20 24 08 44 2C 34 
;08 44 34 30 07 44 30 2C 
;07 55 38 3C 08 55 3C 40 
;08 55 40 38 1F 07 30 06 
;5F 07 30 06 DF 07 30 06 
;9F 07 30 06 3F 4D 00 9A 
;BF 4D 00 9A 		\ end of Krait 
;
;\ -> &5E53 \ Constrictor = Type 31
;
;F3 49 26 7A  	\  Constrictor hull data header info 
;DA 4D 00 2E 
;66 18 00 00	\ 17 vertices  6*17  = &66
;28 2D C8 37 
;00 00 02 2F 
;	\ Constrictor vertices data
;14 07 50 5F 02 99 
;14 07 50 DF 01 99 
;36 07 28 DF 14 99 
;36 07 28 FF 45 89 
;14 0D 28 BF 56 88 
;14 0D 28 3F 67 88 
;36 07 28 7F 37 89 
;36 07 28 5F 23 99 
;14 0D 05 1F FF FF 
;14 0D 05 9F FF FF 
;14 07 3E 52 99 99 
;14 07 3E D2 99 99 
;19 07 19 72 99 99 
;19 07 19 F2 99 99 
;0F 07 0F 6A 99 99 
;0F 07 0F EA 99 99 
;00 07 00 40 9F 01 
;	\ Constrictor edges and face data
;1F 09 00 04 1F 19 04 08 
;1F 01 04 24 1F 02 00 20
;1F 29 00 1C 1F 23 1C 20 
;1F 14 08 24 1F 49 08 0C 
;1F 39 18 1C 1F 37 18 20 
;1F 67 14 20 1F 56 10 24 
;1F 45 0C 24 1F 58 0C 10 
;1F 68 10 14 1F 78 14 18 
;1F 89 0C 18 1F 06 20 24 
;12 99 28 30 05 99 30 38 
;0A 99 38 28 0A 99 2C 3C 
;05 99 34 3C 12 99 2C 34 
;1F 00 37 0F 9F 18 4B 14 
;1F 18 4B 14 1F 2C 4B 00 
;9F 2C 4B 00 9F 2C 4B 00 
;1F 00 35 00 1F 2C 4B 00 
;3F 00 00 A0 5F 00 1B 00   \ end of Constrictor  &5F55


CobraTablePointer   equ 6

ShipModelTable		DW	CargoType5,    ShuttleType9,    TransportType10,   CobraMk3 , TestVector , Constrictor, Python, Viper
ShipVertexTable		DW 	CargoVertices, ShuttleVertices, TransportVertices, CobraMk3Vertices , TestVectorVertices, ConstrictorVertices, PythonVertices, ViperVertices
ShipEdgeTable		DW  CargoEdges,    ShuttleEdges,    TransportEdges,    CobraMk3Edges  , TestVectorEdges , ConstrictorEdges, PythonEdges, ViperEdges
ShipNormalTable	    DW  CargoNormals,  ShuttleNormals,  TransportNormals,  CobraMk3Normals , TestVectorNormals, ConstrictorNormals, PythonNormals, ViperNormals

ShipModelSizeTable  DW  CargoType5Len, ShuttleType9Len, TransportType10Len,CobraMk3Len, TestVectorLen, ConstrictorLen, PythonLen, ViperLen


GetInfo:                                    ; gets pointer to ship data for ship type in a
GINF:
    ld          hl,ShipModelTable
    add         hl,a
    add         hl,a
    ld          e,(hl)
    inc         hl
    ld          d,(hl)
    ret


; memcopy_dma, hl = target address de = source address to copy, bc = length"
CopyVerticesDataToUBnk:
    ld          hl,(VerticesAddyAddr)       ; now the pointers are in Ubnk its easy to read
    ld          de,UBnkHullVerticies
    ld          b,0
	ld			a,(VertexCtX6Addr)
    ld          c,a
    ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
    call        memcopy_dma
    ret

CopyEdgeDataToUBnk:
    ld          hl,(EdgeAddyAddr)          ; now the pointers are in Ubnk its easy to read
    ld          de,UBnkHullEdges
    ld          b,0
	ld			a,(LineX4Addr)
    ld          c,a
    ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
    call        memcopy_dma
    ret

CopyNormalDataToUBnk:
    ld          hl,(FaceAddyAddr)          ; now the pointers are in Ubnk its easy to read
    ld          de,UBnkHullNormals
    ld          b,0
    ld          a,(FaceCtX4Addr)
    ld          c,a
    ex          de,hl                       ; dma transfer goes de -> hl i.e. opposite of ldir
    call        memcopy_dma
    ret

CopyShipDataToUBnk:							; a = model number to copy
	ld			(UbnkShipType),a			; mark ship type in bank
.GetHullDataLength:    
    ld          hl,ShipModelSizeTable
    add         hl,a
    add         hl,a                        ; we won't multiply by 2 as GetInfo is a general purpose routines so would end up x 4
    ld          c,(hl)
    inc         hl
    ld          b,(hl)                      ; bc now equals length of data set
.GetHullDataAddress:
    call        GetInfo                     ; de = address of Ship Data
    ex          de,hl                       ; hl = address of Ship Data
    ld          de,UBnkHullCopy             ; Universe bank
    ld          bc,22                       ; its now 22 bytes 
    ldir                                    ; Copy over 22 bytes
    call        CopyVerticesDataToUBnk
    call        CopyEdgeDataToUBnk
    call        CopyNormalDataToUBnk
    ret
