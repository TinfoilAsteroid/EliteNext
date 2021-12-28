galaxy_page_marker  DB "Galaxy      PG9"
galaxy_pg_cnt       DB "0"
galaxy_master_seed  DS 6
galaxy_data DS 8*256
galaxy_code_end DB "-----------------------------------------------------------------"
GalaxyPresentSystem:     DW 0
GalaxyDestinationSystem: DW 0
GalaxyTargetSystem:      DW 0
; including a DB 0 as a catcher
GalaxySearchString:      DS 32
                         DB 0
GalaxyExpandedName:      DS 32
                         DB 0
GalaxyName_digrams	     DB "ABOUSEITILETSTONLONUTHNOALLEXEGEZACEBISOUSESARMAINDIREA?ERATENBERALAVETIEDORQUANTEISRION"
GalaxyWorkingSeed        DS 6
GalaxyNamingSeed         DS 6
GalaxySavedRandomSeed    DS 6

GalaxyDisplayGovernment         DB 0
GalaxyDisplayEconomy            DB 0
GalaxyDisplayTekLevel           DB 0
GalaxyDisplayPopulation         DB 0
GalaxyDisplayProductivity       DW 0
GalaxyDisplayRadius             DW 0

GalaxyDescList01A       DB "fabled",0
GalaxyDescList01B       DB "notable",0
GalaxyDescList01C       DB "well known",0
GalaxyDescList01D       DB "famous",0
GalaxyDescList01E       DB "noted",0
GalaxyDescList02A       DB "very",0
GalaxyDescList02B       DB "mildly",0
GalaxyDescList02C       DB "most",0
GalaxyDescList02D       DB "reasonably",0
GalaxyDescList02E       DB 0
GalaxyDescList03A       DB "ancient",0
GalaxyDescList03B       DB "<20>",0
GalaxyDescList03C       DB "great",0
GalaxyDescList03D       DB "vast",0
GalaxyDescList03E       DB "pink",0
GalaxyDescList04A       DB "<29> <28> plantations",0
GalaxyDescList04B       DB "mountains",0
GalaxyDescList04C       DB "<27>",0
GalaxyDescList04D       DB "<19> forests",0
GalaxyDescList04E       DB "oceans",0
GalaxyDescList05A       DB "shyness",0
GalaxyDescList05B       DB "silliness",0
GalaxyDescList05C       DB "mating traditions",0
GalaxyDescList05D       DB "loathing of <5>",0
GalaxyDescList05E       DB "love for <5>",0
GalaxyDescList06A       DB "food blenders",0
GalaxyDescList06B       DB "tourists",0
GalaxyDescList06C       DB "poetry",0
GalaxyDescList06D       DB "discos",0
GalaxyDescList06E       DB "<13>",0
GalaxyDescList07A       DB "talking tree",0
GalaxyDescList07B       DB "crab",0
GalaxyDescList07C       DB "bat",0
GalaxyDescList07D       DB "lobst",0
GalaxyDescList07E       DB "%R",0
GalaxyDescList08A       DB "beset",0
GalaxyDescList08B       DB "plagued",0
GalaxyDescList08C       DB "ravaged",0
GalaxyDescList08D       DB "cursed",0
GalaxyDescList08E       DB "scourged",0
GalaxyDescList09A       DB "<21> civil war",0
GalaxyDescList09B       DB "<26> <23> <24>s",0
GalaxyDescList09C       DB "a <26> disease",0
GalaxyDescList09D       DB "<21> earthquakes",0
GalaxyDescList09E       DB "<21> solar activity",0
GalaxyDescList10A       DB "its <2> <3>",0
GalaxyDescList10B       DB "the %I <23> <24>",0
GalaxyDescList10C       DB "its inhabitants' <25> <4>",0
GalaxyDescList10D       DB "<32>",0
GalaxyDescList10E       DB "its <12> <13>",0
GalaxyDescList11A       DB "juice",0
GalaxyDescList11B       DB "brandy",0
GalaxyDescList11C       DB "water",0
GalaxyDescList11D       DB "brew",0
GalaxyDescList11E       DB "gargle blasters",0
GalaxyDescList12A       DB "%R",0
GalaxyDescList12B       DB "%I <24>",0
GalaxyDescList12C       DB "%I %R",0
GalaxyDescList12D       DB "%I <26>",0
GalaxyDescList12E       DB "<26> %R",0
GalaxyDescList13A       DB "fabulous",0
GalaxyDescList13B       DB "exotic",0
GalaxyDescList13C       DB "hoopy",0
GalaxyDescList13D       DB "unusual",0
GalaxyDescList13E       DB "exciting",0
GalaxyDescList14A       DB "cuisine",0
GalaxyDescList14B       DB "night life",0
GalaxyDescList14C       DB "casinos",0
GalaxyDescList14D       DB "sit coms",0
GalaxyDescList14E       DB " <32> ",0
GalaxyDescList15A       DB "%H",0
GalaxyDescList15B       DB "The planet %H",0
GalaxyDescList15C       DB "The world %H",0
GalaxyDescList15D       DB "This planet",0
GalaxyDescList15E       DB "This world",0
GalaxyDescList16A       DB "n unremarkable",0
GalaxyDescList16B       DB " boring",0
GalaxyDescList16C       DB " dull",0
GalaxyDescList16D       DB " tedious",0
GalaxyDescList16E       DB " revolting",0
GalaxyDescList17A       DB "planet",0
GalaxyDescList17B       DB "world",0
GalaxyDescList17C       DB "place",0
GalaxyDescList17D       DB "little planet",0
GalaxyDescList17E       DB "dump",0
GalaxyDescList18A       DB "wasp",0
GalaxyDescList18B       DB "moth",0
GalaxyDescList18C       DB "grub",0
GalaxyDescList18D       DB "ant",0
GalaxyDescList18E       DB "%R",0
GalaxyDescList19A       DB "poet",0
GalaxyDescList19B       DB "arts graduate",0
GalaxyDescList19C       DB "yak",0
GalaxyDescList19D       DB "snail",0
GalaxyDescList19E       DB "slug",0
GalaxyDescList20A       DB "tropical",0
GalaxyDescList20B       DB "dense",0
GalaxyDescList20C       DB "rain",0
GalaxyDescList20D       DB "impenetrable",0
GalaxyDescList20E       DB "exuberant",0
GalaxyDescList21A       DB "funny",0
GalaxyDescList21B       DB "wierd",0
GalaxyDescList21C       DB "unusual",0
GalaxyDescList21D       DB "strange",0
GalaxyDescList21E       DB "peculiar",0
GalaxyDescList22A       DB "frequent",0
GalaxyDescList22B       DB "occasional",0
GalaxyDescList22C       DB "unpredictable",0
GalaxyDescList22D       DB "dreadful",0
GalaxyDescList22E       DB "deadly",0
GalaxyDescList23A       DB "<1> <0> for <9>",0
GalaxyDescList23B       DB "<1> <0> for <9> and <9>",0
GalaxyDescList23C       DB "<7> by <8>",0
GalaxyDescList23D       DB "<1> <0> for <9> but <7> by <8>",0
GalaxyDescList23E       DB "a<15> <16>",0
GalaxyDescList24A       DB "<26>",0
GalaxyDescList24B       DB "mountain",0
GalaxyDescList24C       DB "edible",0
GalaxyDescList24D       DB "tree",0
GalaxyDescList24E       DB "spotted",0
GalaxyDescList25A       DB "<30>",0
GalaxyDescList25B       DB "<31>",0
GalaxyDescList25C       DB "<6>oid",0
GalaxyDescList25D       DB "<18>",0
GalaxyDescList25E       DB "<17>",0
GalaxyDescList26A       DB "ancient",0
GalaxyDescList26B       DB "exceptional",0
GalaxyDescList26C       DB "eccentric",0
GalaxyDescList26D       DB "ingrained",0
GalaxyDescList26E       DB "<20>",0
GalaxyDescList27A       DB "killer",0
GalaxyDescList27B       DB "deadly",0
GalaxyDescList27C       DB "evil",0
GalaxyDescList27D       DB "lethal",0
GalaxyDescList27E       DB "vicious",0
GalaxyDescList28A       DB "parking meters",0
GalaxyDescList28B       DB "dust clouds",0
GalaxyDescList28C       DB "ice bergs",0
GalaxyDescList28D       DB "rock formations",0
GalaxyDescList28E       DB "volcanoes",0
GalaxyDescList29A       DB "plant",0
GalaxyDescList29B       DB "tulip",0
GalaxyDescList29C       DB "banana",0
GalaxyDescList29D       DB "corn",0
GalaxyDescList29E       DB "%Rweed",0
GalaxyDescList30A       DB "%R",0
GalaxyDescList30B       DB "#I %R",0
GalaxyDescList30C       DB "#I <26>",0
GalaxyDescList30D       DB "inhabitant",0
GalaxyDescList30E       DB "%I %R",0
GalaxyDescList31A       DB "shrew",0
GalaxyDescList31B       DB "beast",0
GalaxyDescList31C       DB "bison",0
GalaxyDescList31D       DB "snake",0
GalaxyDescList31E       DB "wolf",0
GalaxyDescList32A       DB "leopard",0
GalaxyDescList32B       DB "cat",0
GalaxyDescList32C       DB "monkey",0
GalaxyDescList32D       DB "goat",0
GalaxyDescList32E       DB "fish",0
GalaxyDescList33A       DB "<11> <10>",0
GalaxyDescList33B       DB "#I <30> <33>",0
GalaxyDescList33C       DB "its <12> <31> <33>",0
GalaxyDescList33D       DB "<34> <35>",0
GalaxyDescList33E       DB "<11> <10>",0
GalaxyDescList34A       DB "meat",0
GalaxyDescList34B       DB "cutlet",0
GalaxyDescList34C       DB "steak",0
GalaxyDescList34D       DB "burgers",0
GalaxyDescList34E       DB "soup",0
GalaxyDescList35A       DB "ice",0
GalaxyDescList35B       DB "mud",0
GalaxyDescList35C       DB "Zero-G",0
GalaxyDescList35D       DB "vacuum",0
GalaxyDescList35E       DB "%I ultra",0
GalaxyDescList36A       DB "hockey",0
GalaxyDescList36B       DB "cricket",0
GalaxyDescList36C       DB "karate",0
GalaxyDescList36D       DB "polo",0
GalaxyDescList36E       DB "tennis",0

