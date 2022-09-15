
WriteTurboRegister:     MACRO   register,value
                        ld      bc,TURBO_SOUND_NEXT_CONTROL
                        ld      a,register
                        out     (c),a
                        ld      bc,SOUND_CHIP_REGISTER_WRITE
                        ld      a,value
                        out     (c),a
                        ENDM
                        
WriteTurboRegisterA:    MACRO   register
                        ex      af,af'
                        ld      bc,TURBO_SOUND_NEXT_CONTROL
                        ld      a,register
                        out     (c),a
                        ld      bc,SOUND_CHIP_REGISTER_WRITE
                        ex      af,af'
                        out     (c),a
                        ENDM

Channel_PitchA          MACRO   
                        ld      hl,TonesPitch
                        sla     a
                        add     hl,a
                        ld      a,(hl)
                        WriteTurboRegisterA CHANNEL_A_COARSE
                        inc     hl
                        ld      a,(hl)
                        WriteTurboRegisterA CHANNEL_A_FINE
                        ENDM

InitAudio:              ld      bc,TURBO_SOUND_NEXT_CONTROL
                        ld      a,TURBO_MANDATORY | TURBO_LEFT | TURBO_RIGHT | TURBO_CHIP_AY1
                        out     (c),a
                        WriteTurboRegister CHANNEL_A_AMPLITUDE, 0
                        WriteTurboRegister CHANNEL_B_AMPLITUDE, 0
                        WriteTurboRegister CHANNEL_C_AMPLITUDE, 0
                        ret
   
SetTone:                ;break
                        ld      hl,TonesPitch
                        add     a,a
                        add     hl,a
                        ld      a,(hl)
                        
                        WriteTurboRegisterA CHANNEL_A_COARSE
                        inc     hl
                        ld      a,(hl)
                        WriteTurboRegisterA CHANNEL_A_FINE
                        ret
                        

SetEngineTone:          ld      a,(DELTA)
                        ld      hl,$08EB
                        ld      d,a
                        ld      e,15
                        mul
                        sub     hl,de
                        ld      a,h
                        WriteTurboRegisterA CHANNEL_A_COARSE                      
                        ld      a,l
                        WriteTurboRegisterA CHANNEL_A_FINE
                        ret

UpdateEngineSound:      
EngineOn:
                        
.TonePitch:             call    SetEngineTone
.NoisePitch:            ld      a,(DELTA)
                        ld      hl,EngineNoise
                        add     hl,a
                        ld      a,(hl)
                        WriteTurboRegisterA NOISE_PERIOD
                        WriteTurboRegister  ENVELOPE_PERIOD_COARSE,0
                        WriteTurboRegister  ENVELOPE_PERIOD_FINE,0
                        WriteTurboRegister ENVELOPE_SHAPE, ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
                        ld      a,(DELTA)
                        sra     a
                        ld      hl,EngineVolume
                        add     hl,a
                        ld      a,(hl)
                        WriteTurboRegisterA CHANNEL_A_AMPLITUDE
                        WriteTurboRegister TONE_ENABLE, TONE_CHANNEL_B | TONE_CHANNEL_C |NOISE_CHANNEL_B| NOISE_CHANNEL_C
                        ret

EngineNoise:     db $1F
                 db $1F
                 db $1F
                 db $1F
                 db $1E
                 db $1E
                 db $1E
                 db $1E
                 db $1D
                 db $1D
                 db $1D
                 db $1D
                 db $1C
                 db $1C
                 db $1C
                 db $1C
                 db $1D
                 db $1D
                 db $1D
                 db $1D
                 db $1D
                 db $1D
                 db $1D

EngineVolume:    db 0
                 db 3
                 db 3
                 db 3
                 db 3
                 db 3
                 db 4
                 db 4
                 db 4
                 db 4
                 db 4
                 db 5
                 db 5
                 db 5
                 db 5
                 db 5
                 db 6
                 db 6
                 db 6
                 db 6
                 db 6
                 db 6
                 db 6
                 db 6
                 
TonesPitch       db $1F, $C8   
                 db $1E, $00
                 db $1D, $90   
                 db $0D, $5D
                 db $0C, $9C
                 db $0B, $E7
                 db $0B, $3C
                 db $0A, $9B
                 db $0A, $02
                 db $09, $73
                 db $08, $EB
                 db $08, $6B
                 db $07, $F2
                 db $07, $80
                 db $07, $64
                 db $06, $AE
                 db $06, $4E
                 db $05, $F3
                 db $05, $9E
                 db $05, $4D
                 db $05, $01
                 db $04, $B9
                 db $04, $75
                 db $04, $35
                 db $03, $F9
                 db $03, $C0
                 db $03, $B2
                 db $03, $57
                 db $03, $27
                 db $02, $F9
                 db $02, $CF
                 db $02, $A6
                 db $02, $80
                 db $02, $5C
                 db $02, $3A
                 db $02, $1A
                 db $01, $FC
                 db $01, $E0
                 db $01, $D9
                 db $01, $AB
                 db $01, $93
                 db $01, $7C
                 db $01, $67
                 db $01, $53
                 db $01, $40
                 db $01, $2E
                 db $01, $1D
                 db $01, $0D
                 db $00, $FE
                 db $00, $F0
                 db $00, $EC
                 db $00, $D5
                 db $00, $C9
                 db $00, $BE
                 db $00, $B3
                 db $00, $A9
                 db $00, $A0
                 db $00, $97
                 db $00, $8E
                 db $00, $86
                 db $00, $7F
                 db $00, $78
                 db $00, $76

