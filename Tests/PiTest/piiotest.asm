hs                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"
                DISPLAY "Piio test"
                DISPLAY "-------------------------------------------------------------------------------------------------------------------------"


    DEFINE DEBUGMODE 1
    DEVICE ZXSPECTRUMNEXT
    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
 CSPECTMAP piiotest.map
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
    INCLUDE "../../Hardware/L2ColourDefines.asm"
    INCLUDE "../../Hardware/L1ColourDefines.asm"
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

                        INCLUDE "../../Hardware/register_defines.asm"
                        INCLUDE "../../Layer2Graphics/layer2_defines.asm"
                        INCLUDE	"../../Hardware/memory_bank_defines.asm"
                        INCLUDE "../../Hardware/screen_equates.asm"
                        INCLUDE "../../Macros/graphicsMacros.asm"
                        INCLUDE "../../Macros/callMacros.asm"
                        INCLUDE "../../Macros/carryFlagMacros.asm"
                        INCLUDE "../../Macros/CopyByteMacros.asm"
                        INCLUDE "../../Macros/ldCopyMacros.asm"
                        INCLUDE "../../Macros/ldIndexedMacros.asm"
                        INCLUDE "../../Macros/jumpMacros.asm"
                        INCLUDE "../../Macros/MathsMacros.asm"
                        INCLUDE "../../Macros/MMUMacros.asm"
                        INCLUDE "../../Macros/NegateMacros.asm"
                        INCLUDE "../../Macros/returnMacros.asm"
                        INCLUDE "../../Macros/ShiftMacros.asm"
                        INCLUDE "../../Macros/signBitMacros.asm"
                        INCLUDE "../../Macros/print_text_macros.asm"

MessageAt:              MACRO   x,y,message
                        push    af,,bc,,de,,hl
                        ld      d,y
                        ld      e,x*8
                        ld      hl,message
                        call    l1_print_at_char_wrap
                        pop     af,,bc,,de,,hl
                        ENDM

PrintHexARegAt:         MACRO   x,y
                        push    af,,bc,,de,,hl
                        ld      d,y
                        ld      e,x*8
                        call    l1_print_u8_hex_at_char
                        pop     af,,bc,,de,,hl
                        ENDM

SetBorder:              MACRO   value
                        ld          a,value
                        call        l1_set_border
                        ENDM
                        
DumpDataTest:           MACRO   command, recordcount, recordlen, dataaddr
                        ld      a,recordcount
                        ld      d,a
                        ld      e,recordlen
                        mul     de
                        ld      hl,dataaddr
                        ld      a,command
                        call    ENPiDumpDataTest
                        ENDM
DumpDataToPi:           MACRO   command, recordcount, recordlen, dataaddr
                        ld      a,recordcount
                        ld      d,a
                        ld      e,recordlen
                        mul     de
                        ld      hl,dataaddr
                        ld      a,command
                        call    ENPiDumpData
                        ENDM
                        

charactersetaddr		equ 15360
STEPDEBUG               equ 1

TopOfStack              equ $5CCB ;$6100

                        ORG $5DCB;      $6200
EliteNextStartup:       di
.InitialiseClockSpeed:  nextreg     TURBO_MODE_REGISTER,Speed_28MHZ
.InitialiseLayerOrder:  DISPLAY "Starting Assembly At ", EliteNextStartup
                        ; "STARTUP"
                        ; Make sure  rom is in page 0 during load
                        nextreg 	SPRITE_LAYERS_SYSTEM_REGISTER,%00000101 ; ULS
                        SetBorder   0
                        call        l1_cls
                        ld          a,7
                        call        l1_attr_cls_to_a
.InitialisePeripherals: nextreg     PERIPHERAL_2_REGISTER, AUDIO_CHIPMODE_AY ; Enable Turbo Sound
                        nextreg     PERIPHERAL_3_REGISTER, DISABLE_RAM_IO_CONTENTION | ENABLE_TURBO_SOUND | INTERNAL_SPEAKER_ENABLE
                        nextreg     PERIPHERAL_4_REGISTER, %00000000
                        nextreg     ULA_CONTROL_REGISTER,  %00010000                ; set up ULA CONRTROL may need to change bit 0 at least, but bit 4 is separate extended keys from main matrix
