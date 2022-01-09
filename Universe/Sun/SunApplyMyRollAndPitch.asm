
; Full version
; 1. K2 = y - alpha * x
; 2. z = z + beta * K2
; 3. y = K2 - beta * z
; 4. x = x + alpha * y



; SunrollWork holds Alpha intermidate results              
SunRollResult:          DS 3                    ; equivalent of K
SunRollResultp1         equ SunRollResult
SunRollResultp2         equ SunRollResult+1
SunRollResultp3         equ SunRollResult+2
SunRollResultp4         DB 0
;SunRollResult2:         DS 3                    ; do we need this? TODO
SunZResult:             DS 3
;  1. K2 = y - alpha * x
;  2. z = z + beta * K2
;  3. y = K2 - beta * z
;  4. x = x + alpha * y
;.... or
;  2. z = z + (beta * (y - alpha * x))
;  3. y = (y - alpha * x) - (beta * z)
;  4. x = x + (alpha * y)


;----------------------------------------------------------------------------------------------------------------------------------
; based on MV40
SunApplyMyRollAndPitch: ld      a,(ALPHA)                   ; no roll or pitch, no calc needed
                        ld      hl,BETA
                        or      (hl)
                        and     SignMask8Bit
                        jp      z,.NoRotation
.CalcZ:                 ;break
                        ld      a,(ALPHA)                   ; get roll magnitude
                        cp      0
                        jr      nz,.ApplyAlpha
.NoAlpha:               ld      de,(SBnKyhi)                ; its going to be just Y if alpha is 0
                        ld      a,(SBnKylo)                 ; .
                        ld      l,a                         ; .
                        jp      .SaveResult1                ; .
.ApplyAlpha:            xor     SignOnly8Bit                ; get Q = -alpha
                        ld      d,a                         ; d reg represents Q (abount to roll)
                        ld      a,(SBnKxlo)                 ; HLE = x sgn, hi, lo
                        ld      e,a                         ;
                        ld      hl,(SBnKxhi)                ;
                        call    mulHLEbyDSigned             ; DELC = x * -alpha, so DEL = X * -alpha / 256
.SkipAlphaMultiply:     ld      a,d
                        ld      (SunRollResultp4),a         ; save D (I guess we need the sign?)
.CalcYPlusDEL:          ld      a,(SBnKylo)                 ; BCH = Y sgn, hi, lo
                        ld      h,a
                        ld      bc,(SBnKyhi)
                        call    AddBCHtoDELsigned           ; DEL = Y - ( X *  alpha /256) (which is K2)
.SaveResult1:           ld      a,d                         ; SunPitchWork = AHL = DEL
                        ld      h,e                         ;
.CopyResultTo2:         ld      (SunRollResult+2),a         ; .
                        ld      (SunRollResult) ,hl         ; .
.CalcY:                 ld      e,l                         ; HLE = result (K2)
                        ld      l,h                         ; .
                        ld      h,a                         ; .
                        ld      a,(BETA)                    ; get pitch
                        ld      d,a                         ; now D = BETA
                        call    mulHLEbyDSigned             ; DELC = (y - alpha * x /256 ) * Beta or K2 * beta
                        ld      bc,(SBnKzhi)                ; BCH = z
                        ld      a,(SBnKzlo)                 ; .
                        ld      h,a                         ; .
                        call    AddBCHtoDELsigned           ; DEL = z + ((y - alpha * x /256 ) * Beta) /256
.SaveZResult:           ld      (SunZResult+1),de           ; We now have a z result which we save
                        ld      (SBnKzhi),de                ; .
                        ld      a,l                         ; . 
                        ld      (SunZResult),a              ; . 
                        ld      (SBnKzlo),a                 ; .
