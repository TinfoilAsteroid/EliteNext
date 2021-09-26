ldAToHLixl:			MACRO value
					ld          hl,value
					ex          af,af'
					ld          a,ixl
					add         hl,a
					ex          af,af'
					ld          (hl),a
					ENDM

ldAToHLiyl:			MACRO value
					ld          hl,value
					ex          af,af'
					ld          a,iyl
					add         hl,a
					ex          af,af'
					ld          (hl),a
					ENDM


ldHLixlToA:         MACRO value
                    ld          hl,value
                    ex          af,af'
                    ld          a,ixl
                    add         hl,a
                    ld          a,(hl)
                    ENDM

ldHLiylToA:         MACRO value
                    ld          hl,value
                    ex          af,af'
                    ld          a,iyl
                    add         hl,a
                    ld          a,(hl)
                    ENDM

ldHLIdxAToA:        MACRO value
                    ld          hl,value
                    add         hl,a
                    ld          a,(hl)
                    ENDM
