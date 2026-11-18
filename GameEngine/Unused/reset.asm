reset:					; New player ship, reset controls
;20 96 42                JSR &4296   \ ZERO  \ zero-out &311-&34B
;A2 08                   LDX #8
;	.SAL3	\  counter X
;95 2A                   STA &2A,X   	    \ BETA,X
;CA                      DEX 
;10 FB                   BPL SAL3    	    \ loop X
;	.RES4
;8A                      TXA 	    	    \ Acc = #&FF
;A2 02                   LDX #2	    	    \ Restore forward, aft shields, and energy
;	.REL5	\ counter X
;9D A5 03                STA &03A5,X \ FSH,X \ forward shield
;CA                      DEX 
;10 FA                   BPL REL5	    \ loop X
reset2:
res2:					; Reset2, done after launch or hyper, new dust.
;A9 12                   LDA #18		    \ #NOST 
;8D C3 03                STA &03C3  \ NOSTM  \ number of stars, dust.
;A2 FF                   LDX #&FF	    \ bline buffers cleared, 78 bytes.
;8E C0 0E                STX &0EC0	    \ LSX2
;8E 0E 0F                STX &0F0E	    \ LSY2
;86 45                   STX &45	   \ MSTG   \ missile has no target
;A9 80                   LDA #&80	    \ center joysticks
;8D 4C 03                STA &034C  \ JSTX   \ joystick X
;8D 4D 03                STA &034D  \ JSTY   \ joystick Y
;0A                      ASL A		    \ = 0
;85 8A                   STA &8A	   \ MCNT   \ move count  
;85 2F                   STA &2F	   \ QQ22+1 \ outer hyperspace countdown
;A9 03                   LDA #3		    \ speed, but not alpha gentle roll
;85 7D                   STA &7D		    \ DELTA
;AD 20 03                LDA &0320  \ SSPR   \ space station present, 0 is SUN.
;F0 03                   BEQ P%+5	    \ if none, leave bulb off
;20 21 38                JSR &3821  \ SPBLB  \ space station bulb
;A5 30                   LDA &30	   \ ECMA   \ any ECM on?
;F0 03                   BEQ yu		    \ hop over as ECM not on
;20 A3 43                JSR &43A3  \ ECMOF  \ silence E.C.M. sound
;.yu	\ hopped over
;20 D8 35                JSR &35D8  \ WPSHPS \ wipe ships on scanner
;20 96 42                JSR &4296  \ ZERO   \ zero-out &311-&34B
;A9 FF                   LDA #&FF	    \ #(LS% MOD 256) 
;8D B0 03                STA &03B0  \ SLSP   \ ship lines pointer reset to top LS% = &0CFF
;A9 0C                   LDA #&0C	    \ #(LS% DIV 256)  
;8D B1 03                STA &03B1  \ SLSP+1 \ hi
;20 62 1F                JSR &1F62  \ DIALS  \ update flight console
;20 A4 44                JSR &44A4  \ Uperc  \ clear keyboard logger
;	.ZINF	\ -> &3F26 \ Zero information, ends with Acc = #&E0
;A0 24                   LDY #36		    \ #(NI%-1) \ NI%=37 is size of inner working space
;A9 00                   LDA #0
;	.ZI1	\ counter Y
;99 46 00                STA &0046,Y	    \ INWK,Y
;88                      DEY 
;10 FA                   BPL ZI1		    \ loop Y
;A9 60                   LDA #&60	    \ unity in rotation matrix
;85 58                   STA &58   \ INWK+18 \ rotmat1y hi
;85 5C                   STA &5C	  \ INWK+22 \ rotmat2x hi
;09 80                   ORA #&80 	    \ -ve unity = #&E0
;85 54                   STA &54	  \ INWK+14 \ rotmat0z hi = -1
		ret

