
;-------------------------------------------------------------------------------------------------
;--- Equates for sounds
;       DEFINE          USETIMER 1
       DEFINE          DANUBEATTACK 1
                        IFDEF   USETIMER
SOUNDSTEPLENGTH             EQU     25
                        ENDIF


WriteTurboControlA:     MACRO
                        ld      bc,TURBO_SOUND_NEXT_CONTROL
                        out     (c),a
                        ENDM

WriteTurboRegisterA:    MACRO   value
                        WriteTurboControlA
                        ld      b,$BF
                        ld      a,value
                        out     (c),a
                        ENDM

WriteTurboRegister:     MACRO   register,value
                        ld      a,register
                        WriteTurboControlA
                        ld      b,$BF
                        ld      a,value
                        out     (c),a
                        ENDM

WriteAToTurboRegister:  MACRO   register
                        ex      af,af'
                        ld      a,register
                        WriteTurboControlA
                        ld      b, $BF
                        ex      af,af'
                        out     (c),a
                        ENDM

SelectAY:               MACRO   chipNbr
                        ld      a,TURBO_MANDATORY | TURBO_LEFT | TURBO_RIGHT | chipNbr
                        WriteTurboControlA
                        ENDM

;--- Interrupt handler, moved from main code
SoundInterruptHandler:  ld      a,(DELTA)
                        ld      hl,LAST_DELTA
                        cp      (hl)
.SpeedChange:           call    nz, UpdateEngineSound
.NoSpeedChange:         call    SfxStartPending             ; start requested effects (PlaySFX)
                        call    SfxStepChannels             ; and play a step of each
                        ret


; On entering here a = AY chip to select
DefaultAYChip:          ld      hl,$FFBF            ; h = turbo control, l = turbo register
                        ld      c,$FD               ; bc = h$FD or l$FD
                        ld      de,$000E            ; d = value 0, e = counter
                        or      TURBO_MANDATORY | TURBO_LEFT | TURBO_RIGHT
                        ld      b,h                 ; now select chip and set to stereo
                        out     (c),a               ; .
.DefaultLoop:           dec     e                   ; loop down we set E 1 higher
                        jp      z,.Complete         ; On zero we complete, we
                        ld      b,h                 ; Set register to 0
                        out     (c),e               ; .
                        ld      b,l                 ; .
                        out     (c),d               ; .
.DefaultDone:           jp      .DefaultLoop        ; and loop
.Complete:              ld      b,h                 ; we set fine tone to 0
                        out     (c),e               ; though as volume is 0
                        ld      b,l                 ; it doesn't really
                        out     (c),d               ; matter
                        ret

;-- Initialise Audio channels to AY1 noise, AY2 and 3 tone, all channels to volume 0

; For each AY channel, set everything to zero, then set up envelope and tone channels.
; for now we are blocking noise channels whilst debugging
InitAudio:              ld      a, TURBO_CHIP_AY1
                        call    DefaultAYChip
                        WriteTurboRegister ENVELOPE_SHAPE,ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
                        WriteTurboRegister TONE_ENABLE,   NOISE_CHANNEL_A | NOISE_CHANNEL_B | NOISE_CHANNEL_C
                        ld      a, TURBO_CHIP_AY2
                        call    DefaultAYChip
                        WriteTurboRegister ENVELOPE_SHAPE,ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
                        WriteTurboRegister TONE_ENABLE,   NOISE_CHANNEL_A | NOISE_CHANNEL_B | NOISE_CHANNEL_C
                        ld      a, TURBO_CHIP_AY3
                        call    DefaultAYChip
                        WriteTurboRegister ENVELOPE_SHAPE,ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
                        WriteTurboRegister TONE_ENABLE,   NOISE_CHANNEL_A | NOISE_CHANNEL_B | NOISE_CHANNEL_C
                        jp      SfxReset                ; no effects playing

;Enable with no noise chanels active
InitAudioMusic:         ld      a, TURBO_CHIP_AY1
                        call    DefaultAYChip
                        WriteTurboRegister ENVELOPE_SHAPE,ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
                        WriteTurboRegister TONE_ENABLE,   NOISE_CHANNEL_A | NOISE_CHANNEL_B | NOISE_CHANNEL_C
                        ld      a, TURBO_CHIP_AY2
                        call    DefaultAYChip
                        WriteTurboRegister ENVELOPE_SHAPE,ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
                        WriteTurboRegister TONE_ENABLE,   NOISE_CHANNEL_A | NOISE_CHANNEL_B | NOISE_CHANNEL_C
                        ld      a, TURBO_CHIP_AY3
                        call    DefaultAYChip
                        WriteTurboRegister ENVELOPE_SHAPE,ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
                        WriteTurboRegister TONE_ENABLE,   NOISE_CHANNEL_A | NOISE_CHANNEL_B | NOISE_CHANNEL_C
                        ret

