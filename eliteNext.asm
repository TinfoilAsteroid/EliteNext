

    DEVICE ZXSPECTRUMNEXT
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
; REAL_HARDWARE: the build for a real Next (sjasmplus -DREAL_HARDWARE, or build.bat hardware): the screen clear and
; memfill_dma use DMA+ fill mode (core 3.03.00 or later, Documentation/ZXNDDMA.md) and the result is EliteNHW.nex.
; CSpect has no DMA+, so the normal build (EliteN.nex) uses the plain zxnDMA only
    IFDEF REAL_HARDWARE
        DISPLAY "REAL_HARDWARE set: the build for a real Next (DMA+, core 3.03.00 or later), EliteNHW.nex"
    ENDIF
    ;DEFINE  STARTUPDIAGS 1              ; use for displaying sprite data on start up for basic diagnostics
    DEFINE  DOUBLEBUFFER 1
    DEFINE  LATECLIPPING 1
    DEFINE  SIMPLEWARP   1
    DEFINE  USE_NORMALISE_IX 1          ; use the replacemtn normaliseix (now should be always used)
    DEFINE  USE_24BIT_ROLL_AND_PITCH 1  ; Use 24 bit maths always
    ;DEFINE  ROUND_ROLL_AND_PITCH    1  ; Forces rouding of rotmat matricies to 8 bit
    ;DEFINE  q 1
    ;DEFINE  TESTSYSTEMMENU 1
    ;DEFINE  TESTMARKETROMENU 1
;    DEFINE  TESTSTATUSMENU 1
    ;DEFINE TESTINVENTORYMENU 1
    ;DEFINE TESTMUL 1
    ;DEFINE  DEBUGCMDREQUIP 1

    ;DEFINE  SPAWN_SHIP_DISABLED  1      ; Forces spawn event to immedatly return rather than do anything
    ;DEFINE DEBUGCIRCLE1 1
    ;DEFINE DEBUGCIRCLE2 1
    ;DEFINE DEBUGCIRCLE3 1
    ;DEFINE DEBUGCIRCLE4 1
    ;DEFINE DEBUGCIRCLE5 1 ws
    ;DEFINE DEBUGCIRCLE6 1
    ;DEFINE  DEBUGPLANET 1
    ;DEFINE  DEBUGPLANETCIRCLE 1
    ;DEFINE  MERIDANLINEDEBUG 1
    DEFINE  PLANETSARESOLID 1
    DEFINE  SOLID_HULL 1                ; solid (filled face) ships, Documentation/SolidHulls.md
    DEFINE  MANUAL_ATTRACT 1            ; attract screen: no auto cycling, F next model, B previous, its name on the HUD
    ;DEFINE  WIREFRAME_FALLBACK 1        ; with SOLID_HULL: a ship nearer than WIREFRAME_DISTANCE is drawn as wireframe
    ;DEFINE  SOLID_OUTLINES ALL          ; with SOLID_HULL: lines over the fill. ALL: every visible edge; DECORATION: only
                                         ; the decoration edges (both faces the same: vents, engines); not defined: none
; SOLID_OUTLINES: its value pasted onto SolidOutlines_ gives the mode (sjasmplus substitutes the define inside the name),
; so any other value stops the build
SolidOutlines_ALL           equ 1
SolidOutlines_DECORATION    equ 2
    IFDEF SOLID_OUTLINES
        ASSERT SolidOutlines_SOLID_OUTLINES > 0, SOLID_OUTLINES must be ALL or DECORATION
SolidOutlinesMode           equ SolidOutlines_SOLID_OUTLINES
    ENDIF
; WIREFRAME_FALLBACK: a ship whose z is less than this is drawn as wireframe. S15.8 (1.0 = 256), so 256/30 is 0.1. To be
; tuned on real hardware. (-DWIREFRAME_DISTANCE=n on the sjasmplus command line overrides it, for the tests)
    IFNDEF WIREFRAME_DISTANCE
WIREFRAME_DISTANCE          equ 256/30
    ENDIF
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
    ; DEFINE MESSAGETRACING 1
     ;DEFINE  DEBUG_SHIP_MOVEMENT 1
 CSPECTMAP eliteN.map
 OPT --zxnext=cspect --syntax=a --reversepop
                DEFINE  SOUNDPACE 3
