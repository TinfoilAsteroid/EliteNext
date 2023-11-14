;  sidev = (1,  0,  0)  sidev = (&6000, 0, 0)
;  roofv = (0,  1,  0)  roofv = (0, &6000, 0)
;  nosev = (0,  0, -1)  nosev = (0, 0, &E000)   E000 = SignBit[96]
InitialiseOrientationMacro      MACRO p?
p?_InitialiseOrientation: ld      hl, 0
                                ld      (p?_BnkrotmatSidevY),hl                ; set the zeroes
                                ld      (p?_BnkrotmatSidevZ),hl                ; set the zeroes
                                ld      (p?_BnkrotmatRoofvX),hl                ; set the zeroes
                                ld      (p?_BnkrotmatRoofvZ),hl                ; set the zeroes
                                ld      (p?_BnkrotmatNosevX),hl                ; set the zeroes
                                ld      (p?_BnkrotmatNosevY),hl                ; set the zeroes
; Optimised as already have 0 in l
                                ld      h, $60	             				; 96 in hi byte
                        ;ld      hl,1
                                ld      (p?_BnkrotmatSidevX),hl
                                ld      (p?_BnkrotmatRoofvY),hl
; Optimised as already have 0 in l
                                ld      h, $E0					            ; -96 in hi byte which is +96 with hl bit 7 set
                                ld      (p?_BnkrotmatNosevZ),hl
                                ret
                                ENDM

InitialisePlayerMissileOrientationMacro: MACRO p?
p?_InitialisePlayerMissileOrientation:
                                call    p?_InitialiseOrientation
                                ld      hl,$6000
                                ld      (p?_BnkrotmatNosevZ),hl           ; mius
                                ret
                                ENDM

;  sidev = (1,  0,  0)  sidev = (&6000, 0, 0)
;  roofv = (0,  1,  0)  roofv = (0, &6000, 0)
;  nosev = (-0,  -0, 1) nosev = (0, 0, &6000)
LaunchedOrientationMacro:       MACRO p?
p?_LaunchedOrientation:   call    p?_InitialiseOrientation
                                FlipSignMem p?_BnkrotmatNosevX+1;  as its 0 flipping will make no difference
                                FlipSignMem p?_BnkrotmatNosevY+1;  as its 0 flipping will make no difference
                                FlipSignMem p?_BnkrotmatNosevZ+1
                                ret
                                ENDM
