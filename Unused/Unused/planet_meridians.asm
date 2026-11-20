; Not in the build: the planet meridian / crater drawing from Universe/Planet/planet_data.asm (PlanetDraw and all it
; called), unreachable since PLANETSARESOLID (PlanetUpdateAndRender draws a filled circle and a rim), and its
; BLINEDEBUG / TESTMERIDIAN test code. It drew its lines with l2_draw_any_line (Layer2Graphics/l2_draw_any_line.asm)

;- DEBUG CODE
                        IFDEF BLINEDEBUG
TestBLINE:              ld  a,$FF
                        ld  (P_BnKFlag),a
                        ld  a,5
                        ld  (P_BnKSTP),a
                        ZeroA
                        ld  (P_BnKCNT),a
.DebugLoop:             ld  ix,(DataPointer)
                        ld  a,(ix+0)
                        ld  l,a
                        ld  a,(ix+1)
                        ld  h,a
                        ld  (P_NewXPos),hl
                        ld  a,(ix+2)
                        ld  l,a
                        ld  a,(ix+3)
                        ld  h,a
                        ld  (P_NewYPos),hl
                        call    BLINE
                        ld      a,(DataPointCounter)
                        inc     a
                        ld      hl,DataPointSize
                        cp      (hl)
                        ret     z
                        ld      (DataPointCounter),a
                        ld      hl,(DataPointer)
                        ld      a,4
                        add     hl,a
                        ld      (DataPointer),hl
                        jp      .DebugLoop

DataPoints:             DW  10,10, 20,60, 30,20, 40,50, 100,90, 150, 30
DataPointSize           DB  6
DataPointCounter        DB  0
DataPointer:            DW  DataPoints
                        ENDIF

                        IFDEF TESTMERIDIAN
TestMeridian:           ld      hl,20        ; 20
                        ld      (P_BnKVx),hl ; vx
                        ld      hl,20        ; 20
                        ld      (P_BnKVy),hl ; vy
                        ld      hl,20        ; 20
                        ld      (P_BnKUx),hl ; ux
                        ld      hl, $8014    ; -20 
                        ld      (P_BnKUy),hl ; uy
                        ld      de,120       ; 120
                        ld      (P_BnKCx),de ; cx
                        ld      de,69        ; 69
                        ld      (P_BnKCy),de ; cy
                        call    DrawMeridian
                        ENDIF                        

; In  flight ship data tables
; In  flight ship data tables
; In  flight ship data tables
; There can be upto &12 objects in flight.
CalcCraterCenterX:      ld      l,a                         ; set HL to Y A
                        ld      a,(regY)                    ;
                        ld      h,a                         ;
                        ld      de,(varK3)                  ; de = K3 [ 1 0 ]
                        ClearCarryFlag
                        adc     hl,de
                        ld      (varK3),hl                  ; K3[1 0] = hl + de
                        ret

; K4(1 0) = (Y A) - K4(1 0) = 222 * roofv_x / z + x-coordinate of planet centre
CalcCraterCenterY:      ld      l,a                         ; set HL to Y A
                        ld      a,(regY)                    ;
                        ld      h,a                         ;
                        ld      de,(varK4)                  ; de = K4 [ 1 0 ]
                        ClearCarryFlag
                        sbc     hl,de
                        ld      (varK4),hl                  ; K4[1 0] = hl + de
                        ret

TwosCompToLeadingSign:  bit     7,h
                        ret     z
                        macronegate16hl
                        ld      a,h
                        or      $80
                        ld      h,a
                        ret
                        
LeadingSignToTwosComp:  bit     7,h
                        ret     z
                        ld      a,h
                        and     $7F
                        ld      h,a
                        macronegate16hl
                        ret

;-- bc = bc * P_radius where bc = S.Fraction ,e.g nosex/nosey
P_BCmulRadius:          ld      a,(P_Radius)                ; we probably don't have radius already
P_BCmulRadiusInA:       ld      d,a                         ; d = radius already in a
                        ld      e,c                         ; e = c (as we only hold 0.8 in bc, i.e. fractional +/- > 0)
                        mul     de                          ; mulitply raidus by c which will be fractional  generating a 8.X value)
                        ld      c,d                         ; we only want the whole number, preserving sign in b
                        ret

   ; DEFINE  PlanetDebugLocal 1
