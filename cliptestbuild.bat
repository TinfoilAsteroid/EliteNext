rem snasm
rem Snasm  -map -next eliteNext.asm 


del     clipTst.map
del     clipTst.txt
del     clipTst.nex

sjasmplus --lst=clipTst.txt clipTst.asm
