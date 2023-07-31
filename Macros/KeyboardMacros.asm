MacroIsKeyPressed:      MACRO C_Pressed_keycode
                        ld      a,C_Pressed_keycode
                        MMUSelectKeyboard
                        call    is_key_pressed
                        ENDM

MacroInitkeyboard:      MACRO
                        MMUSelectKeyboard
                        call    init_keyboard
                        ENDM
                        