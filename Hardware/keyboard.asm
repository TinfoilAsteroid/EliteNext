;
; $FEFE;65278 V, C, X, Z, Caps Shifts       4  3  2  1  0
; $FDFE;65022 G, F, D, S, A                 9  8  7  6  5 
; $FBFE;64510 T, R, E, W, Q                14 13 12 11 10
; $F7FE;63486 5, 4, 3, 2, 1                19 18 17 16 15 
; $EFFE;61438 6, 7, 8, 9, 0                24 23 22 23 20
; $DFFE;57342 Y, U, I, O, P                29 28 27 26 25
; $BFFE;49150 H, J, K, L, Enter            34 33 32 31 30 
; $7FFE;32766 B, N, M, Symbol Shift, Space 39 38 37 36 35
;
; Keyboard
;
;   0      1       2       3       4       5        6       7       8       9       
;  VK_CAPS, VK_Z,  VK_X,   VK_C,   VK_V,   VK_A,    VK_S,   VK_D,   VK_F,   VK_G
;   10     11      12      13      14      15       16      17      18      19       
;  VK_Q,   VK_W,   VK_E,   VK_R,   VK_T,   VK_1,    VK_2,   VK_3,   VK_4,   VK_5
;   20     21      22      23      24      25       26      27      28      29       
;  VK_0    VK_9,   VK_8,   VK_7,   VK_6,   VK_P ,    VK_O,  VK_I,   VK_U,   VK_Y
;   30     31      32      33      34      35       36      37      38      39       
; VK_ENTER VK_L,   VK_K,   VK_J,   VK_H,   VK_SPACE VK_SYM, VK_M,   VK_N,   VK_B
; 
; Default map
;-----------------------------------------------------------------------------------------------------------------------------------
;   0          1           2             3              4           5           6           7           8           9       
;   VK_CAPS    VK_Z        VK_X,         VK_C,          VK_V,       VK_A        VK_S,       VK_D,       VK_F,       VK_G
;              GameSkip                  Equip          SelLCargo   Climb       Decelerate  Recentre    FireM       HomeCursor 
;                                                                                                       Find System
;-----------------------------------------------------------------------------------------------------------------------------------
;   10         11          12            13             14          15          16          17          18          19
;   VK_Q       VK_W,       VK_E,         VK_R,          VK_T,       VK_1        VK_2        VK_3        VK_4        VK_5
;   Dive       Accelerate  ECM           UnarmMissile   TargetM     FrontV      AftV        LeftV       RightV      GalacticChart
;-----------------------------------------------------------------------------------------------------------------------------------
;   20         Accel       22            23             24          25          26          27          28          29       
;   VK_0       VK_9,       VK_8,         VK_7,          VK_6,       VK_P ,      VK_O,       VK_I,       VK_U,       VK_Y
;   EscapePod  Inventory   Status        MarketPrices   LocalChart  RollRight   RolLLeft                EnergyBomb  Quit
;   PlanetData                                                      PauseGame   SaveGame
;-----------------------------------------------------------------------------------------------------------------------------------
;   30         31          32            33             34          Right       36          37          EnergyBomb  39       
;   VK_ENTER   VK_L,       VK_K,         VK_J,          VK_H,       VK_SPACE    VK_SYM,     VK_M,       VK_N,       VK_B
;              Launch                    Distance       Hyperspace  Laser                               DockComp    BuyCargo
;              ResumeGame

; You can read address to check keystate by address KeyboardMap + c_Pressed corresponding key. There is also an addr_ helper too

