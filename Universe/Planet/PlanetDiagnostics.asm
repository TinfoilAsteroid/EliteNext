        IFDEF BLINEDEBUG
                                call    TestBLINE
                        ENDIF
                        IFDEF TESTMERIDIAN
                                call    TestMeridian
                        ENDIF
                        IFDEF PlanetDebugLocal
                                ZeroA
                                ; x 500, y 50, z 2000: 500/7,50/7 =>71,7 => 199,71 Yes
                                ; radius becomes 24576/2000 = 12 (13 is good enough yes)
                                ld      (P_Bnkxsgn),a
                                ld      (P_Bnkysgn),a
                                ld      (P_Bnkzsgn),a
                                ld      hl, 0
                                ld      (P_Bnkxlo),hl
                                ld      hl,0
                                ld      (P_Bnkylo),hl
                                ld      hl, 1500
                                ld      (P_Bnkzlo),hl
                                ld      hl,$C800
                                ld      bc,6144
                                ld      de,0
                                ld      (P_BnkrotmatNosevX),bc
                                ld      (P_BnkrotmatNosevY),de
                                ld      (P_BnkrotmatNosevZ),hl
                                ld      (P_BnkrotmatRoofvX),de
                                ld      (P_BnkrotmatRoofvY),hl
                                ld      (P_BnkrotmatRoofvZ),bc
                                ld      hl,18432
                                ld      bc,$9800
                                ld      (P_BnkrotmatSidevX),hl
                                ld      (P_BnkrotmatSidevY),de
                                ld      (P_BnkrotmatSidevZ),bc
;                                ld      hl, 230
;                                ld      de,100
;                                ld      c,200
;                                ld      b,$FF
                                call    ProjectPlanet               ;  Project the planet/sun onto the screen, returning the centre's coordinates in K3(1 0) and K4(1 0)
                                call    PlanetCalculateRadius
                                
                                ld      hl, (P_centreX)
                                ld      de,(P_centreY)
                                ld      a,(P_Radius)
                                ld      c,a
                                ld      b,$FF
                                MMUSelectLayer2
                                break
                                call    l2_draw_clipped_circle
                                break
.DebugMeridian1:                xor     a
                                ld      (P_BnkCNT2),a
                                ld      hl,(P_centreX)     :  call    TwosCompToLeadingSign : ld      (P_BnkCx),hl
                                ld      hl,(P_centreY)     :  call    TwosCompToLeadingSign : ld      (P_BnkCy),hl
                                call    CalcNoseRoofArcTanPI        ; CNT2 =  = arctan(-nosev_z_hi / roofv_z_hi) / 4,  if nosev_z_hi >= 0 add PI
                                call    CalcNoseXDivNoseZ  :  call  P_BCmulRadius           : ld      (P_BnkUx),bc
                                call    CalcNoseYDivNoseZ  :  call  P_BCmulRadius           : ld      (P_BnkUy),bc
                                call    CalcRoofXDivRoofZ  :  call  P_BCmulRadius           : ld      (P_BnkVx),bc
                                call    CalcRoofYDivRoofZ  :  call  P_BCmulRadius           : ld      (P_BnkVy),bc
                                break
                                
                                break
                                call    DrawMeridian
                                break
.DebugMeridian2:                xor     a
                                ld      (P_BnkCNT2),a
                                ld      hl,(P_centreX)     :  call    TwosCompToLeadingSign : ld      (P_BnkCx),hl
                                ld      hl,(P_centreY)     :  call    TwosCompToLeadingSign : ld      (P_BnkCy),hl
                                call    CalcNoseRoofArcTanPI        ; CNT2 =  = arctan(-nosev_z_hi / roofv_z_hi) / 4,  if nosev_z_hi >= 0 add PI
                                call    CalcNoseXDivNoseZ  :  call  P_BCmulRadius           : ld      (P_BnkUx),bc
                                call    CalcNoseYDivNoseZ  :  call  P_BCmulRadius           : ld      (P_BnkUy),bc
                                call    CalcSideXDivSideZ  :  call  P_BCmulRadius           : ld      (P_BnkVx),bc
                                call    CalcSideYDivSideZ  :  call  P_BCmulRadius           : ld      (P_BnkVy),bc                                
                                break
                                call    DrawMeridian
                                break
                                break

                                
                        ENDIF
                        