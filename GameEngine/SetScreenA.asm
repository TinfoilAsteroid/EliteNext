; SetScreenA.asm
;----------------------------------------------------------------------------------------------------------------------------------
InvalidScreenBlock:     jp     InvalidScreenBlock 
SetScreenA:             JumpIfAGTENusng ScreenCount, InvalidScreenBlock
.SetUpIndex:            ld      (ScreenIndex),a                 ; Set screen index to a
.SetUpIX:               ld      d,a
                        ld      e,ScreenMapRow
                        mul
                        ld      ix,ScreenKeyMap
                        add     ix,de   
                        ld      (ScreenIndexTablePointer),ix    ; optimises later fetches
                        ClearForceTransition                    ; In case it was called by a brute force change in an update loop
                        ld      (ScreenChanged),a               ; Set screen changed to FF                       
.IsItAViewPort:         ld      a,(ix+9)                        ; Screen Map Byte 9  - Draw stars Y/N and also guns present
                        ld      (CheckIfViewUpdate+1),a         ; Set flag to determine if we are on an exterior view
                        JumpIfAIsZero .NotViewPort              ;
                        ld      a,(ix+1)                        ; get screen view number
                        sub     ScreenFront                     ; Now a = screen number 0 = front, 1 = aft, 2 = left 3 = right
                        MMUSelectCommander                      ; Load view laser to current
                        call    LoadLaserToCurrent              ;
.NotViewPort:           ld      a,(ix+4)                        ; Screen Map Byte 4   - Bank with Display code
                        ld      (ScreenLoopBank+1),a            ; setup loop            
                        ld      (HandleBankSelect+1),a          ; setup cursor keys
                        ld      (WarpMMUBank+1),a               ; WarpSFXHandler
                        MMUSelectScreenA
                        ld      a,(ix+5)                        ; Screen Map Byte 5 & 6 - Function for display initialisation
                        ld      (ScreenUpdateAddr+1),a          ; .
                        ld      a,(ix+6)                     c   ; .
                        ld      (ScreenUpdateAddr+2),a          ; .
                        ld      a,(ix+7)                        ; Screen Map Byte 7 & 8 - Main loop update routine
                        ld      (ScreenLoopJP+1),a              ; .
                        ld      a,(ix+8)                        ; .
                        ld      (ScreenLoopJP+2),a              ; .
                        ld      a,(ix+10)                       ; Screen Map Byte 10  - Input Blocker (set to 1 will not allow keyboard screen change until flagged, used by transition screens and pause menus)
                        ld      (InputBlockerCheck+1),a          ; Set flag to block transitions as needed e.g. launch screen    
                        ld      a,(ix+11)                       ; Screen Map Byte 11  - Double Buffering 0 = no, 1 = yes
                        ld      (DoubleBufferCheck+1),a
                        ld      a,(ix+12)
                        ld      (CallCursorRoutine+1),a
                        ld      a,(ix+13)
                        ld      (CallCursorRoutine+2),a
                        ld      a,(ix+16)
                        ld      (UpdateShipsControl+1),a       ; determin if we call update universe objects in this screen                      
                        ld      a,(ix+17)
                        ld      (WarpRoutineAddr+1),a
                        ld      a,(ix+18)
                        ld      (WarpRoutineAddr+2),a
ScreenUpdateAddr:       jp      $0000                          ; We can just drop out now and also get a free ret from caller
