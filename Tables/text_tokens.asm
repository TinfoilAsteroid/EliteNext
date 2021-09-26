TextTokens:
; ">$00 is end of message token where tokenised?, doesnt match for first 3"
57EOR			equb	&57		
TKN1:			DB		$09,$0B, $01, $08, " DISK ACCESS MENU ", $0C, $0A, $0A, $02
LOAD1:			DB		"1. ", $95, $D7 												; 1. LOAD' NEW 'x13 COMMANDER x0cx0a
SAVE1:			DB      "2. S", $53, $4, $FA, $20, $9A, $20, $04, $D7					; 2. SAVE x13 COMMANDER x04=cmn x0cx0a
CAT3:			DB		"3. C", $33, $2E, $20, $43, $F5, $41, $E0, $47, $55, $45, $D7 	; 3. CATALOGUE x0cx0a
DEL4:			DB 		"4. DEL", $DD, $45, $D0, $46, $49, $E5, $D7 					; 4. DELETE' A 'FILE x0cx0a
EXIT5:			DB		"5. EX", $DB, $D7, $00											; 5. EXIT x0cx0a // 01 first token 
WHICHDRIVE:		DB		$0c, "WHICH ", $97, $3F, $00									; x0c WHICH DRIVE?			// 02 second token
COMPNUMBER:		DB		"COMPE", $FB, $FB, $DF, $20, $E1, $4D, $42, $F4, $3A, $00 		; COMPETITI'ON' 'NU'MB'ER':		// 03 
DRIVEMSG:		DB		$96, $97, $20, $10, $98, $D7, $00 								; x09x0bx01x08'DRIVE ' x10=MT16=printsDTW7 'CATALOGUE' x0cx0a	// 04
PLANTDESC:		DB 		$B0, $6D, $CA, $6E, $B1, $00 				      				; Planet description string is fifth token =  x6d is x6e  x0dx0ex13 x6d' IS 'x6e .x0cx0f 		// 05   
LOADNEW:		DB		"  ", 0x95, 
20 20 95 20 01 28 59 2F 4E 29 3F 02 0C 0C 00  	      
\ LOAD NEW COMMANDER x01(Y/N)? x02x0cx0c							// 06 

07 A5 04 04 77 04 07 16 BE 77 AA 77 11 1E A5 7B 
50 F2 53 53 20 53 50 41 E9 20 FD 20 46 49 F2 2C		
\ PRESS SPACE OR FIRE,

CD 79 5B 5B 57
9A 2E 0C 0C 00 						
\ x13 COMMANDER. x0cx0c										// 07

CD 70 04 9F 57  
9A 27 53 C8 00 						
\ x13 COMMANDER'S' NAME? '									// 08

42 11 1E B2 9E 13 12 1B 8A 12 68 57
15 46 49 E5 C9 44 45 4C DD 45 3F 00 			
\ x15 FILE' TO 'DELETE?										// 09  nineth token

40 59 55 10 A5 8A A7 10 04 82 
17 0E 02 47 F2 DD F0 47 53 D5 
\ x17 x0e x02 GREETINGS x13 COMMANDER x04, I x0d AM x02 CAPTAIN x1b x0 OF HER MAJESTY'S SPACE NAVY

E5 44 1E 77 A0 10 87 1A 18 1A A1 03 77 18 11 77 E4 05 77 01 B3 02 8F B2 77 AC 1A 12 9B
B2 13  49 20 F7 47 D0 4D 4F 4D F6 54 20 4F 46 20 B3 52 20 56 E4 55 D8 E5 20 FB 4D 45 CC
\ ' AND 'x13 I BEG' A 'MOMENT OF YOU'R VALUABLE TIME .x0c x13

00 12 77 00 8E 1B 13 77 1B 1E 1C 12 77 E4 9E 13 18 87 1B 8C 03 B2 77 1D 18 15 77 11 AA 77 BB 9B 
57 45 20 57 D9 4C 44 20 4C 49 4B 45 20 B3 C9 44 4F D0 4C DB 54 E5 20 4A 4F 42 20 46 FD 20 EC CC
\ WE WOULD LIKE YOU TO 'DO' A 'LITTLE JOB FOR US.x0c x13

C4 98 77 E4 77 8D 12 77 1F 12 A5 9D 16 85 1A 18 13 12 1B 7B 77 C4 44 14 88 89 05 1E 14 03 AA 7B 
93 CF 20 B3 20 DA 45 20 48 45 F2 CA 41 D2 4D 4F 44 45 4C 2C 20 93 13 43 DF DE 52 49 43 54 FD 2C
\ 'THE 'SHIP' YOU' SEE HERE' IS 'A NEW 'MODEL, 'THE 'x13CONSTRICTOR,

77 12 A9 1E 07 93 00 1E B5 87 03 18 07 77 8D 14 05 8A 85 04 1F 1E 12 1B 13 77 10 A1 A3 A2 AA 
20 45 FE 49 50 C4 57 49 E2 D0 54 4F 50 20 DA 43 52 DD D2 53 48 49 45 4C 44 20 47 F6 F4 F5 FD
\ EQUIP'ED 'WITH' A 'TOP SECRET' NEW 'SHIELD GENERATOR

9B 02 19 11 AA 03 02 19 A2 12 1B 0E 77 8C 70 04 77 A0 A1 77 89 18 1B A1  
CC 55 4E 46 FD 54 55 4E F5 45 4C 59 20 DB 27 53 20 F7 F6 20 DE 4F 4C F6 
\ .x0c x13 UNFORTUNATELY IT'S BEEN STOLEN

9B 41 8C 77 00 A1 03 77 1A 1E 04 04 94 11 05 18 1A 77 8E 05 77 98 77 0E B9 13 77 88 77
CC 16 DB 20 57 F6 54 20 4D 49 53 53 C3 46 52 4F 4D 20 D9 52 20 CF 20 59 EE 44 20 DF 20 
\ .x0c x13 x16IT WENT MISS'ING 'FROM OUR SHIP YARD ON  \ x16 =  PAUSE
 
44 B1 A3 77 11 1E AD 77 1A 88 B5 04 77 16 10 18 E5 4B 9B E4 05 77 1A 1E 04 04 1E 88 7B  
13 E6 F4 20 46 49 FA 20 4D DF E2 53 20 41 47 4F B2 1C CC B3 52 20 4D 49 53 53 49 DF 2C 
\x13XEER FIVE MONTHS AGO' AND 'x1c.x0c x13 'YOU'R MISSION, 
\ 			       x1c = was last seen at Reesdice/jumped to this galaxy	 

77 04 1F 8E 1B 13 77 E4 77 13 12 14 1E 13 12 9E 16 14 BE 07 03 77 8C 7B 77 1E 04 9E 8D 12 1C
20 53 48 D9 4C 44 20 B3 20 44 45 43 49 44 45 C9 41 43 E9 50 54 20 DB 2C 20 49 53 C9 DA 45 4B
\SHOULD' YOU 'DECIDE' TO 'ACCEPT IT, IS' TO 'SEEK
 
E5 13 BA 03 05 18 0E  77 C3 98 9B E4 77 16 A5 77 14 16 02 AC 88 93 B5 A2 77 88 1B 0E 
B2 44 ED 54 52 4F 59 20 94 CF CC B3 20 41 F2 20 43 41 55 FB DF C4 E2 F5 20 DF 4C 59 
\' AND 'DESTROY' THIS 'SHIP.x0c x13'YOU 'ARE CAUTION'ED 'THAT ONLY 

77 51 22 52 04 77 00 8B 1B 77 07 A1 8A AF 03 12 77 C4 19 12 00 77 04 1F 1E 12 1B 13 04 E5 B5 A2 77 C4
20 06 75 05 53 20 57 DC 4C 20 50 F6 DD F8 54 45 20 93 4E 45 57 20 53 48 49 45 4C 44 53 B2 E2 F5 20 93 
\ x06x75x05S  military lasers  WILL PENETRATE' THE 'NEW SHIELDS' AND 'THAT 'THE '

44 14 88 89 05 1E 14 03 AA 9D 11 8C 03 93 00 1E B5 77 A8
13 43 DF DE 52 49 43 54 FD CA 46 DB 54 C4 57 49 E2 20 FF
\ x13CONSTRICTOR' IS 'FITT'ED 'WITH AN

