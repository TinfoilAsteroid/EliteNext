CopyByteAtHLixToA:		MACRO memloc
						ex          de,hl                               ; save hl
						ld          hl,memloc
						add         hl,a
						ld          a,(hl)                              ; get XX2[x]
						ex          de,hl                               ; get hl back as we need it in loop
						ENDM

; Increments IYL
; Increments IHL
; Gets value at hl and loads into Parameter 1 address

CopyByteAtNextHLiyl: 	MACRO memloc
						inc         iyl                                 ;
						inc         hl                                  ; vertex byte#1
						ld          a,(hl)                              ;
						ld          (memloc),a                     ; XX15+2 = (V),Y
						ENDM

;------------------------------------------------------------------------------------------------------------------------------
CopyByteAtNextHL:   MACRO targetaddr
                    inc         hl                                  ; vertex byte#1
                    ld          a,(hl)                              ;
                    ld          (targetaddr),a                     ; SunXX15+2 = (V),Y
                    ENDM