ViewKeyTest:            ld      a,(ScreenIndex)
                        ld      c,a
                        ld      b,ScreenMapLen                  ; For now until add screens are added
                        ld      ix,ScreenKeyMap                 ; IX = table head for scanning
                        ld      hl,(InnerHyperCount)
                        ld      a,h
                        or      l
                        ld      iyh,a
ViewScanLoop:           ld      a,iyh
.HyperspaceCountdown:   and     a
                        jr      z,.CheckDockedFlag
                        ld      a,(ix+14)
                        cp      1
                        jp      z,NotReadNextKey
.CheckDockedFlag:       ld      a,(ix+0)                        ; Screen Map Byte 0 Docked keyboard read flag 
; 0 = not applicable (always read), 1 = only whilst docked, 2 = only when not docked, 3 = No keypress allowed
                        JumpIfAEqNusng 3, NotReadNextKey        ; No keypress allowed at all (e.g. in hyperspace)
                        JumpIfAIsZero    .CanReadKey            ; if its the skip check for docking status
.DocCheck:              ld      d,a                             ; save ix+0 value
                        JumpIfMemEqNusng DockedFlag, StateNormal, .NotDockedCheck ; if we are not in a docked state the we ar egood
.DockedCheck:           ld      a,d                             ; we are docked so only ix+0 value of 1 is allowed
                        JumpIfANENusng 1, NotReadNextKey        ; if we are docked and its not 1 then don't read
                        jr      .CanReadKey                     ; we can now scan as normal  as its 2 and docked
.NotDockedCheck:        ld      a,d                             ; if we are not docked then code 2 is not keyscan allowed
                        JumpIfANENusng 2,NotReadNextKey
.CanReadKey:            ld      a,(ix+1)                        ; Screen Map Byte 1 Screen Id
                        cp      c                               ; is the index the current screen, if so skip the scan
                        ld      e,a
                        jr      z,NotReadNextKey                ; we cant transition to current screen
                        ld      a,(ix+3)                        ; Screen Map Byte 3 - address of keypress table
                        cp      $FF                             ; if upper byte is FF then we do not respond
                        jr      z,NotReadNextKey
                        ld      (ReadKeyAddr+2),a               ; Poke address into the ld hl,(....) below
                        ld      a,(ix+2)                        ; Screen Map Byte 2 - address of keypress table
                        ld      (ReadKeyAddr+1),a
ReadKeyAddr:            ld      hl,($0000)                      ; address is entry in the pointer table to the actual keypress
                        ld      a,(hl)                          ; now fetch the actual keypress
                        JumpIfAIsZero NotReadNextKey
.ValidScreenChange:     ld      a,e                             ; entering here e= current screen search number
                        jp      SetScreenA
;--- CODE WILL NOT FALL TO HERE ---
NotReadNextKey:         ld      de,ScreenMapRow
                        add     ix,de                           ; we have only processed 3 of 8 bytes at here
                        djnz    ViewScanLoop
                        ret

