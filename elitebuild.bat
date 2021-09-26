rem snasm
rem Snasm  -map -next eliteNext.asm 
del     eliteNext.txt
del     eliteN.nex 
sjasmplus --zxnext=cspect --lst=eliteNext.txt --reversepop --inc=Macros --inc=Maths --inc=Maths/Utilities --inc=Universe --inc=Images --inc=Data --inc=Menus --inc=Commander --inc=Hardware --inc=Layer1Graphics --inc=Layer2Graphics --inc=Layer3Sprites eliteNext.asm  

