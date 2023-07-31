; sets z flag is HL less than 255 else sets it to nz (note opposite of GT127)
IsHLGT255:              MACRO
                        bit     7,h
                        ret     z
                        ld      a,h
                        and     a
                        ENDM
                        
; Sets z flat if HL = 255 else sets it to nz                        
IsHLEqu255:             MACRO
                        ld      a,h
                        and     a               ; if its non zero then it can't be 255
                        ret     nz
                        ld      a,l
                        inc     a               ; if it was 255 the inc will set it to zero
                        ENDM
                        
; Sets Z flag if GT 127 else nz
IsHLGT127:              MACRO       
                        bit     7,h             ; -ve?
                        jr      nz,.DoneCheck
                        ld      a,h             ; +ve > 256?
                        and     a
                        jr      nz,.DoneCheck
                        ld      a,l
                        and     $80             ; this will set z to false if bit 7 set and clear lower bits
                        cp      $80             ; this will set z to true if bit 7 set
.DoneCheck:
                        ENDM

ReturnIfHLGT127:        MACRO       
                        bit     7,h             ; -ve?
                        jr      nz,.DoneCheck   ; forces check complete
                        ld      a,h             ; +ve > 256?
                        and     a               ;
                        ret     nz              ; forces a return
                        bit     7,l             ; bit 7 of lower set?
                        ret     nz              ; forces a return
.DoneCheck:
                        ENDM
                        
IsDEGT127:              MACRO       
                        bit     7,d
                        jr      nz,.DoneCheck
                        ld      a,d
                        jr      nz,.DoneCheck
                        ld      a,e
                        and     $80
.DoneCheck:
                        ENDM

ABSa2c:                 MACRO
                        bit     7,a
                        jp      z,.DoneABSa
                        neg
.DoneABSa:              
                        ENDM                        

DEEquSquareA:           MACRO
                        ld  d,a
                        ld  e,a
                        mul de
                        ENDM

ApplyMyRollToVector:    MACRO angle, vectorX, vectorY
                        ldCopyByte angle,varQ               ; Set Q = a = alpha (the roll angle to rotate through)
                        ldCopy2Byte vectorY, varR           ; RS =  nosev_y
                        ldCopyByte  vectorX, varP           ; set P to nosevX lo (may be redundant)
                        ld a,(vectorX+1)                    ; Set A = -nosev_x_hi
                        xor $80                             ;
                        call  madXAequQmulAaddRS            ; Set (A X) = Q * A + (S R) = = alpha * -nosev_x_hi + nosev_y
                        ld  (vectorY),de                    ; nosev_y = nosev_y - alpha * nosev_x_hi
                        ldCopy2Byte vectorX, varR           ; Set (S R) = nosev_x
                        ld  a,(vectorY+1)                   ;  Set A = nosev_y_hi
                        call madXAequQmulAaddRS             ; Set (A X) = Q * A + (S R)
                        ld  (vectorX),de                    ; nosev_x = nosev_x + alpha * nosev_y_hi
                        ENDM

SignedHLTo2C:           MACRO
                        bit     7,h
                        jr      z,.Done2c
                        ld      a,h
                        and     SignMask8Bit
                        ld      h,a
                        NegHL
.Done2c:                                        
                        ENDM

MemSignedTo2C:          MACRO   memfrom
                        ld      hl,(memfrom)
                        bit     7,h
                        jr      z,.Done2c
                        ld      a,h
                        and     SignMask8Bit
                        ld      h,a
.Done2c:                ld      (memfrom),hl
                        ENDM
                        
                        
    ;returns result in H
EDiv10Inline:           MACRO
                        ld      d,0
                        ld      hl,de 
                        add     hl,hl
                        add     hl,de
                        add     hl,hl
                        add     hl,hl
                        add     hl,de
                        add     hl,hl
                        ENDM
                        
cpHLDE:                 MACRO
                        push    hl
                        and     a
                        sbc     hl,de
                        pop     hl
                        ENDM

cpABSDEHL:              MACRO
                        push     hl,,de
                        ld      a,h
                        and     $7F
                        ld      h,a
                        ld      a,d
                        and     $7F
                        ld      d,a
                        ex      de,hl
                        sbc     hl,de
                        pop     hl,,de
                        ENDM

; Simple are they both the same setting z if they are
; tehcicall this works but it measn the final ret z is alwys done
; so jp needs to be to a target
cpHLEquDE:              MACRO   passedCheck
                        ld      a,h
                        cp      d
                        jp      nz, passedCheck
                        ld      a,l
                        cp      e
.NoTheSame:                        
                        ENDM

cpHLEquBC:              MACRO   passedCheck
                        ld      a,h
                        cp      b
                        jp      nz, passedCheck
                        ld      a,l
                        cp      c
.NoTheSame:                        
                        ENDM
                        
cpDEEquBC:              MACRO   passedCheck
                        ld      a,d
                        cp      b
                        jp      nz, passedCheck
                        ld      a,e
                        cp      c
.NoTheSame:                        
                        ENDM                        
; Simple version just sets carry if HL < DE reset, does an initial compare for z
cpHLDELeadSign:         MACRO
                        ld      a,h
                        cp      d
                        jr      nz,.FullCompare
                        ld      a,l
                        cp      e
                        ret     z
.FullCompare:           ld      a,h
                        xor     d
                        and     $80
                        jr      nz,.OppositeSigns   ; If opposite signs is a simple sign test
                        ld      a,h                 ; same signs so a little simpler
                        and     $80
                        jp      z,cpHLDE            ; if h is positive then both are positive by here so just cpHLDE
                        jp      cpABSDEHL           ; else we have to do ABScpDEHL
.OppositeSigns:         ld      a,h
                        and     $80
                        and     $80
                        jp      z,.HLGTDE
.HLLTDE:                SetCarryFlag
                        ret
.HLGTDE:                ClearCarryFlag
                        ret
                        ENDM
                      
;Unsigned
;If HL == DE, then Z flag is set.
;If HL != DE, then Z flag is reset.
;If HL <  DE, then C flag is set.
;If HL >= DE, then C flag is reset.
;
;Signed
;If HL == DE, then Z flag is set.
;If HL != DE, then Z flag is reset.
;If HL <  DE, then S and P/V are different.
;If HL >= DE, then S and P/V are the same.


N0equN1byN2div256:      MACRO param1,param2,param3
                        ld      a,param3                        ; 
                        ld      e,a                         ; use e as var Q = value of XX15 [n] lo
                        ld      a,param2                        ; A = XX16 element
                        ld      d,a
                        mul
                        ld      a,d                         ; we get only the high byte which is like doing a /256 if we think of a as low                
                        ld      (param1),a                      ; Q         ; result variable = XX16[n] * XX15[n]/256
                        ENDM

AequN1xorN2:            MACRO  param1,param2
                        ld      a,(param1)
                        xor     param2
                        ENDM        

SpeedMulAxis:           MACRO   speedreg, axis
                        ld      e,speedreg
                        ld      hl,(axis)
                        ld      a,h
                        ClearSignBitA
                        ld      d,a
                        mul     de
                        ld      a,h
                        SignBitOnlyA
                        ld      b,a;ld      c,a
                        ld      h,d;ld      e,d
                        ld      c,0;ld      d,0
                        ENDM


AddSpeedToVert:         MACRO   vertex
                        ld      de,(vertex+1)
                        ld      a,(vertex)
                        ld      l,a                       
                        call    AddBCHtoDELsigned               ; DEL = DEL + BCH
                        ld      a,l
                        ld      (vertex),a
                        ld      (vertex+1),de
                        ENDM