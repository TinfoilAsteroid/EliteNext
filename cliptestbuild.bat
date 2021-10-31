rem snasm
rem Snasm  -map -next eliteNext.asm 


del     clipTst.map
del     clipTst.txt
del     clipTst.nex

sjasmplus --zxnext=cspect --lst=clipTst.txt --reversepop clipTst.asm  
