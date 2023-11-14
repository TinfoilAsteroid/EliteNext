XX18DefineMacro:                MACRO p?
;-- XX18 --------------------------------------------------------------------------------------------------------------------------
p?_BnkDrawCam0xLo         DB  0               ; XX18+0
p?_BnkDrawCam0xHi         DB  0               ; XX18+1
p?_BnkDrawCam0xSgn        DB  0               ; XX18+2
p?_BnkDrawCam0x           equ p?_BnkDrawCam0xLo
p?_BnkDrawCam0yLo         DB  0               ; XX18+3
p?_BnkDrawCam0yHi         DB  0               ; XX18+4
p?_BnkDrawCam0ySgn        DB  0               ; XX18+5
p?_BnkDrawCam0y           equ p?_BnkDrawCam0yLo
p?_BnkDrawCam0zLo         DB  0               ; XX18+6
p?_BnkDrawCam0zHi         DB  0               ; XX18+7
p?_BnkDrawCam0zSgn        DB  0               ; XX18+8
p?_BnkDrawCam0z           equ p?_BnkDrawCam0zLo
p?_XX18                   equ p?_BnkDrawCam0xLo
                                ENDM    
        
CopyXX18toXX15Macro:            MACRO p?
p?_CopyXX18toXX15:
p?_CopyDrawCamToScaled:   ldCopyByte  p?_BnkDrawCam0xLo ,p?_BnkXScaled        ; xlo
                                ldCopyByte  p?_BnkDrawCam0xSgn,p?_BnkXScaledSign    ; xsg
                                ldCopyByte  p?_BnkDrawCam0yLo ,p?_BnkYScaled        ; xlo
                                ldCopyByte  p?_BnkDrawCam0ySgn,p?_BnkYScaledSign    ; xsg
                                ldCopyByte  p?_BnkDrawCam0zLo ,p?_BnkZScaled        ; xlo
                                ldCopyByte  p?_BnkDrawCam0zSgn,p?_BnkZScaledSign    ; xsg
                                ret
				                ENDM
                                
LoadCraftToCameraMacro:         MACRO p?                   
p?_LoadCraftToCamera:     ld      hl,(p?_Bnkxlo)            ; BnKxlo, BnKxhi
                                ld      de,(p?_Bnkxsgn)           ; BnKxsgn, BnKylo
                                ld      bc,(p?_Bnkyhi)            ; BnKyhi, BnKysgn
                                ld      (p?_BnkDrawCam0xLo),hl    ; BnKDrawCam0xLo, BnKDrawCam0xHi
                                ld      (p?_BnkDrawCam0xSgn),de   ; BnKDrawCam0xSgn,BnKDrawCam0yLo
                                ld      (p?_BnkDrawCam0yHi),bc    ; BnKDrawCam0yHi, BnKDrawCam0ySgn
                                ld      hl,(p?_Bnkzlo)            ; BnKzlo, BnKzhi
                                ld      a,(p?_Bnkzsgn)            ; BnKzlo
                                ld      (p?_BnkDrawCam0zLo),hl     ; BnKDrawCam0zLo, BnKDrawCam0zHi
                                ld      (p?_BnkDrawCam0zSgn),a     ; BnKDrawCam0zSgn
                                ret
                                ENDM

CopyCameraToXX15SignedMacro:    MACRO p?                                           
p?_CopyCameraToXX15Signed:ld  hl,(p?_BnkDrawCam0xLo)
                                ld  a,(p?_BnkDrawCam0xSgn)
                                or  h
                                ld  h,a
                                ld  (p?_BnkXScaled),hl
                                ld  hl,(p?_BnkDrawCam0yLo)
                                ld  a,(p?_BnkDrawCam0ySgn)
                                or  h
                                ld  h,a
                                ld  (p?_BnkYScaled),hl
                                ld  hl,(p?_BnkDrawCam0zLo)
                                ld  a,(p?_BnkDrawCam0zSgn)
                                or  h
                                ld  h,a
                                ld  (p?_BnkZScaled),hl
                                ret
                                ENDM
                                
XX15EquXX15AddXX18Macro:        MACRO p?
p?_X15EquXX15AddXX18:
.LL94Z:                         ld      h,0                            ;           AddZ = FaceData (XX12)z +  ShipPos (XX18)z                                         
                                ld      d,0                            ;           
                                ld      a,(p?_BnkZScaled)        ;           
                                ld      l,a                            ;           
                                ld      a,(p?_BnkZScaledSign)    ;           
                                ld      b,a                            ;           
                                ld      a,(p?_BnkDrawCam0zLo)    ;           
                                ld      e,a                            ;           
                                ld      a,(p?_BnkDrawCam0zSgn)   ;
                                ld      c,a                            ;
                                MMUSelectMathsBankedFns
                                call    ADDHLDESignBC                  ;           
                                ld      b,a                            ;           
                                ld      a,h                            ;           
                                ld      a,b                            ;           else  Scaled (XX15) Z = AddZ
                                ld      (p?_BnkZScaledSign),a            ;           
                                ld      a,l                            ;           
                                ld      (p?_BnkZScaled),a                ;           endif
.LL94X:                         ld      h,0                                                     ;           AddZ = FaceData (XX12)z +  ShipPos (XX18)z                                         
                                ld      d,0                                                     ;           
                                ld      a,(p?_BnkXScaled)                                         ;           
                                ld      l,a                                                     ;           
                                ld      a,(p?_BnkXScaledSign)                                     ;           
                                ld      b,a                                                     ;           
                                ld      a,(p?_BnkDrawCam0xLo)                                     ;           
                                ld      e,a                                                     ;           
                                ld      a,(p?_BnkDrawCam0xSgn)                                    ;
                                ld      c,a                                                     ;
                                MMUSelectMathsBankedFns
                                call    ADDHLDESignBC                                           ;           
                                ld      b,a                                                     ;           
                                ld      a,h                                                     ;           
                                ld      a,b                                                     ;           else  Scaled (XX15) Z = AddZ
                                ld      (p?_BnkXScaledSign),a                                     ;           
                                ld      a,l                                                     ;           
                                ld      (p?_BnkXScaled),a                                         ;           endif                                                                          
.LL94Y:                         ld      h,0                                                     ;           AddZ = FaceData (XX12)z +  ShipPos (XX18)z                                         
                                ld      d,0                                                     ;           
                                ld      a,(p?_BnkYScaled)                                         ;           
                                ld      l,a                                                     ;           
                                ld      a,(p?_BnkYScaledSign)                                     ;           
                                ld      b,a                                                     ;           
                                ld      a,(p?_BnkDrawCam0yLo)                                     ;           
                                ld      e,a                                                     ;           
                                ld      a,(p?_BnkDrawCam0ySgn)                                    ;
                                ld      c,a                                                     ;
                                MMUSelectMathsBankedFns
                                call    ADDHLDESignBC                                           ;           
                                ld      b,a                                                     ;           
                                ld      a,h                                                     ;           
                                ld      a,b                                                     ;           else  Scaled (XX15) Z = AddZ
                                ld      (p?_BnkYScaledSign),a                                     ;           
                                ld      a,l                                                     ;           
                                ld      (p?_BnkYScaled),a                                         ;
                                ret
                                ENDM

