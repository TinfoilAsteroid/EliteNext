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
PBnKDataBlock:
                        INCLUDE "./Universe/Planet/PlanetPosVars.asm"
                        INCLUDE "./Universe/Planet/PlanetRotationMatrixVars.asm"
                        INCLUDE "./Universe/Planet/PlanetAIRuntimeData.asm"


                        INCLUDE "./Universe/Planet/PlanetXX16Vars.asm"
                        INCLUDE "./Universe/Planet/PlanetXX25Vars.asm"
                        INCLUDE "./Universe/Planet/PlanetXX18Vars.asm"

; Used to make 16 bit reads a little cleaner in source code
PBnKzPoint                  DS  3
PBnKzPointLo                equ PBnKzPoint
PBnKzPointHi                equ PBnKzPoint+1
PBnKzPointSign              equ PBnKzPoint+2
                        INCLUDE "./Universe/Planet/PlanetXX15Vars.asm"
                        INCLUDE "./Universe/Planet/PlanetXX12Vars.asm"


; Post clipping the results are now 8 bit
PBnKVisibility              DB  0               ; replaces general purpose xx4 in rendering
PBnKProjectedY              DB  0
PBnKProjectedX              DB  0
PBnKProjected               equ PBnKProjectedY  ; resultant projected position
PLanetXX15Save              DS  8
PLanetXX15Save2             DS  8

PBnK_Data_len               EQU $ - PBnKDataBlock

; --------------------------------------------------------------
ResetPBnKData:          ld      hl,PBnKDataBlock
                        ld      de,PBnK_Data_len
                        xor     a
                        call    memfill_dma
                        ret
; --------------------------------------------------------------
ResetPBnKPosition:      ld      hl,PBnKxlo
                        ld      b, 3*3
                        xor     a
.zeroLoop:              ld      (hl),a
                        inc     hl
                        djnz    .zeroLoop
                        ret
; This uses UBNKNodeArray as the list
; the array is 256 * 2 bytes
; counter is current row y pos
; byte 1 is start x pos
; byte 2 is end x pos
; if they are both 0 then skip
; its always horizontal, yellow

; PLANET
                        
; --------------------------------------------------------------                        
; This sets current universe object to a planet,they use sign + 23 bit positions
CreatePlanet:           call    ResetPBnKData
                        ld      a,(DisplayTekLevel)
                        and     %00000010               ; Set A = 128 or 130 depending on bit 1 of the system's tech level
                        or      %10000000
                        ld      (PBnKShipType),a
                        MaxUnivPitchAndRoll
                        ld      a,(WorkingSeeds+1)      ; a= bits 1 and 0 of working seed1 + 3 + carry
                        and     %00000011               ; .
                        adc     3                       ; .
                        ld      (PBnKzsgn),a            ; set z sign to 3 + C + 0..3 bits
                        rr      a
                        ld      (PBnKxsgn),a
                        ld      (PBnKysgn),a
                        ret

CreatePlanetLaunched:   call    ResetPBnKData
                        ld      hl,0
                        ZeroA
                        ld      (PBnKxlo),hl
                        ld      (PBnKylo),hl
                        ld      hl,$FFFF
                        ld      (PBnKzlo),hl
                        ld      (PBnKxsgn),a
                        ld      (PBnKysgn),a
                        ld      (PBnKzsgn),a
                        MaxUnivPitchAndRoll
                        ret
; NEED FINSIHGING


ScalePlanetTo8Bit:		ld			bc,(PBnKZScaled)
                        ld			hl,(PBnKXScaled)
                        ld			de,(PBnKYScaled)		
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
.SignsDoneSaveResult:	ld			(PBnKZScaled),bc
                        ld			(PBnKXScaled),hl
                        ld			(PBnKYScaled),de
                        ld			a,b
                        ld			(varU),a
                        ld			a,c
                        ld			(varT),a
                        ret

;--------------------------------------------------------------------------------------------------------
                        include "./Universe/Planet/CopyPlanetXX12ScaledToPlanetXX18.asm"

