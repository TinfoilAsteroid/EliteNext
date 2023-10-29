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
SS_StartOfUniv:        DB "Space Station..."
                    INCLUDE "./Universe/Macros/UniverseDefineMacro.asm"
; NOTE we can cheat and pre allocate segs just using a DS for now
                            UnivPosVarsMacro SS
                            UnivRotationVarsMacro SS
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
;;rotXCounter                 equ SS_BnKrotXCounter         ; INWK +29
;;rotZCounter                 equ SS_BnKrotZCounter         ; INWK +30SS_BnKDrawCam0xLo   DB  0               ; XX18+0

                            XX16DefineMacro SS
                            XX25DefineMacro SS
                            XX18DefineMacro SS

                            UnivCoreAIVarsMacro SS
                          
                            XX15DefineMacro SS
                            XX12DefineMacro SS

                            ClippingVarsMacro SS

SS_BnK_Data_len               EQU $ - SS_BnKDataBlock

        UnivCoreAIVarsMacro SS


ss_VarBackface               DB 0
; Heap (or array) information for lines and normals
; Coords are stored XY,XY,XY,XY
; Normals
; This needs re-oprganising now.
; Runtime Calculation Store

            UnivModelVarsMacro SS
; Node heap is used to write out transformed Vertexs
            ShipDataMacro       SS
; Static Ship Data. This is copied in when creating the universe object
            ShipModelDataMacro  SS
SS_BnK_Data_len               EQU $ - SS_StartOfUniv


                        ZeroPitchAndRollMacro   SS
                        MaxPitchAndRollMacro    SS
                        RandomPitchAndRollMacro SS
                        RandomSpeedMacro        SS
                        MaxSpeedMacro           SS
                        ZeroAccellerationMacro  SS
                        SetShipHostileMacro     SS
                        ClearShipHostileMacro   SS
                        
; --------------------------------------------------------------
                        ResetBankDataMacro      SS
                        ResetBnKPositionMacro   SS
                        
                        FireEMCMacro            SS
                        RechargeEnergyMacro     SS
                        
                        UpdateECMMacro          SS
                        
;-- This takes an Axis and subtracts 1, handles leading sign and boundary of 0 going negative
                        JumpOffSetMacro         SS
                        WarpOffSetMacro         SS
                        
; --------------------------------------------------------------                        
; update ship speed and pitch based on adjustments from AI Tactics
UpdateSpeedAndPitch:    ld      a,(SS_BnKAccel)                   ; only apply non zero accelleration
                        JumpIfAIsZero .SkipAccelleration
                        ld      b,a                             ; b = accelleration in 2's c
                        ld      a,(SS_BnKSpeed)                   ; a = speed + accelleration
                        ClearCarryFlag
                        adc     a,b
                        JumpIfPositive  .DoneAccelleration      ; if speed < 0 
.SpeedNegative:         ZeroA                                   ;    then speed = 0
.DoneAccelleration:     ld      b,a                             ; if speed > speed limit
                        ld      a,(SpeedAddr)                   ;    speed = limit
                        JumpIfAGTENusng b, .SpeedInLimits       ; .  
                        ld      b,a                             ; .
.SpeedInLimits:         ld      a,b                             ; .
                        ld      (SS_BnKSpeed),a                   ; .
                        ZeroA                                   ; acclleration = 0
                        ld      (SS_BnKAccel),a                   ; for next AI update
.SkipAccelleration:     ; handle roll and pitch rates                     
                        ret

UnivSetEnemyMissile:    ld      hl,NewLaunchSS_BnKX               ; Copy launch ship matrix
                        ld      de,SS_BnKxlo                      ; 
                        ld      bc,NewLaunchDataBlockSize       ; positon + 3 rows of 3 bytes
                        ldir                                    ; 
.SetUpSpeed:            ld      a,3                             ; set accelleration
                        ld      (SS_BnKAccel),a                   ;
                        ZeroA
                        ld      (SS_BnKRotXCounter),a
                        ld      (SS_BnKRotZCounter),a
                        ld      a,3                             ; these are max roll and pitch rates for later
                        ld      (SS_BnKRAT),a
                        inc     a
                        ld      (SS_BnKRAT2),a
                        ld      a,22
                        ld      (SS_BnKCNT2),a
                        MaxUnivSpeed                            ; and immediatley full speed (for now at least) TODO
                        SetMemFalse SS_BnKMissleHitToProcess
                        ld      a,ShipAIEnabled
                        ld      (SS_BnKaiatkecm),a
                        call    SetShipHostile
