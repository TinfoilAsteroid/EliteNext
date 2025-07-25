;    DEFINE DEBUGMISSILELAUNCH 1
;    DEFINE PLOTPOINTSONLY 1
  DEFINE OVERLAYNODES 1
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
;                       1234567890123456                                        
StartOfUniv:        DB "Universe PG"
StartOfUnivN:       DB "X"
StartOfUnivPad:     DS 2
StartOfUnivM:       DB 0
StartOfUnivT        DB 0
StartOfUnivName     DS 16
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
LineArraySize               equ 50; incerased for max of 28 lines, of 4 points of 16 bits each
; ONLY IF TESTING SOLID FILL TraingleArraySize           equ 25
; Storage arrays for data
; Structure of arrays
; Visibility array  - 1 Byte per face/normal on ship model Bit 7 (or FF) visible, 0 Invisible
; Node array corresponds to a processed vertex from the ship model transformed into world coordinates and tracks the node list from model
; NodeArray         -  4 bytes per element      0           1            2          3
;                                               X Coord Lo  Y Coord Lo   Z CoordLo  Sign Bits 7 6 5 for X Y Z Signs (set = negative)
; Line Array        -  4 bytes per eleement     0           1            2          3
;                                               X1          Y1           X2         Y2
UbnkFaceVisArray            DS FaceArraySize            ; XX2 Up to 16 faces this may be normal list, each entry is controlled by bit 7, 1 visible, 0 3
; Node array holds the projected to screen position regardless of if its clipped or not
; When we use traingles we can cheat a bit on clipping as all lines will be horizontal so clipping is much simplified
UBnkNodeArray               DS NodeArraySize * 4        ; XX3 Holds the points as an array, its an array not a heap
UBnkNodeArray2              DS NodeArraySize * 4        ; XX3 Holds the points as an array, its an array not a heap
UbnkLineArray               DS LineArraySize * 8        ; XX19 Holds the clipped line details
; ONLY IF TESTING SOLID FILL UBnkTriangleOverspill       DS TraingleArraySize * 4    ; jsut a padding for testing
UBnkLinesHeapMax            EQU $ - UbnkLineArray
UBnkTraingleArray           EQU UbnkLineArray           ; We can use the line array as we draw lines or traingles
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
VertexCountAddr             equ UBnkHullCopy + VertexCountOffset    
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
ShipECMFittedChanceAddr     equ UBnkHullCopy + ShipECMFittedChanceOffset
ShipSolidFlagAddr           equ UBnkHullCopy + ShipSolidFlagOffset
ShipSolidFillAddr           equ UBnkHullCopy + ShipSolidFillOffset
ShipSolidLenAddr            equ UBnkHullCopy + ShipSolidLenOffset
; Static Ship Data. This is copied in when creating the universe object
XX0                         equ UBnkHullCopy        ; general hull index pointer TODO find biggest ship design

UBnkHullVerticies           DS  40 * 6              ; largetst is trasnport type 10 at 37 vericies so alows for 40 * 6 Bytes  = 
UBnkHullEdges               DS  50 * 4              ; ype 10 is 46 edges so allow 50
UBnkHullNormals             DS  20 * 4              ; type 10 is 14 edges so 20 to be safe
    IFDEF SOLIDHULLTEST