.InitialisingMessage:   MessageAt   0,0,InitialiseMessage
                        call        PiReset
                        MessageAt   15,0,ResetMessage
                        break
                        call        WaitForAnyKey
DumpTest:               DumpDataTest $F0, (LineHeapSize), 5, LineHeap
                        call        WaitForAnyKey
                        
TestCode:               call        ENPiHello
                        call        WaitForAnyKey
                        call        l1_cls
                        call        ENPiPingTest
                        call        WaitForAnyKey
                        call        l1_cls
                        ld          a,1
                        ld          (Var_ViewPort),a
                        call        ENPiSetView
                        call        WaitForAnyKey
                        call        l1_cls
                        call        ENPiPlayerInput
                        call        WaitForAnyKey
                        call        l1_cls
                        call        ENPiAddShip
                        call        WaitForAnyKey
                        call        l1_cls
                        call        ENPiUpdateUniverse
                        call        WaitForAnyKey
                        call        l1_cls
                        call        ENPiFireECM
                        call        WaitForAnyKey                        
                        call        l1_cls
                        call        ENPiRenderData
                        call        WaitForAnyKey
                        DumpDataToPi $F0, (LineHeapSize), 5, LineHeap
                        call        WaitForAnyKey
                        call        l1_cls
                        call        ENPiSetView ; to test that redner data was OK
EndLoop:                jp          EndLoop
InitialiseMessage:      db 'Starting',0
ResetMessage:           db 'PiReset',0
;--------------------------------------------------------------------------------------
; Elite Pi Commands
;
Var_ViewPort:           DB      0
Var_BYTE                DB      0
PiSendCommand:          MACRO   cmd
                        ld      d,cmd
                        call    PiWriteByte
                        ENDM
PiSendShortDataBlock:   MACRO   dataAddr, dataLen
                        ld      hl,dataAddr
                        ld      b,dataLen
                        call    PiWriteDataBlock
                        ENDM
                      
;--------------------------------------------------------------------------------------
;Receiving data heap
; Size aliases
CloudHeapSize:
CompassHeapSize:
PositionHeapSize:
MatrixHeapSize:
LaserHeapSize:
ScannerDataSize:
LineHeapSize:           DB      0
; Data aliases
CloudHeap:              ; DS      4 * 16
LaserHeap:
MatrixHeap:
PositionHeap:
CompassHeap:
StatusHeap:
ScannerHeap:            ; DS (3*15) + 9                       ; so its ships + star, planet,scanner, data size determins the poitn where it bedomes star data
LineHeap:               DS      256*5
;--------------------------------------------------------------------------------------
ENPiHello:              MessageAt 0,2,CommandMessage
                        PiSendCommand   1
                        MessageAt 9,2,SentMessage
                        MessageAt 13,2,HelloMessage
                        ld      hl,HelloMessage
                        ld      b,5             ; 5 characters
                        ld      e,1             ; fixed, no terminating 0
                        call    PiWriteString
                        MessageAt 18,2,SentHello
                        MessageAt 22,2,ReadingMessage
                        ld      hl,HelloResponse
                        ld      d,5             ; 5 characters
                        ld      e,1             ; fixed, no terminating 0
                        call    PiReadString
                        MessageAt  0,3,HelloResponse
                        ret
;--------------------------------------------------------------------------------------
ENPiPingTest:           MessageAt 0,4,CommandMessage
                        PiSendCommand 2
                        MessageAt 9,4,SentMessage
                        MessageAt 13,4,PingMessage
                        call    PiReadByte
                        ld      hl,PingCode
                        add     a,'0'
                        ld      (hl),a
                        MessageAt   0,5,ResponseMessage
                        ret
;--------------------------------------------------------------------------------------
ENPiSetView:            MessageAt 0,6,CommandMessage
                        PiSendCommand 18
                        MessageAt 9,6,SentMessage
                        MessageAt 13,6,ViewMessage
                        ld      a,(Var_ViewPort)
                        ld      d,a
                        call    PiWriteByte
                        MessageAt  25,6,SentMessage
                        ret
;--------------------------------------------------------------------------------------
; 0x15 To Test    Request Render data
ENPiRenderData:         PiSendCommand   $15
                        MessageAt 9,6,SentMessage
                        MessageAt 13,6,RenderMessage
                        call    PiReadByte                  ; Read number of lines to render
                        and     a
                        ret     z
                        ld      (LineHeapSize),a            ; Cache line list
                        PrintHexARegAt 0,0
                        ld      a,(LineHeapSize)
                        ld      hl,LineHeap
                        ld      d,5                         ; de = 5 byte blocks of data includin gline colour
                        ld      e,a
                        mul     de
                        call    PiReadBlock
                        ; Stick in here drawing lines later
                        ret
