bad:			; Legal status from Cargo scan
badFromCargoScan:
		ld 		a, (SlaveCargoTonnes)			; cargo slaves
		ld		hl,	NarcoticsCargoTonnes
		add		a,(hl)
		sla		a								; double if both slaves and narcotics
		ld		hl, FirearmsCargoTonnes
		add		a,(hl)							;  add firearms 
		ret										; FIST = 64 is cop-killer. Same as 32 tons of Slave or Narcotics.