; ......................................................                                                         ;;; 
            INCLUDE "./Universe/Planet/PlanetApplyMyRollAndPitch.asm"

PlanetOnScreen          DB 0
PlanetScrnX             DW  0       ; signed
PlanetScrnY             DW  0       ; signed
PlanetRadius            DB  0       ; unsigned
; draw circle               

;
;DIVD3B2 K(3 2 1 0) = (A P+1 P) / (z_sign z_hi z_lo)

PlanetVarK                 DS 4
PlanetVarP                 DS 3
PlanetVarQ                 DS 1
PlanetVarR                 DS 1
PlanetVarS                 DS 1
PlanetVarT                 DS 1

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
PLanetAHLequAHLDivCDE:  ld      b,a                         ; save a reg
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

                        
PlanetProcessVertex:    ld      b,a                         ; save sign byte
.PlanetProjectToEye:    ld      de,(PBnKzlo)                ; X Pos = X / Z
                        ld      a,(PBnKzsgn)                ; CDE = z
                        ld      iyh,a                       ; save sign
                        ClearSignBitA     
                        ; Addeed as it neds to be AHL/0CD to force * 256 and get correct screen position on scaling
;                        ld      c,a                         ;
                        ld      e,d
                        ld      d,a
                        ld      c,0
                        ; added above to correct positioning as in reality its X/(Z/256)
                        ld      a,b                         ; restore sign byte
                        ld      iyl,a                       ; save sign
                        ClearSignBitA
                        call PLanetAHLequAHLDivCDE             ; AHL = AHL/CDE unsigned
.CheckPosOnScreenX:     JumpIfAIsNotZero .IsOffScreen         ; if A has a value then its way too large regardless of sign
                        JumpOnLeadSignSet h, .IsOffScreen      ; or bit 7 set of h
                        ld      a,h
                        ReturnIfAGTEusng 4                  ; if a > 1024 then its way too large regardless of sign
                        ld      a,iyh                       ; now deal with the sign
                        xor     iyl
                        SignBitOnlyA                        ; a= resultant sign
                        jr      z,.calculatedVert           ; result is positive so we don't 2's compliment it
.XIsNegative:           NegHL                               ; make 2's c as negative                        
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
PlanetCalculateRadius:  ld      bc,(PBnKzlo)                ; DBC = z position
                        ld      a,(PBnKzsgn)                ; 
                        ld      d,a                         ; 
                        ld      hl,$6000  ; was hl          ; planet radius at Z = 1 006000
                        call    Div16by24usgn               ; radius = HL/DBC = 24576 / distance z
                        or      h                           ; if A or H are not 0 then max Radius
                        JumpIfAIsZero  .SaveRadius
.MaxRadius:             ld      e,248                       ;set radius to 248 as maxed out
.SaveRadius:            ld      a,l                         ; l = resultant radius
                        or      1                           ; at least radius 1 (never even so need to test)
                        ld      (PlanetRadius),a               ; save a copy of radius now for later
                        ld      e,a                         ; as later code expects it to be in e
                        ret    

; Shorter version when sun does not need to be processed to screen                        
PlanetUpdateCompass:    ld      a,(PBnKxsgn)
                        ld      hl,(PBnKxlo)
                        call    PlanetProcessVertex  
                        ld      (PlanetCompassX),hl
                        ld      a,(PBnKysgn)
                        ld      hl,(PBnKylo)
                        call    PlanetProcessVertex
                        ld      (PlanetCompassY),hl
                        ret
                        
                   ; could probabyl set a variable say "varGood", default as 1 then set to 0 if we end up with a good calulation?? may not need it as we draw here     
PlanetUpdateAndRender:     call    PlanetApplyMyRollAndPitch
.CheckDrawable:         ld      a,(PBnKzsgn)
                        JumpIfAGTENusng 48,  PlanetUpdateCompass ; at a distance over 48 its too far away
                        ld      hl,PBnKzhi                  ; if the two high bytes are zero then its too close
                        or      (hl)
                        JumpIfAIsZero       PlanetUpdateCompass
