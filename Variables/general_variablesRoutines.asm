LaserDrainSystems:      DrainSystem PlayerEnergy, CurrLaserEnergyDrain
                        BoostSystem GunTemperature, CurrLaserHeat
                        ret
                        
                        
ResetPlayerShip:        ZeroThrottle
                        ZeroPitch
                        ZeroRoll
                        ClearMissileTargetting
                        ClearECM
                        ChargeEnergyAndShields
                        ClearTemperatures
                        ClearWarpPressed
                        call    IsLaserUseable
                        MMUSelectCommander
                        call    LoadLaserToCurrent
                        ret     z
                        
                        ret

AddCargoTypeD:          ld      hl,CargoTonnes
                        ld      d,a
                        add     hl,a
                        inc     (hl)
                        ret

CanWeScoopCargoD:       ld      a,d
                        JumpIfAGTENusng  GoldIndex, .ItMayNotBeTonnes  ; if its cargo in kgs or gs then jump
.ItsTonnes:             ld      hl,CargoTonnes
                        ld      c,0
                        ld      b,MineralsIndex+1           ; Only count to Gold as that is in KG
.AddLoop:               ld      a,(hl)
                        add     c
                        ld      c,a                     ; add to counter
                        dec     b
                        inc     hl
                        djnz    .AddLoop
                        ld      hl,AlienItemsTonnes     ; Finally do alien items
                        ld      a,(hl)
                        add     c
                        ld      c,a
                        ld      a,(CargoBaySize)        ; Get Bay Size
                        JumpIfAEqNusng c, .CargoFull
.StillRoom:             ClearCarryFlag
                        ret
.CargoFull:             SetCarryFlag
                        ret
.ItMayNotBeTonnes:      JumpIfAEqNusng  AlienItemsIndex,.ItsTonnes       ;ALienItems are tonnes                      
                        ld      hl,CargoTonnes
                        ld      a,d
                        add     hl,a
                        ld      a,(hl)
                        JumpIfAEqNusng  200, .StillRoom
                        jp      .CargoFull
; END of rountine                        

IsLaserUseable:         ld      a,(CurrLaserType)
                        cp      255
                        ret     z
                        ld      a,(CurrLaserDamage)
                        cp      255
                        ret

InitMainLoop:           call    ClearUnivSlotList
                        xor     a
                        ld      (CurrentUniverseAI),a
                        ld      a,3
                        ld      (MenuIdMax),a
                        SetMemFalse SetStationHostileFlag
                        SetMemFalse DockedFlag
;                        call    InitialiseFrontView
                        call    InitialiseCommander
                        MMUSelectUniverseN 2    
                        call    SetInitialShipPosition
; Initialist screen refresh
                        ld      a, ConsoleRefreshInterval
                        ld      (ConsoleRefreshCounter),a
                        SetMemFalse    ConsoleRedrawFlag
                        MMUSelectStockTable
                        call    generate_stock_market
                        call    ResetMessageQueue
                        InitEventCounter
                        ClearMissJump
                        SetMemFalse TextInputMode
                        ret

; needs to be called after a kill too
SetPlayerRank:          ld      hl,(KillTally)
                        ld      ix,RankingTableLow
                        ld      b,0
.CompareLoop:           ld      d,(ix+1)
                        ld      e,(ix+0)
                        and     a             ; compare HL to DE
                        sbc     hl,de         ; we can throw away HL now
                        jr      z,.FoundRank
                        jr      c,.FoundRank
                        inc     ix
                        inc     ix
                        inc     b
                        jr      .CompareLoop
.FoundRank:             ld      a,b
                        ld      (CurrentRank),a
                        ret

SetSpeedZero:           ld      a,0
                        ld      (DELTA),a                                       ;
                        ld      h,a                                             ;
                        ld      l,a                                             ;
                        ld      (DELT4Lo),hl                                    ;
                        ret
                        
RechargeShip:           ld      hl,PlayerEnergy                                 ; if enery >= 128 
                        ld      a,(hl)
                        bit     7,a                                             ; then we can recharge shields
                        jr      z,.UpdatePlayerEnergy
.ShieldCharge:          ld      hl,ForeShield                                   ; charge front shield
                        inc     (hl)
                        jr      nz,.DoneForeShield
.ForeOverCharge:        dec     (hl)
.DoneForeShield:        inc     hl                                              ; point to aft shield
                        inc     (hl)
                        jr      nz,.DoneAftShield
                        dec     (hl)                                            ; back to 255
.DoneAftShield:         inc     hl                                              ; point to energy
.UpdatePlayerEnergy:    inc     (hl)
                        jr      z,.OverflowedEnergy
                        ld      a,(ExtraEnergyUnit)
                        ReturnIfANENusng EquipmentItemFitted                    ; if energy unit fitted an extra step
.EnergyUnitFitted:      inc     (hl)
                        jr      z,.OverflowedEnergy
                        ret
.OverflowedEnergy:      dec     (hl)                                            ;  restore to 255
                        ret
.SkipShieldCharge:      ld      hl,PlayerEnergy
                        jr      .UpdatePlayerEnergy

; sets carry to true if target
IsMissileLockedOn:      ld      a,(MissileTargettingFlag)
                        bit     7,a
                        jr      z, .TargetSelected
                        and     $70                         ; are all upper bits set (we can ignore bit 7)
                        jp      z, .TargetSelected           ; if its only bit 7 then we have a lock
                        ClearCarryFlag                      ; if bitsd 6 to 4 were set then it must be unlocked status
                        ret
.TargetSelected:        JumpIfSlotAEmpty .TargetInvalid     ; does slot A have an target
                        SetCarryFlag
                        ret
.TargetInvalid:         ld      a, StageMissileNotTargeting     ; housekeep missile status if target gone
                        ld      (MissileTargettingFlag),a
                        ret

