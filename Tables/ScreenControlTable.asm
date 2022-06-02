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
; byte 16  - block update ship
;                          0    1                 2                              3                               4                    5                            6                              7                     8                       9   10  11  12                          13                          14  15  16    
ScreenKeyMap:           DB 0,   ScreenLocal     , low addr_Pressed_LocalChart,   high addr_Pressed_LocalChart,   BankMenuShrCht,      low draw_local_chart_menu,   high draw_local_chart_menu,    $00,                  $00,                    $00,$00,$00,low local_chart_cursors,    high local_chart_cursors,   $01,$00,$00;low loop_local_chart_menu,   high loop_local_chart_menu
ScreenKeyGalactic:      DB 0,   ScreenGalactic  , low addr_Pressed_GalacticChrt, high addr_Pressed_GalacticChrt, BankMenuGalCht,      low draw_galactic_chart_menu,high draw_galactic_chart_menu, low loop_gc_menu,     high loop_gc_menu,      $00,$00,$00,low galctic_chart_cursors,  high galctic_chart_cursors, $01,$00,$00
                        DB 1,   ScreenMarket    , low addr_Pressed_MarketPrices, high addr_Pressed_MarketPrices, BankMenuMarket,      low draw_market_prices_menu, high draw_market_prices_menu,  low loop_market_menu, high loop_market_menu,  $00,$00,$00,$00,                        $00,                        $01,$00,$00
                        DB 2,   ScreenMarketDsp , low addr_Pressed_MarketPrices, high addr_Pressed_MarketPrices, BankMenuMarket,      low draw_market_prices_menu, high draw_market_prices_menu,  $00,                  $00,                    $00,$00,$00,$00,                        $00,                        $01,$00,$00
ScreenCmdr:             DB 0,   ScreenStatus    , low addr_Pressed_Status,       high addr_Pressed_Status,       BankMenuStatus,      low draw_status_menu,        high draw_status_menu,         low loop_STAT_menu,  high loop_STAT_menu,     $00,$00,$00,$00,                        $00,                        $01,$00,$00
                        DB 0,   ScreenInvent    , low addr_Pressed_Inventory,    high addr_Pressed_Inventory,    BankMenuInvent,      low draw_inventory_menu,     high draw_inventory_menu,      $00,                  $00,                    $00,$00,$00,$00,                        $00,                        $01,$00,$00
                        DB 0,   ScreenPlanet    , low addr_Pressed_PlanetData,   high addr_Pressed_PlanetData,   BankMenuSystem,      low draw_system_data_menu,   high draw_system_data_menu,    $00,                  $00,                    $00,$00,$00,$00,                        $00,                        $01,$00,$00
                        DB 1,   ScreenEquip     , low addr_Pressed_Equip,        high addr_Pressed_Equip,        BankMenuEquipS,      low draw_eqshp_menu,         high draw_eqshp_menu,          low loop_eqshp_menu,  high loop_eqshp_menu,   $00,$00,$00,$00,                        $00,                        $01,$00,$00
                        DB 1,   ScreenLaunch    , low addr_Pressed_Launch,       high addr_Pressed_Launch,       BankLaunchShip,      low draw_launch_ship,        high draw_launch_ship,         low loop_launch_ship, high loop_launch_ship,  $00,$01,$01,$00,                        $00,                        $01,$00,$FF
ScreenKeyFront:         DB 2,   ScreenFront     , low addr_Pressed_Front,        high addr_Pressed_Front,        BankFrontView,       low draw_front_view,         high draw_front_view,          low update_front_view,high update_front_view, $01,$00,$01,low input_front_view,      high input_front_view,       $00,$00,$00
                        DB 2,   ScreenAft       , low addr_Pressed_Front,        high addr_Pressed_Front,        BankFrontView,       low draw_front_view,         high draw_front_view,          $00,                  $00,                    $01,$00,$01,low input_front_view,      high input_front_view,       $00,$00,$00
                        DB 2,   ScreenLeft      , low addr_Pressed_Front,        high addr_Pressed_Front,        BankFrontView,       low draw_front_view,         high draw_front_view,          $00,                  $00,                    $01,$00,$01,low input_front_view,      high input_front_view,       $00,$00,$00
                        DB 2,   ScreenRight     , low addr_Pressed_Front,        high addr_Pressed_Front,        BankFrontView,       low draw_front_view,         high draw_front_view,          $00,                  $00,                    $01,$00,$01,low input_front_view,      high input_front_view,       $00,$00,$00
                        DB 3,   ScreenDocking   , $FF,                           $FF,                            BankLaunchShip,      low draw_docking_ship,       high draw_docking_ship,        low loop_docking_ship,high loop_docking_ship, $00,$01,$01,$00,                        $00,                        $01,$00,$FF
                        DB 1,   ScreenHyperspace, $FF,                           $FF,                            BankFrontView,       low draw_hyperspace,         high draw_hyperspace,          low loop_hyperspace,  high loop_hyperspace,   $00,$01,$01,$00,                        $00,                        $01,$00,$FF

;               DB low addr_Pressed_Aft,          high addr_Pressed_Aft,          BankMenuGalCht,      low SelectFrontView,         high SelectFrontView,          $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;               DB low addr_Pressed_Left,         high addr_Pressed_Left,         BankMenuGalCht,      low SelectFrontView,         high SelectFrontView,          $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
;               DB low addr_Pressed_Right,        high addr_Pressed_Right,        BankMenuGalCht,      low SelectFrontView,         high SelectFrontView,          $00,$00,$00,$00,$00,$00,$00,$00,$00,$00
ScreenMapRow        EQU ScreenKeyGalactic - ScreenKeyMap
ScreenMapLen        EQU ($ - ScreenKeyMap) / ScreenMapRow
ScreenViewsStart    EQU (ScreenKeyFront - ScreenKeyMap)/ScreenMapRow
ScreenCount         EQU 15
