
;----------------------------------------------------------------------------------------------------------------------------------
; Planet version of pitch and roll is a 24 bit calculation 1 bit sign + 23 bit value
; Need to write a test routine for roll and pitchs
PlanetAlphaMulX            DS 4
PlanetAlphaMulY            DS 4
PlanetBetaMulZ             DS 4
PlanetK2                   DS 3

PlanetApplyMyRollAndPitch: ld      a,(ALPHA)                   ; no roll or pitch, no calc needed
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
                        ;ld      (PlanetAlphaMulX),a            ; save sign from result, ELC holds actual result                   ONLY NEEDED FOR DEBUGGING TEST
                        ld      a,l                         ; also save all of alpha *X as we will need it later
                        ld      (PlanetAlphaMulX+1),a
                        ld      a,e
                        ld      (PlanetAlphaMulX+2),a
                        ld      a,d
                        ld      (PlanetAlphaMulX+3),a          ; we actually only want X1 X2 X3 later as its /256
.CalcK2:                ld      de,(SBnKyhi)                ; DEL = Y
                        ld      a,(SBnKylo)                 ; .
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
.CalcZ:                 ld      bc,(SBnKzhi)                ; BCH = z
                        ld      a,(SBnKzlo)                 ;
                        ld      h,a                         ;
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
                        ld      (PlanetAlphaMulY),a            ; save sign from result, ELC holds actual result
                        ld      a,l                         ; also save all of alpha *X as we will need it later
                        ld      (PlanetAlphaMulY+1),a
                        ld      a,e
                        ld      (PlanetAlphaMulY+2),a
                        ld      a,d
                        ld      (PlanetAlphaMulY+3),a                                             
.CalcxPLusAlphaY:       ld      bc,de                        ; BCH = Y sgn, hi, lo, we loose the C from result Deal with sign in byte 4
                        ld      h,l                         ; .
                        ld      de,(SBnKxhi)                ; DEL = Y
                        ld      a,(SBnKxlo)                 ; .
                        ld      l,a                         ; .
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
                        call    AddBCHtoDELsigned           ; update speed
                        ld      (SBnKzhi),DE                ; write back to zpos
                        ld      a,l
                        ld      (SBnKzlo),a                ;
                        ret
