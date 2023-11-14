ScaleNodeTo8BitMacro:       MACRO p?
p?_ScaleNodeTo8Bit:   ld			bc,(SS_BnkZScaled)
                            ld			hl,(SS_BnkXScaled)
                            ld			de,(SS_BnkYScaled)		
.SetABSbc:                  ld			a,b
                            ld			ixh,a
                            
                            and			SignMask8Bit
                            ld			b,a									; bc = ABS bc
.SetABShl:                  ld			a,h
                            ld			ixl,a
                            and			SignMask8Bit
                            ld			h,a									; hl = ABS hl
.SetABSde:                  ld			a,d
                            ld			iyh,a
                            and			SignMask8Bit
                            ld			d,a									; de = ABS de
.ScaleNodeTo8BitLoop:       ld          a,b		                            ; U	\ z hi
                            or			h                                   ; XX15+1	\ x hi
                            or			d                                   ; XX15+4	\ y hi
                            jr          z,.ScaleNodeDone                   ; if X, Y, Z = 0  exit loop down once hi U rolled to 0
                            ShiftHLRight1
                            ShiftDERight1
                            ShiftBCRight1
                            jp          .ScaleNodeTo8BitLoop
; now we have scaled values we have to deal with sign
.ScaleNodeDone:             ld			a,ixh								; get sign bit and or with b
                            and			SignOnly8Bit
                            or			b
                            ld			b,a
.SignforHL:                 ld			a,ixl								; get sign bit and or with b
                            and			SignOnly8Bit
                            or			h
                            ld			h,a
.SignforDE:                 ld			a,iyh								; get sign bit and or with b
                            and			SignOnly8Bit
                            or			d
                            ld			d,a
.SignsDoneSaveResult:	    ld			(SS_BnkZScaled),bc
                            ld			(SS_BnkXScaled),hl
                            ld			(SS_BnkYScaled),de
                            ld			a,b
                            ld			(varU),a
                            ld			a,c
                            ld			(varT),a
                            ret
                            ENDM
