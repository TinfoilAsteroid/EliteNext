;..................................................................................................................................                        
;                           DEFINE ROTATIONDEBUG 1
;                           DEFINE CLIPDEBUG 1
CurrentShipUniv:        DB      0
;..................................................................................................................................                        
; if ship is destroyed or exploding then z flag is clear, else z flag is set
IsShipDestroyedOrExploding: MACRO
                            ld      a,(UBnKexplDsp)                                 ; is it destroyed
                            and     %10100000                                       ; or exploding
                            ENDM

JumpIfShipNotClose:         MACRO   NotCloseTarget
.CheckIfClose:              ld      hl,(UBnKxlo)                                    ; chigh byte check or just too far away
                            ld      de,(UBnKylo)                                    ; .
                            ld      bc,(UBnKzlo)                                    ; .
                            or      h                                               ; .
                            or      d                                               ; .
                            or      b                                               ; .
                            jp      nz,NotCloseTarget                               ; .
.CheckLowBit7Close:         or      l                                               ; if bit 7 of low is set then still too far
                            or      e                                               ; .
                            or      c                                               ; .
                            ld      iyh,a                                           ; save it in case we need to check bit 6 in collision check
                            and     $80                                             ; .
                            jp      nz,NotCloseTarget                              ; .    
                            ENDM

VeryCloseCheck:             MACRO
                            ld      a,iyh                                           ; bit 6 is still too far
                            and     %11000000  
                            ENDM

JumpIfNotDockingCheck:      MACRO   NotDocking
.CheckIfDockable:           ld      a,(ShipTypeAddr)                                ; Now we have the correct bank
                            JumpIfANENusng  ShipTypeStation, NotDocking             ; if its not a station so we don't test docking
.IsDockableHostoleCheck:    JumpOnMemBitSet ShipNewBitsAddr, ShipHostileNewBitNbr, NotDocking ; if it is angry then we dont test docking
.CheckHighNoseZ:            JumpIfMemLTNusng  UBnkrotmatNosevZ+1 , 214, NotDocking  ; get get high byte of rotmat this is the magic angle to be within 26 degrees +/-
.GetStationVector:          call    GetStationVectorToWork                          ; Normalise position into XX15 as in effect its a vector from out ship to it given we are always 0,0,0, returns with A holding vector z
                            JumpIfALTNusng  89, NotDocking                          ; if the z axis <89 the we are not in the 22 degree angle,m if its negative then unsigned comparison will cater for this
.CheckAbsRoofXHi:           ld      a,(UBnkrotmatRoofvX+1)                          ; get abs roof vector high
                            and     SignMask8Bit                                    ; .
                            JumpIfALTNusng 80, NotDocking                           ; note 80 decimal for 36.6 degrees horizontal
                            ENDM

;..................................................................................................................................                        
; Replacement for MVEIT routine
UpdateUniverseObjects:  xor     a
                        ld      (SelectedUniverseSlot),a
.UpdateUniverseLoop:    ld      d,a                                             ; d is unaffected by GetTypeInSlotA
;.. If the slot is empty (FF) then skip this slot..................................................................................
                        call    GetTypeAtSlotA
                        cp      $FF                                             ; we don't process empty slots
                        jp      z,.UniverseSlotIsEmpty                          ; .
                        ld      iyl,a                                           ; save type into iyl for later
.UniverseObjectFound:   ld      a,d                                             ; Get back Universe slot as we want it
                        MMUSelectUniverseA                                      ; and we apply roll and pitch
;-- EVERY ITERATIONS TIDY UP A SINGLE UNIVERSE ITEM., NEED A VAR TO HOLD CURRENT TIDY SLOT
        IFDEF   CLIPDEBUG
.DEBUG:                     ld      a,(SelectedUniverseSlot)
                            cp      0
                            jr      nz,.ProperUpdate
        ENDIF
        IFDEF   DEBUG_SHIP_MOVEMENT
.DebugUpdate:               call    FixStationPos                        
        ENDIF
        IFDEF   CLIPDEBUG
                            jp      .CheckExploding
        ENDIF
                            DISPLAY "TODO: Make all 4 of these 1 call"
