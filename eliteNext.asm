 DEVICE ZXSPECTRUMNEXT
 DEFINE  DOUBLEBUFFER 1
 DEFINE  LOGMATHS     1
 CSPECTMAP eliteN.map
 OPT --zxnext=cspect --syntax=a --reversepop

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
                        INCLUDE "./Tables/message_queue_macros.asm"
                        INCLUDE "./Variables/general_variables_macros.asm"
                        INCLUDE "./Variables/UniverseSlot_macros.asm"
                        
                        INCLUDE "./Data/ShipIdEquates.asm"
                        
InputMainMacro:         MACRO
                        call    ViewKeyTest
                        call    TestPauseMode
                        ld      a,(GamePaused)
                        cp      0
                        jr      nz,MainLoop
                        call    MovementKeyTest
                        ENDM

DecrementIfPossible:    MACRO   memaddr,notpossjp
                        JumpIfMemZero memaddr, notpossjp
                        dec     a
                        ld      (memaddr),a
                        ENDM
                        
UpdateOnCounter:        MACRO
                        DecrementIfPossible  CurrLaserPulseOnCount, .UpdateOnDone  
                        JumpIfAIsNotZero     .UpdateOnDone
                        ldCopyByte CurrLaserPulseOffTime, CurrLaserPulseOffCount
.UpdateOnDone:
                        ENDM

UpdateOffCounter:       MACRO
                        DecrementIfPossible  CurrLaserPulseOffCount,  .UpdateOffDone
                        JumpIfAIsNotZero     .UpdateOffDone
                        JumpIfMemNeMemusng   CurrLaserPulseRate, CurrLaserPulseRateCount, .UpdateOffDone
                        ldCopyByte CurrLaserPulseRest, CurrLaserPulseRestCount
.UpdateOffDone:
                        ENDM

UpdateRestCounter:      MACRO
                        DecrementIfPossible CurrLaserPulseRestCount, .UpdateRestDone                     ; if pulse rest > 0 then  pulse rest --                   
.DonePulseRest:         JumpIfMemNotZero CurrLaserPulseRestCount, .UpdateRestDone                        ; if pulse rest = 0
.ResetRate:             ZeroA                                                                           ;    then pulse rate count = 0
                        ld      (CurrLaserPulseRateCount),a                                             ;    .
.UpdateRestDone
                        ENDM


UpdateLaserCounters:    MACRO
                       
                        UpdateOnCounter
                        UpdateOffCounter
                        UpdateRestCounter
                        ENDM      

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
                        
                        
charactersetaddr		equ 15360
STEPDEBUG               equ 1

TopOfStack              equ $7F00

                        ORG         $8000
EliteNextStartup:       di
                        DISPLAY "Starting Assembly At ", EliteNextStartup
                        ; "STARTUP"
                        ; Make sure  rom is in page 0 during load
                        MMUSelectLayer2
                        call        asm_disable_l2_readwrite
                        MMUSelectROMS
.GenerateDefaultCmdr:   MMUSelectCommander
                        call		defaultCommander
                        call        saveCommander
                        MMUSelectLayer1
                        call		l1_cls
                        ld			a,7
                        call		l1_attr_cls_to_a
                        ld          a,$FF
                        call        l1_set_border
                        MMUSelectSpriteBank
                        call		sprite_load_sprite_data
Initialise:             MMUSelectLayer2
                        call 		l2_initialise
                        call        init_keyboard
                        ClearForceTransition
TidyDEBUG:              ld          a,16
                        ld          (TidyCounter),a
TestText:               xor			a
                        ld      (JSTX),a
DEBUGCODE:              ClearSafeZone ; just set in open space so compas treacks su n
                        MMUSelectSpriteBank
                        call		init_sprites
.ClearLayer2Buffers:    DoubleBufferIfPossible
                        DoubleBufferIfPossible
; Set up all 8 galaxies, 7later this will be pre built and loaded into memory from files                        
InitialiseGalaxies:     call		ResetUniv                       ; Reset ship data
                        call        ResetGalaxy                     ; Reset each galaxy copying in code
                        call        SeedAllGalaxies
