 ;                       DEFINE DEBUGFORCEHOSTILE 1

NewLaunchUBnKX          DS 3
NewLaunchUBnKY          DS 3
NewLaunchUBnKZ          DS 3

NewLaunchMatrix         DS 3*3*2    ; 3x3 matrix of 3 bytes
NewLaunchSpeed          DS 1
NewLaunchRotX           DS 1
NewLaunchRotZ           DS 1

NewLaunchDataBlockSize  equ (3*3) + (3*3*2)
; ---------------------------------------------------------------------------------------------------------------------------------    
; a = y offset negative from center of ship
CalcLaunchOffset:       ld      hl,UBnKxlo
                        ld      de,NewLaunchUBnKX
                        ld      bc,NewLaunchDataBlockSize
                        ldir
.ApplyOffset:           sla     a
                        sla     a
                        ld      iyl,a                          ; save pre calculated speed
.ApplyToX:              SpeedMulAxis    a, UBnkrotmatRoofvX     ; e =  ABS (nosev x hi) c = sign
                        ld      a,b
                        xor     $80
                        ld      b,a
.AddSpeedToX:           AddSpeedToVert  NewLaunchUBnKX          ; 24 bit maths
.ApplyToY:              SpeedMulAxis    iyl, UBnkrotmatRoofvY     
                        ld      a,b
                        xor     $80
                        ld      b,a
.AddSpeedToY:           AddSpeedToVert NewLaunchUBnKY           ; 24 bit maths
.ApplyToZ:              SpeedMulAxis    iyl, UBnkrotmatRoofvZ
                        ld      a,b
                        xor     $80
                        ld      b,a
.AddSpeedToZ:           AddSpeedToVert NewLaunchUBnKZ           ; 24 bit maths
                        ret

                        
                        
                        ;DEFINE MISSILEBREAK
;.. Thsi version uses new kind logic
;... Now the tactics if current ship is the missile, when we enter this SelectedUniverseSlot holds slot of missile
NormalAI:               IsAIEnabled                             ; check if AI is enabled for ship (say if its had a shut down event it may be disabled)
                        ret     z                               ; if z is set then bit was clear so return
.GetEnergy:             call    RechargeEnergy                  ; TA13 if enegery <= maxumum value for blueprint then recharge energy by 1
                        IsShipTrader
                        jr      nz, .NotATrader
.ItsATrader:            call    doRandom                        
                        ReturnIfALTNusng 100                    ; 61% chance do nothing
                        IFDEF DEBUGFORCEHOSTILE
                                call SetShipHostile
                                ld      a,(ShipNewBitsAddr)
                                or      ShipIsBountyHunter
                                ld      (ShipNewBitsAddr),a
                        ENDIF
.NotATrader:
.IsItBountyHunter:      ld      a,(ShipNewBitsAddr)
                        and     ShipIsBountyHunter
                        jr      nz, .NotBountyHunter
.CheckFIST:             CallIfMemGTENusng FugitiveInnocentStatus, 40, SetShipHostile ; if our FIST rating >= 40 set ship hostile (bit 2)
.NotBountyHunter:
.CheckHostile:          IsShipHostile                           ; if ship is hostile z flag becomes nz
                        jr      nz,.ItsHostile                  ; .
;.. If we get here its not hostile so will be heading towards planet or sun
;.. If its locked on to a target (sun or planet) then it will proceed towards that,
;.. if it reaches the sun it will jump
;.. If it reaaches the planet it will then move to docking phase
.ItsNotHostile:         IsShipDocking                           ; if docking then do dockign algorithm
                        jp      nz, UnivDocking
.NotDocking:            jp      ShipHeadingToUnivBody
                        ; ret   Above jumps both include implicit returns
                        
.ItsHostile:            ld      a,(ShipNewBitsAddr)
.IsItPirate:            and     ShipIsPirate
                        jr      nz,.NotAPirate
.IsItInSafeZone:        ;      if we are not in space station safe zone
.InSafeZone:            ld      a,(ShipNewBitsAddr)
                        or      Bit7Only | ShipIsTrader
.NotSafeZone:           call    SetPlayerAsTarget
                        call    CopyPosToVector
                        MMUSelectMathsBankedFns
                        call    NormalizeTactics
