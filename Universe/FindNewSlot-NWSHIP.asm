NewShip:
FindNewSlot:
NWSHP:
; ">FindNewSlot A = ship Type, carry set = success, clear = failed new ship, a reg hold ship type, b= free slot number, HL = slot addresss"
	ld			ixh,a						; ixh==T	  \ Type stored
	ld			hl,FRIN
	xor			a							; looking for an empty slot
	ld			b,a
	ld			c,13						; bc = 13 bytes to scan
	cpir			
	jr			z,.FoundASlot
.NoFreeSlot:
	or			a							; no slot to clear carry flag an
	ld			a,d							; restore ship type back to a
	ret
.FoundASlot:
	dec			hl							; hl is incremted in the loop so move back to free slot
    ld			a,ixh						; restore ship type to a
    ld          (hl),a                      ; populate the slot with the ship type
	ld			de,FRIN
	or			a							; clear carry flag
	sbc			hl,de						; now l = index offset will never carry
	ld			a,d							; restore ship type to a
	ld			b,l							; b = index of free slot
    call        AddNewShip
	scf										; set carry flag
	ret

    
    
AddNewShip:                                 ; found Room, a FRIN(X) that is still empty. Allowed to add ship, type is in T.
NW1:    
    call        GetInfo
        AT HERE getinfo doesn;'t make sense yet, why get info then get varT? what doesnget info really do?
    
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