77 51 3B 52 E6 55 5F 10 18 18 13 77 1B 02 14 1C 7B 77 CD 83 41 57
20 06 6C 05 B1 02 08 47 4F 4F 44 20 4C 55 43 4B 2C 20 9A D4 16 00 
\ x06x6cx05  e.c.m.system.x0cx0fx02x08  GOOD LUCK,x13COMMANDER .x0cx0fx08x01 MESSAGE ENDSx16	// 0A	tenth token

4E 5E 40 59 55 77 77 A2 03 A1 AC 88 82 79 77 44
19 09 17 0E 02 20 20 F5 54 F6 FB DF D5 2E 20 13
\ x19x09x17x0ex02  ATTENTIONx13COMMANDER x04, Ix0dAMx02 CAPTAINx1b x0OF HER MAJESTY'S SPACE NAVY.x13
 
00 12 77 1F 16 AD 77 19 12 93 18 11 77 E4 05 77 8D 05 01 1E 14 BA 77 16 10 16 A7
57 45 20 48 41 FA 20 4E 45 C4 4F 46 20 B3 52 20 DA 52 56 49 43 ED 20 41 47 41 F0
\ WE HAVE NE'ED 'OF 'YOU'R SERVICES AGAIN

9B 1E 11 77 E4 77 00 8E 1B 13 77 A0 77 BC 77 10 18 18 13 77 16 04 9E 10 18 9E 
CC 49 46 20 B3 20 57 D9 4C 44 20 F7 20 EB 20 47 4F 4F 44 20 41 53 C9 47 4F C9
\.x0c x13 IF 'YOU' WOULD BE SO GOOD AS' TO 'GO ' TO 

44 BE A3 A6 77 E4 77 00 8B 1B 77 A0 77 15 05 1E 12 11 AB 9B 1E 11 77 04 02 14 BE 04 04 11 02 1B 7B
13 E9 F4 F1 20 B3 20 57 DC 4C 20 F7 20 42 52 49 45 46 FC CC 49 46 20 53 55 43 E9 53 53 46 55 4C 2C
\'x13 CEERDI 'YOU 'WILL BE BRIEFED.x0c x13. IF SUCCESSFUL,

 77 E4 77 00 8B 1B 77 A0 77 00 12 1B 1B 77 A5 00 B9 13 AB 83 4F 57  
 20 B3 20 57 DC 4C 20 F7 20 57 45 4C 4C 20 F2 57 EE 44 FC D4 18 00  
\' YOU 'WILL BE WELL REWARDED.x0cx0fx08x01 MESSAGE ENDSx18					// 0B

7F 44 14 7E 77 16 14 AA 19 BC 11 03 77 66 6E 6F 63 57    
28 13 43 29 20 41 43 FD 4E EB 46 54 20 31 39 38 34 00 
\ (x13C) ACORNSOFT 1984										// 0C

15 0E 77 13 79 15 AF A0 19 77 71 77 1E 79 A0 1B 1B 57
42 59 20 44 2E 42 F8 F7 4E 20 26 20 49 2E F7 4C 4C 00 
\ BY D.BRABEN & I.BELL										// 0D

42 C6 9F 4D 57
15 91 C8 1A 00 
\ x15 PLANET' NAME? x1A	= MT26 string input							// 0E

4E 5E 40 59 55 77 77 14 88 10 AF 03 02 AE AC 88 04 77 CD 76 5B 5B B5 A3 12 
19 09 17 0E 02 20 20 43 DF 47 F8 54 55 F9 FB DF 53 20 9A 21 0C 0C E2 F4 45 
\x19x09x17x0e x02  CONGRATULATIONS x13 COMMANDER! x0c x0c THERE

5A 77 00 8B 1B 77 B3 00 16 0E 04 77 A0 87 07 AE BE 77 11 AA 77 E4 77 A7 84
0D 20 57 DC 4C 20 E4 57 41 59 53 20 F7 D0 50 F9 E9 20 46 FD 20 B3 20 F0 D3 
\x0d WILL ALWAYS BE ' A 'PLACE FOR 'YOU' IN HER MAJESTY'S SPACE NAVY

9B A8 13 77 B8 0E A0 77 BC 88 A3 77 B5 A8 77 E4 77 B5 A7 1C 79 79 83 4F 57
CC FF 44 20 EF 59 F7 20 EB DF F4 20 E2 FF 20 B3 20 E2 F0 4B 2E 2E D4 18 00 
\.x0c x13 AND MAYBE SOONER THAN YOU' THINK.. .x0c x0f x08 x01 MESSAGE ENDS x18=PAUSE2	   	// 0F fifteenth token


11 8F B2 13 57		\ X5b		Hex81
46 D8 E5 44 00 			\ FABLED		// 10 = sixteenth token

B4 03 8F B2 57
E3 54 D8 E5 00 			\ NOTABLE		// 11

00 12 1B 1B 77 1C B4 00 19 57
57 45 4C 4C 20 4B E3 57 4E 00  \ WELL KNOWN		// 12

11 16 1A 18 BB 57
46 41 4D 4F EC 00		\ FAMOUS		// 13

B4 03 AB 57    			\ fifth choice of X5b
E3 54 FC 00 			\ NOTED			// 14 

AD 05 0E 57		\ X5c     	Hex82
FA 52 59 00 			\ VERY			// 15

1A 8B 13 1B 0E 57 
4D DC 44 4C 59 00 		\ MILDLY		// 16

1A 18 89 57  
4D 4F DE 00 			\ MOST			// 17

A5 16 04 88 8F 1B 0E 57
F2 41 53 DF D8 4C 59 00  	\ REASONABLY		// 18

57				\ fifth choice of X5c = null 
00				\ BRK			// 19

F2 57 			\ X5d		Hex83   geographical adjectives
A5 00				\ ANCIENT		// 1A

25 57 
72 00				\ x72 =  wierd choices	// 1B

10 A5 A2 57      
47 F2 F5 00 			\ GREAT			// 1C

01 16 89 57
56 41 DE 00 			\ VAST			// 1D

07 A7 1C 57			\ fifth choice of X5d
50 F0 4B 00 			\ PINK			// 1E

55 20 77 21 5A 77 EE 16 AC 88 04 57 	\ X5e geographical feature
02 77 20 76 0D 20 B9 41 FB DF 53 00 
\x02 x77 x76 x13 = 		 e.g PLANTATIONS 	// 1F

CB 04 57 
9C 53 00 			\ MOUNTAIN S		// 20 

22 57				\			// 21
75 00 				\ x75 = parking meters..volcanoes 

D7 77 11 AA BA 03 04 57         \			// 22
80 20 46 FD ED 54 53 00 	\ x80 = types of forest FORESTS

18 BE A8 04 57 			\ fifth choice of X5e
4F E9 FF 53 00 			\ OCEANS		// 23 

04 1F 0E 19 BA 04 57	\ X63		Hex85  characteristic of inhabitants
53 48 59 4E ED 53 00 		\ SHYNESS		// 24

04 8B 1B A7 BA 04 57
53 DC 4C F0 ED 53 00 		\ SILLINESS		// 25

B8 03 94 03 AF A6 AC 88 04 57 
EF 54 C3 54 F8 F1 FB DF 53 00 	\ MAT'ING 'TRADITIONS 	// 26

B7 A2 1F 94 18 11 77 33 57 			
E0 F5 48 C3 4F 46 20 64 00 	\ LOATH'ING 'OF x64 	// 27

B7 AD 77 11 AA 77 33 57 	\ fifth choice of X63 
E0 FA 20 46 FD 20 64 00 	\ LOVE FOR x64		// 28

11 18 18 13 77 15 B2 19 13 A3 04 57 \ X64	Hex86
46 4F 4F 44 20 42 E5 4E 44 F4 53 00   \ FOOD BLENDERS	// 29

03 8E 05 1E 89 04 57   
54 D9 52 49 DE 53 00 			\ TOURISTS	// 2A

07 18 8A 05 0E 57
50 4F DD 52 59 00 			\ POETRY	// 2B

A6 04 14 18 04 57 
F1 53 43 4F 53 00 			\ DISCOS	// 2C

3B 57 					  		// 2D
6C 00 					\ x6c = cuisine etc.
				
