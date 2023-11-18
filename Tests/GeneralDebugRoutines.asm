            IFDEF DEBUGPLANET
DebugPlanetCode:        MMUSelectPlanet
                        call    CreatePlanet
                        ld      a,0
                        ld      (P_BnKzsgn),a
                        ld      (P_BnKxsgn),a
                        ld      (P_BnKysgn),a
                        ld      hl,$0200
                        ld      (P_BnKzlo),hl
                        ld      hl,$00000
                        ld      (P_BnKxlo),hl
                        ld      (P_BnKylo),hl
                        ld      a,127
                        ld      (UBnKRotXCounter),a
                        ld      (UBnKRotZCounter),a
                        ;break
.PlanetDebugLoop:       MMUSelectPlanet
                        call    PlanetDraw
                        ; Planets don't have pitch and roll so not needed       call    ApplyPlanetRollAndPitch
                        ; call    P_NormaliseRotMat
                        ;call    ApplyPlanetPitch
                        
                        ;MMUSelectKeyboard
                        ;call        WaitForAnyKey 
                        ;break                        
                        MMUSelectLayer2
                        call		l2_cls
                        jp          .PlanetDebugLoop
            ENDIF
            IFDEF DEBUGPLANETCIRCLE
DebugPlanetCode:        MMUSelectPlanet
                        call    CreatePlanet
                        ld      a,0
                        ld      (P_BnKzsgn),a
                        ld      (P_BnKxsgn),a
                        ld      (P_BnKysgn),a
                        ld      hl,$0200
                        ld      (P_BnKzlo),hl
                        ld      hl,$00000
                        ld      (P_BnKxlo),hl
                        ld      (P_BnKylo),hl
                        ld      a,127
                        ld      (UBnKRotXCounter),a
                        ld      (UBnKRotZCounter),a
                        ;break
.PlanetDebugLoop:       MMUSelectPlanet
                        call    PlanetDraw
                        ; Planets don't have pitch and roll so not needed       call    ApplyPlanetRollAndPitch
                        ; call    P_NormaliseRotMat
                        ;call    ApplyPlanetPitch
                        
                        ;MMUSelectKeyboard
                        ;call        WaitForAnyKey 
                        ;break                        
                        MMUSelectLayer2
                        call		l2_cls
                        jp          .PlanetDebugLoop
            ENDIF
            
            IFDEF DEBUGLINEDRAW
RenderDiagnostics:      MMUSelectLayer2
                        ld      h, 0
                        ld      l, 0
                        ld      d,0
                        ld      e,255
                        ld      ixl,16
                        ld      a,$C5
                        ld      (line_gfx_colour),a
                        ; draw a grid
.horizontalLoop:        push    hl,,de,,ix
                        call    LineHLtoDE
                        pop     hl,,de,,ix
                        ld      a,h
                        add     8
                        ld      h,a
                        ld      d,a
                        dec     ixl
                        jr      nz,.horizontalLoop
.verticalGrid:          ld      h, 0
                        ld      l, 0
                        ld      d, 127
                        ld      e,0
                        ld  ixl,32
                        ld      a,$C6
                        ld      (line_gfx_colour),a
.verticalLoop:          push    hl,,de,,ix
                        call    LineHLtoDE
                        pop     hl,,de,,ix
                        ld      a,l
                        add     8
                        ld      l,a
                        ld      e,a
                        dec     ixl
                        jr      nz,.verticalLoop
                        ld      a,$A6
                        ld      (line_gfx_colour),a
                        ld      hl,0
                        ld      de,$7FFF
                        call    LineHLtoDE
                        ld      hl,$00FF
                        ld      de,$7F00
                        call    LineHLtoDE
                        ld      a,0
                        MMUSelectUniverseA
                        ; CLip -10,-10 to 20,30
                        ld      a,$56
                        ld      (line_gfx_colour),a
                        ;break
.LineTest1:             ld      hl, DrawTestDataLine1
                        call    DrawClippedLineDebug
.LineTest2:             ld      hl, DrawTestDataLine2
                        call    DrawClippedLineDebug
.LineTest3:             ld      hl, DrawTestDataLine3
                        call    DrawClippedLineDebug
