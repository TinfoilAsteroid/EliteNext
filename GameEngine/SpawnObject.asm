
SpawnStationHandler:            call    SpawnShipTypeA
                                ret     c                                   ; abort if failed
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
                                
SpawnTypeCopHandler:            call    SpawnShipTypeA
                                ret     c                                   ; abort if failed
                                ; Cops will be non hostile if there are no other ones in area
                                ; if there are, then check out cargo and fist to evalutate
                                ; if not hostile and in space station area, then patrol orbiting station
                                ; if not in space station area even split on orbiting a random point in space at distance random
                                ;                                            travelling to station
                                ;                                            travelling to sun
                                ret
SpawnTypeTraderHandler:         call    SpawnShipTypeA
                                ret     c                                   ; abort if failed
                                ; 50/50 goign to planet or sun
                                ;                main loop AI determines if our FIST status will force a jump
                                ret
SpawnTypeNonTraderHandler:      call    SpawnShipTypeA
                                ret     c                                   ; abort if failed
                                ; 50/50 goign to planet or sun
                                ; if FIST is high then 10% chance will auto go hostile
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

SpawnTypeStationDebrisHandler: call    SpawnShipTypeA
                                ret     c                                   ; abort if failed
                                ;Set random position and vector
                                ret
SpawnTypeMissionEventHandler:
SpawnTypeDoNotSpawnHandler:    ret



SpawnHostileCop:        ld      a,ShipID_Viper
                        call    SpawnShipTypeA                      ; call rather than jump
                        call    SetShipHostile                      ; as we have correct universe banked in now
                        ret

SpawnTrader:       ; TODO

; DEFUNCT?SpawnAHostileHunter:    ld      hl, ExtraVesselsCounter             ; prevent the next spawning
; DEFUNCT?                        inc     (hl)                                ;
; DEFUNCT?                        and     3                                   ; a = random 0..3
; DEFUNCT?                        MMUSelectShipBank1
; DEFUNCT?                        GetByteAInTable ShipHunterTable             ; get hunter ship type
; DEFUNCT?                        call    SpawnShipTypeA
; DEFUNCT?                        call    SetShipHostile
; DEFUNCT?                        ret



; input IX = table for spawn data
; output A  = table type
;        b = maximum to spawn
;        de = spawn table address
;        hl = spawn handler address
SelectSpawnTableData:   ld      a,(ix+1*SpawnTableSize)             ; Table Type
                        ld      hl,SpawnTypeHandlers                ; hl = the call address for setting up a spawn
                        add     hl,a                                ; of type A
                        add     hl,a                                ; 
                        ld      b,(ix+2*SpawnTableSize)             ; Nbr to Spawn
                        ld      e,(ix+3*SpawnTableSize)             ; Spawn Table Addr Low
                        ld      d,(ix+4*SpawnTableSize)             ; Spawn Table Addr Hi
                        ret

; Output IX = pointer to correct row in table
; its up to the caller if DE is right table and it it needs to load into
; it is up to the main loop code to maintain SpaceStationSafeZone
SelectSpawnTable:       
.SelectCorrectTable:    JumpIfMemTrue SpaceStationSafeZone, .SelectSpaceStationTable
                        ld      ix,FreeSpaceSpawnTableLow
                        jp      .RandomShip
.SelectSpaceStationTable:ld      ix,StationSpawnTableLow
.RandomShip:            call    doRandom
.SelectLoop:            cp      (ix+0)                              ; Compare high value
                        ret     c                                   ; if random <= high threshold jump to match, we cant just do jr c as 255 would never compare
                        ret     z                                   ; if random <= high threshold jump to match, result is, last values must be 255
                        inc     ix                                  ; move to next row
                        jp      .SelectLoop                         ; we have a 255 marker to stop infinite loop

; Returns with carry set if no ship to spawn
; In = hl = address of first byte of table
SelectSpawnType:        ld      b,3                                 ; maxium of 3 goes
                        ld      iy,hl                               ; save hl as we may need it if the spawn is too high rank
