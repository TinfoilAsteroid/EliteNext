EquipNameTableRowLen    EQU 8
ShipEquipNameTable      DW  WordFuel,       0,              0,          0
                        DW  WordMissile,    0,              0,          0
                        DW  WordLarge,      WordCargo,      WordBay,    0
                        DW  WordECM,        WordSystem,     0,          0
                        DW  WordFuel,       WordScoops,     0,          0
                        DW  WordEscape,     WordPod,        0,          0
                        DW  WordEnergy,     WordBomb,       0,          0
                        DW  WordExtra,      WordEnergy,     WordUnit,   0
                        DW  WordDocking,    WordComputers,  0,          0
                        DW  WordGalactic,   WordHyperdrive, 0,          0
                        DW  WordFront,      WordPulse,      WordLaser,  0
                        DW  WordRear,       WordPulse,      WordLaser,  0
                        DW  WordLeft,       WordPulse,      WordLaser,  0
                        DW  WordRight,      WordPulse,      WordLaser,  0
                        DW  WordFront,      WordBeam,       WordLaser,  0
                        DW  WordRear,       WordBeam,       WordLaser,  0
                        DW  WordLeft,       WordBeam,       WordLaser,  0
                        DW  WordRight,      WordBeam,       WordLaser,  0
                        DW  WordFront,      WordMining,     WordLaser,  0
                        DW  WordRear,       WordMining,     WordLaser,  0
                        DW  WordLeft,       WordMining,     WordLaser,  0
                        DW  WordRight,      WordMining,     WordLaser,  0
                        DW  WordFront,      WordMilitary,   WordLaser,  0
                        DW  WordRear,       WordMilitary,   WordLaser,  0
                        DW  WordLeft,       WordMilitary,   WordLaser,  0
                        DW  WordRight,      WordMilitary,   WordLaser,  0

ShipEquipmentFullName           ;012345678901234567890
    DISPLAY "TODO This coudl actually be used to dynamically build names of componets based on ship build"
    DISPLAY "TODO then we only need 1 laser for each facing and build the name"
EquipNameFuel:               DB "Fuel",0
EquipNameMissile:            DB "Missile",0
EquipNameLargeCargoBay       DB "Large Cargo Bay",0
EquipNameECMSystem           DB "ECM System",0
EquipNameFuelScoops          DB "Fuel Scoops",0
EquipNameEscapePod           DB "Escape Pod",0
EquipNameEnergyBomb          DB "Enerby Bomb",0
EquipNameExtraEnergyUnit     DB "Extra Energy Unit",0
EquipNameDockingComputers    DB "Docking Computers",0
EquipNameGalacticHyperdrive  DB "Galactic Hyperdrive",0
EquipNameFrontPulseLaser     DB "Fwd>Pulse Laser",0
EquipNameRearPulseLaser      DB "Aft>Pulse Laser",0
EquipNameLeftPulseLaser      DB "Lft>Pulse Laser",0
EquipNameRightPulseLaser     DB "Rgt>Pulse Laser",0
EquipNameFrontBeamLaser      DB "Fwd>Beam Laser",0
EquipNameRearBeamLaser       DB "Aft>Beam Laser",0
EquipNameLeftBeamLaser       DB "Lft>Beam Laser",0
EquipNameRightBeamLaser      DB "Rgt>Beam Laser",0
EquipNameFrontMiningLaser    DB "Fwd>Mining Laser",0
EquipNameRearMiningLaser     DB "Aft>Mining Laser",0
EquipNameLeftMiningLaser     DB "Lft>Mining Laser",0
EquipNameRightMiningLaser    DB "Rgt>Mining Laser",0
EquipNameFrontMilitaryLaser  DB "Fwd>Military Laser",0
EquipNameRearMilitaryLaser   DB "Aft>Military Laser",0
EquipNameLeftMilitaryLaser   DB "Lft>Military Laser",0
EquipNameRightMilitaryLaser  DB "Rgt>Military Laser",0
                                ;012345678901234567890
