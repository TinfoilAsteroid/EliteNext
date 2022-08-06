; Could move this into rom area for access as it will be read only
WordDummy					DB  "X",0
WordFront					DB	"Front",0              ;1
WordRight					DB	"Right",0              ;2
WordLeft 					DB	"Left",0               ;3
WordRear   	 				DB	"Rear",0               ;4
WordLarge           		DB  "Large",0              ;5
WordEscape          		DB  "Escape",0             ;6
WordPod             		DB  "Pod",0                ;7
WordCargo           		DB  "Cargo",0              ;8
WordBay             		DB  "Bay",0                ;9
WordFuel            		DB  "Fuel",0               ;10
WordScoops          		DB  "Scoops",0             ;11
WordECM             		DB  "E.C.M.",0             ;12
WordSystem          		DB  "System",0             ;13
WordEnergy					DB  "Energy",0             ;14
WordBomb					DB  "Bomb",0               ;15
WordLaser					DB  "Laser",0              ;16
WordPulse           		DB  "Pulse",0              ;17
WordBeam            		DB  "Beam",0               ;18
WordMiliary         		DB  "Miliary",0            ;19
WordMining          		DB  "Mining",0             ;20
WordCustom          		DB  "Custom",0             ;21
WordUnit            		DB  "Unit",0               ;22
WordShield          		DB  "Shield",0             ;23
WordDocking         		DB  "Docking",0            ;24
WordComputers       		DB  "Computers",0          ;25
WordHyperspace      		DB  "Hyperspace",0         ;26
WordGalactic        		DB  "Galactic",0           ;27
WordExtra           		DB  "Extra",0              ;28
WordClean           		DB  "Clean",0              ;29
WordOffender        		DB  "Offender",0           ;30
WordFugitive        		DB  "Fugitive",0           ;31
WordFood					DB	"Food",0               ;32
WordTextiles				DB 	"Textiles",0           ;33
WordRadioactives			DB  "Radioactives",0       ;34
WordSlaves					DB  "Slaves",0             ;35
WordLiquorWines     		DB  "Liquor/Wines",0       ;36
WordLuxuries  	    		DB  "Luxuries",0	       ;37
WordNarcotics  	    		DB  "Narcotics",0	       ;38
WordMachinery  	    		DB  "Machinery",0	       ;39
WordAlloys  				DB  "Alloys",0		       ;40
WordFirearms  	    		DB  "Firearms",0	       ;41
WordFurs  		    		DB  "Furs",0	           ;42
WordMinerals  	    		DB  "Minerals",0           ;43
WordGold  		    		DB  "Gold",0	           ;44
WordPlatinum  	    		DB  "Platinum",0           ;45
WordGemStones  				DB  "Gem-Stones",0         ;46
WordAlienItems      		DB  "Alien Items",0        ;47
WordTonnes          		DB  "Tonnes",0             ;48
WordKilograms       		DB  "Kilograms",0          ;49
WordGrams           		DB  "Grams",0			   ;50
WordShort           		DB  "Short",0			   ;51
WordRange           		DB  "Range",0			   ;52
WordChart	        		DB  "Chart",0			   ;53
WordData					DB	"Data",0			   ;54
WordOn						DB  "On",0                 ;55
WordDistance        		DB  "Distance",0           ;56
WordEconomy         		DB  "Economy",0            ;57
WordGovernment      		DB  "Government",0         ;58
WordTechLevel       		DB  "TechLevel",0          ;59
WordPopulation      		DB  "Population",0         ;60
WordMillion         		DB  "Million",0            ;61
WordBillion         		DB  "Billion",0            ;62
WordGross           		DB  "Gross",0              ;63
WordProductivity    		DB  "Productivity",0       ;64
WordAverage         		DB  "Average",0            ;65
WordRadius          		DB  "Radius",0             ;66
WordKM              		DB  "KM",0                 ;67
WordMCR             		DB  "M CR",0               ;68
WordRich					DB  "Rich",0               ;69
WordAvg         			DB  "Avg",0            	   ;70
WordMainly          		DB  "Mainly",0             ;71
WordPoor            		DB  "Poor",0               ;72
WordIndustrial      		DB  "Industrial",0         ;73
WordAgricultural    		DB  "Agricultural",0       ;74
WordAnarchy                 DB  "Anarchy",0            ;75
WordFeudal                  DB  "Feudal",0             ;76
WordMultiGovernment         DB  "Multi-Government",0   ;77
WordDictatorship            DB  "Dictatorship",0       ;78
WordCommunist               DB  "Communist",0          ;79
WordConfederacy             DB  "Confederacy",0        ;80
WordDemocracy               DB  "Democracy",0          ;81
WordCorporate               DB  "Corporate State",0    ;82
WordState 					DB  "State",0              ;83
WordLight 					DB  "Light",0              ;84
WordYears 					DB  "Years",0              ;85
Word0						DB  "0",0				   ;86
WordMarket					DB  "Market",0			   ;87
WordPrices					DB  "Prices",0			   ;88
WordProduct    				DB  "Product",0  		   ;89
WordUoM						DB  "UoM",0                ;90
WordPrice					DB  "Price",0              ;91
WordFor                     DB  "For",0                ;92
WordSale                    DB  "Sale",0               ;93
Wordt						DB  "t",0                  ;94
Wordkg						DB  "kg",0                 ;95
Wordg						DB  "g",0                  ;96
WordQuantity				DB  "Quanitity",0		   ;97
WordInv                     DB  "Inv",0                ;98
WordStock                   DB  "Stock",0              ;99
WordEquip                   DB  "Equip",0              ;100
WordShip                    DB  "Ship",0               ;101
;WordMissile                 DB  "Missile",0            ;102
WordHyperdrive              DB  "Hyperdrive",0
WordMilitary                DB  "Military",0
WordAdder                   DB  "Adder",0
WordAnaconda                DB  "Anaconda",0
WordAsp_Mk_2                DB  "Asp_Mk_2",0
WordBoa                     DB  "Boa",0
WordCargoType5              DB  "CargoType5",0
WordBoulder                 DB  "Boulder",0
WordAsteroid                DB  "Asteroid",0
WordBushmaster              DB  "Bushmaster",0
WordChameleon               DB  "Chameleon",0
WordCobraMk3                DB  "CobraMk3",0
WordCobra_Mk_1              DB  "Cobra_Mk_1",0
WordCobra_Mk_3_P            DB  "Cobra_Mk_3_P",0
WordConstrictor             DB  "Constrictor",0
WordCoriolis                DB  "Coriolis",0
WordCougar                  DB  "Cougar",0
WordDodo                    DB  "Dodo",0
WordDragon                  DB  "Dragon",0
WordEscape_Pod              DB  "Escape_Pod",0
WordFer_De_Lance            DB  "Fer_De_Lance",0
WordGecko                   DB  "Gecko",0
WordGhavial                 DB  "Ghavial",0
WordIguana                  DB  "Iguana",0
WordKrait                   DB  "Krait",0
WordLogo                    DB  "Logo",0
WordMamba                   DB  "Mamba",0
WordMissile                 DB  "Missile",0
WordMonitor                 DB  "Monitor",0
WordMoray                   DB  "Moray",0
WordOphidian                DB  "Ophidian",0
WordPlate                   DB  "Plate",0
WordPython                  DB  "Python",0
WordPython_P                DB  "Python_P",0
WordRock_Hermit             DB  "Rock_Hermit",0
WordShuttleType9            DB  "ShuttleType9",0
WordShuttle_Mk_2            DB  "Shuttle_Mk_2",0
WordSidewinder              DB  "Sidewinder",0
WordSplinter                DB  "Splinter",0
WordTestVector              DB  "TestVector",0
WordThargoid                DB  "Thargoid",0
WordThargon                 DB  "Thargon",0
WordTransportType10         DB  "TransportType10",0
WordViper                   DB  "Viper",0
WordWorm                    DB  "Worm",0
WordRattler                 DB  "Rattler",0

