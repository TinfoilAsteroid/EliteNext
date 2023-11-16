    DEVICE ZXSPECTRUMNEXT
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    DEFINE  DOUBLEBUFFER 1
    DEFINE  LATECLIPPING 1
    DEFINE  SIMPLEWARP   1
    ;DEFINE DEBUGCIRCLE1 1
    ;DEFINE DEBUGCIRCLE2 1 
    ;DEFINE DEBUGCIRCLE3 1 
    ;DEFINE DEBUGCIRCLE4 1 
    ;DEFINE DEBUGCIRCLE5 1 
    ;DEFINE DEBUGCIRCLE6 1 
    ;DEFINE  DEBUGPLANET 1
    ;DEFINE  DEBUGPLANETCIRCLE 1
    ;DEFINE  MERIDANLINEDEBUG 1
    DEFINE  PLANETSARESOLID 1
    ;DEFINE DEBUG_LL122_DIRECT 1 ; PASS
    ;DEFINE DEBUG_LL121_DIRECT 1 ; PASS
    ;DEFINE DEBUG_LL129_DIRECT 1 ; PASS
    ;DEFINE DEBUG_LL120_DIRECT 1 ; PASS
    ;DEFINE DEBUG_LL123_DIRECT 1 ; PASS
    ;DEFINE DEBUG_LL118_DIRECT 1
    ;DEFINE DEBUG_LL128_DIRECT
;                  DEFINE DEBUG_LL123_DIRECT 1
;                  DEFINE DEBUG_LL118_DIRECT 1
;                  DEFINE DEBUG_LL28_6502
                  ;DEFINE DEBUG_LL145_6502 1
;                DEFINE DEBUG_LL129
 ;               DEFINE DEBUG_LL120 1
           ; DEFINE DEBUGCLIP 1
    ;DEFINE SKIPATTRACTMUSIC 1
    ;DEFINE SKIPATTRACTGRAPHICS 1
    ;DEFINE  SKIPATTRACT 1
    ;DEFINE  LOGDIVIDEDEBUG 1
    ; DEFINE  BLINEDEBUG 1
    ;DEFINE  TESTMERIDIAN 1
    ;DEFINE  CLIPVersion3 1
    ;DEFINE  LOGMATHS     1
    ;DEFINE  DIAGSPRITES 1
;    DEFINE   SKIPATTRACT
    ; DEFINE DEBUGMISSILETEST 1
    ; DEFINE DEBUGLINEDRAW 1
     DEFINE  LASER_V2    1
 CSPECTMAP eliteN.map
 OPT --zxnext=cspect --syntax=a --reversepop
                DEFINE  SOUNDPACE 3
;                DEFINE  ENABLE_SOUND 1
               DEFINE     MAIN_INTERRUPTENABLE 1
;               DEFINE INTERRUPT_BLOCKER 1
DEBUGSEGSIZE   equ 1
DEBUGLOGSUMMARY equ 1
;DEBUGLOGDETAIL equ 1

;----------------------------------------------------------------------------------------------------------------------------------
; Game Defines
ScreenLocal      EQU 0
ScreenGalactic   EQU ScreenLocal + 1
ScreenMarket     EQU ScreenGalactic + 1
ScreenMarketDsp  EQU ScreenMarket + 1
ScreenStatus     EQU ScreenMarketDsp + 1
ScreenInvent     EQU ScreenStatus + 1
ScreenPlanet     EQU ScreenInvent + 1
ScreenEquip      EQU ScreenPlanet + 1
ScreenLaunch     EQU ScreenEquip + 1
ScreenFront      EQU ScreenLaunch + 1
ScreenAft        EQU ScreenFront+1
ScreenLeft       EQU ScreenAft+1
ScreenRight      EQU ScreenLeft+1
ScreenDocking    EQU ScreenRight+1
ScreenHyperspace EQU ScreenDocking+1
;----------------------------------------------------------------------------------------------------------------------------------
; Colour Defines
    INCLUDE "./Hardware/L2ColourDefines.asm"
    INCLUDE "./Hardware/L1ColourDefines.asm"
;----------------------------------------------------------------------------------------------------------------------------------
; Total screen list
; Local Chart
; Galactic Chart
; Market Prices
; Inventory
; Comander status
; System Data
; Mission Briefing
; missio completion
; Docked  Menu (only place otehr than pause you can load and save)
; Pause Menu (only place you can load from )
; byint and selling equipment
; bying and selling stock

                        INCLUDE "./Hardware/register_defines.asm"
                        INCLUDE "./Layer2Graphics/layer2_defines.asm"
                        INCLUDE	"./Hardware/memory_bank_defines.asm"
                        INCLUDE "./Hardware/screen_equates.asm"
                        INCLUDE "./Data/ShipModelEquates.asm"
                        INCLUDE "./Menus/clear_screen_inline_no_double_buffer.asm"	
                        INCLUDE "./Macros/graphicsMacros.asm"
                        INCLUDE "./Macros/callMacros.asm"
                        INCLUDE "./Macros/carryFlagMacros.asm"
                        INCLUDE "./Macros/CopyByteMacros.asm"
                        INCLUDE "./Macros/ldCopyMacros.asm"
                        INCLUDE "./Macros/ldIndexedMacros.asm"
                        INCLUDE "./Macros/jumpMacros.asm"
                        INCLUDE "./Macros/MathsMacros.asm"
                        INCLUDE "./Macros/MMUMacros.asm"
                        INCLUDE "./Macros/NegateMacros.asm"
                        INCLUDE "./Macros/returnMacros.asm"
                        INCLUDE "./Macros/ShiftMacros.asm"
                        INCLUDE "./Macros/signBitMacros.asm"
                        INCLUDE "./Macros/KeyboardMacros.asm"
                        INCLUDE "./Universe/UniverseMacros/asm_linedraw.asm"
                        INCLUDE "./Universe/UniverseMacros/UniverseVarsDefineMacro.asm"
                        INCLUDE "./Tables/message_queue_macros.asm"
                        INCLUDE "./Variables/general_variables_macros.asm"
                        INCLUDE "./Variables/UniverseSlot_macros.asm"
                        
                        INCLUDE "./Data/ShipIdEquates.asm"
                        

    IFNDEF  LASER_V2
UpdateLaserCountersold: MACRO
                        JumpIfMemZero CurrLaserPulseOnCount,   .SkipPulseOn     ; if beam on count > 0 then beam on count --
                        dec     a                                               ; .
                        ld      (CurrLaserPulseOnCount),a                       ; .
.SkipPulseOn:           JumpIfAIsNotZero  .SkipRestCounter                      ;    if beam on = 0 then                        
                        ld      a,(CurrLaserPulseOffCount)                      ;       if beam off > 0 then  beam off --
                        JumpIfMemZero CurrLaserPulseOffCount, .SkipPulseOff     ;       .
                        dec     a                                               ;       .
                        ld      (CurrLaserPulseOffCount),a                      ;       .
.SkipPulseOff:          JumpIfAIsNotZero  .SkipRestCounter                      ;       if beam off = 0
                        JumpIfMemZero CurrLaserPulseRestCount, .ZeroRateCounter ;
                        dec     a
                        ld      (CurrLaserPulseRestCount),a
                        jr      nz,.SkipRestCounter
.ZeroRateCounter:       ld      (CurrLaserPulseRateCount),a
.SkipRestCounter:       
                        ENDM
    ENDIF 
MessageAt:              MACRO   x,y,message
                        MMUSelectLayer1
                        ld      d,y
                        ld      e,x
                        ld      hl,message
                        call    l1_print_at_wrap
                        ENDM
                        
SetBorder:              MACRO   value 
                        MMUSelectLayer1
                        ld          a,value
                        call        l1_set_border
                        ENDM
                        
charactersetaddr		equ 15360
STEPDEBUG               equ 1

TopOfStack              equ $5CCB ;$6100

                        ORG $5DCB;      $6200
EliteNextStartup:       di
.InitiliseFileIO:       call        GetDefaultDrive
.InitialiseClockSpeed:  nextreg     TURBO_MODE_REGISTER,Speed_28MHZ
.InitialiseLayerOrder:  
                        DISPLAY "Starting Assembly At ", EliteNextStartup
                        ; "STARTUP"
                        ; Make sure  rom is in page 0 during load
                        MMUSelectSpriteBank
                        call		init_sprites
                        MMUSelectLayer2
                        call        asm_disable_l2_readwrite
                        MMUSelectROMS
.InitialisePeripherals: nextreg     PERIPHERAL_2_REGISTER, AUDIO_CHIPMODE_AY ; Enable Turbo Sound
                        nextreg     PERIPHERAL_3_REGISTER, DISABLE_RAM_IO_CONTENTION | ENABLE_TURBO_SOUND | INTERNAL_SPEAKER_ENABLE
                        nextreg     PERIPHERAL_4_REGISTER, %00000000
                        nextreg     ULA_CONTROL_REGISTER,  %00010000                ; set up ULA CONRTROL may need to change bit 0 at least, but bit 4 is separate extended keys from main matrix
                        MMUSelectSound
                        call        InitAudio
.InitialiseInterrupts:  ld	        a,VectorTable>>8
                        ld	        i,a						                        ; im2 table will be at address 0xa000
                        nextreg     LINE_INTERRUPT_CONTROL_REGISTER,%00000110       ; Video interrup on 
                        nextreg     LINE_INTERRUPT_VALUE_LSB_REGISTER,0   ; lasta line..                        
                        im	2                        
.GenerateDefaultCmdr:   MMUSelectCommander
                        call		defaultCommander
                        call        saveCommander
                        MMUSelectLayer1
                        call		l1_cls
                        ld			a,7
                        call		l1_attr_cls_to_a
                        SetBorder   $FF
.InitialiseL2:          MMUSelectLayer2
                        call 		l2_initialise
.InitialisingMessage:   MessageAt   0,0,InitialiseMessage
                        SetBorder   $01
                        MessageAt   0,8,LoadingSpritesMessage
                        ZeroA
                        ld          (LoadCounter),a
