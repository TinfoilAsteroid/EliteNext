 DEVICE ZXSPECTRUMNEXT
 DEVICE ZXSPECTRUMNEXT
 DEVICE ZXSPECTRUMNEXT
 DEFINE  DOUBLEBUFFER 1
 CSPECTMAP eliteNext.map
 OPT --zxnext=cspect --syntax=a

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
    
    INCLUDE "./Macros/MMUMacros.asm"
    INCLUDE "./Macros/ShiftMacros.asm"
    INCLUDE "./Macros/CopyByteMacros.asm"
    INCLUDE "./Macros/GeneralMacros.asm"
    INCLUDE "./Macros/ldCopyMacros.asm"
    INCLUDE "./Macros/ldIndexedMacros.asm"


charactersetaddr		equ 15360
STEPDEBUG               equ 1


                        ORG         $8000
                        di
                        ; "STARTUP"
                        MMUSelectLayer1
                        call		l1_cls
                        ld			a,7
                        call		l1_attr_cls_to_a
                        ld          a,$FF
                        call        l2_set_border
                        MMUSelectSpriteBank
                        call		sprite_load_sprite_data
Initialise:             MMUSelectLayer2
                        call 		l2_initialise
                        ld          a,$FF
                        ld          (ScreenTransitionForced),a

TestText:               xor			a
                        ld      (JSTX),a
                        MMUSelectCmdrData
                        call		defaultCommander
                        
                        MMUSelectSpriteBank
                        call		init_sprites
                        
                        MMUSelectStockTable
                        call		generate_stock_market ; Normally done on jump to system and start up, should be written on load save to stop market price cheating

                        IFDEF DOUBLEBUFFER
                            MMUSelectLayer2
                            call        l2_cls
                            call  l2_flip_buffers
                        ENDIF

                        ;MMUSelectResetUniv
                        call		ResetUniv:   
                        call        ResetGalaxy
                        MMUSelectGalaxyN 0
                        call        SeedGalaxy

                        MMUSelectLayer2
                        MMUSelectUniverseN 0
                        call        l2_cls
                        IFDEF DOUBLEBUFFER    
                            MMUSelectLayer2
                            call  l2_flip_buffers
                        ENDIF    

InitialiseDemoShip:     ld      a,(currentDemoShip)
                        MMUSelectUniverseN 0                          ; load up register into universe bank
                        call    ResetUBnkData                         ; call the routine in the paged in bank, each universe bank will hold a code copy local to it
                        MMUSelectShipModelsA
                        ld		a,(currentDemoShip)
                        call    CopyShipDataToUBnk
                        ld      a,3
                        ld      (MenuIdMax),a
                        ld      a,$FF                               ; Starts Docked
                        ld      (DockedFlag),a
;                        call    InitialiseFrontView
                        call    InitialiseCommander
                        MMUSelectUniverseN 0    
                        call    SetInitialShipPosition
;..................................................................................................................................
MainLoop:	            call    doRandom                            ; redo the seeds every frame
                        call    scan_keyboard
DemoOfShipsDEBUG:       call    TestForNextShip
ScreenTransBlock:       ld      a,$0
                        cp      1
                        jp      z,CheckIfViewUpdate                 ; as we are in a transition the whole update AI is skipped
                        call    ViewKeyTest
                        call    TestPauseMode
                        ld      a,(GamePaused)
                        cp      0
                        jr      nz,MainLoop
                        ld      a,(DockedFlag)
                        cp      0
                        ;call    z,ThrottleTest                      ; only use throttle if flying, may expand the logic to include hyperspace, not sure yet
                        call    MovementKeyTest
;Process cursor keys for respective screen    
HandleMovement:         ld      a,(CallCursorRoutine+2)
                        IfAIsZeroGoto     UpdateUniverseSpeed
HandleBankSelect:       ld      a,$00
                        MMUSelectScreenA
