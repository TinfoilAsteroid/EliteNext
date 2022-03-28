ZeroA:		            MACRO
                        xor a
                        ENDM
                        
SetATrue:               MACRO
                        xor     a
                        ENDM
                       
SetAFalse:              MACRO
                        ld      a,$FF
                        ENDM

SetMemFalse             MACRO   mem
                        ld      a,$FF
                        ld      (mem),a
                        ENDM

SetMemTrue              MACRO   mem
                        xor     a
                        ld      (mem),a
                        ENDM                        

SetMemToN:              MACRO   mem,value
                        ld      a,value
                        ld      (mem),a
                        ENDM

ldCopyStringLen:        MACRO   source, target, strlen
                        ld      hl,source
                        ld      de, target
                        ld      bc, strlen
                        ldir
                        ENDM

ldCopyTextAtHLtoDE:     MACRO
.CopyLoop:              ld      a,(hl)
                        ld      (de),a
                        cp      0
                        jp      z,.DoneCopy
                        inc     hl
                        inc     de
                        jr      .CopyLoop
.DoneCopy:              
                        ENDM
                        
ldClearTextLoop:        MACRO   TextSize
                        ld      b,a
                        ld      a,TextSize
.ClearLoop:             ld      (hl),a
                        inc     hl
                        djnz    .ClearLoop
                        ENDM
               
ldCopyByte:             MACRO memfrom, memto
                        ld       a,(memfrom)
                        ld       (memto),a
                        ENDM


ldCopyByteABS:          MACRO memfrom, memto
                        ld       a,(memfrom)
                        and		$7F
                        ld       (memto),a
                        ENDM

ldAtHLtoMem:            MACRO   memto
                        ld      a,(hl)
                        ld      (memto),a
                        ENDM

ldCopy2Byte             MACRO  memfrom, memto
                        ld       hl,(memfrom)
                        ld       (memto),hl
                        ENDM

ldWriteConst            MACRO  memfrom, memto
                        ld       a,memfrom
                        ld       (memto),a
                        ENDM			   

ldWriteZero             MACRO  memto
                        xor      a
                        ld       (memto),a
                        ENDM					   

ldIXLaFromN:	        MACRO memfrom
                        ld		a,(memfrom)
                        ld		ixl,a
                        ENDM

ldIXHaFromN:	        MACRO memfrom
                        ld		a,(memfrom)
                        ld		ixh,a
                        ENDM

ldIYLaFromN:	        MACRO memfrom
                        ld		a,(memfrom)
                        ld		iyl,a
                        ENDM

ldIYHaFromN:	        MACRO memfrom
                        ld		a,(memfrom)
                        ld		iyh,a
                        ENDM

ldhlde:			        MACRO
                        ld		h,d
                        ld		l,e
                        ENDM

ldhlbc:			        MACRO
                        ld		h,b
                        ld		l,c
                        ENDM

ldbcde:			        MACRO
                        ld		b,d
                        ld		c,e
                        ENDM

lddebc:			        MACRO
                        ld		d,b
                        ld		e,c
                        ENDM

ldbchl:			        MACRO
                        ld		b,h
                        ld		c,l
                        ENDM			   
	
lddeiy:			        MACRO
                        ld		d,iyh
                        ld		e,iyl
                        ENDM	
	
ldiyde:			        MACRO
                        ld		iyh,d
                        ld		iyl,e
                        ENDM			   


FourLDIInstrunctions:   MACRO
                        ldi
                        ldi
                        ldi
                        ldi
                        ENDM

FiveLDIInstrunctions:   MACRO
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ENDM

SixLDIInstrunctions:    MACRO
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ldi
                        ENDM

EightLDIInstrunctions:  MACRO
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
                        ENDM

NineLDIInstrunctions:  MACRO
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
		                ldi
                        ENDM