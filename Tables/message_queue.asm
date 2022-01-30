
                        
ResetMessageQueue:      ZeroA
                        ld      (MessageCount),a
                        ld      (MessageCurrent),a
                        ld      hl,MessageQueue
                        ld      de,MessageIndex
                        ld      b,5
.ClearMessageIndexs:    ld      a,l                                 ; Wipe out the indexes to all the data
                        ld      (de),a                              ; 
                        inc     de                                  ;
                        ld      a,h                                 ;
                        ld      (de),a                              ;
                        inc     de                                  ;
                        ld      a,MESSAGESIZE                       ;
                        add     hl,a                                ;
                        djnz    .ClearMessageIndexs                 ;
.ClearText:             ld      hl,MessageQueue
                        ld      de,(MAXMESSAGES * MESSAGESIZE) + MAXMESSAGES    ; MessageQueue + MessageTimeout
                        ld      a,0
                        call	memfill_dma
                        ret

; Message to enqeue is a string held at DE that must be terminated in \0
;                                       IYH = timer for message
EnqueMessage:           ld      a,(MessageCount)                    ; Maximum message count check
                        ReturnIfAGTENusng    MAXMESSAGES            ; we do not enque if queue is full
                        inc     a
                        ld      (MessageCount),a                    ; get ready for next message
.AddMessage:            ld      c,a
                        ld      a,(MessageCurrent)                  ; a = current message id + count + 1
                        add     c                                   ;
                        JumpIfALTNusng MAXMESSAGES, .ReadyToAdd     ; a = a modulus 5 (note we can only hit 5 messages
.CircularQueue:         sub     MAXMESSAGES                         ; so only need 1 cycle of modulus
.ReadyToAdd:            ld      hl,MessageTimeout                   ; write out message display time
                        add     hl,a                                ; as some may be brief messages
                        ld      c,a                                 ;
                        ld      a,iyh                               ;
                        ld      (hl),a                              ;
                        ld      a,c                                 ; get back index
                        ld      hl,MessageIndex
                        HLEquAddrAtHLPlusA                          ; hl = target location for message
                        ex      de,hl                               ; de = destination, hl = message
                        ldCopyTextAtHLtoDE                          ; copy over text as we have done the rest
                        ret
                        
UpdateMessageTimer:     ld      a,(MessageCurrent)
                        ld      hl,MessageTimeout
                        add     hl,a
                        ld      a,(hl)
                        dec     a
                        jr      z,.UpdateQueue
.UpdateTimer            ld      (hl),a
                        ret
.UpdateQueue:           ld      (hl),a
                        ld      hl,MessageCount
                        dec     (hl)
                        ld      a,(MessageCurrent)
                        inc     hl
                        JumpIfALTNusng MAXMESSAGES, .ReadyToUpdate
.CircularQueue:         ZeroA
.ReadyToUpdate          ld      (MessageCurrent),a                        
                        ret

DisplayCurrentMessage:  ld      a,(MessageCount)
                        ReturnIfAIsZero
                        ld      a,(MessageCurrent)
                        ld      hl,MessageIndex
                        HLEquAddrAtHLPlusA
                        MMUSelectLayer1
                        ld      de,MESSAGELINE
                        call    l1_print_at_wrap
                        ret

HyperSpaceMessage:      MMUSelectLayer1
.DisplayHyperCountDown: ld      de,Hyp_to
                        ld      hl,name_expanded
                        ldCopyTextAtHLtoDE
.DoneName:              xor     a
                        ld      (de),a
                        ld      (Hyp_message+31),a      ; max out at 32 characters
.CentreJustify:         ld      hl,Hyp_message
                        HalfLengthHL
                        ld      hl,Hyp_centeredTarget
                        ldClearTextLoop 32
                        ex      de,hl
                        ld      hl,Hyp_message
                        ldCopyTextAtHLtoDE
                        ZeroA
                        ld      (Hyp_centeredEol),a
                        ld      hl,Hyp_counter           ; clear counter digits
                        ld      a,32                     ; clear counter digits
                        ld      (hl),a                   ; clear counter digits
                        inc     hl                       ; clear counter digits
                        ld      (hl),a                   ; clear counter digits
                        inc     hl                       ; clear counter digits
                        ld      (hl),a                   ; clear counter digits
                        call    UpdateCountdownNumber
                        ld      hl,Hyp_charging
                        HalfLengthHL
                        ld      hl,Hyp_centeredCharging
                        ldClearTextLoop 32
                        ex      de,hl
                        ld      hl,Hyp_charging
                        ldCopyTextAtHLtoDE
                        xor     a
                        ld      (Hyp_centeredEol2),a
.UpdateHyperCountdown:  ld      hl,(InnerHyperCount)
                        dec     l
                        jr      nz,.decHyperInnerOnly
                        dec     h
                        ret     m
.resetHyperInner:       ld      l,$0B
                        push    hl
                        ld      d,12
                        ld      a,L1ColourPaperBlack | L1ColourInkYellow
                        call    l1_attr_cls_2DlinesA
                        ld      d,12 * 8
                        call    l1_cls_2_lines_d
                        ld      de,$6000
                        ld      hl,Hyp_centeredTarget
                        call    l1_print_at
                        ld      de,$6800
                        ld      hl,Hyp_centeredCharging
                        call    l1_print_at
                        pop     hl
.decHyperInnerOnly:     ld      (InnerHyperCount),hl
                        ret
.HyperCountDone:        ld      hl,0
                        ld      (InnerHyperCount),hl
                        ld      d,12
                        ld      a,L1ColourPaperBlack | L1ColourInkBlack
                        call    l1_attr_cls_2DlinesA
                        ld      d,12 * 8
                        call    l1_cls_2_lines_d
                        ForceTransition ScreenHyperspace                            ; transition to hyperspace
                        ret                   
