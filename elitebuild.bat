rem snasm
rem Snasm  -map -next eliteNext.asm 

del     eliteN.map
del     eliteN.txt
del     eliteN.nex

del     /Q .\Build\*.*
rmdir   /Q/F .\Build

sjasmplus --msg=all --color=auto --lst=eliteN.txt eliteNext.asm

mkdir   .\Build
xcopy    eliteN.nex  .\Build\
xcopy    /Q/Y NeSpr*.dat  .\Build\
