InitialiseOrientation:
ZI1:
;  nosev = (0,  0, -1)  nosev = (0, 0, &E000)   E000 = SignBit[96]
;  roofv = (0,  1,  0)  roofv = (0, &6000, 0)
;  sidev = (1,  0,  0)  sidev = (&6000, 0, 0)
    ld      hl, 0
    ld      (UBnkrotmatSidevY),hl                ; set the zeroes
    ld      (UBnkrotmatSidevZ),hl                ; set the zeroes
    ld      (UBnkrotmatRoofvX),hl                ; set the zeroes
    ld      (UBnkrotmatRoofvZ),hl                ; set the zeroes
    ld      (UBnkrotmatNosevX),hl                ; set the zeroes
    ld      (UBnkrotmatNosevY),hl                ; set the zeroes
    ld      hl, $6000					; 96 in hi byte
    ;ld      hl,1
    ld      (UBnkrotmatSidevX),hl
    ld      (UBnkrotmatRoofvY),hl
    ld      hl, $E000					; -96 in hi byte which is +96 with hl bit 7 set
    ld      (UBnkrotmatNosevZ),hl
    ret
	