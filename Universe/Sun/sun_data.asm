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
StartOfSun:        DB "Sun and Planet X"
; NOTE we can cheat and pre allocate segs just using a DS for now

;   \ -> & 565D \ See ship data files chosen and loaded after flight code starts running.
; Universe map substibute for INWK
;-Camera Position of Ship----------------------------------------------------------------------------------------------------------
                        INCLUDE "./Universe/Sun/SunPosVars.asm"
                        INCLUDE "./Universe/Sun/SunRotationMatrixVars.asm"
                        INCLUDE "./Universe/Sun/SunAIRuntimeData.asm"


                        INCLUDE "./Universe/Sun/SunXX16Vars.asm"
                        INCLUDE "./Universe/Sun/SunXX25Vars.asm"
                        INCLUDE "./Universe/Sun/SunXX18Vars.asm"

; Used to make 16 bit reads a little cleaner in source code
SBnKzPoint                  DS  3
SBnKzPointLo                equ SBnKzPoint
SBnKzPointHi                equ SBnKzPoint+1
SBnKzPointSign              equ SBnKzPoint+2
                        INCLUDE "./Universe/Sun/SunXX15Vars.asm"
                        INCLUDE "./Universe/Sun/SunXX12Vars.asm"


; Post clipping the results are now 8 bit
SBnKVisibility              DB  0               ; replaces general purpose xx4 in rendering
SBnKProjectedY              DB  0
SBnKProjectedX              DB  0
SBnKProjected               equ SBnKProjectedY  ; resultant projected position
SunXX15Save                 DS  8
SunXX15Save2                DS  8
; Heap (or array) information for lines and normals
; Coords are stored XY,XY,XY,XY
; Normals
; This needs re-oprganising now.
; Runtime Calculation Store

SunLineArraySize            equ 128 * 2
; Storage arrays for data
; Structure of arrays
; Visibility array  - 1 Byte per face/normal on ship model Bit 7 (or FF) visible, 0 Invisible
; Node array corresponds to a processed vertex from the ship model transformed into world coordinates and tracks the node list from model
; NodeArray         -  4 bytes per element      0           1            2          3
;                                               X Coord Lo  Y Coord Lo   Z CoordLo  Sign Bits 7 6 5 for X Y Z Signs (set = negative)
; Line Array        -  4 bytes per eleement     0           1            2          3
;                                               X1          Y1           X2         Y2
SBnKLineArray               DS SunLineArraySize * 4        ; XX19 Holds the clipped line details
SBnKLinesHeapMax            EQU $ - SBnKLineArray
 
SBnK_Data_len               EQU $ - StartOfUniv

; --------------------------------------------------------------
ResetSBnKData:          ld      hl,StartOfUniv
                        ld      de,SBnK_Data_len
                        xor     a
                        call    memfill_dma
                        ret
; --------------------------------------------------------------
ResetSBnKPosition:      ld      hl,SBnKxlo
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

                        
.SunNoDraw:             SetCarryFlag                        ; ship is behind so do not draw, so we don't care abour draw as dot
                        ret
                        
SunDraw:                MMUSelectLayer2
                        xor     a
                        call    asm_l2_bank_select      ; get in the first bank, we will only then bank select when needed
                        ld      hl,SBnKLineArray
                        ld      b,64
                        ld      c,0
.drawLineLoop1:         push    hl,,bc
                        ld      a,(hl)
                        ld      d,a
                        ld      e,(hl)
                        and     e                       ; if both points are zero then no line
                        jr      z,.NoLine
                        ld      c,d
                        ld      a,e
                        sub     d
                        ld      d,a                     ; de = length (e - d)
                        ld      e,216                   ; yellow
                        call    l2_draw_horz_dma
                        pop     hl,,bc                  ; is it quicker to use iy ??
                        inc     c
                        inc     hl
                        dec     b
                        djnz    .drawLineLoop1
                        ld      a,1
                        call    asm_l2_bank_select      ; now do the lower bank
                        ld      c,0                     ; reset the row as we have moved to a new bank
                        ld      b,64