GalaxyDescList          DW GalaxyDescList01A, GalaxyDescList01B, GalaxyDescList01C, GalaxyDescList01D, GalaxyDescList01E
                        DW GalaxyDescList02A, GalaxyDescList02B, GalaxyDescList02C, GalaxyDescList02D, GalaxyDescList02E
                        DW GalaxyDescList03A, GalaxyDescList03B, GalaxyDescList03C, GalaxyDescList03D, GalaxyDescList03E
                        DW GalaxyDescList04A, GalaxyDescList04B, GalaxyDescList04C, GalaxyDescList04D, GalaxyDescList04E
                        DW GalaxyDescList05A, GalaxyDescList05B, GalaxyDescList05C, GalaxyDescList05D, GalaxyDescList05E
                        DW GalaxyDescList06A, GalaxyDescList06B, GalaxyDescList06C, GalaxyDescList06D, GalaxyDescList06E
                        DW GalaxyDescList07A, GalaxyDescList07B, GalaxyDescList07C, GalaxyDescList07D, GalaxyDescList07E
                        DW GalaxyDescList08A, GalaxyDescList08B, GalaxyDescList08C, GalaxyDescList08D, GalaxyDescList08E
                        DW GalaxyDescList09A, GalaxyDescList09B, GalaxyDescList09C, GalaxyDescList09D, GalaxyDescList09E
                        DW GalaxyDescList10A, GalaxyDescList10B, GalaxyDescList10C, GalaxyDescList10D, GalaxyDescList10E
                        DW GalaxyDescList11A, GalaxyDescList11B, GalaxyDescList11C, GalaxyDescList11D, GalaxyDescList11E
                        DW GalaxyDescList12A, GalaxyDescList12B, GalaxyDescList12C, GalaxyDescList12D, GalaxyDescList12E
                        DW GalaxyDescList13A, GalaxyDescList13B, GalaxyDescList13C, GalaxyDescList13D, GalaxyDescList13E
                        DW GalaxyDescList14A, GalaxyDescList14B, GalaxyDescList14C, GalaxyDescList14D, GalaxyDescList14E
                        DW GalaxyDescList15A, GalaxyDescList15B, GalaxyDescList15C, GalaxyDescList15D, GalaxyDescList15E
                        DW GalaxyDescList16A, GalaxyDescList16B, GalaxyDescList16C, GalaxyDescList16D, GalaxyDescList16E
                        DW GalaxyDescList17A, GalaxyDescList17B, GalaxyDescList17C, GalaxyDescList17D, GalaxyDescList17E
                        DW GalaxyDescList18A, GalaxyDescList18B, GalaxyDescList18C, GalaxyDescList18D, GalaxyDescList18E
                        DW GalaxyDescList19A, GalaxyDescList19B, GalaxyDescList19C, GalaxyDescList19D, GalaxyDescList19E
                        DW GalaxyDescList20A, GalaxyDescList20B, GalaxyDescList20C, GalaxyDescList20D, GalaxyDescList20E
                        DW GalaxyDescList21A, GalaxyDescList21B, GalaxyDescList21C, GalaxyDescList21D, GalaxyDescList21E
                        DW GalaxyDescList22A, GalaxyDescList22B, GalaxyDescList22C, GalaxyDescList22D, GalaxyDescList22E
                        DW GalaxyDescList23A, GalaxyDescList23B, GalaxyDescList23C, GalaxyDescList23D, GalaxyDescList23E
                        DW GalaxyDescList24A, GalaxyDescList24B, GalaxyDescList24C, GalaxyDescList24D, GalaxyDescList24E
                        DW GalaxyDescList25A, GalaxyDescList25B, GalaxyDescList25C, GalaxyDescList25D, GalaxyDescList25E
                        DW GalaxyDescList26A, GalaxyDescList26B, GalaxyDescList26C, GalaxyDescList26D, GalaxyDescList26E
                        DW GalaxyDescList27A, GalaxyDescList27B, GalaxyDescList27C, GalaxyDescList27D, GalaxyDescList27E
                        DW GalaxyDescList28A, GalaxyDescList28B, GalaxyDescList28C, GalaxyDescList28D, GalaxyDescList28E
                        DW GalaxyDescList29A, GalaxyDescList29B, GalaxyDescList29C, GalaxyDescList29D, GalaxyDescList29E
                        DW GalaxyDescList30A, GalaxyDescList30B, GalaxyDescList30C, GalaxyDescList30D, GalaxyDescList30E
                        DW GalaxyDescList31A, GalaxyDescList31B, GalaxyDescList31C, GalaxyDescList31D, GalaxyDescList31E
                        DW GalaxyDescList32A, GalaxyDescList32B, GalaxyDescList32C, GalaxyDescList32D, GalaxyDescList32E
                        DW GalaxyDescList33A, GalaxyDescList33B, GalaxyDescList33C, GalaxyDescList33D, GalaxyDescList33E
                        DW GalaxyDescList34A, GalaxyDescList34B, GalaxyDescList34C, GalaxyDescList34D, GalaxyDescList34E
                        DW GalaxyDescList35A, GalaxyDescList35B, GalaxyDescList35C, GalaxyDescList35D, GalaxyDescList35E
                        DW GalaxyDescList36A, GalaxyDescList36B, GalaxyDescList36C, GalaxyDescList36D, GalaxyDescList36E

