ScoopDebrisOffset	        equ	0                               ; hull byte#0 high nibble is scoop info, lower nibble is debris spin info
MissileLockLoOffset	        equ 1
MissileLockHiOffset	        equ 2
EdgeAddyOffset		        equ 3
LineX4Offset		        equ 5
GunVertexOffset		        equ 6
ExplosionCtOffset	        equ 7
VertexCountOffset           equ 8
VertexCtX6Offset	        equ 9
EdgeCountOffset		        equ 10
BountyLoOffset		        equ 11
BountyHiOffset		        equ 12
FaceCtX4Offset		        equ 13
DotOffset			        equ 14
EnergyOffset		        equ 15
SpeedOffset			        equ 16
FaceAddyOffset		        equ 17
QOffset				        equ 19
LaserOffset			        equ 20
VerticiesAddyOffset         equ 21
ShipTypeOffset              equ 23
ShipNewBitsOffset           equ 24
ShipAIFlagsOffset           equ 25
ShipECMFittedChanceOffset   equ 26
ShipDataLength              equ ShipECMFittedChanceOffset+1

CobraTablePointer           equ 43
;29 faulty
BankThreshold               equ 16

ShipTableALast              equ 23
ShipTableBLast              equ 39
ShipTableCLast              equ 55
