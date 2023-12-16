AequAdivDmul96Unsg:     JumpIfAGTENusng d, .Unity    			; if A >= Q then return with a 1 (unity i.e. 96)
                        ld          b,%11111111                 ; Loop through 8 bits
.DivLoop:               sla         a                           ; shift a left
                        JumpIfALTNusng d, .skipSubtract         ; if a < q skip the following
                        sub         d
.skipSubtract:          FlipCarryFlag
                        rl          b
                        jr          c,.DivLoop
                        ld          a,b
                        srl         a                  			; t = t /4
                        srl			a							; result / 8
                        ld          b,a
                        srl         a
                        add			a,b							; result /8 + result /4
                        ret
.Unity:                 ld			a,$60	    				; unity
                        ret
	