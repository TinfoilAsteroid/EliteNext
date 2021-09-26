GALAXYSEED DB "GALAXYSEED"
copy_galaxy_to_system:
		ld		hl,GalaxySeeds
		ld		de,SystemSeed
copy_seed:		
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi
		ret

copy_system_to_galaxy:
		ld		hl,SystemSeed
		ld		de,GalaxySeeds
		jr		copy_seed

copy_galaxy_to_working:
		ld		hl,GalaxySeeds
		ld		de,WorkingSeeds
		jr		copy_seed

copy_working_to_galaxy:
		ld		hl,WorkingSeeds
		ld		de,GalaxySeeds
		jr		copy_seed

copy_working_to_system:
		ld		hl,WorkingSeeds
		ld		de,SystemSeed
		jr		copy_seed

copy_system_to_working:
		ld		hl,SystemSeed
		ld		de,WorkingSeeds
		jr		copy_seed

next_system_seed:							;.TT20	\ -> &2B0E  \ TWIST on QQ15 to next system
		call	.NextStep					; This logic means we hard code x4
.NextStep:		
		call	process_seed				; This logic means we hard code x2
process_seed:								; TT54	\ -> &2637 \ Twist seed for next digram in QQ15
		ld		a,(SystemSeed)				; QQ15
		or		a							; clear carry flag 
		ld		hl,SystemSeed+2				; hl -> qq+2
		add		a,(hl)						; a= QQ15 + QQ152
		ld		b,a							; partial sum lo
		ld		a,(SystemSeed+1)
		ld		hl,SystemSeed+3				; HL -> QQ+3 )we don't inc as it affects carry)
		adc		a,(hl)						; note add with carry 
		ld		c,a  						; c = QQ1+QQ3+carry bit parial sum hi
		ld		a,(SystemSeed+2)
		ld		(SystemSeed+0),a			; copy qq152 to qq150
		ld		a,(SystemSeed+3)
		ld		(SystemSeed+1),a			; copy qq153 to qq151
		ld		a,(SystemSeed+5)
		ld		(SystemSeed+3),a			; copy qq155 to qq153
		ld		a,(SystemSeed+4)
		ld		(SystemSeed+2),a			; copy qq154 to qq152
		or		a
		ld		a,b
		ld		hl,SystemSeed+2				; hl -> qq+2
		add	    a,(hl)
		ld		(SystemSeed+4),a
		ld		a,c
		ld		hl,SystemSeed+3				; HL -> QQ+3 )we don't inc as it affects carry)
		adc		a,(hl)
		ld		(SystemSeed+5),a
		ret

next_working_seed:							;.TT20	\ -> &2B0E  \ TWIST on QQ15 to next system
		call	.NextStep					; This logic means we hard code x4
.NextStep:		
		call	working_seed				; This logic means we hard code x2
working_seed:								; TT54	\ -> &2637 \ Twist seed for next digram in QQ15
; x = a + c
		ld		a,(WorkingSeeds)			; QQ15
		or		a							; clear carry flag 
		ld		hl,WorkingSeeds+2			; hl -> qq+2 [c]
		add		a,(hl)						; a= QQ15 [a]+ QQ15 [c]		
		ld		b,a							; partial sum lo [x]
; y = b + d	+ carry
		ld		a,(WorkingSeeds+1)          ; [b]
		ld		hl,WorkingSeeds+3			; HL -> QQ+3 [d] we don't inc as it affects carry)
		adc		a,(hl)						; note add with carry 
		ld		c,a  						; c = QQ1+QQ3+carry bit parial sum hi		
		ld		a,(WorkingSeeds+2)
		ld		(WorkingSeeds+0),a			; copy qq152 to qq150 [a] = [c]
		ld		a,(WorkingSeeds+3)
		ld		(WorkingSeeds+1),a			; copy qq153 to qq151 [b] = [d]
		ld		a,(WorkingSeeds+5)
		ld		(WorkingSeeds+3),a			; copy qq155 to qq153 [d] = [f]
		ld		a,(WorkingSeeds+4)
		ld		(WorkingSeeds+2),a			; copy qq154 to qq152 [c] = [e]
		or		a
		ld		a,b
		ld		hl,WorkingSeeds+2		    ; hl -> qq+2 
		add	    a,(hl)
		ld		(WorkingSeeds+4),a			; e = x + [c]
		ld		a,c
		ld		hl,WorkingSeeds+3			; HL -> QQ+3 )we don't inc as it affects carry)
		adc		a,(hl)
		ld		(WorkingSeeds+5),a			; f = y + [d] + carry
		ret

