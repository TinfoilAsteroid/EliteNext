;note: DIV16Amul256dCUNDOC as per
;                                   BC = A0
;                                   DE = 0C
;                                   so BC = a * 256 / C

; We can cheat here, Speed is always 0 or positive
; z postion will always be positive if we can see it 

InitStarAtHL:           ex      de,hl               ; preserving hl
                        call    doRND               ; a = random OR bit 5
                        ex      de,hl               ; .
                        or      8                   ; .
                        ld      (hl),a              ; save to x pos
                        and     $7F                 ; a = abs a
                        inc     hl                  ; 
                        ld      (hl),a              ;
                        ex      de,hl               ; preserving hl 
                        call    doRND               ; a = -ve (random / 2)
                        ex      de,hl               ; .
                        rrca                        ; .
                        and     $80                 ; .
                        or      (hl)                ; or with 
                        ld      (hl),a
                        inc     hl
                        ex      de,hl
                        call    doRND
                        ex      de,hl
                        or      4
                        ld      (hl),a
                        inc     hl
                        and     $7F
                        ld      (hl),a
                        ex      de,hl
                        call    doRND
                        ex      de,hl
                        rrca    
                        and     $80
                        or      (hl)
                        ld      (hl),a
                        inc     hl
                        ex      de,hl
                        call    doRND
                        ex      de,hl
                        or      144
                        ld      (hl),a
                        inc     hl
                        or      %01110000
                        and     $7f     ; bodge
                        ld      (hl),a
                        inc     hl
                        ret
                        
InitHyperStarAtHL:      ex      de,hl
                        call    doRND
                        sla     a
                        sla     a                ; so its * 4 as we have a blank spot
                        ex      de,hl
                        and     %11111000
                        ld      (hl),a
                        and     $7F
                        inc     hl
                        ld      (hl),a
                        ex      de,hl
                        call    doRND
                        ex      de,hl
                        rrca    
                        and     $80
                        or      (hl)
                        ld      (hl),a
                        inc     hl
                        ex      de,hl
                        call    doRND
                        sla     a
                        sla     a               ; so its * 4 as we have a blank spot
                        ex      de,hl
                        and     %11111000
                        ld      (hl),a
                        inc     hl
                        and     $7F
                        ld      (hl),a
                        ex      de,hl
                        call    doRND
                        ex      de,hl
                        rrca    
                        and     $80
                        or      (hl)
                        ld      (hl),a
                        inc     hl
                        ex      de,hl
                        call    doRND
                        ex      de,hl
                        or      95
                        ld      (hl),a
                        inc     hl
                        or      %01110000
                        and     $7f     ; bodge
                        ld      (hl),a
                        inc     hl
                        ret                        

;----------------------------------------------------------------------------------------------------------------------------------        
InitialiseStars:        ld      b,MaxNumberOfStars
                        ld      hl,varDust
.InitStarsLoop:         call    InitStarAtHL
                        djnz    .InitStarsLoop
                        ret
;----------------------------------------------------------------------------------------------------------------------------------        
InitialiseHyperStars:   ld      b,MaxNumberOfStars
                        ld      hl,varDust
.InitStarsLoop:         call    InitHyperStarAtHL
                        djnz    .InitStarsLoop
                        ret
;----------------------------------------------------------------------------------------------------------------------------------
SaveCurrentDust:        ld          iy,varDust
                        ld          ix,varDustWarpRender
                        ld          b, MaxNumberOfStars
.SaveLoop               ld          a,(iy+1)
                        ld          l,a
                        and         $7F
                        JumpOnBitSet l,7,.StarNegXPt
                        add         a,$80
                        ld          e,a
                        jp          .StarDoneX
.StarNegXPt:            ld          d,a
                        ld          a,$80
                        sub         d
                        ld          e,a
.StarDoneX:             ld          a,(iy+3)
                        ld          l,a
                        and         $7F
                        JumpOnBitSet l,7,.StarNegYPt
                        add         a,$60
                        ld          d,a
                        jp          .StarDoneY
