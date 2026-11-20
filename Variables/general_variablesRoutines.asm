
; This will save to current queue position. it also asusmes that we never go beyond queue
; limit so does not do bounds checking for speed
SaveMMU0:               GetNextReg  MMU_SLOT_0_REGISTER             ; Get current reg value
                        ld          hl,(SaveMMU0QueueHead)               ; get address of current slot
                        ld          (hl),a                          ; and write reg value to this address
                        ld          hl,SaveMMU0QueueHead                ; move address pointer up one
                        inc         (hl)
                        ret

RestoreMMU0:            ld          hl,SaveMMU0QueueHead                ; Currently looking at next free
                        dec         (hl)                            ; so step back one
                        ld          hl,(SaveMMU0QueueHead)              ; save position as next free
                        ld          a,(hl)                          ; get value that was there
                        nextreg     MMU_SLOT_0_REGISTER,a           ; and swap MMU bank
                        ret

SaveMMU6:               GetNextReg  MMU_SLOT_6_REGISTER             ; Get current reg value
                        ld          hl,(SaveMMU6QueueHead)              ; get address of current slot
                        ld          (hl),a                          ; and write reg value to this address
                        ld          hl,SaveMMU6QueueHead                ; move address pointer up one
                        inc         (hl)
                        ret

RestoreMMU6:            ld          hl,SaveMMU6QueueHead            ; Currently address pointer looking at next free
                        dec         (hl)                            ; so step back one
                        ld          hl,(SaveMMU6QueueHead)              ; save position as next free
                        ld          a,(hl)                          ; get value that was there
                        nextreg     MMU_SLOT_6_REGISTER,a           ; and swap MMU bank
                        ret

SaveMMU7:               GetNextReg  MMU_SLOT_7_REGISTER             ; Get current reg value
                        ld          hl,(SaveMMU7QueueHead)          ; get address of current slot
                        ld          (hl),a                          ; and write reg value to this address
                        ld          hl,SaveMMU7QueueHead            ; move address pointer up one
                        inc         (hl)
                        ret

RestoreMMU7:            ld          hl,SaveMMU7QueueHead            ; Currently looking at next free
                        dec         (hl)                            ; so step back one
                        ld          hl,(SaveMMU7QueueHead)              ; save position as next free
                        ld          a,(hl)                          ; get value that was there
                        nextreg     MMU_SLOT_7_REGISTER,a           ; and swap MMU bank
                        ret
                        
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
                        call    LaserReset
                        MMUSelectCommander
                        call    LoadLaserToCurrent
                        ret     z
                        
                        ret

; d = cargo type: one more of it in the hold, and in CargoRunningLoad (the tonnes held, as the market keeps it) if it
; is measured in tonnes. (It used a, which CanWeScoopCargoD leaves as the bay size, so a scoop added 1 to the byte 70
; on from CargoTonnes; and it never updated CargoRunningLoad)
AddCargoTypeD:          ld      hl,CargoTonnes
                        ld      a,d
                        add     hl,a
                        inc     (hl)
                        ld      a,d
                        cp      AlienItemsIndex
                        jr      z,.Tonnes
                        cp      GoldIndex
                        ret     nc                      ; gold, platinum, gem stones: kg / g
.Tonnes:                ld      hl,CargoRunningLoad
                        inc     (hl)
                        ret

; d = cargo type: carry if there is no room for one more. Tonnes (food to minerals, and alien items): the total in
; tonnes must be under CargoBaySize. Gold, platinum and gem stones (kg / g) have their own limit of 200 each, as BBC
; Elite. (It summed only every other row, said full only when the total was exactly the bay size, and let kg / g
; items in only when 200 were already held)
CanWeScoopCargoD:       ld      a,d
                        JumpIfAGTENusng  GoldIndex, .ItMayNotBeTonnes  ; if its cargo in kgs or gs then jump
.ItsTonnes:             ld      hl,CargoTonnes
                        ld      c,0
                        ld      b,MineralsIndex+1       ; food to minerals (gold on are in kg / g)
.AddLoop:               ld      a,(hl)
                        add     c
                        ld      c,a                     ; add to counter
                        inc     hl
                        djnz    .AddLoop
                        ld      a,(AlienItemsTonnes)    ; Finally do alien items
                        add     c
                        ld      hl,CargoBaySize
                        cp      (hl)
                        jr      nc,.CargoFull           ; total >= bay size
.StillRoom:             ClearCarryFlag
                        ret
.CargoFull:             SetCarryFlag
                        ret
.ItMayNotBeTonnes:      JumpIfAEqNusng  AlienItemsIndex,.ItsTonnes       ;ALienItems are tonnes
                        ld      hl,CargoTonnes
                        add     hl,a
                        ld      a,(hl)
                        cp      200
                        jr      nc,.CargoFull           ; 200 or more already
                        jr      .StillRoom
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

; Carry set if a missile is locked on: MissileTargettingFlag = $80 | slot (StageMissileNotTargeting $FF and
; StageMissileTargeting $FE are not locks, and bit 7 clear means a launch is already flagged) and that slot still holds
; something, else carry clear (and a lock on an emptied slot is cleared). Was a zero flag test of the wrong bits, so
; firing with no lock launched at slot 14 / 15, and a lock checked slot 0 rather than its target
IsMissileLockedOn:      ld      a,(MissileTargettingFlag)
                        ld      b,a
                        and     $F0                         ; $8n: locked on slot n
                        cp      $80
                        jr      nz,.NotLocked
                        ld      a,b
                        and     $0F                         ; a = the target's slot
                        JumpIfSlotAEmpty .TargetInvalid     ; does slot A have an target
                        SetCarryFlag
                        ret
