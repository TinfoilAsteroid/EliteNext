
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
.NoSpeedChange:         ld      a,(SoundFxToEnqueue)        ; Check for new sound
                        cp      $FF
                        call    nz,EnqueSound
.NoNewSound:            IFDEF   USETIMER
                            ld      hl,SoundChannelTimer
                        ENDIF
                        ld      de,SoundChannelSeq
                        ld      b,8
.ResetLoop:             ld      a,(de)                  ; we only update active channels
                        cp      $FF
                        jr      z,.NextCounter
                        IFDEF   USETIMER
                            dec     (hl)                    ; so update channel timer
                            jr      nz,.NextCounter         ; if its not zero then continue
                        ENDIF
                        ld      a,8                     ; a now = channel to play
                        sub     a,b
                        IFDEF   USETIMER
                            push    bc,,de,,hl              ; save state
                        ELSE
                            push    bc,,de
                        ENDIF
                        call    PlaySound               ; play sound
                        IFDEF   USETIMER
                            pop     bc,,de,,hl              ; restore state so de = correct timer & hl = correct channel, b = coutner
                        ELSE
                            pop     bc,,de              ; restore state so de = correct timer & hl = correct channel, b = coutner
                        ENDIF
; If it went negative new sound update
                        IFDEF   USETIMER
.ResetTimer:                ld      a,SOUNDSTEPLENGTH       ; as we fallin to this it will auto update counter
                            ld      (hl),a                  ; so may take it out of playsound routine
                        ENDIF
.NextCounter:
                        IFDEF   USETIMER
                            inc     hl
                        ENDIF
                        inc     de
                        djnz    .ResetLoop
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
                        ld      hl,SoundChannelSeq      ; now set up all the channel data to $FF
                        ld      hl,SoundChannelSeq      ; now set up all the channel data to $FF
                        ld      a,$FF                   ; which means that it
                        ld      b,8                     ; has no data to play
.InitLoop:              ld      (hl),a
                        inc     hl
                        djnz    .InitLoop
                        ret

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

GetSoundAAddressToHL:   MACRO
                        ld      hl,SFXPointerList
                        add     a,a
                        add     hl,a
                        ld      a,(hl)
                        inc     hl
                        ld      h,(hl)
                        ld      l,a
                        ENDM

SetIXToChannelA:        MACRO
                        ld      hl,SoundChannelSeq
                        add     hl,a
                        ld      ix,hl
                        ENDM

SelectChannelMapping:   MACRO
                        ld      hl,SoundChipMapNumber
                        add     hl,a
                        ld      a,(hl)
                        ENDM

; This version ignores nooise and envelope setup so its always 0 atack hold and
; noise is pre-configured in channel
; The channel always holds a pointer to the next block of data to play
PlayChannelD:           ld      a,(ix+SoundDataPointerOffset)    ; set hl to current data block
                        ld      l,a                              ; for SFX step
                        ld      a,(ix+SoundDataPointerOffset1)   ;
                        ld      h,a                              ;
                        ld      a,(hl)                           ; get fine
                        WriteAToTurboRegister d
                        inc     d                                ; Move to channel coarse
                        inc     hl
                        ld      a,(hl)
                        WriteAToTurboRegister d
                        ld      a,d
                        add     a,7
                        ld      d,a
                        inc     hl                               ; Get Volume
                        ld      a,(hl)
                        WriteAToTurboRegister d
                        ret

;--- Take the current sound to play, Put it in a noise or tone channel (if bit 1 is clear is a tone only)
EnqueSound:             ld      a,(SoundFxToEnqueue)                ; Get Sound FX to Enque
                        JumpIfAGTENusng SFXEndOfList, .InvalidSound ; Invalid sounds get discarded quickly
.GetSoundData:          ld      e,a                                 ; save SoundFxToEnqeue
                        and     $01                                 ; even numbers are tone only (Including 0)
                        jr      nz,.FindFreeNoiseChannel
.FindFreeToneChannel:   ld      hl,SoundChannelSeq + 2              ; so we start at the first tone channel
                        ld      d,$FF                               ; d = marker for free slot cp d will be faster in the loop
                        ld      c,2                                 ; c= current slot
                        ld      b,7                                 ; b = nbr of slots
.ToneScanLoop:          ld      a,(hl)                              ; is channel occupied
                        cp      d
                        jr      z,.SaveSoundId                      ; if its free then move forward
                        inc     c                                   ; c is hunting for a free channel
                        inc     hl                                  ; move tonext address in channel list
                        djnz    .ToneScanLoop
.NoFreeSlot:            ret                                         ; no free slot, leave sound enqued
.FindFreeNoiseChannel:  ld      hl,SoundChannelSeq                  ; We only have 2 noise channels so no need to
                        ld      c,0                                 ; do a complex loop
                        ld      a,(hl)
                        ld      d,$FF                               ; d = marker for free slot
                        cp      d
                        jr      z,.SaveSoundId
                        inc     hl
                        ld      a,(hl)
                        cp      d
