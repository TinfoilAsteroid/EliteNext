INWKxlo:	DB  0				; INW+0
INWKxhi:	DB  0				; there are hi medium low as some times these are 24 bit
INWKxsgn:	DB	0				; INWK+2
INWKyLo		DB	0				; INWK+3 \ ylo
INWKyhi		DB	0				; Y Hi???
INWKysgn:	DB	0				; INWK +5
INWKzlo		DB	0				; INWK +6
INWKzhi		DB	0				; INWK +7
INWKzsgn:	DB	0				; INWK +8
rotmat0xLo: DB	0				; INWK +9
rotmat0xHi: DB	0				; INWK +10
rotmat0yLo: DB	0				; INWK +11
rotmat0yHi: DB	0				; INWK +12	
rotmat0zLo:	DB 	0				; INWK +13
rotmat0zHi:	DB 	0				; INWK +14
rotmat1xLo: DB	0				; INWK +15
rotmat1xHi:	DB	0				; INWK +16
rotmat1yLo:	DB	0				; INWK +17			
rotmat1yHi:	DB	0				; INWK +18
rotmat1zLo:	DB	0				; INWK +19
rotmat1zHi:	DB	0				; INWK +20			
rotmat2xLo: DB	0				; INWK +21
rotmat2xHi:	DB	0				; INWK +22
rotmat2yLo:	DB	0				; INWK +23			
rotmat2yHi:	DB	0				; INWK +24
rotmat2zLo:	DB	0				; INWK +25
rotmat2zHi:	DB	0				; INWK +26
rotmapFx	equ	rotmat0xHi
rotmapFy	equ	rotmat0yHi
rotmapFz	equ	rotmat0zHi
rotmapUx	equ	rotmat1xHi
rotmapUy	equ	rotmat1yHi
rotmapUz	equ	rotmat1zHi
INWKspeed:	DB	0				; INWK +27
INWKAccel	DB	0				; INWK +28			
rotXCounter:DB	0				; INWK +29
rotZCounter:DB	0				; INWK +30
explDsp: 	DB	0				; INWK +31 clear exploding/display state|missiles 
aiatkecm:	DB	0				; INWK +32 ai_attack_univ_ecm i.e. AI type
			DB	0				; INWK +33
			DB	0				; INWK +34
INWKEnergy:	DB	0				; INWK +35
INWKNewb:	DB	0				; INWK +36 INWK+36 \ NEWB bit 7 remove ship?

								; TBA?


