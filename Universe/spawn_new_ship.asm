

.NW1	\ found Room, a FRIN(X) that is still empty. Allowed to add ship, type is in T.
20 32 37                JSR &3732 \ GINF \ Get INFo pointer for slot X from UNIV
A5 D1                   LDA &D1	    \ T  \ the ship type
30 52                   BMI NW2		 \ Planet/sun, hop inner workspace to just store ship type.
0A                      ASL A		 \ type*=2 to get
A8                      TAY 		 \ hull index for table at XX21= &5600
B9 FF 55                LDA &55FF,Y	 \ XX21-1,Y
F0 F0                   BEQ NW3		 \ no address hi, ship not added.
85 1F                   STA &1F	 \ XX0+1 \ hull pointer hi
B9 FE 55                LDA &55FE,Y	 \ XX21-2,Y
85 1E                   STA &1E	 \ XX0	 \ hull pointer lo
C0 04                   CPY #4		 \ #2*SST
F0 30                   BEQ NW6		 \ if ship type #SST space station
A0 05                   LDY #5		 \ hull byte#5 = maxlines for using ship lines stack
B1 1E                   LDA (&1E),Y	 \ (XX0),Y
85 06                   STA &06		 \ T1
AD B0 03                LDA &03B0 \ SLSP \ ship lines pointer
38                      SEC 		 \ ship lines pointer - maxlines
E5 06                   SBC &06		 \ T1
85 67                   STA &67	  \ XX19 \ temp pointer lo for lines
AD B1 03                LDA &03B1	 \ SLSP+1
E9 00                   SBC #0		 \ hi
85 68                   STA &68		 \ XX19+1
A5 67                   LDA &67		 \ XX19
E5 20                   SBC &20	  \ INF  \ info pointer gives present top of all workspace heap
A8                      TAY 		 \ compare later to number of bytes, 37, needed for ship workspace
A5 68                   LDA &68		 \ XX19+1
E5 21                   SBC &21		 \ INF+1
90 C6                   BCC NW3+1	 \ rts if too low, not enough space.
D0 04                   BNE NW4		 \ enough space, else if hi match look at lo
C0 25                   CPY #&25	 \ NI% = #37 each ship workspace size
90 C0                   BCC NW3+1	 \ rts if too low, not enough space
.NW4	\ Enough space for lines
A5 67                   LDA &67	  \ XX19 \ temp pointer lo for lines
8D B0 03                STA &03B0 \ SLSP \ ship lines pointer
A5 68                   LDA &68		 \ XX19+1
8D B1 03                STA &03B1	 \ SLSP+1
.NW6	\ also New Space Station #SST arrives here
A0 0E                   LDY #14		 \ Hull byte#14 = energy
B1 1E                   LDA (&1E),Y	 \ (XX0),Y
85 69                   STA &69	\ INWK+35 \ energy
A0 13                   LDY #19		 \ Hull byte#19 = laser|missile info
B1 1E                   LDA (&1E),Y	 \ (XX0),Y
29 07                   AND #7           \ only lower 3 bits are number of missiles
85 65                   STA &65	\ INWK+31 \ display exploding state|missiles
A5 D1                   LDA &D1	 \ T	 \ reload ship Type
.NW2   \ also Planet/sun store ship type
9D 11 03                STA &0311,X \ FRIN,X \ the type for each nearby ship
AA                      TAX 		 \ slot info lost, X is now ship type.
30 0E                   BMI NW8		 \ hop over as planet
E0 03                   CPX #3		 \ #ESC
90 07                   BCC NW7		 \ < 3   type is not junk
E0 0B                   CPX #11		 \ #CYL 
B0 03                   BCS NW7		 \ >= 11 type is not junk
EE 3E 03                INC &033E \ JUNK \ esc plate oil boulder asteroid splinter shuttle transporter
.NW7	\ not junk
FE 1E 03                INC &031E,X \ MANY,X	\ the total number of ships of type X
.NW8	\ hopped as planet/sun
A4 D1                   LDY &D1	   \ T	 \ the ship type, index to ship type NEWB at E%
B9 3D 56                LDA &563D,Y \ XX21-1+2*31,Y \ E%-1,Y
29 6F                   AND #&6F	 \ clear bits7,4 of hull's NEWB, has escape capsule and ?
05 6A                   ORA &6A \ INWK+36 \ NEWB
85 6A                   STA &6A	\ INWK+36 \ NEWB \ keep previous bits for remove, inno, docking, pirate, angry ..
A0 24                   LDY #36		\ #(NI%-1) start Y counter for inner workspace
.NWL3	\ move workspace out, counter Y
B9 46 00                LDA &0046,Y	\ INWK,Y
91 20                   STA (&20),Y	\ (INF),Y
88                      DEY 		\ next byte
10 F8                   BPL NWL3	\ loop Y
38                      SEC 		\ success in creating new ship, keep carry set.
60                      RTS 