; Engine Sound is always a priority so gets a dedicated channel
; this is only called if delta has changed
UpdateEngineSound:      SelectAY TURBO_CHIP_AY1
.SetUpTone:             ld      a,(DELTA)
                        and     a
                        jp      z,.EngineOff    ; if speed is 0 the engine off as a = 0
                        ld      hl,$08F3        ; base tone - delta * 15
                        ld      d,a             ; we subtract as the tone is the
                        ld      e,15            ; time between pulses
                        sub     hl,de
                        ld      a,CHANNEL_A_FINE
                        ld      bc,$FFFD
                        out     (c),a
                        ld      b,$BF
                        out     (c),h
                        inc     a
                        ld      b,$FF
                        out     (c),a
                        ld      b,$BF
                        out     (c),l
.SetUpNoise:            ld      a,(DELTA)       ; l = DELTA / 4
                        srl     a
                        ld      d,a             ;
                        srl     a
                        srl     a               ; a = DELTA / 8
                        add     a, $1F          ; more noise higher the speed
                        ld      b,$FF
                        ld      e,NOISE_PERIOD
                        out     (c),e
                        ld      b,$BF
                        out     (c),a
                        ld      a,d             ; get back delta / 4
                        add     a,5
                        srl     a               ; calculate a scaled from 2 to 7
.EngineOff:             ld      e,CHANNEL_A_AMPLITUDE
                        ld      b,$FF
                        out     (c),e
                        ld      b,$BF
                        out     (c),a
                        WriteTurboRegister ENVELOPE_PERIOD_FINE,0
                        WriteTurboRegister ENVELOPE_PERIOD_COARSE,0
                        WriteTurboRegister ENVELOPE_SHAPE,ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
                        WriteTurboRegister TONE_ENABLE,   NOISE_CHANNEL_A | NOISE_CHANNEL_B | NOISE_CHANNEL_C
                        ld      a,(DELTA)
                        ld      (LAST_DELTA),a
                        ret

;----------------------------------------------------------------------------------------------------------------------------------
; Sound effects. The game asks for one with PlaySFX id (Macros: SoundFxPending[id] = 1, a single store so it is safe
; against this interrupt); each interrupt SfxStartPending starts every pending one on a free channel and SfxStepChannels
; plays one step (tone period and volume) of every running one, so a step is a frame. Channels: AY1 B and C, AY2 A B C,
; AY3 A B C (AY1 A is the engine, UpdateEngineSound). Tones only: InitAudio's mixer has the noise off. A request with
; every channel busy is dropped. (This replaces EnqueSound / PlaySound, whose register numbers were only right for
; channel A, whose channel map had 6 entries for 8 channels, and which nothing ever asked for a sound)
SfxChannels             equ 8
SfxChannelChip:         DB      TURBO_MANDATORY | TURBO_LEFT | TURBO_RIGHT | TURBO_CHIP_AY1
                        DB      TURBO_MANDATORY | TURBO_LEFT | TURBO_RIGHT | TURBO_CHIP_AY1
                        DB      TURBO_MANDATORY | TURBO_LEFT | TURBO_RIGHT | TURBO_CHIP_AY2
                        DB      TURBO_MANDATORY | TURBO_LEFT | TURBO_RIGHT | TURBO_CHIP_AY2
                        DB      TURBO_MANDATORY | TURBO_LEFT | TURBO_RIGHT | TURBO_CHIP_AY2
                        DB      TURBO_MANDATORY | TURBO_LEFT | TURBO_RIGHT | TURBO_CHIP_AY3
                        DB      TURBO_MANDATORY | TURBO_LEFT | TURBO_RIGHT | TURBO_CHIP_AY3
                        DB      TURBO_MANDATORY | TURBO_LEFT | TURBO_RIGHT | TURBO_CHIP_AY3
SfxChannelVoice:        DB      1, 2, 0, 1, 2, 0, 1, 2              ; A = 0, B = 1, C = 2
SfxChannelLeft:         DS      SfxChannels                         ; steps still to play, 0 = free
SfxChannelPtr:          DS      SfxChannels * 2                     ; the next step, 0 once silenced
SfxChannelSilence:      DS      SfxChannels                         ; non 0: the effect just ended, set the volume to 0

; d = register, a = value on the chip already selected; uses bc
SfxWriteReg:            ld      bc,TURBO_SOUND_NEXT_CONTROL
                        out     (c),d
                        ld      b,$BF
                        out     (c),a
                        ret

; e = channel: select its chip, d = its voice (0 to 2); uses a, bc, hl
SfxSelectChannel:       ld      hl,SfxChannelChip
                        ld      a,e
                        add     hl,a
                        ld      a,(hl)
                        ld      bc,TURBO_SOUND_NEXT_CONTROL
                        out     (c),a
                        ld      hl,SfxChannelVoice
                        ld      a,e
                        add     hl,a
                        ld      d,(hl)
                        ret

; start every requested effect (SoundFxPending, main memory)
SfxStartPending:        ld      hl,SoundFxPending
                        ld      c,0                                 ; c = effect id