.NotAPirate:
.SpawnFighter:          ld      a,(UBnKFightersLeft)
                        and     a
                        jr      z,.NoFighters
.CanSpawnFighter:       call    doRandom
                        JumpIfALTNusng 200, .NoFighters
                        ;break
                        ;SPAWN FIGHTER of Type UBnKFighterShipId at Y - 20 z - 20
                        ld      hl,UBnKFightersLeft             ;reduced figters left
                        dec     (hl)
                        ;inherits parent's ai angry
.NoFighters:            ld      a,(RandomSeed3)                 ;if random >= 250
                        or      104                             ;set a noticable roll
.CheckEnergyLevels:     ld      a,(EnergyAddr)
                        ld      b,a
                        ld      a,(UBnKEnergy)
                        srl     b                               ; max energy / 2
                        JumpIfAGTENusng b,.EnergyOverHalf       ; if ship max energy / 2 < current enerhy
                        srl     b
                        JumpIfAGTENusng b,.EnergyOverQuater     ; if ship max enery / 4 < current energy
                        ld      a,(ShipNewBitsAddr)
                        and     ShipHasEscapePod
                        jr      z, .NoEscapePod
                        ld      a,(RandomSeed2)
                        JumpIfALTNusng 230,.NoEscapePod         ;if random >= 230 
                        call    UnivClearAI                     ;  disable ship AI hostily and ECM
                        ;ZeroA                                   ;  .
                        ld      (UBnKECMFitted),a               ;  .
.LaunchEscapePod:       ;break                        
                        ;            goto spawn escape pod
.EnergyOverHalf:
.EnergyOverQuater:
.NoEscapePod:           ld      a,(UBnKMissilesLeft)            ;      if missiles > 0
                        ld      b,a
                        JumpIfAIsZero .NoMissileLaunch
.MissileLaunchTest:     ld      a,(RandomSeed3)                 ;         if random and 15 > = nbr missiles
                        and     15
                        JumpIfALTNusng b, .NoMissileLaunch
                        ld      a,(ECMCountDown)
                        JumpIfAIsNotZero  .NoMissileLaunch
                        jp    LaunchEnemyMissile                ; jump out and return if firing missile
.NoMissileLaunch:       ld      a,(UBnKxhi)
                        ld      hl,(UBnKyhi)
                        or      (hl)
                        ld      hl,(UBnKzhi)
                        or      (hl)
                        JumpIfAGTENusng 160, .TooFarForLaser   ; if in laser range (all highs order together < 160)
                        call    XX12EquTacticsDotNosev
                        ld      b,a
                        ld      a,(varS)
                        JumpIfAIsNotZero .TooFarForLaser        ;   if dot product of ship < 160 i.e. > -32
                        ld      a,b                            ;    .
                        JumpIfALTNusng    32, .DoneLaserShot  ;    .
.FireLaser:             ;break                        ;      do fire laser logic (drain energy, add beam to lines as random line from ship to a random edge of screen)
                        ld      a,b ;; need to see if b gets corrupted by laser fire
                        JumpIfAEqNusng      35, .LaserHitPlayer
                        JumpIfAEqNusng      36, .LaserHitPlayer
.LaserMissedPlayer:     jp      .DoneLaserShot
.LaserHitPlayer:        ;break ;         do direct hit logic
.DoneLaserShot:         ld      hl,UBnKAccel                   ;      Half attacking ship's accelleration in byte 28 (dec so must be 0 1 or 2)
                        sla     (hl)
.TooFarForLaser:
.UpdateShip             ;break
                        call    CalculateAgression              ; refresh aggression levels
                        ld      a,(UBnKzhi)
                        JumpIfAGTENusng 3, .ShipFarAway
                        ld      a,(UBnKxhi)
                        ld      hl,(UBnKyhi)
                        or      (hl)
                        and     %11111110
                        jr      z,.ShipTurnAway