;--------------------------------------------------------------------------------------
; 0x16 Input......Request Explode Cloud data, returns render position as xy, age, & ship size, leaves drawing to main game engine
ENPiCloudList:          PiSendCommand   $16
                        call    PiReadByte
                        ld      (CloudHeapSize),a
                        and     a
                        ret     z
                        ld      hl,CloudHeap
                        ld      d,a
                        ld      e,4
                        mul     de
                        call    PiReadBlock
                        ret
;--------------------------------------------------------------------------------------
; 0x1A To Test    Request Compass Position Data,Retubnr
ENPiCompassList:        PiSendCommand   $1A
                        call    PiReadByte
                        ld      (CompassHeapSize),a
                        and     a
                        ld      hl,CompassHeap
                        ld      d,3         ; x y z (255 rear, else front)
                        add     a,3         ; factor in star,planet,station, if no ships then a is 0
                        ld      e,a
                        mul     de
                        call    PiReadBlock
                        ret
; 0x1B To Test    Request Compass Position (ship nbr, if bit 7 set then 1 = sun 2 = planet 3 = station) > 4x8 bit values for color, x,y,stick length (signed)
;                 writes to ixh = x ixl = y a = z
ENPiCompassNbr:         PiSendCommand   $1B
                        call    PiReadByte
                        ld      ixh,a
                        call    PiReadByte
                        ld      ixl,a
                        call    PiReadByte
                        ret
; 0x1C To Test    Request all 3d Position Data > next byte is number of ships, followed by 3x24 bit for sun, 3x24 bit for planet, 3x24 bit for space station, nbr ships x 1x8 bit ship index, 3x16 bit for ships
ENPiPositionList:       PiSendCommand   $1C
                        call    PiReadByte
                        ld      (PositionHeapSize),a
                        ld      d,10            ; Ship Nbr x y z are all 16.8 format
                        mul     de
                        ld      hl,3*3          ; star, planet,station
                        add     hl,de
                        ex      de,hl           ; de = length
                        ld      hl,PositionHeap
                        call    PiReadBlock
                        ret  
; 0x1D To Test    Request ship n Position Data (ship nbr, if bit 7 set then 1 = sun 2 = planet 3 = station) >  followed by 3x24 bit for sun, 3x24 bit for planet, 3x24 bit for space station, nbr ships x 3x16 bit for ships
ENPiPositionNbr:        PiSendCommand   $1D
                        ld      (PositionHeapSize),a
                        ld      hl,PositionHeap
                        ld      de, 9*3            ; x y z are all 16.8 format
                        call    PiReadBlock
                        ret  
; 0x1E To Test    Request Matrix data (ships + space station)
ENPiMatrixList:         PiSendCommand   $1E
                        ld      (MatrixHeapSize),a
                        ld      d,(2*9)+1           ; ship nbr 3 x 3 grid of 2 byte values 
                        inc     a                   ; add in space station
                        ld      e,a
                        mul     de
                        dec     de                  ; space station does not have a ship nbr
                        call    PiReadBlock
                        ret
; 0x1F To Test    Request Ship matrix (ship nbr, if bit 7 set then 1 = sun 2 = planet 3 = station)
ENPiMatrixNbr:          PiSendCommand   $1F
                        ld      hl,MatrixHeap
                        ld      de,9*2
                        call    PiReadBlock
                        ret
; 0x20 To Test    Firing > next byte is ship id that would be hit by laser in low byte, bit 7 is 0 for front 1 for rear, FF means no hit
ENPiFiringLaser:        PiSendCommand   $20
                        call    PiReadByte
                        ret
; 0x21 Input      List of lasers hitting player and direction, first byte count follwoed by ship id and facing as per 0x20
ENPiLaserList:          PiSendCommand   $21
                        call    PiReadByte
                        ld      (LaserHeapSize),a
                        ret     z
                        ld      hl,LaserHeap
                        ld      d,2
                        ld      a,a
                        mul     de
                        call    PiReadBlock
                        ret
