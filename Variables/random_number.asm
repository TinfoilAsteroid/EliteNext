doRandom2:									; .DORND2	\ -> &3F85 \ Restricted for explosion dust.
doRND2:
	and		a								; fast clear carry  leave bit0 of RAND+2 at 0. 
doRandom:									;.DORND	\ -> &3F86 \ do random, new A, X.
; "doRandom, Random Seed update, new value in A & B)"
doRND:                  ld		a,(RandomSeed)					; Get Seed 0
                        rl		a								; Rotate L including carry
                        ld		c,a								; c =  double lo
.AddSeed2:              ld		hl,RandomSeed2
                        adc		a,(hl)							; RAND+2
.SaveAtoSeed:           ld		(RandomSeed),a					; and save RAND
.SaveBtoSeed2:          ex		af,af'
                        ld		a,c
                        ld		(RandomSeed2),a
                        ex		af,af'
                        ld		a,(RandomSeed1)
                        ld		c,a								; C = Seed1
.AddSeed3:              ld		hl,RandomSeed3
                        adc		a,(hl)
                        ld		(RandomSeed1),a
                        ex		af,af'
                        ld		a,c
                        ld		(RandomSeed3),a
                        ex		af,af'
                        ret

fillHeapRandom4Points:                      ; counter Y, 4 rnd bytes to edge heap 
	ld		b,4                                                                                            
	ld		hl,UbnkLineArray				; line data                                                    
FillRandom:                                 ; Writes random bytes hl = start address, b = nbr bytes to fill
EE55:                                                                                                      
	call	doRND							; get random                                                   
	ld		(hl),a							; (XX19),Y                                                     
	inc		hl                                                                                             
	djnz	FillRandom						; 3to6 = random bytes for seed
    ret
    