.StreamSpriteData:      MMUSelectSpriteBank
                        call        load_pattern_files
                        MMUSelectKeyboard
                        call        init_keyboard
.PostDiag:              ClearForceTransition
                        SetBorder   $04
                        MMUSelectSpriteBank
                        call        sprite_diagnostic
                        SetBorder   $05
.PostDiag2:             MMUSelectKeyboard
                        call        WaitForAnyKey                      
                        MMUSelectSpriteBank
                        call        sprite_diagnostic_clear                     
TidyDEBUG:              ld          a,16
                        ld          (TidyCounter),a
TestText:               xor			a
                        ld      (JSTX),a
DEBUGCODE:              ClearSafeZone ; just set in open space so compas treacks su n
                        SetBorder   $06
TRIANGLEDIAGNOSTICS:   ;break
                       ;ld          c,10
                       ;ld          e,20
                       ;ld          l,120
                       ;MMUSelectLayer2
                       ;call        l2_draw_horz_saved
                       ;break
                       ;ld          c,20
                       ;ld          e,120
                       ;ld          l,20
                       ;call        l2_draw_horz_saved
                       ;break
                       ;ld          hl,120
                       ;call        l2_drawHorzClipY
                       ;break
                       ;ld          hl,30
                       ;ld          de,50
                       ;exx
                       ;ld          hl,40
                       ;ld          de,60
                       ;ld          ix,SaveArrayS2
                       ;ld          a,$FF
                       ;call        Layer2_Save_ClipY_Line ; Why was is very slow?
;                        break
;                        ld          hl,100; x1 64 hl'
;                        ld          de,150; x2 96 de'
;                        ld          bc,120; x3 78 bc'
;                        exx
;                        ld          hl,50  ;y1 32 hl
;                        ld          de,75  ;y2 4B de
;                        ld          bc,90  ;y3 5A bc
;                        MMUSelectLayer2
;                        call        l2_draw_fillclip_tri
;TRIANGLEDIAGDONE:       break          0136 0153 FF81 FF98  310, 339  = -127, -104 dx 437, 443  (218 221)  91,117
                         ;break
                         MMUSelectUniverseN  0
                         MMUSelectLayer2

                  IFDEF DEBUG_LL122_DIRECT
                        call    Debug_LL122_6502
                  ENDIF

                  IFDEF DEBUG_LL121_DIRECT   
                        call Debug_LL121_6502
                  ENDIF
                        
                  
                  IFDEF DEBUG_LL129_DIRECT
                        call Debug_LL129_6502
                  ENDIF
                  
                  IFDEF DEBUG_LL120_DIRECT
                        call Debug_LL120_6502
                  ENDIF
                        
                  IFDEF DEBUG_LL123_DIRECT
                        call Debug_LL123_6502
                  ENDIF

                  IFDEF DEBUG_LL118_DIRECT
                        call Debug_LL118_6502
                  ENDIF
                  
                  IFDEF DEBUG_LL28_6502
                        call Debug_LL28_6502
                  ENDIF
                  
                  IFDEF DEBUG_LL145_6502
                        ;break
                        call Debug_LL145_6502
                  ENDIF
                        
                  
                IFDEF DEBUG_LL129                         
                        ld      a,240       :ld      (XX12p2),a ; Gradient
                        ld      a,$FF       :ld      (XX12p3),a ; Slope
                        ld      hl,-50      :ld      (SRvarPair),hl
                        call    LL129_6502  ; Should be Q = 240, A = +ve SR = 50 >> PASS
                        ;break
                        ld      a,240       :ld      (XX12p2),a ; Gradient
                        ld      a,0         :ld      (XX12p3),a ; Slope
                        ld      hl,-50      :ld      (SRvarPair),hl
                        call    LL129_6502  ; Should be Q = 240, A = -ve SR = 50 >> PASS
                        ;break
                        ld      a,240       :ld      (XX12p2),a ; Gradient
                        ld      a,$FF       :ld      (XX12p3),a ; Slope
                        ld      hl, 150     :ld      (SRvarPair),hl
                        call    LL129_6502  ; Should be Q = 240, A = -ve SR = 150 >> PASS
                        ld      a,140       :ld      (XX12p2),a ; Gradient
                        ld      a,$0        :ld      (XX12p3),a ; Slope
                        ld      hl,50       :ld      (SRvarPair),hl
                        call    LL129_6502  ; Should be Q = 140, A = +ve SR = 50 >> PASS
                ENDIF
                IFDEF DEBUG_LL120
                        ;break
                        ld      a,0         :ld      (Tvar),a   ; slope +ve so multiply
                        ld      a,$FF       :ld      (Svar),a   ; S var -ve
                        ld      hl,-10      :ld      (XX1510),hl; x1_lo -ve
                        ld      a,168       :ld      (XX12p2),a ; Gradient 
                        ld      a,$FF       :ld      (XX12p3),a ; slope direction    
                        ; LL129 shoud be q = 168, a +ve SR 10 >> PASS 
                        call    LL120_6502  ; Should be -ve 10 * 168  so xy -15   >> FAIL
                        ;break
                        ld      a,$FF       :ld      (Tvar),a   ; slope -ve so divide
                        ld      a,$FF       :ld      (Svar),a   ; S var -ve
                        ld      hl,-10      :ld      (XX1510),hl; x1_lo -ve
                        ld      a,168       :ld      (XX12p2),a ; Gradient 
                        ld      a,$FF       :ld      (XX12p3),a ; slope direction    
                        ; LL129 shoud be q = 168, a +ve SR 10 >> PASS 
                        call    LL120_6502  ; Should be -ve 10 / 168  so xy -6 >> PASS
                ENDIF
            IFDEF  DEBUGCLIP
                        ;break
                        MMUSelectUniverseN 0
                        MMUSelectLayer2
                        call   l2_cls_upper_two_thirds
                        ld      hl,PlotTestData
                        ld      b,32
.testLoop:              push    bc
                        push    hl
                        ld      de,x1
                        ld      bc, 8
                        pop     hl
                        ldir
                        ;break
                        push    hl
                        call    l2_draw_6502_line;l2_draw_elite_line
                        ;break
                        ;MMUSelectKeyboard
                        ;call    WaitForAnyKey
                        pop     hl
                        pop     bc
                        djnz    .testLoop
                        ;break
                        jp      InitialiseGalaxies
                      ;  ld      hl,$FFF7 : ld (x1),hl : ld hl,$0009 : ld (y1),hl : ld hl,$000F : ld (x2),hl : ld hl,$FFEF : ld (y2),hl : call l2_draw_elite_line
                      ;  ld      hl,259   : ld (x1),hl : ld hl,35    : ld (y1),hl : ld hl,250   : ld (x2),hl : ld hl,-12   : ld (y2),hl : call l2_draw_elite_line
                         ld      hl,237   : ld (x1),hl : ld hl,258   : ld (y1),hl : ld hl,353   : ld (x2),hl : ld hl,237   : ld (y2),hl : call l2_draw_elite_line
                      ;  ld      hl,6     : ld (x1),hl : ld hl,-65   : ld (y1),hl : ld hl,-15   : ld (x2),hl : ld hl,7     : ld (y2),hl : call l2_draw_elite_line

PlotTestData:  ; dw  281 ,   60, 252 ,   90  ; pass
               ; dw   -9 ,    9,  16 ,  -17  ; pass
                dw -10  ,  -10,  50 ,   50 ;0:0:50:50   pass
                dw -10  ,    0,  50 ,   50 ;0:8:50:50   fail load x1 y1 as 0,0
                dw -20  ,    0,  50 ,   50 ;0:14:50:50  fail load x1 y1 as 0,0
                dw  -5  ,  -10,  50 ,   50 ;4.5:0:50:50 fail load x1 y1 as 0,0
               
                dw -10  ,  -10,  50 ,   50
                dw  10  ,    0,  50 ,   50
                dw   0  ,    0,  50 ,   50
                dw   0  ,   -5,  50 ,   50
                
                dw  259 ,   35, 250 ,  -12
                dw  237 ,  258, 353 ,  237
                dw    6 ,  -65, -15 ,    7
                dw  280 ,   90, 300 ,   70
                dw  -80 ,   90, -20 ,   70
                dw  -10 ,  120,  10 ,  145
                dw  120 ,  -10,  45 ,   10
                dw  220 , -100,   5 ,   80
                dw  220 ,  120,  35 ,  190
                dw  235 ,  120,  20 ,  190
                dw  -50 ,   60, 145 ,   70
                dw  150 ,   60, 345 ,   70
                dw  140 ,   90, 240 ,   70
                dw  163 ,  256, 116 ,  173
                dw   83 ,  184,  55 ,  192
                dw   68 ,  192,  54 ,  103
                dw  125 , 3937, 127 ,   41
                dw  125 , 3937,  81 ,  111
                dw  310 ,  339,  81 , 3992
                dw  -37 , 4096,  38 ,  560
                dw  283 , 101 ,  65 ,  163
                dw  283 , 101 , 146 ,   78 
                dw  146 , 78  ,   3 ,   93 
                dw  3   , 93  ,  65 ,  163
                dw  -127, 346 ,   3 ,   93 
                dw  44	, 351 , -43 ,  126
                dw  92	, 54  , 144 ,  -14
                dw  144	, -14 , 164 ,    4
                dw  95	, 40  , 159 ,   31 
                dw  159	, 31  , 161 ,   51 



/*007D FF61 FF81 006F
007D FF61 017F 0029
0096 FF61 FF81 004D
0096 FF61 017F 004D
017F 004F 0072 015F
0072 015F FF81 004D
0019 002B 00F6 002B
00F6 002B 00F6 006F
00F6 006F 0019 006F
0019 006F 0019 002B
005A 0079 0095 0027
0096 0027 00AC 0028
0051 005D 00A2 0040
00A2 0040 00AA 0058
005F 0056 00A3 004A
00A3 004A 00A6 005F
0073 0070 007D 0072
007D 0072 007D 0075
006C 0083 0076 0088
0076 0072 007D 0074
006C 0083 0076 0088
0076 0088 0074 008B*/


