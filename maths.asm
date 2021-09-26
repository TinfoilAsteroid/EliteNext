
; SNASM Next Elite 


    INCLUDE "Hardware/register_defines.asm"
    INCLUDE "Layer2Graphics/asm_l2_defines.asm"
; "Setting Origin"
	ORG $8000

	di
testGraphics:
	; "Testing graphics"
testSetup:
; set up 
;;	7	Enable Lores Layer
;;	6	If 1, the sprite rendering priority is flipped, i.e. sprite 0 is on top of other sprites (0 after reset)
;;	5	If 1, the clipping works even in "over border" mode (doubling X-axis coordinates of clip window) (0 after reset)
;;	4-2	Layers priority and mixing			%000	S L U (Sprites are at top, Layer 2 under, Enhanced_ULA at bottom)
;;	1	Enable sprites over border (0 after reset)
;;	0	Enable sprite visibility (0 after reset)							
	NextReg SPRITE_LAYERS_SYSTEM_REGISTER, %00000011
	NextReg REG_GLOBAL_TRANSPARENCY, COLOUR_TRANSPARENT

test1:	; cls
	call 	l2_cls
	ld 		bc, $0505
	ld		a, 74
test2:
	ld		b,20
	ld		c,20
	ld		d,50
	ld		e,30
	ld		a,1
	call	l2_draw_diagonal_save
test3:	
	ld		b, 20
	ld		c, 20
	ld		d, 50
	ld		e, 50
	ld		h, 30
	ld		l, 70
	call	l2_fillBottomFlatTriangle
	catchLoopt2:jp catchLoopt2		



	catchLoopEnd:
	jp catchLoopEnd	


writeResult:
	ld hl,varTest1
	add hl,a
	add hl,a
	ld (hl),e
	inc hl
	ld (hl),d
	ret
db "****************"
db "1122334455667788"
varTest1:
DW 0
varTest2:
DW 0
varTest3:
DW 0
varTest4:
DW 0
varTest5:
DW 0
varTest6:
DW 0
varTest7:
DW 0
varTest8:
DW 0
varDustY:
DB "varDustY"
DS 5
varY:
DW 0
;varP:
;DB "varP"
;DW 0
;varQ:
;DB "varQ"
;DW 0
;varX1:
;DW 0
;varY1:
;DW 0
;varZ1:
;DW 0
;regA:
;DB 0
;regXX15fx:
;DW 0
;regXX15fY:
;DW 0
;regXX15fZ:
;DW 0


INCLUDE "Variables/equates.asm"
INCLUDE "Variables/general_variables.asm"

INCLUDE "Maths/asm_multiply.asm"
INCLUDE "Maths/asm_square.asm"
INCLUDE "Maths/asm_sqrt.asm"
INCLUDE "Maths/asm_divide.asm"
INCLUDE "Maths/asm_unitvector.asm"

INCLUDE "Layer2Graphics/asm_l2_bank_select.asm"
INCLUDE "Layer2Graphics/asm_l2_cls.asm"
INCLUDE "Layer2Graphics/asm_l2_initialise.asm"
INCLUDE "Layer2Graphics/asm_l2_plot_pixel.asm"
INCLUDE "Layer2Graphics/asm_l2_plot_horizontal.asm"
INCLUDE "Layer2Graphics/asm_l2_plot_vertical.asm"
INCLUDE "Layer2Graphics/asm_l2_plot_diagonal.asm"
INCLUDE "Layer2Graphics/asm_l2_plot_triangle.asm"
INCLUDE "Layer2Graphics/asm_l2_fill_triangle.asm"

INCLUDE "./title_page.asm"
	
;;	sqrthltoe
;;	ld de,(regDE)
;;	ld a, (regXX15fx)
;;	a/e
;;	ld (regXX15fx),a
;;	ld a, (regXX15fy)
;;	a/e
;;	ld (regXX15fx),a
;;	ld a, (regXX15f)
;;	a/e
;;	ld (regXX15fx),a
	
	
SAVENEX "MATHS.nex", $8000 , $5000
