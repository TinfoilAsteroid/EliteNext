
SpawnMissileHandler:            ld      a,(UbnKShipUnivBankNbr)             ; save current bank number
                                ld      (EnemyShipBank),a                   ;
                                ld      a,5
                                call    CalcLaunchOffset
                                ld      a,0                                 ; TODO For now only 1 missile type
                                GetByteAInTable ShipMissileTable            ; swap in missile data
                                call    SpawnShipTypeA                      ; spawn the ship
                                ret     c                                   ; return if failed
                                call    UnivSetEnemyMissile                 ; as per player but sets as angry
                                ld      a,$FF
                                ld      (UBnKMissileTarget),a               ; set as definte player as target
                                ld      a,(EnemyShipBank)                   ; Direct restore current bank
                                MMUSelectUnivBankA                          ;
                                ld      hl, UBnKMissilesLeft                ; reduce enemy missile count
                                dec     (hl)
                                ret

            DISPLAY "TODO: FOR NOW ONLY 1 MISSILE TYPE"
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
            DISPLAY "TODO: handle removal of missile from inventory and console"
                                ret
.MissileMissFire:               ClearMissileTargetting
                                ret ; TODO bing bong noise misfire message


SpawnStationHandler:            call    SpawnShipTypeA
                                ret     c                                   ; abort if failed
                                ; extra code goes here
                                ret

SpawnHermitHandler:             call    SpawnShipTypeA
                                ret     c                                   ; abort if failed
                                ret

SpawnAsteroidHandler:           call    SpawnShipTypeA
                                ret     c                                   ; abort if failed
                                ;Set random position and vector
                                ; if its a hermit jump to that to so special

                                ret

SpawnTypeJunkHandler:           push    af
                                TestRoomForJunk .CanAddJunk
                                ret
.CanAddJunk:                    pop     af
                                call    SpawnShipTypeA
                                AddJunkCount
                                ret     c                                   ; abort if failed
                                ret

SpawnTypeCopHandler:            call    SpawnShipTypeA                      ; will add logic later for alignment etc
                                ret     c                                   ; abort if failed
                                ; Cops will be non hostile if there are no other ones in area
                                ; if there are, then check out cargo and fist to evalutate
                                ; if not hostile and in space station area, then patrol orbiting station
                                ; if not in space station area even split on orbiting a random point in space at distance random
                                ;                                            travelling to station
                                ;                                            travelling to sun
                                call    UnivSetAIOnly
                                ret
SpawnTypeTraderHandler:         call    SpawnShipTypeA
                                ret     c                                   ; abort if failed
                                call    UnivSetAIOnly
                                ; 50/50 goign to planet or sun
                                ;                main loop AI determines if our FIST status will force a jump
                                ret

SpawnTypeNonTraderHandler:      call    SpawnShipTypeA
                                ret     c                                   ; abort if failed
                                ; 50/50 goign to planet or sun
                                ; if FIST is high then 10% chance will auto go hostile
                                call    UnivSetAIOnly
                                ret

SpawnTypePirateHandler:         call    SpawnShipTypeA
                                ret     c                                   ; abort if failed
                                ; set random position
                                ; 50/50 going to station or sun
                                ; if in safe zone, then not hostile
                                ; work out value of our cargo then go auto hostile (e.g. gems/gold, special carry nuke mission has cargo so valueable it auto sets hostile)
                                AddPirateCount                              ; another pirate has been spawned
                                ret
SpawnTypeHunterHandler:         call    SpawnShipTypeA
                                ret     c                                   ; abort if failed
                                ; initially hunters will be non hostile and by default going to station
                                ; set random position
                                ; 50/50 going to station or sun
                                ; Check out FIST status, if very high auto hostile
                                ; else its checked on ship event loop
                                ret
SpawnTypeThargoidHandler:       call    SpawnShipTypeA
                                ret     c                                   ; abort if failed
                                ; initially non hostile, main AI does logic (ie.. they will go hostile always after a random time or if shot at)
                                ; start in random position
                                ret
SpawnTypeMissionHandler:        ret

SpawnTypeStationDebrisHandler:  call    SpawnShipTypeA
                                ret     c                                   ; abort if failed
                                ;Set random position and vector
                                ret
SpawnTypeMissionEventHandler:
SpawnTypeDoNotSpawnHandler:     ret



SpawnHostileCop:                ld      a,ShipID_Viper
                                call    SpawnShipTypeA                      ; call rather than jump
                                call    SetShipHostile                      ; as we have correct universe banked in now
                                ret
            DISPLAY "TODO: SPAWN TRADER"
SpawnTrader:       ; TODO

; DEFUNCT?SpawnAHostileHunter:    ld      hl, ExtraVesselsCounter             ; prevent the next spawning
; DEFUNCT?                        inc     (hl)                                ;
; DEFUNCT?                        and     3                                   ; a = random 0..3
; DEFUNCT?                        MMUSelectShipBank1
; DEFUNCT?                        GetByteAInTable ShipHunterTable             ; get hunter ship type
; DEFUNCT?                        call    SpawnShipTypeA
; DEFUNCT?                        call    SetShipHostile
; DEFUNCT?                        ret


