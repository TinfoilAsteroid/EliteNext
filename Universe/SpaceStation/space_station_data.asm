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
SS_StartOfUniv:         DB "Space Station..."
StartOfSpaceStationName DS 16
                    
; NOTE we can cheat and pre allocate segs just using a DS for now
                            UnivPosVarsMacro SS
                            UnivRotationVarsMacro SS
;   \ -> & 565D \ See ship data files chosen and loaded after flight code starts running.
; Universe map substibute for INWK
;-Camera Position of Ship----------------------------------------------------------------------------------------------------------
                            CoreRuntimeDataMacro    SS
; moved to runtime asm
;                        INCLUDE "./Universe/Ships/ShipPosVars.asm"
;                        INCLUDE "./Universe/Ships/RotationMatrixVars.asm"
 
; Orientation Matrix [nosev x y z ] nose vector ( forward) 19 to 26
;                    [roofv x y z ] roof vector (up)
;                    [sidev x y z ] side vector (right)
;;rotXCounter                 equ SS_BnkrotXCounter         ; INWK +29
;;rotZCounter                 equ SS_BnkrotZCounter         ; INWK +30SS_BnkDrawCam0xLo   DB  0               ; XX18+0
                      
                            XX16DefineMacro     SS
                            XX25DefineMacro     SS
                            XX18DefineMacro     SS

                            UnivCoreAIVarsMacro SS
                          
                            XX15DefineMacro     SS
                            XX12DefineMacro     SS

                            ClippingVarsMacro   SS

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
SS_Bnk_Data_len               EQU $ - SS_StartOfUniv


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
;-- Dom't need this?                        JumpOffSetMacro         SS
;-- Dont need this?                        WarpOffSetMacro         SS
                        
                        
; This version needs the planet data which is in the bank so needs a copy in common memory


; --------------------------------------------------------------                        
; update ship speed and pitch based on adjustments from AI Tactics
SS_UpdateSpeedAndPitch: ld      a,(SS_BnkAccel)                   ; only apply non zero accelleration
                        JumpIfAIsZero .SkipAccelleration
                        ld      b,a                             ; b = accelleration in 2's c
                        ld      a,(SS_BnkSpeed)                   ; a = speed + accelleration
                        ClearCarryFlag
                        adc     a,b
                        JumpIfPositive  .DoneAccelleration      ; if speed < 0 
.SpeedNegative:         ZeroA                                   ;    then speed = 0
.DoneAccelleration:     ld      b,a                             ; if speed > speed limit
                        ld      a,(SpeedAddr)                   ;    speed = limit
                        JumpIfAGTENusng b, .SpeedInLimits       ; .  
                        ld      b,a                             ; .
.SpeedInLimits:         ld      a,b                             ; .
                        ld      (SS_BnkSpeed),a                   ; .
                        ZeroA                                   ; acclleration = 0
                        ld      (SS_BnkAccel),a                   ; for next AI update
.SkipAccelleration:     ; handle roll and pitch rates                     
                        ret


; --------------------------------------------------------------
; this applies blast damage to ship
SS_MissileBlast:        ld      a,(CurrentMissileBlastDamage)
                        ld      b,a
                        ld      a,(SS_BnkEnergy)                   ; Reduce Energy
                        sub     b
                        jp      SS_ExplodeShip
                        jr      SS_ExplodeShip
                        ld      (SS_BnkEnergy),a
                        ret

                        ExplodeShipMacro    SS

; --------------------------------------------------------------
; This sets the position of the current space station, called after spawing
; needs to know planet position and algorthim for working out offset (could use system clock for orbits?)
SS_SpawnPosition:       call    InitialiseOrientation
                        RandomUnivPitchAndRoll
                        call    doRandom                        ; set x lo and y lo to random
.setXlo:                ld      (SS_Bnkxlo),a 
.setYlo:                ld      (SS_Bnkylo),a
.setXsign:              rrca                                    ; rotate by 1 bit right
                        ld      b,a
                        and     SignOnly8Bit
                        ld      (SS_Bnkxsgn),a
.setYSign:              ld      a,b                             ; get random back again
                        rrca                                    ; rotate by 1 bit right
                        ld      b,a
                        and     SignOnly8Bit                    ; and set y sign
                        ld      (SS_Bnkysgn),a
.setYHigh:              rrc     b                               ; as value is in b rotate again
                        ld      a,b                             ; 
                        and     31                              ; set y hi to random 0 to 31
                        ld      (SS_Bnkyhi),a                     ;
.setXHigh:              rrc     b                               ; as value is in b rotate again
                        ld      a,b
                        and     31                              ; set x hi to random 0 to 31
                        ld      c,a                             ; save shifted into c as well
                        ld      (SS_Bnkxhi),a
