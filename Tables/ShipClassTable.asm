        DISPLAY "TODO : Can we move all tables into MMU Zero?"
; Note when selecting its skewed by rank which ads a filter so bigger ships should be later in the table
; More optimal will be to order all the ships and then have an entry point and length of tablea

; Each ship type table is constructed as follows
; Header - nbr of ships
; table of min rank 
; table of ship ids
; note unless "SelectSpawnType" is changed we can't put this in location $0000 as it doesn't check L in HL for speed (thsi could be done though)

; we may nneed to rebuidl these tables for cp instruction so its max rank not min
; Coding limit for simplicity, each table has 15 ships in it
ShipPirateTableARank:    DB RankingEQHarmless, RankingEQHarmless, RankingEQMostly,   RankingEQMostly,     RankingEQPoor,     RankingEQAverage,   RankingEQDeadly,    RankingEQDeadly
ShipPirateTableA:        DB ShipID_Sidewinder, ShipID_Adder,      ShipID_Asp_Mk_2,   ShipID_Cobra_Mk_3_P, ShipID_Boulder,    ShipID_Bushmaster,  ShipID_Python_P,    ShipID_Anaconda    

ShipPirateTableBRank:    DB RankingEQHarmless, RankingEQMostly,   RankingEQAverage,  RankingEQDeadly,     RankingEQDeadly,   RankingEQAbove,     RankingEQCompetent, RankingEQCompetent
ShipPirateTableB:        DB ShipID_Chameleon,  ShipID_Worm,       ShipID_Rattler,    ShipID_Python_P,     ShipID_Anaconda,   ShipID_Bushmaster,  ShipID_Python_P,    ShipID_Anaconda    
                                
ShipBodiesTableARank:    DB RankingEQHarmless, RankingEQHarmless, RankingEQHarmless, RankingEQHarmless,   RankingEQHarmless, RankingEQHarmless,  RankingEQHarmless,  RankingEQDangerous
ShipBodiesTableA:        DB ShipID_Asteroid,   ShipID_Asteroid,   ShipID_Asteroid,   ShipID_Asteroid,     ShipID_Asteroid,   ShipID_Asteroid,    ShipID_Asteroid,    ShipID_Rock_Hermit

ShipNonTraderTableARank: DB RankingEQHarmless, RankingEQHarmless, RankingEQHarmless, RankingEQMostly,     RankingEQPoor,     RankingEQAverage,   RankingEQAverage,   RankingEQCompetent
ShipNonTraderTableA:     DB ShipID_Adder,      ShipID_Sidewinder, ShipID_Adder,      ShipID_Mamba,        ShipID_Krait,      ShipID_Gecko,       ShipID_Python,      ShipID_Anaconda

ShipCopTableARank:       DB RankingEQHarmless, RankingEQHarmless, RankingEQHarmless, RankingEQHarmless,   RankingEQHarmless, RankingEQHarmless,  RankingEQAverage,   RankingEQCompetent
ShipCopTableA:           DB ShipID_Viper,      ShipID_Viper,      ShipID_Viper,      ShipID_Viper,        ShipID_Viper,      ShipID_Viper,       ShipID_Python,      ShipID_Anaconda 

ShipHunterTableRank:     DB RankingEQHarmless, RankingEQMostly,   RankingEQPoor,     RankingEQAverage,    RankingEQAbove,    RankingEQCompetent, RankingEQCompetent, RankingEQCompetent
ShipHunterTableA:        DB ShipID_Sidewinder, ShipID_Adder,      ShipID_Boa,        ShipID_Python,       ShipID_Krait,      ShipID_Fer_De_Lance,ShipID_Mamba,       ShipID_Cougar

ShipHunterTableBRank:    DB RankingEQHarmless, RankingEQCompetent,RankingEQCompetent,RankingEQDangerous,  RankingEQDangerous,RankingEQDangerous, RankingEQDeadly,    RankingEQDeadly
ShipHunterTableB:        DB ShipID_Sidewinder, ShipID_Adder,      ShipID_Iguana,     ShipID_Python,       ShipID_Dragon,     ShipID_Gecko,       ShipID_Mamba,       ShipID_Anaconda

ShipHunterTableCRank:    DB RankingEQHarmless, RankingEQCompetent,RankingEQDangerous,RankingEQDangerous,  RankingEQDeadly,   RankingEQElite,     RankingEQSkollob,   RankingEQNutter
ShipHunterTableC:        DB ShipID_Adder,      ShipID_Monitor,    ShipID_Moray,      ShipID_Dragon,       ShipID_Gecko,      ShipID_Ghavial,     ShipID_Ophidian,    ShipID_Thargoid

ShipJunkTableRankA:      DB RankingEQHarmless, RankingEQHarmless, RankingEQHarmless, RankingEQHarmless,   RankingEQHarmless, RankingEQAverage,   RankingEQAbove,     RankingEQCompetent
ShipJunkTableA:          DB ShipID_Asteroid,   ShipID_Asteroid,   ShipID_Asteroid,   ShipID_Plate,        ShipID_CargoType5, ShipID_Splinter,    ShipID_Escape_Pod,  ShipID_Rock_Hermit 

ShipSuperstructureTableA 


; This is determined by system algorithm so there is no rank factor
MasterStations:         DB ShipID_Coriolis   
                        DB ShipID_Dodo   

ShipMissileTable        DB  ShipID_Missile
ShipMissileTableSize    EQU $ - ShipMissileTable



;; clean up below or delte
;ShipPirateTable:
;ShipPackList:           DB  ShipID_Sidewinder, ShipID_Mamba, ShipID_Krait, ShipID_Adder, ShipID_Gecko, ShipID_Cobra_Mk_1, ShipID_Worm, ShipID_Cobra_Mk_3_P
;ShipPackTableSize       EQU $ - ShipPackList
;ShipHunterTable         DB  ShipID_Cobra_Mk_3_P, ShipID_Asp_Mk_2, ShipID_Python_P, ShipID_Fer_De_Lance
;ShipHunterTableSize     EQU $ - ShipHunterTable
;
;MasterShipTable:        
;MasterStations:         DB ShipID_Coriolis   
;                        DB ShipID_Dodo    
; 
;                      
;                        
;MasterJunk:             DB ShipID_Asteroid   
;                        DB ShipID_Plate   
;                        DB ShipID_CargoType5  
;                        DB ShipID_Splinter        
;                        DB ShipID_Escape_Pod      
;                        DB ShipID_Rock_Hermit     
;MasterSuperstructure:                        
;MasterMissile:          DB ShipID_Missile         

                        



MasterThargoid:         DB ShipID_Thargoid        
                        DB ShipID_Thargon         

MasterMission:          DB ShipID_Constrictor     
                        

                        
                                

                        DB ShipID_Logo            
                        DB ShipID_TestVector      
