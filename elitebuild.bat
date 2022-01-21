rem snasm
rem Snasm  -map -next eliteNext.asm 

del     eliteN.map
del     eliteN.txt
del     eliteN.nex

sjasmplus --msg=all --color=auto --lst=eliteN.txt eliteNext.asm
