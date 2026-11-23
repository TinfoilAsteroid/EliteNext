; Set TransMatTo
; XX16(1 0)   (3 2)   (5 4)   = sidev_x sidev_y sidev_z XX16(13,12) (15 14) (17 16)
; XX16(7 6)   (9 8)   (11 10) = roofv_x roofv_y roofv_z XX16(7 6)   (9 8)   (11 10)
; XX16(13 12) (15 14) (17 16) = nosev_x nosev_y nosev_z XX16(1 0)   (3 2)   (5 4)
; This moves Side XYZ to position 0, Roof XYZ to position 1 annd nose XYZ to position 2 as a copy of each batch of 6 bytes
; 18 byte fast copy

; A straight 18 byte copy (the rotmat and transmat vectors are each 9 contiguous words in the same order). It was a
; stack copy (267 T states) under di/ei, but ProcessNodes also runs inside the attract mode interrupt, where that ei
; re-enabled interrupts mid handler and let the next one nest. 18 LDIs (308 T states) need no interrupt protection.
                        ASSERT  UBnkrotmatNosevZ - UBnkrotmatSidevX == 16 && UBnkTransmatNosevZ - UBnkTransmatSidevX == 16
CopyRotmatToTransMat:   ld      hl,UBnkrotmatSidevX
                        ld      de,UBnkTransmatSidevX
                        SixLDIInstrunctions
                        SixLDIInstrunctions
                        SixLDIInstrunctions
                        ret


CopyRotToTransMacro:    MACRO
                        ld      hl,UBnkrotmatSidevX
                        ld      de,UBnkTransmatSidevX
                        SixLDIInstrunctions
                        SixLDIInstrunctions
                        SixLDIInstrunctions
                        ENDM
