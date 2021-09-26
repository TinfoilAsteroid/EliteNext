CopyXX12ScaledToXX18:
CopyResultToDrawCam:
        ldCopyByte XX12         ,XX18             ; XX12+0 => XX18+0  Set XX18(2 0) = dot_sidev
        ldCopyByte XX12+1       ,XX18+2           ; XX12+1 => XX18+2
        ldCopyByte XX12+2       ,XX18+3           ; XX12+2 => XX18+3  Set XX12+1 => XX18+2
        ldCopyByte XX12+3       ,XX18+5           ; XX12+3 => XX18+5
        ldCopyByte XX12+4       ,XX18+6           ; XX12+4 => XX18+6  Set XX18(8 6) = dot_nosev
        ldCopyByte XX12+5       ,XX18+8           ; XX12+5 => XX18+8
        ret
		