.Loop:                  ld      a,(hl)
                        and     a
                        jr      z,.Next
                        ld      (hl),0
                        push    bc,,hl
                        ld      a,c
                        call    SfxStart
                        pop     bc,,hl
.Next:                  inc     hl
                        inc     c
                        ld      a,c
                        cp      SFXCount
                        jr      c,.Loop
                        ret

; a = effect id: on the first free channel (dropped if none)
SfxStart:               ld      hl,SFXPointerList                   ; de = its data
                        add     a,a
                        add     hl,a
                        ld      e,(hl)
                        inc     hl
                        ld      d,(hl)
                        ld      hl,SfxChannelLeft                   ; find a free channel
                        ld      b,SfxChannels
                        ld      c,0
.Find:                  ld      a,(hl)
                        and     a
                        jr      z,.Found
                        inc     hl
                        inc     c
                        djnz    .Find
                        ret                                         ; all busy
.Found:                 ld      a,(de)                              ; the step count
                        ld      (hl),a
                        inc     de                                  ; the first step
                        ld      hl,SfxChannelPtr
                        ld      a,c
                        add     a,a
                        add     hl,a
                        ld      (hl),e
                        inc     hl
                        ld      (hl),d
                        ld      hl,SfxChannelSilence
                        ld      a,c
                        add     hl,a
                        ld      (hl),0
                        ret

; one step of every running effect, and silence the ones that ended last frame
SfxStepChannels:        ld      e,0                                 ; e = channel
.Loop:                  ld      hl,SfxChannelSilence
                        ld      a,e
                        add     hl,a
                        ld      a,(hl)
                        and     a
                        jr      z,.NotEnded
                        ld      (hl),0
                        push    de
                        call    SfxSelectChannel
                        ld      a,d                                 ; volume register 8 + voice
                        add     a,CHANNEL_A_AMPLITUDE
                        ld      d,a
                        xor     a
                        call    SfxWriteReg
                        pop     de
.NotEnded:              ld      hl,SfxChannelLeft
                        ld      a,e
                        add     hl,a
                        ld      a,(hl)
                        and     a
                        jr      z,.Next                             ; free
                        dec     (hl)                                ; one fewer to play
                        jr      nz,.Step
                        ld      hl,SfxChannelSilence                ; the last: silence it next frame
                        ld      a,e
                        add     hl,a
                        ld      (hl),1
.Step:                  ld      hl,SfxChannelPtr                    ; ix = the step's data
                        ld      a,e
                        add     a,a
                        add     hl,a
                        push    hl
                        ld      a,(hl)
                        inc     hl
                        ld      h,(hl)
                        ld      l,a
                        push    hl
                        pop     ix
                        push    de
                        call    SfxSelectChannel                    ; d = voice
                        ld      a,d                                 ; fine tone register 2 * voice
                        add     a,a
                        ld      d,a
                        ld      a,(ix+SFXFineOffset)
                        call    SfxWriteReg
                        inc     d                                   ; coarse 2 * voice + 1
                        ld      a,(ix+SFXCorseOffset)
                        and     $0F
                        call    SfxWriteReg
                        srl     d                                   ; volume 8 + voice
                        ld      a,d
                        add     a,CHANNEL_A_AMPLITUDE
                        ld      d,a
                        ld      a,(ix+SFXVolOffset)
                        and     $0F
                        call    SfxWriteReg
                        pop     de
                        pop     hl                                  ; the pointer on a step
                        ld      bc,SFXBlockLength
                        add     ix,bc
                        push    ix
                        pop     bc
                        ld      (hl),c
                        inc     hl
                        ld      (hl),b
.Next:                  inc     e
                        ld      a,e
                        cp      SfxChannels
                        jr      c,.Loop
                        ret

; silence and free every effect channel (start up)
SfxReset:               ld      hl,SfxChannelLeft
                        ld      b,SfxChannels * 4
.Clear:                 ld      (hl),0
                        inc     hl
                        djnz    .Clear
                        ld      e,0
.Silence:               push    de
                        call    SfxSelectChannel
                        ld      a,d
                        add     a,CHANNEL_A_AMPLITUDE
                        ld      d,a
                        xor     a
                        call    SfxWriteReg
                        pop     de
                        inc     e
                        ld      a,e
                        cp      SfxChannels
                        jr      c,.Silence
                        ret

;--- Effect data (ids SFXLaser .. in Variables/constant_equates.asm, in this order): a step count, then per step the
;--- tone period fine, coarse (4 bits) and the volume (0 to 15); a period is 1.75 MHz / 16 / the frequency
SFXBlockLength          EQU     3
SFXFineOffset           EQU     0
SFXCorseOffset          EQU     1
SFXVolOffset            EQU     2
SoundLabelSFX           DB      "Sound Data      "
; laser pulse (the original table, its 5th step coarse $10, a typo, now $00)
SFXDataLaser:         DB      11                          ; steps (one a frame)
                        DB      $5F, $00, $0E
                        DB      $39, $00, $0E
                        DB      $47, $00, $0D
                        DB      $5E, $00, $0C
                        DB      $6E, $00, $0A
                        DB      $76, $00, $08
                        DB      $76, $00, $07
                        DB      $06, $01, $06
                        DB      $2E, $01, $03
                        DB      $16, $01, $03
                        DB      $03, $00, $01

