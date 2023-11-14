
XX12DefineMacro: MACRO   prefix1?
    DEFINE __XX12_arg1_tmp prefix1?
    LUA ALLPASS 
        prf = sj.get_define("__XX12_arg1_tmp")

        _pl(";-- transmat0 --------------------------------------------------------------------------------------------------------------------------")
        _pl("; Note XX12 comes after as some logic in normal processing uses XX15 and XX12 combines")
        _pl(prf .. "BnKXX12xLo                 DB  0               ; XX12+0")
        _pl(prf .. "BnKXX12xSign               DB  0               ; XX12+1")
        _pl(prf .. "BnKXX12yLo                 DB  0               ; XX12+2")
        _pl(prf .. "BnKXX12ySign               DB  0               ; XX12+3")
        _pl(prf .. "BnKXX12zLo                 DB  0               ; XX12+4")
        _pl(prf .. "BnKXX12zSign               DB  0               ; XX12+5")
        _pl(prf .. "XX12Save                   DS  6")
        _pl(prf .. "XX12Save2                  DS  6")
        _pl(prf .. "XX12                       equ " .. prf .. "BnKXX12xLo")
        _pl(prf .. "varXX12                    equ " .. prf .. "BnKXX12xLo")
        _pl("; Repurposed XX12 when plotting lines")
        _pl(prf .. "BnkY2                      equ " .. prf .. "XX12+0")
        _pl(prf .. "bnKy2Lo                    equ " .. prf .. "XX12+0")
        _pl(prf .. "BnkY2Hi                    equ " .. prf .. "XX12+1")
        _pl(prf .. "BnkDeltaXLo                equ " .. prf .. "XX12+2")
        _pl(prf .. "BnkDeltaXHi                equ " .. prf .. "XX12+3")
        _pl(prf .. "BnkDeltaYLo                equ " .. prf .. "XX12+4")
        _pl(prf .. "BnkDeltaYHi                equ " .. prf .. "XX12+5")
        _pl(prf .. "bnkGradient                equ " .. prf .. "XX12+2")
        _pl(prf .. "BnkTemp1                   equ " .. prf .. "XX12+2")
        _pl(prf .. "BnkTemp1Lo                 equ " .. prf .. "XX12+2")
        _pl(prf .. "BnkTemp1Hi                 equ " .. prf .. "XX12+3")
        _pl(prf .. "BnkTemp2                   equ " .. prf .. "XX12+3")
        _pl(prf .. "BnkTemp2Lo                 equ " .. prf .. "XX12+3")
        _pl(prf .. "BnkTemp2Hi                 equ " .. prf .. "XX12+4")
    ENDLUA
                            ENDM