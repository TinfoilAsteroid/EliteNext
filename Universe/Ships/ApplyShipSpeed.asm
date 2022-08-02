SpeedMulAxis:           MACRO   speedreg, axis
                        ld      e,speedreg
                        ld      hl,(axis)
                        ld      a,h
                        ClearSignBitA
                        ld      d,a
                        mul     de
                        ld      a,h
                        SignBitOnlyA
                        ld      b,a;ld      c,a
                        ld      h,d;ld      e,d
                        ld      c,0;ld      d,0
                        ENDM


AddSpeedToVert:         MACRO   vertex
                        ld      de,(vertex+1)
                        ld      a,(vertex)
                        ld      l,a                       
                        call    AddBCHtoDELsigned               ; DEL = DEL + BCH
                        ld      a,l
                        ld      (vertex),a
                        ld      (vertex+1),de
                        ENDM

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
