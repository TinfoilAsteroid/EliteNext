


	
324   06A0              
324   06A0              
324   06A0              ;void l2_draw_scan_line(uint8_t x, uint8_t y1, uint8_t y2, uint8_t color)
324   06A0              	C_LINE	326,"Graphics\L2graphics.c"
326   06A0              ;{
326   06A0              	C_LINE	327,"Graphics\L2graphics.c"
327   06A0              
327   06A0              ; Function l2_draw_scan_line flags 0x00000200 __smallc
327   06A0              ; void l2_draw_scan_line(unsigned char x, unsigned char y1, unsigned char y2, unsigned char color)
327   06A0              ; parameter 'unsigned char color' at 2 size(1)
327   06A0              ; parameter 'unsigned char y2' at 4 size(1)
327   06A0              ; parameter 'unsigned char y1' at 6 size(1)
327   06A0              ; parameter 'unsigned char x' at 8 size(1)
327   06A0              ._l2_draw_scan_line
327   06A0              	C_LINE	327,"Graphics\L2graphics.c"
327   06A0              ;	uint8_t y3,ylen;
327   06A0              	C_LINE	328,"Graphics\L2graphics.c"
328   06A0              	C_LINE	328,"Graphics\L2graphics.c"
328   06A0              ;
328   06A0              	C_LINE	329,"Graphics\L2graphics.c"
329   06A0              ;	l2_draw_horz_line(x,   y2,  3, color);
329   06A0              	C_LINE	330,"Graphics\L2graphics.c"
330   06A0              	C_LINE	330,"Graphics\L2graphics.c"
330   06A0  C5          	push	bc
330   06A1              ;x;
330   06A1              	C_LINE	331,"Graphics\L2graphics.c"
331   06A1  21 0A 00    	ld	hl,10	;const
331   06A4  39          	add	hl,sp
331   06A5  6E          	ld	l,(hl)
331   06A6  26 00       	ld	h,0
331   06A8  E5          	push	hl
331   06A9              ;y2;
331   06A9              	C_LINE	331,"Graphics\L2graphics.c"
331   06A9  21 08 00    	ld	hl,8	;const
331   06AC  39          	add	hl,sp
331   06AD  6E          	ld	l,(hl)
331   06AE  26 00       	ld	h,0
331   06B0  E5          	push	hl
331   06B1              ;3;
331   06B1              	C_LINE	331,"Graphics\L2graphics.c"
331   06B1  21 03 00    	ld	hl,3	;const
331   06B4  E5          	push	hl
331   06B5              ;color;
331   06B5              	C_LINE	331,"Graphics\L2graphics.c"
331   06B5  21 0A 00    	ld	hl,10	;const
331   06B8  39          	add	hl,sp
331   06B9  6E          	ld	l,(hl)
331   06BA  26 00       	ld	h,0
331   06BC  E5          	push	hl
331   06BD  CD 6D 01    	call	_l2_draw_horz_line
331   06C0  C1          	pop	bc
331   06C1  C1          	pop	bc
331   06C2  C1          	pop	bc
331   06C3  C1          	pop	bc
331   06C4              ;	if (y1 < y2)
331   06C4              	C_LINE	331,"Graphics\L2graphics.c"
331   06C4              	C_LINE	331,"Graphics\L2graphics.c"
331   06C4  21 08 00    	ld	hl,8	;const
331   06C7  39          	add	hl,sp
331   06C8  5E          	ld	e,(hl)
331   06C9  16 00       	ld	d,0
331   06CB  21 06 00    	ld	hl,6	;const
331   06CE  39          	add	hl,sp
331   06CF  6E          	ld	l,(hl)
331   06D0  26 00       	ld	h,0
331   06D2  EB          	ex	de,hl
331   06D3  A7          	and	a
331   06D4  ED 52       	sbc	hl,de
331   06D6  D2 06 07    	jp	nc,i_50
331   06D9              ;	{
331   06D9              	C_LINE	332,"Graphics\L2graphics.c"
332   06D9              	C_LINE	332,"Graphics\L2graphics.c"
332   06D9              ;		y3 = y1;
332   06D9              	C_LINE	333,"Graphics\L2graphics.c"
333   06D9              	C_LINE	333,"Graphics\L2graphics.c"
333   06D9  21 01 00    	ld	hl,1	;const
333   06DC  39          	add	hl,sp
333   06DD  E5          	push	hl
333   06DE  21 0A 00    	ld	hl,10	;const
333   06E1  39          	add	hl,sp
333   06E2  7E          	ld	a,(hl)
333   06E3  D1          	pop	de
333   06E4  12          	ld	(de),a
333   06E5  6F          	ld	l,a
333   06E6  26 00       	ld	h,0
333   06E8              ;		ylen = (y2 - y1 )+1;
333   06E8              	C_LINE	334,"Graphics\L2graphics.c"
334   06E8              	C_LINE	334,"Graphics\L2graphics.c"
334   06E8  21 00 00    	ld	hl,0	;const
334   06EB  39          	add	hl,sp
334   06EC  E5          	push	hl
334   06ED  21 08 00    	ld	hl,8	;const
334   06F0  39          	add	hl,sp
334   06F1  5E          	ld	e,(hl)
334   06F2  16 00       	ld	d,0
334   06F4  21 0A 00    	ld	hl,10	;const
334   06F7  39          	add	hl,sp
334   06F8  6E          	ld	l,(hl)
334   06F9  26 00       	ld	h,0
334   06FB  EB          	ex	de,hl
334   06FC  A7          	and	a
334   06FD  ED 52       	sbc	hl,de
334   06FF  23          	inc	hl
334   0700  D1          	pop	de
334   0701  7D          	ld	a,l
334   0702  12          	ld	(de),a
334   0703              ;	}
334   0703              	C_LINE	335,"Graphics\L2graphics.c"
335   0703              ;	else
335   0703              	C_LINE	336,"Graphics\L2graphics.c"
336   0703  C3 30 07    	jp	i_51
336   0706              .i_50
336   0706              ;	{
336   0706              	C_LINE	337,"Graphics\L2graphics.c"
337   0706              	C_LINE	337,"Graphics\L2graphics.c"
337   0706              ;		y3 = y2;
337   0706              	C_LINE	338,"Graphics\L2graphics.c"
338   0706              	C_LINE	338,"Graphics\L2graphics.c"
338   0706  21 01 00    	ld	hl,1	;const
338   0709  39          	add	hl,sp
338   070A  E5          	push	hl
338   070B  21 08 00    	ld	hl,8	;const
338   070E  39          	add	hl,sp
338   070F  7E          	ld	a,(hl)
338   0710  D1          	pop	de
338   0711  12          	ld	(de),a
338   0712  6F          	ld	l,a
338   0713  26 00       	ld	h,0
338   0715              ;		ylen = (y1 - y2) + 1;
338   0715              	C_LINE	339,"Graphics\L2graphics.c"
339   0715              	C_LINE	339,"Graphics\L2graphics.c"
339   0715  21 00 00    	ld	hl,0	;const
339   0718  39          	add	hl,sp
339   0719  E5          	push	hl
339   071A  21 0A 00    	ld	hl,10	;const
339   071D  39          	add	hl,sp
339   071E  5E          	ld	e,(hl)
339   071F  16 00       	ld	d,0
339   0721  21 08 00    	ld	hl,8	;const
339   0724  39          	add	hl,sp
339   0725  6E          	ld	l,(hl)
339   0726  26 00       	ld	h,0
339   0728  EB          	ex	de,hl
339   0729  A7          	and	a
339   072A  ED 52       	sbc	hl,de
339   072C  23          	inc	hl
339   072D  D1          	pop	de
339   072E  7D          	ld	a,l
339   072F  12          	ld	(de),a
339   0730              ;	}
339   0730              	C_LINE	340,"Graphics\L2graphics.c"
340   0730              .i_51
340   0730              ;	l2_draw_vert_line(x, y3, ylen, color);
340   0730              	C_LINE	341,"Graphics\L2graphics.c"
341   0730              	C_LINE	341,"Graphics\L2graphics.c"
341   0730              ;x;
341   0730              	C_LINE	342,"Graphics\L2graphics.c"
342   0730  21 0A 00    	ld	hl,10	;const
342   0733  39          	add	hl,sp
342   0734  6E          	ld	l,(hl)
342   0735  26 00       	ld	h,0
342   0737  E5          	push	hl
342   0738              ;y3;
342   0738              	C_LINE	342,"Graphics\L2graphics.c"
342   0738  21 03 00    	ld	hl,3	;const
342   073B  39          	add	hl,sp
342   073C  6E          	ld	l,(hl)
342   073D  26 00       	ld	h,0
342   073F  E5          	push	hl
342   0740              ;ylen;
342   0740              	C_LINE	342,"Graphics\L2graphics.c"
342   0740  21 04 00    	ld	hl,4	;const
342   0743  39          	add	hl,sp
342   0744  6E          	ld	l,(hl)
342   0745  26 00       	ld	h,0
342   0747  E5          	push	hl
342   0748              ;color;
342   0748              	C_LINE	342,"Graphics\L2graphics.c"
342   0748  21 0A 00    	ld	hl,10	;const
342   074B  39          	add	hl,sp
342   074C  6E          	ld	l,(hl)
342   074D  26 00       	ld	h,0
342   074F  E5          	push	hl
342   0750  CD E0 02    	call	_l2_draw_vert_line
342   0753  C1          	pop	bc
342   0754  C1          	pop	bc
342   0755  C1          	pop	bc
342   0756  C1          	pop	bc
342   0757              ;	l2_draw_vert_line(x+1, y3, ylen, color);
342   0757              	C_LINE	342,"Graphics\L2graphics.c"
342   0757              	C_LINE	342,"Graphics\L2graphics.c"
342   0757              ;x+1;
342   0757              	C_LINE	343,"Graphics\L2graphics.c"
343   0757  21 0A 00    	ld	hl,10	;const
343   075A  39          	add	hl,sp
343   075B  6E          	ld	l,(hl)
343   075C  26 00       	ld	h,0
343   075E  23          	inc	hl
343   075F  E5          	push	hl
343   0760              ;y3;
343   0760              	C_LINE	343,"Graphics\L2graphics.c"
343   0760  21 03 00    	ld	hl,3	;const
343   0763  39          	add	hl,sp
343   0764  6E          	ld	l,(hl)
343   0765  26 00       	ld	h,0
343   0767  E5          	push	hl
343   0768              ;ylen;
343   0768              	C_LINE	343,"Graphics\L2graphics.c"
343   0768  21 04 00    	ld	hl,4	;const
343   076B  39          	add	hl,sp
343   076C  6E          	ld	l,(hl)
343   076D  26 00       	ld	h,0
343   076F  E5          	push	hl
343   0770              ;color;
343   0770              	C_LINE	343,"Graphics\L2graphics.c"
343   0770  21 0A 00    	ld	hl,10	;const
343   0773  39          	add	hl,sp
343   0774  6E          	ld	l,(hl)
343   0775  26 00       	ld	h,0
343   0777  E5          	push	hl
343   0778  CD E0 02    	call	_l2_draw_vert_line
343   077B  C1          	pop	bc
343   077C  C1          	pop	bc
343   077D  C1          	pop	bc
343   077E  C1          	pop	bc
343   077F              ;}
343   077F              	C_LINE	343,"Graphics\L2graphics.c"
343   077F  C1          	pop	bc
343   0780  C9          	ret
343   0781              
343   0781              
343   0781              ;void l2_draw_box(uint8_t x0, uint8_t y0, uint8_t x1, uint8_t y1 , uint8_t color)
343   0781              	C_LINE	345,"Graphics\L2graphics.c"
345   0781              ;{
345   0781              	C_LINE	346,"Graphics\L2graphics.c"
346   0781              
346   0781              ; Function l2_draw_box flags 0x00000200 __smallc
346   0781              ; void l2_draw_box(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, unsigned char color)
346   0781              ; parameter 'unsigned char color' at 2 size(1)
346   0781              ; parameter 'unsigned char y1' at 4 size(1)
346   0781              ; parameter 'unsigned char x1' at 6 size(1)
346   0781              ; parameter 'unsigned char y0' at 8 size(1)
346   0781              ; parameter 'unsigned char x0' at 10 size(1)
346   0781              ._l2_draw_box
346   0781              	C_LINE	346,"Graphics\L2graphics.c"
346   0781              ;    l2_draw_horz_line(x0,  y0,(x1-x0)+1, color);
346   0781              	C_LINE	347,"Graphics\L2graphics.c"
347   0781              	C_LINE	347,"Graphics\L2graphics.c"
347   0781              ;x0;
347   0781              	C_LINE	348,"Graphics\L2graphics.c"
348   0781  21 0A 00    	ld	hl,10	;const
348   0784  39          	add	hl,sp
348   0785  6E          	ld	l,(hl)
348   0786  26 00       	ld	h,0
348   0788  E5          	push	hl
348   0789              ;y0;
348   0789              	C_LINE	348,"Graphics\L2graphics.c"
348   0789  21 0A 00    	ld	hl,10	;const
348   078C  39          	add	hl,sp
348   078D  6E          	ld	l,(hl)
348   078E  26 00       	ld	h,0
348   0790  E5          	push	hl
348   0791              ;(x1-x0)+1;
348   0791              	C_LINE	348,"Graphics\L2graphics.c"
348   0791  21 0A 00    	ld	hl,10	;const
348   0794  39          	add	hl,sp
348   0795  5E          	ld	e,(hl)
348   0796  16 00       	ld	d,0
348   0798  21 0E 00    	ld	hl,14	;const
348   079B  39          	add	hl,sp
348   079C  6E          	ld	l,(hl)
348   079D  26 00       	ld	h,0
348   079F  EB          	ex	de,hl
348   07A0  A7          	and	a
348   07A1  ED 52       	sbc	hl,de
348   07A3  23          	inc	hl
348   07A4  E5          	push	hl
348   07A5              ;color;
348   07A5              	C_LINE	348,"Graphics\L2graphics.c"
348   07A5  21 08 00    	ld	hl,8	;const
348   07A8  39          	add	hl,sp
348   07A9  6E          	ld	l,(hl)
348   07AA  26 00       	ld	h,0
348   07AC  E5          	push	hl
348   07AD  CD 6D 01    	call	_l2_draw_horz_line
348   07B0  C1          	pop	bc
348   07B1  C1          	pop	bc
348   07B2  C1          	pop	bc
348   07B3  C1          	pop	bc
348   07B4              ;    l2_draw_horz_line(x0,  y1,(x1-x0)+1, color);
348   07B4              	C_LINE	348,"Graphics\L2graphics.c"
348   07B4              	C_LINE	348,"Graphics\L2graphics.c"
348   07B4              ;x0;
348   07B4              	C_LINE	349,"Graphics\L2graphics.c"
349   07B4  21 0A 00    	ld	hl,10	;const
349   07B7  39          	add	hl,sp
349   07B8  6E          	ld	l,(hl)
349   07B9  26 00       	ld	h,0
349   07BB  E5          	push	hl
349   07BC              ;y1;
349   07BC              	C_LINE	349,"Graphics\L2graphics.c"
349   07BC  21 06 00    	ld	hl,6	;const
349   07BF  39          	add	hl,sp
349   07C0  6E          	ld	l,(hl)
349   07C1  26 00       	ld	h,0
349   07C3  E5          	push	hl
349   07C4              ;(x1-x0)+1;
349   07C4              	C_LINE	349,"Graphics\L2graphics.c"
349   07C4  21 0A 00    	ld	hl,10	;const
349   07C7  39          	add	hl,sp
349   07C8  5E          	ld	e,(hl)
349   07C9  16 00       	ld	d,0
349   07CB  21 0E 00    	ld	hl,14	;const
349   07CE  39          	add	hl,sp
349   07CF  6E          	ld	l,(hl)
349   07D0  26 00       	ld	h,0
349   07D2  EB          	ex	de,hl
349   07D3  A7          	and	a
349   07D4  ED 52       	sbc	hl,de
349   07D6  23          	inc	hl
349   07D7  E5          	push	hl
349   07D8              ;color;
349   07D8              	C_LINE	349,"Graphics\L2graphics.c"
349   07D8  21 08 00    	ld	hl,8	;const
349   07DB  39          	add	hl,sp
349   07DC  6E          	ld	l,(hl)
349   07DD  26 00       	ld	h,0
349   07DF  E5          	push	hl
349   07E0  CD 6D 01    	call	_l2_draw_horz_line
349   07E3  C1          	pop	bc
349   07E4  C1          	pop	bc
349   07E5  C1          	pop	bc
349   07E6  C1          	pop	bc
349   07E7              ;    l2_draw_vert_line(x0,  y0,(y1-y0)+1, color);
349   07E7              	C_LINE	349,"Graphics\L2graphics.c"
349   07E7              	C_LINE	349,"Graphics\L2graphics.c"
349   07E7              ;x0;
349   07E7              	C_LINE	350,"Graphics\L2graphics.c"
350   07E7  21 0A 00    	ld	hl,10	;const
350   07EA  39          	add	hl,sp
350   07EB  6E          	ld	l,(hl)
350   07EC  26 00       	ld	h,0
350   07EE  E5          	push	hl
350   07EF              ;y0;
350   07EF              	C_LINE	350,"Graphics\L2graphics.c"
350   07EF  21 0A 00    	ld	hl,10	;const
350   07F2  39          	add	hl,sp
350   07F3  6E          	ld	l,(hl)
350   07F4  26 00       	ld	h,0
350   07F6  E5          	push	hl
350   07F7              ;(y1-y0)+1;
350   07F7              	C_LINE	350,"Graphics\L2graphics.c"
350   07F7  21 08 00    	ld	hl,8	;const
350   07FA  39          	add	hl,sp
350   07FB  5E          	ld	e,(hl)
350   07FC  16 00       	ld	d,0
350   07FE  21 0C 00    	ld	hl,12	;const
350   0801  39          	add	hl,sp
350   0802  6E          	ld	l,(hl)
350   0803  26 00       	ld	h,0
350   0805  EB          	ex	de,hl
350   0806  A7          	and	a
350   0807  ED 52       	sbc	hl,de
350   0809  23          	inc	hl
350   080A  E5          	push	hl
350   080B              ;color;
350   080B              	C_LINE	350,"Graphics\L2graphics.c"
350   080B  21 08 00    	ld	hl,8	;const
350   080E  39          	add	hl,sp
350   080F  6E          	ld	l,(hl)
350   0810  26 00       	ld	h,0
350   0812  E5          	push	hl
350   0813  CD E0 02    	call	_l2_draw_vert_line
350   0816  C1          	pop	bc
350   0817  C1          	pop	bc
350   0818  C1          	pop	bc
350   0819  C1          	pop	bc
350   081A              ;    l2_draw_vert_line(x1,  y0,(y1-y0)+1, color);
350   081A              	C_LINE	350,"Graphics\L2graphics.c"
350   081A              	C_LINE	350,"Graphics\L2graphics.c"
350   081A              ;x1;
350   081A              	C_LINE	351,"Graphics\L2graphics.c"
351   081A  21 06 00    	ld	hl,6	;const
351   081D  39          	add	hl,sp
351   081E  6E          	ld	l,(hl)
351   081F  26 00       	ld	h,0
351   0821  E5          	push	hl
351   0822              ;y0;
351   0822              	C_LINE	351,"Graphics\L2graphics.c"
351   0822  21 0A 00    	ld	hl,10	;const
351   0825  39          	add	hl,sp
351   0826  6E          	ld	l,(hl)
351   0827  26 00       	ld	h,0
351   0829  E5          	push	hl
351   082A              ;(y1-y0)+1;
351   082A              	C_LINE	351,"Graphics\L2graphics.c"
351   082A  21 08 00    	ld	hl,8	;const
351   082D  39          	add	hl,sp
351   082E  5E          	ld	e,(hl)
351   082F  16 00       	ld	d,0
351   0831  21 0C 00    	ld	hl,12	;const
351   0834  39          	add	hl,sp
351   0835  6E          	ld	l,(hl)
351   0836  26 00       	ld	h,0
351   0838  EB          	ex	de,hl
351   0839  A7          	and	a
351   083A  ED 52       	sbc	hl,de
351   083C  23          	inc	hl
351   083D  E5          	push	hl
351   083E              ;color;
351   083E              	C_LINE	351,"Graphics\L2graphics.c"
351   083E  21 08 00    	ld	hl,8	;const
351   0841  39          	add	hl,sp
351   0842  6E          	ld	l,(hl)
351   0843  26 00       	ld	h,0
351   0845  E5          	push	hl
351   0846  CD E0 02    	call	_l2_draw_vert_line
351   0849  C1          	pop	bc
351   084A  C1          	pop	bc
351   084B  C1          	pop	bc
351   084C  C1          	pop	bc
351   084D              ;}
351   084D              	C_LINE	351,"Graphics\L2graphics.c"
351   084D  C9          	ret
351   084E              
351   084E              
351   084E              ;
351   084E              	C_LINE	352,"Graphics\L2graphics.c"
352   084E              ;
352   084E              	C_LINE	353,"Graphics\L2graphics.c"
353   084E              ;
353   084E              	C_LINE	354,"Graphics\L2graphics.c"
354   084E              ;void l2_draw_diagonal (uint8_t x0, uint8_t y0, uint8_t x1, uint8_t y1 , uint8_t color)
354   084E              	C_LINE	355,"Graphics\L2graphics.c"
355   084E              ;{
355   084E              	C_LINE	356,"Graphics\L2graphics.c"
356   084E              
356   084E              ; Function l2_draw_diagonal flags 0x00000200 __smallc
356   084E              ; void l2_draw_diagonal(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, unsigned char color)
356   084E              ; parameter 'unsigned char color' at 2 size(1)
356   084E              ; parameter 'unsigned char y1' at 4 size(1)
356   084E              ; parameter 'unsigned char x1' at 6 size(1)
356   084E              ; parameter 'unsigned char y0' at 8 size(1)
356   084E              ; parameter 'unsigned char x0' at 10 size(1)
356   084E              ._l2_draw_diagonal
356   084E              	C_LINE	356,"Graphics\L2graphics.c"
356   084E              ;
356   084E              	C_LINE	357,"Graphics\L2graphics.c"
357   084E              ;    if (y0 > y1)
357   084E              	C_LINE	358,"Graphics\L2graphics.c"
358   084E              	C_LINE	358,"Graphics\L2graphics.c"
358   084E  21 08 00    	ld	hl,8	;const
358   0851  39          	add	hl,sp
358   0852  5E          	ld	e,(hl)
358   0853  16 00       	ld	d,0
358   0855  21 04 00    	ld	hl,4	;const
358   0858  39          	add	hl,sp
358   0859  6E          	ld	l,(hl)
358   085A  26 00       	ld	h,0
358   085C  A7          	and	a
358   085D  ED 52       	sbc	hl,de
358   085F  D2 8D 08    	jp	nc,i_52
358   0862              ;    {
358   0862              	C_LINE	359,"Graphics\L2graphics.c"
359   0862              	C_LINE	359,"Graphics\L2graphics.c"
359   0862              ;        l2_vx0 = x1;
359   0862              	C_LINE	360,"Graphics\L2graphics.c"
360   0862              	C_LINE	360,"Graphics\L2graphics.c"
360   0862  21 06 00    	ld	hl,6	;const
360   0865  39          	add	hl,sp
360   0866  6E          	ld	l,(hl)
360   0867  26 00       	ld	h,0
360   0869  22 A7 17    	ld	(_l2_vx0),hl
360   086C              ;        l2_vy0 = y1;
360   086C              	C_LINE	361,"Graphics\L2graphics.c"
361   086C              	C_LINE	361,"Graphics\L2graphics.c"
361   086C  21 04 00    	ld	hl,4	;const
361   086F  39          	add	hl,sp
361   0870  6E          	ld	l,(hl)
361   0871  26 00       	ld	h,0
361   0873  22 A9 17    	ld	(_l2_vy0),hl
361   0876              ;        l2_vx1 = x0;
361   0876              	C_LINE	362,"Graphics\L2graphics.c"
362   0876              	C_LINE	362,"Graphics\L2graphics.c"
362   0876  21 0A 00    	ld	hl,10	;const
362   0879  39          	add	hl,sp
362   087A  6E          	ld	l,(hl)
362   087B  26 00       	ld	h,0
362   087D  22 AB 17    	ld	(_l2_vx1),hl
362   0880              ;        l2_vy1 = y0;
362   0880              	C_LINE	363,"Graphics\L2graphics.c"
363   0880              	C_LINE	363,"Graphics\L2graphics.c"
363   0880  21 08 00    	ld	hl,8	;const
363   0883  39          	add	hl,sp
363   0884  6E          	ld	l,(hl)
363   0885  26 00       	ld	h,0
363   0887  22 AD 17    	ld	(_l2_vy1),hl
363   088A              ;    }
363   088A              	C_LINE	364,"Graphics\L2graphics.c"
364   088A              ;    else
364   088A              	C_LINE	365,"Graphics\L2graphics.c"
365   088A  C3 B5 08    	jp	i_53
365   088D              .i_52
365   088D              ;    {
365   088D              	C_LINE	366,"Graphics\L2graphics.c"
366   088D              	C_LINE	366,"Graphics\L2graphics.c"
366   088D              ;        l2_vx0 = x0;
366   088D              	C_LINE	367,"Graphics\L2graphics.c"
367   088D              	C_LINE	367,"Graphics\L2graphics.c"
367   088D  21 0A 00    	ld	hl,10	;const
367   0890  39          	add	hl,sp
367   0891  6E          	ld	l,(hl)
367   0892  26 00       	ld	h,0
367   0894  22 A7 17    	ld	(_l2_vx0),hl
367   0897              ;        l2_vy0 = y0;
367   0897              	C_LINE	368,"Graphics\L2graphics.c"
368   0897              	C_LINE	368,"Graphics\L2graphics.c"
368   0897  21 08 00    	ld	hl,8	;const
368   089A  39          	add	hl,sp
368   089B  6E          	ld	l,(hl)
368   089C  26 00       	ld	h,0
368   089E  22 A9 17    	ld	(_l2_vy0),hl
368   08A1              ;        l2_vx1 = x1;
368   08A1              	C_LINE	369,"Graphics\L2graphics.c"
369   08A1              	C_LINE	369,"Graphics\L2graphics.c"
369   08A1  21 06 00    	ld	hl,6	;const
369   08A4  39          	add	hl,sp
369   08A5  6E          	ld	l,(hl)
369   08A6  26 00       	ld	h,0
369   08A8  22 AB 17    	ld	(_l2_vx1),hl
369   08AB              ;        l2_vy1 = y1;
369   08AB              	C_LINE	370,"Graphics\L2graphics.c"
370   08AB              	C_LINE	370,"Graphics\L2graphics.c"
370   08AB  21 04 00    	ld	hl,4	;const
370   08AE  39          	add	hl,sp
370   08AF  6E          	ld	l,(hl)
370   08B0  26 00       	ld	h,0
370   08B2  22 AD 17    	ld	(_l2_vy1),hl
370   08B5              ;    }
370   08B5              	C_LINE	371,"Graphics\L2graphics.c"
371   08B5              .i_53
371   08B5              ;
371   08B5              	C_LINE	372,"Graphics\L2graphics.c"
372   08B5              ;    l2_dy = l2_vy1 - l2_vy0;
372   08B5              	C_LINE	373,"Graphics\L2graphics.c"
373   08B5              	C_LINE	373,"Graphics\L2graphics.c"
373   08B5  ED 5B AD 17 	ld	de,(_l2_vy1)
373   08B9  2A A9 17    	ld	hl,(_l2_vy0)
373   08BC  EB          	ex	de,hl
373   08BD  A7          	and	a
373   08BE  ED 52       	sbc	hl,de
373   08C0  22 A3 17    	ld	(_l2_dy),hl
373   08C3              ;    l2_dx = l2_vx1 - l2_vx0;
373   08C3              	C_LINE	374,"Graphics\L2graphics.c"
374   08C3              	C_LINE	374,"Graphics\L2graphics.c"
374   08C3  ED 5B AB 17 	ld	de,(_l2_vx1)
374   08C7  2A A7 17    	ld	hl,(_l2_vx0)
374   08CA  EB          	ex	de,hl
374   08CB  A7          	and	a
374   08CC  ED 52       	sbc	hl,de
374   08CE  22 A5 17    	ld	(_l2_dx),hl
374   08D1              ;    l2_layer_shift = 0;
374   08D1              	C_LINE	375,"Graphics\L2graphics.c"
375   08D1              	C_LINE	375,"Graphics\L2graphics.c"
375   08D1  21 00 00    	ld	hl,0 % 256	;const
375   08D4  7D          	ld	a,l
375   08D5  32 9C 17    	ld	(_l2_layer_shift),a
375   08D8              ;    if (l2_dx < 0)
375   08D8              	C_LINE	377,"Graphics\L2graphics.c"
377   08D8              	C_LINE	377,"Graphics\L2graphics.c"
377   08D8  2A A5 17    	ld	hl,(_l2_dx)
377   08DB  7C          	ld	a,h
377   08DC  17          	rla
377   08DD  D2 F2 08    	jp	nc,i_54
377   08E0              ;    {
377   08E0              	C_LINE	378,"Graphics\L2graphics.c"
378   08E0              	C_LINE	378,"Graphics\L2graphics.c"
378   08E0              ;        l2_dx = -l2_dx;
378   08E0              	C_LINE	379,"Graphics\L2graphics.c"
379   08E0              	C_LINE	379,"Graphics\L2graphics.c"
379   08E0  2A A5 17    	ld	hl,(_l2_dx)
379   08E3  CD 00 00    	call	l_neg
379   08E6  22 A5 17    	ld	(_l2_dx),hl
379   08E9              ;        l2_stepx = -1;
379   08E9              	C_LINE	380,"Graphics\L2graphics.c"
380   08E9              	C_LINE	380,"Graphics\L2graphics.c"
380   08E9  21 FF FF    	ld	hl,65535	;const
380   08EC  22 9D 17    	ld	(_l2_stepx),hl
380   08EF              ;    }
380   08EF              	C_LINE	381,"Graphics\L2graphics.c"
381   08EF              ;    else
381   08EF              	C_LINE	382,"Graphics\L2graphics.c"
382   08EF  C3 F8 08    	jp	i_55
382   08F2              .i_54
382   08F2              ;    {
382   08F2              	C_LINE	383,"Graphics\L2graphics.c"
383   08F2              	C_LINE	383,"Graphics\L2graphics.c"
383   08F2              ;        l2_stepx = 1;
383   08F2              	C_LINE	384,"Graphics\L2graphics.c"
384   08F2              	C_LINE	384,"Graphics\L2graphics.c"
384   08F2  21 01 00    	ld	hl,1	;const
384   08F5  22 9D 17    	ld	(_l2_stepx),hl
384   08F8              ;    }
384   08F8              	C_LINE	385,"Graphics\L2graphics.c"
385   08F8              .i_55
385   08F8              ;    l2_dy <<= 1;
385   08F8              	C_LINE	386,"Graphics\L2graphics.c"
386   08F8              	C_LINE	386,"Graphics\L2graphics.c"
386   08F8  2A A3 17    	ld	hl,(_l2_dy)
386   08FB  29          	add	hl,hl
386   08FC  22 A3 17    	ld	(_l2_dy),hl
386   08FF              ;    l2_dx <<= 1;
386   08FF              	C_LINE	387,"Graphics\L2graphics.c"
387   08FF              	C_LINE	387,"Graphics\L2graphics.c"
387   08FF  2A A5 17    	ld	hl,(_l2_dx)
387   0902  29          	add	hl,hl
387   0903  22 A5 17    	ld	(_l2_dx),hl
387   0906              ;    l2_plot_pixel(l2_vx0,l2_vy0,color);
387   0906              	C_LINE	388,"Graphics\L2graphics.c"
388   0906              	C_LINE	388,"Graphics\L2graphics.c"
388   0906              ;l2_vx0;
388   0906              	C_LINE	389,"Graphics\L2graphics.c"
389   0906  2A A7 17    	ld	hl,(_l2_vx0)
389   0909  26 00       	ld	h,0
389   090B  E5          	push	hl
389   090C              ;l2_vy0;
389   090C              	C_LINE	389,"Graphics\L2graphics.c"
389   090C  2A A9 17    	ld	hl,(_l2_vy0)
389   090F  26 00       	ld	h,0
389   0911  E5          	push	hl
389   0912              ;color;
389   0912              	C_LINE	389,"Graphics\L2graphics.c"
389   0912  21 06 00    	ld	hl,6	;const
389   0915  39          	add	hl,sp
389   0916  6E          	ld	l,(hl)
389   0917  26 00       	ld	h,0
389   0919  E5          	push	hl
389   091A  CD 32 01    	call	_l2_plot_pixel
389   091D  C1          	pop	bc
389   091E  C1          	pop	bc
389   091F  C1          	pop	bc
389   0920              ;    if (l2_dx > l2_dy)
389   0920              	C_LINE	390,"Graphics\L2graphics.c"
390   0920              	C_LINE	390,"Graphics\L2graphics.c"
390   0920  ED 5B A5 17 	ld	de,(_l2_dx)
390   0924  2A A3 17    	ld	hl,(_l2_dy)
390   0927  CD 00 00    	call	l_gt
390   092A  D2 A1 09    	jp	nc,i_56
390   092D              ;    {
390   092D              	C_LINE	391,"Graphics\L2graphics.c"
391   092D              	C_LINE	391,"Graphics\L2graphics.c"
391   092D              ;        l2_fraction = l2_dy - (l2_dx >> 1);
391   092D              	C_LINE	392,"Graphics\L2graphics.c"
392   092D              	C_LINE	392,"Graphics\L2graphics.c"
392   092D  2A A3 17    	ld	hl,(_l2_dy)
392   0930  E5          	push	hl
392   0931  2A A5 17    	ld	hl,(_l2_dx)
392   0934  CB 2C       	sra	h
392   0936  CB 1D       	rr	l
392   0938  D1          	pop	de
392   0939  EB          	ex	de,hl
392   093A  A7          	and	a
392   093B  ED 52       	sbc	hl,de
392   093D  22 A1 17    	ld	(_l2_fraction),hl
392   0940              ;        while (l2_vx0 != l2_vx1)
392   0940              	C_LINE	393,"Graphics\L2graphics.c"
393   0940              	C_LINE	393,"Graphics\L2graphics.c"
393   0940              .i_57
393   0940  ED 5B A7 17 	ld	de,(_l2_vx0)
393   0944  2A AB 17    	ld	hl,(_l2_vx1)
393   0947  CD 00 00    	call	l_ne
393   094A  D2 9E 09    	jp	nc,i_58
393   094D              ;        {
393   094D              	C_LINE	394,"Graphics\L2graphics.c"
394   094D              	C_LINE	394,"Graphics\L2graphics.c"
394   094D              ;            if (l2_fraction >= 0)
394   094D              	C_LINE	395,"Graphics\L2graphics.c"
395   094D              	C_LINE	395,"Graphics\L2graphics.c"
395   094D  2A A1 17    	ld	hl,(_l2_fraction)
395   0950  7C          	ld	a,h
395   0951  17          	rla
395   0952  3F          	ccf
395   0953  D2 6B 09    	jp	nc,i_59
395   0956              ;            {
395   0956              	C_LINE	396,"Graphics\L2graphics.c"
396   0956              	C_LINE	396,"Graphics\L2graphics.c"
396   0956              ;                ++l2_vy0;
396   0956              	C_LINE	397,"Graphics\L2graphics.c"
397   0956              	C_LINE	397,"Graphics\L2graphics.c"
397   0956  2A A9 17    	ld	hl,(_l2_vy0)
397   0959  23          	inc	hl
397   095A  22 A9 17    	ld	(_l2_vy0),hl
397   095D              ;                l2_fraction -= l2_dx;
397   095D              	C_LINE	398,"Graphics\L2graphics.c"
398   095D              	C_LINE	398,"Graphics\L2graphics.c"
398   095D  ED 5B A1 17 	ld	de,(_l2_fraction)
398   0961  2A A5 17    	ld	hl,(_l2_dx)
398   0964  EB          	ex	de,hl
398   0965  A7          	and	a
398   0966  ED 52       	sbc	hl,de
398   0968  22 A1 17    	ld	(_l2_fraction),hl
398   096B              ;            }
398   096B              	C_LINE	399,"Graphics\L2graphics.c"
399   096B              ;            l2_vx0 += l2_stepx;
399   096B              	C_LINE	400,"Graphics\L2graphics.c"
400   096B              .i_59
400   096B              	C_LINE	400,"Graphics\L2graphics.c"
400   096B  ED 5B A7 17 	ld	de,(_l2_vx0)
400   096F  2A 9D 17    	ld	hl,(_l2_stepx)
400   0972  19          	add	hl,de
400   0973  22 A7 17    	ld	(_l2_vx0),hl
400   0976              ;            l2_fraction += l2_dy;
400   0976              	C_LINE	401,"Graphics\L2graphics.c"
401   0976              	C_LINE	401,"Graphics\L2graphics.c"
401   0976  ED 5B A1 17 	ld	de,(_l2_fraction)
401   097A  2A A3 17    	ld	hl,(_l2_dy)
401   097D  19          	add	hl,de
401   097E  22 A1 17    	ld	(_l2_fraction),hl
401   0981              ;            l2_plot_pixel(l2_vx0,l2_vy0,color);
401   0981              	C_LINE	402,"Graphics\L2graphics.c"
402   0981              	C_LINE	402,"Graphics\L2graphics.c"
402   0981              ;l2_vx0;
402   0981              	C_LINE	403,"Graphics\L2graphics.c"
403   0981  2A A7 17    	ld	hl,(_l2_vx0)
403   0984  26 00       	ld	h,0
403   0986  E5          	push	hl
403   0987              ;l2_vy0;
403   0987              	C_LINE	403,"Graphics\L2graphics.c"
403   0987  2A A9 17    	ld	hl,(_l2_vy0)
403   098A  26 00       	ld	h,0
403   098C  E5          	push	hl
403   098D              ;color;
403   098D              	C_LINE	403,"Graphics\L2graphics.c"
403   098D  21 06 00    	ld	hl,6	;const
403   0990  39          	add	hl,sp
403   0991  6E          	ld	l,(hl)
403   0992  26 00       	ld	h,0
403   0994  E5          	push	hl
403   0995  CD 32 01    	call	_l2_plot_pixel
403   0998  C1          	pop	bc
403   0999  C1          	pop	bc
403   099A  C1          	pop	bc
403   099B              ;        }
403   099B              	C_LINE	403,"Graphics\L2graphics.c"
403   099B  C3 40 09    	jp	i_57
403   099E              .i_58
403   099E              ;    }
403   099E              	C_LINE	404,"Graphics\L2graphics.c"
404   099E              ;    else
404   099E              	C_LINE	405,"Graphics\L2graphics.c"
405   099E  C3 12 0A    	jp	i_60
405   09A1              .i_56
405   09A1              ;    {
405   09A1              	C_LINE	406,"Graphics\L2graphics.c"
406   09A1              	C_LINE	406,"Graphics\L2graphics.c"
406   09A1              ;        l2_fraction = l2_dx - (l2_dy >> 1);
406   09A1              	C_LINE	407,"Graphics\L2graphics.c"
407   09A1              	C_LINE	407,"Graphics\L2graphics.c"
407   09A1  2A A5 17    	ld	hl,(_l2_dx)
407   09A4  E5          	push	hl
407   09A5  2A A3 17    	ld	hl,(_l2_dy)
407   09A8  CB 2C       	sra	h
407   09AA  CB 1D       	rr	l
407   09AC  D1          	pop	de
407   09AD  EB          	ex	de,hl
407   09AE  A7          	and	a
407   09AF  ED 52       	sbc	hl,de
407   09B1  22 A1 17    	ld	(_l2_fraction),hl
407   09B4              ;        while (l2_vy0 != l2_vy1)
407   09B4              	C_LINE	408,"Graphics\L2graphics.c"
408   09B4              	C_LINE	408,"Graphics\L2graphics.c"
408   09B4              .i_61
408   09B4  ED 5B A9 17 	ld	de,(_l2_vy0)
408   09B8  2A AD 17    	ld	hl,(_l2_vy1)
408   09BB  CD 00 00    	call	l_ne
408   09BE  D2 12 0A    	jp	nc,i_62
408   09C1              ;        {
408   09C1              	C_LINE	409,"Graphics\L2graphics.c"
409   09C1              	C_LINE	409,"Graphics\L2graphics.c"
409   09C1              ;            if (l2_fraction >= 0)
409   09C1              	C_LINE	410,"Graphics\L2graphics.c"
410   09C1              	C_LINE	410,"Graphics\L2graphics.c"
410   09C1  2A A1 17    	ld	hl,(_l2_fraction)
410   09C4  7C          	ld	a,h
410   09C5  17          	rla
410   09C6  3F          	ccf
410   09C7  D2 E3 09    	jp	nc,i_63
410   09CA              ;            {
410   09CA              	C_LINE	411,"Graphics\L2graphics.c"
411   09CA              	C_LINE	411,"Graphics\L2graphics.c"
411   09CA              ;               l2_vx0 += l2_stepx;
411   09CA              	C_LINE	412,"Graphics\L2graphics.c"
412   09CA              	C_LINE	412,"Graphics\L2graphics.c"
412   09CA  ED 5B A7 17 	ld	de,(_l2_vx0)
412   09CE  2A 9D 17    	ld	hl,(_l2_stepx)
412   09D1  19          	add	hl,de
412   09D2  22 A7 17    	ld	(_l2_vx0),hl
412   09D5              ;               l2_fraction -= l2_dy;
412   09D5              	C_LINE	413,"Graphics\L2graphics.c"
413   09D5              	C_LINE	413,"Graphics\L2graphics.c"
413   09D5  ED 5B A1 17 	ld	de,(_l2_fraction)
413   09D9  2A A3 17    	ld	hl,(_l2_dy)
413   09DC  EB          	ex	de,hl
413   09DD  A7          	and	a
413   09DE  ED 52       	sbc	hl,de
413   09E0  22 A1 17    	ld	(_l2_fraction),hl
413   09E3              ;            }
413   09E3              	C_LINE	414,"Graphics\L2graphics.c"
414   09E3              ;            l2_fraction += l2_dx;
414   09E3              	C_LINE	415,"Graphics\L2graphics.c"
415   09E3              .i_63
415   09E3              	C_LINE	415,"Graphics\L2graphics.c"
415   09E3  ED 5B A1 17 	ld	de,(_l2_fraction)
415   09E7  2A A5 17    	ld	hl,(_l2_dx)
415   09EA  19          	add	hl,de
415   09EB  22 A1 17    	ld	(_l2_fraction),hl
415   09EE              ;            ++l2_vy0;
415   09EE              	C_LINE	416,"Graphics\L2graphics.c"
416   09EE              	C_LINE	416,"Graphics\L2graphics.c"
416   09EE  2A A9 17    	ld	hl,(_l2_vy0)
416   09F1  23          	inc	hl
416   09F2  22 A9 17    	ld	(_l2_vy0),hl
416   09F5              ;            l2_plot_pixel(l2_vx0,l2_vy0,color);
416   09F5              	C_LINE	417,"Graphics\L2graphics.c"
417   09F5              	C_LINE	417,"Graphics\L2graphics.c"
417   09F5              ;l2_vx0;
417   09F5              	C_LINE	418,"Graphics\L2graphics.c"
418   09F5  2A A7 17    	ld	hl,(_l2_vx0)
418   09F8  26 00       	ld	h,0
418   09FA  E5          	push	hl
418   09FB              ;l2_vy0;
418   09FB              	C_LINE	418,"Graphics\L2graphics.c"
418   09FB  2A A9 17    	ld	hl,(_l2_vy0)
418   09FE  26 00       	ld	h,0
418   0A00  E5          	push	hl
418   0A01              ;color;
418   0A01              	C_LINE	418,"Graphics\L2graphics.c"
418   0A01  21 06 00    	ld	hl,6	;const
418   0A04  39          	add	hl,sp
418   0A05  6E          	ld	l,(hl)
418   0A06  26 00       	ld	h,0
418   0A08  E5          	push	hl
418   0A09  CD 32 01    	call	_l2_plot_pixel
418   0A0C  C1          	pop	bc
418   0A0D  C1          	pop	bc
418   0A0E  C1          	pop	bc
418   0A0F              ;        }
418   0A0F              	C_LINE	418,"Graphics\L2graphics.c"
418   0A0F  C3 B4 09    	jp	i_61
418   0A12              .i_62
418   0A12              ;    }
418   0A12              	C_LINE	419,"Graphics\L2graphics.c"
419   0A12              .i_60
419   0A12              ;}
419   0A12              	C_LINE	421,"Graphics\L2graphics.c"
421   0A12  C9          	ret
421   0A13              
421   0A13              
421   0A13              ;
421   0A13              	C_LINE	423,"Graphics\L2graphics.c"
423   0A13              ;void l2_draw_diagonal_clip (int x0, int y0, int x1, int y1 , uint8_t color)
423   0A13              	C_LINE	424,"Graphics\L2graphics.c"
424   0A13              ;{
424   0A13              	C_LINE	425,"Graphics\L2graphics.c"
425   0A13              
425   0A13              ; Function l2_draw_diagonal_clip flags 0x00000200 __smallc
425   0A13              ; void l2_draw_diagonal_clip(int x0, int y0, int x1, int y1, unsigned char color)
425   0A13              ; parameter 'unsigned char color' at 2 size(1)
425   0A13              ; parameter 'int y1' at 4 size(2)
425   0A13              ; parameter 'int x1' at 6 size(2)
425   0A13              ; parameter 'int y0' at 8 size(2)
425   0A13              ; parameter 'int x0' at 10 size(2)
425   0A13              ._l2_draw_diagonal_clip
425   0A13              	C_LINE	425,"Graphics\L2graphics.c"
425   0A13              ;
425   0A13              	C_LINE	427,"Graphics\L2graphics.c"
427   0A13              ;    if (y0 > y1)
427   0A13              	C_LINE	428,"Graphics\L2graphics.c"
428   0A13              	C_LINE	428,"Graphics\L2graphics.c"
428   0A13  21 08 00    	ld	hl,8	;const
428   0A16  CD 00 00    	call	l_gintspsp	;
428   0A19  21 06 00    	ld	hl,6	;const
428   0A1C  39          	add	hl,sp
428   0A1D  CD 00 00    	call	l_gint	;
428   0A20  D1          	pop	de
428   0A21  CD 00 00    	call	l_gt
428   0A24  D2 52 0A    	jp	nc,i_64
428   0A27              ;    {
428   0A27              	C_LINE	429,"Graphics\L2graphics.c"
429   0A27              	C_LINE	429,"Graphics\L2graphics.c"
429   0A27              ;        l2_vx0 = x1;
429   0A27              	C_LINE	430,"Graphics\L2graphics.c"
430   0A27              	C_LINE	430,"Graphics\L2graphics.c"
430   0A27  21 06 00    	ld	hl,6	;const
430   0A2A  39          	add	hl,sp
430   0A2B  CD 00 00    	call	l_gint	;
430   0A2E  22 A7 17    	ld	(_l2_vx0),hl
430   0A31              ;        l2_vy0 = y1;
430   0A31              	C_LINE	431,"Graphics\L2graphics.c"
431   0A31              	C_LINE	431,"Graphics\L2graphics.c"
431   0A31  21 04 00    	ld	hl,4	;const
431   0A34  39          	add	hl,sp
431   0A35  CD 00 00    	call	l_gint	;
431   0A38  22 A9 17    	ld	(_l2_vy0),hl
431   0A3B              ;        l2_vx1 = x0;
431   0A3B              	C_LINE	432,"Graphics\L2graphics.c"
432   0A3B              	C_LINE	432,"Graphics\L2graphics.c"
432   0A3B  21 0A 00    	ld	hl,10	;const
432   0A3E  39          	add	hl,sp
432   0A3F  CD 00 00    	call	l_gint	;
432   0A42  22 AB 17    	ld	(_l2_vx1),hl
432   0A45              ;        l2_vy1 = y0;
432   0A45              	C_LINE	433,"Graphics\L2graphics.c"
433   0A45              	C_LINE	433,"Graphics\L2graphics.c"
433   0A45  21 08 00    	ld	hl,8	;const
433   0A48  39          	add	hl,sp
433   0A49  CD 00 00    	call	l_gint	;
433   0A4C  22 AD 17    	ld	(_l2_vy1),hl
433   0A4F              ;    }
433   0A4F              	C_LINE	434,"Graphics\L2graphics.c"
434   0A4F              ;    else
434   0A4F              	C_LINE	435,"Graphics\L2graphics.c"
435   0A4F  C3 7A 0A    	jp	i_65
435   0A52              .i_64
435   0A52              ;    {
435   0A52              	C_LINE	436,"Graphics\L2graphics.c"
436   0A52              	C_LINE	436,"Graphics\L2graphics.c"
436   0A52              ;        l2_vx0 = x0;
436   0A52              	C_LINE	437,"Graphics\L2graphics.c"
437   0A52              	C_LINE	437,"Graphics\L2graphics.c"
437   0A52  21 0A 00    	ld	hl,10	;const
437   0A55  39          	add	hl,sp
437   0A56  CD 00 00    	call	l_gint	;
437   0A59  22 A7 17    	ld	(_l2_vx0),hl
437   0A5C              ;        l2_vy0 = y0;
437   0A5C              	C_LINE	438,"Graphics\L2graphics.c"
438   0A5C              	C_LINE	438,"Graphics\L2graphics.c"
438   0A5C  21 08 00    	ld	hl,8	;const
438   0A5F  39          	add	hl,sp
438   0A60  CD 00 00    	call	l_gint	;
438   0A63  22 A9 17    	ld	(_l2_vy0),hl
438   0A66              ;        l2_vx1 = x1;
438   0A66              	C_LINE	439,"Graphics\L2graphics.c"
439   0A66              	C_LINE	439,"Graphics\L2graphics.c"
439   0A66  21 06 00    	ld	hl,6	;const
439   0A69  39          	add	hl,sp
439   0A6A  CD 00 00    	call	l_gint	;
439   0A6D  22 AB 17    	ld	(_l2_vx1),hl
439   0A70              ;        l2_vy1 = y1;
439   0A70              	C_LINE	440,"Graphics\L2graphics.c"
440   0A70              	C_LINE	440,"Graphics\L2graphics.c"
440   0A70  21 04 00    	ld	hl,4	;const
440   0A73  39          	add	hl,sp
440   0A74  CD 00 00    	call	l_gint	;
440   0A77  22 AD 17    	ld	(_l2_vy1),hl
440   0A7A              ;    }
440   0A7A              	C_LINE	441,"Graphics\L2graphics.c"
441   0A7A              .i_65
441   0A7A              ;
441   0A7A              	C_LINE	442,"Graphics\L2graphics.c"
442   0A7A              ;    l2_dy = l2_vy1 - l2_vy0;
442   0A7A              	C_LINE	443,"Graphics\L2graphics.c"
443   0A7A              	C_LINE	443,"Graphics\L2graphics.c"
443   0A7A  ED 5B AD 17 	ld	de,(_l2_vy1)
443   0A7E  2A A9 17    	ld	hl,(_l2_vy0)
443   0A81  EB          	ex	de,hl
443   0A82  A7          	and	a
443   0A83  ED 52       	sbc	hl,de
443   0A85  22 A3 17    	ld	(_l2_dy),hl
443   0A88              ;    l2_dx = l2_vx1 - l2_vx0;
443   0A88              	C_LINE	444,"Graphics\L2graphics.c"
444   0A88              	C_LINE	444,"Graphics\L2graphics.c"
444   0A88  ED 5B AB 17 	ld	de,(_l2_vx1)
444   0A8C  2A A7 17    	ld	hl,(_l2_vx0)
444   0A8F  EB          	ex	de,hl
444   0A90  A7          	and	a
444   0A91  ED 52       	sbc	hl,de
444   0A93  22 A5 17    	ld	(_l2_dx),hl
444   0A96              ;    l2_layer_shift = 0;
444   0A96              	C_LINE	445,"Graphics\L2graphics.c"
445   0A96              	C_LINE	445,"Graphics\L2graphics.c"
445   0A96  21 00 00    	ld	hl,0 % 256	;const
445   0A99  7D          	ld	a,l
445   0A9A  32 9C 17    	ld	(_l2_layer_shift),a
445   0A9D              ;    if (l2_dx < 0)
445   0A9D              	C_LINE	447,"Graphics\L2graphics.c"
447   0A9D              	C_LINE	447,"Graphics\L2graphics.c"
447   0A9D  2A A5 17    	ld	hl,(_l2_dx)
447   0AA0  7C          	ld	a,h
447   0AA1  17          	rla
447   0AA2  D2 B7 0A    	jp	nc,i_66
447   0AA5              ;    {
447   0AA5              	C_LINE	448,"Graphics\L2graphics.c"
448   0AA5              	C_LINE	448,"Graphics\L2graphics.c"
448   0AA5              ;        l2_dx = -l2_dx;
448   0AA5              	C_LINE	449,"Graphics\L2graphics.c"
449   0AA5              	C_LINE	449,"Graphics\L2graphics.c"
449   0AA5  2A A5 17    	ld	hl,(_l2_dx)
449   0AA8  CD 00 00    	call	l_neg
449   0AAB  22 A5 17    	ld	(_l2_dx),hl
449   0AAE              ;        l2_stepx = -1;
449   0AAE              	C_LINE	450,"Graphics\L2graphics.c"
450   0AAE              	C_LINE	450,"Graphics\L2graphics.c"
450   0AAE  21 FF FF    	ld	hl,65535	;const
450   0AB1  22 9D 17    	ld	(_l2_stepx),hl
450   0AB4              ;    }
450   0AB4              	C_LINE	451,"Graphics\L2graphics.c"
451   0AB4              ;    else
451   0AB4              	C_LINE	452,"Graphics\L2graphics.c"
452   0AB4  C3 BD 0A    	jp	i_67
452   0AB7              .i_66
452   0AB7              ;    {
452   0AB7              	C_LINE	453,"Graphics\L2graphics.c"
453   0AB7              	C_LINE	453,"Graphics\L2graphics.c"
453   0AB7              ;        l2_stepx = 1;
453   0AB7              	C_LINE	454,"Graphics\L2graphics.c"
454   0AB7              	C_LINE	454,"Graphics\L2graphics.c"
454   0AB7  21 01 00    	ld	hl,1	;const
454   0ABA  22 9D 17    	ld	(_l2_stepx),hl
454   0ABD              ;    }
454   0ABD              	C_LINE	455,"Graphics\L2graphics.c"
455   0ABD              .i_67
455   0ABD              ;
455   0ABD              	C_LINE	456,"Graphics\L2graphics.c"
456   0ABD              ;
456   0ABD              	C_LINE	457,"Graphics\L2graphics.c"
457   0ABD              ;    l2_dy <<= 1;
457   0ABD              	C_LINE	458,"Graphics\L2graphics.c"
458   0ABD              	C_LINE	458,"Graphics\L2graphics.c"
458   0ABD  2A A3 17    	ld	hl,(_l2_dy)
458   0AC0  29          	add	hl,hl
458   0AC1  22 A3 17    	ld	(_l2_dy),hl
458   0AC4              ;    l2_dx <<= 1;
458   0AC4              	C_LINE	459,"Graphics\L2graphics.c"
459   0AC4              	C_LINE	459,"Graphics\L2graphics.c"
459   0AC4  2A A5 17    	ld	hl,(_l2_dx)
459   0AC7  29          	add	hl,hl
459   0AC8  22 A5 17    	ld	(_l2_dx),hl
459   0ACB              ;	if (l2_vx0 >0 && l2_vx0 <255 && l2_vy0 > 0 && l2_vy0 <=  127 ) l2_plot_pixel(l2_vx0,l2_vy0,color);
459   0ACB              	C_LINE	460,"Graphics\L2graphics.c"
460   0ACB              	C_LINE	460,"Graphics\L2graphics.c"
460   0ACB  2A A7 17    	ld	hl,(_l2_vx0)
460   0ACE  11 00 00    	ld	de,0
460   0AD1  EB          	ex	de,hl
460   0AD2  CD 00 00    	call	l_gt
460   0AD5  D2 00 0B    	jp	nc,i_69
460   0AD8  2A A7 17    	ld	hl,(_l2_vx0)
460   0ADB  7D          	ld	a,l
460   0ADC  D6 FF       	sub	255
460   0ADE  7C          	ld	a,h
460   0ADF  17          	rla
460   0AE0  3F          	ccf
460   0AE1  1F          	rra
460   0AE2  DE 80       	sbc	128
460   0AE4  D2 00 0B    	jp	nc,i_69
460   0AE7  2A A9 17    	ld	hl,(_l2_vy0)
460   0AEA  11 00 00    	ld	de,0
460   0AED  EB          	ex	de,hl
460   0AEE  CD 00 00    	call	l_gt
460   0AF1  D2 00 0B    	jp	nc,i_69
460   0AF4  2A A9 17    	ld	hl,(_l2_vy0)
460   0AF7  11 7F 00    	ld	de,127
460   0AFA  EB          	ex	de,hl
460   0AFB  CD 00 00    	call	l_le
460   0AFE  38 03       	jr	c,i_70_i_69
460   0B00              .i_69
460   0B00  C3 1D 0B    	jp	i_68
460   0B03              .i_70_i_69
460   0B03              ;l2_vx0;
460   0B03              	C_LINE	461,"Graphics\L2graphics.c"
461   0B03  2A A7 17    	ld	hl,(_l2_vx0)
461   0B06  26 00       	ld	h,0
461   0B08  E5          	push	hl
461   0B09              ;l2_vy0;
461   0B09              	C_LINE	461,"Graphics\L2graphics.c"
461   0B09  2A A9 17    	ld	hl,(_l2_vy0)
461   0B0C  26 00       	ld	h,0
461   0B0E  E5          	push	hl
461   0B0F              ;color;
461   0B0F              	C_LINE	461,"Graphics\L2graphics.c"
461   0B0F  21 06 00    	ld	hl,6	;const
461   0B12  39          	add	hl,sp
461   0B13  6E          	ld	l,(hl)
461   0B14  26 00       	ld	h,0
461   0B16  E5          	push	hl
461   0B17  CD 32 01    	call	_l2_plot_pixel
461   0B1A  C1          	pop	bc
461   0B1B  C1          	pop	bc
461   0B1C  C1          	pop	bc
461   0B1D              ;    if (l2_dx > l2_dy)
461   0B1D              	C_LINE	462,"Graphics\L2graphics.c"
462   0B1D              .i_68
462   0B1D              	C_LINE	462,"Graphics\L2graphics.c"
462   0B1D  ED 5B A5 17 	ld	de,(_l2_dx)
462   0B21  2A A3 17    	ld	hl,(_l2_dy)
462   0B24  CD 00 00    	call	l_gt
462   0B27  D2 0A 0C    	jp	nc,i_71
462   0B2A              ;    {
462   0B2A              	C_LINE	463,"Graphics\L2graphics.c"
463   0B2A              	C_LINE	463,"Graphics\L2graphics.c"
463   0B2A              ;        l2_fraction = l2_dy - (l2_dx >> 1);
463   0B2A              	C_LINE	464,"Graphics\L2graphics.c"
464   0B2A              	C_LINE	464,"Graphics\L2graphics.c"
464   0B2A  2A A3 17    	ld	hl,(_l2_dy)
464   0B2D  E5          	push	hl
464   0B2E  2A A5 17    	ld	hl,(_l2_dx)
464   0B31  CB 2C       	sra	h
464   0B33  CB 1D       	rr	l
464   0B35  D1          	pop	de
464   0B36  EB          	ex	de,hl
464   0B37  A7          	and	a
464   0B38  ED 52       	sbc	hl,de
464   0B3A  22 A1 17    	ld	(_l2_fraction),hl
464   0B3D              ;        while (l2_vx0 != l2_vx1)
464   0B3D              	C_LINE	465,"Graphics\L2graphics.c"
465   0B3D              	C_LINE	465,"Graphics\L2graphics.c"
465   0B3D              .i_72
465   0B3D  ED 5B A7 17 	ld	de,(_l2_vx0)
465   0B41  2A AB 17    	ld	hl,(_l2_vx1)
465   0B44  CD 00 00    	call	l_ne
465   0B47  D2 07 0C    	jp	nc,i_73
465   0B4A              ;        {
465   0B4A              	C_LINE	466,"Graphics\L2graphics.c"
466   0B4A              	C_LINE	466,"Graphics\L2graphics.c"
466   0B4A              ;            if (l2_fraction >= 0)
466   0B4A              	C_LINE	467,"Graphics\L2graphics.c"
467   0B4A              	C_LINE	467,"Graphics\L2graphics.c"
467   0B4A  2A A1 17    	ld	hl,(_l2_fraction)
467   0B4D  7C          	ld	a,h
467   0B4E  17          	rla
467   0B4F  3F          	ccf
467   0B50  D2 68 0B    	jp	nc,i_74
467   0B53              ;            {
467   0B53              	C_LINE	468,"Graphics\L2graphics.c"
468   0B53              	C_LINE	468,"Graphics\L2graphics.c"
468   0B53              ;                ++l2_vy0;
468   0B53              	C_LINE	469,"Graphics\L2graphics.c"
469   0B53              	C_LINE	469,"Graphics\L2graphics.c"
469   0B53  2A A9 17    	ld	hl,(_l2_vy0)
469   0B56  23          	inc	hl
469   0B57  22 A9 17    	ld	(_l2_vy0),hl
469   0B5A              ;                l2_fraction -= l2_dx;
469   0B5A              	C_LINE	470,"Graphics\L2graphics.c"
470   0B5A              	C_LINE	470,"Graphics\L2graphics.c"
470   0B5A  ED 5B A1 17 	ld	de,(_l2_fraction)
470   0B5E  2A A5 17    	ld	hl,(_l2_dx)
470   0B61  EB          	ex	de,hl
470   0B62  A7          	and	a
470   0B63  ED 52       	sbc	hl,de
470   0B65  22 A1 17    	ld	(_l2_fraction),hl
470   0B68              ;            }
470   0B68              	C_LINE	471,"Graphics\L2graphics.c"
471   0B68              ;            l2_vx0 += l2_stepx;
471   0B68              	C_LINE	472,"Graphics\L2graphics.c"
472   0B68              .i_74
472   0B68              	C_LINE	472,"Graphics\L2graphics.c"
472   0B68  ED 5B A7 17 	ld	de,(_l2_vx0)
472   0B6C  2A 9D 17    	ld	hl,(_l2_stepx)
472   0B6F  19          	add	hl,de
472   0B70  22 A7 17    	ld	(_l2_vx0),hl
472   0B73              ;			if (l2_stepx == 1 && l2_vx0 >  127 ) break;
472   0B73              	C_LINE	473,"Graphics\L2graphics.c"
473   0B73              	C_LINE	473,"Graphics\L2graphics.c"
473   0B73  2A 9D 17    	ld	hl,(_l2_stepx)
473   0B76  2B          	dec	hl
473   0B77  7C          	ld	a,h
473   0B78  B5          	or	l
473   0B79  C2 88 0B    	jp	nz,i_76
473   0B7C  2A A7 17    	ld	hl,(_l2_vx0)
473   0B7F  11 7F 00    	ld	de,127
473   0B82  EB          	ex	de,hl
473   0B83  CD 00 00    	call	l_gt
473   0B86  38 03       	jr	c,i_77_i_76
473   0B88              .i_76
473   0B88  C3 8E 0B    	jp	i_75
473   0B8B              .i_77_i_76
473   0B8B  C3 07 0C    	jp	i_73
473   0B8E              ;			if (l2_stepx == -1 && l2_vx0 < 0) break;
473   0B8E              	C_LINE	474,"Graphics\L2graphics.c"
474   0B8E              .i_75
474   0B8E              	C_LINE	474,"Graphics\L2graphics.c"
474   0B8E  2A 9D 17    	ld	hl,(_l2_stepx)
474   0B91  11 FF FF    	ld	de,65535
474   0B94  A7          	and	a
474   0B95  ED 52       	sbc	hl,de
474   0B97  C2 A1 0B    	jp	nz,i_79
474   0B9A  2A A7 17    	ld	hl,(_l2_vx0)
474   0B9D  7C          	ld	a,h
474   0B9E  17          	rla
474   0B9F  38 03       	jr	c,i_80_i_79
474   0BA1              .i_79
474   0BA1  C3 A7 0B    	jp	i_78
474   0BA4              .i_80_i_79
474   0BA4  C3 07 0C    	jp	i_73
474   0BA7              ;            l2_fraction += l2_dy;
474   0BA7              	C_LINE	475,"Graphics\L2graphics.c"
475   0BA7              .i_78
475   0BA7              	C_LINE	475,"Graphics\L2graphics.c"
475   0BA7  ED 5B A1 17 	ld	de,(_l2_fraction)
475   0BAB  2A A3 17    	ld	hl,(_l2_dy)
475   0BAE  19          	add	hl,de
475   0BAF  22 A1 17    	ld	(_l2_fraction),hl
475   0BB2              ;			if (l2_vx0 >0 && l2_vx0 <255 && l2_vy0 > 0 && l2_vy0 <=  127 )
475   0BB2              	C_LINE	476,"Graphics\L2graphics.c"
476   0BB2              	C_LINE	476,"Graphics\L2graphics.c"
476   0BB2  2A A7 17    	ld	hl,(_l2_vx0)
476   0BB5  11 00 00    	ld	de,0
476   0BB8  EB          	ex	de,hl
476   0BB9  CD 00 00    	call	l_gt
476   0BBC  D2 E7 0B    	jp	nc,i_82
476   0BBF  2A A7 17    	ld	hl,(_l2_vx0)
476   0BC2  7D          	ld	a,l
476   0BC3  D6 FF       	sub	255
476   0BC5  7C          	ld	a,h
476   0BC6  17          	rla
476   0BC7  3F          	ccf
476   0BC8  1F          	rra
476   0BC9  DE 80       	sbc	128
476   0BCB  D2 E7 0B    	jp	nc,i_82
476   0BCE  2A A9 17    	ld	hl,(_l2_vy0)
476   0BD1  11 00 00    	ld	de,0
476   0BD4  EB          	ex	de,hl
476   0BD5  CD 00 00    	call	l_gt
476   0BD8  D2 E7 0B    	jp	nc,i_82
476   0BDB  2A A9 17    	ld	hl,(_l2_vy0)
476   0BDE  11 7F 00    	ld	de,127
476   0BE1  EB          	ex	de,hl
476   0BE2  CD 00 00    	call	l_le
476   0BE5  38 03       	jr	c,i_83_i_82
476   0BE7              .i_82
476   0BE7  C3 04 0C    	jp	i_81
476   0BEA              .i_83_i_82
476   0BEA              ;			{
476   0BEA              	C_LINE	477,"Graphics\L2graphics.c"
477   0BEA              	C_LINE	477,"Graphics\L2graphics.c"
477   0BEA              ;				l2_plot_pixel(l2_vx0,l2_vy0,color);
477   0BEA              	C_LINE	478,"Graphics\L2graphics.c"
478   0BEA              	C_LINE	478,"Graphics\L2graphics.c"
478   0BEA              ;l2_vx0;
478   0BEA              	C_LINE	479,"Graphics\L2graphics.c"
479   0BEA  2A A7 17    	ld	hl,(_l2_vx0)
479   0BED  26 00       	ld	h,0
479   0BEF  E5          	push	hl
479   0BF0              ;l2_vy0;
479   0BF0              	C_LINE	479,"Graphics\L2graphics.c"
479   0BF0  2A A9 17    	ld	hl,(_l2_vy0)
479   0BF3  26 00       	ld	h,0
479   0BF5  E5          	push	hl
479   0BF6              ;color;
479   0BF6              	C_LINE	479,"Graphics\L2graphics.c"
479   0BF6  21 06 00    	ld	hl,6	;const
479   0BF9  39          	add	hl,sp
479   0BFA  6E          	ld	l,(hl)
479   0BFB  26 00       	ld	h,0
479   0BFD  E5          	push	hl
479   0BFE  CD 32 01    	call	_l2_plot_pixel
479   0C01  C1          	pop	bc
479   0C02  C1          	pop	bc
479   0C03  C1          	pop	bc
479   0C04              ;			}
479   0C04              	C_LINE	479,"Graphics\L2graphics.c"
479   0C04              ;        }
479   0C04              	C_LINE	480,"Graphics\L2graphics.c"
480   0C04              .i_81
480   0C04  C3 3D 0B    	jp	i_72
480   0C07              .i_73
480   0C07              ;    }
480   0C07              	C_LINE	481,"Graphics\L2graphics.c"
481   0C07              ;    else
481   0C07              	C_LINE	482,"Graphics\L2graphics.c"
482   0C07  C3 C3 0C    	jp	i_84
482   0C0A              .i_71
482   0C0A              ;    {
482   0C0A              	C_LINE	483,"Graphics\L2graphics.c"
483   0C0A              	C_LINE	483,"Graphics\L2graphics.c"
483   0C0A              ;        l2_fraction = l2_dx - (l2_dy >> 1);
483   0C0A              	C_LINE	484,"Graphics\L2graphics.c"
484   0C0A              	C_LINE	484,"Graphics\L2graphics.c"
484   0C0A  2A A5 17    	ld	hl,(_l2_dx)
484   0C0D  E5          	push	hl
484   0C0E  2A A3 17    	ld	hl,(_l2_dy)
484   0C11  CB 2C       	sra	h
484   0C13  CB 1D       	rr	l
484   0C15  D1          	pop	de
484   0C16  EB          	ex	de,hl
484   0C17  A7          	and	a
484   0C18  ED 52       	sbc	hl,de
484   0C1A  22 A1 17    	ld	(_l2_fraction),hl
484   0C1D              ;        while (l2_vy0 != l2_vy1)
484   0C1D              	C_LINE	485,"Graphics\L2graphics.c"
485   0C1D              	C_LINE	485,"Graphics\L2graphics.c"
485   0C1D              .i_85
485   0C1D  ED 5B A9 17 	ld	de,(_l2_vy0)
485   0C21  2A AD 17    	ld	hl,(_l2_vy1)
485   0C24  CD 00 00    	call	l_ne
485   0C27  D2 C3 0C    	jp	nc,i_86
485   0C2A              ;        {
485   0C2A              	C_LINE	486,"Graphics\L2graphics.c"
486   0C2A              	C_LINE	486,"Graphics\L2graphics.c"
486   0C2A              ;            if (l2_fraction >= 0)
486   0C2A              	C_LINE	487,"Graphics\L2graphics.c"
487   0C2A              	C_LINE	487,"Graphics\L2graphics.c"
487   0C2A  2A A1 17    	ld	hl,(_l2_fraction)
487   0C2D  7C          	ld	a,h
487   0C2E  17          	rla
487   0C2F  3F          	ccf
487   0C30  D2 4C 0C    	jp	nc,i_87
487   0C33              ;            {
487   0C33              	C_LINE	488,"Graphics\L2graphics.c"
488   0C33              	C_LINE	488,"Graphics\L2graphics.c"
488   0C33              ;               l2_vx0 += l2_stepx;
488   0C33              	C_LINE	489,"Graphics\L2graphics.c"
489   0C33              	C_LINE	489,"Graphics\L2graphics.c"
489   0C33  ED 5B A7 17 	ld	de,(_l2_vx0)
489   0C37  2A 9D 17    	ld	hl,(_l2_stepx)
489   0C3A  19          	add	hl,de
489   0C3B  22 A7 17    	ld	(_l2_vx0),hl
489   0C3E              ;               l2_fraction -= l2_dy;
489   0C3E              	C_LINE	490,"Graphics\L2graphics.c"
490   0C3E              	C_LINE	490,"Graphics\L2graphics.c"
490   0C3E  ED 5B A1 17 	ld	de,(_l2_fraction)
490   0C42  2A A3 17    	ld	hl,(_l2_dy)
490   0C45  EB          	ex	de,hl
490   0C46  A7          	and	a
490   0C47  ED 52       	sbc	hl,de
490   0C49  22 A1 17    	ld	(_l2_fraction),hl
490   0C4C              ;            }
490   0C4C              	C_LINE	491,"Graphics\L2graphics.c"
491   0C4C              ;            l2_fraction += l2_dx;
491   0C4C              	C_LINE	492,"Graphics\L2graphics.c"
492   0C4C              .i_87
492   0C4C              	C_LINE	492,"Graphics\L2graphics.c"
492   0C4C  ED 5B A1 17 	ld	de,(_l2_fraction)
492   0C50  2A A5 17    	ld	hl,(_l2_dx)
492   0C53  19          	add	hl,de
492   0C54  22 A1 17    	ld	(_l2_fraction),hl
492   0C57              ;            ++l2_vy0;
492   0C57              	C_LINE	493,"Graphics\L2graphics.c"
493   0C57              	C_LINE	493,"Graphics\L2graphics.c"
493   0C57  2A A9 17    	ld	hl,(_l2_vy0)
493   0C5A  23          	inc	hl
493   0C5B  22 A9 17    	ld	(_l2_vy0),hl
493   0C5E              ;			if (l2_vy0 >  127 ) break;
493   0C5E              	C_LINE	494,"Graphics\L2graphics.c"
494   0C5E              	C_LINE	494,"Graphics\L2graphics.c"
494   0C5E  2A A9 17    	ld	hl,(_l2_vy0)
494   0C61  11 7F 00    	ld	de,127
494   0C64  EB          	ex	de,hl
494   0C65  CD 00 00    	call	l_gt
494   0C68  D2 6E 0C    	jp	nc,i_88
494   0C6B  C3 C3 0C    	jp	i_86
494   0C6E              ;            if (l2_vx0 >0 && l2_vx0 <255 && l2_vy0 > 0 && l2_vy0 <=  127 )
494   0C6E              	C_LINE	495,"Graphics\L2graphics.c"
495   0C6E              .i_88
495   0C6E              	C_LINE	495,"Graphics\L2graphics.c"
495   0C6E  2A A7 17    	ld	hl,(_l2_vx0)
495   0C71  11 00 00    	ld	de,0
495   0C74  EB          	ex	de,hl
495   0C75  CD 00 00    	call	l_gt
495   0C78  D2 A3 0C    	jp	nc,i_90
495   0C7B  2A A7 17    	ld	hl,(_l2_vx0)
495   0C7E  7D          	ld	a,l
495   0C7F  D6 FF       	sub	255
495   0C81  7C          	ld	a,h
495   0C82  17          	rla
495   0C83  3F          	ccf
495   0C84  1F          	rra
495   0C85  DE 80       	sbc	128
495   0C87  D2 A3 0C    	jp	nc,i_90
495   0C8A  2A A9 17    	ld	hl,(_l2_vy0)
495   0C8D  11 00 00    	ld	de,0
495   0C90  EB          	ex	de,hl
495   0C91  CD 00 00    	call	l_gt
495   0C94  D2 A3 0C    	jp	nc,i_90
495   0C97  2A A9 17    	ld	hl,(_l2_vy0)
495   0C9A  11 7F 00    	ld	de,127
495   0C9D  EB          	ex	de,hl
495   0C9E  CD 00 00    	call	l_le
495   0CA1  38 03       	jr	c,i_91_i_90
495   0CA3              .i_90
495   0CA3  C3 C0 0C    	jp	i_89
495   0CA6              .i_91_i_90
495   0CA6              ;			{
495   0CA6              	C_LINE	496,"Graphics\L2graphics.c"
496   0CA6              	C_LINE	496,"Graphics\L2graphics.c"
496   0CA6              ;				l2_plot_pixel(l2_vx0,l2_vy0,color);
496   0CA6              	C_LINE	497,"Graphics\L2graphics.c"
497   0CA6              	C_LINE	497,"Graphics\L2graphics.c"
497   0CA6              ;l2_vx0;
497   0CA6              	C_LINE	498,"Graphics\L2graphics.c"
498   0CA6  2A A7 17    	ld	hl,(_l2_vx0)
498   0CA9  26 00       	ld	h,0
498   0CAB  E5          	push	hl
498   0CAC              ;l2_vy0;
498   0CAC              	C_LINE	498,"Graphics\L2graphics.c"
498   0CAC  2A A9 17    	ld	hl,(_l2_vy0)
498   0CAF  26 00       	ld	h,0
498   0CB1  E5          	push	hl
498   0CB2              ;color;
498   0CB2              	C_LINE	498,"Graphics\L2graphics.c"
498   0CB2  21 06 00    	ld	hl,6	;const
498   0CB5  39          	add	hl,sp
498   0CB6  6E          	ld	l,(hl)
498   0CB7  26 00       	ld	h,0
498   0CB9  E5          	push	hl
498   0CBA  CD 32 01    	call	_l2_plot_pixel
498   0CBD  C1          	pop	bc
498   0CBE  C1          	pop	bc
498   0CBF  C1          	pop	bc
498   0CC0              ;			}
498   0CC0              	C_LINE	498,"Graphics\L2graphics.c"
498   0CC0              ;        }
498   0CC0              	C_LINE	499,"Graphics\L2graphics.c"
499   0CC0              .i_89
499   0CC0  C3 1D 0C    	jp	i_85
499   0CC3              .i_86
499   0CC3              ;    }
499   0CC3              	C_LINE	500,"Graphics\L2graphics.c"
500   0CC3              .i_84
500   0CC3              ;}
500   0CC3              	C_LINE	502,"Graphics\L2graphics.c"
502   0CC3  C9          	ret
502   0CC4              
502   0CC4              
502   0CC4              ;
502   0CC4              	C_LINE	503,"Graphics\L2graphics.c"
503   0CC4              ;void l2_draw_line (uint8_t x0, uint8_t y0, uint8_t x1, uint8_t y1 , uint8_t color)
503   0CC4              	C_LINE	504,"Graphics\L2graphics.c"
504   0CC4              ;{
504   0CC4              	C_LINE	505,"Graphics\L2graphics.c"
505   0CC4              
505   0CC4              ; Function l2_draw_line flags 0x00000200 __smallc
505   0CC4              ; void l2_draw_line(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, unsigned char color)
505   0CC4              ; parameter 'unsigned char color' at 2 size(1)
505   0CC4              ; parameter 'unsigned char y1' at 4 size(1)
505   0CC4              ; parameter 'unsigned char x1' at 6 size(1)
505   0CC4              ; parameter 'unsigned char y0' at 8 size(1)
505   0CC4              ; parameter 'unsigned char x0' at 10 size(1)
505   0CC4              ._l2_draw_line
505   0CC4              	C_LINE	505,"Graphics\L2graphics.c"
505   0CC4              ;	if (x0 == x1)
505   0CC4              	C_LINE	506,"Graphics\L2graphics.c"
506   0CC4              	C_LINE	506,"Graphics\L2graphics.c"
506   0CC4  21 0A 00    	ld	hl,10	;const
506   0CC7  39          	add	hl,sp
506   0CC8  5E          	ld	e,(hl)
506   0CC9  16 00       	ld	d,0
506   0CCB  21 06 00    	ld	hl,6	;const
506   0CCE  39          	add	hl,sp
506   0CCF  6E          	ld	l,(hl)
506   0CD0  26 00       	ld	h,0
506   0CD2  CD 00 00    	call	l_eq
506   0CD5  D2 02 0D    	jp	nc,i_92
506   0CD8              ;	{
506   0CD8              	C_LINE	507,"Graphics\L2graphics.c"
507   0CD8              	C_LINE	507,"Graphics\L2graphics.c"
507   0CD8              ;		l2_draw_horz_line_to(x0, x1, y1, color);
507   0CD8              	C_LINE	508,"Graphics\L2graphics.c"
508   0CD8              	C_LINE	508,"Graphics\L2graphics.c"
508   0CD8              ;x0;
508   0CD8              	C_LINE	509,"Graphics\L2graphics.c"
509   0CD8  21 0A 00    	ld	hl,10	;const
509   0CDB  39          	add	hl,sp
509   0CDC  6E          	ld	l,(hl)
509   0CDD  26 00       	ld	h,0
509   0CDF  E5          	push	hl
509   0CE0              ;x1;
509   0CE0              	C_LINE	509,"Graphics\L2graphics.c"
509   0CE0  21 08 00    	ld	hl,8	;const
509   0CE3  39          	add	hl,sp
509   0CE4  6E          	ld	l,(hl)
509   0CE5  26 00       	ld	h,0
509   0CE7  E5          	push	hl
509   0CE8              ;y1;
509   0CE8              	C_LINE	509,"Graphics\L2graphics.c"
509   0CE8  21 08 00    	ld	hl,8	;const
509   0CEB  39          	add	hl,sp
509   0CEC  6E          	ld	l,(hl)
509   0CED  26 00       	ld	h,0
509   0CEF  E5          	push	hl
509   0CF0              ;color;
509   0CF0              	C_LINE	509,"Graphics\L2graphics.c"
509   0CF0  21 08 00    	ld	hl,8	;const
509   0CF3  39          	add	hl,sp
509   0CF4  6E          	ld	l,(hl)
509   0CF5  26 00       	ld	h,0
509   0CF7  E5          	push	hl
509   0CF8  CD 21 05    	call	_l2_draw_horz_line_to
509   0CFB  C1          	pop	bc
509   0CFC  C1          	pop	bc
509   0CFD  C1          	pop	bc
509   0CFE  C1          	pop	bc
509   0CFF              ;	}
509   0CFF              	C_LINE	509,"Graphics\L2graphics.c"
509   0CFF              ;	else
509   0CFF              	C_LINE	510,"Graphics\L2graphics.c"
510   0CFF  C3 70 0D    	jp	i_93
510   0D02              .i_92
510   0D02              ;	{
510   0D02              	C_LINE	511,"Graphics\L2graphics.c"
511   0D02              	C_LINE	511,"Graphics\L2graphics.c"
511   0D02              ;		if (y0 == y1)
511   0D02              	C_LINE	512,"Graphics\L2graphics.c"
512   0D02              	C_LINE	512,"Graphics\L2graphics.c"
512   0D02  21 08 00    	ld	hl,8	;const
512   0D05  39          	add	hl,sp
512   0D06  5E          	ld	e,(hl)
512   0D07  16 00       	ld	d,0
512   0D09  21 04 00    	ld	hl,4	;const
512   0D0C  39          	add	hl,sp
512   0D0D  6E          	ld	l,(hl)
512   0D0E  26 00       	ld	h,0
512   0D10  CD 00 00    	call	l_eq
512   0D13  D2 40 0D    	jp	nc,i_94
512   0D16              ;		{
512   0D16              	C_LINE	513,"Graphics\L2graphics.c"
513   0D16              	C_LINE	513,"Graphics\L2graphics.c"
513   0D16              ;			l2_draw_vert_line_to(x0, y0, y1, color);
513   0D16              	C_LINE	514,"Graphics\L2graphics.c"
514   0D16              	C_LINE	514,"Graphics\L2graphics.c"
514   0D16              ;x0;
514   0D16              	C_LINE	515,"Graphics\L2graphics.c"
515   0D16  21 0A 00    	ld	hl,10	;const
515   0D19  39          	add	hl,sp
515   0D1A  6E          	ld	l,(hl)
515   0D1B  26 00       	ld	h,0
515   0D1D  E5          	push	hl
515   0D1E              ;y0;
515   0D1E              	C_LINE	515,"Graphics\L2graphics.c"
515   0D1E  21 0A 00    	ld	hl,10	;const
515   0D21  39          	add	hl,sp
515   0D22  6E          	ld	l,(hl)
515   0D23  26 00       	ld	h,0
515   0D25  E5          	push	hl
515   0D26              ;y1;
515   0D26              	C_LINE	515,"Graphics\L2graphics.c"
515   0D26  21 08 00    	ld	hl,8	;const
515   0D29  39          	add	hl,sp
515   0D2A  6E          	ld	l,(hl)
515   0D2B  26 00       	ld	h,0
515   0D2D  E5          	push	hl
515   0D2E              ;color;
515   0D2E              	C_LINE	515,"Graphics\L2graphics.c"
515   0D2E  21 08 00    	ld	hl,8	;const
515   0D31  39          	add	hl,sp
515   0D32  6E          	ld	l,(hl)
515   0D33  26 00       	ld	h,0
515   0D35  E5          	push	hl
515   0D36  CD F0 05    	call	_l2_draw_vert_line_to
515   0D39  C1          	pop	bc
515   0D3A  C1          	pop	bc
515   0D3B  C1          	pop	bc
515   0D3C  C1          	pop	bc
515   0D3D              ;		}
515   0D3D              	C_LINE	515,"Graphics\L2graphics.c"
515   0D3D              ;		else
515   0D3D              	C_LINE	516,"Graphics\L2graphics.c"
516   0D3D  C3 70 0D    	jp	i_95
516   0D40              .i_94
516   0D40              ;		{
516   0D40              	C_LINE	517,"Graphics\L2graphics.c"
517   0D40              	C_LINE	517,"Graphics\L2graphics.c"
517   0D40              ;			l2_draw_diagonal(x0, y0, x1, y1, color);
517   0D40              	C_LINE	518,"Graphics\L2graphics.c"
518   0D40              	C_LINE	518,"Graphics\L2graphics.c"
518   0D40              ;x0;
518   0D40              	C_LINE	519,"Graphics\L2graphics.c"
519   0D40  21 0A 00    	ld	hl,10	;const
519   0D43  39          	add	hl,sp
519   0D44  6E          	ld	l,(hl)
519   0D45  26 00       	ld	h,0
519   0D47  E5          	push	hl
519   0D48              ;y0;
519   0D48              	C_LINE	519,"Graphics\L2graphics.c"
519   0D48  21 0A 00    	ld	hl,10	;const
519   0D4B  39          	add	hl,sp
519   0D4C  6E          	ld	l,(hl)
519   0D4D  26 00       	ld	h,0
519   0D4F  E5          	push	hl
519   0D50              ;x1;
519   0D50              	C_LINE	519,"Graphics\L2graphics.c"
519   0D50  21 0A 00    	ld	hl,10	;const
519   0D53  39          	add	hl,sp
519   0D54  6E          	ld	l,(hl)
519   0D55  26 00       	ld	h,0
519   0D57  E5          	push	hl
519   0D58              ;y1;
519   0D58              	C_LINE	519,"Graphics\L2graphics.c"
519   0D58  21 0A 00    	ld	hl,10	;const
519   0D5B  39          	add	hl,sp
519   0D5C  6E          	ld	l,(hl)
519   0D5D  26 00       	ld	h,0
519   0D5F  E5          	push	hl
519   0D60              ;color;
519   0D60              	C_LINE	519,"Graphics\L2graphics.c"
519   0D60  21 0A 00    	ld	hl,10	;const
519   0D63  39          	add	hl,sp
519   0D64  6E          	ld	l,(hl)
519   0D65  26 00       	ld	h,0
519   0D67  E5          	push	hl
519   0D68  CD 4E 08    	call	_l2_draw_diagonal
519   0D6B  C1          	pop	bc
519   0D6C  C1          	pop	bc
519   0D6D  C1          	pop	bc
519   0D6E  C1          	pop	bc
519   0D6F  C1          	pop	bc
519   0D70              ;		}
519   0D70              	C_LINE	519,"Graphics\L2graphics.c"
519   0D70              .i_95
519   0D70              ;	}
519   0D70              	C_LINE	520,"Graphics\L2graphics.c"
520   0D70              .i_93
520   0D70              ;}
520   0D70              	C_LINE	521,"Graphics\L2graphics.c"
521   0D70  C9          	ret
521   0D71              
521   0D71              
521   0D71              ;
521   0D71              	C_LINE	523,"Graphics\L2graphics.c"
523   0D71              ;void l2_draw_line_clip (int x0, int y0, int x1, int y1 , int color)
523   0D71              	C_LINE	524,"Graphics\L2graphics.c"
524   0D71              ;{
524   0D71              	C_LINE	525,"Graphics\L2graphics.c"
525   0D71              
525   0D71              ; Function l2_draw_line_clip flags 0x00000200 __smallc
525   0D71              ; void l2_draw_line_clip(int x0, int y0, int x1, int y1, int color)
525   0D71              ; parameter 'int color' at 2 size(2)
525   0D71              ; parameter 'int y1' at 4 size(2)
525   0D71              ; parameter 'int x1' at 6 size(2)
525   0D71              ; parameter 'int y0' at 8 size(2)
525   0D71              ; parameter 'int x0' at 10 size(2)
525   0D71              ._l2_draw_line_clip
525   0D71              	C_LINE	525,"Graphics\L2graphics.c"
525   0D71              ;	if (x0 == x1)
525   0D71              	C_LINE	526,"Graphics\L2graphics.c"
526   0D71              	C_LINE	526,"Graphics\L2graphics.c"
526   0D71  21 0A 00    	ld	hl,10	;const
526   0D74  CD 00 00    	call	l_gintspsp	;
526   0D77  21 08 00    	ld	hl,8	;const
526   0D7A  39          	add	hl,sp
526   0D7B  CD 00 00    	call	l_gint	;
526   0D7E  D1          	pop	de
526   0D7F  CD 00 00    	call	l_eq
526   0D82  D2 7E 0E    	jp	nc,i_96
526   0D85              ;	{
526   0D85              	C_LINE	527,"Graphics\L2graphics.c"
527   0D85              	C_LINE	527,"Graphics\L2graphics.c"
527   0D85              ;		if (y0 == y1)
527   0D85              	C_LINE	528,"Graphics\L2graphics.c"
528   0D85              	C_LINE	528,"Graphics\L2graphics.c"
528   0D85  21 08 00    	ld	hl,8	;const
528   0D88  CD 00 00    	call	l_gintspsp	;
528   0D8B  21 06 00    	ld	hl,6	;const
528   0D8E  39          	add	hl,sp
528   0D8F  CD 00 00    	call	l_gint	;
528   0D92  D1          	pop	de
528   0D93  CD 00 00    	call	l_eq
528   0D96  D2 FC 0D    	jp	nc,i_97
528   0D99              ;		{
528   0D99              	C_LINE	529,"Graphics\L2graphics.c"
529   0D99              	C_LINE	529,"Graphics\L2graphics.c"
529   0D99              ;			if (x0 >= 0 && x0 <= 255 && y0 >= 0 && y0 <=  127 )
529   0D99              	C_LINE	530,"Graphics\L2graphics.c"
530   0D99              	C_LINE	530,"Graphics\L2graphics.c"
530   0D99  21 0A 00    	ld	hl,10	;const
530   0D9C  39          	add	hl,sp
530   0D9D  CD 00 00    	call	l_gint	;
530   0DA0  7C          	ld	a,h
530   0DA1  17          	rla
530   0DA2  3F          	ccf
530   0DA3  D2 D2 0D    	jp	nc,i_99
530   0DA6  21 0A 00    	ld	hl,10	;const
530   0DA9  39          	add	hl,sp
530   0DAA  5E          	ld	e,(hl)
530   0DAB  23          	inc	hl
530   0DAC  56          	ld	d,(hl)
530   0DAD  21 FF 00    	ld	hl,255
530   0DB0  CD 00 00    	call	l_le
530   0DB3  D2 D2 0D    	jp	nc,i_99
530   0DB6  21 08 00    	ld	hl,8	;const
530   0DB9  39          	add	hl,sp
530   0DBA  CD 00 00    	call	l_gint	;
530   0DBD  7C          	ld	a,h
530   0DBE  17          	rla
530   0DBF  3F          	ccf
530   0DC0  D2 D2 0D    	jp	nc,i_99
530   0DC3  21 08 00    	ld	hl,8	;const
530   0DC6  39          	add	hl,sp
530   0DC7  5E          	ld	e,(hl)
530   0DC8  23          	inc	hl
530   0DC9  56          	ld	d,(hl)
530   0DCA  21 7F 00    	ld	hl,127
530   0DCD  CD 00 00    	call	l_le
530   0DD0  38 03       	jr	c,i_100_i_99
530   0DD2              .i_99
530   0DD2  C3 F9 0D    	jp	i_98
530   0DD5              .i_100_i_99
530   0DD5              ;			{
530   0DD5              	C_LINE	531,"Graphics\L2graphics.c"
531   0DD5              	C_LINE	531,"Graphics\L2graphics.c"
531   0DD5              ;
531   0DD5              	C_LINE	532,"Graphics\L2graphics.c"
532   0DD5              ;				l2_plot_pixel(x0, y0, color);
532   0DD5              	C_LINE	535,"Graphics\L2graphics.c"
535   0DD5              	C_LINE	535,"Graphics\L2graphics.c"
535   0DD5              ;x0;
535   0DD5              	C_LINE	536,"Graphics\L2graphics.c"
536   0DD5  21 0A 00    	ld	hl,10	;const
536   0DD8  39          	add	hl,sp
536   0DD9  CD 00 00    	call	l_gint	;
536   0DDC  26 00       	ld	h,0
536   0DDE  E5          	push	hl
536   0DDF              ;y0;
536   0DDF              	C_LINE	536,"Graphics\L2graphics.c"
536   0DDF  21 0A 00    	ld	hl,10	;const
536   0DE2  39          	add	hl,sp
536   0DE3  CD 00 00    	call	l_gint	;
536   0DE6  26 00       	ld	h,0
536   0DE8  E5          	push	hl
536   0DE9              ;color;
536   0DE9              	C_LINE	536,"Graphics\L2graphics.c"
536   0DE9  21 06 00    	ld	hl,6	;const
536   0DEC  39          	add	hl,sp
536   0DED  CD 00 00    	call	l_gint	;
536   0DF0  26 00       	ld	h,0
536   0DF2  E5          	push	hl
536   0DF3  CD 32 01    	call	_l2_plot_pixel
536   0DF6  C1          	pop	bc
536   0DF7  C1          	pop	bc
536   0DF8  C1          	pop	bc
536   0DF9              ;			}
536   0DF9              	C_LINE	536,"Graphics\L2graphics.c"
536   0DF9              ;		}
536   0DF9              	C_LINE	537,"Graphics\L2graphics.c"
537   0DF9              .i_98
537   0DF9              ;		else
537   0DF9              	C_LINE	538,"Graphics\L2graphics.c"
538   0DF9  C3 7B 0E    	jp	i_101
538   0DFC              .i_97
538   0DFC              ;		{
538   0DFC              	C_LINE	539,"Graphics\L2graphics.c"
539   0DFC              	C_LINE	539,"Graphics\L2graphics.c"
539   0DFC              ;			l2_clipy0 = y0<0?0:y0; if (l2_clipy0> 127 ) l2_clipy0 =  127 ;
539   0DFC              	C_LINE	540,"Graphics\L2graphics.c"
540   0DFC              	C_LINE	540,"Graphics\L2graphics.c"
540   0DFC  21 08 00    	ld	hl,8	;const
540   0DFF  39          	add	hl,sp
540   0E00  CD 00 00    	call	l_gint	;
540   0E03  7C          	ld	a,h
540   0E04  17          	rla
540   0E05  D2 0E 0E    	jp	nc,i_102
540   0E08  21 00 00    	ld	hl,0	;const
540   0E0B  C3 15 0E    	jp	i_103
540   0E0E              .i_102
540   0E0E  21 08 00    	ld	hl,8	;const
540   0E11  39          	add	hl,sp
540   0E12  CD 00 00    	call	l_gint	;
540   0E15              .i_103
540   0E15  22 9A 19    	ld	(_l2_clipy0),hl
540   0E18  11 7F 00    	ld	de,127
540   0E1B  EB          	ex	de,hl
540   0E1C  CD 00 00    	call	l_gt
540   0E1F  D2 28 0E    	jp	nc,i_104
540   0E22  21 7F 00    	ld	hl,127	;const
540   0E25  22 9A 19    	ld	(_l2_clipy0),hl
540   0E28              ;			l2_clipy1 = y1<0?0:y1; if (l2_clipy1> 127 ) l2_clipy1 =  127 ;
540   0E28              	C_LINE	541,"Graphics\L2graphics.c"
541   0E28              .i_104
541   0E28              	C_LINE	541,"Graphics\L2graphics.c"
541   0E28  21 04 00    	ld	hl,4	;const
541   0E2B  39          	add	hl,sp
541   0E2C  CD 00 00    	call	l_gint	;
541   0E2F  7C          	ld	a,h
541   0E30  17          	rla
541   0E31  D2 3A 0E    	jp	nc,i_105
541   0E34  21 00 00    	ld	hl,0	;const
541   0E37  C3 41 0E    	jp	i_106
541   0E3A              .i_105
541   0E3A  21 04 00    	ld	hl,4	;const
541   0E3D  39          	add	hl,sp
541   0E3E  CD 00 00    	call	l_gint	;
541   0E41              .i_106
541   0E41  22 9E 19    	ld	(_l2_clipy1),hl
541   0E44  11 7F 00    	ld	de,127
541   0E47  EB          	ex	de,hl
541   0E48  CD 00 00    	call	l_gt
541   0E4B  D2 54 0E    	jp	nc,i_107
541   0E4E  21 7F 00    	ld	hl,127	;const
541   0E51  22 9E 19    	ld	(_l2_clipy1),hl
541   0E54              ;
541   0E54              	C_LINE	542,"Graphics\L2graphics.c"
542   0E54              ;			l2_draw_vert_line_to(x0, l2_clipy0, l2_clipy1, color);
542   0E54              	C_LINE	545,"Graphics\L2graphics.c"
545   0E54              .i_107
545   0E54              	C_LINE	545,"Graphics\L2graphics.c"
545   0E54              ;x0;
545   0E54              	C_LINE	546,"Graphics\L2graphics.c"
546   0E54  21 0A 00    	ld	hl,10	;const
546   0E57  39          	add	hl,sp
546   0E58  CD 00 00    	call	l_gint	;
546   0E5B  26 00       	ld	h,0
546   0E5D  E5          	push	hl
546   0E5E              ;l2_clipy0;
546   0E5E              	C_LINE	546,"Graphics\L2graphics.c"
546   0E5E  2A 9A 19    	ld	hl,(_l2_clipy0)
546   0E61  26 00       	ld	h,0
546   0E63  E5          	push	hl
546   0E64              ;l2_clipy1;
546   0E64              	C_LINE	546,"Graphics\L2graphics.c"
546   0E64  2A 9E 19    	ld	hl,(_l2_clipy1)
546   0E67  26 00       	ld	h,0
546   0E69  E5          	push	hl
546   0E6A              ;color;
546   0E6A              	C_LINE	546,"Graphics\L2graphics.c"
546   0E6A  21 08 00    	ld	hl,8	;const
546   0E6D  39          	add	hl,sp
546   0E6E  CD 00 00    	call	l_gint	;
546   0E71  26 00       	ld	h,0
546   0E73  E5          	push	hl
546   0E74  CD F0 05    	call	_l2_draw_vert_line_to
546   0E77  C1          	pop	bc
546   0E78  C1          	pop	bc
546   0E79  C1          	pop	bc
546   0E7A  C1          	pop	bc
546   0E7B              ;		}
546   0E7B              	C_LINE	546,"Graphics\L2graphics.c"
546   0E7B              .i_101
546   0E7B              ;	}
546   0E7B              	C_LINE	547,"Graphics\L2graphics.c"
547   0E7B              ;	else
547   0E7B              	C_LINE	548,"Graphics\L2graphics.c"
548   0E7B  C3 57 0F    	jp	i_108
548   0E7E              .i_96
548   0E7E              ;	{
548   0E7E              	C_LINE	549,"Graphics\L2graphics.c"
549   0E7E              	C_LINE	549,"Graphics\L2graphics.c"
549   0E7E              ;		if (y0 == y1)
549   0E7E              	C_LINE	550,"Graphics\L2graphics.c"
550   0E7E              	C_LINE	550,"Graphics\L2graphics.c"
550   0E7E  21 08 00    	ld	hl,8	;const
550   0E81  CD 00 00    	call	l_gintspsp	;
550   0E84  21 06 00    	ld	hl,6	;const
550   0E87  39          	add	hl,sp
550   0E88  CD 00 00    	call	l_gint	;
550   0E8B  D1          	pop	de
550   0E8C  CD 00 00    	call	l_eq
550   0E8F  D2 25 0F    	jp	nc,i_109
550   0E92              ;		{
550   0E92              	C_LINE	551,"Graphics\L2graphics.c"
551   0E92              	C_LINE	551,"Graphics\L2graphics.c"
551   0E92              ;			if (y0 >  127 ) return;
551   0E92              	C_LINE	552,"Graphics\L2graphics.c"
552   0E92              	C_LINE	552,"Graphics\L2graphics.c"
552   0E92  21 08 00    	ld	hl,8	;const
552   0E95  39          	add	hl,sp
552   0E96  5E          	ld	e,(hl)
552   0E97  23          	inc	hl
552   0E98  56          	ld	d,(hl)
552   0E99  21 7F 00    	ld	hl,127
552   0E9C  CD 00 00    	call	l_gt
552   0E9F  D2 A3 0E    	jp	nc,i_110
552   0EA2  C9          	ret
552   0EA3              
552   0EA3              
552   0EA3              ;			l2_clipx0 = x0<0?0:x0; if (l2_clipx0>255) l2_clipx0 = 255;
552   0EA3              	C_LINE	553,"Graphics\L2graphics.c"
553   0EA3              .i_110
553   0EA3              	C_LINE	553,"Graphics\L2graphics.c"
553   0EA3  21 0A 00    	ld	hl,10	;const
553   0EA6  39          	add	hl,sp
553   0EA7  CD 00 00    	call	l_gint	;
553   0EAA  7C          	ld	a,h
553   0EAB  17          	rla
553   0EAC  D2 B5 0E    	jp	nc,i_111
553   0EAF  21 00 00    	ld	hl,0	;const
553   0EB2  C3 BC 0E    	jp	i_112
553   0EB5              .i_111
553   0EB5  21 0A 00    	ld	hl,10	;const
553   0EB8  39          	add	hl,sp
553   0EB9  CD 00 00    	call	l_gint	;
553   0EBC              .i_112
553   0EBC  22 98 19    	ld	(_l2_clipx0),hl
553   0EBF  11 FF 00    	ld	de,255
553   0EC2  EB          	ex	de,hl
553   0EC3  CD 00 00    	call	l_gt
553   0EC6  D2 CF 0E    	jp	nc,i_113
553   0EC9  21 FF 00    	ld	hl,255	;const
553   0ECC  22 98 19    	ld	(_l2_clipx0),hl
553   0ECF              ;			l2_clipx1 = x1<0?0:x1; if (l2_clipx1>255) l2_clipx1 = 255;
553   0ECF              	C_LINE	554,"Graphics\L2graphics.c"
554   0ECF              .i_113
554   0ECF              	C_LINE	554,"Graphics\L2graphics.c"
554   0ECF  21 06 00    	ld	hl,6	;const
554   0ED2  39          	add	hl,sp
554   0ED3  CD 00 00    	call	l_gint	;
554   0ED6  7C          	ld	a,h
554   0ED7  17          	rla
554   0ED8  D2 E1 0E    	jp	nc,i_114
554   0EDB  21 00 00    	ld	hl,0	;const
554   0EDE  C3 E8 0E    	jp	i_115
554   0EE1              .i_114
554   0EE1  21 06 00    	ld	hl,6	;const
554   0EE4  39          	add	hl,sp
554   0EE5  CD 00 00    	call	l_gint	;
554   0EE8              .i_115
554   0EE8  22 9C 19    	ld	(_l2_clipx1),hl
554   0EEB  11 FF 00    	ld	de,255
554   0EEE  EB          	ex	de,hl
554   0EEF  CD 00 00    	call	l_gt
554   0EF2  D2 FB 0E    	jp	nc,i_116
554   0EF5  21 FF 00    	ld	hl,255	;const
554   0EF8  22 9C 19    	ld	(_l2_clipx1),hl
554   0EFB              ;
554   0EFB              	C_LINE	555,"Graphics\L2graphics.c"
555   0EFB              ;			l2_draw_horz_line_to(l2_clipx0, l2_clipx1, y0, color);
555   0EFB              	C_LINE	558,"Graphics\L2graphics.c"
558   0EFB              .i_116
558   0EFB              	C_LINE	558,"Graphics\L2graphics.c"
558   0EFB              ;l2_clipx0;
558   0EFB              	C_LINE	559,"Graphics\L2graphics.c"
559   0EFB  2A 98 19    	ld	hl,(_l2_clipx0)
559   0EFE  26 00       	ld	h,0
559   0F00  E5          	push	hl
559   0F01              ;l2_clipx1;
559   0F01              	C_LINE	559,"Graphics\L2graphics.c"
559   0F01  2A 9C 19    	ld	hl,(_l2_clipx1)
559   0F04  26 00       	ld	h,0
559   0F06  E5          	push	hl
559   0F07              ;y0;
559   0F07              	C_LINE	559,"Graphics\L2graphics.c"
559   0F07  21 0C 00    	ld	hl,12	;const
559   0F0A  39          	add	hl,sp
559   0F0B  CD 00 00    	call	l_gint	;
559   0F0E  26 00       	ld	h,0
559   0F10  E5          	push	hl
559   0F11              ;color;
559   0F11              	C_LINE	559,"Graphics\L2graphics.c"
559   0F11  21 08 00    	ld	hl,8	;const
559   0F14  39          	add	hl,sp
559   0F15  CD 00 00    	call	l_gint	;
559   0F18  26 00       	ld	h,0
559   0F1A  E5          	push	hl
559   0F1B  CD 21 05    	call	_l2_draw_horz_line_to
559   0F1E  C1          	pop	bc
559   0F1F  C1          	pop	bc
559   0F20  C1          	pop	bc
559   0F21  C1          	pop	bc
559   0F22              ;		}
559   0F22              	C_LINE	559,"Graphics\L2graphics.c"
559   0F22              ;		else
559   0F22              	C_LINE	560,"Graphics\L2graphics.c"
560   0F22  C3 57 0F    	jp	i_117
560   0F25              .i_109
560   0F25              ;		{
560   0F25              	C_LINE	561,"Graphics\L2graphics.c"
561   0F25              	C_LINE	561,"Graphics\L2graphics.c"
561   0F25              ;
561   0F25              	C_LINE	562,"Graphics\L2graphics.c"
562   0F25              ;			l2_draw_diagonal_clip(x0, y0, x1, y1, color);
562   0F25              	C_LINE	565,"Graphics\L2graphics.c"
565   0F25              	C_LINE	565,"Graphics\L2graphics.c"
565   0F25              ;x0;
565   0F25              	C_LINE	566,"Graphics\L2graphics.c"
566   0F25  21 0A 00    	ld	hl,10	;const
566   0F28  39          	add	hl,sp
566   0F29  CD 00 00    	call	l_gint	;
566   0F2C  E5          	push	hl
566   0F2D              ;y0;
566   0F2D              	C_LINE	566,"Graphics\L2graphics.c"
566   0F2D  21 0A 00    	ld	hl,10	;const
566   0F30  39          	add	hl,sp
566   0F31  CD 00 00    	call	l_gint	;
566   0F34  E5          	push	hl
566   0F35              ;x1;
566   0F35              	C_LINE	566,"Graphics\L2graphics.c"
566   0F35  21 0A 00    	ld	hl,10	;const
566   0F38  39          	add	hl,sp
566   0F39  CD 00 00    	call	l_gint	;
566   0F3C  E5          	push	hl
566   0F3D              ;y1;
566   0F3D              	C_LINE	566,"Graphics\L2graphics.c"
566   0F3D  21 0A 00    	ld	hl,10	;const
566   0F40  39          	add	hl,sp
566   0F41  CD 00 00    	call	l_gint	;
566   0F44  E5          	push	hl
566   0F45              ;color;
566   0F45              	C_LINE	566,"Graphics\L2graphics.c"
566   0F45  21 0A 00    	ld	hl,10	;const
566   0F48  39          	add	hl,sp
566   0F49  CD 00 00    	call	l_gint	;
566   0F4C  26 00       	ld	h,0
566   0F4E  E5          	push	hl
566   0F4F  CD 13 0A    	call	_l2_draw_diagonal_clip
566   0F52  C1          	pop	bc
566   0F53  C1          	pop	bc
566   0F54  C1          	pop	bc
566   0F55  C1          	pop	bc
566   0F56  C1          	pop	bc
566   0F57              ;		}
566   0F57              	C_LINE	566,"Graphics\L2graphics.c"
566   0F57              .i_117
566   0F57              ;	}
566   0F57              	C_LINE	567,"Graphics\L2graphics.c"
567   0F57              .i_108
567   0F57              ;}
567   0F57              	C_LINE	568,"Graphics\L2graphics.c"
568   0F57  C9          	ret
568   0F58              
568   0F58              
568   0F58              ;
568   0F58              	C_LINE	569,"Graphics\L2graphics.c"
569   0F58              ;
569   0F58              	C_LINE	570,"Graphics\L2graphics.c"
570   0F58              ;void l2_store_diagonal (uint8_t x0,  uint8_t y0, uint8_t x1, uint8_t y1, uint8_t *targetArray)
570   0F58              	C_LINE	571,"Graphics\L2graphics.c"
571   0F58              ;{
571   0F58              	C_LINE	572,"Graphics\L2graphics.c"
572   0F58              
572   0F58              ; Function l2_store_diagonal flags 0x00000200 __smallc
572   0F58              ; void l2_store_diagonal(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, unsigned char uint8_t*targetArray)
572   0F58              ; parameter 'unsigned char uint8_t*targetArray' at 2 size(2)
572   0F58              ; parameter 'unsigned char y1' at 4 size(1)
572   0F58              ; parameter 'unsigned char x1' at 6 size(1)
572   0F58              ; parameter 'unsigned char y0' at 8 size(1)
572   0F58              ; parameter 'unsigned char x0' at 10 size(1)
572   0F58              ._l2_store_diagonal
572   0F58              	C_LINE	572,"Graphics\L2graphics.c"
572   0F58              ;
572   0F58              	C_LINE	573,"Graphics\L2graphics.c"
573   0F58              ;    if (y0 > y1)
573   0F58              	C_LINE	574,"Graphics\L2graphics.c"
574   0F58              	C_LINE	574,"Graphics\L2graphics.c"
574   0F58  21 08 00    	ld	hl,8	;const
574   0F5B  39          	add	hl,sp
574   0F5C  5E          	ld	e,(hl)
574   0F5D  16 00       	ld	d,0
574   0F5F  21 04 00    	ld	hl,4	;const
574   0F62  39          	add	hl,sp
574   0F63  6E          	ld	l,(hl)
574   0F64  26 00       	ld	h,0
574   0F66  A7          	and	a
574   0F67  ED 52       	sbc	hl,de
574   0F69  D2 97 0F    	jp	nc,i_118
574   0F6C              ;    {
574   0F6C              	C_LINE	575,"Graphics\L2graphics.c"
575   0F6C              	C_LINE	575,"Graphics\L2graphics.c"
575   0F6C              ;        l2_vx0 = x1;
575   0F6C              	C_LINE	576,"Graphics\L2graphics.c"
576   0F6C              	C_LINE	576,"Graphics\L2graphics.c"
576   0F6C  21 06 00    	ld	hl,6	;const
576   0F6F  39          	add	hl,sp
576   0F70  6E          	ld	l,(hl)
576   0F71  26 00       	ld	h,0
576   0F73  22 A7 17    	ld	(_l2_vx0),hl
576   0F76              ;        l2_vy0 = y1;
576   0F76              	C_LINE	577,"Graphics\L2graphics.c"
577   0F76              	C_LINE	577,"Graphics\L2graphics.c"
577   0F76  21 04 00    	ld	hl,4	;const
577   0F79  39          	add	hl,sp
577   0F7A  6E          	ld	l,(hl)
577   0F7B  26 00       	ld	h,0
577   0F7D  22 A9 17    	ld	(_l2_vy0),hl
577   0F80              ;        l2_vx1 = x0;
577   0F80              	C_LINE	578,"Graphics\L2graphics.c"
578   0F80              	C_LINE	578,"Graphics\L2graphics.c"
578   0F80  21 0A 00    	ld	hl,10	;const
578   0F83  39          	add	hl,sp
578   0F84  6E          	ld	l,(hl)
578   0F85  26 00       	ld	h,0
578   0F87  22 AB 17    	ld	(_l2_vx1),hl
578   0F8A              ;        l2_vy1 = y0;
578   0F8A              	C_LINE	579,"Graphics\L2graphics.c"
579   0F8A              	C_LINE	579,"Graphics\L2graphics.c"
579   0F8A  21 08 00    	ld	hl,8	;const
579   0F8D  39          	add	hl,sp
579   0F8E  6E          	ld	l,(hl)
579   0F8F  26 00       	ld	h,0
579   0F91  22 AD 17    	ld	(_l2_vy1),hl
579   0F94              ;    }
579   0F94              	C_LINE	580,"Graphics\L2graphics.c"
580   0F94              ;    else
580   0F94              	C_LINE	581,"Graphics\L2graphics.c"
581   0F94  C3 BF 0F    	jp	i_119
581   0F97              .i_118
581   0F97              ;    {
581   0F97              	C_LINE	582,"Graphics\L2graphics.c"
582   0F97              	C_LINE	582,"Graphics\L2graphics.c"
582   0F97              ;        l2_vx0 = x0;
582   0F97              	C_LINE	583,"Graphics\L2graphics.c"
583   0F97              	C_LINE	583,"Graphics\L2graphics.c"
583   0F97  21 0A 00    	ld	hl,10	;const
583   0F9A  39          	add	hl,sp
583   0F9B  6E          	ld	l,(hl)
583   0F9C  26 00       	ld	h,0
583   0F9E  22 A7 17    	ld	(_l2_vx0),hl
583   0FA1              ;        l2_vy0 = y0;
583   0FA1              	C_LINE	584,"Graphics\L2graphics.c"
584   0FA1              	C_LINE	584,"Graphics\L2graphics.c"
584   0FA1  21 08 00    	ld	hl,8	;const
584   0FA4  39          	add	hl,sp
584   0FA5  6E          	ld	l,(hl)
584   0FA6  26 00       	ld	h,0
584   0FA8  22 A9 17    	ld	(_l2_vy0),hl
584   0FAB              ;        l2_vx1 = x1;
584   0FAB              	C_LINE	585,"Graphics\L2graphics.c"
585   0FAB              	C_LINE	585,"Graphics\L2graphics.c"
585   0FAB  21 06 00    	ld	hl,6	;const
585   0FAE  39          	add	hl,sp
585   0FAF  6E          	ld	l,(hl)
585   0FB0  26 00       	ld	h,0
585   0FB2  22 AB 17    	ld	(_l2_vx1),hl
585   0FB5              ;        l2_vy1 = y1;
585   0FB5              	C_LINE	586,"Graphics\L2graphics.c"
586   0FB5              	C_LINE	586,"Graphics\L2graphics.c"
586   0FB5  21 04 00    	ld	hl,4	;const
586   0FB8  39          	add	hl,sp
586   0FB9  6E          	ld	l,(hl)
586   0FBA  26 00       	ld	h,0
586   0FBC  22 AD 17    	ld	(_l2_vy1),hl
586   0FBF              ;    }
586   0FBF              	C_LINE	587,"Graphics\L2graphics.c"
587   0FBF              .i_119
587   0FBF              ;
587   0FBF              	C_LINE	588,"Graphics\L2graphics.c"
588   0FBF              ;    l2_dy = l2_vy1 - l2_vy0;
588   0FBF              	C_LINE	589,"Graphics\L2graphics.c"
589   0FBF              	C_LINE	589,"Graphics\L2graphics.c"
589   0FBF  ED 5B AD 17 	ld	de,(_l2_vy1)
589   0FC3  2A A9 17    	ld	hl,(_l2_vy0)
589   0FC6  EB          	ex	de,hl
589   0FC7  A7          	and	a
589   0FC8  ED 52       	sbc	hl,de
589   0FCA  22 A3 17    	ld	(_l2_dy),hl
589   0FCD              ;    l2_dx = l2_vx1 - l2_vx0;
589   0FCD              	C_LINE	590,"Graphics\L2graphics.c"
590   0FCD              	C_LINE	590,"Graphics\L2graphics.c"
590   0FCD  ED 5B AB 17 	ld	de,(_l2_vx1)
590   0FD1  2A A7 17    	ld	hl,(_l2_vx0)
590   0FD4  EB          	ex	de,hl
590   0FD5  A7          	and	a
590   0FD6  ED 52       	sbc	hl,de
590   0FD8  22 A5 17    	ld	(_l2_dx),hl
590   0FDB              ;    if (l2_dx < 0)
590   0FDB              	C_LINE	592,"Graphics\L2graphics.c"
592   0FDB              	C_LINE	592,"Graphics\L2graphics.c"
592   0FDB  2A A5 17    	ld	hl,(_l2_dx)
592   0FDE  7C          	ld	a,h
592   0FDF  17          	rla
592   0FE0  D2 F5 0F    	jp	nc,i_120
592   0FE3              ;    {
592   0FE3              	C_LINE	593,"Graphics\L2graphics.c"
593   0FE3              	C_LINE	593,"Graphics\L2graphics.c"
593   0FE3              ;        l2_dx = -l2_dx;
593   0FE3              	C_LINE	594,"Graphics\L2graphics.c"
594   0FE3              	C_LINE	594,"Graphics\L2graphics.c"
594   0FE3  2A A5 17    	ld	hl,(_l2_dx)
594   0FE6  CD 00 00    	call	l_neg
594   0FE9  22 A5 17    	ld	(_l2_dx),hl
594   0FEC              ;        l2_stepx = -1;
594   0FEC              	C_LINE	595,"Graphics\L2graphics.c"
595   0FEC              	C_LINE	595,"Graphics\L2graphics.c"
595   0FEC  21 FF FF    	ld	hl,65535	;const
595   0FEF  22 9D 17    	ld	(_l2_stepx),hl
595   0FF2              ;    }
595   0FF2              	C_LINE	596,"Graphics\L2graphics.c"
596   0FF2              ;    else
596   0FF2              	C_LINE	597,"Graphics\L2graphics.c"
597   0FF2  C3 FB 0F    	jp	i_121
597   0FF5              .i_120
597   0FF5              ;    {
597   0FF5              	C_LINE	598,"Graphics\L2graphics.c"
598   0FF5              	C_LINE	598,"Graphics\L2graphics.c"
598   0FF5              ;        l2_stepx = 1;
598   0FF5              	C_LINE	599,"Graphics\L2graphics.c"
599   0FF5              	C_LINE	599,"Graphics\L2graphics.c"
599   0FF5  21 01 00    	ld	hl,1	;const
599   0FF8  22 9D 17    	ld	(_l2_stepx),hl
599   0FFB              ;    }
599   0FFB              	C_LINE	600,"Graphics\L2graphics.c"
600   0FFB              .i_121
600   0FFB              ;    l2_dy <<= 1;
600   0FFB              	C_LINE	602,"Graphics\L2graphics.c"
602   0FFB              	C_LINE	602,"Graphics\L2graphics.c"
602   0FFB  2A A3 17    	ld	hl,(_l2_dy)
602   0FFE  29          	add	hl,hl
602   0FFF  22 A3 17    	ld	(_l2_dy),hl
602   1002              ;    l2_dx <<= 1;
602   1002              	C_LINE	603,"Graphics\L2graphics.c"
603   1002              	C_LINE	603,"Graphics\L2graphics.c"
603   1002  2A A5 17    	ld	hl,(_l2_dx)
603   1005  29          	add	hl,hl
603   1006  22 A5 17    	ld	(_l2_dx),hl
603   1009              ;
603   1009              	C_LINE	604,"Graphics\L2graphics.c"
604   1009              ;    targetArray[y0] = l2_vx0;
604   1009              	C_LINE	605,"Graphics\L2graphics.c"
605   1009              	C_LINE	605,"Graphics\L2graphics.c"
605   1009  21 02 00    	ld	hl,2	;const
605   100C  39          	add	hl,sp
605   100D  5E          	ld	e,(hl)
605   100E  23          	inc	hl
605   100F  56          	ld	d,(hl)
605   1010  21 08 00    	ld	hl,8	;const
605   1013  39          	add	hl,sp
605   1014  6E          	ld	l,(hl)
605   1015  26 00       	ld	h,0
605   1017  19          	add	hl,de
605   1018  EB          	ex	de,hl
605   1019  2A A7 17    	ld	hl,(_l2_vx0)
605   101C  7D          	ld	a,l
605   101D  12          	ld	(de),a
605   101E              ;    if (l2_dx > l2_dy)
605   101E              	C_LINE	607,"Graphics\L2graphics.c"
607   101E              	C_LINE	607,"Graphics\L2graphics.c"
607   101E  ED 5B A5 17 	ld	de,(_l2_dx)
607   1022  2A A3 17    	ld	hl,(_l2_dy)
607   1025  CD 00 00    	call	l_gt
607   1028  D2 94 10    	jp	nc,i_122
607   102B              ;    {
607   102B              	C_LINE	608,"Graphics\L2graphics.c"
608   102B              	C_LINE	608,"Graphics\L2graphics.c"
608   102B              ;        l2_fraction = l2_dy - (l2_dx >> 1);
608   102B              	C_LINE	609,"Graphics\L2graphics.c"
609   102B              	C_LINE	609,"Graphics\L2graphics.c"
609   102B  2A A3 17    	ld	hl,(_l2_dy)
609   102E  E5          	push	hl
609   102F  2A A5 17    	ld	hl,(_l2_dx)
609   1032  CB 2C       	sra	h
609   1034  CB 1D       	rr	l
609   1036  D1          	pop	de
609   1037  EB          	ex	de,hl
609   1038  A7          	and	a
609   1039  ED 52       	sbc	hl,de
609   103B  22 A1 17    	ld	(_l2_fraction),hl
609   103E              ;        while (l2_vx0 != l2_vx1)
609   103E              	C_LINE	610,"Graphics\L2graphics.c"
610   103E              	C_LINE	610,"Graphics\L2graphics.c"
610   103E              .i_123
610   103E  ED 5B A7 17 	ld	de,(_l2_vx0)
610   1042  2A AB 17    	ld	hl,(_l2_vx1)
610   1045  CD 00 00    	call	l_ne
610   1048  D2 91 10    	jp	nc,i_124
610   104B              ;        {
610   104B              	C_LINE	611,"Graphics\L2graphics.c"
611   104B              	C_LINE	611,"Graphics\L2graphics.c"
611   104B              ;            if (l2_fraction >= 0)
611   104B              	C_LINE	612,"Graphics\L2graphics.c"
612   104B              	C_LINE	612,"Graphics\L2graphics.c"
612   104B  2A A1 17    	ld	hl,(_l2_fraction)
612   104E  7C          	ld	a,h
612   104F  17          	rla
612   1050  3F          	ccf
612   1051  D2 69 10    	jp	nc,i_125
612   1054              ;            {
612   1054              	C_LINE	613,"Graphics\L2graphics.c"
613   1054              	C_LINE	613,"Graphics\L2graphics.c"
613   1054              ;                ++l2_vy0;
613   1054              	C_LINE	614,"Graphics\L2graphics.c"
614   1054              	C_LINE	614,"Graphics\L2graphics.c"
614   1054  2A A9 17    	ld	hl,(_l2_vy0)
614   1057  23          	inc	hl
614   1058  22 A9 17    	ld	(_l2_vy0),hl
614   105B              ;                l2_fraction -= l2_dx;
614   105B              	C_LINE	615,"Graphics\L2graphics.c"
615   105B              	C_LINE	615,"Graphics\L2graphics.c"
615   105B  ED 5B A1 17 	ld	de,(_l2_fraction)
615   105F  2A A5 17    	ld	hl,(_l2_dx)
615   1062  EB          	ex	de,hl
615   1063  A7          	and	a
615   1064  ED 52       	sbc	hl,de
615   1066  22 A1 17    	ld	(_l2_fraction),hl
615   1069              ;            }
615   1069              	C_LINE	616,"Graphics\L2graphics.c"
616   1069              ;            l2_vx0 += l2_stepx;
616   1069              	C_LINE	617,"Graphics\L2graphics.c"
617   1069              .i_125
617   1069              	C_LINE	617,"Graphics\L2graphics.c"
617   1069  ED 5B A7 17 	ld	de,(_l2_vx0)
617   106D  2A 9D 17    	ld	hl,(_l2_stepx)
617   1070  19          	add	hl,de
617   1071  22 A7 17    	ld	(_l2_vx0),hl
617   1074              ;            l2_fraction += l2_dy;
617   1074              	C_LINE	618,"Graphics\L2graphics.c"
618   1074              	C_LINE	618,"Graphics\L2graphics.c"
618   1074  ED 5B A1 17 	ld	de,(_l2_fraction)
618   1078  2A A3 17    	ld	hl,(_l2_dy)
618   107B  19          	add	hl,de
618   107C  22 A1 17    	ld	(_l2_fraction),hl
618   107F              ;            targetArray[l2_vy0] = l2_vx0;
618   107F              	C_LINE	619,"Graphics\L2graphics.c"
619   107F              	C_LINE	619,"Graphics\L2graphics.c"
619   107F  C1          	pop	bc
619   1080  E1          	pop	hl
619   1081  E5          	push	hl
619   1082  C5          	push	bc
619   1083  EB          	ex	de,hl
619   1084  2A A9 17    	ld	hl,(_l2_vy0)
619   1087  19          	add	hl,de
619   1088  EB          	ex	de,hl
619   1089  2A A7 17    	ld	hl,(_l2_vx0)
619   108C  7D          	ld	a,l
619   108D  12          	ld	(de),a
619   108E              ;        }
619   108E              	C_LINE	620,"Graphics\L2graphics.c"
620   108E  C3 3E 10    	jp	i_123
620   1091              .i_124
620   1091              ;    }
620   1091              	C_LINE	621,"Graphics\L2graphics.c"
621   1091              ;    else
621   1091              	C_LINE	622,"Graphics\L2graphics.c"
622   1091  C3 FA 10    	jp	i_126
622   1094              .i_122
622   1094              ;    {
622   1094              	C_LINE	623,"Graphics\L2graphics.c"
623   1094              	C_LINE	623,"Graphics\L2graphics.c"
623   1094              ;        l2_fraction = l2_dx - (l2_dy >> 1);
623   1094              	C_LINE	624,"Graphics\L2graphics.c"
624   1094              	C_LINE	624,"Graphics\L2graphics.c"
624   1094  2A A5 17    	ld	hl,(_l2_dx)
624   1097  E5          	push	hl
624   1098  2A A3 17    	ld	hl,(_l2_dy)
624   109B  CB 2C       	sra	h
624   109D  CB 1D       	rr	l
624   109F  D1          	pop	de
624   10A0  EB          	ex	de,hl
624   10A1  A7          	and	a
624   10A2  ED 52       	sbc	hl,de
624   10A4  22 A1 17    	ld	(_l2_fraction),hl
624   10A7              ;        while (l2_vy0 != l2_vy1)
624   10A7              	C_LINE	625,"Graphics\L2graphics.c"
625   10A7              	C_LINE	625,"Graphics\L2graphics.c"
625   10A7              .i_127
625   10A7  ED 5B A9 17 	ld	de,(_l2_vy0)
625   10AB  2A AD 17    	ld	hl,(_l2_vy1)
625   10AE  CD 00 00    	call	l_ne
625   10B1  D2 FA 10    	jp	nc,i_128
625   10B4              ;        {
625   10B4              	C_LINE	626,"Graphics\L2graphics.c"
626   10B4              	C_LINE	626,"Graphics\L2graphics.c"
626   10B4              ;            if (l2_fraction >= 0)
626   10B4              	C_LINE	627,"Graphics\L2graphics.c"
627   10B4              	C_LINE	627,"Graphics\L2graphics.c"
627   10B4  2A A1 17    	ld	hl,(_l2_fraction)
627   10B7  7C          	ld	a,h
627   10B8  17          	rla
627   10B9  3F          	ccf
627   10BA  D2 D6 10    	jp	nc,i_129
627   10BD              ;            {
627   10BD              	C_LINE	628,"Graphics\L2graphics.c"
628   10BD              	C_LINE	628,"Graphics\L2graphics.c"
628   10BD              ;                l2_vx0 += l2_stepx;
628   10BD              	C_LINE	629,"Graphics\L2graphics.c"
629   10BD              	C_LINE	629,"Graphics\L2graphics.c"
629   10BD  ED 5B A7 17 	ld	de,(_l2_vx0)
629   10C1  2A 9D 17    	ld	hl,(_l2_stepx)
629   10C4  19          	add	hl,de
629   10C5  22 A7 17    	ld	(_l2_vx0),hl
629   10C8              ;                l2_fraction -= l2_dy;
629   10C8              	C_LINE	630,"Graphics\L2graphics.c"
630   10C8              	C_LINE	630,"Graphics\L2graphics.c"
630   10C8  ED 5B A1 17 	ld	de,(_l2_fraction)
630   10CC  2A A3 17    	ld	hl,(_l2_dy)
630   10CF  EB          	ex	de,hl
630   10D0  A7          	and	a
630   10D1  ED 52       	sbc	hl,de
630   10D3  22 A1 17    	ld	(_l2_fraction),hl
630   10D6              ;            }
630   10D6              	C_LINE	631,"Graphics\L2graphics.c"
631   10D6              ;            l2_fraction += l2_dx;
631   10D6              	C_LINE	632,"Graphics\L2graphics.c"
632   10D6              .i_129
632   10D6              	C_LINE	632,"Graphics\L2graphics.c"
632   10D6  ED 5B A1 17 	ld	de,(_l2_fraction)
632   10DA  2A A5 17    	ld	hl,(_l2_dx)
632   10DD  19          	add	hl,de
632   10DE  22 A1 17    	ld	(_l2_fraction),hl
632   10E1              ;            ++l2_vy0;
632   10E1              	C_LINE	633,"Graphics\L2graphics.c"
633   10E1              	C_LINE	633,"Graphics\L2graphics.c"
633   10E1  2A A9 17    	ld	hl,(_l2_vy0)
633   10E4  23          	inc	hl
633   10E5  22 A9 17    	ld	(_l2_vy0),hl
633   10E8              ;            targetArray[l2_vy0] = l2_vx0;
633   10E8              	C_LINE	634,"Graphics\L2graphics.c"
634   10E8              	C_LINE	634,"Graphics\L2graphics.c"
634   10E8  C1          	pop	bc
634   10E9  E1          	pop	hl
634   10EA  E5          	push	hl
634   10EB  C5          	push	bc
634   10EC  EB          	ex	de,hl
634   10ED  2A A9 17    	ld	hl,(_l2_vy0)
634   10F0  19          	add	hl,de
634   10F1  EB          	ex	de,hl
634   10F2  2A A7 17    	ld	hl,(_l2_vx0)
634   10F5  7D          	ld	a,l
634   10F6  12          	ld	(de),a
634   10F7              ;        }
634   10F7              	C_LINE	635,"Graphics\L2graphics.c"
635   10F7  C3 A7 10    	jp	i_127
635   10FA              .i_128
635   10FA              ;    }
635   10FA              	C_LINE	636,"Graphics\L2graphics.c"
636   10FA              .i_126
636   10FA              ;}
636   10FA              	C_LINE	637,"Graphics\L2graphics.c"
637   10FA  C9          	ret
637   10FB              
637   10FB              
637   10FB              ;
637   10FB              	C_LINE	639,"Graphics\L2graphics.c"
639   10FB              ;
639   10FB              	C_LINE	658,"Graphics\L2graphics.c"
658   10FB              ;void l2_draw_circle_px(int xc, int yc, int x, int y, uint8_t color)
658   10FB              	C_LINE	659,"Graphics\L2graphics.c"
659   10FB              ;{
659   10FB              	C_LINE	660,"Graphics\L2graphics.c"
660   10FB              
660   10FB              ; Function l2_draw_circle_px flags 0x00000200 __smallc
660   10FB              ; void l2_draw_circle_px(int xc, int yc, int x, int y, unsigned char color)
660   10FB              ; parameter 'unsigned char color' at 2 size(1)
660   10FB              ; parameter 'int y' at 4 size(2)
660   10FB              ; parameter 'int x' at 6 size(2)
660   10FB              ; parameter 'int yc' at 8 size(2)
660   10FB              ; parameter 'int xc' at 10 size(2)
660   10FB              ._l2_draw_circle_px
660   10FB              	C_LINE	660,"Graphics\L2graphics.c"
660   10FB              ;    l2_plot_pixel(xc+x, yc+y, color);
660   10FB              	C_LINE	661,"Graphics\L2graphics.c"
661   10FB              	C_LINE	661,"Graphics\L2graphics.c"
661   10FB              ;xc+x;
661   10FB              	C_LINE	662,"Graphics\L2graphics.c"
662   10FB  21 0A 00    	ld	hl,10	;const
662   10FE  CD 00 00    	call	l_gintspsp	;
662   1101  21 08 00    	ld	hl,8	;const
662   1104  39          	add	hl,sp
662   1105  CD 00 00    	call	l_gint	;
662   1108  D1          	pop	de
662   1109  19          	add	hl,de
662   110A  26 00       	ld	h,0
662   110C  E5          	push	hl
662   110D              ;yc+y;
662   110D              	C_LINE	662,"Graphics\L2graphics.c"
662   110D  21 0A 00    	ld	hl,10	;const
662   1110  CD 00 00    	call	l_gintspsp	;
662   1113  21 08 00    	ld	hl,8	;const
662   1116  39          	add	hl,sp
662   1117  CD 00 00    	call	l_gint	;
662   111A  D1          	pop	de
662   111B  19          	add	hl,de
662   111C  26 00       	ld	h,0
662   111E  E5          	push	hl
662   111F              ;color;
662   111F              	C_LINE	662,"Graphics\L2graphics.c"
662   111F  21 06 00    	ld	hl,6	;const
662   1122  39          	add	hl,sp
662   1123  6E          	ld	l,(hl)
662   1124  26 00       	ld	h,0
662   1126  E5          	push	hl
662   1127  CD 32 01    	call	_l2_plot_pixel
662   112A  C1          	pop	bc
662   112B  C1          	pop	bc
662   112C  C1          	pop	bc
662   112D              ;    l2_plot_pixel(xc-x, yc+y, color);
662   112D              	C_LINE	662,"Graphics\L2graphics.c"
662   112D              	C_LINE	662,"Graphics\L2graphics.c"
662   112D              ;xc-x;
662   112D              	C_LINE	663,"Graphics\L2graphics.c"
663   112D  21 0A 00    	ld	hl,10	;const
663   1130  CD 00 00    	call	l_gintspsp	;
663   1133  21 08 00    	ld	hl,8	;const
663   1136  39          	add	hl,sp
663   1137  CD 00 00    	call	l_gint	;
663   113A  D1          	pop	de
663   113B  EB          	ex	de,hl
663   113C  A7          	and	a
663   113D  ED 52       	sbc	hl,de
663   113F  26 00       	ld	h,0
663   1141  E5          	push	hl
663   1142              ;yc+y;
663   1142              	C_LINE	663,"Graphics\L2graphics.c"
663   1142  21 0A 00    	ld	hl,10	;const
663   1145  CD 00 00    	call	l_gintspsp	;
663   1148  21 08 00    	ld	hl,8	;const
663   114B  39          	add	hl,sp
663   114C  CD 00 00    	call	l_gint	;
663   114F  D1          	pop	de
663   1150  19          	add	hl,de
663   1151  26 00       	ld	h,0
663   1153  E5          	push	hl
663   1154              ;color;
663   1154              	C_LINE	663,"Graphics\L2graphics.c"
663   1154  21 06 00    	ld	hl,6	;const
663   1157  39          	add	hl,sp
663   1158  6E          	ld	l,(hl)
663   1159  26 00       	ld	h,0
663   115B  E5          	push	hl
663   115C  CD 32 01    	call	_l2_plot_pixel
663   115F  C1          	pop	bc
663   1160  C1          	pop	bc
663   1161  C1          	pop	bc
663   1162              ;    l2_plot_pixel(xc+x, yc-y, color);
663   1162              	C_LINE	663,"Graphics\L2graphics.c"
663   1162              	C_LINE	663,"Graphics\L2graphics.c"
663   1162              ;xc+x;
663   1162              	C_LINE	664,"Graphics\L2graphics.c"
664   1162  21 0A 00    	ld	hl,10	;const
664   1165  CD 00 00    	call	l_gintspsp	;
664   1168  21 08 00    	ld	hl,8	;const
664   116B  39          	add	hl,sp
664   116C  CD 00 00    	call	l_gint	;
664   116F  D1          	pop	de
664   1170  19          	add	hl,de
664   1171  26 00       	ld	h,0
664   1173  E5          	push	hl
664   1174              ;yc-y;
664   1174              	C_LINE	664,"Graphics\L2graphics.c"
664   1174  21 0A 00    	ld	hl,10	;const
664   1177  CD 00 00    	call	l_gintspsp	;
664   117A  21 08 00    	ld	hl,8	;const
664   117D  39          	add	hl,sp
664   117E  CD 00 00    	call	l_gint	;
664   1181  D1          	pop	de
664   1182  EB          	ex	de,hl
664   1183  A7          	and	a
664   1184  ED 52       	sbc	hl,de
664   1186  26 00       	ld	h,0
664   1188  E5          	push	hl
664   1189              ;color;
664   1189              	C_LINE	664,"Graphics\L2graphics.c"
664   1189  21 06 00    	ld	hl,6	;const
664   118C  39          	add	hl,sp
664   118D  6E          	ld	l,(hl)
664   118E  26 00       	ld	h,0
664   1190  E5          	push	hl
664   1191  CD 32 01    	call	_l2_plot_pixel
664   1194  C1          	pop	bc
664   1195  C1          	pop	bc
664   1196  C1          	pop	bc
664   1197              ;    l2_plot_pixel(xc-x, yc-y, color);
664   1197              	C_LINE	664,"Graphics\L2graphics.c"
664   1197              	C_LINE	664,"Graphics\L2graphics.c"
664   1197              ;xc-x;
664   1197              	C_LINE	665,"Graphics\L2graphics.c"
665   1197  21 0A 00    	ld	hl,10	;const
665   119A  CD 00 00    	call	l_gintspsp	;
665   119D  21 08 00    	ld	hl,8	;const
665   11A0  39          	add	hl,sp
665   11A1  CD 00 00    	call	l_gint	;
665   11A4  D1          	pop	de
665   11A5  EB          	ex	de,hl
665   11A6  A7          	and	a
665   11A7  ED 52       	sbc	hl,de
665   11A9  26 00       	ld	h,0
665   11AB  E5          	push	hl
665   11AC              ;yc-y;
665   11AC              	C_LINE	665,"Graphics\L2graphics.c"
665   11AC  21 0A 00    	ld	hl,10	;const
665   11AF  CD 00 00    	call	l_gintspsp	;
665   11B2  21 08 00    	ld	hl,8	;const
665   11B5  39          	add	hl,sp
665   11B6  CD 00 00    	call	l_gint	;
665   11B9  D1          	pop	de
665   11BA  EB          	ex	de,hl
665   11BB  A7          	and	a
665   11BC  ED 52       	sbc	hl,de
665   11BE  26 00       	ld	h,0
665   11C0  E5          	push	hl
665   11C1              ;color;
665   11C1              	C_LINE	665,"Graphics\L2graphics.c"
665   11C1  21 06 00    	ld	hl,6	;const
665   11C4  39          	add	hl,sp
665   11C5  6E          	ld	l,(hl)
665   11C6  26 00       	ld	h,0
665   11C8  E5          	push	hl
665   11C9  CD 32 01    	call	_l2_plot_pixel
665   11CC  C1          	pop	bc
665   11CD  C1          	pop	bc
665   11CE  C1          	pop	bc
665   11CF              ;    l2_plot_pixel(xc+y, yc+x, color);
665   11CF              	C_LINE	665,"Graphics\L2graphics.c"
665   11CF              	C_LINE	665,"Graphics\L2graphics.c"
665   11CF              ;xc+y;
665   11CF              	C_LINE	666,"Graphics\L2graphics.c"
666   11CF  21 0A 00    	ld	hl,10	;const
666   11D2  CD 00 00    	call	l_gintspsp	;
666   11D5  21 06 00    	ld	hl,6	;const
666   11D8  39          	add	hl,sp
666   11D9  CD 00 00    	call	l_gint	;
666   11DC  D1          	pop	de
666   11DD  19          	add	hl,de
666   11DE  26 00       	ld	h,0
666   11E0  E5          	push	hl
666   11E1              ;yc+x;
666   11E1              	C_LINE	666,"Graphics\L2graphics.c"
666   11E1  21 0A 00    	ld	hl,10	;const
666   11E4  CD 00 00    	call	l_gintspsp	;
666   11E7  21 0A 00    	ld	hl,10	;const
666   11EA  39          	add	hl,sp
666   11EB  CD 00 00    	call	l_gint	;
666   11EE  D1          	pop	de
666   11EF  19          	add	hl,de
666   11F0  26 00       	ld	h,0
666   11F2  E5          	push	hl
666   11F3              ;color;
666   11F3              	C_LINE	666,"Graphics\L2graphics.c"
666   11F3  21 06 00    	ld	hl,6	;const
666   11F6  39          	add	hl,sp
666   11F7  6E          	ld	l,(hl)
666   11F8  26 00       	ld	h,0
666   11FA  E5          	push	hl
666   11FB  CD 32 01    	call	_l2_plot_pixel
666   11FE  C1          	pop	bc
666   11FF  C1          	pop	bc
666   1200  C1          	pop	bc
666   1201              ;    l2_plot_pixel(xc-y, yc+x, color);
666   1201              	C_LINE	666,"Graphics\L2graphics.c"
666   1201              	C_LINE	666,"Graphics\L2graphics.c"
666   1201              ;xc-y;
666   1201              	C_LINE	667,"Graphics\L2graphics.c"
667   1201  21 0A 00    	ld	hl,10	;const
667   1204  CD 00 00    	call	l_gintspsp	;
667   1207  21 06 00    	ld	hl,6	;const
667   120A  39          	add	hl,sp
667   120B  CD 00 00    	call	l_gint	;
667   120E  D1          	pop	de
667   120F  EB          	ex	de,hl
667   1210  A7          	and	a
667   1211  ED 52       	sbc	hl,de
667   1213  26 00       	ld	h,0
667   1215  E5          	push	hl
667   1216              ;yc+x;
667   1216              	C_LINE	667,"Graphics\L2graphics.c"
667   1216  21 0A 00    	ld	hl,10	;const
667   1219  CD 00 00    	call	l_gintspsp	;
667   121C  21 0A 00    	ld	hl,10	;const
667   121F  39          	add	hl,sp
667   1220  CD 00 00    	call	l_gint	;
667   1223  D1          	pop	de
667   1224  19          	add	hl,de
667   1225  26 00       	ld	h,0
667   1227  E5          	push	hl
667   1228              ;color;
667   1228              	C_LINE	667,"Graphics\L2graphics.c"
667   1228  21 06 00    	ld	hl,6	;const
667   122B  39          	add	hl,sp
667   122C  6E          	ld	l,(hl)
667   122D  26 00       	ld	h,0
667   122F  E5          	push	hl
667   1230  CD 32 01    	call	_l2_plot_pixel
667   1233  C1          	pop	bc
667   1234  C1          	pop	bc
667   1235  C1          	pop	bc
667   1236              ;    l2_plot_pixel(xc+y, yc-x, color);
667   1236              	C_LINE	667,"Graphics\L2graphics.c"
667   1236              	C_LINE	667,"Graphics\L2graphics.c"
667   1236              ;xc+y;
667   1236              	C_LINE	668,"Graphics\L2graphics.c"
668   1236  21 0A 00    	ld	hl,10	;const
668   1239  CD 00 00    	call	l_gintspsp	;
668   123C  21 06 00    	ld	hl,6	;const
668   123F  39          	add	hl,sp
668   1240  CD 00 00    	call	l_gint	;
668   1243  D1          	pop	de
668   1244  19          	add	hl,de
668   1245  26 00       	ld	h,0
668   1247  E5          	push	hl
668   1248              ;yc-x;
668   1248              	C_LINE	668,"Graphics\L2graphics.c"
668   1248  21 0A 00    	ld	hl,10	;const
668   124B  CD 00 00    	call	l_gintspsp	;
668   124E  21 0A 00    	ld	hl,10	;const
668   1251  39          	add	hl,sp
668   1252  CD 00 00    	call	l_gint	;
668   1255  D1          	pop	de
668   1256  EB          	ex	de,hl
668   1257  A7          	and	a
668   1258  ED 52       	sbc	hl,de
668   125A  26 00       	ld	h,0
668   125C  E5          	push	hl
668   125D              ;color;
668   125D              	C_LINE	668,"Graphics\L2graphics.c"
668   125D  21 06 00    	ld	hl,6	;const
668   1260  39          	add	hl,sp
668   1261  6E          	ld	l,(hl)
668   1262  26 00       	ld	h,0
668   1264  E5          	push	hl
668   1265  CD 32 01    	call	_l2_plot_pixel
668   1268  C1          	pop	bc
668   1269  C1          	pop	bc
668   126A  C1          	pop	bc
668   126B              ;    l2_plot_pixel(xc-y, yc-x, color);
668   126B              	C_LINE	668,"Graphics\L2graphics.c"
668   126B              	C_LINE	668,"Graphics\L2graphics.c"
668   126B              ;xc-y;
668   126B              	C_LINE	669,"Graphics\L2graphics.c"
669   126B  21 0A 00    	ld	hl,10	;const
669   126E  CD 00 00    	call	l_gintspsp	;
669   1271  21 06 00    	ld	hl,6	;const
669   1274  39          	add	hl,sp
669   1275  CD 00 00    	call	l_gint	;
669   1278  D1          	pop	de
669   1279  EB          	ex	de,hl
669   127A  A7          	and	a
669   127B  ED 52       	sbc	hl,de
669   127D  26 00       	ld	h,0
669   127F  E5          	push	hl
669   1280              ;yc-x;
669   1280              	C_LINE	669,"Graphics\L2graphics.c"
669   1280  21 0A 00    	ld	hl,10	;const
669   1283  CD 00 00    	call	l_gintspsp	;
669   1286  21 0A 00    	ld	hl,10	;const
669   1289  39          	add	hl,sp
669   128A  CD 00 00    	call	l_gint	;
669   128D  D1          	pop	de
669   128E  EB          	ex	de,hl
669   128F  A7          	and	a
669   1290  ED 52       	sbc	hl,de
669   1292  26 00       	ld	h,0
669   1294  E5          	push	hl
669   1295              ;color;
669   1295              	C_LINE	669,"Graphics\L2graphics.c"
669   1295  21 06 00    	ld	hl,6	;const
669   1298  39          	add	hl,sp
669   1299  6E          	ld	l,(hl)
669   129A  26 00       	ld	h,0
669   129C  E5          	push	hl
669   129D  CD 32 01    	call	_l2_plot_pixel
669   12A0  C1          	pop	bc
669   12A1  C1          	pop	bc
669   12A2  C1          	pop	bc
669   12A3              ;}
669   12A3              	C_LINE	669,"Graphics\L2graphics.c"
669   12A3  C9          	ret
669   12A4              
669   12A4              
669   12A4              ;
669   12A4              	C_LINE	670,"Graphics\L2graphics.c"
670   12A4              ;
670   12A4              	C_LINE	671,"Graphics\L2graphics.c"
671   12A4              ;void l2_draw_circle(int xc, int yc, int r,uint8_t color)
671   12A4              	C_LINE	672,"Graphics\L2graphics.c"
672   12A4              ;{
672   12A4              	C_LINE	673,"Graphics\L2graphics.c"
673   12A4              
673   12A4              ; Function l2_draw_circle flags 0x00000200 __smallc
673   12A4              ; void l2_draw_circle(int xc, int yc, int r, unsigned char color)
673   12A4              ; parameter 'unsigned char color' at 2 size(1)
673   12A4              ; parameter 'int r' at 4 size(2)
673   12A4              ; parameter 'int yc' at 6 size(2)
673   12A4              ; parameter 'int xc' at 8 size(2)
673   12A4              ._l2_draw_circle
673   12A4              	C_LINE	673,"Graphics\L2graphics.c"
673   12A4              ;    l2_circle_x = 0;
673   12A4              	C_LINE	674,"Graphics\L2graphics.c"
674   12A4              	C_LINE	674,"Graphics\L2graphics.c"
674   12A4  21 00 00    	ld	hl,0	;const
674   12A7  22 AF 17    	ld	(_l2_circle_x),hl
674   12AA              ;	l2_circle_y = r;
674   12AA              	C_LINE	675,"Graphics\L2graphics.c"
675   12AA              	C_LINE	675,"Graphics\L2graphics.c"
675   12AA  21 04 00    	ld	hl,4	;const
675   12AD  39          	add	hl,sp
675   12AE  CD 00 00    	call	l_gint	;
675   12B1  22 B1 17    	ld	(_l2_circle_y),hl
675   12B4              ;    l2_circle_d = 3 - (2 * r);
675   12B4              	C_LINE	676,"Graphics\L2graphics.c"
676   12B4              	C_LINE	676,"Graphics\L2graphics.c"
676   12B4  21 04 00    	ld	hl,4	;const
676   12B7  39          	add	hl,sp
676   12B8  CD 00 00    	call	l_gint	;
676   12BB  29          	add	hl,hl
676   12BC  11 03 00    	ld	de,3
676   12BF  EB          	ex	de,hl
676   12C0  A7          	and	a
676   12C1  ED 52       	sbc	hl,de
676   12C3  22 B3 17    	ld	(_l2_circle_d),hl
676   12C6              ;    l2_draw_circle_px(xc, yc, l2_circle_x, l2_circle_y,color);
676   12C6              	C_LINE	677,"Graphics\L2graphics.c"
677   12C6              	C_LINE	677,"Graphics\L2graphics.c"
677   12C6              ;xc;
677   12C6              	C_LINE	678,"Graphics\L2graphics.c"
678   12C6  21 08 00    	ld	hl,8	;const
678   12C9  39          	add	hl,sp
678   12CA  CD 00 00    	call	l_gint	;
678   12CD  E5          	push	hl
678   12CE              ;yc;
678   12CE              	C_LINE	678,"Graphics\L2graphics.c"
678   12CE  21 08 00    	ld	hl,8	;const
678   12D1  39          	add	hl,sp
678   12D2  CD 00 00    	call	l_gint	;
678   12D5  E5          	push	hl
678   12D6              ;l2_circle_x;
678   12D6              	C_LINE	678,"Graphics\L2graphics.c"
678   12D6  2A AF 17    	ld	hl,(_l2_circle_x)
678   12D9  E5          	push	hl
678   12DA              ;l2_circle_y;
678   12DA              	C_LINE	678,"Graphics\L2graphics.c"
678   12DA  2A B1 17    	ld	hl,(_l2_circle_y)
678   12DD  E5          	push	hl
678   12DE              ;color;
678   12DE              	C_LINE	678,"Graphics\L2graphics.c"
678   12DE  21 0A 00    	ld	hl,10	;const
678   12E1  39          	add	hl,sp
678   12E2  6E          	ld	l,(hl)
678   12E3  26 00       	ld	h,0
678   12E5  E5          	push	hl
678   12E6  CD FB 10    	call	_l2_draw_circle_px
678   12E9  C1          	pop	bc
678   12EA  C1          	pop	bc
678   12EB  C1          	pop	bc
678   12EC  C1          	pop	bc
678   12ED  C1          	pop	bc
678   12EE              ;    while (l2_circle_y >= l2_circle_x)
678   12EE              	C_LINE	678,"Graphics\L2graphics.c"
678   12EE              	C_LINE	678,"Graphics\L2graphics.c"
678   12EE              .i_130
678   12EE  ED 5B B1 17 	ld	de,(_l2_circle_y)
678   12F2  2A AF 17    	ld	hl,(_l2_circle_x)
678   12F5  CD 00 00    	call	l_ge
678   12F8  D2 70 13    	jp	nc,i_131
678   12FB              ;    {
678   12FB              	C_LINE	679,"Graphics\L2graphics.c"
679   12FB              	C_LINE	679,"Graphics\L2graphics.c"
679   12FB              ;
679   12FB              	C_LINE	680,"Graphics\L2graphics.c"
680   12FB              ;        ++l2_circle_x;
680   12FB              	C_LINE	681,"Graphics\L2graphics.c"
681   12FB              	C_LINE	681,"Graphics\L2graphics.c"
681   12FB  2A AF 17    	ld	hl,(_l2_circle_x)
681   12FE  23          	inc	hl
681   12FF  22 AF 17    	ld	(_l2_circle_x),hl
681   1302              ;
681   1302              	C_LINE	682,"Graphics\L2graphics.c"
682   1302              ;        if (l2_circle_d > 0)
682   1302              	C_LINE	683,"Graphics\L2graphics.c"
683   1302              	C_LINE	683,"Graphics\L2graphics.c"
683   1302  2A B3 17    	ld	hl,(_l2_circle_d)
683   1305  11 00 00    	ld	de,0
683   1308  EB          	ex	de,hl
683   1309  CD 00 00    	call	l_gt
683   130C  D2 33 13    	jp	nc,i_132
683   130F              ;        {
683   130F              	C_LINE	684,"Graphics\L2graphics.c"
684   130F              	C_LINE	684,"Graphics\L2graphics.c"
684   130F              ;            --l2_circle_y;
684   130F              	C_LINE	685,"Graphics\L2graphics.c"
685   130F              	C_LINE	685,"Graphics\L2graphics.c"
685   130F  2A B1 17    	ld	hl,(_l2_circle_y)
685   1312  2B          	dec	hl
685   1313  22 B1 17    	ld	(_l2_circle_y),hl
685   1316              ;            l2_circle_d = l2_circle_d + 4 * (l2_circle_x - l2_circle_y) + 10;
685   1316              	C_LINE	686,"Graphics\L2graphics.c"
686   1316              	C_LINE	686,"Graphics\L2graphics.c"
686   1316  2A B3 17    	ld	hl,(_l2_circle_d)
686   1319  E5          	push	hl
686   131A  ED 5B AF 17 	ld	de,(_l2_circle_x)
686   131E  2A B1 17    	ld	hl,(_l2_circle_y)
686   1321  EB          	ex	de,hl
686   1322  A7          	and	a
686   1323  ED 52       	sbc	hl,de
686   1325  29          	add	hl,hl
686   1326  29          	add	hl,hl
686   1327  D1          	pop	de
686   1328  19          	add	hl,de
686   1329  ED 34 0A 00 	add	hl,10
686   132D  22 B3 17    	ld	(_l2_circle_d),hl
686   1330              ;        }
686   1330              	C_LINE	687,"Graphics\L2graphics.c"
687   1330              ;        else
687   1330              	C_LINE	688,"Graphics\L2graphics.c"
688   1330  C3 45 13    	jp	i_133
688   1333              .i_132
688   1333              ;		{
688   1333              	C_LINE	689,"Graphics\L2graphics.c"
689   1333              	C_LINE	689,"Graphics\L2graphics.c"
689   1333              ;            l2_circle_d = l2_circle_d + 4 * l2_circle_x + 6;
689   1333              	C_LINE	690,"Graphics\L2graphics.c"
690   1333              	C_LINE	690,"Graphics\L2graphics.c"
690   1333  2A B3 17    	ld	hl,(_l2_circle_d)
690   1336  E5          	push	hl
690   1337  2A AF 17    	ld	hl,(_l2_circle_x)
690   133A  29          	add	hl,hl
690   133B  29          	add	hl,hl
690   133C  D1          	pop	de
690   133D  19          	add	hl,de
690   133E  ED 34 06 00 	add	hl,6
690   1342  22 B3 17    	ld	(_l2_circle_d),hl
690   1345              ;		}
690   1345              	C_LINE	691,"Graphics\L2graphics.c"
691   1345              .i_133
691   1345              ;        l2_draw_circle_px(xc, yc, l2_circle_x, l2_circle_y,color);
691   1345              	C_LINE	692,"Graphics\L2graphics.c"
692   1345              	C_LINE	692,"Graphics\L2graphics.c"
692   1345              ;xc;
692   1345              	C_LINE	693,"Graphics\L2graphics.c"
693   1345  21 08 00    	ld	hl,8	;const
693   1348  39          	add	hl,sp
693   1349  CD 00 00    	call	l_gint	;
693   134C  E5          	push	hl
693   134D              ;yc;
693   134D              	C_LINE	693,"Graphics\L2graphics.c"
693   134D  21 08 00    	ld	hl,8	;const
693   1350  39          	add	hl,sp
693   1351  CD 00 00    	call	l_gint	;
693   1354  E5          	push	hl
693   1355              ;l2_circle_x;
693   1355              	C_LINE	693,"Graphics\L2graphics.c"
693   1355  2A AF 17    	ld	hl,(_l2_circle_x)
693   1358  E5          	push	hl
693   1359              ;l2_circle_y;
693   1359              	C_LINE	693,"Graphics\L2graphics.c"
693   1359  2A B1 17    	ld	hl,(_l2_circle_y)
693   135C  E5          	push	hl
693   135D              ;color;
693   135D              	C_LINE	693,"Graphics\L2graphics.c"
693   135D  21 0A 00    	ld	hl,10	;const
693   1360  39          	add	hl,sp
693   1361  6E          	ld	l,(hl)
693   1362  26 00       	ld	h,0
693   1364  E5          	push	hl
693   1365  CD FB 10    	call	_l2_draw_circle_px
693   1368  C1          	pop	bc
693   1369  C1          	pop	bc
693   136A  C1          	pop	bc
693   136B  C1          	pop	bc
693   136C  C1          	pop	bc
693   136D              ;    }
693   136D              	C_LINE	693,"Graphics\L2graphics.c"
693   136D  C3 EE 12    	jp	i_130
693   1370              .i_131
693   1370              ;}
693   1370              	C_LINE	694,"Graphics\L2graphics.c"
694   1370  C9          	ret
694   1371              
694   1371              
694   1371              ;
694   1371              	C_LINE	696,"Graphics\L2graphics.c"
696   1371              ;void l2_draw_circle_fill_px(int xc, int yc, int x, int y, uint8_t color)
696   1371              	C_LINE	697,"Graphics\L2graphics.c"
697   1371              ;{
697   1371              	C_LINE	698,"Graphics\L2graphics.c"
698   1371              
698   1371              ; Function l2_draw_circle_fill_px flags 0x00000200 __smallc
698   1371              ; void l2_draw_circle_fill_px(int xc, int yc, int x, int y, unsigned char color)
698   1371              ; parameter 'unsigned char color' at 2 size(1)
698   1371              ; parameter 'int y' at 4 size(2)
698   1371              ; parameter 'int x' at 6 size(2)
698   1371              ; parameter 'int yc' at 8 size(2)
698   1371              ; parameter 'int xc' at 10 size(2)
698   1371              ._l2_draw_circle_fill_px
698   1371              	C_LINE	698,"Graphics\L2graphics.c"
698   1371              ;	l2_circle_doublex = x << 1;
698   1371              	C_LINE	699,"Graphics\L2graphics.c"
699   1371              	C_LINE	699,"Graphics\L2graphics.c"
699   1371  21 06 00    	ld	hl,6	;const
699   1374  39          	add	hl,sp
699   1375  CD 00 00    	call	l_gint	;
699   1378  29          	add	hl,hl
699   1379  26 00       	ld	h,0
699   137B  7D          	ld	a,l
699   137C  32 B5 17    	ld	(_l2_circle_doublex),a
699   137F              ;	l2_circle_doubley = y << 1;
699   137F              	C_LINE	700,"Graphics\L2graphics.c"
700   137F              	C_LINE	700,"Graphics\L2graphics.c"
700   137F  21 04 00    	ld	hl,4	;const
700   1382  39          	add	hl,sp
700   1383  CD 00 00    	call	l_gint	;
700   1386  29          	add	hl,hl
700   1387  26 00       	ld	h,0
700   1389  7D          	ld	a,l
700   138A  32 B6 17    	ld	(_l2_circle_doubley),a
700   138D              ;	l2_draw_horz_line(xc-x,  yc+y, l2_circle_doublex, color);
700   138D              	C_LINE	701,"Graphics\L2graphics.c"
701   138D              	C_LINE	701,"Graphics\L2graphics.c"
701   138D              ;xc-x;
701   138D              	C_LINE	702,"Graphics\L2graphics.c"
702   138D  21 0A 00    	ld	hl,10	;const
702   1390  CD 00 00    	call	l_gintspsp	;
702   1393  21 08 00    	ld	hl,8	;const
702   1396  39          	add	hl,sp
702   1397  CD 00 00    	call	l_gint	;
702   139A  D1          	pop	de
702   139B  EB          	ex	de,hl
702   139C  A7          	and	a
702   139D  ED 52       	sbc	hl,de
702   139F  26 00       	ld	h,0
702   13A1  E5          	push	hl
702   13A2              ;yc+y;
702   13A2              	C_LINE	702,"Graphics\L2graphics.c"
702   13A2  21 0A 00    	ld	hl,10	;const
702   13A5  CD 00 00    	call	l_gintspsp	;
702   13A8  21 08 00    	ld	hl,8	;const
702   13AB  39          	add	hl,sp
702   13AC  CD 00 00    	call	l_gint	;
702   13AF  D1          	pop	de
702   13B0  19          	add	hl,de
702   13B1  26 00       	ld	h,0
702   13B3  E5          	push	hl
702   13B4              ;l2_circle_doublex;
702   13B4              	C_LINE	702,"Graphics\L2graphics.c"
702   13B4  2A B5 17    	ld	hl,(_l2_circle_doublex)
702   13B7  26 00       	ld	h,0
702   13B9  E5          	push	hl
702   13BA              ;color;
702   13BA              	C_LINE	702,"Graphics\L2graphics.c"
702   13BA  21 08 00    	ld	hl,8	;const
702   13BD  39          	add	hl,sp
702   13BE  6E          	ld	l,(hl)
702   13BF  26 00       	ld	h,0
702   13C1  E5          	push	hl
702   13C2  CD 6D 01    	call	_l2_draw_horz_line
702   13C5  C1          	pop	bc
702   13C6  C1          	pop	bc
702   13C7  C1          	pop	bc
702   13C8  C1          	pop	bc
702   13C9              ;	l2_draw_horz_line(xc-x,  yc-y, l2_circle_doublex, color);
702   13C9              	C_LINE	702,"Graphics\L2graphics.c"
702   13C9              	C_LINE	702,"Graphics\L2graphics.c"
702   13C9              ;xc-x;
702   13C9              	C_LINE	703,"Graphics\L2graphics.c"
703   13C9  21 0A 00    	ld	hl,10	;const
703   13CC  CD 00 00    	call	l_gintspsp	;
703   13CF  21 08 00    	ld	hl,8	;const
703   13D2  39          	add	hl,sp
703   13D3  CD 00 00    	call	l_gint	;
703   13D6  D1          	pop	de
703   13D7  EB          	ex	de,hl
703   13D8  A7          	and	a
703   13D9  ED 52       	sbc	hl,de
703   13DB  26 00       	ld	h,0
703   13DD  E5          	push	hl
703   13DE              ;yc-y;
703   13DE              	C_LINE	703,"Graphics\L2graphics.c"
703   13DE  21 0A 00    	ld	hl,10	;const
703   13E1  CD 00 00    	call	l_gintspsp	;
703   13E4  21 08 00    	ld	hl,8	;const
703   13E7  39          	add	hl,sp
703   13E8  CD 00 00    	call	l_gint	;
703   13EB  D1          	pop	de
703   13EC  EB          	ex	de,hl
703   13ED  A7          	and	a
703   13EE  ED 52       	sbc	hl,de
703   13F0  26 00       	ld	h,0
703   13F2  E5          	push	hl
703   13F3              ;l2_circle_doublex;
703   13F3              	C_LINE	703,"Graphics\L2graphics.c"
703   13F3  2A B5 17    	ld	hl,(_l2_circle_doublex)
703   13F6  26 00       	ld	h,0
703   13F8  E5          	push	hl
703   13F9              ;color;
703   13F9              	C_LINE	703,"Graphics\L2graphics.c"
703   13F9  21 08 00    	ld	hl,8	;const
703   13FC  39          	add	hl,sp
703   13FD  6E          	ld	l,(hl)
703   13FE  26 00       	ld	h,0
703   1400  E5          	push	hl
703   1401  CD 6D 01    	call	_l2_draw_horz_line
703   1404  C1          	pop	bc
703   1405  C1          	pop	bc
703   1406  C1          	pop	bc
703   1407  C1          	pop	bc
703   1408              ;	l2_draw_horz_line(xc-y,  yc+x, l2_circle_doubley, color);
703   1408              	C_LINE	703,"Graphics\L2graphics.c"
703   1408              	C_LINE	703,"Graphics\L2graphics.c"
703   1408              ;xc-y;
703   1408              	C_LINE	704,"Graphics\L2graphics.c"
704   1408  21 0A 00    	ld	hl,10	;const
704   140B  CD 00 00    	call	l_gintspsp	;
704   140E  21 06 00    	ld	hl,6	;const
704   1411  39          	add	hl,sp
704   1412  CD 00 00    	call	l_gint	;
704   1415  D1          	pop	de
704   1416  EB          	ex	de,hl
704   1417  A7          	and	a
704   1418  ED 52       	sbc	hl,de
704   141A  26 00       	ld	h,0
704   141C  E5          	push	hl
704   141D              ;yc+x;
704   141D              	C_LINE	704,"Graphics\L2graphics.c"
704   141D  21 0A 00    	ld	hl,10	;const
704   1420  CD 00 00    	call	l_gintspsp	;
704   1423  21 0A 00    	ld	hl,10	;const
704   1426  39          	add	hl,sp
704   1427  CD 00 00    	call	l_gint	;
704   142A  D1          	pop	de
704   142B  19          	add	hl,de
704   142C  26 00       	ld	h,0
704   142E  E5          	push	hl
704   142F              ;l2_circle_doubley;
704   142F              	C_LINE	704,"Graphics\L2graphics.c"
704   142F  2A B6 17    	ld	hl,(_l2_circle_doubley)
704   1432  26 00       	ld	h,0
704   1434  E5          	push	hl
704   1435              ;color;
704   1435              	C_LINE	704,"Graphics\L2graphics.c"
704   1435  21 08 00    	ld	hl,8	;const
704   1438  39          	add	hl,sp
704   1439  6E          	ld	l,(hl)
704   143A  26 00       	ld	h,0
704   143C  E5          	push	hl
704   143D  CD 6D 01    	call	_l2_draw_horz_line
704   1440  C1          	pop	bc
704   1441  C1          	pop	bc
704   1442  C1          	pop	bc
704   1443  C1          	pop	bc
704   1444              ;	l2_draw_horz_line(xc-y,  yc-x, l2_circle_doubley, color);
704   1444              	C_LINE	704,"Graphics\L2graphics.c"
704   1444              	C_LINE	704,"Graphics\L2graphics.c"
704   1444              ;xc-y;
704   1444              	C_LINE	705,"Graphics\L2graphics.c"
705   1444  21 0A 00    	ld	hl,10	;const
705   1447  CD 00 00    	call	l_gintspsp	;
705   144A  21 06 00    	ld	hl,6	;const
705   144D  39          	add	hl,sp
705   144E  CD 00 00    	call	l_gint	;
705   1451  D1          	pop	de
705   1452  EB          	ex	de,hl
705   1453  A7          	and	a
705   1454  ED 52       	sbc	hl,de
705   1456  26 00       	ld	h,0
705   1458  E5          	push	hl
705   1459              ;yc-x;
705   1459              	C_LINE	705,"Graphics\L2graphics.c"
705   1459  21 0A 00    	ld	hl,10	;const
705   145C  CD 00 00    	call	l_gintspsp	;
705   145F  21 0A 00    	ld	hl,10	;const
705   1462  39          	add	hl,sp
705   1463  CD 00 00    	call	l_gint	;
705   1466  D1          	pop	de
705   1467  EB          	ex	de,hl
705   1468  A7          	and	a
705   1469  ED 52       	sbc	hl,de
705   146B  26 00       	ld	h,0
705   146D  E5          	push	hl
705   146E              ;l2_circle_doubley;
705   146E              	C_LINE	705,"Graphics\L2graphics.c"
705   146E  2A B6 17    	ld	hl,(_l2_circle_doubley)
705   1471  26 00       	ld	h,0
705   1473  E5          	push	hl
705   1474              ;color;
705   1474              	C_LINE	705,"Graphics\L2graphics.c"
705   1474  21 08 00    	ld	hl,8	;const
705   1477  39          	add	hl,sp
705   1478  6E          	ld	l,(hl)
705   1479  26 00       	ld	h,0
705   147B  E5          	push	hl
705   147C  CD 6D 01    	call	_l2_draw_horz_line
705   147F  C1          	pop	bc
705   1480  C1          	pop	bc
705   1481  C1          	pop	bc
705   1482  C1          	pop	bc
705   1483              ;}
705   1483              	C_LINE	705,"Graphics\L2graphics.c"
705   1483  C9          	ret
705   1484              
705   1484              
705   1484              ;
705   1484              	C_LINE	706,"Graphics\L2graphics.c"
706   1484              ;
706   1484              	C_LINE	707,"Graphics\L2graphics.c"
707   1484              ;void l2_draw_circle_fill(int xc, int yc, int r,uint8_t color)
707   1484              	C_LINE	708,"Graphics\L2graphics.c"
708   1484              ;{
708   1484              	C_LINE	709,"Graphics\L2graphics.c"
709   1484              
709   1484              ; Function l2_draw_circle_fill flags 0x00000200 __smallc
709   1484              ; void l2_draw_circle_fill(int xc, int yc, int r, unsigned char color)
709   1484              ; parameter 'unsigned char color' at 2 size(1)
709   1484              ; parameter 'int r' at 4 size(2)
709   1484              ; parameter 'int yc' at 6 size(2)
709   1484              ; parameter 'int xc' at 8 size(2)
709   1484              ._l2_draw_circle_fill
709   1484              	C_LINE	709,"Graphics\L2graphics.c"
709   1484              ;    l2_circle_x = 0;
709   1484              	C_LINE	710,"Graphics\L2graphics.c"
710   1484              	C_LINE	710,"Graphics\L2graphics.c"
710   1484  21 00 00    	ld	hl,0	;const
710   1487  22 AF 17    	ld	(_l2_circle_x),hl
710   148A              ;	l2_circle_y = r;
710   148A              	C_LINE	711,"Graphics\L2graphics.c"
711   148A              	C_LINE	711,"Graphics\L2graphics.c"
711   148A  21 04 00    	ld	hl,4	;const
711   148D  39          	add	hl,sp
711   148E  CD 00 00    	call	l_gint	;
711   1491  22 B1 17    	ld	(_l2_circle_y),hl
711   1494              ;    l2_circle_d = 3 - 2 * r;
711   1494              	C_LINE	712,"Graphics\L2graphics.c"
712   1494              	C_LINE	712,"Graphics\L2graphics.c"
712   1494  21 04 00    	ld	hl,4	;const
712   1497  39          	add	hl,sp
712   1498  CD 00 00    	call	l_gint	;
712   149B  29          	add	hl,hl
712   149C  11 03 00    	ld	de,3
712   149F  EB          	ex	de,hl
712   14A0  A7          	and	a
712   14A1  ED 52       	sbc	hl,de
712   14A3  22 B3 17    	ld	(_l2_circle_d),hl
712   14A6              ;
712   14A6              	C_LINE	713,"Graphics\L2graphics.c"
713   14A6              ;    l2_draw_circle_fill_px(xc, yc, l2_circle_x, l2_circle_y,color);
713   14A6              	C_LINE	714,"Graphics\L2graphics.c"
714   14A6              	C_LINE	714,"Graphics\L2graphics.c"
714   14A6              ;xc;
714   14A6              	C_LINE	715,"Graphics\L2graphics.c"
715   14A6  21 08 00    	ld	hl,8	;const
715   14A9  39          	add	hl,sp
715   14AA  CD 00 00    	call	l_gint	;
715   14AD  E5          	push	hl
715   14AE              ;yc;
715   14AE              	C_LINE	715,"Graphics\L2graphics.c"
715   14AE  21 08 00    	ld	hl,8	;const
715   14B1  39          	add	hl,sp
715   14B2  CD 00 00    	call	l_gint	;
715   14B5  E5          	push	hl
715   14B6              ;l2_circle_x;
715   14B6              	C_LINE	715,"Graphics\L2graphics.c"
715   14B6  2A AF 17    	ld	hl,(_l2_circle_x)
715   14B9  E5          	push	hl
715   14BA              ;l2_circle_y;
715   14BA              	C_LINE	715,"Graphics\L2graphics.c"
715   14BA  2A B1 17    	ld	hl,(_l2_circle_y)
715   14BD  E5          	push	hl
715   14BE              ;color;
715   14BE              	C_LINE	715,"Graphics\L2graphics.c"
715   14BE  21 0A 00    	ld	hl,10	;const
715   14C1  39          	add	hl,sp
715   14C2  6E          	ld	l,(hl)
715   14C3  26 00       	ld	h,0
715   14C5  E5          	push	hl
715   14C6  CD 71 13    	call	_l2_draw_circle_fill_px
715   14C9  C1          	pop	bc
715   14CA  C1          	pop	bc
715   14CB  C1          	pop	bc
715   14CC  C1          	pop	bc
715   14CD  C1          	pop	bc
715   14CE              ;    while (l2_circle_y >= l2_circle_x)
715   14CE              	C_LINE	715,"Graphics\L2graphics.c"
715   14CE              	C_LINE	715,"Graphics\L2graphics.c"
715   14CE              .i_134
715   14CE  ED 5B B1 17 	ld	de,(_l2_circle_y)
715   14D2  2A AF 17    	ld	hl,(_l2_circle_x)
715   14D5  CD 00 00    	call	l_ge
715   14D8  D2 50 15    	jp	nc,i_135
715   14DB              ;    {
715   14DB              	C_LINE	716,"Graphics\L2graphics.c"
716   14DB              	C_LINE	716,"Graphics\L2graphics.c"
716   14DB              ;
716   14DB              	C_LINE	717,"Graphics\L2graphics.c"
717   14DB              ;        ++l2_circle_x;
717   14DB              	C_LINE	718,"Graphics\L2graphics.c"
718   14DB              	C_LINE	718,"Graphics\L2graphics.c"
718   14DB  2A AF 17    	ld	hl,(_l2_circle_x)
718   14DE  23          	inc	hl
718   14DF  22 AF 17    	ld	(_l2_circle_x),hl
718   14E2              ;
718   14E2              	C_LINE	719,"Graphics\L2graphics.c"
719   14E2              ;        if (l2_circle_d > 0)
719   14E2              	C_LINE	720,"Graphics\L2graphics.c"
720   14E2              	C_LINE	720,"Graphics\L2graphics.c"
720   14E2  2A B3 17    	ld	hl,(_l2_circle_d)
720   14E5  11 00 00    	ld	de,0
720   14E8  EB          	ex	de,hl
720   14E9  CD 00 00    	call	l_gt
720   14EC  D2 13 15    	jp	nc,i_136
720   14EF              ;        {
720   14EF              	C_LINE	721,"Graphics\L2graphics.c"
721   14EF              	C_LINE	721,"Graphics\L2graphics.c"
721   14EF              ;            --l2_circle_y;
721   14EF              	C_LINE	722,"Graphics\L2graphics.c"
722   14EF              	C_LINE	722,"Graphics\L2graphics.c"
722   14EF  2A B1 17    	ld	hl,(_l2_circle_y)
722   14F2  2B          	dec	hl
722   14F3  22 B1 17    	ld	(_l2_circle_y),hl
722   14F6              ;            l2_circle_d = l2_circle_d + 4 * (l2_circle_x - l2_circle_y) + 10;
722   14F6              	C_LINE	723,"Graphics\L2graphics.c"
723   14F6              	C_LINE	723,"Graphics\L2graphics.c"
723   14F6  2A B3 17    	ld	hl,(_l2_circle_d)
723   14F9  E5          	push	hl
723   14FA  ED 5B AF 17 	ld	de,(_l2_circle_x)
723   14FE  2A B1 17    	ld	hl,(_l2_circle_y)
723   1501  EB          	ex	de,hl
723   1502  A7          	and	a
723   1503  ED 52       	sbc	hl,de
723   1505  29          	add	hl,hl
723   1506  29          	add	hl,hl
723   1507  D1          	pop	de
723   1508  19          	add	hl,de
723   1509  ED 34 0A 00 	add	hl,10
723   150D  22 B3 17    	ld	(_l2_circle_d),hl
723   1510              ;        }
723   1510              	C_LINE	724,"Graphics\L2graphics.c"
724   1510              ;        else
724   1510              	C_LINE	725,"Graphics\L2graphics.c"
725   1510  C3 25 15    	jp	i_137
725   1513              .i_136
725   1513              ;		{
725   1513              	C_LINE	726,"Graphics\L2graphics.c"
726   1513              	C_LINE	726,"Graphics\L2graphics.c"
726   1513              ;            l2_circle_d = l2_circle_d + 4 * l2_circle_x + 6;
726   1513              	C_LINE	727,"Graphics\L2graphics.c"
727   1513              	C_LINE	727,"Graphics\L2graphics.c"
727   1513  2A B3 17    	ld	hl,(_l2_circle_d)
727   1516  E5          	push	hl
727   1517  2A AF 17    	ld	hl,(_l2_circle_x)
727   151A  29          	add	hl,hl
727   151B  29          	add	hl,hl
727   151C  D1          	pop	de
727   151D  19          	add	hl,de
727   151E  ED 34 06 00 	add	hl,6
727   1522  22 B3 17    	ld	(_l2_circle_d),hl
727   1525              ;		}
727   1525              	C_LINE	728,"Graphics\L2graphics.c"
728   1525              .i_137
728   1525              ;        l2_draw_circle_fill_px(xc, yc, l2_circle_x, l2_circle_y,color);
728   1525              	C_LINE	729,"Graphics\L2graphics.c"
729   1525              	C_LINE	729,"Graphics\L2graphics.c"
729   1525              ;xc;
729   1525              	C_LINE	730,"Graphics\L2graphics.c"
730   1525  21 08 00    	ld	hl,8	;const
730   1528  39          	add	hl,sp
730   1529  CD 00 00    	call	l_gint	;
730   152C  E5          	push	hl
730   152D              ;yc;
730   152D              	C_LINE	730,"Graphics\L2graphics.c"
730   152D  21 08 00    	ld	hl,8	;const
730   1530  39          	add	hl,sp
730   1531  CD 00 00    	call	l_gint	;
730   1534  E5          	push	hl
730   1535              ;l2_circle_x;
730   1535              	C_LINE	730,"Graphics\L2graphics.c"
730   1535  2A AF 17    	ld	hl,(_l2_circle_x)
730   1538  E5          	push	hl
730   1539              ;l2_circle_y;
730   1539              	C_LINE	730,"Graphics\L2graphics.c"
730   1539  2A B1 17    	ld	hl,(_l2_circle_y)
730   153C  E5          	push	hl
730   153D              ;color;
730   153D              	C_LINE	730,"Graphics\L2graphics.c"
730   153D  21 0A 00    	ld	hl,10	;const
730   1540  39          	add	hl,sp
730   1541  6E          	ld	l,(hl)
730   1542  26 00       	ld	h,0
730   1544  E5          	push	hl
730   1545  CD 71 13    	call	_l2_draw_circle_fill_px
730   1548  C1          	pop	bc
730   1549  C1          	pop	bc
730   154A  C1          	pop	bc
730   154B  C1          	pop	bc
730   154C  C1          	pop	bc
730   154D              ;    }
730   154D              	C_LINE	730,"Graphics\L2graphics.c"
730   154D  C3 CE 14    	jp	i_134
730   1550              .i_135
730   1550              ;}
730   1550              	C_LINE	731,"Graphics\L2graphics.c"
731   1550  C9          	ret
731   1551              
731   1551              
731   1551              ;
731   1551              	C_LINE	776,"Graphics\L2graphics.c"
776   1551              ;
776   1551              	C_LINE	777,"Graphics\L2graphics.c"
777   1551              ;
777   1551              	C_LINE	778,"Graphics\L2graphics.c"
778   1551              ;
778   1551              	C_LINE	779,"Graphics\L2graphics.c"
779   1551              ;
779   1551              	C_LINE	780,"Graphics\L2graphics.c"
780   1551              ;
780   1551              	C_LINE	781,"Graphics\L2graphics.c"
781   1551              ;
781   1551              	C_LINE	782,"Graphics\L2graphics.c"
782   1551              ;
782   1551              	C_LINE	783,"Graphics\L2graphics.c"
783   1551              ;
783   1551              	C_LINE	784,"Graphics\L2graphics.c"
784   1551              ;
784   1551              	C_LINE	785,"Graphics\L2graphics.c"
785   1551              ;
785   1551              	C_LINE	786,"Graphics\L2graphics.c"
786   1551              ;
786   1551              	C_LINE	787,"Graphics\L2graphics.c"
787   1551              ;
787   1551              	C_LINE	788,"Graphics\L2graphics.c"
788   1551              ;
788   1551              	C_LINE	789,"Graphics\L2graphics.c"
789   1551              ;
789   1551              	C_LINE	790,"Graphics\L2graphics.c"
790   1551              ;
790   1551              	C_LINE	791,"Graphics\L2graphics.c"
791   1551              ;
791   1551              	C_LINE	792,"Graphics\L2graphics.c"
792   1551              ;
792   1551              	C_LINE	793,"Graphics\L2graphics.c"
793   1551              ;
793   1551              	C_LINE	796,"Graphics\L2graphics.c"
796   1551              ;
796   1551              	C_LINE	806,"Graphics\L2graphics.c"
806   1551              ;
806   1551              	C_LINE	813,"Graphics\L2graphics.c"
813   1551              ;
813   1551              	C_LINE	816,"Graphics\L2graphics.c"
816   1551              ;
816   1551              	C_LINE	820,"Graphics\L2graphics.c"
820   1551              ;
820   1551              	C_LINE	823,"Graphics\L2graphics.c"
823   1551              ;
823   1551              	C_LINE	830,"Graphics\L2graphics.c"
830   1551              ;
830   1551              	C_LINE	832,"Graphics\L2graphics.c"
832   1551              ;
832   1551              	C_LINE	835,"Graphics\L2graphics.c"
835   1551              ;
835   1551              	C_LINE	842,"Graphics\L2graphics.c"
842   1551              ;
842   1551              	C_LINE	844,"Graphics\L2graphics.c"
844   1551              ;
844   1551              	C_LINE	847,"Graphics\L2graphics.c"
847   1551              ;
847   1551              	C_LINE	854,"Graphics\L2graphics.c"
854   1551              ;
854   1551              	C_LINE	857,"Graphics\L2graphics.c"
857   1551              ;
857   1551              	C_LINE	858,"Graphics\L2graphics.c"
858   1551              ;
858   1551              	C_LINE	859,"Graphics\L2graphics.c"
859   1551              ;
859   1551              	C_LINE	860,"Graphics\L2graphics.c"
860   1551              ;
860   1551              	C_LINE	862,"Graphics\L2graphics.c"
862   1551              ;
862   1551              	C_LINE	865,"Graphics\L2graphics.c"
865   1551              ;
865   1551              	C_LINE	872,"Graphics\L2graphics.c"
872   1551              ;
872   1551              	C_LINE	877,"Graphics\L2graphics.c"
877   1551              ;
877   1551              	C_LINE	878,"Graphics\L2graphics.c"
878   1551              ;
878   1551              	C_LINE	879,"Graphics\L2graphics.c"
879   1551              ;
879   1551              	C_LINE	880,"Graphics\L2graphics.c"
880   1551              ;
880   1551              	C_LINE	882,"Graphics\L2graphics.c"
882   1551              ;
882   1551              	C_LINE	884,"Graphics\L2graphics.c"
884   1551              ;
884   1551              	C_LINE	885,"Graphics\L2graphics.c"
885   1551              ;
885   1551              	C_LINE	887,"Graphics\L2graphics.c"
887   1551              ;void l2_print_chr_at(uint8_t x, uint8_t y,  char chrText, uint8_t colour)
887   1551              	C_LINE	895,"Graphics\L2graphics.c"
895   1551              ;{
895   1551              	C_LINE	896,"Graphics\L2graphics.c"
896   1551              
896   1551              ; Function l2_print_chr_at flags 0x00000200 __smallc
896   1551              ; void l2_print_chr_at(unsigned char x, unsigned char y, char chrText, unsigned char colour)
896   1551              ; parameter 'unsigned char colour' at 2 size(1)
896   1551              ; parameter 'char chrText' at 4 size(1)
896   1551              ; parameter 'unsigned char y' at 6 size(1)
896   1551              ; parameter 'unsigned char x' at 8 size(1)
896   1551              ._l2_print_chr_at
896   1551              	C_LINE	896,"Graphics\L2graphics.c"
896   1551              ;    if (chrText >= 32 && chrText <127)
896   1551              	C_LINE	897,"Graphics\L2graphics.c"
897   1551              	C_LINE	897,"Graphics\L2graphics.c"
897   1551  21 04 00    	ld	hl,4	;const
897   1554  39          	add	hl,sp
897   1555  CD 00 00    	call	l_gchar
897   1558  7D          	ld	a,l
897   1559  EE 80       	xor	128
897   155B  D6 A0       	sub	160
897   155D  3F          	ccf
897   155E  D2 6D 15    	jp	nc,i_139
897   1561  21 04 00    	ld	hl,4	;const
897   1564  39          	add	hl,sp
897   1565  CD 00 00    	call	l_gchar
897   1568  7D          	ld	a,l
897   1569  D6 7F       	sub	127
897   156B  38 03       	jr	c,i_140_i_139
897   156D              .i_139
897   156D  C3 7D 16    	jp	i_138
897   1570              .i_140_i_139
897   1570              ;    {
897   1570              	C_LINE	898,"Graphics\L2graphics.c"
898   1570              	C_LINE	898,"Graphics\L2graphics.c"
898   1570              ;		l2_charAddr = chrText;
898   1570              	C_LINE	899,"Graphics\L2graphics.c"
899   1570              	C_LINE	899,"Graphics\L2graphics.c"
899   1570  21 04 00    	ld	hl,4	;const
899   1573  39          	add	hl,sp
899   1574  CD 00 00    	call	l_gchar
899   1577  22 99 17    	ld	(_l2_charAddr),hl
899   157A              ;		l2_charAddr = l2_charAddr << 3;
899   157A              	C_LINE	900,"Graphics\L2graphics.c"
900   157A              	C_LINE	900,"Graphics\L2graphics.c"
900   157A  2A 99 17    	ld	hl,(_l2_charAddr)
900   157D  29          	add	hl,hl
900   157E  29          	add	hl,hl
900   157F  29          	add	hl,hl
900   1580  22 99 17    	ld	(_l2_charAddr),hl
900   1583              ;		l2_charAddr  += 15360;
900   1583              	C_LINE	901,"Graphics\L2graphics.c"
901   1583              	C_LINE	901,"Graphics\L2graphics.c"
901   1583  2A 99 17    	ld	hl,(_l2_charAddr)
901   1586  ED 34 00 3C 	add	hl,15360
901   158A  22 99 17    	ld	(_l2_charAddr),hl
901   158D              ;        l2_y_work_pca = y+1;
901   158D              	C_LINE	902,"Graphics\L2graphics.c"
902   158D              	C_LINE	902,"Graphics\L2graphics.c"
902   158D  21 06 00    	ld	hl,6	;const
902   1590  39          	add	hl,sp
902   1591  6E          	ld	l,(hl)
902   1592  26 00       	ld	h,0
902   1594  23          	inc	hl
902   1595  26 00       	ld	h,0
902   1597  7D          	ld	a,l
902   1598  32 8E 17    	ld	(_l2_y_work_pca),a
902   159B              ;		l2_local_save = x+1;
902   159B              	C_LINE	903,"Graphics\L2graphics.c"
903   159B              	C_LINE	903,"Graphics\L2graphics.c"
903   159B  21 08 00    	ld	hl,8	;const
903   159E  39          	add	hl,sp
903   159F  6E          	ld	l,(hl)
903   15A0  26 00       	ld	h,0
903   15A2  23          	inc	hl
903   15A3  26 00       	ld	h,0
903   15A5  7D          	ld	a,l
903   15A6  32 93 17    	ld	(_l2_local_save),a
903   15A9              ;        for (l2_loopvar_charj = 1; l2_loopvar_charj < 8;  ++l2_loopvar_charj)
903   15A9              	C_LINE	904,"Graphics\L2graphics.c"
904   15A9              	C_LINE	904,"Graphics\L2graphics.c"
904   15A9  21 01 00    	ld	hl,1 % 256	;const
904   15AC  7D          	ld	a,l
904   15AD  32 81 17    	ld	(_l2_loopvar_charj),a
904   15B0  C3 BD 15    	jp	i_143
904   15B3              .i_141
904   15B3  2A 81 17    	ld	hl,(_l2_loopvar_charj)
904   15B6  26 00       	ld	h,0
904   15B8  23          	inc	hl
904   15B9  7D          	ld	a,l
904   15BA  32 81 17    	ld	(_l2_loopvar_charj),a
904   15BD              .i_143
904   15BD  2A 81 17    	ld	hl,(_l2_loopvar_charj)
904   15C0  26 00       	ld	h,0
904   15C2  7D          	ld	a,l
904   15C3  D6 08       	sub	8
904   15C5  D2 7D 16    	jp	nc,i_142
904   15C8              ;        {
904   15C8              	C_LINE	905,"Graphics\L2graphics.c"
905   15C8              	C_LINE	905,"Graphics\L2graphics.c"
905   15C8              ;			l2_x_work_pca = l2_local_save;
905   15C8              	C_LINE	906,"Graphics\L2graphics.c"
906   15C8              	C_LINE	906,"Graphics\L2graphics.c"
906   15C8  2A 93 17    	ld	hl,(_l2_local_save)
906   15CB  26 00       	ld	h,0
906   15CD  7D          	ld	a,l
906   15CE  32 8F 17    	ld	(_l2_x_work_pca),a
906   15D1              ;            l2_byteToWrite =  (*(unsigned char *)( l2_charAddr+l2_loopvar_charj )) ;
906   15D1              	C_LINE	907,"Graphics\L2graphics.c"
907   15D1              	C_LINE	907,"Graphics\L2graphics.c"
907   15D1  ED 5B 99 17 	ld	de,(_l2_charAddr)
907   15D5  2A 81 17    	ld	hl,(_l2_loopvar_charj)
907   15D8  26 00       	ld	h,0
907   15DA  19          	add	hl,de
907   15DB  6E          	ld	l,(hl)
907   15DC  26 00       	ld	h,0
907   15DE  7D          	ld	a,l
907   15DF  32 78 17    	ld	(_l2_byteToWrite),a
907   15E2              ;			if (l2_byteToWrite != 0)
907   15E2              	C_LINE	908,"Graphics\L2graphics.c"
908   15E2              	C_LINE	908,"Graphics\L2graphics.c"
908   15E2  2A 78 17    	ld	hl,(_l2_byteToWrite)
908   15E5  26 00       	ld	h,0
908   15E7  7D          	ld	a,l
908   15E8  A7          	and	a
908   15E9  CA 70 16    	jp	z,i_144
908   15EC              ;			{
908   15EC              	C_LINE	909,"Graphics\L2graphics.c"
909   15EC              	C_LINE	909,"Graphics\L2graphics.c"
909   15EC              ;                l2_byteToWrite = l2_byteToWrite << 1;
909   15EC              	C_LINE	910,"Graphics\L2graphics.c"
910   15EC              	C_LINE	910,"Graphics\L2graphics.c"
910   15EC  2A 78 17    	ld	hl,(_l2_byteToWrite)
910   15EF  26 00       	ld	h,0
910   15F1  29          	add	hl,hl
910   15F2  26 00       	ld	h,0
910   15F4  7D          	ld	a,l
910   15F5  32 78 17    	ld	(_l2_byteToWrite),a
910   15F8              ;                for (l2_loopvar_chark = 1; l2_loopvar_chark < 7; ++l2_loopvar_chark)
910   15F8              	C_LINE	911,"Graphics\L2graphics.c"
911   15F8              	C_LINE	911,"Graphics\L2graphics.c"
911   15F8  21 01 00    	ld	hl,1 % 256	;const
911   15FB  7D          	ld	a,l
911   15FC  32 82 17    	ld	(_l2_loopvar_chark),a
911   15FF  C3 0C 16    	jp	i_147
911   1602              .i_145
911   1602  2A 82 17    	ld	hl,(_l2_loopvar_chark)
911   1605  26 00       	ld	h,0
911   1607  23          	inc	hl
911   1608  7D          	ld	a,l
911   1609  32 82 17    	ld	(_l2_loopvar_chark),a
911   160C              .i_147
911   160C  2A 82 17    	ld	hl,(_l2_loopvar_chark)
911   160F  26 00       	ld	h,0
911   1611  7D          	ld	a,l
911   1612  D6 07       	sub	7
911   1614  D2 70 16    	jp	nc,i_146
911   1617              ;				{
911   1617              	C_LINE	912,"Graphics\L2graphics.c"
912   1617              	C_LINE	912,"Graphics\L2graphics.c"
912   1617              ;					if ((l2_byteToWrite & 0x80) != 0)
912   1617              	C_LINE	913,"Graphics\L2graphics.c"
913   1617              	C_LINE	913,"Graphics\L2graphics.c"
913   1617  2A 78 17    	ld	hl,(_l2_byteToWrite)
913   161A  26 00       	ld	h,0
913   161C  3E 80       	ld	a,+(128 % 256)
913   161E  A5          	and	l
913   161F  6F          	ld	l,a
913   1620  A7          	and	a
913   1621  CA 41 16    	jp	z,i_148
913   1624              ;					{
913   1624              	C_LINE	914,"Graphics\L2graphics.c"
914   1624              	C_LINE	914,"Graphics\L2graphics.c"
914   1624              ;						l2_plot_pixel(l2_x_work_pca, l2_y_work_pca, colour);
914   1624              	C_LINE	915,"Graphics\L2graphics.c"
915   1624              	C_LINE	915,"Graphics\L2graphics.c"
915   1624              ;l2_x_work_pca;
915   1624              	C_LINE	916,"Graphics\L2graphics.c"
916   1624  2A 8F 17    	ld	hl,(_l2_x_work_pca)
916   1627  26 00       	ld	h,0
916   1629  E5          	push	hl
916   162A              ;l2_y_work_pca;
916   162A              	C_LINE	916,"Graphics\L2graphics.c"
916   162A  2A 8E 17    	ld	hl,(_l2_y_work_pca)
916   162D  26 00       	ld	h,0
916   162F  E5          	push	hl
916   1630              ;colour;
916   1630              	C_LINE	916,"Graphics\L2graphics.c"
916   1630  21 06 00    	ld	hl,6	;const
916   1633  39          	add	hl,sp
916   1634  6E          	ld	l,(hl)
916   1635  26 00       	ld	h,0
916   1637  E5          	push	hl
916   1638  CD 32 01    	call	_l2_plot_pixel
916   163B  C1          	pop	bc
916   163C  C1          	pop	bc
916   163D  C1          	pop	bc
916   163E              ;					}
916   163E              	C_LINE	916,"Graphics\L2graphics.c"
916   163E              ;					else
916   163E              	C_LINE	917,"Graphics\L2graphics.c"
917   163E  C3 57 16    	jp	i_149
917   1641              .i_148
917   1641              ;					{
917   1641              	C_LINE	918,"Graphics\L2graphics.c"
918   1641              	C_LINE	918,"Graphics\L2graphics.c"
918   1641              ;						l2_plot_pixel(l2_x_work_pca, l2_y_work_pca, 0xE3);
918   1641              	C_LINE	919,"Graphics\L2graphics.c"
919   1641              	C_LINE	919,"Graphics\L2graphics.c"
919   1641              ;l2_x_work_pca;
919   1641              	C_LINE	920,"Graphics\L2graphics.c"
920   1641  2A 8F 17    	ld	hl,(_l2_x_work_pca)
920   1644  26 00       	ld	h,0
920   1646  E5          	push	hl
920   1647              ;l2_y_work_pca;
920   1647              	C_LINE	920,"Graphics\L2graphics.c"
920   1647  2A 8E 17    	ld	hl,(_l2_y_work_pca)
920   164A  26 00       	ld	h,0
920   164C  E5          	push	hl
920   164D              ;0xE3;
920   164D              	C_LINE	920,"Graphics\L2graphics.c"
920   164D  21 E3 00    	ld	hl,227	;const
920   1650  E5          	push	hl
920   1651  CD 32 01    	call	_l2_plot_pixel
920   1654  C1          	pop	bc
920   1655  C1          	pop	bc
920   1656  C1          	pop	bc
920   1657              ;					}
920   1657              	C_LINE	920,"Graphics\L2graphics.c"
920   1657              .i_149
920   1657              ;                    ++l2_x_work_pca;
920   1657              	C_LINE	921,"Graphics\L2graphics.c"
921   1657              	C_LINE	921,"Graphics\L2graphics.c"
921   1657  2A 8F 17    	ld	hl,(_l2_x_work_pca)
921   165A  26 00       	ld	h,0
921   165C  23          	inc	hl
921   165D  7D          	ld	a,l
921   165E  32 8F 17    	ld	(_l2_x_work_pca),a
921   1661              ;					l2_byteToWrite = l2_byteToWrite << 1;
921   1661              	C_LINE	922,"Graphics\L2graphics.c"
922   1661              	C_LINE	922,"Graphics\L2graphics.c"
922   1661  2A 78 17    	ld	hl,(_l2_byteToWrite)
922   1664  26 00       	ld	h,0
922   1666  29          	add	hl,hl
922   1667  26 00       	ld	h,0
922   1669  7D          	ld	a,l
922   166A  32 78 17    	ld	(_l2_byteToWrite),a
922   166D              ;				}
922   166D              	C_LINE	923,"Graphics\L2graphics.c"
923   166D  C3 02 16    	jp	i_145
923   1670              .i_146
923   1670              ;			}
923   1670              	C_LINE	924,"Graphics\L2graphics.c"
924   1670              ;			++l2_y_work_pca;
924   1670              	C_LINE	925,"Graphics\L2graphics.c"
925   1670              .i_144
925   1670              	C_LINE	925,"Graphics\L2graphics.c"
925   1670  2A 8E 17    	ld	hl,(_l2_y_work_pca)
925   1673  26 00       	ld	h,0
925   1675  23          	inc	hl
925   1676  7D          	ld	a,l
925   1677  32 8E 17    	ld	(_l2_y_work_pca),a
925   167A              ;        }
925   167A              	C_LINE	926,"Graphics\L2graphics.c"
926   167A  C3 B3 15    	jp	i_141
926   167D              .i_142
926   167D              ;    }
926   167D              	C_LINE	927,"Graphics\L2graphics.c"
927   167D              ;}
927   167D              	C_LINE	928,"Graphics\L2graphics.c"
928   167D              .i_138
928   167D  C9          	ret
928   167E              
928   167E              
928   167E              ;void l2_print_at(uint8_t x, uint8_t y, char *message, uint8_t colour)
928   167E              	C_LINE	930,"Graphics\L2graphics.c"
930   167E              ;{
930   167E              	C_LINE	931,"Graphics\L2graphics.c"
931   167E              
931   167E              ; Function l2_print_at flags 0x00000200 __smallc
931   167E              ; void l2_print_at(unsigned char x, unsigned char y, char *message, unsigned char colour)
931   167E              ; parameter 'unsigned char colour' at 2 size(1)
931   167E              ; parameter 'char *message' at 4 size(2)
931   167E              ; parameter 'unsigned char y' at 6 size(1)
931   167E              ; parameter 'unsigned char x' at 8 size(1)
931   167E              ._l2_print_at
931   167E              	C_LINE	931,"Graphics\L2graphics.c"
931   167E              ;	l2_x_work_pct = 0;
931   167E              	C_LINE	932,"Graphics\L2graphics.c"
932   167E              	C_LINE	932,"Graphics\L2graphics.c"
932   167E  21 00 00    	ld	hl,0 % 256	;const
932   1681  7D          	ld	a,l
932   1682  32 91 17    	ld	(_l2_x_work_pct),a
932   1685              ;
932   1685              	C_LINE	933,"Graphics\L2graphics.c"
933   1685              ;	while (message[l2_x_work_pct] != 0 && l2_x_work_pct < 32)
933   1685              	C_LINE	934,"Graphics\L2graphics.c"
934   1685              	C_LINE	934,"Graphics\L2graphics.c"
934   1685              .i_150
934   1685  21 04 00    	ld	hl,4	;const
934   1688  39          	add	hl,sp
934   1689  5E          	ld	e,(hl)
934   168A  23          	inc	hl
934   168B  56          	ld	d,(hl)
934   168C  D5          	push	de
934   168D  2A 91 17    	ld	hl,(_l2_x_work_pct)
934   1690  26 00       	ld	h,0
934   1692  D1          	pop	de
934   1693  19          	add	hl,de
934   1694  7E          	ld	a,(hl)
934   1695  A7          	and	a
934   1696  CA A0 16    	jp	z,i_152
934   1699  3A 91 17    	ld	a,(_l2_x_work_pct)
934   169C  D6 20       	sub	32
934   169E  38 03       	jr	c,i_153_i_152
934   16A0              .i_152
934   16A0  C3 CF 16    	jp	i_151
934   16A3              .i_153_i_152
934   16A3              ;	{
934   16A3              	C_LINE	935,"Graphics\L2graphics.c"
935   16A3              	C_LINE	935,"Graphics\L2graphics.c"
935   16A3              ;		messagebuffer[l2_x_work_pct] = message[l2_x_work_pct];
935   16A3              	C_LINE	936,"Graphics\L2graphics.c"
936   16A3              	C_LINE	936,"Graphics\L2graphics.c"
936   16A3  11 48 19    	ld	de,_messagebuffer
936   16A6  2A 91 17    	ld	hl,(_l2_x_work_pct)
936   16A9  26 00       	ld	h,0
936   16AB  19          	add	hl,de
936   16AC  E5          	push	hl
936   16AD  21 06 00    	ld	hl,6	;const
936   16B0  39          	add	hl,sp
936   16B1  5E          	ld	e,(hl)
936   16B2  23          	inc	hl
936   16B3  56          	ld	d,(hl)
936   16B4  D5          	push	de
936   16B5  2A 91 17    	ld	hl,(_l2_x_work_pct)
936   16B8  26 00       	ld	h,0
936   16BA  D1          	pop	de
936   16BB  19          	add	hl,de
936   16BC  CD 00 00    	call	l_gchar
936   16BF  D1          	pop	de
936   16C0  7D          	ld	a,l
936   16C1  12          	ld	(de),a
936   16C2              ;
936   16C2              	C_LINE	937,"Graphics\L2graphics.c"
937   16C2              ;		++l2_x_work_pct;
937   16C2              	C_LINE	938,"Graphics\L2graphics.c"
938   16C2              	C_LINE	938,"Graphics\L2graphics.c"
938   16C2  2A 91 17    	ld	hl,(_l2_x_work_pct)
938   16C5  26 00       	ld	h,0
938   16C7  23          	inc	hl
938   16C8  7D          	ld	a,l
938   16C9  32 91 17    	ld	(_l2_x_work_pct),a
938   16CC              ;	}
938   16CC              	C_LINE	939,"Graphics\L2graphics.c"
939   16CC  C3 85 16    	jp	i_150
939   16CF              .i_151
939   16CF              ;	messagebuffer[l2_x_work_pct] = 0;
939   16CF              	C_LINE	940,"Graphics\L2graphics.c"
940   16CF              	C_LINE	940,"Graphics\L2graphics.c"
940   16CF  11 48 19    	ld	de,_messagebuffer
940   16D2  2A 91 17    	ld	hl,(_l2_x_work_pct)
940   16D5  26 00       	ld	h,0
940   16D7  19          	add	hl,de
940   16D8  36 00       	ld	(hl),+(0 % 256)
940   16DA  6E          	ld	l,(hl)
940   16DB  26 00       	ld	h,0
940   16DD              ;
940   16DD              	C_LINE	941,"Graphics\L2graphics.c"
941   16DD              ;	l2_x_work_pct = x;
941   16DD              	C_LINE	942,"Graphics\L2graphics.c"
942   16DD              	C_LINE	942,"Graphics\L2graphics.c"
942   16DD  21 08 00    	ld	hl,8	;const
942   16E0  39          	add	hl,sp
942   16E1  6E          	ld	l,(hl)
942   16E2  26 00       	ld	h,0
942   16E4  7D          	ld	a,l
942   16E5  32 91 17    	ld	(_l2_x_work_pct),a
942   16E8              ;	l2_y_work_pct = y;
942   16E8              	C_LINE	943,"Graphics\L2graphics.c"
943   16E8              	C_LINE	943,"Graphics\L2graphics.c"
943   16E8  21 06 00    	ld	hl,6	;const
943   16EB  39          	add	hl,sp
943   16EC  6E          	ld	l,(hl)
943   16ED  26 00       	ld	h,0
943   16EF  7D          	ld	a,l
943   16F0  32 90 17    	ld	(_l2_y_work_pct),a
943   16F3              ;
943   16F3              	C_LINE	944,"Graphics\L2graphics.c"
944   16F3              ;	l2_loopvar_chrat  = 0;
944   16F3              	C_LINE	945,"Graphics\L2graphics.c"
945   16F3              	C_LINE	945,"Graphics\L2graphics.c"
945   16F3  21 00 00    	ld	hl,0 % 256	;const
945   16F6  7D          	ld	a,l
945   16F7  32 83 17    	ld	(_l2_loopvar_chrat),a
945   16FA              ;	while (l2_loopvar_chrat < 32 && messagebuffer[l2_loopvar_chrat] != 0)
945   16FA              	C_LINE	946,"Graphics\L2graphics.c"
946   16FA              	C_LINE	946,"Graphics\L2graphics.c"
946   16FA              .i_154
946   16FA  3A 83 17    	ld	a,(_l2_loopvar_chrat)
946   16FD  D6 20       	sub	32
946   16FF  D2 0F 17    	jp	nc,i_156
946   1702  11 48 19    	ld	de,_messagebuffer
946   1705  2A 83 17    	ld	hl,(_l2_loopvar_chrat)
946   1708  26 00       	ld	h,0
946   170A  19          	add	hl,de
946   170B  7E          	ld	a,(hl)
946   170C  A7          	and	a
946   170D  20 03       	jr	nz,i_157_i_156
946   170F              .i_156
946   170F  C3 77 17    	jp	i_155
946   1712              .i_157_i_156
946   1712              ;	{
946   1712              	C_LINE	947,"Graphics\L2graphics.c"
947   1712              	C_LINE	947,"Graphics\L2graphics.c"
947   1712              ;
947   1712              	C_LINE	948,"Graphics\L2graphics.c"
948   1712              ;		l2_print_chr_at (l2_x_work_pct, l2_y_work_pct,  messagebuffer[l2_loopvar_chrat], colour);
948   1712              	C_LINE	949,"Graphics\L2graphics.c"
949   1712              	C_LINE	949,"Graphics\L2graphics.c"
949   1712              ;l2_x_work_pct;
949   1712              	C_LINE	950,"Graphics\L2graphics.c"
950   1712  2A 91 17    	ld	hl,(_l2_x_work_pct)
950   1715  26 00       	ld	h,0
950   1717  E5          	push	hl
950   1718              ;l2_y_work_pct;
950   1718              	C_LINE	950,"Graphics\L2graphics.c"
950   1718  2A 90 17    	ld	hl,(_l2_y_work_pct)
950   171B  26 00       	ld	h,0
950   171D  E5          	push	hl
950   171E              ;messagebuffer[l2_loopvar_chrat];
950   171E              	C_LINE	950,"Graphics\L2graphics.c"
950   171E  11 48 19    	ld	de,_messagebuffer
950   1721  2A 83 17    	ld	hl,(_l2_loopvar_chrat)
950   1724  26 00       	ld	h,0
950   1726  19          	add	hl,de
950   1727  CD 00 00    	call	l_gchar
950   172A  E5          	push	hl
950   172B              ;colour;
950   172B              	C_LINE	950,"Graphics\L2graphics.c"
950   172B  21 08 00    	ld	hl,8	;const
950   172E  39          	add	hl,sp
950   172F  6E          	ld	l,(hl)
950   1730  26 00       	ld	h,0
950   1732  E5          	push	hl
950   1733  CD 51 15    	call	_l2_print_chr_at
950   1736  C1          	pop	bc
950   1737  C1          	pop	bc
950   1738  C1          	pop	bc
950   1739  C1          	pop	bc
950   173A              ;		l2_x_work_pct += 8;
950   173A              	C_LINE	950,"Graphics\L2graphics.c"
950   173A              	C_LINE	950,"Graphics\L2graphics.c"
950   173A  2A 91 17    	ld	hl,(_l2_x_work_pct)
950   173D  26 00       	ld	h,0
950   173F  ED 34 08 00 	add	hl,8
950   1743  26 00       	ld	h,0
950   1745  7D          	ld	a,l
950   1746  32 91 17    	ld	(_l2_x_work_pct),a
950   1749              ;		if (l2_x_work_pct > 250)
950   1749              	C_LINE	951,"Graphics\L2graphics.c"
951   1749              	C_LINE	951,"Graphics\L2graphics.c"
951   1749  2A 91 17    	ld	hl,(_l2_x_work_pct)
951   174C  26 00       	ld	h,0
951   174E  3E FA       	ld	a,250
951   1750  95          	sub	l
951   1751  D2 6A 17    	jp	nc,i_158
951   1754              ;		{
951   1754              	C_LINE	952,"Graphics\L2graphics.c"
952   1754              	C_LINE	952,"Graphics\L2graphics.c"
952   1754              ;			l2_y_work_pct += 8;
952   1754              	C_LINE	953,"Graphics\L2graphics.c"
953   1754              	C_LINE	953,"Graphics\L2graphics.c"
953   1754  2A 90 17    	ld	hl,(_l2_y_work_pct)
953   1757  26 00       	ld	h,0
953   1759  ED 34 08 00 	add	hl,8
953   175D  26 00       	ld	h,0
953   175F  7D          	ld	a,l
953   1760  32 90 17    	ld	(_l2_y_work_pct),a
953   1763              ;			l2_x_work_pct  = 0;
953   1763              	C_LINE	954,"Graphics\L2graphics.c"
954   1763              	C_LINE	954,"Graphics\L2graphics.c"
954   1763  21 00 00    	ld	hl,0 % 256	;const
954   1766  7D          	ld	a,l
954   1767  32 91 17    	ld	(_l2_x_work_pct),a
954   176A              ;		}
954   176A              	C_LINE	955,"Graphics\L2graphics.c"
955   176A              ;		++l2_loopvar_chrat;
955   176A              	C_LINE	956,"Graphics\L2graphics.c"
956   176A              .i_158
956   176A              	C_LINE	956,"Graphics\L2graphics.c"
956   176A  2A 83 17    	ld	hl,(_l2_loopvar_chrat)
956   176D  26 00       	ld	h,0
956   176F  23          	inc	hl
956   1770  7D          	ld	a,l
956   1771  32 83 17    	ld	(_l2_loopvar_chrat),a
956   1774              ;	}
956   1774              	C_LINE	957,"Graphics\L2graphics.c"
957   1774  C3 FA 16    	jp	i_154
957   1777              .i_155
957   1777              ;}
957   1777              	C_LINE	958,"Graphics\L2graphics.c"
958   1777  C9          	ret
958   1778              
958   1778              
958   1778              
958   1778              ; --- Start of Static Variables ---
958   1778              
958   1778  00          ._l2_byteToWrite	defs	1
958   1779  00          ._l2_y_parameter	defs	1
958   177A  00          ._l2_x_parameter	defs	1
958   177B  00          ._l2_col_parameter	defs	1
958   177C  00          ._l2_loopvar	defs	1
958   177D  00          ._l2_loopvar_dvs	defs	1
958   177E  00          ._l2_loopvar_hzl	defs	1
958   177F  00          ._l2_loopvar_tft	defs	1
958   1780  00          ._l2_loopvar_bft	defs	1
958   1781  00          ._l2_loopvar_charj	defs	1
958   1782  00          ._l2_loopvar_chark	defs	1
958   1783  00          ._l2_loopvar_chrat	defs	1
958   1784  00          ._l2_y_in	defs	1
958   1785  00          ._l2_x_in	defs	1
958   1786  00          ._l2_col_in	defs	1
958   1787  00          ._l2_y_out	defs	1
958   1788  00 00       ._l2_addr_work	defs	2
958   178A  00          ._l2_y_work	defs	1
958   178B  00          ._l2_x_work	defs	1
958   178C  00          ._l2_y_work_lvl2	defs	1
958   178D  00          ._l2_x_work_lvl2	defs	1
958   178E  00          ._l2_y_work_pca	defs	1
958   178F  00          ._l2_x_work_pca	defs	1
958   1790  00          ._l2_y_work_pct	defs	1
958   1791  00          ._l2_x_work_pct	defs	1
958   1792  00          ._l2_y_work_hzl	defs	1
958   1793  00          ._l2_local_save	defs	1
958   1794  00          ._l2_i	defs	1
958   1795  00          ._l2_length	defs	1
958   1796  00          ._l2_work	defs	1
958   1797  00 00       ._l2_address	defs	2
958   1799  00 00       ._l2_charAddr	defs	2
958   179B  00          ._l2_length_work	defs	1
958   179C  00          ._l2_layer_shift	defs	1
958   179D  00 00       ._l2_stepx	defs	2
958   179F  00 00       ._l2_stepy	defs	2
958   17A1  00 00       ._l2_fraction	defs	2
958   17A3  00 00       ._l2_dy	defs	2
958   17A5  00 00       ._l2_dx	defs	2
958   17A7  00 00       ._l2_vx0	defs	2
958   17A9  00 00       ._l2_vy0	defs	2
958   17AB  00 00       ._l2_vx1	defs	2
958   17AD  00 00       ._l2_vy1	defs	2
958   17AF  00 00       ._l2_circle_x	defs	2
958   17B1  00 00       ._l2_circle_y	defs	2
958   17B3  00 00       ._l2_circle_d	defs	2
958   17B5  00          ._l2_circle_doublex	defs	1
958   17B6  00          ._l2_circle_doubley	defs	1
958   17B7  00          ._l2_dtri_tempx1	defs	1
958   17B8  00          ._l2_dtri_tempx2	defs	1
958   17B9  00          ._l2_dtri_tempy1	defs	1
958   17BA  00 00       ._l2_dtri_newx	defs	2
958   17BC  00 00       ._l2_dtri_newx1	defs	2
958   17BE  00 00       ._l2_dtri_newx2	defs	2
958   17C0  00          ._l2_dtri_workx0	defs	1
958   17C1  00          ._l2_dtri_worky0	defs	1
958   17C2  00          ._l2_dtri_workx1	defs	1
958   17C3  00          ._l2_dtri_worky1	defs	1
958   17C4  00          ._l2_dtri_workx2	defs	1
958   17C5  00          ._l2_dtri_worky2	defs	1
958   17C6  00          ._l2_dtri_workx3	defs	1
958   17C7  00          ._l2_dtri_worky3	defs	1
958   17C8  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
      17E8  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
      1808  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
      1828  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
      1848  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
      1868  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
                        ._l2_LineMaxX	defs	192
958   1888  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
      18A8  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
      18C8  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
      18E8  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
      1908  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
      1928  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
                        ._l2_LineMinX	defs	192
958   1948  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
      1968  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
      1988  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
                        ._messagebuffer	defs	80
958   1998  00 00       ._l2_clipx0	defs	2
958   199A  00 00       ._l2_clipy0	defs	2
958   199C  00 00       ._l2_clipx1	defs	2
958   199E  00 00       ._l2_clipy1	defs	2
958   19A0              
958   19A0              