; Could make this a sub routine but unwrapping saves a call                        
.drawLineLoop2:         push    hl,,bc
                        ld      a,(hl)
                        ld      d,a
                        ld      e,(hl)
                        and     e                       ; if both points are zero then no line
                        jr      z,.NoLine
                        ld      c,d
                        ld      a,e
                        sub     d
                        ld      d,a                     ; de = length (e - d)
                        ld      e,216                   ; yellow
                        call    l2_draw_horz_dma
.NoLine                 pop     hl,,bc                  ; is it quicker to use iy ??
                        inc     c
                        inc     hl
                        dec     b
                        djnz    .drawLineLoop2
                        ret
                        
; --------------------------------------------------------------
; This sets current universe object to a star / sun, they use sign + 23 bit positions
CreateSun:              call    ResetSBnKData
                        ld      a,(WorkingSeeds+3)
                        and     %00000111
                        or      %10000001 ;so working seed byte 3, take lower 3 bits, make sure 0 is set for negative z
                        ld      (SBnKzsgn),a
                        ld      a,(WorkingSeeds+5)
                        and     %00000011
                        ld      (SBnKzsgn),a
                        ld      (SBnKysgn),a
                        ret
; --------------------------------------------------------------                        
; This sets current universe object to a planet,they use sign + 23 bit positions
;;TODOCreatePlanet:           call    ResetSBnKData
;;TODO                        ld      a,(DisplayTekLevel)
;;TODO                        and     $00000010               ; Set A = 128 or 130 depending on bit 1 of the system's tech level
;;TODO                        or      $10000000
;;TODO                        ld      (SBnKShipType),a
;;TODO                        xor     a
;;TODO                        ld      (SBnKaiatkecm),a
;;TODO                        MaxUnivPitchAndRoll
;;TODO                        ld      a,(WorkingSeeds+1)      ; a= bits 1 and 0 of working seed1 + 3 + carry
;;TODO                        and     %00000011               ; .
;;TODO                        adc     3                       ; .
;;TODO                        ld      (SBnKzsgn),a            ; set z sign to 3 + C + 0..3 bits
;;TODO                        rr      a
;;TODO                        ld      (PlanetXsgn),a
;;TODO                        ld      (PlanetYsgn),a
;;TODO                        ret


                   ;     include "./Maths/ADDHLDESignBC.asm"

SunADDHLDESignedv3:     ld      a,h
                        and     SignOnly8Bit
                        ld      b,a                         ;save sign bit in b
                        xor     d                           ;if h sign and d sign were different then bit 7 of a will be 1 which means 
                        JumpIfNegative .SunADDHLDEOppSGN    ;Signs are opposite there fore we can subtract to get difference
.SunADDHLDESameSigns:   ld      a,b
                        or      d
                        JumpIfNegative .SunADDHLDESameNeg   ; optimisation so we can just do simple add if both positive
                        JumpIfNegative .SunADDHLDESameNeg   ; optimisation so we can just do simple add if both positive
                        add     hl,de
                        ret
.SunADDHLDESameNeg:     ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a
                        add     hl,de
                        ld      a,SignOnly8Bit
                        or      h                           ; now set bit for negative value, we won't bother with overflow for now TODO
                        ld      h,a
                        ret
.SunADDHLDEOppSGN:      ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit                     ; here HL and DE are opposite 
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a
                        or      a
                        sbc     hl,de
                        jr      c,.SunADDHLDEOppInvert
.SunADDHLDEOppSGNNoCarry:   ld      a,b                         ; we got here so hl > de therefore we can just take hl's previous sign bit
                        or      h
                        ld      h,a                         ; set the previou sign value
                        ret
.SunADDHLDEOppInvert:       NegHL                                                   ; we need to flip the sign and 2'c the Hl result
                        ld      a,b
                        xor     SignOnly8Bit                ; flip sign bit
                        or      h
                        ld      h,a                         ; recover sign
                        ret 
                
; we could cheat, flip the sign of DE and just add but its not very optimised
.SunSUBHLDESignedv3:        ld      a,h
                        and     SignOnly8Bit
                        ld      b,a                         ;save sign bit in b
                        xor     d                           ;if h sign and d sign were different then bit 7 of a will be 1 which means 
                        JumpIfNegative .SunSUBHLDEOppSGN        ;Signs are opposite therefore we can add
