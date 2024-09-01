ZeroCargo:
		xor		a							;zero-out cargo, including gems.
		ld		b,16						;all the way up to alien items 
		ld		hl,CargoTonnes   			; cargo levels
.ZeroLoop:
        ld      (hl),a
		inc		hl
		djnz	.ZeroLoop
        ld      (SaveCargoRunningLoad),a
		ret