/*;;
28 01 79 00 5a 01 8f 00 28 01 79 00 2f 01 3a 00
2f 01 3a 00 5f 01 53 00 5f 01 53 00 5a 01 8f 00
5a 01 8f 00 14 01 a1 00 28 01 79 00 14 01 a1 00
28 01 79 00 ed 00 53 00 ed 00 53 00 2F 01 3a 00
14 01 a1 00 e3 00 78 00 ed 00 53 00 e3 00 78 00
47 01 6d 00 40 01 5f 00 40 01 5f 00 44 01 5d 00
44 01 5d 00 4b 01 6a 00 4b 01 6a 00 47 01 6d 00
42 01 5d 00 47 01 5d 00 47 01 5d 00 48 01 6d 00
48 01 6d 00 43 01 6d 00 47 01 6d 00 43 01 6c 00
47 01 6d 00 42 01 6c 00 14 00 dc ff 12 00 e1 ff*/

                         MMUSelectKeyboard
                         call        WaitForAnyKey    
            ELSE
                         DISPLAY "Not debugging clip code"            
            ENDIF
            IFDEF LOGDIVIDEDEBUG
                        break
                        MMUSelectMathsTables
                        ld      a,4
                        ld      (varQTEST),a
                        ld      a,1
                        ld      (varATEST),a
                        ld      b,250
                        ld      hl, outputbuffer
.LoopTest:              push    bc,,hl
                        ld      a,(varQTEST)
                        ld      (varQ),a
                        ld      a,(varATEST)
                        call    Requ256mulAdivQ_Log
                        pop     bc,,hl
                        ld      (hl),a
                        inc     hl
                        ld      a,(varATEST)
                        inc     a
                        ld      (varATEST),a
                        ld      a,(varQTEST)
                        ld      (varQTEST),a
                        djnz    .LoopTest
                        break
                        
varATEST    DB  0
varQTEST    DB  0                        
                        
                        
                        
outputbuffer DS 256    
            ENDIF
            IFDEF DEBUGCIRCLE1
                        break
                        ld      hl,128
                        ld      de, 64
                        ld      c,20
                        ld      b,$59
                        MMUSelectLayer2
                        call    l2_draw_clipped_circle_filled
            ENDIF
            IFDEF DEBUGCIRCLE2
                        break
                        ld      hl,128
                        ld      de, 64
                        ld      c,200
                        ld      b,$49
                        MMUSelectLayer2
                        call    l2_draw_clipped_circle_filled
                        break
            ENDIF

            IFDEF DEBUGCIRCLE3
                        break
                        ld      hl,128
                        ld      de, 64
                        ld      c,130
                        ld      b,$49
                        MMUSelectLayer2
                        call    l2_draw_clipped_circle_filled
                        break
            ENDIF

            IFDEF DEBUGCIRCLE4
                        break
                        ld      hl,320
                        ld      de, 128
                        ld      c,10
                        ld      b,$49
                        MMUSelectLayer2
                        call    l2_draw_clipped_circle_filled
                        break
            ENDIF            
            
            IFDEF DEBUGPLANET
DebugPlanetCode:        MMUSelectPlanet
                        call    CreatePlanet
                        ld      a,0
                        ld      (P_BnKzsgn),a
                        ld      (P_BnKxsgn),a
                        ld      (P_BnKysgn),a
                        ld      hl,$0200
                        ld      (P_BnKzlo),hl
                        ld      hl,$00000
                        ld      (P_BnKxlo),hl
                        ld      (P_BnKylo),hl
                        ld      a,127
                        ld      (UBnKRotXCounter),a
                        ld      (UBnKRotZCounter),a
                        break
.PlanetDebugLoop:       MMUSelectPlanet
                        call    PlanetDraw
                        call    ApplyPlanetRollAndPitch
                        call    P_NormaliseRotMat
                        ;call    ApplyPlanetPitch
                        
                        ;MMUSelectKeyboard
                        ;call        WaitForAnyKey 
                        break                        
                        MMUSelectLayer2
                        call		l2_cls
                        jp          .PlanetDebugLoop
            ENDIF

            IFDEF DEBUGPLANETCIRCLE
DebugPlanetCode:        MMUSelectPlanet
                        call    CreatePlanet
                        ld      a,0
                        ld      (P_BnKzsgn),a
                        ld      (P_BnKxsgn),a
                        ld      (P_BnKysgn),a
                        ld      hl,$0200
                        ld      (P_BnKzlo),hl
                        ld      hl,$00000
                        ld      (P_BnKxlo),hl
                        ld      (P_BnKylo),hl
                        ld      a,127
                        ld      (UBnKRotXCounter),a
                        ld      (UBnKRotZCounter),a
                        break
.PlanetDebugLoop:       MMUSelectPlanet
                        call    PlanetDraw
                        call    ApplyPlanetRollAndPitch
                        call    P_NormaliseRotMat
                        ;call    ApplyPlanetPitch
                        
                        ;MMUSelectKeyboard
                        ;call        WaitForAnyKey 
                        break                        
                        MMUSelectLayer2
                        call		l2_cls
                        jp          .PlanetDebugLoop
            ENDIF
            
            IFDEF DEBUGLINEDRAW
RenderDiagnostics:      MMUSelectLayer2
                        ld      h, 0
                        ld      l, 0
                        ld      d,0
                        ld      e,255
                        ld      ixl,16
                        ld      a,$C5
                        ld      (line_gfx_colour),a
                        ; draw a grid
.horizontalLoop:        push    hl,,de,,ix
                        call    LineHLtoDE
                        pop     hl,,de,,ix
                        ld      a,h
                        add     8
                        ld      h,a
                        ld      d,a
                        dec     ixl
                        jr      nz,.horizontalLoop
.verticalGrid:          ld      h, 0
                        ld      l, 0
                        ld      d, 127
                        ld      e,0
                        ld  ixl,32
                        ld      a,$C6
                        ld      (line_gfx_colour),a
.verticalLoop:          push    hl,,de,,ix
                        call    LineHLtoDE
                        pop     hl,,de,,ix
                        ld      a,l
                        add     8
                        ld      l,a
                        ld      e,a
                        dec     ixl
                        jr      nz,.verticalLoop
                        ld      a,$A6
                        ld      (line_gfx_colour),a
                        ld      hl,0
                        ld      de,$7FFF
                        call    LineHLtoDE
                        ld      hl,$00FF
                        ld      de,$7F00
                        call    LineHLtoDE
                        ld      a,0
                        MMUSelectUniverseA
                        ; CLip -10,-10 to 20,30
                        ld      a,$56
                        ld      (line_gfx_colour),a
                        ;break
.LineTest1:             ld      hl, DrawTestDataLine1
                        call    DrawClippedLineDebug
.LineTest2:             ld      hl, DrawTestDataLine2
                        call    DrawClippedLineDebug
.LineTest3:             ld      hl, DrawTestDataLine3
                        call    DrawClippedLineDebug
.LineTest4:             ld      hl, DrawTestDataLine4
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine5
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine6
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine7
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine8
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine9
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine10
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine11
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine12
                        call    DrawClippedLineDebug
                        ld      a,$A8
                        ld      (line_gfx_colour),a                        
                        ld      hl, DrawTestDataLine13
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine14
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine15
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine16
                        call    DrawClippedLineDebug
                        ;break
                        ; draw diagonals on screen tL br, tr bl
                        ; draw diagonals on screen bl tr, br tl
                        ; draw clipped horzontals left clip from -1000 -10 to 50
                        ; draw clipped horzontals right clip from 200 to 260 to +1000
                        ; draw clipped horzontals both clip from -1000 -10 to 260 to 1000
                        ; draw clipped horzontals top clip from -1000 -10 to 50
                        ; draw clipped horzontals bottom clip from 200 to 260 to +1000
                        ; draw clipped horzontals both clip from -1000 -10 to 260 to 1000
                        ; draw diagonal left clip
                        ; draw diagonal right clip
                        ; draw diagonal top clip
                        ; draw diagonal bottom clip
                        ; draw diagonal left top clip
                        ; draw diagonal right top clip
                        ; draw diagonal left bottom clip
                        ; draw diagonal left bottom clip
                        ; draw diagnoal left clip to right clip
                        ; draw diagnoal top clip to bottom clip
                        ; draw diagnoal left top clip to right clip
                        ; flip right to left
                        ; flip bottom to top
.DebugPause:           ; jp      .DebugPause
                        jp      InitialiseGalaxies

DrawTestDataLine1:      DW      -10,   -10,   20,   30
DrawTestDataLine2:      DW      265,   -10,  235,   30
DrawTestDataLine3:      DW      -10,   -10,   30,   20
DrawTestDataLine4:      DW      265,   -10,  225,   20
DrawTestDataLine5:      DW    -1000,   -10,  127,   60
DrawTestDataLine6:      DW     1000,   -10,  128,   60 
DrawTestDataLine7:      DW    -1000,   138,  127,   60
DrawTestDataLine8:      DW     1000,   138,  128,   60 
DrawTestDataLine9:      DW      -10, -1000,  127,   60
DrawTestDataLine10:     DW      265, -1000,  128,   60 
DrawTestDataLine11:     DW      -10,  1138,  127,   60
DrawTestDataLine12:     DW      265,  1138,  128,   60 
DrawTestDataLine13:     DW      -10, -1000,  127,  360
DrawTestDataLine14:     DW      265, -1000,  128,  360 
DrawTestDataLine15:     DW      -10,  1138,  127, -360
DrawTestDataLine16:     DW      265,  1138,  128, -360 
                                                 

DrawClippedLineDebug:   ld      bc,8
                        ld      de,UbnkPreClipX1
                        ldir
                        call    ClipLine
                        ld      a,(UBnkNewY1)
                        ld      h,a
                        ld      a,(UBnkNewX1)
                        ld      l,a
                        ld      a,(UBnkNewY2)
                        ld      d,a
                        ld      a,(UBnkNewX2)
                        ld      e,a
                        call    LineHLtoDE
                        ret

                ENDIF
