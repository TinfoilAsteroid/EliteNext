;;; Q = XX12 xLo ,A = XX15 xLo
;;; T = A * Q/256 Usgined  (FMLTU)
;;; S = XX12 XSign Xor XX15 XSign
;;; Q = XX12 Ynormal Lo, A = XX15+2 (y lo)
;;; Q = A * Q/256 Usigned (FMLTI)
;;; R = T
;;; A = XX12+3 (ySign) Xor XX15+3 (ySign)
;;; T = BADD s(A) = R + Q(SA) (xdot + ydot)
;;; Q = XX12+4 (znormal lo) A = XX15+4 z lo
;;; Q = A * Q /256 usigned (zdot)
;;; R = T
;;; A - XX15+ 5 Zsign Xor XX12+5 Z Sign



DotProductXX12XX15:
        ld          a,(UBnkXX12xLo)         ; Use e as var Q for xnormal lo
        JumpIfAIsZero dotxskipzero
        ld          e,a
        ld          a,(UBnkXScaled)         ; use d as XX12 world xform x, e = norm x
        ld          d,a                     ; de = xx12 x signed 
        JumpIfAIsZero dotxskipzero
		mul
        ld          b,d                     ; b = result
        ld          a,(UBnkXX12xSign)
        ld          hl,UBnkXScaledSign
        xor         (hl)
        and         $80                     ; so sign bit only
        ld          iyh ,a                   ; we actually need to preserve sign in iyh here
        jp          dotmuly
dotxskipzero:
        xor         a
        ld          b,a
        ld          iyh,a
dotmuly:        
; now we have b = XX12 x &d  norm x signed  
        ld          a,(UBnkXX12yLo)
        JumpIfAIsZero dotyskipzero
        ld          e,a
        ld          a,(UBnkYScaled)         ; XX15+2
        JumpIfAIsZero dotyskipzero
        ld          d,a                     ; de = xx12 x signed 
        mul         
        ld          c,d                     ; c = result
        ld          ixl,c
        ld          a,(UBnkXX12ySign)       ; A = ysg
        ld          hl, UBnkYScaledSign     ; a= y sign XOR Y scaled sign
        xor         (hl)                    ; XX15+3
        and         $80                     ; do b = x mul c = y mul, iyh = sign for b and a = sign for c
        ld          ixh,a
        jp          dotaddxy
dotyskipzero:
        xor         a
        ld          c,a
        ld          ixh,a
dotaddxy:
; Optimise later as this is 16 bit
        ld          h,0                     ;
        ld          l,b                     ; hl = xlo + x scaled
        ld          d,0                     ;
        ld          e,c                     ; de = ylo + yscaled
        ld          b,iyh                   ; b = sign of xlo + xscaled
        ld          c,a                     ; c = sign of ylo + yscaled
        MMUSelectMathsBankedFns
        call ADDHLDESignBC                  ; so now hl = result so will push sign to h
        ld          b,a                     ; b = resultant sign , hl = add so far
        ld          a,(UBnkXX12zLo)         ; 
        JumpIfAIsZero dotzskipzero
        ld          e,a                     ; 
        ld          a,(UBnkZScaled)         ;
        JumpIfAIsZero dotzskipzero
        ld          d,a
        mul
        push        hl                      ; save prev result
        ld          a,(UBnkZScaledSign)
        ld          hl, UBnkXX12zSign       ; XX15+5
        xor         (hl)                    ; hi sign
        and         $80                     ; a = sign of multiply
        ld          c,a                     ; c = sign of z lo & z scaled
        pop         hl
        ld          e,d
        ld          d,0
        MMUSelectMathsBankedFns
        call ADDHLDESignBC
        ld          (varS),a
        ld          a,l
        ret                                 ; returns with A = value, varS = sign
dotzskipzero:                               ; if we got here then z was zero so no component so just tidy up from last add
        ld          a,b
        ld          (varS),a
        ld          a,l
        ret
;;;;       DotProductXX12XX15:
;;;;       ld          a,(UBnkXX12xLo)         ; Use e as var Q for xnormal lo
;;;;       ld          e,a
;;;;       ld          a,(UBnkXScaled)         ; use d as XX12 world xform x, e = norm x
;;;;       ld          d,a                     ; de = xx12 x signed 
;;;;		; FMLTU	\ A=A*Q/256unsg using D as A and E as Q
;;;;		mul
;;;;       ld          b,d                     ; b as var T
;;;;       ld          a,(UBnkXX12xSign)
;;;;       ld          hl,UBnkXScaledSign
;;;;       xor         (hl)
;;;;       and         $80                     ; so sign bit only
;;;;       ld          (varS),a                ; we did use c as S \ S	\ x-sign, but we actually need it in varS for BADD
;;;; now we have b = XX12 x & norm x signed        
;;;; by here B = xlo & xscaled C = result sign	
;;;;       ld          a,(UBnkXX12yLo)
;;;;       ld          e,a
;;;;       ld          a,(UBnkYScaled)         ; XX15+2
;;;;		ld          d,a						; MISSED THIS EARLIER BUG FIX
;;;;       mul         
;;;;       ld          a,d
;;;;       ld          (varQ),a                ; Q = Y y-dot
;;;;       ld          a,b                     ; get back T from above held in b
;;;;       ld          (varR),a                ; R= b \ T	\ x-dot
;;;;       ld          a,(UBnkXX12ySign)       ; A = ysg
;;;;       ld          hl, UBnkYScaledSign     ; a= y sign XOR Y scaled sign
;;;;       xor         (hl)                    ; XX15+3
;;;;       and         $80
;;;;       call        baddll38                ; LL38	\ BADD(S)A=R+Q(SA)   \ 1byte add (subtract)
;;;;       ld          (varT),a                ; var T	\ xdot+ydot
;;;;       ld          a,(UBnkXX12zLo)         ; use d as  varQ        ; XX12+4	\ znormal lo to varQ
;;;;       ld          e,a                     ; use e as var Q
;;;;       ld          a,(UBnkZScaled)         ;
;;;;       ld          d,a
;;;;       mul
;;;;       ld          a,d
;;;;       ld          (varQ),a                ; Q	\ zdot
;;;;       ldCopyByte  varT,varR               ; copy T to R so R = resutl of previous calc
;;;;       ld          a,(UBnkZScaledSign)
;;;;       ld          hl, UBnkXX12zSign       ; XX15+5
;;;;       xor         (hl)                    ; hi sign
;;;;       and         $80
;;;;       call        baddll38                ; LL38	\ BADD(S)A=R+Q(SA)   \ 1byte add (subtract)
;;;;       ret                                 ; returns with A = value, varS = sign
		