; 0x22 Input      Missile Hit Check, loops through all missiles in flight: first byte is missile id (low nibble), high nibble nbr of ships hit, list of ships his and distance from missile, if ship id is hit bit 7 then direect hit and no distance byte

;--------------------------------------------------------------------------------------
; 0x23 To Test    Fire ECM, byte = duration
ENPiFireECM:            PiSendCommand   $23
                        ld      d,$50
                        call    PiWriteByte
                        ret
; 0x30 To Test    Add Ship    > next bytes are Type, position, rotation, state (what here) also used for launch missile, flags as bit mask for overides 7=Angry,6 = scared, 5 = hunter, 4 trader, 3 = courier, 2 = bezerk, 1 = has cloak,, 0=has_ecm
; Note position needs to move to 16.8 code is currently 8.8
AddType:                DB 1
AddPosition:            DW $1001, $2002, $0F03
AddRotation:            DW $0100, $0001, $0001, $0001, $0100, $0001, $0001,$0001, $0100
AddRotandSpeed:         DB $01, $02, $03, $04, $05
AddFlags:               DB 0
AddLen:                 equ 31
ENPiAddShip:            PiSendCommand $30
                        PiSendShortDataBlock AddType, AddLen
                        ret
; 0x31 To Test    Ship Dead   > next byte is ship number
ENPiShipDead:           PiSendCommand   $31
                        ld      d,0
                        call    PiWriteByte
                        ret
; 0x32 To Test    Remove Ship > next byte is ship number
ENPiRemoveShip:         PiSendCommand   $33
                        ld      d,0
                        call    PiWriteByte
                        ret
; 0x40 Input      Request ship nbrs in range X of position , 3x8 bit for position, 1x8bit for range
RangeData:              DB      $20,$20,$20,$30
RangeResult:            DS      16
ENPiShipsInRange:       PiSendCommand   $40
                        PiSendShortDataBlock RangeData,4
                        call    PiReadByte
                        ret     z                       ; if zero then no data
                        ld      e,a
                        ld      d,0
                        ld      hl,RangeResult
                        call    PiReadBlock
                        ret 
;--------------------------------------------------------------------------------------
; 0x66 To Test    Shutdown
ENPisShutdown:          PiSendCommand   $66
                        ret
;--------------------------------------------------------------------------------------
; 0x67 To Test    Restart Universe
ENPiResetUniverse:      PiSendCommand   $67
                        ret
;--------------------------------------------------------------------------------------
; 0x68 Input      Performed Jump
JumpSampleSeeds:        DW  $AF, $B0, $34, $54, $76, $01
ENPiPerformedJump:      PiSendCommand   $68
                        PiSendShortDataBlock JumpSampleSeeds,6
                        ret
;--------------------------------------------------------------------------------------
; 0x69 Input      Undock Player assuming existing seed it valid
ENPiUndock:             PiSendCommand   $69
                        ret
;--------------------------------------------------------------------------------------
; 0x6A Input      Undock Player Seeded, used if we need to set new seed, e.g. after load game
ENPiUndockSeeded:       PiSendCommand   $6A
                        PiSendShortDataBlock JumpSampleSeeds,6
                        ret
;--------------------------------------------------------------------------------------
; 0x70 Input      Player input
PlayerInput:            DW $0201, $0403,$0605,$0807
ENPiPlayerInput:        PiSendCommand   $70
                        PiSendShortDataBlock PlayerInput, 8
                        ret
;--------------------------------------------------------------------------------------
; 0x71 Input      Update Universe
ENPiUpdateUniverse:     PiSendCommand   $71
                        ret
;--------------------------------------------------------------------------------------
; 0x72 Input      Update Universe n ticks, tick count in d
EMPiUpdateTicks:        push    de
                        PiSendCommand   $72
                        pop     de
                        call    PiWriteByte
                        ret
; 0x73 Input      Update tactics all
ENPiUndateTactics:      PiSendCommand   $73
                        ret
;--------------------------------------------------------------------------------------
; 0x74 Input      Update tactics ship n (bit 7 means space station), ship Id in d
ENPiTacticsNbr:         push    de
                        PiSendCommand   $74
                        pop     de
                        call    PiWriteByte
                        ret
