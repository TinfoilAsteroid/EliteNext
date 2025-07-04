;Contants

SignMask8Bit		equ %01111111
SignMask16Bit		equ %0111111111111111
SignOnly8Bit		equ $80
SignOnly16Bit		equ $8000

Bit7Only            equ %10000000
Bit6Only            equ %01000000
Bit5Only            equ %00100000
Bit4Only            equ %00010000
Bit3Only            equ %00001000
Bit2Only            equ %00000100
Bit1Only            equ %00000010
Bit0Only            equ %00000001
Bit7Clear           equ %01111111
Bit6Clear           equ %10111111
Bit5Clear           equ %11011111
Bit4Clear           equ %11101111
Bit3Clear           equ %11110111
Bit2Clear           equ %11111011
Bit1Clear           equ %11111101
Bit0Clear           equ %11111110
ConstPi				equ $80
ConstNorm           equ 197
;OpCodes
OpCodeSCF           equ $37
OpCodeCCF           equ $3F
OpCodeAndA          equ $A7
OpCodeClearCarryFlag equ OpCodeAndA

TidyInterval        equ 16

;Text Tokens
EliteToken			equ $1E			; Token ID for text messsage ---- E L I T E ----
BrabenBellToken 	equ $0D
AcorToken			equ $0C
; Cursor Bits
CursorClimb         equ %10000000
CursorDive          equ %01000000
CursorLeft          equ %00100000
CursorRight         equ %00010000
CursorHome          equ %00001000
CursorRecenter      equ %00000100
; Menu Colours
txt_status_colour		equ $FF
txt_highlight_colour    equ $D0
; Intro Screen
TitleShip			equ	$8C
RotationUnity		equ $60
DBCheckCode			equ $DB
MaxVisibility		equ $1F
FarInFront			equ $C0
; Equipment Flags     
EquipmentItemFitted     equ $FF
EquipmentItemNotFitted  equ 0
; Universe Managment
PlanetTypeMeridian      equ 128
PlanetMinRadius         equ 6

ShipTotalModelCount     equ 44
ShipTypeNormal          equ 0
ShipTypeMissile         equ 1
ShipTypeStation         equ 2
ShipTypeJunk            equ 3
ShipTypeScoopable       equ 4         ; a sub set of junk
ShipTypeTargoid         equ 5
ShipTypeUndefined1      equ 6
ShipTypeUndefined2      equ 7
ShipTypeUndefined3      equ 8
ShipTypeUndefined4      equ 9
ShipTypeUndefined5      equ 10
ShipTypeUndefined6      equ 11
ShipTypeUndefined7      equ 12
ShipTypeUndefined8      equ 13
ShipTypeUndefined9      equ 14
ShipTypeUndefined10      equ 15
ShipTypeNoAI            equ 16

ShipTypeText            equ 253
ShipTypeDebug           equ 254
ShipTypeEmpty           equ 255

SpawnTypeStation        EQU 0
SpawnTypeBodies         EQU SpawnTypeStation        + 1
SpawnTypeJunk           EQU SpawnTypeBodies         + 1
SpawnTypeCop            EQU SpawnTypeJunk           + 1
SpawnTypeTrader         EQU SpawnTypeCop            + 1
SpawnTypeNonTrader      EQU SpawnTypeTrader         + 1
SpawnTypePirate         EQU SpawnTypeNonTrader      + 1
SpawnTypeHunter         EQU SpawnTypePirate         + 1
SpawnTypeThargoid       EQU SpawnTypeHunter         + 1
SpawnTypeMission        EQU SpawnTypeThargoid       + 1
SpawnTypeStationDebris  EQU SpawnTypeMission        + 1
SpawnTypeMissionEvent   EQU SpawnTypeStationDebris  + 1
SpawnTypeDoNotSpawn     EQU SpawnTypeMissionEvent   + 1