PlanetDraw:             IFDEF BLINEDEBUG
                                call    TestBLINE
                        ENDIF
                        IFDEF TESTMERIDIAN
                                call    TestMeridian
                        ENDIF
                        IFDEF PlanetDebugLocal
                                ZeroA
                                ; x 500, y 50, z 2000: 500/7,50/7 =>71,7 => 199,71 Yes
                                ; radius becomes 24576/2000 = 12 (13 is good enough yes)
                                ld      (P_BnKxsgn),a
                                ld      (P_BnKysgn),a
                                ld      (P_BnKzsgn),a
                                ld      hl, 0
                                ld      (P_BnKxlo),hl
                                ld      hl,0
                                ld      (P_BnKylo),hl
                                ld      hl, 1500
                                ld      (P_BnKzlo),hl
                                ld      hl,$C800
                                ld      bc,6144
                                ld      de,0
                                ld      (P_BnKrotmatNosevX),bc
                                ld      (P_BnKrotmatNosevY),de
                                ld      (P_BnKrotmatNosevZ),hl
                                ld      (P_BnKrotmatRoofvX),de
                                ld      (P_BnKrotmatRoofvY),hl
                                ld      (P_BnKrotmatRoofvZ),bc
                                ld      hl,18432
                                ld      bc,$9800
                                ld      (P_BnKrotmatSidevX),hl
                                ld      (P_BnKrotmatSidevY),de
                                ld      (P_BnKrotmatSidevZ),bc
                                call    ProjectPlanet               ;  Project the planet/sun onto the screen, returning the centre's coordinates in K3(1 0) and K4(1 0)
                                call    PlanetCalculateRadius
                                
                                ld      hl, (P_centreX)
                                ld      de,(P_centreY)
                                ld      a,(P_Radius)
                                ld      c,a
                                ld      b,$FF
                                MMUSelectLayer2
                                call    l2_draw_clipped_circle
.DebugMeridian1:                xor     a
                                ld      (P_BnKCNT2),a
                                ld      hl,(P_centreX)     :  call    TwosCompToLeadingSign : ld      (P_BnKCx),hl
                                ld      hl,(P_centreY)     :  call    TwosCompToLeadingSign : ld      (P_BnKCy),hl
                                call    CalcNoseRoofArcTanPI        ; CNT2 =  = arctan(-nosev_z_hi / roofv_z_hi) / 4,  if nosev_z_hi >= 0 add PI
                                call    CalcNoseXDivNoseZ  :  call  P_BCmulRadius           : ld      (P_BnKUx),bc
                                call    CalcNoseYDivNoseZ  :  call  P_BCmulRadius           : ld      (P_BnKUy),bc
                                call    CalcRoofXDivRoofZ  :  call  P_BCmulRadius           : ld      (P_BnKVx),bc
                                call    CalcRoofYDivRoofZ  :  call  P_BCmulRadius           : ld      (P_BnKVy),bc
                               
                                call    DrawMeridian

.DebugMeridian2:                xor     a
                                ld      (P_BnKCNT2),a
                                ld      hl,(P_centreX)     :  call    TwosCompToLeadingSign : ld      (P_BnKCx),hl
                                ld      hl,(P_centreY)     :  call    TwosCompToLeadingSign : ld      (P_BnKCy),hl
                                call    CalcNoseRoofArcTanPI        ; CNT2 =  = arctan(-nosev_z_hi / roofv_z_hi) / 4,  if nosev_z_hi >= 0 add PI
                                call    CalcNoseXDivNoseZ  :  call  P_BCmulRadius           : ld      (P_BnKUx),bc
                                call    CalcNoseYDivNoseZ  :  call  P_BCmulRadius           : ld      (P_BnKUy),bc
                                call    CalcSideXDivSideZ  :  call  P_BCmulRadius           : ld      (P_BnKVx),bc
                                call    CalcSideYDivSideZ  :  call  P_BCmulRadius           : ld      (P_BnKVy),bc                                

                                call    DrawMeridian


                        ENDIF
                        ld      a,(P_BnKzsgn)                ; a = z sign of position
