AttractDuration             EQU $00F0
AttractCounterStart         EQU $80
AttractTimer:              DW      AttractDuration
AttractCounter:            DB      AttractCounterStart

Attract_boiler_text		DW $083D


ATTR_LoadCommander      DB "Load Commander (Y/N)",0

AttractMode:            MMUSelectLayer1
                        call	l1_cls 
                        ld		a,7
                        call	l1_attr_cls_to_a                        
                        ld      e,$FF
                        ld      de,(Attract_boiler_text)
                        ld      hl,ATTR_LoadCommander
                        call    l1_print_at
                        MMUSelectSpriteBank    
                        call        sprite_cls_cursors  
                        call    l2_cls_lower_third 
                        MMUSelectConsoleBank
                        ld          hl,ScreenL1Bottom       ; now the pointers are in Ubnk its easy to read
                        ld          de,ConsoleImageData
                        ld          bc, ScreenL1BottomLen
                        call        memcopy_dma
                        ld          hl,ScreenL1AttrBtm       ; now the pointers are in Ubnk its easy to read
                        ld          de,ConsoleAttributes
                        ld          bc, ScreenL1AttrBtmLen
                        call        memcopy_dma
                        MMUSelectLayer2 
                        call    asm_l2_double_buffer_on
.StartShip:             call    SelectARandomShip
.DrawLoop:              call    scan_keyboard
                        ld      a,c_Pressed_Yes
                        call    is_key_up_state
                        jr      nz,.YPressed
                        ld      a,c_Pressed_No
                        call    is_key_up_state
                        jr      nz,.NPressed
                        MMUSelectUniverseN  1
                        call    ApplyShipRollAndPitch
                     ;   xor     a
                     ;  ld      (UBnKRotXCounter),a
                     ;  ld      (UBnKRotZCounter),a
.ProcessUnivShip:       MMUSelectLayer2
                        call   l2_cls_upper_two_thirds
                        call    ProcessShip
.Drawbox:               ld		bc,$0101
                        ld		de,$7FFD
                        ld		a,$C0
                        MMUSelectLayer2
                        call	l2_draw_box
.DoubleBuffer:          call    l2_flip_buffers
                        ld      a,(AttractCounter)
                        JumpIfAIsZero .SameShipPosition
                        dec     a
                        ld      (AttractCounter),a
                        ld      hl, (UBnKzlo)
.UpdatePos:             ld      de, $0008
                        sbc     hl,de
                        ld      (UBnKzlo),hl
                        call    doRandom
.SameShipPosition:      ld      hl,(AttractTimer)
                        dec     hl
                        ld      (AttractTimer),hl
                        ld      a,h
                        or      l
                        jr      nz,.DrawLoop
.NewShip:               ld      hl,AttractDuration
                        ld      (AttractTimer),hl
                        jp      .StartShip
.YPressed:              ld      a,0
                        ret
.NPressed:              ld      a,$FF
                        ret
.ExitAttractMode:       break

SelectARandomShip:      ld      b,1                             ; Demo screen uses slot 1
                        MMUSelectUniverseN  1
                        MMUSelectShipBank1
.SelectRandom:          call    doRandom
                        JumpIfAGTENusng ShipID_Rattler+1, .SelectRandom
                        call    GetShipBankId                       ; find actual memory location of data
                        MMUSelectShipBankA
                        ld      a,b
                        call    CopyShipToUniverse
                        ld      a,(ShipTypeAddr)
                        bit     7,a                                 ; is it a type we don't want in attract mode
                        jr      nz,.SelectRandom
                        call    UnivInitRuntime                       
                        call    UnivSetDemoPostion
                        ld      hl,AttractDuration
                        ld      (AttractTimer),hl
                        ld      a, AttractCounterStart
                        ld      (AttractCounter),a
                        ret
                        
                        
