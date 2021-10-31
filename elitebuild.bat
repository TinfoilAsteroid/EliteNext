rem snasm
rem Snasm  -map -next eliteNext.asm 

del     eliteN.map
del     eliteN.txt
del     eliteN.nex

sjasmplus --zxnext=cspect --lst=eliteN.txt --reversepop eliteNext.asm  