00 B3 1C 94 C9 57		\ X61   	Hex87  animal'OID
57 E4 4B C3 9E 00			\WALK'ING 'TREE // 2E    not talking

14 AF 15 57 
43 F8 42 00 				\ CRAB		// 2F

15 A2 57
42 F5 00				\ BAT		// 30
 
B7 15 89 57 
E0 42 DE 00 				\ LOBST		// 31

45 57					  		// 32 
12 00   				\ x12=random name

A0 04 8A 57			\ X66   	Hex88
F7 53 DD 00 				\ BESET         // 33 

07 AE 10 02 AB 57 
50 F9 47 55 FC 00 			\ PLAGUED	// 34

AF 01 16 10 AB 57
F8 56 41 47 FC 00 			\ RAVAGED	// 35

14 02 05 04 AB 57 
43 55 52 53 FC 00 			\ CURSED	// 36

04 14 8E 05 10 AB 57			\ fifth choice of X66
53 43 D9 52 47 FC 00 			\ SCOURGED	// 37

26 77 14 1E 01 8B 77 00 B9 57  	\ X67    	Hex89   
71 20 43 49 56 DC 20 57 EE 00 		\x71 CIVIL WAR	// 38

3F 77 08 77 37 04 57     x5f=strange animals,  x60 =  strange animal/drink
68 20 5F 20 60 53 00 		
\x68 x5f x60S						// 39 

16 77 3F 77 A6 8D 16 8D 57
41 20 68 20 F1 DA 41 DA 00 		  \x68 = life-threatening adjective
\A x68 DISEASE						// 3A

26 77 12 B9 B5 A9 16 1C BA 57		  \x71 = adjectives for calamity
71 20 45 EE E2 FE 41 4B ED 00    
\x71 EARTHQUAKES					// 3B

26 77 BC AE 05 77 16 14 AC 01 8C 0E 57    \ fifth choice of X67
71 20 EB F9 52 20 41 43 FB 56 DB 59 00    
\x71 SOLAR ACTIVITY 					// 3C 

F8 0A 77 09 57       	\ X65         	Hex8A  	= its ..
AF 5D 20 5E 00 		   \'ITS 'x5d x5e  		// 3D    x5e = geographical feature

C4 46 77 08 77 37 57		 =x11  planet name-ian, x5f=strange animals
93 11 20 5F 20 60 00	   \'THE 'x11 x5f x60 		// 3E

F8 96 04 70 77 35 77 34 57      \ x62 = ingrained etc, x63 = characteristic of inhabitants 
AF C1 53 27 20 62 20 63 00 \'ITS 'INHABITANTS' x62 x63  // 3F  

55 2D 5A 57 		       				// 40
02 7A 0D 00 		   \ x02 x7a= near top-level aspect of planet x0d

F8 3C 77 3B 57 			     			// 41
AF 6B 20 6C 00 		   \ ITS x6b x6c  = cuisine etc. 

1D 02 1E BE 57		\ X69 		Hex8B     drinks
4A 55 49 E9 00 		   \ JUICE			// 42 

15 AF 19 13 0E 57
42 F8 4E 44 59 00	   \ BRANDY 			// 43 

0 A2 A3 57
57 F5 F4 00 		   \ WATER			// 44

15 A5 00 57  
42 F2 57 00 		   \ BREW			// 45

10 B9 10 B2 77 15 AE 89 A3 04 57 
47 EE 47 E5 20 42 F9 DE F4 53 00 \ GARGLE BLASTERS 	// 46

45 57			\ X6a         Hex8C 	creature/drinks adjectives
12 00 				 \ x12	= random name	// 47

46 77 37 57			     x60 =  strange animal/drink
11 20 60 00 		       	\x11 x60		// 48

46 77 45 57			     x12 = random name
11 20 12 00 		        \x11 x12		// 49

46 77 3F 57			      x11 = planet name-ian 
11 20 68 00 		       	\x11 x68		// 4A

3F 77 45 57   			x68 = life-threatening adjective, x12 = random name
68 20 12 00 		       	\x68 x12		// 4B

11 8F 02 B7 BB 57      \ X6b     Hex8D         adjective for social activity or animal		
46 D8 55 E0 EC 00 		\ FABULOUS		// 4C

12 0F 18 AC 14 57
45 58 4F FB 43 00 		\ EXOTIC		// 4D

1F 18 18 07 0E 57 
48 4F 4F 50 59 00 		\ HOOPY			// 4E

02 B6 04 02 B3 57 
55 E1 53 55 E4 00 		\ UNUSUAL		// 4F

12 0F 14 8C A7 10 57		\ fifth choice of X6b
45 58 43 DB F0 47 00 		\ EXCITING  		// 50 

14 02 1E 04 A7 12 57 	\ X6c 	Hex8E	love/loathing
43 55 49 53 F0 45 00 		\ CUISINE		// 51

19 1E 10 1F 03 77 1B 1E 11 12 57 
4E 49 47 48 54 20 4C 49 46 45 00 \ NIGHT LIFE 		// 52 

14 16 04 1E B4 04 57 
43 41 53 49 E3 53 00 		\ CASINOS		// 53

04 8C 77 14 18 1A 04 57
53 DB 20 43 4F 4D 53 00 	\ SIT COMS		// 54

55 2D 5A 57 			\ fifth choice of X6c
02 7A 0D 00 			\ x02x7ax0d		// 55   x7a= near top-level aspect of planet

54 57  			\ X6d    Hex8F [First half of string  
03 00 					\  x03		// 56

C4 C6 77 54 57              	\x03 planet name
93 91 20 03 00 			\ 'THE 'PLANET x03	// 57

C4 C5 77 54 57			
93 92 20 03 00 			\ 'THE 'WORLD x03	// 58

C3 C6 57
94 91 00 			\ 'THIS 'PLANET   	// 59

C3 C5 57 			\ fifth choice of X6d
94 92 00   			\ 'THIS 'WORLD    	// 5A

04 88 77 18 11 87 15 8C 14 1F 57   \  X73	5 rouge chocies
53 DF 20 4F 46 D0 42 DB 43 48 00 
	\ SON OF' A 'BITCH 				// 5B
04 14 8E 19 13 A5 1B 57
53 43 D9 4E 44 F2 4C 00 
	\ SCOUNDREL  					// 5C

15 AE 14 1C 10 02 B9 13 57 
42 F9 43 4B 47 55 EE 44 00 
	\ BLACKGUARD 					// 5D

05 18 10 02 12 57
52 4F 47 55 45 00 
	\ ROGUE 					// 5E

00 1F AA BA 88 77 A0 8A B2 77 1F 12 16 13
57 48 FD ED DF 20 F7 DD E5 20 48 45 41 44 
	\ WHORESON BEETLE HEAD		\ fifth choice of X73

91 11 AE 07 77 12 B9 70 13 77 1C 19 16 AD 57 \ xC6 = 00
C6 46 F9 50 20 45 EE 27 44 20 4B 4E 41 FA 00 \ not used?
\xc6  FLAP EAR'D KNAVE 	\				// 5F

19 77 02 19 A5 B8 05 1C 8F B2 57  \ X6f		Hex90     	'A' planet adjective choices
4E 20 55 4E F2 EF 52 4B D8 E5 00	N UNREMARKABLE 	// 60

77 15 AA A7 10 57  
20 42 FD F0 47 00 		 	BORING		// 61

77 13 02 1B 1B 57 
20 44 55 4C 4C 00 		 	DULL		// 62

77 03 12 A6 18 BB 57
20 54 45 F1 4F EC 00 		 	TEDIOUS		// 63

77 A5 01 18 1B 03 A7 10 57 		\ fifth choice of X6f 
20 F2 56 4F 4C 54 F0 47 00 	 	REVOLTING  	// 64 

C6 57				\ X70  		Hex91		planet noun, 2nd half
91 00					PLANET  	// 65
 
C5 57    				\ x92
92 00 					WORLD   	// 66 

07 AE BE 57
50 F9 E9 00 				PLACE   	// 67

1B 8C 03 B2 77 C6 57
4C DB 54 E5 20 91 00 			LITTLE PLANET 	// 68

13 02 1A 07 57				\ fifth choice of X70
44 55 4D 50 00 				DUMP   		// 69 

1E 77 1F 12 B9 87 25 77 B7 18 1C 94 98 77 16 07 07 12 B9 93 A2 86 57	\ X74   Errius 5 choices 
49 20 48 45 EE D0 72 20 E0 4F 4B C3 CF 20 41 50 50 45 EE C4 F5 D1 00 
\ I HEAR' A 'x72 LOOKING 'SHIP APPEAR'ED 'AT' ERRIUS' 	// 6A  		\ x72 =  wierd choices

0E 12 16 1F 7B 77 1E 77 1F 12 B9 87 25 77 98 77 B2 11 03 86 
59 45 41 48 2C 20 49 20 48 45 EE D0 72 20 CF 20 E5 46 54 D1
	\ YEAH, I HEAR' A 'x72' SHIP' LEFT' ERRIUS    			\ x72 =  wierd choices

87 77  00 1F 1E B2 77 15 16 14 1C 57  
D0 20 57 48 49 E5 20 42 41 43 4B 00 
	\ A' WHILE BACK 				// 6B

10 8A 77 E4 05 77 1E 05 88 77 16 04 04 77 18 01 A3 77 03 18 86 57
47 DD 20 B3 52 20 49 52 DF 20 41 53 53 20 4F 56 F4 20 54 4F D1 00
	\ GET 'YOU'R IRON ASS OVER TO' ERRIUS '		// 6C

BC 1A 12 77 24 85 98 77 00 16 04 77 8D A1 77 A2 86 57   
EB 4D 45 20 73 D2 CF 20 57 41 53 20 DA F6 20 F5 D1 00 
	\ SOME x73' NEW 'SHIP WAS SEEN AT' ERRIUS ' 	// 6D   	\ x73 = 5 rouge choices

03 05 0E 86 57				\ fifth choice of X74
54 52 59 D1 00 				TRY' ERRIUS '	// 6E 

57 57 57 57		\ Elite-A uses 3 of these for special cargo and modified credit.
00 00 00 00		BRK: BRK: BRK: BRK 

00 16 04 07 57			\ X7e 		Hex 92  small animal, creatures v)
57 41 53 50 00 				WASP		// 73