.LineTest4:             ld      hl, DrawTestDataLine4
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine5
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine6
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine7
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine8
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine9
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine10
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine11
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine12
                        call    DrawClippedLineDebug
                        ld      a,$A8
                        ld      (line_gfx_colour),a                        
                        ld      hl, DrawTestDataLine13
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine14
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine15
                        call    DrawClippedLineDebug
                        ld      hl, DrawTestDataLine16
                        call    DrawClippedLineDebug
                        ;break
                        ; draw diagonals on screen tL br, tr bl
                        ; draw diagonals on screen bl tr, br tl
                        ; draw clipped horzontals left clip from -1000 -10 to 50
                        ; draw clipped horzontals right clip from 200 to 260 to +1000
                        ; draw clipped horzontals both clip from -1000 -10 to 260 to 1000
                        ; draw clipped horzontals top clip from -1000 -10 to 50
                        ; draw clipped horzontals bottom clip from 200 to 260 to +1000
                        ; draw clipped horzontals both clip from -1000 -10 to 260 to 1000
                        ; draw diagonal left clip
                        ; draw diagonal right clip
                        ; draw diagonal top clip
                        ; draw diagonal bottom clip
                        ; draw diagonal left top clip
                        ; draw diagonal right top clip
                        ; draw diagonal left bottom clip
                        ; draw diagonal left bottom clip
                        ; draw diagnoal left clip to right clip
                        ; draw diagnoal top clip to bottom clip
                        ; draw diagnoal left top clip to right clip
                        ; flip right to left
                        ; flip bottom to top
.DebugPause:           ; jp      .DebugPause
                        jp      InitialiseGalaxies

DrawTestDataLine1:      DW      -10,   -10,   20,   30
DrawTestDataLine2:      DW      265,   -10,  235,   30
DrawTestDataLine3:      DW      -10,   -10,   30,   20
DrawTestDataLine4:      DW      265,   -10,  225,   20
DrawTestDataLine5:      DW    -1000,   -10,  127,   60
DrawTestDataLine6:      DW     1000,   -10,  128,   60 
DrawTestDataLine7:      DW    -1000,   138,  127,   60
DrawTestDataLine8:      DW     1000,   138,  128,   60 
DrawTestDataLine9:      DW      -10, -1000,  127,   60
DrawTestDataLine10:     DW      265, -1000,  128,   60 
DrawTestDataLine11:     DW      -10,  1138,  127,   60
DrawTestDataLine12:     DW      265,  1138,  128,   60 
DrawTestDataLine13:     DW      -10, -1000,  127,  360
DrawTestDataLine14:     DW      265, -1000,  128,  360 
DrawTestDataLine15:     DW      -10,  1138,  127, -360
DrawTestDataLine16:     DW      265,  1138,  128, -360 
                                                 

DrawClippedLineDebug:   ld      bc,8
                        ld      de,UbnkPreClipX1
                        ldir
                        call    ClipLine
                        ld      a,(UBnkNewY1)
                        ld      h,a
                        ld      a,(UBnkNewX1)
                        ld      l,a
                        ld      a,(UBnkNewY2)
                        ld      d,a
                        ld      a,(UBnkNewX2)
                        ld      e,a
                        call    LineHLtoDE
                        ret

                ENDIF            
            IFDEF DEBUGCIRCLE1
                        ;break
                        ld      hl,128
                        ld      de, 64
                        ld      c,20
                        ld      b,$59
                        MMUSelectLayer2
                        call    l2_draw_clipped_circle_filled
            ENDIF
            IFDEF DEBUGCIRCLE2
                        ;break
                        ld      hl,128
                        ld      de, 64
                        ld      c,200
                        ld      b,$49
                        MMUSelectLayer2
                        call    l2_draw_clipped_circle_filled
                        ;break
            ENDIF

            IFDEF DEBUGCIRCLE3
                        ;break
                        ld      hl,128
                        ld      de, 64
                        ld      c,130
                        ld      b,$49
                        MMUSelectLayer2
                        call    l2_draw_clipped_circle_filled
                        ;break
            ENDIF

            IFDEF DEBUGCIRCLE4
                        ;break
                        ld      hl,320
                        ld      de, 128
                        ld      c,10
                        ld      b,$49
                        MMUSelectLayer2
                        call    l2_draw_clipped_circle_filled
                        ;break
            ENDIF            

            IFDEF LOGDIVIDEDEBUG
                        ;break
                        MMUSelectMathsTables
                        ld      a,4
                        ld      (varQTEST),a
                        ld      a,1
                        ld      (varATEST),a
                        ld      b,250
                        ld      hl, outputbuffer
.LoopTest:              push    bc,,hl
                        ld      a,(varQTEST)
                        ld      (varQ),a
                        ld      a,(varATEST)
                        call    Requ256mulAdivQ_Log
                        pop     bc,,hl
                        ld      (hl),a
                        inc     hl
                        ld      a,(varATEST)
                        inc     a
                        ld      (varATEST),a
                        ld      a,(varQTEST)
                        ld      (varQTEST),a
                        djnz    .LoopTest
                        ;break
                        
