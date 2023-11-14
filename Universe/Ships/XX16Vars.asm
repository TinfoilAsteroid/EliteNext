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
UbnkTransmatTransX          DW 0
UbnkTransmatTransY          DW 0
UbnkTransmatTransZ          DW 0
XX16                        equ UBnkTransmatSidev
;-- XX16Inv --------------------------------------------------------------------------------------------------------------------------
UbnkTransInvRow0x0          DW 0
UbnkTransInvRow0x1          DW 0
UbnkTransInvRow0x2          DW 0
UbnkTransInvRow0x3          DW 0
UbnkTransInvRow1y0          DW 0
UbnkTransInvRow1y1          DW 0
UbnkTransInvRow1y2          DW 0
UbnkTransInvRow1y3          DW 0
UbnkTransInvRow2z0          DW 0
UbnkTransInvRow2z1          DW 0
UbnkTransInvRow2z2          DW 0
UbnkTransInvRow2z3          DW 0

XX16Inv             equ UbnkTransInvRow0x0
