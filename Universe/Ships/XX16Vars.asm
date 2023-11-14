;-- XX16 --------------------------------------------------------------------------------------------------------------------------
UBnkTransmatSidevX          DW  0               ; XX16+0
UBnkTransmatSidev           EQU UBnkTransmatSidevX
UBnkTransmatSidevY          DW 0                ; XX16+2
UBnkTransmatSidevZ          DW 0                ; XX16+2
UBnkTransmatRoofvX          DW 0
UBnkTransmatRoofv           EQU UBnkTransmatRoofvX
UBnkTransmatRoofvY          DW 0                ; XX16+2
UBnkTransmatRoofvZ          DW 0                ; XX16+2
UBnkTransmatNosevX          DW 0
UBnkTransmatNosev           EQU UBnkTransmatNosevX
UBnkTransmatNosevY          DW 0                ; XX16+2
UBnkTransmatNosevZ          DW 0                ; XX16+2
UBnkTransmatTransX          DW 0
UBnkTransmatTransY          DW 0
UBnkTransmatTransZ          DW 0
XX16                        equ UBnkTransmatSidev
;-- XX16Inv --------------------------------------------------------------------------------------------------------------------------
UBnkTransInvRow0x0          DW 0
UBnkTransInvRow0x1          DW 0
UBnkTransInvRow0x2          DW 0
UBnkTransInvRow0x3          DW 0
UBnkTransInvRow1y0          DW 0
UBnkTransInvRow1y1          DW 0
UBnkTransInvRow1y2          DW 0
UBnkTransInvRow1y3          DW 0
UBnkTransInvRow2z0          DW 0
UBnkTransInvRow2z1          DW 0
UBnkTransInvRow2z2          DW 0
UBnkTransInvRow2z3          DW 0

XX16Inv             equ UBnkTransInvRow0x0
