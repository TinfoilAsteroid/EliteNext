ShiftIYRight1: MACRO
			   ld 	a,iyh
			   srl 	a
			   ld	iyh,a
			   ld 	a,iyl
			   rra
			   ld	iyl,a
			   ENDM

ShiftIXRight1: MACRO
			   ld 	a,ixh
			   srl 	a
			   ld	ixh,a
			   ld 	a,ixl
			   rra
			   ld	ixl,a
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
			   
ShiftHLLeft1:  MACRO    ; 16 T states
			   sla l
			   rl  h
			   ENDM
            
ShiftDELeft1:  MACRO    ; 16 T states
			   sla e
			   rl  d
			   ENDM

BarrelHLLeft3: MACRO
               ex       de,hl   ; 4   43 T states vs 32 for doing ShiftHL Twice, so need at least 3 Shifts
               push     bc      ; 10
               ld       b,3     ; 7
               bsrl     de,b    ; 8 
               pop      bc      ; 10
               ex       de,hl   ; 4
               ENDM

BarrelHLRight3: MACRO
               ex       de,hl   ; 4   43 T states vs 32 for doing ShiftHL Twice, so need at least 3 Shifts
               push     bc      ; 10
               ld       b,3     ; 7
               bsrl     de,b    ; 8 
               pop      bc      ; 10
               ex       de,hl   ; 4
               ENDM

RollBCLeft1:   MACRO	; 16 T states  
               rl  c
               rl  b
               ENDM

RollDELeft1:   MACRO	; 16 T states  
               rl  e
               rl  d
               ENDM
			   
ShiftBCLeft1:  MACRO    ; 16 T states
			   sla c
			   rl  b
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
                                    