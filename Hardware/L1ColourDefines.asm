             
L1ColourInkBlack        EQU %00000000
L1ColourInkBlue         EQU %00000001
L1ColourInkRed          EQU %00000010
L1ColourInkMagenta      EQU %00000011
L1ColourInkGreen        EQU %00000100
L1ColourInkCyan         EQU %00000101
L1ColourInkYellow       EQU %00000110
L1ColourInkWhite        EQU %00000111
L1ColourPaperBlack      EQU %00000000
L1ColourPaperBlue       EQU %00001000
L1ColourPaperRed        EQU %00010000
L1ColourPaperMagenta    EQU %00011000
L1ColourPaperGreen      EQU %00100000
L1ColourPaperCyan       EQU %00101000
L1ColourPaperYellow     EQU %00110000
L1ColourPaperWhite      EQU %00111000
L1ColourFlash           EQU %10000000
L1ColourBright          EQU %01000000
;----------------------------------------------------------------------------------------------------------------------------------
; Screen Specific Colour Defines
L1InvHighlight          EQU L1ColourBright | L1ColourPaperRed   | L1ColourInkYellow
L1InvLowlight           EQU                  L1ColourPaperBlack | L1ColourInkWhite