;Number in hl to decimal ASCII
;Thanks to z80 Bits
;inputs:	hl = number to ASCII
;example: hl=300 outputs '00300'
;destroys: af, bc, hl, de used
DispHLtoDE:
; "DispHL, writes HL to DE address"
	ld	bc,-10000
	call	Num1
	ld	bc,-1000
	call	Num1
	ld	bc,-100
	call	Num1
	ld	c,-10
	call	Num1
	ld	c,-1
Num1:	
	ld	a,'0'-1
.Num2:	
	inc	a
	add	hl,bc
	jr	c,.Num2
	sbc	hl,bc
	ld	(de),a
	inc	de
	ret 

DispAtoDE:
	ld h,0
	ld l,a
	jp DispHLtoDE

DispPriceAtoDE:
	ld h,0
	ld l,a
	ld	bc,-100
	call	.NumLeadBlank1
	ld	c,-10
	call	Num1
	ld		a,'.'					; we could assume preformat but
	ld		(de),a					; we can optimse that later TODO
	inc		de						; with just an inc De
	ld	c,-1
	jr		Num1
.NumLeadBlank1:	
	ld	a,'0'-1
.NumLeadBlank2:	
	inc	a
	add	hl,bc
	jr	c,.NumLeadBlank2
	cp	'0'
	jr	nz,.DontBlank
.Blank:
	ld	a,' '
.DontBlank:	
	sbc	hl,bc
	ld	(de),a
	inc	de
	ret 

DispQtyAtoDE:
	cp	0
	jr	z,.NoStock
	ld h,0
	ld l,a
	ld	bc,-100
	call	.NumLeadBlank1
	ld	c,-10
	call	.NumLeadBlank1
	ld	c,-1
	jr		Num1
.NumLeadBlank1:	
	ld	a,'0'-1
.NumLeadBlank2:	
	inc	a
	add	hl,bc
	jr	c,.NumLeadBlank2
	cp	'0'
	jr	nz,.DontBlank
.Blank:
	ld	a,' '
.DontBlank:	
	sbc	hl,bc
	ld	(de),a
	inc	de
	ret 
.NoStock:
	ld	a,' '
	ld	(de),a
	inc	de
	ld	(de),a
	inc	de
	ld	a,'-'
	ld	(de),a
	inc de
	ret


;### CLCN32 -> Converts 32Bit-Value in ASCII-String (terminated by 0)
;### Input      DE,IX=32bit value, IY=destination address
;### Output     IY=last char in destination string
;### Destroyed AF,BC,DE,HL,IX
clcn32t dw 1,0,     10,0,     100,0,     1000,0,       10000,0
        dw $86a0,1, $4240,$0f, $9680,$98, $e100,$05f5, $ca00,$3b9a
clcn32z ds 4

; As per display but shifts final digit by 1 and puts in "." for 1 decimal place
DispDEIXtoIY1DP:        call    DispDEIXtoIY
                        ld      a,(IY+0)
                        ld      (IY+1),a
                        ld      a,"."
                        ld      (IY+0),a
                        ret

DispDEIXtoIY:           ld (clcn32z),ix
                        ld (clcn32z+2),de
                        ld ix,clcn32t+36
                        ld b,9
                        ld c,0
.clcn321:               ld a,'0'
                        or a
.clcn322:               ld e,(ix+0)
                        ld d,(ix+1)
                        ld hl,(clcn32z)
                        sbc hl,de
                        ld (clcn32z),hl
                        ld e,(ix+2)
                        ld d,(ix+3)
                        ld hl,(clcn32z+2)
                        sbc hl,de
                        ld (clcn32z+2),hl
                        jr c,.clcn325
                        inc c
                        inc a
                        jr .clcn322
.clcn325:               ld e,(ix+0)
                        ld d,(ix+1)
                        ld hl,(clcn32z)
                        add hl,de
                        ld (clcn32z),hl
                        ld e,(ix+2)
                        ld d,(ix+3)
                        ld hl,(clcn32z+2)
                        adc hl,de
                        ld (clcn32z+2),hl
                        ld de,-4
                        add ix,de
                        inc c
                        dec c
                        jr z,.clcn323
                        ld (iy+0),a
                        inc iy
.clcn323:               djnz .clcn321
                        ld a,(clcn32z)
                        add A,'0'
                        ld (iy+0),a
                        ld (iy+1),0
                        ret
