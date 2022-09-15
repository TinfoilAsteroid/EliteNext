 DEVICE ZXSPECTRUMNEXT

 CSPECTMAP soundTst.map
 OPT --zxnext=cspect --syntax=a --reversepop


DEBUGSEGSIZE   equ 1
DEBUGLOGSUMMARY equ 1
;DEBUGLOGDETAIL equ 1

;----------------------------------------------------------------------------------------------------------------------------------
; Game Defines
ScreenLocal     EQU 0
ScreenGalactic  EQU ScreenLocal + 1
ScreenMarket    EQU ScreenGalactic + 1
ScreenMarketDsp EQU ScreenMarket + 1
ScreenStatus    EQU ScreenMarketDsp + 1
ScreenInvent    EQU ScreenStatus + 1
ScreenPlanet    EQU ScreenInvent + 1
ScreenEquip     EQU ScreenPlanet + 1
ScreenLaunch    EQU ScreenEquip + 1
ScreenFront     EQU ScreenLaunch + 1
ScreenAft       EQU ScreenFront+1
ScreenLeft      EQU ScreenAft+2
ScreenRight     EQU ScreenLeft+3
;----------------------------------------------------------------------------------------------------------------------------------
; Colour Defines
    INCLUDE "./Hardware/L2ColourDefines.asm"
    INCLUDE "./Hardware/L1ColourDefines.asm"

;----------------------------------------------------------------------------------------------------------------------------------

    INCLUDE "./Hardware/register_defines.asm"
    INCLUDE "./Layer2Graphics/layer2_defines.asm"
    INCLUDE	"./Hardware/memory_bank_defines.asm"
    INCLUDE "./Hardware/screen_equates.asm"


    INCLUDE "./Macros/MMUMacros.asm"
    INCLUDE "./Macros/ShiftMacros.asm"
    INCLUDE "./Macros/CopyByteMacros.asm"
    INCLUDE "./Macros/jumpMacros.asm"
    INCLUDE "./Macros/returnMacros.asm"
    INCLUDE "./Macros/carryFlagMacros.asm"
    INCLUDE "./Macros/graphicsMacros.asm"
   
    INCLUDE "./Macros/NegateMacros.asm"    
    INCLUDE "./Macros/callMacros.asm"    
    INCLUDE "./Macros/ldCopyMacros.asm"
    INCLUDE "./Macros/ldIndexedMacros.asm"
    INCLUDE "./Variables/general_variables_macros.asm"
    


                        ORG         $8000
start:                  MMUSelectROMS
                        di
                        nextreg     TURBO_MODE_REGISTER,0;Speed_28MHZ
.InitialisePeripherals: nextreg     PERIPHERAL_2_REGISTER, AUDIO_CHIPMODE_AY ; Enable Turbo Sound
                        nextreg     PERIPHERAL_3_REGISTER, DISABLE_RAM_IO_CONTENTION | ENABLE_TURBO_SOUND
                        call        InitAudio
                        ld	a,VectorTable>>8
                        ld	i,a						                        ; im2 table will be at address 0xa000
                        nextreg     LINE_INTERRUPT_CONTROL_REGISTER,2       ; Video interrup on 
                        nextreg     LINE_INTERRUPT_VALUE_LSB_REGISTER,64    ; first line..                        
                        im	2                                               ; enable Interrupts
                        ei
                        
SoundLoop:              ld          bc,$0FFF
                        call        Delay
                        ld          hl,(IR_COUNT)
                        ld          a,h
                        or          l
                        jr          nz,SoundLoop
                        di
                        ld          hl, $0060
                        ld          (IR_COUNT),hl
                        ld          a,(DELTA)
                        cp          40
                        jr          z,.ResetDelta
                        inc         a
                        ld          (DELTA),a
                        ei
                        jr          SoundLoop
.ResetDelta:            ld          a,0
                        ld          (DELTA),a
                        ei
                        jp          SoundLoop

Delay:                  nop
                        nop
                        nop
                        nop
                        nop
.PauseLoop:             dec         bc
                        ld          a,b
                        or          c
                        djnz       Delay
                        ret
;Vector table must be bank aligned
                org     $d000
VectorTable:            
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine
                        
IM2Routine:     ; initially do nothing
                push    af,,hl,,bc
                ld      a,(DELTA)
                ld      hl,LAST_DELTA
                cp      (hl)
                jr      z,.NoSpeedChange
.SpeedChange:   call    EngineOn
                ld      a,(DELTA)
                ld      (LAST_DELTA),a
.NoSpeedChange: ld      hl,(IR_COUNT)
                ld      a,h
                or      l
                jr      z,.NoDec
                dec     hl
                ld      (IR_COUNT),hl
.NoDec:         pop     af,,hl,,bc
                ei
                reti
                
    INCLUDE "./Hardware/sound.asm"

IR_COUNT        dw  $0060
DELTA           db  0
LAST_DELTA      db  0
    
    SAVENEX OPEN "soundTst.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    