c_Pressed_Front         equ 0  * 2
c_Pressed_Aft           equ 1  * 2
c_Pressed_Left          equ 2  * 2
c_Pressed_Right         equ 3  * 2
c_Pressed_RollLeft      equ 4  * 2
c_Pressed_RollRight     equ 5  * 2
c_Pressed_Dive          equ 6  * 2
c_Pressed_Climb         equ 7  * 2
c_Pressed_Accellerate   equ 8  * 2
c_Pressed_Decellerate   equ 9  * 2
c_Pressed_FireLaser     equ 10 * 2
c_Pressed_TargetMissle  equ 11 * 2
c_Pressed_FireMissile   equ 12 * 2
c_Pressed_UnarmMissile  equ 13 * 2
c_Pressed_ECM           equ 14 * 2
c_Pressed_EnergyBomb    equ 15 * 2
c_Pressed_EscapePod     equ 16 * 2
c_Pressed_DockingComp   equ 17 * 2
c_Pressed_Hyperspace    equ 18 * 2
c_Pressed_Distance      equ 19 * 2
c_Pressed_HomeCursor    equ 20 * 2
c_Pressed_Launch        equ 21 * 2
c_Pressed_BuyCargo      equ 22 * 2
c_Pressed_SellCargo     equ 23 * 2
c_Pressed_Equip         equ 24 * 2
c_Pressed_GalacticChrt  equ 25 * 2
c_Pressed_LocalChart    equ 26 * 2
c_Pressed_MarketPrices  equ 27 * 2
c_Pressed_Status        equ 28 * 2
c_Pressed_Inventory     equ 29 * 2
c_Pressed_GameSkip      equ 30 * 2
c_Pressed_Save          equ 31 * 2
c_Pressed_Freeze        equ 32 * 2
c_Pressed_Resume        equ 33 * 2
c_Pressed_Recentre      equ 34 * 2
c_Pressed_Quit          equ 35 * 2
c_Pressed_PlanetData    equ 36 * 2
c_Pressed_CursorUp      equ 37 * 2
c_Pressed_CursorDown    equ 38 * 2
c_Pressed_Find          equ 39 * 2

; half row 1
VK_CAPS  				equ 0
VK_Z  					equ 1
VK_X  					equ 2
VK_C  					equ 3
VK_V  					equ 4
; half row 2
VK_A  					equ 5
VK_S  					equ 6
VK_D  					equ 7
VK_F  					equ 8
VK_G  					equ 9
; half row 3
VK_Q  					equ 10
VK_W  					equ 11
VK_E  					equ 12
VK_R  					equ 13
VK_T  					equ 14
; half row 4
VK_1  					equ 15
VK_2  					equ 16
VK_3  					equ 17
VK_4  					equ 18
VK_5  					equ 19
; half row 5
VK_0 					equ 20
VK_9 					equ 21
VK_8 					equ 22
VK_7 					equ 23
VK_6 					equ 24
; half row 6
VK_P  					equ 25
VK_O  					equ 26
VK_I  					equ 27
VK_U  					equ 28
VK_Y  					equ 29
; half row 7
VK_ENTER 				equ 30
VK_L  					equ 31
VK_K  					equ 32
VK_J  					equ 33
VK_H  					equ 34
; half row 8
VK_SPACE 				equ 35
VK_SYM  				equ 36
VK_M  					equ 37
VK_N  					equ 38
VK_B  					equ 39

;KeyboardMapping
KeyCode_Front        	equ VK_1
KeyCode_Aft          	equ VK_2
KeyCode_Left         	equ VK_3
KeyCode_Right        	equ VK_4
KeyCode_RollLeft     	equ VK_O
KeyCode_RollRight    	equ VK_P
KeyCode_Dive         	equ VK_Q
KeyCode_Climb        	equ VK_A
KeyCode_Accellerate  	equ VK_W
KeyCode_Decellerate  	equ VK_S
KeyCode_FireLaser    	equ VK_SPACE
KeyCode_TargetMissle 	equ VK_T
KeyCode_FireMissile  	equ VK_F
KeyCode_Find        	equ VK_F
KeyCode_UnarmMissile 	equ VK_R
KeyCode_ECM          	equ VK_E
KeyCode_EnergyBomb   	equ VK_U
KeyCode_EscapePod    	equ VK_CAPS
KeyCode_DockingComp  	equ VK_N
KeyCode_Hyperspace   	equ VK_H
KeyCode_Distance     	equ VK_J
KeyCode_HomeCursor   	equ VK_G
KeyCode_Launch       	equ VK_L
KeyCode_BuyCargo     	equ VK_B
KeyCode_SellCargo    	equ VK_V
KeyCode_Equip        	equ VK_C
KeyCode_GalacticChrt 	equ VK_5
KeyCode_LocalChart   	equ VK_6
KeyCode_MarketPrices 	equ VK_7
KeyCode_Status       	equ VK_8
KeyCode_Inventory    	equ VK_9
KeyCode_GameSkip     	equ VK_Z
KeyCode_Save         	equ VK_O
KeyCode_Freeze       	equ VK_B
KeyCode_Resume       	equ VK_L
KeyCode_Recentre     	equ VK_D
KeyCode_Quit         	equ VK_Y
KeyCode_PlanetData   	equ VK_0
KeyCode_CursorUp        equ VK_Q
KeyCode_CursorDown      equ VK_A