EquipNameIndex:         DW  EquipNameFuel               , EquipNameMissile           
                        DW  EquipNameLargeCargoBay      , EquipNameECMSystem         
                        DW  EquipNameFuelScoops         , EquipNameEscapePod         
                        DW  EquipNameEnergyBomb         , EquipNameExtraEnergyUnit   
                        DW  EquipNameDockingComputers   , EquipNameGalacticHyperdrive
                        DW  EquipNameFrontPulseLaser    , EquipNameRearPulseLaser    
                        DW  EquipNameLeftPulseLaser     , EquipNameRightPulseLaser   
                        DW  EquipNameFrontBeamLaser     , EquipNameRearBeamLaser     
                        DW  EquipNameLeftBeamLaser      , EquipNameRightBeamLaser    
                        DW  EquipNameFrontMiningLaser   , EquipNameRearMiningLaser   
                        DW  EquipNameLeftMiningLaser    , EquipNameRightMiningLaser  
                        DW  EquipNameFrontMilitaryLaser , EquipNameRearMilitaryLaser 
                        DW  EquipNameLeftMilitaryLaser  , EquipNameRightMilitaryLaser
    
; This needs to be expanded to cater for all lasertypes, cloak etc
    DISPLAY "TODO need to redo missiles as we need type in equipment as well as count, chagne save game to handle this"



ShipEquipmentList       DB  0, 0, 1, 1, low     2, high     2, EQ_FUEL          , 0     ,$FF , 0  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0, 1, 1, 1, low   300, high   300, EQ_MISSILE       , 0     ,$FF , 0  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0, 2, 1, 1, low  4000, high  4000, EQ_CARGO_BAY     , 0     ,$FF , 0  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0, 3, 1, 2, low  6000, high  6000, EQ_ECM           , 0     ,$FF , 0  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0, 4, 1, 5, low  5250, high  5250, EQ_FUEL_SCOOPS   , 0     ,$FF , 0  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0, 5, 1, 6, low 10000, high 10000, EQ_ESCAPE_POD    , 0     ,$FF , 0  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0, 6, 1, 7, low  9000, high  9000, EQ_ENERGY_BOMB   , 0     ,$FF , 0  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0, 7, 1, 8, low 15000, high 15000, EQ_ENERGY_UNIT   , 0     ,$FF , 0  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0, 8, 1, 9, low 15000, high 15000, EQ_DOCK_COMP     , 0     ,$FF , 0  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0, 9, 1,10, low 50000, high 50000, EQ_GAL_DRIVE     , 0     ,$FF , 0  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,10, 1, 3, low  4000, high  4000, EQ_FRONT_PULSE   , 0     ,$00 , 0  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,11, 1, 3, low  4000, high  4000, EQ_REAR_PULSE    , 0     ,$01 , 1  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,12, 1, 3, low  4000, high  4000, EQ_LEFT_PULSE    , 0     ,$02 , 2  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,13, 1, 3, low  4000, high  4000, EQ_RIGHT_PULSE   , 0     ,$03 , 3  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,14, 0, 4, low 10000, high 10000, EQ_FRONT_BEAM    , 0     ,$00 , 0  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,15, 0, 4, low 10000, high 10000, EQ_REAR_BEAM     , 0     ,$01 , 1  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,16, 0, 4, low 10000, high 10000, EQ_LEFT_BEAM     , 0     ,$02 , 2  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,17, 0, 4, low 10000, high 10000, EQ_RIGHT_BEAM    , 0     ,$03 , 3  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,18, 0,10, low  8000, high  8000, EQ_FRONT_MINING  , 0     ,$00 , 0  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,19, 0,10, low  8000, high  8000, EQ_REAR_MINING   , 0     ,$01 , 1  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,20, 0,10, low  8000, high  8000, EQ_LEFT_MINING   , 0     ,$02 , 2  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,21, 0,10, low  8000, high  8000, EQ_RIGHT_MINING  , 0     ,$03 , 3  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,22, 0,10, low 60000, high 60000, EQ_FRONT_MILITARY, 0     ,$00 , 0  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,23, 0,10, low 60000, high 60000, EQ_REAR_MILITARY , 0     ,$01 , 1  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,24, 0,10, low 60000, high 60000, EQ_LEFT_MILITARY , 0     ,$02 , 2  , 0  , 0  , 0  , 0  , 0 , 0
                        DB  0,25, 0,10, low 60000, high 60000, EQ_RIGHT_MILITARY, 0     ,$03 , 3  , 0  , 0  , 0  , 0  , 0 , 0
ShipEquipTableRowLen    EQU 16
ShipEquipTableSize      EQU ($-ShipEquipmentList)/ShipEquipTableRowLen