CallCursorRoutine:      call    $0000
; need to optimise so not looping over agint for all universe doign ingle updates
UpdateUniverseSpeed:    MMUSelectUniverseN 0
                        call    TestRollLoop
                        ld      a,(DELTA)
                        ld      d,0
                        ld      e,a
                        ld      hl,(UBnKzlo)
                        ld      a,(UBnKzsgn)
                        ld      b,a
                        ld      c,$80
                        call    ADDHLDESignBC
                        ld      (UBnKzlo),hl
                        ld      (UBnKzsgn),a
                        call    ApplyMyRollAndPitch
                       call    DEBUGSETNODES
                      ;  call    DEBUGSETPOS
                        call   ProcessNodes
DrawShipTest:           MMUSelectLayer1
                        ld     a,$DF
                        ld     (line_gfx_colour),a 
CheckIfViewUpdate:      ld      a,$00
                        cp      0
                        jr      z, MenusLoop; This will change as more screens are added TODO
SpecificCodeWhenInView: ;call   SetAllFacesVisible
                        call   BackFaceCull				; culling but over aggressive backface assumes all 0 up front TOFIX
                        call   PrepLines                   ; LL72, process lines and clip, ciorrectly processing face visibility now
                        MMUSelectLayer2
                        call   l2_cls
                        MMUSelectUniverseN 0    
                        call   DrawLines                   ; Need to plot all lines
DrawStars:              call   StarsForward
                        MMUSelectViewFront    
                        call   UpdateConsole
                        jp LoopRepeatPoint
MenusLoop:              ld      hl,(ScreenLoopJP+1)
                        ld      a,h
                        or      l
                        jp      z,LoopRepeatPoint
ScreenLoopBank:         ld      a,$0
                        MMUSelectScreenA
ScreenLoopJP:           call    $0000
LoopRepeatPoint:
DoubleBufferCheck:      ld      a,00
                        IFDEF DOUBLEBUFFER
                            cp      0
                            jp      z,MainLoop
                            MMUSelectLayer2
                            ld     a,(varL2_BUFFER_MODE)
                            cp     0
                            call   nz,l2_flip_buffers
                        ENDIF
                        ld      a,(ScreenTransitionForced)          ; was there a bruite force screen change in any update loop
                        cp      $FF
                        jp      z,MainLoop
.BruteForceChange:      ld      d,a
                        ld      e,ScreenMapRow
                        mul
                        ld      ix,ScreenKeyMap
                        add     ix,de                               ; Force screen transition
                        call    SetScreenAIX
                        jp MainLoop
;..................................................................................................................................
	;call		keyboard_main_loop
    
TestForNextShip:        ld      a,c_Pressed_Quit
                        call    is_key_pressed
                        ret     nz
                        ld      a,(currentDemoShip)
                        inc     a
                        cp      44
                        jr      nz,.TestOK
                        xor     a
.TestOK:                ld      (currentDemoShip),a
                        MMUSelectUniverseN 0
                        call    ResetUBnkData                         ; call the routine in the paged in bank, each universe bank will hold a code copy local to it
                        ld      a,(currentDemoShip)
                        MMUSelectShipModelsA
                        call    CopyShipDataToUBnk
                        call    SetInitialShipPosition
                        ret

TestPauseMode:          ld      a,(GamePaused)
                        cp      0
                        jr      nz,.TestForResume
.CheckViewMode:         ld      a,(ScreenIndex)                     ; we can only pause if not on screen view
                        ReturnIfAGTENusng       ScreenFront
.CheckPauseKey:         ld      a,c_Pressed_Freeze
                        call    is_key_pressed
                        ret     nz
.PausePressed:          ld      a,$FF                               ; doesn't really matter if we were in pause already as resume is a different key
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
currentDemoShip:        DB 0


DEBUGSETNODES:          ld      hl,DEBUGUBNKDATA
                        ld      de,UBnKxlo
                        ld      bc,9
                        ldir
                        ld      hl,DEBUGROTMATDATA
                        ld      de,UBnkrotmatSidevX
                        ld      bc,6*3
                        ldir
                        
                        ret
