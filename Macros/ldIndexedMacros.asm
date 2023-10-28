GetByteAInTable:    MACRO table
                    ld          hl,table
                    add         hl,a
                    ld          a,(hl)
                    ENDM

HLWordAInTable:     MACRO table
                    ld          hl,table
                    sla         a
                    add         hl,a
                    ld          a,(hl)
                    inc         hl
                    ld          h,(hl)
                    ld          l,a
                    ENDM


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

HLEquAddrAtHLPlusA: MACRO
                    sla         a
                    add         hl,a
                    ld          a,(hl)
                    inc         hl
                    ld          h,(hl)
                    ld          l,a
                    ENDM

;-- Performs HL = |HL| - 1
DecHLABS:           MACRO
                    bit         7,h
                    jp          nz,.NegativeDec
.IsHLZero:          ld          a,h                 ; if its zero it becomes negative
                    or          l
                    jp          z,.HLZero
.PositiveDec:       dec         hl
                    jp          .Done
.NegativeDec:       ld          a,h
                    and         $7F
                    ld          h,a
                    dec         hl
                    set         7,h
                    jp          .Done
.HLZero:            ld          hl,$8001                    
.Done:
                    ENDM

;-- Performs HL = HL - 1 
DecHLSigned:        MACRO
                    bit         7,h
                    jp          nz,.NegativeDec
.IsHLZero:          ld          a,h                 ; if its zero it becomes negative
                    or          l
                    jp          z,.HLZero
.PositiveDec:       dec         hl
                    jp          .Done
.NegativeDec:       ld          a,h
                    and         $7F
                    ld          h,a
                    inc         hl                  ; if its already negative then add 1 to make it further
                    set         7,h
                    jp          .Done
.HLZero:            ld          hl,$8001                    
.Done:
                    ENDM
