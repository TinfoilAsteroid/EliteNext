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
                        ld		(TargetPlanetX),a
                        ld		a,defaultHomeY
                        ld		(PresentSystemY),a
                        ld		(TargetPlanetY),a
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
                        ld      (EquipmentFitted+EQ_FRONT_PULSE),a
                        ld		(MissionData),a						;The Plan/Mission
                        xor     a
                        ld		(LaserList+1),a
                        ld		(LaserList+2),a
                        ld		(LaserList+3),a
                        ld      a,EQ_FRONT_PULSE
                        ld		(LaserList),a
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
                        ; more to DO	
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
                        