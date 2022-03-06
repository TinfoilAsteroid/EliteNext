rem snasm
rem Snasm  -map -next eliteNext.asm 

del     keyTst.map
del     keyTst.txt
del     keyTst.nex

sjasmplus --msg=all --color=auto --lst=keyTst.txt keyTst.asm
