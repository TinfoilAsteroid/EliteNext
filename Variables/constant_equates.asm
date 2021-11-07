;Contants

SignMask8Bit		equ %01111111
SignMask16Bit		equ %0111111111111111
SignOnly8Bit		equ $80
SignOnly16Bit		equ $8000

ConstPi				equ $80
ConstNorm           equ 197

;Text Tokens
EliteToken			equ $1E			; Token ID for text messsage ---- E L I T E ----
BrabenBellToken 	equ $0D
AcorToken			equ $0C

; Intro Screen
TitleShip			equ	$8C
RotationUnity		equ $60
DBCheckCode			equ $DB
MaxVisibility		equ $1F
FarInFront			equ $C0

; Universe Managment
MaxNumberOfStars	equ 11
FreeListSize		equ	$12
ShipTypeSize		equ	32 			;??????? just a guess for now
ShipSST				equ 4			; its a space station
UniverseBasePage 	equ 70			; Base memory bank for universe Item #0
ShipDataBasePage	equ	90			; Needs 2mb upgrade but what the heck
ShipCountMax		equ	2			; For now just 2 ships to debug
LineLimitPerShip	equ 70			; Max lines per ship
FaceLimitPerShip	equ	70			; Same as line limit to simplify some logic
; "NEED TO DEFINE SHIPTYPESIZE TODO"
PlayerDocked		equ	$FF

; Memory page managment	(Refers to a memory slot as a place to access data)
ShipDataSlot		equ	6			; this may move into rom swap out space later
UniverseObjectSlot	equ	7

KeyForwardsView		equ	$20

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