Keys					DS	40
c_KeyBoardLen 			equ $ - Keys
RawKeys					DS	8
KeyAddrTab				DW	$FEFE, $FDFE, $FBFE, $F7FE, $EFFE, $DFFE, $BFFE, $7FFE
; Now keyboard map lists each game key and the corresponding address in the Keys table to get the value. This way redefining keys is just a case 
; of updating this table with the respective location to look up
; key list sequence is in table above
KeyboardMap             DW  Keys+KeyCode_Front        ,Keys+KeyCode_Aft          ,Keys+KeyCode_Left         ,Keys+KeyCode_Right        ,Keys+KeyCode_RollLeft     
                        DW  Keys+KeyCode_RollRight    ,Keys+KeyCode_Dive         ,Keys+KeyCode_Climb        ,Keys+KeyCode_Accellerate  ,Keys+KeyCode_Decellerate  
                        DW  Keys+KeyCode_FireLaser    ,Keys+KeyCode_TargetMissle ,Keys+KeyCode_FireMissile  ,Keys+KeyCode_UnarmMissile ,Keys+KeyCode_ECM          
                        DW  Keys+KeyCode_EnergyBomb   ,Keys+KeyCode_EscapePod    ,Keys+KeyCode_DockingComp  ,Keys+KeyCode_Hyperspace   ,Keys+KeyCode_Distance     
                        DW  Keys+KeyCode_HomeCursor   ,Keys+KeyCode_Launch       ,Keys+KeyCode_BuyCargo     ,Keys+KeyCode_SellCargo    ,Keys+KeyCode_Equip        
                        DW  Keys+KeyCode_GalacticChrt ,Keys+KeyCode_LocalChart   ,Keys+KeyCode_MarketPrices ,Keys+KeyCode_Status       ,Keys+KeyCode_Inventory    
                        DW  Keys+KeyCode_GameSkip     ,Keys+KeyCode_Save         ,Keys+KeyCode_Freeze       ,Keys+KeyCode_Resume       ,Keys+KeyCode_Recentre     
                        DW  Keys+KeyCode_Quit         ,Keys+KeyCode_PlanetData   ,Keys+KeyCode_CursorUp     ,Keys+KeyCode_CursorDown   ,Keys+KeyCode_Find

ASCII_Map:              DB "#","Z","X","C","V"
                        DB "A","S","D","F","G"
                        DB "Q","W","E","R","T"
                        DB "1","2","3","4","5"
                        DB "0","9","8","7","6"
                        DB "P","O","I","U","Y"
                        DB ">","L","K","J","H"
                        DB " ","^","M","N","B"


