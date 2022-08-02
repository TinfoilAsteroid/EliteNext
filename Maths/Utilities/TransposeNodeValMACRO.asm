;--------------------------------------------------------------------------------------------------------
; Process edges
; .....................................................
TransposeNodeVal:   MACRO arg0?
        ldCopyByte  UBnK\0sgn,Ubnk\1PointSign           ; UBnkXSgn => XX15+2 x sign
        ld          bc,(UBnkXX12\0Lo)                   ; c = lo, b = sign   XX12XLoSign
        xor         b                                   ; a = UBnkKxsgn (or XX15+2) here and b = XX12xsign,  XX12+1 \ rotated xnode h                                                                             ;;;           a = a XOR XX12+1                              XCALC
        jp          m,NodeNegative\1                                                                                                                                                            ;;;           if sign is +ve                        ::LL52   XCALC
; XX15 [0,1] = INWK[0]+ XX12[0] + 256*INWK[1]                                                                                       ;;;          while any of x,y & z hi <> 0 
NodeXPositive\1:
        ld          a,c                                 ; We picked up XX12+0 above in bc Xlo
        ld          b,0                                 ; but only want to work on xlo                                                           ;;;              XX15xHiLo = XX12HiLo + xpos lo             XCALC
        ld          hl,(UBnK\0lo)                       ; hl = XX1 UBNKxLo
        ld          h,0                                 ; but we don;t want the sign
        add         hl,bc                               ; its a 16 bit add
        ld          (Ubnk\1Point),hl                    ; And written to XX15 0,1 
        xor         a                                   ; we want to write 0 as sign bit (not in original code)
        ld          (UbnkXPointSign),a
        jp          FinishedThisNode\1
; If we get here then _sign and vertv_ have different signs so do subtract
NodeNegative\1:        
LL52\1:                                                 ;
        ld          hl,(UBnK\0lo)                       ; Coord
        ld          bc,(UBnkXX12\0Lo)                   ; XX12
        ld          b,0                                 ; XX12 lo byte only
        sbc         hl,bc                               ; hl = UBnKx - UBnkXX12xLo
        jp          p,SetAndMop\1                       ; if result is positive skip to write back
NodeXNegSignChange\1:        
; If we get here the result is 2'c compliment so we reverse it and flip sign
        call        negate16hl                          ; Convert back to positive and flip sign
        ld          a,(Ubnk\1PointSign)                 ; XX15+2
        xor         $80                                 ; Flip bit 7
        ld          (Ubnk\1PointSign),a                 ; XX15+2
SetAndMop\1:                             
        ld          (UBnK\0lo),hl                       ; XX15+0
FinishedThisNode\1
                    ENDM