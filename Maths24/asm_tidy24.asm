; ix = pointer to orientation matrix (XX15)
; ix data structure needs to be
;       X          y            Z
; side +00 , +01   +02 , +03    +04 , +05
; roof +06 , +07   +08 , +09    +10 , +11
; nose +12 , +13   +14 , +15    +16 , +17

TidyOrientation:push    ix
.TidyNose:      ld      hl,ix                   ; point ix to nosev
                ld      a,POS_MAT_NOSEVX        ; .
                add     hl,a                    ; .
                ld      ix,hl                   ; .
                call    Normalise16IX           ; normalise orientation for nosev
                pop     ix
.ProcessRoof:   ld      a,(ix+POS_MAT_NOSEVXHI)
                and     %01100000
                jp      z,.NotNosevX
;-------------- Process Nose Roof --------------;
.DivideByNosevX:ld      d,(ix+POS_MAT_NOSEVYHI) ; roofv_x = -(nosev_y * roofv_y + nosev_z * roofv_z) / nosev_x
                ld      e,(ix+POS_MAT_ROOFVYHI)
                call    mul8Signed              ; HL =  high of nosev_x * roofv_x
                ex      de,hl                   ; .
                ld      d,(ix+POS_MAT_NOSEVZHI) ; DE =  high of nosev_y * roofv_y
                ld      e,(ix+POS_MAT_ROOFVZHI) ; .
                call    mul8Signed              ; .
                call    HLequHLplusDE           ; de = new roofv_y temp value predivide
                ex      de,hl                   ; .
                ld      bc,$0060                ; divide by 96
                call    div_de_div_bc_signed    ; .
                ld      b,0
                ld      a,(ix+POS_MAT_NOSEVXHI)
                ld      c,a
                call    div_de_div_bc_signed
                ld      (ix+POS_MAT_ROOFVX),de
                jp      .DoneRoof
.NotNosevX:     ld      a,(ix+POS_MAT_NOSEVYHI)
                and     %01100000
                jp      z,.DivideByNosevZ
.DivideByNosevY:ld      d,(ix+POS_MAT_NOSEVXHI) ; roofv_y = -(nosev_x * roofv_x + nosev_z * roofv_z) / nosev_y
                ld      e,(ix+POS_MAT_ROOFVXHI)
                call    mul8Signed              ; HL =  high of nnosev_x * roofv_x
                ex      de,hl                   ; .
                ld      d,(ix+POS_MAT_NOSEVZHI) ; DE =  high of nosev_y * roofv_y
                ld      e,(ix+POS_MAT_ROOFVZHI) ; .
                call    mul8Signed              ; .
                call    HLequHLplusDE           ; de = new roofv_y temp value predivide
                ex      de,hl                   ; .
                ld      bc,$0060                ; divide by 96
                call    div_de_div_bc_signed    ; .
                ld      b,0
                ld      a,(ix+POS_MAT_NOSEVYHI)
                ld      c,a
                call    div_de_div_bc_signed
                ld      (ix+POS_MAT_ROOFVY),de
                ;divide by ix +16
                ;negate result
                jp      .DoneRoof
.DivideByNosevZ:ld      d,(ix+POS_MAT_NOSEVXHI) ; roofv_z = -(nosev_x * roofv_x + nosev_y * roofv_y) / nosev_z
                ld      e,(ix+POS_MAT_ROOFVXHI)
                call    mul8Signed              ; HL =  high of nnosev_x * roofv_x
                ex      de,hl                   ; .
                ld      d,(ix+POS_MAT_NOSEVYHI) ; DE =  high of nosev_y * roofv_y
                ld      e,(ix+POS_MAT_ROOFVYHI) ; .
                call    mul8Signed              ; .
                call    HLequHLplusDE           ; de = new roofv_y temp value predivide
                ex      de,hl                   ; .
                ld      bc,$0060                ; divide by 96
                call    div_de_div_bc_signed    ; .
                ld      b,0
                ld      a,(ix+POS_MAT_NOSEVZHI)
                ld      c,a
                call    div_de_div_bc_signed
                ld      (ix+POS_MAT_ROOFVZ),de
.DoneRoof:      push    ix
.TidyRoof:      ld      hl,ix                   ; point ix to roof
                ld      a,POS_MAT_ROOFVX        ; .
                add     hl,a                    ; .
                ld      ix,hl                   ; .
                call    Normalise16IX           ; normalise orientation for roof
;-------------- Process Nose Side --------------;
.ProcessSidev:  pop     ix
.CalcSideX      ld      d,(ix+POS_MAT_NOSEVZHI) ; sidev_x´ = ((nosev_z´ * roofv_y´) / 96) - ((nosev_y´ * roofv_z´) / 96)
                ld      e,(ix+POS_MAT_ROOFVYHI)
                call    mul8Signed              ; .
                ex      de,hl
                ld      d,(ix+POS_MAT_NOSEVYHI) ; 
                ld      e,(ix+POS_MAT_ROOFVZHI)
                call    mul8Signed              ; .
                call    HLequHLminusDE
                ex      de,hl
                ld      bc,$0060                ; divide by 96
                call    div_de_div_bc_signed    ; .
                ld      a,d
                or      e
                ld      d,a
                ld      e,0 
                ld      (ix+POS_MAT_SIDEVX),de
.CalcSideY      ld      d,(ix+POS_MAT_NOSEVXHI) ; sidev_y´ = ((nosev_x´ * roofv_z´) / 96) - ((nosev_z´ * roofv_x´) / 96)
                ld      e,(ix+POS_MAT_ROOFVZHI)
                call    mul8Signed              ; .
                ex      de,hl
                ld      d,(ix+POS_MAT_NOSEVZHI) ; 
                ld      e,(ix+POS_MAT_ROOFVXHI)
                call    mul8Signed              ; .
                call    HLequHLminusDE
                ex      de,hl
                ld      bc,$0060                ; divide by 96
                call    div_de_div_bc_signed    ; .
                ld      a,d
                or      e
                ld      d,a
                ld      e,0
                ld      (ix+POS_MAT_SIDEVY),de
.CalcSideZ:     ld      d,(ix+POS_MAT_NOSEVYHI) ; sidev_z´ = ((nosev_y´ * roofv_x´) / 96) - ((nosev_x´ * roofv_y´) / 96)
                ld      e,(ix+POS_MAT_ROOFVXHI)
                call    mul8Signed              ; .
                ex      de,hl
                ld      d,(ix+POS_MAT_NOSEVXHI) ; 
                ld      e,(ix+POS_MAT_ROOFVYHI)
                call    mul8Signed              ; .
                call    HLequHLminusDE
                ex      de,hl
                ld      bc,$0060                ; divide by 96
                call    div_de_div_bc_signed    ; .
                ld      a,d
                or      e
                ld      d,a
                ld      e,0                
                ld      (ix+POS_MAT_SIDEVZ),de
                ret
                