;-------------------------------------------------------------------
; input IX = table for spawn data
; output b = maximum to spawn (0 means no spawn)
;        de = spawn table address (0 means no spawn)
;        iy = hl  = spawn handler routine address
    DISPLAY "TODO: SelectSpawnTableData needs algorithim for selecting the spawn rank table based on commander, galaxy etc"
    DISPLAY "TODO: SelectSpawnTableData for now only does basic 'A' table selection"
SelectSpawnTableData:   
                        ;ld      a,(ix+1*SpawnTableSize)             ; Table Type, e.g. SpawnTypeTrader being an off set (SpaceStatoin = 0, Trader = 4 etc)
                        ;ld      hl,SpawnTypeHandlers                ; hl = the location in spawn hanlder routine look up table for the call address for setting up a spawn
                        ;add     hl,a                                ; adjust for 2 * A to get the address of the respective spawn hanlder routine
                        ;add     hl,a                                ; .
                        ;ld      a,(hl)                              ; then get the address from that table into HL
                        ;inc     hl                                  ; .
                        ;ld      h,(hl)                              ; .
                        ;ld      l,a                                 ; hl now is proper address
                        ld      b,(ix+2*SpawnTableSize)             ; Get Nbr of objects to  Spawn
                        ld      e,(ix+3*SpawnTableSize)             ; Spawn Rank Table Addr Low
                        ld      d,(ix+4*SpawnTableSize)             ; Spawn Rank Table Addr Hi
                        ld      l,(ix+5*SpawnTableSize)             ; address of spawn routine
                        ld      h,(ix+6*SpawnTableSize)    
                        ret
;-------------------------------------------------------------------
; Picks a random number and then sets ix to the column where table low >= random number
; Output IX = pointer to address of correct column in table Fress Space Spawn Table
; its up to the caller if DE is right table and it it needs to load into
; it is up to the main loop code to maintain SpaceStationSafeZone
; if in safe zone then uses StationSpawnTable
SelectSpawnTable:       JumpIfMemTrue SpaceStationSafeZone, .SelectStationTable ; if in space station safe zone switch to the corresponding table
                        ld      ix,FreeSpaceSpawnTableLow           ; else we use free space table
                        jp      .RandomShip                         ; and now do a random number
.SelectStationTable:    ld      ix,StationSpawnTableLow             ; here we selected safe zone table
.RandomShip:            call    doRandom                            ; random number
.SelectLoop:            cp      (ix+0)                              ; Compare high value
                        ret     c                                   ; if random <= high threshold jump to match, we cant just do jr c as 255 would never compare
                        ret     z                                   ; if random <= high threshold jump to match, result is, last values must be 255
                        inc     ix                                  ; move to next row
                        jp      .SelectLoop                         ; we have a 255 marker to stop infinite loop
;-------------------------------------------------------------------
; takes ship rank table at address hl, adds random number from 0 to 16
; entering here all decisions have already been made on what to spawn
; In = hl = address of first byte of table
; returns b with rank, c with ship id for ship type
SelectSpawnType:        push    hl                                  ; save hl for random, de not affected by doRandom
                        call    doRandom                            ; random number 0 to 7
                        pop     hl
                        and     %00000111                           ; .
                        add     hl,a                                ; hl = row 1 on rank table
                        ld      a,(hl)                              ; b = rank to be spawned, removed the limit now as the rank table selection should dictate this
                        ld      b,a                                 
                        ld      a,8                                 ; move to next row of rank table which is ship type
                        add     hl,a
                        ld      a,(hl)
                        ld      c,a                                 ; so now b = rank, c = type
                        ret                                         ; we are only selecting a candidate so no need for carry flag logic anymore
                        
                        ;ld      a,(CurrentRank)                     ; are we experienced enough to face this ship
                        ;JumpIfAGTENusng b, .GoodToSpawn             ; if current rank >= table rank, we are good
;.TooLowRank:            ld      hl,iy
;                        djnz    .SelectSpawnType                    ; 3 goes then fail out
;.NoSpawn:               SetCarryFlag
;                        ret
;GoodToSpawn:           ClearCarryFlag                              ; carry is clear as we are 
;                       ret

; Spawn table is in two halves. if we are within range X of space station we use the second table
; thsi means we coudl in theory drag a hunter / pirate or thargoid say into a space station zone
; Probability high
; Class of table,       0=Station,
; Table to pick from (this is then based on ranking )

