;  sidev = (1,  0,  0)  sidev = (&6000, 0, 0)
;  roofv = (0,  1,  0)  roofv = (0, &6000, 0)
;  nosev = (0,  0, -1)  nosev = (0, 0, &E000)   E000 = SignBit[96]
InitialiseOrientation:
ZI1:                    ld      hl, 0
                        ld      (UBnkrotmatSidevY),hl                ; set the zeroes
                        ld      (UBnkrotmatSidevZ),hl                ; set the zeroes
                        ld      (UBnkrotmatRoofvX),hl                ; set the zeroes
                        ld      (UBnkrotmatRoofvZ),hl                ; set the zeroes
                        ld      (UBnkrotmatNosevX),hl                ; set the zeroes
                        ld      (UBnkrotmatNosevY),hl                ; set the zeroes
; Optimised as already have 0 in l
                        ld      h, $60	             				; 96 in hi byte
                        ;ld      hl,1
                        ld      (UBnkrotmatSidevX),hl
                        ld      (UBnkrotmatRoofvY),hl
; Optimised as already have 0 in l
                        ld      h, $E0					            ; -96 in hi byte which is +96 with hl bit 7 set
                        ld      (UBnkrotmatNosevZ),hl
                        ret

InitialisePlayerMissileOrientation:
                        call    InitialiseOrientation
                        ld      hl,$6000
                        ld      (UBnkrotmatNosevZ),hl           ; mius
                        ret


;  sidev = (1,  0,  0)  sidev = (&6000, 0, 0)
;  roofv = (0,  1,  0)  roofv = (0, &6000, 0)
;  nosev = (-0,  -0, 1) nosev = (0, 0, &6000)
LaunchedOrientation:    call    InitialiseOrientation
                        FlipSignMem UBnkrotmatNosevX+1;  as its 0 flipping will make no difference
                        FlipSignMem UBnkrotmatNosevY+1;  as its 0 flipping will make no difference
                        FlipSignMem UBnkrotmatNosevZ+1
                        ret