1A 18 B5 57    
4D 4F E2 00 				MOTH		// 74

10 05 02 15 57 
47 52 55 42 00 				GRUB		// 75

A8 03 57
FF 54 00				ANT		// 76 

45 57					\ fifth choice of X7e  x12 = HexB2 random name
12 00 					x12		// 77

07 18 8A 57			\ X7f		Hex93	strange animals iv)
50 4F DD 00 				POET            // 78 

B9 03 04 77 10 AF 13 02 A2 12 57 
EE 54 53 20 47 F8 44 55 F5 45 00 	ARTS GRADUATE   // 79

0E 16 1C 57
59 41 4B 00				YAK		// 7A

04 19 16 8B 57   
53 4E 41 DC 00 				SNAIL		// 7B

04 1B 02 10 57 				\ fifth choice of X7f 
53 4C 55 47 00 				SLUG		// 7C 

03 05 18 07 1E 14 B3 57		\ X80 		Hex94  	types of forest 
54 52 4F 50 49 43 E4 00 		TROPICAL	// 7D

13 A1 8D 57 
44 F6 DA 00 				DENSE		// 7E 

AF A7 57
F8 F0 00 				RAIN		// 7F

1E 1A 07 A1 8A AF 15 B2 57
49 4D 50 F6 DD F8 42 E5 00 		IMPENETRABLE	// 80

12 0F 02 A0 AF 19 03 57 		\ fifth choice of X80 last block added
45 58 55 F7 F8 4E 54 00 		EXUBERANT	// 81

11 02 19 19 0E 57		\ X72 		Hex95 	adjective for geography/inhabitants/constrictor 
46 55 4E 4E 59 00 			FUNNY		// 82

00 1E A3 13 57				\ oops
57 49 F4 44 00 				WIERD		// 83  

02 B6 04 02 B3 57 
55 E1 53 55 E4 00 			UNUSUAL		// 84

89 AF 19 B0 57
DE F8 4E E7 00				STRANGE		// 85 	

07 12 14 02 1B 1E B9 57   		\ fifth choice of X72
50 45 43 55 4C 49 EE 00 		PECULIAR	// 86 

11 A5 A9 A1 03 57		\ X71		 Hex96  adjectives for calamity
46 F2 FE F6 54 00 			FREQUENT	// 87 

18 14 14 16 04 1E 88 B3 57
4F 43 43 41 53 49 DF E4 00 		OCCASIONAL	// 88

02 19 07 A5 A6 14 03 8F B2 57
55 4E 50 F2 F1 43 54 D8 E5 00 		UNPREDICTABLE	// 89

13 A5 16 13 11 02 1B 57 
44 F2 41 44 46 55 4C 00 		DREADFUL	// 8A 

FC 57					\ fifth choice of X71
AB 00 					DEADLY		// 8B

0B 77 0C 77 11 AA 77 32 57	\ X6e 		Hex97     Second half of string
5C 20 5B 20 46 FD 20 65 00 		x5c x5b FOR x65	// 8C

DB E5 32 57					\ above and something else
8C B2 65 00 				x8c' AND 'x65   // 8D

31 77 15 0E 77 30 57				\ beset by civil
66 20 42 59 20 67 00			x66 BY x67  	// 8E

DB 77 15 02 03 77 D9 57     			\ two above
8C 20 42 55 54 20 8E 00 		x8c BUT x8e 	// 8F 

77 16 38 77 27 57			\ fifth choice of   x6F,70 = ..n remarkable dump
20 41 6F 20 70 00 			' A'x6F x70 	// 90

07 1B A8 8A 57				\ entries used in x6d, first half
50 4C FF DD 00 				PLANET      	// 91

00 AA 1B 13 57
57 FD 4C 44 00 				WORLD	    	// 92

B5 12 77 57
E2 45 20 00				'THE '	    	// 93 

B5 1E 04 77 57
E2 49 53 20 00				'THIS '	    	// 94 

B7 16 13 85 CD 57    				/=5
E0 41 44 D2 9A 00 			LOAD' NEW 'x13COMMANDER  // 95 

5E 5C 56 5F 57
09 0B 01 08 00 				x09 x0b x01 x08	// 96 = new window, nlin4, captital, indent

13 05 1E AD 57
44 52 49 FA 00 				DRIVE	    	// 97

77 14 A2 16 B7 10 02 12 57 
20 43 F5 41 E0 47 55 45 00 		 CATALOGUE   	// 98

1E A8 57				 \ -ian ending
49 FF 00 				IAN         	// 99 

44 14 18 1A 1A A8 13 A3 57			/=5
13 43 4F 4D 4D FF 44 F4 00		x13 COMMANDER   // 9A
 
3F 57 				\ X5f		Hex98   animal adjective  
68 00 					x6 =threatening // 9B

1A 8E 19 03 16 A7 57  
4D D9 4E 54 41 F0 00 			MOUNTAIN    	// 9C

AB 1E 15 B2 57
FC 49 42 E5 00 				EDIBLE      	// 9D

03 A5 12 57
54 F2 45 00 				TREE        	// 9E

04 07 18 03 03 AB 57			\ fifth choice of X5F
53 50 4F 54 54 FC 00 			SPOTTED	    	// 9F

2F 57				\ X60 		Hex99	creatures 1 
78 00					x78       	// A0  \ strange creature noun 1
 
2E 57   
79 00 					x79		// A1  \ strange creature noun 2

36 18 1E 13 57					
61 4F 49 44 00 				x61OID	    	// A2  \ ?OID creature

28 57 						\ (poet..)
7F 00 					x7f    		// A3  \ strange animals iv)

29 57					\ fifth choice of X60  again (wasp..)
7E 00					x7e    		// A4  \ small animal, creatures v) 

A8 14 1E A1 03 57 		\ X62		Hex9A 	ingrained etc.
FF 43 49 F6 54 00 			ANCIENT     	// A5 

12 0F BE 07 AC 88 B3 57 
45 58 E9 50 FB DF E4 00 		EXCEPTIONAL 	// A6

12 14 BE 19 03 05 1E 14 57
45 43 E9 4E 54 52 49 43 00 		ECCENTRIC   	// A7