.SunSUBHLDESameSigns:       ld      a,b
                        or      d
                        JumpIfNegative .SunSUBHLDESameNeg       ; optimisation so we can just do simple add if both positive
                        or      a
                        sbc     hl,de
                        JumpIfNegative .SunSUBHLDESameOvrFlw            
                        ret
.SunSUBHLDESameNeg:         ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a
                        or      a
                        sbc     hl,de
                        JumpIfNegative .SunSUBHLDESameOvrFlw            
                        ld      a,h                         ; now set bit for negative value, we won't bother with overflow for now TODO
                        or      SignOnly8Bit
                        ld      h,a
                        ret
.SunSUBHLDESameOvrFlw:      NegHL                                                        ; we need to flip the sign and 2'c the Hl result
                        ld      a,b
                        xor     SignOnly8Bit                ; flip sign bit
                        or      h
                        ld      h,a                         ; recover sign
                        ret         
.SunSUBHLDEOppSGN:          or      a                                               ; here HL and DE are opposite so we can add the values
                        ld      a,h                         ; so if we enter here then signs are the same so we clear the 16th bit
                        and     SignMask8Bit                ; we could check the value of b for optimisation
                        ld      h,a
                        ld      a,d
                        and     SignMask8Bit
                        ld      d,a     
                        add     hl,de
                        ld      a,b                         ; we got here so hl > de therefore we can just take hl's previous sign bit
                        or      h
                        ld      h,a                         ; set the previou sign value
                        ret

    
.SunSBCHLDESigned:      JumpOnBitSet h,7,.SunSBCHLDEhlNeg
.SunSBCHLDEhlPos:       JumpOnBitSet h,7,.SunSBCHLDEhlNeg
.SunSBCHLDEhlPosDePos:  sbc     hl,de                           ; ignore overflow for now will sort later TODO
                        ret
.SunSBCHLDEhlPosDeNeg:  res     7,d
                        add     hl,de                           ; ignore overflow for now will sort later TODO
                        set     7,d
                        ret
.SunSBCHLDEhlNeg:       res     7,h
                        JumpOnBitSet d,7,.SunSBCHLDEhlNegdeNeg
.SunSBCHLDEhlNegdePos:  sbc     hl,de                       ; ignore overflow for now will sort later TODO
                        set     7,h     
                        ret
.SunSBCHLDEhlNegdeNeg:      res     7,d
                        add     hl,de                   ; ignore overflow for now will sort later TODO
                        set     7,d
                        set     7,h
                        ret
    

    
;                    include "Universe/InitialiseOrientation.asm"
;----------------------------------------------------------------------------------------------------------------------------------
;;;
;;;Project:
;;;PROJ:                   ld      hl,(SBnKxlo)                    ; Project K+INWK(x,y)/z to K3,K4 for center to screen
;;;                        ld      (varP),hl
;;;                        ld      a,(SBnKxsgn)
;;;                        call    PLS6                            ; returns result in K (0 1) (unsigned) and K (3) = sign note to no longer does 2's C
;;;                        ret     c                               ; carry means don't print
;;;                        ld      hl,(varK)                       ; hl = k (0 1)
;;;                        ; Now the question is as hl is the fractional part, should this be multiplied by 127 to get the actual range
;;;                        ld      a,ViewCenterX
;;;                        add     hl,a                            ; add unsigned a to the 2's C HL to get pixel position
;;;                        ld      (varK3),hl                      ; K3 = X position on screen
;;;ProjectY:               ld      hl,(SBnKylo)
;;;                        ld      (varP),hl
;;;                        ld      a,(SBnKysgn)
;;;                        call    PLS6
;;;                        ret     c
;;;                        ld      hl,(varK)                       ; hl = k (0 1)
;;;                        ld      a,ViewCenterY
;;;                        add     hl,a                            ; add unsigned a to the 2's C HL to get pixel position
;;;                        ld      (varK4),hl                      ; K3 = X position on screen
;;;                        ret
;--------------------------------------------------------------------------------------------------------
;                        include "./ModelRender/EraseOldLines-EE51.asm"
;                        include "./ModelRender/TrimToScreenGrad-LL118.asm"
;                        include "./ModelRender/CLIP-LL145.asm"
;--------------------------------------------------------------------------------------------------------
;                        include "./Variables/CopyRotmatToTransMat.asm"
                        include "./Universe/Sun/TransposeSunXX12BySunToSunXX15.asm"