.NoNoiseSlot:           ret     nz                                  ; no free slot, leave sound enqued
.NoiseChannel2:         ld      c,1                                 ; So we have channel 1 free
.SaveSoundId:           ld      a,e                                 ; get back sound id
                        GetSoundAAddressToHL                        ; hl = pointer to sfx data
                        ex      de,hl                               ; save pointer to data also makes loading to (ix) easier
.SetIXToChannelPointer: ld      hl,SoundChannelSeq                  ; Get the sequence for the
                        ld      a,c                                 ; respective channel
                        add     hl,a                                ; that we are looking at
                        ld      ix,hl                               ; now we can use indexed access
.GetSFXDataBack:        ex      de,hl                               ; hl = sound fx again
.LoadSeqCount           ZeroA
                        ld      (ix+0),a                            ; set SoundChannelSeq[channel] to 0 as its starting
                        ld      a,(hl)                              ; get the nbr of steps
                        ld      (ix+SoundLastSeqOffset),a           ; load SoundChannelLastSeq[channel]
                        IFDEF   USETIMER
                            ld      a,1                             ; for now we have separate timers, we enque with 1 so the loops starts immediatly
                            ld      (ix+SoundTimerOffset),a         a; load SoundChannelTimer[channel] with duration
                        ENDIF
                        inc     hl                                  ; move hl to first byte of data block
                        ld      (ix+SoundDataPointerOffset),l       ; load SoundDataPointer[channel] with current data set
                        ld      (ix+SoundDataPointerOffset1),h
.InvalidSound:          ld      a,$FF
                        ld      (SoundFxToEnqueue),a                ; ClearFXEnqeue
                        ret

PlaySound:              ld      e,a                                 ; save channel number
                        SetIXToChannelA                             ; We trap for debugging
.GetCurrentSeq:         ld      a,(ix+0)                            ; for optimisation we
                        cp      $FF                                 ; will never call this if its $FF
                        ret     z                                   ; its just a belt n braces
;--- Play Next Step, we select chip, select channel, set up tone then step, timer & pointer
.SelectChip             ld      a,(ix+SoundChipMapOffset)           ; get the mapping. bits 1 and 0 hold
                        ld      d,a                                 ; .
                        or      %11111100                           ; .
                        WriteTurboControlA                          ; .
.CheckLastSeq:          ld      a,(ix+SoundLastSeqOffset)           ; get last in sequence
                        JumpIfALTNusng  (ix+0),.CompletedSFX        ; if we have gone beyond last then done
.PlayStep:              ld      a,d                                 ; Get the channel number
                        and     %00110000
                        swapnib                                     ; get channel to lower bits
                        ld      d,a
                        call    PlayChannelD                        ; play channel D step ix is pointer to correct soundchannelseq
.UpdateStep:            inc     (ix+0)                              ; next stepssss
                        IFDEF   USETIMER
.UpdateTimer:               ld      a,SOUNDSTEPLENGTH
                            ld      (ix+SoundTimerOffset),a
                        ENDIF
.UpdateStepPointer:     ld      e,(ix+SoundDataPointerOffset)       ; move pointer on by 7 bytes
                        ld      d,(ix+SoundDataPointerOffset+1)     ;
                        ex      de,hl                               ; hl = current pointer
                        ld      a,SFXBlockLength                    ; move to next block
                        add     hl,a                                ; .
                        ex      de,hl                               ; move to de for load back
                        ld      (ix+SoundDataPointerOffset),e       ;
                        ld      (ix+SoundDataPointerOffset+1),d     ;
                        ret
.CompletedSFX:          ld      a,(ix+SoundChipMapOffset)           ; channel number is in upper bits
                        swapnib                                     ; so we need it in
                        and     %00000011                           ; lower for selecting volume register
                        add     a,CHANNEL_A_AMPLITUDE               ; select the register
                        WriteTurboRegisterA 0                       ; set volume to 0
                        WriteTurboRegister ENVELOPE_PERIOD_FINE,0
                        WriteTurboRegister ENVELOPE_PERIOD_COARSE,0
                        WriteTurboRegister ENVELOPE_SHAPE,ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
                        WriteTurboRegister TONE_ENABLE,   NOISE_CHANNEL_A | NOISE_CHANNEL_B | NOISE_CHANNEL_C
                        ld      a,$FF                               ; set sequence to FF to denote
                        ld      (ix+0),a                            ; channel is now free
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

