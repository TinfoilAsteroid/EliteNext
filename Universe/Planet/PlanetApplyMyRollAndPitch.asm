
;----------------------------------------------------------------------------------------------------------------------------------
; Planet version of pitch and roll is a 24 bit calculation 1 bit sign + 23 bit value
; Need to write a test routine for roll and pitchs
PlanetAlphaMulX            DS 4
PlanetAlphaMulY            DS 4
PlanetBetaMulZ             DS 4
PlanetK2                   DS 3


; Roate around axis
; varAxis1 and varAxis2 point to the address of the axis to rotate
; so the axis x1 points to roofv  x , y or z
;             x2           nosev or sidev  x, y or z
;   Axis1 = Axis1 * (1 - 1/512)  + Axis2 / 16
;   Axis2 = Axis2 * (1 - 1/512)  - Axis1 / 16
; var RAT2 gives direction  
; for pitch x we come in with Axis1 = roofv_x and Axis2 = nosev_x
;-Set up S R -----------------------------------------
; optimised we don't deal with sign here just the value of roof axis / 512
P_MVS5RotateAxis:       ld      hl,(varAxis1)   ; work on roofv axis to get (1- 1/152) * roofv axis
                        ld      e,(hl)
                        inc     hl
                        ld      d,(hl)          ; de = Axis1 (roofv x for pitch x)
                        ex      de,hl           ; hl = Axis1 (roofv x for pitch x)
                        ld      a,h
                        and     SignOnly8Bit                
                        ld      iyh,a           ; iyh = sign Axis1
                        ld      a,h
                        and     SignMask8Bit    ; a = Axis1 (roof hi axis  unsigned)
                        srl     a               ; a = Axis1/2
                        ld      e,a             ; 
                        ld      a,iyh           ; A = Axis 1 sign
                        ld      d,a             ; de = signed Axis1 / 512
                        or      a               ; clear carry
                        call    subHLDES15      ; hl = roof axis - (roof axis /512) which in effect is roof * (1-1/512)
;-Push to stack roof axis - (roofaxis/152)  ----------------------------------------------------------------------------------
                        push    hl              ; save hl on stack PUSH ID 1 (roof axis - roofv aixs /512)
                        ld      a,l
                        ld      (varR),a
                        ld      a,h
                        ld      (varS),a        ;  RS now equals (1- 1/152) * roofv axis or (roof axis - roofv aixs /512)
;-calculate roofv latter half of calc   
                        ld      hl,(varAxis2)   ; now work on nosev axis to get nosev axis / 16
                        ld      e,(hl)
                        inc     hl
                        ld      d,(hl)          ; de = value of roof axis
                        ld      a,d
                        and     SignOnly8Bit
                        ld      iyh,a           ; save sign 
                        ld      a,d 
                        and     SignMask8Bit    ; a = nosev hi axis  unsigned
                        ld      d,a             ; de = abs (nosev)
                        ShiftDERight1
                        ShiftDERight1
                        ShiftDERight1
                        ShiftDERight1           ; de = nosev /16 unsigned
                        ld      a,(univRAT2)     ; need to consider direction, so by defautl we use rat2, but flip via sign bit
                        xor     iyh             ; get the sign back we saveded from DE in so de = nosev axis / 16 signed
                        and     SignOnly8Bit
                        or      d
                        ld      d,a             ; de = nosev /16 signed and ready as if we were doing a + or - based on RAT2            
;;; ld      a,e
;;;     or      iyh
;;; ld      (varP),a        ; PA now equals nosev axis / 16 signed
;-now AP = nosev /16  --------------------------------------------------------------------------------------------------------
                        pop     hl              ; get back RS POP ID 1
    ;ex     de,hl           ; swapping around so hl = AP and de = SR , shoud not matter though as its an add
;-now DE = (roofaxis/512) hl - abs(nosevaxis) --------------------------------------------------------------------------------
                        call    ADDHLDESignedV4 ; do add using hl and de
                        push    hl              ; we use stack to represent var K here now varK = Nosev axis /16 + (1 - 1/512) * roofv axis PUSH ID 2