ScaleSunTo8Bit:			ld			bc,(SBnKZScaled)
                        ld			hl,(SBnKXScaled)
                        ld			de,(SBnKYScaled)		
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
.SignsDoneSaveResult:	ld			(SBnKZScaled),bc
                        ld			(SBnKXScaled),hl
                        ld			(SBnKYScaled),de
                        ld			a,b
                        ld			(varU),a
                        ld			a,c
                        ld			(varT),a
                        ret

;--------------------------------------------------------------------------------------------------------
;;;;X = normal scale
;;;;ZtempHi = zhi
;;;;......................................................
;;;; if ztemp hi <> 0                                   ::Scale Object Distance
;;;;  Loop                                              ::LL90
;;;;     inc X
;;;;     divide X, Y & ZtempHiLo by 2
;;;;  Until ZtempHi = 0
;;;;......................................................
;-LL21---------------------------------------------------------------------------------------------------
;                        include "./Universe/NormaliseTransMat.asm"
;-LL91---------------------------------------------------------------------------------------------------

; Now we have
;   * XX18(2 1 0) = (x_sign x_hi x_lo)
;   * XX18(5 4 3) = (y_sign y_hi y_lo)
;   * XX18(8 7 6) = (z_sign z_hi z_lo)
;
;--------------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------
;   XX12(1 0) = [x y z] . sidev  = (dot_sidev_sign dot_sidev_lo)  = dot_sidev
;   XX12(3 2) = [x y z] . roofv  = (dot_roofv_sign dot_roofv_lo)  = dot_roofv
;   XX12(5 4) = [x y z] . nosev  = (dot_nosev_sign dot_nosev_lo)  = dot_nosev
; Returns
;
;   XX12(1 0)            The dot product of [x y z] vector with the sidev (or _x)
;                        vector, with the sign in XX12+1 and magnitude in XX12
;
;   XX12(3 2)            The dot product of [x y z] vector with the roofv (or _y)
;                        vector, with the sign in XX12+3 and magnitude in XX12+2
;
;   XX12(5 4)            The dot product of [x y z] vector with the nosev (or _z)
;                        vector, with the sign in XX12+5 and magnitude in XX12+4


 ; TESTEDOK
SXX12DotOneRow:
SXX12CalcX:              N0equN1byN2div256 varT, (hl), (SBnKXScaled)       ; T = (hl) * regSunXX15fx /256 
                        inc     hl                                  ; move to sign byte
SXX12CalcXSign:          AequN1xorN2 SBnKXScaledSign,(hl)             ;
                        ld      (varS),a                            ; Set S to the sign of x_sign * sidev_x
                        inc     hl
SXX12CalcY:              N0equN1byN2div256 varQ, (hl),(SBnKYScaled)       ; Q = XX16 * SunXX15 /256 using varQ to hold regSunXX15fx
                        ldCopyByte varT,varR                        ; R = T =  |sidev_x| * x_lo / 256
                        inc     hl
                        AequN1xorN2 SBnKYScaledSign,(hl)             ; Set A to the sign of y_sign * sidev_y
; (S)A = |sidev_x| * x_lo / 256  = |sidev_x| * x_lo + |sidev_y| * y_lo
SSTequSRplusAQ           push    hl
                        call    baddll38                            ; JSR &4812 \ LL38   \ BADD(S)A=R+Q(SA) \ 1byte add (subtract)
                        pop     hl
                        ld      (varT),a                            ; T = |sidev_x| * x_lo + |sidev_y| * y_lo
                        inc     hl
SXX12CalcZ:              N0equN1byN2div256 varQ,(hl),(SBnKZScaled)       ; Q = |sidev_z| * z_lo / 256
                        ldCopyByte varT,varR                        ; R = |sidev_x| * x_lo + |sidev_y| * y_lo
                        inc     hl
                        AequN1xorN2 SBnKZScaledSign,(hl)             ; A = sign of z_sign * sidev_z