.ElimiateBehind:        and     a
                        ret     m                           ; if its negative then behind so exit
.TooFarAway:            ReturnIfAGTEusng   48               ; if sign (high byte 2) > 48 then too far away to render
                        ld      hl, P_BnKzhi                 ; if |P_BnKzsgn| or P_BnKzsgn are both 0 then the planet is too close so return
                        or      (hl)                        ; .
                        ret     z                           ; .
;                       loads P_centreX and Y with planet on screen centre
.Project                call    ProjectPlanet               ;  Project the planet/sun onto the screen, returning the centre's coordinates in K3(1 0) and K4(1 0)
                        ret     c                           ; If the C flag is set by PROJ then the planet/sun is  not visible on-screen, so return
.CalcRadius:            call    PlanetCalculateRadius
                IFDEF   PLANETSARESOLID
                        DISPLAY "ASSMEBLING WITH SOLID PLANETS"
                        ld      hl,(P_centreX)
                        ld      de,(P_centreY)
                        ld      a,(P_Radius)
                        ld      c,a
                        ld      b,$CF
                        MMUSelectLayer2
                        call    l2_draw_clipped_circle_filled
                        ret
                         
                ELSE

; Note we don't to the planet type check as hitting here its always a planet                        
                        ld      hl, (P_centreX)
                        ld      de,(P_centreY)
                        ld      a,(P_Radius)
                        ld      c,a
                        ld      b,$FF
                        MMUSelectLayer2
                        call    l2_draw_clipped_circle
                        DISPLAY "DONE: REmoved check for Planet Radius high as its already done win calculate radius"
.DrawFeatures:          ;ld      a,(P_RadiusHigh)
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
                        xor     a
                        ld      (P_BnKCNT2),a
                        call    DrawMeridian                ;--- Drawn first Meridian                        
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
                ENDIF


;PLS2                                                   Test
; K[10] = radius                                        $0000?
; k3[10], K4[10] X, y pixel of centre
; (XX16, K2), (XX16+1,K2+1) u_x , u_y                   $1F80  $FE80    
; (XX16+2, K2+2), (XX16+3,K2+3) z_x , z_y               $0000  $0000
; TGT - target segment count                            $00
; CNT2 - starting segment                               $0D
; Now uses (Word) P_BnKCx, Cy, (Byte) Ux, Uy, Vx, Vy
DrawMeridian:           ld      a,63                        ; Set TGT = 31, so we only draw half an ellipse
                        ld      (P_BnKTGT),a                ; and fall into DrawElipse
                        ld      a,1
                        ld      (P_BnKSTP),a
;PLS22
; Set counter to 0 and reset flags--------------------------
DrawElipse:
.Initialise:            ZeroA
                        ld      (P_BnKCNT),a                ; Set CNT = 0
                        ld      (P_BnKSinCNT2Sign),a
                        ld      (P_BnKCosCNT2Sign),a
                        ld      (P_BnKUxCosSign),a          ; for debugging later we will just use the cos and sin signs above
                        ld      (P_BnKUyCosSign),a          ; .
                        ld      (P_BnKUxUyCosSign),a        ; .
                        ld      (P_BnKVxSinSign),a          ; .
                        ld      (P_BnKVySinSign),a          ; .
                        ld      (P_BnKVxVySinSign),a        ; .
                        dec     a
                        ld      (P_BnKFlag),a               ; Set FLAG = &FF to reset the ball line heap in the call to the BLINE routine below
.PLL4:                  ;break
.GetSinAngle:           ld      a,(P_BnKCNT2)               ; Set angle = CNT2 mod 32 (was regX)
                        and     31                          ; 
; Caclulate Sin(CNT2)---------------------------------------;                        
                        ld      (P_BnKAngle),a              ; save for debugging So P_BnKAngle is the starting segment, reduced to the range 0 to 32, so as there are 64 segments in the circle, this