;-push to stack nosev axis + roofvaxis /512  which is what roofv axis will be ------------------------------------------------  
;-- Set up SR = 1 - 1/512 * nosev-----------------------
                        ld      hl,(varAxis2)   ; work on nosev again to get nosev - novesv / 512
                        ld      e,(hl)
                        inc     hl
                        ld      d,(hl)
                        ex      de,hl
                        ld      a,h
                        and     $80
                        ld      iyh,a
                        ld      a,h
                        and     SignMask8Bit    ; a = roof hi axis  unsigned
                        srl     a               ; now A = unsigned 15 bit nosev axis hi / 2 (or in effect nosev / 512
                        ld      e,a
                        ld      a,iyh
                        ld      d,a
                        or      a               ; clear carry
                        call    subHLDES15
;   sbc     hl,de           ; hl = nosev - novesv / 512
                        push    hl              ; save hl on stack  PUSH ID 3
                        ld      a,l
                        ld      (varP),a        ; p = low of resuilt
                        ld      a,h
                        and     SignMask8Bit    ; a = roof hi axis  unsigned
                        ld      (varT),a        ; t = high of result
;-- Set up TQ
                        ld      hl,(varAxis1)   ; now work on roofv axis / 16
;   ld      hl,(varAxis2)   ; work on nosev again 
                        ld      e,(hl)
                        inc     hl
                        ld      d,(hl)
                        ld      a,d
                        and     $80
                        ld      iyh,a           ; save sign 
                        ld      a,d
                        and     SignMask8Bit    ; a = nosev hi axis  unsigned
                        ld      d,a             ; de = abs (nosev)
                        ShiftDERight1
                        ShiftDERight1
                        ShiftDERight1
                        ShiftDERight1           ; de = nosev /16 unsigned
                        ld      a,(univRAT2)
                        xor     iyh             ; get the sign back in so de = nosev axis / 16 signed
                        and     $80
                        or      d
                        ld      d,a
;;; ld      a,e
;;;     or      iyh
;;; ld      (varP),a        ; PA now equals nosev axis / 16 signed
                        pop     hl              ; get back RS   POP ID 3
;   ex      de,hl           ; swapping around so hl = AP and de = SR , shoud not matter though as its an add
                        call    subHLDES15 ; do add using hl and de
;-- Update nosev ---------------------------------------
                        ex      de,hl           ; save hl to de
                        ld      hl,(varAxis2)
                        ld      (hl),e
                        inc     hl
                        ld      (hl),d          ; copy result into nosev
;-- Update roofv ---------------------------------------
                        pop     de              ; get calc saved on stack POP ID 2
                        ld      hl,(varAxis1)
                        ld      (hl),e
                        inc     hl
                        ld      (hl),d          ; copy result into nosev
                        ret
; Planets don't have pitch and roll so not needed    
;ApplyPlanetPitchOnly:   ld      a,(UBnKRotZCounter)
;                        cp      $FF
;.PitchSAxes:            ld	    hl,P_BnKrotmatRoofvX; UBnkrotmatSidevY
;                        ld	    (varAxis1),hl
;                        ld	    hl,P_BnKrotmatNosevX; UBnkrotmatSidevZ	
;                        ld	    (varAxis2),hl
;                        call    P_MVS5RotateAxis
;.PitchRAxes:            ld	    hl,P_BnKrotmatRoofvY	
;                        ld	    (varAxis1),hl
;                        ld	    hl,P_BnKrotmatNosevY;UBnkrotmatRoofvZ	
;                        ld	    (varAxis2),hl
;                        call    P_MVS5RotateAxis
;.PitchNAxes:            ld	    hl,P_BnKrotmatRoofvZ; UBnkrotmatNosevY	
;                        ld	    (varAxis1),hl
;                        ld	    hl,P_BnKrotmatNosevZ	
;                        ld	    (varAxis2),hl
;                        call    P_MVS5RotateAxis
;                        ret
; Planets don't have pitch and roll so not needed       
;ApplyPlanetRollAndPitch:ld      a,(UBnKRotZCounter)
;                        cp      $FF
;.PitchSAxes:            ld	    hl,P_BnKrotmatRoofvX; UBnkrotmatSidevY
;                        ld	    (varAxis1),hl
;                        ld	    hl,P_BnKrotmatNosevX; UBnkrotmatSidevZ	
;                        ld	    (varAxis2),hl
;                        call    P_MVS5RotateAxis
;.PitchRAxes:            ld	    hl,P_BnKrotmatRoofvY	
;                        ld	    (varAxis1),hl
;                        ld	    hl,P_BnKrotmatNosevY;UBnkrotmatRoofvZ	
;                        ld	    (varAxis2),hl
;                        call    P_MVS5RotateAxis
;.PitchNAxes:            ld	    hl,P_BnKrotmatRoofvZ; UBnkrotmatNosevY	
;                        ld	    (varAxis1),hl
;                        ld	    hl,P_BnKrotmatNosevZ	
;                        ld	    (varAxis2),hl
;                        call    P_MVS5RotateAxis
; Planets don't have pitch and roll so not needed    
;ApplyPlanetRollOnly:
;.ProcessRoll:           ld      a,(P_BnKRotXCounter)
;                        cp      $FF
;.RollSAxis:           	ld	    hl,P_BnKrotmatRoofvX; UBnkrotmatSidevX	
;                        ld	    (varAxis1),hl
;                        ld	    hl,P_BnKrotmatSidevX; UBnkrotmatSidevY
;                        ld	    (varAxis2),hl
;                        call    P_MVS5RotateAxis
;.RollRAxis:             ld	    hl,P_BnKrotmatRoofvY; UBnkrotmatRoofvX	
;                        ld	    (varAxis1),hl
;                        ld	    hl,P_BnKrotmatSidevY; UBnkrotmatRoofvY	
;                        ld	    (varAxis2),hl
;                        call    P_MVS5RotateAxis
;.RollNAxis:             ld	    hl,P_BnKrotmatRoofvZ; UBnkrotmatNosevX
;                        ld	    (varAxis1),hl
;                        ld	    hl,P_BnKrotmatSidevZ; UBnkrotmatNosevY	
;                        ld	    (varAxis2),hl
;                        call    P_MVS5RotateAxis
;                        ret


PlanetApplyMyRollAndPitch: ld      a,(ALPHA)                   ; no roll or pitch, no calc needed
                        ld      hl,BETA
                        or      (hl)
                        and     SignMask8Bit
                        jp      z,.NoRotation
.CalcAlphaMulX:         ld      a,(ALPHA)                   ; get roll magnitude
                        xor     SignOnly8Bit                ; d = -alpha (Q value)
                        ld      d,a                         ; .
                        ld      a,(P_BnKxlo)                 ; HLE = x sgn, hi, lo
                        ld      e,a                         ; .
                        ld      hl,(P_BnKxhi)                ; .
                        call    mulHLEbyDSigned             ; DELC = x * -alpha, so DEL = X * -alpha / 256 where d = sign byte
.SaveAlphaMulX:         ;ld      a,c                         ; a = upper byte of results which will have the sign               ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      (PlanetAlphaMulX),a            ; save sign from result, ELC holds actual result                   ONLY NEEDED FOR DEBUGGING TEST
                        ld      a,l                         ; also save all of alpha *X as we will need it later
                        ld      (PlanetAlphaMulX+1),a
                        ld      a,e
                        ld      (PlanetAlphaMulX+2),a
                        ld      a,d
                        ld      (PlanetAlphaMulX+3),a          ; we actually only want X1 X2 X3 later as its /256
.CalcK2:                ld      de,(P_BnKyhi)                ; DEL = Y
                        ld      a,(P_BnKylo)                 ; .
                        ld      l,a                         ; .
                        ld      bc,(PlanetAlphaMulX+2)         ; BCH = Y sgn, hi, lo, we loose the C from result
                        ld      a,(PlanetAlphaMulX+1)          ; Deal with sign in byte 4
                        ld      h,a                         ; .
                        call    AddBCHtoDELsigned           ; DEL = y - (alpha * x)
                        ld      a,l                         ; K2  = DEA = DEL = y - (alpha * x)
                        ld      (PlanetK2),a                   ; we also need to save l for teh beta k2 calc
                        ld      (PlanetK2+1),de                ; 
.CalcBetaMulK2:         ex      de,hl                       ; HLE == DEA
                        ld      e,a                         ; .
                        ld      a,(BETA)                    ; D = BETA
                        ld      d,a                         ; .
                        call    mulHLEbyDSigned             ; DELC = Beta * K2, DEL = Beta/256 * K2
.CalcZ:                 ld      bc,(P_BnKzhi)                ; BCH = z
                        ld      a,(P_BnKzlo)                 ;
                        ld      h,a                         ;
                        call    AddBCHtoDELsigned           ; DEL still = Beta * K2 so its z + Beta * K2
                        ld      (P_BnKzhi),de                ; z = resuklt
                        ld      a,l                         ; .
                        ld      (P_BnKzlo),a                 ; .
.CalcBetaZ:             ld      a,(BETA)
                        xor     SignOnly8Bit                ; d = -beta (Q value)
                        ld      d,a                         ; .
                        ld      a,(P_BnKzlo)                 ; HLE = z
                        ld      e,a                         ; .
                        ld      hl,(P_BnKzhi)                ; .
                        call    mulHLEbyDSigned             ; DELC = z * -beta, so DEL = Z * -beta / 256 where d = sign byte
.SaveAlphaMulZ:         ;ld      a,c                         ; a = upper byte of results which will have the sign             ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      (PlanetBetaMulZ),a             ; save sign from result, ELC holds actual result                 ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      a,l                         ; also save all of alpha *X as we will need it later             ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      (PlanetBetaMulZ+1),a           ; .                                                              ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      a,e                         ; .                                                              ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      (PlanetBetaMulZ+2),a           ; .                                                              ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      a,d                         ; .                                                              ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      (PlanetBetaMulZ+3),a           ; we actually only want X1 X2 X3 later as its /256               ONLY NEEDED FOR DEBUGGING TEST
.CalcY:                 ld      bc,de                       ; bch = - Beta * z
                        ld      h,l
                        ld      de,(PlanetK2+1)                ; DEL = k2
                        ld      a,(PlanetK2)
                        ld      l,a
                        call    AddBCHtoDELsigned           ; DEL = K2 - Beta * Z
                        ld      (P_BnKyhi),de                ; y = DEL = K2 - Beta * Z
                        ld      a,l                         ; .
                        ld      (P_BnKylo),a                 ; .
.CalcAlphaMulY:         ld      a,(ALPHA)
                        ld      d,a                         ; d = alpha (Q value)
                        ld      a,(P_BnKylo)                 ; HLE = x sgn, hi, lo
                        ld      e,a                         ; .
                        ld      hl,(P_BnKyhi)                ; .
                        call    mulHLEbyDSigned             ; DELC = y * alpha, so DEL = Y * alpha / 256 where d = sign byte
.SaveAlphaMulY:         ld      a,c                         ; a = upper byte of results which will have the sign
                        ld      (PlanetAlphaMulY),a            ; save sign from result, ELC holds actual result
                        ld      a,l                         ; also save all of alpha *X as we will need it later
                        ld      (PlanetAlphaMulY+1),a
                        ld      a,e
                        ld      (PlanetAlphaMulY+2),a
                        ld      a,d
                        ld      (PlanetAlphaMulY+3),a                                             
.CalcxPLusAlphaY:       ld      bc,de                        ; BCH = Y sgn, hi, lo, we loose the C from result Deal with sign in byte 4
                        ld      h,l                         ; .
                        ld      de,(P_BnKxhi)                ; DEL = Y
                        ld      a,(P_BnKxlo)                 ; .
                        ld      l,a                         ; .
                        call    AddBCHtoDELsigned           ; DEL = x + alpha * Y
.SaveResult1:           ld      a,d                         ; Result 1 (X) = AHL + DEL
                        ld      h,e                         ;
.CopyResultTo2:         ld      (P_BnKxlo+2),a               ; .
                        ld      (P_BnKxlo) ,hl               ; .
                        ret
.NoRotation:            ld      a,(DELTA)                   ; BCH = - Delta
                        ReturnIfAIsZero
                        ld      c,0                         ;
                        ld      h,a                         ; 
                        ld      b,$80                       ;
                        ld      de,(P_BnKzhi)                ; DEL = z position
                        ld      a,(P_BnKzlo)                 ; .
                        ld      l,a                         ; .
                        call    AddBCHtoDELsigned           ; update speed
                        ld      (P_BnKzhi),DE                ; write back to zpos
                        ld      a,l
                        ld      (P_BnKzlo),a                ;
                        ret