; a ship hit by our laser or a collision
SFXDataHit:           DB      6                           ; steps (one a frame)
                        DB      $6E, $00, $0F
                        DB      $8C, $00, $0D
                        DB      $AA, $00, $0B
                        DB      $C8, $00, $08
                        DB      $E6, $00, $05
                        DB      $04, $01, $02

; an explosion: random low periods (no noise channel) dying away
SFXDataExplosion:     DB      25                          ; steps (one a frame)
                        DB      $B2, $08, $0F
                        DB      $ED, $05, $0E
                        DB      $D5, $09, $0E
                        DB      $EE, $0D, $0D
                        DB      $49, $04, $0D
                        DB      $AC, $04, $0C
                        DB      $16, $0C, $0B
                        DB      $05, $05, $0B
                        DB      $5D, $09, $0A
                        DB      $D7, $0C, $0A
                        DB      $71, $04, $09
                        DB      $A2, $0B, $08
                        DB      $F3, $06, $08
                        DB      $1D, $04, $07
                        DB      $E4, $04, $07
                        DB      $74, $0A, $06
                        DB      $34, $0A, $05
                        DB      $A2, $04, $05
                        DB      $5D, $07, $04
                        DB      $F7, $04, $04
                        DB      $55, $0C, $03
                        DB      $4E, $0A, $02
                        DB      $76, $04, $02
                        DB      $90, $0C, $01
                        DB      $7F, $05, $01

; missile launch: a rising whoosh
SFXDataMissile:       DB      16                          ; steps (one a frame)
                        DB      $BC, $02, $0C
                        DB      $96, $02, $0C
                        DB      $71, $02, $0C
                        DB      $4C, $02, $0C
                        DB      $26, $02, $0C
                        DB      $01, $02, $0C
                        DB      $DC, $01, $0C
                        DB      $B6, $01, $0C
                        DB      $91, $01, $0C
                        DB      $6C, $01, $0C
                        DB      $46, $01, $0A
                        DB      $21, $01, $08
                        DB      $FC, $00, $06
                        DB      $D6, $00, $04
                        DB      $B1, $00, $03
                        DB      $8C, $00, $02

; ECM: a warble
SFXDataECM:           DB      32                          ; steps (one a frame)
                        DB      $82, $00, $0A
                        DB      $5A, $00, $0A
                        DB      $82, $00, $0A
                        DB      $5A, $00, $0A
                        DB      $82, $00, $0A
                        DB      $5A, $00, $0A
                        DB      $82, $00, $0A
                        DB      $5A, $00, $0A
                        DB      $82, $00, $0A
                        DB      $5A, $00, $0A
                        DB      $82, $00, $0A
                        DB      $5A, $00, $0A
                        DB      $82, $00, $0A
                        DB      $5A, $00, $0A
                        DB      $82, $00, $0A
                        DB      $5A, $00, $0A
                        DB      $82, $00, $0A
                        DB      $5A, $00, $0A
                        DB      $82, $00, $0A
                        DB      $5A, $00, $0A
                        DB      $82, $00, $0A
                        DB      $5A, $00, $0A
                        DB      $82, $00, $0A
                        DB      $5A, $00, $0A
                        DB      $82, $00, $09
                        DB      $5A, $00, $08
                        DB      $82, $00, $07
                        DB      $5A, $00, $06
                        DB      $82, $00, $05
                        DB      $5A, $00, $04
                        DB      $82, $00, $03
                        DB      $5A, $00, $02

; bing bong: the jump drive hot or mass locked, a missile with no lock
SFXDataBong:          DB      22                          ; steps (one a frame)
                        DB      $18, $01, $0D
                        DB      $18, $01, $0D
                        DB      $18, $01, $0C
                        DB      $18, $01, $0B
                        DB      $18, $01, $0A
                        DB      $18, $01, $09
                        DB      $18, $01, $08
                        DB      $18, $01, $06
                        DB      $A4, $01, $0D
                        DB      $A4, $01, $0D
                        DB      $A4, $01, $0C
                        DB      $A4, $01, $0B
                        DB      $A4, $01, $0A
                        DB      $A4, $01, $09
                        DB      $A4, $01, $08
                        DB      $A4, $01, $07
                        DB      $A4, $01, $06
                        DB      $A4, $01, $05
                        DB      $A4, $01, $04
                        DB      $A4, $01, $03
                        DB      $A4, $01, $02
                        DB      $A4, $01, $01

