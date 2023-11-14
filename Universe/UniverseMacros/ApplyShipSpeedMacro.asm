

;AddSpeedToVert:         MACRO   vertex
;                        ld      hl,(vertex)
;                        ld      a,(vertex+2)
;                        ld      b,a
;                        call    AHLEquBHLaddCDE
;                        ld      (vertex),hl
;                        ld      (vertex+2),a
;                        ENDM
                        

; ---------------------------------------------------------------------------------------------------------------------------------    

ApplyShipSpeedMacro     MACRO   p?
p?_ApplyShipSpeed:ld      a,(p?_BnkSpeed)                   ; get speed * 4
                        cp      0
                        ret     z
                        sla     a
                        sla     a
                        ld      iyl,a                           ; save pre calculated speed
.ApplyToX:              SpeedMulAxis    a, p?_BnkrotmatNosevX     ; e =  ABS (nosev x hi) c = sign
.AddSpeedToX:           AddSpeedToVert p?_Bnkxlo
.ApplyToY:              SpeedMulAxis    iyl, p?_BnkrotmatNosevY     
.AddSpeedToY:           AddSpeedToVert p?_Bnkylo
.ApplyToZ:              SpeedMulAxis    iyl, p?_BnkrotmatNosevZ
.AddSpeedToZ:           AddSpeedToVert p?_Bnkzlo
                        ret
                        ENDM
