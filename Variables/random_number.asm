doRandom2:									; .DORND2	\ -> &3F85 \ Restricted for explosion dust.
doRND2:
	and		a								; fast clear carry  leave bit0 of RAND+2 at 0. 
doRandom:									;.DORND	\ -> &3F86 \ do random, new A, X.
; "doRandom, Random Seed update, new value in A & C)"
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

saveRandomSeeds:        ld      hl,RandomSeed
                        ld      de,RandomSeedSave
                        ld      bc,4
                        ldi
                        ldi
                        ldi
                        ldi
                        ret

restoreRandomSeeds:     ld      hl,RandomSeedSave
                        ld      de,RandomSeed
                        ld      bc,4
                        ldi
                        ldi
                        ldi
                        ldi
                        ret