; hyperspace: a long rising sweep
SFXDataHyperspace:    DB      40                          ; steps (one a frame)
                        DB      $E8, $03, $0C
                        DB      $A2, $03, $0C
                        DB      $61, $03, $0C
                        DB      $25, $03, $0C
                        DB      $ED, $02, $0C
                        DB      $B9, $02, $0C
                        DB      $88, $02, $0C
                        DB      $5B, $02, $0C
                        DB      $31, $02, $0C
                        DB      $0A, $02, $0C
                        DB      $E6, $01, $0C
                        DB      $C4, $01, $0C
                        DB      $A4, $01, $0C
                        DB      $87, $01, $0C
                        DB      $6C, $01, $0C
                        DB      $52, $01, $0C
                        DB      $3B, $01, $0C
                        DB      $25, $01, $0C
                        DB      $10, $01, $0C
                        DB      $FD, $00, $0C
                        DB      $EC, $00, $0C
                        DB      $DB, $00, $0C
                        DB      $CC, $00, $0C
                        DB      $BE, $00, $0C
                        DB      $B1, $00, $0C
                        DB      $A4, $00, $0C
                        DB      $99, $00, $0C
                        DB      $8E, $00, $0C
                        DB      $84, $00, $0C
                        DB      $7B, $00, $0C
                        DB      $72, $00, $0B
                        DB      $6A, $00, $0A
                        DB      $63, $00, $09
                        DB      $5C, $00, $08
                        DB      $56, $00, $07
                        DB      $50, $00, $06
                        DB      $4A, $00, $05
                        DB      $45, $00, $04
                        DB      $40, $00, $03
                        DB      $3C, $00, $02

SFXPointerList:         DW      SFXDataLaser, SFXDataHit, SFXDataExplosion, SFXDataMissile, SFXDataECM, SFXDataBong, SFXDataHyperspace


DanubePointer1:         DW BlueDanube1
DanubePointer2:         DW BlueDanube2
DanubePointer3:         DW BlueDanube3
DanubePointer4:         DW BlueDanube4
DanubePointer5:         DW BlueDanube5
DanubePointer6:         DW BlueDanube6
; Sustain reduces volume each cycle, playing a note resets it
DanubeVolume1:          DB 0
DanubeChip1:            DB TURBO_CHIP_AY2
DanubeVolume2:          DB 0
DanubeChip2:            DB TURBO_CHIP_AY2
DanubeVolume3:          DB 0
DanubeChip3:            DB TURBO_CHIP_AY2
DanubeVolume4:          DB 0
DanubeChip4:            DB TURBO_CHIP_AY3
DanubeVolume5:          DB 0
DanubeChip5:            DB TURBO_CHIP_AY3
DanubeVolume6:          DB 0
DanubeChip6:            DB TURBO_CHIP_AY3
PointerVolOffset:       EQU 12
PointerChipOffset:      EQU 13
DanubeCounter:          DW 0
DanubeMax:              EQU BlueDanube2 - BlueDanube1 +1
DanubeMaxMem:           DW  DanubeMax
DanubeVolume:           DB $0F
DanubePace:             DB 8
DanubeTimer:            DB 8
DanubeAttackEnvelope    DW $0000

SelectDanubeAYa:        or TURBO_MANDATORY | TURBO_LEFT | TURBO_RIGHT
                        WriteTurboControlA
                        ret

WriteAToTurboRegisterD: ex      af,af'
                        ld      a,d
                        WriteTurboControlA
                        ld      b,$BF
                        ex      af,af'
                        out     (c),a
                        ret

SetChannelAVolume0:     WriteTurboControlA
                        ld      b,$BF
                        ZeroA
                        out     (c),a
                        ret

SetChannelDNoteAtHL:    ld      a,d                 ; a is now 0 to 2
                        sla     a                   ; multiply by 2 so now 0, 2, 4
                        push    af                  ; save fine adjust register nbr
                        WriteTurboControlA          ; Send out fine adjust
                        ld      b,$BF
                        ld      a,(hl)              ; get fine note
                        out     (c),a               ; write fine note
                        pop     af                  ; get back fine adjust register
                        inc     a
                        WriteTurboControlA
                        inc     hl                  ; move to coarse value
                        ld      b,$BF
                        ld      a,(hl)
                        out     (c),a
.SetAttack:             ;    ld      hl,(DanubeAttackEnvelope)
.SetVolume:             ld      a,d                 ; get back channel
                        add     a,8
                        WriteTurboControlA
                        ld      b,$BF
                        ld      a,(DanubeVolume)    ; could put in ixh but we have plenty of cycles
                        out     (c),a
                        ret
                        
SustainNote:            ld      a,(ix+6)
                        dec     a
                        jr      nz,.MinNoteSkip
                        ld      a,1
.MinNoteSkip:           ld      (ix+PointerVolOffset),a
                        ld      a,b          ; get back channel which is passed in via b
                        add     a,8
                        WriteTurboControlA
                        ld      b,$BF
                        ld      a,(ix+PointerVolOffset)    
                        out     (c),a
                        IFDEF   DANUBEATTACK
.SetAttack:                 ld      a,ENVELOPE_PERIOD_FINE
                            WriteTurboControlA
                            ld      b,$BF
                            ZeroA
                            out     (c),a
                            ld      a,ENVELOPE_PERIOD_COARSE
                            WriteTurboControlA
                            ld      b,$BF
                            ZeroA
                            out     (c),a
                        ENDIF
                        ret