.setZHigh:              ld      a,80                            ; set z hi to 80 - xhi - yhi - carry
                        sbc     b
                        sbc     c
                        ld      (SS_Bnkzhi),a
.CheckIfBodyOrJunk:     ld      a,(SS_ShipTypeAddr)
                        ReturnIfAEqNusng ShipTypeJunk
                        ReturnIfAEqNusng ShipTypeScoopable
                        ld      a,b                             ; its not junk to set z sign
                        rrca                                    ; as it can jump in
                        and     SignOnly8Bit
                        ld      (SS_Bnkzsgn),a
                        ret
                        
; --------------------------------------------------------------                        
; This sets the cargo type or carryflag set for not cargo
; Later this will be done via a loadable lookup table
SS_CargoType:           ld      a,(SS_ShipTypeAddr)
.CargoCanister:         call    doRandom
                        and     15                      ; Limit stock from Food to Platinum
                        ret


; Space Station   = x y z of planet
;                 x = x + (seed.c & 3 (if a is even * -1 ) << 8
;                 y = y + (seed.c & 3 (if a is even * -1 ) << 8
;                 z = z + (seed.c & 3 (if a is even * -1 ) << 8
CalculateSpaceStationWarpPositon:
.CalcZPosition:         ld      a,(WorkingSeeds+1)      ; seed d & 7 
                        and     %00000111               ; .
                        add     a,7                     ; + 7
                        sra     a                       ; / 2
.SetZPosition:          ld      (SS_Bnkzsgn),a            ; << 16 (i.e. load into z sign byte
                        ld      hl, $0000               ; now set z hi and lo
                        ld      (SS_Bnkzlo),hl            ;
.CalcXandYPosition:     ld      a,(WorkingSeeds+5)      ; seed f & 3
                        and     %00000011               ; .
                        add     a,3                     ; + 3
                        ld      b,a
                        ld      a,(WorkingSeeds+4)      ; get low bit of seed e
                        and     %00000001
                        rra                             ; roll bit 0 into bit 7
                        or      b                       ; now calc is f & 3 * -1 if seed e is odd
.SetXandYPosition:      ld      (SS_Bnkxsgn),a            ; set into x and y sign byte
                        ld      (SS_Bnkysgn),a            ; .
                        ld      a,b                     ; we want just seed f & 3 here
                        ld      (SS_Bnkxhi),a             ; set into x and y high byte
                        ld      (SS_Bnkyhi),a             ; .
                        ZeroA
                        ld      (SS_Bnkxlo),a
                        ld      (SS_Bnkylo),a                        
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
                        ld      de,(SS_Bnkxhi)
                        ld      a,(SS_Bnkxsgn)
                        ld      l,a
                        MMUSelectMathsBankedFns
                        call    AddBCHtoDELsigned
                        ld      (SS_Bnkxhi),de
                        ld      a,l
                        ld      (SS_Bnkxsgn),a
.TransposeY:            pop     bc,,hl
                        push    bc,,hl
                        ld      de,(SS_Bnkyhi)
                        ld      a,(SS_Bnkysgn)
                        ld      l,a
                        call    AddBCHtoDELsigned
                        ld      (SS_Bnkyhi),de
                        ld      a,l
                        ld      (SS_Bnkysgn),a
.TransposeZ:            pop     bc,,hl
                        ld      de,(SS_Bnkzhi)
                        ld      a,(SS_Bnkzsgn)
                        ld      l,a
                        call    AddBCHtoDELsigned
                        ld      (SS_Bnkzhi),de
                        ld      a,l
                        ld      (SS_Bnkzsgn),a
                        ret
                        
CalculateSpaceStationLaunchPositon:
                        ld      hl,0
                        ZeroA
                        ld      (SS_Bnkxlo),hl
                        ld      (SS_Bnkxsgn),a
                        ld      (SS_Bnkylo),hl
                        ld      (SS_Bnkysgn),a
                        ld      hl,0
                        ld      a,$81
                        ld      (SS_Bnkzlo),hl
                        ld      (SS_Bnkxsgn),a
                        ret

; --------------------------------------------------------------
; generate space station type based on seed values
SelectSpaceStationType: ld      a,(DisplayEcononmy)
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
                                                
CreateSpaceStationLaunched: 
                        break
                        call    CreateSpaceStation              
                        DISPLAY "TODO: Now need to correct space station position"
                        DISPLAY "This shoudl be as per normal launch and planet shifts"
.SetPositionBehindUs:   ld      hl,$0000
                        ld      (SS_Bnkxlo),hl
                        ld      hl,$0000
                        ld      (SS_Bnkylo),hl
                        ld      hl,$01B0                            ; so its a negative distance behind
                        ld      (SS_Bnkzlo),hl
                        xor     a
                        ld      (SS_Bnkxsgn),a
                        ld      (SS_Bnkysgn),a
                        ld      a,$80
                        ld      (SS_Bnkzsgn),a
                        DISPLAY "TODO: This needs to feedback to ParentPLanet to adjust position"
                        ret


CopyPlanetGlobaltoSpaceStation:
                        ld      hl,ParentPlanetX
                        ld      de,SS_Bnkxlo
                        ld      bc,3*3
                        ldir
                        ret
; --------------------------------------------------------------                        
; This sets current univrse object to space station
CreateSpaceStation:     call    SelectSpaceStationType          ; a= station type
.GetModelBank.          ld      iyl,a                               ; iyl = station type
                        MMUSelectShipBank1
                        ld      a,iyl                               ; a = station type
.CopyOverShipData:      call    GetShipBankId
                        MMUSelectShipBankA                          
                        ld      a,b                                 ;
                        break
                        call    CopyShipToSpaceStation
.CalculatePosition:     call    CalculateSpaceStationWarpPositon
.BlockSlotNumber:       and     a,$FF
                        ld      (SS_BnkSlotNumber),a
.SetAI:                 ld  a,%10000001                         ; Has AI and 1 Missile
                        ld  (SS_Bnkaiatkecm),a                    ; set hostinle, no AI, has ECM
                        xor a
.SetRollCounters:       ld      (SS_BnkRotZCounter),a             ; no pitch
                        ld      (ShipNewBitsAddr),a             ; initialise new bits logic
                        ld      a,$FF
                        ld      (SS_BnkRotXCounter),a             ; set roll to maxi on station
.LoadPosToGlobalVars:   call    CopyPlanetGlobaltoSpaceStation      ;
                        DISPLAY "TODO: Adjust space station offset from Planet when entering system"
;  sidev = (1,  0,  0)  sidev = (&6000, 0, 0)
;  roofv = (0,  1,  0)  roofv = (0, &6000, 0)
;  nosev = (-0,  -0, 1) nosev = (0, 0, &6000)
.InitialiseOrientation: ld      hl, 0
                        ld      (SS_BnkrotmatSidevY),hl                ; set the zeroes
                        ld      (SS_BnkrotmatSidevZ),hl                ; set the zeroes
                        ld      (SS_BnkrotmatRoofvX),hl                ; set the zeroes
                        ld      (SS_BnkrotmatRoofvZ),hl                ; set the zeroes
                        ld      (SS_BnkrotmatNosevX),hl                ; set the zeroes
                        ld      (SS_BnkrotmatNosevY),hl                ; set the zeroes
; Optimised as already have 0 in l
                        ld      h, $60	             				; 96 in hi byte
                        ;ld      hl,1
                        ld      (SS_BnkrotmatSidevX),hl
                        ld      (SS_BnkrotmatRoofvY),hl
; Optimised as already have 0 in l
                        ld      h, $E0					            ; -96 in hi byte which is +96 with hl bit 7 set
                        ld      (SS_BnkrotmatNosevZ),hl
                        ld      hl,$6000
                        ld      (SS_BnkrotmatNosevZ),hl           ; mius
.SetOrientation:        FlipSignMem SS_BnkrotmatNosevX+1;  as its 0 flipping will make no difference
                        FlipSignMem SS_BnkrotmatNosevY+1;  as its 0 flipping will make no difference
                        FlipSignMem SS_BnkrotmatNosevZ+1
                        ret


SS_FighterTypeMapping:  DB ShipID_Worm, ShipID_Sidewinder, ShipID_Viper, ShipID_Thargon

; Initialiase data, iyh must equal slot number
;                   iyl must be ship type
;                   a  = current bank number
SS_InitRuntime:         ld      bc,SS_BnkRuntimeSize        ; Clear Runtime data
                        ld      hl,SS_BnkStartOfRuntimeData ; .
                        ZeroA                               ; .
                        ld      (SS_BnkECMCountDown),a      ; .
.InitLoop:              ld      (hl),a                      ; .
                        inc     hl                          ; .
                        djnz    .InitLoop                   ; .
.SetEnergy:             ldCopyByte SS_EnergyAddr, SS_BnkEnergy
.SetBankData:           ; N.A for SpaceStation ld      a,0                         ; we use slot 0 as non ship slot
                        ; N.A for SpaceStation ld      (SS_BnkSlotNumber),a
                        ; N.A for SpaceStation add     a,BankUNIVDATA0
                        ; N.A for SpaceStation ld      (SS_BnkShipUnivBankNbr),a
                        ; N.A for SpaceStation ld      a,iyl
                        ld      (SS_BnkShipModelId),a
                        call    GetShipBankId                ; this will mostly be debugging info
                        ld      (SS_BnkShipModelBank),a        ; this will mostly be debugging info
                        ld      a,b                          ; this will mostly be debugging info
                        ld      (SS_BnkShipModelNbr),a         ; this will mostly be debugging info
.SetUpMissileCount:     ld      a,(LaserAddr)                ; get laser and missile details
                        and     ShipMissileCount
                        ld      c,a
                        ld      a,(RandomSeed1)              ; missile flag limit
                        and     c                            ; .
                        ld      (SS_BnkMissilesLeft),a
.SetupLaserType         ld      a,(LaserAddr)
                        and     ShipLaserPower
                        swapnib
                        ld      (SS_BnkLaserPower),a
.SetUpFighterBays:      ld      a,(ShipAIFlagsAddr)
                        ld      c,a
                        and     ShipFighterBaySize
                        JumpIfANENusng ShipFighterBaySizeInf, .LimitedBay
                        ld      a,$FF                       ; force unlimited ships
.LimitedBay:            swapnib                             ; as its bits 6 to 4 and we have removed bit 7 we can cheat with a swapnib
                        ld      (SS_BnkFightersLeft),a
.SetUpFighterType:      ld      a,c                         ; get back AI flags
                        and     ShipFighterType             ; fighter type is bits 2 and 3
                        rr      a                           ; so get them down to 0 and 1
                        rr      a                           ;
                        ld      hl,FighterTypeMapping       ; then use the lookup table
                        add     hl,a                        ; for the respective ship id
                        ld      a,(hl)                      ; we work on this for optimisation
                        ld      (SS_BnkFighterShipId),a       ; ship data holds index to this table
.SetUpECM:              ld      a,(ShipECMFittedChanceAddr) ; Now handle ECM
                        ld      b,a
.FetchLatestRandom:     ld      a,(RandomSeed3)              
                        JumpIfALTNusng b, .ECMFitted
.ECMNotFitted:          SetMemFalse SS_BnkECMFitted
                        jp      .DoneECM
.ECMFitted:             SetMemTrue  SS_BnkECMFitted
.DoneECM:               ; TODO set up laser power
                        ret
    DISPLAY "Tracing 2", $
    
                        InitialiseOrientationMacro      SS
                        InitialisePlayerMissileOrientationMacro SS
                        LaunchedOrientationMacro        SS
    DISPLAY "Need to re label CLip LL45 for space station"
;                        include "./ModelRender/CLIP-LL145.asm"
;--------------------------------------------------------------------------------------------------------

                        
                        ScaleXX16Matrix197Macro         SS

                        ScaleNormalMacro                SS
                        
                        LoadCraftToCameraMacro          SS
                        
                        CopyCameraToXX15SignedMacro     SS
                        
                        ; already in XX12 macros XX12EquNodeDotXX16Macro         SS
                        
                        CopyRotmatToTransMatMacro       SS
                        
                        ScaleDrawcamMacro               SS
                        
                        CheckVisibleMacro               SS
                        
                        CullV2Macro                     SS
                        
                        ScaleNodeTo8BitMacro            SS
;--------------------------------------------------------------------------------------------------------
                        SetFaceAVisibleMacro            SS
;--------------------------------------------------------------------------------------------------------
                        SetFaceAHiddenMacro             SS
;--------------------------------------------------------------------------------------------------------
                        SetAllFacesVisibleMacro         SS
;--------------------------------------------------------------------------------------------------------
                        SetAllFacesHiddenMacro          SS
;--------------------------------------------------------------------------------------------------------
                        Norm256mulAdivQMacro            SS
;--------------------------------------------------------------------------------------------------------
                        NormaliseTransMatMacro          SS
;-LL91---------------------------------------------------------------------------------------------------
                        InverseXX16Macro                SS
;--------------------------------------------------------------------------------------------------------
                        XX12DotOneRowMacro              SS
;--------------------------------------------------------------------------------------------------------                       
                        XX12EquXX15DotProductXX16Macro  SS
;--------------------------------------------------------------------------------------------------------
                        CopyXX12ScaledToXX18Macro       SS
;--------------------------------------------------------------------------------------------------------
                        CopyXX12toXX15Macro             SS
;--------------------------------------------------------------------------------------------------------
                        CopyXX18toXX15Macro             SS
;--------------------------------------------------------------------------------------------------------
                        CopyXX12ToScaledMacro           SS
;--------------------------------------------------------------------------------------------------------
                        DotProductXX12XX15Macro         SS
;--------------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------
; scale Normal. IXL is xReg and A is loaded with XX17 holds the scale factor to apply
; Not Used in code      include "Universe/Ships/ScaleNormal.asm"
;--------------------------------------------------------------------------------------------------------
                        ScaleObjectDistanceMacro        SS
;--------------------------------------------------------------------------------------------------------
                        CopyFaceToXX15Macro             SS                        
;--------------------------------------------------------------------------------------------------------
                        CopyFaceToXX12Macro             SS
;--------------------------------------------------------------
; line of sight (eye outwards dot face normal vector < 0
; So lin eof sight = vector from 0,0,0 to ship pos, now we need to consider teh ship's facing
; now if we add teh veector for teh normal(times magnitude)) to teh ship position we have the true center of the face
; now we can calcualt teh dot product of this caulated vector and teh normal which if < 0 is goot. this means we use rot mat not inverted rotmat.
;--LL52 to LL55-----------------------------------------------------------------------------------------------------------------                    
                        TransposeXX12NodeToXX15Macro    SS
                        TransposeXX12ByShipToXX15Macro  SS
                        
                        XX12NodeDotOrientationMacro     SS
;--LL49-------------------------------------------------------------------------------------------------------------------------                    
;--------------------------------------------------------------------------------------------------------
                        CopyNodeToXX15Macro             SS

;;;     Byte 4 = High 4 bits Face 2 Index Low 4 bits = Face 1 Index
;;;     Byte 5 = High 4 bits Face 4 Index Low 4 bits = Face 3 Index
;..............................................................................................................................
; Start loop on Nodes for visibility, each node has 4 faces associated with ;;; For each node (point) in model                  ::LL48 
                        INCLUDE "./Universe/UniverseMacros/ProcessNodesMacro.asm"
                    
                        ProcessVisibleNodeMacro         SS

                        ProcessANodemacro               SS

                        ProcessDotMacro                 SS
                        
                        ProcessNodesMacro               SS

                        ProcessShipMacro                SS
                        
                        HLEquARandCloudMacro            SS

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
            INCLUDE "./Universe/UniverseMacros/ApplyMyRollAndPitchMacro.asm"
                        ApplyMyRollAndPitchMacro        SS
; ---------------------------------------------------------------------------------------------------------------------------------    
            INCLUDE "./Universe/UniverseMacros/ApplyShipRollAndPitchMacros.asm"
                        ApplyShipRollAndPitchMacro      SS
; ------------------------------------------------------------------------------------ss---------------------------------------------    
            INCLUDE "./Universe/UniverseMacros/ApplyShipSpeedMacro.asm"
                        ApplyShipSpeedMacro             SS
; ---------------------------------------------------------------------------------------------------------------------------------    
                        
;            INCLUDE "./ModelRender/DrawLines.asm"
; ---------------------------------------------------------------------------------------------------------------------------------    
; .....................................................
; Process Nodes does the following:
; for each node:
;     see if node > 
SS_NXX20DIV6          DB      0
SS_NVERTEXPTR         DW      0   ; DEBUG WILL USE LATER
SS_NNODEPRT           DW      0   ; DEBUG WILL USE LATER
SS_NLASTNORM          DB      0
                        
                   ; set flags and signal to remove from slot list        

; Hl = HlL +/- (Random * projected cloud size)
; In - d = z distance, hl = vert hi lo
; Out hl = adjusted distance
; uses registers hl, de

                        include "./Universe/UniverseMacros/Actions.asm"
                        
                        DISPLAY "TODO: GetExperiancePointsMacro    SS"
                        DISPLAY "TODO: KillShipMacro               SS"
                        DISPLAY "TODO: DamageShipMacro             SS"

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

    DISPLAY "Tracing 7", $

                        getVertexNodeAtAToDEMacro       SS
                        GetFaceAtAMacro                 SS
                        PrepLinesMacro                  SS
                        DrawLinesLateClippingMacro      SS
                        
SpaceStationUpdateAndRender: 
                        call    SS_ApplyMyRollAndPitch
                        call    SS_ApplyShipRollAndPitch
                        call    SS_ProcessShip
                        ret

                        ; set flags and signal to remove from slot list        

; Hl = HlL +/- (Random * projected cloud size)
; In - d = z distance, hl = vert hi lo
; Out hl = adjusted distance
; uses registers hl, de




    DISPLAY "Tracing XX", $

SS_BankSize  EQU $ - SS_StartOfUniv