.StarNegYPt:            ld          d,a
                        ld          a,$60
                        sub         d
                        ld          d,a
.StarDoneY:             ld          (ix+0),e
                        ld          (ix+1),d
                        inc         ix
                        inc         ix
                        ld          hl,iy
                        ld          a,6
                        add         hl,a
                        ld          iy,hl
                        djnz        .SaveLoop
                        ret
                                
;----------------------------------------------------------------------------------------------------------------------------------
DustForward:            ld      b,MaxNumberOfStars                  ; get the number of stars to process
                        ld      iy,varDust                          ; hl is now a pointer to the dust array
StarProcessLoop:        push    bc                                  ; save counter +1
.Qequ64XSpeedDivZHi:    ld      a,(iy+5)                            ; e  = z high
                        ld      e,a                                 ; d = 0
                        ld      d,0                                 ; de = zhi/256
                        ld      a,(DELTA)                           ; a = speed
                        JumpIfAIsNotZero .NormalSpeed               ; if we are stationary set speed 
                        inc     a                                   ; so it is at least some dust movement
.NormalSpeed:           ld      b,a                                 ;
                        ld      c,0                                 ; bc = delta * 256
                        call    BC_Div_DE                           ; BC = Speed/Z , HL = remainder
                        ShiftHLRight1
                        ShiftHLRight1                               ; hl = remainder/2 so now 64 * speed / zhi
                        ld      a,l                                 ; 
                        or      1                                   ; so ensure A is at least 1 for ambient movement
                        ld      ixl,a                               ; preserve A which is also VarQ = 64 * speed / zhi
.ZequZMinusSpeedX64:    ld      hl,(iy+4)                           ; hl = z
                        ld      de, (DELTA4)                         ; de = delta4 i.e. speed * 64 pre computed
                        call    subHLDES15
                        JumpOnBitSet h,7,ResetStar                  ; if z ended up negative then reset the star
                        ld      (iy+4),hl                           ; save new z pos
.XEquXPlusXhiMulQ       ld      hl,(iy+0)                           ; hl  = x
                        ld      a,h                                 ;
                        and     $7F                                 ; 
                        ld      d,a                                 ; d = abs(x hi)
                        ld      e,ixl                               ; e = Q = 64 * speed / zhi
                        mul                                         ; de =  abs(x hi) * Q
                        ld      a,h                                 ;
                        and     $80                                 ;
                        or      d                                   ; set sign bit in d
                        ld      d,a                                 ;
                        call    ADDHLDESignedV4                  ; x = x + (x hi/256 * Q)
                        ld      a,h
                        and     $7F
                        JumpIfAGTENusng $70, ResetStar
                        ld      (iy+0),hl                           ;
.YEquYPlusYhiMulQ       ld      hl,(iy+2)                           ; hl  = y
                        ld      a,h                                 ;
                        and     $7F                                 ; 
                        ld      d,a                                 ; d = abs(y hi)
                        ld      e,ixl                               ; e = Q = 64 * speed / zhi
                        mul                                         ; de =  abs(y hi) * Q
                        ld      a,h                                 ;
                        and     $80                                 ;
                        or      d                                   ; set sign bit in d
                        ld      d,a                                 ;
                        call    ADDHLDESignedV4                  ; y = y + (x hi/256 * Q)
                        ld      a,h
                        and     $7F
                        JumpIfAGTENusng $60, ResetStar
                        ld      a,h
                        and     $80
                        jr      nz,.NoSecondCheck
                        ld      a,h
                        JumpIfAGTENusng $20, ResetStar
.NoSecondCheck:         ld      (iy+2),hl                           ;
; Now roll
;  6. x = x - alpha * y / 256  
.XRoll:                 ld      a,(ALP1)                           ; h = sign, l = magnitude
                        cp      0
                        jr      z,.NoRoll                           ; don;t roll if magnitude is 0
                     ;   break
                        ld      l,a                                 ; roll magnitude
                        ld      a,(ALP2FLIP)                        ; inverted roll sign
                        and     SignOnly8Bit                        ; sanitise sign bit
                        ld      h,a                                 ; h = roll sign
                        push    hl                                  ; save on the stack
