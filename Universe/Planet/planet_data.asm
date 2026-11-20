

; To avoid hassle of memory heap managment, the free list
; will correspond to a memory bank offset so data will be held in
; 1 bank per universe object. Its a waste of a lot of memory but really
; 1 bank per universe object. Its a waste of a lot of memory but really
; simple that way. Each bank will be 8K and swapped on 8K slot 7 $E000 to $FFFF
; This means each gets its own line list, inwork etc

; "Runtime Ship Data paged into in Bank 7"
;                      0123456789ABCDEF
StartOfPlanet:     DB "Planet Data....."
; NOTE we can cheat and pre allocate segs just using a DS for now
;   \ -> & 565D \ See ship data files chosen and loaded after flight code starts running.
; Universe map substibute for INWK
;-Camera Position of Ship----------------------------------------------------------------------------------------------------------
P_BnKDataBlock:
                            UnivPosVarsMacro P
                        ; ; Not needed as we don't rotate planets and suns    UnivRotationVarsMacro P

                            XX18DefineMacro P
                            UnivCoreAIVarsMacro P                ; (the radius and colours)

                            

                            XX15DefineMacro P
                            XX12DefineMacro P

                            ClippingVarsMacro P


P_BnK_Data_len               EQU $ - P_BnKDataBlock
    
    
                            ; Not needed as we don't do rotation matrices for planets

; --------------------------------------------------------------
; clear out the planet data block
ResetP_BnKData:         ld      hl,P_BnKDataBlock       
                        ld      de,P_BnK_Data_len
                        xor     a
                        call    memfill_dma
                        ret
; --------------------------------------------------------------
ResetP_BnKPosition:     ld      hl,P_BnKxlo
                        ld      b, 3*3
                        xor     a
.zeroLoop:              ld      (hl),a
                        inc     hl
                        djnz    .zeroLoop
                        ret
; --------------------------------------------------------------
; Normalise planet vectors
; Not needed as we don't rotate planets and suns
;                        ;===call    RequAmul256divC				; R = (2(hi).0)/ConstNorm - LL28 Optimised BFRDIV R=A*256/Q = delta_y / delta_x Use Y/X grad. as not steep

                        
; This uses UBNKNodeArray as the list
; the array is 256 * 2 bytes
; counter is current row y pos
; byte 1 is start x pos
; byte 2 is end x pos
; if they are both 0 then skip
; its always horizontal, yellow
; 16 different Planet Colours
; codes D<> Dark, M<> Mid, L<> Light B<> Brightest
PlanetColour10DG        equ      40     ; Green
PlanetColour20DG        equ      44
PlanetColour11MG        equ      44
PlanetColour21MG        equ      80
PlanetColour12LG        equ      80
PlanetColour22LG        equ      84
PlanetColour13BG        equ      84
PlanetColour23BG        equ      120
PlanetColour14DB        equ      1      ; Blue
PlanetColour24DB        equ      2
PlanetColour15MB        equ      2
PlanetColour25MB        equ      3
PlanetColour16LB        equ      3
PlanetColour26LB        equ      67
PlanetColour17DO        equ      68     ; Orange
PlanetColour27DO        equ      100
PlanetColour18MO        equ      100
PlanetColour28MO        equ      136
PlanetColour19LO        equ      136
PlanetColour29LO        equ      168
PlanetColour1ABO        equ      168
PlanetColour2ABO        equ      204
PlanetColour1BDR        equ      64     ; Red
PlanetColour2BDR        equ      96
PlanetColour1CMR        equ      96
PlanetColour2CMR        equ      128
PlanetColour1DLR        equ      128
PlanetColour2DLR        equ      160
PlanetColour1EMC        equ      18     ; Cyan
PlanetColour2EMC        equ      22
PlanetColour1FMP        equ      163    ; Purple
PlanetColour2FMP        equ      226    ; note avoiding transparent

PlanetColour1Table:     DB       PlanetColour10DG, PlanetColour11MG, PlanetColour12LG, PlanetColour13BG
                        DB       PlanetColour14DB, PlanetColour15MB, PlanetColour16LB, PlanetColour17DO
                        DB       PlanetColour18MO, PlanetColour19LO, PlanetColour1ABO, PlanetColour1BDR
                        DB       PlanetColour1CMR, PlanetColour1DLR, PlanetColour1EMC, PlanetColour1FMP
