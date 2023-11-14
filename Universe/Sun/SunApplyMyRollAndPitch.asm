
; Full version
; 1. K2 = y - alpha * x
; 2. z = z + beta * K2
; 3. y = K2 - beta * z
; 4. x = x + alpha * y



; SunrollWork holds Alpha intermidate results              
;  1. K2 = y - alpha * x
;  2. z = z + beta * K2
;  3. y = K2 - beta * z
;  4. x = x + alpha * y
;.... or
;  2. z = z + (beta * (y - alpha * x))
;  3. y = (y - alpha * x) - (beta * z)
;  4. x = x + (alpha * y)


;----------------------------------------------------------------------------------------------------------------------------------
; Sun version of pitch and roll is a 24 bit calculation 1 bit sign + 23 bit value
; Need to write a test routine for roll and pitchs
SunAlphaMulX            DS 4
SunAlphaMulY            DS 4
SunBetaMulZ             DS 4
SunK2                   DS 3

SunApplyMyRollAndPitch: ld      a,(ALPHA)                   ; no roll or pitch, no calc needed
                        ld      hl,BETA
                        or      (hl)
                        and     SignMask8Bit
                        jp      z,.NoRotation
.CalcAlphaMulX:         ld      a,(ALPHA)                   ; get roll magnitude
                        xor     SignOnly8Bit                ; d = -alpha (Q value)
                        ld      d,a                         ; .
                        ld      a,(SBnKxlo)                 ; HLE = x sgn, hi, lo
                        ld      e,a                         ; .
                        ld      hl,(SBnKxhi)                ; .
                        call    mulHLEbyDSigned             ; DELC = x * -alpha, so DEL = X * -alpha / 256 where d = sign byte
.SaveAlphaMulX:         ;ld      a,c                         ; a = upper byte of results which will have the sign               ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      (SunAlphaMulX),a            ; save sign from result, ELC holds actual result                   ONLY NEEDED FOR DEBUGGING TEST
                        ld      a,l                         ; also save all of alpha *X as we will need it later
                        ld      (SunAlphaMulX+1),a
                        ld      a,e
                        ld      (SunAlphaMulX+2),a
                        ld      a,d
                        ld      (SunAlphaMulX+3),a          ; we actually only want X1 X2 X3 later as its /256
.CalcK2:                ld      de,(SBnKyhi)                ; DEL = Y
                        ld      a,(SBnKylo)                 ; .
                        ld      l,a                         ; .
                        ld      bc,(SunAlphaMulX+2)         ; BCH = Y sgn, hi, lo, we loose the C from result
                        ld      a,(SunAlphaMulX+1)          ; Deal with sign in byte 4
                        ld      h,a                         ; .
                        MMUSelectMathsBankedFns
                        call    AddBCHtoDELsigned           ; DEL = y - (alpha * x)
                        ld      a,l                         ; K2  = DEA = DEL = y - (alpha * x)
                        ld      (SunK2),a                   ; we also need to save l for teh beta k2 calc
                        ld      (SunK2+1),de                ; 
.CalcBetaMulK2:         ex      de,hl                       ; HLE == DEA
                        ld      e,a                         ; .
                        ld      a,(BETA)                    ; D = BETA
                        ld      d,a                         ; .
                        call    mulHLEbyDSigned             ; DELC = Beta * K2, DEL = Beta/256 * K2
.CalcZ:                 ld      bc,(SBnKzhi)                ; BCH = z
                        ld      a,(SBnKzlo)                 ;
                        ld      h,a                         ;
                        MMUSelectMathsBankedFns
                        call    AddBCHtoDELsigned           ; DEL still = Beta * K2 so its z + Beta * K2
                        ld      (SBnKzhi),de                ; z = resuklt
                        ld      a,l                         ; .
                        ld      (SBnKzlo),a                 ; .
.CalcBetaZ:             ld      a,(BETA)
                        xor     SignOnly8Bit                ; d = -beta (Q value)
                        ld      d,a                         ; .
                        ld      a,(SBnKzlo)                 ; HLE = z
                        ld      e,a                         ; .
                        ld      hl,(SBnKzhi)                ; .
                        call    mulHLEbyDSigned             ; DELC = z * -beta, so DEL = Z * -beta / 256 where d = sign byte
.SaveAlphaMulZ:         ;ld      a,c                         ; a = upper byte of results which will have the sign             ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      (SunBetaMulZ),a             ; save sign from result, ELC holds actual result                 ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      a,l                         ; also save all of alpha *X as we will need it later             ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      (SunBetaMulZ+1),a           ; .                                                              ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      a,e                         ; .                                                              ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      (SunBetaMulZ+2),a           ; .                                                              ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      a,d                         ; .                                                              ONLY NEEDED FOR DEBUGGING TEST
                        ;ld      (SunBetaMulZ+3),a           ; we actually only want X1 X2 X3 later as its /256               ONLY NEEDED FOR DEBUGGING TEST
.CalcY:                 ld      bc,de                       ; bch = - Beta * z
                        ld      h,l
                        ld      de,(SunK2+1)                ; DEL = k2
                        ld      a,(SunK2)
                        ld      l,a
                        MMUSelectMathsBankedFns
                        call    AddBCHtoDELsigned           ; DEL = K2 - Beta * Z
                        ld      (SBnKyhi),de                ; y = DEL = K2 - Beta * Z
                        ld      a,l                         ; .
                        ld      (SBnKylo),a                 ; .
.CalcAlphaMulY:         ld      a,(ALPHA)
                        ld      d,a                         ; d = alpha (Q value)
                        ld      a,(SBnKylo)                 ; HLE = x sgn, hi, lo
                        ld      e,a                         ; .
                        ld      hl,(SBnKyhi)                ; .
                        call    mulHLEbyDSigned             ; DELC = y * alpha, so DEL = Y * alpha / 256 where d = sign byte
.SaveAlphaMulY:         ld      a,c                         ; a = upper byte of results which will have the sign
                        ld      (SunAlphaMulY),a            ; save sign from result, ELC holds actual result
                        ld      a,l                         ; also save all of alpha *X as we will need it later
                        ld      (SunAlphaMulY+1),a
                        ld      a,e
                        ld      (SunAlphaMulY+2),a
                        ld      a,d
                        ld      (SunAlphaMulY+3),a                                             
.CalcxPLusAlphaY:       ld      bc,de                        ; BCH = Y sgn, hi, lo, we loose the C from result Deal with sign in byte 4
                        ld      h,l                         ; .
                        ld      de,(SBnKxhi)                ; DEL = Y
                        ld      a,(SBnKxlo)                 ; .
                        ld      l,a                         ; .
                        MMUSelectMathsBankedFns
                        call    AddBCHtoDELsigned           ; DEL = x + alpha * Y
.SaveResult1:           ld      a,d                         ; Result 1 (X) = AHL + DEL
                        ld      h,e                         ;
.CopyResultTo2:         ld      (SBnKxlo+2),a               ; .
                        ld      (SBnKxlo) ,hl               ; .
                        ret
.NoRotation:            ld      a,(DELTA)                   ; BCH = - Delta
                        ReturnIfAIsZero
                        ld      c,0                         ;
                        ld      h,a                         ; 
                        ld      b,$80                       ;
                        ld      de,(SBnKzhi)                ; DEL = z position
                        ld      a,(SBnKzlo)                 ; .
                        ld      l,a                         ; .
                        MMUSelectMathsBankedFns
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