.ShipFarAway:           ld      a,(RandomSeed2)                     ; if random with bit 7 set < ship AI byte 32 flag
                        ;or      %10000000               ; .
                        JumpIfAGTEMemusng UBnKShipAggression, .ShipTurnAway
                        FlipSignMem TacticsVectorX+2                ; negate vector in XX15 so it points opposite direction
                        FlipSignMem TacticsVectorY+2                ; we have already negated the dot product above
                        FlipSignMem TacticsVectorZ+2                ; .                         
                        call    ShipSeekingLogic            ;    seek as per missile
                        ret
.ShipTurnAway:          call    ShipSeekingLogic            ; move away (ie.. as per missile but dot products not reversed)
                        ;              consider a random roll
                        ret

ShipSeekingLogic:       call    XX12EquTacticsDotNosev              ; SA = nose . XX15                           (     ->TAS3)
                        ld      (TacticsDotProduct1),a              ; CNT = A (high byte of dot product)
                        ld      a,(varS)                            ; get sign from dot product
                        ld      (TacticsDotProduct2+1),a            ; Note here its direction not dir
.RoofDotProduct:        call    XX12EquTacticsDotRoofv              ; Now tran the roof for rotation        
                        ld      (TacticsDotProduct2),a              ; so if its +ve then the roof is similar so pull up to head towards it
                        ld      a,(varS)                            ; .                                       
                        ld      (TacticsDotProduct2+1),a            ; Note here its direction not dir
                        call    ShipPitchv3
                        call    ShipRollv3
                        call    ShipSpeedv3
                        ret

ShipPitchv3:            ld      hl,(TacticsDotProduct2)            ; pitch counter sign = opposite sign to roofdir sign
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
                        IFDEF MISSILEDEBUG
                            ld  (TacticsRotZ),a
                        ENDIF
                        ret
.skipPitchZero:         ld      a,2
                        or      h
                        ld      (UBnKRotZCounter),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsRotZ),a
                        ENDIF
                        ret
                        
ShipRollv3:             call    XX12EquTacticsDotSidev             ; calculate side dot protuct
                        ld      (TacticsDotProduct3),a             ; .
                        ld      l,a                                ; .
                        ld      a,(varS)                           ; .
                        ld      (TacticsDotProduct3+1),a           ; .
                        ld      h,a                                ; h = sign sidev
                        ld      a,(TacticsDotProduct2+1)           ; get flipped pitch counter sign
                        ld      b,a                                ; b = roof product
                        ld      a,l                                ; a = abs sidev  * 2
                        sla     a                                  ;
                        JumpIfAGTENusng 16,.skipRollZero           ;
                        ZeroA                                      ; if its zoer then set rotx to zero
                        or      b
                        ld      (UBnKRotXCounter),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsRotX),a
                        ENDIF
                        ret
.skipRollZero:          ld      a,2
                        or      h
                        xor     b
                        ld      (UBnKRotXCounter),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsRotX),a
                        ENDIF
                        ret

ShipSpeedv3:            ld      hl,(TacticsDotProduct1)
                        ld      a,h
                        and     a
                        jr      nz,.SlowDown
                        ld      de,(TacticsDotProduct2)             ; dot product is +ve so heading at each other
                        ld      a,l 
                        JumpIfALTNusng  22,.SlowDown                                  ; nose dot product < 
.Accelerate:            ld      a,3                                 ; else
                        ld      (UBnKAccel),a                       ;  accelleration = 3
                        IFDEF MISSILEDEBUG
                            ld  (TacticsSpeed),a
                        ENDIF                        
                        ret                                         ;  .
.SlowDown:              JumpIfALTNusng 18, .NoSpeedChange
.Deccelerate:           ld      a,-1
                        ld      (UBnKAccel),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsSpeed),a
                        ENDIF
                        ret
.NoSpeedChange:         ZeroA                                       ; else no change
                        ld      (UBnKAccel),a
                        IFDEF MISSILEDEBUG
                            ld  (TacticsSpeed),a
                        ENDIF
                        ret
                        
;-------------------------------------------------------------------
; randomly set tactics to fly towards sun or planet                 
; updates UBnKHeadingToPlanetOrSun, 1 = planet, 2 = Sun
SetTargetBody:          call    doRandom                            ; random number
                        and     $01                                 ; if bit 1 is set then we can load that to planet and exit
                        jp      nz,.SelectPlanet
