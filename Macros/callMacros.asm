
CallIfAGTENusng:        MACRO   reg,target
                        cp      reg
                        call	nc,target
                        ENDM

CallIfAGTEMemusng:      MACRO   reg,target
                        ld      hl,reg
                        cp      (hl)
                        call	nc,target
                        ENDM
                        
CallIfALTNusng:         MACRO   reg,target
                        cp      reg
                        call	c,target
                        ENDM
                        
CallIfMemEqMemusng:     MACRO mem, address, target
                        ld   a,(mem)
                        ld   hl,address
                        cp   (hl)
                        call    z,target
                        ENDM
