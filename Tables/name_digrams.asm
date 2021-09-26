name_digrams	DB "ABOUSEITILETSTONLONUTHNO"
name_digrams2   DB "ALL"
				DB "EXEGEZACEBISOUSESARMAINDIREA"
				DB "?ERATENBERALAVETIEDORQUANTEISRION"

; TODO Moveinto galaxy data module
name_expanded	DS 32
				DB 0



NamingLoop:
	ld		a,(WorkingSeeds+5)	; a = first byte of name seed
	and 	$1F					; Keep bottom 5 bits only
	cp		0					; 0 = skip 2 chars
	jr		z,.SkipPhrase
	add		a,12
	sla		a					; phrase = (a+12)*2
	ld		hl,name_digrams
	add		hl,a
	ldi	
	ld		a,(hl)
	cp		'?'
	jr		z,.SkipPhrase
.AddExtra:
	ldi	
.SkipPhrase:
	push	de
	call	working_seed
	pop		de
	ret
	
;GetDigramGalaxySeed:
;	call	copy_galaxy_to_working
;	jr		GetDigramWorkingSeed
;GetDigramSystemSeed:
;	call	copy_system_to_working
;GetDigramWorkingSeed:
;; ">GetDigram a = digram seed"
;	ld		de,name_expanded
;	ld		b,3
;	ld		a,(WorkingSeeds)
;	and		$40
;	jr		z,.SmallSizeName
;.LargeSizeName:
;	call	NamingLoop
;.SmallSizeName:
;	call	NamingLoop
;	call	NamingLoop
;	call	NamingLoop
;.DoneName:
;	ex		de,hl
;	ld		(hl),0
;	ex		de,hl
;	ret

	
	