A7 10 AF A7 AB 57
F0 47 F8 F0 FC 00 			INGRAINED   	// A8

25 57					\ fifth choice of X62  
72 00 					x72     	// A9

1C 8B 1B A3 57			\ X68 		Hex9B 	life-threatening adjective 
4B DC 4C F4 00 				KILLER      	// AA 

13 12 16 13 1B 0E 57
44 45 41 44 4C 59 00 			DEADLY      	// AB

12 01 8B 57
45 56 DC 00 				EVIL        	// AC

B2 B5 B3 57 
E5 E2 E4 00 				LETHAL      	// AD
 
01 1E 14 1E 18 BB 57    		\ fifth choice of X68
56 49 43 49 4F EC 00 			VICIOUS	    	// AE  

8C 04 77 57					/=1
DB 53 20 00 				ITS '         	// AF

5A 59 44 57
0D 0E 13 00 				x0d x0 ex13   	// B0  begin, start buffer, only first letter capital

79 5B 58 57 
2E 0C 0F 00 				.x0c x0f     	// B1  end sentence, flush buffer.

77 A8 13 77 57 
20 FF 44 20 00 				' AND '	    	// B2

0E 8E 57 					/=5
59 D9 00 				'YOU'       	// B3      

07 B9 1C 94 1A 8A A3 04 57	\ X75 		Hex9C 	geographic feature
50 EE 4B C3 4D DD F4 53 00 		PARK'ING 'METERS// B4

13 BB 03 77 14 B7 02 13 04 57
44 EC 54 20 43 E0 55 44 53 00 		DUST CLOUDS 	// B5

1E BE 77 A0 05 10 04 57
49 E9 20 F7 52 47 53 00 		ICE BERGS    	// B6

05 18 14 1C 77 11 AA B8 AC 88 04 57
52 4F 43 4B 20 46 FD EF FB DF 53 00	ROCK FORMATIONS // B7

01 18 1B 14 16 B4 BA 57  		\ fifth choice of X75
56 4F 4C 43 41 E3 ED 00 		VOLCANOES   	// B8

07 1B A8 03 57  		 \ X76 		Hex9D 	plantation adjective part2
50 4C FF 54 00 				PLANT	    	// B9 

03 02 1B 1E 07 57
54 55 4C 49 50 00 			TULIP       	// BA

15 A8 A8 16 57
42 FF FF 41 00 				BANANA      	// BB

14 AA 19 57 
43 FD 4E 00 				CORN	    	// BC

45 00 12 AB 57 				\ fifth choice of X76
12 57 45 FC 00 		    x12= HexB2 random name WEED // BD

45 57   			\ X77 		Hex9E 	plantation adjective part1
12 00 					x12         	// BE 

46 77 45 57				\ x11 = HexB1 planet name-ian x12 = HexB2 random name
11 20 12 00 				x11 x12     	// BF

46 77 3F 57 				\   x68=Hex9B life-threatening adjective
11 20 68 00 				x11 x68     	// C0

A7 1F 16 BD 03 A8 03 57 
F0 48 41 EA 54 FF 54 00 		INHABITANT  	// C1 

E8 57					\ fifth choice of X77
BF 00 					x11 x12     	// C2    

A7 10 77 57 
F0 47 20 00 				'ING ' 	    	// C3

AB 77 57 
FC 20 00 				'ED ' 	    	// C4

57 57 57
00 00 00 	\	BRK: BRK: BRK 			// C5 C6 C7

77 19 16 1A 12 68 77 57  
20 4E 41 4D 45 3F 20 00 		' NAME?	'  	// C8

77 03 18 77 57  
20 54 4F 20 00 				' TO '     	// C9

77 1E 04 77 57
20 49 53 20 00 				' IS '     	// CA

00 16 04 77 AE 89 77 8D A1 77 A2 77 44 57
57 41 53 20 F9 DE 20 DA F6 20 F5 20 13 00
\'WAS LAST SEEN AT 'x13	   				// CB

79 5B 77 44 57    
2E 0C 20 13 00 				.x0c x13   	// CC    end one sentence, start next one on next line 

13 18 14 1C AB 57
44 4F 43 4B FC 00 			DOCKED	   	// CD

56 7F 0E 78 19 7E 68 57 
01 28 59 2F 4E 29 3F 00 		x01 (Y/N)?  	// CE

04 1F 1E 07 57 
53 48 49 50 00 				SHIP       	// CF

77 16 77 57
20 41 20 00				' A '      	// D0 

77 A3 05 1E BB 57 
20 F4 52 49 EC 00 			' ERRIUS' 	// D1

77 19 12 00 77 57
20 4E 45 57 20 00 			' NEW '    	// D2

55 77 1F A3 77 B8 1D BA 03 0E 70 04 77 04 07 16 BE 77 19 16 01 0E 5A 57
02 20 48 F4 20 EF 4A ED 54 59 27 53 20 53 50 41 E9 20 4E 41 56 59 0D 00
\ x02 HER MAJESTY'S SPACE NAVY x0d			// D3

E6 5F 56 77 77 1A BA 04 16 B0 77 A1 13 04 57 
B1 08 01 20 20 4D ED 53 41 E7 20 F6 44 53 00 
\ .x0c x0f=flush x08=indent x01 MESSAGE ENDS		// D4

77 CD 77 53 7B 77 1E 77 5A 16 1A  
20 9A 20 04 2C 20 49 20 0D 41 4D 
\ x13 COMMANDER x04=cmn, I x0d=lowercase AM

55 77 14 16 07 03 16 A7 77 4C 77 5A 18 11 84 57
02 20 43 41 50 54 41 F0 20 1B 20 0D 4F 46 D3 00  
\ x02 CAPTAIN x1b=MT27 x0d OF HER MAJESTY'S SPACE NAVY	// D5 

57
00			BRK				// D6

58 77 02 19 1C B4 00 19 77 C6 57
0F 20 55 4E 4B E3 57 4E 20 91 00 
\ x0F UNKNOWN PLANET 					// D7 / error used on first visit to DETOK
							      / otherwise 2 lines, x0c x0a first TKN2 digram
5E 5F 40 56 A7 14 18 1A 94 1A BA 04 16 B0 57
09 08 17 01 F0 43 4F 4D C3 4D ED 53 41 E7 00 
\ x09x08x17x01 INCOM'ING 'MESSAGE     			// D8   'AB'

14 02 05 05 02 B5 A3 04 57 
43 55 52 52 55 E2 F4 53 00 
\ CURRUTHERS  						// D9	'OU'

11 18 04 13 0E 1C 12 77 04 1A 0E B5 12 57
46 4F 53 44 59 4B 45 20 53 4D 59 E2 45 00 
\ FOSDYKE SMYTHE					// DA   'SE'

11 AA 03 BA A9 12 57  
46 FD 54 ED FE 45 00 
\ FORTESQUE 						// DB   'IT'

9C A5 BA A6 BE 57
CB F2 ED F1 E9 00 
\ 'WAS LAST SEEN AT 'REESDICE 				// DC   'IL'

1E 04 77 A0 1B 1E 12 01 AB 9E 1F 16 AD 77 1D 02 1A 07 AB 9E C3 10 B3 16 0F 0E 57
49 53 20 F7 4C 49 45 56 FC C9 48 41 FA 20 4A 55 4D 50 FC C9 94 47 E4 41 58 59 00 
\ IS BELIEVED' TO 'HAVE JUMPED 'TO ''THIS 'GALAXY	// DD	'ET'


4E 5E 4A 59 55 10 18 18 13 77 13 16 0E 77 CD 77 53 9B 1E 5A 77 16 1A 77 44 16 10 A1 03 77
19 09 1D 0E 02 47 4F 4F 44 20 44 41 59 20 9A 20 04 CC 49 0D 20 41 4D 20 13 41 47 F6 54 20
\ x19 x09 x1d=MT29 x0e x02 GOOD DAY x13 COMMANDER  x04=cmn .x0c x13 I x0d AM x13 AGENT

44 15 AE 1C 12 77 18 11 77 44 19 16 01 16 1B 77 44 A7 03 12 1B B2 10 A1 BE 9B 16 04 77 E4 77 1C B4 00 7B 77 C4
13 42 F9 4B 45 20 4F 46 20 13 4E 41 56 41 4C 20 13 F0 54 45 4C E5 47 F6 E9 CC 41 53 20 B3 20 4B E3 57 2C 20 93 
\ x13 BLAKE OF x13 NAVAL x13 INTELLEGENCE.x0c x13 AS' YOU' KNOW,' THE 'x13

