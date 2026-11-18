; ix = pointer to orientation matrix (XX15)
; ix data structure needs to be
;       X          y            Z
; side +00 , +01   +02 , +03    +04 , +05
; roof +06 , +07   +08 , +09    +10 , +11
; nose +12 , +13   +14 , +15    +16 , +17
TidyOrientation:push    ix
.TidyNose:      ld      hl,ix                   ; point ix to nosev
                ld      a,12                    ; .
                add     hl,a                    ; .
                ld      ix,hl                   ; .
                call    Normalise24IX           ; normalise orientation for nosev
.TidyRoof:      ld      a,(ix+12)
                and     %01100000
                jp      z,.NotNosevX
;-------------- Process Nose Roof --------------;
.DivideByNosevX:pop     ix
                ld      d,(ix+13)               ; roofv_y = -(nosev_x * roofv_x + nosev_y * roofv_y) / nosev_z
                ld      e,(ix+07)
                call    mul8Signed              ; HL =  high of nnosev_x * roofv_x
                ex      de,hl                   ;
                ld      d,(ix+15)               ; DE =  high of nosev_y * roofv_y
                ld      e,(ix+09)               ;
                call    mul8Signed              ; bc = HL * DE (S7.8)
                pop     hl                      ; get nosev_x * roofv_x  calc back
                call    HLequHLplusDE           ; de = new roofv_y temp value predivide
                ex      de,hl                   ; .
                ld      bc,$0060
                call    div_de_div_bc_signed    ; divide by 96
                break
                ;divide by ix +16
                ;negate result
                jp      .DoneRoof

.NotNosevX:     pop     ix
                ld      a,(ix+14)
                and     %01100000
                jp      z,.NotNosevY
.DivideByNosevY:pop     ix                      ; roofv_z = -(nosev_x * roofv_x + nosev_z * roofv_z) / nosev_y

.NotNosevY:                                     ; roofv_x = -(nosev_y * roofv_y + nosev_z * roofv_z) / nosev_x
.DoneRoof:      push    ix
.TidyNose:      ld      hl,ix                   ; point ix to roof
                ld      a,6                   ; .
                add     hl,a                    ; .
                ld      ix,hl                   ; .
                call    Normalise24IX           ; normalise orientation for roof
;-------------- Process Nose Side --------------;
                
; d = vector 1 e = vector 2 h = vector3 l = vector 4 b = vector 5
; performs (d*e + h*l) / b and puts the result in de where e is 0
TidyCalc:       push    bc
                call    DEequDmulEs           ; de = vector 1 * vector 2
                ex      hl,de                   ; get hl into de and save result of de
                call    DEequDmulEs           ; de = vector 2 * vector 3
                call    AddDEtoHLSigned         ; BC = HL = HL + DE
                pop     de                      ; DE = BC saved from earlier
                ld      a,h                     ; check for result 0
                or      l                       ; .
                jp      z,.ZeroResult           ; .
                ld      bc,hl                   ; .
                ld      a,d                     ; check for divide by zero
                and     a                       ; .
                jp      z,.MaxedResult          ; .
                ld      e,d                     ; now de = 0b (i.e. b register not hex value)
                ld      d,0                     ;
                call    Floor_DivQSigned        ; TO BE TESTED should do BC = BC / DE
                ld      a,b                     ; sign bit from b
                and     $80                     ; .
                or      c                       ; bring in the value
                ld      d,a                     ; de = c0 (i.e. c register not hex value)
                ld      e,0                     ; .
                ret
.MaxedResult:   ld      a,b                     ; make result signed unity (i.e. 1 or 96 in our case)
                xor     $80
                or      $60
                ld      d,a
                ld      e,0
                ret
.ZeroResult:    ld      de,0
                ret
; as per tidy calc except
; d = vector 1 e = vector 2 h = vector3 l = vector 4
; performs (d*e - h*l) / 96 and puts the result in de where e is 0

TidySide:       call    DEequDmulEs           ; de = vector 1 * vector 2
                ex      de,hl                   ; get hl = vector 1 * vector 2
                call    DEequDmulEs           ; de = vector 2 * vector 3
                call    SubDEfromHLSigned       ; BC = HL = HL - DE
                ld      bc,hl                   ; .
                ld      de,$60                  ; now de = 96
                call    Floor_DivQSigned        ; TO BE TESTED should do BC = BC / DE
                ld      a,b                     ; sign bit from b
                and     $80                     ; .
                or      c                       ; bring in the value
                ld      d,a                     ; de = c0 (i.e. c register not hex value)
                ld      e,0                     ; .
                ret

;; orthonormalise vector for UBnK ship vector uses IX IT
    DISPLAY "TidyVectorsIX"
TidyVectorsIX:  ld      ix,UBnkrotmatNosevX
                call    NormaliseIXVector       ; initially we normalise the nose vector
.CheckNoseXSize:ld      a,(UBnkrotmatNosevX+1)  ; a = nose x
                and     %00110000                ; if bits 7 and 6 are clear the work with nosey
                jp      z, .NoseXSmall