;.ClearLayer2Buffers:    DoubleBufferIfPossible
;                        DoubleBufferIfPossible
; Set up all 8 galaxies, 7later this will be pre built and loaded into memory from files            
                
                IFDEF LOGDIVIDEDEBUG
                   DISPLAY "DEBUG: SKIPPING INIT TO SAVE MEMORY FOR LOG DIVIDE DEBUG TEST"
                ELSE
                        SetBorder   $07
InitialiseGalaxies:     MessageAt   0,24,InitialisingGalaxies
                        ;break
                        call		ResetUniv                       ; Reset ship data
                        call        ResetGalaxy                     ; Reset each galaxy copying in code
                        call        SeedAllGalaxies
                        MMUSelectSpriteBank
                        call        sprite_cls_all
                        MMUSelectLayer1
                        call		l1_cls
                        SetBorder   $00
                ENDIF
                IFDEF SKIPATTRACT
                        DISPLAY "INITGALAXIES SKIP ATTRACT"
                        jp DefaultCommander
                ELSE
                        DISPLAY "INITGALAXIES ATTRACT ENABLED"
StartAttractMode:       di                                          ; we are changing interrupts
                        MMUSelectSound
                        call        InitAudioMusic
                        ld          hl,AttractInterrrupt
                        ld          (IM2SoundHandler+1),hl
                        call        AttractModeInit
                        ei
                        ;break
                        break
                        call        AttractModeMain                 ; now drive attact mode keyboard scan
                        di                                          ; set up for main 
                        ld          hl,SoundInterrupt               ; sound handler
                        ld          (IM2SoundHandler+1),hl
                        MMUSelectSound
                        call        InitAudio                       ; jsut re-init all audio for now rather than sound off
                        IFDEF MAIN_INTERRUPTENABLE
                            DISPLAY "Main Interrupt Enabled"
                            ei 
                        ELSE
                            DISPLAY "Main Interrupt Disabled"
                        ENDIF
                        JumpIfAIsZero  SkipDefaultCommander
                ENDIF
DefaultCommander:       MMUSelectCommander
                        call		defaultCommander
                        jp          InitialiseMainLoop:
SkipDefaultCommander:           
                        ; This bit needs to MMU Selet exdos
                        ; bring up a browser for saves
                        ; load saves it
                        ; switch back to maths MMU
;                        call    FindNextFreeSlotInA
;                        ld      b,a
;                        ld      a,13 ;Coriolis station
;                        call    InitialiseShipAUnivB
;                        xor     a
InitialiseMainLoop:     call    InitMainLoop
;..MAIN GAME LOOP..................................................................................................................
; MACRO BLOCKS.....................................................................................................................
;.. Check if keyboard scanning is allowed by screen. If this is set then skip all keyboard and AI..................................



; if beam on count > 0
;    then beam on count --
;         if beam on count = 0 
;            then beam off count = beam off
; if beam off > 0 
;    then beam off --
;         if beam off = 0 and pulse rate count = max count
;            then pulse rest count = pulse rest
; if pulse rest > 0 then pulse rest --
;    if pulse rest = 0
;       then pulse rate count = 0

          
; counter logic
;    if beam on count > 0 then beam on count --
;    if beam on = 0 then  
;       if beam off count >0 then beam off count --
;       if beam off count = 0 them
;          if pulse rest count > 0 then pulse rest count --
;             if reset count = 0 then pulse rate count = 0
; shoting logic
;    if pulse on count is 0 and pulse off count is 0 and rest count is 0                        
;       then  if fire pressed is OK
;                if not beam type
;                   then pulse rate count ++
;                        if pulse rate count < pulse max count
;                           then pulse on count = pulse on time
;                                pulse off count = pulse off time
;                                pulse rest count = pulse rest time
;                           else pulse rest count = pulse rest time
;                                pulse rate count, pulse on count, pulse off count = 0
;                   else pulse on count = $FF
;                        pulse off time , rest time = 0

;..................................................................................................................................
                        INCLUDE "./GameEngine/MainLoop.asm"
                        INCLUDE "./GameEngine/SpawnObject.asm"
;..................................................................................................................................
;..Process A ship..................................................................................................................
; Apply Damage b to ship based on shield value of a
; returns a with new shield value
                        INCLUDE "./GameEngine/DamagePlayer.asm"
;..Update Universe Objects.........................................................................................................
                        INCLUDE "./GameEngine/UpdateUniverseObjects.asm"
;..................................................................................................................................                        
;; TODODrawForwardSun:         MMUSelectSun
;; TODO                        ld      a,(SunKShipType)
;; TODO.ProcessBody:           cp      129
;; TODO                        jr      nz,.ProcessPlanet
;; TODO.ProcessSun:            call    ProcessSun
;; TODO
;; TODOProcessSun:             call    CheckSunDistance
;; TODO
;; TODO                        ret
;; TODO.ProcessPlanet:         call    ProcessPlanet
;; TODO                        ret                        
;..................................................................................................................................                        
 

;;;ProcessUnivShip:        call    CheckVisible               ; Will check for negative Z and skip (how do we deal with read and side views? perhaps minsky transformation handles that?)
;;;                        ret     c
;;;                        ld      a,(UbnkDrawAsDot)
;;;                        and     a
;;;                        jr      z,.CarryOnWithDraw
;;;.itsJustADot:           ld      bc,(UBnkNodeArray)          ; if its at dot range
;;;                        ld      a,$FF                       ; just draw a pixel
;;;                        MMUSelectLayer2                     ; then go to update radar
;;;                        call    l2_plot_pixel               ; 
;;;                        ClearCarryFlag
;;;                        ret
;;;.ProcessShipNodes:      call    ProcessShip
;;;
;;;call    ProcessNodes ; it hink here we need the star and planet special cases
;;;.DrawShip:              call    CullV2				        ; culling but over aggressive backface assumes all 0 up front TOFIX
;;;                        call    PrepLines                   ; LL72, process lines and clip, ciorrectly processing face visibility now
;;;                        ld      a,(CurrentShipUniv)
;;;                        MMUSelectUniverseA
;;;                        call   DrawLines
;;;                        ClearCarryFlag
;;;                        ret                        

;----------------------------------------------------------------------------------------------------------------------------------
InitialiseMessage       DB "Intialising",0
LoadingSpritesMessage   DB "LoadingSprites",0
InitialisingGalaxies    DB "IntiailisingGalaxies",0
LoadCounter             DB 0
SpriteProgress          DB "*",0
;----------------------------------------------------------------------------------------------------------------------------------

NeedAMessageQueue:

;..................................................................................................................................
                        INCLUDE "./GameEngine/HyperSpaceTimers.asm"



;DisplayTargetAndRange
;DisplayCountDownNumber
;----------------------------------------------------------------------------------------------------------------------------------
TestPauseMode:          ld      a,(GamePaused)
                IFDEF LOGDIVIDEDEBUG
                        DISPLAY "DEBUG: SKIPPING PAUSE MODE TO SAVE MEMORY FOR LOG DIVIDE DEBUG TEST"
                        ret
                ELSE

                        cp      0
                        jr      nz,.TestForResume
.CheckViewMode:         ld      a,(ScreenIndex)                     ; we can only pause if not on screen view
                        ReturnIfAGTENusng       ScreenFront
.CheckPauseKey:         MacroIsKeyPressed c_Pressed_Freeze
                        ret     nz
.PausePressed:          SetAFalse                                  ; doesn't really matter if we were in pause already as resume is a different key
                        ld      (GamePaused),a
                        ret
.TestForResume:         MacroIsKeyPressed c_Pressed_Resume                  ; In pause loop so we can check for resume key
                        ret     nz
.ResumePressed:         xor     a             
                        ld      (GamePaused),a                      ; Resume pressed to reset pause state
                        ret
                ENDIF
TestQuit:               MacroIsKeyPressed c_Pressed_Quit
                        ret
currentDemoShip:        DB      13;$12 ; 13 - corirollis 


GetStationVectorToWork: ld      hl,UBnKxlo
                        ld      de,varVector9ByteWork
                IFDEF LOGDIVIDEDEBUG
                        DISPLAY "DEBUG: SKIPPING GetStationVectorToWork TO SAVE MEMORY FOR LOG DIVIDE DEBUG TEST"
                        ret
                ELSE
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
.CalcNormalToXX15:      ld      hl, (varVector9ByteWork)  ; X
                        ld      de, (varVector9ByteWork+3); Y
                        ld      bc, (varVector9ByteWork+6); Z
                        ld      a,l
                        or      e
                        or      c
                        or      1
                        ld      ixl,a                   ; or all bytes and with 1 so we have at least a 1
                        ld      a,h
                        or      d
                        or      b                       ; or all high bytes but don't worry about 1 as its sorted on low bytes
.MulBy2Loop:            push    bc
                        ld      b,ixl
                        sla     b                       ; Shift ixl left 
                        ld      ixl,b
                        pop     bc
                        rl      a                       ; roll into a
                        jr      c,.TA2                  ; if bit rolled out of rl a then we can't shift any more to the left
                        ShiftHLLeft1                    ; Shift Left X
                        ShiftDELeft1                    ; Shift Left Y
                        ShiftBCLeft1                    ; Shift Left Z
                        jr      .MulBy2Loop              ; no need to do jr nc as the first check looks for high bits across all X Y and Z
.TA2:                   ld      a,(varVector9ByteWork+2); x sign
                        srl     h
                        or      h
                        ld      (XX15VecX),a         ; note this is now a signed highbyte
                        ld      a,(varVector9ByteWork+5); y sign
                        srl     d
                        or      d
                        ld      (XX15VecY),a         ; note this is now a signed highbyte                        
                        ld      a,(varVector9ByteWork+8); y sign
                        srl     b
                        or      b
                        ld      (XX15VecZ),a         ; note this is now a signed highbyte                        
                        call    normaliseXX1596S7 
                        ret                          ; will return with a holding Vector Z
                ENDIF

