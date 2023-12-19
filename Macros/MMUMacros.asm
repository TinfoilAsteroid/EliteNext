MMUSelectROM0:       MACRO
                     nextreg EXSDOSMMU0,        BankROM 
                     ENDM

MMUSelectROMS:       MACRO
                     nextreg EXSDOSMMU0,        BankROM
                     nextreg EXSDOSMMU1,        BankROM
                     ENDM
                     
MMUSelectMathsTables:MACRO
                     nextreg MathsTablesMMU,    BankMathsTables
                     ENDM

MMUSelectKeyboard:   MACRO
                     nextreg KeyboardMMU,       BankKeyboard
                     ENDM

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
                     nextreg ResetUniverseMMU, BankResetUniv
                     ENDM

MMUSelectShipARead:  MACRO
                     add    a,BankUNIVDATA0 
                     nextreg ShipReadMMU,       a
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
                     nextreg PlanetMMU,         BankPlanetData
                     ENDM

MMUSelectUniverseA:  MACRO
                     add    a,BankUNIVDATA0
                     nextreg UniverseMMU,       a
                     ENDM
;Version that assumes a pre calulated A, used whn optimising many switches
MMUSelectUnivBankA:  MACRO
                     nextreg UniverseMMU,       a
                     ENDM

MMUSelectUniverseN:  MACRO value
                     nextreg UniverseMMU,       BankUNIVDATA0+value
                     ENDM

MMUSelectSpaceStation: MACRO
                     nextreg SpaceStationMMU,   BankSpaceStationData
                     ENDM

MMUSelectMathsBankedFns   MACRO
                     nextreg MathsBankedFnsMMU, BankMathsBankedFns
                     ENDM
                     
MMUSelectGalaxyA:    MACRO
                     nextreg GalaxyDataMMU,     a
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

MMUSelectSound:      MACRO
                     nextreg SoundMMU,		    BankSound
					 ENDM
                     


SaveMMU6:           MACRO
                    GetNextReg  MMU_SLOT_6_REGISTER
                    ld      (SavedMMU6),a
                    ENDM

RestoreMMU6:        MACRO     
                    ld      a,(SavedMMU6)               ; now restore up post interrupt
                    nextreg MMU_SLOT_6_REGISTER,a       ; Restore MMU7                   
                    ENDM

SaveMMU7:           MACRO
                    GetNextReg  MMU_SLOT_7_REGISTER
                    ld      (SavedMMU7),a
                    ENDM

RestoreMMU7:        MACRO     
                    ld      a,(SavedMMU7)               ; now restore up post interrupt
                    nextreg MMU_SLOT_7_REGISTER,a       ; Restore MMU7                   
                    ENDM                     