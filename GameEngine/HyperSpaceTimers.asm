;----------------------------------------------------------------------------------------------------------------------------------
; The hyperspace countdown, timed by FrameCounter16 (the interrupt's 50 Hz count, which stops while paused) so a second is
; a second however fast the main loop runs. OuterHyperCount is the seconds left, shown 11 to 1; the jump starts when it
; would reach 0. InnerHyperCount is non zero while counting (ViewKeyTest and the warp key test the pair as a word).
; HyperSpaceMessage (main loop, views) draws the text every loop and clears it once when the count stops.

; start the countdown (Front_View, the H key with a target in range)
HyperSpaceStart:        ld      a,HyperSpaceSeconds
                        ld      (OuterHyperCount),a
                        ld      a,1
                        ld      (InnerHyperCount),a
                        ld      hl,(FrameCounter16)                 ; (one instruction: the interrupt can't split it)
                        ld      de,FramesPerSecond
                        add     hl,de
                        ld      (HyperNextTick),hl
                        ret

; stop it (H again, docking, or the jump starting); HyperSpaceMessage then clears the text
HyperSpaceCancel:       xor     a
                        ld      (InnerHyperCount),a
                        ld      (OuterHyperCount),a
                        ret

; once a main loop: a second down each time FrameCounter16 passes HyperNextTick, the jump when it would reach 0
HyperSpaceTick:         ld      a,(InnerHyperCount)
                        and     a
                        ret     z                                   ; not counting
                        ld      a,(DockedFlag)                      ; only in flight (docking stops it)
                        cp      StateNormal
                        jp      nz,HyperSpaceCancel
                        ld      hl,(FrameCounter16)                 ; now - next tick < 0: not yet
                        ld      de,(HyperNextTick)
                        or      a
                        sbc     hl,de
                        bit     7,h
                        ret     nz
                        ex      de,hl                               ; next tick a second on
                        ld      de,FramesPerSecond
                        add     hl,de
                        ld      (HyperNextTick),hl
                        ld      hl,OuterHyperCount
                        dec     (hl)
                        ret     nz                                  ; still counting
                        call    HyperSpaceCancel                    ; 0: jump (draw_hyperspace clears Layer 1)
                        ld      (HyperTextOnScreen),a               ; (a = 0)
                        PlaySFX SFXHyperspace
                        ForceTransition ScreenHyperspace
                        ret

UpdateCountdownNumber:  ld		a,(OuterHyperCount)
                        ld		de,Hyp_counter
                        ld	c, -100
                        call	.Num1
                        ld	c,-10
                        call	.Num1
                        ld	c,-1
.Num1:	                ld	b,'0'-1
.Num2:	                inc		b
                        add		a,c
                        jr		c,.Num2
                        sub 	c
                        push	bc
                        push	af
                        ld		a,c
                        cp		-1
                        ld		a,b
                        ld		(de),a
                        inc		de
                        pop		af
                        pop		bc
                        ret 
                        
;----------------------------------------------------------------------------------------------------------------------------------
Hyp_message             DB "To:"
Hyp_to                  DS 32
Hyp_space1              DB " "
Hyp_dist_amount         DB "0.0"
Hyp_decimal             DB "."
Hyp_fraction            DB "0"
Hyp_dis_ly              DB " LY",0
Hyp_charging            DB "Charging:"
Hyp_counter             DB "000",0
Hyp_centeredTarget      DS 32
Hyp_centeredEol         DB 0
Hyp_bufferpadding       DS 32   ; just in case we get a buffer ovverun. shoudl never get beyond 32 chars
Hyp_centeredCharging    DS 32
Hyp_centeredEol2        DB 0
Hyp_bufferpadding2      DS 32   ; just in case we get a buffer ovverun. shoudl never get beyond 32 chars

                        