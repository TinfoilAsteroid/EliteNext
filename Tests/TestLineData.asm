
TestLineData	DB 20,20,30,30,23,25,54,65,23,34,56,76,34,12,64,56,23,65,34,14,65,37,75,57
	
TestClip:	
		ld	hl,$0020
		ld	(UBnkX1),hl
		ld	hl,$0030
		ld	(UBnkY1),hl
		ld	hl,$0250
		ld	(UBnkX2),hl
		ld	hl,$0060
		ld	(UBnkY2),hl
TESTBFR:
		ld		a,$50
		ld		(varQ),a
		ld		a,$30
		call	BFRDIV		
		call	CLIP
		ld		bc,(UBnkPoint1Clipped)
		ld		de,(UBnkPoint2Clipped)
		ld		a,$FF
		MMUSelectLayer2
		call    l2_draw_any_line                ; call version of LOIN that used BCDE

		ret
        