.SelectSun:             ld      a,2                                 ; else set it to 2 and mark as Sun
                        ld      (UBnKHeadingToPlanetOrSun),a
                        ret
.SelectPlanet:          ld      (UBnKHeadingToPlanetOrSun),a
                        ret
                        
;-------------------------------------------------------------------
; Sort out target heading for ship
; if its 0 then randomly select sun or planet
; after this work otu target position and course changes requried                        
ShipHeadingToUnivBody:  ld      a,(UBnKHeadingToPlanetOrSun)        ; do we have a preference?
                        and     a
                        call    z,SetTargetBody                     ; no preference so we head randomly towards sun or planet then fall into movement tactics code
                        cp      1
                        jp      nz, UpdateSunTracking               ; if its not 1 then must be sun
;.. Update tracking to planet.......................................
            DISPLAY "TODO: Change this from move to planet to move to station as moving to planet is now superfluous"
UpdatePlanetTracking:   call    SaveMMU6                            ; save current ship     
                        MMUSelectPlanet
                            DISPLAY "TODO: Sort out targeting station not planet" 
                        call    CopyPlanettoGeneral                 ; get planet position
                        call    RestoreMMU6                         ; get current Universe Object back
                        ld      iy,PlanetXPos
                        call    VectorUnivtoIY                      ; get Univ Target vector to planet - ship position
;.. Get distance ...................................................
                        call    UnivDistanceToTarget                ; Determine if ship is in safe zone of planet, 
                        jp      c,.MoveToDockingPhase               ; if close enough to planet move to docking phase
                        MMUSelectMathsBankedFns
                        call    NormalseUnivTarget                  ; now in the target normalise it to work out direction
.NegateDirection:       FlipSignMem UBnKTargetXPosSgn                ; negate vector so it points opposite direction
                        FlipSignMem UBnKTargetXPosSgn                ; we have already negated the dot product above
                        FlipSignMem UBnKTargetXPosSgn                ; .                         
                        jp      UnivSeekingLogic                     ; 
                        ; implicit ret
;.. If we are close enough moce to docking phase
.MoveToDockingPhase:    DISPLAY "TODO: Add in transitiion to docking phase"
                        ret

                         DISPLAY "TODO: Sort out random directio etc if needed" 
;.. Close enough to start docking ..................................


UpdateSunTracking:      call    SaveMMU6
                        MMUSelectSun
                        call    CopySuntoGeneral                    ; get sun position
                        call    RestoreMMU6                         ; get current Universe Object back
                        ld      iy,SunXPos
                        call    VectorUnivtoIY                      ; get Univ Target vector to planet - ship position
                        call    UnivDistanceToTarget                ; Determine if ship is in safe zone of planet, 
                        jp      c,UnivMoveToJump                    ; if close enough to sun then jump (i.e. destrouy object but use flash of light)
                        MMUSelectMathsBankedFns
                        call    NormalseUnivTarget                  ; now in teh target normalise it to work out direction
.NegateDirection:       FlipSignMem UBnKTargetXPosSgn                ; negate vector so it points opposite direction
                        FlipSignMem UBnKTargetXPosSgn                ; we have already negated the dot product above
                        FlipSignMem UBnKTargetXPosSgn                ; .                         
                        jp      UnivSeekingLogic                     ; 
                        ret
                        
                            DISPLAY "TODO: Sort out docking" 
UnivDocking:            ret

UnivMoveToJump:         DISPLAY "TODO: Add flash of light jump logic into ships. similar to explosion but just a star of random lines and no kill score"
                        ret

UnivSeekingLogic:       call    TacticsDotNosev                     ; TacticsVarResult = nose . Target Vector                           (     ->TAS3)
                        ld      ( UBnKTargetDotProduct1),a              ; CNT = A (high byte of dot product)
                        ld      a,(varS)                            ; get sign from dot product
                        ld      ( UBnKTargetDotProduct2+1),a            ; Note here its direction not dir
.RoofDotProduct:        call    XX12EquTacticsDotRoofv              ; Now tran the roof for rotation        
                        ld      (TacticsDotProduct2),a              ; so if its +ve then the roof is similar so pull up to head towards it
                        ld      a,(varS)                            ; .                                       
                        ld      ( UBnKTargetDotProduct2+1),a            ; Note here its direction not dir
