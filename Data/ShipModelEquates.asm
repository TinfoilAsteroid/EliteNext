ScoopDebrisOffset	    equ	0                               ; hull byte#0 high nibble is scoop info, lower nibble is debris spin info
MissileLockLoOffset	    equ 1
MissileLockHiOffset	    equ 2
EdgeAddyOffset		    equ 3
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
FaceAddyOffset		    equ 16
QOffset				    equ 18
LaserOffset			    equ 19
VerticiesAddyOffset     equ 20
ShipTypeOffset          equ 22
ShipNewBitsOffset       equ 23
ShipDataLength          equ ShipNewBitsOffset+1

CobraTablePointer       equ 43
;29 faulty
BankThreshold           equ 16

ShipTableALast          equ 23
ShipTableBLast          equ 39
ShipTableCLast          equ 55
