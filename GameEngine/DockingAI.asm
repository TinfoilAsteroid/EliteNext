;----------------------------------------------------------------------------------------------------------------------------------
; Docking for non hostile ships (NormalAI: traders and the like heading for the planet, once the space station is there).
; In BankMathsBankedFns, paged in at slot 0 by UnivDocking (NormalAI.asm), so it can page the station's universe bank
; into slot 6 to read its position and nose while the ship's own bank is saved (SaveMMU6 / RestoreMMU6).
;
; Each AI turn, from where the ship is now (no phase is kept, so a ship knocked off course just carries on):
;   * no station: the docking flag is cleared, and the ship goes back to heading for the planet;
;   * in front of the slot (the station's nose . the unit vector from the station to the ship >= DockConeDot) it
;     steers for the station itself, slowing to DockSpeed within DockSlowHi; within DockRangeHi it has docked and
;     leaves the slot list (no explosion, no kill);
;   * anywhere else it steers for the approach point, DockApproachDistance nose lengths out from the slot, which
;     brings it round in front of the slot.
; The station's nose points out of its slot (UnivSetStationInSafeZone puts the slot towards us, as the player's docking
; test in UpdateUniverseObjects wants). Ships don't collide with the station, so one coming from behind flies through.
; Tools/test_docking.py
;----------------------------------------------------------------------------------------------------------------------------------
DockApproachDistance    equ 24                      ; the approach point: the station + its nose (96 = 1.0) * this, 2304 out
DockConeDot             equ 26                      ; in front: the dot (36 = 1.0) at least this, within about 44 degrees
DockRangeHi             equ 2                       ; docked: within 512 of the station on every axis (hi bytes < this)
DockSlowHi              equ $10                     ; within 4096: slow down
DockSpeed               equ 8                       ; to this speed
DockTurnSpeed           equ 3                       ; or this while turning onto the target
DockAlignedDot          equ 30                      ; the nose on the target: its dot with the target's direction >= this


; DockStationPos, DockStationNose, DockTargetPos and DockNear are in main memory (GameEngine/TacticsWorkingData.asm):
; this bank is at $0000, where Layer 2's write paging goes while drawing, so a store here could land in the screen

; one axis of the approach point: station + nose hi byte * DockApproachDistance (MissileVectorAdd: AHL = BHL + CDE)
DockApproachAxis:       MACRO   axis
                        ld      hl,(DockStationPos + 3 * axis)
                        ld      a,(DockStationPos + 3 * axis + 2)
                        ld      b,a
                        ld      a,(DockStationNose + 2 * axis + 1)  ; nose hi byte: sign and magnitude (96 = 1.0)
                        ld      c,a
                        and     SignMask8Bit
                        ld      d,a
                        ld      e,DockApproachDistance
                        mul     de                                  ; de = |nose| * DockApproachDistance
                        ld      a,c
                        and     SignOnly8Bit
                        ld      c,a                                 ; c = the nose's sign
                        call    MissileVectorAdd
                        ld      (DockTargetPos + 3 * axis),hl
                        ld      (DockTargetPos + 3 * axis + 2),a
                        ENDM

; DockNear from TacticsVector (ship - station, S15.8, not normalised yet)
DockRange:              ld      a,(TacticsVectorX+2)                ; 65536 or more off on an axis: not near
                        ld      hl,TacticsVectorY+2
                        or      (hl)
                        ld      hl,TacticsVectorZ+2
                        or      (hl)
                        and     SignMask8Bit
                        ld      c,0                                 ; c = DockNear
                        jr      nz,.Done
                        ld      a,(TacticsVectorX+1)                ; a = the largest hi byte
                        ld      hl,TacticsVectorY+1
                        cp      (hl)
                        jr      nc,.NotY
                        ld      a,(hl)
.NotY:                  ld      hl,TacticsVectorZ+1
                        cp      (hl)
                        jr      nc,.NotZ
                        ld      a,(hl)
