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
;0=blk,1=blu,2=red,3=mag,4=grn,5=cyn,6=yel,7=wht
                        ORG         $8000
Start:                  MMUSelectROMS
                        di
                        ld          a,0
                        call        SetBorder
                        nextreg     TURBO_MODE_REGISTER,0;Speed_28MHZ
                        ; For testing we will assume all is mono for now
.InitialisePeripherals: nextreg     PERIPHERAL_2_REGISTER, AUDIO_CHIPMODE_AY ; Enable Turbo Sound A left B center C right
                        nextreg     PERIPHERAL_3_REGISTER, DISABLE_RAM_IO_CONTENTION | ENABLE_TURBO_SOUND | INTERNAL_SPEAKER_ENABLE
                        nextreg     PERIPHERAL_4_REGISTER, %00000000
                        MMUSelectSound
                        call        InitAudioMusic
;.DefaultAYChip1:        ld      hl,$FFBF            ; h = turbo control, l = turbo register
;                        ld      c,$FD               ; bc = h$FD or l$FD
;                        ld      de,$000E            ; d = value 0, e = counter
;                        or      TURBO_MANDATORY | TURBO_LEFT | TURBO_RIGHT
;                        ld      b,h                 ; now select chip and set to stereo
;                        out     (c),a               ; .
;.DefaultLoop:           dec     e                   ; loop down we set E 1 higher
;                        jp      z,.Complete         ; On zero we complete, we
;                        ld      b,h                 ; Set register to 0
;                        out     (c),e               ; .
;                        ld      b,l                 ; .
;                        out     (c),d               ; .
;.DefaultDone:           jp      .DefaultLoop        ; and loop
;.Complete:              ld      b,h                 ; we set fine tone to 0
;                        out     (c),e               ; though as volume is 0
;                        ld      b,l                 ; it doesn't really 
;                        out     (c),d               ; matter 
;SoundTestMinimal:       ld      a,%10000001
;                        ld      bc,$FFFD
;                        out     (c),a
;.TestTone:              ld      a,CHANNEL_A_AMPLITUDE
;                        ld      bc,$FFFD
;                        out     (c),a
;                        ld      b,$BF
;                        ld      a,$0F
;                        out     (c),a
;                        ld      a,CHANNEL_A_COARSE
;                        ld      b,$FF
;                        out     (c),a
;                        ld      a,$1F
;                        ld      b,$BD
;                        out     (c),a
;                        ld      a,CHANNEL_A_FINE
;                        ld      b,$FF
;                        out     (c),a
;                        ld      a,$C8
;                        ld      b,$BF
;                        out     (c),a
;.EndLoop:               jp      .EndLoop                        
                        MMUSelectLayer2
                        ld	        a,VectorTable>>8
                        ld	        i,a						                       ; im2 table will be at address 0xa000
                        nextreg     LINE_INTERRUPT_CONTROL_REGISTER,%00000110      ; Video interrupt
                        nextreg     LINE_INTERRUPT_VALUE_LSB_REGISTER,0            ; .                     
                        ZeroA                                                      ; Enqueu an intial sound
                        ld          (SoundFxToEnqueue),a                           ; .
                        im	2    
                        ; enable Interrupts
                       ei
SoundLoop:              ld          a,5
                        ld          a,(DELTA)
                        xor         $20
                        or          $0F
                        ld          (DELTA),a
                        call        SetBorder
.UpdateEventCounter:    ld          hl,(SoundTrigger)                               ; this counter just says
                        dec         hl                                              ; every 65536 cycles update speed and 
                        ld          (SoundTrigger),hl                               ; trigger sound fx 0
                        ld          a,h
                        or          l
                        jr          nz,.SkipTrigger
.WriteSound:            ZeroA                                                       ; sound fx 0
                        ld          (SoundFxToEnqueue),a                            ;
                        ld          a,(DELTA)                                       ; If speed = 40 
                        cp          40                                              ; reset it back to 20
                        jr          z,.ResetDelta                                   ; else speed ++
                        inc         a                                               ; .
                        ld          (DELTA),a                                       ; .
                        jr          SoundLoop                                       ; .
.ResetDelta:            ld          a,20                                            ; .
                        ld          (DELTA),a                                       ; .
                        ld          a,1
                        call        SetBorder
.SkipTrigger:           nop                                                         ; Just hang around for a bit
                        nop                                                         ; and consume some
                        nop                                                         ; cycles
                       ; call        IM2Routine
                        jp          SoundLoop
                        
SetBorder:           ; ld	    bc, 0xFEFE
                     ;  out		(c),a
                        ret
                        
SavedMMU7               db      0
SoundTrigger            dw      0

;Vector table must be bank aligned
                org     $d000
                ;crashes
                display "Vector Start at ",$
                
VectorTable:            
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine
                ;(The last DW could just be a DB as it needs to b 257 bytes but its cleaner for source code)
                display "Vector End at ",$
                org     $d1d1
                display "IR at ",$
                
IM2Routine:     push    af,,bc,,de,,hl,,ix,,iy
                ex      af,af'
                exx
                push    af,,bc,,de,,hl
                GetNextReg  MMU_SLOT_7_REGISTER
                ld      (SavedMMU7),a
                MMUSelectSound
                ; This is a self modifying code address to change the
                ; actual sound vector if we are doing special music
                ; e.g. intro or docking
IM2SoundHandler:call    PlayDanube       ; this does the work
.DoneInterrupt: ld      a,(SavedMMU7)               ; now restore up post interrupt
                nextreg MMU_SLOT_7_REGISTER,a       ; Restore MMU7
                pop    af,,bc,,de,,hl
                ex      af,af'
                exx
                pop     af,,bc,,de,,hl,,ix,,iy
.IMFinishup:    ei
                reti

                
IM2RoutineSFX:     push    af,,bc,,de,,hl,,ix,,iy          ; we arn't using alternate registers in this test code
                GetNextReg  MMU_SLOT_7_REGISTER         ; get current MMU and save it
                ld      (SavedMMU7),a                   ; set MMU7 to sound bank
                MMUSelectSound
                ld      a,(DELTA)                       ; if the speed has changed
                ld      hl,LAST_DELTA                   ; then we change the engine sound
                cp      (hl)                            ; .
.SpeedChange:   call      nz, UpdateEngineSound         ; .
                ; NOTE play then equeue simplifies ligic, more chance slot free
.NoDec:         ld      a,(SoundFxToEnqueue)            ; Check for new sound 
                cp      $FF                             ; FF means no sound to process
                call    nz,EnqueSound                   ;. else add it to a channel
.NoNewSound:    ld      hl,SoundChannelSeq              ; Now check all the sound channels
                ld      b,8                             ; channel 0 is ring fenced for engines
.ResetLoop:     ld      a,(hl)                          ; we only update channels
                cp      $FF                             ; where the sequence nbr is loaded with a non $FF (ie. active)
                jr      z,.NextCounter                  ; .
                ld      a,8                             ; so we have something to play 
                sub     a,b                             ; so a = 8 - b which is actual channel number
                push    bc,,hl                          ; save counter and hl pointer
                call    PlaySound                       ; play sound
                pop     bc,,hl                          ; restore state so de = correct timer & hl = correct channel, b = coutner
; If it went negative new sound update
.NextCounter    inc     hl                              ; continue loop
                djnz    .ResetLoop
.DoneInterrupt: ld      a,(SavedMMU7)                   ; Restore MMU7 
                nextreg MMU_SLOT_7_REGISTER,a       
                pop     af,,bc,,de,,hl,,ix,,iy          ; get back the registers
                ei
              ; ret
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
    