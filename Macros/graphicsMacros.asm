; General Graphics macros
DoubleBufferIfPossible: MACRO
                        IFDEF DOUBLEBUFFER
                            MMUSelectLayer2
                            call  l2_cls
                            call  l2_flip_buffers
                        ENDIF
                        ENDM

DoubleBuffer320IfPossible: MACRO
                        IFDEF DOUBLEBUFFER
                            MMUSelectLayer2
                            call  l2_320_cls
                            call  l2_flip_buffers
                        ENDIF
                        ENDM                        
                        
    IFDEF L2_640_SUPPORT                        
DoubleBuffer640IfPossible: MACRO
                        IFDEF DOUBLEBUFFER
                            MMUSelectLayer2
                            call  l2_640_cls
                            call  l2_flip_buffers
                        ENDIF
                        ENDM                        
    ENDIF


ErrorEquStepMinusDelta: MACRO   delta_step, delta_value
                        ld      hl,(delta_step)
                        ld      de,(delta_value)
                        ClearCarryFlag
                        sbc     hl,de
                        ld      (error),hl
                        ENDM

; we could hold steps and deltas in alternate registers later
ErrorPlusStep:          MACRO   delta_step
                        ld      hl,(error)
                        ld      de,(delta_step)
                        add     hl,de
                        ld      (error),hl
                        ENDM

ErrorMinusStep:         MACRO   delta_step
                        ld      hl,(error)
                        ld      de,(delta_step)
                        ClearCarryFlag
                        sbc     hl,de
                        ld      (error),hl
                        ENDM
                        
SetExitFalse:           MACRO
                        xor     a
                        ld      (set_exit),a
                        ENDM

; pulls axis high byte to a, returns nz if negative, z if positive
IsAxisLT0:              MACRO   axis
                        ld      a,(axis+1)
                        and     $80
                        ENDM

; modifies HL, loaded with register, returns z if >=0, nz if negative
IsMemld16GTE0           MACRO   mem
                        ld      hl, (mem)
                        bit     7,h
                        ENDM

IsMemNegative8JumpFalse:MACRO   mem, target
                        ld      a,(mem)
                        and     $80
                        jp      z, target
                        ENDM

IsMem16GT0JumpFalse:    MACRO   mem, target
                        ld      hl, (mem)
                        bit     7,h
                        jp      nz, target
                        ld      a,h
                        or      l
                        jp      z,  target
                        ENDM

FloorHLdivDETarget:     MACRO   target
                        call    l_div                   ;       .  (so we swap and call l_div) HL = DE / HL, DE = DE % HL 
                        ld      a,d                     ;       .  get bit 7 into carry (set if negative)
                        sla     a                       ;
                        jr      nc,.FloorIsOK           ;
.FloorAdjust:           dec     hl                      ;       .  if remainder >= adjust by 1 for negative
.FloorIsOK:             ld      (target),hl             ;       .  now save the msd value
                        ENDM
                        