.NotZ:                  cp      DockSlowHi
                        jr      nc,.Done
                        set     1,c
                        cp      DockRangeHi
                        jr      nc,.Done
                        set     0,c
.Done:                  ld      a,c
                        ld      (DockNear),a
                        ret

; the ship's universe bank in slot 6, the maths banked fns in slot 0
DockingAI:              call    IsSpaceStationPresent               ; carry clear if slot 0 is the station
                        jr      nc,.StationHere
.NoStation:             ld      a,(ShipNewBitsAddr)                 ; back to heading for the planet
                        and     ~ShipIsDocking & $FF
                        ld      (ShipNewBitsAddr),a
                        ret
.StationHere:           call    SaveMMU6                            ; the station's position and nose
                        MMUSelectUniverseN 0                        ; (this code is in slot 0, so slot 6 can change)
                        ld      hl,UBnKxlo
                        ld      de,DockStationPos
                        ld      bc,9
                        ldir
                        ld      hl,UBnkrotmatNosevX
                        ld      de,DockStationNose
                        ld      bc,6
                        ldir
                        call    RestoreMMU6                         ; the ship back
                        ld      ix,DockStationPos                   ; TacticsVector = ship - station
                        call    UnivBodyVector
                        call    DockRange
                        call    NormalizeTactics                    ; the unit vector from the station to the ship
                        ld      hl,DockStationNose+1                ; . the station's nose
                        call    CopyRotmatToTacticsMat
                        call    XX12EquTacticsDotHL                 ; a = |dot| (36 = 1.0), varS its sign
                        ld      b,a
                        ld      a,(varS)
                        and     SignOnly8Bit
                        jr      nz,.ToApproachPoint                 ; behind the station
                        ld      a,b
                        cp      DockConeDot
                        jr      c,.ToApproachPoint                  ; off to the side
.InFront:               ld      a,(DockNear)
                        bit     0,a
                        jr      nz,.Docked
                        call    UnivSteerNormalised                 ; for the station: TacticsVector is already the unit
                        jp      DockSlowDown                        ; vector from the station to the ship
.Docked:                ld      a,(SelectedUniverseSlot)            ; in the slot: gone from the universe
                        jp      ClearSlotA                          ; implicit ret
.ToApproachPoint:       DockApproachAxis 0
                        DockApproachAxis 1
                        DockApproachAxis 2
                        ld      ix,DockTargetPos                    ; TacticsVector = ship - the approach point
                        call    UnivBodyVector
                        call    UnivSteerToBody
; within DockSlowHi of the station: no faster than DockSpeed, or DockTurnSpeed while the nose isn't on the target (the
; nose dot from ShipSeekingLogic below DockAlignedDot, or behind), and no speeding up past it. A ship's AI turn is every 12 main
; loops, so at full speed it went past the slot (and through the station) between turns; and at DockSpeed its turning
; circle was wider than the station's approach, so it went round and round it
DockSlowDown:           ld      a,(DockNear)
                        bit     1,a
                        ret     z                                   ; not near yet
                        ld      b,DockSpeed
                        ld      a,(TacticsDotProduct1+1)            ; the nose dot's sign: behind
                        and     SignOnly8Bit
                        jr      nz,.Turning
                        ld      a,(TacticsDotProduct1)              ; or not yet near the target's direction
                        cp      DockAlignedDot
                        jr      nc,.Limit
.Turning:               ld      b,DockTurnSpeed
.Limit:                 ld      a,(UBnKSpeed)                       ; below b: ShipSpeedv3's acceleration stands
                        cp      b
                        ret     c
                        ld      a,b                                 ; else speed = b, and slowing down (ShipSpeedv3)
                        ld      (UBnKSpeed),a                       ; is kept, speeding up not
                        ld      a,(UBnKAccel)
                        and     SignOnly8Bit
                        ret     nz
                        ld      (UBnKAccel),a                       ; (a = 0)
                        ret