;GetDigramWorkingSeed:
;	MESSAGE ">GetDigram a = digram seed b = length"
;	ld		b,5					; working seed
;	ld		de,name_expanded
;.ExpansionLoop:
;	push	bc
;	ld		hl,WorkingSeeds
;	ld		a,b
;	add		hl,a
;	ld		a,(hl)	; a = first byte of name seed
;	and 	$1F					; Keep bottom 5 bits only
;	cp		0					; 0 = skip 2 chars
;	jr		z,.SkipPhrase
;	or		&80					; set buit 7 high (probabtyl capitalisation)
;	call	TT27
;.SkipPhrase:
;	push	de
;	call	next_working_seed
;	pop		de
;	pop		bc
;	djnz	GetDigramWorkingSeed
;.DoneName:
;	ex		de,hl
;	ld		(hl),0
;	ex		de,hl
;	ret	
;
;ExpandToken:
;	DE = target
;	a = token
;	
;PlanetDigram:
;	cp		&A0							; >- 160
;	jr		c,MorePage4
;	and		$7F							; 128 to 159 now 0 to 31
;	asl		2							; Multiply by 2
;	ld		hl, name_digrams2
;	add		hl,a
;	ld		a,(hl)
;	call	ProcessTextToken
;	inc		hl
;	ld		a,(hl)
;	cp		'?'
;	ret		z
;	call	ProcessTextToken
;	ret
;MorePage4:
;	sub		$A0
;ExtraTokenCheck:
;	push	de							; save target address
;	push	bc
;	ld		b,a
;	ld		hl,varV
;	ld		(VarV),0400
;	ld		(varV),a
;	ld		
;	
;		.TT43	\ Token > 127 page4 token or planet digram.
;C9 A0                   CMP #&A0	      \ >= #160 ?
;B0 14                   BCS TT47	      \ more page4, subtract #160
;29 7F                   AND #&7F	      \ else token 128to159  -> 0 to 31
;0A                      ASL A		      \ *= 2
;A8                      TAY 		      \ digram index = 0to62
;B9 80 08                LDA &0880,Y \ QQ16,Y  \ ALLEXEGEZACEBISOUSESARMAINDIREA?ER  etc.
;20 9A 33                JSR &339A   \ TT27    \ process text token
;B9 81 08                LDA &0881,Y \ QQ16+1,Y \ 2nd character of diagram. Flight copied down from docked code.
;C9 3F                   CMP #&3F	      \ is second letter '?'
;F0 40                   BEQ TT48    	      \ rts, name has odd-number of letters.
;4C 9A 33                JMP &339A   \ TT27    \ process text token
;
;	.TT47	\ more page4, subtract #160
;E9 A0                   SBC #&A0	\ -= 160
;	.ex	\ -> &342D \ extra, token >= 96 or Acc = 128to145 or -=160
;AA                      TAX 		\ copy of word index
;A9 00                   LDA #0		\ page 4 words lo  #QQ18 MOD 256
;85 22                   STA &22		\ V
;A9 04                   LDA #4		\ page 4 words hi  #QQ18 DIV 256
;85 23                   STA &23		\ V+1
;A0 00                   LDY #0
;8A                      TXA 		\ token = word index
;F0 13                   BEQ TT50	\ if X=0 then Y offset to word correct
;	.TT51	\ counters Y letter, X token
;B1 22                   LDA (&22),Y	\ (V),Y
;F0 07                   BEQ TT49	\ exit as word ended
;C8                      INY 		\ letter count
;D0 F9                   BNE TT51	\ loop Y
;E6 23                   INC &23	  \ V+1 \ next page as Y reached 256
;D0 F5                   BNE TT51    	\ guaranteed, loop Y letter
;	.TT49	\ word ended
;C8                      INY 
;D0 02                   BNE TT59    	\ next word
;E6 23                   INC &23	  \ V+1	\ next page as Y reached 256
;	.TT59	\ next word
;CA                      DEX 		\ token count
;D0 ED                   BNE TT51	\ loop X token
;	.TT50	\ token X = 0, counter Y offset to word correct
;98                      TYA 
;48                      PHA 		\ store Yindex
;A5 23                   LDA &23		\ V+1
;48                      PHA 		\ correct pointer hi 
;B1 22                   LDA (&22),Y 	\ (V),Y
;49 23                   EOR #&23	\ decode '#'
;20 9A 33                JSR &339A \ TT27 \ process text token to next depth
;68                      PLA 		\ restore this depth's Vhi
;85 23                   STA &23		\ V+1
;68                      PLA 		
;A8                      TAY 		\ restore this depth's Yindex
;C8                      INY 		\ next letter
;D0 02                   BNE P%+4	\ not zero so skip next page
;E6 23                   INC &23		\ V+1
;B1 22                   LDA (&22),Y	\ (V),Y
;D0 E6                   BNE TT50    	\ loop Y for next letter of page4 token
;	.TT48 	\ rts
;60                      RTS 		\ end of flight token printing TT27
;
;
;	
;	
;	
;	
;		.TT27	\ -> &36E0 \ process flight text Token in Acc
;;AA                      TAX		\ copy token to count down
;;F0 DE                   BEQ csh		\ Acc = 0, up to Cash
;30 74                   BMI TT43	\ if token is >  127 down, page4 token or digram
;CA                      DEX 
;F0 BC                   BEQ tal		\ Acc == 1, up, print Galaxy number.
;CA                      DEX 
;F0 A3                   BEQ ypl		\ Acc == 2, up, present planet in QQ2.
;CA                      DEX 
;D0 03                   BNE P%+5	\ hop over, else X == 0
;4C 0A 33                JMP &330A \ cpl \ Acc = 3 print Planet name for seed QQ15
;CA                      DEX 
;F0 8A                   BEQ cmn		\ Acc == 4, up, commander name.
;CA                      DEX 
;F0 B5                   BEQ fwl		\ Acc == 5, up, fuel followed by cash.
;CA                      DEX 
;D0 05                   BNE  P%+7	\ hop over, else X == 0
;A9 80                   LDA #&80	\ Acc == 6, set bit 7 TT27m
;85 72                   STA &72	 	\ QQ17 
;60                      RTS 
;CA                      DEX 		\ skip Acc ==7
;CA                      DEX 
;D0 03                   BNE P%+5	\ hop over to continue Acc 9to127
;86 72                   STX &72	 \ QQ17	\ else Acc ==8, QQ17 set to X = 0
;60                      RTS 
;CA                      DEX 		\ continue 9to127 tokens
;F0 38                   BEQ crlf	\ Acc == 9, down, colon on right.
;C9 60                   CMP #&60	\ discard X, look at Acc = token >= 96
;B0 66                   BCS ex   	\ extra >= #&60, far down
;C9 0E                   CMP #14		\ < 14 ?
;90 04                   BCC P%+6	\ goes to Token < 14 or > 31
;C9 20                   CMP #32		\ < 32 ?
;90 28                   BCC qw   	\ 14 <= token A < 32 becomes 128to145 page4 digram
;		\ Token  < 14 or > 31
;A6 72                   LDX &72	 	\ QQ17
;F0 3D                   BEQ TT74 	\ if QQ17 = 0 Upper case, jmp TT26, print character.
;30 11                   BMI TT41 	\ if bit7 set
;24 72                   BIT &72		\ QQ17 has bit6 set too
;70 30                   BVS TT46 	\ If only bit6 set, clear bit6 and print as Upper
;	.TT42	\ Uppercase to lowercase
;C9 41                   CMP #&41	\ < ascii 'A'
;90 06                   BCC TT44 	\ jmp TT26, print character
;C9 5B                   CMP #&5B	\ >= ascii 'Z'+1
;B0 02                   BCS TT44 	\ jmp TT26, print character
;69 20                   ADC #&20	\ else Upper to lowercase
;	.TT44	\ print character as is with TT26
;4C FC 1E                JMP &1EFC \ TT26 \ print character
;
;	.TT41	\ QQ17 bit7 set
;24 72                   BIT &72		\ QQ17
;70 17                   BVS TT45	\ bit6 set too, Nothing or lower.
;C9 41                   CMP #&41	\ < ascii 'A'
;90 22                   BCC TT74 	\ print as is using TT26
;48                      PHA 		\ else store token Acc
;8A                      TXA 		\ QQ17 copy
;09 40                   ORA #&40	\ set bit6 in QQ17 so subsequent ones lower
;85 72                   STA &72	 	\ QQ17
;68                      PLA 		\ restore token
;D0 EC                   BNE TT44	\ guaranteed up, print as Uppercase with TT26.
;
;	.qw	\ Acc = 14to31 becomes 128to145 page4 digram
;69 72                   ADC #&72	\ A+=114 becomes 128to145 page4 digram
;D0 32                   BNE ex		\ guaranteed down, extra.
;
;	.crlf	\ Acc == 9,  colon on right
;A9 15                   LDA #21		\ on right
;85 2C                   STA &2C		\ XC
;D0 97                   BNE TT73	\ guaranteed up, print colon.
;
;	.TT45	\ QQ17 bits 7,6 set. Nothing or lower.
;E0 FF                   CPX #&FF	\ if QQ17 = #&FF
;F0 63                   BEQ TT48	\ rts
;C9 41                   CMP #&41	\ >= ascii 'A' ?
;B0 D0                   BCS TT42	\ Uppercase to lowercase, up.
;	.TT46	\ clear bit6 QQ17 and print as is using TT26
;48                      PHA 		\ push token
;8A                      TXA 		\ QQ17 copy
;29 BF                   AND #&BF	\ clear bit6
;85 72                   STA &72	 	\ QQ17
;68                      PLA 		\ pull token
;	.TT74	\ TT26, print character.
;4C FC 1E                JMP &1EFC	\ TT26
;
;	.TT43	\ Token > 127 page4 token or planet digram.
;C9 A0                   CMP #&A0	      \ >= #160 ?
;B0 14                   BCS TT47	      \ more page4, subtract #160
;29 7F                   AND #&7F	      \ else token 128to159  -> 0 to 31
;0A                      ASL A		      \ *= 2
;A8                      TAY 		      \ digram index = 0to62
;B9 80 08                LDA &0880,Y \ QQ16,Y  \ ALLEXEGEZACEBISOUSESARMAINDIREA?ER  etc.
;20 9A 33                JSR &339A   \ TT27    \ process text token
;B9 81 08                LDA &0881,Y \ QQ16+1,Y \ 2nd character of diagram. Flight copied down from docked code.
;C9 3F                   CMP #&3F	      \ is second letter '?'
;F0 40                   BEQ TT48    	      \ rts, name has odd-number of letters.
;4C 9A 33                JMP &339A   \ TT27    \ process text token
;
;	.TT47	\ more page4, subtract #160
;E9 A0                   SBC #&A0	\ -= 160
;	.ex	\ -> &342D \ extra, token >= 96 or Acc = 128to145 or -=160
;AA                      TAX 		\ copy of word index
;A9 00                   LDA #0		\ page 4 words lo  #QQ18 MOD 256
;85 22                   STA &22		\ V
;A9 04                   LDA #4		\ page 4 words hi  #QQ18 DIV 256
;85 23                   STA &23		\ V+1
;A0 00                   LDY #0
;8A                      TXA 		\ token = word index
;F0 13                   BEQ TT50	\ if X=0 then Y offset to word correct
;	.TT51	\ counters Y letter, X token
;B1 22                   LDA (&22),Y	\ (V),Y
;F0 07                   BEQ TT49	\ exit as word ended
;C8                      INY 		\ letter count
;D0 F9                   BNE TT51	\ loop Y
;E6 23                   INC &23	  \ V+1 \ next page as Y reached 256
;D0 F5                   BNE TT51    	\ guaranteed, loop Y letter
;	.TT49	\ word ended
;C8                      INY 
;D0 02                   BNE TT59    	\ next word
;E6 23                   INC &23	  \ V+1	\ next page as Y reached 256
;	.TT59	\ next word
;CA                      DEX 		\ token count
;D0 ED                   BNE TT51	\ loop X token
;	.TT50	\ token X = 0, counter Y offset to word correct
;98                      TYA 
;48                      PHA 		\ store Yindex
;A5 23                   LDA &23		\ V+1
;48                      PHA 		\ correct pointer hi 
;B1 22                   LDA (&22),Y 	\ (V),Y
;49 23                   EOR #&23	\ decode '#'
;20 9A 33                JSR &339A \ TT27 \ process text token to next depth
;68                      PLA 		\ restore this depth's Vhi
;85 23                   STA &23		\ V+1
;68                      PLA 		
;A8                      TAY 		\ restore this depth's Yindex
;C8                      INY 		\ next letter
;D0 02                   BNE P%+4	\ not zero so skip next page
;E6 23                   INC &23		\ V+1
;B1 22                   LDA (&22),Y	\ (V),Y
;D0 E6                   BNE TT50    	\ loop Y for next letter of page4 token
;	.TT48 	\ rts
;60                      RTS 		\ end of flight token printing TT27
;
;
;