CopySXX12ScaledToSXX18:
CopyResultToSDrawCam:
        ldCopyByte SXX12         ,SXX18             ; XX12+0 => XX18+0  Set XX18(2 0) = dot_sidev
        ldCopyByte SXX12+1       ,SXX18+2           ; XX12+1 => XX18+2
        ldCopyByte SXX12+2       ,SXX18+3           ; XX12+2 => XX18+3  Set XX12+1 => XX18+2
        ldCopyByte SXX12+3       ,SXX18+5           ; XX12+3 => XX18+5
        ldCopyByte SXX12+4       ,SXX18+6           ; XX12+4 => XX18+6  Set XX18(8 6) = dot_nosev
        ldCopyByte SXX12+5       ,SXX18+8           ; XX12+5 => XX18+8
        ret
		