;TrimToScreenGrad:
;LL118:										; Trim XX15,XX15+2 to screen grad=XX12+2 for CLIP
;ret
;TODO        ld      hl,(UBnkx1Lo)               ; XX15+0,1 \ x1 hi
;TODO        bit     7,a
;TODO        jr      nz,LL119		            ; x1 hi+ve skip down
;TODO        ld      a,h
;TODO        ld      (varS),a                    ; S	 \ else x1 hi -ve
;TODO        call    XYeqyx1loSmulMdiv256                       ; LL120	 \ X1<0  their comment \ X.Y = x1_lo.S *  M/2566
;TODO        ld      bc,(UBnky1Lo)               ; step Y1 lo
        
;18                      CLC 
;65 36                   ADC &36		\ XX15+2 \ Y1 lo
;85 36                   STA &36			 \ XX15+2
;98                      TYA 			 \ step Y1 hi
;65 37                   ADC &37		\ XX15+3 \ Y1 hi
;85 37                   STA &37			 \ XX15+3
;A9 00                   LDA #0			 \ xleft min
;85 34                   STA &34		\ XX15+0 \ X1 lo
;85 35                   STA &35		\ XX15+1 \ X1 = 0
;AA                      TAX 			 \ Xreg = 0, will skip to Ytrim
;	.LL119	\ x1 hi +ve from LL118
;F0 19                   BEQ LL134		 \ if x1 hi = 0 skip to Ytrim
;85 83                   STA &83		\ S	 \ else x1 hi > 0
;C6 83                   DEC &83		\ S	 \ x1 hi-1
;20 19 50                JSR &5019	\ LL120  \ X1>255 their comment \ X.Y = x1lo.S *  M/256
;8A                      TXA 			 \ step Y1 lo
;18                      CLC 
;65 36                   ADC &36		\ XX15+2 \ Y1 lo
;85 36                   STA &36			 \ XX15+2
;98                      TYA 			 \ step Y1 hi
;65 37                   ADC &37		\ XX15+3 \ Y1 hi
;85 37                   STA &37			 \ XX15+3
;A2 FF                   LDX #&FF		 \ xright max
;86 34                   STX &34		\ XX15+0 \ X1 lo
;E8                      INX 			 \ X = 0
;86 35                   STX &35		\ XX15+1 \ X1 = 255
;	.LL134	\ Ytrim
;A5 37                   LDA &37		\ XX15+3 \ y1 hi
;10 1A                   BPL LL135		 \ y1 hi +ve
;85 83                   STA &83		\ S	 \ else y1 hi -ve
;A5 36                   LDA &36		\ XX15+2 \ y1 lo
;85 82                   STA &82		\ R	 \ Y1<0 their comment
;20 48 50                JSR &5048	\ LL123	 \ X.Y=R.S*256/M (M=grad.)   \where 256/M is gradient
;8A                      TXA 			 \ step X1 lo
;18                      CLC 
;65 34                   ADC &34		\ XX15+0 \ X1 lo
;85 34                   STA &34			 \ XX15+0
;98                      TYA 			 \ step X1 hi
;65 35                   ADC &35		\ XX15+1 \ X1 hi
;85 35                   STA &35			 \ XX15+1
;A9 00                   LDA #0			 \ Y bottom min
;85 36                   STA &36		\ XX15+2 \ Y1 lo
;85 37                   STA &37		\ XX15+3 \ Y1 = 0
;	.LL135	\ y1 hi +ve from LL134
;A5 36                   LDA &36		\ XX15+2 \ Y1 lo
;38                      SEC 
;E9 C0                   SBC #&C0		 \ #Y*2  screen y height
;85 82                   STA &82		\ R	 \ Y1>191 their comment
;A5 37                   LDA &37		\ XX15+3 \ Y1 hi
;E9 00                   SBC #0			 \ any hi	
;85 83                   STA &83			 \ S
;90 16                   BCC LL136		 \ failed, rts
;	.LL139
;20 48 50                JSR &5048	\ LL123	 \ X.Y=R.S*256/M (M=grad.)   \where 256/M is gradient
;8A                      TXA 			 \ step X1 lo
;18                      CLC 
;65 34                   ADC &34		\ XX15+0 \ X1 lo
;85 34                   STA &34			 \ XX15+0
;98                      TYA 			 \ step X1 hi
;65 35                   ADC &35		\ XX15+1 \ X1 hi
;85 35                   STA &35			 \ XX15+1
;A9 BF                   LDA #&BF		 \ #Y*2-1 = y top max
;85 36                   STA &36		\ XX15+2 \ Y1 lo
;A9 00                   LDA #0			 \ Y1 hi = 0
;85 37                   STA &37		\ XX15+3 \ Y1 = 191
;	.LL136	\ rts
;60                      RTS 		 	 \ -- trim for CLIP done
;
