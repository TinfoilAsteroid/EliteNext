CopyXX18toXX15:
CopyDrawCamToScaled:
        ldCopyByte  UBnkDrawCam0xLo ,UBnkXScaled        ; xlo
        ldCopyByte  UBnkDrawCam0xSgn,UBnkXScaledSign    ; xsg
        ldCopyByte  UBnkDrawCam0yLo ,UBnkYScaled        ; xlo
        ldCopyByte  UBnkDrawCam0ySgn,UBnkYScaledSign    ; xsg
        ldCopyByte  UBnkDrawCam0zLo ,UBnkZScaled        ; xlo
        ldCopyByte  UBnkDrawCam0zSgn,UBnkZScaledSign    ; xsg
        ret
		