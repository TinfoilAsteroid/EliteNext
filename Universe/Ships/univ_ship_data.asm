; In  flight ship data tables
; In  flight ship data tables
; There can be upto &12 objects in flight.
; To avoid hassle of memory heap managment, the free list
; will correspond to a memory bank offset so data will be held in
; 1 bank per universe object. Its a waste of a lot of memory but really
; 1 bank per universe object. Its a waste of a lot of memory but really
; simple that way. Each bank will be 8K and swapped on 8K slot 7 $E000 to $FFFF
; This means each gets its own line list, inwork etc

; "Runtime Ship Data paged into in Bank 7"
StartOfUniv:        DB "Universe PG"
StartOfUnivN:       DB "X"
; NOTE we can cheat and pre allocate segs just using a DS for now

;   \ -> & 565D \ See ship data files chosen and loaded after flight code starts running.
; Universe map substibute for INWK
;-Camera Position of Ship----------------------------------------------------------------------------------------------------------
                       INCLUDE "./Universe/Ships/AIRuntimeData.asm"
; moved to runtime asm
;                        INCLUDE "./Universe/Ships/ShipPosVars.asm"
;                        INCLUDE "./Universe/Ships/RotationMatrixVars.asm"
 
; Orientation Matrix [nosev x y z ] nose vector ( forward) 19 to 26
;                    [roofv x y z ] roof vector (up)
;                    [sidev x y z ] side vector (right)
;;rotXCounter                 equ UBnkrotXCounter         ; INWK +29
;;rotZCounter                 equ UBnkrotZCounter         ; INWK +30UBnkDrawCam0xLo   DB  0               ; XX18+0
univRAT      DB  0               ; 99
univRAT2     DB  0               ; 9A
univRAT2Val  DB  0               ; 9A

                        INCLUDE "./Universe/Ships/XX16Vars.asm"
                        INCLUDE "./Universe/Ships/XX25Vars.asm"
                        INCLUDE "./Universe/Ships/XX18Vars.asm"

; Used to make 16 bit reads a little cleaner in source code
UbnkZPoint                  DS  3
UbnkZPointLo                equ UbnkZPoint
UbnkZPointHi                equ UbnkZPoint+1
UbnkZPointSign              equ UbnkZPoint+2
                        INCLUDE "./Universe/Ships/XX15Vars.asm"
                        INCLUDE "./Universe/Ships/XX12Vars.asm"


; Post clipping the results are now 8 bit
UBnkVisibility              DB  0               ; replaces general purpose xx4 in rendering
UBnKDrawAsDot               DB  0               ; if 0 then OK, if 1 then just draw dot of line heap
UBnkProjectedY              DB  0
UBnkProjectedX              DB  0
UBnkProjected               equ UBnkProjectedY  ; resultant projected position
XX15Save                    DS  8
XX15Save2                   DS  8
VarBackface                 DB 0
; Heap (or array) information for lines and normals
; Coords are stored XY,XY,XY,XY
; Normals
; This needs re-oprganising now.
; Runtime Calculation Store

FaceArraySize               equ 30
EdgeHeapSize                equ 40
NodeArraySize               equ 40
LineArraySize               equ 50
; Storage arrays for data
; Structure of arrays
; Visibility array  - 1 Byte per face/normal on ship model Bit 7 (or FF) visible, 0 Invisible
; Node array corresponds to a processed vertex from the ship model transformed into world coordinates and tracks the node list from model
; NodeArray         -  4 bytes per element      0           1            2          3
;                                               X Coord Lo  Y Coord Lo   Z CoordLo  Sign Bits 7 6 5 for X Y Z Signs (set = negative)
; Line Array        -  4 bytes per eleement     0           1            2          3
;                                               X1          Y1           X2         Y2
UbnkFaceVisArray            DS FaceArraySize            ; XX2 Up to 16 faces this may be normal list, each entry is controlled by bit 7, 1 visible, 0 hidden
UBnkNodeArray               DS NodeArraySize * 4        ; XX3 Holds the points as an array, its an array not a heap
UBnkNodeArray2              DS NodeArraySize * 4        ; XX3 Holds the points as an array, its an array not a heap
UbnkLineArray               DS LineArraySize * 4        ; XX19 Holds the clipped line details
UBnkLinesHeapMax            EQU $ - UbnkLineArray
UbnkEdgeProcessedList DS EdgeHeapSize
; Array current Lengths
UbnkFaceVisArrayLen         DS 1
UBnkNodeArrayLen            DS 1
UbnkLineArrayLen            DS 1                        ; total number of lines loaded to array 
UbnkLineArrayBytes          DS 1                        ; total number of bytes loaded to array  = array len * 4
XX20                        equ UbnkLineArrayLen
varXX20                     equ UbnkLineArrayLen

UbnkEdgeHeapSize            DS 1
UbnkEdgeHeapBytes           DS 1
UBnkLinesHeapLen            DS 1
UbnKEdgeHeapCounter         DS 1
UbnKEdgeRadius              DS 1
UbnKEdgeShipType            DS 1
UbnKEdgeExplosionType       DS 1

; Node heap is used to write out transformed Vertexs

; Lines
UBnkXX19                    DS  3

UBnkHullCopy                DS  ShipDataLength
ScoopDebrisAddr             equ UBnkHullCopy + ScoopDebrisOffset	 
MissileLockLoAddr           equ UBnkHullCopy + MissileLockLoOffset	 
MissileLockHiAddr           equ UBnkHullCopy + MissileLockHiOffset	 
EdgeAddyAddr                equ UBnkHullCopy + EdgeAddyOffset		 
LineX4Addr                  equ UBnkHullCopy + LineX4Offset		 
GunVertexAddr               equ UBnkHullCopy + GunVertexOffset		 
ExplosionCtAddr             equ UBnkHullCopy + ExplosionCtOffset	 
VertexCtX6Addr              equ UBnkHullCopy + VertexCtX6Offset	 
EdgeCountAddr               equ UBnkHullCopy + EdgeCountOffset		 
BountyLoAddr                equ UBnkHullCopy + BountyLoOffset		 
BountyHiAddr                equ UBnkHullCopy + BountyHiOffset		 
FaceCtX4Addr                equ UBnkHullCopy + FaceCtX4Offset		 
DotAddr                     equ UBnkHullCopy + DotOffset			 
EnergyAddr                  equ UBnkHullCopy + EnergyOffset		 
SpeedAddr                   equ UBnkHullCopy + SpeedOffset			 
FaceAddyAddr                equ UBnkHullCopy + FaceAddyOffset		 
QAddr                       equ UBnkHullCopy + QOffset				 
LaserAddr                   equ UBnkHullCopy + LaserOffset			 
VerticesAddyAddr            equ UBnkHullCopy + VerticiesAddyOffset  
ShipTypeAddr                equ UBnkHullCopy + ShipTypeOffset       
ShipNewBitsAddr             equ UBnkHullCopy + ShipNewBitsOffset    
ShipAIFlagsAddr             equ UBnkHullCopy + ShipAIFlagsOffset
; Static Ship Data. This is copied in when creating the universe object
XX0                         equ UBnkHullCopy        ; general hull index pointer TODO find biggest ship design
;UBnkHullVerticies           DS  40 * 6              ; Type 10 is 37 verts so 40 to be safe
;UBnkHullEdges               DS  50 * 4              ; Type 10 is 46 edges sp 200 to be safe
;UBnkHullNormals             DS  20 * 4              ; type 10 is 14 edges so 20 to be safe

UBnkHullVerticies           DS  300                 ; can only be 255
UBnkHullEdges               DS  1200                ; can be 255 * 4
UBnkHullNormals             DS  300                 ; can only be 255


OrthagCountdown             DB  12

UBnkShipCopy                equ UBnkHullVerticies               ; Buffer for copy of ship data, for speed will copy to a local memory block, Cobra is around 400 bytes on creation of a new ship so should be plenty
UBnk_Data_len               EQU $ - StartOfUniv

ZeroUnivPitchAndRoll:   MACRO
                        xor     a
                        ld      (UBnKRotXCounter),a
                        ld      (UBnKRotZCounter),a
                        ENDM

MaxUnivPitchAndRoll:    MACRO
                        ld      a,127
                        ld      (UBnKRotXCounter),a
                        ld      (UBnKRotZCounter),a
                        ENDM                   

RandomUnivPitchAndRoll: MACRO
                        call    doRandom
                        or      %01101111
                        ld      (UBnKRotXCounter),a
                        call    doRandom
                        or      %01101111
                        ld      (UBnKRotZCounter),a
                        ENDM

RandomUnivSpeed:        MACRO
                        call    doRandom
                        and     31
                        ld      (UBnKspeed),a
                        ENDM
                        
MaxUnivSpeed:           MACRO
                        ld      a,31
                        ld      (UBnKspeed),a
                        ENDM
                        
ZeroUnivAccelleration:  MACRO
                        xor     a
                        ld      (UBnKAccel),a
                        ENDM
                        
SetShipHostile:         ld      a,(ShipNewBitsAddr)
                        or      ShipIsHostile 
                        ld      (ShipNewBitsAddr),a
                        ret

ClearShipHostile:       ld      a,(ShipNewBitsAddr)
                        and     ShipNotHostile 
                        ld      (ShipNewBitsAddr),a
                        ret

AequN1xorN2:            MACRO  param1,param2
                        ld      a,(param1)
                        xor     param2
                        ENDM