GalaxyInhabitantDesc1   DB "Large ",0
GalaxyInhabitantDesc1A  DB "Fierce ",0
GalaxyInhabitantDesc1B  DB "Small ", 0
GalaxyInhabitantDesc2   DB "Green ",0
GalaxyInhabitantDesc2A  DB "Red ",  0
GalaxyInhabitantDesc2B  DB "Yellow ",0
GalaxyInhabitantDesc2C  DB "Blue ",  0
GalaxyInhabitantDesc2D  DB "Black ",0
GalaxyInhabitantDesc2E  DB "Harmless ",0
GalaxyInhabitantDesc3   DB "Slimy ",0
GalaxyInhabitantDesc3A  DB "Bug-Eyed ", 0
GalaxyInhabitantDesc3B  DB "Horned ",0
GalaxyInhabitantDesc3C  DB "Bony ",  0
GalaxyInhabitantDesc3D  DB "Fat ",  0
GalaxyInhabitantDesc3E  DB "Furry ",  0
GalaxyInhabitantDesc4   DB "Rodent",0
GalaxyInhabitantDesc4A  DB "Frog",      0
GalaxyInhabitantDesc4B  DB "Lizard", 0
GalaxyInhabitantDesc4C  DB "Lobster",0
GalaxyInhabitantDesc4D  DB "Bird",  0
GalaxyInhabitantDesc4E  DB "Humanoid", 0
GalaxyInhabitantDesc4F  DB "Feline", 0
GalaxyInhabitantDesc4G  DB "Insect",0
GalaxyInhabitantHuman   DB "Human Colonal",0

GalaxyInhabitantDesc1Ix DW GalaxyInhabitantDesc1,GalaxyInhabitantDesc1A,GalaxyInhabitantDesc1B
GalaxyInhabitantDesc2Ix DW GalaxyInhabitantDesc2,GalaxyInhabitantDesc2A,GalaxyInhabitantDesc2B,GalaxyInhabitantDesc2C,GalaxyInhabitantDesc2D,GalaxyInhabitantDesc2E
GalaxyInhabitantDesc3Ix DW GalaxyInhabitantDesc3,GalaxyInhabitantDesc3A,GalaxyInhabitantDesc3B,GalaxyInhabitantDesc3C,GalaxyInhabitantDesc3D,GalaxyInhabitantDesc3E
GalaxyInhabitantDesc4Ix DW GalaxyInhabitantDesc4,GalaxyInhabitantDesc4A,GalaxyInhabitantDesc4B,GalaxyInhabitantDesc4C,GalaxyInhabitantDesc4D,GalaxyInhabitantDesc4E,GalaxyInhabitantDesc4F,GalaxyInhabitantDesc4G
GalaxyInhabitantHumanIx DW GalaxyInhabitantHuman
GalaxySpecies           DS 32
                        DB 0
GalaxyPlanetDescription DS 300
                        DB 0
GalaxyPlanetSource      DS 300,0
GalaxyPlanetDescStarter DB "<14> is <22>",0


GalaxyExtendedDescs:    DB 211                                                  ; System 211, Galaxy 0                Teorge = Token  1
                        DB 150                                                  ; System 150, Galaxy 0, Mission 1       Xeer = Token  2
                        DB 36                                                   ; System  36, Galaxy 0, Mission 1   Reesdice = Token  3
                        DB 28                                                   ; System  28, Galaxy 0, Mission 1      Arexe = Token  4
                        DB 253                                                  ; System 253, Galaxy 1, Mission 1     Errius = Token  5
                        DB 79                                                   ; System  79, Galaxy 1, Mission 1     Inbibe = Token  6
                        DB 53                                                   ; System  53, Galaxy 1, Mission 1      Ausar = Token  7
                        DB 118                                                  ; System 118, Galaxy 1, Mission 1     Usleri = Token  8
                        DB 100                                                  ; System 100, Galaxy 2                Arredi = Token  9
                        DB 32                                                   ; System  32, Galaxy 1, Mission 1     Bebege = Token 10
                        DB 68                                                   ; System  68, Galaxy 1, Mission 1     Cearso = Token 11
                        DB 164                                                  ; System 164, Galaxy 1, Mission 1     Dicela = Token 12
                        DB 220                                                  ; System 220, Galaxy 1, Mission 1     Eringe = Token 13
                        DB 106                                                  ; System 106, Galaxy 1, Mission 1     Gexein = Token 14
                        DB 16                                                   ; System  16, Galaxy 1, Mission 1     Isarin = Token 15
                        DB 162                                                  ; System 162, Galaxy 1, Mission 1   Letibema = Token 16
                        DB 3                                                    ; System   3, Galaxy 1, Mission 1     Maisso = Token 17
                        DB 107                                                  ; System 107, Galaxy 1, Mission 1       Onen = Token 18
                        DB 26                                                   ; System  26, Galaxy 1, Mission 1     Ramaza = Token 19
                        DB 192                                                  ; System 192, Galaxy 1, Mission 1     Sosole = Token 20
                        DB 184                                                  ; System 184, Galaxy 1, Mission 1     Tivere = Token 21
                        DB 5                                                    ; System   5, Galaxy 1, Mission 1     Veriar = Token 22
                        DB 101                                                  ; System 101, Galaxy 2, Mission 1     Xeveon = Token 23
                        DB 193                                                  ; System 193, Galaxy 1, Mission 1     Orarra = Token 24
                        DB 41                                                   ; System  41, Galaxy 2                Anreer = Token 25
                        DB 7                                                    ; System   7, Galaxy 0                  Lave = Token 26
                        DB 46                                                   ; System  46, Galaxy 0              Riedquat = Token 27

    INCLUDE "./Data/EquipmentEquates.asm"

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

