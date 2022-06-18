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
ShipTotalModelCount     equ 44
ShipTypeScoopable       equ 4         ; a sub set of junk
ShipTypeJunk            equ 3
ShipTypeStation         equ 2
ShipTypeMissile         equ 1
ShipTypeNormal          equ 0
ShipTypeText            equ 253
ShipTypeDebug           equ 254
ShipTypeEmpty           equ 255
; TacticsControl
ShipExplosionDuration   equ 75         ; amount of frames an explosion lasts for
ShipIsTrader            equ Bit0Only   ; Trader flag  80% are peaceful 20% also have Bounty Hunter flag
ShipIsBountyHunter      equ Bit1Only   ; 
ShipIsHostile           equ Bit2Only   ;
ShipNotHostile          equ Bit2Clear   ;
ShipIsPirate            equ Bit3Only   ; 
ShipIsDot               equ Bit3Only
ShipIsNotDot            equ Bit3Clear
ShipIsDotBitNbr         equ 3
ShipKilled              equ Bit4Only    ; Ship has just been marked as killed so initiate cloud of debris
ShipKilledBitNbr        equ 4
ShipIsDocking           equ Bit4Only   ; 
ShipIsBystander         equ Bit5Only   ; 
ShipIsVisible           equ Bit6Only
ShipIsVisibleBitNbr     equ 6
ShipIsCop               equ Bit6Only   ; 
ShipIsScoopDockEsc      equ Bit7Only   ; 
ShipAIEnabled           equ Bit7Only   ; 
ShipAIDisabled          equ Bit7Clear
ShipAIEnabledBitNbr     equ 7
ShipExploding           equ Bit5Only
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
StageMissileNoTarget equ $FF
StageMissileTargeting equ $FE
; UniverseAIControl     
ShipCanAnger        equ %00000001


ShipMaxDistance     equ 192
HyperSpaceTimers    equ $0B0B


MaxNumberOfStars	equ 11
ConsoleRefreshInterval  equ 5

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
