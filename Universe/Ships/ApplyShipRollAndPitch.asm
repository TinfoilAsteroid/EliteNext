
; A = value for rotation
; HL = address of value for rotation
; TODO logic for permanent spin, I thik this it -127??
SplitAndDampenZ:        MACRO
                        ld      a,(UBnKRotZCounter)
                        ld      b,a
                        and     SignMask8Bit            ; if abs (Rotz) is 0 then skip
                        jp      z,.ProcessRoll  
                        ld      a,b                     ; b = rotate counter S7
                        and     SignOnly8Bit            ; a = sign rat2 = c = sign
                        ld      c,a                     ; .
                        ld      (univRAT2),a            ; .
                        ld      a,b                     ; a = abs b
                        and     SignMask8Bit            ; .
                        dec     a                       ; dampen
                        ld      (univRAT2Val),a
                        or      c                       ; make S7 again after dampening
                        ld      (UBnKRotZCounter),a
                        ENDM
                        
SplitAndDampenX:        MACRO
                        ld      a,(UBnKRotXCounter)
                        ld      b,a
                        and     SignMask8Bit            ; exit early is ABS = 0
                        and     a                       ; .
                        ret     z                       ; .
                        ld      a,b                     ; a = rotate counter S7
                        and     SignOnly8Bit            ; rat2 = c = sign
                        ld      c,a                     ; .
                        ld      (univRAT2),a            ; .
                        ld      a,b                     ; a = abs b
                        and     SignMask8Bit            ; .
                        dec     a                       ; dampen
                        ld      (univRAT2Val),a
                        or      c                       ; make S7 again after dampening
                        ld      (UBnKRotXCounter),a
                        ENDM
                        

;----------------------------------------------------------------------------------------------------------------------------------
; based on MVEIT part 4 of 9
; x and z counters are proper 2's c values
ApplyShipRollAndPitch:  SplitAndDampenZ
.PitchSAxes:            ld	    hl,UBnkrotmatRoofvX; UBnkrotmatSidevY
                        ld	    (varAxis1),hl
                        ld	    hl,UBnkrotmatNosevX; UBnkrotmatSidevZ	
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
.PitchRAxes:            ld	    hl,UBnkrotmatRoofvY	
                        ld	    (varAxis1),hl
                        ld	    hl,UBnkrotmatNosevY;UBnkrotmatRoofvZ	
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
.PitchNAxes:            ld	    hl,UBnkrotmatRoofvZ; UBnkrotmatNosevY	
                        ld	    (varAxis1),hl
                        ld	    hl,UBnkrotmatNosevZ	
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
.ProcessRoll:           SplitAndDampenX
.RollSAxis:           	ld	    hl,UBnkrotmatRoofvX; UBnkrotmatSidevX	
                        ld	    (varAxis1),hl
                        ld	    hl,UBnkrotmatSidevX; UBnkrotmatSidevY
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
.RollRAxis:             ld	    hl,UBnkrotmatRoofvY; UBnkrotmatRoofvX	
                        ld	    (varAxis1),hl
                        ld	    hl,UBnkrotmatSidevY; UBnkrotmatRoofvY	
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
.RollNAxis:             ld	    hl,UBnkrotmatRoofvZ; UBnkrotmatNosevX
                        ld	    (varAxis1),hl
                        ld	    hl,UBnkrotmatSidevZ; UBnkrotmatNosevY	
                        ld	    (varAxis2),hl
                        call    MVS5RotateAxis
                        ret



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
MVS5RotateAxis:         ld      hl,(varAxis1)   ; work on roofv axis to get (1- 1/152) * roofv axis
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
    
 