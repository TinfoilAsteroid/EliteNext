; Universe position data manipulation
POS_XOFFSET                 EQU 00 ;
POS_XHIOFFSET               EQU 01 ;
POS_XSGNOFFSET              EQU 02 ;
POS_YOFFSET                 EQU 03 ;
POS_YHIOFFSET               EQU 04 ;
POS_YSGNOFFSET              EQU 05 ;
POS_ZOFFSET                 EQU 06 ;
POS_ZHIOFFSET               EQU 07 ;
POS_ZSGNOFFSET              EQU 08 ;
POS_COMPASSXOFFSET          EQU 09 ;
POS_COMPASSXHIOFFSET        EQU 10 ; 0A
POS_COMPASSYOFFSET          EQU 11 ;
POS_COMPASSYHIOFFSET        EQU 12 ;
POS_RADARXOFFSET            EQU 13 ; 0C
POS_RADARYOFFSET            EQU 15 ; 0F
POS_NORMROOTOFFSET          EQU 17 ; 11
POS_NORMROOTHIOFFSET        EQU 18 ; 11
POS_NORMROOTAOFFSET         EQU 19 ; 11
POS_NORMX96OFFSET           EQU 20 ; 14
POS_NORMY96OFFSET           EQU 22 ; 16
POS_NORMZ96OFFSET           EQU 24 ; 18
POS_NORMXOFFSET             EQU 26 ; 1A
POS_NORMXHIOFFSET           EQU 27 ;
POS_NORMYOFFSET             EQU 28 ; 1C
POS_NORMYHIOFFSET           EQU 29 ;
POS_NORMZOFFSET             EQU 30 ; 1E
POS_NORMZHIOFFSET           EQU 31 ;
;------------------------------------------------------------------------------
; Sets IYH to sign bits, bit 7 = x, bit 6 = y bit 5 = z
SetIYHToSignBits:       MACRO
                        ld      a,(ix+POS_ZSGNOFFSET)   ; get Z sign
                        and     $80                     ; and shift it via A into IYH bit 7
                        srl     a                       ;
                        ld      iyh,a                   ;
                        ld      a,(ix+POS_YSGNOFFSET)   ; get Y sign
                        and     $80                     ; and shift it via A into IYH bit 7
                        or      iyh                     ; which moves Z into IYH bit 6
                        srl     a                       ;
                        ld      iyh,a                   ;
                        ld      a,(ix+POS_XSGNOFFSET)   ; get X sign
                        and     $80                     ; and shift it via A into IYH bit 7
                        or      iyh                     ; which moves Y into IYH bit 6 and Z into IYH bit 5
                        ld      iyh,a                   ;
                        ENDM
;------------------------------------------------------------------------------
; gets high bytes of vector at IX
; sets h = abs x sign, l = abs y sgn d and a to abs z|y|x sgn
SetAHLDToABSXYZSgn      MACRO
                        ld      a,(ix+POS_XSGNOFFSET)
                        and     $7F
                        ld      h,a
                        ld      a,(ix+POS_YSGNOFFSET)
                        and     $7F
                        ld      l,a
                        ld      a,(ix+POS_ZSGNOFFSET)
                        and     $7F
                        ld      d,a
                        or      h
                        or      l
                        ENDM
;------------------------------------------------------------------------------
SetAHLDToABSXYZHi       MACRO
                        ld      a,(ix+POS_XHIOFFSET)
                        ld      h,a
                        ld      a,(ix+POS_YHIOFFSET)
                        ld      l,a
                        ld      a,(ix+POS_ZHIOFFSET)
                        ld      d,a
                        or      h
                        or      l
                        ENDM
;------------------------------------------------------------------------------
SetAHLDToABSXYZLo       MACRO
                        ld      a,(ix+POS_XOFFSET)
                        ld      h,a
                        ld      a,(ix+POS_YOFFSET)
                        ld      l,a
                        ld      a,(ix+POS_ZOFFSET)
                        ld      d,a
                        or      h
                        or      l
                        ENDM
;------------------------------------------------------------------------------
SetBHLtoX:              MACRO
                        ld      b,(ix+POS_XSGNOFFSET)
                        ld      hl,(ix+POS_XOFFSET)
                        ENDM
;------------------------------------------------------------------------------
SetCDEtoX:              MACRO
                        ld      c,(ix+POS_XSGNOFFSET)
                        ld      de,(ix+POS_XOFFSET)
                        ENDM
;------------------------------------------------------------------------------
SaveDEHToX:             MACRO
                        ld      (ix+POS_XSGNOFFSET),d   ; save DE.H into Zd
                        ld      (ix+POS_XHIOFFSET),e    ; .
                        ld      (ix+POS_XOFFSET),h      ; .
                        ENDM
;------------------------------------------------------------------------------
SaveAHLToX:             MACRO
                        ld      (ix+POS_XSGNOFFSET),a   ; save AH.L into Zd
                        ld      (ix+POS_XHIOFFSET),h    ; .
                        ld      (ix+POS_XOFFSET),l      ; .
                        ENDM
