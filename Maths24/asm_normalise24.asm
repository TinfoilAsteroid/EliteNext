
; takes a 3x24 bit vector and normalilses them, this is done by taking the ABS values scaling down into a maxioum of a 15 bit number

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
                        
Normalise24IX:          ld      b,0                 ; B = 0
.GetAllSignBytes:       SetIYHToSignBits            ; bit 7 = sign X, bit 6 sign Y, bit 5 sign Z
                        SetAHLDToABSXYZSgn          ; get ABS X,Y,Z Sign into H L D and set a to X|Y|Z (abs values), will also set or flags
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
                        DISPLAY "Logging HL and A for diagnotics"
                        SetNormRootToHL             ;
                        SetNormRootAToA             ;
                        exx                         ; now get back HLD for XYZ
.performNorm:           ld      iyl,a               ; save a copy of sqrt as iyh holds sign bits                                        
.NormaliseZ:            ld      a,d                 ; divide X by sqrt
                        ld      d,iyl               ; 
                        call    AEquAmul256DivD
                        SetNormZToA
                        NormZMul96
                        SetNormZ96ToDE                ;
.NormaliseY:            ld      a,l
                        ld      d,iyl
                        call    AEquAmul256DivD
                        SetNormYToA
                        NormYMul96
                        SetNormY96ToDE 
.NormaliseX:            ld      a,h
                        ld      d,iyl
                        call    AEquAmul256DivD
                        SetNormXToA
                        NormXMul96
                        SetNormX96ToDE
                        ret