;.. Update facing and speed ........................................
                        call    UnivPitchToTarget
                        call    UnivRollToTarget
                        call    UnivSpeedToTarget
                        ret                       

                        
;;;ShipPitchv2:  ;break
;;;                        ld      hl,(TacticsDotProduct2)            ; pitch counter sign = opposite sign to roofdir sign
;;;                        ld      a,h                                ; .
;;;                        xor     $80                                ; .
;;;                        and     $80                                ; .
;;;                        ld      h,a                                ; h  = flipped sign
;;;                        ld      a,l                                ; a = value * 2
;;;                        sla     a                                  ; 
;;;                        JumpIfAGTENusng 16, .skipPitchZero         ; if its > 16 then update pitch
;;;                        ZeroA                                      ; else we zero pitch but
;;;                        or      h                                  ; we need to retain the sign
;;;                        ld      (UBnKRotZCounter),a                ; .
;;;                        IFDEF MISSILEDEBUG
;;;                            ld  (TacticsRotZ),a
;;;                        ENDIF
;;;                        ret
;;;.skipPitchZero:         ld      a,3
;;;                        or      h
;;;                        ld      (UBnKRotZCounter),a
;;;                        IFDEF MISSILEDEBUG
;;;                            ld  (TacticsRotZ),a
;;;                        ENDIF
;;;                        ret
                        
                        
;;;ShipRollv2:             ld      a,(UBnKRotXCounter)
;;;                        and     $7F
;;;                        cp      16
;;;                        ret     z
;;;                        call    XX12EquTacticsDotSidev             ; calculate side dot protuct
;;;                        ld      (TacticsDotProduct3),a             ; .
;;;                        ld      l,a                                ; .
;;;                        ld      a,(varS)                           ; .
;;;                        ld      (TacticsDotProduct3+1),a           ; .
;;;                        ld      h,a                                ; h = sign sidev
;;;                        ld      a,(TacticsDotProduct2+1)           ; get flipped pitch counter sign
;;;                        ld      b,a                                ; b = roof product
;;;                        ld      a,l                                ; a = abs sidev  * 2
;;;                        sla     a                                  ;
;;;                        JumpIfAGTENusng 16,.skipRollZero           ;
;;;                        ZeroA                                      ; if its zoer then set rotx to zero
;;;                        or      b
;;;                        ld      (UBnKRotXCounter),a
;;;                        IFDEF MISSILEDEBUG
;;;                            ld  (TacticsRotX),a
;;;                        ENDIF
;;;                        ret
;;;.skipRollZero:          ld      a,3
;;;                        or      h
;;;                        xor     b
;;;                        ld      (UBnKRotXCounter),a
;;;                        IFDEF MISSILEDEBUG
;;;                            ld  (TacticsRotX),a
;;;                        ENDIF
;;;                        ret
;;;
;;;ShipSpeedv2:            ld      hl,(TacticsDotProduct1)
;;;                        ld      a,h
;;;                        and     a
;;;                        jr      nz,.SlowDown
;;;                        ld      de,(TacticsDotProduct2)             ; dot product is +ve so heading at each other
;;;                        ld      a,l 
;;;                        JumpIfALTNusng  22,.SlowDown                                  ; nose dot product < 
;;;.Accelerate:            ld      a,2                                 ; else
;;;                        ld      (UBnKAccel),a                       ;  accelleration = 3
;;;                        IFDEF MISSILEDEBUG
;;;                            ld  (TacticsSpeed),a
;;;                        ENDIF                        
;;;                        ret                                         ;  .
;;;.SlowDown:              JumpIfALTNusng 18, .NoSpeedChange
;;;.Deccelerate:           ld      a,-1
;;;                        ld      (UBnKAccel),a
;;;                        IFDEF MISSILEDEBUG
;;;                            ld  (TacticsSpeed),a
;;;                        ENDIF
;;;                        ret
;;;.NoSpeedChange:         ZeroA                                       ; else no change
;;;                        ld      (UBnKAccel),a
;;;                        IFDEF MISSILEDEBUG
;;;                            ld  (TacticsSpeed),a
;;;                        ENDIF
;;;                        ret
;;;
;;;
;;;
;;;RAT2 equ    4           ; roll pitch threshold
;;;RAT  equ    3           ; magnitude of counter
;;;CNT2 equ    22          ; angle for ship slowdown
;;;                        
;;;                        
;;;ShipPitch:              ld      hl,(TacticsDotProduct2)            ; pitch counter sign = opposite sign to roofdir sign
;;;                        ld      a,h                                ; .
;;;                        xor     $80                                ; .
;;;                        and     $80                                ; .
;;;                        ld      h,a                                ; h  = flipped sign
;;;                        ld      a,l                                ; a = value * 2
;;;                        sla     a                                  ; 
;;;                        JumpIfAGTENusng RAT2, .skipPitchZero         ; if its > 16 then update pitch
;;;                        ZeroA                                      ; else we zero pitch but
;;;                        or      h                                  ; we need to retain the sign
;;;                        ld      (UBnKRotZCounter),a                ; .
;;;                        IFDEF MISSILEDEBUG
;;;                            ld  (TacticsRotZ),a
;;;                        ENDIF
;;;                        ret
;;;.skipPitchZero:         ld      a,l
;;;                        or      h
;;;                        ld      (UBnKRotZCounter),a
;;;                        IFDEF MISSILEDEBUG
;;;                            ld  (TacticsRotZ),a
;;;                        ENDIF
;;;                        ret
;;;                        
;;;
;;;                        ;
;;;ShipRoll:               call    XX12EquTacticsDotSidev             ; calculate side dot protuct
;;;                        ld      (TacticsDotProduct3),a             ; .
;;;                        ld      l,a                                ; .
;;;                        ld      a,(varS)                           ; .
;;;                        ld      (TacticsDotProduct3+1),a           ; .
;;;                        ld      h,a                                ; h = sign sidev
;;;                        ld      a,(TacticsDotProduct2+1)           ; get flipped pitch counter sign
;;;                        ld      b,a                                ; b = roof product
;;;                        ld      a,l                                ; a = abs sidev  * 2
;;;                        sla     a                                  ;
;;;                        JumpIfAGTENusng RAT2,.skipRollZero           ;
;;;                        ZeroA                                      ; if its zoer then set rotx to zero
;;;                        or      b
;;;                        ld      (UBnKRotXCounter),a
;;;                        IFDEF MISSILEDEBUG
;;;                            ld  (TacticsRotX),a
;;;                        ENDIF
;;;                        ret
;;;.skipRollZero:          ld      a,1
;;;                        or      h
;;;                        xor     b
;;;                        ld      (UBnKRotXCounter),a
;;;                        IFDEF MISSILEDEBUG
;;;                            ld  (TacticsRotX),a
;;;                        ENDIF
;;;                        ret
;;;
;;;ShipSpeed:              ld      hl,(TacticsDotProduct1)
;;;                        ld      a,h
;;;                        and     a
;;;                        jr      nz,.SlowDown
;;;                        ld      de,(TacticsDotProduct2)             ; dot product is +ve so heading at each other
;;;                        ld      a,l 
;;;                        JumpIfALTNusng  22,.SlowDown                                  ; nose dot product < 
;;;.Accelerate:            ld      a,3                                 ; else
;;;                        ld      (UBnKAccel),a                       ;  accelleration = 3
;;;                        IFDEF MISSILEDEBUG
;;;                            ld  (TacticsSpeed),a
;;;                        ENDIF                        
;;;                        ret                                         ;  .
;;;.SlowDown:              JumpIfALTNusng 18, .NoSpeedChange
;;;.Deccelerate:           ld      a,-1
;;;                        ld      (UBnKAccel),a
;;;                        IFDEF MISSILEDEBUG
;;;                            ld  (TacticsSpeed),a
;;;                        ENDIF
;;;                        ret
;;;.NoSpeedChange:         ZeroA                                       ; else no change
;;;                        ld      (UBnKAccel),a
;;;                        IFDEF MISSILEDEBUG
;;;                            ld  (TacticsSpeed),a
;;;                        ENDIF
;;;                        ret