.NwS1	\ -> &37FC \ flip signs and X+=2 needed by new space station
B5 46                   LDA &46,X	\ INWK,X
49 80                   EOR #&80	\ flip sg coordinate
95 46                   STA &46,X	\ INWK,X
E8                      INX 
E8                      INX 		\ X+=2
60                      



.FoundFreeSlot:								; New Ship – Add ship OK now hl = address of free slot (hopefully won't need index)	
	ld		a,FreeListSize					; 
	sub		b								; a = FreeList - Index, so if it was item 12 then 12-12 = 0
	add		UniverseBasePage				; Now a = page number to swap in for data
.DerriveType
	ld		a,(varT)
	bits	7,a
	jr		nz, .PlanetOrSun
.ItsNotPlanetOrSun:
	sla									; A *= 2
	ld		b,0
	ld		b,a							; save into b reg
	ld		hl,	HULLINDEX
	add		hl,a						; HL = HULLINDEX[A]
	ld		d,(hl)
	inc		hl
	ld		e,(hl)						; de = address of hull data
	ld		a,d
	cp		0							;
	jr		z, .CleanUpWorkspace		;  (NW3) if h = 0 then no ship data so just exit setting INF to b reg
	ld		(XX0),de					; may not be needed after optimisation
	ld		hl,XX21-2
	cp		ShipSST						; is ship hull index = 4?
	jr		z,.ItsASpaceStation
	ld		hl,(XX0)					; hl = address of hull data
	ld		ixh,h
	ld		ixl,l						; ix = address of hull data
	ld		a,(ix+5)					; hull byte#5 = maxlines for using ship lines stack
	ld		(varT1),a					; store in T1 for now
	ld		hl,(SLSP)					; ship lines pointer, WHERE is this set? (Must be iniitalise earlier as its actually a variable heap)
	or		a							; clear carry flag
	sub		hl,a						; hl = (SLSP) - varT1				
	ld		(XX19),hl					; XX19+XX20 = (SLSP)-varT1
	ld		bc,(INF)
	or		a							; clear carry flag
	sub		hl,bc						; hl = (SLSP)-varT1 - INFO info pointer gives present top of all workspace heap
	ld		iyh,h			
	ld		iyl,l						; compare later to number of bytes, 37, needed for ship workspace
	ld		a,(XX20)					; High byte of XX19
	ld		hl,INF+1					; High byte of inf
	sub		hl							; 
	ret		nc							; Return if carry clear so not enough space
	jr		nz, .enoughHeapSpace		; not equal to zero so enoug space
; ">Is there any heap maangment code in this lot for lines?"
; ">We may just binbag all that and just have a bank per ship, as we have enough ram"
	at herer

85 67                   STA &67	  \ XX19 \ temp pointer lo for lines
AD B1 03                LDA &03B1	 \ SLSP+1
E9 00                   SBC #0		 \ hi
85 68                   STA &68		 \ XX19+1
A5 67                   LDA &67		 \ XX19
E5 20                   SBC &20	  \ INF  \ info pointer gives present top of all workspace heap
A8                      TAY 		 \ compare later to number of bytes, 37, needed for ship workspace
A5 68                   LDA &68		 \ XX19+1
E5 21                   SBC &21		 \ INF+1
90 C6                   BCC NW3+1	 \ rts if too low, not enough space.
D0 04                   BNE NW4		 \ enough space, else if hi match look at lo
C0 25                   CPY #&25	 \ NI% = #37 each ship workspace size
90 C0                   BCC NW3+1	 \ rts if too low, not enough space
.NW4	\ Enough space for lines
A5 67                   LDA &67	  \ XX19 \ temp pointer lo for lines
8D B0 03                STA &03B0 \ SLSP \ ship lines pointer
A5 68                   LDA &68		 \ XX19+1
8D B1 03                STA &03B1	 \ SLSP+1
.NW6	\ also New Space Station #SST arrives here
A0 0E                   LDY #14		 \ Hull byte#14 = energy
B1 1E                   LDA (&1E),Y	 \ (XX0),Y
85 69                   STA &69	\ INWK+35 \ energy
A0 13                   LDY #19		 \ Hull byte#19 = laser|missile info
B1 1E                   LDA (&1E),Y	 \ (XX0),Y
29 07                   AND #7           \ only lower 3 bits are number of missiles
85 65                   STA &65	\ INWK+31 \ display exploding state|missiles
A5 D1                   LDA &D1	 \ T	 \ reload ship Type
.NW2   \ also Planet/sun store ship type
9D 11 03                STA &0311,X \ FRIN,X \ the type for each nearby ship
AA                      TAX 		 \ slot info lost, X is now ship type.
30 0E                   BMI NW8		 \ hop over as planet
E0 03                   CPX #3		 \ #ESC
90 07                   BCC NW7		 \ < 3   type is not junk
E0 0B                   CPX #11		 \ #CYL 
B0 03                   BCS NW7		 \ >= 11 type is not junk
EE 3E 03                INC &033E \ JUNK \ esc plate oil boulder asteroid splinter shuttle transporter
.NW7	\ not junk
FE 1E 03                INC &031E,X \ MANY,X	\ the total number of ships of type X
.NW8	\ hopped as planet/sun
A4 D1                   LDY &D1	   \ T	 \ the ship type, index to ship type NEWB at E%
B9 3D 56                LDA &563D,Y \ XX21-1+2*31,Y \ E%-1,Y
29 6F                   AND #&6F	 \ clear bits7,4 of hull's NEWB, has escape capsule and ?
05 6A                   ORA &6A \ INWK+36 \ NEWB
85 6A                   STA &6A	\ INWK+36 \ NEWB \ keep previous bits for remove, inno, docking, pirate, angry ..
A0 24                   LDY #36		\ #(NI%-1) start Y counter for inner workspace
.NWL3	\ move workspace out, counter Y
B9 46 00                LDA &0046,Y	\ INWK,Y
91 20                   STA (&20),Y	\ (INF),Y
88                      DEY 		\ next byte
10 F8                   BPL NWL3	\ loop Y
38                      SEC 		\ success in creating new ship, keep carry set.
60                      RTS 
	
.CleanUpWorkspace:						;.NWL3	\ move workspace out, counter Y
	ld		hl, INWK				
	ld		a,b
	add		hl, a						hl = INWK [b]
	ld		a,(hl)
	ld		(INF),a
	djnz	.CleanUpWorkspace
	scf									; Set carry flag to denote success
	ret
	
.NwS1	\ -> &37FC \ flip signs and X+=2 needed by new space station
B5 46                   LDA &46,X	\ INWK,X
49 80                   EOR #&80	\ flip sg coordinate
95 46                   STA &46,X	\ INWK,X
E8                      INX 
E8                      INX 		\ X+=2
60                      RTS 