;                DEFINE  ENABLE_SOUND 1
               DEFINE     MAIN_INTERRUPTENABLE 1
;               DEFINE INTERRUPT_BLOCKER 1
DEBUGSEGSIZE   equ 1
DEBUGLOGSUMMARY equ 1

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
ScreenSystemMap  EQU ScreenEquip + 1             ; (before ScreenFront: the pause test takes ScreenFront on as views)
ScreenLaunch     EQU ScreenSystemMap + 1
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
                        INCLUDE "./Data/EquipmentEquates.asm"
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
                        INCLUDE "./Macros/print_text_macros.asm"
                        INCLUDE "./Universe/UniverseMacros/asm_linedraw.asm"
                        INCLUDE "./Universe/UniverseMacros/UniverseVarsDefineMacro.asm"
                        INCLUDE "./Macros/UniverseObjectPosMacros.asm"
                        INCLUDE "./Tables/message_queue_macros.asm"
                        INCLUDE "./Variables/general_variables_macros.asm"
                        INCLUDE "./Variables/UniverseSlot_macros.asm"
                        INCLUDE "./Data/ShipIdEquates.asm"
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

;--- START OF CODE -------------------------------------------------------------------------
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
                        ; disable next keys creating normal 8x5 grid presses
                        nextreg     ULA_CONTROL_REGISTER,  %00010000                ; set up ULA CONRTROL may need to change bit 0 at least, but bit 4 is separate extended keys from main matrix
                        MMUSelectSound
                        call        InitAudio
.InitialiseInterrupts:  ld	        a,VectorTable>>8
                        ld	        i,a						                        ; im2 table will be at address 0xa000
                        nextreg     LINE_INTERRUPT_CONTROL_REGISTER,%00000110       ; Video interrup on
                        nextreg     LINE_INTERRUPT_VALUE_LSB_REGISTER,0   ; lasta line..
                        im	2
                        di ; debug
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
.InitialisingMessage:
                    IFDEF MESSAGETRACING
                        MessageAt   0,0,InitialiseMessage
                        SetBorder   $01
                        MessageAt   0,8,LoadingSpritesMessage
                    ENDIF
                        ZeroA
                        ld          (LoadCounter),a
.StreamSpriteData:      MMUSelectSpriteBank
                        call        load_pattern_files
                        MMUSelectKeyboard
                        call        init_keyboard
.PostDiag:              ClearForceTransition
                    IFDEF STARTUPDIAGS
                        SetBorder   $04
                        MMUSelectSpriteBank
                        call        sprite_diagnostic
                        SetBorder   $05
.PostDiag2:             MMUSelectKeyboard
                        call        WaitForAnyKey
                        MMUSelectSpriteBank
                        call        sprite_diagnostic_clear
                    ENDIF
TestText:               xor			a
                        ld      (JSTX),a
DEBUGCODE:              ClearSafeZone ; just set in open space so compas treacks su n
                        SetBorder   $06
                        MMUSelectUniverseN  0
                        MMUSelectLayer2
                        SetBorder   $07
;
InitialiseGalaxies:
                    IFDEF MESSAGETRACING
                        MessageAt   0,24,InitialisingGalaxies
                    ENDIF
                        call		ResetUniv                       ; Reset ship data
                        call        ResetGalaxy                     ; Reset each galaxy copying in code
                        call        SeedAllGalaxies
                        MMUSelectSpriteBank
                        call        sprite_cls_all
                        MMUSelectLayer1
                        call		l1_cls
                        SetBorder   $00

                        DISPLAY "INITGALAXIES ATTRACT ENABLED"
StartAttractMode:       di                                          ; we are changing interrupts
                        MMUSelectSound
                        call        InitAudioMusic
                        ld          hl,AttractInterrrupt
                        ld          (IM2SoundHandler+1),hl
                        call        AttractModeInit
                        ei
                        call        AttractModeMain                 ; now drive attact mode keyboard scan
                        di                                          ; set up for main
                        ld          hl,SoundInterrupt               ; sound handler
                        ld          (IM2SoundHandler+1),hl
                        MMUSelectSound
                        call        InitAudio                       ; jsut re-init all audio for now rather than sound off
                        ei
                        JumpIfAIsZero  SkipDefaultCommander