TidyCounter             DB  0

            INCLUDE "./debugMatrices.asm"


            DISPLAY "TODO: Optimisation"
; Need this table to handle differnet events 
; 1-main loop update - just general updates specfic to that screen that are not galaxy or stars, e.g. update heat, console
; cursor key, joystick press
; cursor key, joystick press
; non cursor keys presses
;
                        INCLUDE "./Tables/ScreenControlTable.asm"

ScreenTransitionForced  DB $FF    
    INCLUDE "./GameEngine/resetUniverse.asm"


;----------------------------------------------------------------------------------------------------------------------------------
                        DISPLAY "TODO: Check collision detection as currently can destroy space station"
                        DISPLAY "TODO: Docking works but bouncing off is wrong for space station"
    
InitialiseCommander:    ld      a,(ScreenCmdr+1)
                        jp      SetScreenA
                
InitialiseFrontView:    ld      a,(ScreenKeyFront+1)
                        jp      SetScreenA
; false ret here as we get it free from jp    
;----------------------------------------------------------------------------------------------------------------------------------                    
                        INCLUDE "./GameEngine/SetScreenA.asm"
                        INCLUDE "./GameEngine/ViewKeyTest.asm"
;----------------------------------------------------------------------------------------------------------------------------------                    
SetInitialShipPosition: ld      hl,$0000
                        ld      (UBnKxlo),hl
                        ld      hl,$0000
                        ld      (UBnKylo),hl
                        ld      hl,$03B4
                        ld      (UBnKzlo),hl
                        xor     a
                        ld      (UBnKxsgn),a
                        ld      (UBnKysgn),a
                        ld      (UBnKzsgn),a
            DISPLAY "TODO:  call    Reset TODO"
                        call	InitialiseOrientation            ;#00;
                        ld      a,1
                        ld      (DELTA),a
                        ld      hl,4
                        ld      (DELTA4),hl
                        ret    

; Checks to see if current ship swapped in is in our sights
; we don;t need to deal with planets or sun as they have their own memory bank
ShipInSights:           ClearCarryFlag                          ; Carry clear no hit
                        ReturnIfMemIsNegative UBnKzsgn
                        ld      a,(UBnKexplDsp)                 ; get exploding flag and or with x and y high
                        ld      hl,(UBnKxlo)                    ; do 16 bit fetch as we will often need both bytes
                        ld      bc,(UBnKylo)                    ; .
                        or      h
                        or      b
                        ret     nz                              ; if exploding or x hi or y hi are set then its nto targetable
                        ld      a,l                             ; hl =xlo ^ 2
                        DEEquSquareA                            ; .
                        ld      hl,de                           ; .
                        ld      a,c                             ; de = de = ylo ^ 2
                        DEEquSquareA                            ; .
                        add     hl,de                           ; hl = xlo ^ 2 + ylo ^ 2
                        ret     c                               ; if there was a carry then out of line of sight
                        ld      de,(MissileLockLoAddr)          ; get targettable area ^ 2 from blueprint copy
                        cpHLDE                                  ; now compare x^2 + y^2 to target area
                        jr      z,.EdgeHit                      ; if its an edge hit then we need to set carry
                        ret                                     ; if its < area then its a hit and carry is set, we will not work on = 
.EdgeHit:               SetCarryFlag                            ; its an edge hit then we need to set carry
                        ret
                        

            INCLUDE "./Views/ConsoleDrawing.asm"
            INCLUDE "./Tables/message_queue.asm"
            INCLUDE "./Tables/LaserStatsTable.asm"
            INCLUDE "./Tables/ShipClassTable.asm"

SeedGalaxy0:            xor     a
                        MMUSelectGalaxyA
                        ld      ix,galaxy_data
                        xor		a
                        ld		(XSAV),a
                        call    copy_galaxy_to_system
SeedGalaxy0Loop:        push    ix
                        pop     de
                        ld      hl,SystemSeed
                        call    copy_seed
                        push    ix
                        pop     hl
                        add     hl,8
                        push    hl
                        pop     ix
                        call    next_system_seed
                        ld		a,(XSAV)
                        dec		a
                        cp		0
                        ret		z
                        ld		(XSAV),a
                        jr      nz,SeedGalaxy0Loop
                        ret



            
    ;include "./ModelRender/testdrawing.asm"
    IFDEF SKIPATTRACT
        DISPLAY "NOT LOADING ATTRACT MODE CODE"
    ELSE
        include "./Menus/AttractMode.asm"
    ENDIF

    include "./Maths/Utilities/XX12EquNodeDotOrientation.asm"
    include "./ModelRender/CopyXX12ToXX15.asm"	
    ;;DEFUNCTinclude "./ModelRender/CopyXX15ToXX12.asm"
    include "./Maths/Utilities/ScaleXX16Matrix197.asm"
		    
    include "./Universe/StarDust/StarRoutines.asm"
;    include "Universe/move_object-MVEIT.asm"
;    include "./ModelRender/draw_object.asm"
;    include "./ModelRender/draw_ship_point.asm"
;    include "./ModelRender/drawforwards-LL17.asm"
;    include "./ModelRender/drawforwards-LL17.asm"
    
    INCLUDE	"./Hardware/memfill_dma.asm"
    INCLUDE	"./Hardware/memcopy_dma.asm"
XX12PVarQ			DW 0
XX12PVarR			DW 0
XX12PVarS			DW 0
XX12PVarResult1		DW 0
XX12PVarResult2		DW 0
XX12PVarResult3		DW 0
XX12PVarSign2		DB 0
XX12PVarSign1		DB 0								; Note reversed so BC can do a little endian fetch
XX12PVarSign3		DB 0
    INCLUDE "./Variables/constant_equates.asm"
    INCLUDE "./Variables/general_variables.asm"
    INCLUDE "./Variables/general_variablesRoutines.asm"
    INCLUDE "./Variables/UniverseSlotRoutines.asm"
    INCLUDE "./Variables/EquipmentVariables.asm"
    INCLUDE "./Variables/random_number.asm"
    INCLUDE "./Variables/galaxy_seed.asm"
    INCLUDE "./Tables/text_tables.asm"
    INCLUDE "./Tables/dictionary.asm"
    INCLUDE "./Tables/name_digrams.asm"
;INCLUDE "Tables/inwk_table.asm" This is no longer needed as we will write to univer object bank
; Include all maths libraries to test assembly   
    ;INCLUDE "./Maths/asm_add.asm"
    ;INCLUDE "./Maths/asm_subtract.asm"
    INCLUDE "./Maths/Utilities/AddDEToCash.asm"
    INCLUDE "./Maths/DIVD3B2.asm"
    INCLUDE "./Maths/multiply.asm"
    INCLUDE "./Maths/asm_square.asm"
    INCLUDE "./Maths/asm_sine.asm"
    INCLUDE "./Maths/asm_sqrt.asm"
    INCLUDE "./Maths/asm_arctan.asm"
    INCLUDE "./Maths/SineTable.asm"
    INCLUDE "./Maths/ArcTanTable.asm"
    INCLUDE "./Maths/negate16.asm"
    INCLUDE "./Maths/asm_divide.asm"
    INCLUDE "./Maths/asm_unitvector.asm"
    INCLUDE "./Maths/compare16.asm"
    INCLUDE "./Maths/normalise96.asm"
    INCLUDE "./Maths/binary_to_decimal.asm"
    INCLUDE "./Maths/Utilities/AequAdivQmul96-TIS2.asm"
    INCLUDE "./Maths/Utilities/AequAmulQdiv256-FMLTU.asm"
    INCLUDE "./Maths/Utilities/PRequSpeedDivZZdiv8-DV42-DV42IYH.asm"
;    INCLUDE "./Maths/Utilities/AequDmulEdiv256usgn-DEFMUTL.asm" Moved to general multiply code

    INCLUDE "./Maths/Utilities/APequQmulA-MULT1.asm"
    INCLUDE "./Maths/Utilities/badd_ll38.asm"
;;DEFUNCT    INCLUDE "./Maths/Utilities/moveship4-MVS4.asm"

    INCLUDE "./Maths/Utilities/RequAmul256divQ-BFRDIV.asm"
    INCLUDE "./Maths/Utilities/RequAdivQ-LL61.asm"
    INCLUDE "./Maths/Utilities/RSequQmulA-MULT12.asm"

    include "./Universe/Ships/CopyRotMattoXX15.asm"
    include "./Universe/Ships/CopyXX15toRotMat.asm"
    INCLUDE "./Maths/Utilities/tidy.asm"
    INCLUDE "./Maths/Utilities/LL28AequAmul256DivD.asm"    
    INCLUDE "./Maths/Utilities/XAequMinusXAPplusRSdiv96-TIS1.asm"

    INCLUDE "./GameEngine/Tactics.asm"
    INCLUDE "./Hardware/drive_access.asm"

    INCLUDE "./Menus/common_menu.asm"
MainNonBankedCodeEnd:
    DISPLAY "Main Non Banked Code Ends at ",$

    org $B000
    DISPLAY "Vector Table Starts at ",$
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

IR_COUNT        dw  $0060

LAST_DELTA      db  0    
SavedMMU6       db  0 
SavedMMU7       db  0
SoundInterrupt      EQU IM2Sound
DanubeInterrupt     EQU IM2PlayDanube
AttractInterrrupt   EQU IM2AttractMode


StartOfInterruptHandler:
    DISPLAY "Non Banked Code Ends At", StartOfInterruptHandler

                ; NOTE play then equeue simplifies ligic, more chance slot free
                org $B1B1
    DISPLAY "Interrupt Handler Starts at",$