.CalculateSinCNT2:      call    LookupSineA                 ; Set Q = sin(angle)  = sin(CNT2 mod 32) = |sin(CNT2)|
                        ld      c,a                         ; C = Q, for AequAmulCdiv256u
                        ld      (P_BnKSinCNT2),a            ; for debugging
; calculate BnKVxSin = VX*Sin(CNT2)-------------------------;
.GetVxSin:              ld      a,(P_BnKVx)                 ; Set A = K2+2 = |v_x|
                        AequAmulCdiv256u                    ; R = A * Q / 256 = |v_x| * |sin(CNT2)|
                        ld      (P_BnKVxSin),a              ; now varR = vx*sin(CNT2)
; calculate BnkVySin = Vy*Sin(CNT2)-------------------------;
.GetVySin:              ld      a,(P_BnKVy)                 ; Set A = K2+3 = |v_y|
                        AequAmulCdiv256u                    ; Set varK = A * Q / 256 = |v_y| * |sin(CNT2)|
                        ld      (P_BnKVySin),a              ; 
; Now work sign of vx and vy * sin -------------------------; In 6502 below, in z80 C flag is reversed
.CalcVxVyMulSinSign:    ld      a,(P_BnKCNT2)               ; If CNT2 >= 33 then this sets the C flag, else clear : C is clear if the segment starts in the first half of the circle, 0 to 180 degrees
                        cp      33                          ;                                                       C is set if the segment starts in the second half of the circle, 180 to 360 degrees
                        jp      c,.NoSignChangeSin          ; in z80 c means < 33 so we don't do sign flip
                        ld      a,$80
                        ld      (P_BnKSinCNT2Sign),a        ; save sign of sin CNT2 for debugging
                        ld      (P_BnKVxSinSign),a          ; |v_x| * |sin(CNT2)|
                        ld      (P_BnKVySinSign),a          ; |v_y| * |sin(CNT2)|
                        ld      (P_BnKVxVySinSign),a        ; |v_x/y| * |sin(CNT2)|
.NoSignChangeSin:      
; calculate cos(CNT2)---------------------------------------;
.CalculateCosCNT2:      ld      a,(P_BnKCNT2)               ; Set X = (CNT2 + 16) mod 32
                        add     a, 16                       ; .
                        and     31                          ; .
                        ld      (P_BnKAngle),a              ; save for debugging So we can use X as a lookup index into the SNE table to get the cosine (as there are 16 segments in a  quarter-circle)
                        call    LookupSineA                 ; Set Q = sin(X)  = sin((CNT2 + 16) mod 32) = |cos(CNT2)|
                        ld      c,a                         ; C = Q, for AequAmulCdiv256u
                        ld      (P_BnKCosCNT2),a            ; for debugging                        
; calculate Uy*Cos(CNT2)------------------------------------;
.GetUyCos:              ld      a,(P_BnKUy)                 ; Set A = K2+1 = |u_y|
                        AequAmulCdiv256u                    ; Set P_BnKUyCos(wasK+2) = A * Q / 256 = |u_y| * |cos(CNT2)|
                        ld      (P_BnKUyCos),a              ; .
; calculate Ux*Cos(CNT2)------------------------------------;
.GetUxCos:              ld      a,(P_BnKUx)                 ; Set A = K2 = |u_x|
                        AequAmulCdiv256u                    ; Set P_BnKUxCos(wasP) = A * Q / 256 = |u_x| * |cos(CNT2)| also sets the C flag, so in the following, ADC #15 adds 16 rather than 15 (use use non carry add)
                        ld      (P_BnKUxCos),a              ; .
