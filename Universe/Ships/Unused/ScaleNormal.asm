; scale Normal. IXL is xReg and A is loaded with XX17 holds the scale factor to apply
; returns with XX15 scaled by Q but also z scaled in a register
ScaleNormal:
LL93:
        ld      a,(XX17)                    ; scale--
		ld		ixl,a
		ld		a,(UBnkZScaled)				; needs to be in a just in case we abort early
		dec		ixl
		ret		m							; return if q was 0, i.e. no scaling
ScaleLoop:
LL933:
        ld      hl,XX15
        srl     (hl)                        ; XX15	\ xnormal lo/2 \ LL93+3 \ counter X
        inc     hl							; looking at XX15 x sign now
        inc     hl							; looking at XX15 y Lo now
        srl     (hl)                        ; XX15+2	\ ynormal lo/2
		inc		hl							; looking at XX15 y sign now
		inc		hl							; looking at XX15 z Lo now
		srl		(hl)
		ld		a,(hl)						; znormal lo/2 also into a it came in at the end of LL92
        dec     ixl                         ; reduce scale
        jp      p,ScaleLoop                 ; LL93-3 loop to lsr xx15
        ret
