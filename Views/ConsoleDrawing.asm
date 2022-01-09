; bc = start position, d = length, e = colour
Draw3LineBar:           ld      e,16
                        push    bc,,de
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        pop     bc,,de
                        dec     b
                        push    bc,,de
                        ld      e,20
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        pop     bc,,de
                        dec     b    
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        ret
                        
DrawColourCodedBar:     ld      e,124
                        cp      40
                        jr      nc,DrawColourEBar
                        ld      e,84
                        cp      30
                        jr      nc,DrawColourEBar
                        ld      e,216
                        cp      20
                        ld      e,236
                        cp      10
                        jr      nc,DrawColourEBar
                        ld      e,225
                        cp      5
                        jr      nc,DrawColourEBar
                        ld      e,224
DrawColourEBar:         push    bc,,de
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        pop     bc,,de
                        dec     b
                        push    bc,,de
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        pop     bc,,de
                        dec     b    
                        MMUSelectLayer2
                        call    l2_draw_horz_line
                        ret
                    
                        ; no ret needed as jp handles it


        
        
UpdateConsole:          ld      a,(DELTA)
                        cp      0                           ; don't draw if there is nothing to draw
                        jr      z,.UpdateRoll   
                        ld      bc,SpeedoStart
                        ld      hl,SpeedoMapping
                        add     hl,a
                        ld      d,(hl)
                        call    Draw3LineBar
.UpdateRoll:            ld      a,(ALP1)
                        cp      0
                        jp      z,.UpdatePitch
                        ld      hl,RollMiddle
                        ld      a,(ALP2)
                        cp      0
                        jp     z,.PosRoll
.NegRoll:               ld      d,0
                        ld      a,(ALP1)
                        sla     a
                        ld      e,a
                        or      a
                        sbc     hl,de
                        ld      bc,hl
                        ld      a,DialMiddleXPos
                        sub     c
                        ld      d,a
                        ld      e,$FF
                        call    Draw3LineBar
                        jr      .UpdatePitch
.PosRoll:               ld      bc,RollMiddle
                        ld      a,(ALP1)
                        sla     a
                        ld      d,a
                        ld      e,$FF
                        call    Draw3LineBar
.UpdatePitch:           ld      a,(BET1)
                        cp      0
                        jp      z,.Fuel
                        ld      hl,PitchMiddle
                        ld      a,(BET2)
                        cp      0
                        jp      z,.PosPitch
.NegPitch:              ld      d,0
                        ld      a,(BET1)
                        sla     a
                        ld      e,a
                        or      a
                        sbc     hl,de
                        ld      bc,hl
                        ld      a,DialMiddleXPos
                        sub     c
                        ld      d,a
                        ld      e,$FF
                        call    Draw3LineBar
                        jp      .Fuel
.PosPitch:              ld      bc,PitchMiddle
                        ld      a,(BET1)
                        sla     a
                        ld      d,a
                        ld      e,$FF
                        call    Draw3LineBar
.Fuel:                  ld      a,(Fuel)
                        srl     a               ; divide by 4 to get range on screen
                        ld      hl,FuelMapping
                        add     hl,a
                        ld      a,(hl)
                        ld      bc,FuelStart
                        ld      d,a
                        call    DrawColourCodedBar                        
.ForeShield:            ld      a,(ForeShield)
                        srl     a
                        srl     a
                        srl     a               
                        ld      bc,FShieldStart
                        call    DrawColourCodedBar                        
.AftShield:             ld      a,(AftShield)
                        srl     a
                        srl     a
                        srl     a               
                        ld      bc,AShieldStart
                        ld      d,a
                        call    DrawColourCodedBar  ;ld		(ForeShield),a
.EnergyBars:            ld      a,(PlayerEnergy)
                        srl     a                   ; energy = energy / 2 so 31 per bar
                        CallIfALTNusng  31 + 1,.Draw1EnergyBar
                        CallIfALTNusng  (31*2) + 1,.Draw2EnergyBars
                        CallIfALTNusng  (31*3) + 1,.Draw3EnergyBars
