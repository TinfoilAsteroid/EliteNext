 DISPLAY "TODO: calculate STP step based on planet size"
; Note we don't to the planet type check as hitting here its always a planet                        
                        DISPLAY "TODO:set color green"
                        DISPLAY "TODO:draw circle (do we draw solid??)"
                        ld      hl, (P_centreX)
                        ld      de,(P_centreY)
                        ld      a,(P_Radius)
                        ld      c,a
                        ld      b,$FF
                        MMUSelectLayer2
                        call    l2_draw_clipped_circle
                        DISPLAY "TODO: Add check to see if on screen rather than checkign clipped Circle"
                        ;ret     c                           ; circle failure means exit
                        DISPLAY "DONE: REmoved check for Planet Radius high as its already done win calculate radius"
                        ;ReturnIfMemNotZero    P_RadiusHigh   ; if planet raidus < 256 draw meridians or craters
.DrawFeatures:          ;ld      a,(P_RadiusHigh)
                        ;and     a
                        ;ret     nz
                        DISPLAY "TODO: Need logic to generate Planet Type"
.DetermineFeature:      ld      a,(P_BnKShipType)              
                        cp      PlanetTypeMeridian
                        jp      nz,DrawPlanetCrater
DrawPlanetMeridian:     ld      a,(P_Radius)                 ; we only pull low byte as that is all we are interested in
.MinSizeCheck:          ReturnIfALTNusng PlanetMinRadius
                        ld      hl,(P_centreX)     :  call    TwosCompToLeadingSign : ld      (P_BnKCx),hl
                        ld      hl,(P_centreY)     :  call    TwosCompToLeadingSign : ld      (P_BnKCy),hl
                        call    CalcNoseRoofArcTanPI        ; CNT2 =  = arctan(-nosev_z_hi / roofv_z_hi) / 4,  if nosev_z_hi >= 0 add PI
                        call    CalcNoseXDivNoseZ  :  call  P_BCmulRadius           : ld      (P_BnKUx),bc
                        call    CalcNoseYDivNoseZ  :  call  P_BCmulRadius           : ld      (P_BnKUy),bc
                        call    CalcRoofXDivRoofZ  :  call  P_BCmulRadius           : ld      (P_BnKVx),bc
                        call    CalcRoofYDivRoofZ  :  call  P_BCmulRadius           : ld      (P_BnKVy),bc
                        DISPLAY "TODO: PCNT2Debug"
                        xor     a
                        ld      (P_BnKCNT2),a
                        call    DrawMeridian                ;--- Drawn first Meridian                        
                        DISPLAY "TODO: Debug whilst sorting meridain"
                        ret
;--- Start Second Meridian             
                        ld      a,(P_BnKrotmatNosevZ)       ; Set P = -nosev_z_hi
                        xor     SignOnly8Bit                ; .
                        ld      (varP),a                    ; .
                        call    CalcNoseSideArcTanPI        ; CNT2 =  = arctan(-nosev_z_hi / side_z_hi) / 4,  if nosev_z_hi >= 0 add PI
                        ld      hl,(P_centreX)     :  call    TwosCompToLeadingSign : ld      (P_BnKCx),hl
                        ld      hl,(P_centreY)     :  call    TwosCompToLeadingSign : ld      (P_BnKCy),hl
                        call    CalcNoseRoofArcTanPI        ; CNT2 =  = arctan(-nosev_z_hi / roofv_z_hi) / 4,  if nosev_z_hi >= 0 add PI
                        call    CalcNoseXDivNoseZ  :  call  P_BCmulRadius           : ld      (P_BnKUx),bc
                        call    CalcNoseYDivNoseZ  :  call  P_BCmulRadius           : ld      (P_BnKUy),bc
                        call    CalcSideXDivSideZ  :  call  P_BCmulRadius           : ld      (P_BnKVx),bc
                        call    CalcSideYDivSideZ  :  call  P_BCmulRadius           : ld      (P_BnKVy),bc                                
                        DISPLAY "TODO: PCNT2Debug"
                        xor     a
                        ld      (P_BnKCNT2),a
                        jp      DrawMeridian
                        ; implicit ret
DrawPlanetCrater:       ld      a,(P_BnKrotmatRoofvZ+1)      ; a= roofz hi
                        and     a                           ; if its negative, crater is on far size of planet
                        ret     m                           ; .
                        call    Cacl222MulRoofXDivRoofZ     ;  (Y A P) = 222 * roofv_x / z to give the x-coordinate of the crater offset 
                        call    CalcCraterCenterX           ;  222 * roofv_x / z + x-coordinate of planet centre
                        call    Cacl222MulRoofYDivRoofZ     ;  (Y A P) = 222 * roofv_y / z to give the x-coordinate of the crater offset 
                        call    CalcCraterCenterY           ;  222 * roofv_y / z - y-coordinate of planet centre
                        call    CalcNoseXDivNoseZ           ;  (Y A) = nosev_x / z
                        call    CalcNoseYDivNoseZ           ; (XX16+1 K2+1) = nosev_y / z
                        call    CalcSideYDivSideZ           ;  (Y A) = sidev_y / z
                        srl     a                           ; Set (XX16+3 K2+3) = (Y A) / 2
                        ld      (varK2+3),a                 ; .
                        ld      a,(regY)                    ; (which is also in b to optimise later)
                        ld      (P_XX16+3),a                 ;
                        ld      a,64                        ; Set TGT = 64, so we draw a full ellipse in the call to PLS22 below
                        ld      (P_BnKTGT),a
                        ZeroA
                        ld      (P_BnKCNT2),a                ; Set CNT2 = 0 as we are drawing a full ellipse, so we don't need to apply an offset
                        jp      DrawElipse