;Each row is 7 bytes
;                                                               12345  6  789012345678901
;	canbuy;
;	y;
;	show;
;	level;
;	price 2 bytes;
;	type;
;ShipFrontWeapons        DB EQ_FRONT_PULSE,  EQ_FRONT_PULSE,     EQ_FRONT_MINING,    EQ_FRONT_MINING
;ShipRearWeapons         DB EQ_REAR_PULSE,   EQ_REAR_PULSE,      EQ_REAR_MINING,     EQ_REAR_MINING
;ShipLeftWeapons         DB EQ_LEFT_PULSE,   EQ_LEFT_PULSE,      EQ_LEFT_MINING,     EQ_LEFT_MINING
;ShipRightWeapons        DB EQ_RIGHT_PULSE,  EQ_RIGHT_PULSE,     EQ_RIGHT_MINING,    EQ_RIGHT_MINING
;                           c  y  s  t                                            
;                           a  p  h  e                                            fi     P
;                           n  o  o  c                                            tt     o
;                           B  s  w  h  price                  type               ed     s
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
                        DB  0,11, 1, 3, low  4000, high  4000, EQ_REAR_PULSE    , 0     ,$01 , 0  , 0  , 0  , 0  , 0  , 0 , 0 
                        DB  0,12, 1, 3, low  4000, high  4000, EQ_LEFT_PULSE    , 0     ,$02 , 0  , 0  , 0  , 0  , 0  , 0 , 0 
                        DB  0,13, 1, 3, low  4000, high  4000, EQ_RIGHT_PULSE   , 0     ,$03 , 0  , 0  , 0  , 0  , 0  , 0 , 0 
                        DB  0,14, 0, 4, low 10000, high 10000, EQ_FRONT_BEAM    , 0     ,$00 , 0  , 0  , 0  , 0  , 0  , 0 , 0 
                        DB  0,15, 0, 4, low 10000, high 10000, EQ_REAR_BEAM     , 0     ,$01 , 0  , 0  , 0  , 0  , 0  , 0 , 0 
                        DB  0,16, 0, 4, low 10000, high 10000, EQ_LEFT_BEAM     , 0     ,$02 , 0  , 0  , 0  , 0  , 0  , 0 , 0 
                        DB  0,17, 0, 4, low 10000, high 10000, EQ_RIGHT_BEAM    , 0     ,$03 , 0  , 0  , 0  , 0  , 0  , 0 , 0 
                        DB  0,18, 0,10, low  8000, high  8000, EQ_FRONT_MINING  , 0     ,$00 , 0  , 0  , 0  , 0  , 0  , 0 , 0 
                        DB  0,19, 0,10, low  8000, high  8000, EQ_REAR_MINING   , 0     ,$01 , 0  , 0  , 0  , 0  , 0  , 0 , 0 
                        DB  0,20, 0,10, low  8000, high  8000, EQ_LEFT_MINING   , 0     ,$02 , 0  , 0  , 0  , 0  , 0  , 0 , 0 
                        DB  0,21, 0,10, low  8000, high  8000, EQ_RIGHT_MINING  , 0     ,$03 , 0  , 0  , 0  , 0  , 0  , 0 , 0 
                        DB  0,22, 0,10, low 60000, high 60000, EQ_FRONT_MILITARY, 0     ,$00 , 0  , 0  , 0  , 0  , 0  , 0 , 0 
                        DB  0,23, 0,10, low 60000, high 60000, EQ_REAR_MILITARY , 0     ,$01 , 0  , 0  , 0  , 0  , 0  , 0 , 0 
                        DB  0,24, 0,10, low 60000, high 60000, EQ_LEFT_MILITARY , 0     ,$02 , 0  , 0  , 0  , 0  , 0  , 0 , 0 
                        DB  0,25, 0,10, low 60000, high 60000, EQ_RIGHT_MILITARY, 0     ,$03 , 0  , 0  , 0  , 0  , 0  , 0 , 0 
ShipEquipTableRowLen    EQU 16
ShipEquipTableSize      EQU ($-ShipEquipmentList)/ShipEquipTableRowLen

;------------------------------------------------------------------------------------------------------------------------------------
GalaxyRandSeed			DB	43	            ; Just some start values
GalaxyRandSeed1			DB	32	            ; Just some start values
GalaxyRandSeed2			DB	12	            ; Just some start values
GalaxyRandSeed3			DB	66	            ; Just some start values
GalaxySeedRandom:
;------------------------------------------------------------------------------------------------------------------------------------
GetDigramGalaxySeed:    call	copy_galaxy_to_working
                        jr		GetDigramWorkingSeed
GetDigramSystemSeed:    call	copy_system_to_working
GetDigramWorkingSeed:   ld		de,name_expanded    ; ">GetDigram a = digram seed"
                        ld		b,3
                        ld		a,(WorkingSeeds)
                        and		$40
                        jr		z,.SmallSizeName
.LargeSizeName:         call	NamingLoop
.SmallSizeName:         call	NamingLoop
                        call	NamingLoop
                        call	NamingLoop
.DoneName:              ex		de,hl
                        ld		(hl),0
                        ex		de,hl
                        ret

GalaxySetSeedFromHL:    ld      de,GalaxyRandSeed
; Uses registers a,b and hl
GalaxyDoRandom:         or      a                                               ; in 6502 this is called after a bcc instruction to will always be clear (see .detok2 and .dt6)
                        ld      a,(GalaxyRandSeed)
.Seed0Rolled:           rl      a                                               ; r0 << 1
                        ld      b,a                                             ; b = reg x in 6502 so x = r0 << 1
.AddSeed2               ld      hl,GalaxyRandSeed2                              ;
                        adc     a,(hl)                                          ; a = r0 << 1 + r2
.SetRandSeed0:          ld		(GalaxyRandSeed),a					            ; set r0' = (r0 << 1) +  r2 + (r0 bit 7)
                        ld      a,b
.SetRandSeed2:          ld      (GalaxyRandSeed2),a                             ; set r2' =  r0 << 1
.GetRandSeed1:          ld      a,(GalaxyRandSeed1)
                        ld      b,a                                             ; b = r1
                        ld      hl,GalaxyRandSeed3
                        adc     a,(hl)                                          ; Adc from before may have set carry flag or may not, will be set if r0 << 1 + r2 + carry > 256
                        ld      (GalaxyRandSeed1),a                             ; set r1' = r1 + r3 + carry
                        ld      c,a
                        ld      a,b
                        ld      (GalaxyRandSeed3),a                             ; set r3 = r1
                        ld      a,c
                        ret

;------------------------------------------------------------------------------------------------------------------------------------
galaxy_cpy_str_a_at_hl_to_de:add     hl,a
                        add     hl,a
                        ld      a,(hl)              ;  Fetch low byte
                        ld      b,a
                        inc     hl
                        ld      a,(hl)              ;  Fetch high byte
                        ld      l,b
                        ld      h,a
GalaxyCopyLoop:         ld      a,(hl)
                        cp      0
                        ret     z
                        ld      (de),a
                        inc     hl
                        inc     de
                        jr      GalaxyCopyLoop
;------------------------------------------------------------------------------------------------------------------------------------
galaxy_get_species:     ld      de,GalaxySpecies
                        ld      a,"("
                        ld      (de),a
                        inc     de
                        ld      a,(GalaxyWorkingSeed+4)
                        bit     7,a
                        jr      nz,.NonHuman
                        ld      hl,GalaxyInhabitantHumanIx
                        xor     a
                        call    galaxy_cpy_str_a_at_hl_to_de
                        jp      .galaxy_species_exit
.NonHuman:              ld      a,(GalaxyWorkingSeed+5)
                        srl     a
                        srl     a
                        and     $07
                        cp      3
                        jr      nc,.NotDesc1
                        ld      hl,GalaxyInhabitantDesc1Ix
                        call    galaxy_cpy_str_a_at_hl_to_de
                        ld      a," "
                        ld      (de),a
                        inc     de
.NotDesc1:              ld      a,(GalaxyWorkingSeed+5)
                        srl     a
                        srl     a
                        srl     a
                        srl     a
                        srl     a
                        cp      6
                        jr      nc,.NotDesc2
                        ld      hl,GalaxyInhabitantDesc2Ix
                        call    galaxy_cpy_str_a_at_hl_to_de
                        ld      a," "
                        ld      (de),a
                        inc     de
.NotDesc2:              ld      a,(GalaxyWorkingSeed+1)
                        ld      b,a
                        ld      a,(GalaxyWorkingSeed+3)
                        xor     b
                        and     $07
                        push    af
                        cp      6
                        jr      nc,.NotDesc3
                        ld      hl,GalaxyInhabitantDesc3Ix
                        call    galaxy_cpy_str_a_at_hl_to_de
                        ld      a," "
                        ld      (de),a
                        inc     de
.NotDesc3:              pop     af
                        ld      b,a
                        ld      a,(GalaxyWorkingSeed+5)
                        and     $03
                        add     a,b
                        and     $07
                        ld      hl,GalaxyInhabitantDesc4Ix
                        call    galaxy_cpy_str_a_at_hl_to_de
