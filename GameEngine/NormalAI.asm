                        DEFINE DEBUGFORCEHOSTILE 1

NewLaunchUBnKX          DS 3
NewLaunchUBnKY          DS 3
NewLaunchUBnKZ          DS 3

NewLaunchMatrix         DS 3*3
NewLaunchSpeed          DS 1
NewLaunchRotX           DS 1
NewLaunchRotZ           DS 1

; ---------------------------------------------------------------------------------------------------------------------------------    
; a = y offset negative from center of ship
CalcLaunchOffset:       ld      hl,UBnKxlo
                        ld      de,NewLaunchUBnKX
                        ld      bc,9
                        ldir
.ApplyOffset:           sla     a
                        sla     a
                        ld      iyl,a                          ; save pre calculated speed
.ApplyToX:              SpeedMulAxis    a, UBnkrotmatRoofvX     ; e =  ABS (nosev x hi) c = sign
                        ld      a,b
                        xor     $80
                        ld      b,a
.AddSpeedToX:           AddSpeedToVert NewLaunchUBnKX
.ApplyToY:              SpeedMulAxis    iyl, UBnkrotmatRoofvY     
                        ld      a,b
                        xor     $80
                        ld      b,a
.AddSpeedToY:           AddSpeedToVert NewLaunchUBnKY
.ApplyToZ:              SpeedMulAxis    iyl, UBnkrotmatRoofvZ
                        ld      a,b
                        xor     $80
                        ld      b,a
.AddSpeedToZ:           AddSpeedToVert NewLaunchUBnKZ
                        ret

                        
                        
                        ;DEFINE MISSILEBREAK
;.. Thsi version uses new kind logic
;... Now the tactics if current ship is the missile, when we enter this SelectedUniverseSlot holds slot of missile
NormalAI:               ;ld      a,(ShipAIEnabled)
                        ;ReturnOnBitClear a, ShipAIEnabledBitNbr 
.GetEnergy:             call    RechargeEnergy                  ; TA13 if enegery <= maxumum value for blueprint then recharge energy by 1
                        ld      a,(ShipNewBitsAddr)
.IsItATrader:           and     ShipIsTrader
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
.CheckHostile:          ld      a,(ShipNewBitsAddr)
                        and     ShipIsHostile
                        jr      nz,.ItsHostile
.ItsNotHostile:         ld      a,(ShipNewBitsAddr)
                        and     ShipIsDocking                   ; if bit 4 is not clear
                        jr      nz,.NotDocking
.ItsDocking:            break
                        ;       do docking algorithm
                        ;       return
                        ret
.NotDocking:            break
                        ;       calcuilate vector to planet
                        ;       move towards planet
                        ;       return
                        ret
.ItsHostile:            ld      a,(ShipNewBitsAddr)
.IsItPirate:            and     ShipIsPirate
                        jr      nz,.NotAPirate
.IsItInSafeZone:        ;      if we are not in space station safe zone
.InSafeZone:            ld      a,(ShipNewBitsAddr)
                        or      Bit7Only | ShipIsTrader
.NotSafeZone:           call    CalcVectorToMyShip
                        call    NormalizeTactics
.NotAPirate:
.SpawnFighter:          ld      a,(UBnKFightersLeft)
                        and     a
                        jr      z,.NoFighters
.CanSpawnFighter:       call    doRandom
                        JumpIfALTNusng 200, .NoFighters
                        break
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
                        ld      a,(UBnkaiatkecm)                ;  disable ship AI hostily and ECM
                        and     ShipAIDisabled                  ;  .
                        ld      (UBnkaiatkecm),a                ;  .
                        ZeroA                                   ;  .
                        ld      (UBnKECMFitted),a               ;  .
.LaunchEscapePod:       break                        
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
.FireLaser:             break                        ;      do fire laser logic (drain energy, add beam to lines as random line from ship to a random edge of screen)
                        ld      a,b ;; need to see if b gets corrupted by laser fire
                        JumpIfAEqNusng      35, .LaserHitPlayer
                        JumpIfAEqNusng      36, .LaserHitPlayer
.LaserMissedPlayer:     jp      .DoneLaserShot
.LaserHitPlayer:        break ;         do direct hit logic
.DoneLaserShot:         ;      Half attacking ship's accelleration in byte 28 (dec so must be 0 1 or 2)
.TooFarForLaser:
.UpdateShip             break
                        ld      a,(UBnKzhi)
                        JumpIfAGTENusng 3, .ShipFarAway
                        ld      a,(UBnKxhi)
                        ld      hl,(UBnKyhi)
                        or      (hl)
                        and     %11111110
                        jr      z,.ShipTurnAway
.ShipFarAway:           FlipSignMem TacticsVectorX+2                ; negate vector in XX15 so it points opposite direction
                        FlipSignMem TacticsVectorY+2                ; we have already negated the dot product above
                        FlipSignMem TacticsVectorZ+2                ; .                         
                        ld      a,(RandomSeed2)         ; if random with bit 7 set < ship AI byte 32 flag
                        or      %10000000               ; .
                        JumpIfAGTEMemusng ShipAIFlagsAddr, .ShipTurnAway
                        call    SeekingLogic            ;    seek as per missile
                        ret
.ShipTurnAway:          call    SeekingLogic            ; move away (ie.. as per missile but dot products not reversed)
                        ;              consider a random roll
                        ret
