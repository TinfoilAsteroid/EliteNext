
;### CLCN32 -> Converts 32Bit-Value in ASCII-String (terminated by 0)
;### Input      DE,IX=32bit value, IY=destination address
;### Output     IY=last char in destination string
;### Destroyed AF,BC,DE,HL,IX


                        ld (.clcn32z),ix
                        ld (.clcn32zIX),de
                        ld ix,.clcn32t+36
                        ld b,9
                        ld c,0
.clcn321:               ld a,'0'
                        or a
.clcn322:               ld e,(ix+0)
                        ld d,(ix+1)
                        ld hl,(.clcn32z)
                        sbc hl,de
                        ld (.clcn32z),hl
                        ld e,(ix+2)
                        ld d,(ix+3)
                        ld hl,(.clcn32zIX)
                        sbc hl,de
                        ld (.clcn32zIX),hl
                        jr c,.clcn325
                        inc c
                        inc a
                        jr .clcn322
.clcn325:               ld e,(ix+0)
                        ld d,(ix+1)
                        ld hl,(.clcn32z)
                        add hl,de
                        ld (.clcn32z),hl
                        ld e,(ix+2)
                        ld d,(ix+3)
                        ld hl,(.clcn32zIX)
                        adc hl,de
                        ld (.clcn32zIX),hl
                        ld de,-4
                        add ix,de
                        inc c
                        dec c
                        jr z,.clcn323
                        ld (iy+0),a
                        inc iy
.clcn323:               djnz .clcn321
                        ld a,(.clcn32z)
                        add A,'0'
                        ld (iy+0),a
                        ld (iy+1),0
                        ret
.clcn32t                dw 1,0,     10,0,     100,0,     1000,0,       10000,0
                        dw $86a0,1, $4240,$0f, $9680,$98, $e100,$05f5, $ca00,$3b9a
.clcn32z                ds 2
.clcn32zIX              ds 2

