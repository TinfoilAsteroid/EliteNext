;    DEFINE DEBUGDRAWDISTANCE 1
    DEFINE CHECKDOTSHIPDATA  1
;    DEFINE DEBUGFORCEFACEDRAW 1
CurrentNormIdx  DB 0

;   Backface cull logic  line of sight vector . face normal vector
;       line of sight vector . face normal vector
;       => line of sight vector = [x y z] + face normal vector
;       Where [x y z] =
;                                               [ [x y z] . sidev ]
;                    projected [x y z] vector = [ [x y z] . roofv ]
;                                               [ [x y z] . nosev ]
;       
;   so project the [x y z] vector into the face's normal space
;  line of sight vector = projected [x y z] vector + face normal vector
;                         [ [x y z] . sidev ]   [ normal_x ]
;                       = [ [x y z] . roofv ] + [ normal_y ]
;                         [ [x y z] . nosev ]   [ normal_z ]
;
;                         [ [x y z] . sidev + normal_x ]
;                       = [ [x y z] . roofv + normal_y ]
;                         [ [x y z] . nosev + normal_z ]
;
; so 
;              visibility = [ [x y z] . sidev + normal_x ]   [ normal_x ]
;                            [ [x y z] . roofv + normal_y ] . [ normal_y ]
;                           [ [x y z] . nosev + normal_z ]   [ normal_z ]
;               
; where face is visible if visibility < 0
; 
;   so we set XX15 to [x y z] . sidev 
;                     [x y z] . roofv 
;                     [x y z] . nosev 
;


XX12EquNodeDotXX16:					         		; .LL51	\ -> &4832 \ XX12=XX15.XX16  each vector is 16-bit x,y,z **** ACTUALLY XX16 is value in low sign bit in high
;...X cell
		ld		hl,UBnkTransmatSidevX     			; process orientation matrix row 0
        call    XX12ProcessOneRow                   ; hl = result, a = sign
		ld		b,a                                 ; b = sign
		ld		a,h                                 ; a = high byte
		or		b
		ld		(UBnkXX12xSign),a					; a = result with sign in bit 7
		ld		a,l                                 ; the result will be in the lower byte now
        ld      (UBnkXX12xLo),a						; that is result done for
;...Y cell
		ld		hl,UBnkTransmatRoofvX     			; process orientation matrix row 1
        call    XX12ProcessOneRow
		ld		b,a
		ld		a,h
		or		b
		ld		(UBnkXX12ySign),a					; a = result with sign in bit 7
		ld		a,l                                 ; the result will be in the lower byte now
        ld      (UBnkXX12yLo),a						; that is result done for
;...Z cell
		ld		hl,UBnkTransmatNosevX     			; process orientation matrix row 1
        call    XX12ProcessOneRow
		ld		b,a
        ld		a,h
		or		b
		ld		(UBnkXX12zSign),a					; a = result with sign in bit 7
		ld		a,l                                 ; the result will be in the lower byte now
        ld      (UBnkXX12zLo),a						; that is result done for
        ret

 
; Halves the camera until z hi = 0 (z < 256). |x|,|y| < z from CheckVisible, so the three dot products
; P.sidev/roofv/nosev in XX12EquNodeDotXX16 are up to ~762: the low byte goes in XX18 lo and bits 8-9 sit in the
; XX18 sign byte, and the face test below works on the full value, so nothing wraps
ScaleDrawcam:           ld      hl,(UBnkDrawCam0xLo)        ; pull postition into registers
                        ld      de,(UBnkDrawCam0yLo)        ;
                        ld      bc,(UBnkDrawCam0zLo)        ;
.ScaleNormalLoop:       ld      a,b                         ; done once z hi = 0
                        or      a                           ; .
                        jr      z,.ScaledDown               ; .
.Halve:                 inc     iyl                         ; Q goes up by one
                        ShiftHLRight1                       ; divide cam position by 2
                        ShiftDERight1                       ;
                        ShiftBCRight1                       ;
                        jp      .ScaleNormalLoop            ;
.ScaledDown:            ld      (UBnkDrawCam0xLo),hl        ; save position back to XX18
                        ld      (UBnkDrawCam0yLo),de        ;
                        ld      (UBnkDrawCam0zLo),bc        ;
.ScaleDone:             ld      a,iyl
                        ld      (varXX17),a                  ; XX17 = normal scale factor for current ship adjusted for camera
                        ret

CheckVisible:           ld      a,(UBnKzsgn)                 ; Is the ship behind us
.CheckBehind:           and     SignOnly8Bit                 ; which means z sign is negative
                        jr      nz,.ShipNoDraw               ; .
.CheckFar:              ld      a,(UBnKxsgn)                 ; positions are 24 bit: bits 0-6 of the sign bytes are the top of the
                        ld      hl,UBnKysgn                  ; magnitude, and anything there is >= 65536, beyond ShipMaxDistance
                        or      (hl)                         ; (z < 49152) or outside the view (|x|,|y| must be < z), so the 16 bit
                        ld      hl,UBnKzsgn                  ; tests below would only see the truncated low 16 bits
                        or      (hl)
                        and     SignMask8Bit
                        jr      nz,.ShipNoDraw