UBnkHullSolid               DS  100 * 4             ; Up to 100 triangles (May optimise so only loads non 3 faces later
    ENDIF
OrthagCountdown             DB  12

UBnkShipCopy                equ UBnkHullVerticies               ; Buffer for copy of ship data, for speed will copy to a local memory block, Cobra is around 400 bytes on creation of a new ship so should be plenty
UBnk_Data_len               EQU $ - StartOfUniv

; --------------------------------------------------------------
ZeroUnivPitch:          MACRO
                        xor     a
                        ld      (UBnKRotZCounter),a
                        ENDM
; --------------------------------------------------------------
ZeroUnivRoll:           MACRO
                        xor     a
                        ld      (UBnKRotXCounter),a
                        ENDM
; --------------------------------------------------------------
ZeroUnivPitchAndRoll:   MACRO
                        xor     a
                        ld      (UBnKRotXCounter),a
                        ld      (UBnKRotZCounter),a
                        ENDM
; --------------------------------------------------------------
MaxUnivPitchAndRoll:    MACRO
                        ld      a,127
                        ld      (UBnKRotXCounter),a
                        ld      (UBnKRotZCounter),a
                        ENDM                   
; --------------------------------------------------------------
InfinitePitch:          MACRO
                        ld      a,$FF
                        ld      (UBnKRotZCounter),a
                        ENDM   
; --------------------------------------------------------------
InfiniteRoll:           MACRO
                        ld      a,$FF
                        ld      (UBnKRotXCounter),a
                        ENDM   
; --------------------------------------------------------------
InfinitePitchAndRoll:    MACRO
                        ld      a,$FF
                        ld      (UBnKRotXCounter),a
                        ld      (UBnKRotZCounter),a
                        ENDM   
; --------------------------------------------------------------
RandomUnivPitchAndRoll: MACRO
                        call    doRandom
                        or      %01101111
                        ld      (UBnKRotXCounter),a
                        call    doRandom
                        or      %01101111
                        ld      (UBnKRotZCounter),a
                        ENDM
; --------------------------------------------------------------
RandomUnivSpeed:        MACRO
                        call    doRandom
                        and     31
                        ld      (UBnKSpeed),a
                        ENDM
; --------------------------------------------------------------
MaxUnivSpeed:           MACRO
                        ld      a,31
                        ld      (UBnKSpeed),a
                        ENDM
; --------------------------------------------------------------
ZeroUnivAccelleration:  MACRO
                        xor     a
                        ld      (UBnKAccel),a
                        ENDM
; --------------------------------------------------------------
SetShipHostile:         ld      a,(ShipNewBitsAddr)
                        or      ShipIsHostile 
                        ld      (ShipNewBitsAddr),a
                        ret
; --------------------------------------------------------------
ClearShipHostile:       ld      a,(ShipNewBitsAddr)
                        and     ShipNotHostile 
                        ld      (ShipNewBitsAddr),a
                        ret
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
FireECM:                break
                        ld      a,ECMCounterMax                 ; set ECM time
                        ld      (UBnKECMCountDown),a            ;
                        ld      a,(ECMCountDown)
                        ReturnIfALTNusng ECMCounterMax
                        ld      a,ECMCounterMax
                        ld      (ECMCountDown),a
                        ret
; --------------------------------------------------------------
RechargeEnergy:         ld      a,(UBnKEnergy)
                        ReturnIfAGTEMemusng EnergyAddr
                DISPLAY "TODO: Add recharge rate logic for ship types"
                        inc     a       
                        ld      (UBnKEnergy),a
                        ret
; --------------------------------------------------------------
; A ship normally needs enough energy to fire ECM but if its shot then
; it may be too low, in which case the ECM does a saftey shutdown and returns 1 energy
; plus a 50% chance it will blow the ECM up
UpdateECM:              ld      a,(UBnKECMCountDown)
                        ReturnIfAIsZero
                        dec     a
                        ld      (UBnKECMCountDown),a
                        ld      hl,UBnKEnergy
                        dec     (hl)
                        ret     p
.ExhaustedEnergy:       call    UnivExplodeShip                 ; if it ran out of energy it was as it was also shot or collided as it checks in advance. Main ECM loop will continue as a compromise as multiple ships can fire ECM simultaneously
                        ret
;-- This takes an Axis and subtracts 1, handles leading sign and boundary of 0 going negative
JumpOffSet:             MACRO   Axis
                        ld      hl,(Axis)
                        ld      a,h
                        and     SignOnly8Bit
                        jr      nz,.NegativeAxis
.PositiveAxis:          dec     l
                        jp      m,.MovingNegative
                        jp      .Done
.NegativeAxis:          inc     l                               ; negative means increment the z
                        jp      .Done
.MovingNegative:        ld      hl,$8001                        ; -1
.Done                   ld      (Axis),hl
                        ENDM
; --------------------------------------------------------------
WarpOffset:             JumpOffSet  UBnKzhi                     ; we will simplify on just moving Z
                        ret
; --------------------------------------------------------------
WarpUnivByHL:           ld      b,h
                        ld      c,l
                        ld      h,0
                        ld      de,(UBnKzhi)
                        ld      a,(UBnKzlo)
                        ld      l,a
                        MMUSelectMathsBankedFns : call  SubBCHfromDELsigned
                        ld      (UBnKzhi),de
                        ld      a,l
                        ld      (UBnKzlo),a
                        ret
; --------------------------------------------------------------                        
; update ship speed and pitch based on adjustments from AI Tactics
UpdateSpeedAndPitch:    ld      a,(UBnKAccel)                   ; only apply non zero accelleration
                        JumpIfAIsZero .SkipAccelleration
                        ld      b,a                             ; b = accelleration in 2's c
                        ld      a,(UBnKSpeed)                   ; a = speed + accelleration
                        ClearCarryFlag
                        adc     a,b
                        JumpIfPositive  .DoneAccelleration      ; if speed < 0 
.SpeedNegative:         ZeroA                                   ;    then speed = 0
.DoneAccelleration:     ld      b,a                             ; if speed > speed limit
                        ld      a,(SpeedAddr)                   ;    speed = limit
                        JumpIfAGTENusng b, .SpeedInLimits       ; .  
                        ld      b,a                             ; .
.SpeedInLimits:         ld      a,b                             ; .
                        ld      (UBnKSpeed),a                   ; .
                        ZeroA                                   ; acclleration = 0
                        ld      (UBnKAccel),a                   ; for next AI update
.SkipAccelleration:     ; handle roll and pitch rates                     
                        ret
; --------------------------------------------------------------
UnivSetEnemyMissile:    ld      hl,NewLaunchUBnKX               ; Copy launch ship matrix
                        ld      de,UBnKxlo                      ; 
                        ld      bc,NewLaunchDataBlockSize       ; positon + 3 rows of 3 bytes
                        ldir                                    ; 
.SetUpSpeed:            ld      a,3                             ; set accelleration
                        ld      (UBnKAccel),a                   ;
                        ZeroA
                        ld      (UBnKRotXCounter),a
                        ld      (UBnKRotZCounter),a
                        ld      a,3                             ; these are max roll and pitch rates for later
                        ld      (UBnKRAT),a
                        inc     a
                        ld      (UBnKRAT2),a
                        ld      a,22
                        ld      (UBnKCNT2),a
                        MaxUnivSpeed                            ; and immediatley full speed (for now at least) TODO
                        SetMemFalse UBnKMissleHitToProcess
                        call    UnivSetAIOnly
                        call    SetShipHostile
.SetupPayload:          ld      a,150
                        ld      (UBnKMissileBlastDamage),a
                        ld      (UBnKMissileDetonateDamage),a
                        ld      a,5
                        ld      (UBnKMissileBlastRange),a
                        ld      (UBnKMissileDetonateRange),a
                        ret
; --------------------------------------------------------------                        
; This sets the position of the current ship if its a player launched missile
UnivSetPlayerMissile:   call    InitialisePlayerMissileOrientation  ; Copy in Player  facing
                        call    ResetUbnkPosition               ; home position
                        ld      a,MissileDropHeight             ; the missile launches from underneath
                        ld      (UBnKylo),a                     ; so its -ve drop height
                        IFDEF DEBUGMISSILELAUNCH
                            ld      a,$20       ; DEBUG
                            ld      (UBnKzlo),a
                        ENDIF
                        ld      a,$80                           ;
                        ld      (UBnKysgn),a                    ;
                        ld      a,3                             ; set accelleration
                        ld      (UBnKAccel),a                   ;
                        ZeroA
                        ld      (UBnKRotXCounter),a
                        ld      (UBnKRotZCounter),a
                        ld      a,3                             ; these are max roll and pitch rates for later
                        ld      (UBnKRAT),a
                        inc     a
                        ld      (UBnKRAT2),a
                        ld      a,22
                        ld      (UBnKCNT2),a
                        MaxUnivSpeed                            ; and immediatley full speed (for now at least) TODO
                        SetMemFalse UBnKMissleHitToProcess
                        call    UnivSetAIOnly
                        call    ClearShipHostile                ; its a player missile
                        ret
; --------------------------------------------------------------
; this applies blast damage to ship
ShipMissileBlast:       ld      a,(CurrentMissileBlastDamage)
                        ld      b,a
                        ld      a,(UBnKEnergy)                   ; Reduce Energy
                        sub     b
                        jp      UnivExplodeShip
                        jr      UnivExplodeShip
                        ld      (UBnKEnergy),a
                        ret
; --------------------------------------------------------------
; this applies AI flag and resets all other bits
UnivSetAIOnly:          ld      a,ShipAIEnabled
                        ld      (UBnkaiatkecm),a
                        ret
; --------------------------------------------------------------                        
; Sets visibile and not a dot
UnivVisible:            ld      a,(UBnkaiatkecm)                ;  disable ship AI hostily and ECM
                        or      ShipIsVisible
                        ld      (UBnkaiatkecm),a                ;  .
                        ret
; --------------------------------------------------------------                        
; Sets invisibile
UnivInvisible:          ClearMemBitN  UBnkaiatkecm  , ShipIsVisibleBitNbr ; Assume its hidden
                        ret
; --------------------------------------------------------------                        
; Clears ship killed bit to acknowled its happened
UnivAcknowledExploding: ld      hl, UBnkaiatkecm                                     
                        res     ShipKilledBitNbr,(hl)
                        ret
; --------------------------------------------------------------                        
; Clears ship exploding bit
UnivFinishedExplosion:  ld      hl, UBnkaiatkecm                                     
                        res     ShipExplodingBitNbr,(hl)
                        ret
; --------------------------------------------------------------                        
; Sets visibile and not a dot
UnivVisibleNonDot:      ld      a,(UBnkaiatkecm)                ;  disable ship AI hostily and ECM
                        or      ShipIsVisible
                        and     ShipIsNotDot  
                        ld      (UBnkaiatkecm),a                ;  .
                        ret
; --------------------------------------------------------------                        
; Sets visibile and  a dot
UnivVisibleDot:         ld      a,(UBnkaiatkecm)                ;  disable ship AI hostily and ECM
                        or      ShipIsVisible | ShipIsDot
                        ld      (UBnkaiatkecm),a                ;  .
                        ret
; --------------------------------------------------------------                        
; Removes AI Bit from ship
UnivClearAI:            ld      a,(UBnkaiatkecm)                ;  disable ship AI hostily and ECM
                        and     ShipAIDisabled                  ;  .
                        ld      (UBnkaiatkecm),a                ;  .
                        ret

; --------------------------------------------------------------                        
; This sets the ship as a shower of explosiondwd, flags as killed and removes AI
UnivExplodeShip:        break
                        ld      a,(UBnkaiatkecm)
                        or      ShipExploding | ShipKilled      ; Set Exlpoding flag and mark as just been killed
                        and     Bit7Clear                       ; Remove AI
                        ld      (UBnkaiatkecm),a
                        xor     a
                        ld      (UBnKEnergy),a
                        ;TODO
                        ret
; --------------------------------------------------------------
UnivSetDemoPostion:     call    UnivSetSpawnPosition
                        ld      a,%10000001                     ; AI Enabled has 1 missile
                        ld      (UBnkaiatkecm),a                ; set hostinle, no AI, has ECM
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
CopyPlanetGlobaltoSpaceStation:
                        ld      hl,ParentPlanetX
                        ld      de,UBnKxlo
                        ld      bc,3*3
                        ldir
                        ret
; --------------------------------------------------------------
CopySpaceStationtoPlanetGlobal:
                        ld      hl,UBnKxlo
                        ld      de,ParentPlanetX
                        ld      bc,3*3
                        ldir
                        ret  
; --------------------------------------------------------------
; This group of routines copy the global variables to local universe
; so we can a) track what is going on for debugging and b) encapsulate data
CopyParentPlanettoUnivTarget:
                        ld      hl,ParentPlanetX                ; Copy the interface data to Univ (interface may be scapped later to just use Planet X Pos
                        jp      copyHlToTargetXPos
; --------------------------------------------------------------
CopyPlanettoUnivTarget: ld      hl,PlanetXPos                   ; Copy planet position to local target data
                        jp      copyHlToTargetXPos
; --------------------------------------------------------------
CopySpaceStationtoUniv: ld      hl,StationXPos                  ; Copy sun position to local target data
                        jp      copyHlToTargetXPos
; --------------------------------------------------------------
CopySuntoUniv:          ld      hl,SunXPos                      ; the Sun routine as teh last one can just fall into copyHL                       
; --------------------------------------------------------------
; -- General purpose copy 9 bytes from HL to UBnKTarget block
; -- done here so that optimisation can be applied later
copyHlToTargetXPos:     ld      de,UBnKTargetXPos
                        ld      bc,3*3
                        ldir
                        ret
; --------------------------------------------------------------
; generate space station type based on seed values
; returns space station type in a
UnivSelSpaceStationType:ld      a,(DisplayEcononmy)
                        ld      hl,(DisplayGovernment)          ; h = TekLevel, l = Government
                        ld      de,(DisplayPopulation)          ; d = productivity e = Population
                        ; so its economdy + government - TekLevel + productivity - population %00000001
                        add     a,l
                        sbc     a,h
                        add     a,d
                        sbc     a,e
                        and     $01
                        ld      hl,MasterStations               ; in main memory
                        add     hl,a
                        ld      a,(hl)
                        ret      
; --------------------------------------------------------------
UnivPitchToTarget:      ld      hl,( UBnKTargetDotProduct2)        ; pitch counter sign = opposite sign to roofdir sign
                        ld      a,h                                ; .
                        xor     $80                                ; .
                        and     $80                                ; .
                        ld      h,a                                ; h  = flipped sign
                        ld      a,l                                ; a = value * 2
                        sla     a                                  ; 
                        JumpIfAGTENusng 16, .skipPitchZero         ; if its > 16 then update pitch
                        ZeroA                                      ; else we zero pitch but
                        or      h                                  ; we need to retain the sign
                        ld      (UBnKRotZCounter),a                ; .
                        ret
.skipPitchZero:         ld      a,2
                        or      h
                        ld      (UBnKRotZCounter),a
                        ret

;Direct on dot product nose is $24
; Position                  Pitch   Roll    Speed
; Top left forwards         up      -ve     +
; Top right forwards        up      +ve     +
; Bottom left forwards      down    -ve     +
; Bottom right forwards     down    +ve     +
; Top left rear             up      -ve     -
; Top right rear            up      +ve     -
; Bottom left rear          down    -ve     -
; Bottom right rear         down    +ve     -
                        
UnivRollToTarget:       call    TacticsDotSidev             ; calculate side dot protuct
                        ld      ( UBnKTargetDotProduct3),a             ; .
                        ld      l,a                                ; .
                        ld      a,(varS)                           ; .
                        ld      ( UBnKTargetDotProduct3+1),a           ; .
                        ld      h,a                                ; h = sign sidev
                        ld      a,( UBnKTargetDotProduct2+1)           ; get flipped pitch counter sign
                        ld      b,a                                ; b = roof product
                        ld      a,l                                ; a = abs sidev  * 2
                        sla     a                                  ;
                        JumpIfAGTENusng 16,.skipRollZero           ;
                        ZeroA                                      ; if its zoer then set rotx to zero
                        or      b
                        ld      (UBnKRotXCounter),a
                        ret
.skipRollZero:          ld      a,2
                        or      h
                        xor     b
                        ld      (UBnKRotXCounter),a
                        ret

UnivSpeedToTarget:      ld      hl,( UBnKTargetDotProduct1)
                        ld      a,h
                        and     a
                        jr      nz,.SlowDown
                        ld      de,( UBnKTargetDotProduct2)             ; dot product is +ve so heading at each other
                        ld      a,l 
                        JumpIfALTNusng  22,.SlowDown                                  ; nose dot product < 
.Accelerate:            ld      a,3                                 ; else
                        ld      (UBnKAccel),a                       ;  accelleration = 3
                        ret                                         ;  .
.SlowDown:              JumpIfALTNusng 18, .NoSpeedChange
.Deccelerate:           ld      a,-2
                        ld      (UBnKAccel),a
                        ret
.NoSpeedChange:         ZeroA                                       ; else no change
                        ld      (UBnKAccel),a
                        ret                        
; --------------------------------------------------------------
CalculateSpaceStationWarpPositon:
.CalcZPosition:         ld      a,(WorkingSeeds+1)      ; seed d & 7 
                        and     %00000111               ; .
                        add     a,7                     ; + 7
                        sra     a                       ; / 2
.SetZPosition:          ld      (UBnKzsgn),a            ; << 16 (i.e. load into z sign byte
                        ld      hl, $0000               ; now set z hi and lo
                        ld      (UBnKzlo),hl            ;
.CalcXandYPosition:     ld      a,(WorkingSeeds+5)      ; seed f & 3
                        and     %00000011               ; .
                        add     a,3                     ; + 3
                        ld      b,a
                        ld      a,(WorkingSeeds+4)      ; get low bit of seed e
                        and     %00000001
                        rra                             ; roll bit 0 into bit 7
                        or      b                       ; now calc is f & 3 * -1 if seed e is odd
.SetXandYPosition:      ld      (UBnKxsgn),a            ; set into x and y sign byte
                        ld      (UBnKysgn),a            ; .
                        ld      a,b                     ; we want just seed f & 3 here
                        ld      (UBnKxhi),a             ; set into x and y high byte
                        ld      (UBnKyhi),a             ; .
                        ZeroA
                        ld      (UBnKxlo),a
                        ld      (UBnKylo),a                        
.CaclculateSpaceStationOffset:
.CalculateOffset:       ld      a,(WorkingSeeds+2)
                        and     %00000011
                        ld      c,a
                        ld      a,(WorkingSeeds)
                        and     %00000001
                        rla     
                        ld      b,a
                        ld      h,c
                        ld      c,0
.TransposeX:            push    bc,,hl
                        ld      de,(UBnKxhi)
                        ld      a,(UBnKxsgn)
                        ld      l,a
                        MMUSelectMathsBankedFns : call        AddBCHtoDELsigned
                        ld      (UBnKxhi),de
                        ld      a,l
                        ld      (UBnKxsgn),a
.TransposeY:            pop     bc,,hl
                        push    bc,,hl
                        ld      de,(UBnKyhi)
                        ld      a,(UBnKysgn)
                        ld      l,a
                        MMUSelectMathsBankedFns : call        AddBCHtoDELsigned
                        ld      (UBnKyhi),de
                        ld      a,l
                        ld      (UBnKysgn),a
.TransposeZ:            pop     bc,,hl
                        ld      de,(UBnKzhi)
                        ld      a,(UBnKzsgn)
                        ld      l,a
                        MMUSelectMathsBankedFns : call        AddBCHtoDELsigned
                        ld      (UBnKzhi),de
                        ld      a,l
                        ld      (UBnKzsgn),a
                        ret
; --------------------------------------------------------------
UnivSpawnSpaceStationLaunched:
                        call    UnivSpawnSpaceStation
                        call    CopySpaceStationtoPlanetGlobal
                        call    ResetStationLaunch
                        ret
                        DISPLAY "TODO:fall into SpaceStation Launch Position once startup fixed"
                        DISPLAY "TODO: Fault is probably as maths for xyz is 16 bit and shoudl be 24"
; --------------------------------------------------------------
SpaceStationLaunchPositon:
                        ld      hl,0
                        ZeroA
                        ld      (UBnKxlo),hl
                        ld      (UBnKxsgn),a
                        ld      (UBnKylo),hl
                        ld      (UBnKysgn),a
                        ld      a,$81
                        ld      (UBnKzlo),hl
                        ld      (UBnKzsgn),a
                        ret                 
; --------------------------------------------------------------
UnivSpawnSpaceStation:  ;    UnivSelSpaceStationType ; set a to type
                        ;ld      c,13                    ; c to slot 13 which is space station
                        ;call    SpawnShipTypeASlotC     ; load inito universe slot
.CalculatePosition:     call    CopyPlanetGlobaltoSpaceStation
.CalcOrbitOffset:       call    CalculateSpaceStationWarpPositon
                        call    InitialiseOrientation
.SetRollCounters:       ZeroUnivPitch
                        InfiniteRoll
.SetOrientation:        FlipSignMem UBnkrotmatNosevX+1;  as its 0 flipping will make no difference
                        FlipSignMem UBnkrotmatNosevY+1;  as its 0 flipping will make no difference
                        FlipSignMem UBnkrotmatNosevZ+1
                        ret                        
; --------------------------------------------------------------
; This sets the position of the current ship randomly, called after spawing
; Spawns in withink 16 bit range so 24 bit friendly
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
.CheckIfBodyOrJunk:     ld      a,(ShipTypeAddr)
                        ReturnIfAEqNusng ShipTypeJunk
                        ReturnIfAEqNusng ShipTypeScoopable
                        ld      a,b                             ; its not junk to set z sign
                        rrca                                    ; as it can jump in
                        and     SignOnly8Bit
                        ld      (UBnKzsgn),a
                        ret
                        
; --------------------------------------------------------------                        
; This sets the cargo type or carryflag set for not cargo
; Later this will be done via a loadable lookup table
ShipCargoType:          ld      a,(ShipTypeAddr)
                        JumpIfAEqNusng ShipID_CargoType5, .CargoCanister
.IsItThargon:           JumpIfAEqNusng ShipID_Thargon,    .Thargon
.IsItAlloy:             JumpIfAEqNusng ShipID_Plate,      .Plate
.IsItSplinter:          JumpIfAEqNusng ShipID_Splinter,   .Splinter
.IsItEscapePod:         JumpIfAEqNusng ShipID_Escape_Pod, .EscapePod
.CargoCanister:         call    doRandom
                        and     15                      ; Limit stock from Food to Platinum
                        ret
.Thargon:               ld      a,AlienItemsIndex                        
                        ret
.Plate:                 ld      a,AlloysIndex
                        ret
.Splinter:              ld      a,MineralsIndex
                        ret
.EscapePod:             ld      a,SlavesIndex
                        ret
        IFDEF DEBUG_SHIP_MOVEMENT
FixStationPos:          ld      hl, DebugPos
                        ld      de, UBnKxlo
                        ld      bc,9
                        ldir
                        ld      hl,DebugRotMat
                        ld      de, UBnkrotmatSidevX
                        ld      bc,6*3
                        ldir
                        ret
        ENDIF
        IFDEF DEBUG_SHIP_MOVEMENT
DebugPos:               DB $00,$00,$00,$92,$01,$00,$7E,$04,$00                        
DebugRotMat:            DB $37,$88,$9A,$DC,$1B,$F7
DebugRotMat1:           DB $DF,$6D,$2A,$07,$C1,$83
DebugRotMat2:           DB $00,$80,$4A,$9B,$AA,$D8                     
        ENDIF

; --------------------------------------------------------------                        
; This sets current univrse object to space station
ResetStationLaunch:     ld  a,%10000001                         ; Has AI and 1 Missile
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
                        ld      a,$00
                        ld      (UBnKzsgn),a
.SetOrientation:        call    LaunchedOrientation             ; set initial facing
                        ret
    ;Input: BC = Dividend, DE = Divisor, HL = 0
;Output: BC = Quotient, HL = Remainder
; --------------------------------------------------------------
FighterTypeMapping:     DB ShipID_Worm, ShipID_Sidewinder, ShipID_Viper, ShipID_Thargon

; Initialiase data, iyh must equal slot number
;                   iyl must be ship type
;                   a  = current bank number
UnivInitRuntime:        ld      bc,UBnKRuntimeSize
                        ld      hl,UBnKStartOfRuntimeData
                        ZeroA
                        ld      (UBnKECMCountDown),a
                        ld      (UBnKHeadingToPlanetOrSun),a ; at the moment we don't have a preferred trader route
.InitLoop:              ld      (hl),a
                        inc     hl
                        djnz    .InitLoop            
.SetEnergy:             ldCopyByte EnergyAddr, UBnKEnergy
.SetBankData:           ld      a,iyh
                        ld      (UBnKSlotNumber),a
                        add     a,BankUNIVDATA0
                        ld      (UbnKShipUnivBankNbr),a
                        ld      a,iyl
                        ld      (UBnKShipModelId),a
                        call    GetShipBankId                ; this will mostly be debugging info
                        ld      (UBnkShipModelBank),a        ; this will mostly be debugging info
                        ld      a,b                          ; this will mostly be debugging info
                        ld      (UBnKShipModelNbr),a         ; this will mostly be debugging info
.SetUpMissileCount:     ld      a,(LaserAddr)                ; get laser and missile details
                        and     ShipMissileCount
                        ld      c,a
                        ld      a,(RandomSeed1)              ; missile flag limit
                        and     c                            ; .
                        ld      (UBnKMissilesLeft),a
.SetupLaserType         ld      a,(LaserAddr)
                        and     ShipLaserPower
                        swapnib
                        ld      (UBnKLaserPower),a
.SetUpFighterBays:      ld      a,(ShipAIFlagsAddr)
                        ld      c,a
                        and     ShipFighterBaySize
                        JumpIfANENusng ShipFighterBaySizeInf, .LimitedBay
                        ld      a,$FF                       ; force unlimited ships
.LimitedBay:            swapnib                             ; as its bits 6 to 4 and we have removed bit 7 we can cheat with a swapnib
                        ld      (UBnKFightersLeft),a
.SetUpFighterType:      ld      a,c                         ; get back AI flags
                        and     ShipFighterType             ; fighter type is bits 2 and 3
                        rr      a                           ; so get them down to 0 and 1
                        rr      a                           ;
                        ld      hl,FighterTypeMapping       ; then use the lookup table
                        add     hl,a                        ; for the respective ship id
                        ld      a,(hl)                      ; we work on this for optimisation
                        ld      (UBnKFighterShipId),a       ; ship data holds index to this table
.SetUpECM:              ld      a,(ShipECMFittedChanceAddr) ; Now handle ECM
                        ld      b,a
.FetchLatestRandom:     ld      a,(RandomSeed3)              
                        JumpIfALTNusng b, .ECMFitted
.ECMNotFitted:          SetMemFalse UBnKECMFitted
                        jp      .DoneECM
.ECMFitted:             SetMemTrue  UBnKECMFitted
.DoneECM:               ; TODO set up laser power
                        ret
    DISPLAY "Tracing 2", $
    
                        include "Universe/Ships/InitialiseOrientation.asm"
;----------------------------------------------------------------------------------------------------------------------------------
;OrientateVertex:
;                      [ sidev_x sidev_y sidev_z ]   [ x ]
;  projected [x y z] = [ roofv_x roofv_y roofv_z ] . [ y ]
;                      [ nosev_x nosev_y nosev_z ]   [ z ]
;

;----------------------------------------------------------------------------------------------------------------------------------
;TransposeVertex:
;                      [ sidev_x roofv_x nosev_x ]   [ x ]
;  projected [x y z] = [ sidev_y roofv_y nosev_y ] . [ y ]
;                      [ sidev_z roofv_z nosev_z ]   [ z ]
; VectorToVertex:
;                     [ sidev_x roofv_x nosev_x ]   [ x ]   [ x ]
;  vector to vertex = [ sidev_y roofv_y nosev_y ] . [ y ] + [ y ]
;                     [ sidev_z roofv_z nosev_z ]   [ z ]   [ z ]
;INPUTS:    bhl = dividend  cde = divisor where b and c are sign bytes
;OUTPUTS:   cahl = quotient cde = divisor
;--------------------------------------------------------------------------------------------------------
                        ;include "./ModelRender/EraseOldLines-EE51.asm"
 ; OBSOLETE                       include "./ModelRender/TrimToScreenGrad-LL118.asm"
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
;---------------------------------------------------------------------------------------------------------
;-- 
    DISPLAY "TODO: Change to a tidy that checks for normal accuracy first"
TidyRotation:       IFNDEF FORCE_TIDY    
                        ld      a,(UBnkTidyCounter)         ; loops every 16 iterations
                        dec     a                           ; and call is determined 
                        and     %00001111                   ; by if the counter
                        ld      (UBnkTidyCounter),a         ; matches teh slot number
                        ld      hl,UBnKSlotNumber           ; of course this is then 16 slots max
                        cp      (hl)
                        ret     nz                          ; when counter matches slot number tidy stops it doing all tidies on same iteration
                    ENDIF
                    IFNDEF BYPASS_TIDY
                        MMUSelectMathsBankedFns
                        call    TidyVectorsIX
                    ENDIF
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
    DISPLAY "Tracing 3", $

                        include "Universe/Ships/NormaliseTransMat.asm"
;;;                        include "Universe/Ships/NormaliseXX15.asm"
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


    DISPLAY "Tracing 4", $

;-- LL51---------------------------------------------------------------------------------------------------------------------------
;TESTED OK
;XX12EquScaleDotOrientation:                         ; .LL51 \ -> &4832 \ XX12=XX15.XX16  each vector is 16-bit x,y,z
XX12EquXX15DotProductXX16:
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
; Not Used in code      include "Universe/Ships/ScaleNormal.asm"
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
    include "./ModelRender/BackfaceCull.asm"
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
    
    DISPLAY "Tracing 5", $

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
        MMUSelectMathsBankedFns
        call        RequAmul256divQ;RequAdivQ                           ; LL61  \ visit up  R = A/Q = x/z
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
        call        RequAmul256divQ;RequAdivQ                           ; LL61  \ else visit up R = A/Q = y/z
        jp          SkipYScale                          ; LL68 hop over small y yangle
SmallYHop:
LL67:                                                   ; Arrive from LL66 above if XX15+3 < Q \ small yangle
        MMUSelectMathsBankedFns
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
CopyNodeToXX15:             ldCopyByte  hl, UBnkXScaled                     ; Load into XX15                                                                     Byte 0;;;     XX15 xlo   = byte 0
                            inc         hl
                            ldCopyByte  hl, UBnkYScaled                     ; Load into XX15                                                                     Byte 0;;;     XX15 xlo   = byte 0
                            inc         hl
                            ldCopyByte  hl, UBnkZScaled                     ; Load into XX15                                                                     Byte 0;;;     XX15 xlo   = byte 0
                            inc         hl
; Simplfied for debugging, needs optimising back to original DEBUG TODO
.PopulateXX15SignBits:      ld          a,(hl)
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

    DISPLAY "Tracing 6", $

ProjectNodeToEye:
    ld          bc,(UBnkZScaled)                    ; BC = Z Cordinate. By here it MUST be positive as its clamped to 4 min
    ld          a,c                                 ;  so no need for a negative check
    ld          (varQ),a                            ; VarQ = z
    ld          a,(UBnkXScaled)                     ; XX15  \ rolled x lo which is signed
    call        DIV16Amul256dCUNDOC                 ; result in BC which is 16 bit TODO Move to 16 bit below not just C reg
    ld          a,(UBnkXScaledSign)                 ; XX15+2 \ sign of X dist
    JumpOnBitSet a,7,EyeNegativeXPoint             ; LL62 up, -ve Xdist, RU screen onto XX3 heap
EyePositiveXPoint:                                  ; x was positive result
    ld          l,ScreenCenterX                     ; 
    ld          h,0
    add         hl,bc                               ; hl = Screen Centre + X
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
    ld          bc,(UBnkZScaled)                    ; Now process Y co-ordinate
    ld          a,c
    ld          (varQ),a
    ld          a,(UBnkYScaled)                     ; XX15  \ rolled x lo
    call        DIV16Amul256dCUNDOC                 ; a = Y scaled * 256 / zscaled
    ld          a,(UBnkYScaledSign)                 ; XX15+2 \ sign of X dist
    JumpOnBitSet a,7,EyeNegativeYPoint             ; LL62 up, -ve Xdist, RU screen onto XX3 heap top of screen is Y = 0
EyePositiveYPoint:                                  ; Y is positive so above the centre line
    ld          l,ScreenCenterY
    ClearCarryFlag
    sbc         hl,bc                               ; hl = ScreenCentreY - Y coord (as screen is 0 at top)
    jp          EyeStoreYPoint
EyeNegativeYPoint:                                  ; this bit is only 8 bit aware TODO FIX
    ld          l,ScreenCenterY                     
    ld          h,0
    add         hl,bc                               ; hl = ScreenCenterY + Y as negative is below the center of screen
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
            INCLUDE "./Universe/Ships/ApplyShipSpeed.asm"
            INCLUDE "./ModelRender/DrawLines.asm"
; ---------------------------------------------------------------------------------------------------------------------------------    

; DIot seem to lawyas have Y = 0???
ProcessDot:            ; break
                        call    CopyRotmatToTransMat             ;#01; Load to Rotation Matrix to XX16, 16th bit is sign bit
                        call    ScaleXX16Matrix197               ;#02; Normalise XX16
                        call    LoadCraftToCamera                ;#04; Load Ship Coords to XX18
                        call    InverseXX16                      ;#11; Invert rotation matrix
                        ld      hl,0
                        ld      (UBnkXScaled),hl
                        ld      (UBnkYScaled),hl
                        ld      (UBnkZScaled),hl
                        xor     a
                        call    XX12EquNodeDotOrientation
                        call    TransposeXX12ByShipToXX15
                        call    ScaleNodeTo8Bit                     ; scale to 8 bit values, why don't we hold the magnitude here?x
                        ld      iy,UBnkNodeArray
                        call    ProjectNodeToEye
                        ret
                
; .....................................................
; Plot Node points as part of debugging
PlotAllNodes:           ld      a,(VertexCtX6Addr)               ; get Hull byte#9 = number of vertices *6                                   ;;;
.GetActualVertexCount:  ld      c,a                              ; XX20 also c = number of vertices * 6 (or XX20)
                        ld      c,a                              ; XX20 also c = number of vertices * 6 (or XX20)
                        ld      d,6
                        MMUSelectMathsBankedFns
                        call    asm_div8                         ; asm_div8 C_Div_D - C is the numerator, D is the denominator, A is the remainder, B is 0, C is the result of C/D,D,E,H,L are not changed"
                        ld      b,c                              ; c = number of vertices
                        ld      iy,UBnkNodeArray
.PlotLoop:              ld      e,(iy)
                        ld      d,(iy+1)
                        ld      l,(iy+2)
                        ld      h,(iy+3)
                        push    bc,,iy
                        call    PlotAtDEHL
                        pop     bc,,iy
                        inc     iy
                        inc     iy
                        inc     iy
                        inc     iy
                        djnz    .PlotLoop
                        ret

PlotAtDEHL:             ld      a,d
                        and     a
                        ret     nz
                        ld      a,h
                        and     a
                        ret     nz
                        ld      a,l
                        and     $80
                        ret     nz
                        MMUSelectLayer2
                        ld      b,l
                        ld      c,e
                        ld      a,$88
                        call    l2_plot_pixel
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
                        call    CopyRotmatToTransMat            ; CopyRotToTransMacro                      ;#01; Load to Rotation Matrix to XX16, 16th bit is sign bit
                        call    ScaleXX16Matrix197               ;#02; Normalise XX16
                        call    LoadCraftToCamera                ;#04; Load Ship Coords to XX18
                        call    InverseXX16                      ;#11; Invert rotation matrix
                        ld      hl,UBnkHullVerticies
                        ld      a,(VertexCtX6Addr)               ; get Hull byte#9 = number of vertices *6                                   ;;;
GetActualVertexCount:   ld      c,a                              ; XX20 also c = number of vertices * 6 (or XX20)
                        ld      c,a                              ; XX20 also c = number of vertices * 6 (or XX20)
                        ld      d,6
                        MMUSelectMathsBankedFns
                        call    asm_div8                         ; asm_div8 C_Div_D - C is the numerator, D is the denominator, A is the remainder, B is 0, C is the result of C/D,D,E,H,L are not changed"
                        ld      b,c                              ; c = number of vertices
                        ld      iy,UBnkNodeArray
LL48:   
PointLoop:              push    bc                                  ; save counters
                        push    hl                                  ; save verticies list pointer
                        push    iy                                  ; save Screen plot array pointer
                        ld      a,b
                        ;break
                        call    CopyNodeToXX15                      ; copy verices at hl to xx15
                        ld      a,(UBnkXScaledSign)
                        call    XX12EquNodeDotOrientation
                        call    TransposeXX12ByShipToXX15
                        call    ScaleNodeTo8Bit                     ; scale to 8 bit values, why don't we hold the magnitude here?x
                        pop     iy                                  ; get back screen plot array pointer
                        call    ProjectNodeToEye                     ; set up screen plot list entry
   ; ld      hl,UbnkLineArrayLen
  ;  inc     (hl)                                ; another node done
ReadyForNextPoint:      push    iy                                  ; copy screen plot pointer to hl
                        pop     hl
                        ld      a,4
                        add     hl,a
                        push    hl                                  ; write it back at iy + 4
                        pop     iy                                  ; and put it in iy again
                        pop     hl                                  ; get hl back as vertex list
                        ld      a,6
                        add     hl,a                                ; and move to next vertex
                        pop     bc                                  ; get counter back
                        djnz    PointLoop
; ......................................................   
                        ClearCarryFlag
                        ret                                         
; ...........................................................
ProcessShip:            call    CheckVisible                ; checks for z -ve and outside view frustrum, sets up flags for next bit
.IsItADot:              ld      a,(UBnkaiatkecm)
                        and     ShipIsVisible | ShipIsDot | ShipExploding  ; first off set if we can draw or need to update explosion
                        ret     z                           ; if none of these flags are set we can fast exit
                        JumpOnABitSet ShipExplodingBitNbr, .ExplodingCloud; we always do the cloud processing even if invisible
;............................................................  
.DetermineDrawType:     ReturnOnBitClear    a, ShipIsVisibleBitNbr          ; if its not visible exit early
                        JumpOnABitClear ShipIsDotBitNbr, .CarryOnWithDraw   ; if not dot do normal draw
                        ;break
;............................................................  
.itsJustADot:           call    ProcessDot
                        call    UnivVisibleNonDot           ; set is a dot flag
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
                        call    ShipPixel                   ; 
                        ret
;............................................................  
.CarryOnWithDraw:       call    ProcessNodes                ; process notes is the poor performer or check distnace is not culling
                       ; break
                    IFDEF PLOTPOINTSONLY 
                        ld      a,$F6
                        ld      (line_gfx_colour),a  
                        call    PlotAllNodes
                    ELSE
                        ld      a,$E3
                        ld      (line_gfx_colour),a  
                        call    CullV2
                        call    PrepLines                       ; With late clipping this just moves the data to the line array which is now x2 size
                        call    DrawLinesLateClipping
                    ENDIF
                    IFDEF OVERLAYNODES
                        ld      a,$CF
                        ld      (line_gfx_colour),a  
                        call    PlotAllNodes
                    ENDIF
                    IFDEF FLIPBUFFERSTEST
                        DISPLAY "Univ_ship_data flip buffer test Enabled"
                        call   l2_flip_buffers
                        call   l2_flip_buffers
                    ELSE
                        DISPLAY "Univ_ship_data flip buffer test Disabled"
                    ENDIF
                        ret 
;............................................................  
.ExplodingCloud:        ;break
                        call    ProcessNodes
                        call    UnivAcknowledExploding      ; acknowledge ship exploding
.UpdateCloudCounter:    ld      a,(UBnKCloudCounter)        ; counter += 4 until > 255
                        add     4                           ; we do this early as we now have logic for
                        jp      c,.FinishedExplosion        ; display or not later
                        ld      (UBnKCloudCounter),a        ; .
.SkipHiddenShip:        ReturnOnMemBitClear  UBnkaiatkecm , ShipIsVisibleBitNbr
.IsShipADot:            JumpOnABitSet ShipIsDotBitNbr, .itsJustADot ; if its dot distance then explosion is a dot, TODO later we will do as a coloured dot
.CalculateZ:            ld      hl,(UBnKzlo)                ; al = hl = z
                        ld      a,h                         ; .
                        JumpIfALTNusng 32,.CalcFromZ        ; if its >= 32 then set a to FE and we are done
                        ld      h,$FE                       ; .
                        jp      .DoneZDist                  ; .
.CalcFromZ:             ShiftHLLeft1                        ; else
                        ShiftHLLeft1                        ; hl = hl * 2
                        SetCarryFlag                        ; h = h * 3 rolling in lower bit
                        rl  h                               ; 
.DoneZDist:             ld      b,0                         ; bc = cloud z distance calculateed
                        ld      c,h                         ; .
.CalcCloudRadius:       ld      a,(UBnKCloudCounter)        ; de = cloud counter * 256
        IFDEF LOGMATHS
                        MMUSelectMathsTables
                        ld      b,h
                        call    AEquAmul256DivBLog
                        ld      d,a
                        MMUSelectROM0
        ELSE
                        ld      d,a                         ;
                        ld      e,0                         ;
                        MMUSelectMathsBankedFns
                        call    DEequDEDivBC                ; de = cloud counter * 256 / z distance
                        ld      a,d                         ; if radius >= 28
        ENDIF
                        JumpIfALTNusng  28,.SetCloudRadius  ; then set raidus in d to $FE
.MaxCloudRadius:        ld      d,$FE                       ;
                        jp      .SizedUpCloud               ;
.SetCloudRadius:        ShiftDELeft1                        ; de = 8 * de
                        ShiftDELeft1                        ; .
                        ShiftDELeft1                        ; .
.SizedUpCloud:          ld      a,d                         ; cloudradius = a = d or (cloudcounter * 8 / 256)
                        ld      (UBnKCloudRadius),a         ; .
                        ld      ixh,a                       ; ixh = a = calculated cloud radius
.CalcSubParticleColour: ld      a,(UBnKCloudCounter)        ; colur fades away
                        swapnib                             ; divive by 16
                        and     $0F                         ; mask off upper bytes
                        sra     a                           ; divide by 32
                        ld      hl,DebrisColourTable
                        add     hl,a
                        ld      a,(hl)
                        ld      iyl,a                       ; iyl = pixel colours
.CalcSubParticleCount:  ld      a,(UBnKCloudCounter)        ; cloud counter = abs (cloud counter) in effect if > 127 then shrinks it
                        ABSa2c                              ; a = abs a
.ParticlePositive:      sra a                               ; iyh = (a /8) 
                        sra a                               ; .
                        sra a                               ; .
                        or  1                               ; bit 0 set so minimum 1
.DoneSubParticleCount:  ld      ixl,a                       ; ixl = nbr particles per vertex
.ForEachVertex:         ld      a,(VertexCountAddr)         ; load vertex count into b
                        ld      b,a                         ; .
                        ld      hl,UBnkNodeArray            ; hl = list of vertices
.ExplosionVertLoop:     push    bc,,hl                      ; save vertex counter in b and pointer to verticles in hl
                            ld      ixl,b                   ; save counter
                            ld      c,(hl)                  ; get vertex into bc and de
                            inc     hl                      ; .
                            ld      b,(hl)                  ; .
                            inc     hl                      ; .
                            ld      e,(hl)                  ; .
                            inc     hl                      ; .
                            ld      d,(hl)                  ; now hl is done with and we can use it 
.LoopSubParticles:          ld      a,ixl                   ; iyh = loop iterator for nbr of particles per vertex
                            ld      iyh,a                   ; 
                            ;break
.ProcessAParticle:          push    de,,bc                  ; save y then x coordinates
                                ex      de,hl               ; hl = de (Y)
                                ld      d,ixh               ; d = cloud radius
                                call    HLEquARandCloud     ; vertex = vertex +/- (random * projected cloud side /256)
                                ld      a,h                 ; if off screen skip
                                JumpIfAIsNotZero  .NextIteration
                                ex      de,hl               ; de = result for y which was put into hl
                                pop     hl                  ; get x back from bc on stack
                                push    hl                  ; put bc (which is now in hl) back on the stack
                                push    de                  ; save de
                                ld      d,ixh               ; d = cloud radius
                                call    HLEquARandCloud     ; vertex = vertex +/- (random * projected cloud side /256)
                                pop     de                  ; get de back doing pop here clears stack up
                                ld      a,h                 ; if high byte has a value then off screen
                                JumpIfAIsNotZero .NextIteration ; 
                                ld      b,e                 ; bc = y x of pixel from e and c regs
                                ld      c,l                 ; iyl already has colour
                                MMUSelectLayer2             ; plot it with debris code as this can chop y > 128
                                call    DebrisPixel         ; .
.NextIteration:             pop    de,,bc                   ; ready for next iteration, get back y and x coordinates
                            dec    iyh                      ; one partcile done
                            jr      nz,.ProcessAParticle    ; until all done
.NextVert:              pop     bc,,hl                      ; recover loop counter and source pointer
                        ld      a,4                         ; move to next vertex group
                        add     hl,a                        ;
                        djnz    .ExplosionVertLoop          ;         
                        ret
.FinishedExplosion:     ;break
                        ld      a,(UBnKSlotNumber)          ; get slot number
                        call    ClearSlotA                  ; gauranted to be in main memory as non bankables
                        call    UnivFinishedExplosion       ;
                        ret


DebrisColourTable:      DB L2ColourYELLOW_1, L2ColourYELLOW_2, L2ColourYELLOW_3, L2ColourYELLOW_4, L2ColourYELLOW_5, L2ColourYELLOW_6, L2ColourYELLOW_7,L2ColourGREY_4
                        ; set flags and signal to remove from slot list        

; Hl = HlL +/- (Random * projected cloud size)
; In - d = z distance, hl = vert hi lo
; Out hl = adjusted distance
; uses registers hl, de
HLEquARandCloud:        push    hl                          ; random number geneator upsets hl register
                        call    doRandom                    ; a= random * 2
                        pop     hl
                        rla                                 ;
                        jr      c,.Negative                 ; if buit 7 went into carry
.Positive:              ld  e,a
                        mul
                        ld  e,d
                        ld  d,0
                        ClearCarryFlag
                        adc     hl,de                       ; hl = hl + a
                        ret
.Negative:              ld  e,a
                        mul
                        ld  e,d
                        ld  d,0
                        ClearCarryFlag
                        sbc     hl,de                       ; hl = hl + a
                        ret

GetExperiencePoints:    ; TODO calculate experience points
                        ; TODO mission updates check
                        ret

; ......................................................   
KillShip:               ld      a,(ShipTypeAddr)            ; we can't destroy stations in a collision
                        cp      ShipTypeStation             ; for destructable one we will have a special type of ship
                        ret     z
                        call    UnivExplodeShip             ; remove AI, mark killed, mark exploding
                        SetMemToN   UBnKexplDsp, ShipExplosionDuration ; set debris cloud timer, also usered in main to remove from slots
                        ldWriteZero UBnKEnergy              ; Zero ship energy
                        ld      (UBnKCloudRadius),a
                        ld      a,18
                        ld      (UBnKCloudCounter),a        ; Zero cloud
                        ; TODO logic to spawn cargo/plates goes here
                        ret
                        
; in a = damage                        
DamageShip:             ld      b,a                         ; b = a = damage comming in
                        ld      a,(ShipTypeAddr)            ; we can't destroy stations in a collision
                        cp      ShipTypeStation             ; for destructable one we will have a special type of ship
                        ret     z
                        ld      a,(UBnKEnergy)              ; get current energy level
                        ClearCarryFlag
                        sbc     a,b                         ; subtract damage
.Overkilled:            jp      nc,.DoneDamage              ; if no carry then its not gone negative
                        call    KillShip                    ; else kill it
                        ret
.DoneDamage:            ld      (UBnKEnergy),a
                        ret
; need recovery for energy too
; Shall we have a "jolt ship off course routine for when it gets hit by a blast or collision)                        
                        
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
        call        ClipLineV3                            ; LL145 \ clip test on XX15 XX12 vector, returns carry 
        jr          c,CalculateNewLines
;        jr          c,CalculateNewLines                 ; LL170 clip returned carry set so not visibile if carry set skip the rest (laser not firing)
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

    DISPLAY "Tracing 7", $

    INCLUDE "Universe/Ships/PrepLines.asm"

    DISPLAY "Tracing XX", $

UnivBankSize  EQU $ - StartOfUniv
