;    DEFINE DEBUGMISSILELAUNCH 1
;    DEFINE PLOTPOINTSONLY 1
;   DEFINE OVERLAYNODES 1
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
;-Camera Position of Ship----------------------------------------------------------------------------------------------------------
                       INCLUDE "../../Universe/Ships/AIRuntimeData.asm"
                        INCLUDE "../../Universe/Ships/XX16Vars.asm"
                        INCLUDE "../../Universe/Ships/XX25Vars.asm"
                        INCLUDE "../../Universe/Ships/XX18Vars.asm"

; Used to make 16 bit reads a little cleaner in source code
UbnkZPoint                  DS  3
UbnkZPointLo                equ UbnkZPoint
UbnkZPointHi                equ UbnkZPoint+1
UbnkZPointSign              equ UbnkZPoint+2
                        INCLUDE "../../Universe/Ships/XX15Vars.asm"
                        INCLUDE "../../Universe/Ships/XX12Vars.asm"


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
UbnkFaceVisArray            DS FaceArraySize            ; XX2 Up to 16 faces this may be normal list, each entry is controlled by bit 7, 1 visible, 0 hidden
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
UBnkHullSolid               DS  100 * 4             ; Up to 100 triangles (May optimise so only loads non hidden faces later
    ENDIF
OrthagCountdown             DB  12

UBnkShipCopy                equ UBnkHullVerticies               ; Buffer for copy of ship data, for speed will copy to a local memory block, Cobra is around 400 bytes on creation of a new ship so should be plenty
UBnk_Data_len               EQU $ - StartOfUniv


ZeroUnivPitch:          MACRO
                        xor     a
                        ld      (UBnKRotZCounter),a
                        ENDM

ZeroUnivRoll:           MACRO
                        xor     a
                        ld      (UBnKRotXCounter),a
                        ENDM

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

InfinitePitch:          MACRO
                        ld      a,$FF
                        ld      (UBnKRotZCounter),a
                        ENDM   

InfiniteRoll:           MACRO
                        ld      a,$FF
                        ld      (UBnKRotXCounter),a
                        ENDM   

InfinitePitchAndRoll:    MACRO
                        ld      a,$FF
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
                        ld      (UBnKSpeed),a
                        ENDM
                        
MaxUnivSpeed:           MACRO
                        ld      a,31
                        ld      (UBnKSpeed),a
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
; Sets invisibile
UnivInvisible:          ClearMemBitN  UBnkaiatkecm  , ShipIsVisibleBitNbr ; Assume its hidden
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
                        
                        
WarpOffset:             JumpOffSet  UBnKzhi                     ; we will simplify on just moving Z
                        ret
                        
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


UnivSetDemoPostion:     call    UnivSetSpawnPosition
                        ld      a,%10000001                     ; AI Enabled has 1 missile
                        ld      (UBnkaiatkecm),a                ; set hostinle, no AI, has ECM
                        ld      (ShipNewBitsAddr),a             ; initialise new bits logic
                        ld      a,0
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
    DISPLAY "Tracing 1", $
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
    ;Input: BC = Dividend, DE = Divisor, HL = 0
;Output: BC = Quotient, HL = Remainder

; Initialiase data, iyh must equal slot number
;                   iyl must be ship type
;                   a  = current bank number
UnivInitRuntime:        ld      bc,UBnKRuntimeSize
                        ld      hl,UBnKStartOfRuntimeData
                        ZeroA
.InitLoop:              ld      (hl),a
                        inc     hl
                        djnz    .InitLoop            
                        ret
    DISPLAY "Tracing 2", $
    
                        include "../../Universe/Ships/InitialiseOrientation.asm"

;--------------------------------------------------------------------------------------------------------
                        INCLUDE "../../ModelRender/CLIP-LL145.asm"
;--------------------------------------------------------------------------------------------------------
                        INCLUDE "../../Universe/Ships/CopyRotmatToTransMat.asm"
                        INCLUDE "../../Universe/Ships/TransposeXX12ByShipToXX15.asm"
                        INCLUDE "../../Maths/Utilities/ScaleNodeTo8Bit.asm"

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
;--------------------------------------------------------------------------------------------------------
                        include "../../Universe/Ships/NormaliseTransMat.asm"
;--------------------------------------------------------------------------------------------------------
                        include "../../Universe/Ships/InverseXX16.asm"
;--------------------------------------------------------------------------------------------------------
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
                        INCLUDE "../../Universe/Ships/CopyXX12ScaledToXX18.asm"
                        INCLUDE "../../Universe/Ships/CopyXX12toXX15.asm"
                        INCLUDE "../../Universe/Ships/CopyXX18toXX15.asm"
                        INCLUDE "../../Universe/Ships/CopyXX18ScaledToXX15.asm"
                        INCLUDE "../../Universe/Ships/CopyXX12ToScaled.asm"
;--------------------------------------------------------------------------------------------------------
                        INCLUDE "../../Maths/Utilities/DotProductXX12XX15.asm"
;--------------------------------------------------------------------------------------------------------
; scale Normal. IXL is xReg and A is loaded with XX17 holds the scale factor to apply
; Not Used in code      include "Universe/Ships/ScaleNormal.asm"
;--------------------------------------------------------------------------------------------------------
                        INCLUDE "../../Universe/Ships/ScaleObjectDistance.asm"
;--------------------------------------------------------------------------------------------------------

; Backface cull        
; is the angle between the ship -> camera vector and the normal of the face as long as both are unit vectors soo we can check that normal z > 0
; normal vector = cross product of ship ccordinates 
;
                        INCLUDE "../../Universe/Ships/CopyFaceToXX15.asm"
                        INCLUDE "../../Universe/Ships/CopyFaceToXX12.asm"
;--------------------------------------------------------------
;--------------------------------------------------------------
                        INCLUDE "../../ModelRender/BackfaceCull.asm"
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
; ---------------------------------------------------------------------------------------------------------------------------------    
            INCLUDE "../../Universe/Ships/ApplyMyRollAndPitch.asm"
            INCLUDE "../../Universe/Ships/ApplyShipRollAndPitch.asm"
            INCLUDE "../../Universe/Ships/ApplyShipSpeed.asm"
            INCLUDE "../../ModelRender/DrawLines.asm"
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
                        call    CopyRotmatToTransMat ; CopyRotToTransMacro                      ;#01; Load to Rotation Matrix to XX16, 16th bit is sign bit
                        call    ScaleXX16Matrix197               ;#02; Normalise XX16
                        call    LoadCraftToCamera                ;#04; Load Ship Coords to XX18
                        call    InverseXX16                      ;#11; Invert rotation matrix
                        ld      hl,UBnkHullVerticies
                        ld      a,(VertexCtX6Addr)               ; get Hull byte#9 = number of vertices *6                                   ;;;
GetActualVertexCount:   ld      c,a                              ; XX20 also c = number of vertices * 6 (or XX20)
                        ld      c,a                              ; XX20 also c = number of vertices * 6 (or XX20)
                        ld      d,6
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
;............................................................  
.DetermineDrawType:     ReturnOnBitClear    a, ShipIsVisibleBitNbr          ; if its not visible exit early
;............................................................  
.CarryOnWithDraw:       call    ProcessNodes                ; process notes is the poor performer or check distnace is not culling
                       ; break
                        ld      a,$E3
                        ld      (line_gfx_colour),a  
                        call    CullV2
                        call    PrepLines                       ; With late clipping this just moves the data to the line array which is now x2 size
                        call    DrawLinesLateClipping
                        ret 

    ;INCLUDE "../../Universe/Ships/PrepLines.asm"
;--------------------------------------------------------------------------------------------------------
        DISPLAY "Tracing 8", $

    INCLUDE "../../ModelRender/getVertexNodeAtAToX1Y1.asm"
    
        DISPLAY "Tracing 9", $

    INCLUDE "../../ModelRender/getVertexNodeAtAToX2Y2.asm"
        DISPLAY "Tracing 10", $

    INCLUDE "../../ModelRender/GetFaceAtA.asm"
        DISPLAY "Tracing 11", $

;--------------------------------------------------------------------------------------------------------
; LL72 Goes through each edge in to determine if they are on a visible face, if so load start and end to line array as clipped lines
 ;   DEFINE NOBACKFACECULL 1
PLEDGECTR           DB          0

PrepLines:
InitialiseLineRead:  
        ;break
        ldWriteZero UbnkLineArrayLen                    ; current line array index = 0
        ld          (UbnkLineArrayBytes),a              ; UbnkLineArrayBytes= nbr of bytes of lines laoded = array len * 4
        ld          (PLEDGECTR),a
        ld          a,(EdgeCountAddr)
        ld          ixh,a                               ; ixh = XX17 = Total number of edges to traverse
        ld          iyl,0                               ; ixl = current edge index
        ld          hl,UbnkLineArray                    ; head of array
        ld          (varU16),hl                         ; store current line array pointer un varU16
        ldCopyByte  EdgeCountAddr, XX17                 ; XX17  = total number of edges to traverse edge counter
        ld          a,(UBnKexplDsp)                     ; get explosion status
        JumpOnBitClear a,6,CalculateNewLines            ; LL170 bit6 of display state clear (laser not firing) \ Calculate new lines
        and         $BF                                 ; else laser is firing, clear bit6.
        ld          (UBnKexplDsp),a                     ; INWK+31
;   TODO commentedout as teh subroutine is a mess   call        AddLaserBeamLine                    ; add laser beam line to draw list
; NOw we can calculate hull after including laser line        
CalculateNewLines:
LL170:                                                  ;(laser not firing) \ Calculate new lines   \ their comment
CheckEdgesForVisibility:        
        ld          hl,UBnkHullEdges
        ; TODO change heap to 3 separate arrays and break them down during copy of ship hull data
        ld          (varV),hl                           ; V \ is pointer to where edges data start
        ld          a,(LineX4Addr)
        ld          b,a                                 ; nbr of bytes of edge data
LL75Loop:                                               ; count Visible edges
IsEdgeInVisibilityRange:
        ld          hl,(varV)
        push        hl
        pop         iy
        ld          a,(LastNormalVisible)               ; XX4 is visibility range
        ld          d,a                                 ; d holds copy of XX4
; Get Edge Byte 0
        ld          a,(IY+0)                            ; edge data byte#0 is visibility distance
        JumpIfALTNusng d,LL78EdgeNotVisible             ; XX4   \ visibility LLx78 edge not visible
EdgeMayBeVisibile:
; Get Edge Byte 1
IsFace1Visibile:                                        ; edges have 2 faces to test
        ld          a,(IY+1)                            ; (V),Y \ edge data byte#1 bits 0 to 3 face 1 4 to 7 face 2
        ld          c,a                                 ;  c = a copy of byte 1
        and         $0F                                 ;
        GetFaceAtA
;       jp  VisibileEdge; DEBUG BODGE TEST TODO
        JumpIfAIsNotZero VisibileEdge                     ; LL70 visible edge
IsFace2Visibile:
        ld          a,c                                 ; restore byte 1 from c register
        swapnib                                         ; 
        and         $0F                                 ; swap high byte into low byte
        push        hl
        GetFaceAtA
        pop         hl
        JumpIfAIsZero LL78EdgeNotVisible                ; edge not visible
VisibileEdge:                                           ; Now we need to node id from bytes 2 - start and 3 - end
;LL79--Visible edge--------------------------------------
; Get Edge Byte 2
        ld          a,(IY+2)                            ; get Node id
        ld          de,UBnkX1
        call        getVertexNodeAtAToDE; getVertexNodeAtAToX1Y1              ; get the points X1Y1 from node
        ld          a,(IY+3)
        ld          de,UBnkX2
        call        getVertexNodeAtAToDE; getVertexNodeAtAToX2Y2              ; get the points X2Y2 from node
LL80:                                                   ; ll80 \ Shove visible edge onto XX19 ship lines heap counter U
        ld          de,(varU16)                         ; clipped edges heap address
        ld          hl,UbnkPreClipX1
        FourLDIInstrunctions
        FourLDIInstrunctions
        ld          (varU16),de                         ; update U16 with current address
        ld          hl,UbnkLineArrayLen                 ; we have loaded one line
        inc         (hl)
        ld          a,(hl)
        JumpIfAGTENusng LineArraySize,CompletedLineGeneration   ; have we hit max lines for a model hop over jmp to Exit edge data loop
; If we hit here we skip the write of line arryay u16
LL78EdgeNotVisible:                                     ; also arrive here if Edge not visible, loop next data edge.
LL78:
        ld          hl,(varV)                           ; varV is current edge address
        ld          a,4
        add         hl,a
        ld          (varV),hl
        ld          hl,PLEDGECTR                        ;
        inc         (hl)                                ;
        ld          a,(hl)                              ; current edge index ++
        JumpIfANEMemusng XX17,LL75Loop                  ; compare with total number of edges
CompletedLineGeneration:        
LL81:
LL81SHPPT:                                              ; SHPPT ship is a point arrives here with Acc=2, bottom entry in heap
        ld          a,(UbnkLineArrayLen)                ; UbnkLineArrayLen = nbr of lines loaded 
        sla         a
        sla         a                                   ; multiple by 4 to equal number of bytes
        sla         a                           ; multiple by 8 to equal number of bytes
        ld          (UbnkLineArrayBytes),a              ; UbnkLineArrayBytes= nbr of bytes of lines laoded = array len * 4
ExitEdgeDataLoop:
        ret
            

    DISPLAY "Tracing XX", $

UnivBankSize  EQU $ - StartOfUniv