.galaxy_species_exit:   ld      a,"s"
                        ld      (de),a
                        inc     de
                        ld      a,")"
                        ld      (de),a
                        inc     de
                        xor     a
                        ld      (de),a
                        ret


; To copy seed, loops from 3 to 0
; copy seed X + 2 to target X
; x = x -1

; For lave we shoudl have "Lave is most famous for its vast rain forests and the Lavian tree grub"

GalaxyCapitaliseString: ; ">CapitaliseString hl = address"
                        inc		hl
                        ld		a,(hl)
                        cp		0
                        ret		z
                        cp		'Z'+1
                        jr		nc,GalaxyCapitaliseString
                        cp		'A'
                        jr		c,GalaxyCapitaliseString
.LowerCase:             add		a,'a'-'A'
                        ld		(hl),a
                        jr		GalaxyCapitaliseString


GalaxyGoatSoup:         ;ld      (GalaxyTargetSystem),bc                         ; Set the galaxy target variable
                        ;call    galaxy_system_under_cursor                      ; and set the galaxyworkingseed based on cursor
                        ;cp      $FF
                        ;jr      z,.NoSystemFound
.SeedGalaxy             ld      a,(WorkingSeeds+2)                              ;
                        ld      (GalaxyRandSeed),a                              ; r0 = Seed C
                        ld      a,(WorkingSeeds+3)                              ;
                        ld      (GalaxyRandSeed1),a                             ; r1 = Seeed D
                        ld      a,(WorkingSeeds+4)                              ;
                        ld      (GalaxyRandSeed2),a                             ; r2 = Seed E
                        ld      a,(WorkingSeeds+5)                              ;
                        ld      (GalaxyRandSeed3),a                             ; r3 = Seed F
                        ret