; Inventory Equates
StockTypeCount          EQU 17
StockTypeMax            EQU StockTypeCount - 1
StockTypePenultimate    EQU StockTypeCount - 2
; Laser and Missile Settings
; Laser and Missile
ShipLaserPower          equ %11110000
ShipMissileCount        equ %00001111
ShipMissiles1           equ %00000001
ShipMissiles2           equ %00000010
ShipMissiles3           equ %00000011
ShipMissiles4           equ %00000100
ShipMissiles5           equ %00000101
ShipMissiles6           equ %00000110
ShipMissiles7           equ %00000111
ShipMissiles8           equ %00001000
ShipMissiles9           equ %00001001
ShipMissiles10          equ %00001010
ShipMissiles11          equ %00001011
ShipMissiles12          equ %00001100
ShipMissiles13          equ %00001101
ShipMissiles14          equ %00001110
ShipMissiles15          equ %00001111
; AI Flags  UniverseAIControl     
ShipCanAnger            equ %10000000   ; Yes or no
ShipFighterBaySize      equ %01110000   ; fighter day size 0 = none 1,2 = 1 or 2 fighters, 3 = infinite
ShipFighterBaySize1     equ %00010000   ; fighter day size 0 = none 1,2 = 1 or 2 fighters, 3 = infinite
ShipFighterBaySize2     equ %00100000   ; fighter day size 0 = none 1,2 = 1 or 2 fighters, 3 = infinite
ShipFighterBaySize3     equ %00110000   ; fighter day size 0 = none 1,2 = 1 or 2 fighters, 3 = infinite
ShipFighterBaySize4     equ %01000000   ; fighter day size 0 = none 1,2 = 1 or 2 fighters, 3 = infinite
ShipFighterBaySize5     equ %01010000   ; fighter day size 0 = none 1,2 = 1 or 2 fighters, 3 = infinite
ShipFighterBaySizeInf   equ %01110000   ; Infinite fighters (well 255 as thats enough)
ShipFighterType         equ %00001100   ; 4 types 0 = Worm, 1 = Sidewinder, 2 = Viper, 3 = Thargon
ShipFighterWorm         equ %00000000
ShipFighterSidewinder   equ %00000100
ShipFighterViper        equ %00001000
ShipFighterThargon      equ %00001100
ShipUltraHostile        equ %00000010   ; If ultra hostile, will never back down so behaves like a missile
ShipFree                equ $00000011   ; Unused bits at present for later
; NewBTactics
ShipIsTrader            equ Bit0Only   ; Trader flag  80% are peaceful 20% also have Bounty Hunter flag
ShipIsBountyHunter      equ Bit1Only   ; 
ShipIsHostile           equ Bit2Only   ; Also used as Angry flag now
ShipIsPirate            equ Bit3Only   ; 
ShipIsDocking           equ Bit4Only   ; 
ShipIsBystander         equ Bit5Only   ; 
ShipIsCop               equ Bit6Only   ; 
ShipHasEscapePod        equ Bit7Only   ;
ShipHostileNewBitNbr    equ 2
        DISPLAY "TODO: Add bravery based on rank, new bits and type of ship"

; UBnkaiatkecm
;Unused                 equ Bit0Only
;Unused                 equ Bit1Only
;Unused                 equ Bit2Only
ShipIsDot               equ Bit3Only
ShipKilled              equ Bit4Only    ; Ship has just been marked as killed so initiate cloud of debris
ShipExploding           equ Bit5Only
ShipIsVisible           equ Bit6Only
ShipAIEnabled           equ Bit7Only   ; 


; UBnkaiakecm 2
;ShipAngryNewBitNbr      equ 4
ShipExplosionDuration   equ 75         ; amount of frames an explosion lasts for
ShipNotHostile          equ Bit2Clear   ;
ShipIsNotDot            equ Bit3Clear
ShipIsDotBitNbr         equ 3
ShipKilledBitNbr        equ 4
ShipIsVisibleBitNbr     equ 6
ShipIsScoopDockEsc      equ Bit7Only   ; 
ShipAIDisabled          equ Bit7Clear
ShipAIEnabledBitNbr     equ 7
ShipExplodingBitNbr     equ 5
; Equipment Defaults
ECMCounterMax           equ $80
; Main Loop State
StatePlayerDocked       equ $FF
StateCompletedLaunch    equ $FD
StateInTransition       equ $FE
StateHJumping           equ $FC
StateHEntering          equ $FB
StateCompletedHJump     equ $FA
StateNormal             equ 0
; Missile Stage flags , $8x = locked to ship id x, $0x = fire at ship id x requested
StageMissileNotTargeting equ $FF
StageMissileTargeting   equ $FE


ShipMaxDistance     equ 192
HyperSpaceTimers    equ $0B0B

; -- game limts
MaxNumberOfStars	equ 11
ConsoleRefreshInterval  equ 5
MaxJunkStation      equ 3
MaxJunkFreeSpace    equ 5
WarpCoolDownPeriod  equ 90

