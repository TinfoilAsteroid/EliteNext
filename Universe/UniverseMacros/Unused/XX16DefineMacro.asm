
XX16DefineMacro: MACRO   prefix1?
    DEFINE __XX16_arg1_tmp prefix1?
    LUA ALLPASS 
        prf = sj.get_define("__XX16_arg1_tmp")

        _pl(";-- XX16 --------------------------------------------------------------------------------------------------------------------------")
        _pl(prf .. "BnkTransmatSidevX          DW  0               ; XX16+0")
        _pl(prf .. "BnkTransmatSidev           EQU " .. prf .. "BnkTransmatSidevX")
        _pl(prf .. "BnkTransmatSidevY          DW 0                ; XX16+2")
        _pl(prf .. "BnkTransmatSidevZ          DW 0                ; XX16+2")
        _pl(prf .. "BnkTransmatRoofvX          DW 0")
        _pl(prf .. "BnkTransmatRoofv           EQU " .. prf .. "BnkTransmatRoofvX")
        _pl(prf .. "BnkTransmatRoofvY          DW 0                ; XX16+2")
        _pl(prf .. "BnkTransmatRoofvZ          DW 0                ; XX16+2")
        _pl(prf .. "BnkTransmatNosevX          DW 0")
        _pl(prf .. "BnkTransmatNosev           EQU " .. prf .. "BnkTransmatNosevX")
        _pl(prf .. "BnkTransmatNosevY          DW 0                ; XX16+2")
        _pl(prf .. "BnkTransmatNosevZ          DW 0                ; XX16+2")
        _pl(prf .. "BnkTransmatTransX          DW 0")
        _pl(prf .. "BnkTransmatTransY          DW 0")
        _pl(prf .. "BnkTransmatTransZ          DW 0")
        _pl(prf .. "XX16                       equ " .. prf .. "BnkTransmatSidev")
        _pl(";-- XX16Inv --------------------------------------------------------------------------------------------------------------------------")
        _pl(prf .. "BnkTransInvRow0x0          DW 0")
        _pl(prf .. "BnkTransInvRow0x1          DW 0")
        _pl(prf .. "BnkTransInvRow0x2          DW 0")
        _pl(prf .. "BnkTransInvRow0x3          DW 0")
        _pl(prf .. "BnkTransInvRow1y0          DW 0")
        _pl(prf .. "BnkTransInvRow1y1          DW 0")
        _pl(prf .. "BnkTransInvRow1y2          DW 0")
        _pl(prf .. "BnkTransInvRow1y3          DW 0")
        _pl(prf .. "BnkTransInvRow2z0          DW 0")
        _pl(prf .. "BnkTransInvRow2z1          DW 0")
        _pl(prf .. "BnkTransInvRow2z2          DW 0")
        _pl(prf .. "BnkTransInvRow2z3          DW 0")

        _pl(prf .. "XX16Inv                    equ " .. prf .. "BnkTransInvRow0x0")
    ENDLUA
                            ENDM