N0equN1byN2div256:      MACRO param1,param2,param3
                        ld      a,param3                        ; 
                        ld      e,a                         ; use e as var Q = value of XX15 [n] lo
                        ld      a,param2                        ; A = XX16 element
                        ld      d,a
                        mul
                        ld      a,d                         ; we get only the high byte which is like doing a /256 if we think of a as low                
                        ld      (param1),a                      ; Q         ; result variable = XX16[n] * XX15[n]/256
                        ENDM
                        
; --------------------------------------------------------------
ResetUBnkData:          ld      hl,StartOfUniv
                        ld      de,UBnk_Data_len
                        xor     a
                        call    memfill_dma
                        ret
; --------------------------------------------------------------
ResetUbnkPosition:      ld      hl,UBnKxlo
                        ld      b, 3*3
                        xor     a
.zeroLoop:              ld      (hl),a
                        inc     hl
                        djnz    .zeroLoop
                        ret

; --------------------------------------------------------------                        
; This sets the position of the current ship if its a player launched missile
UnivSetPlayerMissile:   call    InitialiseOrientation           ; Player  facing
                        call    ResetUbnkPosition               ; home position
                        ld      a,MissileDropHeight
                        ld      (UBnKylo),a
                        ld      a,$80
                        ld      (UBnKysgn),a
                        MaxUnivSpeed
                        ret
; --------------------------------------------------------------
; this applies blast damage to ship
ShipMissileBlast:       ld      a,(CurrentMissileBlastDamage)
                        ld      b,a
                        ld      a,(UbnKEnergy)                   ; Reduce Energy
                        sub     b
                        jp      UnivExplodeShip
                        jr      UnivExplodeShip
                        ld      (UbnKEnergy),a
                        ret
; --------------------------------------------------------------                        
; This sets the ship as a shower of explosiondwd
UnivExplodeShip:        ld      a,(UBnkaiatkecm)
                        or      ShipExploding
                        and     Bit7Clear
                        ld      (UBnkaiatkecm),a
                        xor     a
                        ld      (UbnKEnergy),a
                        ;TODO
                        ret

UnivSetDemoPostion:     call    UnivSetSpawnPosition
                        ld  a,%10000001
                        ld  (UBnkaiatkecm),a                    ; set hostinle, no AI, has ECM
                        ld      (ShipNewBitsAddr),a             ; initialise new bits logic
                        ld      a,$FF
                        ld      (UBnKRotZCounter),a             ; no pitch
                        ld      (UBnKRotXCounter),a             ; set roll to maxi on station
                        ZeroA
                        ld      (UBnKxsgn),a
                        ld      (UBnKysgn),a
                        ld      (UBnKzsgn),a
                        ld      hl,0
                        ld      (UBnKxlo),hl
                        ld      (UBnKylo),hl
                        ld      a,(ShipTypeAddr)
                        ld      hl,$05B0                            ; so its a negative distance behind
                        JumpIfANENusng ShipTypeStation, .SkipFurther
                        ld      a,5
                        add     h
                        ld      h,a
.SkipFurther            ld      (UBnKzlo),hl
                        ret
; --------------------------------------------------------------
; This sets the position of the current ship randomly, called after spawing
UnivSetSpawnPosition:   call    InitialiseOrientation
                        RandomUnivPitchAndRoll
                        call    doRandom                        ; set x lo and y lo to random
.setXlo:                ld      (UBnKxlo),a 
.setYlo:                ld      (UBnKylo),a
.setXsign:              rrca                                    ; rotate by 1 bit right
                        ld      b,a
                        and     SignOnly8Bit
                        ld      (UBnKxsgn),a
.setYSign:              ld      a,b                             ; get random back again
                        rrca                                    ; rotate by 1 bit right
                        ld      b,a
                        and     SignOnly8Bit                    ; and set y sign
                        ld      (UBnKysgn),a
.setYHigh:              rrc     b                               ; as value is in b rotate again
                        ld      a,b                             ; 
                        and     31                              ; set y hi to random 0 to 31
                        ld      (UBnKyhi),a                     ;
.setXHigh:              rrc     b                               ; as value is in b rotate again
                        ld      a,b
                        and     31                              ; set x hi to random 0 to 31
                        ld      c,a                             ; save shifted into c as well
                        ld      (UBnKxhi),a
.setZHigh:              ld      a,80                            ; set z hi to 80 - xhi - yhi - carry
                        sbc     b
                        sbc     c
                        ld      (UBnKzhi),a
.CheckIfBodyOrJunk:     ReturnIfMemEquN ShipTypeAddr, ShipTypeJunk
                        ld      a,b                             ; its not junk to set z sign
                        rrca                                    ; as it can jump in
                        and     SignOnly8Bit
                        ld      (UBnKzsgn),a
                        ret
                        
; --------------------------------------------------------------                        
; This sets current univrse object to space station
ResetStationLaunch:     ld  a,%10000001
                        ld  (UBnkaiatkecm),a                    ; set hostinle, no AI, has ECM
                        xor a
                        ld      (UBnKRotZCounter),a             ; no pitch
                        ld      (ShipNewBitsAddr),a             ; initialise new bits logic
                        ld      a,$FF
                        ld      (UBnKRotXCounter),a             ; set roll to maxi on station
.SetPosBehindUs:        ld      hl,$0000
                        ld      (UBnKxlo),hl
                        ld      hl,$0000
                        ld      (UBnKylo),hl
                        ld      hl,$01B0                            ; so its a negative distance behind
                        ld      (UBnKzlo),hl
                        xor     a
                        ld      (UBnKxsgn),a
                        ld      (UBnKysgn),a
                        ld      a,$80
                        ld      (UBnKzsgn),a
.SetOrientation:        call    LaunchedOrientation             ; set initial facing
                        ret
    ;Input: BC = Dividend, DE = Divisor, HL = 0
;Output: BC = Quotient, HL = Remainder

; Initialiase data, iyh must equal slot number
;                   iyl must be ship type
UnivInitRuntime:        ld      (UbnKShipBankNbr),a
                        ld      bc,UBnKRuntimeSize
                        ld      hl,UBnKShipType
                        ZeroA
.InitLoop:              ld      (hl),a
                        inc     hl
                        djnz    .InitLoop            
.SetBankData:           ld      a,iyh
                        ld      (UbnKShipBankNbr),a
                        ld      a,iyl
                        ld      (UBnKShipType),a
                        call    GetShipBankId                ; this will mostly be debugging info
                        ld      (UBnkShipModelBank),a        ; this will mostly be debugging info
                        ld      a,b                          ; this will mostly be debugging info
                        ld      (UBnkShipModelNbr),a         ; this will mostly be debugging info
                        ret


ADDHLDESignedv3:        ld      a,h
                        and     SignOnly8Bit
                        ld      b,a                         ;save sign bit in b
                        xor     d                           ;if h sign and d sign were different then bit 7 of a will be 1 which means 
                        JumpIfNegative ADDHLDEOppSGN        ;Signs are opposite there fore we can subtract to get difference
ADDHLDESameSigns:       ld      a,b
                        or      d
                        JumpIfNegative ADDHLDESameNeg       ; optimisation so we can just do simple add if both positive
                        add     hl,de
                        ret
ADDHLDESameNeg:         ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a
                        add     hl,de
                        ld      a,SignOnly8Bit
                        or      h                           ; now set bit for negative value, we won't bother with overflow for now TODO
                        ld      h,a
                        ret
ADDHLDEOppSGN:          ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit                     ; here HL and DE are opposite 
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a
                        or      a
                        sbc     hl,de
                        jr      c,ADDHLDEOppInvert
ADDHLDEOppSGNNoCarry:   ld      a,b                         ; we got here so hl > de therefore we can just take hl's previous sign bit
                        or      h
                        ld      h,a                         ; set the previou sign value
                        ret
ADDHLDEOppInvert:       NegHL                                                   ; we need to flip the sign and 2'c the Hl result
                        ld      a,b
                        xor     SignOnly8Bit                ; flip sign bit
                        or      h
                        ld      h,a                         ; recover sign
                        ret 
                
; we could cheat, flip the sign of DE and just add but its not very optimised
SUBHLDESignedv3:        ld      a,h
                        and     SignOnly8Bit
                        ld      b,a                         ;save sign bit in b
                        xor     d                           ;if h sign and d sign were different then bit 7 of a will be 1 which means 
                        JumpIfNegative SUBHLDEOppSGN        ;Signs are opposite therefore we can add
SUBHLDESameSigns:       ld      a,b
                        or      d
                        JumpIfNegative SUBHLDESameNeg       ; optimisation so we can just do simple add if both positive
                        or      a
                        sbc     hl,de
                        JumpIfNegative SUBHLDESameOvrFlw            
                        ret
SUBHLDESameNeg:         ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a
                        or      a
                        sbc     hl,de
                        JumpIfNegative SUBHLDESameOvrFlw            
                        ld      a,h                         ; now set bit for negative value, we won't bother with overflow for now TODO
                        or      SignOnly8Bit
                        ld      h,a
                        ret
SUBHLDESameOvrFlw:      NegHL                                                        ; we need to flip the sign and 2'c the Hl result
                        ld      a,b
                        xor     SignOnly8Bit                ; flip sign bit
                        or      h
                        ld      h,a                         ; recover sign
                        ret         
SUBHLDEOppSGN:          or      a                                               ; here HL and DE are opposite so we can add the values
                        ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a     
                        add     hl,de
                        ld      a,b                         ; we got here so hl > de therefore we can just take hl's previous sign bit
                        or      h
                        ld      h,a                         ; set the previou sign value
                        ret

    