.rxSaveAlphaSign:       ld      c,a                                 ; save alpha sign in c
.rxDEquABSAlpha:        ld      d,l                                 ; d= abs (alpha)
                        ld      a,(iy+3)                            ; get high byte from x coord
                        ld      e,a                                 ; save signed byte
                        and     SignOnly8Bit                        ; a = sign only
.rxBEquSignXHi:         ld      b,a                                 ; save sign of x in b
.rxEEquABSignX:         ld      a,e                                 ; e = abs byte
                        and     SignMask8Bit                                
                        ld      e,a                                 ; save abs x hi in e
                        mul                                         ; abs(alpha) * abs(y high) (so /256)
                        ld      a,c                                 ; get back sign from roll
                        xor     b                                   ; handle muliple sign bits
                        or      d
                        ld      d,a                                 ; de = signed alpha & y high / 256
                        ld      hl,(iy+0)                           ; h = iy+1, l = iy+0
                        call    subHLDES15                       ; we are usign add, so may need to fip sign?
                        ld      (iy+0),hl
;  5. y = y + alpha * x / 256
.YRoll:                 ;break
                        pop     hl                                  ; h = sign, l = magnitude
.rySaveAlphaSign:       ld      c,h                                 ; save alpha sign in c
.ryDEquABSAlpha:        ld      d,l                                 ; d= abs (alpha)
                        ld      a,(iy+1)                            ; get high byte from x coord
                        ld      e,a                                 
                        and     SignOnly8Bit
.ryBEquSignXHi:         ld      b,a                                 ; save sign of x in b
.ryEEquABSignX:         ld      a,e
                        and     SignMask8Bit                                 
                        ld      e,a                                 ; save abs x hi in e
                        mul                                         ; abs(alpha) * abs(y high) (so /256)
                        ld      a,c
                        xor     b                                   ; handle muliple sign bits
                        or      d
                        ld      d,a                                 ; de = signed alpha & y high / 256
                        ld      hl,(iy+2)                           ; h = iy+1, l = iy+0
                        call    ADDHLDESignedV4                  ; we are usign add, so may need to fip sign?
                        ld      (iy+2),hl
.NoRoll:                ld      a,(BET1)
                        cp      0
                        jr      z,.NoPitch
;  8. y = y - beta * 256
.YPitch:                ld      d,a                                 ; d = BET1
                        ld      a,(iy+2)
                        ld      e,a                                 ; e = Y HI
                        mul                                         ; de = BET1 * YHi so now D = BETA & YHI / 256
                        ld      e,a
                        mul                                         ; so now de = (BETA & Yhi) ^ 2
                        ShiftDELeft1                                ; de = 2 * ((BETA & Yhi) ^ 2)
                        ld      a,(BET2)                            ; get inverted Sign
                        or      d
                        ld      d,a                                 ; de = - (2 * ((BETA & Yhi) ^ 2))
                        ld      hl,(iy+2)
                        call    ADDHLDESignedV4
                        ld      (iy+2),hl
; now work out screen pos
; Note two optimistations, write to layer 2 - we get a free removal via double buffer cls
; read z dept than determine hw many pixesl to plot, e.g. 1,2,3,4
;        pop     de
 ;       call    ProjectStarXToScreen
                        ;pop     de
.NoPitch:
.ProjectStar:           ld      a,(iy+1)
                        ld      l,a
                        and     $7F
                        JumpOnBitSet l,7,StarNegXPt
                        add     a,$80
                        ld      c,a
                        jp      StarDoneX
StarNegXPt:             ld      b,a
                        ld      a,$80
                        sub     b
                        ld      c,a