; now work out sign for cos CNT2----------------------------;
.CalcUxUyMulCosSign:    ld      a,(P_BnKCNT2)               ; If (CNT2 + 16) mod 64 >= 33 then this sets the C flag,
                        add     a,16                        ; otherwise it's clear, so this means that:
                        and     63                          ; .
                        cp      33                          ; c is clear if the segment is 0 to 90 or 270 to 360, we need 
                        jp      c,.NoSignChangeCos          ; in z80 c means < 33 so we don't do sign flip
                        ld      a,$80
                        ld      (P_BnKCosCNT2Sign),a        ; save sign of sin CNT2 for debugging
                        ld      (P_BnKUxCosSign),a          ; add XX16+5 as the high byte to give us (XX16+5 K) = |v_y| * sin(CNT2) &  (XX16+5 R) = |v_x| * sin(CNT2)
                        ld      (P_BnKUyCosSign),a          ; add XX16+5 as the high byte to give us (XX16+5 K) = |v_y| * sin(CNT2) &  (XX16+5 R) = |v_x| * sin(CNT2)
                        ld      (P_BnKUxUyCosSign),a        ; add XX16+5 as the high byte to give us (XX16+5 K) = |v_y| * sin(CNT2) &  (XX16+5 R) = |v_x| * sin(CNT2)
.NoSignChangeCos:      
; calculate Ux*cos + vx*sin---------------------------------;
.CalcSignOfVxMulSin:    ld      a,(P_BnKSinCNT2Sign)        ; Set S = the sign of XX16+2 * XX16+5
                        ld      hl,P_BnKVxSign              ; = the sign of v_x * XX16+5
                        xor     (hl)                        ; .
                        and     $80                         ; so a is only sign bit now
                        ld      (P_BnKVxSinSign),a          ; P_BnKVxSin (was SR) = v_x * sin(CNT2)
