
;--------------------------------------------------------------------------------------
; Elite Pi Command MACROS
;

PiSendCommand:          MACRO   cmd
                        ld      d,cmd
                        call    PiWriteByte
                        ENDM
PiSendShortDataBlock:   MACRO   dataAddr, dataLen
                        ld      hl,dataAddr
                        ld      b,dataLen
                        call    PiWriteDataBlock
                        ENDM
PiSendHLShortDataBlock: MACRO   dataLen
                        ld      b,dataLen
                        call    PiWriteDataBlock
                        ENDM;--------------------------------------------------------------------------------------
;Receiving data heap
; Size aliases
CloudHeapSize:
CompassHeapSize:
PositionHeapSize:
MatrixHeapSize:
LaserHeapSize:
ScannerDataSize:
LineHeapSize:           DB      0
HeapSizeBytes:          DW      0
; Data aliases
CloudHeap:              ; DS      4 * 16
LaserHeap:
MatrixHeap:
PositionHeap:
CompassHeap:
StatusHeap:
ScannerHeap:            ; DS (3*15) + 9                       ; so its ships + star, planet,scanner, data size determins the poitn where it bedomes star data
LineHeap:               
ResultHeap:             DS      256*5
;--------------------------------------------------------------------------------------
; read a data block of A records, each record D size into location HL
ENPiReadRecords:        ld      e,a
                        mul     de
                        ld      (HeapSizeBytes),de
                        call    PiReadBlock
                        ret
;--------------------------------------------------------------------------------------
; Send Hello command, loads result into result heap
ENPiHello:              PiSendCommand   1
                        ld      hl,ResultHeap   ; general purpose response heap
                        ld      d,5             ; 5 characters
                        ld      e,1             ; fixed, no terminating 0
                        call    PiReadString
                        ret
;--------------------------------------------------------------------------------------
; A = response to ping request which should be 1
ENPiPingTest:           PiSendCommand 2
                        call    PiReadByte
                        ret
;--------------------------------------------------------------------------------------
; view to write should be in a reg
ENPiSetView:            ex      af,af'
                        PiSendCommand 18
                        ex      af,af'
                        ld      d,a
                        call    PiWriteByte
                        ret
;--------------------------------------------------------------------------------------
; 0x15 To Test    Request Render data
ENPiRenderData:         PiSendCommand   $15
                        call    PiReadByte                  ; Read number of lines to render
                        ld      (LineHeapSize),a            ; set line list size
                        and     a
                        ret     z                           ; we can bail out early if empty
                        ld      hl,LineHeap
                        ld      d,5                         ; de = 5 byte blocks of data includin gline colour
                        jp      ENPiReadRecords
;--------------------------------------------------------------------------------------
; 0x16 Input......Request Explode Cloud data, returns render position as xy, age, & ship size, leaves drawing to main game engine
ENPiCloudList:          PiSendCommand   $16
                        call    PiReadByte
                        ld      (CloudHeapSize),a
                        and     a
                        ret     z
                        ld      hl,CloudHeap
                        ld      d,4
                        jp      ENPiReadRecords
;--------------------------------------------------------------------------------------
; 0x1A To Test    Request Compass Position Data,Retubnr
ENPiCompassList:        PiSendCommand   $1A
                        call    PiReadByte
                        ld      (CompassHeapSize),a
                        and     a
                        ld      hl,CompassHeap
                        ld      d,3         ; x y z (255 rear, else front)
                        add     a,3         ; factor in star,planet,station, if no ships then a is 0
                        jp      ENPiReadRecords
;--------------------------------------------------------------------------------------
; 0x1B To Test    Request Compass Position (ship nbr, if bit 7 set then 1 = sun 2 = planet 3 = station) > 4x8 bit values for color, x,y,stick length (signed)
;                 writes to ixh = x ixl = y a = z
ENPiCompassNbr:         PiSendCommand   $1B
                        call    PiReadByte
                        ld      ixh,a
                        call    PiReadByte
                        ld      ixl,a
                        call    PiReadByte
                        ret
;--------------------------------------------------------------------------------------
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
;--------------------------------------------------------------------------------------
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
                        jp      ENPiReadRecords
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
; 0x70 Input      Player input at hl
ENPiPlayerInput:        PiSendCommand   $70
                        PiSendHLShortDataBlock 8
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
                        ret

PiSetWriteMode:         nextreg 144, 16+32+64+128   ;pins 4 to 7 write enable
                        nextreg 145, 1+2+4+8        ;pins 0 to 3 write enable
                        nextreg 147, 1 + 8          ;DSR and Desync pins write enable
                        ret
;--------------------------------------------------------------------------------------
PiReset:                nextreg 147,1+2+4           ; data ready 0, cts 0, ack 0
                        nextreg 155,0               ;
                        call    PiSetWriteMode      ; clear out bits on data line
                        nextreg 152,0
                        nextreg 153,0
                        nextreg 155,0               ; and clear DSR,DeSync
                        call    PiSetReadMode
                        nextreg 155,0               ; and clear CTS,ACK
                        ret

;--------------------------------------------------------------------------------------
;  Write byte held in d (data)
PiWriteByte:            call    PiSetWriteMode      ; Write Mode
                        PiSetnDSRnCTSnACK
                        call    PiWaitforCTSnACK    ; wait for Clear to send
                        ld      a,d                 ; build up port values and send
                        and     %11110000           ; we don't swap here and let the pi
                        nextreg 152,a               ; handle that
                        ld      a,d                 ; .
                        and     %00001111           ; .
                        nextreg 153,a               ; .
                        PiSetDSR                    ; Data Set is Ready
                        call    PiWaitforACK        ; Poll for Ackowledge
                        PiSetnDSRnCTSnACK           ; clear DSR
                        ret
;--------------------------------------------------------------------------------------
; result in a, affects af, hl, de
PiReadByte:             call    PiSetReadMode       ; read mode
                        PiSetnDSRCTSnACK            ; CTS and nACK (DSR is write only so won't matter)
                        call    PiWaitforDSR        ; Wait for data to be ready
                        GetNextReg  152             ; Read data and re-assemble byte
                        and     %11110000           ; it will be pre swapnib on the pi side
                        ld      l,a                 ; so we don't have to here
                        GetNextReg  153             ; .
                        and     %00001111           ; .
                        or      l                   ; .
                        PiSetnCTSACK                ; not clear to send, ACK set
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
                        call    PiWriteByte
                        inc     hl
                        pop     bc
                        djnz    PiWriteDataBlock ; if d has not hit zero then loop
                        ret
; hl = address of string to write, b = length, if e = 0 then send terminating /0
; Max string length 256 characters
PiWriteString:          call    PiWriteDataBlock
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
                        and %00000100               ;
                        jp  z,PiWaitforACK          ; if not then spin waiting
                        ret

PiWaitforCTS:           GetNextReg  155             ; read status until bit 1 (CTS) is set
                        and %00000010               ;
                        jp  z,PiWaitforCTS          ; if not then spin waiting
                        ret
PiWaitforCTSnACK:       GetNextReg  155             ; read status for ACK low and CTS High
                        and %00000110               ; just want ACK and CTS bits
                        cp  %00000010               ; if CTS is set and ACK is clear
                        jp  nz,PiWaitforCTSnACK     ; reg value is just CTS then we are good
                        ret

PiWaitforDSR:           GetNextReg  155             ; read status until bit 2 (DSR) is set
                        and %00000001               ;
                        jp  z,PiWaitforDSR          ; if not then spin waiting
                        ret

SetPiDesycMode:

PIDescyncReceived:

SendAddObject:
