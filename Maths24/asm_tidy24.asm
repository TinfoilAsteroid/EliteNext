; ix = pointer to orientation matrix, each value a 16 bit lead sign word with 1.0 = $6000 (96 in the hi byte)
; ix data structure needs to be
;       X          y            Z
; side +00 , +01   +02 , +03    +04 , +05
; roof +06 , +07   +08 , +09    +10 , +11
; nose +12 , +13   +14 , +15    +16 , +17
;
; Re-orthonormalises the matrix against drift (Elite TIDY), working on the hi bytes as Normalise16IX does:
;   1. nose = nose / |nose|
;   2. make roof perpendicular to nose: pick the nose axis k with the largest |nose_k| (>= 96/sqrt(3) once normalised,
;      so the divide is well conditioned and roof moves the least) and set roof_k = -(nose_a * roof_a + nose_b * roof_b) / nose_k
;   3. roof = roof / |roof|
;   4. side = (nose x roof) / 96, then side = side / |side|
; ix is preserved, uses the banked maths routines so MathsBankedFns must be paged in
TidyOrientation:        push    ix
.NormaliseNose:         ld      bc,POS_MAT_NOSEVX
                        add     ix,bc
                        call    Normalise16IX
                        pop     ix
.PickRoofAxis:          ld      a,(ix+POS_MAT_NOSEVXHI) ; correct roof along the largest nose axis
                        and     $7F
                        ld      b,a                     ; b = |nose_x|
                        ld      a,(ix+POS_MAT_NOSEVYHI)
                        and     $7F
                        ld      c,a                     ; c = |nose_y|
                        ld      a,(ix+POS_MAT_NOSEVZHI)
                        and     $7F                     ; a = |nose_z|
                        cp      b
                        jr      c,.XOrY                 ; z < x so x or y
                        cp      c
                        jr      c,.FixRoofY             ; x <= z < y
                        jr      .FixRoofZ               ; z is the largest
.XOrY:                  ld      a,b
                        cp      c
                        jr      nc,.FixRoofX            ; x >= y
                        jr      .FixRoofY
.FixRoofZ:              ld      d,(ix+POS_MAT_NOSEVXHI) ; roofv_z = -(nosev_x * roofv_x + nosev_y * roofv_y) / nosev_z
                        ld      e,(ix+POS_MAT_ROOFVXHI)
                        ld      b,(ix+POS_MAT_NOSEVYHI)
                        ld      c,(ix+POS_MAT_ROOFVYHI)
                        ld      a,(ix+POS_MAT_NOSEVZHI)
                        call    TidyRoofComponent
                        ld      (ix+POS_MAT_ROOFVZ),de
                        jr      .NormaliseRoof
.FixRoofY:              ld      d,(ix+POS_MAT_NOSEVXHI) ; roofv_y = -(nosev_x * roofv_x + nosev_z * roofv_z) / nosev_y
                        ld      e,(ix+POS_MAT_ROOFVXHI)
                        ld      b,(ix+POS_MAT_NOSEVZHI)
                        ld      c,(ix+POS_MAT_ROOFVZHI)
                        ld      a,(ix+POS_MAT_NOSEVYHI)
                        call    TidyRoofComponent
                        ld      (ix+POS_MAT_ROOFVY),de
                        jr      .NormaliseRoof
.FixRoofX:              ld      d,(ix+POS_MAT_NOSEVYHI) ; roofv_x = -(nosev_y * roofv_y + nosev_z * roofv_z) / nosev_x
                        ld      e,(ix+POS_MAT_ROOFVYHI)
                        ld      b,(ix+POS_MAT_NOSEVZHI)
                        ld      c,(ix+POS_MAT_ROOFVZHI)
                        ld      a,(ix+POS_MAT_NOSEVXHI)
                        call    TidyRoofComponent
                        ld      (ix+POS_MAT_ROOFVX),de
.NormaliseRoof:         push    ix
                        ld      bc,POS_MAT_ROOFVX
                        add     ix,bc
                        call    Normalise16IX
                        pop     ix
.CalcSideX:             ld      d,(ix+POS_MAT_NOSEVYHI) ; sidev_x = (nosev_y * roofv_z - nosev_z * roofv_y) / 96
                        ld      e,(ix+POS_MAT_ROOFVZHI)
                        ld      b,(ix+POS_MAT_NOSEVZHI)
                        ld      c,(ix+POS_MAT_ROOFVYHI)
                        call    TidyCrossComponent
                        ld      (ix+POS_MAT_SIDEVX),de
.CalcSideY:             ld      d,(ix+POS_MAT_NOSEVZHI) ; sidev_y = (nosev_z * roofv_x - nosev_x * roofv_z) / 96
                        ld      e,(ix+POS_MAT_ROOFVXHI)
                        ld      b,(ix+POS_MAT_NOSEVXHI)
                        ld      c,(ix+POS_MAT_ROOFVZHI)
                        call    TidyCrossComponent
                        ld      (ix+POS_MAT_SIDEVY),de
.CalcSideZ:             ld      d,(ix+POS_MAT_NOSEVXHI) ; sidev_z = (nosev_x * roofv_y - nosev_y * roofv_x) / 96
                        ld      e,(ix+POS_MAT_ROOFVYHI)
                        ld      b,(ix+POS_MAT_NOSEVYHI)
                        ld      c,(ix+POS_MAT_ROOFVXHI)
                        call    TidyCrossComponent
                        ld      (ix+POS_MAT_SIDEVZ),de
.NormaliseSide:         push    ix                      ; side is at offset 0
                        call    Normalise16IX
                        pop     ix
                        ret

; d,e and b,c = lead sign hi bytes of the two nose * roof products, a = nose_k hi byte (the largest nose axis)
; de = -(d * e + b * c) / nose_k as a lead sign word with the magnitude in the hi byte
TidyRoofComponent:      push    af                      ; nose_k
                        push    bc
                        call    mul8Signed              ; de = d * e
                        pop     bc
                        push    de
                        ld      d,b
                        ld      e,c
                        call    mul8Signed              ; de = b * c
                        pop     hl
                        call    HLequHLplusDE           ; hl = d * e + b * c
                        pop     af
                        ld      c,a                     ; c = nose_k
                        xor     h                       ; result sign = -(sign sum xor sign nose_k)
                        and     $80
                        xor     $80
                        ld      b,a
                        res     7,h                     ; hl = |sum|
                        ld      a,c
                        and     $7F
                        ld      c,a                     ; c = |nose_k|
                        jr      TidyDivideToWord

; d,e and b,c = lead sign hi bytes; de = (d * e - b * c) / 96 as a lead sign word with the magnitude in the hi byte
TidyCrossComponent:     push    bc
                        call    mul8Signed              ; de = d * e
                        pop     bc
                        push    de
                        ld      d,b
                        ld      e,c
                        call    mul8Signed              ; de = b * c
                        pop     hl
                        call    HLequHLminusDE          ; hl = d * e - b * c
                        ld      a,h
                        and     $80
                        ld      b,a                     ; b = result sign
                        res     7,h
                        ld      c,96

; hl = magnitude, c = divisor, b = sign -> de = lead sign word with min(hl / c, 127) in the hi byte
TidyDivideToWord:       push    bc
                        call    div_hl_div_c            ; hl = hl / c
                        pop     bc
                        ld      a,h                     ; the magnitude has to fit 7 bits of the hi byte
                        and     a
                        jr      nz,.Clamp
                        ld      a,l
                        cp      128
                        jr      c,.InRange
.Clamp:                 ld      a,127
.InRange:               or      b
                        ld      d,a
                        ld      e,0
                        ret