.SetupPayload:          ld      a,150
                        ld      (SS_BnKMissileBlastDamage),a
                        ld      (SS_BnKMissileDetonateDamage),a
                        ld      a,5
                        ld      (SS_BnKMissileBlastRange),a
                        ld      (SS_BnKMissileDetonateRange),a
                        ret

; --------------------------------------------------------------                        
; This sets the position of the current ship if its a player launched missile
UnivSetPlayerMissile:   call    InitialisePlayerMissileOrientation  ; Copy in Player  facing
                        call    ResetSS_BnKPosition               ; home position
                        ld      a,MissileDropHeight             ; the missile launches from underneath
                        ld      (SS_BnKylo),a                     ; so its -ve drop height
                        IFDEF DEBUGMISSILELAUNCH
                            ld      a,$20       ; DEBUG
                            ld      (SS_BnKzlo),a
                        ENDIF
                        ld      a,$80                           ;
                        ld      (SS_BnKysgn),a                    ;
                        ld      a,3                             ; set accelleration
                        ld      (SS_BnKAccel),a                   ;
                        ZeroA
                        ld      (SS_BnKRotXCounter),a
                        ld      (SS_BnKRotZCounter),a
                        ld      a,3                             ; these are max roll and pitch rates for later
                        ld      (SS_BnKRAT),a
                        inc     a
                        ld      (SS_BnKRAT2),a
                        ld      a,22
                        ld      (SS_BnKCNT2),a
                        MaxUnivSpeed                            ; and immediatley full speed (for now at least) TODO
                        SetMemFalse SS_BnKMissleHitToProcess
                        ld      a,ShipAIEnabled
                        ld      (SS_BnKaiatkecm),a
                        ;break
                        call    ClearShipHostile                ; its a player missile
                        
                        ret
; --------------------------------------------------------------
; this applies blast damage to ship
ShipMissileBlast:       ld      a,(CurrentMissileBlastDamage)
                        ld      b,a
                        ld      a,(SS_BnKEnergy)                   ; Reduce Energy
                        sub     b
                        jp      UnivExplodeShip
                        jr      UnivExplodeShip
                        ld      (SS_BnKEnergy),a
                        ret

                        ExplodeShipMacro    SS

UnivSetDemoPostion:     call    UnivSetSpawnPosition
                        ld      a,%10000001                     ; AI Enabled has 1 missile
                        ld      (SS_BnKaiatkecm),a                ; set hostinle, no AI, has ECM
                        ld      (ShipNewBitsAddr),a             ; initialise new bits logic
                        ld      a,$FF
                        ld      (SS_BnKRotZCounter),a             ; no pitch
                        ld      (SS_BnKRotXCounter),a             ; set roll to maxi on station
                        ZeroA
                        ld      (SS_BnKxsgn),a
                        ld      (SS_BnKysgn),a
                        ld      (SS_BnKzsgn),a
                        ld      hl,0
                        ld      (SS_BnKxlo),hl
                        ld      (SS_BnKylo),hl
                        ld      a,(ShipTypeAddr)
                        ld      hl,$05B0                            ; so its a negative distance behind
                        JumpIfANENusng ShipTypeStation, .SkipFurther
                        ld      a,5
                        add     h
                        ld      h,a
.SkipFurther            ld      (SS_BnKzlo),hl
                        ret
    DISPLAY "Tracing 1", $
; --------------------------------------------------------------
; This sets the position of the current ship randomly, called after spawing
UnivSetSpawnPosition:   call    InitialiseOrientation
                        RandomUnivPitchAndRoll
                        call    doRandom                        ; set x lo and y lo to random
.setXlo:                ld      (SS_BnKxlo),a 
.setYlo:                ld      (SS_BnKylo),a
.setXsign:              rrca                                    ; rotate by 1 bit right
                        ld      b,a
                        and     SignOnly8Bit
                        ld      (SS_BnKxsgn),a
.setYSign:              ld      a,b                             ; get random back again
                        rrca                                    ; rotate by 1 bit right
                        ld      b,a
                        and     SignOnly8Bit                    ; and set y sign
                        ld      (SS_BnKysgn),a
.setYHigh:              rrc     b                               ; as value is in b rotate again
                        ld      a,b                             ; 
                        and     31                              ; set y hi to random 0 to 31
                        ld      (SS_BnKyhi),a                     ;
