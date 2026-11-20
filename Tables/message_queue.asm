
                        
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

; The hyperspace countdown text (main loop, while a view is up and either counting or the text is still showing): drawn
; every loop from the seconds left now (HyperSpaceTick does the timing), cleared once when the count stops (H again,
; docking). The two lines are only cleared when the text first appears, so redrawing it doesn't flicker
HyperSpaceMessage:      MMUSelectLayer1                 ; We are using Layer 1
                        ld      a,(InnerHyperCount)     ; stopped: clear the text
                        and     a
                        jp      z,.ClearText
.DisplayHyperCountDown: ld      de,Hyp_to               ; Sort out destination
                        ld      hl,name_expanded
                        ldCopyTextAtHLtoDE
.DoneName:              xor     a
                        ld      (de),a
                        ld      (Hyp_message+31),a      ; max out at 32 characters
.CentreJustify:         ld      hl,Hyp_message          ; Center justify
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
                        call    UpdateCountdownNumber    ; Update count down
                        ld      hl,Hyp_counter           ; leading zeros as spaces (keeps the width, so
                        ld      a,(hl)                   ; printing over the last loop's text is enough)
                        cp      '0'
                        jr      nz,.CounterDone
                        ld      (hl),' '
                        inc     hl
                        ld      a,(hl)
                        cp      '0'
                        jr      nz,.CounterDone
                        ld      (hl),' '
.CounterDone:
                        ld      hl,Hyp_charging
                        HalfLengthHL
                        ld      hl,Hyp_centeredCharging  
                        ldClearTextLoop 32
                        ex      de,hl
                        ld      hl,Hyp_charging
                        ldCopyTextAtHLtoDE
                        xor     a
                        ld      (Hyp_centeredEol2),a
.ShowText:              ld      d,12                    ; yellow on black (every loop, in case the attributes were reset)
                        ld      a,L1ColourPaperBlack | L1ColourInkYellow
                        call    l1_attr_cls_2DlinesA
                        ld      a,(HyperTextOnScreen)   ; clear the lines when it first appears
                        and     a
                        jr      nz,.PrintText
                        inc     a
                        ld      (HyperTextOnScreen),a
                        ld      d,12 * 8
                        call    l1_cls_2_lines_d
.PrintText:             ld      de,$6000                ; the lines are full width, so printing over them is enough
                        ld      hl,Hyp_centeredTarget
                        call    l1_print_at
                        ld      de,$6800
                        ld      hl,Hyp_centeredCharging
                        call    l1_print_at
                        ret
.ClearText:             ld      (HyperTextOnScreen),a   ; (a = 0)
                        ld      d,12
                        ld      a,L1ColourPaperBlack | L1ColourInkBlack
                        call    l1_attr_cls_2DlinesA
                        ld      d,12 * 8
                        call    l1_cls_2_lines_d
                        ret                   
