
SetFaceAVisibleMacro:   MACRO prefix1?
prefix1?_SetFaceAVisible:ld      hl,prefix1?_BnKFaceVisArray
                        add     hl,a
                        ld      a,$FF
                        ld      (hl),a
                        ret
                        ENDM
;--------------------------------------------------------------------------------------------------------
SetFaceAHiddenMacro:    MACRO prefix1?
prefix1?_SetFaceAHidden:         ld      hl,prefix1?_BnKFaceVisArray
                        add     hl,a
                        xor     a
                        ld      (hl),a
                        ret
                        ENDM
;--------------------------------------------------------------------------------------------------------
SetAllFacesVisibleMacro:MACRO prefix1?
prefix1?_SetAllFacesVisible:     ld      a,(prefix1?_FaceCtX4Addr)            ; (XX0),Y which is XX0[0C] or SS_BnKHullCopy+FaceCtX4Addr                                 ;;; Faces count (previously loaded into b up front but no need to shave bytes for clarity
                        srl     a                           ; else do explosion needs all vertices                                                  ;;;
                        srl     a                           ;  /=4  TODO add this into blueprint data for speed                                                           ;;; For loop = 15 to 0
                        ld      b,a                         ; b = Xreg = number of normals, faces
                        ld      hl,prefix1?_BnKFaceVisArray
                        ld      a,$FF
.SetAllFacesVisibleLoop:ld      (hl),a
                        inc     hl
                        djnz    .SetAllFacesVisibleLoop
                        ret
                        ENDM
;--------------------------------------------------------------------------------------------------------
SetAllFacesHiddenMacro: MACRO prefix1?
prefix1?_SetAllFacesHidden: 
                        ld      a,(prefix1?_FaceCtX4Addr)   ; (XX0),Y which is XX0[0C] or SS_BnKHullCopy+ShipHullFacesCount                           ;;; Faces count (previously loaded into b up front but no need to shave bytes for clarity
                        srl     a                           ; else do explosion needs all vertices                                                  ;;;
                        srl     a                           ;  /=4                                                                                  ;;; For loop = 15 to 0
                        ld      b,a                         ; b = Xreg = number of normals, faces
                        ld      b,16
                        ld      hl,prefix1?_BnKFaceVisArray
                        ld      a,$00
.SetAllFacesHiddenLoop: ld      (hl),a
                        inc     hl
                        djnz    .SetAllFacesHiddenLoop
                        ret
                        ENDM

