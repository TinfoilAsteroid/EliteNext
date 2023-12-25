rem snasm
rem Snasm  -map -next eliteNext.asm 

del     VecTest.map
del     VecTest.txt
del     VecTest.nex

sjasmplus --msg=all --color=auto --lst=VecTest.txt VecTest.asm

