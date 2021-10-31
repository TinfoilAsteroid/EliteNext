AutoDocking				DB	0				; $033F						
PlayerECM				DB	0				; $0340				
Laser2					DB	0				; 0343 laser Power? Not sure 
LaserCount				DB	0				; 0346  LASCT  \ laser count =9 for pulse, cooled off?
Cash					DB  0,0,0,0			; 0361 - 0364 Cash now litte endian
Fuel					DB	25				; 0365  QQ14
LaserList				DB	5,2,3,1			; View Lasers $0368 to $036B
CargoBaySize			DB	70				; 036E
CargoRunningLoad        DB  0
CargoTonnes             DB  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;CargoTonnes		    DB	16,1,2,3,4,5,6,7,6,9,10,11,12,13,14,15			; 036F - 037F	QQ20
SlaveCargoTonnes		equ CargoTonnes+3
NarcoticsCargoTonnes	equ CargoTonnes+6
FirearmsCargoTonnes		equ CargoTonnes+10

QQ20                    equ CargoTonnes
EquipmentFitted         DS  EQ_ITEM_COUNT    ; Series of flags for if each item is fitted
ECMPresent				EQU EquipmentFitted + EQ_ECM				; 0380
EnergyBomb				EQU EquipmentFitted + EQ_ENERGY_BOMB		; 0382	Also random hyperspeace in Elite A
ExtraEnergyUnit			EQU EquipmentFitted + EQ_ENERGY_UNIT        ; 0383
DockingComputer 		EQU EquipmentFitted + EQ_DOCK_COMP    		; 0384
GalacticHyperDrive		EQU EquipmentFitted + EQ_GAL_DRIVE   		; 0385
EscapePod				EQU EquipmentFitted + EQ_ESCAPE_POD  		; 0386
FuelScoopsBarrelStatus	DB	1				; 0381
