ScaleObjectDistanceMacro:               MACRO  p?
; ">ScaleObjectDistance, scales camera location and returns c = scaling factor (equiv of X reg)"
p?_ScaleObjectDistance:           ld      a,(p?_QAddr)          ; Hull byte #18 normals scaled by 2^Q% DtProd^XX2  their comment   Dot product gives  normals' visibility in XX2
                                        ld      c,a                         ; c = Q factor for scaling of normals
; scaling object distance
.LL90:                                  ld      a,(p?_BnkDrawCam0zHi)         ; z_hi
                                        ld      b,a                         ; z_hi (yReg)
                                        ReturnIfAIsZero                     ; if zHi 0 test ifis object close/small, i.e. zhi already zero then we are done
; Loop dividing camera by 2 until zhi is 0 and updating scale factor
.LL90Loop:                              inc     c                           ; LL90+3 \ repeat INWK z brought closer, take Qscale X up
                                        ShiftMem16Right1 p?_BnkDrawCam0yLo    ; cam Y /= 2
                                        ShiftMem16Right1 p?_BnkDrawCam0xLo    ; cam X /= 2
                                        ShiftMem16Right1 p?_BnkDrawCam0zLo    ; cam Z /= 2
                                        ld      a,h                         ; last shift will result in zhi adjusted into h reg. 
                                        JumpIfAIsNotZero .LL90Loop           ; loop until z hi = 0 this gives scalinging in c
                                        ret
                                        ENDM
                                        
		