; For later......
.MarkExtendedDesc:      ld      a,5                                             ;  ("{lower case}{justify}{single cap}[86-90] IS [140-144].{cr}{left align}"
.GalaxyExpandDesc:      push    af
                        ld      b,a                                             ; b = 6502 X reg
                        push    bc                                              ; save Y reg

;------------------------------------------------------------------------------------------------------------------------------------
; We enter here with BC = the Y and X Coordinates of the system to select in this galaxy
; This is based on the docked BBC PDesc Pink Volcanoes version ratehr tha goat soup
GalaxyPinkVolcano:      ld      (GalaxyTargetSystem),bc                         ; Set the galaxy target variable
                        call    galaxy_system_under_cursor                      ; and set the galaxyworkingseed based on cursor
                        ;cp      $FF
                        ;jr      z,.NoSystemFound
.SpecialDescs:          ; this is not implemented yet to read GalaxyExtendedDescs look at .PDL1



;.NoSytemFound:          Print the "Unable to identify a system at present position"

GalaxyNameCopy          DS      30

ExpandAtHLToE:          ld      e,0
.ExpandTokenLoop:       ld      a,(hl)
                        cp      ">"
                        ret     z
                        inc     hl
                        ld      d,10
                        mul
                        sub     "0"
                        add     a,e
                        ld      e,a
                        jr      .ExpandTokenLoop

SelectTokenToHL:        push    hl                                          ;+1
                        push    bc                                          ;+2
                        call    GalaxyDoRandom
                        pop     bc                                          ;+1
                        pop     hl                                          ;+0
.CalcOptionAToD:        ld      d,0
                        cp      $33
                        jp      c,.Check66
.IsGTE33:               inc     d
.Check66:               cp      $66
                        jp      c,.Check99
.IsGTE66:               inc     d
.Check99:               cp      $99
.IsGTE99:               jp      c,.CheckCC
                        inc     d
.CheckCC:               cp      $CC
                        jr      c,.TokenIdToAddress
.ItGETCC:               inc     d
.TokenIdToAddress:      ld      hl,GalaxyDescList
                        ld      a,e
                        sla     a                                               ; x 2
                        add     hl,a                                            ; hl + a * 2
                        add     hl,a                                            ; hl + a * 4
                        add     hl,a                                            ; hl + a * 6
                        add     hl,a                                            ; hl + a * 8
                        add     hl,a                                            ; hl + a * 10
                        ld      a,d
                        add     hl,a
                        add     hl,a                                            ; hl = desc array [e][d]
.LookUpDataFromTable:   ld      a,(hl)
                        ld      ixl,a
                        inc     hl
                        ld      a,(hl)
                        ld      ixh,a                                           ; ix = address at (hl)
                        push    ix                                              ;+2
                        pop     hl                                              ;+1
                        ret
;------------------------------------------------------------------------------------------------------------------------------------
ProcessHSymbol:         push    hl                                              ;+1
                        push    de                                              ;+2
                        push    bc                                              ;+3
.CopyInNameH:           ld      hl, GalaxyNameCopy
                        ld      d,iyh
                        ld      e,iyl
                        call    GalaxyCopyLoop
                        ld      iyh,d
                        ld      iyl,e
                        pop     bc                                              ;+2
                        pop     de                                              ;+1
                        pop     hl
                        ret
;------------------------------------------------------------------------------------------------------------------------------------
ProcessISymbol:         push    hl                                              ;+1
                        push    de                                              ;+2
                        push    bc                                              ;+3
.CopyInNameI:           ld      hl, GalaxyNameCopy
                        ld      d,iyh
                        ld      e,iyl
                        call    GalaxyCopyLoop
                        ld      iyh,d
                        ld      iyl,e
                        ld      a,"i"
                        ex      de,hl
                        ld      (hl),a
                        inc     hl
                        ld      a,"a"
                        ld      (hl),a
                        inc     hl
                        ld      a,"n"
                        ld      (hl),a
                        inc     hl
                        push    hl
                        pop     iy
                        pop     bc                                              ;+2
                        pop     de                                              ;+1
                        pop     hl                                              ;+0
                        ret
;------------------------------------------------------------------------------------------------------------------------------------
ProcessRSymbol:         push    hl                                              ;+1
                        push    de                                              ;+2
                        call    GalaxyDoRandom ;(Correct one or do we use teh clear carry version?)
                        and     $03
                        ld      b,a
                        inc     b
                        xor     a
                        ld      c,a
.RLoop:                 push    bc                                              ;+3
                        call    GalaxyDoRandom
                        pop     bc                                              ;+2
                        and     $3E
                        ld      hl,GalaxyName_digrams
                        add     hl,a
                        ld      a,(hl)
                        cp      "A"
                        jr      c,.NotLowercase
                        add     a,c
.NotLowercase:          ld      (iy+0),a
                        inc     hl
                        inc     iy
                        ld      c,$20               ; fixed force to lower case
                        ld      a,(hl)
                        cp      "A"
                        jr      c,.NotLowercase2
                        add     a,c
.NotLowercase2:         ld      (iy+0),a
                        inc     iy
                        djnz    .RLoop
                        pop     de                                              ;+1
                        pop     hl                                              ;+0
                        ret
;------------------------------------------------------------------------------------------------------------------------------------
GalaxyGenerateDesc:     ld      (GalaxyTargetSystem),bc                         ; Set the galaxy target variable
                        call    galaxy_system_under_cursor
.CopySystemName:        call    galaxy_digram_seed                              ; make a local copy of system name
                        ld      hl,GalaxyExpandedName
                        ld      de,GalaxyNameCopy
                        call    GalaxyCopyLoop
.CapitaliseName:        ld      hl,GalaxyNameCopy
                        call    GalaxyCapitaliseString
                        ; we will also capitalise the local copy here later
.InitDescription:       ld      hl,GalaxyPlanetDescStarter                      ; Initialise galaxy description to  <14> is <22>
                        ld      de,GalaxyPlanetSource
                        call    GalaxyCopyLoop
.ClearOutDescription:   xor     a
                        ld      hl,GalaxyPlanetDescription
                        ld      (hl),a
                        ld      de,GalaxyPlanetDescription+1
                        ld      bc,300                                          ; copy previous byte to current for 300 bytes (as we have DS 300 + 1)
                        ldir                                                    ; zero it out, don't need this at the end but simplifies debugging
.CopySeedToRandom:      call    GalaxyGoatSoup
                        ld      hl,GalaxyPlanetSource
                        ld      iy,GalaxyPlanetDescription
; At this point we are now prepped ready to expand the string to a full description
;-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
.ExpRecursive:          ld      a,(hl)
                        cp      0
                        jp      z,.ExpansionComplete
                        cp      "<"
                        jp      nz,.NotToken
.ItIsAToken:            inc     hl
.ReadToken:             call    ExpandAtHLToE                                   ; here we have a <X> token
                        inc     hl
.SaveCurrentPosition:   push    hl                                              ;+1 Save the current pointer to the text as we are now diverting off to another address
.LookUpToken:           call    SelectTokenToHL                                 ; Get random token id by using d as list and e as offest against galaxydesc list and return address in hl
                        call    .ExpRecursive
.RestoreCurrentPosition:pop     hl                                              ;+0 get back our old HL we saved off
.TokenNextIteration:    jp      .ExpRecursive
;-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
.NotToken:              cp      "%"
                        jp      nz,.RegularCharacter
                        inc     hl                                              ; issue was that it was stuck on "%" and not reading the next character for the token to expand
                        ld      a,(hl)
                        cp      "H"
                        jr      nz,.IsItI
.ItIsAnH:               inc     hl
                        call    ProcessHSymbol
                        jp      .ExpRecursive
.IsItI:                 cp      "I"
                        jr      nz,.ItIsR
.ItIsAnI:               inc     hl
                        call    ProcessISymbol
                        jp      .ExpRecursive
.ItIsR:                 call    ProcessRSymbol
                        inc     hl
.SystemNextIteration:   jp      .ExpRecursive
.RegularCharacter:      ld      (iy+0),a
                        inc     iy
                        inc     hl
.RegularNextIteration:  jp      .ExpRecursive
.ExpansionComplete:     xor     a
                        ld      (iy+1),a    ; will thsi work as a bodge
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
galaxy_equip_market:    ld      a,(GalaxyDisplayTekLevel)
                        inc     a
                        ld      h,a
                        ld      c,0
                        ld      b,ShipEquipTableSize            ;NO_OF_EQUIP_ITEMS
                        ld      de,ShipEquipTableRowLen         ; Bytes per row
                        ld      ix,ShipEquipmentList
.ItemCheckLoop:         ld      a,(ix+6)                        ; is it type fuel
                        cp      0
                        ; Check Cash TODO
                        jr      z,.CheckTechLevel
.CheckTechLevel:        ld      a,(ix+3)                        ; ItemTech Level
                        cp      h
                        ;jr      nc,.DoNotShowItem
.CheckShowItem:         ld      a,(ix+2)
                        cp      0
                      ;  jr      z,.DoNotShowItem
.ShowItem:              ld      a,c
                        ld      (ix+1),c                        ; Show Item Row Id
.CheckFitted:           ld      a,(ix+6)
                        cp      EQ_FUEL
                        jr      z,.FuelLevel
                        cp      EQ_MISSILE
                        jr      z,.CountMissiles
.IsFitted:              ld      hl,EquipmentFitted
                        add     hl,a
                        ld      a,(hl)
                        cp      0
                        jr      z,.NotFittedItem
.FittedItem:            ld      a,"*"                        
                        jp      .MoreToDoCheck
.NotFittedItem:         ld      a,"-"
                        jp      .MoreToDoCheck
.FuelLevel:             ld      a,(Fuel)
                        cp      MaxFuelLevel
                        jr      z,.FullFuel
.NotFullFuel:           ld      a,"-"                        
                        jp      .MoreToDoCheck                        
.FullFuel               ld      a,"*"                           ; later on do 3 starts low, med,full
                        jp      .MoreToDoCheck
.CountMissiles:         ld      a,(NbrMissiles)
                        cp      0
                        jr      z,.NoMissiles
                        add     "0"
                        jp      .MoreToDoCheck
.NoMissiles:            ld      a,"-"                        
                        jp      .MoreToDoCheck                                    
.MoreToDoCheck:         ld      (ix+7),a                        ; update fitted status
                        inc     c
                        add     ix,de                        
                        djnz    .ItemCheckLoop
                        ret
.DoNotShowItem          ld      a,$FF                           ; $FF = hide
                        ld      (ix+1),a
                        add     ix,de
                        djnz    .ItemCheckLoop
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
galaxy_planet_data:     ld      a,(GalaxyWorkingSeed+2)
.GenerateGovernment:    or      a
                        srl	    a                                               ; Government = seed2 / 8 & 7
                        srl	    a
                        srl	    a                                                   ;
                        and     $07                                             ;
                        ld      (GalaxyDisplayGovernment),a                     ;
.GenerateEconomy:       ld      a,(GalaxyWorkingSeed+1)
                        and     $07
                        ld      b,a
                        ld      a,(GalaxyDisplayGovernment)
                        JumpIfAGTENusng 1, .GreaterThan1
.OneOrZero:             ld      a,b
                        or      2
                        ld      (GalaxyDisplayEconomy),a
                        jp      .GenerateTechLevel
.GreaterThan1:          ld      a,b
                        ld      (GalaxyDisplayEconomy),a
.GenerateTechLevel:     xor     $07                                             ; tech = economy xor 7 + seed3 & 3 + government /2 + fovernemnt & 1
                        ld      b,a
                        ld      a,(GalaxyWorkingSeed+3)
                        and     $03
                        add     b
                        ld      b,a
                        ld      a,(GalaxyDisplayGovernment)
                        ld      c,a
                        sra     a
                        add     b
                        ld      b,a
                        ld      a,c
                        and     $1
                        add     b
                        ld      (GalaxyDisplayTekLevel),a
.GeneratePopulation:    sla     a                                               ; population = tech level * 4 + government + economy + 1
                        sla     a
                        ld      hl,GalaxyDisplayGovernment
                        add     a,(hl)
                        ld      b,a
                        ld      a,(GalaxyDisplayEconomy)
                        add     a,b
                        inc     a
                        ld      (GalaxyDisplayPopulation),a
.GenerateProductivity:  ld      a,(GalaxyDisplayEconomy)
                        xor     7
                        add     3
                        ld      d,a
                        ld      a,(GalaxyDisplayGovernment)
                        add     4
                        ld      e,a
                        mul                                                     ; the next mulitply will be a 16 bit value
                        ld      a,(GalaxyDisplayPopulation)
                        ld      h,0
                        ld      l,a
                        call    mulDEbyHL
                        ex      de,hl
                        ShiftDELeft1
                        ShiftDELeft1
                        ShiftDELeft1
                        ld      (GalaxyDisplayProductivity),de
.GenerateRadius:        ld		a,(GalaxyWorkingSeed+5)                         ;radius min = 256*11 = 2816 km
                        and		$0F
                        add     11
                        ld      b,a
                        ld      a,(GalaxyWorkingSeed+3)
                        ld      c,a
                        ld      (GalaxyDisplayRadius),bc
                        ret

galaxy_master_seed_to_system:
		ld		hl,galaxy_master_seed
		ld		de,SystemSeed
galaxy_copy_seed:
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi
		ret

galaxy_master_to_galaxy_working:
		ld		hl,galaxy_master_seed
		ld		de,GalaxyWorkingSeed
		jr		galaxy_copy_seed

galaxy_master_to_galaxy_naming:
		ld		hl,galaxy_master_seed
		ld		de,GalaxyNamingSeed
		jr		galaxy_copy_seed

working_seed_to_galaxy_working:
        ld      hl,WorkingSeeds
		ld		de,GalaxyWorkingSeed
		jr		galaxy_copy_seed

working_seed_to_galaxy_naming:
        ld      hl,WorkingSeeds
		ld		de,GalaxyNamingSeed
		jr		galaxy_copy_seed

galaxy_ix_seed_to_galaxy_naming:
        push    ix
        pop     hl
		ld		de,GalaxyNamingSeed
		jr		galaxy_copy_seed


galaxy_working_seed_to_galaxy_naming:
        ld      hl,GalaxyWorkingSeed
		ld		de,GalaxyNamingSeed
		jr		galaxy_copy_seed

galaxy_working_seed_to_system:
		ld		hl,GalaxyWorkingSeed
		ld		de,SystemSeed
		jr		galaxy_copy_seed

system_seed_to_galaxy_working:
		ld		hl,SystemSeed
		ld		de,GalaxyWorkingSeed
		jr		galaxy_copy_seed


system_seed_to_galaxy_naming:
		ld		hl,SystemSeed
		ld		de,GalaxyNamingSeed
		jr		galaxy_copy_seed

ix_seed_to_galaxy_working:
        push    ix
        pop     hl
		ld		de,GalaxyWorkingSeed
		jr		galaxy_copy_seed

; Here we twist just once rather than the usual4 for a system
NextGalaxyNamingSeed:   ld		a,(GalaxyNamingSeed)			; QQ15 ; x = a + c
                        or		a							; clear carry flag
                        ld		hl,GalaxyNamingSeed+2			; hl -> qq+2 [c]
                        add		a,(hl)						; a= QQ15 [a]+ QQ15 [c]
                        ld		b,a							; partial sum lo [x]
; y = b + d	+ carry
                        ld		a,(GalaxyNamingSeed+1)          ; [b]
                        ld		hl,GalaxyNamingSeed+3			; HL -> QQ+3 [d] we don't inc as it affects carry)
                        adc		a,(hl)						; note add with carry
                        ld		c,a  						; c = QQ1+QQ3+carry bit parial sum hi
                        ld		a,(GalaxyNamingSeed+2)
                        ld		(GalaxyNamingSeed+0),a			; copy qq152 to qq150 [a] = [c]
                        ld		a,(GalaxyNamingSeed+3)
                        ld		(GalaxyNamingSeed+1),a			; copy qq153 to qq151 [b] = [d]
                        ld		a,(GalaxyNamingSeed+5)
                        ld		(GalaxyNamingSeed+3),a			; copy qq155 to qq153 [d] = [f]
                        ld		a,(GalaxyNamingSeed+4)
                        ld		(GalaxyNamingSeed+2),a			; copy qq154 to qq152 [c] = [e]
                        or		a
                        ld		a,b
                        ld		hl,GalaxyNamingSeed+2		    ; hl -> qq+2
                        add	    a,(hl)
                        ld		(GalaxyNamingSeed+4),a			; e = x + [c]
                        ld		a,c
                        ld		hl,GalaxyNamingSeed+3			; HL -> QQ+3 )we don't inc as it affects carry)
                        adc		a,(hl)
                        ld		(GalaxyNamingSeed+5),a			; f = y + [d] + carry
                        ret