.setXHigh:              rrc     b                               ; as value is in b rotate again
                        ld      a,b
                        and     31                              ; set x hi to random 0 to 31
                        ld      c,a                             ; save shifted into c as well
                        ld      (SS_BnKxhi),a
.setZHigh:              ld      a,80                            ; set z hi to 80 - xhi - yhi - carry
                        sbc     b
                        sbc     c
                        ld      (SS_BnKzhi),a
.CheckIfBodyOrJunk:     ld      a,(ShipTypeAddr)
                        ReturnIfAEqNusng ShipTypeJunk
                        ReturnIfAEqNusng ShipTypeScoopable
                        ld      a,b                             ; its not junk to set z sign
                        rrca                                    ; as it can jump in
                        and     SignOnly8Bit
                        ld      (SS_BnKzsgn),a
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
                        ld      de, SS_BnKxlo
                        ld      bc,9
                        ldir
                        ld      hl,DebugRotMat
                        ld      de, SS_BnKrotmatSidevX
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
                        ld  (SS_BnKaiatkecm),a                    ; set hostinle, no AI, has ECM
                        xor a
                        ld      (SS_BnKRotZCounter),a             ; no pitch
                        ld      (ShipNewBitsAddr),a             ; initialise new bits logic
                        ld      a,$FF
                        ld      (SS_BnKRotXCounter),a             ; set roll to maxi on station
.SetPosBehindUs:        ld      hl,$0000
                        ld      (SS_BnKxlo),hl
                        ld      hl,$0000
                        ld      (SS_BnKylo),hl
                        ld      hl,$01B0                            ; so its a negative distance behind
                        ld      (SS_BnKzlo),hl
                        xor     a
                        ld      (SS_BnKxsgn),a
                        ld      (SS_BnKysgn),a
                        ld      a,$80
                        ld      (SS_BnKzsgn),a
.SetOrientation:        call    LaunchedOrientation             ; set initial facing
                        ret
    ;Input: BC = Dividend, DE = Divisor, HL = 0
;Output: BC = Quotient, HL = Remainder



FighterTypeMapping:     DB ShipID_Worm, ShipID_Sidewinder, ShipID_Viper, ShipID_Thargon

; Initialiase data, iyh must equal slot number
;                   iyl must be ship type
;                   a  = current bank number
SS_InitRuntime:         ld      bc,SS_BnKRuntimeSize
                        ld      hl,SS_BnKStartOfRuntimeData
                        ZeroA
                        ld      (SS_BnKECMCountDown),a
.InitLoop:              ld      (hl),a
                        inc     hl
                        djnz    .InitLoop            
.SetEnergy:             ldCopyByte EnergyAddr, SS_BnKEnergy
.SetBankData:           ld      a,iyh
                        ld      (SS_BnKSlotNumber),a
                        add     a,BankUNIVDATA0
                        ld      (SS_BnKShipUnivBankNbr),a
                        ld      a,iyl
                        ld      (SS_BnKShipModelId),a
                        call    GetShipBankId                ; this will mostly be debugging info
                        ld      (SS_BnKShipModelBank),a        ; this will mostly be debugging info
                        ld      a,b                          ; this will mostly be debugging info
                        ld      (SS_BnKShipModelNbr),a         ; this will mostly be debugging info
.SetUpMissileCount:     ld      a,(LaserAddr)                ; get laser and missile details
                        and     ShipMissileCount
                        ld      c,a
                        ld      a,(RandomSeed1)              ; missile flag limit
                        and     c                            ; .
                        ld      (SS_BnKMissilesLeft),a
.SetupLaserType         ld      a,(LaserAddr)
                        and     ShipLaserPower
                        swapnib
                        ld      (SS_BnKLaserPower),a
.SetUpFighterBays:      ld      a,(ShipAIFlagsAddr)
                        ld      c,a
                        and     ShipFighterBaySize
                        JumpIfANENusng ShipFighterBaySizeInf, .LimitedBay
                        ld      a,$FF                       ; force unlimited ships
.LimitedBay:            swapnib                             ; as its bits 6 to 4 and we have removed bit 7 we can cheat with a swapnib
                        ld      (SS_BnKFightersLeft),a
.SetUpFighterType:      ld      a,c                         ; get back AI flags
                        and     ShipFighterType             ; fighter type is bits 2 and 3
                        rr      a                           ; so get them down to 0 and 1
                        rr      a                           ;
                        ld      hl,FighterTypeMapping       ; then use the lookup table
                        add     hl,a                        ; for the respective ship id
                        ld      a,(hl)                      ; we work on this for optimisation
                        ld      (SS_BnKFighterShipId),a       ; ship data holds index to this table