44 19 16 01 0E 77 1F 16 AD 77 A0 A1 77 1C 12 12 07 94 C4
13 4E 41 56 59 20 48 41 FA 20 F7 F6 20 4B 45 45 50 C3 93
\x13 NAVY HAVE BEEN KEEP'ING ''THE

44 B5 B9 10 18 1E 13 04 77 18 11 11 77 E4 05 77 16 04 04 77 8E 03 77 A7
13 E2 EE 47 4F 49 44 53 20 4F 46 46 20 B3 52 20 41 53 53 20 D9 54 20 F0  
\x13 THARGOIDS OFF 'YOU'R ASS OUT IN

77 13 12 12 07 77 04 07 16 BE 77 11 AA 77 B8 19 0E 77 0E 12 B9 04 77 B4 00 79  
20 44 45 45 50 20 53 50 41 E9 20 46 FD 20 EF 4E 59 20 59 45 EE 53 20 E3 57 2E 
\ DEEP SPACE FOR MANY YEARS NOW

77 44 00 12 1B 1B 77 C4 04 8C 02 16 AC 88 77 1F 16 04 77 14 1F A8 10 AB 
20 13 57 45 4C 4C 20 93 53 DB 55 41 FB DF 20 48 41 53 20 43 48 FF 47 FC 
\  x13 WELL' THE 'SITUATION HAS CHANGED

9B 8E 05 77 15 18 0E 04 77 B9 12 77 A5 16 13 0E 77 11 AA 87 07 02 04 1F
CC D9 52 20 42 4F 59 53 20 EE 45 20 F2 41 44 59 20 46 FD D0 50 55 53 48 
\ .x0c x13 OUR BOYS ARE	READY FOR' A 'PUSH

77 05 1E 10 1F 03 9E C4 1F 18 1A 12 77 04 0E 04 03 12 1A 77 18 11 77 B5 18 8D 77 1A 18 B5 A3 04  
20 52 49 47 48 54 C9 93 48 4F 4D 45 20 53 59 53 54 45 4D 20 4F 46 20 E2 4F DA 20 4D 4F E2 F4 53 
\ RIGHT' TO ''THE 'HOME	SYSTEM OF THOSE MOTHERS

9B 4F 5E 4A 1E 5A 77 1F 16 AD 77 18 15 03 16 A7 93 C4 13 12 11 A1 BE
CC 18 09 1D 49 0D 20 48 41 FA 20 4F 42 54 41 F0 C4 93 44 45 46 F6 E9 
\ .x0c x13 x18=pause2 x09 x1d=MT29=indent, I x0d HAVE OBTAIN'ED ''THE 'DEFENCE

77 07 AE 19 04 77 11 AA 77 B5 12 1E 05 77 44 1F 1E AD 77 44 00 AA 1B 13 04
20 50 F9 4E 53 20 46 FD 20 E2 45 49 52 20 13 48 49 FA 20 13 57 FD 4C 44 53 
\ PLANS	FOR THEIR			x13 HIVE x13 WORLDS

9B C4 A0 8A B2 04 77 1C B4 00 77 00 12 70 AD 77 10 18 03 77 BC 1A 12 B5 94 15 02 03 77 B4 03 77 00 1F A2 
CC 93 F7 DD E5 53 20 4B E3 57 20 57 45 27 FA 20 47 4F 54 20 EB 4D 45 E2 C3 42 55 54 20 E3 54 20 57 48 F5 
\ .x0c x13 'THE 'BEETLES KNOW WE'VE GOT SOMETH'ING 'BUT NOT WHAT

9B 1E 11 77 44 1E 77 03 AF 19 04 1A 8C 77 C4 07 AE 19 04 9E 8E 05 77 15 16 8D 77 88 77 44
CC 49 46 20 13 49 20 54 F8 4E 53 4D DB 20 93 50 F9 4E 53 C9 D9 52 20 42 41 DA 20 DF 20 13 
\ .x0C x13 IF x13 I TRANSMIT 'THE 'PLANS' TO 'OUR BASE ON x13

BD A5 AF 77 B5 12 0E 70 1B 1B 77 A7 03 A3 BE 07 03 77 C4 03 05 A8 04 1A 1E 04 04 1E 88 79 77 44
EA F2 F8 20 E2 45 59 27 4C 4C 20 F0 54 F4 E9 50 54 20 93 54 52 FF 53 4D 49 53 53 49 DF 2E 20 13 
\ BIRERA THEY'LL INTERCEPT 'THE 'TRANSMISSION. x13

1E 77 19 12 AB 87 98 9E B8 1C 12 77 C4 05 02 19 9B E4 70 A5 77 12 B2 14 03 AB
49 20 4E 45 FC D0 CF C9 EF 4B 45 20 93 52 55 4E CC B3 27 F2 20 45 E5 43 54 FC 
\ I NEED' A ''SHIP'' TO 'MAKE 'THE 'RUN.x0C x13 YOU'RE ELECTED

9B C4 07 AE 19 04 77 16 A5 77 02 19 1E 07 02 1B 8D 77 14 18 13 93 00 1E B5 A7
CC 93 50 F9 4E 53 20 41 F2 20 55 4E 49 50 55 4C DA 20 43 4F 44 C4 57 49 E2 F0
\.x0C x13'THE 'PLANS ARE UNIPULSE COD'ED 'WITHIN

77 C3 03 05 A8 04 1A 1E 04 04 1E 88 9B 5F E4 77 00 8B 1B 77 A0 77 07 16 1E 13 
20 94 54 52 FF 53 4D 49 53 53 49 DF CC 08 B3 20 57 DC 4C 20 F7 20 50 41 49 44 
\ THIS TRANSMISSION.x0C x13x08  'YOU' WILL BE PAID

9B 77 77 77 77 44 10 18 18 13 77 1B 02 14 1C 77 CD 83 4F 57
CC 20 20 20 20 13 47 4F 4F 44 20 4C 55 43 4B 20 9A D4 18 00
\.x0C x13 '    ' x13 GOOD  LUCK x13 COMMANDER MESSAGE ENDS x18 = pause2 // DE token on later visits 'ST'
  
4E 5E 4A 5F 59 5A 44 00 12 1B 1B 77 13 88 12 77 CD
19 09 1D 08 0E 0D 13 57 45 4C 4C 20 44 DF 45 20 9A
\ x0e=buffer x0d x13 WELL DONE x13 COMMANDER

9B E4 77 1F 16 AD 77 8D 05 01 93 02 04 77 00 12 1B 1B E5 00 12 77 04 1F B3 1B 77 A5 1A 12 1A 15 A3
CC B3 20 48 41 FA 20 DA 52 56 C4 55 53 20 57 45 4C 4C B2 57 45 20 53 48 E4 4C 20 F2 4D 45 4D 42 F4
\.x0C x13 'YOU' HAVE SERV'ED 'US WELL' AND 'WE SHALL REMEMBER

9B 00 12 77 13 1E 13 77 B4 03 77 12 0F 07 12 14 03 77 C4 44 B5 B9 10 18 1E 13 04 9E 11 A7 13
CC 57 45 20 44 49 44 20 E3 54 20 45 58 50 45 43 54 20 93 13 E2 EE 47 4F 49 44 53 C9 46 F0 44
\.x0C x13  WE DID NOT EXPECT 'THE 'x13 THARGOIDS' TO 'FIND

77 8E 03 77 16 15 8E 03 77 E4 9B 11 AA 77 C4 1A 18 1A A1 03 77 07 B2 16 8D 77 16 14 BE 07 03 77 
20 D9 54 20 41 42 D9 54 20 B3 CC 46 FD 20 93 4D 4F 4D F6 54 20 50 E5 41 DA 20 41 43 E9 50 54 20  \ 41 42 -> D8
\ OUT ABOUT 'YOU'.x0C x13 FOR 'THE 'MOMENT PLEASE ACCEPT

