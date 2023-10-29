
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
                        ;INCLUDE "./Universe/Planet/PlanetPosVars.asm"
                        ;INCLUDE "./Universe/Planet/PlanetRotationMatrixVars.asm"
                        ;INCLUDE "./Universe/Planet/PlanetAIRuntimeData.asm"
                            UnivPosVarsMacro P
                            UnivRotationVarsMacro P

                        ;INCLUDE "./Universe/Planet/PlanetXX16Vars.asm"
                        ;INCLUDE "./Universe/Planet/PlanetXX25Vars.asm"
                        ;INCLUDE "./Universe/Planet/PlanetXX18Vars.asm"
                            XX16DefineMacro P
                            XX25DefineMacro P
                            XX18DefineMacro P

                            UnivCoreAIVarsMacro P
                            

                        ;INCLUDE "./Universe/Planet/PlanetXX15Vars.asm"
                            XX15DefineMacro P
                        ;INCLUDE "./Universe/Planet/PlanetXX12Vars.asm"
                            XX12DefineMacro P

                            ClippingVarsMacro P


P_BnK_Data_len               EQU $ - P_BnKDataBlock
    
    
                            ClippingCodeLL28Macro P
                            ClippingCodeLL120Macro P
                            ClippingCodeLL122Macro P
                            ClippingCodeLL145Macro P
                            InitialiseUniverseObjMacro P

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
P_NormaliseRotMat:      ld      hl,P_BnkTransmatNosevZ+1   ; initialise loop
                        ld      c,ConstNorm                 ; c = Q = norm = 197
                        ld      a,c
                        ld      (varQ),a                    ; set up varQ
                        ld      b,9                         ; total of 9 elements to transform
.LL21Loop:              ld      d,(hl)
                        dec     hl
                        ld      e,(hl)                      ; de = hilo now   hl now = pointer to low byte
                        ShiftDELeft1                        ; De = DE * 2
                        ld      a,d                         ; a = hi byte after shifting
                        push	hl
                        push	bc
                        call    Norm256mulAdivQ
                        ;===call    RequAmul256divC				; R = (2(hi).0)/ConstNorm - LL28 Optimised BFRDIV R=A*256/Q = delta_y / delta_x Use Y/X grad. as not steep
                        ld      a,c                         ; BFRDIV returns R also in l reg
                        pop		bc
                        pop		hl							; bc gets wrecked by BFRDIV
                        ld      (hl),a                      ; write low result to low byte so zlo = (zhl *2)/197, we keep hi byte in tact as we need the sign bit
                        dec     hl                          ; now hl = hi byte of pre val e.g z->y->x
                        djnz    .LL21Loop                    ; loop from 2zLo through to 0xLo
                        ret

                        
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
CreatePlanet:           call    ResetP_BnKData          ; Clear out planet block
                        ld      a,(DisplayTekLevel)
                        and     %00000010               ; Set A = 128 or 130 depending on bit 1 of the system's tech level
                        or      %10000000
                        ld      (P_BnKShipType),a       ; and load to ship type (synomous with planet type)
                        MaxUnivPitchAndRoll
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
.SetOrientation:        call    P_InitRotMat
                        ret

CreatePlanetLaunched:   call    ResetP_BnKData
                        call    CreatePlanet
                        ld      hl,0
                        ld      (P_BnKxlo),hl
                        ld      (P_BnKylo),hl
                        ld      hl,$FF03
                        ld      (P_BnKzlo),hl
                        ZeroA
                        ld      (P_BnKxsgn),a
                        ld      (P_BnKysgn),a
                        ld      (P_BnKzsgn),a
                        MaxUnivPitchAndRoll
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
;PlanetRadius            DW  0       ; unsigned
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
.divideAHLbyCDE:        call    Div24by24
                        ex      hl,de                         ; ahl is result
                        ld      a,c                           ; ahl is result
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
                        call    E_Div_C
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
.ProcessXPositive:      ld      de,ViewCenterX
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
.ProcessYPositive:      ld      de,ViewCenterY              ; set hl to center Y and de to 2s'c Y/Z
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
; calculates 24576/z, maxes at 248
PlanetCalculateRadius:  ld      bc,(P_BnKzlo)                ; DBC = z position
                        ld      a,(P_BnKzsgn)                ; 
                        ld      d,a                         ; 
                        ld      hl,$6000  ; was hl          ; planet radius at Z = 1 006000
                        call    Div16by24usgn               ; radius = HL/DBC = 24576 / distance z
                        or      h                           ; if A or H are not 0 then max Radius
                        JumpIfAIsZero  .SaveRadius
.MaxRadius:             ld      hl,248                      ; set radius to 248 as maxed out
.SaveRadius:            ld      a,l                         ; l = resultant radius
                        or      1                           ; at least radius 1 (never even so need to test)
                        DISPLAY "DONE - Eliiminate the check to see if planet radius is > 255 as its already fixed in Planet Calculate Radius"
                        ;ld      l,a                        ;
                        ;ld      (P_Radius),hl              ; save a copy of radius now for later
                        ld      (P_Radius),a
                        ld      e,a                         ; as later code expects it to be in e
