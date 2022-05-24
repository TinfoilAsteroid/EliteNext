SpeedMulAxis:           MACRO   speedreg, axis
                        ld      e,speedreg
                        ld      hl,(axis)
                        ld      a,h
                        ClearSignBitA
                        ld      d,a
                        mul     de
                        ld      a,h
                        SignBitOnlyA
                        ld      c,a
                        ld      e,d
                        ld      d,0
                        ENDM

AddSpeedToVert:         MACRO   vertex
                        ld      hl,(vertex)
                        ld      a,(vertex+2)
                        ld      b,a
                        call    AHLEquBHLaddCDE
                        ld      (vertex),hl
                        ld      (vertex+2),a
                        ENDM
                        

; ---------------------------------------------------------------------------------------------------------------------------------    
ApplyShipSpeed:         ld      a,(UBnKSpeed)                   ; get speed * 4
                        sla     a
                        sla     a
                        ld      iyl,a                           ; save pre calculated speed
.ApplyToX:              SpeedMulAxis    a, UBnkrotmatNosevX     ; e =  ABS (nosev x hi) c = sign
.AddSpeedToX:           AddSpeedToVert UBnKxlo
.ApplyToY:              SpeedMulAxis    a, UBnkrotmatNosevY     
.AddSpeedToY:           AddSpeedToVert UBnKylo
.ApplyToZ:              SpeedMulAxis    a, UBnkrotmatNosevZ
.AddSpeedToZ:           AddSpeedToVert UBnKzlo
                        ret