.calculateX:            ld      a,(PBnKxsgn)
                        ld      hl,(PBnKxlo)
                        call    PlanetProcessVertex            ; now returns carry set for failure
                        ld      (PlanetCompassX),hl
                        ret     c
.calculatedX:           ld      e,ScreenCenterX
                        ld      d,0
                        ClearCarryFlag
                        adc     hl,de
                        ;call    HL2cEquHLSgnPlusAusgn       ; correct to center of screen
                        ld      (PlanetScrnX),hl               ; save projected X Position, 2's compliment
.calculateY:            ld      a,(PBnKysgn)
                        ld      hl,(PBnKylo)
                        call    PlanetProcessVertex            ; now returns carry set for failure
                        ld      (PlanetCompassY),hl
                        ret     c
.calculatedY:           ld      e,ScreenCenterY
                        ld      d,0
                        ex      de,hl
                        ClearCarryFlag
                        sbc     hl,de
                        ;call    HL2cEquHLSgnPlusAusgn       ; correct to center of screen
                        ld      (PlanetScrnY),hl               ; save projected Y Position, 2's compliment
; .........................................................................................................................
                        call    PlanetCalculateRadius
; .........................................................................................................................  
.CheckIfSunOnScreen:    ld      hl,(PlanetScrnX)               ; get x pixel position
                        ld      iyh,0                       ; iyh holds draw status, 0= OK
                        ld      d,0                         ; e still holds radius
                        ld      a,h
                        JumpOnLeadSignSet   h,.CheckXNegative
.CheckXPositive:        ld      a,h
                        JumpIfAIsZero   .XOnScreen          ; if high byte of h is not zero its definitly on screen
                        ld      d,0                         ; de = radius
                        ClearCarryFlag
                        sbc     hl,de
                        jp      m   ,.XOnScreen             ; if result was negative then it spans screen
                        ld      a,h
                        JumpIfAIsZero   .XOnScreen          ; if high byte of h is not zero then its partially on screen at least
                        ret                                 ; None of the X coordinates are on screen
.CheckXNegative:        ld      d,0                         ; de = radius
                        ClearCarryFlag
                        adc     hl,de                       ; so we have hl - de
                        jp      p,.XOnScreen                ; if result was positive then it spans screen so we are good
                        ret                                 ; else x is totally off the left side of the screen
; .........................................................................................................................  
.XOnScreen:             ld      hl,(PlanetScrnY)               ; now Check Y coordinate
                        JumpOnLeadSignSet   h,.CheckYNegative
.CheckYPositive:        ld      a,h
                        JumpIfAIsNotZero   .PosYCheck2
                        ld      a,l
                        and     %10000000
                        jp      z,.YOnScreen                ; at least 1 row is on screen as > 128
.PosYCheck2:            ld      d,0                         ; de = radius
                        ClearCarryFlag
                        sbc     hl,de
                        jp      m,.YOnScreen                ; so if its -ve then it spans screen
                        ld      a,h                         ; if h > 0 then off screen so did not span
                        ReturnIfANotZero                    ; .
                        ld      a,l                         ; if l > 128 then off screen so did not span
                        and     %10000000                   ; .
                        ReturnIfANotZero                    ; .
                        jp      YOnScreen                  ; so Y at least spans
.CheckYNegative:        ld      d,0                         ; de = radius
                        ClearCarryFlag
                        adc     hl,de                       ; so we have hl - de
                        jp      p,.YOnScreen                ; if result was positive then it spans screen so we are good
                        ret                                 ; else never gets above 0 so return
; .........................................................................................................................  
.YOnScreen:             call    PlanetDraw
                        ret

PlanetDraw:             MMUSelectLayer2
                        ld      hl,(PlanetScrnX)
                        ld      de,(PlanetScrnY)
                        ld      a,(PlanetRadius)
                        ld      c,a
                        ld      a,L2ColourGREEN_4
                        call    l2_draw_clipped_circle
                        ret


PlanetBankSize  EQU $ - StartOfPlanet