C3 44 19 16 01 0E 77 51 25 52 77 16 04 77 07 16 0E 1A A1 03 83 4F 57 
94 13 4E 41 56 59 20 06 72 05 20 41 53 20 50 41 59 4D F6 54 D4 18 00
\' THIS 'x13 NAVY x6 energy unit x5 AS PAYMENT. MESSAGE ENDS x18 = PAUSE2  // DF token on later visits 'ON' 

57
00		BRK					// E0     	'LO'

04 1F A5 00 57 			\ X78 		Hex9F   strange creature noun 1
53 48 F2 57 00 				SHREW		// E1		'NU'    

A0 16 89 57
F7 41 DE 00				BEAST		// E2		'TH'

15 1E 04 88 57    
42 49 53 DF 00 				BISON		// E3		'NO' end   42 49 -> EA

04 19 16 1C 12 57 
53 4E 41 4B 45 00 			SNAKE		// E4		'AL' start

00 18 1B 11 57				\ fifth choice of X78
57 4F 4C 46 00 				WOLF		// E5 		'LE'

B2 18 07 B9 13 57		\ X79 		HexA0   strange creature noun 2
E5 4F 50 EE 44 00 			LEOPARD 	// E6 		'XE'    

14 A2 57
43 F5 00 				CAT		// E7		'GE'

1A 88 1C 12 0E 57
4D DF 4B 45 59 00			MONKEY  	// E8		'ZA'
 
10 18 A2 57      
47 4F F5 00 				GOAT		// E9		'CE'

11 1E 04 1F 57				\ fifth choice of x79
46 49 53 48 00 				FISH		// EA 		'BI'

3D 77 3E 57			\ X7a 		HexA1	 near top-level aspect of planet. drinks.
6A 20 69 00				x6a x69		// EB    	'SO'  

46 77 2F 77 2C 57			\ x11 = HexB1 planet name-ian animal food
11 20 78 20 7B 00 			x11 x78 x7b	// EC           'US'

F8 3C 77 2E 77 2C 57			\ strange creature food
AF 6B 20 79 20 7B 00 		      'ITS 'x6b x79 x7b // ED 		'ES'   its fabulous its  

2B 77 2A 57				\  mud cricket 
7C 20 7D 00 				x7c x7d		// EE 		'AR'    
 
3D 77 3E 57    				\ fifth choice of X7a   drinks again
6A 20 69 00 				x6a x69		// EF           'MA'   

1A 12 A2 57			\ X7b 		HexA2  	food
4D 45 F5 00 				MEAT		// F0 	 	'IN' 

14 02 03 1B 8A 57 
43 55 54 4C DD 00 			CUTLET 		// F1           'DI'

89 12 16 1C 57
DE 45 41 4B 00 				STEAK		// F2		'RE'

15 02 05 10 A3 04 57
42 55 52 47 F4 53 00 			BURGERS 	// F3		'A?'

BC 02 07 57 				\ fifth choice of X7b
EB 55 50 00 				SOUP		// F4		'ER'

1E BE 57 			\ X7c 		HexA3 	sport adjective
49 E9 00 				ICE		// F5  		'AT' 

1A 02 13 57
4D 55 44 00 				MUD		// F6		'EN'

0D A3 18 7A 44 10 57			    \ x13= MT19=Upper case for one letter
5A F4 4F 2D 13 47 00 			ZERO-x13G	// F7		'BE' 

01 16 14 02 02 1A 57
56 41 43 55 55 4D 00 			VACUUM  	// F8		'RA'

46 77 02 1B 03 AF 57			\ fifth choice of X7c
11 20 55 4C 54 F8 00 			x11 ULTRA  	// F9		'LA'   

1F 18 14 1C 12 0E 57		\ X7d 		HexA4	sport noun
48 4F 43 4B 45 59 00			HOCKEY		// FA 		'VE'   
 
14 05 1E 14 1C 8A 57   
43 52 49 43 4B DD 00 			CRICKET 	// FB		'TI'

1C B9 A2 12 57 
4B EE F5 45 00 				KARATE		// FC		'ED'

07 18 B7 57
50 4F E0 00 				POLO		// FD		'OR'

03 A1 19 1E 04 57 			\ fifth choice of X7d
54 F6 4E 49 53 00  			TENNIS  	// FE		'QU'

57  \ #VE				\ last TKN1 token
00  \ used for EOR above.  				// FF   255     'AN'  

	\ +++++ Onto the running mission tokens ++++++

	.RUPLA \ -> &5339  \ 25 planet numbers, 25 galaxies numbers, then 25 strings. Start check at 25-1  
D3 96 24 1C 			\ planet #211 [Teorge] cloning, #150 [Xeer], #36 [Reesdice], #28 [Arexe]
FD 4F 35 76 64 			\ .. planet #100 elite II
20 44 A4 DC 6A 10 A2 03 
6B 1A C0 B8 05 65		\ .. planet #101 too far
C1 29 				\ .. planet #41  aviator. Last is RUPLA,24

	.RUGAL \ -> &5352  \ 25 galaxies bit7 set doesn't need mission running  
80 00 00 00 			\ Cloning galaxy 1, Constrictor Galaxy 1.
01 01 01 01 82 			\ Contrictor in galaxy 2, Galaxy 3 coming soon.
01 01 01 01 01 01 01 01 	\ Galaxy 2
01 01 01 01 01 02 		\ .. Galaxy 3 too far for mission
01 82 				\ .. Galaxy 3 aviator

	.RUTOK \ -> &536B  \ RU tokens
57  				\ #VE
00  				\ used for EOR below

C4 14 18 B7 19 1E 89 04 77 1F 12 A5 77 1F 16 AD 77 01 1E 18 1B A2 AB 55
93 43 4F E0 4E 49 DE 53 20 48 45 F2 20 48 41 FA 20 56 49 4F 4C F5 FC 02
\'THE 'COLONISTS HERE HAVE VIOLATED x02

77 A7 03 A3 10 B3 16 14 AC 14 77 14 B7 19 94 07 05 18 03 18 14 18 1B 5A 
20 F0 54 F4 47 E4 41 43 FB 43 20 43 E0 4E C3 50 52 4F 54 4F 43 4F 4C 0D 
\INTERGALACTIC CLON'ING 'PROTOCOL x0d = all lower case

E5 04 1F 8E 1B 13 77 A0 77 16 01 18 1E 13 AB 57
B2 53 48 D9 4C 44 20 F7 20 41 56 4F 49 44 FC 00 
\ ' AND 'SHOULD BE AVOIDED 						//  RU 1 of 25 .Teorge

C4 14 88 89 05 1E 14 03 AA 77 9C A5 BA A6 BE 7B 77 CD 57
93 43 DF DE 52 49 43 54 FD 20 CB F2 ED F1 E9 2C 20 9A 00 
\'THE 'CONSTRICTOR 'WAS LAST SEEN AT 'REESDICE,x13COMMANDER		// RU 2 of 25 .Xeer

16 77 25 77 B7 18 1C 94 98 77 B2 11 03 77 1F 12 A5 87 00 1F 1E B2 77 15 16 14 1C 79
41 20 72 20 E0 4F 4B C3 CF 20 E5 46 54 20 48 45 F2 D0 57 48 49 E5 20 42 41 43 4B 2E 
\A x72=wierd choices LOOK'ING ''SHIP 'LEFT HERE' A 'WHILE BACK.

77 1B 18 18 1C 93 15 8E 19 13 77 11 AA 77 B9 12 B1 57
20 4C 4F 4F 4B C4 42 D9 4E 44 20 46 FD 20 EE 45 E6 00    / 4C 4F -> E0
\ LOOK'ED 'BOUND FOR AREXE   						// RU 3 of 25 .Reesdice

0E 12 07 7B 87 25 85 98 77 1F 16 13 87 10 B3 16 14 AC 14 77 1F 0E 07 A3 13 05 1E AD
59 45 50 2C D0 72 D2 CF 20 48 41 44 D0 47 E4 41 43 FB 43 20 48 59 50 F4 44 52 49 FA 
\YEP,' A 'x72=wierd choice ' NEW ''SHIP 'HAD' A 'GALACTIC HYPERDRIVE 

77 11 8C 03 93 1F 12 A5 79 77 BB 93 8C 77 03 18 18 57
20 46 DB 54 C4 48 45 F2 2E 20 EC C4 DB 20 54 4F 4F 00 
\ FITT'ED 'HERE. US'ED 'IT TOO  					// RU 4 of 25 .Arexe

