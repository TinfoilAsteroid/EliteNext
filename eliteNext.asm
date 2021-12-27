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
                        call        l1_set_border
                        MMUSelectSpriteBank
                        call		sprite_load_sprite_data
Initialise:             MMUSelectLayer2
                        call 		l2_initialise
                        ld          a,$FF
                        ld          (ScreenTransitionForced),a
TidyDEBUG:              ld          a,16
                        ld          (TidyCounter),a

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
                        
                        
;InitialiseDemoShip:     call    ClearFreeSlotList
;                        call    FindNextFreeSlotInA
;                        ld      b,a
;                        ld      a,13 ;Coriolis station
;                        call    InitialiseShipAUnivB
;                        xor     a
InitialiseMainLoop:     ld      (CurrentUniverseAI),a
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
;.. This bit allows cycling of ships on universe 0 in demo.........................................................................
DemoOfShipsDEBUG:       call    TestForNextShip
;.. Check if keyboard scanning is allowed by screen. If this is set then skip all keyboard and AI..................................
InputBlockerCheck:      ld      a,$0
                        JumpIfAEqNusng $01, SkipInputHandlers       ; as we are in a transition the whole update AI is skipped
                        call    ViewKeyTest
                        call    TestPauseMode
                        ld      a,(GamePaused)
                        cp      0
                        jr      nz,MainLoop
                        call    MovementKeyTest
;.. Process cursor keys for respective screen if the address is 0 then we skill just skip movement.................................
HandleMovement:         ld      a,(CallCursorRoutine+2)
                        IfAIsZeroGoto     TestAreWeDocked
;.. Handle displaying correct screen ..............................................................................................
HandleBankSelect:       ld      a,$00
                        MMUSelectScreenA