GalaxyNamingLoop:       ld		a,(GalaxyNamingSeed+5)	        ; a = first byte of name seed
                        and 	$1F					            ; Keep bottom 5 bits only
                        cp		0					            ; 0 = skip 2 chars
                        jr		z,.SkipPhrase
                        add		a,12
                        sla		a					            ; phrase = (a+12)*2
                        ld		hl,GalaxyName_digrams
                        add		hl,a
                        ldi
                        ld		a,(hl)
                        cp		'?'
                        jr		z,.SkipPhrase
.AddExtra:              ldi
.SkipPhrase:            push	de
                        call	NextGalaxyNamingSeed
                        pop		de
                        ret

; takes location in BC, finds seed and expands the name
galaxy_name_at_bc:      ld      (GalaxyTargetSystem),bc
galaxy_digram_seed:     call    galaxy_system_under_cursor
                        cp      0
                        ret     z

GalaxyDigramWorkings:   call    working_seed_to_galaxy_naming
                        jp      GalaxyDigramNamingSeed

GalaxyDigramSeed:       call    galaxy_master_to_galaxy_naming
                        jp      GalaxyDigramNamingSeed

GalaxyDigramWorkingSeed:call    galaxy_working_seed_to_galaxy_naming
                        jp      GalaxyDigramNamingSeed

GalaxyDigramWIXSeed:    call    galaxy_ix_seed_to_galaxy_naming
                        jp      GalaxyDigramNamingSeed

SystemGetDigramSeed:    call    system_seed_to_galaxy_naming

GalaxyDigramNamingSeed: ld		de,GalaxyExpandedName
GalaxyDigramToDE:       ld		b,3
                        ld		a,(GalaxyNamingSeed)
                        and		$40
                        jr		z,.SmallSizeName
.LargeSizeName:         call	GalaxyNamingLoop
.SmallSizeName:         call	GalaxyNamingLoop
                        call	GalaxyNamingLoop
                        call	GalaxyNamingLoop
.DoneName:              ex		de,hl
                        ld		(hl),0
                        ex		de,hl
                        xor     a
                        dec     a
                        ret
;reorte X 13 Y 97

set_names_lowercase:
    ;- to do, for case insensitive match
    ret
;----------------------------------------------------------------------------------------------------------------------------------
is_system_found:        ; search string does not have /0
; search for riinus then ra you get seardh of rainus
                        ld      hl,GalaxySearchString
                        ld      de,GalaxyExpandedName
.getsearchlen:          ld      c,0
.getsearchlenloop:      ld      a,(hl)
                        cp      0
                        jr      z,.readyToSearch
                        inc     hl
                        inc     c
                        jp      .getsearchlenloop
                        ld      b,32
.readyToSearch:         ld      hl,GalaxySearchString
.searchLoop:            ld      a,(de)
                        cp      0
                        jr      z,.EndOfMatch
                        dec     c
                        push    bc
                        cpi
                        pop     bc
                        jr      nz,.noMatch
                        inc     de

                        djnz    .searchLoop
.noMatch:               ld      a,$FF
                        ret
.EndOfMatch:            ld      a,c
                        cp      0
                        ret     z
                        ld      a,$FF
                        ret

find_system_by_name:    xor     a
                        ld      (XSAV),a
                        ld      ix,galaxy_data
.nextSystem:            call    ix_seed_to_galaxy_working
                        call    GalaxyDigramWorkingSeed
                        call    is_system_found
                        cp      0
                        jr      z,.FoundAtIX
                        ld      a,(XSAV)
                        dec     a
                        jr      z,.NoMoreSystems
                        ld      (XSAV),a
                        push    ix
                        pop     hl
                        add     hl,8
                        push    hl
                        pop     ix
                        jp      .nextSystem
.NoMoreSystems:         ld      a,$FF
                        ret
.FoundAtIX              call    ix_seed_to_galaxy_working
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
nearestfound:           DW 0
; In here de carries current nearest and loads into nearest found
; does a basic distance check for x then y each under threshold, then does x+y under threshold  jsut in case we have an extreme like 0 x and high dist y
find_nearest_to_bc:     ld      ix,galaxy_data
                        ld      iyh,0
                        ld      iyl,120
                        ld      (nearestfound),bc