.SetUpECM:              ld      a,(ShipECMFittedChanceAddr) ; Now handle ECM
                        ld      b,a
.FetchLatestRandom:     ld      a,(RandomSeed3)              
                        JumpIfALTNusng b, .ECMFitted
.ECMNotFitted:          SetMemFalse SS_BnKECMFitted
                        jp      .DoneECM
.ECMFitted:             SetMemTrue  SS_BnKECMFitted
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

                        include "./Universe/Macros/FaceVisibility.asm"

                        SetFaceAVisibleMacro        SS
                        SetFaceAHiddenMacro         SS
                        SetAllFacesVisibleMacro     SS
                        SetAllFacesHiddenMacro      SS

                        include "Universe/Ships/NormaliseTransMat.asm"
;;;                        include "Universe/Ships/NormaliseXX15.asm"
;-LL91---------------------------------------------------------------------------------------------------
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
XX12CalcX:              N0equN1byN2div256 varT, (hl), (SS_BnKXScaled)       ; T = (hl) * regXX15fx /256 
                        inc     hl                                  ; move to sign byte
XX12CalcXSign:          AequN1xorN2 SS_BnKXScaledSign,(hl)             ;
                        ld      (varS),a                            ; Set S to the sign of x_sign * sidev_x
                        inc     hl
XX12CalcY:              N0equN1byN2div256 varQ, (hl),(SS_BnKYScaled)       ; Q = XX16 * XX15 /256 using varQ to hold regXX15fx
                        ldCopyByte varT,varR                        ; R = T =  |sidev_x| * x_lo / 256
                        inc     hl
                        AequN1xorN2 SS_BnKYScaledSign,(hl)             ; Set A to the sign of y_sign * sidev_y
; (S)A = |sidev_x| * x_lo / 256  = |sidev_x| * x_lo + |sidev_y| * y_lo
STequSRplusAQ           push    hl
                        call    baddll38                            ; JSR &4812 \ LL38   \ BADD(S)A=R+Q(SA) \ 1byte add (subtract)
                        pop     hl
                        ld      (varT),a                            ; T = |sidev_x| * x_lo + |sidev_y| * y_lo
                        inc     hl
XX12CalcZ:              N0equN1byN2div256 varQ,(hl),(SS_BnKZScaled)       ; Q = |sidev_z| * z_lo / 256
                        ldCopyByte varT,varR                        ; R = |sidev_x| * x_lo + |sidev_y| * y_lo
                        inc     hl
                        AequN1xorN2 SS_BnKZScaledSign,(hl)             ; A = sign of z_sign * sidev_z
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
                        ld      hl,SS_BnKTransmatSidevX     
                        call    XX12DotOneRow
                        ld      (SS_BnKXX12xLo),a
                        ld      a,(varS)
                        ld      (SS_BnKXX12xSign),a
                        ld      hl,SS_BnKTransmatRoofvX     
                        call    XX12DotOneRow
                        ld      (SS_BnKXX12yLo),a
                        ld      a,(varS)
                        ld      (SS_BnKXX12ySign),a
                        ld      hl,SS_BnKTransmatNosevX     
                        call    XX12DotOneRow
                        ld      (SS_BnKXX12zLo),a
                        ld      a,(varS)
                        ld      (SS_BnKXX12zSign),a
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
; line of sight (eye outwards dot face normal vector < 0
; So lin eof sight = vector from 0,0,0 to ship pos, now we need to consider teh ship's facing
; now if we add teh veector for teh normal(times magnitude)) to teh ship position we have the true center of the face
; now we can calcualt teh dot product of this caulated vector and teh normal which if < 0 is goot. this means we use rot mat not inverted rotmat.
    include "./ModelRender/BackfaceCull.asm"
;--LL52 to LL55-----------------------------------------------------------------------------------------------------------------                    

TransposeXX12NodeToXX15:
        ldCopyByte  SS_BnKxsgn,SS_BnKXPointSign           ; SS_BnKXSgn => XX15+2 x sign
        ld          bc,(SS_BnKXX12xLo)                   ; c = lo, b = sign   XX12XLoSign
        xor         b                                   ; a = SS_BnKKxsgn (or XX15+2) here and b = XX12xsign,  XX12+1 \ rotated xnode h                                                                             ;;;           a = a XOR XX12+1                              XCALC
        jp          m,NodeNegativeX                                                                                                                                                            ;;;           if sign is +ve                        ::LL52   XCALC
