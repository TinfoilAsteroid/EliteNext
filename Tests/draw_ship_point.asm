

ShipPlotPoint:
SHPPT:	                                    ; ship plot as point from LL10
    call    EraseOldLines                   ; EE51	\ if bit3 set draw to erase lines in XX19 heap
SHPPT_ProjectToK3K4:
    call    Project                         ; PROJ	\ Project K+INWK(x,y)/z to K3,K4 for craft center
SHPTOnScreenTest:    
	ld		hl,(varK3)						; get X Y ccords from K3 and K4
	ld		de,(varK4)
	ld		a,h
	or		d								;
	jr		nz,SHPTFinishup					; quick test to see if K3 or K4 hi are populated , if they are its too big (or negative coord)
	ld		a,e								; k4 or Y lo
	JumpIfAGTENusng ViewHeight,SHPTFinishup	; off view port?
SHPTInjectFalseLine:						; it will always be 1 line only
	ld		a,1
	ld		(UBnkLineArrayLen),a
	ld		a,4
	ld		(UBnkLineArrayLen),a
	ld		d,l                             ; de = Y lo X hi
	ld		hl,UBnkLineArray				; head of array
	ld		(hl),d
	inc		hl
	ld		(hl),e
	inc		hl
	ld		(hl),d
	inc		hl
	ld		(hl),e
	inc		hl								; write out point as a line for clean up later
SHPTIsOnScreen:	
	ld		b,e
	ld		c,d								; bc = XY
	ld		a,ShipColour
	MMUSelectLayer2
    call    l2_plot_pixel
SHPTFinishup:
    ld      a,(UBnkexplDsp)
    and     $F7                             ;  clear bit3
    ld      (UBnkexplDsp),a                 ; set bit3 (to erase later) and plot as Dot display|missiles explosion state
    ret                                     ; now it will return to the caller of 
    

;
;DrawLineBCtoDE:
;LIONBCDE:
;    -- Set colour etc
;    call    l2_draw_diagonal:
;; ">l2_draw_diagonal, bc = y0,x0 de=y1,x1,a=color) Thsi version performs a pre sort based on y axis"
DVID3B2:                ld      (varPhi2),a                     ;DVID3B2 \ Divide 3 bytes by 2, K = [P(HiLo).A]/[INWK_z HiLo], for planet radius, Xreg protected. ; P+2    \ num sg
                        ldCopy2Byte UBnkzlo, varQ               ; [QR} = UBnk zlohi  (i.e. Inwk_z HiLo)
                        ld      a,(UBnkzsgn)                    ; 
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
DVL6:                   dec     iyl                             ; counter Y back down, dddd S. ;  scale Y back
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
DV12:                   JumpIfAIsZero   DV13                    ; Y Count zerp, go to DV13
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
Project:
PROJ:                   ld      hl,(UBnkxlo)                    ; Project K+INWK(x,y)/z to K3,K4 for center to screen
                        ld      (varP),hl
                        ld      a,(UBnkxsgn)
                        call    PLS6                            ; returns result in K (0 1) (unsigned) and K (3) = sign note to no longer does 2's C
                        ret     c                               ; carry means don't print
                        ld      hl,(varK)                       ; hl = k (0 1)
                        ; Now the question is as hl is the fractional part, should this be multiplied by 127 to get the actual range
                        ld      a,ViewCenterX
                        add     hl,a                            ; add unsigned a to the 2's C HL to get pixel position
                        ld      (varK3),hl                      ; K3 = X position on screen
ProjectY:               ld      hl,(UBnkylo)
                        ld      (varP),hl
                        ld      a,(UBnkysgn)
                        call    PLS6
                        ret     c
                        ld      hl,(varK)                       ; hl = k (0 1)
                        ld      a,ViewCenterY
                        add     hl,a                            ; add unsigned a to the 2's C HL to get pixel position
                        ld      (varK4),hl                      ; K3 = X position on screen
                        ret