StartAttractMode:       call        AttractMode
                        JumpIfAIsZero  .SkipDefault
                        MMUSelectCommander
                        call		defaultCommander
                        jp          InitialiseMainLoop:
.SkipDefault                        
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
NeedAMessageQueue:

;..................................................................................................................................
                        INCLUDE "./GameEngine/HyperSpaceTimers.asm"



;DisplayTargetAndRange
;DisplayCountDownNumber
;----------------------------------------------------------------------------------------------------------------------------------
TestPauseMode:          ld      a,(GamePaused)
                        cp      0
                        jr      nz,.TestForResume
.CheckViewMode:         ld      a,(ScreenIndex)                     ; we can only pause if not on screen view
                        ReturnIfAGTENusng       ScreenFront
.CheckPauseKey:         ld      a,c_Pressed_Freeze
                        call    is_key_pressed
                        ret     nz
.PausePressed:          SetAFalse                                  ; doesn't really matter if we were in pause already as resume is a different key
                        ld      (GamePaused),a
                        ret
.TestForResume:         ld      a,c_Pressed_Resume                  ; In pause loop so we can check for resume key
                        call    is_key_pressed
                        ret     nz
.ResumePressed:         xor     a             
                        ld      (GamePaused),a                      ; Resume pressed to reset pause state
                        ret

TestQuit:               ld      a,c_Pressed_Quit
                        call    is_key_pressed
                        ret
currentDemoShip:        DB      13;$12 ; 13 - corirollis 


GetStationVectorToWork: ld      hl,UBnKxlo
                        ld      de,varVector9ByteWork
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
                        call    normaliseXX1596fast 
                        ret                          ; will return with a holding Vector Z

TidyCounter             DB  0

            INCLUDE "./debugMatrices.asm"


