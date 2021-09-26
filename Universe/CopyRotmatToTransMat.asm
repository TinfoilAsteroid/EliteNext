; Set TransMatTo
; XX16(1 0)   (3 2)   (5 4)   = sidev_x sidev_y sidev_z XX16(13,12) (15 14) (17 16)
; XX16(7 6)   (9 8)   (11 10) = roofv_x roofv_y roofv_z XX16(7 6)   (9 8)   (11 10)
; XX16(13 12) (15 14) (17 16) = nosev_x nosev_y nosev_z XX16(1 0)   (3 2)   (5 4)
; This moves Side XYZ to position 0, Roof XYZ to position 1 annd nose XYZ to position 2 as a copy of each batch of 6 bytes
CopyRotmatToTransMat:                       ; Tested
LL15_CopyRotMat:                            ; unrolled loop
        ld      hl,UBnkrotmatSidevX                      
        ld      de,UBnkTransmatSidevX
        SixLDIInstrunctions
        ld      hl,UBnkrotmatRoofvX
        ld      de, UBnkTransmatRoofvX
        SixLDIInstrunctions
        ld      hl,UBnkrotmatNosevX
        ld      de, UBnkTransmatNosevX
        SixLDIInstrunctions
        ret
