
SetFaceAVisibleMacro:   MACRO p?
p?_SetFaceAVisible:ld      hl,p?_BnkFaceVisArray
                        add     hl,a
                        ld      a,$FF
                        ld      (hl),a
                        ret
                        ENDM
;--------------------------------------------------------------------------------------------------------
SetFaceAHiddenMacro:        MACRO p?
p?_SetFaceAHidden:    ld      hl,p?_BnkFaceVisArray
                            add     hl,a
                            xor     a
                            ld      (hl),a
                            ret
                            ENDM
;--------------------------------------------------------------------------------------------------------
SetAllFacesVisibleMacro:MACRO p?
p?_SetAllFacesVisible:     ld      a,(p?_FaceCtX4Addr)            ; (XX0),Y which is XX0[0C] or SS_BnkHullCopy+FaceCtX4Addr                                 ;;; Faces count (previously loaded into b up front but no need to shave bytes for clarity
                        srl     a                           ; else do explosion needs all vertices                                                  ;;;
                        srl     a                           ;  /=4  TODO add this into blueprint data for speed                                                           ;;; For loop = 15 to 0
                        ld      b,a                         ; b = Xreg = number of normals, faces
                        ld      hl,p?_BnkFaceVisArray
                        ld      a,$FF
.SetAllFacesVisibleLoop:ld      (hl),a
                        inc     hl
                        djnz    .SetAllFacesVisibleLoop
                        ret
                        ENDM
;--------------------------------------------------------------------------------------------------------
SetAllFacesHiddenMacro: MACRO p?
p?_SetAllFacesHidden: 
                        ld      a,(p?_FaceCtX4Addr)   ; (XX0),Y which is XX0[0C] or SS_BnkHullCopy+ShipHullFacesCount                           ;;; Faces count (previously loaded into b up front but no need to shave bytes for clarity
                        srl     a                           ; else do explosion needs all vertices                                                  ;;;
                        srl     a                           ;  /=4                                                                                  ;;; For loop = 15 to 0
                        ld      b,a                         ; b = Xreg = number of normals, faces
                        ld      b,16
                        ld      hl,p?_BnkFaceVisArray
                        ld      a,$00
.SetAllFacesHiddenLoop: ld      (hl),a
                        inc     hl
                        djnz    .SetAllFacesHiddenLoop
                        ret
                        ENDM