ShipTypeSize		equ	32 			;??????? just a guess for now
ShipSST				equ 4			; its a space station
UniverseBasePage 	equ 70			; Base memory bank for universe Item #0
ShipDataBasePage	equ	90			; Needs 2mb upgrade but what the heck
ShipCountMax		equ	2			; For now just 2 ships to debug
LineLimitPerShip	equ 70			; Max lines per ship
FaceLimitPerShip	equ	70			; Same as line limit to simplify some logic
; "NEED TO DEFINE SHIPTYPESIZE TODO"

; Memory page managment	(Refers to a memory slot as a place to access data)
ShipDataSlot		equ	6			; this may move into rom swap out space later
UniverseObjectSlot	equ	7

KeyForwardsView		equ	$20
; Game specific equates
MissileDropHeight   equ 5           ; how far the missile is ejected on launch in y axis
WarpSequenceCount   equ 50

;...Game Colour Mapping
L2DustColour        equ L2ColourGREY_1
L2SunScannerBright  equ 252
L2SunScanner        equ 180
L2DebrisColour      equ L2ColourYELLOW_1


; Ship Data
;;;;	.XX21	\ -> &5600 \ Table of pointers to ships' data given to XX0
;;;;00 7F			 EQUW &7F00 \ type  1 is #MSL  Missile data on page off bottom of screen
;;;;00 00			 EQUW 0     \ type  2 is #SST  Space Station, Coriolis or Dodo.
;;;;00 00			 EQUW 0     \ type  3 is #ESC  Escape capsule
;;;;00 00			 EQUW 0     \ type  4 is #PLT  Plate, alloys
;;;;00 00			 EQUW 0     \ type  5 is #OIL  Cargo cannister
;;;;00 00			 EQUW 0     \ type  6 is       Boulder
;;;;00 00			 EQUW 0     \ type  7 is #AST  Asteroid
;;;;00 00			 EQUW 0     \ type  8 is #SPL  Splinter, rock.
;;;;00 00			 EQUW 0     \ type  9 is #SHU  Shuttle
;;;;00 00			 EQUW 0     \ type 10 is       Transporter
;;;;00 00			 EQUW 0     \ type 11 is #CYL  Cobra Mk III,  Boa
;;;;00 00			 EQUW 0     \ type 12 is       Python
;;;;00 00			 EQUW 0     \ type 13 is       Last of three traders	
;;;;00 00			 EQUW 0     \ type 14 is #ANA  Anaconda
;;;;00 00			 EQUW 0     \ type 15 is #WRM  Worm with Anaconda
;;;;00 00			 EQUW 0     \ type 16 is #COP  Viper
;;;;00 00			 EQUW 0     \ type 17 is       First pirate
;;;;00 00			 EQUW 0     \ type 18 is
;;;;00 00			 EQUW 0     \ type 19 is #KRA  Krait small pirate
;;;;00 00			 EQUW 0     \ type 20 is #ADA  Adder
;;;;00 00			 EQUW 0     \ type 21 is
;;;;00 00			 EQUW 0     \ type 22 is
;;;;00 00			 EQUW 0     \ type 23 is
;;;;00 00			 EQUW 0     \ type 24 is #CYL2 Last strong pirate
;;;;00 00			 EQUW 0     \ type 25 is #ASP  Asp Mk II
;;;;00 00			 EQUW 0     \ type 26 is #FER  Fer de Lance
;;;;00 00			 EQUW 0     \ type 27 is
;;;;00 00			 EQUW 0     \ type 28 is	Last of three bounty hunters
;;;;00 00			 EQUW 0     \ type 29 is #THG  Thargoid
;;;;00 00			 EQUW 0     \ type 30 is #TGL  Thargon
;;;;00 00			 EQUW 0     \ type 31 is #CON  Constrictor
;;;;	.E%	\ -> &563E \ Hull NEWB bits are escpod, cop, inno, ?, pirate, angry, hunter, trader.
;;;;			\ NEWB examples
;;;;\ 21			EQUB &21    \ 0010 0001    9 Shuttle has no escape pod, inno, trader.
;;;;\ 61			EQUB &61    \ 0110 0001   10 Tansporter no escape pod, Cop, inno, trader.
;;;;\ A0			EQUB &A0    \ 1010 0000   11 Cobra has Escape pod, inno, not a trader.
;;;;\ C2			EQUB &C2    \ 1100 0010   16 Viper has Escape pod, Cop, hunter.
;;;;\ 8C			EQUB &8C    \ 1000 1100   19 Krait pirate has escape pod, is pirate and angry.
