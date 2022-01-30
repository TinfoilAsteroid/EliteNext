MMUSelectSpriteBank: MACRO
					 nextreg SpritememMMU,	    BankSPRITE
					 ENDM

MMUSelectConsoleBank: MACRO
					 nextreg ConsoleImageDataMMU,  BankConsole
					 ENDM
					 
MMUSelectLayer1: 	 MACRO
					 nextreg L1memMMU,		    BankLAYER1
					 ENDM					 

MMUSelectLayer2: 	 MACRO
					 nextreg L2memMMU,		    BankLAYER2
					 ENDM					 
					 
MMUSelectResetUniv:  MACRO
                     nextreg  ResetUniverseMMU, BankResetUniv
                     ENDM

MMUSelectShipBank1:  MACRO
					 nextreg ShipModelMMU,	    BankShipModels1
					 ENDM
MMUSelectShipBank2:  MACRO
					 nextreg ShipModelMMU,	    BankShipModels2
					 ENDM
MMUSelectShipBank3:  MACRO
					 nextreg ShipModelMMU,	    BankShipModels3
					 ENDM
MMUSelectShipBank4:  MACRO
					 nextreg ShipModelMMU,	    BankShipModels4
					 ENDM
                     
MMUSelectShipBankA   MACRO
					 nextreg ShipModelMMU,	    a
					 ENDM

MMUSelectShipBankN:  MACRO value
					 nextreg ShipModelMMU,	    value
					 ENDM
					 
MMUSelectCommander:	 MACRO
                     nextreg CommanderMMU,       BankCommander	
					 ENDM

MMUSelectStockTable: MACRO
                     nextreg StockTableMMU,     BankStockTable	
					 ENDM				 
					 
MMUSelectCpySrcA:    MACRO
                     nextreg DMACpySourceMMU,	a
					 ENDM	

MMUSelectCpySrcN:    MACRO value
                     nextreg DMACpySourceMMU,	value
					 ENDM	
         
MMUSelectSun:        MACRO
                     nextreg SunMMU,            BankSunData
                     ENDM

MMUSelectPlanet:     MACRO
                     nextreg PlanetMMU,         PlanetBankAddr
                     ENDM

MMUSelectUniverseA:  MACRO
                     add    a,BankUNIVDATA0
                     nextreg UniverseMMU,       a
                     ENDM

MMUSelectUniverseN:  MACRO value
                     nextreg UniverseMMU,       BankUNIVDATA0+value
                     ENDM
                     
MMUSelectGalaxyA:    MACRO
                     nextreg GalaxyDataMMU,       a
                     ENDM

MMUSelectGalaxyN:    MACRO value
                     nextreg GalaxyDataMMU,     BankGalaxyData0+value
                     ENDM
MMUSelectGalaxyACopy:MACRO
                     nextreg UniverseMMU,       a
                     ENDM
 
MMUSelectUniverseAbs:MACRO value
                     nextreg UniverseMMU,       value
                     ENDM

MMUSelectMenuGalCht: MACRO
                     nextreg MenuGalChtMMU,		BankMenuGalCht
					 ENDM	
 
MMUSelectMenuShrCht: MACRO
					 nextreg MenuShrChtMMU,		BankMenuShrCht
					 ENDM	
					 
MMUSelectMenuInvent: MACRO
                     nextreg MenuInventMMU,		BankMenuInvent
					 ENDM	
                                         
MMUSelectMenuSystem: MACRO
                     nextreg MenuSystemMMU,		BankMenuSystem
					 ENDM	                    

MMUSelectMenuMarket: MACRO
                     nextreg MenuMarketMMU,		BankMenuMarket
					 ENDM

MMUSelectMenuStatus: MACRO
                     nextreg MenuStatusMMU,		BankMenuStatus
					 ENDM

MMUSelectViewFront:  MACRO
                     nextreg ScreenBankMMU,		BankFrontView
					 ENDM
                     
MMUSelectScreenA:    MACRO
                     nextreg ScreenBankMMU,		a
					 ENDM
