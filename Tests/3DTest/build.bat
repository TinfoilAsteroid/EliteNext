rem snasm
rem Snasm  -map -next eliteNext.asm 

del     3DTest.map
del     3DTest.txt
del     3DTest.nex

sjasmplus --msg=all --color=auto --lst=3DTest.txt 3DTest.asm