WordIdx				DW  WordDummy,          WordFront,        WordRight,        WordLeft		;0-3
					DW  WordRear,           WordLarge,        WordEscape,       WordPod      	;4-7
					DW  WordCargo,          WordBay,          WordFuel,         WordScoops   	;8
					DW  WordECM,            WordSystem,       WordEnergy,       WordBomb     	;12
					DW  WordLaser,          WordPulse,        WordBeam,         WordMiliary  	;16
					DW  WordMining,         WordCustom,       WordUnit,         WordShield   	;20
					DW  WordDocking,        WordComputers,    WordHyperspace,   WordGalactic 	;24
					DW  WordExtra,          WordClean,        WordOffender,     WordFugitive	;28
					DW  WordFood,           WordTextiles,     WordRadioactives, WordSlaves		;32
					DW  WordLiquorWines,    WordLuxuries,     WordNarcotics,    WordMachinery   ;36
					DW  WordAlloys,         WordFirearms,     WordFurs,         WordMinerals    ;40
					DW  WordGold,           WordPlatinum,     WordGemStones,    WordAlienItems  ;44               ;
WordIdxUoMFull		DW  WordTonnes,         WordKilograms,    WordGrams,		WordShort		;48
					DW	WordRange,		    WordChart,        WordData,         WordOn          ;52
					DW  WordDistance,       WordEconomy,      WordGovernment,   WordTechLevel   ;56
					DW  WordPopulation,     WordMillion,      WordBillion,      WordGross       ;60
					DW  WordProductivity,   WordAverage,      WordRadius,       WordKM          ;64
					DW  WordMCR																	;68
