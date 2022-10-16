commanderPage           DB  "COMMANDERPAGE 56"
defaultName		        DB	"JAMESON",0
defaultStock	        DB $10, $0F, $11, $00, $03, $1C,$0E, $00, $00, $0A, $00, $11,$3A, $07, $09, $08, $00
defaultSeeds	        DB $4a, $5a, $48, $02, $53, $b7
defaultHomeX	        DB $14
defaultHomeY	        DB $AD
defaultSaveName         DB "Default.SAV",0,0,0,0

; Gun and cabin temps are not saved as can only be saved in dock
; Note Can only save whilst docked
SaveCommanderHeader     DB  "COMMANDERSAVE..."
SaveFilename            DS  15
SaveCommanderName       DS  15
SaveSeeds               DS  06
SaveStockAvaliabiliy    DS  17
SaveCargo               DS  16
SaveEquipmentFitted     DS  EQ_ITEM_COUNT
SaveLaserType           DS  4
SaveLaserDamagedFlag    DS  4
SavePresentSystemX      DS  1 
SavePresentSystemY      DS  1
SaveTargetSystemX       DS  1
SaveTargetSystemY       DS  1
SaveCash                DS  4
SaveFuel                DS  1
SaveFugitiveInnocentStatus DS 1
SaveKillTally           DS  2
SaveOuterHyperCount     DS  1
SaveInnerHyperCount     DS  1
SaveForeShield          DS  1
SaveAftShield           DS  1
SavePlayerEnergy        DS  1
SaveCargoBaySize        DS  1
SaveFuelScoopStatus     DS  1
SaveSize                equ $ - SaveCommanderHeader

copyCommanderToSave:    ldCopyStringLen CommanderName,      SaveCommanderName, 15
                        ldCopyStringLen GalaxySeeds,        SaveSeeds, 6
                        ldCopyStringLen StockAvaliabiliy,   SaveStockAvaliabiliy, 16
                        ldCopyStringLen CargoTonnes,        SaveCargo, 16
                        ldCopyStringLen EquipmentFitted,    SaveEquipmentFitted, EQ_ITEM_COUNT
                        ldCopyStringLen LaserType,          SaveLaserType, 4
                        ldCopyStringLen LaserDamagedFlag,   SaveLaserDamagedFlag, 4
                        ldCopy2Byte     PresentSystemX,     SavePresentSystemX
                        ldCopy2Byte     TargetSystemX,      SaveTargetSystemX
                        ldCopyStringLen Cash,               SaveCash, 6
                        ldCopyByte      Fuel,               SaveFuel
                        ldCopyByte      FugitiveInnocentStatus,  SaveFugitiveInnocentStatus
                        ldCopy2Byte     KillTally           ,SaveKillTally
                        ldCopyByte      OuterHyperCount     ,SaveOuterHyperCount
                        ldCopyByte      InnerHyperCount     ,SaveInnerHyperCount
                        ldCopyByte      ForeShield          ,SaveForeShield     
                        ldCopyByte      AftShield           ,SaveAftShield      
                        ldCopyByte      PlayerEnergy        ,SavePlayerEnergy   
                        ldCopyByte      CargoBaySize        ,SaveCargoBaySize   
                        ldCopyByte      FuelScoopsBarrelStatus     ,SaveFuelScoopStatus
                        ret

copyCommanderFromSave:  ldCopyStringLen SaveCommanderName,      CommanderName, 15
                        ldCopyStringLen SaveSeeds,              GalaxySeeds, 6
                        ldCopyStringLen SaveStockAvaliabiliy,   StockAvaliabiliy, 16
                        ldCopyStringLen SaveCargo,              CargoTonnes, 16
                        ldCopyStringLen SaveEquipmentFitted,    EquipmentFitted, EQ_ITEM_COUNT
                        ldCopyStringLen SaveLaserType,          LaserType, 4
                        ldCopyStringLen SaveLaserDamagedFlag,    LaserDamagedFlag, 4
                        ldCopy2Byte     SavePresentSystemX,     PresentSystemX
                        ldCopy2Byte     SaveTargetSystemX,      TargetSystemX
                        ld		hl,IndexedWork              ; not sure yet why thisis done here
                        call	        copy_galaxy_to_system
                        call	        find_present_system
                        call	        copy_working_to_galaxy
                        ldCopyStringLen SaveCash,               Cash, 6
                        ldCopyByte      SaveFuel,               Fuel
                        ldCopyByte      SaveFugitiveInnocentStatus,  FugitiveInnocentStatus
                        ldCopy2Byte     SaveKillTally           ,KillTally
                        ldCopyByte      SaveOuterHyperCount     ,OuterHyperCount
                        ldCopyByte      SaveInnerHyperCount     ,InnerHyperCount
                        ldCopyByte      SaveForeShield          ,ForeShield     
                        ldCopyByte      SaveAftShield           ,AftShield      
                        ldCopyByte      SavePlayerEnergy        ,PlayerEnergy   
                        ldCopyByte      SaveCargoBaySize        ,CargoBaySize   
                        ldCopyByte      SaveFuelScoopStatus     ,FuelScoopsBarrelStatus
                        ret

saveCommander:          call    copyCommanderToSave
                        ldCopyStringLen defaultSaveName, SaveFilename, 15
                        ld      hl, defaultSaveName             ; default debug name
                        ld      ix, SaveCommanderHeader
                        ld      bc, SaveSize
                        call    FileSave
                        ret
                        
loadCommander:          ld      hl, defaultSaveName             ; default debug name
                        ld      ix, SaveCommanderHeader
                        ld      bc, SaveSize
                        call    FileLoad
                        call    copyCommanderFromSave
                        ClearMissileTargetting
                        call    SetPlayerRank
                        ret
                        
 ; For now hard laod, later correctlt sequence gneeral vars and dma fill with 0 for a start
