ShiftIYRight1: MACRO
			   ld 	a,iyh
			   srl 	a
			   ld	iyh,a
			   ld 	a,iyl
			   rra
			   ld	iyl,a
			   ENDM

ShiftHLRight1: MACRO
			   srl h
			   rr  l
			   ENDM

ShiftDERight1: MACRO
			   srl d
			   rr  e
			   ENDM

ShiftBCRight1: MACRO
			   srl b
			   rr  c
			   ENDM


			   
ShiftHLDiv8:   MACRO
			   srl h
			   rr  l
			   srl h
			   rr  l
			   srl h
			   rr  l
			   ENDM 
			   
ShiftHLLeft1:  MACRO
			   sla l
			   rl  h
			   ENDM
            
ShiftDELeft1:  MACRO
			   sla e
			   rl  d
			   ENDM


RollDELeft1:   MACRO			   
               rl  e
               rl   d
               ENDM
			   
ShiftBCLeft1:  MACRO
			   sla b
			   rl  c
			   ENDM
               
ShiftMem16Right1:   MACRO memaddr
                    ld    hl,(memaddr)
                    srl   h
                    rr    l
                    ld    (memaddr),hl
                    ENDM
                    
ShiftMem8Right1:    MACRO memaddr
                    ld      a,(memaddr)
                    srl     a
                    ld      (memaddr),a
                    ENDM

                    
ShiftMem8Left1A:    MACRO memaddr
                    ld      a,(memaddr)
                    sla     a
                    ld      (memaddr),a
                    ENDM
                                    