.CheckViewPort:         ld      hl,(UBnKzlo)                 ; now check to see if its within 90 degree arc
                        ld      a,h
                        JumpIfAGTENusng ShipMaxDistance, .ShipNoDraw
.CheckXAxis:            ld      de,(UBnKxlo)                 ; if abs x > abx z then its out side of view port
                        call    compare16HLDE                
                        jr      c,.ShipNoDraw               ; ship is too far out on the X Axis
.CheckYAxis:            ld      de,(UBnKylo)                ; if abs y > abx z then its out side of view port
                        call    compare16HLDE
                        jr      c,.ShipNoDraw               ; ship is too far out on the X Axis
                        IFDEF   CHECKDOTSHIPDATA
.CheckDotV2:                ld      a,(DotAddr)
                            JumpIfAGTENusng h, .DrawFull
                            jp      .ShipIsADot
.DrawFull:                  call    UnivVisibleNonDot           ;
                            ClearCarryFlag
                            ret
                        ELSE
.CalculateXX4:              ShiftHLRight1                       ; hl = z pos / 8        
                            ShiftHLRight1                       ; .
                            ShiftHLRight1                       ; .
                            ld      a,h
                            srl     a                           ; if a / 16 <> 0 then ship is a dot
.DrawAsDotCheck:            JumpIfNotZero   .ShipIsADot
                            ; Check visbility distance
.SetXX4Dist:                ;break
                            ld      a,l
                            rra                                 ; l may have had bit 0 of h carried in
                            srl     a                           ; so move it to bit 4 giving A as distance $000xxxxx
                            srl     a
                            srl     a
                            ld      (UBnkDrawAllFaces),a        ; XX4 = "all faces" distance
                            call    UnivVisibleNonDot               ;
                            ClearCarryFlag
                            ret
                        ENDIF
.ShipNoDraw:            call    UnivInvisible
                        ret
.ShipIsADot:            IFDEF DEBUGDRAWDISTANCE
                            call    UnivVisible  ; 
                        ELSE
                            call    UnivVisibleDot
                        ENDIF
                        ret
                        
CullV2:                 ReturnIfMemisZero FaceCtX4Addr      ;   
                        call    CopyRotmatToTransMat        ; XX16 = UBNKRotMat    
                        call    ScaleXX16Matrix197          ; scale rotation matrix in XX16
                        call    LoadCraftToCamera           ; XX18 = camera
.BackfaceLoop:          ld      a,(QAddr)                   ;  
                        ld      iyl,a                       ; iyl = scale factor
; By this point XX18 = scaled draw cam and iyl = scale factor
                        call    ScaleDrawcam                ; XX18 = scaled camera XX17 = scale
                        ld      a,(varXX17)                 ; normals are added as N >> XX17, capped at 8 as an
                        cp      8                           ; 8 bit normal is all shifted out by then
                        jr      c,.ShiftOK
                        ld      a,8
.ShiftOK:               ld      (CullShift),a
                        call    CopyCameraToXX15Signed      ; Xx18 -> xx15 sign + 15 bit
.LL91:                  call    XX12EquNodeDotXX16          ; xx12 = Scaled Camera . Rotation matrix (Note Xx16 no Xx16 inv)
                        call    CopyXX12ScaledToXX18        ; now xx18 = XX12 = xx15.xx16
.PrepNormals:           ld      hl,UBnkHullNormals                                                                                                 ;;; V = address of Normal start
                        ld      (varV),hl  
                        ld      a,(FaceCtX4Addr)                                        ; For each face
                        srl     a                                              ;
                        srl     a                                              ;
                        ld      b,a                                            ;
                        xor     a                           
                        ld      (CurrentNormIdx),a                                          ; used to increment up face incdex as b decrements
.ProcessNormalsLoop:    push    hl                          
                        push    bc                          
.LL86:                  ld      a,(hl)                                         ; Get Face sign and visibility distance byte 
                        and     $1F                                            ; if normal visibility range  < XX4
                        push    hl                          
                        ld      hl,UBnkDrawAllFaces              
                        cp      (hl)                        
                        pop     hl                 
                        IFDEF DEBUGFORCEFACEDRAW
                            jp      .FaceVisible
                        ELSE
                            jp      c,.FaceVisible              ; then we always draw
                        ENDIF