.ProperUpdate:          call    ApplyMyRollAndPitch                             ; todo , make all 4 of these 1 call
                        ld      a,(UBnKRotZCounter)
                        cp      0
                        call    ApplyShipRollAndPitch
                        call    ApplyShipSpeed
                        call    UpdateSpeedAndPitch                             ; update based on rates of speed roll and pitch accelleration/decelleration
;.. apply ships movement                        
;.. If its a space station then see if we are ready to dock........................................................................
.CheckExploding:        IsShipDestroyedOrExploding                              ; fi its destroyed or exploding z flag will be clear
                        jp      nz,.ProcessedUniverseSlot                       ; then no action
;.. we can't collide with missiles, they collide with us as part of tactics
.CheckIfMissile:        JumpIfMemEqNusng ShipTypeAddr, ShipTypeMissile, .CollisionDone ; Missiles don't have ECM and do collision checks on their tactics phase
.ProcessECM:            call    UpdateECM                                       ; Update ECM Counters         
.CheckIfClose:          JumpIfShipNotClose .PostCollisionTest
.CheckIfDockable:       JumpIfNotDockingCheck .CollisionCheck                   ; check if we are docking or colliding
;.. Its passed all validation and we are docking...................................................................................
.WeAreDocking:          MMUSelectLayer1
                        ld        a,$6
                        call      l1_set_border
.EnterDockingBay:       ForceTransition ScreenDocking                           ;  Force transition 
                        ret                                                     ;  don't bother with other objects
                        ; So it is a candiate to test docking. Now we do the position and angle checks
;.. else we are just colliding and have to handle that
.CollisionCheck:        ld      a,iyl
                        JumpIfAEqNusng ShipTypeStation, .HaveCollided           ; stations dont check bit 6
                        JumpIfAEqNusng ShipTypeMissile, .PostCollisionTest      ; Missile collisions are done in the tactics code
.VeryCloseCheck:        VeryCloseCheck                                          ; bit 6 is still too far
                        jr      nz,.PostCollisionTest                            ; .
.ScoopableCheck:        ld      a,iyl                                           ; so if its not scoopable
                        JumpIfANENusng  ShipTypeScoopable, .HaveCollided        ; then its a collision
.ScoopsEquiped:         ld      a,(FuelScoop)                                   ; if there is no scoop then impact
                        JumpIfANENusng  EquipmentItemFitted, .HaveCollided      ; .
.ScoopRegion:           ld      a,(UBnKysgn)                                    ; if the y axis is negative then we are OK
                        JumpIfAIsZero   .HaveCollided                           ; else its a collision
.CollectedCargo:        call    ShipCargoType
.DoWeHaveCapacity:      ld      d,a                                             ; save cargotype
                        call    CanWeScoopCargoD
                        jr      c, .NoRoom
.CanScoop:              call    AddCargoTypeD
.NoRoom:                ClearSlotMem    SelectedUniverseSlot                    ; we only need to clear slot list as univ ship is now junk
                        jp      .PostCollisionTest
; ... Generic collision
.HaveCollided:          JumpIfMemLTNusng DELTA, 5, .SmallBump
.BigBump:               ld      a,(UBnKEnergy)                                  ; get energy level which gives us an approximate to size and health
                        SetCarryFlag
                        rla                                                     ; divide by 2 but also bring in carry so its 128 + energy / 2
                        ld      b,a
                        call    KillShip                                        ; mark ship as dead (if possible)
                        jp      .ApplyDamage
.SmallBump:             ld      a,(DELTA)                                       ; if out ship speed < 5 then set damage to 
                        ld      b,a
                                    DISPLAY "TODO: det target too"
                        call    DamageShip                                      ; dent target too  TODO make damge totally proportional to speed
                        jp      .ApplyDamage
.ApplyDamage:           call    SetSpeedZero
                        ld      a,(UBnKzsgn)                                    ; front or back
                        and     $80
                        jr      nz,.HitRear
                        ld      a,(ForeShield)
                        call    ApplyDamage
                        ld      (ForeShield),a
                        jp      .CollisionDone
.HitRear:               ld      a,(AftShield)
                        call    ApplyDamage
                        ld      (AftShield),a
