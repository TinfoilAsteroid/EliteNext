commanderPage           DB  "COMMANDERPAGE 56"
defaultName		        DB	"JAMESON",0
defaultStock	        DB $10, $0F, $11, $00, $03, $1C,$0E, $00, $00, $0A, $00, $11,$3A, $07, $09, $08, $00;
defaultSeeds	        DB $4a, $5a, $48, $02, $53, $b7
defaultHomeX	        equ $14
defaultHomeY	        equ $AD

 ; For now hard laod, later correctlt sequence gneeral vars and dma fill with 0 for a start
defaultCommander:       ld		de,CommanderName				;set commander name
                        ld		hl,defaultName
                        ld		bc,8
                        ldir
                        ld		de,GalaxySeeds
                        ld		hl,defaultSeeds
                        ld		bc,8
                        ldir	
                        ld		a,defaultHomeX
                        ld		(PresentSystemX),a
                        ld		(TargetSystemX),a
                        ld		a,defaultHomeY
                        ld		(PresentSystemY),a
                        ld		(TargetSystemY),a
	; testing
                        ld		hl,IndexedWork
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
                        ret     



                        ;TODO in load and save need ot preserve damage to guns, heat , ship etc i.e. run time state
                        
                        
                        
                        ; more to DO	
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
                        ld      b,a                             ; .
                        ld      a,(NarcoticsCargoTonnes)        ; .
                        add     b                               ; .
                        sla     a                               ; .
                        ld      b,a                             ;
                        ld      a,(FirearmsCargoTonnes)         ; Badness += firearms tonns    
                        add     b
                        ret
                        