SBCHLDESigned:          JumpOnBitSet h,7,SBCHLDEhlNeg
SBCHLDEhlPos:           JumpOnBitSet h,7,SBCHLDEhlNeg
SBCHLDEhlPosDePos:      sbc     hl,de                           ; ignore overflow for now will sort later TODO
                        ret
SBCHLDEhlPosDeNeg:      res     7,d
                        add     hl,de                           ; ignore overflow for now will sort later TODO
                        set     7,d
                        ret
SBCHLDEhlNeg:           res     7,h
                        JumpOnBitSet d,7,SBCHLDEhlNegdeNeg
SBCHLDEhlNegdePos:      sbc     hl,de                       ; ignore overflow for now will sort later TODO
                        set     7,h     
                        ret
SBCHLDEhlNegdeNeg:      res     7,d
                        add     hl,de                   ; ignore overflow for now will sort later TODO
                        set     7,d
                        set     7,h
                        ret
    
; Roate around axis
; varAxis1 and varAxis2 point to the address of the axis to rotate
; so the axis x1 points to roofv  x , y or z
;             x2           nosev or sidev  x, y or z
;   Axis1 = Axis1 * (1 - 1/512)  + Axis2 / 16
;   Axis2 = Axis2 * (1 - 1/512)  - Axis1 / 16
; var RAT2 gives direction  
; for pitch x we come in with Axis1 = roofv_x and Axis2 = nosev_x
;-Set up S R -----------------------------------------
; optimised we don't deal with sign here just the value of roof axis / 512
MVS5RotateAxis:         ld      hl,(varAxis1)   ; work on roofv axis to get (1- 1/152) * roofv axis
                        ld      e,(hl)
                        inc     hl
                        ld      d,(hl)          ; de = Axis1 (roofv x for pitch x)
                        ex      de,hl           ; hl = Axis1 (roofv x for pitch x)
                        ld      a,h
                        and     SignOnly8Bit                
                        ld      iyh,a           ; iyh = sign Axis1
                        ld      a,h
                        and     SignMask8Bit    ; a = Axis1 (roof hi axis  unsigned)
                        srl     a               ; a = Axis1/2
                        ld      e,a             ; 
                        ld      a,iyh           ; A = Axis 1 sign
                        ld      d,a             ; de = signed Axis1 / 512
                        or      a               ; clear carry
                        call    SUBHLDESignedv3 ; hl = roof axis - (roof axis /512) which in effect is roof * (1-1/512)
;-Push to stack roof axis - (roofaxis/152)  ----------------------------------------------------------------------------------
                        push    hl              ; save hl on stack PUSH ID 1 (roof axis - roofv aixs /512)
                        ld      a,l
                        ld      (varR),a
                        ld      a,h
                        ld      (varS),a        ;  RS now equals (1- 1/152) * roofv axis or (roof axis - roofv aixs /512)
;-calculate roofv latter half of calc   
                        ld      hl,(varAxis2)   ; now work on nosev axis to get nosev axis / 16
                        ld      e,(hl)
                        inc     hl
                        ld      d,(hl)          ; de = value of roof axis
                        ld      a,d
                        and     SignOnly8Bit
                        ld      iyh,a           ; save sign 
                        ld      a,d 
                        and     SignMask8Bit    ; a = nosev hi axis  unsigned
                        ld      d,a             ; de = abs (nosev)
                        ShiftDERight1
                        ShiftDERight1
                        ShiftDERight1
                        ShiftDERight1           ; de = nosev /16 unsigned
                        ld      a,(univRAT2)     ; need to consider direction, so by defautl we use rat2, but flip via sign bit
                        xor     iyh             ; get the sign back we saveded from DE in so de = nosev axis / 16 signed
                        and     SignOnly8Bit
                        or      d
                        ld      d,a             ; de = nosev /16 signed and ready as if we were doing a + or - based on RAT2            
;;; ld      a,e
;;;     or      iyh
;;; ld      (varP),a        ; PA now equals nosev axis / 16 signed
;-now AP = nosev /16  --------------------------------------------------------------------------------------------------------
                        pop     hl              ; get back RS POP ID 1
    ;ex     de,hl           ; swapping around so hl = AP and de = SR , shoud not matter though as its an add
;-now DE = (roofaxis/512) hl - abs(nosevaxis) --------------------------------------------------------------------------------
                        call    ADDHLDESignedv3 ; do add using hl and de
                        push    hl              ; we use stack to represent var K here now varK = Nosev axis /16 + (1 - 1/512) * roofv axis PUSH ID 2