.CollisionDone:         
;.. Now check laser to see if the ship is being shot in sights
.PostCollisionTest:     call    ShipInSights
                        jr      nc,.ProcessedUniverseSlot                        ; for laser and missile we can check once
                        ld      a,(CurrLaserPulseRate)
                        JumpIfAIsNotZero .CheckForPulse
                        JumpIfMemFalse FireLaserPressed,     .NoLaser
                        jp      .LaserDamage
.CheckForPulse:         JumpIfMemZero CurrLaserPulseOnCount, .NoLaser
.LaserDamage:           ld      a,(CurrLaserDamageOutput)
                        call    DamageShip
                        ld      a,(UBnKexplDsp)                                 ; is it destroyed
                        and     %10100000      
                        jp      nz,.ProcessedUniverseSlot                       ; can't lock on debris
.NoLaser:   
; Now check missile lock
.PlayerMissileLock:     JumpIfMemNeNusng MissileTargettingFlag, StageMissileTargeting, .ProcessedUniverseSlot
.LockPlayerMissile:     ld      a,(SelectedUniverseSlot)                        ; set to locked and nto launchedd
                        LockMissileToA                                          ; .                        
.ProcessedUniverseSlot: 
;...Tactics Section................................................................................................................
.AreWeReadyForAI:       ld      a,(SelectedUniverseSlot)                        ; get back current slot number
                        IsSlotMissile                                           ; Missiles update every iteration
                        jp      z,.UpdateMissile                                ; so we bypass the logic check
.CheckIfSlotAITurn:     CallIfMemEqMemusng SelectedUniverseSlot, CurrentUniverseAI, UpdateShip
.UniverseSlotIsEmpty:
.DoneAICheck:           ld      a,(SelectedUniverseSlot)                        ; Move to next ship in loop
                        inc     a                                               ; .
                        JumpIfAGTENusng   UniverseSlotListSize, .UpdateAICounter; if we are beyond the loop then update the mast AI counter and we are done
                        ld      (SelectedUniverseSlot),a                        ; else update loop pointer
                        jp      .UpdateUniverseLoop                             ; if there are more to go we continue
.UpdateAICounter:       IncMemMaxNCycle CurrentUniverseAI , UniverseSlotListSize
.CheckIfStationHostile: ReturnIfMemFalse  SetStationHostileFlag                ; we coudl move this to pre loop so its only done once
.CheckSetStationHostile:ReturnIfMemNeNusng UniverseSlotList, ShipTypeStation
                        MMUSelectUniverseN 0
                        call    SetShipHostile
                        SetMemFalse    SetStationHostileFlag
                        ret
.UpdateMissile:         ;break
                        call    UpdateShip                                      ; we do it this way top avoid double calling
                        jp      .DoneAICheck                                    ; ai if the ai slot to process = missile type
;..................................................................................................................................

SaveUBNK:               DS 3*3

SavePosition:           push    hl,,de,,bc,,af
                        ld      a,(CurrentShipUniv)
                        cp      2
                        jr      nz,.DoneSave
                        ;break
                        ld      hl, UBnKxlo
                        ld      de, SaveUBNK
                        ld      bc, 3*3
                        ldir
                        ld      a,0
                        ld      (UBnKyhi)  ,a
                        ld      (UBnKxhi)  ,a
                        ld      (UBnKzhi)  ,a                        
                        ld      (UBnKxsgn) ,a
                        ld      (UBnKysgn) ,a
                        ld      (UBnKzhi)  ,a
                        ld      (UBnKzsgn) ,a
                        ld      a, $5
                        ld      (UBnKylo)  ,a
                        ld      a, $5
                        ld      (UBnKxlo)  ,a
                        ld      a, $6E
                        ld      (UBnKzlo)  ,a
.DoneSave:              pop     hl,,de,,bc,,af
                        ret
                        
RestorePosition:        push    hl,,de,,bc,,af
                        ld      a,(CurrentShipUniv)
                        cp      2
                        jr      nz,.DoneSave
                        ;break
                        ld      hl, SaveUBNK
                        ld      de, UBnKxlo
                        ld      bc, 3*3
                        ldir
.DoneSave:              pop     hl,,de,,bc,,af
                        ret
                         

DrawForwardShips:       xor     a
.DrawShipLoop:          ld      (CurrentShipUniv),a
                        call    GetTypeAtSlotA
                        cp      $FF
                        jr      z,.ProcessedDrawShip
                        ; Add in a fast check for ship behind to process nodes and if behind jump to processed Draw ship
