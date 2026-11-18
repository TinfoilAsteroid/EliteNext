ESCAPE:										;	\ -> &20C1 \ your Escape capsule launch
		call			res2				; RES2 \ reset2
		ld				a,11				; Cobra Mk3  # CYL
		ld				(TYPE),a			; type used for drawing
		call			FRS1				; escape capsule launch, missile launch.
		jr				c,ES1				; carry flag set so ship was added
		ld				a,24				; CYCL2
		call			FRS1				; try for type 24 and just force the issue
.ES1:										; room for ship
		ld				a,8					; modest speed 
		ld				(INWKspeed)			; we will in reality use bank switching for all this later
		ld				a,$C2				; rotz, pitch counter
		ld				(rotZCounter),a		; INWK+30
		sra				a					; #&61 = ai dumb but has ecm, also counter.
		ld				(aiatkecm),a		;
.ESL1:										; ai counter INWK+32, ship flys out of view.
		call			.mveit				;  MVEIT			  Move it
		call			.ObjectEntry		; LL9  \ object ENTRY Draw it
		ld				hl,aiatkecm			;
		dec				(hl)				; INWK+32 
		jr				nz,.ESL1			; loop ai counter
		call			Scan				; SCAN \ ships on scanner
		call			ZeroCargo			; zero-out cargo, including gems.
		MakeInnocentMacro					;  FIST \ fugitative/innocent status, make clean
		NoEscapePodMacro					;  ESCP \ no escape pod 
		MaxFuelMacro						; 
		jp				GOIN				;  GOIN \ dock code
		
