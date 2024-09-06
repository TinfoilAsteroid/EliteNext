AttractDuration            EQU $00F0
AttractCounterStart        EQU $80
AttractTimer:              DW      AttractDuration
AttractCounter:            DB      AttractCounterStart

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
                        ;ReturnIfALTNusng 254
                        ld      a,(LocalZCounter)
                        xor     $80
                        ld      (LocalZCounter),a
                        ret
                        

AttractModeInit:        MMUSelectLayer1
                        call	    l1_cls 
                        ld		    a,7
                        call	    l1_attr_cls_to_a                        
                        ld          e,$FF
                        ld          de,(Attract_boiler_text)
                        ld          hl,ATTR_LoadCommander
                        call        l1_print_at
                        MMUSelectSpriteBank    
                        call        sprite_cls_all;sprite_cls_cursors  
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


;.StartShip:             ld          a,(InterruptCounter)
;                        ld          hl,LastInterrupt
;                        cp          (hl)
;                        jp          z,.StartShip            ; we only refresh once per interupt
;                        ld          (hl),a
                        
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
                        jp      AttractModeMain
.YPressed:              ld      a,0
                        ret
.NPressed:              ld      a,$FF
                        ret

; alternate interrupts, one clears back buffer, one processes ship, one draws ship
AttractStep             DB      0

AttractModeUpdate:      MMUSelectMathsBankedFns                                 ; Need to set it on entering post interrupt to make sure we are in bank 0
                        ld      hl,(AttractTimer)
                        dec     hl
                        ld      (AttractTimer),hl
                        ld      a,h
                        or      l
                        jp      nz,.DrawShip
                        call    SelectARandomShip
                        ret
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
.PrepLines:             call    PrepLines
                        ;break
        IFDEF LATECLIPPING
.DrawLines:             call    DrawLinesLateClipping     
                        ;break
        ELSE
.DrawLines:             call    DrawLines
        ENDIF
.Drawbox:               ld		bc,$0101
                        ld		de,$7FFD
                        ld		a,$C0
                        ;break
                        MMUSelectLayer2
                        call	l2_draw_box
.DoubleBuffer:          call    l2_flip_buffers
.UpdateZPosIfReady:     ld      a,(AttractCounter)
                        ;break
                        and     a
                        jp      z,.DoneIM2
                        dec     a
                        ld      (AttractCounter),a
                        ld      hl, (UBnKzlo)
.UpdatePos:             ld      de, $0008
                        sbc     hl,de
                        ld      (UBnKzlo),hl                        
.DoneIM2:               ld      a,(AttractStep)
                        inc     a
                        cp      3
                        ld      (AttractStep),a
                        ret     nz
                        ZeroA
                        ld      (AttractStep),a
                        ;break
                        ret



SelectARandomShip:      ld      b,1                             ; Demo screen uses slot 1
                        MMUSelectUniverseN  1
                        MMUSelectShipBank1
                        ld      iyh, 1
.SelectRandom:          call    doRandom
                        JumpIfAGTENusng ShipID_Rattler+1, .SelectRandom
                        ld      iyl,a
                        call    GetShipBankId                       ; find actual memory location of data
                        MMUSelectShipBankA
                        ld      a,b
                        call    CopyShipToUniverse
                        ld      a,(ShipTypeAddr)
                        bit     7,a                                 ; is it a type we don't want in attract mode
                        jr      nz,.SelectRandom
                        ld      a,1                                 ; slot 1, iyh and iyl already set
                        call    UnivInitRuntime                       
                        call    UnivSetDemoPostion
                        ld      hl,AttractDuration*2
                        ld      (AttractTimer),hl
                        ld      a, AttractCounterStart
                        ld      (AttractCounter),a
                        ZeroA
                        ld      (AttractStep),a
                        ret
                        
                        