SoundLabel              DB      "Sound Channels  "
SoundChannelSeq         DS      8   ; The current step in the SFX or $FX for empty
SoundChannelLastSeq     DS      8   ; A copy of SFX length to save an extra lookup, $FF means 1 step always on, $00 means off
SoundChannelTimer       DS      8   ; The count down to next sequence
SoundDataPointer        DS      2*8 ; pointer to current sound step
;                  Channel/Chip B/1  C/1  A/2  B/2  C/2  A/3  B/3  C/3
SoundChipMapNumber      DB      $10 | TURBO_CHIP_AY1, $20 | TURBO_CHIP_AY1
                        DB      $00 | TURBO_CHIP_AY2, $10 | TURBO_CHIP_AY2 | $20 | TURBO_CHIP_AY2
                        DB      $00 | TURBO_CHIP_AY2, $10 | TURBO_CHIP_AY3 | $20 | TURBO_CHIP_AY3
SoundLastSeqOffset      EQU     8
SoundTimerOffset        EQU     SoundLastSeqOffset + 8
SoundDataPointerOffset  EQU     SoundTimerOffset + 8
SoundDataPointerOffset1 EQU     SoundTimerOffset + 9
SoundChipMapOffset      EQU     SoundDataPointerOffset + 16
;Chip map is            bits 5,4 channel letter A = 0 B =1 C = 2    1,0 Chip Number
;Mapping                0 = 1B, 1 = 1C, 3=2A, 4 = 2B, 5=2C, 6 = 3A, 7 = 3B, 8 = 3C
;                       Chip 1 Engine, noise channel but engine noise period is priority
;                       Chip 2 General FX, no noise
;                       Chip 3 General FX, no noise

;--- Data sets for Sound
;--- Sound Channels are 0 to 9 AY1 A B C AY2 A B C AY3 A B C
;--- Sounds can not enqueu, the find a free slot & SoundFxtoEnqueue gets zeroed or it gets left
;--- AY1 channel 1 is reserved for engine noise as its calculated on the fly
; Predefined value for each channel to load to $FFFD before setting up tone
; Hcops a copy of the 3 chips register 7


; StepLength            DB      1   ; $FF = 1 step forever else number of entries in StepListArray
; StepListArray
;     TonePitch         DW      4 bits unused + 12 bits
;     NoisePitch        DB      5 bit or $FF for no noise
;     Volume            DB      0 to 15
;     EnvelopePeriod    DW      0
;     WaveForm          DB      0

; SFX Format
; SFXPointerList - Odd numbers are tone, Even Numbers have noise too, optimisation for channel handling
SoundLabelSFX   DB      "Sound Data      "
SFXPointerList  dw      SFXLaser
SFXEndOfList    EQU     1
SFXBlockLength  EQU     3
SFXFineOffset   EQU     0
SFXCorseOffset  EQU     1
SFXVolOffset    EQU     2
;                       Step Count
SoundLaser      DB      "Laser  "
SFXLaser        db      11
;                       Tone
;                      Fine Crs  Vol
               db      $5F, $00, $0E
               db      $39, $00, $0E
               db      $47, $00, $0D
               db      $5E, $00, $0C
               db      $6E, $10, $0A
               db      $76, $00, $08
               db      $76, $00, $07
               db      $06, $01, $06
               db      $2E, $01, $03
               db      $16, $01, $03
               db      $03, $00, $01

;
;
;Laser1:          db 14,14,13,12,10, 8, 7, 6, 3, 1
;LaserFrameCount  db  5, 5, 5, 5, 5, 5, 5, 5, 5, 5
;LaserLength:     db $-LaserFrameCount
;LaserTone:       dw $05F, $089, $097, $0AE, $0CE, $0B6, $0E6, $106, $13E, $126, $136

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
                        ;IFDEF   DANUBEATTACK
.SetAttack:             ;    ld      hl,(DanubeAttackEnvelope)
                        ;    ld      a,ENVELOPE_PERIOD_FINE
                        ;    WriteTurboControlA
                        ;    ld      b,$BF
                        ;    ld      a,l
                        ;    out     (c),a
                        ;    ld      a,ENVELOPE_PERIOD_COARSE
                        ;    WriteTurboControlA
                        ;    ld      b,$BF
                        ;    ld      a,h
                        ;    out     (c),a
                        ;ENDIF
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
                        ;jp      z,SustainNote
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
                        ;break
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
;BlueDanube1:     DB $00, $00, $00, $00, $00, $61, $61, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $61, $61, $5B, $5B, $00, $00, $00
;BlueDanube2:     DB $00, $00, $00, $00, $00, $5A, $5A, $5A, $5A, $00, $00, $00, $00, $00, $00, $00, $00, $58, $58, $55, $55, $00, $00, $00
;BlueDanube3:     DB $00, $00, $00, $41, $41, $00, $00, $56, $56, $00, $00, $00, $00, $00, $00, $41, $41, $00, $00, $00, $00, $00, $00, $00
;BlueDanube4:     DB $36, $36, $3A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $36, $36, $3A, $00, $00, $00, $00, $00, $00, $00, $00, $00

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