; XX15 [0,1] = INWK[0]+ XX12[0] + 256*INWK[1]                                                                                       ;;;          while any of x,y & z hi <> 0 
NodeXPositiveX:
        ld          a,c                                 ; We picked up XX12+0 above in bc Xlo
        ld          b,0                                 ; but only want to work on xlo                                                           ;;;              XX15xHiLo = XX12HiLo + xpos lo             XCALC
        ld          hl,(SS_BnKxlo)                       ; hl = XX1 SS_BnKxLo
        ld          h,0                                 ; but we don;t want the sign
        add         hl,bc                               ; its a 16 bit add
        ld          (SS_BnKXPoint),hl                    ; And written to XX15 0,1 
        xor         a                                   ; we want to write 0 as sign bit (not in original code)
        ld          (SS_BnKXPointSign),a
        jp          FinishedThisNodeX
; If we get here then _sign and vertv_ have different signs so do subtract
NodeNegativeX:        
LL52X:                                                 ;
        ld          hl,(SS_BnKxlo)                       ; Coord
        ld          bc,(SS_BnKXX12xLo)                   ; XX12
        ld          b,0                                 ; XX12 lo byte only
        sbc         hl,bc                               ; hl = SS_BnKx - SS_BnKXX12xLo
        jp          p,SetAndMopX                       ; if result is positive skip to write back
NodeXNegSignChangeX:        
; If we get here the result is 2'c compliment so we reverse it and flip sign
        call        negate16hl                          ; Convert back to positive and flip sign
        ld          a,(SS_BnKXPointSign)                 ; XX15+2
        xor         $80                                 ; Flip bit 7
        ld          (SS_BnKXPointSign),a                 ; XX15+2
SetAndMopX:                             
        ld          (SS_BnKxlo),hl                       ; XX15+0
FinishedThisNodeX:

LL53:

        ldCopyByte  SS_BnKysgn,SS_BnKYPointSign           ; SS_BnKXSgn => XX15+2 x sign
        ld          bc,(SS_BnKXX12yLo)                   ; c = lo, b = sign   XX12XLoSign
        xor         b                                   ; a = SS_BnKKxsgn (or XX15+2) here and b = XX12xsign,  XX12+1 \ rotated xnode h                                                                             ;;;           a = a XOR XX12+1                              XCALC
        jp          m,NodeNegativeY                                                                                                                                                            ;;;           if sign is +ve                        ::LL52   XCALC
; XX15 [0,1] = INWK[0]+ XX12[0] + 256*INWK[1]                                                                                       ;;;          while any of x,y & z hi <> 0 
NodeXPositiveY:
        ld          a,c                                 ; We picked up XX12+0 above in bc Xlo
        ld          b,0                                 ; but only want to work on xlo                                                           ;;;              XX15xHiLo = XX12HiLo + xpos lo             XCALC
        ld          hl,(SS_BnKylo)                       ; hl = XX1 SS_BnKxLo
        ld          h,0                                 ; but we don;t want the sign
        add         hl,bc                               ; its a 16 bit add
        ld          (SS_BnKYPoint),hl                    ; And written to XX15 0,1 
        xor         a                                   ; we want to write 0 as sign bit (not in original code)
        ld          (SS_BnKXPointSign),a
        jp          FinishedThisNodeY
; If we get here then _sign and vertv_ have different signs so do subtract
NodeNegativeY:        
LL52Y:                                                 ;
        ld          hl,(SS_BnKylo)                       ; Coord
        ld          bc,(SS_BnKXX12yLo)                   ; XX12
        ld          b,0                                 ; XX12 lo byte only
        sbc         hl,bc                               ; hl = SS_BnKx - SS_BnKXX12xLo
        jp          p,SetAndMopY                       ; if result is positive skip to write back
NodeXNegSignChangeY:        
; If we get here the result is 2'c compliment so we reverse it and flip sign
        call        negate16hl                          ; Convert back to positive and flip sign
        ld          a,(SS_BnKYPointSign)                 ; XX15+2
        xor         $80                                 ; Flip bit 7
        ld          (SS_BnKYPointSign),a                 ; XX15+2
SetAndMopY:                             
        ld          (SS_BnKylo),hl                       ; XX15+0
FinishedThisNodeY:
    
    DISPLAY "Tracing 5", $

