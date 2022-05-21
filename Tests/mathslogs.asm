                        DEVICE ZXSPECTRUMNEXT
                        DEFINE  DOUBLEBUFFER 1
                        CSPECTMAP mathslogs.map
                        OPT --zxnext=cspect --syntax=a --reversepop
                        INCLUDE "../Macros/carryFlagMacros.asm"
                        INCLUDE "../Macros/jumpMacros.asm"
                        INCLUDE "../Macros/ldCopyMacros.asm"
                        INCLUDE "../Macros/ShiftMacros.asm"
                        INCLUDE "../Macros/NegateMacros.asm" 
                        
testStartup:            ORG         $8000

                        ld      ix, TestCase1
.TestLoop:              ld      a,(testCounter)
                        ld      hl, testTotal
                        cp      (hl)
                        jr      z,.Done1
                        ld      a,(ix+testCase.QVal)
                        ld      b,a
                        ld      a,(ix+testCase.AVal)
                        JumpIfALTNusng 197, .LTCalc
.GTCalc:                ld      e,a
                        call    AEquAmul256Div197Log
                        ld      (ix+testCase.Result),a
                        xor     a
                        ld      (ix+testCase.Expected),a
                        jp      .NextIteration
.LTCalc:                ld      e,a
                        call    AEquAmul256Div197LogLT
                        ld      (ix+testCase.Expected),a
                        xor      a
                        ld      (ix+testCase.Result),a
.NextIteration:         ld      hl,testCounter
                        inc     (hl)
                        push    ix
                        pop     hl
                        ld      a,4
                        add     hl,a
                        push    hl
                        pop     ix
                        jp      .TestLoop
.Done1:                 ld      ix, TestCase10
                        xor     a
                        ld      (testCounter),a
.TestLoop2:             ld      a,(testCounter)
                        ld      hl, testTotal2
                        cp      (hl)
                        jr      z,.Done
                        ld      a,(ix+testCase.QVal)
                        ld      b,a
                        ld      a,(ix+testCase.AVal)
                        JumpIfALTNusng b, .LTCalc2
.GTCalc2:               ld      e,a
                        call    AEquAmul256DivBLog
                        ld      (ix+testCase.Result),a
                        xor     a
                        ld      (ix+testCase.Expected),a
                        jp      .NextIteration2
.LTCalc2:               ld      e,a
                        call    AEquAmul256DivBLogLT
                        ld      (ix+testCase.Expected),a
                        xor      a
                        ld      (ix+testCase.Result),a
.NextIteration2:        ld      hl,testCounter
                        inc     (hl)
                        push    ix
                        pop     hl
                        ld      a,4
                        add     hl,a
                        push    hl
                        pop     ix
                        jp      .TestLoop2
.Done                   break
                        jp      .Done                   ; complete tight loop

                        INCLUDE "../Variables/constant_equates.asm"
                        INCLUDE "../Hardware/L2ColourDefines.asm"
                       
                        INCLUDE "../Variables/general_variables_macros.asm"
                        INCLUDE "../Maths/multiply.asm"
                        INCLUDE "../Variables/general_variables.asm"
                        
                        INCLUDE "../Maths/logmaths.asm"
                        INCLUDE "../Tables/antilogtable.asm"
                        INCLUDE "../Tables/logtable.asm"                       

                        STRUCT testCase
AVal                    BYTE 1
QVal                    BYTE 2
Result                  BYTE 3
Expected                BYTE 4
                        ENDS
;                            01   02   03   04  
TestCase1               DB  $05,  197, $FF, $FF
TestCase2               DB  $06,  197, $FF, $FF
TestCase3               DB  $A5,  197, $FF, $FF
TestCase4               DB  $C5,  197, $FF, $FF
TestCase5               DB  $65,  197, $FF, $FF
TestCase6               DB  $8A,  197, $FF, $FF
TestCase7               DB  $AC,  197, $FF, $FF
TestCase8               DB  $85,  197, $FF, $FF
TestCase9               DB  $09,  197, $FF, $FF
TestCase10              DB  $01,  197, $FF, $FF
TestCase12              DB  $05,  $01, $FF, $FF
TestCase13              DB  $05,  $A3, $FF, $FF
TestCase14              DB  $A5,  $83, $FF, $FF
TestCase15              DB  $05,  $03, $FF, $FF
TestCase16              DB  $05,  $00, $FF, $FF
TestCase17              DB  $0A,  $80, $FF, $FF
TestCase18              DB  $05,  $80, $FF, $FF
TestCase19              DB  $85,  $83, $FF, $FF
TestCase20              DB  $05,  $83, $FF, $FF
TestCase21              DB  $05,  $03, $FF, $FF
testTotal               DB  ($-TestCase10)/4
testTotal2              DB  ($-TestCase10)/4
testCounter             DB   0




    SAVENEX OPEN "mathslogs.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    