; (S)A= |sidev_x| * x_lo + |sidev_y| * y_lo + |sidev_z| * z_lo        
                        call    baddll38                            ; JSR &4812 \ LL38   \ BADD(S)A=R+Q(SA)   \ 1byte add (subtract)
; Now we exit with A = result S = Sign        
                        ret



;--------------------------------------------------------------------------------------------------------
                        include "./Universe/Sun/CopySunXX12ScaledToSunXX18.asm"
;                        include "./Variables/CopySunXX12toSunXX15.asm"
;                       include "./Variables/CopySunXX18toSunXX15.asm"
;                       include "./Variables/CopySunXX18ScaledToSunXX15.asm"
;                       include "./Variables/CopySunXX12ToScaled.asm"
;--------------------------------------------------------------------------------------------------------
;                        include "./Maths/Utilities/DotProductXX12SunXX15.asm"
;--------------------------------------------------------------------------------------------------------

ScaleDownSXX15byIXH:    dec     ixh
                        ret     m
                        ld      hl,SBnKXScaled
                        srl     (hl)                        ; SunXX15  \ xnormal lo/2 \ LL93+3 \ counter X
                        inc     hl                          ; looking at SunXX15 x sign now
                        inc     hl                          ; looking at SunXX15 y Lo now
                        srl     (hl)                        ; SunXX15+2    \ ynormal lo/2
                        inc     hl                          ; looking at SunXX15 y sign now
                        inc     hl                          ; looking at SunXX15 z Lo now
                        srl     (hl)
                        jp      ScaleDownSXX15byIXH
                        ret

DivideSXX18By2:         ld      hl,SBnKDrawCam0xLo
                        srl     (hl)                        ; XX18  \ xnormal lo/2 \ LL93+3 \ counter X
                        inc     hl                          ; looking at XX18 x sign now
                        inc     hl                          ; looking at XX18 y Lo now
                        srl     (hl)                        ; XX18+2    \ ynormal lo/2
                        inc     hl                          ; looking at XX18 y sign now
                        inc     hl                          ; looking at XX18 z Lo now
                        srl     (hl)
                        ret

; ......................................................                                                         ;;; 

SunProjectToEye:
	ld			bc,(SBnKZScaled)					; BC = Z Cordinate. By here it MUST be positive as its clamped to 4 min
	ld			a,c                                 ;  so no need for a negative check
	ld			(varQ),a		                    ; VarQ = z
    ld          a,(SBnKXScaled)                     ; SunXX15	\ rolled x lo which is signed
	call		DIV16Amul256dCUNDOC					; result in BC which is 16 bit TODO Move to 16 bit below not just C reg
    ld          a,(SBnKXScaledSign)                 ; SunXX15+2 \ sign of X dist
    JumpOnBitSet a,7,.EyeNegativeXPoint             ; LL62 up, -ve Xdist, RU screen onto XX3 heap
.EyePositiveXPoint:									; x was positive result
    ld          l,ScreenCenterX						; 
    ld          h,0
    add         hl,bc								; hl = Screen Centre + X
    jp          EyeStoreXPoint
.EyeNegativeXPoint:                                 ; x < 0 so need to subtract from the screen centre position
    ld          l,ScreenCenterX                     
    ld          h,0
    ClearCarryFlag
    sbc         hl,bc                               ; hl = Screen Centre - X
.EyeStoreXPoint:                                    ; also from LL62, XX3 node heap has xscreen node so far.
    ex          de,hl
    ld          (iy+0),e                            ; Update X Point TODO this bit is 16 bit aware just need to fix above bit
    ld          (iy+1),d                            ; Update X Point
.EyeProcessYPoint:
	ld			bc,(SBnKZScaled)					; Now process Y co-ordinate
	ld			a,c
	ld			(varQ),a
    ld          a,(SBnKYScaled)                     ; SunXX15	\ rolled x lo
	call		DIV16Amul256dCUNDOC	                ; a = Y scaled * 256 / zscaled
    ld          a,(SBnKYScaledSign)                 ; SunXX15+2 \ sign of X dist
    JumpOnBitSet a,7,.EyeNegativeYPoint             ; LL62 up, -ve Xdist, RU screen onto XX3 heap top of screen is Y = 0
