

;AddSpeedToVert:         MACRO   vertex
;                        ld      hl,(vertex)
;                        ld      a,(vertex+2)
;                        ld      b,a
;                        call    AHLEquBHLaddCDE
;                        ld      (vertex),hl
;                        ld      (vertex+2),a
;                        ENDM
                        

; ---------------------------------------------------------------------------------------------------------------------------------    
ApplyShipSpeed:         ld      a,(UBnkSpeed)                   ; get speed * 4
                        cp      0
                        ret     z
                        sla     a
                        sla     a
                        ld      iyl,a                           ; save pre calculated speed
.ApplyToX:              SpeedMulAxis    a, UBnkrotmatNosevX     ; e =  ABS (nosev x hi) c = sign
.AddSpeedToX:           AddSpeedToVert UBnkxlo
.ApplyToY:              SpeedMulAxis    iyl, UBnkrotmatNosevY     
.AddSpeedToY:           AddSpeedToVert UBnkylo
.ApplyToZ:              SpeedMulAxis    iyl, UBnkrotmatNosevZ
.AddSpeedToZ:           AddSpeedToVert UBnkzlo
                        ret