;----------------------------------------------------------------------
; Free space spawn table. select a column on the tabel to determine the
; row (table low, type, count, addr) to spawn
; each row is 8 bytes so uses ix as an index into here generally
; Its prefilled to 8 options in the table to allocate space. though the table can only accomodate 8. ther eis a 9th as a marker, value of table = 0 means no spawn
; Last value on TableLow Low Column must be 255 to avoid unexpected stuff happening
; SpawnTableCount is a bit mask for random number generator, random is or'ed with 1 so mask of 2 will still generate 1 or 2
FreeSpaceSpawnTableLow:     DB 84,                       159,                            250,                            253,                         255,                             255,                             255,                             255
FreeSpaceSpawnTableType:    DB SpawnTypeCop,             SpawnTypeTrader,                SpawnTypeNonTrader,             SpawnTypePirate,             SpawnTypeBodies,                 SpawnTypeDoNotSpawn,             SpawnTypeDoNotSpawn,             SpawnTypeDoNotSpawn
FreeSpaceSpawnTableCount:   DB 1,                        1,                              1,                              2,                           0,                               0,                               0,                               0
FreeSpaceSpawnTableAddrLo:  DB low(ShipCopTableARank),   low(ShipNonTraderTableARank),   low(ShipNonTraderTableARank),   low(ShipPirateTableARank),   low(ShipBodiesTableARank),       low(0),                          low(0),                          low(0)
FreeSpaceSpawnTableAddrHi:  DB high(ShipCopTableARank),  high(ShipNonTraderTableARank),  high(ShipNonTraderTableARank),  high(ShipPirateTableARank),  high(ShipBodiesTableARank),      high(0),                         high(0),                         high(0)
FreeSpaceSpawnHandlerAddrLo:DB low(SpawnTypeCopHandler), low(SpawnTypeTraderHandler),    low(SpawnTypeNonTraderHandler), low(SpawnTypePirateHandler), low(SpawnAsteroidHandler),       low(SpawnTypeDoNotSpawnHandler), low(SpawnTypeDoNotSpawnHandler), low(SpawnTypeDoNotSpawnHandler)
FreeSpaceSpawnHandlerAddrHi:DB high(SpawnTypeCopHandler),high(SpawnTypeTraderHandler),   high(SpawnTypeNonTraderHandler),high(SpawnTypePirateHandler),high(SpawnAsteroidHandler),      high(SpawnTypeDoNotSpawnHandler),high(SpawnTypeDoNotSpawnHandler),high(SpawnTypeDoNotSpawnHandler)

StationSpawnTableLow:       DB 84,                       159,                            250,                            255,                         255,                             255,                             255,                             255
StationSpawnTableType:      DB SpawnTypeCop,             SpawnTypeTrader,                SpawnTypeNonTrader,             SpawnTypePirate,             SpawnTypeDoNotSpawn,             SpawnTypeDoNotSpawn,             SpawnTypeDoNotSpawn,             SpawnTypeDoNotSpawn
StationSpawnTableCount:     DB 1,                        1,                              1,                              3,                           0,                               0,                               0,                               0
StationSpawnTableAddrLo:    DB low(ShipCopTableARank),   low(ShipNonTraderTableARank),   low(ShipNonTraderTableARank),   low(ShipPirateTableARank),   low(0),                          low(0),                          low(0),                          low(0)
StationSpawnTableAddrHi:    DB high(ShipCopTableARank),  high(ShipNonTraderTableARank),  high(ShipNonTraderTableARank),  high(ShipPirateTableARank),  high(0),                         high(0),                         high(0),                         high(0)
StationSpawnHandlerAddrLo:  DB low(SpawnTypeCopHandler), low(SpawnTypeTraderHandler),    low(SpawnTypeNonTraderHandler), low(SpawnTypePirateHandler), low(SpawnTypeDoNotSpawnHandler), low(SpawnTypeDoNotSpawnHandler), low(SpawnTypeDoNotSpawnHandler), low(SpawnTypeDoNotSpawnHandler)
StationSpawnHandlerAddrHi:  DB high(SpawnTypeCopHandler),high(SpawnTypeTraderHandler),   high(SpawnTypeNonTraderHandler),high(SpawnTypePirateHandler),high(SpawnTypeDoNotSpawnHandler),high(SpawnTypeDoNotSpawnHandler),high(SpawnTypeDoNotSpawnHandler),high(SpawnTypeDoNotSpawnHandler)

SpawnTableSize             EQU  FreeSpaceSpawnTableType - FreeSpaceSpawnTableLow

; Looko in constant equates, Spawntype equates for the values for this jump table
; note at minium it must itmust point to SpawnTypeDoNotSpawnHandlers which just does a ret
SpawnTypeHandlers:         DW SpawnStationHandler,       SpawnAsteroidHandler,      SpawnTypeJunkHandler,          SpawnTypeCopHandler
                           DW SpawnTypeTraderHandler,    SpawnTypeNonTraderHandler, SpawnTypePirateHandler,        SpawnTypeHunterHandler
                           DW SpawnTypeThargoidHandler,  SpawnTypeMissionHandler,   SpawnTypeStationDebrisHandler, SpawnTypeMissionEventHandler
                           DW SpawnTypeDoNotSpawnHandler