varATEST    DB  0
varQTEST    DB  0                        
                        
                        
                        
outputbuffer DS 256    
            ENDIF

                  IFDEF DEBUG_LL122_DIRECT
                        call    Debug_LL122_6502
                  ENDIF

                  IFDEF DEBUG_LL121_DIRECT   
                        call Debug_LL121_6502
                  ENDIF
                        
                  
                  IFDEF DEBUG_LL129_DIRECT
                        call Debug_LL129_6502
                  ENDIF
                  
                  IFDEF DEBUG_LL120_DIRECT
                        call Debug_LL120_6502
                  ENDIF
                        
                  IFDEF DEBUG_LL123_DIRECT
                        call Debug_LL123_6502
                  ENDIF

                  IFDEF DEBUG_LL118_DIRECT
                        call Debug_LL118_6502
                  ENDIF
                  
                  IFDEF DEBUG_LL28_6502
                        call Debug_LL28_6502
                  ENDIF
                  
                  IFDEF DEBUG_LL145_6502
                        ;break
                        call Debug_LL145_6502
                  ENDIF
                        
                  
                IFDEF DEBUG_LL129                         
                        ld      a,240       :ld      (XX12p2),a ; Gradient
                        ld      a,$FF       :ld      (XX12p3),a ; Slope
                        ld      hl,-50      :ld      (SRvarPair),hl
                        call    LL129_6502  ; Should be Q = 240, A = +ve SR = 50 >> PASS
                        ;break
                        ld      a,240       :ld      (XX12p2),a ; Gradient
                        ld      a,0         :ld      (XX12p3),a ; Slope
                        ld      hl,-50      :ld      (SRvarPair),hl
                        call    LL129_6502  ; Should be Q = 240, A = -ve SR = 50 >> PASS
                        ;break
                        ld      a,240       :ld      (XX12p2),a ; Gradient
                        ld      a,$FF       :ld      (XX12p3),a ; Slope
                        ld      hl, 150     :ld      (SRvarPair),hl
                        call    LL129_6502  ; Should be Q = 240, A = -ve SR = 150 >> PASS
                        ld      a,140       :ld      (XX12p2),a ; Gradient
                        ld      a,$0        :ld      (XX12p3),a ; Slope
                        ld      hl,50       :ld      (SRvarPair),hl
                        call    LL129_6502  ; Should be Q = 140, A = +ve SR = 50 >> PASS
                ENDIF
                IFDEF DEBUG_LL120
                        ;break
                        ld      a,0         :ld      (Tvar),a   ; slope +ve so multiply
                        ld      a,$FF       :ld      (Svar),a   ; S var -ve
                        ld      hl,-10      :ld      (XX1510),hl; x1_lo -ve
                        ld      a,168       :ld      (XX12p2),a ; Gradient 
                        ld      a,$FF       :ld      (XX12p3),a ; slope direction    
                        ; LL129 shoud be q = 168, a +ve SR 10 >> PASS 
                        call    LL120_6502  ; Should be -ve 10 * 168  so xy -15   >> FAIL
                        ;break
                        ld      a,$FF       :ld      (Tvar),a   ; slope -ve so divide
                        ld      a,$FF       :ld      (Svar),a   ; S var -ve
                        ld      hl,-10      :ld      (XX1510),hl; x1_lo -ve
                        ld      a,168       :ld      (XX12p2),a ; Gradient 
                        ld      a,$FF       :ld      (XX12p3),a ; slope direction    
                        ; LL129 shoud be q = 168, a +ve SR 10 >> PASS 
                        call    LL120_6502  ; Should be -ve 10 / 168  so xy -6 >> PASS
                ENDIF
            IFDEF  DEBUGCLIP
                        ;break
                        MMUSelectUniverseN 0
                        MMUSelectLayer2
                        call   l2_cls_upper_two_thirds
                        ld      hl,PlotTestData
                        ld      b,32
.testLoop:              push    bc
                        push    hl
                        ld      de,x1
                        ld      bc, 8
                        pop     hl
                        ldir
                        ;break
                        push    hl
                        call    l2_draw_6502_line;l2_draw_elite_line
                        ;break
                        ;MMUSelectKeyboard
                        ;call    WaitForAnyKey
                        pop     hl
                        pop     bc
                        djnz    .testLoop
                        ;break
                        jp      InitialiseGalaxies
                      ;  ld      hl,$FFF7 : ld (x1),hl : ld hl,$0009 : ld (y1),hl : ld hl,$000F : ld (x2),hl : ld hl,$FFEF : ld (y2),hl : call l2_draw_elite_line
                      ;  ld      hl,259   : ld (x1),hl : ld hl,35    : ld (y1),hl : ld hl,250   : ld (x2),hl : ld hl,-12   : ld (y2),hl : call l2_draw_elite_line
                         ld      hl,237   : ld (x1),hl : ld hl,258   : ld (y1),hl : ld hl,353   : ld (x2),hl : ld hl,237   : ld (y2),hl : call l2_draw_elite_line
                      ;  ld      hl,6     : ld (x1),hl : ld hl,-65   : ld (y1),hl : ld hl,-15   : ld (x2),hl : ld hl,7     : ld (y2),hl : call l2_draw_elite_line