; This bit needs to be added to force face visible
.LL87:                  call    CopyFaceToXX12              ; XX12 = normal magnitudes with $80/$00 sign bytes
; Face is visible if (P + N/2^XX17) . N < 0, where P = XX18 (camera in ship axes, 16 bit sign magnitude) and N is the
; stored normal. Summed exactly in a 24 bit accumulator: no truncated 8 bit products, no wrapping, no Q >= 4 shortcut
                        xor     a
                        ld      (CullAcc),a
                        ld      (CullAcc+1),a
                        ld      (CullAcc+2),a
                        ld      a,(UBnkDrawCam0xLo)         ; x: de = P.sidev
                        ld      e,a
                        ld      a,(UBnkDrawCam0xSgn)
                        call    CullSignMagToTwos
                        ld      a,(UBnkXX12xLo)
                        ld      b,a
                        ld      a,(UBnkXX12xSign)
                        ld      c,a
                        call    CullAddAxis
                        ld      a,(UBnkDrawCam0yLo)         ; y: de = P.roofv
                        ld      e,a
                        ld      a,(UBnkDrawCam0ySgn)
                        call    CullSignMagToTwos
                        ld      a,(UBnkXX12yLo)
                        ld      b,a
                        ld      a,(UBnkXX12ySign)
                        ld      c,a
                        call    CullAddAxis
                        ld      a,(UBnkDrawCam0zLo)         ; z: de = P.nosev
                        ld      e,a
                        ld      a,(UBnkDrawCam0zSgn)
                        call    CullSignMagToTwos
                        ld      a,(UBnkXX12zLo)
                        ld      b,a
                        ld      a,(UBnkXX12zSign)
                        ld      c,a
                        call    CullAddAxis
                        ld      a,(CullAcc+2)               ; negative total means the face points towards us
                        and     a
                        jp      m,.FaceVisible
.FaceNotVisible:         ld          a,(CurrentNormIdx)
                        call        SetFaceAHidden                                      ;           set face invisible
                        jp          .ProcessNormalLoopEnd                                ;        end if
.FaceVisible:            ld          a,(CurrentNormIdx)
                        call        SetFaceAVisible
.ProcessNormalLoopEnd:  ld          hl, CurrentNormIdx
                        inc         (hl)                    ; move index pointer up by one
                        pop         bc
                        pop         hl                      ; get normal data pointer back
                        ld          a,4
                        add         hl,a                    ; move to next normal entry
                        ld          (varV),hl               ; save as we need it again
                        dec         b
                        jp          nz,.ProcessNormalsLoop
                        ret   
                        
CullAcc                 DS      3                           ; 24 bit 2's complement sum of (P + N >> XX17) . N
CullShift               DB      0                           ; XX17 capped at 8
CullProductSign         DB      0

; e = magnitude low byte, a = sign byte holding the sign in bit 7 and magnitude bits 8-14 in bits 0-6
; -> de = value as 16 bit 2's complement
CullSignMagToTwos:      ld      d,a
                        res     7,d
                        bit     7,a
                        ret     z
                        xor     a
                        sub     e
                        ld      e,a
                        sbc     a,a
                        sub     d
                        ld      d,a
                        ret

; de = P component (2's complement), b = |N| component, c = N sign ($80 negative)
; CullAcc += (P + N >> CullShift) * N, worked as |T| * |N| (at most ~1020 * 255) with the sign applied on the add
CullAddAxis:            ld      l,b                         ; hl = |N| >> CullShift
                        ld      h,0
                        ld      a,(CullShift)
                        and     a
                        jr      z,.Shifted
.ShiftLoop:             srl     l
                        dec     a
                        jr      nz,.ShiftLoop
.Shifted:               bit     7,c                         ; apply the normal's sign
                        jr      z,.AddP
                        xor     a
                        sub     l
                        ld      l,a
                        sbc     a,a
                        sub     h
                        ld      h,a
.AddP:                  add     hl,de                       ; hl = T = P + N >> shift
                        ld      a,h                         ; product sign = sign T xor sign N
                        xor     c
                        ld      (CullProductSign),a
                        bit     7,h                         ; hl = |T|
                        jr      z,.TPositive
                        xor     a
                        sub     l
                        ld      l,a
                        sbc     a,a
                        sub     h
                        ld      h,a
.TPositive:             ld      d,h                         ; |T| * |N| = (h * N) << 8 + l * N
                        ld      e,b
                        mul     de
                        push    de                          ; h * N
                        ld      d,l
                        ld      e,b
                        mul     de                          ; de = l * N
                        pop     hl                          ; hl = h * N
                        ld      a,d                         ; product = c:d:e with c = h + carry, d = d + l
                        add     a,l
                        ld      d,a
                        ld      a,h
                        adc     a,0
                        ld      c,a
                        ld      hl,CullAcc
                        ld      a,(CullProductSign)
                        and     a
                        jp      m,.Subtract
                        ld      a,(hl)                      ; CullAcc += product
                        add     a,e
                        ld      (hl),a
                        inc     hl
                        ld      a,(hl)
                        adc     a,d
                        ld      (hl),a
                        inc     hl
                        ld      a,(hl)
                        adc     a,c
                        ld      (hl),a
                        ret
.Subtract:              ld      a,(hl)                      ; CullAcc -= product
                        sub     e
                        ld      (hl),a
                        inc     hl
                        ld      a,(hl)
                        sbc     a,d
                        ld      (hl),a
                        inc     hl
                        ld      a,(hl)
                        sbc     a,c
                        ld      (hl),a
                        ret
