CopyXX15toRotMatNoseV:
        ldCopyByte  XX15VecX, UBnkrotmatNosevX+1
        ldCopyByte  XX15VecY, UBnkrotmatNosevY+1 
        ldCopyByte  XX15VecZ, UBnkrotmatNosevZ+1
        ZeroA
        ld  (UBnkrotmatNosevX),a
        ld  (UBnkrotmatNosevY),a
        ld  (UBnkrotmatNosevZ),a
        ret

CopyXX15toRotMatRoofV:
        ldCopyByte  XX15VecX, UBnkrotmatRoofvX+1
        ldCopyByte  XX15VecY, UBnkrotmatRoofvY+1
        ldCopyByte  XX15VecZ, UBnkrotmatRoofvZ+1
        ZeroA
        ld  (UBnkrotmatRoofvX),a
        ld  (UBnkrotmatRoofvY),a
        ld  (UBnkrotmatRoofvZ),a
        ret

CopyXX15toRotMatSideV:
        ldCopyByte  XX15VecX, UBnkrotmatSidevX+1
        ldCopyByte  XX15VecY, UBnkrotmatSidevY+1
        ldCopyByte  XX15VecZ, UBnkrotmatSidevZ+1
        ZeroA
        ld  (UBnkrotmatSidevX),a
        ld  (UBnkrotmatSidevY),a
        ld  (UBnkrotmatSidevZ),a        
        ret
		