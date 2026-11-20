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
ShipSolidFlagOffset         equ 27 ; Intially for non cargo these will be garbage
ShipSolidFillOffset         equ 28
ShipSolidLenOffset          equ 29
ShipDataLength              equ ShipSolidLenOffset+1         ; (was ShipECMFittedChanceOffset + 1: the solid fields were never copied)
; SOLID_HULL phase 2 polygons (ports, Tools/ship_faces.py PORTS): each one's type, which picks its colour
; (SolidPortColours, Layer2Graphics/l2_solid_hull.asm); later an engine may take a thrust colour while manoeuvring
PortEngine                  equ 0                           ; engine ports: dark grey
PortEntrance                equ 1                           ; a station's entrance: black

CobraTablePointer           equ 43
;29 faulty
BankThreshold               equ 16

ShipTableALast              equ 23
ShipTableBLast              equ 39
ShipTableCLast              equ 55