DEBUGSETPOS:            ld      hl,DEBUGUBNKDATA 
                        ld      de,UBnKxlo 
                        ld      bc,9 - 3
                        ldir
                        ret

; FAILS due to sharp angle, OK now
;DEBUGUBNKDATA:          db      $39,	$01,	$00,	$43,	$01,	$00,	$EF,	$03,	$00
;DEBUGROTMATDATA:        db      $01,	$2F,	$B2,	$CC,	$4C,	$27
;                        db      $17,	$46,	$87,	$3C,	$95,	$20
;                        db      $E2,	$32,	$31,	$8C,	$EF,	$D1
; TOP RIGHT CORNER Passes as python and cobra
;DEBUGUBNKDATA:          db      $39,	$01,	$00,	$43,	$01,	$00,	$5B,	$04,	$00
;DEBUGROTMATDATA:        db      $E2,	$03,	$3A,	$16,	$F5,	$60
;                        db      $D3,	$CE,	$F3,	$BA,	$4E,	$0F
;                        db      $03,	$BE,	$4A,	$4B,	$DB,	$8C
; Looks OK
;DEBUGUBNKDATA:          db      $39,    $01,    $00,    $43,    $01,    $00,    $EE,    $02,    $00
;DEBUGROTMATDATA:        db      $35,    $d8,    $98,    $9f,    $b0,    $1a
;                        db      $4B,    $26,    $CE,    $d6,    $60,    $16
;                        db      $89,    $90,    $c4,    $9f,    $dd,    $d9
;
; Massive horizontal line
; 15th line (or line 14 has corrodinates 05,00 to D8,00) which looks wrong
; node array looks OK, looks liek its sorted as it was both -ve Y off screen fix added
;DEBUGUBNKDATA:          db      $39,    $01,    $00,    $43,    $01,    $00,    $BD,    $03,    $00
;DEBUGROTMATDATA:        db      $59,    $CF,    $06,    $B6,    $61,    $8D
;                        db      $AD,    $B1,    $97,    $4F,    $C9,    $98
;                        db      $61,    $99,    $E0,    $0D,    $11,    $5C
; Line lost in clipping 
;DEBUGUBNKDATA:          db      $39,    $01,    $00,    $43,    $01,    $00,    $8B,    $04,    $00
;DEBUGROTMATDATA:        db      $A3,    $4D,    $A9,    $28,    $F8,    $AF
;                        db      $FB,    $97,    $8C,    $B5,    $FB,    $D0
;                        db      $DB,    $3A,    $29,    $CA,    $29,    $1C
;DEBUGUBNKDATA:          db      $5E,    $02,    $00,    $FE,    $00,    $FE,    $E5,    $09,    $00
;DEBUGROTMATDATA:        db      $A6,    $88,    $89,    $BB,    $53,    $4D
;                        db      $6D,    $D9,    $F0,    $99,    $BA,    $9E
;                        db      $4A,    $A8,    $89,    $47,    $DF,    $33
;            
;DEBUGUBNKDATA:          db      $ED,    $05,    $00,    $FE,    $00,    $FE,    $F1,    $0A,    $00
;DEBUGROTMATDATA:        db      $1B,    $33,    $DE,    $B4,    $ED,    $C5
;                        db      $73,    $C4,    $BC,    $1E,    $96,    $C4
;                        db      $55,    $B9,    $35,    $D1,    $80,    $0F
; top left off right issue
;DEBUGUBNKDATA:          db      $39,    $01,    $00,    $43,    $01,    $00,    $2F,    $03,    $00
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
; test middle of screen
;DEBUGUBNKDATA:          db      $00,    $00,    $00,    $00,    $00,    $00,    $20,    $01,    $00
;          
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
; test middle of screen futher away
DEBUGUBNKDATA:          db      $00,    $00,    $00,    $00,    $00,    $00,    $20,    $02,    $00
          
DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
                        db      $E6,    $01,    $81,    $AD,    $B0,    $55

; Test left center clip still warping
;DEBUGUBNKDATA:          db      $80,    $00,    $80,    $00,    $00,    $00,    $20,    $01,    $00
;          
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
; Test right center clip - seems to be warping values towards bottom of screen on clip
;DEBUGUBNKDATA:          db      $80,    $00,    $00,    $00,    $00,    $00,    $20,    $01,    $00
;          
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
; Test top center clip test 1 - good test many ships fail
;DEBUGUBNKDATA:          db      $19,    $00,    $00,    $50,    $00,    $00,    $20,    $01,    $00
;          
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
; Test top center clip test 2 - Poss 2nd ship has an issue with a small line
;*DEBUGUBNKDATA:          db      $19,    $00,    $00,    $60,    $00,    $00,    $2F,    $01,    $00
;*          
;*DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;*                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;*                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
; Test bottom center clip ; complet shambles as if its forcing cip to below 128
; looks better now may have some clipping issues maybe ship data
;DEBUGUBNKDATA:          db      $19,    $00,    $00,    $50,    $00,    $80,    $20,    $01,    $00
;          
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
; Test left top center clip

; Test right top center clip
; Test left bottom center clip
; Test right bottom center clip

; Tests with no clip
;DEBUGUBNKDATA:          db      $39,    $00,    $00,    $43,    $00,    $00,    $2F,    $04,    $00
;          
;DEBUGROTMATDATA:        db      $FD,    $50,    $47,    $B0,    $53,    $9A
;                        db      $73,    $B7,    $98,    $C8,    $80,    $A3
;                        db      $E6,    $01,    $81,    $AD,    $B0,    $55
;
;DEBUGUBNKDATA:          db      $00,    $00,    $00,    $00,    $00,    $00,    $1F,    $00,    $00
;      
; UBNKPOs example 39,01,00,43,01,00,f4,03,00
; rotmat  example b1, 83,ae,5d,b0,1a,5e,de,82,8a,69,16,70,99,52,19,dd,d9


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
; Byte 0 - Docked flag  : 0 = not applicable, 1 = only whilst docked, 2 = only when not docked
; Byte 1 - Screen Id
; Byte 2,3 - address of keypress table
; Byte 4   - Bank with Display code
; Byte 5,6 - Function for display
; Byte 7,8 - Main loop update routine
; Byte 9   - Draw stars Y/N
; byte 10  - Input Blocker (set to 1 will not allow keyboard screen change until flagged, used by transition screens and pause menus)
; byte 11  - Double Buffering 0 = no, 1 = yes
; byte 12,13  - cursor key input 
;                          0    1                 2                              3                               4                    5                            6                              7                     8                       9   10  11  12                          13                          14  15    
ScreenKeyMap:           DB 0,   ScreenLocal     , low addr_Pressed_LocalChart,   high addr_Pressed_LocalChart,   BankMenuShrCht,      low draw_local_chart_menu,   high draw_local_chart_menu,    $00,                  $00,                    $00,$00,$00,low local_chart_cursors,    high local_chart_cursors,   $00,$00;low loop_local_chart_menu,   high loop_local_chart_menu
ScreenKeyGalactic:      DB 0,   ScreenGalactic  , low addr_Pressed_GalacticChrt, high addr_Pressed_GalacticChrt, BankMenuGalCht,      low draw_galactic_chart_menu,high draw_galactic_chart_menu, low loop_gc_menu,     high loop_gc_menu,      $00,$00,$00,low galctic_chart_cursors,  high galctic_chart_cursors, $00,$00
                        DB 1,   ScreenMarket    , low addr_Pressed_MarketPrices, high addr_Pressed_MarketPrices, BankMenuMarket,      low draw_market_prices_menu, high draw_market_prices_menu,  low loop_market_menu, high loop_market_menu,  $00,$00,$00,$00,$00,$00,$00
                        DB 2,   ScreenMarketDsp , low addr_Pressed_MarketPrices, high addr_Pressed_MarketPrices, BankMenuMarket,      low draw_market_prices_menu, high draw_market_prices_menu,  $00,                  $00,                    $00,$00,$00,$00,$00,$00,$00
