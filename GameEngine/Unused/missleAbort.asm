missleAbort:
abort:										;.ABORT	\ -> &3805 \ draw Missile block, Unarm missile
		ld		a,$FF
		ld		(regX),a
missleAbort2:
abort2:										;  Xreg stored as Missile target
		ld		a,(regX)
		ld		(MSTG),a
		ld		a, (NOMSL)					; NOMSL \ number of missiles
		ld		(regX),a
		call	MsBar						;  MSBAR \ draw missile bar, returns with Y = 0.
		xor		a
		ld		(MSAR),a					; MSAR  \ missiles armed status, we just use a reg as zero as y = 0 from above
		ret