.CalcMinusBetaMulZ:     ex      de,hl                       ; HLE = DEL = z post calculation
                        ; not needed bugld      e,l                         ; .
                        ld      a,(BETA)                    ; d = - BETA
                        xor     SignOnly8Bit                ; .
                        ld      d,a                         ; .
                        call    mulHLEbyDSigned             ; DELC = z * - BETA
                        ld      bc, (SunRollResult+1)       ; BCH = (y - alpha * x) (or K2)
                        ld      a,(SunRollResult)           ; .
                        ld      h,a                         ; .
                        call    AddBCHtoDELsigned           ; DEL = (y - alpha * x) - (Z * BETA) (K2+ (Z * -BETA)
                        ld      (SBnKyhi),de                ; y = (y - alpha * x) - (Z * BETA)
                        ld      a,l                         ; .
                        ld      (SBnKylo),a                 ; .
.CalcX:                 ex      de,hl                       ; HLE = DEL = Y
                        ld      e,l                         ; .
                        ld      a,(ALPHA)                   ; D = alpha
                        cp      0                           ; if alpha is 0 then don't update x 
                        jp      z,.NoRotation
                        ld      d,a                         ; .
                        call    mulHLEbyDSigned             ; DELC = Y * alpha
                        ld      bc,(SBnKxhi)                ; BCH = x
                        ld      a,(SBnKxlo)                 ; .
                        ld      h,a                         ; .
                        call    AddBCHtoDELsigned           ; DEL = x + (alpha * y /256 )
                        ld      (SBnKxhi),de                ; x = x + (alpha * y /256 )
                        ld      a,h                         ; .
                        ld      (SBnKxlo),a                 ; .
                        ret
.NoRotation:            ld      a,(DELTA)                   ; BCH = - Delta
                        cp      0
                        ret     z
                        ld      c,0                         ;
                        ld      h,a                         ; 
                        ld      b,$80                       ;
                        ld      de,(SBnKzhi)                ; DEL = z position
                        ld      a,(SBnKzlo)                 ; .
                        ld      l,a                         ; .
                        call    AddBCHtoDELsigned           ; update speed
                        ld      (SBnKzhi),DE                ; write back to zpos
                        ld      a,l
                        ld      (SBnKzlo),a                ;
                        ret

;
;SunApplyMyRollAndPitch: ld      a,(ALPHA)                   ; no roll or pitch, no calc needed
;                        ld      hl,BETA
;                        or      (hl)
;                        and     SignMask8Bit
;                        ret     z
;.CalcZ:                 ;break
;                        ld      a,(ALPHA)                   ; get roll magnitude
;                        xor     SignOnly8Bit                ; get Q = -alpha
;                        ld      d,a                         ; d reg represents Q (abount to roll)
;                        ld      a,(SBnKxlo)                 ; HLE = x sgn, hi, lo
;                        ld      e,a                         ;
;                        ld      hl,(SBnKxhi)                ;
;                        call    mulHLEbyDSigned             ; DELC = x * -alpha, so DEL = X * -alpha / 256
;                        ld      a,d
;                        ld      (SunRollResultp4),a         ; save D (I guess we need the sign?)
;.CalcYPlusDEL:          ld      a,(SBnKylo)                 ; BCH = Y sgn, hi, lo
;                        ld      h,a
;                        ld      bc,(SBnKyhi)
;                        call    AddBCHtoDELsigned           ; DEL = Y - ( X *  alpha /256)
;.SaveResult1:           ld      a,l                         ; SunPitchWork = DEL
;                        ;ld      (SunRollResult), a          ; SunPitchWork + 0 = L
;                        ex      de,hl                       ; SunPitchWork + 1 = E
;.CopyResultTo2:         ld      (SunRollResult+1),a         ; SunPitchWork + 2 = D
;                        ld      (SunRollResult+1) ,hl       ; Copy K to K2 (y - alpha * x)
;                        ;ld      (SunRollResult2+1),hl       ; also HLA = result
;                        ld      a,(SunRollResult)           ; .
;                        ;ld      (SunRollResult2),a          ; .
;.CalcY:                 ld      e,a                         ; so now HLE = result
;                        ld      a,(BETA)                    ; get pitch
;                        ld      d,a                         ; now D = BETA
;                        call    mulHLEbyDSigned             ; DELC = (y - alpha * x /256 ) * Beta
;                        ld      bc,(SBnKzhi)                ; BCH = z
;                        ld      a,(SBnKzlo)                 ;
;                        ld      h,a                         ;
;                        call    AddBCHtoDELsigned           ; DEL = z + ((y - alpha * x /256 ) * Beta) /256
;.SaveZResult:           ld      (SunZResult+1),de           ; We now have a z result which we save
;                        ld      (SBnKzhi),de                ; .
;                        ld      a,l                         ; . 
;                        ld      (SunZResult),a              ; . 
;                        ld      (SBnKzlo),a                 ; .
;.CalcMinusBetaMulZ:     ex      de,hl                       ; HLE = DEL = z post calculation
;                        ld      e,l                         ;
;                        ld      a,(BETA)                    ; d = - BETA
;                        ld      d,a                         ;
;                        xor     SignOnly8Bit                ;
;                        call    mulHLEbyDSigned             ; DELC = z * - BETA
;                        ld      bc, (SunRollResult+1)       ; BCH = (y - alpha * x) (or K2)
;                        ld      a,(SunRollResult)           ;
;                        ld      h,a                         ;
;                        call    AddBCHtoDELsigned           ; DEL = (y - alpha * x) - (Z * BETA)
;                        ld      (SBnKyhi),de                ; y = (y - alpha * x) - (Z * BETA)
;                        ld      a,l                         ;
;                        ld      (SBnKylo),a                 ;
;.CalcX:                 ex      de,hl                       ; HLE = DEL = Y
;                        ld      e,l                         ;
;                        ld      a,(ALPHA)
;                        ld      d,a                         ; D = alpha
;                        call    mulHLEbyDSigned             ; DELC = Y * alpha
;                        ld      bc,(SBnKxhi)                ; BCH = x
;                        ld      a,(SBnKxlo)                 ;
;                        ld      h,a                         ;
;                        call    AddBCHtoDELsigned           ; DEL = x + (alpha * y /256 )
;                        ld      (SBnKxhi),de                ; x = x + (alpha * y /256 )
;                        ld      a,h                         ; 
;                        ld      (SBnKxlo),a                 ;
;                        ret
;