CopyXX12ToScaled:
CopyResultToScaled:
        ldCopyByte  XX12+0,UBnkXScaled      ; xnormal lo
        ldCopyByte  XX12+2,UBnkYScaled      ; ynormal lo
        ldCopyByte  XX12+4,UBnkZScaled      ; znormal lo and leaves a holding zscaled normal
        ret
		