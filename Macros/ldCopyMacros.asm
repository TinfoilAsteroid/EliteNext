ZeroA:		   MACRO
			   xor a
			   ENDM
			   
ldCopyByte:    MACRO memfrom, memto
               ld       a,(memfrom)
               ld       (memto),a
			   ENDM


ldCopyByteABS: MACRO memfrom, memto
               ld       a,(memfrom)
			   and		$7F
               ld       (memto),a
			   ENDM

ldCopy2Byte    MACRO  memfrom, memto
               ld       hl,(memfrom)
               ld       (memto),hl
               ENDM

ldWriteConst   MACRO  memfrom, memto
               ld       a,memfrom
               ld       (memto),a
               ENDM			   

ldWriteZero    MACRO  memto
               xor      a
               ld       (memto),a
               ENDM					   

ldIXLaFromN:	MACRO memfrom
                ld		a,(memfrom)
                ld		ixl,a
                ENDM

ldIXHaFromN:	MACRO memfrom
                ld		a,(memfrom)
                ld		ixh,a
                ENDM

ldIYLaFromN:	MACRO memfrom
                ld		a,(memfrom)
                ld		iyl,a
                ENDM

ldIYHaFromN:	MACRO memfrom
                ld		a,(memfrom)
                ld		iyh,a
                ENDM

ldhlde:			MACRO
                ld		h,d
                ld		l,e
                ENDM

ldhlbc:			MACRO
                ld		h,b
                ld		l,c
                ENDM

ldbcde:			MACRO
                ld		b,d
                ld		c,e
                ENDM

lddebc:			MACRO
                ld		d,b
                ld		e,c
                ENDM

ldbchl:			MACRO
                ld		b,h
                ld		c,l
                ENDM			   
	
lddeiy:			MACRO
                ld		d,iyh
                ld		e,iyl
                ENDM	
	
ldiyde:			MACRO
                ld		iyh,d
                ld		iyl,e
                ENDM			   