addr_Pressed_Front         equ KeyboardMap+c_Pressed_Front       
addr_Pressed_Aft           equ KeyboardMap+c_Pressed_Aft          
addr_Pressed_Left          equ KeyboardMap+c_Pressed_Left         
addr_Pressed_Right         equ KeyboardMap+c_Pressed_Right        
addr_Pressed_RollLeft      equ KeyboardMap+c_Pressed_RollLeft     
addr_Pressed_RollRight     equ KeyboardMap+c_Pressed_RollRight    
addr_Pressed_Dive          equ KeyboardMap+c_Pressed_Dive         
addr_Pressed_Climb         equ KeyboardMap+c_Pressed_Climb        
addr_Pressed_Accellerate   equ KeyboardMap+c_Pressed_Accellerate  
addr_Pressed_Decellerate   equ KeyboardMap+c_Pressed_Decellerate  
addr_Pressed_FireLaser     equ KeyboardMap+c_Pressed_FireLaser    
addr_Pressed_TargetMissle  equ KeyboardMap+c_Pressed_TargetMissle 
addr_Pressed_FireMissile   equ KeyboardMap+c_Pressed_FireMissile  
addr_Pressed_UnarmMissile  equ KeyboardMap+c_Pressed_UnarmMissile 
addr_Pressed_ECM           equ KeyboardMap+c_Pressed_ECM          
addr_Pressed_EnergyBomb    equ KeyboardMap+c_Pressed_EnergyBomb   
addr_Pressed_EscapePod     equ KeyboardMap+c_Pressed_EscapePod    
addr_Pressed_DockingComp   equ KeyboardMap+c_Pressed_DockingComp  
addr_Pressed_Hyperspace    equ KeyboardMap+c_Pressed_Hyperspace   
addr_Pressed_Distance      equ KeyboardMap+c_Pressed_Distance     
addr_Pressed_HomeCursor    equ KeyboardMap+c_Pressed_HomeCursor   
addr_Pressed_Launch        equ KeyboardMap+c_Pressed_Launch       
addr_Pressed_BuyCargo      equ KeyboardMap+c_Pressed_BuyCargo     
addr_Pressed_SellCargo     equ KeyboardMap+c_Pressed_SellCargo    
addr_Pressed_Equip         equ KeyboardMap+c_Pressed_Equip        
addr_Pressed_GalacticChrt  equ KeyboardMap+c_Pressed_GalacticChrt 
addr_Pressed_LocalChart    equ KeyboardMap+c_Pressed_LocalChart   
addr_Pressed_MarketPrices  equ KeyboardMap+c_Pressed_MarketPrices 
addr_Pressed_Status        equ KeyboardMap+c_Pressed_Status       
addr_Pressed_Inventory     equ KeyboardMap+c_Pressed_Inventory    
addr_Pressed_GameSkip      equ KeyboardMap+c_Pressed_GameSkip     
addr_Pressed_Save          equ KeyboardMap+c_Pressed_Save         
addr_Pressed_Freeze        equ KeyboardMap+c_Pressed_Freeze       
addr_Pressed_Resume        equ KeyboardMap+c_Pressed_Resume       
addr_Pressed_Recentre      equ KeyboardMap+c_Pressed_Recentre     
addr_Pressed_Quit          equ KeyboardMap+c_Pressed_Quit         
addr_Pressed_PlanetData    equ KeyboardMap+c_Pressed_PlanetData   
addr_Pressed_CursorUp      equ KeyboardMap+c_Pressed_CursorUp
addr_Pressed_CursorDown    equ KeyboardMap+c_Pressed_CursorDown
addr_Pressed_Find          equ KeyboardMap+c_Pressed_Find


MIsKeyPressed:      MACRO   keyaddress, misstarget
                    ld      hl,(keyaddress)
                    ld      a,(hl)
                    JumpIfAIsZero   misstarget
                    ENDM

init_keyboard:      ld		hl,Keys
                    ld		de, c_KeyBoardLen
                    ld		a,0
                    call	memfill_dma
                    ret
	
scan_keyboard:      ld		hl,RawKeys
                    ld		de,KeyAddrTab
                    xor		a
                    ld		iyl,8
                    ld      ix,Keys
.PortReadLoop:      ld		a,(de)							; Set up BC as port to read
                    ld		c,a
                    inc		de
                    ld      a,(de)
                    ld		b,a
                    inc		de
                    in		a,(c)							; read port to a
                    ld		(hl),a							; set raw keys to value
                    inc		hl								; and ready for next element
                    ld		b,5								; loop all bits (there are only 5 keys to a group)
.ProcessBitsLoop:   bit		0,a								; is bit set
                    jr      z,.SetKeyPressed  
                    ex      af,af'
                    xor     a
                    jp      .SetKey
                    jr		nz,.SkipKeySet
.SetKeyPressed:	    ex		af,af'
                    ld      a,(ix+0)
                    inc     a
                    and     $3                              ; so bit 0 set is pressed, bit 1 set is repeat pressed, i.e. 0 = no, 1 = yes 2,3 = held
.SetKey:            ld		(ix+0),a							; Key Pressed
                    ex		af,af'
.SkipKeySet:	    inc		ix								; move to next key
                    srl		a								; move next key into bit 0
                    djnz	.ProcessBitsLoop				; Process all key group bits
                    dec     iyl
                    jr      nz,.PortReadLoop				; Read next input port
                    ret