; keeping the handler to a minimal size in order to make best use of
; non pageable memory    
IM2Routine:             IFDEF INTERRUPT_BLOCKER
                                DISPLAY "Interrupt Blocker Enabled"
                                ei
                                reti
                        ELSE
                                DISPLAY "Interrupt Blocker Disabled"
                        ENDIF
                        push    af,,bc,,de,,hl,,ix,,iy
                        ex      af,af'
                        exx
                        push    af,,bc,,de,,hl
                        ld      hl,InterruptCounter
                        inc     (hl)                        ; cycles each interrupt
                        ;break                         
IM2SoundHandler:        call    IM2Sound                    ; This is a self modifying code address to change the actual sound vector if we are doing special music e.g. intro or docking
                        pop    af,,bc,,de,,hl
                        ex      af,af'
                        exx
                        pop     af,,bc,,de,,hl,,ix,,iy
.IMFinishup:            ei
                        reti
    DISPLAY "Interrupt Handler Ends at",$
EndOfNonBanked:
    DISPLAY "Non Banked Code + Interrupt Handler Ends At", EndOfNonBanked


SaveMMU6:               MACRO
                        GetNextReg  MMU_SLOT_6_REGISTER
                        ld      (SavedMMU6),a
                        ENDM

RestoreMMU6:            MACRO     
                        ld      a,(SavedMMU6)               ; now restore up post interrupt
                        nextreg MMU_SLOT_6_REGISTER,a       ; Restore MMU7                   
                        ENDM

SaveMMU7:               MACRO
                        GetNextReg  MMU_SLOT_7_REGISTER
                        ld      (SavedMMU7),a
                        ENDM

RestoreMMU7:            MACRO     
                        ld      a,(SavedMMU7)               ; now restore up post interrupt
                        nextreg MMU_SLOT_7_REGISTER,a       ; Restore MMU7                   
                        ENDM

IM2Sound:               SaveMMU7
                        MMUSelectSound
                        ; This is a self modifying code address to change the
                        ; actual sound vector if we are doing special music
                        ; e.g. intro or docking
.IM2SoundHandler:       call    SoundInterruptHandler       ; this does the work
.DoneInterrupt:         RestoreMMU7
                        ret
   

IM2PlayDanube:          SaveMMU7
                        MMUSelectSound
                        ; This is a self modifying code address to change the
                        ; actual sound vector if we are doing special music
                        ; e.g. intro or docking
.IM2SoundHandler:       call    PlayDanube                  ; this does the work
.DoneInterrupt:         RestoreMMU7
                        ret
                        
IM2AttractMode:         ;break
                    IFDEF SKIPATTRACTMUSIC
                        DISPLAY "Attract mode Music disabled"
                    ELSE                        
                        DISPLAY "Attract mode Music enabled"
                        call    IM2PlayDanube
                    ENDIF
                    IFDEF SKIPATTRACTGRAPHICS
                        DISPLAY "Attract mode graphics disabled"
                    ELSE
                        DISPLAY "Attract mode graphics enabled"
                        SaveMMU6
                        SaveMMU7
                        ;break
                        call    AttractModeUpdate
                        RestoreMMU6
                        RestoreMMU7
                    ENDIF
                        ret

; ARCHIVED INCLUDE "Menus/draw_fuel_and_crosshair.asm"
;INCLUDE "./title_page.asm"

; Blocks dependent on variables in Universe Banks
; Bank 49
;    SEG RESETUNIVSEG
;seg     CODE_SEG,       4:              $0000,       $8000                 ; flat address
;seg     RESETUNIVSEG,   BankResetUniv:  StartOfBank, ResetUniverseAddr      



;	ORG ResetUniverseAddr
;INCLUDE "./GameEngine/resetUniverse.asm"
; Bank 50  ------------------------------------------------------------------------------------------------------------------------
    SLOT    MenuShrChtAddr
    PAGE    BankMenuShrCht
	ORG     MenuShrChtAddr,BankMenuShrCht
    INCLUDE "./Menus/short_range_chart_menu.asm"
    DISPLAY "Bank ",BankMenuShrCht," - Bytes free ",/D, $2000 - ($-MenuShrChtAddr), " - BankMenuShrCht"
; Bank 51  ------------------------------------------------------------------------------------------------------------------------
    SLOT    MenuGalChtAddr
    PAGE    BankMenuGalCht
	ORG     MenuGalChtAddr
    INCLUDE "./Menus//galactic_chart_menu.asm"
    DISPLAY "Bank ",BankMenuGalCht," - Bytes free ",/D, $2000 - ($-MenuGalChtAddr), " - BankMenuGalCht"
; Bank 52  ------------------------------------------------------------------------------------------------------------------------
    SLOT    MenuInventAddr
    PAGE    BankMenuInvent
	ORG     MenuInventAddr
    INCLUDE "./Menus/inventory_menu.asm"        
    DISPLAY "Bank ",BankMenuInvent," - Bytes free ",/D, $2000 - ($-MenuInventAddr), " - BankMenuInvent"
; Bank 53  ------------------------------------------------------------------------------------------------------------------------
    SLOT    MenuSystemAddr
    PAGE    BankMenuSystem
	ORG     MenuSystemAddr
    INCLUDE "./Menus/system_data_menu.asm"
    DISPLAY "Bank ",BankMenuSystem," - Bytes free ",/D, $2000 - ($-MenuSystemAddr), " - BankMenuSystem"
; Bank 54  ------------------------------------------------------------------------------------------------------------------------
    SLOT    MenuMarketAddr
    PAGE    BankMenuMarket
    ORG     MenuMarketAddr
    INCLUDE "./Menus/market_prices_menu.asm"
    DISPLAY "Bank ",BankMenuMarket," - Bytes free ",/D, $2000 - ($-MenuMarketAddr), " - BankMenuMarket"
; Bank 55  ------------------------------------------------------------------------------------------------------------------------
    SLOT    StockTableAddr
    PAGE    BankStockTable
    ORG     StockTableAddr  
    INCLUDE "./Tables/stock_table.asm"
    DISPLAY "Bank ",BankStockTable," - Bytes free ",/D, $2000 - ($-StockTableAddr), " - BankStockTable"
; Bank 56  ------------------------------------------------------------------------------------------------------------------------
    SLOT    CommanderAddr
    PAGE    BankCommander
    ORG     CommanderAddr, BankCommander
    INCLUDE "./Commander/commanderData.asm"
    INCLUDE "./Commander/zero_player_cargo.asm"
    DISPLAY "Bank ",BankCommander," - Bytes free ",/D, $2000 - ($-CommanderAddr), " - BankCommander"
; Bank 57  ------------------------------------------------------------------------------------------------------------------------
    SLOT    LAYER2Addr
    PAGE    BankLAYER2
    ORG     LAYER2Addr
     
    INCLUDE "./Layer2Graphics/layer2_bank_select.asm"
    INCLUDE "./Layer2Graphics/layer2_cls.asm"
    INCLUDE "./Layer2Graphics/layer2_initialise.asm"
    INCLUDE "./Layer2Graphics/l2_flip_buffers.asm"
    INCLUDE "./Layer2Graphics/layer2_plot_pixel.asm"
    INCLUDE "./Layer2Graphics/layer2_print_character.asm"
    INCLUDE "./Layer2Graphics/layer2_draw_box.asm"
    INCLUDE "./Layer2Graphics/asm_l2_plot_horizontal.asm"
    INCLUDE "./Layer2Graphics/asm_l2_plot_vertical.asm"
    INCLUDE "./Layer2Graphics/layer2_plot_diagonal.asm"
;    INCLUDE "./Layer2Graphics/asm_l2_plot_triangle.asm"
;    INCLUDE "./Layer2Graphics/asm_l2_fill_triangle.asm"
;    INCLUDE "./Layer2Graphics/L2_SolidTriangles.asm"
    INCLUDE "./Layer2Graphics/layer2_plot_circle.asm"
    INCLUDE "./Layer2Graphics/layer2_plot_circle_fill.asm"
    INCLUDE "./Layer2Graphics/l2_draw_any_line.asm"
;    INCLUDE "./Layer2Graphics/clearLines-LL155.asm"
    INCLUDE "./Layer2Graphics/l2_draw_line_v2.asm"
    DISPLAY "Bank ",BankLAYER2," - Bytes free ",/D, $2000 - ($-LAYER2Addr), " - BankLAYER2"
; Bank 58  ------------------------------------------------------------------------------------------------------------------------
    SLOT    LAYER1Addr
    PAGE    BankLAYER1
    ORG     LAYER1Addr, BankLAYER1
Layer1Header:  DB "Bank L1 Utils--"

    INCLUDE "./Layer1Graphics/layer1_attr_utils.asm"
    INCLUDE "./Layer1Graphics/layer1_cls.asm"
    INCLUDE "./Layer1Graphics/layer1_print_at.asm"
    DISPLAY "Bank ",BankLAYER1," - Bytes free ",/D, $2000 - ($-LAYER1Addr), " - BankLAYER1"
; Bank 59  ------------------------------------------------------------------------------------------------------------------------
; In the first copy of the banks the "Non number" labels exist. They will map directly in other banks
; as the is aligned and data tables are after that
; need to make the ship index tables same size in each to simplify further    
    SLOT    ShipModelsAddr
    PAGE    BankShipModels1
	ORG     ShipModelsAddr, BankShipModels1
    INCLUDE "./Data/ShipModelMacros.asm"
    INCLUDE "./Data/ShipBank1Label.asm"
GetShipBankId:
GetShipBank1Id:         MGetShipBankId ShipBankTable
CopyVertsToUniv:
CopyVertsToUniv1:       McopyVertsToUniverse
CopyEdgesToUniv:
CopyEdgesToUniv1:       McopyEdgesToUniverse
CopyNormsToUniv:        
CopyNormsToUniv1:       McopyNormsToUniverse
ShipBankTable:
ShipBankTable1:         MShipBankTable
CopyShipToUniverse:
CopyShipToUniverse1     MCopyShipToUniverse     BankShipModels1
CopyBodyToUniverse:
CopyBodyToUniverse1:    MCopyBodyToUniverse     CopyShipToUniverse1
    INCLUDE "./Data/ShipModelMetaData1.asm"
    DISPLAY "Bank ",BankShipModels1," - Bytes free ",/D, $2000 - ($-ShipModelsAddr), " - BankShipModels1"
