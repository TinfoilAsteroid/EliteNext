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

MMUSelectShipModelsA: MACRO
					 nextreg ShipModelMMU,	    BankShipModelsA
					 ENDM
MMUSelectShipModelsB: MACRO
					 nextreg ShipModelMMU,	    BankShipModelsB
					 ENDM
MMUSelectShipModelsC: MACRO
					 nextreg ShipModelMMU,	    BankShipModelsC
					 ENDM

MMUSelectShipModelA: MACRO
					 nextreg ShipModelMMU,	    a
					 ENDM

MMUSelectShipModelN: MACRO value
					 nextreg ShipModelMMU,	    value
					 ENDM
					 
MMUSelectCmdrData:	 MACRO
                     nextreg CmdrDataMMU,       BankCmdrData	
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
         
MMUSelectUniverseA:  MACRO
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
