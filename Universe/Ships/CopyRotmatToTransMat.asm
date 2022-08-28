; Set TransMatTo
; XX16(1 0)   (3 2)   (5 4)   = sidev_x sidev_y sidev_z XX16(13,12) (15 14) (17 16)
; XX16(7 6)   (9 8)   (11 10) = roofv_x roofv_y roofv_z XX16(7 6)   (9 8)   (11 10)
; XX16(13 12) (15 14) (17 16) = nosev_x nosev_y nosev_z XX16(1 0)   (3 2)   (5 4)
; This moves Side XYZ to position 0, Roof XYZ to position 1 annd nose XYZ to position 2 as a copy of each batch of 6 bytes
; 18 byte fast copy

; Fast copy using the stack                                                         ; T states
CopyRotmatToTransMat:   ld      ix,0                                                ; 14
                        add     ix,sp                                               ; 15
                        ld      sp,UBnkrotmatSidevX ; Source                        ; 10
                        pop     hl                  ; UBnkrotmatSidevX              ; 10
                        pop     de                  ; UBnkrotmatSidevY              ; 10
                        pop     bc                  ; UBnkrotmatSidevZ              ; 10
                        exx                                                         ; 4
                        pop     hl                  ; UBnkrotmatRoofvX              ; 10
                        pop     de                  ; UBnkrotmatRoofvY              ; 10
                        pop     bc                  ; UBnkrotmatRoofvZ              ; 10
                        ld      sp,UBnkTransmatRoofvZ+2 ; Target + 2 reversed       ; 10
                        push    bc                                                  ; 10
                        push    de                                                  ; 10
                        push    hl                                                  ; 10
                        exx                                                         ; 4
                        push    bc                                                  ; 10
                        push    de                                                  ; 10
                        push    hl                                                  ; 10
                        ld      sp,UBnkrotmatNosevX ; Source                        ; 10
                        pop     hl                  ; UBnkrotmatSidevX              ; 10
                        pop     de                  ; UBnkrotmatSidevY              ; 10
                        pop     bc                  ; UBnkrotmatSidevZ              ; 10
                        ld      sp,UBnkTransmatNosevZ+2                             ; 10
                        push    bc                                                  ; 10
                        push    de                                                  ; 10
                        push    hl                                                  ; 10
                        ld      sp,ix               ; restore stack                 ; 10
                        ret                                                         ; 10 Total 267 (LDI version is 318)
                        
                            
                        
;CopyRotmatToTransMat:   
;                        ld      hl,UBnkrotmatSidevX
;                        ld      de,UBnkTransmatSidevX
;                        SixLDIInstrunctions
;                        ld      hl,UBnkrotmatRoofvX
;                        ld      de, UBnkTransmatRoofvX
;                        SixLDIInstrunctions
;                        ld      hl,UBnkrotmatNosevX
;                        ld      de, UBnkTransmatNosevX
;                        SixLDIInstrunctions
;                        ret

CopyRotToTransMacro:    MACRO
                        ld      hl,UBnkrotmatSidevX
                        ld      de,UBnkTransmatSidevX
                        SixLDIInstrunctions
                        SixLDIInstrunctions
                        SixLDIInstrunctions
                        ENDM