; Bank 66  ------------------------------------------------------------------------------------------------------------------------
    SLOT    DispMarketAddr
    PAGE    BankDispMarket
    ORG     DispMarketAddr
    INCLUDE "./Menus/market_prices_disp.asm"
    DISPLAY "Bank ",BankDispMarket," - Bytes free ",/D, $2000 - ($-MenuShrChtAddr), " - BankDispMarket"
; Bank 67  ------------------------------------------------------------------------------------------------------------------------
    SLOT    ShipModelsAddr
    PAGE    BankShipModels2
	ORG     ShipModelsAddr, BankShipModels2

    INCLUDE "./Data/ShipBank2Label.asm"
GetShipBank2Id:         MGetShipBankId ShipBankTable2                        
CopyVertsToUniv2:       McopyVertsToUniverse
CopyEdgesToUniv2:       McopyEdgesToUniverse
CopyNormsToUniv2:       McopyNormsToUniverse
ShipBankTable2:         MShipBankTable
CopyShipToUniverse2     MCopyShipToUniverse     BankShipModels2
CopyBodyToUniverse2:    MCopyBodyToUniverse     CopyShipToUniverse2

    INCLUDE "./Data/ShipModelMetaData2.asm"
    DISPLAY "Bank ",BankShipModels2," - Bytes free ",/D, $2000 - ($-ShipModelsAddr), " - BankShipModels2"
; Bank 68  ------------------------------------------------------------------------------------------------------------------------
    SLOT    ShipModelsAddr
    PAGE    BankShipModels3
	ORG     ShipModelsAddr, BankShipModels3

    INCLUDE "./Data/ShipBank3Label.asm"
GetShipBank3Id:         MGetShipBankId ShipBankTable3
CopyVertsToUniv3:       McopyVertsToUniverse
CopyEdgesToUniv3:       McopyEdgesToUniverse
CopyNormsToUniv3:       McopyNormsToUniverse    
ShipBankTable3:         MShipBankTable
CopyShipToUniverse3     MCopyShipToUniverse     BankShipModels3
CopyBodyToUniverse3:    MCopyBodyToUniverse     CopyShipToUniverse3
    INCLUDE "./Data/ShipModelMetaData3.asm"
;;Privisioned for more models ; Bank 69  ------------------------------------------------------------------------------------------------------------------------
;;Privisioned for more models     SLOT    ShipModelsAddr
;;Privisioned for more models     PAGE    BankShipModels4
;;Privisioned for more models 	ORG     ShipModelsAddr, BankShipModels4
    DISPLAY "Bank ",BankShipModels3," - Bytes free ",/D, $2000 - ($-ShipModelsAddr), " - BankShipModels3"
; Bank 60  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    SpritemembankAddr
                    PAGE    BankSPRITE
                    ORG     SpritemembankAddr, BankSPRITE
                    INCLUDE "./Layer3Sprites/sprite_routines.asm"
                    INCLUDE "./Layer3Sprites/sprite_load.asm"
;;;***    INCLUDE " A./Layer3Sprites/SpriteSheet.asm"
                    DISPLAY "Bank ",BankSPRITE," - Bytes free ",/D, $2000 - ($-ShipModelsAddr), " - BankSPRITE"
                    ASSERT $-SpritemembankAddr <8912 , Bank code leaks over 8K boundary
; Bank 61  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    ConsoleImageAddr
                    PAGE    BankConsole
                    ORG     ConsoleImageAddr, BankConsole
                    INCLUDE "./Images/ConsoleImageData.asm"
                    DISPLAY "Bank ",BankConsole," - Bytes free ",/D, $2000 - ($-ConsoleImageAddr), " - BankConsole"
                    ASSERT $-ConsoleImageAddr <8912 , Bank code leaks over 8K boundary
; Bank 62  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    ViewFrontAddr
                    PAGE    BankFrontView
                    ORG     ViewFrontAddr  
                    INCLUDE "./Views/Front_View.asm"    
                    DISPLAY "Bank ",BankFrontView," - Bytes free ",/D, $2000 - ($-ViewFrontAddr), " - BankFrontView"
                    ASSERT $-ViewFrontAddr <8912 , Bank code leaks over 8K boundary
; Bank 63  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    MenuStatusAddr
                    PAGE    BankMenuStatus
                    ORG     MenuStatusAddr
                    INCLUDE "./Menus/status_menu.asm"
                    DISPLAY "Bank ",BankMenuStatus," - Bytes free ",/D, $2000 - ($-MenuStatusAddr), " - BankMenuStatus"
                    ASSERT $-MenuStatusAddr <8912 , Bank code leaks over 8K boundary
; Bank 64  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    MenuEquipSAddr
                    PAGE    BankMenuEquipS
                    ORG     MenuEquipSAddr  
                    INCLUDE "./Menus/equip_ship_menu.asm"    
                    DISPLAY "Bank ",BankMenuEquipS," - Bytes free ",/D, $2000 - ($-MenuEquipSAddr), " - BankMenuEquipS"
                    ASSERT $-MenuEquipSAddr <8912 , Bank code leaks over 8K boundary
; Bank 65  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    LaunchShipAddr
                    PAGE    BankLaunchShip
                    ORG     LaunchShipAddr
                    INCLUDE "./Transitions/launch_ship.asm"
                    DISPLAY "Bank ",BankLaunchShip," - Bytes free ",/D, $2000 - ($-LaunchShipAddr), " - BankLaunchShip"
                    ASSERT $-LaunchShipAddr <8912 , Bank code leaks over 8K boundary
; Bank 70  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    UniverseBankAddr
                    PAGE    BankUNIVDATA0
                    ORG	    UniverseBankAddr,BankUNIVDATA0
                    INCLUDE "./Universe/Ships/univ_ship_data.asm"
                    DISPLAY "Sizing Bank ",BankUNIVDATA0," - Start ",UniverseBankAddr," End - ",$, "- Universe Data A"
                    DISPLAY "Bank ",BankUNIVDATA0," - Bytes free ",/D, $2000 - ($-UniverseBankAddr), "- Universe Data A"
                    ASSERT $-UniverseBankAddr <8912, Bank code leaks over 8K boundary
; Bank 71  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    UniverseBankAddr
                    PAGE    BankUNIVDATA1
                    ORG	UniverseBankAddr,BankUNIVDATA1
UNIVDATABlock1      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankUNIVDATA1," - Bytes free ",/D, $2000 - ($-UniverseBankAddr), "- Universe Data B"
                    ASSERT $-UniverseBankAddr <8912, Bank code leaks over 8K boundary
; Bank 72  ------------------------------------------------------------------------------------------------------------------------    
                    SLOT    UniverseBankAddr
                    PAGE    BankUNIVDATA2
                    ORG	UniverseBankAddr,BankUNIVDATA2
UNIVDATABlock2      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankUNIVDATA2," - Bytes free ",/D, $2000 - ($-UniverseBankAddr), "- Universe Data C"
                    ASSERT $-UniverseBankAddr <8912, Bank code leaks over 8K boundary
; Bank 73  ------------------------------------------------------------------------------------------------------------------------    
                    SLOT    UniverseBankAddr
                    PAGE    BankUNIVDATA3
                    ORG	UniverseBankAddr,BankUNIVDATA3
UNIVDATABlock3      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankUNIVDATA3," - Bytes free ",/D, $2000 - ($-UniverseBankAddr), "- Universe Data D"
                    ASSERT $-UniverseBankAddr <8912, Bank code leaks over 8K boundary
; Bank 74  ------------------------------------------------------------------------------------------------------------------------    
                    SLOT    UniverseBankAddr
                    PAGE    BankUNIVDATA4
                    ORG	UniverseBankAddr,BankUNIVDATA4
UNIVDATABlock4      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankUNIVDATA3," - Bytes free ",/D, $2000 - ($-UniverseBankAddr), "- Universe Data E"
                    ASSERT $-UniverseBankAddr <8912, Bank code leaks over 8K boundary
; Bank 75  ------------------------------------------------------------------------------------------------------------------------    
                    SLOT    UniverseBankAddr
                    PAGE    BankUNIVDATA5
                    ORG	UniverseBankAddr,BankUNIVDATA5
UNIVDATABlock5      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankUNIVDATA3," - Bytes free ",/D, $2000 - ($-UniverseBankAddr), "- Universe Data F"
                    ASSERT $-UniverseBankAddr <8912, Bank code leaks over 8K boundary
; Bank 76  ------------------------------------------------------------------------------------------------------------------------    
                    SLOT    UniverseBankAddr
                    PAGE    BankUNIVDATA6
                    ORG	UniverseBankAddr,BankUNIVDATA6
UNIVDATABlock6      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankUNIVDATA3," - Bytes free ",/D, $2000 - ($-UniverseBankAddr), "- Universe Data G"
                    ASSERT $-UniverseBankAddr <8912, Bank code leaks over 8K boundary
; Bank 77  ------------------------------------------------------------------------------------------------------------------------    
                    SLOT    UniverseBankAddr
                    PAGE    BankUNIVDATA7
                    ORG	UniverseBankAddr,BankUNIVDATA7
UNIVDATABlock7      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankUNIVDATA3," - Bytes free ",/D, $2000 - ($-UniverseBankAddr), "- Universe Data H"
                    ASSERT $-UniverseBankAddr <8912, Bank code leaks over 8K boundary
; Bank 78  ------------------------------------------------------------------------------------------------------------------------    
                    SLOT    UniverseBankAddr
                    PAGE    BankUNIVDATA8
                    ORG	UniverseBankAddr,BankUNIVDATA8
UNIVDATABlock8      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankUNIVDATA3," - Bytes free ",/D, $2000 - ($-UniverseBankAddr), "- Universe Data I"
                    ASSERT $-UniverseBankAddr <8912, Bank code leaks over 8K boundary