;------------------------------------------------------------------------------
SetCDEtoY:              MACRO
                        ld      c,(ix+POS_YSGNIOFFSET)
                        ld      de,(ix+POS_YOFFSET)
                        ENDM
;------------------------------------------------------------------------------
SetBHLtoY:              MACRO
                        ld      b,(ix+POS_YSGNOFFSET)
                        ld      hl,(ix+POS_YOFFSET)
                        ENDM
;------------------------------------------------------------------------------
SaveDEHToY:             MACRO
                        ld      (ix+POS_YSGNOFFSET),d                ; save DE.H into Zd
                        ld      (ix+POS_YHIOFFSET),e                ; .
                        ld      (ix+POS_YOFFSET),h                ; .
                        ENDM
;------------------------------------------------------------------------------
SaveAHLToY:             MACRO
                        ld      (ix+POS_YSGNOFFSET),a                ; save DE.H into Zd
                        ld      (ix+POS_YHIOFFSET),h                ; .
                        ld      (ix+POS_YOFFSET),l                ; .
                        ENDM
;------------------------------------------------------------------------------
SetCDEtoZ:              MACRO
                        ld      c,(ix+POS_ZSGNOFFSET)
                        ld      de,(ix+POS_ZOFFSET)
                        ENDM
;------------------------------------------------------------------------------
SetBHLtoZ:              MACRO
                        ld      b,(ix+POS_ZSGNOFFSET)
                        ld      hl,(ix+POS_ZOFFSET)
                        ENDM
;------------------------------------------------------------------------------
SaveDEHToZ:             MACRO
                        ld      (ix+POS_ZSGNOFFSET),d                ; save DE.H into Zd
                        ld      (ix+POS_ZHIOFFSET),e                ; .
                        ld      (ix+POS_ZOFFSET),h                ; .
                        ENDM
;------------------------------------------------------------------------------
SaveAHLToZ:             MACRO
                        ld      (ix+POS_ZSGNOFFSET),a                ; save DE.H into Zd
                        ld      (ix+POS_ZHIOFFSET),h                ; .
                        ld      (ix+POS_ZOFFSET),l                ; .
                        ENDM
;------------------------------------------------------------------------------
SetDEAtoABSX:           MACRO
                        ld      de,(ix+POS_XHIOFFSET)
                        ld      a,(ix+POS_XOFFSET)
                        res     7,d
                        ENDM
;------------------------------------------------------------------------------
SetDEAtoABSY:           MACRO
                        ld      de,(ix+POS_YHIOFFSET)
                        ld      a,(ix+POS_YOFFSET)
                        res     7,d
                        ENDM
;------------------------------------------------------------------------------
SetDEAtoABSZ:           MACRO
                        ld      de,(ix+POS_ZHIOFFSET)
                        ld      a,(ix+POS_ZOFFSET)
                        res     7,d
                        ENDM
;------------------------------------------------------------------------------
SetHLtoABSXHiLo:        MACRO
                        ld      hl,(ix+POS_XOFFSET)
                        ENDM
;------------------------------------------------------------------------------
SetDEtoABSYHiLo:        MACRO
                        ld      de,(ix+POS_YOFFSET)
                        ENDM
;------------------------------------------------------------------------------
SetBCtoABSZHiLo:        MACRO
                        ld      bc,(ix+POS_ZOFFSET)
                        ENDM
;------------------------------------------------------------------------------
SetHLtoABSXSgnHi:       MACRO
                        ld      hl,(ix+POS_XHIOFFSET)
                        ld      a, h
                        and     $7F
                        ld      h,a
                        ENDM
;------------------------------------------------------------------------------
SetDEtoABSYSgnHi:       MACRO
                        ld      de,(ix+POS_YHIOFFSET)
                        ld      a, d
                        and     $7F
                        ld      d,a
                        ENDM
;------------------------------------------------------------------------------
SetBCtoABSZSgnHi:       MACRO
                        ld      bc,(ix+POS_ZHIOFFSET)
                        ld      a, b
                        and     $7F
                        ld      b,a
                        ENDM
;------------------------------------------------------------------------------
SetNormRootToHL:        MACRO
                        ld      (ix+POS_NORMROOTOFFSET),hl
                        ENDM
;------------------------------------------------------------------------------
SetNormRootAToA:        MACRO
                        ld      (ix+POS_NORMROOTAOFFSET),a
                        ENDM
;------------------------------------------------------------------------------
SetNormX96ToDE:         MACRO
                        ld      (ix+POS_NORMX96OFFSET),de
                        ENDM
;------------------------------------------------------------------------------
SetNormY96ToDE:         MACRO
                        ld      (ix+POS_NORMY96OFFSET),de
                        ENDM
;------------------------------------------------------------------------------
SetNormZ96ToBC:         MACRO
                        ld      (ix+POS_NORMZ96OFFSET),bc
                        ENDM
;------------------------------------------------------------------------------
SetNormZ96ToDE:         MACRO
                        ld     (ix+POS_NORMZ96OFFSET),de
                        ENDM
