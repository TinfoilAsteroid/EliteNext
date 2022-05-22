;----------------------------------------------------------------------------------------------------------------------------------
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

                        