working_distX	DB 50
working_distY	DB 50
current_distY	DB 0

find_present_system:
	xor		a
	ld		(XSAV),a
.CounterLoop:
	ld		a,(SystemSeed+1)				; QQ15+1 \ seed Ycoord of star
	ld		c,a
.calcLocaldy:
	ld		a,(PresentSystemY)
	ld		b,a								; so b holds Y ccord
	ld		a,c
	sub		b
	bit		7,a
	jr		z,.positivedy
.negativedy:
	neg
.positivedy:
	ld		(current_distY),a				; save cuirrent_dist Y as we need it maybe
	ld		de,(working_distX)
	cp		d
	jr		nc,.toofar
.calcLocaldx:
	ld		a,(SystemSeed+3)				; QQ15+3 \ seed Xcoord of star
	ld		c,a
	ld		a,(PresentSystemX)
	ld		b,a								; so b holds Y ccord
	ld		a,c
	sub		b
	bit		7,a
	jr		z,.positivedx
.negativedx:
	neg
.positivedx:
	ld		c,a
	cp		e
	jr		nc,.toofar
.Nearer:									; we have a closer system
	ld		a,(current_distY)
	ld		b,a								; we have c to recall Y into b
	ld		(working_distX),bc
	push	bc
	call 	copy_system_to_working
	pop		bc
	ld		a,b								;
	or		c								;
	ret		z								; if we have distance 0 then bang on
.toofar:
	call	next_system_seed
	ld		a,(XSAV)
	dec		a
	cp		0
	ret		z
	ld		(XSAV),a
	jr		.CounterLoop
	
	
get_planet_data_working_seed:
		ld		a, (WorkingSeeds+1)
		and		7
		ld		(DisplayEcononmy),a
		ld		a, (WorkingSeeds+2)
		srl	a
		srl	a
		srl	a
		srl	a								; c/8
		and		7
		ld		(DisplayGovernment),a
		srl	a
		cp		0
		jr		nz,.CanBeRich
.Fedual:
		ld		a,(DisplayEcononmy)
		or		2							; Adjust Eco for Anarchy and Feudal, set bit 1.
		ld		(DisplayEcononmy),a
.CanBeRich:
		ld		a,(DisplayEcononmy)
		xor		7							; flip economy so Rich is now 7
		ld		(DisplayTekLevel),a			; Flipped Eco, EcoEOR7, Rich Ind = 7
		ld		b,a
		ld		a,(WorkingSeeds+3)
		and		3
		add		a,b
		ld		(DisplayTekLevel),a			; Tek Level += seed d & 3
		ld		a,(DisplayGovernment)		; Government, 0 is Anarchy
		srl		a 							; gov/2
		ld		b,a
		ld		a,(DisplayTekLevel)
		add		a,b
		ld		(DisplayTekLevel),a			; Tek += gov /2
		sla		a
		sla		a							; Onto Population (TL-1)*= 4
		ld		b,a
		ld		a,(DisplayEcononmy)
		add		a,b                  		; TechLevel*4 + Eco   7-56
		ld		b,a
		ld		a,(DisplayGovernment)
		inc		a  							; +Government, 0 is Anarchy + 1
		ld		(DisplayPopulation),a
		ld		a,(DisplayEcononmy)
		xor		7							; Onto productivity
		add		3							;  (Flipped eco +3)
		ld		d,a
		ld		a,(DisplayGovernment)		; Government, 0 is Anarchy
		add		4
		ld		e,a						
		mul									; ; DE = d*e, Productivity part 1. has hsb in A, lsb in P.
		ld		a,(DisplayPopulation)		; then we use d for radius
		ld		d,a
		mul
		sla		e
		rr		d
		sla		e
		rr		d
		sla		e
		rr		d							; de * 8
		ld		(DisplayProductivity),de	
.DoRadius:
		ld		a,(WorkingSeeds+3)
		ld		c,a
		ld		a,(WorkingSeeds+5)
		and		$0F							;  lower 4 bits of w2_h determine planet radius
		add		11							;  radius min = 256*11 = 2816 km
		ld		b,a							;  
		ld		(DisplayRadius),bc
		ret
        