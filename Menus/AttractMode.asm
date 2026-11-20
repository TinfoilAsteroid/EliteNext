AttractDuration            EQU $00F0
AttractCounterStart        EQU $80
AttractTimer:              DW      AttractDuration
AttractCounter:            DB      AttractCounterStart

       ; DEFINE DEBUGBACKFACE 1 This stops the ship moving forward, so you can see the backface culling in action

Attract_boiler_text		DW $083D


ATTR_LoadCommander      DB "Load Commander (Y/N)",0

LocalXCounter           DB $FF
LocalZCounter           DB $FF
LastInterrupt           DB 0

RandomXCounter:         call    doRandom
                        ret     nz
                        ld      a,(LocalXCounter)
                        xor     $80
                        ld      (LocalXCounter),a
                        ret

RandomYCounter:         call    doRandom
                        ret     nz
                        ld      a,(LocalZCounter)
                        xor     $80
                        ld      (LocalZCounter),a
                        ret
                        

AttractModeInit:        MMUSelectLayer1
                        call	    l1_cls                  ; Clear layer 1
                        ld		    a,L1ColourInkWhite      ; set attr 1 to inkw white paper black
                        call	    l1_attr_cls_to_a                        
                        ld          e,$FF
                        ld          de,(Attract_boiler_text)
                        ld          hl,ATTR_LoadCommander
                        call        l1_print_at
                        MMUSelectSpriteBank    
                        call        sprite_cls_all          ;sprite_cls_cursors  
.ClearLayer2:           MMUSelectLayer2 
                        call        asm_l2_double_buffer_on
                        call        l2_cls     
                        call        l2_flip_buffers
                        call        l2_cls     
                        MMUSelectConsoleBank
.LoadConsole:           ld          hl,ScreenL1Bottom       ; now the pointers are in Ubnk its easy to read
                        ld          de,ConsoleImageData
                        ld          bc, ScreenL1BottomLen
                        call        memcopy_dma
                        ld          hl,ScreenL1AttrBtm       ; now the pointers are in Ubnk its easy to read
                        ld          de,ConsoleAttributes
                        ld          bc, ScreenL1AttrBtmLen
                        call        memcopy_dma
                        ld          a,(InterruptCounter)
                        ld          (LastInterrupt),a
                        call        SelectARandomShip
                        ret


AttractModeMain:        MMUSelectKeyboard
                        call    scan_keyboard
                        ld      a,c_Pressed_Yes
                        MMUSelectKeyboard
                        call    is_key_up_state
                        jr      nz,.YPressed
                        ld      a,c_Pressed_No
                        MMUSelectKeyboard
                        call    is_key_up_state
                        jr      nz,.NPressed
                    IFDEF MANUAL_ATTRACT
                        ld      a,VK_F                          ; F: the next model, B: the previous (one a press;
                        MMUSelectKeyboard                       ; the interrupt makes the change between frames)
                        call    is_vkey_pressed
                        ld      a,1
                        jr      z,.Request
                        ld      a,VK_B
                        call    is_vkey_pressed
                        jp      nz,AttractModeMain
                        ld      a,$FF
.Request:               ld      (AttractRequest),a
                    ENDIF
                        jp      AttractModeMain
.YPressed:              ld      a,0
                        ret
.NPressed:              ld      a,$FF
                        ret

; alternate interrupts, one clears back buffer, one processes ship, one draws ship
AttractStep             DB      0

AttractModeUpdate:      MMUSelectMathsBankedFns                                 ; Need to set it on entering post interrupt to make sure we are in bank 0
                    IFDEF MANUAL_ATTRACT
                        ld      a,(AttractStep)                 ; never cycles itself: F / B (AttractModeMain) ask for
                        and     a                               ; the next / previous model, taken here at the start
                        jp      nz,.DrawShip                    ; of a frame so its 3 steps are all one model
                        ld      a,(AttractRequest)
                        and     a
                        jp      z,.DrawShip
                        ld      c,a
                        xor     a
                        ld      (AttractRequest),a
                        ld      a,(AttractShipId)               ; + 1 or - 1, wrapping round every model
                        add     a,c
                        cp      ShipTotalModelCount
                        jr      c,.IdOK
                        ld      a,ShipTotalModelCount-1         ; (below 0: the last)
                        bit     7,c
                        jr      nz,.IdOK
                        xor     a                               ; (past the last: the first)
.IdOK:                  ld      (AttractShipId),a
                        call    SelectARandomShip
                        ret
                    ELSE
                        ld      hl,(AttractTimer)
                        dec     hl
                        ld      (AttractTimer),hl
                        ld      a,h
                        or      l
                        jp      nz,.DrawShip
                        call    SelectARandomShip
                        ret
                    ENDIF
.DrawShip:              ;BREAK
.RandomRotateShip:      call    doRandom
                        MMUSelectUniverseN  1
                        ld      a,(AttractStep)
                        and     a       ; 0
                        jp      z,.ApplyShipRollAndPitch
                        dec     a       ; 1
                        jp      z,.ProcessNodes
                        jp      .PrepLines ; 2
 
.ApplyShipRollAndPitch: call    ApplyShipRollAndPitch
                        call    RandomXCounter
                        call    RandomYCounter
                        ld      a,(LocalXCounter)
                        ld      (UBnKRotXCounter),a
                        ld      a,(LocalZCounter)
                        ld      (UBnKRotZCounter),a
