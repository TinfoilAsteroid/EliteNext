
;-------------------------------------------------------------------------------------------------
;--- Equates for sounds
;       DEFINE          USETIMER 1
                        IFDEF   USETIMER
SOUNDSTEPLENGTH             EQU     25
                        ENDIF
ChipChannelSettings     DS      3
  

WriteTurboControlA:     MACRO   
                        ld      bc,TURBO_SOUND_NEXT_CONTROL
                        out     (c),a
                        ENDM
                        
WriteTurboRegisterA:    MACRO   value
                        ld      bc,TURBO_SOUND_NEXT_CONTROL
                        out     (c),a
                        ;ld      b,$BF
                        ld      bc,SOUND_CHIP_REGISTER_WRITE
                        ld      a,value
                        out     (c),a
                        ENDM
                        
WriteTurboRegister:     MACRO   register,value
                        ld      bc,TURBO_SOUND_NEXT_CONTROL
                        ld      a,register
                        out     (c),a
                        ;ld      b,$BF
                        ld      bc,SOUND_CHIP_REGISTER_WRITE
                        ld      a,value
                        out     (c),a
                        ENDM


WriteAToTurboRegister:  MACRO   register
                        ex      af,af'
                        ld      bc,TURBO_SOUND_NEXT_CONTROL
                        ld      a,register
                        out     (c),a
                        ;ld      b, $BF;
                        ld      bc,SOUND_CHIP_REGISTER_WRITE
                        ex      af,af'
                        out     (c),a
                        ENDM

SelectAY:               MACRO   chipNbr
                        ld      a,TURBO_MANDATORY | TURBO_LEFT | TURBO_RIGHT | chipNbr
                        WriteTurboControlA
                        ENDM

DefaultAYChip:          WriteTurboRegister CHANNEL_A_AMPLITUDE, $00
                        WriteTurboRegister CHANNEL_B_AMPLITUDE, $00
                        WriteTurboRegister CHANNEL_C_AMPLITUDE, $00
                        WriteTurboRegister NOISE_PERIOD,0
                        WriteTurboRegister ENVELOPE_PERIOD_FINE,0
                        WriteTurboRegister ENVELOPE_PERIOD_COARSE,0
                        WriteTurboRegister ENVELOPE_SHAPE,ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
                        ret
;-- Initialise Audio channels to AY1 noise, AY2 and 3 tone, all channels to volume 0

InitAudio:              ;break
                        SelectAY TURBO_CHIP_AY1
                        call    DefaultAYChip
                        ; still have chip mapping issue
                        WriteTurboRegister TONE_ENABLE,   NOISE_CHANNEL_A | NOISE_CHANNEL_B | NOISE_CHANNEL_C
                        SelectAY TURBO_CHIP_AY2
                        WriteTurboRegister TONE_ENABLE,   NOISE_CHANNEL_A | NOISE_CHANNEL_B | NOISE_CHANNEL_C
                        call    DefaultAYChip
                        SelectAY TURBO_CHIP_AY3
                        WriteTurboRegister TONE_ENABLE,   NOISE_CHANNEL_A | NOISE_CHANNEL_B | NOISE_CHANNEL_C
                        call    DefaultAYChip
                        
                        ld      hl,ChipChannelSettings          ; set local copy of tone
                        ld      (hl),0                          ; to all enabled
                        inc     hl                              ;
                        ld      (hl),0                          ;
                        inc     hl                              ;
                        ld      (hl),0                          ;
                        
                        ld      hl,SoundChannelSeq
                        ld      a,$FF
                        ld      b,8
.InitLoop:              ld      (hl),a
                        inc     hl
                        djnz    .InitLoop
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
PlayChannelD:           ld      a,(ix+SoundDataPointerOffset)    ; set hl to current data block
                        ld      l,a                              ; for SFX step
                        ld      a,(ix+SoundDataPointerOffset1)   ;
                        ld      h,a   
                        ld      a,(hl)
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
EnqueSound:            ; break
                        ld      a,(SoundFxToEnqueue)                ; Get Sound FX to Enque
                        JumpIfAGTENusng SFXEndOfList, .InvalidSound ; Invalid sounds get discarded quickly
.GetSoundData:          ld      e,a                                 ; save SoundFxToEnqeue
                        and     $01                                 ; even numbers are tone only (Including 0)
                        jr      nz,.FindFreeNoiseChannel         
