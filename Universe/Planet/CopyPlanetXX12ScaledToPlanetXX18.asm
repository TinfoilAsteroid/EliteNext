CopyPSXX12ScaledToPXX18:
CopyResultToPDrawCam:
        ldCopyByte PXX12         ,PXX18             ; XX12+0 => XX18+0  Set XX18(2 0) = dot_sidev
        ldCopyByte PXX12+1       ,PXX18+2           ; XX12+1 => XX18+2
        ldCopyByte PXX12+2       ,PXX18+3           ; XX12+2 => XX18+3  Set XX12+1 => XX18+2
        ldCopyByte PXX12+3       ,PXX18+5           ; XX12+3 => XX18+5
        ldCopyByte PXX12+4       ,PXX18+6           ; XX12+4 => XX18+6  Set XX18(8 6) = dot_nosev
        ldCopyByte PXX12+5       ,PXX18+8           ; XX12+5 => XX18+8
        ret
		