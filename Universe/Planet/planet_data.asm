
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

CalculatePlanetLaunchedPosition:
.CalcXPosition:         MMUSelectMathsBankedFns
                        ld      ix,P_BnKxlo             ; P_BnKxlo += ParentPlanetX
                        ld      iy,ParentPlanetX        ; .
                        call    AddAtIXtoAtIY24Signed   ; .
.CalcYPosition:         ld      ix,P_BnKylo             ; P_BnKylo += ParentPlanetZ
                        ld      iy,ParentPlanetY        ; .
                        call    AddAtIXtoAtIY24Signed   ; .
.CalcZPosition:         ld      ix,P_BnKzlo             ; P_BnKzlo += ParentPlanetZ
                        ld      iy,ParentPlanetZ        ; .
                        call    AddAtIXtoAtIY24Signed   ; .
                        ret
; --------------------------------------------------------------                                                
CopyPlanettoGlobal:     ld      hl,P_BnKxlo
                        ld      de,ParentPlanetX
                        ld      bc,3*3
                        ldir
                        ret                 
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
                        call    CopyPlanettoGlobal      ; Set up global position interface
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
.ProcessXPositive:      ld      de,128
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
.ProcessYPositive:      ld      de,64                       ; set hl to center Y and de to 2s'c Y/Z
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
.TooFarAway:            JumpIfAGTENusng   48,.SkipDrawPlanet  ; if sign (high byte 2) > 48 then too far away to render
                        ld      hl, P_BnKzhi                 ; if |P_BnKzsgn| or P_BnKzsgn are both 0 then the planet is too close so return
                        or      (hl)                         ; .
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
                        

; K3(1 0) = (Y A) + K3(1 0) = 222 * roofv_x / z + x-coordinate of planet centre
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
                ENDIF


;PLS2                                                   Test
; K[10] = radius                                        $0000?
; k3[10], K4[10] X, y pixel of centre
; (XX16, K2), (XX16+1,K2+1) u_x , u_y                   $1F80  $FE80    
; (XX16+2, K2+2), (XX16+3,K2+3) z_x , z_y               $0000  $0000
; TGT - target segment count                            $00
; CNT2 - starting segment                               $0D
; Now uses (Word) P_BnKCx, Cy, (Byte) Ux, Uy, Vx, Vy
                        DISPLAY "TODO move code back in that was pulled outof BLINE"
DrawMeridian:           ld      a,63                        ; Set TGT = 31, so we only draw half an ellipse
                        ld      (P_BnKTGT),a                ; and fall into DrawElipse
                        DISPLAY "TODO DEBUG STP Default of 1"
                        ld      a,1
                        ld      (P_BnKSTP),a
;PLS22
                        DISPLAY "TODO: Sort out sign byte for uxuy vxvy in calling code"
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
                        ld      (varQ),a                    ; .
                        ld      (P_BnKSinCNT2),a            ; for debugging
; calculate BnKVxSin = VX*Sin(CNT2)-------------------------;
.GetVxSin:              ld      a,(P_BnKVx)                 ; Set A = K2+2 = |v_x|
                        call    AequAmulQdiv256usgn         ; R = A * Q / 256 = |v_x| * |sin(CNT2)|
                        ld      (P_BnKVxSin),a              ; now varR = vx*sin(CNT2)
; calculate BnkVySin = Vy*Sin(CNT2)-------------------------;
.GetVySin:              ld      a,(P_BnKVy)                 ; Set A = K2+3 = |v_y|
                        call    AequAmulQdiv256usgn         ; Set varK = A * Q / 256 = |v_y| * |sin(CNT2)|
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
                        ld      (varQ),a                    ; .
                        ld      (P_BnKCosCNT2),a            ; for debugging                        
; calculate Uy*Cos(CNT2)------------------------------------;
.GetUyCos:              ld      a,(P_BnKUy)                 ; Set A = K2+1 = |u_y|
                        call    AequAmulQdiv256usgn         ; Set P_BnKUyCos(wasK+2) = A * Q / 256 = |u_y| * |cos(CNT2)|
                        ld      (P_BnKUyCos),a              ; .
