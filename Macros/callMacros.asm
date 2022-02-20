
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

CallIfMemTrue:          MACRO mem, target
                        ld      a,(mem)
                        and     a
                        call    z, target
                        ENDM
                        
CallIfMemFalse:         MACRO mem, target
                        ld      a,(mem)
                        and     a
                        call    nz, target
                        ENDM

CallIfATrue:            MACRO target
                        and     a
                        call    z, target
                        ENDM
                        
CallIfAFalse:           MACRO target
                        and     a
                        call    nz, target
                        ENDM