.TargetInvalid:         ld      a, StageMissileNotTargeting     ; housekeep missile status if target gone
                        ld      (MissileTargettingFlag),a
.NotLocked:             ClearCarryFlag
                        ret


;----------------------------------------------------------------------------------------------------------------------------------
; The galactic and local chart cursors: carry set and a = CursorKeysPressed if the cursor should move this loop, else carry
; clear. The first loop a cursor key is down it moves, then every ChartCursorFrames frames (FrameCounter16) while held, so
; the speed doesn't depend on how fast the menu loop runs (it was a count of loops: 125 and 75)
ChartCursorDue:         ld      a,(CursorKeysPressed)
                        and     a
                        jr      nz,.KeyDown
                        ld      hl,(FrameCounter16)                 ; none down: the next press moves at once
                        ld      (ChartCursorNext),hl
                        ret                                         ; (carry clear from the and)
.KeyDown:               ld      hl,(FrameCounter16)                 ; now - next < 0: not yet
                        ld      de,(ChartCursorNext)
                        or      a
                        sbc     hl,de
                        bit     7,h
                        jr      nz,.NotYet
                        ld      hl,(FrameCounter16)
                        ld      de,ChartCursorFrames
                        add     hl,de
                        ld      (ChartCursorNext),hl
                        ld      a,(CursorKeysPressed)
                        scf
                        ret
.NotYet:                or      a
                        ret

; The galactic and local charts' cursor keys: hl = a table of 6 handler addresses, for the bits of CursorKeysPressed
; from bit 7 down: up (Q), down (A), left, right, home, recentre. When ChartCursorDue says a move is due, calls the
; handler of each key down, in that order. The handlers may change any register and just return at a limit
ChartCursorKeys:        push    hl
                        call    ChartCursorDue                      ; carry: move now, a = the cursor keys
                        pop     hl
                        ret     nc
                        ld      b,6
.NextKey:               rla                                         ; this key's bit into carry
                        jr      nc,.NotDown
                        push    af,,bc,,hl
                        ld      e,(hl)
                        inc     hl
                        ld      d,(hl)
                        ex      de,hl
                        call    .JumpHL
                        pop     af,,bc,,hl
.NotDown:               inc     hl
                        inc     hl
                        djnz    .NextKey
                        ret
.JumpHL:                jp      (hl)

;----------------------------------------------------------------------------------------------------------------------------------
; The system map's positions (Menus/system_map_menu.asm), gathered here in main memory as the sun, planet and ship banks
; page into slot 6, where the map's code is: per object a kind (SystemMapKind*) and its 9 byte position (x, y, z: lo, hi,
; sign); the sun, the planet, then each occupied universe slot not destroyed or exploding; then a 0
SystemMapKindSun        equ 1
SystemMapKindPlanet     equ 2
SystemMapKindStation    equ 3
SystemMapKindShip       equ 4
SystemMapKindHostile    equ 5
SystemMapObjectSize     equ 10
SystemMapMaxObjects     equ 2 + UniverseSlotListSize
SystemMapObjects:       DS  SystemMapMaxObjects * SystemMapObjectSize + 1

; fills SystemMapObjects, then pages the system map's bank (BankMenuSystem) back into slot 6
SystemMapGather:        ld      de,SystemMapObjects
                        MMUSelectSun
                        ld      a,SystemMapKindSun
                        ld      hl,SBnKxlo
                        call    .Copy
                        MMUSelectPlanet
                        ld      a,SystemMapKindPlanet
                        ld      hl,P_BnKxlo
                        call    .Copy
                        ld      c,0
.Slot:                  ld      hl,UniverseSlotList
                        ld      a,c
                        add     hl,a
                        ld      a,(hl)
                        cp      $FF
                        jr      z,.NextSlot
                        ld      a,c
                        MMUSelectUniverseA
                        ld      a,(UBnKexplDsp)
                        and     %10100000                   ; destroyed or exploding
                        jr      nz,.NextSlot
                        ld      hl,UniverseSlotType
                        ld      a,c
                        add     hl,a
                        ld      b,SystemMapKindStation
                        ld      a,(hl)
                        cp      ShipTypeStation
                        jr      z,.HaveKind
                        ld      b,SystemMapKindShip
                        ld      a,(ShipNewBitsAddr)
                        and     ShipIsHostile
                        jr      z,.HaveKind
                        ld      b,SystemMapKindHostile
.HaveKind:              ld      a,b
                        ld      hl,UBnKxlo
                        push    bc
                        call    .Copy
                        pop     bc
.NextSlot:              inc     c
                        ld      a,c
                        cp      UniverseSlotListSize
                        jr      c,.Slot
                        xor     a
                        ld      (de),a
                        nextreg MMU_SLOT_6_REGISTER,BankMenuSystem
                        ret
.Copy:                  ld      (de),a
                        inc     de
                        ld      bc,9
                        ldir
                        ret
