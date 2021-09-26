DENGY:										; 	\ -> &3629 \ Drain player's Energy
		ld 			hl,PlayerEnergy
		dec			(hl)
		push		af						; preserve z flag as part of this
		jr			nz,	.notZero
.ZeroEnergy:
		inc			(hl)					; \ ENERGY \ energy set back to 1 if 0
.notZero:		
		pop			af						
		ret									;  pull dec flag