.FindFreeToneChannel:   ld      hl,SoundChannelSeq + 2
                        ld      d,$FF                               ; d = marker for free slot cp d will be faster in the loop
                        ld      c,2                                 ; c= current slot
                        ld      b,7                                 ; b = nbr of slots
.ToneScanLoop:          ld      a,(hl)
                        cp      d
                        jr      z,.SaveSoundId
                        inc     c                                   ; c is hunting for a free channel
                        inc     hl                                  ; move tonext address in channel list
                        djnz    .ToneScanLoop
.NoFreeSlot:            ret
.FindFreeNoiseChannel:  ld      hl,SoundChannelSeq                  ; We onyl have 2 noise channels so no need to
                        ld      c,0                                 ; do a complex loop
                        ld      a,(hl)
                        ld      d,$FF                               ; d = marker for free slot
                        cp      d
                        jr      z,.SaveSoundId
                        inc     hl
                        ld      a,(hl)
                        cp      d
.NoNoiseSlot:           ret     nz
.NoiseChannel2:         ld      c,1                        
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
                        ld      (ix+SoundLastSeqOffset),a                            ; load SoundChannelLastSeq[channel]
                        IFDEF   USETIMER
                            
                            ld      a,1                                 ; for now we have separate timers, we enque with 1 so the loops starts immediatly
                            ld      (ix+SoundTimerOffset),a             ; load SoundChannelTimer[channel] with duration
                        ENDIF
                        inc     hl                                  ; move hl to first byte of data block
                        ld      (ix+SoundDataPointerOffset),l       ; load SoundDataPointer[channel] with current data set
                        ld      (ix+SoundDataPointerOffset1),h
.InvalidSound:          ld      a,$FF           
                        ld      (SoundFxToEnqueue),a                ; ClearFXEnqeue
                        ret

PlaySound:              ;break
                        ld      e,a                                 ; save channel number
                        SetIXToChannelA                             ; We trap for debugging
.GetCurrentSeq:         ld      a,(ix+0)                            ; for optimisation we 
                        cp      $FF                                 ; will never call this if its $FF
                        ret     z
;--- Play Next Step, we select chip, select channel, set up tone then step, timer & pointer
.SelectChip             ld      a,(ix+SoundChipMapOffset)           ; get the mapping. bits 1 and 0 hold
                        ld      d,a                                 ; .
                        or      %11111100                           ; .
                        WriteTurboControlA                          ; .
.CheckLastSeq:          ld      a,(ix+SoundLastSeqOffset)           ; get last in sequence
                        JumpIfALTNusng  (ix+0),.CompletedSFX             ; if we have gone beyond last then done                        
.PlayStep:              ld      a,d                                 ; Get the channel number
                        and     %00110000 
                        swapnib                                     ; get channel to lower bits
                        ld      d,a
                        call    PlayChannelD                        ; play channel D step ix is pointer to correct soundchannelseq
.UpdateStep:            inc     (ix+0)
                        IFDEF   USETIMER
.UpdateTimer:           ld      a,SOUNDSTEPLENGTH
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
.CompletedSFX:          ;break
                       ; SelectAY TURBO_CHIP_AY2
                        ld      a,(ix+SoundChipMapOffset)           ; channel number is in upper bits
                        swapnib                                     ; so we need it in 
                        and     %00000011                           ; lower for selecting volume register
                        add     a,CHANNEL_A_AMPLITUDE             ; select the register
                        WriteTurboRegisterA 0                       ; set volume to 0
                        ld      a,$FF
                        ld      (ix+0),a                            ; close off that channel
                        ret

;SetTone:                ;break
;                       ld      hl,TonesPitch
;                       add     a,a
;                       add     hl,a
;                       ld      a,(hl)
;                       
;                       WriteAToTurboRegister CHANNEL_A_COARSE
;                       inc     hl
;                       ld      a,(hl)
;                       WriteAToTurboRegister CHANNEL_A_FINE
;                       ret
                        

SetEngineTone:          ld      a,(DELTA)
                        ld      hl,$08EB
                        ld      d,a
                        ld      e,15
                        mul
                        sub     hl,de
                        ld      a,h
                        WriteAToTurboRegister CHANNEL_A_COARSE                      
                        ld      a,l
                        WriteAToTurboRegister CHANNEL_A_FINE
                        ret




