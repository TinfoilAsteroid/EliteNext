; Set TransMatTo
; XX16(1 0)   (3 2)   (5 4)   = sidev_x sidev_y sidev_z XX16(13,12) (15 14) (17 16)
; XX16(7 6)   (9 8)   (11 10) = roofv_x roofv_y roofv_z XX16(7 6)   (9 8)   (11 10)
; XX16(13 12) (15 14) (17 16) = nosev_x nosev_y nosev_z XX16(1 0)   (3 2)   (5 4)
; This moves Side XYZ to position 0, Roof XYZ to position 1 annd nose XYZ to position 2 as a copy of each batch of 6 bytes
; 18 byte fast copy

CopyRotmatToTransMatMacro:      MACRO p?
; Fast copy using the stack                                                         ; T states
p?_CopyRotmatToTransMat:  ld      ix,0                                                ; 14
                                add     ix,sp                                               ; 15
                                ld      sp,p?_BnkrotmatSidevX ; Source                        ; 10
                                pop     hl                  ; p?_BnkrotmatSidevX              ; 10
                                pop     de                  ; p?_BnkrotmatSidevY              ; 10
                                pop     bc                  ; p?_BnkrotmatSidevZ              ; 10
                                exx                                                         ; 4
                                pop     hl                  ; p?_BnkrotmatRoofvX              ; 10
                                pop     de                  ; p?_BnkrotmatRoofvY              ; 10
                                pop     bc                  ; p?_BnkrotmatRoofvZ              ; 10
                                ld      sp,p?_BnkTransmatRoofvZ+2 ; Target + 2 reversed       ; 10
                                push    bc                                                  ; 10
                                push    de                                                  ; 10
                                push    hl                                                  ; 10
                                exx                                                         ; 4
                                push    bc                                                  ; 10
                                push    de                                                  ; 10
                                push    hl                                                  ; 10
                                ld      sp,p?_BnkrotmatNosevX ; Source                        ; 10
                                pop     hl                  ; p?_BnkrotmatSidevX              ; 10
                                pop     de                  ; p?_BnkrotmatSidevY              ; 10
                                pop     bc                  ; p?_BnkrotmatSidevZ              ; 10
                                ld      sp,p?_BnkTransmatNosevZ+2                             ; 10
                                push    bc                                                  ; 10
                                push    de                                                  ; 10
                                push    hl                                                  ; 10
                                ld      sp,ix               ; restore stack                 ; 10
                                ret                                                         ; 10 Total 267 (LDI version is 318)
                                ENDM
                        

;                        ret