.Draw4EnergyBars:       ld      e,24
                        sub     (32*3)
                        ld      d,a
                        ld      bc,EnergyBar4Start
                        call    DrawColourEBar 
                        ld      d,31
                        ld      e,24
                        ld      bc,EnergyBar3Start
                        call    DrawColourEBar                        
                        ld      d,31
                        ld      e,24
                        ld      bc,EnergyBar2Start
                        call    DrawColourEBar                        
                        ld      d,31
                        ld      e,24
                        ld      bc,EnergyBar1Start
                        call    DrawColourEBar                        
                        jp      .DoneEnergyBars
.Draw1EnergyBar:        ld      e,224
                        ld      d,a
                        ld      bc,EnergyBar1Start
                        call    DrawColourEBar                        
                        jp      .DoneEnergyBars
.Draw2EnergyBars:       ld      e,216
                        sub     31
                        ld      d,a
                        ld      bc,EnergyBar2Start
                        call    DrawColourEBar                        
                        ld      d,31
                        ld      e,216
                        ld      bc,EnergyBar1Start
                        call    DrawColourEBar                        
                        jp      .DoneEnergyBars
.Draw3EnergyBars:       ld      e,20
                        sub     31*2
                        ld      d,a
                        ld      e,20
                        ld      bc,EnergyBar3Start
                        call    DrawColourEBar                        
                        ld      d,31
                        ld      e,20
                        ld      bc,EnergyBar2Start
                        call    DrawColourEBar                        
                        ld      d,31
                        ld      e,20
                        ld      bc,EnergyBar1Start
                        call    DrawColourEBar                        
.DoneEnergyBars:                                

                        
                        
; NEED ENERGY BAR
;PlayerEnergy                      
; BNEED LASER temp
; NEED CABIN TEMP
;NEED ALTITUDE   
; Draw compas - if in range draw station, else do planet
.DoneConsole:           ret
    
ScannerX                equ 128
ScannerY                equ 171 
ScannerBottom           equ 190
ScannerTypeMissle       equ 2
ScannerXRangeOffset     equ $35
ScannerCenter           equ 127

ScannerDefault          equ 0
ScannerMissile          equ 2
ScannerStation          equ 4
ScannerEnemy            equ 6

ScannerColourTable:     DB  16,28,144,252,18,31,128,224

GetShipColor:           MACRO                   
                        ld      a,(ShipTypeAddr)
                        sla     a                            ; as its byte pairs * 2
                        ld      hl,ScannerColourTable
                        add     hl,a
                        ld      a,(hl)
                        ENDM
GetShipColorBright:     MACRO                   
                        ld      a,(ShipTypeAddr)
                        sla     a                            ; as its byte pairs * 2
                        inc     a
                        ld      hl,ScannerColourTable
                        add     hl,a
                        ld      a,(hl)
                        ENDM
           
UpdateScannerSun:       ld      hl,(SBnKzhi)
                        ld      a,h
                        and     SignMask8Bit
                        ld      h,a
                        ld      a,(SBnKzlo)
                        ShiftHLRight1
                        rr      a
                        ShiftHLRight1
                        rr      a
                        ShiftHLRight1
                        rr      a
                        ShiftHLRight1
                        rr      a
                        ld      h,l
                        ld      l,a

                        ld      de,(SBnKxhi)
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a                        
                        ShiftDERight1
                        rr      a
                        ShiftDERight1
                        rr      a
                        ShiftDERight1
                        rr      a
                        ShiftDERight1
                        rr      a
                        ld      d,e
                        ld      e,a

                        ld      bc,(SBnKyhi)
                        ld      a,b
                        and     SignMask8Bit
                        ld      b,a
                        ShiftBCRight1
                        rr      a
                        ShiftBCRight1
                        rr      a
                        ShiftBCRight1
                        rr      a
                        ShiftBCRight1
                        rr      a
                        ld      b,c
                        ld      c,a

;                        ld      a,h
;                        or      d
;                        or      b
;                        and     %11000000
;                        ret     nz                          ; if distance Hi > 64 on any ccord- off screen
.MakeX2Compliment:      ld      a,(SBnKxsgn)
                        bit     7,a
                        jr      z,.absXHi
                        NegD                                
.absXHi:                ld      a,d
                        add     ScannerX           
                        ld      ixh,a                       ; store adjusted X in ixh
.ProcessZCoord:         srl     h
                        srl     h
.MakeZ2Compliment:      ld      a,(SBnKzsgn)
                        bit     7,a
                        jr      z,.absZHi
                        NegH
