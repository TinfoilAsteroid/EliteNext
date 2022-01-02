;-- XX16 --------------------------------------------------------------------------------------------------------------------------
SBnkTransmatSidevX          DW  0               ; XX16+0
SBnkTransmatSidev           EQU SBnkTransmatSidevX
SBnkTransmatSidevY          DW 0                ; XX16+2
SBnkTransmatSidevZ          DW 0                ; XX16+2
SBnkTransmatRoofvX          DW 0
SBnkTransmatRoofv           EQU SBnkTransmatRoofvX
SBnkTransmatRoofvY          DW 0                ; XX16+2
SBnkTransmatRoofvZ          DW 0                ; XX16+2
SBnkTransmatNosevX          DW 0
SBnkTransmatNosev           EQU SBnkTransmatNosevX
SBnkTransmatNosevY          DW 0                ; XX16+2
SBnkTransmatNosevZ          DW 0                ; XX16+2
SBnkTransmatTransX          DW 0
SBnkTransmatTransY          DW 0
SBnkTransmatTransZ          DW 0
SunXX16                      equ SBnkTransmatSidev
;-- XX16Inv --------------------------------------------------------------------------------------------------------------------------
SBnkTransInvRow0x0          DW 0
SBnkTransInvRow0x1          DW 0
SBnkTransInvRow0x2          DW 0
SBnkTransInvRow0x3          DW 0
SBnkTransInvRow1y0          DW 0
SBnkTransInvRow1y1          DW 0
SBnkTransInvRow1y2          DW 0
SBnkTransInvRow1y3          DW 0
SBnkTransInvRow2z0          DW 0
SBnkTransInvRow2z1          DW 0
SBnkTransInvRow2z2          DW 0
SBnkTransInvRow2z3          DW 0

SunXX16Inv             equ SBnkTransInvRow0x0