defaultCommander:       ldCopyStringLen defaultName, CommanderName, 8
                        ldCopyStringLen defaultSeeds, GalaxySeeds, 6
                        ldCopy2Byte defaultHomeX, PresentSystemX
                        ldCopy2Byte defaultHomeX, TargetSystemX
                        ld		hl,IndexedWork              ; not sure yet why thisis done here
                        call	copy_galaxy_to_system
                        call	find_present_system
                        call	copy_working_to_galaxy
                        ld      bc,60000
                        ld      (Cash),bc
                        ld		bc,0
                        ld		(Cash+2), bc                    ; cash no longer big endian
                        ld		a,MaxFuelLevel
                        ld		(Fuel),a
                        ld      a,BankGalaxyData0
                        ld		(Galaxy),a
                        xor		a
                        ld      hl,EquipmentFitted
                        ld      b, EQ_ITEM_COUNT
.ClearFittedLooop:      ld      (hl),a
                        inc     hl
                        djnz    .ClearFittedLooop
                        SetAFalse
                        ld      (EquipmentFitted+EQ_FRONT_BEAM),a
                        ld		(MissionData),a						;The Plan/Mission
                        ld      a,4                                  ; a = 0 = pulse laser
                        ld		(LaserType),a
                        ld      a,$FF                                 ; a = 255
                        ld		(LaserType+1),a
                        ld		(LaserType+2),a
                        ld		(LaserType+3),a
                        xor     a                                  ; a= 0
                        ld      (LaserDamagedFlag),a
                        ld      (LaserDamagedFlag+1),a
                        ld      (LaserDamagedFlag+2),a
                        ld      (LaserDamagedFlag+3),a
; REMOVE?             ld      a,EQ_FRONT_PULSE
                        xor     a
                        ld		(ECMPresent),a
                        ld		(FuelScoopsBarrelStatus),a
                        ld		(EnergyBomb),a
                        ld		(ExtraEnergyUnit),a
                        ld		(DockingComputer),a
                        ld		(GalacticHyperDrive),a
                        ld		(EscapePod),a
                        ld      (FugitiveInnocentStatus),a
                        ld		(KillTally),a
                        ld      (OuterHyperCount),a
                        ld      (InnerHyperCount),a
                        dec		a								; now a = 255
                        ld		(ForeShield),a
                        ld		(AftShield),a
                        ld		(PlayerEnergy),a
                        ld		a,20
                        ld		(CargoBaySize),a
                        call	ZeroCargo						; Clear out cargo
.SetLasers:             ld      a,0                             ; we start on Front view
                        call    LoadLaserToCurrent
                        ClearMissileTargetting
                        call    SetPlayerRank
                        ret     


; a = current view number
LoadLaserToCurrent:     ld      hl,LaserType                    ; .
                        add     hl,a                            ; .
                        ld      a,(hl)                          ; .
                        ld      b,a                             ; first off is there a laser present in current view
                        ld      (CurrLaserType),a               ; set type
                        cp      255                             ; .
                        ret     z                               ; we can then drop out early if nothing fitted
                        ld      a,4                             ; Damage state is in next variable in memory
                        add     hl,a
                        ld      a,(hl)
                        ld      (CurrLaserDamage),a             ; copy over current laser's damage
                        ld      d,b                             ; get table index
                        ld      e,LaserStatsTableWidth          ;
                        mul     de                              ;
                        ld      hl,LaserStatsTable              ;
                        add     hl,de                           ;
                        inc     hl                              ; we already have type
                        ldAtHLtoMem CurrLaserPulseRate          ; table [1]
                        inc     hl                              ; table [2]
                        ldAtHLtoMem CurrLaserPulseOnTime        
                        inc     hl                              ; table [3]
                        ldAtHLtoMem CurrLaserPulseOffTime
                        inc     hl                              ; table [4]
                        ldAtHLtoMem CurrLaserPulseRest
                        inc     hl                              ; table [5]
                        ldAtHLtoMem CurrLaserDamageOutput                        
                        inc     hl                              ; table [6]
                        ldAtHLtoMem CurrLaserEnergyDrain   
                        inc     hl                              ; table [7]
                        ldAtHLtoMem CurrLaserHeat
                        inc     hl                              ; table [8]
                        ldAtHLtoMem CurrLaserDurability
                        inc     hl                              ; table [9]
                        ldAtHLtoMem CurrLaserDurabilityAmount   ; we don't need tech level etc for in game run only markets so stop here
                        ret

; Set a = 2 * (slaves + narcotics) + firearms
calculateBadness:       ld      a,(SlaveCargoTonnes)            ; Badness = 2(slaves + narcotics)
                        ld      b,a                             ; b= slaves 
                        ld      a,(NarcoticsCargoTonnes)        ; .
                        add     a,b                             ; a = b + narcotics
                        sla     a                               ; a *= 2
                        ld      b,a                             ; b = a
                        ld      a,(FirearmsCargoTonnes)         ; a = firearms tonns    
                        add     a,b                             ; a += b so firearms + 2(slaves + narcotics)
                        ret
                        
PlayerDeath:            call    copyCommanderFromSave           ; load last loaded/saved commander
                        ZeroA                                   ; set current laser to front
                        call    LoadLaserToCurrent
                        call    InitMainLoop
                        call    ResetPlayerShip
                        ret
                    ;    clear out all other objects
                    ;    create debris 
                    ;    if cargo presetn then create a cargo
                    ;    
                    ;    enqueve message game over
                    ;    go to load commander page