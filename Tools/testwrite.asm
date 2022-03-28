 DEVICE ZXSPECTRUMNEXT

 CSPECTMAP testwrite.map
 OPT --zxnext=cspect --syntax=a --reversepop
; test file write
; sjasmplus --msg=all --lst=testw.txt testwrite.asm
; cSpect.exe -brk -debug -16bit -s28  -map=testwrite.map -rewind -sound -w3 -zxnext -cur -mmc=.\ testwrite.nex



M_GETSETDRV             equ $89
F_OPEN                  equ $9a
F_CLOSE                 equ $9b
F_READ                  equ $9d
F_WRITE                 equ $9e
F_SEEK                  equ $9f
FA_READ                 equ $01
FA_APPEND               equ $06
FA_OVERWRITE            equ $0C


                org     $5c5c
IM2Routine:     ei
                reti
                org     $5d00
VectorTable:            
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine
                
EliteNextStartup:       ORG         $8000
                ld      a,VectorTable>>8
                ld      i,a                     
                im      2                       ; Setup IM2 mode
                ei
GetDefaultDrive:         xor	    a	; a = 0 means get default drive into A
                        ld      a,"A"
                        rst	    $08
                        db	    $89
                        ld      l,a

                        ld          hl,Filename
                        ld          ix,testfile
                        ld          bc,100
OpenFile:               push	bc,,ix   			; store size& save address
                        push	hl		        	; get name into ix
                        pop	    ix
                        ld      b,FA_OVERWRITE		; mode open for writing
                        push	hl,,ix
                        push	ix
                        ld	    a,(DefaultDrive)
                        rst	    $08
                        db	    F_OPEN
                        pop	    hl,,ix
                        push    af
                        push	hl,,ix
                        pop	    hl
                        rst	    $08
                        db	    F_WRITE
                        pop	    hl
                        break

DefaultDrive:	        db	0
Filename    db "RHTEST.TXT",0

testfile    DB "testFile.txt",0
            DS 100

    SAVENEX OPEN "testwrite.nex", $8000 , $7F00
    SAVENEX CFG  0,0,0,1
    SAVENEX AUTO
    SAVENEX CLOSE