GetKeyStateAddressDE: MACRO
                      ld      hl,KeyboardMap                  ; work our address to read from
                      add     hl,a
                      ld      a,(hl)
                      ld      e,a
                      inc     hl
                      ld      a,(hl)
                      ld      d,a                             ; now de = address in keypress list
                      ENDM


; call with a = c_Pressed key, will then read mapping
wait_for_key_a_press:       GetKeyStateAddressDE
                            push    de
wait_for_key_press_loop:    call    scan_keyboard
                            pop     hl                              ; get key address into hl
                            push    hl
                            ld      a,(hl)
                            JumpIfANENusng  1,wait_for_key_press_loop         ; will also loop if held down when entering this routine
                            pop     hl                              ; tidy up rogue push, less t states than detecting if we want to push or not
                            ret

wait_for_key_a_held:        GetKeyStateAddressDE
                            push    de
wait_for_key_a_held_loop:   call    scan_keyboard
                            pop     hl
                            push    hl
                            ld      a,(hl)
                            JumpIfALTNusng  2,wait_for_key_a_held_loop
                            pop     hl
                            ret
    
get_key_a_state:            GetKeyStateAddressDE                 ; reads a mapped key and sets a to key staus, e.g. 0 1 or >=2 DOES NOT SCAN KEYBOARD
                            ex      de,hl
                            ld      a,(hl)                        ; a = keystate
                            ret

force_key_press:            GetKeyStateAddressDE
                            ex      de,hl
                            ld      a,1
                            ld      (hl),a
                            ret

; returns z is set if c_ key is pressed
is_key_pressed:             GetKeyStateAddressDE
                            ex      de,hl
                            ld      a,(hl)                          ; a = keystate
                            cp      1
                            ret
      
; returns z is set if c_ key is held
is_key_held:                GetKeyStateAddressDE
                            ex      de,hl
                            ld      a,(hl)                          ; a = keystate
                            and     2                               ; clear out bit 1 which elimiates state 3, so it can now be 2 (held) or 0 (not pressed or one off)
                            cp      2
                            ret

is_any_key_pressed:
    ld      hl,Keys
    ld      b,40
    ld      c,0
.KeyReadLoop:    
    ld      a,(hl)
    cp      1
    jp      z,.KeyPressed
    inc     hl
    inc     c
    djnz    .KeyReadLoop
    SetAFalse
    ret
.KeyPressed:
    ld      a,c
    ret

is_any_key_held:
    ld      hl,Keys
    ld      b,40
    ld      c,0
.KeyReadLoop:    
    ld      a,(hl)
    and     2                               ; clear out bit 1 which elimiates state 3, so it can now be 2 (held) or 0 (not pressed or one off)
    cp      2
    jp      z,.KeyPressed
    inc     hl
    inc     c
    djnz    .KeyReadLoop
    SetAFalse
    ret
.KeyPressed:
    ld      a,c
    ret    
    

InputString             DS  30              ; used for a 30 character input buffer
                        DB  0               ; end of string marker as a safety
InputCursor             DB  0
EnterPressed            DB  0               ; zero notpressed FF pressed
InputChanged            DB  0
InputLimit              EQU 20 

keyboard_copy_input_to_de:
    ld      hl,InputString
    ld      a,(InputCursor)
    cp      0
    jr      z,.NoString
    ld      c,a
    ld      b,0
    ldir
.NoString
    ld      a,0
    ld      (de),a
    ret

initInputText:
    xor     a
    ld      (InputCursor),a
    ld      (EnterPressed),a
    ld      (InputChanged),a
    ld      hl,InputString
    ld      b,30
.wipeloop:    
    ld      (hl),a
    inc     hl
    djnz    .wipeloop
    ret
    
InputName:                  xor     a
                            ld      (InputChanged),a
                            call    is_any_key_pressed
                            cp      $FF
                            ret     z
.KeyPressed:
    ld      c,a
    ld      a,(InputCursor)                 ; No key so we can now look at if we are at the end of the buffer    
    cp      InputLimit                      ; move to variable later and then cp (hl)
    jr      z,.DeleteOrEnterOnly            ;
    ld      hl,ASCII_Map
    ld      a,c
    add     hl,a
    ld      a,(hl)
    cp      "A"
    jr      nc,.AlphaPressed