; Bank 79  ------------------------------------------------------------------------------------------------------------------------    
                    SLOT    UniverseBankAddr
                    PAGE    BankUNIVDATA9
                    ORG	UniverseBankAddr,BankUNIVDATA9
UNIVDATABlock9      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankUNIVDATA3," - Bytes free ",/D, $2000 - ($-UniverseBankAddr), "- Universe Data J"
                    ASSERT $-UniverseBankAddr <8912, Bank code leaks over 8K boundary
; Bank 80  ------------------------------------------------------------------------------------------------------------------------    
                    SLOT    UniverseBankAddr
                    PAGE    BankUNIVDATA10
                    ORG	UniverseBankAddr,BankUNIVDATA10
UNIVDATABlock10     DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankUNIVDATA3," - Bytes free ",/D, $2000 - ($-UniverseBankAddr), "- Universe Data K"
                    ASSERT $-UniverseBankAddr <8912, Bank code leaks over 8K boundary
; Bank 81  ------------------------------------------------------------------------------------------------------------------------    
                    SLOT    UniverseBankAddr
                    PAGE    BankUNIVDATA11
                    ORG	UniverseBankAddr,BankUNIVDATA11
UNIVDATABlock11     DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankUNIVDATA3," - Bytes free ",/D, $2000 - ($-UniverseBankAddr), "- Universe Data L"
                    ASSERT $-UniverseBankAddr <8912, Bank code leaks over 8K boundary
; Bank 82  ------------------------------------------------------------------------------------------------------------------------             
                    SLOT    UniverseBankAddr
                    PAGE    BankUNIVDATA12
                    ORG	UniverseBankAddr,BankUNIVDATA12
UNIVDATABlock12     DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankUNIVDATA3," - Bytes free ",/D, $2000 - ($-UniverseBankAddr), "- Universe Data M"
                    ASSERT $-UniverseBankAddr <8912, Bank code leaks over 8K boundary
; Bank 84  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    SunBankAddr
                    PAGE    BankSunData
                    ORG	    SunBankAddr,BankSunData
                    INCLUDE "./Universe/Sun/sun_data.asm"
                    DISPLAY "Bank ",BankSunData," - Bytes free ",/D, $2000 - ($-SunBankAddr), " - BankSunData"
                    ASSERT $-SunBankAddr <8912, Bank code leaks over 8K boundary
; Bank 85  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    PlanetBankAddr
                    PAGE    BankPlanetData
                    ORG	    PlanetBankAddr,BankPlanetData
                    INCLUDE "./Universe/Planet/planet_data.asm"
                    DISPLAY "Bank ",BankPlanetData," - Bytes free ",/D, $2000 - ($-PlanetBankAddr), " - BankPlanetData"
                    ASSERT $-PlanetBankAddr <8912, Bank code leaks over 8K boundary
;;;***; Bank 85  ------------------------------------------------------------------------------------------------------------------------
;;;***                        SLOT    SpriteDataAAddr
;;;***                        PAGE    BankSpriteDataA
;;;***                        ORG     SpriteDataAAddr, BankSpriteDataA
;;;***                        INCLUDE "./Layer3Sprites/sprite_loadA.asm"
;;;***                        INCLUDE "./Layer3Sprites/SpriteSheetA.asm"
;;;***                        DISPLAY "Bank ",BankSpriteDataA," - Bytes free ",/D, $2000 - ($-SpriteDataAAddr), " - BankSpriteDataA"
;;;***; Bank 86  ------------------------------------------------------------------------------------------------------------------------
;;;***                        SLOT    SpriteDataBAddr
;;;***                        PAGE    BankSpriteDataB
;;;***                        ORG     SpriteDataBAddr, BankSpriteDataB 
;;;***                        INCLUDE "./Layer3Sprites/sprite_loadB.asm"
;;;***                        INCLUDE "./Layer3Sprites/SpriteSheetB.asm"
;;;***                        DISPLAY "Bank ",BankSpriteDataB," - Bytes free ",/D, $2000 - ($-SpriteDataBAddr), " - BankSpriteDataB"
; Bank 91  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    GalaxyDataAddr
                    PAGE    BankGalaxyData0
                    ORG GalaxyDataAddr, BankGalaxyData0
                    INCLUDE "./Universe/Galaxy/galaxy_data.asm"                                                            
                    DISPLAY "Bank ",BankGalaxyData0," - Bytes free ",/D, $2000 - ($- GalaxyDataAddr), " - BankGalaxyData0"
                    ASSERT $-GalaxyDataAddr <8912, Bank code leaks over 8K boundary
; Bank 92  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    GalaxyDataAddr
                    PAGE    BankGalaxyData1
                    ORG GalaxyDataAddr, BankGalaxyData1
GALAXYDATABlock1:   DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now  
                    DISPLAY "Bank ",BankGalaxyData1," - Bytes free ",/D, $2000 - ($- GalaxyDataAddr), " - BankGalaxyData1"
                    ASSERT $-GalaxyDataAddr <8912, Bank code leaks over 8K boundary
; Bank 93  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    GalaxyDataAddr
                    PAGE    BankGalaxyData2
                    ORG GalaxyDataAddr, BankGalaxyData2
GALAXYDATABlock2:   DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankGalaxyData2," - Bytes free ",/D, $2000 - ($- GalaxyDataAddr), " - BankGalaxyData2"
                    ASSERT $-GalaxyDataAddr <8912, Bank code leaks over 8K boundary
; Bank 94  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    GalaxyDataAddr
                    PAGE    BankGalaxyData3
                    ORG GalaxyDataAddr, BankGalaxyData3
GALAXYDATABlock3:   DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankGalaxyData3," - Bytes free ",/D, $2000 - ($- GalaxyDataAddr), " - BankGalaxyData3"
                    ASSERT $-GalaxyDataAddr <8912, Bank code leaks over 8K boundary
; Bank 95  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    GalaxyDataAddr
                    PAGE    BankGalaxyData4
                    ORG GalaxyDataAddr, BankGalaxyData4
GALAXYDATABlock4:   DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankGalaxyData4," - Bytes free ",/D, $2000 - ($- GalaxyDataAddr), " - BankGalaxyData4"
                    ASSERT $-GalaxyDataAddr <8912, Bank code leaks over 8K boundary
; Bank 96  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    GalaxyDataAddr
                    PAGE    BankGalaxyData5
                    ORG GalaxyDataAddr,BankGalaxyData5
GALAXYDATABlock5:   DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankGalaxyData5," - Bytes free ",/D, $2000 - ($- GalaxyDataAddr), " - BankGalaxyData5"
                    ASSERT $-GalaxyDataAddr <8912, Bank code leaks over 8K boundary
; Bank 97  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    GalaxyDataAddr
                    PAGE    BankGalaxyData6
                    ORG GalaxyDataAddr,BankGalaxyData6
GALAXYDATABlock6:   DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankGalaxyData6," - Bytes free ",/D, $2000 - ($- GalaxyDataAddr), " - BankGalaxyData6"
                    ASSERT $-GalaxyDataAddr <8912, Bank code leaks over 8K boundary
; Bank 98  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    GalaxyDataAddr
                    PAGE    BankGalaxyData7
                    ORG GalaxyDataAddr,BankGalaxyData7
GALAXYDATABlock7:   DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    DISPLAY "Bank ",BankGalaxyData7," - Bytes free ",/D, $2000 - ($- GalaxyDataAddr), " - BankGalaxyData7"
                    ASSERT $-GalaxyDataAddr <8912, Bank code leaks over 8K boundary
; Bank 99  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    MathsTablesAddr
                    PAGE    BankMathsTables
                    ORG     MathsTablesAddr,BankMathsTables
                    INCLUDE "./Maths/logmaths.asm"
                    INCLUDE "./Tables/antilogtable.asm"
                    INCLUDE "./Tables/logtable.asm"
                    DISPLAY "Bank ",BankMathsTables," - Bytes free ",/D, $2000 - ($-MathsTablesAddr), " - BankMathsTables"
                    ASSERT $-MathsTablesAddr <8912, Bank code leaks over 8K boundary
; Bank 100  -----------------------------------------------------------------------------------------------------------------------
                    SLOT    KeyboardAddr
                    PAGE    BankKeyboard
                    ORG SoundAddr, BankKeyboard             
                    INCLUDE "./Hardware/keyboard.asm"
                    DISPLAY "Keyboard ",BankKeyboard," - Bytes free ",/D, $2000 - ($-KeyboardAddr), " - BankKeyboard"
                    ASSERT $-KeyboardAddr <8912, Bank code leaks over 8K boundary
; Bank 101  -----------------------------------------------------------------------------------------------------------------------
                    SLOT    SoundAddr
                    PAGE    BankSound
                    ORG SoundAddr, BankSound             
                    INCLUDE "./Hardware/sound.asm"
                    DISPLAY "Sound ",BankSound," - Bytes free ",/D, $2000 - ($-SoundAddr), " - BankSound"
                    ASSERT $-SoundAddr <8912, Bank code leaks over 8K boundary
 ; Bank 102  -----------------------------------------------------------------------------------------------------------------------
                    SLOT    MathsBankedFnsAddr
                    PAGE    BankMathsBankedFns
                    ORG     MathsBankedFnsAddr,BankMathsBankedFns
                    INCLUDE "./Maths/MathsBankedFns.asm"
                    DISPLAY "Bank ",MathsBankedFnsAddr," - Bytes free ",/D, $2000 - ($-MathsBankedFnsAddr), " - BankMathsBankedAdd"
                    ASSERT $-MathsBankedFnsAddr <8912, Bank code leaks over 8K boundary
    
    SAVENEX OPEN "EliteN.nex", EliteNextStartup , TopOfStack
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    DISPLAY "Main Non Banked Code End ", MainNonBankedCodeEnd , " Bytes free ", 0B000H - MainNonBankedCodeEnd
    ASSERT MainNonBankedCodeEnd < 0B000H, Program code leaks intot interrup vector table
    