TransposeZ:
LL55:                                                   ; Both y signs arrive here, Onto z                                          ;;;
        ld          a,(SS_BnKXX12zSign)                   ; XX12+5    \ rotated znode hi                                              ;;;
        JumpOnBitSet a,7,NegativeNodeZ                    ; LL56 -ve Z node                                                           ;;;
        ld          a,(SS_BnKXX12zLo)                     ; XX12+4 \ rotated znode lo                                                 ;;;
        ld          hl,(SS_BnKzlo)                        ; INWK+6    \ zorg lo                                                       ;;;
        add         hl,a                                ; hl = INWKZ + XX12z                                                        ;;;
        ld          a,l
        ld          (varT),a                            ;                                                                           ;;;
        ld          a,h
        ld          (varU),a                            ; now z = hl or U(hi).T(lo)                                                 ;;;
        ret                                             ; LL57  \ Node additions done, z = U.T                                      ;;;
; Doing additions and scalings for each visible node around here                                                                    ;;;
NegativeNodeZ:
LL56:                                                   ; Enter XX12+5 -ve Z node case  from above                                  ;;;
        ld          hl,(SS_BnKzlo)                        ; INWK+6 \ z org lo                                                         ;;;
        ld          bc,(SS_BnKXX12zLo)                    ; XX12+4    \ rotated z node lo                                                 ......................................................
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
        ld          hl,SS_BnKXPointHi
        or          (hl)                                ; XX15+1    \ x hi
        ld          hl,SS_BnKYPointHi
        or          (hl)                                ; XX15+4    \ y hi
AreXYZHiAllZero:
        jr          z,NodeScalingDone                   ; if X, Y, Z = 0  exit loop down once hi U rolled to 0
DivideXYZBy2:
        ShiftMem16Right1    SS_BnKXPoint                  ; XX15[0,1]
        ShiftMem16Right1    SS_BnKYPoint                  ; XX15[3,4]
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
        ld          a,(SS_BnKXPointLo)                    ; XX15  \ rolled x lo
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
        ld          a,(SS_BnKXPointSign)                  ; XX15+2 \ sign of X dist
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
        ld          a,(SS_BnKYPointLo)                    ; XX15+3 \ rolled y low
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
        ld          a,(SS_BnKYPointSign)                  ; XX15+5 \ sign of X dist
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
        ldCopyByte  hl, SS_BnKXScaled                     ; Load into XX15                                                                     Byte 0;;;     XX15 xlo   = byte 0
        inc         hl
        ldCopyByte  hl, SS_BnKYScaled                     ; Load into XX15                                                                     Byte 0;;;     XX15 xlo   = byte 0
        inc         hl
        ldCopyByte  hl, SS_BnKZScaled                     ; Load into XX15                                                                     Byte 0;;;     XX15 xlo   = byte 0
        inc         hl
PopulateXX15SignBits: 
; Simplfied for debugging, needs optimising back to original DEBUG TODO
        ld          a,(hl)
        ld          c,a                                 ; copy sign and visibility to c
        ld          b,a
        and         $80                                 ; keep high 3 bits
        ld          (SS_BnKXScaledSign),a                 ; Copy Sign Bits                                                            ;;;     
        ld          a,b
        and         $40
        sla         a                                   ; Copy Sign Bits                                                            ;;;     
        ld          (SS_BnKYScaledSign),a                 ; Copy Sign Bits                                                            ;;;     
        ld          a,b
        and         $20
        sla         a                                   ; Copy Sign Bits                                                            ;;;     
        sla         a                                   ; Copy Sign Bits                                                            ;;;     
        ld          (SS_BnKZScaledSign),a                 ; Copy Sign Bits                                                            ;;;     
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
        ldHLIdxAToA SS_BnKFaceVisArray                    ; visibility at face 1                                                Byte 4;;;
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
        ldHLIdxAToA SS_BnKFaceVisArray                  ; visibility at face 1                                                Byte 5;;;
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
    ld          bc,(SS_BnKZScaled)                    ; BC = Z Cordinate. By here it MUST be positive as its clamped to 4 min
    ld          a,c                                 ;  so no need for a negative check
    ld          (varQ),a                            ; VarQ = z
    ld          a,(SS_BnKXScaled)                     ; XX15  \ rolled x lo which is signed
    call        DIV16Amul256dCUNDOC                 ; result in BC which is 16 bit TODO Move to 16 bit below not just C reg
    ld          a,(SS_BnKXScaledSign)                 ; XX15+2 \ sign of X dist
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
    ld          bc,(SS_BnKZScaled)                    ; Now process Y co-ordinate
    ld          a,c
    ld          (varQ),a
    ld          a,(SS_BnKYScaled)                     ; XX15  \ rolled x lo
    call        DIV16Amul256dCUNDOC                 ; a = Y scaled * 256 / zscaled
    ld          a,(SS_BnKYScaledSign)                 ; XX15+2 \ sign of X dist
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
                        ld      (SS_BnKXScaled),hl
                        ld      (SS_BnKYScaled),hl
                        ld      (SS_BnKZScaled),hl
                        xor     a
                        call    XX12EquNodeDotOrientation
                        call    TransposeXX12ByShipToXX15
                        call    ScaleNodeTo8Bit                     ; scale to 8 bit values, why don't we hold the magnitude here?x
                        ld      iy,SS_BnKNodeArray
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
                        ld      iy,SS_BnKNodeArray
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
                        ld      (SS_BnKLineArrayLen),a
                        call    CopyRotmatToTransMat ; CopyRotToTransMacro                      ;#01; Load to Rotation Matrix to XX16, 16th bit is sign bit
                        call    ScaleXX16Matrix197               ;#02; Normalise XX16
                        call    LoadCraftToCamera                ;#04; Load Ship Coords to XX18
                        call    InverseXX16                      ;#11; Invert rotation matrix
                        ld      hl,SS_BnKHullVerticies
                        ld      a,(VertexCtX6Addr)               ; get Hull byte#9 = number of vertices *6                                   ;;;
