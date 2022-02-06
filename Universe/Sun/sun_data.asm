fdraw; In  flight ship data tables
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
CheckRowHLOnScreen:     MACRO   failtarget
                        ld      a,h                             ; is greater than 128
                        and     a                               ; or negative
                        jr      nz,failtarget                   ; h <> 0 so fails (covers <0 and > 255
                        ld      a,l                             ; l bit 7 0?
                        bit     7,a                             ;  covers l > 127
                        jr      nz,failtarget                   ;
                        ENDM

IYEquRowN:              MACRO   rowValue                        ; set up iy as target address
                        ld      a,rowValue
                        ld      hl,SBnKLineArray
                        add     hl,a
                        add     hl,a
                        push    hl
                        pop     iy
                        ENDM
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

SBnKLineArray               DS SunLineArraySize ; XX19 Holds the clipped line details
SBnKLinesHeapMax            EQU $ - SBnKLineArray

LineArrayPtr                DW  0
 
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

                        
.SunNoDraw:             SetCarryFlag                    ; ship is behind so do not draw, so we don't care abour draw as dot
                        ret


                        
SunBankDraw:            MACRO
.drawLoop               ld      a,(hl)
                        ld      c,a                     ; c = left column
                        inc     hl
                        ld      d,(hl)                  ; d = right col
                        inc     hl                      ; now ready for next linel
                        push    hl,,bc
                        cp      d                       ; if both points are the same then no line (we will ignore single pixel as it can't happen at this stage other than tips of circles)
                        IfResultZeroGoto .NoLineDraw
                        ld      a,d                     ; get right col back
                        sub     c                       ; subtract left so a = length
                        inc     a                       ; so its at least 1 , TODO add cp jr c logic in dma routine so that it does non dma if line < x 
                        call    z, .FixWidth
                        ld      d,a                     ; de = length (e - d)
                        ld      e,216                   ; yellow
                        call    l2_draw_horz_dma        ; draw without bank switch
.NoLineDraw:            pop     hl,,bc
                        inc     b
                        dec     iyh
                        IfResultNotZeroGoto  .drawLoop
                        ENDM


                        
SunDraw:                MMUSelectLayer2
.OptimiseStartPos:      ld      a,(MinYOffset)
                        JumpIfAIsZero .OffsetIsZero     ; if offset is 0 then just initate as normal
                        JumpIfALTNusng 64, .OffsetLT64  ; if offset >=64 then we adjust and mve to bank 0
.OffsetGTE64:           sub     64
                        ld      (MinYOffset),a          ; adjust offset for bank 2
                        jp      .StartBank2
.OffsetIsZero:          ld      b,0                     ; row
                        ld      iyh,64                  ; counter
                        ld      hl,SBnKLineArray        ; set hl to start of array
                        jp      .StartBank1
;-- Snuck routine in here so that the macro will be happier                        
.FixWidth:              dec     a                       ; if carry resulted in a value of zero then correct
                        ret                        
.OffsetLT64:            ld      hl,SBnKLineArray        ; adjust hl for line array offset
                        add     hl,a                    ; .
                        add     hl,a                    ; .
                        ld      b,a                     ; set b row to the actual offset
                        ld      c,a                     ; iyh = 64 - Y offset
                        ld      a,64                    ; .
                        sub     c                       ; .
                        ld      iyh,a
                        xor     a                       ; Ready bank 2 with no offset
                        ld      (MinYOffset),a          ; .
.StartBank1:            exx
                        ld      a,LAYER2_SHIFTED_SCREEN_TOP
                        call    asm_l2_bank_select      ; get in the first bank, we will only then bank select when needed
                        exx
                        SunBankDraw
.StartBank2:            ld      a,(MinYOffset)
                        JumpIfAIsZero .OffsetBank2IsZero; if offset is 0 then we just continue, offset can never be >127 else there would be no draw
.NotZeroOffset:         ld      hl,SBnKLineArray + (64 * 2); adjust to correct offset
                        add     hl,a
                        add     hl,a
                        ld      c,a                     ; iyh = 64 - offset
                        ld      a,64                    ; .
                        sub     c                       ; .
                        ld      iyh,a                   ; .
                        ld      b,c                     ; b = offset row
                        jp      .drawLineBank2
.OffsetBank2IsZero:     ld      hl,SBnKLineArray + (64 * 2); start with offset adjusted 
                        ld      b,0
                        ld      iyh,64
.drawLineBank2:         exx
                        ld      a,LAYER2_SHIFTED_SCREEN_MIDDLE
                        call    asm_l2_bank_select      ; now do the lower bank
                        exx
; Could make this a sub routine but unwrapping saves a call                        
                        SunBankDraw
                        ret
                        
; --------------------------------------------------------------
; This sets current universe object to a star / sun, they use sign + 23 bit positions
CreateSun:              ;break
                        call    ResetSBnKData
                        ld      a,(WorkingSeeds+3)
                        and     %00000111
                        and     %00000001;DEBUG TO DO
                        
                        or      %10000001 ;so working seed byte 3, take lower 3 bits, make sure 0 is set for negative z
                        ld      (SBnKzsgn),a
                        ld      a,(WorkingSeeds+5)
                        and     %00000011
                        ld      (SBnKxsgn),a
                        ld      (SBnKysgn),a
                     ; DEBUG   ld      hl, $0000
                     ; DEBUG   ld      (SBnKzhi),hl
                     ; DEBUG   ld      a, $E3
                     ; DEBUG   ld      (SBnKzlo),a
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

SunOnScreen             DB 0
cLineArrayPtr            DW 0
LineCount               DB 0
RaggedSize              DB 0
MinYOffset              DB 0
MaxYOffSet              DB 0
XCentre                 DW  0       ; signed
YCentre                 DW  0       ; signed
SunRadius               DB  0       ; unsigned
; draw circle               

                        
SunUpdateAndRender:     call    SunApplyMyRollAndPitch
.CheckDrawable:         ld      a,(SBnKzsgn)
                        and     SignOnly8Bit
                        ret     nz
.CheckDist48:           ReturnIfAGTENusng 48                ; at a distance over 48 its too far away
                        ld      hl,(SBnKzhi)                ; if the two high bytes are zero then its too close
                        or      (hl)
                        ReturnIfAIsZero
.SunProjectToEye:       ld      de,(SBnKzlo)                ; X Pos = X / Z
                        ld      a,(SBnKzsgn)                ; CDE = z
                        ld      c,a                         ;
                        ld      hl,(SBnKxlo)                ; AHL = x
                        ld      a,(SBnKxsgn)                ;
                        call    Div24by24LeadSign           ; could do 16 bit in reality 
.CheckPosOnScreenX:     ld      a,c                         ;
                        and     SignMask8Bit                ; a= abs highest byte
                        ret     nz                          ; off screen
                        ld      a,d                         ; if high byte >=4 then off screen (we can do this as ABS
                        cp      4                           ; 
                        ret     nc                          ; off screen
                        ld      l,e
                        ld      a,d
                        or      c                           ; we know that C can only hold a sign bit if its on screen
                        ld      h,l
                        ld      a,ScreenCenterX
                        call    AddAusngToHLsng             ; correct to center of screen
                        ld      (XCentre),hl                ; save projected X Position
.caclYProj:             ld      de,(SBnKzlo)                ; calc center y 
                        ld      a,(SBnKzsgn)                ; cde = z
                        ld      c,a                         ;
                        ld      hl,(SBnKylo)                ; ahl = y
                        ld      a,(SBnKysgn)                ;
                        call    Div24by24LeadSign           ;
.CheckPosOnScreenY:     ld      a,c
                        and     SignMask8Bit                ; a= abs highest byte
                        ret     nz                          ; off screen
                        ld      a,d                         ; if high byte >=4 then off screen (we can do this as ABS
                        cp      4                           ; 
                        ret     nc                          ; off screen
                        ld      l,e
                        ld      a,d
                        or      c                           ; we know that C can only hold a sign bit if its on screen
                        ld      h,l
                        ld      a,ScreenCenterY
                        call    HLEequAusngMinusHLsng
                        ld      (YCentre),hl                  ; save projected T Position
.ClearLineArray:        ld      hl,SBnKLineArray            ; we load start and end as 0
                        ld		de, SunLineArraySize        ; just if we get a 0,0 genuine we will not plot it
                        ld		a,0
                        call	memfill_dma
                        ;break
.CalculateRadius:       ld      de,(SBnKzlo)
                        ld      a,(SBnKzsgn)
                        ld      c,a
                        ld      hl,$6000  ; was hl          ; planet radius at Z = 1 006000
                        xor     a
                        call    Div24by24LeadSign           ; radius = AHL/CDE = 24576 / distance z
                        ld      a,d
                        cp      0
                        jr      z,.SkipSetK
                        ld      e,248                       ;set radius to 248 as maxed out
.SkipSetK:              ld      hl,SBnKLineArray
                        ld      (LineArrayPtr),hl
                        xor     a
                        ld      (LineCount),a
                        ld      d,0
.SetRaggedEdgeMax:      ld      a,e
                        ld      e,0
                        ld      (SunRadius),a
                        cp      96
                        FlipCarryFlag
                        rl      e
                        cp      40
                        FlipCarryFlag
                        rl      e
                        cp      16
                        FlipCarryFlag
                        rl     e
                        ld      a,e
                        ; DEBUGGING DIAG for FUZZING CODE, LOOKS OK THOUGH ld      a,%00000001; DEBUG RAGGED
                        ld      (RaggedSize),a
.GetMinY:               ld      hl,(YCentre)
                        ld      a,h
                        and     SignOnly8Bit
                        jr      nz,.NegativeY               ; if its neative then we start with 0 as it can only go up screen after radius
                        ld      a,(SunRadius)               ; raged does not affect Y axis
                        ld      e,a
                        ld      d,0
                        ClearCarryFlag
                        sbc     hl,de                       ; hl now is a 2's c value if its negative else still +ve
                        jp      m, .NegativeY
                        ld      a,h
                        and     SignMask8Bit
                        ret     nz                          ; if its off screen then its not to be processed
                        ld      a,l
                        ReturnIfAGTENusng 128                ; if min is off screen then not to be processed
                        jp      .SetMinY
.NegativeY:             xor     a
.SetMinY:               ld      (MinYOffset),a              ; so now we have Y top of screen
.GetMaxY:               ld      hl,(YCentre)
                        ld      a,h
                        and     SignMask8Bit
                        jr      nz,.MaxPosY                 ; if its neative then we start with 0 as it can only go up screen after radius
                        ld      a,(SunRadius)
                        add     hl,a
                        ld      a,l
                        JumpIfAGTENusng 128, .MaxPosY
                        ld      a,e
                        add     a,l
                        JumpIfAGTENusng 128, .MaxPosY
                        JumpIfOverflow     .MaxPosY
                        ld      a,e
                        call    AddAusngToHLsng
                        ld      a,h
                        and     SignOnly8Bit
                        ret     nz                ; if max is negative then its off screen too
                        ld      a,h
                        and     SignMask8Bit                ; if h had a value then its max Y as well
                        ld      a,l
                        JumpIfAGTENusng 128, .MaxPosY         ; if l > 127 then max Y as well
                        jr      nz, .MaxPosY
                        jp      .SetMinY
.MaxPosY:               ld      a,127
.SetMaxY                ld      (MaxYOffSet),a              ; so now we have min and max Y coordinates and proj holds center
                        ;break
                        call    SunDrawCircle
                        call    SunDraw
                        ret
;.. Now we caluclate the circle of the star
;.. its from MinY down the screen to MaxY center ProjX,ProjY.                
;.. We can use the circle draw logic gtom Bressenham's algorithm
; so now there are the following conditions to consider
; y min = 0   y center is negative radius <= ABS (Y center)             => Don't draw
; y min = 0   y center is negative radius > ABS (Y center)+1            => Draw bottom half only
; y max = 127 y center is > 127    radius <= y center - 127             => Don't draw
; y max = 127 y center is > 127    radius > y center - 127              => Draw top half only
; y min >= 0  y center > y min     we don't need to worry about radius  => Draw both halves
; x center + radius < 0                                                 => Don't draw
; x center - radius > 255                                               => Don't draw
; we won't consider x more here as the driver is the y coordinate but we will check if x is vaiable
; x point = max (x point, 0)   on left 
; x point = min (x point, 255) on right

SetIYPlusOffset:        MACRO   reg
                        push    hl,,iy                          ; save hl, then hl = iy
                        pop     hl                              ;
                        ld      a,reg
                        add     hl,a
                        add     hl,a
                        push    hl
                        pop     iy
                        pop     hl
                        ENDM

SetIYMinusOffset:       MACRO   reg
                        push    de,,hl,,iy                      ; save hl, then hl = iy
                        pop     hl                              ;
                        ld      a,reg
                        add     a,a
                        ld      e,a
                        ld      d,0
                        ClearCarryFlag
                        sbc     hl,de
                        push    hl
                        pop     iy
                        pop     de,,hl
                        ENDM
                      

SunDrawCircle:          
.CheckRadius:           ld      a,(SunRadius)                   ;we could do this early 
                        and     a
                        ret     z
                        cp      1
                        jp      z,SunCircleSinglePixel
.MakeCentreX2C:         MemSignedTo2C XCentre
.MakeCentreY2C:         MemSignedTo2C YCentre
.PrepCircleData:        ld      ixl,0
                        ld		(.Plot1+1),bc			        ; save origin into DE reg in code
                        ld		ixh,a							; ixh = radius
                        ld		ixl,0						    ; ixl = delta
.calcd:	                ld		h,0                             ; de = radius * 2
                        ld		l,a                             ; .
                        add		hl,hl							; .
                        ex		de,hl							; .
                        ld		hl,3                            ; hl = 3
                        and		a                               ; hl = 3 - (r * 2)
                        sbc		hl,de							; .
                        ld		b,h                             ; bc = 3 - (r * 2) : d = 3 - 2r
                        ld		c,l								; .
.calcdelta:             ld		hl,1                            ; set hl to 1
                        ld		d,0                             ; de = ixl
                        ld		e,ixl                           ;
                        and		a                               ;
                        sbc		hl,de                           ; hl = 1 - ixl
.Setde1:                ld		de,1                            ; del = 1
.CircleLoop:            ld		a,ixh                           ; if x = y then exit
                        cp		ixl                             ;
                        ret		c                               ;
.ProcessLoop:	        exx                                     ; save out registers
; Process CY+Y CX+X & CY+Y CX-X..................................
.Plot1:                 ld      hl, (YCentre)
.Get1YRow:              ld      a,ixh                           
                        add     hl,a                            ; Check to see if CY+Y
.Check1YRowOnScreen:    CheckRowHLOnScreen .NoTopPixelPair
.Write1YCoord:          SetIYPlusOffset ixh
                        IYEquRowN l                             ; set up iy as target address
                        ld      a,ixl
                        call    ProcessXRowA
.NoTopPixelPair:
; Process CY-Y CX+X & CY-Y CX-X..................................
.Plot2:                 ld      hl, (YCentre)
.Get2YRow:              ld      d,0
                        ld      e,ixh
                        ClearCarryFlag
                        sbc     hl,de
.Check2YRowOnScreen:    CheckRowHLOnScreen .NoBottomPixelPair
                        SetIYMinusOffset ixh
.Write2YCoord:          IYEquRowN l                             ; set up iy as target address
                        ld      a,ixl
                        call    ProcessXRowA
.NoBottomPixelPair:
; Process CY+X CX+Y & CY+X CX-Y..................................
.Plot3:                 ld      hl, (YCentre)
.Get3YRow:              ld      a,ixl                          
                        add     hl,a                            ; Check to see if CY+Y
.Check3YRowOnScreen:    CheckRowHLOnScreen .NoTop3PixelPair
                        SetIYPlusOffset ixl
.Write3YCoord:          IYEquRowN l                             ; set up iy as target address
                        ld      a,ixh
                        call    ProcessXRowA
.NoTop3PixelPair:
; Process CY-X CX+Y & CY-X CX-Y..................................
.Plot4:                 ld      hl, (YCentre)
.Get4YRow:              ld      d,0
                        ld      e,ixl
                        ClearCarryFlag
                        sbc     hl,de
.Check4YRowOnScreen:    CheckRowHLOnScreen .NoBottom4PixelPair
                        SetIYMinusOffset ixl
.Write4YCoord:          IYEquRowN l                             ; set up iy as target address
                        ld      a,ixh
                        call    ProcessXRowA
.NoBottom4PixelPair:
; Completed one iteration........................................
                        exx
.IncrementCircle:	    bit     7,h				; Check for Hl<=0
                        jr z,   .draw_circle_1
                        add hl,de			; Delta=Delta+D1
                        jr      .draw_circle_2		; 
.draw_circle_1:		    add     hl,bc			; Delta=Delta+D2
                        inc     bc
                        inc     bc				; D2=D2+2
                        dec     ixh				; Y=Y-1
.draw_circle_2:		    inc bc				; D2=D2+2
                        inc bc
                        inc de				; D1=D1+2
                        inc de	
                        inc ixl				; X=X+1
                        jp      .CircleLoop
SunCircleSinglePixel:     ld      hl,(XCentre)
                        ld      a,h
                        and     a
                        ret     nz                  ; if the high byte is set then no pixel
                        ld      c,l
                        ld      hl,(YCentre)
                        ld      a,h
                        and     a
                        ret     nz                  ; if the high byte is set then no pixel
                        ld      a,l
                        bit     7,a
                        ret     nz                  ; if l > 127 then no pixel
                        ld      b,a
                        ld		a,e
                        call	l2_plot_pixel_y_test
                        ret

ProcessXRowA:           ;break
                        ld      hl,(XCentre)                    ; get X Center
                        push    af                              ; save A (curent offset +/- value
                        add     hl,a                            ; Hl = HL + offset
                        ld      a,h                             ; is HL negative?, if so then set C to 0
                        bit     7,a                             ;
                        jr      nz,.XCoordNegative              ; We can have this for non X + Radius i.e. the equater
                        and     a                               ; if H <> 0? (why by here must be +ve), set c to $FF
                        jr      nz,.XCoordMaxed                 ; .
                        ld      c,l                             ; else set c to l and do the -ve offset
.AddFuzz:               push    bc
                        call    doRandom                        ; c = c - random AND ragged Size
                        pop     bc
                        ld      hl,RaggedSize                   ;
                        and     (hl)                            ;
                        add     c                               ;
                        ld      c,a                             ;
                        jr      c,.XCoordMaxed                  ; has fuzz caused a carry, if so > 255 to make 255
                        jp      .ProcessSubtract                ; 
.XCoordNegative:        ld      c,0                             ; if it was negative then 0
                        jp      .ProcessSubtract
.XCoordMaxed:           ld      c,255                           ; if it was +ve then 255
.ProcessSubtract:       pop     af                              ; get offset back
                        ld      e,a                             ; but goes into DE as its a subtract
                        ld      d,0
                        ld      hl,(XCentre)                    ; so do subtract
                        ClearCarryFlag                          ; .
                        sbc     hl,de                           ; .
                        jp      m,.XCoordLeftNegative           ; again test for min max
.AddFuzzSubtract:       push    hl,,bc
                        call    doRandom                        ; c = c - random AND ragged Size
                        pop     bc
                        ld      hl,RaggedSize                   ;
                        and     (hl)                            ;
                        ld      e,a
                        pop     hl
                        sbc     hl,de
                        jp      m,.XCoordLeftNegative           ; again test for min max
                        ld      a,h
                        and     a
                        jp      nz,.XCordLeftMaxed
                        ld      b,l
                        jp      .CompletedXCoords
.XCoordLeftNegative:    ld      b,0                        
                        jp      .CompletedXCoords
.XCordLeftMaxed:        ld      b,255
.CompletedXCoords:      ld      a,b
.RowSaveIY1             ld      (iy+0),a                        ; iy holds current line array index
                        ld      a,c
.RowSaveIY3             ld      (iy+1),a
                        ret
                
; .....................................................
; if the universe object is a planet or sun then do that instead
;;TODOProcessPlanet:          cp      129
;;TODO                        jr      nz, .ItsAPlanet
;;TODO.ItsAStar:              ld      a,(SBnKzsgn)
;;TODO                        cp      48                               ; if z > 48 (it must be positive to enter this routine)
                        
                        
; Square Root using tables
; DE = number to find                        
SunLookupSqrtDE:        ld      hl,SunSquareRootTable
.LookupCorseJump:       ld      a,d
                        add     hl,a
                        add     hl,a
                        ld      a,(hl)
                        inc     hl
                        ld      h,(hl)
                        ld      l,a
.FineSearchLoop:        ld      a,(hl)
                        JumpIfAEqNusng  e, .FoundByte
                        JumpIfAGTENusng e, .PreviousByte
.NotFound:              inc     hl
                        inc     hl
                        jp      .FineSearchLoop
.FoundByte:             inc     hl
                        ld      a,(hl)
                        ret
.PreviousByte:          dec     hl
                        ld      a,(hl)
                        ret

SunRootHighIndex:       DW SunSqr00,SunSqr01,SunSqr02,SunSqr03,SunSqr04,SunSqr05,SunSqr06,SunSqr07,SunSqr08,SunSqr09,SunSqr0A,SunSqr0B,SunSqr0C,SunSqr0D,SunSqr0E,SunSqr0F
                        DW SunSqr10,SunSqr11,SunSqr12,SunSqr13,SunSqr14,SunSqr15,SunSqr16,SunSqr17,SunSqr18,SunSqr19,SunSqr1A,SunSqr1B,SunSqr1C,SunSqr1D,SunSqr1E,SunSqr1F
                        DW SunSqr20,SunSqr21,SunSqr22,SunSqr23,SunSqr24,SunSqr25,SunSqr26,SunSqr27,SunSqr28,SunSqr29,SunSqr2A,SunSqr2B,SunSqr2C,SunSqr2D,SunSqr2E,SunSqr2F
                        DW SunSqr30,SunSqr31,SunSqr32,SunSqr33,SunSqr34,SunSqr35,SunSqr36,SunSqr37,SunSqr38,SunSqr39,SunSqr3A,SunSqr3B,SunSqr3C,SunSqr3D,SunSqr3E,SunSqr3F
                        DW SunSqr40,SunSqr41,SunSqr42,SunSqr43,SunSqr44,SunSqr45,SunSqr46,SunSqr47,SunSqr48,SunSqr49,SunSqr4A,SunSqr4B,SunSqr4C,SunSqr4D,SunSqr4E,SunSqr4F
                        DW SunSqr50,SunSqr51,SunSqr52,SunSqr53,SunSqr54,SunSqr55,SunSqr56,SunSqr57,SunSqr58,SunSqr59,SunSqr5A,SunSqr5B,SunSqr5C,SunSqr5D,SunSqr5E,SunSqr5F
                        DW SunSqr60,SunSqr61,SunSqr62,SunSqr63,SunSqr64,SunSqr65,SunSqr66,SunSqr67,SunSqr68,SunSqr69,SunSqr6A,SunSqr6B,SunSqr6C,SunSqr6D,SunSqr6E,SunSqr6F
                        DW SunSqr70,SunSqr71,SunSqr72,SunSqr73,SunSqr74,SunSqr75,SunSqr76,SunSqr77,SunSqr78,SunSqr79,SunSqr7A,SunSqr7B,SunSqr7C,SunSqr7D,SunSqr7E,SunSqr7F
                        DW SunSqr80,SunSqr81,SunSqr82,SunSqr83,SunSqr84,SunSqr85,SunSqr86,SunSqr87,SunSqr88,SunSqr89,SunSqr8A,SunSqr8B,SunSqr8C,SunSqr8D,SunSqr8E,SunSqr8F
                        DW SunSqr90,SunSqr91,SunSqr92,SunSqr93,SunSqr94,SunSqr95,SunSqr96,SunSqr97,SunSqr98,SunSqr99,SunSqr9A,SunSqr9B,SunSqr9C,SunSqr9D,SunSqr9E,SunSqr9F
                        DW SunSqrA0,SunSqrA1,SunSqrA2,SunSqrA3,SunSqrA4,SunSqrA5,SunSqrA6,SunSqrA7,SunSqrA8,SunSqrA9,SunSqrAA,SunSqrAB,SunSqrAC,SunSqrAD,SunSqrAE,SunSqrAF
                        DW SunSqrB0,SunSqrB1,SunSqrB2,SunSqrB3,SunSqrB4,SunSqrB5,SunSqrB6,SunSqrB7,SunSqrB8,SunSqrB9,SunSqrBA,SunSqrBB,SunSqrBC,SunSqrBD,SunSqrBE,SunSqrBF
                        DW SunSqrC0,SunSqrC1,SunSqrC2,SunSqrC3,SunSqrC4,SunSqrC5,SunSqrC6,SunSqrC7,SunSqrC8,SunSqrC9,SunSqrCA,SunSqrCB,SunSqrCC,SunSqrCD,SunSqrCE,SunSqrCF
                        DW SunSqrD0,SunSqrD1,SunSqrD2,SunSqrD3,SunSqrD4,SunSqrD5,SunSqrD6,SunSqrD7,SunSqrD8,SunSqrD9,SunSqrDA,SunSqrDB,SunSqrDC,SunSqrDD,SunSqrDE,SunSqrDF
                        DW SunSqrE0,SunSqrE1,SunSqrE2,SunSqrE3,SunSqrE4,SunSqrE5,SunSqrE6,SunSqrE7,SunSqrE8,SunSqrE9,SunSqrEA,SunSqrEB,SunSqrEC,SunSqrED,SunSqrEE,SunSqrEF
                        DW SunSqrF0,SunSqrF1,SunSqrF2,SunSqrF3,SunSqrF4,SunSqrF5,SunSqrF6,SunSqrF7,SunSqrF8,SunSqrF9,SunSqrFA,SunSqrFB,SunSqrFC,SunSqrFD,SunSqrFE,SunSqrFF

SunSquareRootTable:
SunSqr00:               DB $00,   0
                        DB $04,   2
                        DB $10,   4
                        DB $24,   6
                        DB $40,   8
                        DB $64,  10
                        DB $90,  12
                        DB $C4,  14
                        DB $FF,  15
SunSqr01:               DB $00,  16
                        DB $21,  17
                        DB $44,  18
                        DB $69,  19
                        DB $90,  20
                        DB $B9,  21
                        DB $FF,  22
SunSqr02:               DB $11,  23
                        DB $40,  24
                        DB $71,  25
                        DB $A4,  26
                        DB $D9,  27
                        DB $FF,  27
SunSqr03:               DB $10,  28
                        DB $49,  29
                        DB $84,  30
                        DB $C1,  31
                        DB $FF,  31
SunSqr04:               DB $00,  32
                        DB $41,  33
                        DB $84,  34
                        DB $FF,  35
SunSqr05:               DB $10,  36
                        DB $59,  37
                        DB $A4,  38
                        DB $FF,  39
SunSqr06:               DB $40,  40
                        DB $91,  41
                        DB $E4,  42
                        DB $FF,  42
SunSqr07:               DB $39,  43
                        DB $90,  44
                        DB $E9,  45
                        DB $FF,  45
SunSqr08:               DB $44,  46
                        DB $A1,  47
                        DB $FF,  47
SunSqr09:               DB $00,  48
                        DB $61,  49
                        DB $C4,  50
                        DB $FF,  50
SunSqr0A:               DB $29,  51
                        DB $90,  52
                        DB $FF,  53
SunSqr0B:               DB $64,  54
                        DB $FF,  55
SunSqr0C:               DB $40,  56
                        DB $B1,  57
                        DB $FF,  57
SunSqr0D:               DB $24,  58
                        DB $99,  59
                        DB $FF,  59
SunSqr0E:               DB $10,  60
                        DB $89,  61
                        DB $FF,  61
SunSqr0F:               DB $04,  62
                        DB $81,  63
                        DB $FF,  63
SunSqr10:               DB $00,  64
                        DB $81,  65
                        DB $FF,  65
SunSqr11:               DB $04,  66
                        DB $89,  67
                        DB $FF,  67
SunSqr12:               DB $10,  68
                        DB $99,  69
                        DB $FF,  69
SunSqr13:               DB $24,  70
                        DB $B1,  71
                        DB $FF,  71
SunSqr14:               DB $40,  72
                        DB $FF,  73
SunSqr15:               DB $64,  74
                        DB $FF,  75
SunSqr16:               DB $FF,  76
SunSqr17:               DB $C4,  77
                        DB $FF,  78
SunSqr18:               DB $61,  79
                        DB $FF,  79
SunSqr19:               DB $00,  80
                        DB $FF,  81
SunSqr1A:               DB $44,  82
                        DB $FF,  83
SunSqr1B:               DB $90,  84
                        DB $FF,  84
SunSqr1C:               DB $39,  85
                        DB $FF,  86
SunSqr1D:               DB $FF,  87
SunSqr1E:               DB $40,  88
                        DB $FF,  89
SunSqr1F:               DB $FF,  90
SunSqr20:               DB $59,  91
                        DB $FF,  91
SunSqr21:               DB $10,  92
                        DB $FF,  93
SunSqr22:               DB $FF,  94
SunSqr23:               DB $FF,  95
SunSqr24:               DB $00,  96
                        DB $FF,  97
SunSqr25:               DB $84,  98
SunSqr26:               DB $49,  99
SunSqr27:               DB $10, 100
                        DB $FF, 101
SunSqr28:               DB $FF, 102
SunSqr29:               DB $FF, 103
SunSqr2A:               DB $FF, 104
SunSqr2B:               DB $11, 105
                        DB $FF, 106
SunSqr2C:               DB $FF, 107
SunSqr2D:               DB $FF, 108
SunSqr2E:               DB $69, 109
                        DB $FF, 110
SunSqr2F:               DB $44, 110
                        DB $FF, 111
SunSqr30:               DB $21, 111
                        DB $FF, 112
SunSqr31:               DB $00, 112
                        DB $FF, 113
SunSqr32:               DB $C4, 114
                        DB $FF, 114
SunSqr33:               DB $FF, 115
SunSqr34:               DB $90, 116
                        DB $FF, 117
SunSqr35:               DB $79, 117
                        DB $FF, 118
SunSqr36:               DB $64, 118
                        DB $64, 119
SunSqr37:               DB $51, 119
SunSqr38:               DB $40, 120
                        DB $FF, 121
SunSqr39:               DB $31, 121
                        DB $FF, 122
SunSqr3A:               DB $24, 122
                        DB $FF, 123
SunSqr3B:               DB $19, 123
                        DB $FF, 124
SunSqr3C:               DB $10, 124
                        DB $FF, 125
SunSqr3D:               DB $09, 125
                        DB $FF, 125
SunSqr3E:               DB $04, 126
                        DB $FF, 126
SunSqr3F:               DB $01, 127
                        DB $FF, 127
SunSqr40:               DB $00, 128
                        DB $FF, 128
SunSqr41:               DB $01, 129
                        DB $FF, 130
SunSqr42:               DB $04, 130
                        DB $FF, 131
SunSqr43:               DB $09, 131
                        DB $FF, 132
SunSqr44:               DB $10, 132
                        DB $FF, 133
SunSqr45:               DB $19, 133
                        DB $FF, 134
SunSqr46:               DB $24, 134
                        DB $FF, 135
SunSqr47:               DB $31, 135
                        DB $FF, 136
SunSqr48:               DB $40, 136
                        DB $FF, 137
SunSqr49:               DB $51, 137
                        DB $FF, 138
SunSqr4A:               DB $64, 138
                        DB $FF, 138
SunSqr4B:               DB $79, 139
                        DB $FF, 139
SunSqr4C:               DB $90, 140
                        DB $FF, 140
SunSqr4D:               DB $A9, 141
                        DB $FF, 141
SunSqr4E:               DB $C4, 142
                        DB $FF, 142
SunSqr4F:               DB $E1, 143
                        DB $FF, 143
SunSqr50:               DB $FF, 143
SunSqr51:               DB $00, 144
                        DB $FF, 144
SunSqr52:               DB $21, 145
                        DB $FF, 145
SunSqr53:               DB $44, 146
                        DB $FF, 146
SunSqr54:               DB $69, 147
                        DB $FF, 147
SunSqr55:               DB $90, 148
                        DB $FF, 148
SunSqr56:               DB $B9, 149
                        DB $FF, 149
SunSqr57:               DB $E4, 150
                        DB $FF, 150
SunSqr58:               DB $FF, 150
SunSqr59:               DB $11, 151
                        DB $FF, 151
SunSqr5A:               DB $40, 152
                        DB $FF, 152
SunSqr5B:               DB $71, 153
                        DB $FF, 153
SunSqr5C:               DB $A4, 154
                        DB $FF, 154
SunSqr5D:               DB $D9, 155
                        DB $FF, 155
SunSqr5E:               DB $FF, 155
SunSqr5F:               DB $10, 156
                        DB $FF, 156
SunSqr60:               DB $49, 157
                        DB $FF, 157
SunSqr61:               DB $84, 158
                        DB $FF, 158
SunSqr62:               DB $C1, 159
                        DB $FF, 159
SunSqr63:               DB $FF, 159
SunSqr64:               DB $00, 160
                        DB $FF, 160
SunSqr65:               DB $41, 161
                        DB $FF, 161
SunSqr66:               DB $84, 162
                        DB $FF, 162
SunSqr67:               DB $C9, 163
                        DB $FF, 163
SunSqr68:               DB $FF, 163
SunSqr69:               DB $10, 164
                        DB $FF, 164
SunSqr6A:               DB $59, 165
                        DB $FF, 165
SunSqr6B:               DB $A4, 166
                        DB $FF, 166
SunSqr6C:               DB $FF, 167
SunSqr6D:               DB $FF, 167
SunSqr6E:               DB $40, 168
                        DB $FF, 168
SunSqr6F:               DB $91, 169
                        DB $FF, 169
SunSqr70:               DB $E4, 170
                        DB $FF, 170
SunSqr71:               DB $00, 170
                        DB $FF, 170
SunSqr72:               DB $39, 171
                        DB $FF, 171
SunSqr73:               DB $90, 172
                        DB $FF, 172
SunSqr74:               DB $E9, 173
                        DB $FF, 173
SunSqr75:               DB $FF, 173
SunSqr76:               DB $44, 174
                        DB $FF, 174
SunSqr77:               DB $A1, 175
                        DB $FF, 175
SunSqr78:               DB $FF, 175
SunSqr79:               DB $00, 176
                        DB $FF, 176
SunSqr7A:               DB $61, 177
                        DB $FF, 177
SunSqr7B:               DB $C4, 178
                        DB $FF, 178
SunSqr7C:               DB $FF, 178
SunSqr7D:               DB $29, 179
                        DB $FF, 179
SunSqr7E:               DB $90, 180
                        DB $FF, 180
SunSqr7F:               DB $F9, 181
                        DB $FF, 181
SunSqr80:               DB $FF, 181
SunSqr81:               DB $64, 182
                        DB $FF, 182
SunSqr82:               DB $D1, 183
SunSqr83:               DB $FF, 183
                        DB $FF, 183
SunSqr84:               DB $40, 184
                        DB $FF, 184
SunSqr85:               DB $B1, 185
                        DB $FF, 185
SunSqr86:               DB $FF, 185
SunSqr87:               DB $24, 186
                        DB $FF, 186
SunSqr88:               DB $99, 187
                        DB $FF, 187
SunSqr89:               DB $FF, 187
SunSqr8A:               DB $10, 188
                        DB $FF, 188
SunSqr8B:               DB $89, 189
                        DB $FF, 189
SunSqr8C:               DB $FF, 189
SunSqr8D:               DB $04, 190
                        DB $FF, 190
SunSqr8E:               DB $81, 191
                        DB $FF, 191
SunSqr8F:               DB $FF, 191
SunSqr90:               DB $00, 192
                        DB $FF, 192
SunSqr91:               DB $81, 193
                        DB $FF, 193
SunSqr92:               DB $FF, 193
SunSqr93:               DB $04, 194
                        DB $FF, 194
SunSqr94:               DB $89, 195
                        DB $FF, 195
SunSqr95:               DB $FF, 195
SunSqr96:               DB $10, 196
                        DB $FF, 196
SunSqr97:               DB $99, 197
                        DB $FF, 197
SunSqr98:               DB $FF, 197
SunSqr99:               DB $24, 198
                        DB $FF, 198
SunSqr9A:               DB $B1, 199
                        DB $FF, 199
SunSqr9B:               DB $FF, 199
SunSqr9C:               DB $40, 200
                        DB $FF, 200
SunSqr9D:               DB $D1, 201
                        DB $FF, 201
SunSqr9E:               DB $FF, 201
SunSqr9F:               DB $64, 202
                        DB $FF, 202
SunSqrA0:               DB $F9, 203
                        DB $FF, 203
SunSqrA1:               DB $FF, 203
SunSqrA2:               DB $90, 204
                        DB $FF, 204
SunSqrA3:               DB $FF, 204
SunSqrA4:               DB $29, 205
                        DB $FF, 205
SunSqrA5:               DB $C4, 206
                        DB $FF, 206
SunSqrA6:               DB $FF, 206
SunSqrA7:               DB $61, 207
                        DB $FF, 207
SunSqrA8:               DB $FF, 207
SunSqrA9:               DB $00, 208
                        DB $FF, 208
SunSqrAA:               DB $A1, 209
                        DB $FF, 209
SunSqrAB:               DB $FF, 209
SunSqrAC:               DB $44, 210
                        DB $FF, 210
SunSqrAD:               DB $E9, 211
                        DB $FF, 211
SunSqrAE:               DB $FF, 211
SunSqrAF:               DB $90, 212
SunSqrB0:               DB $FF, 212
SunSqrB1:               DB $39, 213
                        DB $FF, 213
SunSqrB2:               DB $E4, 214
                        DB $FF, 214
SunSqrB3:               DB $FF, 214
SunSqrB4:               DB $91, 215
                        DB $FF, 215
SunSqrB5:               DB $FF, 215
SunSqrB6:               DB $40, 216
                        DB $FF, 216
SunSqrB7:               DB $F1, 217
                        DB $FF, 217
SunSqrB8:               DB $FF, 217
                        DB $FF, 217
SunSqrB9:               DB $A4, 218
SunSqrBA:               DB $FF, 218 ; we can reuse SunSeqrBA as  $FF for B9 terminator as well as they have the same target
SunSqrBB:               DB $59, 219
                        DB $FF, 219
SunSqrBC:               DB $FF, 219
SunSqrBD:               DB $10, 220
                        DB $FF, 220
SunSqrBE:               DB $C9, 221
                        DB $FF, 221
SunSqrBF:               DB $FF, 221
SunSqrC0:               DB $84, 222
                        DB $FF, 222
SunSqrC1:               DB $FF, 222
SunSqrC2:               DB $41, 223
                        DB $FF, 223
SunSqrC3:               DB $FF, 223
SunSqrC4:               DB $00, 224
                        DB $FF, 224
SunSqrC5:               DB $C1, 225
                        DB $FF, 225
SunSqrC6:               DB $FF, 225
SunSqrC7:               DB $84, 226
SunSqrC8:               DB $FF, 226
SunSqrC9:               DB $49, 227
                        DB $FF, 227
SunSqrCA:               DB $FF, 228
SunSqrCB:               DB $10, 228
                        DB $FF, 228
SunSqrCC:               DB $D9, 229
                        DB $FF, 229
SunSqrCD:               DB $FF, 229
SunSqrCE:               DB $A4, 230
                        DB $FF, 230
SunSqrCF:               DB $FF, 230
SunSqrD0:               DB $71, 231
                        DB $FF, 231
SunSqrD1:               DB $FF, 231
SunSqrD2:               DB $40, 232
                        DB $FF, 232
SunSqrD3:               DB $FF, 232
SunSqrD4:               DB $11, 233
                        DB $FF, 233
SunSqrD5:               DB $E4, 234
                        DB $FF, 234
SunSqrD6:               DB $FF, 234
SunSqrD7:               DB $B9, 235
                        DB $FF, 235
SunSqrD8:               DB $FF, 235
SunSqrD9:               DB $90, 236
                        DB $FF, 236
SunSqrDA:               DB $FF, 236
SunSqrDB:               DB $69, 237
                        DB $FF, 237
SunSqrDC:               DB $FF, 237
SunSqrDD:               DB $44, 238
SunSqrDE:               DB $FF, 238
SunSqrDF:               DB $21, 239
                        DB $FF, 239
SunSqrE0:               DB $00, 240
                        DB $FF, 240
SunSqrE1:               DB $00, 240
                        DB $FF, 240
SunSqrE2:               DB $E1, 241
                        DB $FF, 241
SunSqrE3:               DB $E1, 241
                        DB $FF, 241
SunSqrE4:               DB $C4, 242
                        DB $FF, 242
SunSqrE5:               DB $FF, 242
SunSqrE6:               DB $A9, 243
                        DB $FF, 243
SunSqrE7:               DB $FF, 243
                        DB $FF, 243
SunSqrE8:               DB $90, 243
                        DB $FF, 244
SunSqrE9:               DB $FF, 244
SunSqrEA:               DB $79, 245
                        DB $FF, 245
SunSqrEB:               DB $FF, 245
SunSqrEC:               DB $64, 246
SunSqrED:               DB $FF, 246
SunSqrEE:               DB $51, 247
                        DB $FF, 247
SunSqrEF:               DB $FF, 247
SunSqrF0:               DB $40, 248
SunSqrF1:               DB $FF, 248
SunSqrF2:               DB $31, 249
                        DB $FF, 249
SunSqrF3:               DB $FF, 249
SunSqrF4:               DB $24, 250
                        DB $FF, 250
SunSqrF5:               DB $FF, 250
SunSqrF6:               DB $19, 251
                        DB $FF, 251
SunSqrF7:               DB $FF, 251
SunSqrF8:               DB $10, 252
                        DB $FF, 252
SunSqrF9:               DB $FF, 252
SunSqrFA:               DB $09, 253
                        DB $FF, 253
SunSqrFB:               DB $FF, 253
SunSqrFC:               DB $04, 254
                        DB $FF, 254
SunSqrFD:               DB $FF, 254
SunSqrFE:               DB $01, 255
SunSqrFF:               DB $FF, 255                                       
                        
               

SunBankSize  EQU $ - StartOfSun