;-- When nosex is large ------------------------  roofv_x =-(nosev_y * roofv_y + nosev_z * roofv_z) / nosev_x        
.NoseXLarge:    ld      a,(UBnkrotmatNosevY+1)  ; a = nose x
                ld      d,a
                ld      a,(UBnkrotmatRoofvY+1)  ; hl = nosev_y * roofv_y
                ld      e,a                     ; we already have d so only need roofY
                ld      a,(UBnkrotmatNosevZ+1)  ; de = nosev_z * roofv_z
                ld      h,a                     ; .
                ld      a,(UBnkrotmatRoofvZ+1)  ; .
                ld      l,a                     ; .
                ld      a,(UBnkrotmatNosevX+1)
                ld      b,a
                call    TidyCalc
                ld      a,d
                or      e
                jp      z,.NoRoofXFlip
                ld      a,$80                   ; flip sign bit if not zero
                xor     d
                ld      d,a
.NoRoofXFlip:   ld      (UBnkrotmatRoofvX),de   ; write roofvx
                jp      .NormaliseRoofv
.MaxedRoofX:    ld      de,$E000                ; TEST if sign is correct for all of these if was divide by zero make it -1
                ld      (UBnkrotmatRoofvX),de   ; write roofvx
                jp      .NormaliseRoofv
;-- When noseX is small ------------------------ determine if we are doign roofz or roof y
.NoseXSmall:    ld      a,(UBnkrotmatNosevY)
                and     %01100000
                jp      z,.NoseYSmall
;-- When noseY is large ------------------------ roofv_z = -(nosev_x * roofv_x + nosev_y * roofv_y) / nosev_z
.NoseYLarge:    ld      a,(UBnkrotmatNosevX+1)  
                ld      d,a
                ld      a,(UBnkrotmatRoofvX+1)  
                ld      e,a                     
                ld      a,(UBnkrotmatNosevY+1)  
                ld      h,a                     
                ld      a,(UBnkrotmatRoofvY+1)  
                ld      l,a                     
                ld      a,(UBnkrotmatNosevZ+1)
                ld      b,a
                call    TidyCalc
                ld      a,d
                or      e
                jp      z,.NoRoofZFlip
                ld      a,$80                   ; flip sign bit if not zero
                xor     d
                ld      d,a
                ld      a,$80                   ; flip sign bit
                xor     d
                ld      d,a
.NoRoofZFlip:   ld      (UBnkrotmatRoofvZ),de   ; write roofvz
                jp      .NormaliseRoofv             
;-- When noseY is large ------------------------ roofv_y = -(nosev_x * roofv_x + nosev_z * roofv_z) / nosev_y
.NoseYSmall:    ld      a,(UBnkrotmatNosevX+1)  
                ld      d,a
                ld      a,(UBnkrotmatRoofvX+1)  
                ld      e,a                     
                ld      a,(UBnkrotmatNosevZ+1)  
                ld      h,a                     
                ld      a,(UBnkrotmatRoofvZ+1)  
                ld      l,a                     
                ld      a,(UBnkrotmatNosevY+1)
                ld      b,a
                call    TidyCalc
                ld      a,d
                or      e
                jp      z,.NoRoofYFlip
                ld      a,$80                   ; flip sign bit if not zero
                xor     d
                ld      d,a
                ld      a,$80                   ; flip sign bit
                xor     d
                ld      d,a
.NoRoofYFlip:   ld      (UBnkrotmatRoofvY),de   ; write roofvy
.NormaliseRoofv:ld      ix,UBnkrotmatRoofvX     ; now normalise roofv
                call    NormaliseIXVector
; -- sidev_x = (nosev_z * roofv_y - nosev_y * roofv_z) / 96                
.CalcSidevX:    ld      a,(UBnkrotmatNosevZ+1)  
                ld      d,a
                ld      a,(UBnkrotmatRoofvY+1)  
                ld      e,a                     
                ld      a,(UBnkrotmatNosevY+1)  
                ld      h,a                     
                ld      a,(UBnkrotmatRoofvZ+1)  
                ld      l,a                     
                call    TidySide
                ld      (UBnkrotmatSidevX),de   ; write sidevX
; -- sidev_y = (nosev_x * roofv_z - nosev_z * roofv_x) / 96              
.CalcSidevY:    ld      a,(UBnkrotmatNosevX+1)  
                ld      d,a
                ld      a,(UBnkrotmatRoofvZ+1)  
                ld      e,a                     
                ld      a,(UBnkrotmatNosevZ+1)  
                ld      h,a                     
                ld      a,(UBnkrotmatRoofvX+1)  
                ld      l,a                     
                call    TidySide
                ld      (UBnkrotmatSidevY),de   ; write sidevX
; -- sidev_z = (nosev_y * roofv_x - nosev_x * roofv_y) / 96            
.CalcSidevZ:    ld      a,(UBnkrotmatNosevY+1)  
                ld      d,a
                ld      a,(UBnkrotmatRoofvX+1)  
                ld      e,a                     
                ld      a,(UBnkrotmatNosevX+1)  
                ld      h,a                     
                ld      a,(UBnkrotmatRoofvY+1)  
                ld      l,a                     
                call    TidySide
                ld      (UBnkrotmatSidevZ),de   ; write sidevX
            IFDEF ROUND_ROLL_AND_PITCH
.ClearLowBytes: ld      hl,UBnkrotmatSidevX
                ZeroA
                ld      b,9
.WriteLoop:     ld      (hl),a
                inc     hl
                inc     hl
                djnz    .WriteLoop
            ENDIF
                ret