DefaultCommander:       MMUSelectCommander
                        call		defaultCommander
                        jp          InitialiseMainLoop:
; Load Commander (Y): the save, Default.SAV for now (a file browser later); on any error the default commander made at
; start up stays. (This was only comments, so Y did the same as N)
SkipDefaultCommander:   MMUSelectCommander
                        MMUSelectROMS                               ; rst $08 needs the ROM in slots 0 and 1
                        call    loadCommander
                        MMUSelectMathsBankedFns
InitialiseMainLoop:     call    InitMainLoop
;..MAIN GAME LOOP..................................................................................................................
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
                        INCLUDE "./GameEngine/ProcessWarp.asm"
                        INCLUDE "./GameEngine/SpawnObject.asm"
;..................................................................................................................................
;..Process A ship..................................................................................................................
; Apply Damage b to ship based on shield value of a
; returns a with new shield value
                        INCLUDE "./GameEngine/DamagePlayer.asm"
;..Update Universe Objects.........................................................................................................
                        INCLUDE "./GameEngine/UpdateUniverseObjects.asm"
;----------------------------------------------------------------------------------------------------------------------------------
                    IFDEF MESSAGETRACING
InitialiseMessage       DB "Intialising",0
LoadingSpritesMessage   DB "LoadingSprites",0
InitialisingGalaxies    DB "IntiailisingGalaxies",0
                    ENDIF
LoadCounter             DB 0
SpriteProgress          DB "*",0
;----------------------------------------------------------------------------------------------------------------------------------
NeedAMessageQueue:
;..................................................................................................................................
                        INCLUDE "./GameEngine/HyperSpaceTimers.asm"
;----------------------------------------------------------------------------------------------------------------------------------
TestPauseMode:          ld      a,(GamePaused)
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

currentDemoShip:        DB      13;$12 ; 13 - corirollis


GetStationVectorToWork: ld      hl,UBnKxlo
                        ld      de,varVector9ByteWork
                        ld      bc,9
                        ldir
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
                        MMUSelectMathsBankedFns
                        call    normaliseXX1596S7
                        ret                          ; will return with a holding Vector Z


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

InitialiseCommander:    ld      a,(ScreenCmdr+1)
                        jp      SetScreenA

InitialiseFrontView:    ld      a,(ScreenKeyFront+1)
                        jp      SetScreenA
; false ret here as we get it free from jp
;----------------------------------------------------------------------------------------------------------------------------------
                        INCLUDE "./GameEngine/SetScreenA.asm"
                        INCLUDE "./GameEngine/ViewKeyTest.asm"
;----------------------------------------------------------------------------------------------------------------------------------
; Set initial ship position as X,Y,Z 000,000,03B4 - Moved to UpodateUniverseObjects.asm