; IN iyh = channel number, a = note, ix = pointer to danubepointer table corresponding to guitar string
PlayDanubeNote:         ld      a,(ix+PointerChipOffset)
                        push    bc
                        call    SelectDanubeAYa
                        pop     bc
                        ld      a,(ix+0)
                        ld      l,a
                        ld      a,(ix+1)
                        ld      h,a
                        ld      a,(hl)
                        and     a
                        jr      z,  .NoNote
                        cp      $FF
                        ret     z
                        ld      hl, TonesPitch
                        ld      e,a         ; save a
                        and     $F0         ; load octave to d
                        swapnib             ;
                        ld      d,a         ;
                        ld      a,e         ; get a back
                        ld      e,12        ; 12 semi tones so mul by 12
                        mul                 ;
                        and     $0F         ; get semi tone
                        ex      de,hl       ; hl = octave * 12 + semi tone
                        add     hl,a        ; .
                        ShiftHLLeft1        ; multiply by 2 as we have 2 bytes per tone
                        ld      de,TonesPitch
                        add     hl,de       ; now we are pointing at table
                        ld      d,b         ; get channel number
                        call    SetChannelDNoteAtHL ; leaves with A = volume note
                        ld      (ix+PointerVolOffset),a    ;
                        ret
.NoNote:                ld      a,b         ; a= channel number 0 to 3
                        add     8           ; adjust to volume register
.NoNoteOK               call    SetChannelAVolume0
                        ret

PlayDanube:             ld      a,(DanubeTimer)
                        dec     a
                        jr      z,.PlaySequence
                        ld      (DanubeTimer),a
                        ret
.PlaySequence:          ld      b,6
                        ld      ix,DanubePointer1
                        ld      c,0
.ChannelLoop:           push    bc 
                        ld      b,c
                        call    PlayDanubeNote
                        pop     bc
                        inc     ix
                        inc     ix
                        inc     c
                        ld      a,c
                        cp      3
                        jr      nz,.SkipChannelMax
                        ld      c,0
.SkipChannelMax:        djnz    .ChannelLoop
                        jp      UpdatePointers
;
.sPlaySequence:
.PlayChannel1:          ld      a,TURBO_CHIP_AY2
                        call    SelectDanubeAYa
                        ld      ix,DanubePointer1
                        ld      a,(ix+0)
                        ld      hl,(DanubePointer1)
                        ld      a,(hl)
                        ld      b,0
                        call    PlayDanubeNote
.PlayChannel2:          ;break
                        ld      a,TURBO_CHIP_AY2
                        call    SelectDanubeAYa
                        ld      ix,DanubePointer2
                        ld      a,(ix+0)
                        ld      b,1
                        call    PlayDanubeNote
.PlayChannel3:          ld      a,TURBO_CHIP_AY2
                        call    SelectDanubeAYa
                        ld      ix,DanubePointer3
                        ld      a,(ix+0)
                        ld      b,2
                        call    PlayDanubeNote
.PlayChannel4:          ld      a,TURBO_CHIP_AY3
                        call    SelectDanubeAYa
                        ld      ix,DanubePointer4
                        ld      a,(ix+0)
                        ld      b,0
                        call    PlayDanubeNote
.PlayChannel5:          ld      a,TURBO_CHIP_AY3
                        call    SelectDanubeAYa
                        ld      ix,DanubePointer5
                        ld      a,(ix+0)
                        ld      b,1
                        call    PlayDanubeNote
.PlayChannel6:          ld      a,TURBO_CHIP_AY3
                        call    SelectDanubeAYa
                        ld      ix,DanubePointer6
                        ld      a,(ix+0)
                        ld      b,2
                        call    PlayDanubeNote
UpdatePointers:         ld      a,(DanubePace)
                        ld      (DanubeTimer),a
                        ld      hl,(DanubeCounter)
                        ld      de,DanubeMax
.compare16HLDE:         push    hl
                        and     a
                        sbc     hl,de
                        pop     hl
                        jr      nz,.MovePointersForward
.ResetPointers:         ld      hl,BlueDanube1
                        ld      (DanubePointer1),hl
                        ld      hl,BlueDanube2
                        ld      (DanubePointer2),hl
                        ld      hl,BlueDanube3
                        ld      (DanubePointer3),hl
                        ld      hl,BlueDanube4
                        ld      (DanubePointer4),hl
                        ld      hl,BlueDanube5
                        ld      (DanubePointer5),hl
                        ld      hl,BlueDanube6
                        ld      (DanubePointer6),hl
                        ld      hl,0
                        ld      (DanubeCounter),hl
.MovePointersForward:   inc     hl
                        ld      (DanubeCounter),hl
                        ld      hl,DanubePointer1
                        call    AdvancePointer
                        ld      hl,DanubePointer2
                        call    AdvancePointer
                        ld      hl,DanubePointer3
                        call    AdvancePointer
                        ld      hl,DanubePointer4
                        call    AdvancePointer
                        ld      hl,DanubePointer5
                        call    AdvancePointer
                        ld      hl,DanubePointer6
                        call    AdvancePointer
                        ret