; 0x75 Input      get all status data upper nibble byte 1 ship nbr lowe nibble + next byte 12 bit mask + 2 bytes for space station
;                 Bit Mask   11, 10, 9 111 In Use and alive
;                                      100 In Use Dead
;                                      101 In Use Exploding
;                                      110 In Use to remove
;                             8 Is Angry
;                             7 Is Scared
;                             6 Is Firing
;                             5 Is Berzerk
;                             4 Is cloaked
;                             3 Is hunter
;                             2 ,1 0    111 Is Trader
;                                       100 Is Pirate
;                                       101 Is Authority
;                                       110 Is Courier
;                                       001 Is Thargoid
;                             1 ECM Active
;                             0
ENPiGetStatusAll:       PiSendCommand  $75
                        call    PiReadByte
                        inc     a
                        ld      d,a
                        ld      e,2
                        mul     de
                        ld      hl,StatusHeap
                        call    PiReadBlock
                        ret
; 0x76 Input      get ship n status data (bit 7 means space station), returns status in de
ENPiGetStatusNbr:       push    de
                        PiSendCommand  $76
                        pop     de
                        call    PiWriteByte
                        call    PiReadWord
                        ret
; 0x80 Input      get all scanner data next byte is number of ships, followed by 1 byte ship nbr, 3x1 byte, x1,y1,y2, blob is draw at y2
ENPiGetScannerAll:      PiSendCommand   $80
                        call    PiReadByte
                        ld      (ScannerDataSize),a
                        ld      d,a
                        ld      e,4                         ; ship nbr, x1 y1 y2
                        mul     de
                        ld      hl,9                        ; Star, Planet Station
                        add     hl,de
                        ex      hl,de                       ; de = total data block now
                        ld      hl,ScannerHeap
                        call    PiReadBlock
                        ret
; 0x81 Input      get ship scanner data > object id, bit 7 shifs to bodies < returns 3x1 byte, x1,y1,y2, blob is draw at y2
;                 d = ship nbr, returns de x1 y1 a y2
ENPiGetScannerNbr:      push    de
                        PiSendCommand   $80
                        pop     de
                        call    PiWriteByte
                        call    PiReadByte
                        ld      d,a
                        call    PiReadByte
                        ld      e,a
                        call    PiReadByte
                        ret
; 0x90 Input      set object status > object nbr
;                 a = object nbr, de = status mask as per get status TODO shall we do as a word instead of two bytes?
ENPiSetObjectStatus:    push    de,,af
                        PiSendCommand   $90
                        pop     af
                        ld      d,a
                        call    PiWriteByte
                        pop     de
                        ld      ixl,e
                        call    PiWriteByte
                        ld      e,ixl
                        call    PiWriteByte
                        ret
; 0xA0 Input      set all mode 1 = all objects regarless of if they exist, 0 = only ones where object used = true
; 0xF0 to 0xFF    send command in a reg then send b messages from memory location hl with d a multiplier based on packet size
;                 d = 1 for byte, 2 for word, 3 for 8.8 etc
; Raw data dump, hl = address, de  length in bytes
ENPiDumpData:           push    hl,,de,,bc
                        PiSendCommand   a
                        pop     hl,,bc,,de
                        ld      bc,de
                        call    PiWriteLongDataBlock        ; hl = address of string to write, bc  = length
                        ret
ENPiDumpDataTest:       push    hl,,de,,bc
                        pop     hl,,de,,bc
                        ld      bc,de
                        call    PiTestLongDataBlock        ; hl = address of string to write, bc  = length
                        ret

;--------------------------------------------------------------------------------------
; Tests to implement

;--------------------------------------------------------------------------------------
; viarables for printing
HelloMessage:           DB 'Hello',0
CommandMessage:         DB 'Command',0
SentMessage:            DB 'Sent',0
SentHello:              DB 'String Hello',0
ReadingMessage:         DB 'Reading',0
PingMessage:            db 'Ping ',0,0
HelloResponse:          db 'XXXXX',0,0,0,0,0,0,0,0
ViewMessage:            db 'View Set',0,0,0
RenderMessage:          db 'Render',0
ResponseMessage:        DB      'Ping Result : '
PingCode:               DB      '0', 0
StringMessage:          DB '                               ',0
StringClear:            DB '...............................',0
;--------------------------------------------------------------------------------------
; Pi diagnostics
; d = row char e = col pixel
ClearMessageArea:       push    af,,bc,,hl,,de
                        ld      hl,StringMessage
                        ld      b,30
                        ld      a,0
