rem snasm
rem Snasm  -map -next eliteNext.asm 
del     eliteNext.map
del     eliteNext.txt
del     eliteN.nex 

sjasmplus --zxnext=cspect --lst=eliteNext.txt --reversepop eliteNext.asm  