.SelectSpawnType:       call    doRandom
                        and     %00001111                           ; random 1 to 15
                        sla     a                                   ; * 2 as its 2 bytes per row
                        add     hl,a
                        ld      a,(hl)
                        ld      b,a
                        ld      a,(CurrentRank)                     ; are we experienced enough to face this ship
                        JumpIfAGTENusng b, .GoodToSpawn             ; if current rank >= table rank, we are good
.TooLowRank:            ld      hl,iy
                        djnz    .SelectSpawnType                    ; 3 goes then fail out
.NoSpawn:               SetCarryFlag
                        ret
.GoodToSpawn:           ld      a,8                                 ; so we shift by 8
                        add     hl,a                                ; to get to the ship id
                        ld      a,(hl)                              ; and fetch it in a
                        ClearCarryFlag
                        ret

; Spawn table is in two halves. if we are within range X of space station we use the second table
; thsi means we coudl in theory drag a hunter / pirate or thargoid say into a space station zone
; Probability high
; Class of table,       0=Station,
; Table to pick from (this is then based on ranking )

; Its prefilled to 8 options in the table to allocate space. though the table can only accomodate 8. ther eis a 9th as a marker, value of table = 0 means no spawn
FreeSpaceSpawnTableLow:    DB 84,                       159,                            250,                            255,                        255,                 255,                 255,                 255               
FreeSpaceSpawnTableType:   DB SpawnTypeCop,             SpawnTypeTrader,                SpawnTypeNonTrader,             SpawnTypePirate,            SpawnTypeDoNotSpawn, SpawnTypeDoNotSpawn, SpawnTypeDoNotSpawn, SpawnTypeDoNotSpawn
FreeSpaceSpawnTableCount:  DB 1,                        1,                              1,                              2,                          0,                   0,                   0,                   0
FreeSpaceSpawnTableAddrLo: DB low(ShipCopTableARank),   low(ShipNonTraderTableARank),   low(ShipNonTraderTableARank),   low(ShipPirateTableARank),  low(0),              low(0),              low(0),              low(0)
FreeSpaceSpawnTableAddrHi: DB high(ShipCopTableARank),  high(ShipNonTraderTableARank),  high(ShipNonTraderTableARank),  high(ShipPirateTableARank), high(0),             high(0),             high(0),             high(0)

StationSpawnTableLow:      DB 84,                       159,                            250,                            255,                        255,                 255,                 255,                 255
StationSpawnTableType:     DB SpawnTypeCop,             SpawnTypeTrader,                SpawnTypeNonTrader,             SpawnTypePirate,            SpawnTypeDoNotSpawn, SpawnTypeDoNotSpawn, SpawnTypeDoNotSpawn, SpawnTypeDoNotSpawn
StationSpawnTableCount:    DB 1,                        1,                              1,                              3,                          0,                   0,                   0,                   0
StationSpawnTableAddrLo:   DB low(ShipCopTableARank),   low(ShipNonTraderTableARank),   low(ShipNonTraderTableARank),   low(ShipPirateTableARank),  low(0),              low(0),              low(0),              low(0)             
StationSpawnTableAddrHi:   DB high(ShipCopTableARank),  high(ShipNonTraderTableARank),  high(ShipNonTraderTableARank),  high(ShipPirateTableARank), high(0),             high(0),             high(0),             high(0)

SpawnTableSize             EQU  FreeSpaceSpawnTableType - FreeSpaceSpawnTableLow

; Looko in constant equates, Spawntype equates for the values for this jump table
; note at minium it must itmust point to SpawnTypeDoNotSpawnHandlers which just does a ret
SpawnTypeHandlers:         DW SpawnStationHandler,       SpawnAsteroidHandler,      SpawnTypeJunkHandler,          SpawnTypeCopHandler
                           DW SpawnTypeTraderHandler,    SpawnTypeNonTraderHandler, SpawnTypePirateHandler,        SpawnTypeHunterHandler
                           DW SpawnTypeThargoidHandler,  SpawnTypeMissionHandler,   SpawnTypeStationDebrisHandler, SpawnTypeMissionEventHandler
                           DW SpawnTypeDoNotSpawnHandler