WordIdxEconomy		DW  WordRich,           WordAvg,      	  WordMainly,       WordPoor        ;69
                    DW  WordIndustrial,     WordAgricultural									;73
WordIdxGovernment	DW  WordAnarchy,        WordFeudal,       WordMultiGovernment, WordDictatorship ;75
                    DW  WordCommunist,      WordConfederacy,  WordDemocracy,       WordCorporate ;79
					DW  WordState,          WordLight,        WordYears,           Word0         ; 83
WordIdxMarketmenu	DW  WordMarket,         WordPrices,       WordProduct,         WordUoM	    ;87
                    DW  WordPrice,          WordFor,          WordSale                          ;91
WordIdxUomAbbrev	DW	Wordt,				Wordkg,           Wordg                 		    ;94	
					DW  WordQuantity,       WordInv,          WordStock,           WordEquip	;97
                    DW  WordShip,           WordMissile       ; 101
WordIdxShipNames:   DW  WordAdder,          WordAnaconda,     WordAsp_Mk_2,        WordBoa
                    DW  WordCargoType5,     WordBoulder,      WordAsteroid,        WordBushmaster
                    DW  WordChameleon,      WordCobraMk3,     WordCobra_Mk_1,      WordCobra_Mk_3_P
                    DW  WordConstrictor,    WordCoriolis,     WordCougar,          WordDodo
                    DW  WordDragon,         WordEscape_Pod,   WordFer_De_Lance,    WordGecko
                    DW  WordGhavial,        WordIguana,       WordKrait,           WordLogo
                    DW  WordMamba,          WordMissile,      WordMonitor,         WordMoray
                    DW  WordOphidian,       WordPlate,        WordPython,          WordPython_P
                    DW  WordRock_Hermit,    WordShuttleType9, WordShuttle_Mk_2,    WordSidewinder
                    DW  WordSplinter,       WordTestVector,   WordThargoid,        WordThargon
                    DW  WordTransportType10,WordViper,        WordWorm,            WordRattler 
