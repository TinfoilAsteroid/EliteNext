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

; close = within 128 (lo bit 7 clear, hi and the sign bytes' integer bits 0) on every axis; iyh = the lo bytes or'd
; (once started with A as UpdateECM left it, and ignored the sign bytes, so a ship 65536 off could count as close)
                            ASSERT  StationCollisionRange == $80                    ; (the lo byte bit 7 test below)
JumpIfShipNotClose:         MACRO   NotCloseTarget
.CheckSignBytes:            ld      a,(UBnKxsgn)                                    ; any axis 65536 or more away?
                            ld      hl,UBnKysgn                                     ; .
                            or      (hl)                                            ; .
                            ld      hl,UBnKzsgn                                     ; .
                            or      (hl)                                            ; .
                            and     SignMask8Bit                                    ; . (a = 0 if not)
                            jp      nz,NotCloseTarget                               ; .
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
                        ld      (SelectedUniverseSlot),a                            ; set universe current selected slot to 0
.UpdateUniverseLoop:    ld      d,a                                                 ; d is unaffected by GetTypeInSlotA
;.. If the slot is empty (FF) then skip this slot..................................................................................
                        call    GetTypeAtSlotA
                        cp      $FF                                                 ; we don't process empty slots
                        jp      z,.UniverseSlotIsEmpty                              ; .
                        ld      iyl,a                                               ; save type into iyl for later
.UniverseObjectFound:   ld      a,d                                                 ; Get back Universe slot as we want it
                        MMUSelectUniverseA                                          ; and we apply roll and pitch
;-- EVERY ITERATIONS TIDY UP A SINGLE UNIVERSE ITEM., NEED A VAR TO HOLD CURRENT TIDY SLOT
        IFDEF   CLIPDEBUG
.DEBUG:                     ld      a,(SelectedUniverseSlot)                        ; if we are debugging clipping routine
                            cp      0                                               ; then only work on slot 0
                            jr      nz,.ProperUpdate                                ;
        ENDIF
        IFDEF   DEBUG_SHIP_MOVEMENT
.DebugUpdate:               call    FixStationPos                                   ; if we are debugging space station code
        ENDIF
        IFDEF   CLIPDEBUG                                                           ; if we are debugging clipping then skip all update code
                            jp      .CheckExploding
        ENDIF
.ProperUpdate:          MMUSelectMathsBankedFns
                        ld      ix,UBnkrotmat
                        CallIfMemEqMemusng SelectedUniverseSlot, CurrentUniverseAI, TidyOrientation  ; determine if its tidy time within the universe model
                        call    ShipApplyMyRollAndPitch;MyRollAndPitch24Bit;ApplyMyRollAndPitch             ; Apply our ship movement to universe object
                        call    ApplyShipRollAndPitch                               ; Apply ships own movement to universe object
                        call    ApplyShipSpeed                                      ; Apply ships speed to universe object
                        call    UpdateSpeedAndPitch                                 ; update based on rates of speed roll and pitch accelleration/decelleration
;.. apply ships movement
;.. If its a space station then see if we are ready to dock........................................................................
.CheckExploding:        IsShipDestroyedOrExploding                                  ; if its destroyed or exploding z flag will be clear
                        jp      nz,.ProcessedUniverseSlot                           ; then no action
;.. we can't collide with missiles, they collide with us as part of tactics
.CheckIfMissile:        JumpIfMemEqNusng ShipTypeAddr, ShipTypeMissile, .CollisionDone ; Missiles don't have ECM and do collision checks on their tactics phase
.ProcessECM:            call    UpdateECM                                           ; Update ECM Counters
.CheckIfClose:          JumpIfShipNotClose .PostCollisionTest
.CheckIfDockable:       JumpIfNotDockingCheck .CollisionCheck                       ; check if we are docking or colliding
;.. Its passed all validation and we are docking...................................................................................
.WeAreDocking:          MMUSelectLayer1
                        ld        a,$6
                        call      l1_set_border
.EnterDockingBay:       ForceTransition ScreenDocking                               ;  Force transition
                        ret                                                         ;  don't bother with other objects
                        ; So it is a candiate to test docking. Now we do the position and angle checks
;.. else we are just colliding and have to handle that
.CollisionCheck:        ld      a,(ShipTypeAddr)                                    ; (iyl, the slot's type, doesn't survive the roll and pitch code)
                        JumpIfAEqNusng ShipTypeStation, .HaveCollided               ; stations dont check bit 6
                        JumpIfAEqNusng ShipTypeMissile, .PostCollisionTest          ; Missile collisions are done in the tactics code
.VeryCloseCheck:        VeryCloseCheck                                              ; bit 6 is still too far
                        jr      nz,.PostCollisionTest                               ; .
.ScoopableCheck:        ld      a,(ShipTypeAddr)                                    ; so if its not scoopable
                        JumpIfANENusng  ShipTypeScoopable, .HaveCollided            ; then its a collision
.ScoopsEquiped:         ld      a,(FuelScoop)                                       ; if there is no scoop then impact
                        JumpIfANENusng  EquipmentItemFitted, .HaveCollided          ; .
.ScoopRegion:           ld      a,(UBnKysgn)                                        ; if the y axis is negative then we are OK
                        JumpIfAIsZero   .HaveCollided                               ; else its a collision
.CollectedCargo:        call    ShipCargoType
.DoWeHaveCapacity:      ld      d,a                                                 ; save cargotype
                        call    CanWeScoopCargoD
                        jr      c, .NoRoom
.CanScoop:              call    AddCargoTypeD
.NoRoom:                ClearSlotMem    SelectedUniverseSlot                        ; we only need to clear slot list as univ ship is now junk
                        jp      .PostCollisionTest
; ... Generic collision
.HaveCollided:          ;break
                        JumpIfMemLTNusng DELTA, 5, .SmallBump
.BigBump:               ld      a,(UBnKEnergy)                                      ; get energy level which gives us an approximate to size and health
                        SetCarryFlag
                        rla                                                         ; divide by 2 but also bring in carry so its 128 + energy / 2
                        ld      b,a
                        call    KillShip                                            ; mark ship as dead (if possible)
                        jp      .ApplyDamage
.SmallBump:             ld      a,(DELTA)                                           ; if out ship speed < 5 then set damage to
                        ld      b,a
                        call    DamageShip                                          ; dent target too  TODO make damge totally proportional to speed
                        jp      .ApplyDamage
.ApplyDamage:           PlaySFX SFXHit                                              ; a collision
                        call    SetSpeedZero
                        ld      a,(UBnKzsgn)                                        ; front or back
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
                        ld      a,(LaserHitDamage)                              ; this loop's laser damage (LaserUpdate)
                        and     a
                        jr      z,.NoLaser
                        PlaySFX SFXHit
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
;.. For normal ships AI is only updated once every 16th cycle, i.e. CurrentUniverseAI increments though 1 count each game loop....,
.CheckIfSlotAITurn:     CallIfMemEqMemusng SelectedUniverseSlot, CurrentUniverseAI, UpdateShip
.UniverseSlotIsEmpty:
.DoneAICheck:           ld      a,(SelectedUniverseSlot)                        ; Move to next ship in loop
                        inc     a                                               ; .
                        JumpIfAGTENusng   UniverseSlotListSize, .UpdateAICounter; if we are beyond the loop then update the master AI counter and we are done
                        ld      (SelectedUniverseSlot),a                        ; else update loop pointer
                        jp      .UpdateUniverseLoop                             ; if there are more to go we continue
.UpdateAICounter:       IncMemMaxNCycle CurrentUniverseAI , UniverseSlotListSize; if we get to AI counter update then we have updated all ships so we are done
.CheckIfStationHostile: ReturnIfMemFalse  SetStationHostileFlag                 ; If the space station hostile flag is set
.CheckSetStationHostile:ReturnIfMemNeNusng UniverseSlotList, ShipTypeStation    ; and we are on a type space station (now hard coded to be always slot 0 but check as we may have multiple space stations later)
                        MMUSelectUniverseN 0                                    ; so we can select universe slot 0 and set it to hostile
                        call    SetShipHostile
                        SetMemFalse    SetStationHostileFlag
                        ret
;.. For Missiles AI is updated every cycle
.UpdateMissile:         ;break                                                   ; Missile AI to add later for now we just fall into UpdateShip
                        call    UpdateShip                                      ; we do it this way top avoid double calling
                        jp      .DoneAICheck                                    ; ai if the ai slot to process = missile type
;..................................................................................................................................

SaveUBNK:               DS 3*3

SavePosition:           push    hl,,de,,bc,,af
                        ld      a,(CurrentShipUniv)
                        cp      2
                        jr      nz,.DoneSave
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
                        ld      hl, SaveUBNK
                        ld      bc, 3*3
                        ld      de, UBnKxlo
                        ldir
.DoneSave:              pop     hl,,de,,bc,,af
                        ret

;----------------------------------------------------------------
;-- Draw all the ships from the perspective of a forward view
;-- iterates through all slots within this loop
    IFDEF SOLID_HULL
;----------------------------------------------------------------------------------------------------------------------------------
; SOLID_HULL: the ships are drawn furthest first (painter's algorithm), so a nearer ship's fill covers a further one.
; SortShipsFurthestFirst fills ShipDrawOrder with the active slots, by key, largest first:
;   a dot ($FFFF: always first, as they are tiny and always furthest), else the distance along the view axis: (|z| hi 15 bits)
;   for the front view, 0 for a ship behind (it isn't drawn). The rear view uses the same key, as DrawForwardShips does.
;   When the left and right views are done, they want |x| here instead (the view's own axis).
; Dots use last frame's ShipIsDot (ProcessShip sets it), which is fine for ordering
ShipDrawOrder           DS UniverseSlotListSize         ; slot numbers, furthest first
ShipDrawKey             DS UniverseSlotListSize * 2     ; their keys
ShipDrawCount           DB 0
ShipDrawIndex           DB 0

SortShipsFurthestFirst: xor     a
                        ld      (ShipDrawCount),a
                        ld      c,a                             ; c = slot
.Gather:                ld      a,c
                        call    GetTypeAtSlotA                  ; (hl, a)
                        cp      $FF
                        jr      z,.Next
                        ld      a,c
                        MMUSelectUniverseA
                        ld      hl,$FFFF                        ; a dot: first
                        ld      a,(UBnkaiatkecm)
                        and     ShipIsDot
                        jr      nz,.Insert
                        ld      hl,0                            ; behind: last
                        ld      a,(UBnKzsgn)
                        bit     7,a
                        jr      nz,.Insert
                        ld      h,a                             ; else z / 256 (16 bits of the 24 bit z)
                        ld      a,(UBnKzhi)
                        ld      l,a
.Insert:                ld      a,(ShipDrawCount)               ; insertion: b = position, moving down while the entry
                        ld      b,a                             ; above it has a smaller key
.Shift:                 ld      a,b
                        and     a
                        jr      z,.Put
                        push    hl
                        dec     a
                        add     a,a
                        ld      hl,ShipDrawKey
                        add     hl,a
                        ld      e,(hl)                          ; de = key[b - 1]
                        inc     hl
                        ld      d,(hl)
                        pop     hl
                        push    hl
                        or      a
                        sbc     hl,de                           ; stop when key <= key[b - 1]
                        pop     hl
                        jr      c,.Put
                        jr      z,.Put
                        push    hl
                        ld      a,b                             ; key[b] = key[b - 1]
                        add     a,a
                        ld      hl,ShipDrawKey
                        add     hl,a
                        ld      (hl),e
                        inc     hl
                        ld      (hl),d
                        ld      hl,ShipDrawOrder                ; order[b] = order[b - 1]
                        ld      a,b
                        add     hl,a
                        dec     hl
                        ld      a,(hl)
                        inc     hl
                        ld      (hl),a
                        pop     hl
                        dec     b
                        jr      .Shift
.Put:                   ex      de,hl                           ; key[b] = key, order[b] = slot
                        ld      a,b
                        add     a,a
                        ld      hl,ShipDrawKey
                        add     hl,a
                        ld      (hl),e
                        inc     hl
                        ld      (hl),d
                        ld      hl,ShipDrawOrder
                        ld      a,b
                        add     hl,a
                        ld      (hl),c
                        ld      hl,ShipDrawCount
                        inc     (hl)
.Next:                  inc     c
                        ld      a,c
                        cp      UniverseSlotListSize
                        jr      c,.Gather
                        ret
    ENDIF

DrawForwardShips:
    IFDEF SOLID_HULL
                        call    SortShipsFurthestFirst
                        xor     a
.DrawOrderLoop:         ld      (ShipDrawIndex),a
                        ld      hl,ShipDrawCount
                        cp      (hl)
                        jr      nc,.DrawSunCompass
                        ld      hl,ShipDrawOrder
                        add     hl,a
                        ld      a,(hl)
                        ld      (CurrentShipUniv),a
                        MMUSelectUniverseA
                        call    ProcessShip
                        CallIfMemTrue ConsoleRedrawFlag,UpdateScannerShip
                        ld      a,(ShipDrawIndex)
                        inc     a
                        jr      .DrawOrderLoop
    ENDIF
                        xor     a
.DrawShipLoop:          ld      (CurrentShipUniv),a
                        call    GetTypeAtSlotA                  ; skip any slot which is set to $FF as its not an active ship slot
                        cp      $FF                             ; .
                        jr      z,.ProcessedDrawShip            ; .
                        ; Add in a fast check for ship behind to process nodes and if behind jump to processed Draw ship
.SelectShipToDraw:       ld      a,(CurrentShipUniv)
                        MMUSelectUniverseA
                        IFDEF ROTATIONDEBUG
                            call    SavePosition
                        ENDIF
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

                        CallIfMemTrue ConsoleRedrawFlag,UpdateScannerShip ; Always update ship positions when consoel redraw is flagged
.ProcessedDrawShip:     ld      a,(CurrentShipUniv)
                        inc     a
                        ;   DEBUGGING SHIPS RENDERING
                        JumpIfALTNusng   UniverseSlotListSize, .DrawShipLoop
.DrawSunCompass:        MMUSelectSun
                        call    UpdateCompassSun                ; Always update the sun position
                        call    UpdateScannerSun                ; Always attempt to put the sun on the scanner
.CheckPlanetCompass:    ;JumpIfMemFalse SpaceStationSafeZone, .DrawStationCompass
.DrawPlanetCompass:     MMUSelectPlanet
                        call    UpdateCompassPlanet
                        call    UpdateScannerPlanet
                        call    IsSpaceStationPresent           ; carry clear if slot 0 is the station
                        jr      c,.NoStationCompass             ; else its bank holds some other ship (or nothing)
                        MMUSelectSpaceStation
                        call    UpdateCompassStation
                        jr      .DrawRadarEdges
.NoStationCompass:      nextreg SPRITE_PORT_INDEX_REGISTER,compass_station ; hide the station's compass dot
                        nextreg SPRITE_PORT_ATTR3_REGISTER,$00            ; (as HideSprite)
.DrawRadarEdges:        CallIfMemTrue ConsoleRedrawFlag, RadarEdgeSun       ; dots on the scanner outline for the sun, planet
                        CallIfMemTrue ConsoleRedrawFlag, RadarEdgePlanet    ; and station when out of scanner range, only on the
                        CallIfMemTrue ConsoleRedrawFlag, RadarEdgeStation   ; frames the console area of layer 2 is cleared
                        ret
.DrawStationCompass:

                        ret


;----------------------------------------------------------------------------------------------------------------------------------
; Set initial ship position as X,Y,Z 000,000,03B4
SetInitialShipPosition: ld      hl,$0000
                        ld      (UBnKxlo),hl
                        ld      hl,$0000
                        ld      (UBnKylo),hl
                        ld      hl,$03B4
                        ld      (UBnKzlo),hl
                        xor     a
                        ld      (UBnKxsgn),a
                        ld      (UBnKysgn),a
                        ld      (UBnKzsgn),a
                        call	InitialiseOrientation            ;#00;
                        ld      a,1
                        ld      (DELTA),a
                        ld      hl,4
                        ld      (DELTA4),hl
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
                        ret
