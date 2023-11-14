 DEVICE ZXSPECTRUMNEXT

 CSPECTMAP clipTst.map
 OPT --zxnext=cspect --syntax=a --reversepop

    MACRO LL121_TEST prefix1?, prefix2?, prefix3?
prefix1?_JumpPoint: ld a, 1
prefix2?JumpPoint:  ld b, 1
prefix3?JumpPoint:  ld c, a    
    
    ENDM

    MACRO LL121_6502 prefix1?, prefix2?, prefix3?
    DEFINE __testM_arg1_tmp prefix1?
    DEFINE __testM_arg2_tmp prefix2?
    DEFINE __testM_arg3_tmp prefix3?
    LUA ALLPASS
                xp = sj.get_define("__testM_arg1_tmp")
                yp = sj.get_define("__testM_arg2_tmp")
                zp = sj.get_define("__testM_arg3_tmp")
                
                _pl(xp .. "BnKXScaled                  DB  0               ; XX15+0Xscaled")
                _pl(xp .. "coord:         DB 0 ; dumpt")
                _pl(yp .. "coord:         DB 0")
                _pl(zp .. "coord:         DB 0")

                _pl(xp .. "_label:     ld  a,(" .. xp .. "coord)")
                _pc("     ld  b,a")
                _pc("     ld  a,(" .. yp .. "coord)")
                _pc("     add a,b")
                _pc("     ld  (" .. zp .. "coord),a")

    ENDLUA
                ENDM



                        INCLUDE "./Universe/UniverseMacros/XX15DefineMacro.asm"
                                           
                        
                        ORG         $8000
                        ;ExampleMacro  X, Y, Z
                        LL121_TEST A, B, C
                      ;  XX15DefineMacro P 
EndCode:               jp           EndCode                        

    SAVENEX OPEN "macroTst.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    