.fillLoop:              ld      (hl),a
                        inc     hl
                        djnz    .fillLoop
                        pop     af,,bc,,hl,,de
                        ret
PrintPortBinary:        push    af,,bc,,hl,,de
                        ld      d,12
                        ld      e,20
                        GetNextReg 152
                        call    l1_print_bin8_l2r_at_char
                        ld      d,12
                        ld      e,10
                        GetNextReg 153
                        call    l1_print_bin8_l2r_at_char
                        ld      d,12
                        ld      e,0
                        GetNextReg 155
                        call    l1_print_bin8_l2r_at_char
                        pop     af,,bc,,hl,,de
                        ret
;--------------------------------------------------------------------------------------
; Pi Library

PiSetnDSRnCTSnACK:      MACRO
                        nextreg 155,0
                        ENDM
PiSetnDSRCTSnACK:       MACRO
                        nextreg 155,2
                        ENDM
PiSetDSR:               MACRO
                        nextreg 155,1           ; Set DSR high andy anything else writable low
                        ENDM
PiSetnCTSACK:           MACRO
                        nextreg 155,4           ; Set ACK high andy anything else writable low
                        ENDM
PiSetReadMode:          nextreg 144, 0              ; pins 4 to 7 read  enable
                        nextreg 145, 0              ; pins 0 to 3 read enable
                        nextreg 147,2+4             ; data ready pin read, CTS write, ack write , Desync read
                        MessageAt 0,15,PiInReadMode
                        MessageAt 15,15,PiClearMode
                        ret

PiSetWriteMode:         nextreg 144, 16+32+64+128   ;pins 4 to 7 write enable
                        nextreg 145, 1+2+4+8        ;pins 0 to 3 write enable
                        nextreg 147, 1 + 8          ;DSR and Desync pins write enable
                        MessageAt 15,15,PiInWriteMode
                        MessageAt 0,15,PiClearMode
                        ret
;--------------------------------------------------------------------------------------
PiReset:                nextreg 147,1+2+4           ; data ready 0, cts 0, ack 0
                        nextreg 155,0               ;
                        ret
                        call    PiSetWriteMode      ; clear out bits on data line
                        nextreg 152,0
                        nextreg 153,0
                        nextreg 155,0               ; and clear DSR,DeSync
                        call    PiSetReadMode
                        nextreg 155,0               ; and clear CTS,ACK
                        ret

;--------------------------------------------------------------------------------------
;  Write byte held in d (data)
PiWriteByte:            IFDEF DEBUGMODE
                            ld      a,d
                            ld      (Var_BYTE),a
                        ENDIF
                        call    PiSetWriteMode      ; Write Mode
                        PiSetnDSRnCTSnACK
                        IFDEF DEBUGMODE
                            MessageAt 0,16,PiWaitCTS
                            MessageAt 15,16,PiClearMode
                            MessageAt 0,17,PiClearMode
                        ENDIF
                        call    PiWaitforCTSnACK    ; wait for Clear to send
                        IFDEF DEBUGMODE
                            MessageAt 15,16,PiWriting
                            MessageAt 0,16,PiClearMode
                            ld      a,(Var_BYTE)
                            PrintHexARegAt 25,19
                        ENDIF
                        ld      a,d                 ; build up port values and send
                        IFDEF DEBUGMODE
                            ld      a,(Var_BYTE)    ; DEBUG
                            ld      d,a
                        ENDIF
                        and     %11110000           ; we don't swap here and let the pi
                        nextreg 152,a               ; handle that
                        ld      a,d                 ; .
                        and     %00001111           ; .
                        nextreg 153,a               ; .
                        PiSetDSR                    ; Data Set is Ready
                        IFDEF DEBUGMODE
                            MessageAt 0,17,PiWaitACK
                            MessageAt 15,16,PiClearMode
                        ENDIF
                        call    PiWaitforACK        ; Poll for Ackowledge
                        IFDEF DEBUGMODE
                            MessageAt 0,17,PiClearMode
                            MessageAt 15,16,PiClearMode
                        ENDIF
                        PiSetnDSRnCTSnACK           ; clear DSR
                        ret
