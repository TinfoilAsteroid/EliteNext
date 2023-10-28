
XX15DefineMacro: MACRO   prefix1?
    DEFINE __XX15_arg1_tmp prefix1?
    LUA ALLPASS 
        prf = sj.get_define("__XX15_arg1_tmp")
        
        _pl(prf .. "BnKXScaled                  DB  0               ; XX15+0Xscaled")
        _pl(prf .. "BnKXScaledSign              DB  0               ; XX15+1xsign")
        _pl(prf .. "BnKYScaled                  DB  0               ; XX15+2yscaled")
        _pl(prf .. "BnKYScaledSign              DB  0               ; XX15+3ysign")
        _pl(prf .. "BnKZScaled                  DB  0               ; XX15+4zscaled")
        _pl(prf .. "BnKZScaledSign              DB  0               ; XX15+5zsign")

        _pl(prf .. "XX15:                       equ " .. prf .. "BnKXScaled")
        _pl(prf .. "XX15VecX:                   equ " .. prf .. "XX15")
        _pl(prf .. "XX15VecY:                   equ " .. prf .. "XX15+1")
        _pl(prf .. "XX15VecZ:                   equ " .. prf .. "XX15+2")
        _pl(prf .. "BnKXPoint:                  equ " .. prf .. "XX15")
        _pl(prf .. "BnKXPointLo:                equ " .. prf .. "XX15+0")
        _pl(prf .. "BnKXPointHi:                equ " .. prf .. "XX15+1")
        _pl(prf .. "BnKXPointSign:              equ " .. prf .. "XX15+2")
        _pl(prf .. "BnKYPoint:                  equ " .. prf .. "XX15+3")
        _pl(prf .. "BnKYPointLo:                equ " .. prf .. "XX15+3")
        _pl(prf .. "BnKYPointHi:                equ " .. prf .. "XX15+4")
        _pl(prf .. "BnKYPointSign:              equ " .. prf .. "XX15+5")
    ENDLUA
                            ENDM