FRS1:										;.FRS1	\ -> &2508  \ escape capsule Launched, see Cobra Mk3 ahead, or player missile launch.
		call		ZeroInfo				;  ZINF \ zero info
		ld			a,28					; ylo distance
		ld			(INWKyLo),a 			; 
		srl			a						;  #14 = zlo
		ld			(INWKzlo),a				; INWK+6
		ld			a,$80					; ysg -ve is below
		ld			(INWKysgn),a			; INWK+5
		ld			a,MissileTarget			;  MSTG \ = #FF if missile NOT targeted
		asl			a						;  convert to univ index, no ecm.
		ora			80						; set bit7, ai_active
		ld			(aiatkecm),a			; 
FQ1:										;  type Xreg cargo/alloys in explosion arrives here
		ld			a,$60					; unit +1
		ld			(rotmat0zHi),a			; rotmat0z hi
		ld			a,$80					; unit -1
		ld			(rotmat2xHi),a
		ld			a,(DELTA)				;  DELTA	  \ speed
		rla			a						; missile speed is double
		ld			(INWKspeed),a			;  INWK+27 \ speed
		ld			a,(regX)				; ship type
		call		NewShip					;  NWSHP \ New ship type X from A reg