find_nearest_loop:      ld      a,(ix+3)                        ;
                        ld      e,a                             ; e= current seed x
                        JumpIfALTNusng c, nearestXPosLT         ; not we need to know if its e - c or c - e we coudl do 2's compliement of course
nearestXPosGTE:         push    de                              ;
                        ld      h,0                             ;
                        ld      l,a                             ; hl = seed x
                        ld      d,0                             ;
                        ld      e,c                             ; de = nearest x
                        or      a                               ;
                        sbc     hl,de                           ; hl = distance between the two
                        pop     de
                        jp      nearestDistXPos
nearestXPosLT:          push    de                              ;
                        ld      h,0                             ;
                        ld      l,c                             ; hl = nearest x
                        ld      d,0                             ;
                        or      a                               ; de = seed x
                        sbc     hl,de                           ;
                        pop     de                              ; hl = distance between the two
nearestDistXPos:        ld      a,l                             ; so l = abs distance as does a
                        cp      iyl                             ; under initial threshold?
                        jr      nc,find_nearest_miss            ; no so its a miss
 ;DEBUG                       ld      l,a                             ; l = distance (we can drop thsi as it was done above!)
                        ld      a,(ix+1)                        ;
                        ld      d,a                             ; d = seed y
                        JumpIfALTNusng b, nearestYPosLT         ; determine abs calc
nearestYPosGTE:         push    hl                              ; save current x distance
                        push    de                              ;
                        ld      h,0                             ;
                        ld      l,a                             ; hl = seed y
                        ld      d,0                             ;
                        ld      e,b                             ; de = nearest y
                        or      a                               ;
                        sbc     hl,de                           ; hl = distance between the two
                        ld      a,l
                        pop     de
                        pop     hl
                        jp      nearestDistYPos
nearestYPosLT:          push    hl                              ; save current x distance
                        push    de                              ;
                        ld      h,0                             ;
                        ld      l,b                             ; hl = nearest y
                        ld      e,d                             ;
                        ld      d,0                             ; de = seed y
                        or      a                               ;
                        sbc     hl,de                           ; hl = distance between the two
                        ld      a,l
                        pop     de
                        pop     hl                              ; now we get distance in l back into hl, distance y is in a
nearestDistYPos:        cp      iyl                             ; under initial threshold?
                        jr      nc, find_nearest_miss
                        ld      h,0                             ; hl = distance for x
                        add     hl,a                            ; adding distance y
                        ld      a,l                             ; and copy it to l
                        cp      iyl                             ; is the pair under distance
                        jr      nc, find_nearest_miss           ;
nearest_found_a_hit:    ld      iyl,a                           ; so we have a hit
                        ld      (nearestfound),de               ;
                        ReturnIfALTNusng 2                      ; exact match bail out, note 1 can be an exact match due to Y axis, as we are looking at seed pos then this is accurate enough and we won't hit dx 1 and dy 0 hopefully in any galaxy :)
find_nearest_miss:      push     ix
                        pop      hl
                        add      hl,8
                        push     hl
                        pop      ix
                        dec     iyh
                        ld      a,iyh
                        IfANotZeroGoto find_nearest_loop
                        ld      bc ,(nearestfound)              ; if we hit here then after searching we have found a nearest
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; Does a sqare root distance
galaxy_find_distance:   ld      d,0
                        ld      h,0
                        ld      a,(GalaxyPresentSystem)
                        ld      b,a
                        ld      a,(GalaxyDestinationSystem)
                        cp      b
                        jr      nz,.NotSame
.XSame:                 push    bc
                        push    af
                        ld      a,(GalaxyPresentSystem+1)
                        ld      b,a
                        ld      a,(GalaxyDestinationSystem+1)
                        cp      b
                        pop     bc
                        pop     af
                        jr      z,.ZeroDistance
.NotSame:               jr      nc,.DestinationGTEPresentX
.DestinationLTPresentX: ld      l,b
                        ld      e,a
                        or      a
                        sbc     hl,de
                        jp      .SquareXDist
.DestinationGTEPresentX:ld      l,a
                        ld      e,b
                        or      a
                        sbc     hl,de
.SquareXDist:           ld      d,l
                        ld      e,l
                        mul
.CalcYDistSq            ld      a,(GalaxyPresentSystem+1)
                        ld      b,a
                        ld      a,(GalaxyDestinationSystem+1)
                        cp      b
                        jr      nc,.DestinationGTEPresentY
.DestinationLTPresentY: ld      c,a
                        ld      l,b
                        ld      b,0
                        ld      h,0
                        sbc     hl,bc
                        jp      .DestinationYDone
.DestinationGTEPresentY:ld      c,b
                        ld      l,a
                        ld      b,0
                        ld      h,0
                        sbc     hl,bc
.DestinationYDone:      sra     l                   ; divide L by 2 for galaxy size
                        ld      a,l
                        ex      de,hl
                        ld      d,a
                        ld      e,a
.SquareYDist:           mul
                        add     hl,de
                        ex      de,hl
                        call    asm_sqrt            ; distance via pythagoras in hl
                        ShiftHLLeft1
                        ShiftHLLeft1                ; Multiply by 4 to get distance
                        ld      (Distance),hl       ; Distance is now caulated distance
                        ret
.ZeroDistance:          xor     a
                        ld      (Distance),a
                        ld      (Distance+1),a
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
; Find the systems pointed to by GalaxyTargetSystem and loads it into WorkingSeeds
; this needs to chagne to galaxyresultseed or galayxworkingseed
galaxy_system_under_cursor:xor     a
                        ld		(XSAV),a
                        ld      ix,galaxy_data
.GCCounterLoop:         ld      hl,(GalaxyTargetSystem)
                        push    ix
                        ld      a,l
                        cp      (ix+3)                          ; seed x
                        jr      nz,.ItsNotThisX
                        ld      a,h
                        cp      (ix+1)                          ; seed x
.FoundSystem:           jr      nz,.ItsNotThisX
                        push    ix
                        pop     hl
                        ld      de,WorkingSeeds                 ;' copy to wkring Seeds
                        call    copy_seed
                        ld      a,$FF
                        pop     ix
                        ret
.ItsNotThisX:           pop     hl
                        add     hl,8
                        push    hl
                        pop     ix
                        ld		a,(XSAV)
                        dec		a
                        ld      (XSAV),a
                        cp		0
                        ret		z
                        jr		.GCCounterLoop
;----------------------------------------------------------------------------------------------------------------------------------
SeedGalaxy:             ld      hl,SystemSeed                   ; First copy system seed to galaxy master
                        ld      de,galaxy_master_seed           ; .
                        ldi                                     ; .
                        ldi                                     ; .
                        ldi                                     ; .
                        ldi                                     ; .
                        ldi                                     ; .
                        ldi                                     ; .
                        ld      ix,galaxy_data                  ; Generate system seed data for each planet
                        xor		a                               ; .
                        ld		(XSAV),a                        ; .
SeedGalaxyLoop:         push    ix                              ; .
                        pop     de                              ; .
                        ld      hl,SystemSeed                   ; .
                        call    copy_seed                       ; .
                        push    ix                              ; .
                        pop     hl                              ; .
                        add     hl,8                            ; .
                        push    hl                              ; .
                        pop     ix                              ; .
                        call    next_system_seed                ; .
                        ld		a,(XSAV)                        ; .
                        dec		a                               ; .
                        cp		0                               ; .
                        ret		z                               ; .
                        ld		(XSAV),a                        ; .
                        jr      SeedGalaxyLoop                  ; .
                        ret

GalaxyBankSize   EQU $ - galaxy_page_marker