; Engine Sound is always a priority
UpdateEngineSound:      call    SetEngineTone
.NoisePitch:            ld      a,(DELTA)
                        ld      hl,EngineNoise
                        add     hl,a
                        ld      a,(hl)
                        WriteAToTurboRegister   NOISE_PERIOD
                        WriteTurboRegister      ENVELOPE_PERIOD_COARSE,0
                        WriteTurboRegister      ENVELOPE_PERIOD_FINE,0
                        WriteTurboRegister      ENVELOPE_SHAPE, ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
                        ld      a,(DELTA)
                        sra     a
                        ld      hl,EngineVolume
                        add     hl,a
                        ld      a,(hl)
                        WriteAToTurboRegister CHANNEL_A_AMPLITUDE
                        WriteTurboRegister TONE_ENABLE, TONE_CHANNEL_B | TONE_CHANNEL_C |NOISE_CHANNEL_B| NOISE_CHANNEL_C
                        ret
;                    00   01   02   03   04   05   06   07   08   09   10
EngineNoise:     db $1F, $1F, $1F, $1F, $1E, $1E, $1E, $1E, $1D, $1D, $1D
                 db $1D, $1C, $1C, $1C, $1C, $1D, $1D, $1D, $1D, $1D, $1D 

EngineVolume:    db 0, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6
                               ; 0123456789ABCDEF
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
;                      Fine Crs  Nois Vol 

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

       ;       db      $5F, $00, $00, $0E, $00, $00, ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
       ;       db      $89, $00, $00, $0E, $00, $00, ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
       ;       db      $97, $00, $00, $0D, $00, $00, ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
       ;       db      $AE, $00, $00, $0C, $00, $00, ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
       ;       db      $CE, $00, $00, $0A, $00, $00, ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
       ;       db      $B6, $00, $00, $08, $00, $00, ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
       ;       db      $B6, $00, $00, $08, $00, $00, ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
       ;       db      $E6, $00, $00, $07, $00, $00, ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
       ;       db      $06, $01, $00, $06, $00, $00, ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
       ;       db      $3E, $01, $00, $03, $00, $00, ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
       ;       db      $26, $01, $00, $03, $00, $00, ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD
       ;       db      $13, $00, $00, $01, $00, $00, ENVELOPE_SHAPE_SINGLE_ATTACK_HOLD

;
;
;Laser1:          db 14,14,13,12,10, 8, 7, 6, 3, 1
;LaserFrameCount  db  5, 5, 5, 5, 5, 5, 5, 5, 5, 5
;LaserLength:     db $-LaserFrameCount
;LaserTone:       dw $05F, $089, $097, $0AE, $0CE, $0B6, $0E6, $106, $13E, $126, $136

                 
;TonesPitch       db $1F, $C8   
;                 db $1E, $00
;                 db $1D, $90   
;                 db $0D, $5D
;                 db $0C, $9C
;                 db $0B, $E7
;                 db $0B, $3C
;                 db $0A, $9B
;                 db $0A, $02
;                 db $09, $73
;                 db $08, $EB
;                 db $08, $6B
;                 db $07, $F2
;                 db $07, $80
;                 db $07, $64
;                 db $06, $AE
;                 db $06, $4E
;                 db $05, $F3
;                 db $05, $9E
;                 db $05, $4D
;                 db $05, $01
;                 db $04, $B9
;                 db $04, $75
;                 db $04, $35
;                 db $03, $F9
;                 db $03, $C0
;                 db $03, $B2
;                 db $03, $57
;                 db $03, $27
;                 db $02, $F9
;                 db $02, $CF
;                 db $02, $A6
;                 db $02, $80
;                 db $02, $5C
;                 db $02, $3A
;                 db $02, $1A
;                 db $01, $FC
;                 db $01, $E0
;                 db $01, $D9
;                 db $01, $AB
;                 db $01, $93
;                 db $01, $7C
;                 db $01, $67
;                 db $01, $53
;                 db $01, $40
;                 db $01, $2E
;                 db $01, $1D
;                 db $01, $0D
;                 db $00, $FE
;                 db $00, $F0
;                 db $00, $EC
;                 db $00, $D5
;                 db $00, $C9
;                 db $00, $BE
;                 db $00, $B3
;                 db $00, $A9
;                 db $00, $A0
;                 db $00, $97
;                 db $00, $8E
;                 db $00, $86
;                 db $00, $7F
;                 db $00, $78
;                 db $00, $76