; Checks to see if current ship swapped in is in our sights
; we don;t need to deal with planets or sun as they have their own memory bank
ShipInSights:           ClearCarryFlag                          ; Carry clear no hit
                        ReturnIfMemIsNegative UBnKzsgn
                        ld      a,(UBnKxsgn)                    ; 65536 or more to the side (the sign bytes' integer bits):
                        ld      hl,UBnKysgn                     ; not in the sights (they were ignored, so a ship that far
                        or      (hl)                            ; off with small x / y lo and hi bytes counted as a hit)
                        and     SignMask8Bit                    ; (and clears carry)
                        ret     nz
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

    IFDEF SKIPATTRACT
        DISPLAY "NOT LOADING ATTRACT MODE CODE"
    ELSE
        include "./Menus/AttractMode.asm"
    ENDIF

    include "./Maths/Utilities/XX12EquNodeDotOrientation.asm"
    include "./ModelRender/CopyXX12ToXX15.asm"
    include "./Maths/Utilities/ScaleXX16Matrix197.asm"
    include "./Universe/StarDust/StarRoutines.asm"
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
; The equipment tables (names, prices, tech levels, what's fitted) in main memory: the galaxy code (galaxy_equip_market)
; runs from slot 7 and the equip ship screen pages the galaxy into slot 7, so in their own slot 7 bank they read code
; bytes instead (the equip screen's list, the market's tech level pass and buying all used the wrong data)
    INCLUDE "./Tables/EquipmentTables.asm"
    INCLUDE "./Tables/name_digrams.asm"
; Include all maths libraries to test assembly
    INCLUDE "./Maths/asm_AddDEToCash.asm"
    DISPLAY ">24 bit mulitply routine, currently not bank 0 safe"
    INCLUDE "./Maths24/asm_mul24_notbank0safe.asm"
    DISPLAY ">Loading S78 Maths routines"
    INCLUDE "./MathsFPS78/asm_multiply_S78.asm"
 DISPLAY "Moved 24 bit maths to bank 0"
    INCLUDE "./Maths/asm_square.asm"
    INCLUDE "./Maths/asm_sine.asm"
    INCLUDE "./Maths/asm_sqrt.asm"
    INCLUDE "./Maths/asm_arctan.asm"
    INCLUDE "./Maths/SineTable.asm"
    INCLUDE "./Maths/ArcTanTable.asm"
    INCLUDE "./Maths/negate16.asm"
    INCLUDE "./Maths/asm_unitvector.asm"
    INCLUDE "./Maths/compare16.asm"
    INCLUDE "./Maths/asm_AequAdivQmul96.asm"
    INCLUDE "./Maths/Utilities/AequAmulQdiv256-FMLTU.asm"


    INCLUDE "./Maths/Utilities/APequQmulA-MULT1.asm"
    INCLUDE "./Maths/Utilities/badd_ll38.asm"


    include "./Universe/Ships/CopyRotMattoXX15.asm"
    include "./Universe/Ships/CopyXX15toRotMat.asm"
    INCLUDE "./GameEngine/Tactics.asm"
    INCLUDE "./Hardware/drive_access.asm"
MainNonBankedCodeEnd:
    DISPLAY "Main Non Banked Code Ends at ",$
;-- END OF MAIN NON BANKED CODE ---------------------------------------------------------
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

LAST_DELTA          db  0
SavedMMU6           db  0               ; use by interrupt handler only
SavedMMU7           db  0               ; use by interrupt handler only
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
                        ld      a,(GamePaused)              ; 16 bit 50Hz frame counter for game timers
                        and     a                           ; it stops while the game is paused
                        jr      nz,.FrameCountPaused        ; .
                        ld      hl,(FrameCounter16)         ; .
                        inc     hl                          ; .
                        ld      (FrameCounter16),hl         ; .
.FrameCountPaused:
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
                        call    AttractModeUpdate
                        RestoreMMU6
                        RestoreMMU7
                    ENDIF
                        ret

; ARCHIVED INCLUDE "Menus/draw_fuel_and_crosshair.asm"

; Blocks dependent on variables in Universe Banks
; Bank 49
;    SEG RESETUNIVSEG
;seg     CODE_SEG,       4:              $0000,       $8000                 ; flat address
;seg     RESETUNIVSEG,   BankResetUniv:  StartOfBank, ResetUniverseAddr


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
    INCLUDE "./Menus/system_map_menu.asm"
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
    INCLUDE "./Layer2Graphics/layer2_plot_circle.asm"
    INCLUDE "./Layer2Graphics/layer2_plot_circle_fill.asm"
    INCLUDE "./Layer2Graphics/BBCEliteDirectMappingLL118.asm"
    INCLUDE "./Layer2Graphics/l2_draw_any_line.asm"
    INCLUDE "./Layer2Graphics/l2_fill_polygon.asm"
    INCLUDE "./Layer2Graphics/l2_solid_hull.asm"
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
CopyFacesToUniv:
CopyFacesToUniv1:       McopyFacesToUniverse
ShipBankTable:
ShipBankTable1:         MShipBankTable
CopyShipToUniverse:
CopyShipToUniverse1     MCopyShipToUniverse     BankShipModels1
CopyBodyToUniverse:
CopyBodyToUniverse1:    MCopyBodyToUniverse     CopyShipToUniverse1
    INCLUDE "./Data/ShipModelMetaData1.asm"
    DISPLAY "Bank ",BankShipModels1," - Bytes free ",/D, $2000 - ($-ShipModelsAddr), " - BankShipModels1"
; Bank 66  ------------------------------------------------------------------------------------------------------------------------
; (was the equipment tables: they are in main memory now, see Tables/EquipmentTables.asm's include)
; Bank 67  ------------------------------------------------------------------------------------------------------------------------
    SLOT    ShipModelsAddr
    PAGE    BankShipModels2
	ORG     ShipModelsAddr, BankShipModels2

    INCLUDE "./Data/ShipBank2Label.asm"
GetShipBank2Id:         MGetShipBankId ShipBankTable2
CopyVertsToUniv2:       McopyVertsToUniverse
CopyEdgesToUniv2:       McopyEdgesToUniverse
CopyNormsToUniv2:       McopyNormsToUniverse
CopyFacesToUniv2:       McopyFacesToUniverse
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
CopyFacesToUniv3:       McopyFacesToUniverse
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
; Bank 83  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    SunBankAddr
                    PAGE    BankSunData
                    ORG	    SunBankAddr,BankSunData
                    INCLUDE "./Universe/Sun/sun_data.asm"
                    DISPLAY "Bank ",BankSunData," - Bytes free ",/D, $2000 - ($-SunBankAddr), " - BankSunData"
                    ASSERT $-SunBankAddr <8912, Bank code leaks over 8K boundary
; Bank 84  ------------------------------------------------------------------------------------------------------------------------
                    SLOT    PlanetBankAddr
                    PAGE    BankPlanetData
                    ORG	    PlanetBankAddr,BankPlanetData
                    INCLUDE "./Universe/Planet/planet_data.asm"
                    DISPLAY "Bank ",BankPlanetData," - Bytes free ",/D, $2000 - ($-PlanetBankAddr), " - BankPlanetData"
                    ASSERT $-PlanetBankAddr <8912, Bank code leaks over 8K boundary
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
; Bank 101  -----------------------------------------------------------
                    PAGE    BankSound
                    ORG SoundAddr, BankSound
                    INCLUDE "./Hardware/sound.asm"
                    DISPLAY "Sound ",BankSound," - Bytes free ",/D, $2000 - ($-SoundAddr), " - BankSound"
                    ASSERT $-SoundAddr <8912, Bank code leaks over 8K boundary
; Bank 102  -----------------------------------------------------------------------------------------------------------------------
                    SLOT    MathsBankedFnsAddr
                    PAGE    BankMathsBankedFns
                    ORG     MathsBankedFnsAddr,BankMathsBankedFns
                    DISPLAY "*** Maths24 - BankMathsBankedFns"
                    INCLUDE "./Maths24/asm_addition24.asm"
                    INCLUDE "./Maths24/asm_divide24.asm"
                    INCLUDE "./Maths24/asm_divide_helpers.asm"
                    INCLUDE "./Maths24/asm_rollpitch24_origin.asm"
                    INCLUDE "./Maths24/asm_compass24.asm"
                    INCLUDE "./Maths24/asm_normalise24.asm"
                    INCLUDE "./Maths24/asm_tidy24.asm"
                    INCLUDE "./Maths24/asm_sqrt24.asm"
                    DISPLAY ">Multiply is currently not bank 0 safe"
                    DISPLAY "*** ./Maths/MathsBankedFns.asm  - BankMathsBankedFns"
                    INCLUDE "./Maths/MathsBankedFns.asm"
                    DISPLAY "*** removed ./Maths/asm_tidy.asm - BankMathsBankedFns"
                    DISPLAY "*** ./Maths/normalise96.asm - BankMathsBankedFns"
                    INCLUDE "./Maths/normalise96.asm"
                    DISPLAY "Bank ",BankMathsBankedFns," - Bytes free ",/D, $2000 - ($-MathsBankedFnsAddr), " - BankMathsBankedFns"
                    ASSERT $-MathsBankedFnsAddr <8912, Bank code leaks over 8K boundary
    IFDEF REAL_HARDWARE
    SAVENEX OPEN "EliteNHW.nex", EliteNextStartup , TopOfStack
    SAVENEX CORE 3,3,0                              ; DMA+ needs core 3.03.00
    ELSE
    SAVENEX OPEN "EliteN.nex", EliteNextStartup , TopOfStack
    ENDIF
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    DISPLAY "Main Non Banked Code End ", MainNonBankedCodeEnd , " Bytes free ", 0B000H - MainNonBankedCodeEnd
    ASSERT MainNonBankedCodeEnd < 0B000H, Program code leaks intot interrup vector table
 