.CalculateStep:         ld      d,8
                        JumpIfALTNusng 8, .DoneStepCalc
                        srl     d                           ; d = d / 2
                        JumpIfALTNusng 60, .DoneStepCalc
                        srl     d                           ; d = d / 2
.DoneStepCalc:          ld      a,d
                        ld      (P_BnKSTP),a
                        ret    

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
.TooFarAway:            JumpIfAGTENusng   48,.SkipDrawPlanet ; if sign (high byte 2) > 48 then too far away to render
                        ld      hl, P_BnKzhi                 ; if |P_BnKzsgn| or P_BnKzhi or P_Bnkzlo upper byte are both 0 then the planet is too close so return
                        or      (hl)                         ; .
                        dec     hl
                        ld      b,a
                        ld      a,(hl)
                        and     $F0
                        or      b
                        jp      z,.SkipDrawPlanet            ; .
;                       loads P_centreX and Y with planet on screen centre
.Project                call    ProjectPlanet                ; Project the planet/sun onto the screen, returning the centre's coordinates in K3(1 0) and K4(1 0)
.CalcRadius:            call    PlanetCalculateRadius
                        DISPLAY "ASSMEBLING WITH SOLID PLANETS"
                        DISPLAY "TODO, pick colour based on galaxy map"
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
                        cp      PlanetMinRadius             ; radius < min radius means no atmosphere
                        ld      c,a                         ; as a holds radius from Jump Macro
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
CalcNoseSideArcTanPI:   ld      a, (P_BnKrotmatNosevZ + 1)   ; P = - nosevz hi
                        xor     $80
                        ld      (varP),a
                        ld      a, (P_BnKrotmatSidevZ + 1)
                        jp      CalcArcTanPiPA
;  CNT2 =  = arctan(-nosev_z_hi / roofv_z_hi) / 4,  if nosev_z_hi >= 0 add PI
CalcNoseRoofArcTanPI:   ld      a, (P_BnKrotmatNosevZ + 1)   ; P = - nosevz hi
                        xor     $80
                        ld      (varP),a
                        ld      a, (P_BnKrotmatRoofvZ + 1)
; CNT2 = arctan(P / A) / 4  
CalcArcTanPiPA:         ld      (varQ),a                    ; STA Q                  \ Set Q = A
                        call    ARCTAN                      ; A = arctan(P / Q)
                        ld      c,a                         ; save a
                        ld      a,(P_BnKrotmatNosevZ+1)
                        and     $80
                        ld      a,c                         ; restore a as it doesn't affect flags doing an ld
                        jp      m,.SkipFlipSign             ; If nosev_z_hi is negativeleave the angle in A as a positive
; Adds 128 to the result (rather than makes it negative)
.FlipSign:              xor     $80                         ; If we get here then nosev_z_hi is positive, so flip bit 7 of the angle in A, which is the same as adding 128
.SkipFlipSign:          srl     a                           ; Set CNT2 = A / 4
                        srl     a                           ; .
                        ld      (P_BnKCNT2),a                ; .
                        ret                         
                        
; (PSL1)                     
; XX16 K2) = nosev_x / z   
CalcNoseXDivNoseZ:      ld      hl,(P_BnKrotmatNosevX)
                        ld      de,(P_BnKrotmatNosevZ)
                        jp      CalcRotMatDivide
CalcNoseYDivNoseZ:      ld      hl,(P_BnKrotmatNosevY)
                        ld      de,(P_BnKrotmatNosevZ)
                        jp      CalcRotMatDivide 
CalcRoofXDivRoofZ:      ld      hl,(P_BnKrotmatRoofvX)
                        ld      de,(P_BnKrotmatRoofvZ)
                        jp      CalcRotMatDivide 
CalcRoofYDivRoofZ:      ld      hl,(P_BnKrotmatRoofvY)
                        ld      de,(P_BnKrotmatRoofvZ)
                        jp      CalcRotMatDivide 
CalcSideXDivSideZ:      ld      hl,(P_BnKrotmatSidevX)
                        ld      de,(P_BnKrotmatSidevZ)
                        jp      CalcRotMatDivide 
CalcSideYDivSideZ:      ld      hl,(P_BnKrotmatSidevY)
                        ld      de,(P_BnKrotmatSidevZ)
; (PLS1) (Y A) = nosev_x / z where B = Y (also stores in regY), K+3 = sign of calculation             
; stores result in BC now as well
; does not do increment of X as its not needed when directly loading verticies of rotation
CalcRotMatDivide:
.LoadDEtoQRS:           ld      a,e                         ; Q
                        ld      (varQ),a                    ;
                        ld      a,d                         ;
                        and     $7F                         ;
                        ld      (varR),a                    ;
                        ld      a,d                         ;
                        and     $80                         ;
                        ld      (varS),a                    ;