C3 77 25 77 98 77 13 12 1F 0E 07 93 1F 12 A5 77 11 05 18 1A 77 B4 00 1F 12 A5 7B
94 20 72 20 CF 20 44 45 48 59 50 C4 48 45 F2 20 46 52 4F 4D 20 E3 57 48 45 F2 2C 
\'THIS 'x72=wierd choice 'SHIP 'DEHYP'ED 'HERE FROM NOWHERE,

77 04 02 19 77 04 1C 1E 1A 1A AB E5 1D 02 1A 07 AB 79 77 1E 77 1F 12 B9 77 8C 77 00 A1 03 9E A7 BD A0 57
20 53 55 4E 20 53 4B 49 4D 4D FC B2 4A 55 4D 50 FC 2E 20 49 20 48 45 EE 20 DB 20 57 F6 54 C9 F0 EA F7 00 
\ SUN SKIMMED' AND 'JUMPED. I HEAR IT WENT ' TO 'INBIBE 		// RU 5 of 25 now in Gal2

24 77 98 77 00 A1 03 77 11 AA 77 1A 12 77 A2 77 16 BB B9 79 77 1A 0E 77 AE 04 A3 04 
73 20 CF 20 57 F6 54 20 46 FD 20 4D 45 20 F5 20 41 EC EE 2E 20 4D 59 20 F9 53 F4 53
\x73=rouge choice 'SHIP 'WENT FOR ME AT AUSAR. MY  LASERS   	
 
77 13 1E 13 19 70 03 77 12 01 A1 77 04 14 AF 03 14 1F 77 C4 24 57
20 44 49 44 4E 27 54 20 45 56 F6 20 53 43 F8 54 43 48 20 93 73 00  / 44 49 -> F1 in Elite-A
\  DIDN'T ..  SCRATCH' THE 'x73=rouge choices 				// RU 6 of 25 .Errius in Gal2
 
18 1F 77 13 12 B9 77 1A 12 77 0E BA 79 87 11 05 1E 10 1F 03 11 02 1B 77 05 18 10 02 12 77 00 1E B5 77 00 1F A2 77 1E 
4F 48 20 44 45 EE 20 4D 45 20 59 ED 2E D0 46 52 49 47 48 54 46 55 4C 20 52 4F 47 55 45 20 57 49 E2 20 57 48 F5 20 49 
\OH DEAR ME YES.' A 'FRIGHTFUL ROGUE WITH WHAT I

77 A0 1B 1E 12 AD 77 E4 77 07 12 18 07 B2 77 14 B3 1B 87 B2 16 13 77 07 18 89 A3 1E AA 77 04 1F 18 03 77 02 07 77 B7 03 04
20 F7 4C 49 45 FA 20 B3 20 50 45 4F 50 E5 20 43 E4 4C D0 E5 41 44 20 50 4F DE F4 49 FD 20 53 48 4F 54 20 55 50 20 E0 54 53
\ BELIEVE' YOU 'PEOPLE CALL' A 'LEAD POSTERIOR SHOT UP LOTS

77 18 11 77 B5 18 8D 77 A0 16 89 1B 0E 77 07 1E AF 03 BA E5 00 A1 03 9E BB B2 05 1E 57 
20 4F 46 20 E2 4F DA 20 F7 41 DE 4C 59 20 50 49 F8 54 ED B2 57 F6 54 C9 EC E5 52 49 00 
\  OF THOSE BEASTLY PIRATES' AND 'WENT ' TO '	USLERI			// RU 7 of 25 .Inbibe in Gal2

E4 77 14 A8 77 03 16 14 1C B2 77 C4 3F 77 24 77 1E 11 77 E4 77 1B 1E 1C 12 79 77 
B3 20 43 FF 20 54 41 43 4B E5 20 93 68 20 73 20 49 46 20 B3 20 4C 49 4B 45 2E 20 
\ 'YOU' CAN TACKLE 'THE 'x68 x73 IF 'YOU' LIKE. 	/ x68=life-threatening choices  x73=rouge choices

1F 12 70 04 77 A2 77 AA B9 AF 57
48 45 27 53 20 F5 20 FD EE F8 00 
\ HE'S AT ORARRA							// RU 8 of 25 .Ausar in Gal2

56 14 18 1A 94 BC 88 6D 77 12 1B 8C 12 77 1E 1E 57
01 43 4F 4D C3 EB DF 3A 20 45 4C DB 45 20 49 49 00			// RU 9 of 25  in Gal3  
\ x01 COM'ING 'SOON: ELITE II

23 57 23 57 23 57 23 57 23 57 23 57 23 57 23 57 23 57 23 57 23 57 23 57 23 57  
74 00 74 00 74 00 74 00 74 00 74 00 74 00 74 00 74 00 74 00 74 00 74 00 74 00  
\ 13 places to give 1of5 x74= try ERRIUS choices in Galaxy 2 (32,1) 	// RU 10 to RU 22 of 25
 
15 18 0E 77 16 A5 77 E4 77 A7 77 C4 00 05 88 10 77 10 B3 16 0F 0E 76 57  			
42 4F 59 20 41 F2 20 B3 20 F0 20 93 57 52 DF 47 20 47 E4 41 58 59 21 00 / too far
\ BOY ARE 'YOU' IN 'THE 'WRONG GALAXY! 					// RU 23 of 25  Gal3
 
B5 A3 12 70 04 87 A5 B3 77 24 77 07 1E AF 03 12 77 8E 03 77 B5 A3 12 57
E2 F4 45 27 53 D0 F2 E4 20 73 20 50 49 F8 54 45 20 D9 54 20 E2 F4 45 00 // RU 24 of 25 .Orrara in Gal2
\ THERE'S' A 'REAL x73= 5rouge choices PIRATE OUT THERE			

C4 96 04 77 18 11 77 3A 77 16 A5 77 BC 77 16 B8 0D A7 10 1B 0E
93 C1 53 20 4F 46 20 6D 20 41 F2 20 EB 20 41 EF 5A F0 47 4C 59 
\ THE 'INHABITANTS OF x6d= planet choice for this planet name ARE SO AMAZINGLY

77 07 05 1E 1A 1E AC AD 77 B5 A2 77 B5 12 0E 77 89 8B 1B 77 B5 A7 1C
20 50 52 49 4D 49 FB FA 20 E2 F5 20 E2 45 59 20 DE DC 4C 20 E2 F0 4B 
\ PRIMITIVE THAT THEY STILL THINK
 
77 44 16 7D 7D 7D 7D 7D 05 9D 16 77 07 A5 03 03 0E 77 19 12 A2 77 10 16 1A 12 57 / aviator
20 13 41 2A 2A 2A 2A 2A 52 CA 41 20 50 F2 54 54 59 20 4E 45 F5 20 47 41 4D 45 00 // RU 25 of 25 in Gal3
\ x13A*****R' IS 'A PRETTY NEAT GAME

\ ++ All Tokens done. No need for eor'd with #&57 anymore ++

\ (MTIN-&5B,original A)+0to4  \ lowest hex block is 5B (ie Z is 5A)
	.MTIN \ -> &55C0 in block A. Table used for 5choices.
 10 15 1A 1F 9B A0 2E A5  build offsets in steps in 5
\5B 5C 5D 5E 5F 60 61 62  called with these indicies, tokens above 'Z'.

 24 29 3D 33 38 AA 42 47  build offsets in steps in 5
\63 64 65 66 67 68 69 6A  called with these indicies, tokens above 'Z'.

 4C 51 56 8C 60 65 87 82  build offsets in steps in 5
\6B 6C 6D 6E 6F 70 71 72  called with these indicies, tokens above 'Z'.

 5B 6A B4 B9 BE E1 E6 EB  build offsets in steps in 5
\73 74 75 76 77 78 79 7A  called with these indicies, tokens above 'Z'.

 F0 F5 FA 73 78 7D   	  build offsets in steps in 5
\7B 7C 7D 7E 7F 80   	  called with these indicies, tokens above 'Z'.

45 4E 44 2D 45 4E 44 2D 45 4E 44  EQUS "END-END-END"

8E 13 1C 00 
00 73 56 52 
49 53 00 
8E 13 34 B3
