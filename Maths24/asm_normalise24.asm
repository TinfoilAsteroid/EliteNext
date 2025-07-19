

; takes a 3x24 bit vector and normalilses them, this is done by taking the ABS values scaling down into a maxioum of a 15 bit number

; gets high bytes of vector at IX

; sets h = abs x sign, l = abs y sgn d and a to abs z|y|x sgn
SetAHLDToABSXYZSgn      MACRO
                        ld      a,(ix+2)
                        and     $7F
                        ld      h,a
                        ld      a,(ix+5)
                        and     $7F
                        ld      l,a
                        ld      a,(ix+8)
                        and     $7F
                        ld      d,a
                        or      h
                        or      l
                        ENDM

SetAHLDToABSXYZHi      MACRO
                        ld      a,(ix+1)
                        ld      h,a
                        ld      a,(ix+4)
                        ld      l,a
                        ld      a,(ix+7)
                        ld      d,a
                        or      h
                        or      l
                        ENDM

SetAHLDToABSXYZLo       MACRO
                        ld      a,(ix+0)
                        ld      h,a
                        ld      a,(ix+3)
                        ld      l,a
                        ld      a,(ix+6)
                        ld      d,a
                        or      h
                        or      l
                        ENDM
                        
SetDEAtoABSX:           MACRO
                        ld      de,(ix+1)
                        ld      a,(ix+0)
                        res     7,d
                        ENDM

SetDEAtoABSY:           MACRO
                        ld      de,(ix+4)
                        ld      a,(ix+3)
                        res     7,d
                        ENDM                        

SetDEAtoABSZ:           MACRO
                        ld      de,(ix+7)
                        ld      a,(ix+6)
                        res     7,d
                        ENDM
                        
SetHLtoABSXHiLo:        MACRO
                        ld      hl,(ix)
                        ENDM
                        
SetDEtoABSYHiLo:        MACRO
                        ld      de,(ix+3)
                        ENDM

SetBCtoABSZHiLo:        MACRO
                        ld      bc,(ix+6)
                        ENDM

SetHLtoABSXSgnHi:       MACRO
                        ld      hl,(ix+1)
                        ld      a, h
                        and     $7F
                        ld      h,a
                        ENDM
                       
SetDEtoABSYSgnHi:       MACRO
                        ld      de,(ix+4)
                        ld      a, d
                        and     $7F
                        ld      d,a
                        ENDM
                        
SetBCtoABSZSgnHi:       MACRO
                        ld      bc,(ix+7)
                        ld      a, b
                        and     $7F
                        ld      b,a
                        ENDM
                        
SetNormXToHL:           MACRO
                        ld     (ix+20),hl
                        ENDM
                        
SetNormXToDE:           MACRO
                        ld     (ix+20),de
                        ENDM
                        
SetNormYToDE:           MACRO
                        ld     (ix+22),de
                        ENDM
                        
SetNormZToBC:           MACRO
                        ld     (ix+24),bc
                        ENDM
                        
SetNormZToDE:           MACRO
                        ld     (ix+24),de
                        ENDM                        

NormXMul96:             MACRO
                        ld      e,a
                        ld      d,96
                        mul     de
                        ld      a,d                 ; is norm 0,
                        or      e                   ; if so we can skip
                        jp      z,.DoneNorm96Y      ; sign check
                        ld      a,(ix+2)            ;
                        and     $80                 ;
                        or      d
                        ld      d,a
.DoneNorm96X:                        
                        ENDM

NormYMul96:             MACRO
                        ld      e,a
                        ld      d,96
                        mul     de
                        ld      a,d                 ; is norm 0,
                        or      e                   ; if so we can skip
                        jp      z,.DoneNorm96Y      ; sign check
                        ld      a,(ix+5)            ;
                        and     $80                 ;
                        or      d
                        ld      d,a
.DoneNorm96Y:                        
                        ENDM

NormZMul96:             MACRO
                        ld      e,a
                        ld      d,96
                        mul     de
                        ld      a,d                 ; is norm 0,
                        or      e                   ; if so we can skip
                        jp      z,.DoneNorm96Y      ; sign check
                        ld      a,(ix+8)            ;
                        and     $80                 ;
                        or      d
                        ld      d,a
.DoneNorm96Z:                        
                        ENDM

PrepScale:              MACRO                       ;setg [A IYH] to or'ed all bytes of ABS X,Y,Z
                        ld      a,h                 
                        or      d
                        or      c
                        ld      iyh,a
                        ld      a,l
                        or      e
                        or      c
                        or      1                   ; we can never have a status where hl,de,bc are 0 but we will force bit 1 to be safe
                        ENDM