ScreenCmdr:             DB 0,   ScreenStatus    , low addr_Pressed_Status,       high addr_Pressed_Status,       BankMenuStatus,      low draw_status_menu,        high draw_status_menu,         low loop_STAT_menu,  high loop_STAT_menu,     $00,$00,$00,$00,$00,$00,$00
                        DB 0,   ScreenInvent    , low addr_Pressed_Inventory,    high addr_Pressed_Inventory,    BankMenuInvent,      low draw_inventory_menu,     high draw_inventory_menu,      $00,                  $00,                    $00,$00,$00,$00,$00,$00,$00
                        DB 0,   ScreenPlanet    , low addr_Pressed_PlanetData,   high addr_Pressed_PlanetData,   BankMenuSystem,      low draw_system_data_menu,   high draw_system_data_menu,    $00,                  $00,                    $00,$00,$00,$00,$00,$00,$00
                        DB 1,   ScreenEquip     , low addr_Pressed_Equip,        high addr_Pressed_Equip,        BankMenuEquipS,      low draw_eqshp_menu,         high draw_eqshp_menu,          low loop_eqshp_menu,  high loop_eqshp_menu,   $00,$00,$00,$00,$00,$00,$00
                        DB 1,   ScreenLaunch    , low addr_Pressed_Launch,       high addr_Pressed_Launch,       BankLaunchShip,      low draw_launch_ship,        high draw_launch_ship,         low loop_launch_ship, high loop_launch_ship,  $00,$01,$01,$00,$00,$00,$00
ScreenKeyFront:         DB 2,   ScreenFront     , low addr_Pressed_Front,        high addr_Pressed_Front,        BankFrontView,       low draw_front_view,         high draw_front_view,          $00,                  $00,                    $01,$00,$01,low input_front_view,      high input_front_view,       $00,$00
;               DB low addr_Pressed_Aft,          high addr_Pressed_Aft,          BankMenuGalCht,      low SelectFrontView,         high SelectFrontView,          $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;               DB low addr_Pressed_Left,         high addr_Pressed_Left,         BankMenuGalCht,      low SelectFrontView,         high SelectFrontView,          $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;               DB low addr_Pressed_Right,        high addr_Pressed_Right,        BankMenuGalCht,      low SelectFrontView,         high SelectFrontView,          $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
ScreenMapRow        EQU ScreenKeyGalactic - ScreenKeyMap
ScreenMapLen        EQU ($ - ScreenKeyMap) / ScreenMapRow
ScreenViewsStart    EQU (ScreenKeyFront - ScreenKeyMap)/ScreenMapRow
ScreenTransitionForced  DB $FF    
    INCLUDE "./GameEngine/resetUniverse.asm"

    
InitialiseCommander:    ld      a,(ScreenCmdr+1)
                        ld      ix,ScreenCmdr
                        jp      SetScreenAIX
                
InitialiseFrontView:    ld      a,(ScreenKeyFront+1)
                        ld      ix,ScreenKeyFront
                        jp      SetScreenAIX
; false ret here as we get it free from jp    