;------------------------------------------------------------------------------
; IYH holds sign bits so we need bit 7 for x
SetNormXToA:            MACRO
                        ld      e,a                    
                        and     a                   ; if A is zero then ignore sign
                        jp      z,.WriteResult      ; processing logic
.ProcessSigned:         ld      a,iyh
                        and     $80
.WriteResult:           ld      d,a
                        ld     (ix+POS_NORMXOFFSET),de
                        ENDM
;------------------------------------------------------------------------------
; IYH holds sign bits so we need bit 6 for y
SetNormYToA:            MACRO
                        ld      e,a                    
                        and     a                   ; if A is zero then ignore sign
                        jp      z,.WriteResult      ; processing logic
.ProcessSigned:         ld      a,iyh
                        sla     a
                        and     $80
.WriteResult:           ld      d,a
                        ld     (ix+POS_NORMYOFFSET),de
                        ENDM
;------------------------------------------------------------------------------
; IYH holds sign bits so we need bit 5 for z
SetNormZToA:            MACRO
                        ld      e,a                    
                        and     a                   ; if A is zero then ignore sign
                        jp      z,.WriteResult      ; processing logic
.ProcessSigned:         ld      a,iyh
                        sla     a
                        sla     a
                        and     $80
.WriteResult:           ld      d,a
                        ld     (ix+POS_NORMZOFFSET),de
                        ENDM
;------------------------------------------------------------------------------
; IYH holds sign bits so we need bit 5 for z
;------------------------------------------------------------------------------
SetBCToNormX:           MACRO
                        ld      bc,(IX+POS_NORMXOFFSET)
                        ENDM
;------------------------------------------------------------------------------
SetBCToNormY:           MACRO
                        ld      bc,(IX+POS_NORMYOFFSET)
                        ENDM
;------------------------------------------------------------------------------
SetBCToNormZ:           MACRO
                        ld      bc,(IX+POS_NORMZOFFSET)
                        ENDM
;------------------------------------------------------------------------------
SetAToNormXlo:          MACRO
                        ld      a,(IX+POS_NORMXOFFSET)
                        ENDM
;------------------------------------------------------------------------------
SetAToNormYlo:          MACRO
                        ld      a,(IX+POS_NORMYOFFSET)
                        ENDM
;------------------------------------------------------------------------------
SetAToNormZlo:          MACRO
                        ld      a,(IX+POS_NORMZOFFSET)
                        ENDM
;------------------------------------------------------------------------------
SetAToNormXSign:        MACRO
                        ld     a,(ix+POS_NORMXHIOFFSET)
                        and     $80
                        ENDM
;------------------------------------------------------------------------------
SetAToNormYSign:        MACRO
                        ld     a,(ix+POS_NORMYHIOFFSET)
                        and     $80
                        ENDM
;------------------------------------------------------------------------------
SetAToNormZSign:        MACRO
                        ld     a,(ix+POS_NORMZHIOFFSET)
                        and     $80
                        ENDM
;------------------------------------------------------------------------------
SetCompassXToHL:        MACRO
                        ld      (ix+POS_COMPASSXOFFSET),hl
                        ENDM
;------------------------------------------------------------------------------
SetCompassYToHL:        MACRO
                        ld      (ix+POS_COMPASSYOFFSET),hl
                        ENDM
;------------------------------------------------------------------------------
SetBCCompassYX:         MACRO
                        ld      b,(ix+POS_COMPASSYOFFSET)
                        ld      c,(ix+POS_COMPASSXOFFSET)
                        ENDM
;------------------------------------------------------------------------------
NormXMul96:             MACRO
                        ld      e,a
                        ld      d,96
                        mul     de
                        ld      a,d                 ; is norm 0,
                        or      e                   ; if so we can skip
                        jp      z,.DoneNorm96X      ; sign check
                        ld      a,(ix+POS_XSGNOFFSET)            ;
                        and     $80                 ;
                        or      d
                        ld      d,a
.DoneNorm96X:
                        ENDM
;------------------------------------------------------------------------------
NormYMul96:             MACRO
                        ld      e,a
                        ld      d,96
                        mul     de
                        ld      a,d                 ; is norm 0,
                        or      e                   ; if so we can skip
                        jp      z,.DoneNorm96Y      ; sign check
                        ld      a,(ix+POS_YSGNOFFSET)            ;
                        and     $80                 ;
                        or      d
                        ld      d,a
.DoneNorm96Y:
                        ENDM
;------------------------------------------------------------------------------
NormZMul96:             MACRO
                        ld      e,a
                        ld      d,96
                        mul     de
                        ld      a,d                 ; is norm 0,
                        or      e                   ; if so we can skip
                        jp      z,.DoneNorm96Z      ; sign check
                        ld      a,(ix+POS_ZSGNOFFSET)            ;
                        and     $80                 ;
                        or      d
                        ld      d,a
.DoneNorm96Z:
                        ENDM
;------------------------------------------------------------------------------
