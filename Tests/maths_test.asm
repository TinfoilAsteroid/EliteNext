                        DEVICE ZXSPECTRUMNEXT
                        DEFINE  DOUBLEBUFFER 1
                        CSPECTMAP  maths_test.map
                        OPT --zxnext=cspect --syntax=a --reversepop


                        INCLUDE "../Hardware/register_defines.asm"
                        INCLUDE "../Hardware/L2ColourDefines.asm"
                        INCLUDE "../Layer2Graphics/layer2_defines.asm"
                        INCLUDE	"../Hardware/memory_bank_defines.asm"
                        INCLUDE "../Hardware/screen_equates.asm"
                        INCLUDE "../Data/ShipModelEquates.asm"
                        INCLUDE "../Menus/clear_screen_inline_no_double_buffer.asm"	
                        INCLUDE "../Macros/graphicsMacros.asm"
                        INCLUDE "../Macros/callMacros.asm"
                        INCLUDE "../Macros/carryFlagMacros.asm"
                        INCLUDE "../Macros/CopyByteMacros.asm"
                        INCLUDE "../Macros/ldCopyMacros.asm"
                        INCLUDE "../Macros/ldIndexedMacros.asm"
                        INCLUDE "../Macros/jumpMacros.asm"
                        INCLUDE "../Macros/MathsMacros.asm"
                        INCLUDE "../Macros/MMUMacros.asm"
                        INCLUDE "../Macros/NegateMacros.asm"
                        INCLUDE "../Macros/returnMacros.asm"
                        INCLUDE "../Macros/ShiftMacros.asm"
                        INCLUDE "../Macros/signBitMacros.asm"
                        INCLUDE "../Tables/message_queue_macros.asm"
                        INCLUDE "../Variables/general_variables_macros.asm"
                        INCLUDE "../Variables/UniverseSlot_macros.asm"
                        INCLUDE "../Variables/constant_equates.asm"

testStartup:            ORG         $8000

SetXX15:            MACRO val1, val2,val3
                    ld  a,val1
                    ld  (XX15VecX),a
                    ld  a,val2
                    ld  (XX15VecY),a
                    ld  a,val3
                    ld  (XX15VecZ),a
                    ENDM

testMaths:
; "Testing Maths"
;16 0A DD -> 22  10 -93
; 93 60 E0 -> 23  55 -96

test1:
                SetXX15 16,32,$80 | 1           ; 57 2B 91 -> 87  43 -1 Seems wrong X & Y wrong way round?
                call NormalizeXX15
                break
                SetXX15 $80 | 16,37,$80 | 1     ; 90 37 91 -> 23  55 -1
                call NormalizeXX15
                break
                SetXX15 0,0,96                  ; 00 00 60 -> 00  00 96 Good
                call NormalizeXX15      
                break       
                SetXX15 0,0,$E0                 ; 00 60 9F -> 00  96 -31 Error
                call NormalizeXX15      
                break       
                SetXX15 0,96,0                  ; 60 00 60 -> 96  00  96 Error
                call NormalizeXX15      
                break       
                SetXX15 $E0,0,0                 ; 80 00 60 -> -0  96  0 Error
                call NormalizeXX15
                break
                SetXX15 $80 | 48,0,0            ; 80 00 60 -> -0  96  0 Error
                call NormalizeXX15
                break
                SetXX15 $80 | 60,$80 | 48,$80 | 48            ; 80 00 60 -> -0  96  0 Error
                call NormalizeXX15
                break
               
                


varP            DB 0    
varU                    DB  0               ;   80
varQ					DB  0 				;	81		
varR					DB  0 				;	82		
varS					DB  0 				;	83		
varT					DB  0 				;	83		
varRS                   equ varR

    INCLUDE "../Maths/asm_square.asm"
    INCLUDE "../Maths/Utilities/APequQmulA-MULT1.asm"
    INCLUDE "../Maths/asm_sqrt.asm"
    include "../Universe/Ships/XX15Vars.asm"
    include "../Universe/Ships/AIRuntimeData.asm"
    include "../Universe/Ships/CopyRotMattoXX15.asm"
    include "../Universe/Ships/CopyXX15toRotMat.asm"
    include "../Maths/Utilities/AequAdivQmul96-TIS2.asm"
    include "../Maths/Utilities/RSequQmulA-MULT12.asm"
    include "../Maths/normalise96.asm"
    include "../Maths/Utilities/tidy.asm"
    include "../Maths/asm_divide.asm"
    include "../Maths/multiply.asm"

    SAVENEX OPEN "maths_test.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE
        
        
;call    EAeqyDEdivC
;   break
;   ld      d,01
;   ld      e,56
;   ld      c,6
;    call    EAeqyDEdivC
;   break
;   ld      d,0
;   ld      e,0
;   ld      c,8
;    call    EAeqyDEdivC
;   break
;   ld      d,16
;   ld      e,16
;   ld      c,0
;    call    EAeqyDEdivC
;   break    
;test1:	
;	ld hl, 50
;	ld (varDustY),hl
;	ld hl,5
;	ld (varQ),hl
;	ld a,0
;	ld (varY),a
;	call asm_mlu1
;	ld a,0
;	call writeResult
;test2:
;    ld a,100
;	ld hl,varQ
;	ld (hl),a
;	ld a,3
;	call asm_mlu2
;	ld a,1
;	call writeResult
;test3:
;	ld a,9
;	call asm_squa
;	ld a,2
;	call writeResult ;; 8`
;test4:
;	ld de,$1EF1
;	call asm_sqrt
;	ex de,hl
;	ld a,3
;	call writeResult	;; 3
;test5:
;	ld hl, varQ
;	ld (hl),43
;	ld a, 43
;	call asm_tis2
;	ex de,hl
;	ld a,4
;	call writeResult ;; 96
;test6:
;	ld hl, varQ
;	ld (hl),22
;	ld a, 56
;	call asm_tis2 ;; hl = result
;	ex de,hl
;	ld a,5
;	call writeResult ;; 96
;test7:
;	ld hl, varQ
;	ld (hl),56
;	ld a, 22
;startLoop:
;	jp startLoop
;	call asm_tis2
;	ex de,hl
;	ld a,6
;	call writeResult;; 38
;test8:
;	ld hl, varQ
;	ld (hl),22
;	ld a, 11
;	call asm_tis2
;	ex de,hl
;	ld a,7
;	call writeResult	 ;; 48	
;            




asm_squa:
	and SignMask8Bit
; "ASM SQUA2 : TESTGOOD"
; "AP = A^2 A = low,P = hi singed"
asm_squa2:
	ld e, a
	ld d,a
	mul
	ld (varP),de
	ld a,e
	ret