AdvancePointer:         ld      a,(hl)
                        inc     hl
                        ld      d,(hl)
                        ld      e,a
                        inc     de
                        ld      (hl),d
                        dec     hl
                        ld      (hl),e
                        ret


TonesPitch       db  $BF,   $0F
                 db  $DC,   $0E
                 db  $07,   $0E
                 db  $7B,   $1A
                 db  $FE,   $18
                 db  $97,   $17
                 db  $44,   $16
                 db  $04,   $15
                 db  $D6,   $13
                 db  $B9,   $12
                 db  $AC,   $11
                 db  $AE,   $10
                 db  $DF,   $07
                 db  $6E,   $07
                 db  $03,   $07
                 db  $3D,   $0D
                 db  $7F,   $0C
                 db  $CC,   $0B
                 db  $22,   $0B
                 db  $82,   $0A
                 db  $EB,   $09
                 db  $5D,   $09
                 db  $D6,   $08
                 db  $57,   $08
                 db  $F0,   $03
                 db  $B7,   $03
                 db  $82,   $03
                 db  $9F,   $06
                 db  $40,   $06
                 db  $E6,   $05
                 db  $91,   $05
                 db  $41,   $05
                 db  $F6,   $04
                 db  $AE,   $04
                 db  $6B,   $04
                 db  $2C,   $04
                 db  $F8,   $01
                 db  $DC,   $01
                 db  $C1,   $01
                 db  $4F,   $03
                 db  $20,   $03
                 db  $F3,   $02
                 db  $C9,   $02
                 db  $A1,   $02
                 db  $7B,   $02
                 db  $57,   $02
                 db  $36,   $02
                 db  $16,   $02
                 db  $FC,   $00
                 db  $EE,   $00
                 db  $E0,   $00
                 db  $A8,   $01
                 db  $90,   $01
                 db  $79,   $01
                 db  $64,   $01
                 db  $50,   $01
                 db  $3D,   $01
                 db  $2C,   $01
                 db  $1B,   $01
                 db  $0B,   $01
                 db  $7E,   $00
                 db  $77,   $00
                 db  $70,   $00
                 db  $D4,   $00
                 db  $C8,   $00
                 db  $BD,   $00
                 db  $B2,   $00
                 db  $A8,   $00
                 db  $9F,   $00
                 db  $96,   $00
                 db  $8D,   $00
                 db  $85,   $00
                 db  $3F,   $00
                 db  $3B,   $00
                 db  $38,   $00
                 db  $6A,   $00
                 db  $64,   $00
                 db  $5E,   $00
                 db  $59,   $00
                 db  $54,   $00
                 db  $4F,   $00
                 db  $4B,   $00
                 db  $47,   $00
                 db  $43,   $00


; 1 Byte high nibble Octave, low note
; for now middle octave 3,
; low nibble mapping
;       0      1  2  3  4  5  6   7  8  9   A  B  C
;       None   A  A# B  C  C# D  D#  E  F  F#  G  G#

BlueDanube1:          DB 	$00, 	$00, 	$00, 	$48, 	$00, 	$00, 	$00, 	$4A, 	$FF, 	$4A, 	$FF, 	$4A, 	$FF, 	$00, 	$00, 	$48, 	$00, 	$00, 	$00, 	$4B, 	$FF, 	$4B, 	$FF, 	$4B, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00
                      DB	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00
                      DB	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$48, 	$FF, 	$48, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$48, 	$00, 	$48, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$4B, 	$FF, 	$4B, 	$FF, 	$00, 	$00
                      DB	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$4B, 	$FF, 	$4B, 	$FF, 	$00, 	$00, 	$48, 	$FF, 	$48, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$4A, 	$FF, 	$4A, 	$FF, 	$4A, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$48
                      DB	$FF, 	$00, 	$00, 	$00, 	$00, 	$4A, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$4B, 	$FF, 	$4B, 	$FF, 	$00, 	$00, 	$4B, 	$FF, 	$49, 	$FF
