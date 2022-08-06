

;AddSpeedToVert:         MACRO   vertex
;                        ld      hl,(vertex)
;                        ld      a,(vertex+2)
;                        ld      b,a
;                        call    AHLEquBHLaddCDE
;                        ld      (vertex),hl
;                        ld      (vertex+2),a
;                        ENDM
                        

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