CallCursorRoutine:      call    $0000
;.. Check to see if we are docked as if we are (or are docking.launching then no AI/Ship updates occur.............................
;.. Also end up here if we have the screen input blocker set
SkipInputHandlers:      
;.. For Docked flag its - 0 = in free space, FF = Docked, FE transition, FD = Setup open space and transition to not docked
TestAreWeDocked:        ld      a,(DockedFlag)                                ; if if we are in free space do universe update
                        JumpIfANENusng  0, SkipUniveseUpdate                  ; else we skip it. As we are also in dock/transition then no models should be updated so we dont; need to draw
;.. If we get here then we are in game running mode regardless of which screen we are on, so update AI.............................
;.. we do one universe slot each loop update ......................................................................................
                        call    UpdateUniverseObjects
                        JumpIfMemNeNusng ScreenTransitionForced, $FF, BruteForceChange                          ; if we docked then a transition would have been forced
CheckIfViewUpdate:      ld      a,$00                                         ; if this is set to a view number then we process a view
                        cp      0                                             ; .
                        jr      z, MenusLoop                                  ; This will change as more screens are added TODO
;..Processing a view...............................................................................................................
;..Display any message ............................................................................................................
                        ld      a,(MessageCount)
                        jr      z,.NoMessages                                 ; note message end will tidy up display
.NoMessages:            ld      hl,(InnerHyperCount)
                        ld      a,h
                        or      l
                        jr      z,.NoHyperspace                               ; note message end will tidy up display
.HyperSpaceMessage:     MMUSelectLayer1
                        ;break
                        call    DisplayHyperCountDown
.UpdateHyperCountdown:  ld      hl,(InnerHyperCount)
                        dec     l
                        jr      nz,.decHyperInnerOnly
                        dec     h
                        jp      m,.HyperCountDone
.resetHyperInner:       ld      l,$0B
                        push    hl
                        ld      d,12
                        ld      a,L1ColourPaperBlack | L1ColourInkYellow
                        call    l1_attr_cls_2DlinesA
                        ld      d,12 * 8
                        call    l1_cls_2_lines_d
                        ld      de,$6000
                        ld      hl,Hyp_centeredTarget
                        call    l1_print_at
                        ld      de,$6800
                        ld      hl,Hyp_centeredCharging
                        call    l1_print_at
                        pop     hl
.decHyperInnerOnly:     ld      (InnerHyperCount),hl
                        jr      .DoneHyperCounter
.HyperCountDone:        ld      hl,0
                        ld      (InnerHyperCount),hl
                        ld      d,12
                        ld      a,L1ColourPaperBlack | L1ColourInkBlack
                        call    l1_attr_cls_2DlinesA
                        ld      d,12 * 8
                        call    l1_cls_2_lines_d
                        ld      a,ScreenHyperspace                            ; transition to hyperspace
                        ld      (ScreenTransitionForced),a
; do some enbaling jump code and jump trasition
.DoneHyperCounter:                      
.NoHyperspace:          MMUSelectLayer2
                        call   l2_cls                        
                        MMUSelectLayer1
;..Later this will be done via self modifying code to load correct stars routine for view..........................................
DrawStarsForwards:      ld     a,$DF
                        ld     (line_gfx_colour),a                         
StarUpdateBank:         MMUSelectViewFront                                    ; This needs to be self modifying
StarUpdateRoutine:      call   StarsForward                                   ; This needs to be self modifying
PrepLayer2:             MMUSelectLayer2                                       ; Clear layer 2 for graphics
                      ;  call   l2_cls                        
ProcessShipModels:      call    DrawForwardShips                              ; Draw all ships (this may need to be self modifying)
                        call   UpdateConsole                                  ; Update display console on layer 1
                        jp LoopRepeatPoint                                    ; And we are done with views, so check if there was a special command to do
;..If we were not in views then we were in display screens/menus...................................................................
MenusLoop:              ld      hl,(ScreenLoopJP+1)
                        ld      a,h
                        or      l
                        jp      z,LoopRepeatPoint
;..This is the screen update routine for menus.....................................................................................
;.. Also used by transition routines
SkipUniveseUpdate:      JumpIfMemZero ScreenLoopJP+1,LoopRepeatPoint
ScreenLoopBank:         ld      a,$0
                        MMUSelectScreenA
ScreenLoopJP:           call    $0000
LoopRepeatPoint:        ld      a,(DockedFlag)
HandleLaunched:         JumpIfAEqNusng  $FD, WeHaveCompletedLaunch
                        JumpIfAEqNusng  $FE, WeAreInTransition
                        JumpIfAEqNusng  $FC, WeAreHJumping
                        JumpIfAEqNusng  $FB, WeHaveCompletedHJump
                        jp  DoubleBufferCheck
WeHaveCompletedHJump:   ; set up new star system and landing location in system                        
WeHaveCompletedLaunch:  call    LaunchedFromStation
                        jp  DoubleBufferCheck
WeAreHJumping:                        
WeAreInTransition:                        
DoubleBufferCheck:      ld      a,00
                        IFDEF DOUBLEBUFFER
                            cp      0
                            jp      z,TestTransition
                            MMUSelectLayer2
                            ld     a,(varL2_BUFFER_MODE)
                            cp     0
                            call   nz,l2_flip_buffers
                        ENDIF
TestTransition:        ld      a,(ScreenTransitionForced)          ; was there a bruite force screen change in any update loop
                        cp      $FF
                        jp      z,MainLoop
BruteForceChange:      ld      d,a
                        ld      e,ScreenMapRow
                        mul
                        ld      ix,ScreenKeyMap
                        add     ix,de                               ; Force screen transition
                        call    SetScreenAIX
                        jp MainLoop

;..................................................................................................................................
;..Update Universe Objects.........................................................................................................
UpdateUniverseObjects:  xor     a
                        ld      (SelectedUniverseSlot),a
.UpdateUniverseLoop:     ld      d,a                                             ; d is unaffected by GetTypeInSlotA
;.. If the slot is empty (FF) then skip this slot..................................................................................
                        call    GetTypeAtSlotA
                        cp      $FF
                        jr      z,.ProcessedUniverseSlot            
.UniverseObjectFound:   ld      a,d                                             ; Get back Universe slot as we want it
                        MMUSelectUniverseA                                      ; and we apply roll and pitch
                        call    ApplyMyRollAndPitch
                        call    ApplyShipRollAndPitch
;.. If its a space station then see if we are ready to dock........................................................................
.CheckIfDockable:       ld      a,(ShipTypeAddr)                                ; Now we have the correct bank
                        JumpIfANENusng  ShipTypeStation, .NotDockingCheck       ; if its not a station so we don't test docking
.IsDockableAngryCheck:  JumpOnMemBitSet ShipNewBitsAddr, 4, .NotDockingCheck    ; if it is angry then we dont test docking
                        call    DockingCheck                                    ; So it is a candiate to test docking. Now we do the position and angle checks
                        ReturnIfMemEquN ScreenTransitionForced, $FF            ; if we docked then a transition would have been forced
.NotDockingCheck:       CallIfMemEqMemusng SelectedUniverseSlot, CurrentUniverseAI, UpdateShip
.ProcessedUniverseSlot: ld      a,(SelectedUniverseSlot)                        ; Move to next ship cycling if need be to 0
                        inc     a                                               ; .
                        JumpIfAGTENusng   UniverseListSize, .UpdateAICounter    ; .
                        ld      (SelectedUniverseSlot),a
                        jp      .UpdateUniverseLoop
.UpdateAICounter:       ld      a,(CurrentUniverseAI)
                        inc     a
                        cp      12
                        jr      c,.IterateAI
                        xor     a
.IterateAI:             ld      (CurrentUniverseAI),a
                        ret
;..................................................................................................................................
;.. Quickly eliminate space stations too far away..................................................................................
DockingCheck:           ld      bc,(UBnKxlo)
                        ld      hl,(UBnKylo)
                        ld      de,(UBnKzlo)
                        ld      a,b
                        or      h
                        or      d
                        ret     nz
.CheckIfInRangeLo:      ld      a,c
                        or      l
                        or      e
                        and     %11000000                           ; Note we should make this 1 test for scoop or collision too
                        ret     nz
;.. Now check to see if we are comming in at a viable angle........................................................................
.CheckDockingAngle:     ld      a,(UBnkrotmatNosevZ+1)              ; get get high byte of rotmat
                        ReturnIfALTNusng 214                       ; this is the magic angle to be within 26 degrees +/-
                        call    GetStationVectorToWork              ; Normalise position into XX15 as in effect its a vector from out ship to it given we are always 0,0,0, returns with A holding vector z
                        bit     7,a                                 ; if its negative
                        ret     nz                                  ; we are flying away from it
                        ReturnIfALTNusng 89                         ; if the axis <89 the we are not in the 22 degree angle
                        ld      a,(UBnkrotmatRoofvX+1)              ; get roof vector high
                        and     SignMask8Bit
                        ReturnIfALTNusng 80                         ; note 80 decimal for 36.6 degrees
;.. Its passed all validation and we are docking...................................................................................
.AreDocking:            MMUSelectLayer1
                        ld        a,$6
                        call      l1_set_border
.EnterDockingBay:       ld      a,ScreenDocking
                        ld      (ScreenTransitionForced),a
                        ret
;..................................................................................................................................                        
DrawForwardShips:       xor     a
DrawShipLoop:           push    af
                        call    GetTypeAtSlotA
                        cp      $FF
                        jr      z,ProcessedDrawShip
; Add in a fast check for ship behind to process nodes and if behind jump to processed Draw ship
SelectShipToDraw:       pop     af
                        push    af
                        MMUSelectUniverseA
                        ;break
                        call    CheckDistance
                        jr      c,UpdateRadar               ; it can't be drawn if carry is set by may appear on radar
                        call    ProcessNodes
DrawShip:               ;call   SetAllFacesVisible
                        call    CullV2				        ; culling but over aggressive backface assumes all 0 up front TOFIX
                        call    PrepLines                   ; LL72, process lines and clip, ciorrectly processing face visibility now
                        pop     af
                        push    af
                        MMUSelectUniverseA
                        call   DrawLines                   ; Need to plot all lines
                        ld      a,BankFrontView
                        MMUSelectScreenA
                        call        hyperspace_Lightning                        
                        pop     af
                        push    af
                        MMUSelectUniverseA
UpdateRadar:            call    UpdateScannerShip
ProcessedDrawShip:      pop     af
                        inc     a
                        JumpIfALTNusng   UniverseListSize, DrawShipLoop
                        ret    
;..................................................................................................................................

    
TestForNextShip:        ld      a,c_Pressed_Quit
                        call    is_key_pressed
                        ret     nz
                        ld      a,(currentDemoShip)
                        inc     a
                        cp      44
                        jr      nz,.TestOK
                        xor     a
.TestOK:                ld      (currentDemoShip),a
                        call    ClearUnivSlotList
                        ld      a,(currentDemoShip)
                        ld      b,a
                        xor     a
                        call    SetSlotAToTypeB
                        MMUSelectUniverseN 0
                        call    ResetUBnkData                         ; call the routine in the paged in bank, each universe bank will hold a code copy local to it
                        ld      a,(currentDemoShip)
                        MMUSelectShipBank1
                        call    GetShipBankId
                        MMUSelectShipBankA
                        ld      a,b
                        call    CopyShipToUniverse
                        call    SetInitialShipPosition
                        call    DEBUGSETNODES                        
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
NeedAMessageQueue:

UpdateCountdownNumber:  ld		a,(OuterHyperCount)
                        ld		de,Hyp_counter
                        ld	c, -100
                        call	.Num1
                        ld	c,-10
                        call	.Num1
                        ld	c,-1
.Num1:	                ld	b,'0'-1
.Num2:	                inc		b
                        add		a,c
                        jr		c,.Num2
                        sub 	c
                        push	bc
                        push	af
                        ld		a,c
                        cp		-1
                        ld		a,b
                        ld		(de),a
                        inc		de
                        pop		af
                        pop		bc
                        ret 

;----------------------------------------------------------------------------------------------------------------------------------
Hyp_message             DB "To:"
Hyp_to                  DS 32
Hyp_space1              DB " "
Hyp_dist_amount         DB "0.0"
Hyp_decimal             DB "."
Hyp_fraction            DB "0"
Hyp_dis_ly              DB " LY",0
Hyp_charging            DB "Charging:"
Hyp_counter             DB "000",0
Hyp_centeredTarget      DS 32
Hyp_centeredEol         DB 0
Hyp_bufferpadding       DS 32   ; just in case we get a buffer ovverun. shoudl never get beyond 32 chars
Hyp_centeredCharging    DS 32
Hyp_centeredEol2        DB 0
Hyp_bufferpadding2      DS 32   ; just in case we get a buffer ovverun. shoudl never get beyond 32 chars

MainCopyLoop:           ld      a,(hl)
                        cp      0
                        ret     z
                        ld      (de),a
                        inc     hl
                        inc     de
                        jr      MainCopyLoop

CountLengthHL:          ld      b,0
.CountLenLoop:          ld      a,(hl)
                        cp      0
                        jr      z,.DoneCount
                        inc     b
                        inc     hl
                        jr      .CountLenLoop
.DoneCount:             ld      a,32
                        sub     b
                        sra     a         
                        ret
                        
MainClearTextLoop:      ld      b,a
                        ld      a,32
.ClearLoop:             ld      (hl),a
                        inc     hl
                        djnz    .ClearLoop
                        ret

     
DisplayHyperCountDown:  ld      de,Hyp_to
                        ld      hl,name_expanded
                        call    MainCopyLoop
.DoneName:              xor     a
                        ld      (de),a
                        ld      (Hyp_message+31),a      ; max out at 32 characters
.CentreJustify:         ld      hl,Hyp_message
                        call    CountLengthHL
                        ld      hl,Hyp_centeredTarget
                        call    MainClearTextLoop
                        ex      de,hl
                        ld      hl,Hyp_message
                        call    MainCopyLoop
                        xor     a
                        ld      (Hyp_centeredEol),a
                        ld      hl,Hyp_counter           ; clear counter digits
                        ld      a,32                     ; clear counter digits
                        ld      (hl),a                   ; clear counter digits
                        inc     hl                       ; clear counter digits
                        ld      (hl),a                   ; clear counter digits
                        inc     hl                       ; clear counter digits
                        ld      (hl),a                   ; clear counter digits
                        call    UpdateCountdownNumber
                        ld      hl,Hyp_charging
                        call    CountLengthHL
                        ld      hl,Hyp_centeredCharging
                        call    MainClearTextLoop
                        ex      de,hl
                        ld      hl,Hyp_charging
                        call    MainCopyLoop
                        xor     a
                        ld      (Hyp_centeredEol2),a
                        ret

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
currentDemoShip:        DB      13;$12 ; 13 - corirollis 


;----------------------------------------------------------------------------------------------------------------------------------
UpdateShip:             ;  call    DEBUGSETNODES ;       call    DEBUGSETPOS
                        ld      hl,TidyCounter
                        dec     (hl)
                        ret     nz
                        ld      a,16
                        ld      (TidyCounter),a
                        ; call    TIDY TIDY IS BROKEN
                       ; add AI in here too
                        ret
            
InitialiseShipAUnivB:   push    af
                        ld      a,b
                        MMUSelectUniverseA                          ; load up register into universe bank
                        call    ResetUBnkData                         ; call the routine in the paged in bank, each universe bank will hold a code copy local to it
                        MMUSelectShipBank1
                        pop     af
                        call    CopyShipToUniverse
                        ret

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
                        ret                             ; will return with a holding Vector Z

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
; Byte 9   - Draw stars Y/N
; byte 10  - Input Blocker (set to 1 will not allow keyboard screen change until flagged, used by transition screens and pause menus)
; byte 11  - Double Buffering 0 = no, 1 = yes
; byte 12,13  - cursor key input routine
; byte 14  - HyperspaceBlock - can not select this screen if in hyperpace - 00 can , 01 can not
; byte 15    padding at the momnent (should add in an "AI enabled flag" for optimistation, hold previous value and on change create ships
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
ScreenKeyFront:         DB 2,   ScreenFront     , low addr_Pressed_Front,        high addr_Pressed_Front,        BankFrontView,       low draw_front_view,         high draw_front_view,          $00,                  $00,                    $01,$00,$01,low input_front_view,      high input_front_view,       $00,$00
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
LaunchedFromStation:    call    ClearUnivSlotList
                        xor     a
                        call    SetSlotAToSpaceStation              ; set slot 0 to space station
                        MMUSelectUniverseA                          ; Prep Target universe
                        MMUSelectShipBank1                          ; Bank in the ship model code
                        ld      a,CoriloisStation
                        call    GetShipBankId             
                        MMUSelectShipBankA                          ; Select the correct bank found
                        ld      a,b                                 ; Select the correct ship
                        call    CopyShipToUniverse
.BuiltStation:          call    ResetStationLaunch
.NowInFlight:           xor     a
                        ld      (DockedFlag),a
                        ld      a,ScreenFront
                        ld      (ScreenTransitionForced),a                        
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
.HyperspaceCountdown:   ld      a,(ix+14)
                        cp      1
                        jr      z,NotReadNextKey               ; can not change to this vie win hyperspace countdown
ViewScanLoop:           ld      a,(ix+0)                        ; Screen Map Byte 0 Docked flag 
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


            INCLUDE "./Views/ConsoleDrawing.asm"



;.absXhi:                        
;                        ld      a,ScannerX
;                        JumpOnBitSet d,7,ScannerNegX
;                        add     a,e
;                        jp      ScannerZCoord
;ScannerNegX:            sub     e
;ScannerZCoord:          ld      e,a
;                        srl     c
;                        srl     c
;                        ld      a,ScannerY
;                        JumpOnBitSet b,7,ScannerNegZ
;                        sub     c
;                        jp      ScannerYCoord
;ScannerNegZ:            add     a,c
;ScannerYCoord:          ld      d,a                     ; now de = pixel pos d = y e = x  for base of stick X & Z , so need Y Stick height
;                        JumpOnBitSet h,7,ScannerStickDown
;                        sub     l                       ; a already holds actual Y
;                        JumpIfAGTENusng 128,ScannerHeightDone
;                        ld      a,128
;                        jp      ScannerHeightDone
;ScannerStickDown:       add     a,l     
;                        JumpIfAGTENusng 191,ScannerHeightDone
;                        ld      a,191
;ScannerHeightDone:      ld      c,e            ; Now sort out line from point DE horzontal by a
;                        ld      b,d
;                        ld      d,a
;                        cp      b
;                        jp      z,Scanner0Height
;                        ld      e,194 ; Should be coloured based on status but this will do for now
;                        push    bc
;                        push    de
;                        MMUSelectLayer2  
;                        call    l2_draw_vert_line_to
;                        pop     de
;                        pop     bc
;Scanner0Height:         ld      b,d
;                       push    bc
;                       ld      a,255
;                       MMUSelectLayer2  
;                       call    l2_plot_pixel
;                       pop     bc
;                       inc     c
;                       ld      a,255
;                       MMUSelectLayer2  
;                       call    l2_plot_pixel
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



            
    ;include "./ModelRender/testdrawing.asm"
XX12PVarQ			DW 0
XX12PVarR			DW 0
XX12PVarS			DW 0
XX12PVarResult1		DW 0
XX12PVarResult2		DW 0
XX12PVarResult3		DW 0
XX12PVarSign2		DB 0
XX12PVarSign1		DB 0								; Note reversed so BC can do a little endian fetch
XX12PVarSign3		DB 0

    include "./Maths/Utilities/XX12EquNodeDotOrientation.asm"
    include "ModelRender/CopyXX12ToXX15.asm"	
    include "ModelRender/CopyXX15ToXX12.asm"
    include "./Maths/Utilities/ScaleXX16Matrix197.asm"
		    
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

    INCLUDE "./Variables/UniverseSlotRoutines.asm"

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
    