;INPUTS: ahl = dividend cde = divisor
;OUTPUTS: cde = quotient ahl = remainder
Div24by24:              ld b,a   
                        push hl   
                        pop ix
                        ld l,24
                        push hl
                        xor a
                        ld h,a
                        ld l,a
.Div24by24loop:         add ix,ix
                        rl b
                        adc hl,hl
                        rla
                        cp c
                        jr c,.Div24by24skip
                        jr nz,.Div24by24setbit
                        sbc hl,de
                        add hl,de
                        jr c,.Div24by24skip
.Div24by24setbit:       sbc hl,de
                        sbc a,c
                        inc ix
.Div24by24skip:         ex (sp),hl
                        dec l
                        ex (sp),hl
                        jr nz,.Div24by24loop
                        pop de
                        ld c,b
                        push ix
                        pop de
                        ret
                        
Div24by24LeadSign:      ld      iyh,a           ; Preserve signed in IYL
                        xor     c               ; flip sign if negative
                        and     SignOnly8Bit    ; .
                        ld      iyl,a           ; .
                        ld      a,c             ; make both values ABS
                        and     SignMask8Bit    ; .
                        ld      c,a             ; .
                        ld      a,iyh           ; .
                        and     SignMask8Bit    ; .
                        call    Div24by24       ; do abs divide
                        or      iyl             ; bring in sign bit
                        ld      iyh,a           ; save a
                        ld      a,c             ; sort sign for c
                        or      iyl             ; 
                        ld      c,a             ; 
                        ld      a,iyh           ; sort sign of a
                        ret
                        
; --------------------------------------------------------------
;divdide by 16 using undocumented instrunctions
;Input: BC = Dividend, DE = Divisor, HL = 0
;Output: BC = Quotient, HL = Remainder
PROJ256mulAdivQ:        ld      b,a
                        ld      c,0
                        ld      d,0
                        ld      a,(varQ)
                        ld      e,a
PROJDIV16UNDOC:         ld      hl,0
                        ld      a,b 
                        ld      b,16
PROJDIV16UNDOCLOOP:     sll     c       ; unroll 16 times
                        rla             ; ...
                        adc     hl,hl       ; ...
                        sbc     hl,de       ; ...
                        jr      nc,PROJDIV16UNDOCSKIP       ; ...
                        add     hl,de       ; ...
                        dec     c       ; ...
PROJDIV16UNDOCSKIP:     djnz    PROJDIV16UNDOCLOOP
                        ld      a,c
                        ld      (varR),a
                        ret

;INPUTS:    bhl = dividend  cde = divisor where b and c are sign bytes
;OUTPUTS:   cahl = quotient cde = divisor
DVID3B2:                ld      (varPhi2),a                     ;DVID3B2 \ Divide 3 bytes by 2, K = [P(HiLo).A]/[INWK_z HiLo], for planet radius, Xreg protected. ; P+2    \ num sg
                        ldCopy2Byte UBnKzlo, varQ               ; [QR} = Ubnk zlohi  (i.e. Inwk_z HiLo)
                        ld      a,(UBnKzsgn)                    ; 
                        ld      (varS),a                        ; S = inkw z sign 
DVID3B:                 ld      de,(varP)                       ; K (3bytes)=P(Lo Hi Hi2)/S.R.Q approx  Acc equiv K(0).; get P and P+1 into de
                        ld      a,e                             ; num lo
                        or      1                               ; must be at least 1
                        ld      (varP),a                        ; store
                        ld      e,a                             ; update DE too
                        ld      a,(varPhi2)                     ; varP Sign     E.D.A = P Lo Hi Hi2
                        ld      hl,varS                         ; hl = address of VarS
                        xor     (hl)                            ; A = PHi2 Xor S Signs
                        and     $80                             ; 
                        ld      (varT),a                        ; T = Sign bit of A
                        ld      iyl,0                           ; iyl = yReg = counter
                        ld      a,(varPhi2)                     ; 
                        and     $7F                             ; A = Ph2 again but minus sign bit 
