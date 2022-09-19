 DEVICE ZXSPECTRUMNEXT

 CSPECTMAP soundTst.map
 OPT --zxnext=cspect --syntax=a --reversepop


DEBUGSEGSIZE   equ 1
DEBUGLOGSUMMARY equ 1
;DEBUGLOGDETAIL equ 1
   ; DEFINE          USETIMER 25
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

TXTINK          EQU 0x10
TXTPAPER        EQU 0x11
TXTFLASH        EQU 0x12
TXTBRIGHT       EQU 0x13
TXTINVERSE      EQU 0x14
TXTOVER         EQU 0x15
TXTAT           EQU 0x16
TXTTAB          EQU 0x17
TXTCR           EQU 0x0C
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
    
TopOfStack              equ $7F00 ;$6100

                        ORG         $8000
Start:                  MMUSelectROMS
                        di
                        nextreg     TURBO_MODE_REGISTER,0;Speed_28MHZ
                        ; For testing we will assume all is mono for now
.InitialisePeripherals: nextreg     PERIPHERAL_2_REGISTER, AUDIO_CHIPMODE_AY ; Enable Turbo Sound A left B center C right
                        nextreg     PERIPHERAL_3_REGISTER, DISABLE_RAM_IO_CONTENTION | ENABLE_TURBO_SOUND
                        MMUSelectSound
                        call        InitAudio
                        MMUSelectLayer2
                        ld	        a,VectorTable>>8
                        ld	        i,a						                        ; im2 table will be at address 0xa000
                        nextreg     LINE_INTERRUPT_CONTROL_REGISTER,%00000110       ; Video interrup on 
                        nextreg     LINE_INTERRUPT_VALUE_LSB_REGISTER,0   ; lasta line..                        
                        im	2                                               ; enable Interrupts
                        ei
                        ZeroA                       
                        ld          (SoundFxToEnqueue),a
SoundLoop:              
                        call        Delay
                        call        Delay
                        call        Delay
                        call        Delay
                        call        Delay
                        
                        ZeroA
                        ld          (SoundFxToEnqueue),a
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
.ResetDelta:            ld          a,20
                        ld          (DELTA),a
                        ei
                        jp          SoundLoop

Delay:                  ld          bc,$4FFF
DelayLoop:                        nop
                        nop
                        nop
                        nop
                        nop
.PauseLoop:             dec         bc
                        ld          a,b
                        or          c
                        jr      nz,       DelayLoop
                       ; call    ShutdownSound
                        ret

SavedMMU7       db      0

;Vector table must be bank aligned
                org     $d000
                ;crashes
                
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
                push    af,,bc,,de,,hl,,ix,,iy
                ; get current MMU and save it
                GetNextReg  MMU_SLOT_7_REGISTER
                ld      (SavedMMU7),a
                MMUSelectSound
                ld      a,(DELTA)
                ld      hl,LAST_DELTA
                cp      (hl)
                jr      z,.NoSpeedChange
.SpeedChange:   ;call    UpdateEngineSound
                ld      a,(DELTA)
                ld      (LAST_DELTA),a
.NoSpeedChange: ld      hl,(IR_COUNT)
                ld      a,h
                or      l
                jr      z,.NoDec
                dec     hl
                ld      (IR_COUNT),hl
                ; NOTE play then equeue simplifies ligic, more chance slot free
.NoDec:         ld      a,(SoundFxToEnqueue)        ; Check for new sound 
                cp      $FF
                call    nz,EnqueSound
.NoNewSound:    IFDEF   USETIMER
                   ld      hl,SoundChannelTimer
                ENDIF
                ld      de,SoundChannelSeq
                ld      b,8
.ResetLoop:     ld      a,(de)                  ; we only update active channels
                cp      $FF
                jr      z,.NextCounter
                IFDEF   USETIMER
                    
                    dec     (hl)                    ; so update channel timer
                    jr      nz,.NextCounter         ; if its not zero then continue
                ENDIF
                ld      a,8                     ; a now = channel to play
                sub     a,b
                IFDEF   USETIMER
                    push    bc,,de,,hl              ; save state
                ELSE
                    push    bc,,de
                ENDIF
                call    PlaySound               ; play sound
                IFDEF   USETIMER
                    pop     bc,,de,,hl              ; restore state so de = correct timer & hl = correct channel, b = coutner
                ELSE
                    pop     bc,,de              ; restore state so de = correct timer & hl = correct channel, b = coutner
                ENDIF                
; If it went negative new sound update
                IFDEF   USETIMER
.ResetTimer:        ld      a,SOUNDSTEPLENGTH       ; as we fallin to this it will auto update counter 
                    ld      (hl),a                  ; so may take it out of playsound routine
                ENDIF
.NextCounter    IFDEF   USETIMER
                    inc     hl
                ENDIF
                inc     de
                djnz    .ResetLoop
.DoneInterrupt: ld      a,(SavedMMU7)
                nextreg MMU_SLOT_7_REGISTER,a       ; Restore MMU7
                pop     af,,bc,,de,,hl,,ix,,iy
                
                ei
                reti

EngineSoundChanged:     DB  0
SoundFxToEnqueue        DB  $FF             ; $FF No sound to enque,if it is $FF then next sound will not get enqued
	
IR_COUNT        dw  $0060
DELTA           db  20
LAST_DELTA      db  0

                
                        SLOT    SoundAddr
                        PAGE    BankSound
                        ORG SoundAddr, BankSound             
    INCLUDE "./Hardware/sound.asm"

; SoundFX Variables -------------------------------------------------------------------------------------------
    
    SAVENEX OPEN "soundTst.nex", Start , TopOfStack
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    