;----------------------------------------------------------------------------------------------------------------------------------
SetScreenAIX:           ld      (ScreenIndex),a                 ; Set screen index to ixl
                        xor     a
                        dec     a                               ; set A to FF
                        ld      (ScreenTransitionForced),a      ; In case it was called by a brute force change in an update loop
                        ld      (ScreenChanged),a               ; Set screen changed to FF
                        ld      a,(ix+4)                        ; Screen Map Byte 4   - Bank with Display code
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
                        ld      a,(ix+9)                        ; Screen Map Byte 9  - Draw stars Y/N
                        ld      (CheckIfViewUpdate+1),a         ; Set flag to determine if we are on an exterior view
                        ld      a,(ix+10)                       ; Screen Map Byte 10  - Input Blocker (set to 1 will not allow keyboard screen change until flagged, used by transition screens and pause menus)
                        ld      (ScreenTransBlock+1),a          ; Set flag to block transitions as needed e.g. launch screen    
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
ViewScanLoop:           ld      a,(ix+0)                        ; Screen Map Byte 0 Docked flag
                        cp      0
                        jr      z,.NoDocCheck
.DocCheck:              ld      d,a
                        ld      a,(DockedFlag)
                        cp      0
                        jr      z,.NotDockedCheck
.DockedCheck:           ld      a,d
                        cp      1
                        jr      nz,NotReadNextKey
                        jr      .NoDocCheck
.NotDockedCheck:        ld      a,d
                        cp      2
                        jr      nz,NotReadNextKey
.NoDocCheck:            ld      a,(ix+1)                        ; Screen Map Byte 1 Screen Id
                        cp      c                               ; is the index the current screen, if so skip the scan
                        ld      e,a
                        jr      z,NotReadNextKey   
                        ld      a,(ix+2)                        ; Screen Map Byte 2 - address of keypress table
                        ld      (ReadKeyAddr+1),a               ; Poke address into the ld hl,(....) below
                        ld      a,(ix+3)                        ; Screen Map Byte 3 - address of keypress table
                        ld      (ReadKeyAddr+2),a
ReadKeyAddr:            ld      hl,($0000)                      ; address is entry in the pointer table to the actual keypress
                        ld      a,(hl)                          ; now fetch the actual keypress
                        IfAIsZeroGoto NotReadNextKey
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
                        ld      hl,$0F04
                        ld      (UBnKzlo),hl
                        xor     a
                        ld      (UBnKxsgn),a
                        ld      (UBnKysgn),a
                        ld      (UBnKzsgn),a
;    call    Reset TODO
                        call	InitialiseOrientation            ;#00;
                        ld      a,8
                        ld      (DELTA),a
                        ld      hl,16
                        ld      (DELTA4),hl
                        ret    

Draw3Lines:             ld      e,16
                        push    bc,,de
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        pop     bc,,de
                        dec     b
                        push    bc,,de
                        ld      e,20
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        pop     bc,,de
                        dec     b    
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        ret

UpdateConsole:          ld      a,(DELTA)
                        cp      0                           ; don't draw if there is nothing to draw
                        jr      z,.UpdateRoll   
                        ld      bc,SpeedoStart
                        ld      hl,SpeedoMapping
                        add     hl,a
                        ld      d,(hl)
                        call    Draw3Lines
.UpdateRoll:            ld      a,(ALP1)
                        cp      0
                        jr      z,.UpdatePitch
                        ld      hl,RollMiddle
                        ld      a,(ALP2)
                        cp      0
                        jr      z,.PosRoll
.NegRoll:               ld      d,0
                        ld      a,(ALP1)
                        sla     a
                        ld      e,a
                        or      a
                        sbc     hl,de
                        ld      bc,hl
                        ld      a,DialMiddleXPos
                        sub     c
                        ld      d,a
                        ld      e,$FF
                        call    Draw3Lines
                        jr      .UpdatePitch
.PosRoll:               ld      bc,RollMiddle
                        ld      a,(ALP1)
                        sla     a
                        ld      d,a
                        ld      e,$FF
                        call    Draw3Lines
.UpdatePitch:           ld      a,(BET1)
                        cp      0
                        jr      z,.DoneConsole
                        ld      hl,PitchMiddle
                        ld      a,(BET2)
                        cp      0
                        jr      z,.PosPtich