.EyePositiveYPoint:									; Y is positive so above the centre line
    ld          l,ScreenCenterY
    ClearCarryFlag
    sbc         hl,bc  							 	; hl = ScreenCentreY - Y coord (as screen is 0 at top)
    jp          EyeStoreYPoint
.EyeNegativeYPoint:									; this bit is only 8 bit aware TODO FIX
    ld          l,ScreenCenterY						
    ld          h,0
    add         hl,bc								; hl = ScreenCenterY + Y as negative is below the center of screen
.EyeStoreYPoint:                                    ; also from LL62, XX3 node heap has xscreen node so far.
    ex          de,hl
    ld          (iy+2),e                            ; Update Y Point
    ld          (iy+3),d                            ; Update Y Point
    ret
    
    
    
; Pitch and roll are 2 phases
; 1 - we apply our pitch and roll to the ship position
;       x -> x + alpha * (y - alpha * x)
;       y -> y - alpha * x - beta * z
;       z -> z + beta * (y - alpha * x - beta * z)
; which can be simplified as:
;       1. K2 = y - alpha * x
;       2. z = z + beta * K2
;       3. y = K2 - beta * z
;       4. x = x + alpha * y
; 2 - we apply our patch and roll to the ship orientation
;      Roll calculations:
;      
;        nosev_y = nosev_y - alpha * nosev_x_hi
;        nosev_x = nosev_x + alpha * nosev_y_hi
;      Pitch calculations:
;      
;        nosev_y = nosev_y - beta * nosev_z_hi
;        nosev_z = nosev_z + beta * nosev_y_hi


            INCLUDE "./Universe/Sun/SunApplyMyRollAndPitch.asm"
;            INCLUDE "./Universe/SunApplyShipRollAndPitch.asm"

XProj       DS 3
YProj       DS 3
SunUpdateAndRender:     call    SunApplyMyRollAndPitch
.CheckDrawable:         ld      a,(SBnKzsgn)
                        and     SignOnly8Bit
                        ret     nz
.CheckDist48:           ReturnIfAGTENusng 48
                        ld      hl,(SBnKzhi)                ; are zhigh and zsng both 0, if so too close
                        or      (hl)
                        ReturnIfAIsZero
;.ProjectCentreOfSunX:   ld      hl,(SBnKzLo)
;                        ex      hl,de
;                        ld      a,(SBnKzsgn)
;                        ld      c,a
;                        ld      hl,(SBnKXLo)
;                        ld      a,(SBnKXsgn)
;                        call    Div24by24LeadSign
;
;                        ret     c                           ; if carry way set then off screen
;                        
.PojectCenterOfSunX:    ld      hl,(SBnKzlo)
                        ld      (varP),hl
                        ld      a,(SBnKzsgn)
                        ld      (varPhi2),a
                        ld      hl,(SBnKzhi)
                        
                        ld      a,ViewCenterX
                        add     hl,a
                        
.ProjectCentreOfSunY:   ld      hl,(SBnKzlo)
                        ex      hl,de
                        ld      a,(SBnKzsgn)
                        ld      c,a
                        ld      hl,(SBnKylo)
                        ld      a,(SBnKysgn)
                        call    Div24by24LeadSign

                        ret     c                           ; if carry way set then off screen
                        
                        ld      a,ViewCenterY
                        add     hl,a


                          ; no need to do set carry so just return
.CalculateRadius:       ld      hl,(SBnKzlo)
                        ld      a,(SBnKzsgn)
                        ex      hl,de
                        ld      c,a

                        ld      hl,$6000                    ; planet radius at Z = 1
                        xor     a
                        call    Div24by24LeadSign
                        ld      a,d
                        cp      0
                        jr      z,.SkipSetK
                        ld      c,248
.SkipSetK:              
                        
               
                        
                            
; .....................................................
; if the universe object is a planet or sun then do that instead
;;TODOProcessPlanet:          cp      129
;;TODO                        jr      nz, .ItsAPlanet
;;TODO.ItsAStar:              ld      a,(SBnKzsgn)
;;TODO                        cp      48                               ; if z > 48 (it must be positive to enter this routine)
                        
                        

SunBankSize  EQU $ - StartOfSun