.DeleteOrEnterOnly                          ; CAPS and Symbol act as delete for now
    cp      "0"                             ; if 0 was preseed check caps shift too
    jr      z,.CheckShiftDelete             ; for now we will ignore the shift and just assume delete
    cp      ">"         ; ENTER
    jr      z,.EnterPressed
    cp      "#"         ; CAPS
    jr      z,.CapsPressed
    cp      "^"         ; SYMBOLSHIFT
    jr      z,.SymbolPressed
    cp      " "         ; space
    jr      z,.SpacePressed
    ret
.AlphaPressed:
    ld      b,a
    ld      a,(InputCursor)
    ld      c,a
    ld      hl,InputString
    add     hl,a
    ld      a,b
    ld      (hl),b
    ld      a,c
    ld      hl,InputCursor
    inc     (hl)
    SetMemFalse InputChanged
    ret
.EnterPressed:
    ld      a,(InputCursor)
    inc     a
    ld      hl,InputString
    add     hl,a
    xor     a
    ld      (hl),a
    dec     a
    ld      (EnterPressed),a
    ld      (InputChanged),a
    ret
.CheckShiftDelete:
.CapsPressed:                               ; act as a delete key for now
.SymbolPressed:    
.SpacePressed:    
    ld      a,(InputCursor)
    cp      0
    ret     z
    dec     a
    ld      (InputCursor),a
    ld      hl,InputString
    add     hl,a
    xor     a
    ld      (hl),a
    SetMemFalse InputChanged
    ret

MovementKeyTest:        xor     a
                        ld      (CursorKeysPressed),a
                        ld      a,(MenuIdMax)
                        and     $FC
                        jr      nz,CursorKeys
ClimbDiveKeys:          ld      hl,(addr_Pressed_Climb)
                        ld      a,(hl)
                        JumpIfAIsZero ScanDiveKey
                        ld      a,(CursorKeysPressed)
                        or      $80
                        ld      (CursorKeysPressed),a
                        jp      ScanLeftKey
ScanDiveKey:            ld      hl,(addr_Pressed_Dive)
                        ld      a,(hl)
                        JumpIfAIsZero ScanLeftKey
                        ld      a,(CursorKeysPressed)
                        or      $40
                        ld      (CursorKeysPressed),a
                        jp      ScanLeftKey
CursorKeys:             ld      hl,(addr_Pressed_CursorUp)
                        ld      a,(hl)
                        JumpIfAIsZero ScanCursorDownKey
                        ld      a,(CursorKeysPressed)
                        or      $80
                        ld      (CursorKeysPressed),a
                        jp      ScanLeftKey
ScanCursorDownKey:      ld      hl,(addr_Pressed_CursorDown)
                        ld      a,(hl)
                        JumpIfAIsZero ScanLeftKey
                        ld      a,(CursorKeysPressed)
                        or      $40
                        ld      (CursorKeysPressed),a
ScanLeftKey:            ld      hl,(addr_Pressed_RollLeft)
                        ld      a,(hl)
                        JumpIfAIsZero ScanRightKey
                        ld      a,(CursorKeysPressed)
                        or      $20
                        ld      (CursorKeysPressed),a
                        ret
ScanRightKey:           ld      hl,(addr_Pressed_RollRight)
                        ld      a,(hl)
                        JumpIfAIsZero ScanHomeKey
                        ld      a,(CursorKeysPressed)
                        or      $10
                        ld      (CursorKeysPressed),a
                        ret
ScanHomeKey:            ld      hl,(addr_Pressed_HomeCursor)
                        ld      a,(hl)
                        JumpIfAIsZero ScanRecentreKey
                        ld      a,(CursorKeysPressed)
                        or      $08
                        ld      (CursorKeysPressed),a
                        ret
ScanRecentreKey:        ld      hl,(addr_Pressed_Recentre)
                        ld      a,(hl)
                        ReturnIfAIsZero
                        ld      a,(CursorKeysPressed)
                        or      $04
                        ld      (CursorKeysPressed),a
                        ret

    