PlanetColour2Table:     DB       PlanetColour20DG, PlanetColour21MG, PlanetColour22LG, PlanetColour23BG
                        DB       PlanetColour24DB, PlanetColour25MB, PlanetColour26LB, PlanetColour27DO
                        DB       PlanetColour28MO, PlanetColour29LO, PlanetColour2ABO, PlanetColour2BDR
                        DB       PlanetColour2CMR, PlanetColour2DLR, PlanetColour2EMC, PlanetColour2FMP

WarpPlanetByHL:         ld      b,h
                        ld      c,l
                        ld      h,0
                        ld      de,(P_BnKzhi)
                        ld      a,(P_BnKzlo)
                        ld      l,a
                        MMUSelectMathsBankedFns : call  SubBCHfromDELsigned
                        ld      (P_BnKzhi),de
                        ld      a,l
                        ld      (P_BnKzlo),a
                        ret

; PLANET
WarpPlanetCloser:       ld      hl,P_BnKzsgn
.PositiveAxis:          ld      a,(hl)
                        ReturnIfALTNusng 2                      ; hard liit along z axis
                        dec     (hl)
                        ret

; It should normally be behind but someone could fly past a planet, turn aroudn and jump
WarpPlanetFurther:      ld      hl,P_BnKzsgn
                        ld      a,(hl)
                        ReturnIfAGTENusng $7F                   ; this is the hard limit else it woudl turn negative and flip to -0
                        inc     (hl)                           ; if its negative it will still increase as we will block insane values
                        ret      

; --------------------------------------------------------------                        
; This sets current universe object to a planet,they use sign + 23 bit positions
; we need to have variable size and color
CalculatePlanetWarpPositon:
.CalcZPosition:         ld      a,(WorkingSeeds+1)      ; seed d & 7 
                        and     %00000111               ; .
                        add     a,7                     ; + 7
                        sra     a                       ; / 2