.NegPitch:              ld      d,0
                        ld      a,(BET1)
                        sla     a
                        ld      e,a
                        or      a
                        sbc     hl,de
                        ld      bc,hl
                        ld      a,DialMiddleXPos
                        sub     c
                        ld      d,a
                        ld      e,$FF
                        call    Draw3Lines
                        jr      .DoneConsole
.PosPtich:              ld      bc,PitchMiddle
                        ld      a,(BET1)
                        sla     a
                        ld      d,a
                        ld      e,$FF
                        call    Draw3Lines
.DoneConsole:           call    UpdateRadar
                        ret
    
ScannerX equ 128
ScannerY equ 171 

; This will go though all the universe ship data banks and plot, for now we will just work on one bank
UpdateScannerShip:      ld      bc,(UBnKzhi)
                        ld      a,c
                        and     $C0
                        ret     nz
                        ld      de,(UBnKxhi)
                        ld      a,e
                        and     $C0
                        ret     nz
                        ld      hl,(UbnKyhi)
                        ld      a,l
                        and     $C0
                        ret     nz
                        ld      a,ScannerX
                        JumpOnBitSet d,7,ScannerNegX
                        add     a,e
                        jp      ScannerZCoord
ScannerNegX:            sub     e
ScannerZCoord:          ld      e,a
                        srl     c
                        srl     c
                        ld      a,ScannerY
                        JumpOnBitSet b,7,ScannerNegZ
                        sub     c
                        jp      ScannerYCoord
ScannerNegZ:            add     a,c
ScannerYCoord:          ld      d,a                     ; now de = pixel pos d = y e = x  for base of stick X & Z , so need Y Stick height
                        JumpOnBitSet h,7,ScannerStickDown
                        sub     l                       ; a already holds actual Y
                        JumpIfAGTENusng 128,ScannerHeightDone
                        ld      a,128
                        jp      ScannerHeightDone
ScannerStickDown:       add     a,l     
                        JumpIfAGTENusng 191,ScannerHeightDone
                        ld      a,191
ScannerHeightDone:      ld      c,e            ; Now sort out line from point DE horzontal by a
                        ld      b,d
                        ld      d,a
                        cp      b
                        jp      z,Scanner0Height
                        ld      e,194 ; Should be coloured based on status but this will do for now
                        push    bc
                        push    de
                        MMUSelectLayer2  
                        call    l2_draw_vert_line_to
                        pop     de
                        pop     bc
Scanner0Height:         ld      b,d
                        push    bc
                        ld      a,255
                        MMUSelectLayer2  
                        call    l2_plot_pixel
                        pop     bc
                        inc     c
                        ld      a,255
                        MMUSelectLayer2  
                        call    l2_plot_pixel
                        ret

UpdateRadar:            MMUSelectUniverseN 0                          ; load up register into universe bank
                        call    UpdateScannerShip
                        ret

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



            
    include "./ModelRender/testdrawing.asm"
    include "./Universe/StarRoutines.asm"
;    include "Universe/move_object-MVEIT.asm"
    include "./ModelRender/draw_object.asm"
    include "./ModelRender/draw_ship_point.asm"
    include "./ModelRender/drawforwards-LL17.asm"
    
    INCLUDE	"./Hardware/memfill_dma.asm"
    INCLUDE	"./Hardware/memcopy_dma.asm"
    INCLUDE "./Hardware/keyboard.asm"
    
    INCLUDE "./Variables/constant_equates.asm"
    INCLUDE "./Variables/general_variables.asm"
    INCLUDE "./Variables/EquipmentVariables.asm"
    
    INCLUDE "./Variables/random_number.asm"
    INCLUDE "./Variables/galaxy_seed.asm"
    INCLUDE "./Tables/text_tables.asm"
    INCLUDE "./Tables/dictionary.asm"
    INCLUDE "./Tables/name_digrams.asm"
;INCLUDE "Tables/inwk_table.asm" This is no longer needed as we will write to univer object bank