;-push to stack nosev axis + roofvaxis /512  which is what roofv axis will be ------------------------------------------------  
;-- Set up SR = 1 - 1/512 * nosev-----------------------
                    ld      hl,(varAxis2)   ; work on nosev again to get nosev - novesv / 512
                    ld      e,(hl)
                    inc     hl
                    ld      d,(hl)
                    ex      de,hl
                    ld      a,h
                    and     $80
                    ld      iyh,a
                    ld      a,h
                    and     SignMask8Bit    ; a = roof hi axis  unsigned
                    srl     a               ; now A = unsigned 15 bit nosev axis hi / 2 (or in effect nosev / 512
                    ld      e,a
                    ld      a,iyh
                    ld      d,a
                    or      a               ; clear carry
                    call    SUBHLDESignedv3
;   sbc     hl,de           ; hl = nosev - novesv / 512
                    push    hl              ; save hl on stack  PUSH ID 3
                    ld      a,l
                    ld      (varP),a        ; p = low of resuilt
                    ld      a,h
                    and     SignMask8Bit    ; a = roof hi axis  unsigned
                    ld      (varT),a        ; t = high of result
;-- Set up TQ
                    ld      hl,(varAxis1)   ; now work on roofv axis / 16
;   ld      hl,(varAxis2)   ; work on nosev again 
                    ld      e,(hl)
                    inc     hl
                    ld      d,(hl)
                    ld      a,d
                    and     $80
                    ld      iyh,a           ; save sign 
                    ld      a,d
                    and     SignMask8Bit    ; a = nosev hi axis  unsigned
                    ld      d,a             ; de = abs (nosev)
                    ShiftDERight1
                    ShiftDERight1
                    ShiftDERight1
                    ShiftDERight1           ; de = nosev /16 unsigned
                    ld      a,(univRAT2)
                    xor     iyh             ; get the sign back in so de = nosev axis / 16 signed
                    and     $80
                    or      d
                    ld      d,a
;;; ld      a,e
;;;     or      iyh
;;; ld      (varP),a        ; PA now equals nosev axis / 16 signed
                    pop     hl              ; get back RS   POP ID 3
;   ex      de,hl           ; swapping around so hl = AP and de = SR , shoud not matter though as its an add
                    call    SUBHLDESignedv3 ; do add using hl and de
;-- Update nosev ---------------------------------------
                    ex      de,hl           ; save hl to de
                    ld      hl,(varAxis2)
                    ld      (hl),e
                    inc     hl
                    ld      (hl),d          ; copy result into nosev
;-- Update roofv ---------------------------------------
                    pop     de              ; get calc saved on stack POP ID 2
                    ld      hl,(varAxis1)
                    ld      (hl),e
                    inc     hl
                    ld      (hl),d          ; copy result into nosev
                    ret
    
                    include "Universe/Ships/InitialiseOrientation.asm"

;----------------------------------------------------------------------------------------------------------------------------------
OrientateVertex:

;                      [ sidev_x sidev_y sidev_z ]   [ x ]
;  projected [x y z] = [ roofv_x roofv_y roofv_z ] . [ y ]
;                      [ nosev_x nosev_y nosev_z ]   [ z ]
;

;----------------------------------------------------------------------------------------------------------------------------------
TransposeVertex:
;                      [ sidev_x roofv_x nosev_x ]   [ x ]
;  projected [x y z] = [ sidev_y roofv_y nosev_y ] . [ y ]
;                      [ sidev_z roofv_z nosev_z ]   [ z ]
VectorToVertex:
;                     [ sidev_x roofv_x nosev_x ]   [ x ]   [ x ]
;  vector to vertex = [ sidev_y roofv_y nosev_y ] . [ y ] + [ y ]
;                     [ sidev_z roofv_z nosev_z ]   [ z ]   [ z ]

Project:
PROJ:                   ld      hl,(UBnKxlo)                    ; Project K+INWK(x,y)/z to K3,K4 for center to screen
                        ld      (varP),hl
                        ld      a,(UBnKxsgn)
                        call    PLS6                            ; returns result in K (0 1) (unsigned) and K (3) = sign note to no longer does 2's C
                        ret     c                               ; carry means don't print
                        ld      hl,(varK)                       ; hl = k (0 1)
                        ; Now the question is as hl is the fractional part, should this be multiplied by 127 to get the actual range
                        ld      a,ViewCenterX
                        add     hl,a                            ; add unsigned a to the 2's C HL to get pixel position
                        ld      (varK3),hl                      ; K3 = X position on screen
ProjectY:               ld      hl,(UBnKylo)
                        ld      (varP),hl
                        ld      a,(UBnKysgn)
                        call    PLS6
                        ret     c
                        ld      hl,(varK)                       ; hl = k (0 1)
                        ld      a,ViewCenterY
                        add     hl,a                            ; add unsigned a to the 2's C HL to get pixel position
                        ld      (varK4),hl                      ; K3 = X position on screen
                        ret
;--------------------------------------------------------------------------------------------------------
                        include "./ModelRender/EraseOldLines-EE51.asm"
                        include "./ModelRender/TrimToScreenGrad-LL118.asm"
                        include "./ModelRender/CLIP-LL145.asm"
;--------------------------------------------------------------------------------------------------------
                        include "./Universe/Ships/CopyRotmatToTransMat.asm"
                        include "./Universe/Ships/TransposeXX12ByShipToXX15.asm"
                        include "./Maths/Utilities/ScaleNodeTo8Bit.asm"

;--------------------------------------------------------------------------------------------------------
SetFaceAVisible:        ld      hl,UbnkFaceVisArray
                        add     hl,a
                        ld      a,$FF
                        ld      (hl),a
                        ret
;--------------------------------------------------------------------------------------------------------
SetFaceAHidden:         ld      hl,UbnkFaceVisArray
                        add     hl,a
                        xor     a
                        ld      (hl),a
                        ret
;--------------------------------------------------------------------------------------------------------
SetAllFacesVisible:     ld      a,(FaceCtX4Addr)            ; (XX0),Y which is XX0[0C] or UBnkHullCopy+FaceCtX4Addr                                 ;;; Faces count (previously loaded into b up front but no need to shave bytes for clarity
                        srl     a                           ; else do explosion needs all vertices                                                  ;;;
                        srl     a                           ;  /=4  TODO add this into blueprint data for speed                                                           ;;; For loop = 15 to 0
                        ld      b,a                         ; b = Xreg = number of normals, faces
                        ld      hl,UbnkFaceVisArray
                        ld      a,$FF
SetAllFacesVisibleLoop:
EE30:                   ld      (hl),a
                        inc     hl
                        djnz    SetAllFacesVisibleLoop
                        ret
;--------------------------------------------------------------------------------------------------------
SetAllFacesHidden:      ld      a,(FaceCtX4Addr)            ; (XX0),Y which is XX0[0C] or UBnkHullCopy+ShipHullFacesCount                           ;;; Faces count (previously loaded into b up front but no need to shave bytes for clarity
                        srl     a                           ; else do explosion needs all vertices                                                  ;;;
                        srl     a                           ;  /=4                                                                                  ;;; For loop = 15 to 0
                        ld      b,a                         ; b = Xreg = number of normals, faces
                        ld      b,16
                        ld      hl,UbnkFaceVisArray
                        ld      a,$00
SetAllFacesHiddenLoop:  ld      (hl),a
                        inc     hl
                        djnz    SetAllFacesHiddenLoop
                        ret

;;;;X = normal scale
;;;;ZtempHi = zhi
;;;;......................................................
;;;; if ztemp hi <> 0                                   ::Scale Object Distance
;;;;  Loop                                              ::LL90
;;;;     inc X
;;;;     divide X, Y & ZtempHiLo by 2
;;;;  Until ZtempHi = 0
;;;;......................................................
;-LL21---------------------------------------------------------------------------------------------------
                        include "Universe/Ships/NormaliseTransMat.asm"
;-LL91---------------------------------------------------------------------------------------------------

; Now we have
;   * XX18(2 1 0) = (x_sign x_hi x_lo)
;   * XX18(5 4 3) = (y_sign y_hi y_lo)
;   * XX18(8 7 6) = (z_sign z_hi z_lo)
;
;--------------------------------------------------------------------------------------------------------
                        include "Universe/Ships/InverseXX16.asm"
;--------------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------
;   XX12(1 0) = [x y z] . sidev  = (dot_sidev_sign dot_sidev_lo)  = dot_sidev
;   XX12(3 2) = [x y z] . roofv  = (dot_roofv_sign dot_roofv_lo)  = dot_roofv
;   XX12(5 4) = [x y z] . nosev  = (dot_nosev_sign dot_nosev_lo)  = dot_nosev
; Returns
;
;   XX12(1 0)            The dot product of [x y z] vector with the sidev (or _x)
;                        vector, with the sign in XX12+1 and magnitude in XX12
;
;   XX12(3 2)            The dot product of [x y z] vector with the roofv (or _y)
;                        vector, with the sign in XX12+3 and magnitude in XX12+2
;
;   XX12(5 4)            The dot product of [x y z] vector with the nosev (or _z)
;                        vector, with the sign in XX12+5 and magnitude in XX12+4
XXCURRENTN0equN1byN2div256: MACRO param1, param2, param3
                        ld      c,0
                        ld      a,param3                      ; 
                        bit     7,a
                        jr      z,.val2Pos
;HandleSignebits
                        neg
                        ld      c,$80
.val2Pos:               ld      e,a                         ; use e as var Q = value of XX15 [n] lo
                        ld      a,param2                        ; A = XX16 element
                        bit     7,a
                        jr      z,.val1Pos
;HandleSignebits
                        neg
                        ld      b,a
                        ld      a,c
                        xor     $80
                        ld      c,a
                        ld      a,b
.val1Pos:               ld      d,a
;AequAmulQdiv256:
                        mul
                        ld      a,c
                        bit     7,a
                        ld      a,d                         ; we get only the high byte which is like doing a /256 if we think of a as low                
                        jr      z,.resultPos
                        neg
.resultPos:             ld      (param1),a                      ; Q         ; result variable = XX16[n] * XX15[n]/256
                        ENDM
                

 ; TESTEDOK
XX12DotOneRow:
XX12CalcX:              N0equN1byN2div256 varT, (hl), (UBnkXScaled)       ; T = (hl) * regXX15fx /256 
                        inc     hl                                  ; move to sign byte
XX12CalcXSign:          AequN1xorN2 UBnkXScaledSign,(hl)             ;
                        ld      (varS),a                            ; Set S to the sign of x_sign * sidev_x
                        inc     hl
XX12CalcY:              N0equN1byN2div256 varQ, (hl),(UBnkYScaled)       ; Q = XX16 * XX15 /256 using varQ to hold regXX15fx
                        ldCopyByte varT,varR                        ; R = T =  |sidev_x| * x_lo / 256
                        inc     hl
                        AequN1xorN2 UBnkYScaledSign,(hl)             ; Set A to the sign of y_sign * sidev_y
; (S)A = |sidev_x| * x_lo / 256  = |sidev_x| * x_lo + |sidev_y| * y_lo
STequSRplusAQ           push    hl
                        call    baddll38                            ; JSR &4812 \ LL38   \ BADD(S)A=R+Q(SA) \ 1byte add (subtract)
                        pop     hl
                        ld      (varT),a                            ; T = |sidev_x| * x_lo + |sidev_y| * y_lo
                        inc     hl
XX12CalcZ:              N0equN1byN2div256 varQ,(hl),(UBnkZScaled)       ; Q = |sidev_z| * z_lo / 256
                        ldCopyByte varT,varR                        ; R = |sidev_x| * x_lo + |sidev_y| * y_lo
                        inc     hl
                        AequN1xorN2 UBnkZScaledSign,(hl)             ; A = sign of z_sign * sidev_z
; (S)A= |sidev_x| * x_lo + |sidev_y| * y_lo + |sidev_z| * z_lo        
                        call    baddll38                            ; JSR &4812 \ LL38   \ BADD(S)A=R+Q(SA)   \ 1byte add (subtract)
; Now we exit with A = result S = Sign        
                        ret


;-- LL51---------------------------------------------------------------------------------------------------------------------------
;TESTED OK
XX12EquXX15DotProductXX16:
XX12EquScaleDotOrientation:                         ; .LL51 \ -> &4832 \ XX12=XX15.XX16  each vector is 16-bit x,y,z
                        ld      bc,0                                ; LDX, LDY 0
                        ld      hl,UBnkTransmatSidevX     
                        call    XX12DotOneRow
                        ld      (UBnkXX12xLo),a
                        ld      a,(varS)
                        ld      (UBnkXX12xSign),a
                        ld      hl,UBnkTransmatRoofvX     
                        call    XX12DotOneRow
                        ld      (UBnkXX12yLo),a
                        ld      a,(varS)
                        ld      (UBnkXX12ySign),a
                        ld      hl,UBnkTransmatNosevX     
                        call    XX12DotOneRow
                        ld      (UBnkXX12zLo),a
                        ld      a,(varS)
                        ld      (UBnkXX12zSign),a
                        ret
;--------------------------------------------------------------------------------------------------------
                        include "./Universe/Ships/CopyXX12ScaledToXX18.asm"
                        include "./Universe/Ships/CopyXX12toXX15.asm"
                        include "./Universe/Ships/CopyXX18toXX15.asm"
                        include "./Universe/Ships/CopyXX18ScaledToXX15.asm"
                        include "./Universe/Ships/CopyXX12ToScaled.asm"
;--------------------------------------------------------------------------------------------------------
                        include "./Maths/Utilities/DotProductXX12XX15.asm"
;--------------------------------------------------------------------------------------------------------
; scale Normal. IXL is xReg and A is loaded with XX17 holds the scale factor to apply
                        include "Universe/Ships/ScaleNormal.asm"
;--------------------------------------------------------------------------------------------------------
                        include "./Universe/Ships/ScaleObjectDistance.asm"
;--------------------------------------------------------------------------------------------------------

; Backface cull        
; is the angle between the ship -> camera vector and the normal of the face as long as both are unit vectors soo we can check that normal z > 0
; normal vector = cross product of ship ccordinates 
;

                        include "./Universe/Ships/CopyFaceToXX15.asm"
                        include "./Universe/Ships/CopyFaceToXX12.asm"
;--------------------------------------------------------------
; Original loginc in EE29 (LL9 4 of 12)
; Enters with XX4 = z distnace scaled to 1 .. 31
; get number of faces * 4      FaceCntX4
; return if no faces
; get Face Normal scale factor FaceScale (XX17)
; get ship pos z hi     (XX18)
; While Z hi <> 0
;    FaceScale = FaceScale + 1           (XX17)
;    Ship pos y = ship pos y / 2         (XX18)
;    ship pos x = ship pos x / 2         (XX18)
;    ship pos z = ship pos z / 2         (XX18)
; Loop
; Copy Ship Pos (XX18) to Scaled         (XX15)
; Get Dot Product of Scaled (XX15) and XX16 (pre inverted) into XX12
; Copy XX12 into XX18
; For each face
;     Get Face sign and visibility distance byte 
;     if normal visibility range  < XX4
;        Get Face data into XX12
;        if FaceScale (XX17) >= 4                           
;            Copy Ship Pos (XX18) to scaled (XX15)                                                                  ::LL143
;        else
;           Copy FaceScale scaled to X  (XX17)
;LabelOverflowLoop:
;           Copy FaceData (XX12) to Scaled (XX15)                                                                   ::LL92
;           While X >= 0
;              X--                                                                                                  ::LL93
;              if  x >= 0
;                  XX15x = XX15x / 2
;                  XX15y = XX15y / 2
;                  XX15y = XX15y / 2
;           loop 
;           AddZ = FaceData (XX12)z +  ShipPos (XX18)z                                                              ::LL94
;           if A > 256 (i.e. was overflow)
;               ShipPos (XX18)x,y & z = ShipPos(XX18)x,y & z / 2 (Divide each component by 2)
;               X = 1
;               Goto LabelOverflowLoop
;           else
;              Scaled (XX15) Z = AddZ
;           endif
;           AddX = FaceData (XX12)x +  ShipPos (XX18)x
;           if A > 256 (i.e. was overflow)
;               ShipPos (XX18)x,y & z = ShipPos(XX18)x,y & z / 2 (Divide each component by 2)
;               X = 1
;               Goto LabelOverflowLoop
;           else
;              Scaled (XX15) X = AddX
;           endif
;           AddY = FaceData (XX12)y +  ShipPos (XX18)y
;           if A > 256 (i.e. was overflow)
;               ShipPos (XX18)x,y & z = ShipPos(XX18)x,y & z / 2 (Divide each component by 2)
;               X = 1
;               Goto LabelOverflowLoop
;           else
;              Scaled (XX15) Y = AddY
;           endif
;        endif
;        calculate dot product XX12.XX15  (XX15x * XX12x /256 + XX15y * XX12y /256 + XX15z * XX12z /256)        ::LL89
;        if dot product < 0
;           set face visible
;        else
;           set face invisible
;        end if
;     else
;       Set FaceVisibility to true
;     end if
; Next Face     

ScaleDownXX15byIXH:     dec     ixh
                        ret     m
                        ld      hl,UBnkXScaled
                        srl     (hl)                        ; XX15  \ xnormal lo/2 \ LL93+3 \ counter X
                        inc     hl                          ; looking at XX15 x sign now
                        inc     hl                          ; looking at XX15 y Lo now
                        srl     (hl)                        ; XX15+2    \ ynormal lo/2
                        inc     hl                          ; looking at XX15 y sign now
                        inc     hl                          ; looking at XX15 z Lo now
                        srl     (hl)
                        jp      ScaleDownXX15byIXH
                        ret

DivideXX18By2:          ld      hl,UBnkDrawCam0xLo
                        srl     (hl)                        ; XX18  \ xnormal lo/2 \ LL93+3 \ counter X
                        inc     hl                          ; looking at XX18 x sign now
                        inc     hl                          ; looking at XX18 y Lo now
                        srl     (hl)                        ; XX18+2    \ ynormal lo/2
                        inc     hl                          ; looking at XX18 y sign now
                        inc     hl                          ; looking at XX18 z Lo now
                        srl     (hl)
                        ret

;line of sight vector = [x y z] + face normal vector

;               [ [x y z] . sidev + normal_x ]   [ normal_x ]
;  visibility = [ [x y z] . roofv + normal_y ] . [ normal_y ]
;               [ [x y z] . nosev + normal_z ]   [ normal_z ]
;
;--------------------------------------------------------------
; line of sight (eye outwards dot face normal vector < 0
; So lin eof sight = vector from 0,0,0 to ship pos, now we need to consider teh ship's facing
; now if we add teh veector for teh normal(times magnitude)) to teh ship position we have the true center of the face
; now we can calcualt teh dot product of this caulated vector and teh normal which if < 0 is goot. this means we use rot mat not inverted rotmat.

RotateXX15ByTransMatXX16:
                        ld      hl,UBnkTransmatSidevX               ; process orientation matrix row 0
                        call    XX12ProcessOneRow
                        ld      b,a                                 ; get 
                        ld      a,l
                        or      b
                        ld      (UBnkXX12xSign),a                   ; a = result with sign in bit 7
                        ld      a,l
                        ld      (UBnkXX12xLo),a                     ; that is result done for

                        ld      hl,UBnkTransmatRoofvX               ; process orientation matrix row 0
                        call    XX12ProcessOneRow
                        ld      b,a                                 ; get 
                        ld      a,l
                        or      b
                        ld      (UBnkXX12ySign),a                   ; a = result with sign in bit 7
                        ld      a,l
                        ld      (UBnkXX12yLo),a                     ; that is result done for
                 
                        ld      hl,UBnkTransmatNosevX               ; process orientation matrix row 0
                        call    XX12ProcessOneRow
                        ld      b,a                                 ; get 
                        ld      a,l
                        or      b
                        ld      (UBnkXX12zSign),a                   ; a = result with sign in bit 7
                        ld      a,l
                        ld      (UBnkXX12zLo),a                     ; that is result done for
                        ret

    include "./ModelRender/BackfaceCull.asm"
;--------------------------------------------------------------------------------------------------------
; Process edges
; .....................................................
TransposeNodeVal:   MACRO arg0?
        ldCopyByte  UBnK\0sgn,Ubnk\1PointSign           ; UBnkXSgn => XX15+2 x sign
        ld          bc,(UBnkXX12\0Lo)                   ; c = lo, b = sign   XX12XLoSign
        xor         b                                   ; a = UBnkKxsgn (or XX15+2) here and b = XX12xsign,  XX12+1 \ rotated xnode h                                                                             ;;;           a = a XOR XX12+1                              XCALC
        jp          m,NodeNegative\1                                                                                                                                                            ;;;           if sign is +ve                        ::LL52   XCALC
; XX15 [0,1] = INWK[0]+ XX12[0] + 256*INWK[1]                                                                                       ;;;          while any of x,y & z hi <> 0 
NodeXPositive\1:
        ld          a,c                                 ; We picked up XX12+0 above in bc Xlo
        ld          b,0                                 ; but only want to work on xlo                                                           ;;;              XX15xHiLo = XX12HiLo + xpos lo             XCALC
        ld          hl,(UBnK\0lo)                       ; hl = XX1 UBNKxLo
        ld          h,0                                 ; but we don;t want the sign
        add         hl,bc                               ; its a 16 bit add
        ld          (Ubnk\1Point),hl                    ; And written to XX15 0,1 
        xor         a                                   ; we want to write 0 as sign bit (not in original code)
        ld          (UbnkXPointSign),a
        jp          FinishedThisNode\1
; If we get here then _sign and vertv_ have different signs so do subtract
NodeNegative\1:        
LL52\1:                                                 ;
        ld          hl,(UBnK\0lo)                       ; Coord
        ld          bc,(UBnkXX12\0Lo)                   ; XX12
        ld          b,0                                 ; XX12 lo byte only
        sbc         hl,bc                               ; hl = UBnKx - UBnkXX12xLo
        jp          p,SetAndMop\1                       ; if result is positive skip to write back
NodeXNegSignChange\1:        
; If we get here the result is 2'c compliment so we reverse it and flip sign
        call        negate16hl                          ; Convert back to positive and flip sign
        ld          a,(Ubnk\1PointSign)                 ; XX15+2
        xor         $80                                 ; Flip bit 7
        ld          (Ubnk\1PointSign),a                 ; XX15+2
SetAndMop\1:                             
        ld          (UBnK\0lo),hl                       ; XX15+0
FinishedThisNode\1
                    ENDM

;--LL52 to LL55-----------------------------------------------------------------------------------------------------------------                    

TransposeXX12NodeToXX15:
        ldCopyByte  UBnKxsgn,UbnkXPointSign           ; UBnkXSgn => XX15+2 x sign
        ld          bc,(UBnkXX12xLo)                   ; c = lo, b = sign   XX12XLoSign
        xor         b                                   ; a = UBnkKxsgn (or XX15+2) here and b = XX12xsign,  XX12+1 \ rotated xnode h                                                                             ;;;           a = a XOR XX12+1                              XCALC
        jp          m,NodeNegativeX                                                                                                                                                            ;;;           if sign is +ve                        ::LL52   XCALC
; XX15 [0,1] = INWK[0]+ XX12[0] + 256*INWK[1]                                                                                       ;;;          while any of x,y & z hi <> 0 
NodeXPositiveX:
        ld          a,c                                 ; We picked up XX12+0 above in bc Xlo
        ld          b,0                                 ; but only want to work on xlo                                                           ;;;              XX15xHiLo = XX12HiLo + xpos lo             XCALC
        ld          hl,(UBnKxlo)                       ; hl = XX1 UBNKxLo
        ld          h,0                                 ; but we don;t want the sign
        add         hl,bc                               ; its a 16 bit add
        ld          (UbnkXPoint),hl                    ; And written to XX15 0,1 
        xor         a                                   ; we want to write 0 as sign bit (not in original code)
        ld          (UbnkXPointSign),a
        jp          FinishedThisNodeX
; If we get here then _sign and vertv_ have different signs so do subtract
NodeNegativeX:        
LL52X:                                                 ;
        ld          hl,(UBnKxlo)                       ; Coord
        ld          bc,(UBnkXX12xLo)                   ; XX12
        ld          b,0                                 ; XX12 lo byte only
        sbc         hl,bc                               ; hl = UBnKx - UBnkXX12xLo
        jp          p,SetAndMopX                       ; if result is positive skip to write back
NodeXNegSignChangeX:        
; If we get here the result is 2'c compliment so we reverse it and flip sign
        call        negate16hl                          ; Convert back to positive and flip sign
        ld          a,(UbnkXPointSign)                 ; XX15+2
        xor         $80                                 ; Flip bit 7
        ld          (UbnkXPointSign),a                 ; XX15+2
SetAndMopX:                             
        ld          (UBnKxlo),hl                       ; XX15+0
FinishedThisNodeX:

LL53:

        ldCopyByte  UBnKysgn,UbnkYPointSign           ; UBnkXSgn => XX15+2 x sign
        ld          bc,(UBnkXX12yLo)                   ; c = lo, b = sign   XX12XLoSign
        xor         b                                   ; a = UBnkKxsgn (or XX15+2) here and b = XX12xsign,  XX12+1 \ rotated xnode h                                                                             ;;;           a = a XOR XX12+1                              XCALC
        jp          m,NodeNegativeY                                                                                                                                                            ;;;           if sign is +ve                        ::LL52   XCALC
; XX15 [0,1] = INWK[0]+ XX12[0] + 256*INWK[1]                                                                                       ;;;          while any of x,y & z hi <> 0 
NodeXPositiveY:
        ld          a,c                                 ; We picked up XX12+0 above in bc Xlo
        ld          b,0                                 ; but only want to work on xlo                                                           ;;;              XX15xHiLo = XX12HiLo + xpos lo             XCALC
        ld          hl,(UBnKylo)                       ; hl = XX1 UBNKxLo
        ld          h,0                                 ; but we don;t want the sign
        add         hl,bc                               ; its a 16 bit add
        ld          (UbnkYPoint),hl                    ; And written to XX15 0,1 
        xor         a                                   ; we want to write 0 as sign bit (not in original code)
        ld          (UbnkXPointSign),a
        jp          FinishedThisNodeY
; If we get here then _sign and vertv_ have different signs so do subtract
NodeNegativeY:        
LL52Y:                                                 ;
        ld          hl,(UBnKylo)                       ; Coord
        ld          bc,(UBnkXX12yLo)                   ; XX12
        ld          b,0                                 ; XX12 lo byte only
        sbc         hl,bc                               ; hl = UBnKx - UBnkXX12xLo
        jp          p,SetAndMopY                       ; if result is positive skip to write back
NodeXNegSignChangeY:        
; If we get here the result is 2'c compliment so we reverse it and flip sign
        call        negate16hl                          ; Convert back to positive and flip sign
        ld          a,(UbnkYPointSign)                 ; XX15+2
        xor         $80                                 ; Flip bit 7
        ld          (UbnkYPointSign),a                 ; XX15+2
SetAndMopY:                             
        ld          (UBnKylo),hl                       ; XX15+0
FinishedThisNodeY:
    

TransposeZ:
LL55:                                                   ; Both y signs arrive here, Onto z                                          ;;;
        ld          a,(UBnkXX12zSign)                   ; XX12+5    \ rotated znode hi                                              ;;;
        JumpOnBitSet a,7,NegativeNodeZ                    ; LL56 -ve Z node                                                           ;;;
        ld          a,(UBnkXX12zLo)                     ; XX12+4 \ rotated znode lo                                                 ;;;
        ld          hl,(UBnKzlo)                        ; INWK+6    \ zorg lo                                                       ;;;
        add         hl,a                                ; hl = INWKZ + XX12z                                                        ;;;
        ld          a,l
        ld          (varT),a                            ;                                                                           ;;;
        ld          a,h
        ld          (varU),a                            ; now z = hl or U(hi).T(lo)                                                 ;;;
        ret                                             ; LL57  \ Node additions done, z = U.T                                      ;;;
; Doing additions and scalings for each visible node around here                                                                    ;;;
NegativeNodeZ:
LL56:                                                   ; Enter XX12+5 -ve Z node case  from above                                  ;;;
        ld          hl,(UBnKzlo)                        ; INWK+6 \ z org lo                                                         ;;;
        ld          bc,(UBnkXX12zLo)                    ; XX12+4    \ rotated z node lo                                                 ......................................................
        ld          b,0                                 ; upper byte will be garbage
        ClearCarryFlag
        sbc         hl,bc                               ; 6502 used carry flag compliment
        ld          a,l
        ld          (varT),a                            ; t = result low
        ld          a,h
        ld          (varU),a                            ; u = result high
        jp          po,MakeNodeClose                    ; no overflow to parity would be clear
LL56Overflow:
        cp          0                                   ; is varU 0?
        jr          nz,NodeAdditionsDone                ; Enter Node additions done, UT=z
        ld          a,(varT)                            ; T \ restore z lo
        ReturnIfAGTENusng 4                              ; >= 4 ? zlo big enough, Enter Node additions done.
MakeNodeClose:
LL140:                                                  ; else make node close
        xor         a                                   ; hi This needs tuning to use a 16 bit variable
        ld          (varU),a                            ; U
        ld          a,4                                 ; lo
        ld          (varT),a                            ; T
        ret
;--LL49-------------------------------------------------------------------------------------------------------------------------                    
ProcessVisibleNode:
RotateNode:                                                                                                                         ;;;     
        call        XX12EquXX15DotProductXX16                                                                                       ;;;           call      XX12=XX15.XX16
LL52LL53LL54LL55
TransposeNode:      
        call        TransposeXX12NodeToXX15

; ......................................................                                                         ;;; 
NodeAdditionsDone:
Scale16BitTo8Bit:
LL57:                                                   ; Enter Node additions done, z=T.U set up from LL55
        ld          a,(varU)                            ; U \ z hi
        ld          hl,UbnkXPointHi
        or          (hl)                                ; XX15+1    \ x hi
        ld          hl,UbnkYPointHi
        or          (hl)                                ; XX15+4    \ y hi
AreXYZHiAllZero:
        jr          z,NodeScalingDone                   ; if X, Y, Z = 0  exit loop down once hi U rolled to 0
DivideXYZBy2:
        ShiftMem16Right1    UbnkXPoint                  ; XX15[0,1]
        ShiftMem16Right1    UbnkYPoint                  ; XX15[3,4]
        ld          a,(varU)                            ; U \ z hi
        ld          h,a
        ld          a,(varT)                            ; T \ z lo
        ld          l,a
        ShiftHLRight1
        ld          a,h
        ld          (varU),a
        ld          a,l
        ld          (varT),a                            ; T \ z lo
        jp          Scale16BitTo8Bit                    ; loop U
NodeScalingDone:
LL60:                                                   ; hi U rolled to 0, exited loop above.
ProjectNodeToScreen:
        ldCopyByte  varT,varQ                           ; T =>  Q   \ zdist lo
        ld          a,(UbnkXPointLo)                    ; XX15  \ rolled x lo
        ld          hl,varQ
        cp          (hl)                                ; Q
        JumpIfALTusng DoSmallAngle                      ; LL69 if xdist < zdist hop over jmp to small x angle
        call        RequAdivQ                           ; LL61  \ visit up  R = A/Q = x/z
        jp          SkipSmallAngle                      ; LL65  \ hop over small xangle
DoSmallAngle:                                           ; small x angle
LL69:
; TODO check if we need to retain BC as this trashes it
;Input: BC = Dividend, DE = Divisor, HL = 0
;Output: BC = Quotient, HL = Remainder
        ld      b,a
        call    DIV16UNDOC
        ld      a,c
        ld      (varR),a
 ;;;       call        RequAmul256divQ                     ; LL28  \ BFRDIV R=A*256/Q byte for remainder of division
SkipSmallAngle:
ScaleX:
LL65:                                                   ; both continue for scaling based on z
        ld          a,(UbnkXPointSign)                  ; XX15+2 \ sign of X dist
        JumpOnBitSet a,7,NegativeXPoint                 ; LL62 up, -ve Xdist, RU screen onto XX3 heap   
; ......................................................   
PositiveXPoint:
        ld          a,(varR)
        ld          l,a
        ld          a,(varU)
        ld          h,a
        ld          a,ScreenCenterX
        add         hl,a
        ex          de,hl
        jp          StoreXPoint
NegativeXPoint:
LL62:                                                   ; Arrive from LL65 just below, screen for -ve RU onto XX3 heap, index X=CNT ;;;
        ld          a,(varR)
        ld          l,a
        ld          a,(varU)
        ld          h,a
        ld          c,ScreenCenterX
        ld          b,0
        ClearCarryFlag
        sbc         hl,bc                               ; hl = RU-ScreenCenterX
        ex          de,hl      
StoreXPoint:                                            ; also from LL62, XX3 node heap has xscreen node so far.
        ld          (iy+0),e                            ; Update X Point
        ld          (iy+1),d                            ; Update X Point
        inc         iy
        inc         iy
; ......................................................   
LL66:
ProcessYPoint:
        xor         a                                   ; y hi = 0
        ld          (varU),a                            ; U
        ldCopyByte  varT,varQ                           ; Q \ zdist lo
        ld          a,(UbnkYPointLo)                    ; XX15+3 \ rolled y low
        ld          hl,varQ
        cp          (hl)                                ; Q
        JumpIfALTusng SmallYHop                         ; if ydist < zdist hop to small yangle
SmallYPoint:        
        call        RequAdivQ                           ; LL61  \ else visit up R = A/Q = y/z
        jp          SkipYScale                          ; LL68 hop over small y yangle
SmallYHop:
LL67:                                                   ; Arrive from LL66 above if XX15+3 < Q \ small yangle
        call        RequAmul256divQ                     ; LL28  \ BFRDIV R=A*256/Q byte for remainder of division
SkipYScale:
LL68:                                                   ; both carry on, also arrive from LL66, yscaled based on z
        ld          a,(UbnkYPointSign)                  ; XX15+5 \ sign of X dist
        bit         7,a
        jp          nz,NegativeYPoint                   ; LL62 up, -ve Xdist, RU screen onto XX3 heap   
PositiveYPoint:
        ld          a,(varR)
        ld          l,a
        ld          a,(varU)
        ld          h,a
        ld          a,ScreenHeightHalf
        add         hl,a
        ex          de,hl
        jp          LL50
NegativeYPoint:
LL70:                                                   ; Arrive from LL65 just below, screen for -ve RU onto XX3 heap, index X=CNT ;;;
        ld          a,(varR)
        ld          l,a
        ld          a,(varU)
        ld          h,a
        ld          c,ScreenHeightHalf
        ld          b,0
        ClearCarryFlag
        sbc         hl,bc                               ; hl = RU-ScreenCenterX
        ex          de,hl      
LL50:                                                   ; also from LL62, XX3 node heap has xscreen node so far.
        ld          (iy+0),e                            ; Update X Point
        ld          (iy+1),d                            ; Update X Point
        inc         iy
        inc         iy
        ret
;--------------------------------------------------------------------------------------------------------
;;;     Byte 0 = X magnitide with origin at middle of ship
;;;     Byte 1 = Y magnitide with origin at middle of ship      
;;;     Byte 2 = Z magnitide with origin at middle of ship          
;;;     Byte 3 = Sign Bits of Vertex 7=X 6=Y 5 = Z 4 - 0 = visibility beyond which vertix is not shown
CopyNodeToXX15:
        ldCopyByte  hl, UBnkXScaled                     ; Load into XX15                                                                     Byte 0;;;     XX15 xlo   = byte 0
        inc         hl
        ldCopyByte  hl, UBnkYScaled                     ; Load into XX15                                                                     Byte 0;;;     XX15 xlo   = byte 0
        inc         hl
        ldCopyByte  hl, UBnkZScaled                     ; Load into XX15                                                                     Byte 0;;;     XX15 xlo   = byte 0
        inc         hl
PopulateXX15SignBits: 
; Simplfied for debugging, needs optimising back to original DEBUG TODO
        ld          a,(hl)
        ld          c,a                                 ; copy sign and visibility to c
        ld          b,a
        and         $80                                 ; keep high 3 bits
        ld          (UBnkXScaledSign),a                 ; Copy Sign Bits                                                            ;;;     
        ld          a,b
        and         $40
        sla         a                                   ; Copy Sign Bits                                                            ;;;     
        ld          (UBnkYScaledSign),a                 ; Copy Sign Bits                                                            ;;;     
        ld          a,b
        and         $20
        sla         a                                   ; Copy Sign Bits                                                            ;;;     
        sla         a                                   ; Copy Sign Bits                                                            ;;;     
        ld          (UBnkZScaledSign),a                 ; Copy Sign Bits                                                            ;;;     
        ld          a,c                                 ; returns a with visibility sign byte
        and         $1F                                 ; visibility is held in bits 0 to 4                                                              ;;;     A = XX15 Signs AND &1F (to get lower 5 visibility)
        ld          (varT),a                            ; and store in varT as its needed later
        ret

;;;     Byte 4 = High 4 bits Face 2 Index Low 4 bits = Face 1 Index
;;;     Byte 5 = High 4 bits Face 4 Index Low 4 bits = Face 3 Index
;..............................................................................................................................
ProcessANode:                                           ; Start loop on Nodes for visibility, each node has 4 faces associated with ;;; For each node (point) in model                  ::LL48 
LL48GetScale:
        ld          a,(LastNormalVisible)               ; get Normal visible range into e before we copy node
        ld          e,a
        call        CopyNodeToXX15
LL48GetVertices:
LL48GetVertSignAndVisDist:
        JumpIfALTNusng e,NodeIsNotVisible               ; if XX4 > Visibility distance then vertext too far away , next vertex.                                             ;;;        goto LL50 (end of loop)
CheckFace1:                                                                                                                         ;;;     if all FaceVisile[point face any of idx1,2,3 or 4] = 0
        CopyByteAtNextHL varP                           ; vertex byte#4, first 2 faces two 4-bit indices 0:15 into XX2 for 2 of the ;;;     get point face idx from byte 4 & 5 of normal
        ld          d,a                                 ; use d to hold a as a temp                                                 ;;;
        and         $0F                                 ; face 1                                                                    ;;;
        push        hl                                  ; we need to save HL                                                        ;;;
        ldHLIdxAToA UbnkFaceVisArray                    ; visibility at face 1                                                Byte 4;;;
        pop         hl                                  ;                                                                           ;;;
        JumpIfAIsNotZero NodeIsVisible                  ; is face 1 visible                                                         ;;;
CheckFace2:                                                                                                                         ;;;
        ld          a,d                                                                                                             ;;;
        swapnib                                                                                                                     ;;;
        and         $0F                                 ; this is face 2                                                            ;;;
        JumpIfAIsNotZero NodeIsVisible                  ; is face 1 visible                                                         ;;;
CheckFace3:                                                                                                                         ;;;
        CopyByteAtNextHL varP                           ; vertex byte#4, first 2 faces two 4-bit indices 0:15 into XX2 for 2 of the ;;;     
        ld          d,a                                 ; use d to hold a as a temp                                                 ;;;
        and         $0F                                 ; face 1                                                                    ;;;     
        push        hl                                  ; we need to save HL                                                        ;;;
        ldHLIdxAToA UbnkFaceVisArray                  ; visibility at face 1                                                Byte 5;;;
        pop         hl                                  ;                                                                           ;;;
        JumpIfAIsNotZero NodeIsVisible                  ; is face 1 visible                                                         ;;;
CheckFace4:                                                                                                                         ;;;
        ld          a,d                                                                                                             ;;;
        swapnib                                                                                                                     ;;;
        and         $0F                                 ; this is face 2                                                            ;;;
        JumpIfAIsNotZero NodeIsVisible                  ; is face 1 visible                                                         ;;;
NodeIsNotVisible:                                                                                                                   ;;;
        ld          bc,4
        add         iy,bc                               ; if not visible then move to next element in array anyway                  ;;;
        ;;; Should we be loading FFFFFFFF into 4 bytes or just ignore?
        ret                                                                                                      ;;;        goto LL50 (end of loop)
NodeIsVisible:
LL49:
        call        ProcessVisibleNode                  ; Process node to determine if it goes on heap
        ret


ProjectNodeToEye:
	ld			bc,(UBnkZScaled)					; BC = Z Cordinate. By here it MUST be positive as its clamped to 4 min
	ld			a,c                                 ;  so no need for a negative check
	ld			(varQ),a		                    ; VarQ = z
    ld          a,(UBnkXScaled)                     ; XX15	\ rolled x lo which is signed
	call		DIV16Amul256dCUNDOC					; result in BC which is 16 bit TODO Move to 16 bit below not just C reg
    ld          a,(UBnkXScaledSign)                 ; XX15+2 \ sign of X dist
    JumpOnBitSet a,7,EyeNegativeXPoint             ; LL62 up, -ve Xdist, RU screen onto XX3 heap
EyePositiveXPoint:									; x was positive result
    ld          l,ScreenCenterX						; 
    ld          h,0
    add         hl,bc								; hl = Screen Centre + X
    jp          EyeStoreXPoint
EyeNegativeXPoint:                                 ; x < 0 so need to subtract from the screen centre position
    ld          l,ScreenCenterX                     
    ld          h,0
    ClearCarryFlag
    sbc         hl,bc                               ; hl = Screen Centre - X
EyeStoreXPoint:                                    ; also from LL62, XX3 node heap has xscreen node so far.
    ex          de,hl
    ld          (iy+0),e                            ; Update X Point TODO this bit is 16 bit aware just need to fix above bit
    ld          (iy+1),d                            ; Update X Point
EyeProcessYPoint:
	ld			bc,(UBnkZScaled)					; Now process Y co-ordinate
	ld			a,c
	ld			(varQ),a
    ld          a,(UBnkYScaled)                     ; XX15	\ rolled x lo
	call		DIV16Amul256dCUNDOC	                ; a = Y scaled * 256 / zscaled
    ld          a,(UBnkYScaledSign)                 ; XX15+2 \ sign of X dist
    JumpOnBitSet a,7,EyeNegativeYPoint             ; LL62 up, -ve Xdist, RU screen onto XX3 heap top of screen is Y = 0
EyePositiveYPoint:									; Y is positive so above the centre line
    ld          l,ScreenCenterY
    ClearCarryFlag
    sbc         hl,bc  							 	; hl = ScreenCentreY - Y coord (as screen is 0 at top)
    jp          EyeStoreYPoint
EyeNegativeYPoint:									; this bit is only 8 bit aware TODO FIX
    ld          l,ScreenCenterY						
    ld          h,0
    add         hl,bc								; hl = ScreenCenterY + Y as negative is below the center of screen
EyeStoreYPoint:                                    ; also from LL62, XX3 node heap has xscreen node so far.
    ex          de,hl
    ld          (iy+2),e                            ; Update Y Point
    ld          (iy+3),d                            ; Update Y Point
    ret
    
    
    
; Pitch and roll are 2 phases
; 1 - we apply our pitch and roll to the ship position
;       x -> x + alpha * (y - alpha * x)
;       y -> y - alpha * x - beta * z
;       z -> z + beta * (y - alpha * x - beta * z)
; which can be simplified as:
;       1. K2 = y - alpha * x
;       2. z = z + beta * K2
;       3. y = K2 - beta * z
;       4. x = x + alpha * y
; 2 - we apply our patch and roll to the ship orientation
;      Roll calculations:
;      
;        nosev_y = nosev_y - alpha * nosev_x_hi
;        nosev_x = nosev_x + alpha * nosev_y_hi
;      Pitch calculations:
;      
;        nosev_y = nosev_y - beta * nosev_z_hi
;        nosev_z = nosev_z + beta * nosev_y_hi


; ---------------------------------------------------------------------------------------------------------------------------------    
            INCLUDE "./Universe/Ships/ApplyMyRollAndPitch.asm"
            INCLUDE "./Universe/Ships/ApplyShipRollAndPitch.asm"
            INCLUDE "./ModelRender/DrawLines.asm"
; ---------------------------------------------------------------------------------------------------------------------------------    

; DIot seem to lawyas have Y = 0???
ProcessDot:            ; break
                        call    CopyRotmatToTransMat             ;#01; Load to Rotation Matrix to XX16, 16th bit is sign bit
                        call    ScaleXX16Matrix197               ;#02; Normalise XX16
                        call    LoadCraftToCamera                ;#04; Load Ship Coords to XX18
                        call    InverseXX16                      ;#11; Invert rotation matrix
                        ld      hl,0
                        ld      (UBnkXScaled),a
                        ld      (UBnkYScaled),a
                        ld      (UBnkZScaled),a
                        xor     a
                        call    XX12EquNodeDotOrientation
                        call    TransposeXX12ByShipToXX15
                        call	ScaleNodeTo8Bit					    ; scale to 8 bit values, why don't we hold the magnitude here?x
                        ld      iy,UBnkNodeArray
                        call    ProjectNodeToEye
                        ret
                 
; .....................................................
; Process Nodes does the following:
; for each node:
;     see if node > 
PNXX20DIV6          DB      0
PNVERTEXPTR         DW      0   ; DEBUG WILL USE LATER
PNNODEPRT           DW      0   ; DEBUG WILL USE LATER
PNLASTNORM          DB      0
ProcessNodes:           ZeroA
                        ld      (UbnkLineArrayLen),a
                        call CopyRotmatToTransMat ; CopyRotToTransMacro                      ;#01; Load to Rotation Matrix to XX16, 16th bit is sign bit
                        call    ScaleXX16Matrix197               ;#02; Normalise XX16
                        call    LoadCraftToCamera                ;#04; Load Ship Coords to XX18
                        call    InverseXX16                      ;#11; Invert rotation matrix
                        ld      hl,UBnkHullVerticies
                        ld      a,(VertexCtX6Addr)               ; get Hull byte#8 = number of vertices *6                                   ;;;
GetActualVertexCount:   ld      c,a                              ; XX20 also c = number of vertices * 6 (or XX20)
                        ld      c,a                              ; XX20 also c = number of vertices * 6 (or XX20)
                        ld      d,6
                        call    asm_div8                         ; asm_div8 C_Div_D - C is the numerator, D is the denominator, A is the remainder, B is 0, C is the result of C/D,D,E,H,L are not changed"
                        ld      b,c                              ; c = number of vertices
                        ld      iy,UBnkNodeArray
LL48:   
PointLoop:	            push	bc                                  ; save counters
                        push	hl                                  ; save verticies list pointer
                        push	iy                                  ; save Screen plot array pointer
                        ld      a,b
                        ;break
                        call    CopyNodeToXX15                      ; copy verices at hl to xx15
                        ld		a,(UBnkXScaledSign)
                        call    XX12EquNodeDotOrientation
                        call    TransposeXX12ByShipToXX15
                        call	ScaleNodeTo8Bit					    ; scale to 8 bit values, why don't we hold the magnitude here?x
                        pop		iy                                  ; get back screen plot array pointer
                        call    ProjectNodeToEye                     ; set up screen plot list entry
   ; ld      hl,UbnkLineArrayLen
  ;  inc     (hl)                                ; another node done
ReadyForNextPoint:      push	iy                                  ; copy screen plot pointer to hl
                        pop		hl
                        ld		a,4
                        add		hl,a
                        push	hl                                  ; write it back at iy + 4
                        pop		iy								    ; and put it in iy again
                        pop		hl                                  ; get hl back as vertex list
                        ld		a,6
                        add 	hl,a                                ; and move to next vertex
                        pop		bc                                  ; get counter back
                        djnz	PointLoop
; ......................................................   
                        ClearCarryFlag
                        ret                                         

; ......................................................   
ProcessShip:            call    CheckDistance               ; checks for z -ve and outside view frustrum
                        ret     c                           ; carry flag means drop out
.IsItADot:              ld      a,(UBnKDrawAsDot)           ; if its just a dot then don't draw
                        JumpIfATrue .CarryOnWithDraw                        
.itsJustADot:           call    ProcessDot
                        ld      bc,(UBnkNodeArray)          ; if its at dot range get X
                        ld      de,(UBnkNodeArray+2)        ; and Y
                        ld      a,b                         ; if high byte components are not 0 then off screen
                        or      d                           ;
                        ret     nz                          ;
                        ld      a,e
                        and     %10000000                   ; check to see if Y > 128
                        ret     nz
                        ld      b,e                         ; now b = y and c = x
                        ld      a,L2ColourWHITE_1           ; just draw a pixel
                        ld      a,224
                        MMUSelectLayer2                     ; then go to update radar
                        call    l2_plot_pixel               ; 
                        ClearCarryFlag
                        ret
.CarryOnWithDraw:       ;break
;DEBUG                        ld      a,(UBnkaiatkecm)            ; if its exploding then we just draw
;DEBUG                        and     ShipExploding               ; clouds of pixels
;DEBUG                        jr      nz,.ExplodingCloud          ; .
                        call    ProcessNodes                ; process notes is the poor performer or check distnace is not culling
                        call    CullV2
                        call    PrepLines
                        call    DrawLines
                        ClearCarryFlag
                        ret 
.ExplodingCloud:        break
                        ret
; ......................................................   

;-LL49-----------------------------------------------------------------------------------------------------------------------------
;  Entering Here we have the following:
;  XX15(1 0) = vertex x-coordinate but sign not populated
;  XX15(3 2) = vertex y-coordinate but sign not populated
;  XX15(5 4) = vertex z-coordinate but sign not populated
;
;  XX16(  1 0)sidev_x   (3 2)roofv_x   (5 4)nosev_x
;  XX16(  7 6)sidev_y   (9 8)roofv_y (11 10)nosev_y
;  XX16(13 12)sidev_z (15 14)roofv_z (17 16)nosev_z
;--------------------------------------------------------------------------------------------------------
AddLaserBeamLine:
; this code is a bag of shit and needs re-writing
GetGunVertexNode:
        ld          a,(GunVertexAddr)                   ; Hull byte#6, gun vertex*4 (XX0),Y
        ld          hl,UBnkNodeArray                    ; list of lines to read
        add         hl,a                                ; HL = address of GunVertexOnNodeArray
        ld          iyl,0
MoveX1PointToXX15:
        ld          c,(hl)                              ; 
        inc         hl
        ld          b,(hl)                              ; bc = x1 of gun vertex
        inc         hl
        ld          (UBnkX1),bc
        inc         c
        ret         z                                   ; was c 255?
        inc         b
        ret         z                                   ; was c 255?
MoveY1PointToXX15:
        ld          c,(hl)                              ; 
        inc         hl
        ld          b,(hl)                              ; bc = y1 of gun vertex
        inc         hl
        ld          (UBnkY1),bc
SetX2PointToXX15:
        ld          bc,0                                ; set X2 to 0
        ld          (UBnkX2),bc
        ld          a,(UBnKzlo)
        ld          c,a
SetY2PointToXX15:
        ld          (UBnkY2),bc                         ; set Y2to 0
        ld          a,(UBnKxsgn)
        JumpOnBitClear a,7,LL74SkipDec
LL74DecX2:
        ld          a,$FF
        ld          (UBnkX2Lo),a                        ; rather than dec (hl) just load with 255 as it will always be that at this code point
LL74SkipDec:        
        call        ClipLine                            ; LL145 \ clip test on XX15 XX12 vector, returns carry 
        jr          c,CalculateNewLines                 ; LL170 clip returned carry set so not visibile if carry set skip the rest (laser not firing)
; Here we are usign hl to replace VarU as index        
        ld          hl,(varU16)
        ld          a,(UBnKx1Lo)
        ld          (hl),a
        inc         hl
        ld          a,(UbnKy1Lo)
        ld          (hl),a
        inc         hl
        ld          a,(UBnkX2Lo)
        ld          (hl),a
        inc         hl
        ld          a,(UbnKy2Lo)
        ld          (hl),a
        inc         iyl                                 ; iyl holds as a counter to iterations
        inc         hl
        inc         iyl                                 ; ready for next byte
        ld          (varU16),hl
        ret

    INCLUDE "Universe/Ships/PrepLines.asm"

UnivBankSize  EQU $ - StartOfUniv