PlotTestData:  ; dw  281 ,   60, 252 ,   90  ; pass
               ; dw   -9 ,    9,  16 ,  -17  ; pass
                dw -10  ,  -10,  50 ,   50 ;0:0:50:50   pass
                dw -10  ,    0,  50 ,   50 ;0:8:50:50   fail load x1 y1 as 0,0
                dw -20  ,    0,  50 ,   50 ;0:14:50:50  fail load x1 y1 as 0,0
                dw  -5  ,  -10,  50 ,   50 ;4.5:0:50:50 fail load x1 y1 as 0,0
               
                dw -10  ,  -10,  50 ,   50
                dw  10  ,    0,  50 ,   50
                dw   0  ,    0,  50 ,   50
                dw   0  ,   -5,  50 ,   50
                
                dw  259 ,   35, 250 ,  -12
                dw  237 ,  258, 353 ,  237
                dw    6 ,  -65, -15 ,    7
                dw  280 ,   90, 300 ,   70
                dw  -80 ,   90, -20 ,   70
                dw  -10 ,  120,  10 ,  145
                dw  120 ,  -10,  45 ,   10
                dw  220 , -100,   5 ,   80
                dw  220 ,  120,  35 ,  190
                dw  235 ,  120,  20 ,  190
                dw  -50 ,   60, 145 ,   70
                dw  150 ,   60, 345 ,   70
                dw  140 ,   90, 240 ,   70
                dw  163 ,  256, 116 ,  173
                dw   83 ,  184,  55 ,  192
                dw   68 ,  192,  54 ,  103
                dw  125 , 3937, 127 ,   41
                dw  125 , 3937,  81 ,  111
                dw  310 ,  339,  81 , 3992
                dw  -37 , 4096,  38 ,  560
                dw  283 , 101 ,  65 ,  163
                dw  283 , 101 , 146 ,   78 
                dw  146 , 78  ,   3 ,   93 
                dw  3   , 93  ,  65 ,  163
                dw  -127, 346 ,   3 ,   93 
                dw  44	, 351 , -43 ,  126
                dw  92	, 54  , 144 ,  -14
                dw  144	, -14 , 164 ,    4
                dw  95	, 40  , 159 ,   31 
                dw  159	, 31  , 161 ,   51 



/*007D FF61 FF81 006F
007D FF61 017F 0029
0096 FF61 FF81 004D
0096 FF61 017F 004D
017F 004F 0072 015F
0072 015F FF81 004D
0019 002B 00F6 002B
00F6 002B 00F6 006F
00F6 006F 0019 006F
0019 006F 0019 002B
005A 0079 0095 0027
0096 0027 00AC 0028
0051 005D 00A2 0040
00A2 0040 00AA 0058
005F 0056 00A3 004A
00A3 004A 00A6 005F
0073 0070 007D 0072
007D 0072 007D 0075
006C 0083 0076 0088
0076 0072 007D 0074
006C 0083 0076 0088
0076 0088 0074 008B*/


/*;;
28 01 79 00 5a 01 8f 00 28 01 79 00 2f 01 3a 00
2f 01 3a 00 5f 01 53 00 5f 01 53 00 5a 01 8f 00
5a 01 8f 00 14 01 a1 00 28 01 79 00 14 01 a1 00
28 01 79 00 ed 00 53 00 ed 00 53 00 2F 01 3a 00
14 01 a1 00 e3 00 78 00 ed 00 53 00 e3 00 78 00
47 01 6d 00 40 01 5f 00 40 01 5f 00 44 01 5d 00
44 01 5d 00 4b 01 6a 00 4b 01 6a 00 47 01 6d 00
42 01 5d 00 47 01 5d 00 47 01 5d 00 48 01 6d 00
48 01 6d 00 43 01 6d 00 47 01 6d 00 43 01 6c 00
47 01 6d 00 42 01 6c 00 14 00 dc ff 12 00 e1 ff*/

                         MMUSelectKeyboard
                         call        WaitForAnyKey    
            ELSE
                         DISPLAY "Not debugging clip code"            
            ENDIF
            