.SelectShipToDraw:       ld      a,(CurrentShipUniv)
                        MMUSelectUniverseA
                        IFDEF ROTATIONDEBUG
                            call    SavePosition
                        ENDIF
;Debug set position     
              ;         ld      hl,$0000
              ;         ld      a,$00
              ;         ld      (UBnKxlo),hl
              ;         ld      (UBnKxsgn),a
              ;         ld      hl,$0148
              ;         ld      a,$00
              ;         ld      (UBnKylo),hl
              ;         ld      (UBnKysgn),a
              ;         ld      hl,$0149
              ;         ld      a,$00
              ;         ld      (UBnKzlo),hl
              ;         ld      (UBnKzsgn),a
              ;         ld      hl,$A558
              ;         ld      (UBnkrotmatSidevX),hl
              ;         ld      hl,$D8CE
              ;         ld      (UBnkrotmatSidevY),hl
              ;         ld      hl,$0000
              ;         ld      (UBnkrotmatSidevZ),hl
              ;         ld      hl,$58CE
              ;         ld      (UBnkrotmatRoofvX),hl
              ;         ld      hl,$A558
              ;         ld      (UBnkrotmatRoofvY),hl
              ;         ld      hl,$0000
              ;         ld      (UBnkrotmatRoofvZ),hl
              ;         ld      hl,$8000
              ;         ld      (UBnkrotmatNosevX),hl
              ;         ld      hl,$8000
              ;         ld      (UBnkrotmatNosevY),hl
              ;         ld      hl,$6000
              ;         ld      (UBnkrotmatNosevZ),hl
                        
                        
                                    DISPLAY "TODO: Tune this"
.ProcessUnivShip:       call    ProcessShip          ; The whole explosion logic is now encapsulated in process ship ;TODO TUNE THIS   ;; call    ProcessUnivShip
; Debris still appears on radar                        
                        IFDEF ROTATIONDEBUG
                            call    RestorePosition
                        ENDIF
.UpdateRadar: 
;;;Does nothing                       ld      a,BankFrontView
;;;Does nothing                       MMUSelectScreenA
;;;Does nothing         ld      a,(CurrentShipUniv)
;;;Does nothing         MMUSelectUniverseA
                        
                        CallIfMemTrue ConsoleRedrawFlag,UpdateScannerShip ; Always update ship positions                        
.ProcessedDrawShip:     ld      a,(CurrentShipUniv)
                        inc     a
                        DISPLAY "TO DO - Add all ships back to radar"
                        ;   DEBUGGING SHIPS RENDERING
                        ;   JumpIfALTNusng   UniverseSlotListSize, .DrawShipLoop
.DrawSunCompass:        MMUSelectSun
                        call    UpdateCompassSun                ; Always update the sun position
                        call    UpdateScannerSun                ; Always attempt to put the sun on the scanner 
.CheckPlanetCompass:    ;JumpIfMemFalse SpaceStationSafeZone, .DrawStationCompass
.DrawPlanetCompass:     MMUSelectPlanet
                        call    UpdateCompassPlanet
                        call    UpdateScannerPlanet
                        MMUSelectSpaceStation
                        call    UpdateCompassStation
                        ret
.DrawStationCompass:

                        ret   
                        
                        
;..................................................................................................................................
                        
TestForNextShip:        MacroIsKeyPressed c_Pressed_Quit
                        ret     nz
                        ld      a,(currentDemoShip)
                        inc     a
                        cp      44
                        jr      nz,.TestOK
                        xor     a
.TestOK:                ld      (currentDemoShip),a
                        call    ClearUnivSlotList
                        ld      a,(currentDemoShip)
                        ld      b,a
                        xor     a
                        call    SetSlotAToTypeB
                        push    af
                        MMUSelectUniverseN 2
                        SetSlotAToUnivClass
                        pop     af
                        call    ResetUBnkData                         ; call the routine in the paged in bank, each universe bank will hold a code copy local to it
                        ld      a,(currentDemoShip)
                        MMUSelectShipBank1
                        call    GetShipBankId
                        MMUSelectShipBankA
                        ld      a,b
                        call    CopyShipToUniverse
                        call    SetInitialShipPosition
                        call    DEBUGSETNODES                        
                        ret
                        