; calculate Ux*Cos(CNT2)------------------------------------;
.GetUxCos:              ld      a,(P_BnKUx)                 ; Set A = K2 = |u_x|
                        call    AequAmulQdiv256usgn         ; Set P_BnKUxCos(wasP) = A * Q / 256 = |u_x| * |cos(CNT2)| also sets the C flag, so in the following, ADC #15 adds 16 rather than 15 (use use non carry add)
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
                        ;ld      h,a
                        ;ld      a,(P_Xreg)
                        ;ld      l,a
BLINE_HL:               ;ld      de,(P_varK4)        ; Set K6(3 2) = (T X) + K4(1 0) = y-coord of centre + y-coord of new point
                        ;ex      de,hl               ;not really needed
                        ;ClearCarryFlag              ; .
                        ;adc     hl,de               ; .
                        ;ld      a,h
                        ;ld      (P_varK6p2),hl      ; so K6(3 2) now contains the y-coordinate of the new point on the circle but as a screen coordinate, to go along with the screen y-coordinate in K6(1 0)
                        ld      a,(P_BnKFlag)       ; If FLAG = 0, jump down to BL1, else its FF so we save first point
                        and     a                   ; .
                        jp      z,.BL1              ; .
.FirstPlot:             
; This code now stores on line heap if debugging is enabled else it just stores in Prev X and Y for direct plotting                        
; First time in we are just establinshign first position point, then we can exit
.BL5:                   inc     a                   ; Flag is &FF so this is the first call to BLINE so increment FLAG to set it to 0
                        ld      (P_BnKFlag),a       ; so we just save the first point and don't plot it
                        DISPLAY "TODO, set up proper variables, hold variables for previous X Y, we don't need ball heap"
                        DISPLAY "TODO, created a plot xy heap to store for debugging purposes, delete once not needed"
                        DISPLAY "TODO, need flag for start which is probably CNT being 0?"
                        IFDEF   MERIDANLINEDEBUG
                        ZeroA
                        ld      (P_BnKPlotIndex),a  ; Initialise line list
                        ENDIF
; We don't need to copy to prev here as we do it in BL7                        
                        jp      .SkipFirstPlot      ; Jump to BL7 to tidy up and return from the subroutine
; This section performs teh clipping and draw of the line. it retrieves previous position and draws to new                        
.BL1:                   
; note we still need the unclipped points for the next segment as we have to clip again                         
                        ;ld      hl,(PLINEx1)        ; Otherwise the coordinates were swapped by the call to
                        ;ld      de,(PLINEx2)        ; LL145 above, so we swap (X1, Y1) and (X2, Y2) back
                        ;ld      (PLINEx1),de        ; again
                        ;ld      (PLINEx2),hl        ; .
.BL9:                   DISPLAY "TODO  Removed BnKLSP, check fine"
.BL8:                   DISPLAY "TODO  Removed BnKLSP, check fine"
                        ;ld      a,(P_BnKPlotIndex) ; Set Line Stack Pointer to be the same as Plot Index)
                        ;ld      (P_BnKLSP),a        
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
                        DISPLAY "TODO what was the Ld de for?"
;                        ld      de,(XX1532)
                        DISPLAY "TODO SORT OUT PROPER PLANET COLOR"
.DrawLine:              ld      a,$CC               
                        ld      bc,(P_XX15PlotX1)
                        ld      de,(P_XX15PlotX2)
                        MMUSelectLayer2
                        call    l2_draw_any_line
                        DISPLAY "TODO removed check for starting line segments again as we draw direct"
;                        ld      a,(P_XX13)          ; If XX13 is non-zero, jump up to BL5 to add a &FF marker to the end of the line heap. XX13 is non-zero
;                        and     a                   ; after the call to the clipping routine LL145 above if the end of the line was clipped, meaning the next line
;                        jp      z,.BL5              ; sent to BLINE can't join onto the end but has to start a new segment, and that's what inserting the &FF marker does                        
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
;                        ld      (P_varK5),hl        ; * K5(1 0)(3 2) = x, y of previous point
;                        ld      (P_varK5p2),de      ;
                        ld      a,(P_BnKCNT)         ; CNT = CNT + STP
                        ld      hl,P_BnKSTP
                        ClearCarryFlag
                        adc     a,(hl)
                        ld      (P_BnKCNT),a
                        ret

PlanetBankSize  EQU $ - StartOfPlanet