.LoadHLtoP012:          ld      a,l                         ; set A P+1 P to (signnoseX) (|noseX|)
                        ld      (varP),a                    ; set P to nosevX lo
                        ld      a,h                         ; set P_1 to |nosevX hi|
                        ld      b,h                         ; .
                        and     $7F                         ; .
                        ld      (varP+1),a                  ; .
                        ld      a,b                         ; set a to sign nosevX
                        and     $80
                        ld      (varP+2),a
                        call    DVID3B                      ; call DVI3B2 variane where z is in de as 16 bit and needs expanding to 32
                        ld      a,(varK+1)                  ; get second byte into b
                        ld      b,a                         ; and also check to see if its
                        and     a                           ; zero
                        ld      a,(varK)
                        ld      c,a                         ; so now BC = result too
                        jp      z,.Skip254
.Force254Result:        ld      a,254                       ; if 2nd byte is non zero set a to 254 as our max 1 byte value to return
                        ld      c,a
.Skip254:               push    af
                        ld      a,c                         ; if a is 0 then force sign to be +ve
                        and     a
                        jp      nz,.DoNotForceSign
.ForceSignPositive:     ld      (regY),a
                        ld      b,a
                        pop     af
                        ret
.DoNotForceSign:        ld      a,(varK+3)                  ; set b to sign (which was Y in 6502)
                        ld      (regY),a
                        ld      b,a                         ; bc also is result as c was a copy of a
                        pop     af                          ; so c doesn't need to be pushed to stack
                        ret
                        
; (PLS3)
;  (Y A P) = 222 * roofv_x / z to give the x-coordinate of the crater offset 
Cacl222MulRoofXDivRoofZ:ld      hl,(P_BnKrotmatRoofvX)
                        ld      de,(P_BnKrotmatRoofvZ)
                        jp      Calc222MulHLDivDE
; (Y A P) = 222 * roofv_y / z to give the x-coordinate of the crater offset 
Cacl222MulRoofYDivRoofZ:ld      hl,(P_BnKrotmatRoofvY)
                        ld      de,(P_BnKrotmatRoofvZ)
; Optimise, move result at the end into HL instead of YA (we can ignore P)                        
Calc222MulHLDivDE:      call    CalcRotMatDivide            ; calculate (Y A) = nosev_x(orY) / z
                        ld      d,a                         ; P = |roofv_x / z|
                        ld      e,222                       ; LDA #222               \ Set Q = 222, the offset to the crater
                        ; Not needed                        ; STA Q
                        ; Not needed                        ; STX U                  \ Store the vector index X in U for retrieval after the  call to MULTU
                        mul     de                          ; call MULTU (unsigned multiply) de = 222 * |roofv_x / z|
                        ld      a,(varK+3)                  ; LDY K+3                \ If the sign of the result in K+3 is positive, skip to
                        and     a
                        jp      p,.PL12                     ; BPL PL12               \ PL12 to return with Y = 0
                        ld      a,$FF                       ; LDY #&FF               \ Set Y = &FF to be a negative high byte
                        ld      (regY),a                    ; .
                        ld      b,a                         ; .
                        macronegate16de                     ; Otherwise the result should be negative, so negate    
                        ld      a,e                         ; now we have Y A P (with Y in b also)
                        ld      (varP),a                    ; .
                        ld      a,d                         ; .
                        and     a
                        jp      z,.ForcePositive            ; if A is 0, special case to make +ve
                        ret                                 ; RTS                    \ Return from the subroutine
.ForcePositive:         ZeroA                               ; set regY and b to 0
                        ld      (regY),a
                        ld      b,a
                        ld      a,d                         ; get d back into a again
                        ret
.PL12:                  ZeroA                               ; set Y A P to be 0 D E from mul
                        ld      b,a
                        ld      (regY),a
                        ld      a,e
                        ld      (varP),a
                        ld      a,d
                        ret
                        


;-- bc = bc * P_radius where bc = S.Fraction ,e.g nosex/nosey
P_BCmulRadius:          ld      a,(P_Radius)                ; we probably don't have radius already
P_BCmulRadiusInA:       ld      d,a                         ; d = radius already in a
                        ld      e,c                         ; e = c (as we only hold 0.8 in bc, i.e. fractional +/- > 0)
                        mul     de                          ; mulitply raidus by c which will be fractional  generating a 8.X value)
                        ld      c,d                         ; we only want the whole number, preserving sign in b
                        ret

   ; DEFINE  PlanetDebugLocal 1
PlanetDraw:             INCLUDE "./Universe/Planet/PlanetDiagnostics.asm"
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
                        DISPLAY "TODO, pick colour based on galaxy map"
                        ld      hl,(P_centreX)
                        ld      de,(P_centreY)
                        ld      a,(P_Radius)
                        ld      c,a
                        ld      b,$CF
                        MMUSelectLayer2
                        call    l2_draw_clipped_circle_filled
                        ret
                ELSE
                        INCLUDE "./Universe/Planet/PlanetWireframe.asm"
                ENDIF

                IFNDEF  PLANETSARESOLID
                        INCLUDE "./Universe/Planet/PlanetMeridian.asm"
                ENDIF



PlanetBankSize  EQU $ - StartOfPlanet