; Include all maths libraries to test assembly
    INCLUDE "./Maths/addhldesigned.asm"
    INCLUDE "./Maths/addhlasigned.asm"
    INCLUDE "./Maths/Utilities/AddDEtoCash.asm"
    INCLUDE "./Maths/multiply.asm"
    INCLUDE "./Maths/asm_square.asm"
    INCLUDE "./Maths/asm_sqrt.asm"
    INCLUDE "./Maths/asm_divide.asm"
    INCLUDE "./Maths/asm_unitvector.asm"
    INCLUDE "./Maths/compare16.asm"
    INCLUDE "./Maths/negate16.asm"
    INCLUDE "./Maths/normalise96.asm"
    INCLUDE "./Maths/binary_to_decimal.asm"
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


    INCLUDE "./Drive/drive_access.asm"

    INCLUDE "./Menus/common_menu.asm"
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
    SLOT    CMDRDATAAddr
    PAGE    BankCmdrData
    ORG     CMDRDATAAddr, BankCmdrData
    INCLUDE "./Commander/CommanderData.asm"
    INCLUDE "./Commander/zero_player_cargo.asm"
; Bank 58  ------------------------------------------------------------------------------------------------------------------------
    SLOT    LAYER1Addr
    PAGE    BankLAYER1
    ORG     LAYER1Addr, BankLAYER1

    INCLUDE "./Layer1Graphics/layer1_attr_utils.asm"
    INCLUDE "./Layer1Graphics/layer1_cls.asm"
    INCLUDE "./Layer1Graphics/layer1_print_at.asm"
; Bank 59  ------------------------------------------------------------------------------------------------------------------------
    SLOT    ShipModelsAddr
    PAGE    BankShipModelsA
	ORG     ShipModelsAddr, BankShipModelsA
    DEFINE  SHIPBANKA 1
    INCLUDE "./Data/ShipModels.asm"
; Bank 67  ------------------------------------------------------------------------------------------------------------------------
    SLOT    ShipModelsAddr
    PAGE    BankShipModelsB
	ORG     ShipModelsAddr, BankShipModelsB
    UNDEFINE SHIPBANKA
    DEFINE   SHIPBANKB 1  
    INCLUDE "./Data/ShipModels.asm"
; Bank 68  ------------------------------------------------------------------------------------------------------------------------
    SLOT    ShipModelsAddr
    PAGE    BankShipModelsC
	ORG     ShipModelsAddr, BankShipModelsC
    UNDEFINE SHIPBANKB
    DEFINE   SHIPBANKC 1  
    INCLUDE "./Data/ShipModels.asm"
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
    INCLUDE "./Universe/univ_ship_data.asm"
    
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
    PAGE    BankUNIVDATA8
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
 
    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData0
	ORG GalaxyDataAddr, BankGalaxyData0
    INCLUDE "./Universe/galaxy_data.asm"                                                            
    
    DISPLAY "Galaxy Data - Bytes free ",/D, $2000 - ($- GalaxyDataAddr)


    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData1
	ORG GalaxyDataAddr, BankGalaxyData1
GALAXYDATABlock1         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now  

    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData2
	ORG GalaxyDataAddr, BankGalaxyData2
GALAXYDATABlock2         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData3
	ORG GalaxyDataAddr, BankGalaxyData3
GALAXYDATABlock3         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData4
	ORG GalaxyDataAddr, BankGalaxyData4
GALAXYDATABlock4         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData5
	ORG GalaxyDataAddr,BankGalaxyData5
GALAXYDATABlock5         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData6
	ORG GalaxyDataAddr,BankGalaxyData6
GALAXYDATABlock6         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now
    SLOT    GalaxyDataAddr
    PAGE    BankGalaxyData7
	ORG GalaxyDataAddr,BankGalaxyData7
GALAXYDATABlock7         DB $FF
                         DS $1FFF                 ; just allocate 8000 bytes for now




    SAVENEX OPEN "EliteN.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    