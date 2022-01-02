;----------------------------------------------------------------------------------------------------------------------------------
; based on MVEIT part 4 of 9
SunApplyShipRollAndPitch:  ld      a,(SunrotZCounter)             ; get roll magnitudeShip Pitch counter
                        ld      b,a
                        and     SignOnly8Bit                
                        ld      c,a
                        ld      (SunRAT2),a                ; get sign of pitch
                        ld      a,b
                        and     SignMask8Bit                ; and magnitude
                        jr      z,.ProcessRoll
.CheckPitchDamping:     cp      SignMask8Bit
                        jr      z,.NoPitchDamping
.ApplyPitchDamping:     dec     a                           ; pitch = pitch-1
.NoPitchDamping         ld      (SunRAT2Val),a
                        ld      b,a
                        or      c                           ; bring sign back in
                        ld      (SunrotZCounter),a             ; SunrotZCounter = updated value
.PitchSAxes:            ld	    hl,SunKrotmatRoofvX; SunKrotmatSidevY
                        ld	    (varAxis1),hl
                        ld	    hl,SunKrotmatNosevX; SunKrotmatSidevZ	
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
.PitchRAxes:            ld	    hl,SunKrotmatRoofvY	
                        ld	    (varAxis1),hl
                        ld	    hl,SunKrotmatNosevY;SunKrotmatRoofvZ	
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
.PitchNAxes:            ld	    hl,SunKrotmatRoofvZ; SunKrotmatNosevY	
                        ld	    (varAxis1),hl
                        ld	    hl,SunKrotmatNosevZ	
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
.ProcessRoll:           ld      a,(SunrotXCounter)
                        ld      b,a
                        and     SignOnly8Bit                
                        ld      c,a
                        ld      (SunRAT2),a                ; get sign of pitch
                        ld      a,b
                        and     SignMask8Bit                ; and magnitude
                        ret     z                           ; if no work to do then exit
.CheckRollDamping:      cp      SignMask8Bit
                        jr      z,.NoRollDamping
.ApplyRollDamping:      dec      a                     ; pitch = pitch-1
.NoRollDamping          ld      (SunRAT2Val),a
                        ld      b,a
                        or      c                           ; bring sign back in
                        ld      (SunrotXCounter),a             ; SunrotZCounter = updated value
.RollSAxis:           	ld	    hl,SunKrotmatRoofvX; SunKrotmatSidevX	
                        ld	    (varAxis1),hl
                        ld	    hl,SunKrotmatSidevX; SunKrotmatSidevY
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
.RollRAxis:             ld	    hl,SunKrotmatRoofvY; SunKrotmatRoofvX	
                        ld	    (varAxis1),hl
                        ld	    hl,SunKrotmatSidevY; SunKrotmatRoofvY	
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
.RollNAxis:             ld	    hl,SunKrotmatRoofvZ; SunKrotmatNosevX
                        ld	    (varAxis1),hl
                        ld	    hl,SunKrotmatSidevZ; SunKrotmatNosevY	
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
                        ret

