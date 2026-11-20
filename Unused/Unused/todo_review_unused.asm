; Code nothing used (2026-11-20, the TODO list review): kept for reference.

; ---- from UniverseSlotRoutines.asm: ClearFreeSlotListSaveA: broken (it walked 48 bytes in steps of 2 and never counted its slot) and nothing called it
; Clears all except slot A, used when say restarting a space station post launch
ClearFreeSlotListSaveA: ld      d,a
                        ld      c,0
                        ld      hl,UniverseSlotList
                        ld      b, UniverseSlotListSize * 2
.fillLoop:              ld      a,c
                        cp      d
                        jr      z,.SkipSlot
                        ld      a,$FF
                        ld      (hl),a
.SkipSlot:              inc     hl
                        inc     hl
                        djnz    .fillLoop
                        ret

; ---- from SpawnObject.asm: SpawnMissileHandler / SpawnPlayerMissileHandler: never called; LaunchEnemyMissile and LaunchPlayerMissile (MainLoop.asm) do this
SpawnMissileHandler:            ld      a,(UbnKShipUnivBankNbr)             ; save current bank number
                                ld      (EnemyShipBank),a                   ;
                                ld      a,5
                                call    CalcLaunchOffset
                                ld      a,0                                 ; TODO For now only 1 missile type
                                GetByteAInTable ShipMissileTable            ; swap in missile data
                                call    SpawnShipTypeA                      ; spawn the ship
                                ret     c                                   ; return if failed
                                call    UnivSetEnemyMissile
                        PlaySFX SFXMissile                 ; as per player but sets as angry
                                ld      a,$FF
                                ld      (UBnKMissileTarget),a               ; set as definte player as target
                                ld      a,(EnemyShipBank)                   ; Direct restore current bank
                                MMUSelectUnivBankA                          ;
                                ld      hl, UBnKMissilesLeft                ; reduce enemy missile count
                                dec     (hl)
                                ret

SpawnPlayerMissileHandler:      ZeroA                                       ; TODO For now only 1 missile type
                                GetByteAInTable ShipMissileTable            ; swap in missile data
                                call    SpawnShipTypeA                      ; spawn the ship
                                jr      c,.MissileMissFire                  ; give a miss fire indicator as we have no slots
                                ld      a,(MissileTargettingFlag)           ; Get target from computer
                                ld      (UBnKMissileTarget),a               ; load target Data
                                call    UnivSetPlayerMissile                ; .
                                ClearMissileTargetting                      ; reset targetting
                                ld      hl, NbrMissiles
                                dec     (hl)
                                ret
.MissileMissFire:               ClearMissileTargetting
                                ret ; TODO bing bong noise misfire message

; ---- from Tactics.asm: CalcTargetVector: never called
CalcTargetVector:       ld      de,(TacticsTargetX)                        ; get target ship X
                        ld      a,(TacticsTargetX+2)                       ; and flip sign so we have missile - target
                        FlipSignBitA
                        ld      c,a                                 ; get target ship x sign but * -1 as we are subtracting
                        ld      hl,(UBnKxlo)                        ; get missile x
                        ld      a,(UBnKxsgn)                        ; get missile x sign
                        ld      b,a
                        call    ADDHLDESignBC                       ;AHL = BHL + CDE i.e. missile - target x
                        ld      (TacticsVectorX),hl
                        ld      (TacticsVectorX+2),a
.UpdateTargetingShipY:  ld      de,(TacticsTargetY)
                        ld      a,(TacticsTargetY+2)
                        FlipSignBitA
                        ld      c,a                                 ; get target ship x sign but * -1 as we are subtracting
                        ld      hl,(UBnKylo)                        ; get missile x
                        ld      a,(UBnKysgn)                        ; get missile x sign
                        ld      b,a
                        call    ADDHLDESignBC                       ;AHL = BHL + CDE i.e. missile - target x
                        ld      (TacticsVectorY),hl
                        ld      (TacticsVectorY+2),a
.UpdateTargetingShipZ:  ld      de,(TacticsTargetZ)
                        ld      a,(TacticsTargetZ+2)
                        FlipSignBitA
                        ld      c,a                                 ; get target ship x sign but * -1 as we are subtracting
                        ld      hl,(UBnKzlo)                        ; get missile x
                        ld      a,(UBnKzsgn)                        ; get missile x sign
                        ld      b,a
                        call    ADDHLDESignBC                       ;AHL = BHL + CDE i.e. missile - target x
                        ld      (TacticsVectorZ),hl
                        ld      (TacticsVectorZ+2),a
                        ret

; ---- from Tactics.asm: DebugTacticsCopy (TACTICSDEBUG): copied the rotation matrix every missile update for the missile diagnostics display (MISSILEDIAGNOSTICS, off)
                        IFDEF TACTICSDEBUG                        
DebugTacticsCopy:   
                        ld      hl,(UBnkrotmatSidevX)
                        ld      de,(UBnkrotmatSidevY)
                        ld      bc,(UBnkrotmatSidevZ)
                        ld      (TacticsSideX),hl
                        ld      (TacticsSideY),de
                        ld      (TacticsSideZ),bc

                        ld      hl,(UBnkrotmatRoofvX)
                        ld      de,(UBnkrotmatRoofvY)
                        ld      bc,(UBnkrotmatRoofvZ)
                        ld      (TacticsRoofX),hl
                        ld      (TacticsRoofY),de
                        ld      (TacticsRoofZ),bc

                        ld      hl,(UBnkrotmatNosevX)
                        ld      de,(UBnkrotmatNosevY)
                        ld      bc,(UBnkrotmatNosevZ)
                        ld      (TacticsNoseX),hl
                        ld      (TacticsNoseY),de
                        ld      (TacticsNoseZ),bc

                        ret
                        ENDIF

; ---- from MainLoop.asm: WeHaveCompletedHJump: commented out leftovers (CreateSun and CreatePlanet above do this)
;TODO                        call    generateSunAndPlanetPos        ; uses current carry state too
; PROBABLY NOT NEEDED NOW                      MMUSelectShipBank1
; PROBABLY NOT NEEDED NOW                      call    GetShipBankId
;;SELECT CORRECT BANK                        MMUSelectUniverseN 0
;;TODO                        call    CopyBodyToUniverse
;;TODO                        call    CreateSun
;;TODO                       MMUSelectShipBank1
;;TODO                    eliteb       call    GetShipBankId
;;TODO                       MMUSelectUniverseBankN 1
;;TODO                       call    CopyBodyToUniverse