; Phrases
TextLargeCargoBay			DB 	5,8,9,0          ;0
TextEscapePod				DB	6,7,0            ;1
TextFuelScoops				DB	10,11,0          ;2
TextECMSystem				DB	12,13,0          ;3
TextEnergyBomb				DB	14,15,0          ;4
TextEnergyUnit				DB	14,22,0          ;5
TextDockingComp     		DB  24,25,0          ;6
TextGalacticHyper			DB	27,26,0          ;7
TextFrontLaser      		DB  01,18,16,0       ;8
TextLeftLaser       		DB  03,18,16,0       ;9
TextRightLaser      		DB  02,18,16,0       ;10
TextRearLaser       		DB  04,18,16,0       ;11
TextShortRangeChart 		DB	51,52,53,0       ;12
TextGalacticChart   		DB	27,53,0          ;13
TextDataOn					DB	54,55,0          ;14
TextRichIndustrial          DB  69,73,0          ;15
TextAvgIndustrial           DB  70,73,0			 ;16
TextMainIndustrial          DB  71,73,0          ;17
TextPoorIndustrial          DB  72,73,0          ;18
TextRichAgricultural        DB  69,74,0          ;19
TextAvgAgricultural         DB  70,74,0          ;20
TextMainAgricultural        DB  71,74,0          ;21
TextPoorAgricultural        DB  72,74,0          ;22
TextLightYears				DB  84,85,0			 ;23
Text0LightYears				DB  86,84,85,0		 ;24
TextMarketPrices			DB  87,88,0			 ;25
TextEquipShip               DB  100,101          ;26

TextDummy					DB  0

TextTokens			DW  TextLargeCargoBay, TextEscapePod, TextFuelScoops				; 0 2
					DW  TextECMSystem, TextEnergyBomb, TextEnergyUnit					; 3 5
					DW  TextDockingComp, TextGalacticHyper  							; 6 7
					DW	TextFrontLaser, TextLeftLaser, TextRightLaser, TextRearLaser	; 8 11
					DW  TextShortRangeChart, TextGalacticChart, TextDataOn				; 12 14			
TextTokenEconomy	DW  TextRichIndustrial, TextAvgIndustrial, TextPoorIndustrial, TextMainIndustrial, TextMainAgricultural, TextRichAgricultural, TextAvgAgricultural,  TextPoorAgricultural
					DW  TextLightYears		                                            ; 21 23
					DW  Text0LightYears, TextMarketPrices	
					DW  TextDummy;  25
TextBuffer			DS	33

TextEconomyOffset   EQU (TextTokenEconomy - TextTokens)/2
TextGovOffset       EQU (WordIdxGovernment - WordIdx)/2

CapitaliseString:
; ">CapitaliseString hl = address"
.CapLoop:
	inc		hl
	ld		a,(hl)
	cp		0
	ret		z
	cp		'Z'+1
	jr		nc,.CapLoop
	cp		'A'
	jr		c,.CapLoop
.LowerCase:
	add		a,'a'-'A'
	ld		(hl),a
	jr		.CapLoop

ShipIndexToAddress      ld      hl,WordIdxShipNames
                        jp      WordLookup

WordIndexToAddress:     ld		hl,WordIdx
WordLookup:             add		hl,a
                        add		hl,a
                        push	de
                        ld		e,(hl)
                        inc		hl
                        ld		d,(hl)
                        ex		de,hl
                        pop		de
                        ret
	
	
expandTokenToString:
; ">expandTokenToString a = texttoken"
	ld		hl,TextTokens
	call	getTableText
	ld		de,TextBuffer
.ReadLoop:
	ld		a,(hl)
	cp		0
	jr		z,.ReadDone
	push	hl
	push	de
	ld		hl,WordIdx
	call	getTableText
	pop		de
.WordExpandLoop:
	ld		a,(hl)
	cp		0
	jr		z,.AddSpace
;.GetChar:
	ld		(de),a
	inc		de
	inc		hl
	jr		.WordExpandLoop
.AddSpace:
	ld		a,' '
	ld		(de),a
	inc		de
	pop		hl
	inc		hl
	jr		.ReadLoop
.ReadDone:
	dec		de
	xor		a
	ld		(de),a
	ret