BlueDanube2:          DB 	$00, 	$44, 	$46, 	$00, 	$00, 	$44, 	$FF, 	$44, 	$FF, 	$44, 	$FF, 	$44, 	$FF, 	$44, 	$46, 	$00, 	$00, 	$43, 	$FF, 	$43, 	$FF, 	$43, 	$FF, 	$43, 	$FF, 	$43, 	$44, 	$46, 	$00, 	$00, 	$00, 	$44, 	$00, 	$00, 	$00, 	$00, 	$00, 	$44, 	$00, 	$00, 	$00, 	$00, 	$00, 	$44, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00
                      DB	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$46, 	$00, 	$46, 	$00, 	$00, 	$00, 	$43, 	$00, 	$43, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$46, 	$FF, 	$46, 	$FF, 	$00, 	$00, 	$44, 	$44, 	$00, 	$00, 	$00, 	$00
                      DB	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$44, 	$FF, 	$44, 	$FF, 	$00, 	$00, 	$44, 	$FF, 	$44, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$43, 	$00, 	$43, 	$00, 	$00, 	$00, 	$43, 	$FF, 	$43, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$43, 	$FF, 	$43, 	$FF, 	$00, 	$46
                      DB	$FF, 	$46, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$48, 	$FF, 	$48, 	$FF, 	$00, 	$00, 	$44, 	$FF, 	$44, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$44, 	$FF, 	$44, 	$FF, 	$44, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$43, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$43, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$44
                      DB	$FF, 	$00, 	$00, 	$00, 	$00, 	$44, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$43, 	$FF, 	$43, 	$FF, 	$00, 	$00, 	$43, 	$FF, 	$00, 	$00                                                                                                                                                                                                                                                                                                                                                      
BlueDanube3:          DB 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$41, 	$FF, 	$41, 	$FF, 	$41, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$3B, 	$FF, 	$3B, 	$FF, 	$3B, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$41, 	$00, 	$00, 	$00, 	$00, 	$00, 	$3B, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$41, 	$00, 	$00, 	$00, 	$00, 	$00, 	$3B, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00
                      DB	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$43, 	$00, 	$43, 	$00, 	$00, 	$00, 	$3B, 	$00, 	$3B, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$41, 	$FF, 	$41, 	$FF, 	$00, 	$00, 	$41, 	$41, 	$00, 	$00, 	$00, 	$00
                      DB	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$41, 	$FF, 	$41, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$3B, 	$FF, 	$3B, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$3B, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$00, 	$3B
                      DB	$FF, 	$3B, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$3B, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$3B, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$41, 	$FF, 	$41, 	$FF, 	$41, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$3B, 	$FF, 	$3B, 	$FF, 	$00, 	$00, 	$3B, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00
                      DB	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$3B, 	$FF, 	$3B, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$3C, 	$FF                                                                                                                                                                                                                                                                                                                                                     
BlueDanube4:          DB 	$00, 	$00, 	$00, 	$00, 	$36, 	$00, 	$00, 	$36, 	$FF, 	$36, 	$FF, 	$36, 	$FF, 	$00, 	$00, 	$00, 	$36, 	$00, 	$00, 	$36, 	$FF, 	$36, 	$FF, 	$36, 	$FF, 	$00, 	$00, 	$00, 	$36, 	$36, 	$00, 	$00, 	$00, 	$36, 	$00, 	$36, 	$00, 	$00, 	$00, 	$36, 	$00, 	$3A, 	$00, 	$00, 	$00, 	$36, 	$00, 	$38, 	$00, 	$00, 	$00, 	$00, 	$00, 	$36, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$3A, 	$00, 	$00
                      DB	$00, 	$36, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$36, 	$FF, 	$36, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$36, 	$FF, 	$36, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$00, 	$00, 	$00, 	$00
                      DB	$00, 	$00, 	$00, 	$00, 	$38, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$38, 	$FF, 	$38, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$38, 	$FF, 	$38, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$36, 	$36, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$00, 	$00
                      DB	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$36, 	$FF, 	$38, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$38, 	$FF, 	$38, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$36, 	$FF, 	$00, 	$00, 	$36, 	$FF, 	$36, 	$FF, 	$36, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00
                      DB	$00, 	$00, 	$00, 	$38, 	$FF, 	$00, 	$00, 	$36, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00                                                                                                                                                                                                                                                                                                                                                  
BlueDanube5:          DB 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$34, 	$00, 	$00, 	$00, 	$00, 	$00, 	$33, 	$00, 	$34, 	$00, 	$00, 	$00, 	$31
                      DB	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$34, 	$00, 	$00, 	$00, 	$00, 	$00, 	$31, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$33, 	$FF, 	$00, 	$00, 	$33, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$33, 	$FF, 	$00, 	$00, 	$31, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00
                      DB	$00, 	$00, 	$31, 	$FF, 	$00, 	$00, 	$31, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$31, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$31, 	$FF, 	$00, 	$00, 	$33, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$33, 	$FF, 	$00, 	$33, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$00, 	$33
                      DB	$FF, 	$33, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$33, 	$FF, 	$00, 	$00, 	$34, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$31, 	$FF, 	$31, 	$FF, 	$34, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$35, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$33, 	$FF, 	$33, 	$FF, 	$00
                      DB	$00, 	$31, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00                                                                                                                                                                                                                                                                                                                                                   
BlueDanube6:          DB 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00
                      DB	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$2B, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$2B, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$2B, 	$FF, 	$2B, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$2A, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$2A, 	$FF
                      DB	$2A, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$2A, 	$FF, 	$2A, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$2B, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$2B, 	$FF, 	$2B, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00
                      DB	$00, 	$00, 	$00, 	$00, 	$00, 	$2B, 	$FF, 	$2B, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$2B, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00
                      DB	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$2B, 	$FF, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00, 	$00