DVL9:                   JumpIfAGTENusng $40,DV14                ; counter Y up; if object is over $40 away then scaled and exit Y count
                        ShiftDELeft1                            ; de (or P,P1) > 1
                        rl      a                               ; and accumulator as 3rd byte
                        inc     iyl
                        jp      nz,DVL9                         ; loop again with a max of 256 iterations
DV14:                   ld      (varPhi2),a                     ; scaled, exited Ycount
                        ld      (varP),de                       ; store off the value so far
                        ld      a,(varS)                        ; zsign
                        and     $7F                             ; denom sg7
                        ; jp mi,DV9                             ; this can never happen as bit 7 is and'ed out
                        ld      hl,(varQ)                       ; demon lo
DVL6:                   dec     iyl                             ; counter Y back down, roll S. ;  scale Y back
                        ShiftHLLeft1
                        rl      a                               ; mulitply QRS by 2
                        jp      p,DVL6                          ; loop roll S until Abit7 set.
DV9:                    ld      (varQ),hl                       ; bmi cant enter here from above ; save off so far
                        ld      (varQ),a                        ; Q \ mostly empty so now reuse as hi denom
                        ld      a,$FE                           ;  Xreg protected so can't LL28+4
                        ld      (varR),a                        ;  R
                        ld      a,(varPhi2)                     ; P+2 \ big numerator
                        call    PROJ256mulAdivQ                 ; TODO LL31\ R now =A*256/Q
                        ld      a,0
                        ld      (varKp1),a
                        ld      (varKp2),a
                        ld      (varKp3),a                      ; clear out K+1 to K+3
                        ld      a,iyl                           ; Y counter for scale
                        JumpOnBitClear a,7,DV12                 ; Ycount +ve
                        ld      a,(varR)                        ; R     \ else Y count is -ve, Acc = remainder.
                        ld      de,(varK)                       ; d= k1
                        ld      hl,(varK2)                      ; h = k3, l = k2
                        ld      e,a                             ; use e to hold K0 pulled from a
DVL8:                   sla     a                               ; boost up a                     ;  counter Y up
                        rl      d                               ; k1
                        rl      l                               ; k2
                        rl      h                               ; k3
                        inc     iyl
                        jr      nz,DVL8                         ;
DVL8Save:               ld      (varK),de
                        ld      (varK2),hl                      ; save back K0 to k3
                        ld      a,(varT)
                        ld      c,a                             ; get varT into c reg 
                        ld      a,h                             ; a= k3 (sign)
                        or      c                               ; merge in varT (sign)that was saved much earlier up)
                        ld      (varK3),a                       ; load sign bit back into K3
                        ret
DV12:                   IfAIsZeroGoto   DV13                    ; Y Count zerp, go to DV13
                        ld      a,(varR)                        ; Reduce Remainder
DVL10:                  srl     a                               ; divide by 2                     ; counter Y reduce
                        dec     iyl
                        jp      nz,DVL10                        ; loop y reduce until y is zero
                        ld      (varK),a                        ; k Lo
                        ldCopyByte  varT,varKp3                 ; Copy sign to K+3
                        ret
DV13:                   ldCopyByte  varR,varK                   ; R \ already correct so copy to K lo;DV13   \ Ycount zero \ K(1to2) already = 0
                        ldCopyByte  varT,varKp3                 ; Copy sign to K+3
                        ret
 
    
PLS6:                   call    DVID3B2                         ; Returns AHL K ( 2 1 0 )
                        ld      a,(varKp3)
                        and     $7F
                        ld      hl,varKp2
                        or      (hl)
                        jp      nz,PL44TooBig
                        ld      a,(varKp1)
                        cp      4                               ; if high byte > 4 then total > 1024 so too big
                        jr      nc,PL44TooBig
                        ClearCarryFlag                          ; we have a good result regardless
                        ld      hl,(varK)                       ; get K (0 1)
                        ld      a,(varKp3)                      ; if sign bit high?
                        bit     7,a
                        ret     z                               ; no so we can just return
PL44:                   ret 
PL44TooBig:             scf
                        ret
                        