;TODO Optimisation
; Need this table to handle differnet events 
; 1-main loop update - just general updates specfic to that screen that are not galaxy or stars, e.g. update heat, console
; cursor key, joystick press
; cursor key, joystick press
; non cursor keys presses
;
; First byte is now docked flag
; 
; Padded to 8 bytes to allow a * 8 for addressing    
; Byte 0   - Docked flag  : 0 = not applicable (always read), 1 = only whilst docked, 2 = only when not docked, 3 = No keypress allowed
; Byte 1   - Screen Id
; Byte 2,3 - address of keypress table
; Byte 4   - Bank with Display code
; Byte 5,6 - Function for display
; Byte 7,8 - Main loop update routine
; Byte 9   - Draw stars Y/N ; also are we in an external view that can have guns?
; byte 10  - Input Blocker (set to 1 will not allow keyboard screen change until flagged, used by transition screens and pause menus)
; byte 11  - Double Buffering 0 = no, 1 = yes
; byte 12,13  - cursor key input routine
; byte 14  - HyperspaceBlock - can not select this screen if in hyperpace - 00 can , 01 can not
; byte 15    padding at the momnent (should add in an "AI enabled flag" for optimistation, hold previous value and on change create ships
;
;                          0    1                 2                              3                               4                    5                            6                              7                     8                       9   10  11  12                          13                          14  15    
ScreenKeyMap:           DB 0,   ScreenLocal     , low addr_Pressed_LocalChart,   high addr_Pressed_LocalChart,   BankMenuShrCht,      low draw_local_chart_menu,   high draw_local_chart_menu,    $00,                  $00,                    $00,$00,$00,low local_chart_cursors,    high local_chart_cursors,   $01,$00;low loop_local_chart_menu,   high loop_local_chart_menu
ScreenKeyGalactic:      DB 0,   ScreenGalactic  , low addr_Pressed_GalacticChrt, high addr_Pressed_GalacticChrt, BankMenuGalCht,      low draw_galactic_chart_menu,high draw_galactic_chart_menu, low loop_gc_menu,     high loop_gc_menu,      $00,$00,$00,low galctic_chart_cursors,  high galctic_chart_cursors, $01,$00
                        DB 1,   ScreenMarket    , low addr_Pressed_MarketPrices, high addr_Pressed_MarketPrices, BankMenuMarket,      low draw_market_prices_menu, high draw_market_prices_menu,  low loop_market_menu, high loop_market_menu,  $00,$00,$00,$00,                        $00,                        $01,$00
                        DB 2,   ScreenMarketDsp , low addr_Pressed_MarketPrices, high addr_Pressed_MarketPrices, BankMenuMarket,      low draw_market_prices_menu, high draw_market_prices_menu,  $00,                  $00,                    $00,$00,$00,$00,                        $00,                        $01,$00
ScreenCmdr:             DB 0,   ScreenStatus    , low addr_Pressed_Status,       high addr_Pressed_Status,       BankMenuStatus,      low draw_status_menu,        high draw_status_menu,         low loop_STAT_menu,  high loop_STAT_menu,     $00,$00,$00,$00,                        $00,                        $01,$00
                        DB 0,   ScreenInvent    , low addr_Pressed_Inventory,    high addr_Pressed_Inventory,    BankMenuInvent,      low draw_inventory_menu,     high draw_inventory_menu,      $00,                  $00,                    $00,$00,$00,$00,                        $00,                        $01,$00
                        DB 0,   ScreenPlanet    , low addr_Pressed_PlanetData,   high addr_Pressed_PlanetData,   BankMenuSystem,      low draw_system_data_menu,   high draw_system_data_menu,    $00,                  $00,                    $00,$00,$00,$00,                        $00,                        $01,$00
                        DB 1,   ScreenEquip     , low addr_Pressed_Equip,        high addr_Pressed_Equip,        BankMenuEquipS,      low draw_eqshp_menu,         high draw_eqshp_menu,          low loop_eqshp_menu,  high loop_eqshp_menu,   $00,$00,$00,$00,                        $00,                        $01,$00
                        DB 1,   ScreenLaunch    , low addr_Pressed_Launch,       high addr_Pressed_Launch,       BankLaunchShip,      low draw_launch_ship,        high draw_launch_ship,         low loop_launch_ship, high loop_launch_ship,  $00,$01,$01,$00,                        $00,                        $01,$00
ScreenKeyFront:         DB 2,   ScreenFront     , low addr_Pressed_Front,        high addr_Pressed_Front,        BankFrontView,       low draw_front_view,         high draw_front_view,          low update_front_view,high update_front_view, $01,$00,$01,low input_front_view,      high input_front_view,       $00,$00
                        DB 2,   ScreenAft       , low addr_Pressed_Front,        high addr_Pressed_Front,        BankFrontView,       low draw_front_view,         high draw_front_view,          $00,                  $00,                    $01,$00,$01,low input_front_view,      high input_front_view,       $00,$00
                        DB 2,   ScreenLeft      , low addr_Pressed_Front,        high addr_Pressed_Front,        BankFrontView,       low draw_front_view,         high draw_front_view,          $00,                  $00,                    $01,$00,$01,low input_front_view,      high input_front_view,       $00,$00
                        DB 2,   ScreenRight     , low addr_Pressed_Front,        high addr_Pressed_Front,        BankFrontView,       low draw_front_view,         high draw_front_view,          $00,                  $00,                    $01,$00,$01,low input_front_view,      high input_front_view,       $00,$00
                        DB 3,   ScreenDocking   , $FF,                           $FF,                            BankLaunchShip,      low draw_docking_ship,       high draw_docking_ship,        low loop_docking_ship,high loop_docking_ship, $00,$01,$01,$00,                        $00,                        $01,$00
                        DB 1,   ScreenHyperspace, $FF,                           $FF,                            BankFrontView,       low draw_hyperspace,         high draw_hyperspace,          low loop_hyperspace,  high loop_hyperspace,   $00,$01,$01,$00

;               DB low addr_Pressed_Aft,          high addr_Pressed_Aft,          BankMenuGalCht,      low SelectFrontView,         high SelectFrontView,          $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;               DB low addr_Pressed_Left,         high addr_Pressed_Left,         BankMenuGalCht,      low SelectFrontView,         high SelectFrontView,          $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;               DB low addr_Pressed_Right,        high addr_Pressed_Right,        BankMenuGalCht,      low SelectFrontView,         high SelectFrontView,          $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
ScreenMapRow        EQU ScreenKeyGalactic - ScreenKeyMap
ScreenMapLen        EQU ($ - ScreenKeyMap) / ScreenMapRow
ScreenViewsStart    EQU (ScreenKeyFront - ScreenKeyMap)/ScreenMapRow
ScreenTransitionForced  DB $FF    
    INCLUDE "./GameEngine/resetUniverse.asm"


;----------------------------------------------------------------------------------------------------------------------------------
LaunchedFromStation:    MMUSelectSun
                        call    CreateSunLaunched                   ; create the local sun and set position based on seed
                        MMUSelectPlanet
                        call    CreatePlanetLaunched
                        call    ClearUnivSlotList
                        call    SetSlot0ToSpaceStation              ; set slot 1 to space station
                        MMUSelectUniverseN 0                        ; Prep Target universe
                        MMUSelectShipBank1                          ; Bank in the ship model code
                        ld      iyh,0                               ; Zero ship runtime data
                        ld      iyl,ShipTypeStation                 ; and mark as spece station
                        call    UnivInitRuntime                     ; its always slot 0
                        ld      a,CoriloisStation
                        call    GetShipBankId             
                        MMUSelectShipBankA                          ; Select the correct bank found
                        ld      a,b                                 ; Select the correct ship
                        call    CopyShipToUniverse
.BuiltStation:          call    ResetStationLaunch
.NowInFlight:           xor     a
                        ld      (DockedFlag),a
                        ForceTransition ScreenFront
                        call    ResetPlayerShip
                        ret
    
InitialiseCommander:    ld      a,(ScreenCmdr+1)
                        ld      ix,ScreenCmdr
                        jp      SetScreenAIX
                
InitialiseFrontView:    ld      a,(ScreenKeyFront+1)
                        ld      ix,ScreenKeyFront
                        jp      SetScreenAIX
; false ret here as we get it free from jp    

;----------------------------------------------------------------------------------------------------------------------------------
SetScreenAIX:           ld      (ScreenIndex),a                 ; Set screen index to a
                        ClearForceTransition                    ; In case it was called by a brute force change in an update loop
                        ld      (ScreenChanged),a               ; Set screen changed to FF                       
.IsItAViewPort:         ld      a,(ix+9)                        ; Screen Map Byte 9  - Draw stars Y/N and also guns present
                        ld      (CheckIfViewUpdate+1),a         ; Set flag to determine if we are on an exterior view
                        JumpIfAIsZero .NotViewPort              ;
                        ld      a,(ix+1)                        ; get screen view number
                        sub     ScreenFront                     ; Now a = screen number 0 = front, 1 = aft, 2 = left 3 = right
                        MMUSelectCommander                      ; Load view laser to current
                        call    LoadLaserToCurrent              ;
.NotViewPort:           ld      a,(ix+4)                        ; Screen Map Byte 4   - Bank with Display code
                        ld      (ScreenLoopBank+1),a            ; setup loop            
                        ld      (HandleBankSelect+1),a          ; setup cursor keys
                        MMUSelectScreenA
                        ld      a,(ix+5)                        ; Screen Map Byte 5 - Function for display
                        ld      (ScreenUpdateAddr+1),a
                        ld      a,(ix+6)                        ; Screen Map Byte 6 - Function for display
                        ld      (ScreenUpdateAddr+2),a
                        ld      a,(ix+7)                        ; Screen Map Byte 7 - Main loop update routine
                        ld      (ScreenLoopJP+1),a
                        ld      a,(ix+8)                        ; Screen Map Byte 8 - Main loop update routine
                        ld      (ScreenLoopJP+2),a   
                        ld      a,(ix+10)                       ; Screen Map Byte 10  - Input Blocker (set to 1 will not allow keyboard screen change until flagged, used by transition screens and pause menus)
                        ld      (InputBlockerCheck+1),a          ; Set flag to block transitions as needed e.g. launch screen    
                        ld      a,(ix+11)                       ; Screen Map Byte 11  - Double Buffering 0 = no, 1 = yes
                        ld      (DoubleBufferCheck+1),a
                        ld      a,(ix+12)
                        ld      (CallCursorRoutine+1),a
                        ld      a,(ix+13)
                        ld      (CallCursorRoutine+2),a
                      
ScreenUpdateAddr:       jp      $0000                          ; We can just drop out now and also get a free ret from caller
;----------------------------------------------------------------------------------------------------------------------------------                    
ViewKeyTest:            ld      a,(ScreenIndex)
                        ld      c,a
                        ld      b,ScreenMapLen                  ; For now until add screens are added
                        ld      ix,ScreenKeyMap
                        ld      hl,(InnerHyperCount)
                        ld      a,h
                        or      l
                        ld      iyh,a
ViewScanLoop:           ld      a,iyh
.HyperspaceCountdown:   and     a
                        jr      z,.DockedFlag
                        ld      a,(ix+14)
                        cp      1
                        jp      z,NotReadNextKey
.DockedFlag:            ld      a,(ix+0)                        ; Screen Map Byte 0 Docked flag 
; 0 = not applicable (always read), 1 = only whilst docked, 2 = only when not docked, 3 = No keypress allowed
                        cp      3                               ; if not selectable then don't scan this (becuase its a transition screen)
                        jr      z,NotReadNextKey                ; 
                        cp      0                               ; if itr a always read skip docking check
                        jr      z,.NoDocCheck
.DocCheck:              ld      d,a
                        ld      a,(DockedFlag)
                        cp      0                               ; if we are docked
                        jr      z,.NotDockedCheck
.DockedCheck:           ld      a,d
                        cp      1                               ; if we are docked and its a dock only then scan
                        jr      nz,NotReadNextKey
                        jr      .NoDocCheck
.NotDockedCheck:        ld      a,d
                        cp      2                               ; if we are not docked and its a flight only then scan
                        jr      nz,NotReadNextKey
.NoDocCheck:            ld      a,(ix+1)                        ; Screen Map Byte 1 Screen Id
                        cp      c                               ; is the index the current screen, if so skip the scan
                        ld      e,a
                        jr      z,NotReadNextKey   
                        ld      a,(ix+2)                        ; Screen Map Byte 2 - address of keypress table
                        cp      $FF                             ; if upper byte is FF then we do not respond
                        jr      z,NotReadNextKey
                        ld      (ReadKeyAddr+1),a               ; Poke address into the ld hl,(....) below
                        ld      a,(ix+3)                        ; Screen Map Byte 3 - address of keypress table
                        ld      (ReadKeyAddr+2),a
ReadKeyAddr:            ld      hl,($0000)                      ; address is entry in the pointer table to the actual keypress
                        ld      a,(hl)                          ; now fetch the actual keypress
                        JumpIfAIsZero NotReadNextKey
.ValidScreenChange:     ld      a,e
                        jp      SetScreenAIX
;--- CODE WILL NOT FALL TO HERE ---
NotReadNextKey:         ld      de,ScreenMapRow
                        add     ix,de                           ; we have only processed 3 of 8 bytes at here
                        djnz    ViewScanLoop
                        ret

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
;    call    Reset TODO
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
    include "./Menus/AttractMode.asm"

    include "./Maths/Utilities/XX12EquNodeDotOrientation.asm"
    include "./ModelRender/CopyXX12ToXX15.asm"	
    include "./ModelRender/CopyXX15ToXX12.asm"
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
    INCLUDE "./Hardware/keyboard.asm"
    
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
    
;;    INCLUDE "./Maths/addhldesigned.asm"
    INCLUDE "./Maths/asm_add.asm"
    INCLUDE "./Maths/Utilities/AddDEToCash.asm"
    INCLUDE "./Maths/DIVD3B2.asm"
    INCLUDE "./Maths/multiply.asm"
    INCLUDE "./Maths/asm_square.asm"
    INCLUDE "./Maths/asm_sqrt.asm"
    INCLUDE "./Maths/asm_divide.asm"
    INCLUDE "./Maths/asm_unitvector.asm"
    INCLUDE "./Maths/compare16.asm"
    INCLUDE "./Maths/negate16.asm"
    INCLUDE "./Maths/normalise96.asm"
    INCLUDE "./Maths/binary_to_decimal.asm"
;;    include "./Maths/ADDHLDESignBC.asm"    
;INCLUDE "badd_ll38.asm"
;;INCLUDE "XX12equXX15byXX16.asm"
    INCLUDE "./Maths/Utilities/AequAdivQmul96-TIS2.asm"
    INCLUDE "./Maths/Utilities/AequAmulQdiv256-FMLTU.asm"
    INCLUDE "./Maths/Utilities/PRequSpeedDivZZdiv8-DV42-DV42IYH.asm"
    INCLUDE "./Maths/Utilities/AequDmulEdiv256usgn-DEFMUTL.asm"
;INCLUDE "AP2equAPmulQunsgEorP-MLTU2.asm"
;INCLUDE "APequPmulQUnsg-MULTU.asm"
;INCLUDE "APequPmulX-MU11.asm"
    INCLUDE "./Maths/Utilities/APequQmulA-MULT1.asm"
    INCLUDE "./Maths/Utilities/badd_ll38.asm"
    INCLUDE "./Maths/Utilities/moveship4-MVS4.asm"
;INCLUDE "MoveShip5-MVS5.asm"
;INCLUDE "PAequAmulQusgn-MLU2.asm"
;INCLUDE "PAequDustYIdxYmulQ-MLU1.asm"
;INCLUDE "PlanetP12addInwkX-MVT6.asm"
    INCLUDE "./Maths/Utilities/RequAmul256divQ-BFRDIV.asm"
    INCLUDE "./Maths/Utilities/RequAdivQ-LL61.asm"
;    INCLUDE "./Maths/Utilities/RSequABSrs-LL129.asm"
    INCLUDE "./Maths/Utilities/RSequQmulA-MULT12.asm"
;INCLUDE "SwapRotmapXY-PUS1.asm"
    INCLUDE "./Maths/Utilities/tidy.asm"
    INCLUDE "./Maths/Utilities/LL28AequAmul256DivD.asm"    
    INCLUDE "./Maths/Utilities/XAequMinusXAPplusRSdiv96-TIS1.asm"
;INCLUDE "XAequQmuilAaddRS-MAD-ADD.asm"
;INCLUDE "XHiYLoequPA-gc3.asm"
;INCLUDE "XHiYLoequPmulAmul4-gc2.asm"
;INCLUDE "XLoYHiequPmulQmul4-gcash.asm"
;INCLUDE "XX12equXX15byXX16-LL51.asm"
  ;  INCLUDE "./Maths/Utilities/XYeqyx1loSmulMdiv256-Ll120-LL123.asm"

    INCLUDE "./GameEngine/Tactics.asm"
    INCLUDE "./Hardware/drive_access.asm"

    INCLUDE "./Menus/common_menu.asm"

EndOfNonBanked:
    DISPLAY "Non Banked Code Ends At", EndOfNonBanked

; ARCHIVED INCLUDE "Menus/draw_fuel_and_crosshair.asm"
;INCLUDE "./title_page.asm"

; Blocks dependent on variables in Universe Banks
; Bank 49
;    SEG RESETUNIVSEG
;seg     CODE_SEG,       4:              $0000,       $8000                 ; flat address
;seg     RESETUNIVSEG,   BankResetUniv:  StartOfBank, ResetUniverseAddr      



;	ORG ResetUniverseAddr
;INCLUDE "./GameEngine/resetUniverse.asm"
; Bank 50
         


    SLOT    MenuShrChtAddr
    PAGE    BankMenuShrCht
	ORG     MenuShrChtAddr,BankMenuShrCht
    INCLUDE "./Menus/short_range_chart_menu.asm"
; Bank 51

    SLOT    MenuGalChtAddr
    PAGE    BankMenuGalCht
	ORG     MenuGalChtAddr
    INCLUDE "./Menus//galactic_chart_menu.asm"
; Bank 52

    SLOT    MenuInventAddr
    PAGE    BankMenuInvent
	ORG     MenuInventAddr
    INCLUDE "./Menus/inventory_menu.asm"        

; Bank 53

    SLOT    MenuSystemAddr
    PAGE    BankMenuSystem
	ORG     MenuSystemAddr
    INCLUDE "./Menus/system_data_menu.asm"

; Bank 54	

    SLOT    MenuMarketAddr
    PAGE    BankMenuMarket
    ORG     MenuMarketAddr
    INCLUDE "./Menus/market_prices_menu.asm"

; Bank 66	

    SLOT    DispMarketAddr
    PAGE    BankDispMarket
    ORG     DispMarketAddr
    INCLUDE "./Menus/market_prices_disp.asm"

; Bank 55

    SLOT    StockTableAddr
    PAGE    BankStockTable
    ORG     StockTableAddr  
    INCLUDE "./Tables/stock_table.asm"

; Bank 57

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
    INCLUDE "./Layer2Graphics/asm_l2_plot_triangle.asm"
    INCLUDE "./Layer2Graphics/asm_l2_fill_triangle.asm"
    INCLUDE "./Layer2Graphics/layer2_plot_circle.asm"
    INCLUDE "./Layer2Graphics/layer2_plot_circle_fill.asm"
    INCLUDE "./Layer2Graphics/l2_draw_any_line.asm"
    INCLUDE "./Layer2Graphics/clearLines-LL155.asm"
    INCLUDE "./Layer2Graphics/l2_draw_line_v2.asm"
; Bank 56  ------------------------------------------------------------------------------------------------------------------------
    SLOT    CommanderAddr
    PAGE    BankCommander
    ORG     CommanderAddr, BankCommander
    INCLUDE "./Commander/commanderData.asm"
    INCLUDE "./Commander/zero_player_cargo.asm"
; Bank 58  ------------------------------------------------------------------------------------------------------------------------
    SLOT    LAYER1Addr
    PAGE    BankLAYER1
    ORG     LAYER1Addr, BankLAYER1

    INCLUDE "./Layer1Graphics/layer1_attr_utils.asm"
    INCLUDE "./Layer1Graphics/layer1_cls.asm"
    INCLUDE "./Layer1Graphics/layer1_print_at.asm"
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
GetShipBank1Id:        MGetShipBankId ShipBankTable
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

; Bank 60  ------------------------------------------------------------------------------------------------------------------------
    SLOT    SpritemembankAddr
    PAGE    BankSPRITE
	ORG     SpritemembankAddr, BankSPRITE
    INCLUDE "./Layer3Sprites/sprite_routines.asm"
    INCLUDE "./Layer3Sprites/sprite_load.asm"
    INCLUDE "./Layer3Sprites/SpriteSheet.asm"
; Bank 61  ------------------------------------------------------------------------------------------------------------------------
    SLOT    ConsoleImageAddr
    PAGE    BankConsole
	ORG     ConsoleImageAddr, BankConsole

    INCLUDE "./Images/ConsoleImageData.asm"
; Bank 62  ------------------------------------------------------------------------------------------------------------------------
    SLOT    ViewFrontAddr
    PAGE    BankFrontView
    ORG     ViewFrontAddr  
    INCLUDE "./Views/Front_View.asm"    
; Bank 63  ------------------------------------------------------------------------------------------------------------------------
    SLOT    MenuStatusAddr
    PAGE    BankMenuStatus
    ORG     MenuStatusAddr
    INCLUDE "./Menus/status_menu.asm"

; Bank 64  ------------------------------------------------------------------------------------------------------------------------

    SLOT    MenuEquipSAddr
    PAGE    BankMenuEquipS
    ORG     MenuEquipSAddr  
    INCLUDE "./Menus/equip_ship_menu.asm"    


    SLOT    LaunchShipAddr
    PAGE    BankLaunchShip
    ORG     LaunchShipAddr
    INCLUDE "./Transitions/launch_ship.asm"

; Bank 70  ------------------------------------------------------------------------------------------------------------------------
    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA0
	ORG	    UniverseBankAddr,BankUNIVDATA0
    INCLUDE "./Universe/Ships/univ_ship_data.asm"
    DISPLAY "Universe Data - Bytes free ",/D, $2000 - (UnivBankSize)
    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA1
	ORG	UniverseBankAddr,BankUNIVDATA1
UNIVDATABlock1      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA2
	ORG	UniverseBankAddr,BankUNIVDATA2
UNIVDATABlock2      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA3
	ORG	UniverseBankAddr,BankUNIVDATA3
UNIVDATABlock3      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA4
	ORG	UniverseBankAddr,BankUNIVDATA4
UNIVDATABlock4      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA5
	ORG	UniverseBankAddr,BankUNIVDATA5
UNIVDATABlock5      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA6
	ORG	UniverseBankAddr,BankUNIVDATA6
UNIVDATABlock6      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA7
	ORG	UniverseBankAddr,BankUNIVDATA7
UNIVDATABlock7      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA8
	ORG	UniverseBankAddr,BankUNIVDATA8
UNIVDATABlock8      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA9
	ORG	UniverseBankAddr,BankUNIVDATA9
UNIVDATABlock9      DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA10
	ORG	UniverseBankAddr,BankUNIVDATA10
UNIVDATABlock10     DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now

    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA11
	ORG	UniverseBankAddr,BankUNIVDATA11
UNIVDATABlock11     DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
                    
    SLOT    UniverseBankAddr
    PAGE    BankUNIVDATA12
	ORG	UniverseBankAddr,BankUNIVDATA12
UNIVDATABlock12     DB $FF
                    DS $1FFF                 ; just allocate 8000 bytes for now
 
; Bank 83  ------------------------------------------------------------------------------------------------------------------------
    SLOT    SunBankAddr
    PAGE    BankSunData
	ORG	    SunBankAddr,BankSunData
    INCLUDE "./Universe/Sun/sun_data.asm"

; Bank 84  ------------------------------------------------------------------------------------------------------------------------
    SLOT    PlanetBankAddr
    PAGE    BankPlanetData
	ORG	    PlanetBankAddr,BankPlanetData
    INCLUDE "./Universe/Planet/planet_data.asm"

; Bank 91  ------------------------------------------------------------------------------------------------------------------------
                        SLOT    GalaxyDataAddr
                        PAGE    BankGalaxyData0
                        ORG GalaxyDataAddr, BankGalaxyData0
                        INCLUDE "./Universe/Galaxy/galaxy_data.asm"                                                            
                        
                        DISPLAY "Galaxy Data - Bytes free ",/D, $2000 - ($- GalaxyDataAddr)

; Bank 92  ------------------------------------------------------------------------------------------------------------------------
                        SLOT    GalaxyDataAddr
                        PAGE    BankGalaxyData1
                        ORG GalaxyDataAddr, BankGalaxyData1
GALAXYDATABlock1         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now  
; Bank 93  ------------------------------------------------------------------------------------------------------------------------
                        SLOT    GalaxyDataAddr
                        PAGE    BankGalaxyData2
                        ORG GalaxyDataAddr, BankGalaxyData2
GALAXYDATABlock2         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
; Bank 94  ------------------------------------------------------------------------------------------------------------------------
                        SLOT    GalaxyDataAddr
                        PAGE    BankGalaxyData3
                        ORG GalaxyDataAddr, BankGalaxyData3
GALAXYDATABlock3         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
; Bank 95  ------------------------------------------------------------------------------------------------------------------------
                        SLOT    GalaxyDataAddr
                        PAGE    BankGalaxyData4
                        ORG GalaxyDataAddr, BankGalaxyData4
GALAXYDATABlock4         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
; Bank 96  ------------------------------------------------------------------------------------------------------------------------
                        SLOT    GalaxyDataAddr
                        PAGE    BankGalaxyData5
                        ORG GalaxyDataAddr,BankGalaxyData5
GALAXYDATABlock5         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
; Bank 97  ------------------------------------------------------------------------------------------------------------------------
                        SLOT    GalaxyDataAddr
                        PAGE    BankGalaxyData6
                        ORG GalaxyDataAddr,BankGalaxyData6
GALAXYDATABlock6         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
; Bank 98  ------------------------------------------------------------------------------------------------------------------------
                        SLOT    GalaxyDataAddr
                        PAGE    BankGalaxyData7
                        ORG GalaxyDataAddr,BankGalaxyData7
GALAXYDATABlock7         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
; Bank 99  ------------------------------------------------------------------------------------------------------------------------
                        SLOT    MathsTablesAddr
                        PAGE    BankMathsTables
                        ORG     MathsTablesAddr,BankMathsTables
                        INCLUDE "./Maths/logmaths.asm"
                        INCLUDE "./Tables/antilogtable.asm"
                        INCLUDE "./Tables/logtable.asm"

    
    SAVENEX OPEN "EliteN.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    