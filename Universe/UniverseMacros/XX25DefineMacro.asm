

XX25DefineMacro: MACRO   prefix1?
    DEFINE __XX25_arg1_tmp prefix1?
    LUA ALLPASS 
        prf = sj.get_define("__XX25_arg1_tmp")
        
        _pl(prf .. ";-- XX25 --------------------------------------------------------------------------------------------------------------------------")
        _pl(prf .. "BnKProjxLo                 DB  0")
        _pl(prf .. "BnKProjxHi                 DB  0")
        _pl(prf .. "BnKProjxSgn                DB  0")
        _pl(prf .. "BnKProjx                   EQU " .. prf .. "BnKProjxLo")
        _pl(prf .. "BnKProjyLo                 DB  0")
        _pl(prf .. "BnKProjyHi                 DB  0")
        _pl(prf .. "BnKProjySgn                DB  0")
        _pl(prf .. "BnKProjy                   EQU " .. prf .. "BnKProjyLo")
        _pl(prf .. "BnKProjzLo                 DB  0")
        _pl(prf .. "BnKProjzHi                 DB  0")
        _pl(prf .. "BnKProjzSgn                DB  0")
        _pl(prf .. "BnKProjz                   EQU " .. prf .. "BnKProjzLo")
        _pl(prf .. "XX25                       EQU " .. prf .. "BnKProjxLo")
    ENDLUA
                            ENDM        