.CalcSignOfUxMulCos:    ld      a,(P_BnKCosCNT2Sign)        ; Set A = the sign of XX16 * XX16+4
                        ld      hl,P_BnKUxSign              ; (i.e. sign of u_x * XX16_+4
                        xor     (hl)                        ; so (A P) = u_x * cos(CNT2)
                        and     $80                         ; so a is only sign bit now
                        ld      (P_BnKUxCosSign),a          ; now P_BnKUxCos
.AddUxCosVxSin:         ld      hl,(P_BnKUxCos)             ; Set (A X) = (A P) + (S R)  = u_x * cos(CNT2) + v_x * sin(CNT2) we could work with a but its simpler to jsut reload hl
                        ld      de,(P_BnKVxSin)             ; as R S are next to each other can load as one
                        call    AddDEtoHLSigned             ; hl = u_x * cos(CNT2) + v_x * sin(CNT2) format S15 not 2'sc
.DoneAddUxCosVxSin:     ld      (P_BnKUxCosAddVxSin),hl     ; 
; calculate -(Uy*cos - vy*sin)------------------------------;
.CalcSignOfVyMulSin:    ld      a,(P_BnKSinCNT2Sign)        ; Set S = the sign of XX16+2 * XX16+5
                        ld      hl,P_BnKVySign              ; = the sign of v_x * XX16+5
                        xor     (hl)                        ; .
                        and     $80                         ; so a is only sign bit now                        
                        ld      (P_BnKVySinSign),a          ; P_BnKVxSin (was SR) = v_x * sin(CNT2)
.CalcSignOfUyMulCos:    ld      a,(P_BnKCosCNT2Sign)        ; Set A = the sign of XX16 * XX16+4
                        ld      hl,P_BnKUySign              ; (i.e. sign of u_x * XX16_+4
                        xor     (hl)                        ; so (A P) = u_x * cos(CNT2)
                        and     $80                         ; so a is only sign bit now                        
                        ld      (P_BnKUyCosSign),a          ; now P_BnKUxCos
.AddUyCosVySin:         ld      hl,(P_BnKUyCos)             ; Set (A X) = (A P) + (S R)  = u_x * cos(CNT2) + v_x * sin(CNT2) we could work with a but its simpler to jsut reload hl
                        ld      de,(P_BnKVySin)             ; as R S are next to each other can load as one
                        call    AddDEtoHLSigned             ; hl = u_x * cos(CNT2) + v_x * sin(CNT2) format S15 not 2'sc
.DoneAddUyCosVySin:     ld      (P_BnKUyCosSubVySin),hl     ; 
; Calculate NewXPos = Centrey - Uy cos - vy cos (which we still have in hl)
.PL42:
.CalcNewYPos:           ld      de, (P_BnKCy)               ; Hl is already in HL so de =  Cx
                        ex      hl,de                       ; swap round so we can do hl + de where de is already negated to effect a subtract (probabyl don't don't need this)
                        ld      a,d
                        xor     $80                         ; now flip bit as its a subtract not add
                        ld      d,a
                        call    ScaleDE75pct
                        call    AddDEtoHLSigned             ; hl = cy - ( uy Cos + vy sin)
                        ld      (P_NewYPos),hl              ; load to new Y Pos
.CalcNewXPos:           ld      hl,(P_BnKCx)
                        ld      de,(P_BnKUxCosAddVxSin)
                        call    ScaleDE75pct
                        call    AddDEtoHLSigned             ; hl = cx - ( ux Cos + vx sin)
                        ld      (P_NewXPos),hl
.PL43:                  call    BLINE                       ; hl = TX  draw this segment, updates CNT in A
                        ReturnIfAGTEMemusng P_BnKTGT        ; If CNT > TGT then jump to PL40 to stop drawing the ellipse (which is how we draw half-ellipses)
                        ld      a,(P_BnKCNT2)               ; Set CNT2 = (CNT2 + STP) mod 64
                        ld      hl,P_BnKSTP                 ; .
                        add     a,(hl)                      ; .
                        ld      (P_BnKCNT2),a               ; .
                        jp      .PLL4                       ; Jump back to PLL4 to draw the next segment
.PL40:                  ret


ScaleDE75pct:           ex      de,hl
                        ld      a,h
                        and     a
                        push    af
                        jp      p,.PositiveHL
.NegativeHL:            and     $7F
                        ld      h,a
.PositiveHL:            push    de
                        ld      de,hl
                        add     hl,hl                       ; * 2
                        add     hl,de
                        pop     de
                        ShiftHLRight1
                        ShiftHLRight1
CheckSign:              ex      de,hl
                        pop     af
                        and     a
                        ret     p
                        ld      a,h
                        or      $80
                        ld      h,a
                        ret

;  Draw a single segment of a circle, adding the point to the ball line heap.
;  Arguments:
;   CNT                  The number of this segment
;   STP                  The step size for the circle
;   K6(1 0)              The x-coordinate of the new point on the circle, as a screen coordinate
;   P_New Pos-- (T X)                The y-coordinate of the new point on the circle, as an offset from the centre of the circle
;   FLAG                 Set to &FF for the first call, so it sets up the first point in the heap but waits until the second call before drawing anything (as we need two points, i.e. two calls, before we can draw a line)
;   -- Not UsedK                    The circle's radius
;   -- Not UsedK3(1 0)              Pixel x-coordinate of the centre of the circle
;   -- Not UsedK4(1 0)              Pixel y-coordinate of the centre of the circle
;   P_PrevXPos--K5(1 0)              Screen x-coordinate of the previous point added to the ball line heap (if this is not the first point)
;   P_PrevYPos--K5(3 2)              Screen y-coordinate of the previous point added to the ball line heap (if this is not the first point)
;   SWAP                 If non-zero, we swap (X1, Y1) and (X2, Y2)
; Returns:
;   CNT                  CNT is updated to CNT + STP
;   A                    The new value of CNT
;   P_PrevXPos --K5(1 0)              Screen x-coordinate of the point that we just added to the ball line heap
;   P_PrevYPos--K5(3 2)              Screen y-coordinate of the point that we just added to the ball line heap
;   FLAG                 Set to 0`
; ** THIS NEEDS CHANGING TO IMMEDIATE DRAW and retain last line end pos) ;
; Flow of code 
; Entry Bline, prepare T , X K4 etc
;       BL1        
PLINEx1                 DB 0
PLINEy1                 DB 0
PLINEx2                 DB 0
PLINEy2                 DB 0

                        IFDEF MERIDANLINEDEBUG
; Store X and Y on plot line (ball) heap, values bc = YX to save, a = offset
P_StoreXYOnHeap:        ld      hl,P_BnKPlotXHeap
                        ld      bc,(P_NewXPos)
                        ld      de,(P_NewYPos)      ; now save Y
                        ld      a,(P_BnKPlotIndex)  ; get off set
                        add     hl,a                ; now we have x heap target
                        ld      (hl),b
                        inc     hl
                        ld      (hl),c
                        ld      a, $80 - 1          ; note its 2 bytes per coord element, we have already incremeted by 1 byte
                        add     hl,a
                        ld      (hl),d
                        inc     hl
                        ld      (hl),e
                        ld      a,(P_BnKPlotIndex)  ; get index back
                        inc     a                   ; move on 2 bytes
                        inc     a                   ; .
                        ld      (P_BnKPlotIndex),a  ; and save it
                        ret
                        ENDIF

; We'll move the calculation of absolute screen pos outside of bline so we expect screen pixel coordinates
BLINE:                  ;ld      a,(P_Tvar)          ; entry point if we need to fetch TX
BLINE_HL:               ;ld      de,(P_varK4)        ; Set K6(3 2) = (T X) + K4(1 0) = y-coord of centre + y-coord of new point
                        ld      a,(P_BnKFlag)       ; If FLAG = 0, jump down to BL1, else its FF so we save first point
                        and     a                   ; .
                        jp      z,.BL1              ; .
.FirstPlot:             
; This code now stores on line heap if debugging is enabled else it just stores in Prev X and Y for direct plotting                        
; First time in we are just establinshign first position point, then we can exit
.BL5:                   inc     a                   ; Flag is &FF so this is the first call to BLINE so increment FLAG to set it to 0
                        ld      (P_BnKFlag),a       ; so we just save the first point and don't plot it
                        IFDEF   MERIDANLINEDEBUG
                        ZeroA
                        ld      (P_BnKPlotIndex),a  ; Initialise line list
                        ENDIF
; We don't need to copy to prev here as we do it in BL7                        
                        jp      .SkipFirstPlot      ; Jump to BL7 to tidy up and return from the subroutine
; This section performs teh clipping and draw of the line. it retrieves previous position and draws to new                        
.BL1:                   
; note we still need the unclipped points for the next segment as we have to clip again                         
.BL9:
.BL8:
                        ld      hl,(P_PrevXPos)     ; set line X2 to PLINEx2
                        ld      (P_XX1510),hl
                        ld      hl,(P_PrevYPos)     ; set line X2 to PLINEx2
                        ld      (P_XX1532),hl
                        ld      hl,(P_NewXPos)      ; set line X2 to PLINEx2
                        ld      (P_XX1554),hl
                        ld      hl,(P_NewYPos)      ; set line X2 to PLINEx2
                        ld      (P_XX1210),hl
.CLipLine:              call    P_LL145_6502        ; Clip  line from (X1, Y1) to (X2, Y2), loads to X1,Y1,X2,Y2 P_XX1510 as bytes                        ld      bc,(XX1510)
                        jr      c,.LineTotallyClipped
.DrawLine:              ld      a,$CC               
                        ld      bc,(P_XX15PlotX1)
                        ld      de,(P_XX15PlotX2)
                        MMUSelectLayer2
                        call    l2_draw_any_line
; if line was totally clipped just store new x and y as previous and continue from there
.SkipFirstPlot:
.LineTotallyClipped:
.BL7:                   ld      hl,(P_NewXPos)        ; Copy the data for this step point from K6(3 2 1 0)
                        ld      de,(P_NewYPos)        ; into K5(3 2 1 0), for use in the next call to BLINE:
                        ld      (P_PrevXPos),hl
                        ld      (P_PrevYPos),de
                        IFDEF   MERIDANLINEDEBUG
                        call    P_StoreXYOnHeap
                        ENDIF
                        ld      a,(P_BnKCNT)         ; CNT = CNT + STP
                        ld      hl,P_BnKSTP
                        ClearCarryFlag
                        adc     a,(hl)
                        ld      (P_BnKCNT),a
                        ret