GetActualVertexCount:   ld      c,a                              ; XX20 also c = number of vertices * 6 (or XX20)
                        ld      c,a                              ; XX20 also c = number of vertices * 6 (or XX20)
                        ld      d,6
                        call    asm_div8                         ; asm_div8 C_Div_D - C is the numerator, D is the denominator, A is the remainder, B is 0, C is the result of C/D,D,E,H,L are not changed"
                        ld      b,c                              ; c = number of vertices
                        ld      iy,SS_BnKNodeArray
LL48:   
PointLoop:              push    bc                                  ; save counters
                        push    hl                                  ; save verticies list pointer
                        push    iy                                  ; save Screen plot array pointer
                        ld      a,b
                        ;break
                        call    CopyNodeToXX15                      ; copy verices at hl to xx15
                        ld      a,(SS_BnKXScaledSign)
                        call    XX12EquNodeDotOrientation
                        call    TransposeXX12ByShipToXX15
                        call    ScaleNodeTo8Bit                     ; scale to 8 bit values, why don't we hold the magnitude here?x
                        pop     iy                                  ; get back screen plot array pointer
                        call    ProjectNodeToEye                     ; set up screen plot list entry
   ; ld      hl,SS_BnKLineArrayLen
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
.IsItADot:              ld      a,(SS_BnKaiatkecm)
                        and     ShipIsVisible | ShipIsDot | ShipExploding  ; first off set if we can draw or need to update explosion
                        ret     z                           ; if none of these flags are set we can fast exit
                        JumpOnABitSet ShipExplodingBitNbr, .ExplodingCloud; we always do the cloud processing even if invisible
;............................................................  
.DetermineDrawType:     ReturnOnBitClear    a, ShipIsVisibleBitNbr          ; if its not visible exit early
                        JumpOnABitClear ShipIsDotBitNbr, .CarryOnWithDraw   ; if not dot do normal draw
;............................................................  
.itsJustADot:           call    ProcessDot
                        SetMemBitN  SS_BnKaiatkecm , ShipIsDotBitNbr ; set is a dot flag
                        ld      bc,(SS_BnKNodeArray)          ; if its at dot range get X
                        ld      de,(SS_BnKNodeArray+2)        ; and Y
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
.ExplodingCloud:        call    ProcessNodes
                        ClearMemBitN  SS_BnKaiatkecm, ShipKilledBitNbr ; acknowledge ship exploding
.UpdateCloudCounter:    ld      a,(SS_BnKCloudCounter)        ; counter += 4 until > 255
                        add     4                           ; we do this early as we now have logic for
                        jp      c,.FinishedExplosion        ; display or not later
                        ld      (SS_BnKCloudCounter),a        ; .
