AutoDocking				DB	0				; $033F						
PlayerECM				DB	0				; $0340				
Laser2					DB	0				; 0343 laser Power? Not sure 
LaserCount				DB	0				; 0346  LASCT  \ laser count =9 for pulse, cooled off?
Cash					DB  0,0,0,0			; 0361 - 0364 Cash now litte endian
Fuel					DB	25				; 0365  QQ14
CargoBaySize			DB	70				; 036E
CargoRunningLoad        DB  0
CargoTonnes             DB  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;CargoTonnes		    DB	16,1,2,3,4,5,6,7,6,9,10,11,12,13,14,15			; 036F - 037F	QQ20
SlaveCargoTonnes		equ CargoTonnes+3
NarcoticsCargoTonnes	equ CargoTonnes+6
FirearmsCargoTonnes		equ CargoTonnes+10
GoldCargoKGs:           equ CargoTonnes+15
AlienItemsTonnes        equ CargoTonnes+17
; For each view laser a localised copy of the stats
; TODO - need to add code to maintain on load/save/equipment transactions
LaserType               DS  4               ; quick reference to laser type
LaserDamagedFlag        DS  4               ; probabiliy out of 255 that it will no fire, 0 = good, 255 = will not fire
; dont need as static from table LaserPulseRate          DS  4               ; how many pulses can be fired before long pause
; dont need as static from table LaserPulsePause         DS  4               ; time before next pulse - 0 = beam
; dont need as static from table LaserPulseRest          DS  4               ; time before pulse count resets to 0
; dont need as static from table LaserDamageOutput       DS  4               ; amount of damage for a laser hit
; dont need as static from table LaserEnergyDrain        DS  4               ; amount of energy drained by cycle
; dont need as static from table LaserHeat               DS  4               ; amount of heat generated
; dont need as static from table LaserDurability         DS  4               ; probabability out of 255 that a hit on it unshielded will add random amount of damage
; dont need as static from table LaserDurabilityAmount   DS  4               ; max amount of damagage can be sustained in one damage hit
QQ20                    equ CargoTonnes
EquipmentFitted         DS  EQ_ITEM_COUNT    ; Series of flags for if each item is fitted
ECMPresent				EQU EquipmentFitted + EQ_ECM				; 0380
FuelScoop               EQU EquipmentFitted + EQ_FUEL_SCOOPS
EnergyBomb				EQU EquipmentFitted + EQ_ENERGY_BOMB		; 0382	Also random hyperspeace in Elite A
ExtraEnergyUnit			EQU EquipmentFitted + EQ_ENERGY_UNIT        ; 0383
DockingComputer 		EQU EquipmentFitted + EQ_DOCK_COMP    		; 0384
GalacticHyperDrive		EQU EquipmentFitted + EQ_GAL_DRIVE   		; 0385
EscapePod				EQU EquipmentFitted + EQ_ESCAPE_POD  		; 0386
FuelScoopsBarrelStatus	DB	1				; 0381
; Each item will have a DamagedFlag which will report on a scale 0 good 255 destroyed, and colour coded on a scale (will need a custom pallet now for the offsets)
; laser damage already there above, need moving here
; if item is not fitted then a not present is show on status lamps
ECMDamageStatus                 DS 1 ; percentage that it won't fire
EnergyBombDamageStatus          DS 1 ; As per missile, destruction causes ejection and loss
DockingComputerDamageStatus     DS 1 ; random chance of docking computer being unable to engage, once engaged will stay on until docked
GalacticHyperDriveDamageStatus  DS 1 ; Causes % chance of failure to launch, at 250% can cause a random galaxy jump +/-1 at 255, needs replacement
EscapePodDamageStatus           DS 1 ; until 255 then escape pod lost
FuelScoopDamageStatus           DS 1 ; rate of scooping, always able to trickle
CargoHoldDamageStatus           DS 1 ; random chance random item lost
WarpDriveDamageStatus           DS 1 ; random Bong mass locked
EnginesDamageStatus             DS 1 ; maximum speed random adjust a combination of max speed and random adjustments
ForeShieldDamageStatus          DS 1 ; energy drain rate on shield
AftShieldDamageStatus           DS 1 ; energy drain rate on shield
EnergyUnitDamageStatus          DS 1 ; percentage chance of recharge not occuring at 255 there will still be trickle charge at least
MissleLauncherDamageStatus      DS 1 ; Determines ability to lock and fire, once launched missile tracks independently 
MissleDamageStatus              DS 4 ; Damaging a missile causes it to be ejected & lost rather than explode
FuelDamageStatus                DS 1 ; percentage chance of a fuel leak of random amount