;--------------------------------------------------------------------------------------
; result in a, affects af, hl, de
PiReadByte:             call    PiSetReadMode       ; read mode
                        PiSetnDSRCTSnACK            ; CTS and nACK (DSR is write only so won't matter)
                        IFDEF DEBUGMODE
                            MessageAt 0,16,PiWaitDSR
                            MessageAt 15,16,PiClearMode
                        ENDIF
                        call    PiWaitforDSR        ; Wait for data to be ready
                        IFDEF DEBUGMODE
                            MessageAt 15,16,PiReading
                        ENDIF
                        GetNextReg  152             ; Read data and re-assemble byte
                        and     %11110000           ; it will be pre swapnib on the pi side
                        ld      l,a                 ; so we don't have to here
                        GetNextReg  153             ; .
                        and     %00001111           ; .
                        or      l                   ; .
                        IFDEF DEBUGMODE
                            ld      (Var_BYTE),a
                        ENDIF
                        PiSetnCTSACK                ; not clear to send, ACK set
                        IFDEF DEBUGMODE
                            ld      a,(Var_BYTE)
                            PrintHexARegAt 25,19
                            ld      a,(Var_BYTE)
                            MessageAt 15,16,PiClearMode
                        ENDIF
                        ret
;--------------------------------------------------------------------------------------
; hl = target, de = length
PiReadBlock:            exx                         ; preserve hl and de
                        call    PiReadByte          ; read data
                        exx                         ; recover hl and de
                        ld      (hl),a              ; of course exx does not affect af so we can do this
                        inc     hl                  ; next memory addr
                        dec     de                  ; a byte done
                        ld      a,d                 ; have we reached the last byte
                        or      e                   ; .
                        jp      nz,PiReadBlock      ; if no loop
                        ret
;--------------------------------------------------------------------------------------
; Diag messages
PiInWriteMode:          DB 'In Write  Mode',0
PiInReadMode:           DB 'In Read Mode ',0
PiClearMode:            DB '.............',0
PiWriting               DB 'Writing      ',0
PiReading               DB 'Reading      ',0
PiWaitCTS:              DB 'Waiting CTS  ',0
PiWaitDSR:              DB 'Waiting DSR  ',0
PiWaitACK:              DB 'Waiting ACK  ',0
;--------------------------------------------------------------------------------------
; hl = word to write
PiWriteWord:            ld      d,l
                        push    hl
                        call    PiWriteByte
                        pop     hl
                        ld      d,h
                        call    PiWriteByte
                        ret
;--------------------------------------------------------------------------------------
; de = word read - low high sequence
PiReadWord:             call    PiReadByte
                        ld      e,a
                        call    PiReadByte
                        ld      d,a

; hl = address of string to write, bc  = length
PiWriteLongDataBlock:   ld      d,(hl)              ; assume that if d = 0 then we are writing 256 bytes
                        push    bc,,hl
                        call    PiWriteByte
                        pop     bc,,hl
                        inc     hl
                        dec     bc
                        ld      a,b
                        or      c
                        jp      nz,PiWriteLongDataBlock ; if d has not hit zero then loop
                        ret
; hl = address of string to write, bc  = length
PiTestLongDataBlock:    ld      d,(hl)              ; assume that if d = 0 then we are writing 256 bytes
                        push    bc,,hl
                        nop
                        pop     bc,,hl
                        inc     hl
                        dec     bc
                        ld      a,b
                        or      c
                        jp      nz,PiTestLongDataBlock ; if d has not hit zero then loop
                        ret
; hl = address of string to write, b = length
PiWriteDataBlock:       push    bc
                        ld      d,(hl)              ; assume that if d = 0 then we are writing 256 bytes
                        IFDEF DEBUGMODE
                            push ix
                            push af
                            ld  a,d
                            ld (ix+0),a
                            MessageAt 20,5,StringMessage
                            pop  af
                        ENDIF
                        call    PiWriteByte
                        inc     hl
                        IFDEF DEBUGMODE
                            pop  ix
                            inc  ix
                        ENDIF
                        pop     bc
                        djnz    PiWriteDataBlock ; if d has not hit zero then loop
                        ret
; hl = address of string to write, b = length, if e = 0 then send terminating /0
; Max string length 256 characters
PiWriteString:          IFDEF DEBUGMODE
                            call    ClearMessageArea
                            ld      ix,StringMessage
                        ENDIF
                        call    PiWriteDataBlock
                        ZeroA                       ; if e is zero then send a /0 to finish
                        or      e                   ; .
                        ret     nz                  ; this is done if receiving end is expecting variable string length
                        ld      d,a                 ; d is data to write
                        call    PiWriteByte         ; a will stil be /0
                        ret
; hl = address to write to, d = Limit, if e = 0 then expecting terminating /0 (i.e. variable length) else d = fixed string length
PiReadString:           push    de,,hl              ; Recived
                        call    PiReadByte
                        pop     hl
                        ld      (hl),a
                        inc     hl
                        pop     de
                        dec     d
                        ret     z                   ; d provides a hard limit or fixed string length depending on e
                        or      e                   ; if the byte read the a is 0 and e was zero then this will be zero
                        jp      nz,PiReadString
                        ret

PiWaitforACK:           GetNextReg  155             ; read status until bit 2 (ACK) is set
                        call    PrintPortBinary
                        and %00000100               ;
                        jp  z,PiWaitforACK          ; if not then spin waiting
                        ret

PiWaitforCTS:           GetNextReg  155             ; read status until bit 1 (CTS) is set
                        IFDEF DEBUGMODE
                            call    PrintPortBinary
                        ENDIF
                        and %00000010               ;
                        jp  z,PiWaitforCTS          ; if not then spin waiting
                        ret
PiWaitforCTSnACK:       GetNextReg  155             ; read status for ACK low and CTS High
                        IFDEF DEBUGMODE
                            call    PrintPortBinary
                        ENDIF
                        and %00000110               ; just want ACK and CTS bits
                        cp  %00000010               ; if CTS is set and ACK is clear
                        jp  nz,PiWaitforCTSnACK     ; reg value is just CTS then we are good
                        ret

PiWaitforDSR:           GetNextReg  155             ; read status until bit 2 (DSR) is set
                        IFDEF DEBUGMODE
                            call    PrintPortBinary
                        ENDIF
                        and %00000001               ;
                        jp  z,PiWaitforDSR          ; if not then spin waiting
                        ret


SetPiDesycMode:

PIDescyncReceived:


SendAddObject:


                        INCLUDE	"../../Hardware/memfill_dma.asm"
; Layer 1  ------------------------------------------------------------------------------------------------------------------------
    INCLUDE "../../Layer1Graphics/layer1_attr_utils.asm"
    INCLUDE "../../Layer1Graphics/layer1_cls.asm"
    INCLUDE "../../Layer1Graphics/layer1_print_at.asm"

; Keyboard
KeyAddrTab				DB	$FE, $FD, $FB, $F7, $EF, $DF, $BF, $7F

WaitForNoKey:           ld      hl,KeyAddrTab                   ; de = table of IO ports to read
                        ld		b,8                             ; 8 ports to ready
.PortReadLoop:          ld		a,(hl)							; Set up port to read as (hl)$FE
                        in		a,($FE)							; read port to a
                        and     %00011111
                        cp      %00011111
                        jr      nz ,WaitForNoKey
                        inc		hl                              ; and ready for next read
                        djnz    .PortReadLoop
                        ret
WaitMsg:                DB "Waiting for Input",0
WaitClear:              DB ".................",0
WaitForAnyKey:          push    af,,de,,bc,,hl
                        IFDEF DEBUGMODE
                            MessageAt 10,20,WaitMsg
                        ENDIF
                        call    WaitForNoKey
.waitKeyLoop:           ld		hl,KeyAddrTab                   ; de = table of IO ports to read
                        ld		b,8                             ; 8 ports to ready
.PortReadLoop:          ld		a,(hl)							; Set up port to read as (hl)$FE
                        in		a,($FE)							; read port to a
                        and     %00011111
                        cp      %00011111
                        jp      nz,.WaitComplete
                        ret     nz
                        inc		hl                              ; and ready for next read
                        djnz    .PortReadLoop
                        jp      .waitKeyLoop
.WaitComplete:          pop     af,,de,,bc,,hl
                        IFDEF DEBUGMODE
                            MessageAt 10,20,WaitClear
                        ENDIF
                        ret

MainNonBankedCodeEnd:


    SAVENEX OPEN "piiotest.nex", EliteNextStartup , TopOfStack
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
    DISPLAY "Main Non Banked Code End ", MainNonBankedCodeEnd , " Bytes free ", 0B000H - MainNonBankedCodeEnd
    ASSERT MainNonBankedCodeEnd < 0B000H, Program code leaks intot interrup vector table