.SkipHiddenShip:        ReturnOnMemBitClear  SS_BnKaiatkecm , ShipIsVisibleBitNbr
.IsShipADot:            JumpOnABitSet ShipIsDotBitNbr, .itsJustADot ; if its dot distance then explosion is a dot, TODO later we will do as a coloured dot
.CalculateZ:            ld      hl,(SS_BnKzlo)                ; al = hl = z
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
.CalcCloudRadius:       ld      a,(SS_BnKCloudCounter)        ; de = cloud counter * 256
        IFDEF LOGMATHS
                        MMUSelectMathsTables
                        ld      b,h
                        call    AEquAmul256DivBLog
                        ld      d,a
                        MMUSelectROM0
        ELSE
                        ld      d,a                         ;
                        ld      e,0                         ;
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
                        ld      (SS_BnKCloudRadius),a         ; .
                        ld      ixh,a                       ; ixh = a = calculated cloud radius
.CalcSubParticleColour: ld      a,(SS_BnKCloudCounter)        ; colur fades away
                        swapnib                             ; divive by 16
                        and     $0F                         ; mask off upper bytes
                        sra     a                           ; divide by 32
                        ld      hl,DebrisColourTable
                        add     hl,a
                        ld      a,(hl)
                        ld      iyl,a                       ; iyl = pixel colours
.CalcSubParticleCount:  ld      a,(SS_BnKCloudCounter)        ; cloud counter = abs (cloud counter) in effect if > 127 then shrinks it
                        ABSa2c                              ; a = abs a
.ParticlePositive:      sra a                               ; iyh = (a /8) 
                        sra a                               ; .
                        sra a                               ; .
                        or  1                               ; bit 0 set so minimum 1
.DoneSubParticleCount:  ld      ixl,a                       ; ixl = nbr particles per vertex
.ForEachVertex:         ld      a,(VertexCountAddr)         ; load vertex count into b
                        ld      b,a                         ; .
                        ld      hl,SS_BnKNodeArray            ; hl = list of vertices
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
                        ld      a,(SS_BnKSlotNumber)          ; get slot number
                        call    ClearSlotA                  ; gauranted to be in main memory as non bankables
                        ClearMemBitN SS_BnKaiatkecm, ShipExplodingBitNbr
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


                        include ".\Universe\Macros\Actions.asm"
                        
                        GetExperiancePointsMacro    SS
                        KillShipMacro               SS
                        DamageShipMacro             SS

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
        ld          hl,SS_BnKNodeArray                    ; list of lines to read
        add         hl,a                                ; HL = address of GunVertexOnNodeArray
        ld          iyl,0
MoveX1PointToXX15:
        ld          c,(hl)                              ; 
        inc         hl
        ld          b,(hl)                              ; bc = x1 of gun vertex
        inc         hl
        ld          (SS_BnKX1),bc
        inc         c
        ret         z                                   ; was c 255?
        inc         b
        ret         z                                   ; was c 255?
MoveY1PointToXX15:
        ld          c,(hl)                              ; 
        inc         hl
        ld          b,(hl)                              ; bc = y1 of gun vertex
        inc         hl
        ld          (SS_BnKY1),bc
SetX2PointToXX15:
        ld          bc,0                                ; set X2 to 0
        ld          (SS_BnKX2),bc
        ld          a,(SS_BnKzlo)
        ld          c,a
SetY2PointToXX15:
        ld          (SS_BnKY2),bc                         ; set Y2to 0
        ld          a,(SS_BnKxsgn)
        JumpOnBitClear a,7,LL74SkipDec
LL74DecX2:
        ld          a,$FF
        ld          (SS_BnKX2Lo),a                        ; rather than dec (hl) just load with 255 as it will always be that at this code point
LL74SkipDec:        
        call        ClipLineV3                            ; LL145 \ clip test on XX15 XX12 vector, returns carry 
        jr          c,CalculateNewLines
;        jr          c,CalculateNewLines                 ; LL170 clip returned carry set so not visibile if carry set skip the rest (laser not firing)
; Here we are usign hl to replace VarU as index        
        ld          hl,(varU16)
        ld          a,(SS_BnKx1Lo)
        ld          (hl),a
        inc         hl
        ld          a,(SS_BnKy1Lo)
        ld          (hl),a
        inc         hl
        ld          a,(SS_BnKX2Lo)
        ld          (hl),a
        inc         hl
        ld          a,(SS_BnKy2Lo)
        ld          (hl),a
        inc         iyl                                 ; iyl holds as a counter to iterations
        inc         hl
        inc         iyl                                 ; ready for next byte
        ld          (varU16),hl
        ret

    DISPLAY "Tracing 7", $

    INCLUDE "Universe/Ships/PrepLines.asm"

    DISPLAY "Tracing XX", $

SS_BankSize  EQU $ - SS_StartOfUniv