StarDoneX:              ld      a,(iy+3)
                        ld      l,a
                        and     $7F
                        JumpOnBitSet l,7,StarNegYPt
                        add     a,$60
                        ld      b,a
                        jp      StarDoneY
StarNegYPt:             ld      b,a
                        ld      a,$60
                        sub     b
                        ld      b,a
StarDoneY:              ld      a,L2DustColour
                        push    bc
.DrawStar:              MMUSelectLayer2 
                        call    l2_plot_pixel 
                        ld      a,(iy+5)
                        pop    bc
                        JumpIfAGTENusng $60,EndofStarsLoop
                        ld      a,L2DustColour
                        inc     c
                        push    bc
                        MMUSelectLayer2
                        call    l2_plot_pixel 
                        ld      a,(iy+5)
                        pop    bc
                        JumpIfAGTENusng $37,EndofStarsLoop
                        ld      a,L2DustColour
                        inc     b
                        push    bc
                        MMUSelectLayer2 
                        call    l2_plot_pixel 
                        ld      a,(iy+5)
                        pop    bc
                        ld      a,L2DustColour
                        dec     c
                        MMUSelectLayer2
                        call    l2_plot_pixel  
EndofStarsLoop:         pop     bc                                      ;  0
NextStarLoop3:          push    iy                                      ; +1
                        pop     hl                                      ;  0
                        add     hl,6
NextStarLoop2:          push    hl                                      ; +1
                        pop     iy                                      ;  0
                        dec     b
                        jp      nz,StarProcessLoop
                        ret
ResetStar:              pop     bc                                      ; 0
                        push    iy                                      ; +1 (current star)
                        pop     hl                                      ; 0  
                        call    InitStarAtHL
                        jp      NextStarLoop3
;----------------------------------------------------------------------------------------------------------------------------------               
ProjectStarXToScreen:   ld      c,(iy+0)
                        ld      a,(iy+1)
                        ld      l,a
                        and     $7F
                        ld      b,a
                        call    DIV16BCDivDEUNDOC
                        ld      a,l
                        JumpOnBitSet a,7,StarXNegativePoint             ; LL62 up, -ve Xdist, RU screen onto XX3 heap
;StarXPositivePoint:									; x was positive result
                        ld          l,ScreenCenterX						; 
                        ld          h,0
                        add         hl,bc								; hl = Screen Centre + X
                        jp          StarStoreXPoint
StarXNegativePoint:                                 ; x < 0 so need to subtract from the screen centre position
                        ld          l,ScreenCenterX                     
                        ld          h,0
                        ClearCarryFlag
                        sbc         hl,bc                               ; hl = Screen Centre - X
StarStoreXPoint:                                    ; also from LL62, XX3 node heap has xscreen node so far.    
                        ld          a,l
                        ld          (varStarX),a
                        ret
    
ProjectStarYToScreen:   ld          b,(iy+2)
                        ld          a,(iy+3)
                        ld          l,a
                        and         $7F
                        ld          b,a
                        call        DIV16BCDivDEUNDOC
                        ld          a,l                                 ; XX15+2 \ sign of X dist
                        JumpOnBitSet a,7,StarNegativeYPoint             ; LL62 up, -ve Xdist, RU screen onto XX3 heap top of screen is Y = 0
                    ;StarPositiveYPoint:									; Y is positive so above the centre line
                       ld          l,ScreenCenterY
                        ClearCarryFlag
                        sbc         hl,bc  							 	; hl = ScreenCentreY - Y coord (as screen is 0 at top)
                        jp          StarStoreYPoint
StarNegativeYPoint:									; this bit is only 8 bit aware TODO FIX
                        ld          l,ScreenCenterY						
                        ld          h,0
                        add         hl,bc								; hl = ScreenCenterY + Y as negative is below the center of screen
StarStoreYPoint:                                    ; also from LL62, XX3 node heap has xscreen node so far.
                        ld          a,l
                        ld          (varStarY),a
                        ret
        
                