.SetZPosition:          ld      (P_BnKzsgn),a            ; << 16 (i.e. load into z sign byte
                        ld      hl, $0000               ; now set z hi and lo
                        ld      (P_BnKzlo),hl            ;
.CalcXandYPosition:     ld      a,(WorkingSeeds+5)      ; seed f & 3
                        and     %00000011               ; .
                        add     a,3                     ; + 3
                        ld      b,a
                        ld      a,(WorkingSeeds+4)      ; get low bit of seed e
                        and     %00000001
                        rra                             ; roll bit 0 into bit 7
                        or      b                       ; now calc is f & 3 * -1 if seed e is odd
.SetXandYPosition:      ld      (P_BnKxsgn),a            ; set into x and y sign byte
                        ld      (P_BnKysgn),a            ; .
                        ld      a,b                     ; we want just seed f & 3 here
                        ld      (P_BnKxhi),a             ; set into x and y high byte
                        ld      (P_BnKyhi),a             ; .
                        ZeroA
                        ld      (P_BnKxlo),a
                        ld      (P_BnKylo),a                        
                        ret         

; --------------------------------------------------------------                                                
CopyPlanettoGlobal:     ld      hl,P_BnKxlo
                        ld      de,ParentPlanetX
                        ld      bc,3*3
                        ldir
                        ret                 
; --------------------------------------------------------------                                                
CopyPlanettoGeneral:    ld      hl,P_BnKxlo
                        ld      de,PlanetXPos
                        ld      bc,3*3
                        ldir
                        ret                 
; This sets current universe object to a planet,they use sign + 23 bit positions
; we need to have variable size and color
CreatePlanet:           call    ResetP_BnKData          ; Clear out planet block
                        ; PLanets don't have pitch and roll MaxUnivPitchAndRoll
                        ld      a,(WorkingSeeds+1)      ; a= bits 1 and 0 of working seed1 + 3 + carry
                        and     %00000011               ; .
                        adc     3                       ; we also lauch planet side so its infront of us
                        ld      (P_BnKzsgn),a           ; set z sign to 3 + C + 0..3 bits 
                        rr      a
                        ld      (P_BnKxsgn),a
                        ld      (P_BnKysgn),a
.SetColour:             ld      a,(DisplayTekLevel)
                        ld      hl,DisplayPopulation    ; add displaypopulation
                        add     a, (hl)
                        ld      b,a                     ; save for atmosphere level
                        inc     hl                      ; move to DisplayProductivity
                        add     a, (hl)
                        and     $0F                     ; limit to 0 to 16
                        ld      hl,PlanetColour1Table
                        add     hl,a
                        ld      a,(hl)
                        ld      (P_Colour1),a
                        ld      a,$10
                        add     hl,a
                        ld      a,(hl)
                        ld      (P_Colour2),a
                        ld      a,b
                        and     %00000111               ; atmosphere can be 0 to  3 pixels thick
                        srl     a                       ; 
                        ld      (P_Colour2Thickness),a                       
.SetOrientation:        ; Not needed as we don't do planet rotation call    P_InitRotMat
                        call    CopyPlanettoGlobal      ; Set up global position interface
                        ret

CreatePlanetLaunched:   call    ResetP_BnKData
                        call    CreatePlanet
                        ld      hl,0
                        ld      (P_BnKxlo),hl
                        ld      (P_BnKylo),hl
                        ld      hl,StationSafeZoneRange-StationLaunchDistance ; the station (StationLaunchDistance behind us,
                        ld      (P_BnKzlo),hl           ; ResetStationLaunch) 192 from the planet as UnivSetStationInSafeZone
                                                        ; puts it, and us inside the safe zone (it was $FF03, outside)
                        ZeroA
                        ld      (P_BnKxsgn),a
                        ld      (P_BnKysgn),a
                        ld      (P_BnKzsgn),a
                        ; PLanets don't have pitch and roll MaxUnivPitchAndRoll
                        call    CopyPlanettoGlobal      ; Set up global position interface                        
                        ret
; NEED FINSIHGING


ScalePlanetTo8Bit:		ld			bc,(P_BnKZScaled)
                        ld			hl,(P_BnKXScaled)
                        ld			de,(P_BnKYScaled)		
.SetABSbc:              ld			a,b
                        ld			ixh,a
                        and			SignMask8Bit
                        ld			b,a									; bc = ABS bc
.SetABShl:              ld			a,h
                        ld			ixl,a
                        and			SignMask8Bit
                        ld			h,a									; hl = ABS hl
.SetABSde:              ld			a,d
                        ld			iyh,a
                        and			SignMask8Bit
                        ld			d,a									; de = ABS de
.ScaleNodeTo8BitLoop:   ld          a,b		                            ; U	\ z hi
                        or			h                                   ; XX15+1	\ x hi
                        or			d                                   ; XX15+4	\ y hi
                        jr          z,.ScaleNodeDone                   ; if X, Y, Z = 0  exit loop down once hi U rolled to 0
                        ShiftHLRight1
                        ShiftDERight1
                        ShiftBCRight1
                        jp          .ScaleNodeTo8BitLoop
; now we have scaled values we have to deal with sign
.ScaleNodeDone:          ld			a,ixh								; get sign bit and or with b
                        and			SignOnly8Bit
                        or			b
                        ld			b,a
.SignforHL:              ld			a,ixl								; get sign bit and or with b
                        and			SignOnly8Bit
                        or			h
                        ld			h,a
.SignforDE:              ld			a,iyh								; get sign bit and or with b
                        and			SignOnly8Bit
                        or			d
                        ld			d,a
.SignsDoneSaveResult:	ld			(P_BnKZScaled),bc
                        ld			(P_BnKXScaled),hl
                        ld			(P_BnKYScaled),de
                        ld			a,b
                        ld			(varU),a
                        ld			a,c
                        ld			(varT),a
                        ret

;--------------------------------------------------------------------------------------------------------
                        include "./Universe/Planet/CopyPlanetXX12ScaledToPlanetXX18.asm"
                        include "./Universe/Planet/CopyPlanetPosToPlanetXX15.asm"

; ......................................................                                                         ;;; 
            INCLUDE "./Universe/Planet/PlanetApplyMyRollAndPitch.asm"

PlanetOnScreen          DB 0
PlanetScrnX             DW  0       ; signed
PlanetScrnY             DW  0       ; signed
; draw circle               

;
;DIVD3B2 K(3 2 1 0) = (A P+1 P) / (z_sign z_hi z_lo)

PlanetVarK                 DS 4
PlanetVarP                 DS 3
PlanetVarQ                 DS 1
PlanetVarR                 DS 1
PlanetVarS                 DS 1
PlanetVarT                 DS 1


MaximiseHLVector:       ld      c,(ix+0)
                        ld      b,(ix+1)
                        ld      e,(ix+2)
                        ld      d,(ix+3)
                        ld      l,(ix+4)
                        ld      h,(ix+5)
MaxShiftOutSign:        ShiftBCLeft1
                        ShiftDELeft1
                        ShiftHLLeft1
MaximiseIXVector:       ld      a,b                 ; Now loop round until bit 7 is populated
                        or      d
                        or      e
                        and     $80
                        jp      z,MaxShiftOutSign
.MakeSpaceForSign:      ShiftBCRight1               ; Now go back 1 so sign bit is clear
                        ShiftDERight1
                        ShiftHLRight1
                        ld      a,(ix+0)
                        and     SignOnly8Bit
                        or      b
                        ld      a,(ix+1)
                        and     SignOnly8Bit
                        or      d
                        ld      a,(ix+3)
                        and     SignOnly8Bit
                        or      e
                        ld      (ix+0),c
                        ld      (ix+1),b
                        ld      (ix+2),e
                        ld      (ix+3),d
                        ld      (ix+4),h
                        ld      (ix+5),l
                        ret

                        
; Subroutine: SPS1 (Docked) Calculate the vector to the planet and store it in XX15
; calls SPS3 and falls into TAS2


VectorToPlanet:         call    PlanetCopyPosToXX15 ; Perform all of SPS3 
                        ld      ix,P_XX15
                        call    MaximiseIXVector
                        MMUSelectMathsBankedFns
                        call    NormaliseIXVector


;;INWORK 
;;INWORK Main loop
;;INWORK 
;;INWORK Subroutine: Main flight loop (Part 14 of 16) (Flight)
;;INWORK 
;;INWORK Spawn a space station if we are close enough to the planet
;;INWORK 
;;INWORK Main loop
;;INWORK 
;;INWORK Subroutine: Main flight loop (Part 15 of 16) (Flight)
;;INWORK 
;;INWORK Perform altitude checks with the planet and sun and process fuel scooping if appropriate
;;INWORK 
;;INWORK Maths (Geometry)
;;INWORK 
;;INWORK Subroutine: MAS2 (Flight)
;;INWORK 
;;INWORK Calculate a cap on the maximum distance to the planet or sun
;;INWORK 
;;INWORK Universe
;;INWORK 
;;INWORK Subroutine: SOS1 (Flight)
;;INWORK 
;;INWORK Update the missile indicators, set up the planet data block
;;INWORK 
;;INWORK 
;;INWORK Dashboard
;;INWORK 
;;INWORK Subroutine: SP2 (Flight)
;;INWORK 
;;INWORK Draw a dot on the compass, given the planet/station vector

; Drawing planets Subroutine: PL2 (Flight) Remove the planet or sun from the screen
;                             PLANET (Flight) Draw the planet or sun
;                             PL9 (Part 1 of 3) (Flight) Draw the planet, with either an equator and meridian, or a crater
;                             PL9 (Part 2 of 3) (Flight) Draw the planet's equator and meridian
;                             PL9 (Part 3 of 3) (Flight) Draw the planet's crater
;                             PLS1 (Flight)  Calculate (Y A) = nosev_x / z
;                             PLS2 (Flight) Draw a half-ellipse
;                             PLS22 (Flight) Draw an ellipse or half-ellipse


; Drawing circles Subroutine: CIRCLE (Flight) Draw a circle for the planet
;                             CIRCLE2 (Flight) Draw a circle (for the planet or chart)
;                             WPLS2 (Flight) Remove the planet from the screen
;                             WP1 (Flight) Reset the ball line heap
; Drawing planets PL21 (Flight) Return from a planet/sun-drawing routine with a failure flag
;                 PLS3 (Flight) Calculate (Y A P) = 222 * roofv_x / z
;                 PLS4 (Flight) Calculate CNT2 = arctan(P / A) / 4
;                 PLS5 (Flight) Calculate roofv_x / z and roofv_y / z
;                 PLS6 (Flight) Calculate (X K) = (A P) / (z_sign z_hi z_lo)
; SPS1 (Flight) Calculate the vector to the planet and store it in XX15
; MV40 rate planet by our pitch
;
;look at PL9


; Optimisation
; if a <> 0
;       divide AH by CD
; if h <> 0
;      if c <> 0 return 0
;      else
;        divide HL by DE
; if l <>0
;      if c or d <> 0 return 0
;      else
;        divide l by e
;
PlanetAHLequAHLDivCDE:  ld      b,a                         ; save a reg
                        ld      a,c                         ; check for divide by zero
                        or      d                           ; .
                        or      e                           ; .
                        JumpIfZero      .divideByZero       ; .
                        ld      a,b                         ; get a back
                        JumpIfAIsNotZero    .divideAHLbyCDE
.AIsZero:               ld      a,h
                        JumpIfAIsNotZero    .divideHLbyDE
.HIsZero:               ld      a,l
                        JumpIfAIsNotZero    .divideLbyE
.resultIsZero:          ZeroA
                        ld      h,a                        ; result is zero so set hlde
                        ld      l,a                        ; result is zero so set hlde
                        ld      de,hl
                        ClearCarryFlag
                        ret
.divideByZero:          ld      a,$FF
                        ld      h,a
                        ld      l,a
                        ld      de,hl
                        SetCarryFlag
                        ret
; AHL = ahl/cde, this could be a genuine 24 bit divide
; if AHL is large and cde small then the value will be big so will be off screen so we can risk 16 bit divide
.divideAHLbyCDE:        MMUSelectMathsBankedFns
                        call    AHLequAHLDivCDE             ; AHL = AHL/CDE (integer quotient, same as SunProcessVertex uses)
                        ClearCarryFlag
                        ret 
; AHL = 0hl/0de as A is zero
.divideHLbyDE:          ld      a,c                         ;'if c = 0 then result must be zero
                        JumpIfAIsNotZero   .resultIsZero
                        ld      bc,hl
                        call    BC_Div_DE                   ; BC = HL/DE
                        ld      hl,bc
                        ZeroA                               ; so we can set A to Zero
                        ClearCarryFlag
                        ret
; AHL = 00l/00e as A and H are zero
.divideLbyE:            ld      a,c                         ; if d = 0 then result must be zero
                        or      d
                        JumpIfAIsNotZero   .resultIsZero
                        ld      c,e
                        ld      e,l
                        MMUSelectMathsBankedFns
                        call    div_e_div_c
                        ld      l,a
                        ZeroA
                        ld      h,a
                        ClearCarryFlag
                        ret      

; Project XY to screen location
ProjectPlanet:          ld      ixh,0
                        ld      hl,(P_BnKxlo)
                        ld      a,(P_BnKxsgn)
                        call    PlanetProcessVertex         ; hl = PixelCentreY + (Y / Z)*-1 (as its 0 = top of screen)
                        ld      (P_centreX),hl
                        inc     ixh
                        ld      hl,(P_BnKylo)
                        ld      a,(P_BnKysgn)
                        call    PlanetProcessVertex         ; hl = PixelCentreY + (Y / Z)*-1 (as its 0 = top of screen)
                        ld      (P_centreY),hl
                        ret

; PlanetProcessVertex AHL = X or Y position (sign in A)
;                     fetches z as this used in both calcs                        
PlanetProcessVertex:    ld      b,a                         ; save sign/high byte
.PlanetProjectToEye:    ld      de,(P_BnKzlo)               ; B H L   = X or Y
                        ld      a,(P_BnKzsgn)               ; IYH D E = z
                        ld      iyh,a                       ; save sign
                        ClearSignBitA                       ; A D E   = | z |
                        ; Addeed as it neds to be AHL/0CD to force * 256 and get correct screen position on scaling
                        ld      e,d                         ; C D E   = A D E * 256, i.e. 0 A D
                        ld      d,a                         ; .
                        ld      c,0                         ; .
                        ; added above to correct positioning as in reality its X/(Z/256) to get +-256 rather than +- 1
                        ld      a,b                         ; copy X or Y sign into iyl
                        ld      iyl,a                       ; .
                        ClearSignBitA                       ; A H L = |X| (or |Y|)
                        call PlanetAHLequAHLDivCDE          ; AHL = AHL/CDE unsigned
                        jp      c,.IsOffScreen              ; carry flag indicates failure
.CheckPosOnScreen:      JumpIfAIsNotZero .IsOffScreen       ; if A has a value then its way too large regardless of sign
                        JumpOnLeadSignSet h, .IsOffScreen   ; or bit 7 set of h
.CheckXorY:             ld      a,ixh
                        JumpIfAIsNotZero .ProcessYCoord
; Handle X Coord offset
.ProcessXCoord:         ld      a,iyh                       ; determine if its + or - value of AHL/CDE
                        xor     iyl
                        and     $80
                        jp      z,.ProcessXPositive
.ProcessXNegative:      macronegate16hl
.ProcessXPositive:      ld      de,ScreenCenterX
                        ClearCarryFlag
                        adc     hl,de                       ; now X position is CenterX+ (X / Z) in 2's c
                        ld      de,hl                       ; set de to | hl for +/- 1024 check
                        jp      p,.CheckBoundaries          ; .
                        macronegate16de                     ; .
                        jp      .CheckBoundaries            ; .
; Handle Y Coord offset
.ProcessYCoord:         ld      a,iyh
                        xor     iyl
                        and     $80
                        jp      z,.ProcessYPositive
.ProcessYNegative:      macronegate16hl
.ProcessYPositive:      ld      de,ScreenCenterY            ; set hl to center Y and de to 2s'c Y/Z
                        ex      de,hl
                        ClearCarryFlag
                        sbc     hl,de                       ; now HL  position is CenterY - (Y / Z) in 2's c
                        ld      de,hl                       ; 
                        jp      p,.CheckBoundaries          ; .
                        macronegate16de                     ; load DE with | result to simplify +-1024 check|
.CheckBoundaries:       ld      a,d
                        JumpIfAGTENusng 4, .IsOffScreen     ; if |position| > 1024 then way to large
.calculatedVert:        ClearCarryFlag
                        ret
.IsOffScreen:           ld      hl,$7FFF
                        ld      a,iyh
                        xor     iyl
                        SignBitOnlyA
                        jr      z,.calculatedOffScreen
                        inc     hl                          ; set hl to $8001 i.e. -32768
                        inc     hl                          ; .
.calculatedOffScreen:   SetCarryFlag
                        ret
                        
                        
; .........................................................................................................................
; we only hit this if z is positive so we can ignore signs
; radius = 16384 / (z / 256): BBC Elite uses 24576 (on the same X / (Z / 256) scale as the projected centre), scaled to
; 2/3 as our view is 128 rows high against the BBC 192, so the size still grows in step with
; the position. Worked as 32768 / (z / 128) for an extra bit of precision: PlanetUpdateAndRender only draws when
; z sign < 48 and z >= 256, so z / 128 is 2..24575 and fits the 16 bit divisor. Any radius 1..248 (odd or even)
; so the planet grows a pixel at a time rather than jumping
PlanetCalculateRadius:  ld      a,(P_BnKzsgn)                ; DBC = z / 128 = 0 : (sign<<1 | hi bit 7) : (hi<<1 | lo bit 7)
                        and     SignMask8Bit                 ; .
                        ld      b,a                          ; .
                        ld      a,(P_BnKzlo)                 ; .
                        rla                                  ; . carry = z bit 7
                        ld      a,(P_BnKzhi)                 ; .
                        rla                                  ; .
                        ld      c,a                          ; .
                        rl      b                            ; .
                        ld      d,0                          ; .
                        ld      hl,$8000                     ; 32768 = 16384 * 2
                        call    Div16by24usgn               ; radius = 32768 / (z / 128) = 16384 / (z / 256)
                        or      h                           ; if A or H are not 0 then max Radius
                        JumpIfAIsZero  .SaveRadius
.MaxRadius:             ld      hl,248                      ; set radius to 248 as maxed out
.SaveRadius:            ld      a,l                         ; l = resultant radius
                        and     a                           ; at least radius 1 so a distant planet is still a dot
                        jr      nz,.HaveRadius              ; .
                        inc     a                           ; .
.HaveRadius:
                        ld      (P_Radius),a
                        ld      e,a                         ; as later code expects it to be in e
                        ret                                 ; (it also worked out P_BnKSTP, the meridians' step, which nothing reads now)    

; Shorter version when sun does not need to be processed to screen                        
PlanetUpdateCompass:    ld      a,(P_BnKxsgn)
                        ld      hl,(P_BnKxlo)
                        call    PlanetProcessVertex  
                        ld      (P_CompassX),hl
                        ld      a,(P_BnKysgn)
                        ld      hl,(P_BnKylo)
                        call    PlanetProcessVertex
                        ld      (P_CompassY),hl
                        ret
                        
                   ; could probabyl set a variable say "varGood", default as 1 then set to 0 if we end up with a good calulation?? may not need it as we draw here     
PlanetUpdateAndRender:  call    PlanetApplyMyRollAndPitch    ; not needed for solid as yet
.DrawSolidPlanet:       ld      a,(P_BnKzsgn)                ; a = z sign of position
.ElimiateBehind:        and     a
                        jp      m,.SkipDrawPlanet            ; if its negative then behind so exit
.TooFarAway:            JumpIfAGTENusng   48,.SkipDrawPlanet  ; if sign (high byte 2) > 48 then too far away to render
                        ld      hl, P_BnKzhi                 ; if |P_BnKzsgn| or P_BnKzsgn are both 0 then the planet is too close so return
                        or      (hl)                         ; .
                        jp      z,.SkipDrawPlanet            ; .
;                       loads P_centreX and Y with planet on screen centre
.Project                call    ProjectPlanet                ; Project the planet/sun onto the screen, returning the centre's coordinates in K3(1 0) and K4(1 0)
.CalcRadius:            call    PlanetCalculateRadius
                        DISPLAY "ASSMEBLING WITH SOLID PLANETS"
                        ld      hl,(P_centreX)
                        ld      de,(P_centreY)
                        ld      a,(P_Radius)
                        and     a
                        jp      z,.SkipDrawPlanet            ; skip 0 size
                        ld      c,a
                        ld      a,(P_Colour1)
                        ld      b,a
                        MMUSelectLayer2
                        call    l2_draw_clipped_circle_filled
                        JumpIfMemLTNusng P_Radius, 5, .SkipDrawPlanet
                        cp      5               ; radius < 3 means no atmosphere
                        ld      c,a             ; as a holds radius from Jump Macro
                        jp      z,.SkipDrawPlanet
                        ld      hl,(P_centreX) ; just to test putting a rim there
                        ld      de,(P_centreY)
                        ld      a,(P_Colour2)
                        ld      b,a
                        MMUSelectLayer2
                        call    l2_draw_clipped_circle
.SkipDrawPlanet:        call    PlanetUpdateCompass
                        ret                                 ; else x is totally off the left side of the screen
; 
; (PLS4)
; CNT2 =  = arctan(-nosev_z_hi / side_z_hi) / 4,  if nosev_z_hi >= 0 add PI
; Not needed as we don't rotate planets and suns
;;  CNT2 =  = arctan(-nosev_z_hi / roofv_z_hi) / 4,  if nosev_z_hi >= 0 add PI
;; CNT2 = arctan(P / A) / 4  
;; Adds 128 to the result (rather than makes it negative)
                        
; (PSL1)                     
; XX16 K2) = nosev_x / z   
; Not needed as we don't rotate planets and suns
; (PLS1) (Y A) = nosev_x / z where B = Y (also stores in regY), K+3 = sign of calculation             
; stores result in BC now as well
; does not do increment of X as its not needed when directly loading verticies of rotation
; Not needed as we don't rotate planets and suns
                        
; (PLS3)
;  (Y A P) = 222 * roofv_x / z to give the x-coordinate of the crater offset 
; Not needed as we don't rotate planets and suns
;; (Y A P) = 222 * roofv_y / z to give the x-coordinate of the crater offset 
;; Optimise, move result at the end into HL instead of YA (we can ignore P)                        
;                        ; Not needed                        ; STA Q
;                        ; Not needed                        ; STX U                  \ Store the vector index X in U for retrieval after the  call to MULTU
                        

; K3(1 0) = (Y A) + K3(1 0) = 222 * roofv_x / z + x-coordinate of planet centre
; (the meridian and crater drawing, PlanetDraw to BLINE, unreachable since the planets are solid, is in
; Unused/Unused/planet_meridians.asm)

PlanetBankSize  EQU $ - StartOfPlanet