.ClearScreen:           MMUSelectLayer2
                        call    l2_cls_upper_two_thirds
                        jp      .DoneIM2
.ProcessNodes:          call    ProcessNodes
.CullV2:                call    CullV2
                        jp      .DoneIM2
.PrepLines:
        IFDEF SOLID_HULL
                        MMUSelectLayer2
                        call    SolidHullDraw                   ; filled, as in flight (the nodes and visible faces are
                        jr      c,.Drawbox                      ; from the last step); else the wireframe
        ENDIF
                        call    PrepLines
        IFDEF LATECLIPPING
.DrawLines:             call    DrawLinesLateClipping     
        ELSE
.DrawLines:             call    DrawLines
        ENDIF
.Drawbox:               ld		bc,$0101
                        ld		de,$7FFD
                        ld		a,$C0
                        MMUSelectLayer2
                        call	l2_draw_box
.DoubleBuffer:          call    l2_flip_buffers
.UpdateZPosIfReady:     ld      a,(AttractCounter)
                        and     a
                        jp      z,.DoneIM2
                    IFDEF DEBUGBACKFACE
                        nop
                    ELSE                        
                        dec     a
                        ld      (AttractCounter),a
                        ld      hl, (UBnKzlo)
.UpdatePos:             ld      de, $0008
                        sbc     hl,de
                        ld      (UBnKzlo),hl      
                    ENDIF                  
.DoneIM2:               ld      a,(AttractStep)
                        inc     a
                        cp      3
                        ld      (AttractStep),a
                        ret     nz
                        ZeroA
                        ld      (AttractStep),a
                        ret


SelectARandomShip:      ld      b,1                             ; Demo screen uses slot 1
                        MMUSelectUniverseN  1
                        MMUSelectShipBank1
                        ld      iyh, 1
.SelectRandom:
                    IFDEF MANUAL_ATTRACT
                        ld      a,(AttractShipId)               ; the model F / B chose: every model, none skipped
                    ELSE
                    IFDEF DEBUGBACKFACE
                        ld      a,ShipID_Coriolis               ; always the Coriolis station to debug backface culling
                    ELSE
                        call    doRandom
                        JumpIfAGTENusng ShipID_Rattler+1, .SelectRandom
                    ENDIF
                    ENDIF
                        ld      iyl,a
                        call    GetShipBankId                       ; find actual memory location of data
                        MMUSelectShipBankA
                        ld      a,b
                        call    CopyShipToUniverse
                    IFNDEF MANUAL_ATTRACT
                        ld      a,(ShipTypeAddr)
                        bit     7,a                                 ; is it a type we don't want in attract mode
                        jr      nz,.SelectRandom
                    ENDIF
                        ld      a,1                                 ; slot 1, iyh and iyl already set
                        call    UnivInitRuntime
                        call    UnivSetDemoPostion
                    IFDEF MANUAL_ATTRACT
                        call    AttractShowName
                    ENDIF
                        ld      hl,AttractDuration*2
                        ld      (AttractTimer),hl
                        ld      a, AttractCounterStart
                        ld      (AttractCounter),a
                        ZeroA
                        ld      (AttractStep),a
                        ret

    IFDEF MANUAL_ATTRACT
; MANUAL_ATTRACT (eliteNext.asm): the attract screen shows one model at a time, F the next, B the previous, with its
; name at the top of the HUD (the console's top row, between the gauges). The name is the universe bank's
; StartOfUnivName (16 characters, space padded, from the ship names table when the model was copied in), centred, with
; _ shown as a space
AttractShipId           DB      0                               ; the model shown
AttractRequest          DB      0                               ; from the key loop: 1 next, $FF previous, 0 none
AttractNameCols         equ     16
AttractNameRow          equ     16                              ; character row (the console's top)
AttractNameCol          equ     8                               ; character column (centred between the gauges)
AttractNameText         DS      AttractNameCols + 1

AttractShowName:        ld      hl,AttractNameText              ; spaces, then the name centred in them
                        ld      b,AttractNameCols
.Blank:                 ld      (hl)," "
                        inc     hl
                        djnz    .Blank
                        ld      (hl),0
                        ld      hl,StartOfUnivName+AttractNameCols  ; its length: up to the last non space
                        ld      b,AttractNameCols
.Length:                dec     hl
                        ld      a,(hl)
                        cp      " "+1
                        jr      nc,.GotLength
                        djnz    .Length
.GotLength:             ld      a,AttractNameCols               ; start = (16 - length) / 2
                        sub     b
                        srl     a
                        ld      de,AttractNameText
                        add     de,a
                        ld      hl,StartOfUnivName
                        ld      a,b
                        and     a
                        jr      z,.Copied
.Copy:                  ld      a,(hl)
                        cp      "_"
                        jr      nz,.NotUnderscore
                        ld      a," "
.NotUnderscore:         ld      (de),a
                        inc     hl
                        inc     de
                        djnz    .Copy
.Copied:                ld      hl,ScreenL1AttrBtm+(AttractNameRow-16)*32+AttractNameCol
                        ld      b,AttractNameCols               ; visible there (the console leaves it black on black)
.Attr:                  ld      (hl),L1ColourPaperBlack | L1ColourInkYellow
                        inc     hl
                        djnz    .Attr
                        MMUSelectLayer1
                        ld      d,AttractNameRow*8
                        ld      e,AttractNameCol*8
                        ld      hl,AttractNameText
                        jp      l1_print_at
    ENDIF