ScaleHLD:               MACRO
                        ld      a,h
                        or      l
                        or      d
                        jp      nz,.StartShift      ; if its zero then we need to set to at least 1 to avoid infinite loop and hence divide by 0 later
                        ld      a,1
                        ld      h,a
                        ld      l,a
                        ld      d,a
                        jp      .DoneShift
.StartShift:            bit     7,a                 ; if its already 7 bit then shift right one
                        jp      z,.ShiftLoop
.ShiftRight:            srl     h
                        srl     l
                        srl     d
                        jp      .DoneShift
.ShiftLoop:             sla     a
                        jp      m,.DoneShift        ; so if a bit ends up in bit 7 that measn that its negative so we can stop now leavign HLD as 7 bit
                        sla     h
                        sla     l
                        sla     d
                        jp      .ShiftLoop
.DoneShift:
                        ENDM
                        
CalculateScale:         MACRO
                        ld      iyl,a
                        exx                         ; save off registers so we can use altgernates for barrel shift calc
                        ld      b,0             
                        ld      de,iy               ; moving iy to de for faster bit and shift operations
                        ; as we ABS then bit 7 can never have been set anmd we want to stop after setting bit 6 so max range is 16129 (127 ^ 2)
.ScaleLoop:             bit     6,d                 ; this loop will find the minium number of shifts requried
                        jp      nz,.DoneShift       ; if bit 6 is set then we have done enough shifts
                        ShiftDELeft1
                        inc     b
                        jp      .ScaleLoop
.DoneShift              ld      a,b                 ; b is all we are interestred in so save it in IYL
                        exx                         ; now we have the vector coords recovered
                        ENDM
ScaleY:                 MACRO
                        ld      b,a                 ; shift de
                        bsrl    de,b
                        ENDM
ScaleX:                 MACRO                       ; as b is already loaded we can just swap over de,hl and do the shift
                        ex      de,hl
                        bsrl    de,b
                        ENDM
ScaleZ:                 MACRO                       ; as b is already loaded we can just swap over de,hl and do the shift
                        push    de                  ; we need DE spare
                        ld      de,bc
                        ld      b,a
                        bsrl    de,b
                        ld      bc,de
                        pop     de
                        ENDM    
SquareX:                MACRO
                        ex      de,hl
                        mul     de
                        ex      de,hl
                        ENDM
SquareY:                MACRO
                        mul     de
                        ENDM
SquareZ:                MACRO
                        ld      de,bc
                        mul     de                  ; d * e
                        ENDM
                        
Normalise24IX:          break
                        ld      b,0                 ; B = 0
.GetAllSignBytes:       SetAHLDToABSXYZSgn          ; get ABS X,Y,Z Sign into H L D and set a to X|Y|Z (abs values), will also set or flags
                        jp      nz,.PerformShift    ; if we have values in sign then we use that for divide
.HiLoOnly:              SetAHLDToABSXYZHi           
                        jp      z,.LoOnly           ; Signs are all 0 
                        jp      .PerformShift
.LoOnly:                SetAHLDToABSXYZLo           ; High bytes are all 0 so we use lo bytes
.PerformShift:          ScaleHLD                    ; now scale all teh values so we have H = X, L = Y, D = Z
                        ld      e,d                 ; prep for squares
                        push    hl,,de              ; and save off current values
                        exx                         ; and work from alternates for squares
                        pop     hl,,de
                        mul     de                  ; Z^2
                        ex      de,hl               ; how de = X Y
                        ld      a,d                 ; a = X
                        ld      d,e                 ; Y^2
                        mul     de                  ;
                        ld      bc,de               ; bc = Y^2
                        ld      d,a                 ; X^2
                        ld      e,a                 ;
                        mul     de                  ;
                        add     hl,de               ; hl = x^2 + z^2 + y ^2
                        add     hl,bc               ; .
                        call    sqrtHL              ; a = sqrt (hl)
                        exx                         ; now get back HLD for XYZ
.performNorm:           ld      iyh,a               ; save a copy of sqrt                                              
.NormaliseZ:            ld      a,d                 ; divide X by sqrt
                        ld      d,iyh               ; 
                        break
                        call    AEquAmul256DivD
                        NormZMul96
                        SetNormZToDE                ;
.NormaliseY:            ld      a,l
                        ld      d,iyh
                        call    AEquAmul256DivD
                        NormYMul96
                        SetNormYToDE 
.NormaliseX:            ld      a,h
                        ld      d,iyh
                        call    AEquAmul256DivD
                        NormXMul96
                        SetNormXToDE
                        ret