.absZHi:                ld      a,ScannerY
                        sub     h
                        ld      iyh,a                       ; make iyh adjusted Z = row on screen
.ProcessStickLength:    srl     b                           ; divide b by 2
                        jr      nz,.StickHasLength
.Stick0Length:          ld      a,iyh                       ; abs stick end is row - length   
                        ld      iyl,a    
                        ld      a,ixl
                        ld      a,L2SunScannerBright
                        MMUSelectLayer2  
                        jp      .NoStick
.StickHasLength:        ld      a,(UBnKysgn)                ; if b  =  0 then no line
                        bit     7,a
                        jr      z,.absYHi
                        NegB
.absYHi:                ld      a,iyh
.SetStickPos:           sub     b
                        JumpIfALTNusng ScannerBottom, .StickOnScreen
                        ld      a,ScannerBottom
.StickOnScreen:         ld      iyl,a                       ; iyh is again stick end point   
                        ld      b,iyh                       ; from row
                        ld      c,ixh                       ; from col
                        ld      d,iyl                       ; to row
                        ld      e,L2SunScanner
                        push    hl
                        MMUSelectLayer2  
                        call    l2_draw_vert_line_to
                        pop     hl
                        inc     hl
                        ld      a,(hl)
.NoStick:               ld      b,iyl                       ; row
                        ld      c,ixh                       ; col
                        push    af
                        call    l2_plot_pixel
                        pop     af
                        ld      b,iyl
                        ld      c,ixh
                        inc     c
                        call    l2_plot_pixel
                        ret

           
                        
; This will go though all the universe ship data banks and plot, for now we will just work on one bank
UpdateScannerShip:      
                        ld      a,(UBnKexplDsp)             ; if bit 4 is clear then ship should not be drawn
                        bit     4,a                         ; .
                        ;DEBUG ret     z                           ; .
                        ld      a,(ShipTypeAddr)            ; if its a planet or sun, do not display
                        bit     7,a
                        ret     nz
; DEBUG Add in station types later                       
.NotMissile:            ld      hl,(UBnKzlo)
                        ld      de,(UBnKxlo)
                        ld      bc,(UBnKylo)
                        ld      a,h
                        or      d
                        or      b
                        and     %11000000
                        ret     nz                          ; if distance Hi > 64 on any ccord- off screen
.MakeX2Compliment:      ld      a,(UBnKxsgn)
                        bit     7,a
                        jr      z,.absXHi
                        NegD                                
.absXHi:                ld      a,d
                        add     ScannerX           
                        ld      ixh,a                       ; store adjusted X in ixh
.ProcessZCoord:         srl     h
                        srl     h
.MakeZ2Compliment:      ld      a,(UBnKzsgn)
                        bit     7,a
                        jr      z,.absZHi
                        NegH
.absZHi:                ld      a,ScannerY
                        sub     h
                        ld      iyh,a                       ; make iyh adjusted Z = row on screen
.ProcessStickLength:    srl     b                           ; divide b by 2
                        jr      nz,.StickHasLength
.Stick0Length:          ld      a,iyh                       ; abs stick end is row - length   
                        ld      iyl,a    
                        ld      a,ixl
                        GetShipColorBright
                        MMUSelectLayer2  
                        jp      .NoStick
.StickHasLength:        ld      a,(UBnKysgn)                ; if b  =  0 then no line
                        bit     7,a
                        jr      z,.absYHi
                        NegB
.absYHi:                ld      a,iyh
.SetStickPos:           sub     b
                        JumpIfALTNusng ScannerBottom, .StickOnScreen
                        ld      a,ScannerBottom
.StickOnScreen:         ld      iyl,a                       ; iyh is again stick end point   
                        GetShipColor
                        ld      ixl,a
                        ld      b,iyh                       ; from row
                        ld      c,ixh                       ; from col
                        ld      d,iyl                       ; to row
                        ld      e,ixl                       ; colur will only be green or yellow for now
                        push    hl
                        MMUSelectLayer2  
                        call    l2_draw_vert_line_to
                        pop     hl
                        inc     hl
                        ld      a,(hl)
.NoStick:               ld      b,iyl                       ; row
                        ld      c,ixh                       ; col
                        push    af
                        call    l2_plot_pixel
                        pop     af
                        ld      b,iyl
                        ld      c,ixh
                        inc     c
                        call    l2_plot_pixel
                        ret
                        
