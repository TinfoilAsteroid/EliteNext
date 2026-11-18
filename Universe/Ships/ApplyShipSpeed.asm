

; ---------------------------------------------------------------------------------------------------------------------------------    
ApplyShipSpeed:         ld      a,(UBnKSpeed)                   ; get speed * 4
                        cp      0
                        ret     z
                        sla     a
                        sla     a
                        ld      iyl,a                           ; save pre calculated speed
.ApplyToX:              SpeedMulAxis    a, UBnkrotmatNosevX     ; e =  ABS (nosev x hi) c = sign
.AddSpeedToX:           AddSpeedToVert UBnKxlo
.ApplyToY:              SpeedMulAxis    iyl, UBnkrotmatNosevY     
.AddSpeedToY:           AddSpeedToVert UBnKylo
.ApplyToZ:              SpeedMulAxis    iyl, UBnkrotmatNosevZ
.AddSpeedToZ:           AddSpeedToVert UBnKzlo
                        ret
