
XX18DefineMacro: MACRO   prefix1?
    DEFINE __XX18_arg1_tmp prefix1?
    LUA ALLPASS 
        prf = sj.get_define("__XX18_arg1_tmp")
        

;-- XX18 --------------------------------------------------------------------------------------------------------------------------
        _pl(prf .. "BnkDrawCam0xLo             DB  0               ; XX18+0")
        _pl(prf .. "BnkDrawCam0xHi             DB  0               ; XX18+1")
        _pl(prf .. "BnkDrawCam0xSgn            DB  0               ; XX18+2")
        _pl(prf .. "BnkDrawCam0x               equ " .. prf .. "BnkDrawCam0xLo")
        _pl(prf .. "BnkDrawCam0yLo             DB  0               ; XX18+3")
        _pl(prf .. "BnkDrawCam0yHi             DB  0               ; XX18+4")
        _pl(prf .. "BnkDrawCam0ySgn            DB  0               ; XX18+5")
        _pl(prf .. "BnkDrawCam0y               equ " .. prf .. "BnkDrawCam0yLo")
        _pl(prf .. "BnkDrawCam0zLo             DB  0               ; XX18+6")
        _pl(prf .. "BnkDrawCam0zHi             DB  0               ; XX18+7")
        _pl(prf .. "BnkDrawCam0zSgn            DB  0               ; XX18+8")
        _pl(prf .. "BnkDrawCam0z               equ " .. prf .. "BnkDrawCam0zLo")
        _pl(prf .. "XX18                       equ " .. prf .. "BnkDrawCam0xLo")
    ENDLUA
                            ENDM