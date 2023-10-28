ScreenHeight 		equ 192
ScreenLastRow       equ ScreenHeight -1
ScreenWidth  		equ 256
ScreenLastCol       equ ScreenWidth -1
ScreenHeightHalf	equ 96
ScreenWidthHalf  	equ 128
ScreenCenterY		equ 96
ScreenCenterX       equ 128
ViewHeight          equ 128
ViewHeightPlus1     equ 128+1
ViewLastRow       	equ ViewHeight -1
ViewWidth  			equ 256
ViewLastCol         equ ViewWidth -1
ViewHeightHalf      equ 63
ViewWidthHalf       equ 127
ViewCenterY         equ 64
ViewCenterX         equ 128
                        DISPLAY "TODO: place odler for debugging"
ShipColour			equ $FF		; place holder for debugging TODO
ScreenL1Bottom      equ $5000
ScreenL1BottomLen   equ 32 * 8 * 8
ScreenL1AttrBtm     equ $5A00
ScreenL1AttrBtmLen  equ 32 * 8
