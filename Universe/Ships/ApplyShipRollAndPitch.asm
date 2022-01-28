;----------------------------------------------------------------------------------------------------------------------------------
; based on MVEIT part 4 of 9
ApplyShipRollAndPitch:  ld      a,(UBnKRotZCounter)             ; get roll magnitudeShip Pitch counter
                        ld      b,a
                        and     SignOnly8Bit                
                        ld      c,a
                        ld      (univRAT2),a                ; get sign of pitch
                        ld      a,b
                        and     SignMask8Bit                ; and magnitude
                        jr      z,.ProcessRoll
.CheckPitchDamping:     cp      SignMask8Bit
                        jr      z,.NoPitchDamping
.ApplyPitchDamping:     dec     a                           ; pitch = pitch-1
.NoPitchDamping         ld      (univRAT2Val),a
                        ld      b,a
                        or      c                           ; bring sign back in
                        ld      (UBnKRotZCounter),a             ; rotZCounter = updated value
.PitchSAxes:            ld	    hl,UBnkrotmatRoofvX; UBnkrotmatSidevY
                        ld	    (varAxis1),hl
                        ld	    hl,UBnkrotmatNosevX; UBnkrotmatSidevZ	
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
.PitchRAxes:            ld	    hl,UBnkrotmatRoofvY	
                        ld	    (varAxis1),hl
                        ld	    hl,UBnkrotmatNosevY;UBnkrotmatRoofvZ	
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
.PitchNAxes:            ld	    hl,UBnkrotmatRoofvZ; UBnkrotmatNosevY	
                        ld	    (varAxis1),hl
                        ld	    hl,UBnkrotmatNosevZ	
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
.ProcessRoll:           ld      a,(UBnKRotXCounter)
                        ld      b,a
                        and     SignOnly8Bit                
                        ld      c,a
                        ld      (univRAT2),a                ; get sign of pitch
                        ld      a,b
                        and     SignMask8Bit                ; and magnitude
                        ret     z                           ; if no work to do then exit
.CheckRollDamping:      cp      SignMask8Bit
                        jr      z,.NoRollDamping
.ApplyRollDamping:      dec      a                     ; pitch = pitch-1
.NoRollDamping          ld      (univRAT2Val),a
                        ld      b,a
                        or      c                           ; bring sign back in
                        ld      (UBnKRotXCounter),a             ; rotZCounter = updated value
.RollSAxis:           	ld	    hl,UBnkrotmatRoofvX; UBnkrotmatSidevX	
                        ld	    (varAxis1),hl
                        ld	    hl,UBnkrotmatSidevX; UBnkrotmatSidevY
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
.RollRAxis:             ld	    hl,UBnkrotmatRoofvY; UBnkrotmatRoofvX	
                        ld	    (varAxis1),hl
                        ld	    hl,UBnkrotmatSidevY; UBnkrotmatRoofvY	
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
.RollNAxis:             ld	    hl,UBnkrotmatRoofvZ; UBnkrotmatNosevX
                        ld	    (varAxis1),hl
                        ld	    hl,UBnkrotmatSidevZ; UBnkrotmatNosevY	
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
                        ret

