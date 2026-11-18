rem build            -> assemble EliteN.nex, then run the regression tests (Tools\run_tests.py)
rem build notest     -> without the tests
rem build hardware   -> also EliteNHW.nex for a real Next: -DREAL_HARDWARE, DMA+ fill mode for the screen
rem                          clear and memfill_dma, needs core 3.03.00 (CSpect has no DMA+, so run EliteN.nex there)
rem Tools\sprite_writer.py writes the sprite pattern files NESpr01-40.dat from Layer3Sprites\SpriteSheet.SPR
rem snasm
rem Snasm  -map -next eliteNext.asm 

set TESTS=1
set HARDWARE=0
for %%a in (%*) do (
    if /i "%%a"=="notest" set TESTS=0
    if /i "%%a"=="hardware" set HARDWARE=1
)

del     eliteN.map
del     eliteN.txt
del     eliteN.nex

del     /Q .\Build\*.*
rmdir   /Q .\Build

python Tools\sprite_writer.py || exit /b 1
sjasmplus --msg=all --color=auto --lst=eliteN.txt --sym=eliteN.sym eliteNext.asm || exit /b 1
if "%TESTS%"=="1" python Tools\run_tests.py || exit /b 1
if "%HARDWARE%"=="1" sjasmplus --msg=war -DREAL_HARDWARE --lst=EliteNHW.txt --sym=EliteNHW.sym eliteNext.asm || exit /b 1

mkdir   .\Build
xcopy    eliteN.nex  .\Build\
if "%HARDWARE%"=="1" xcopy /Y EliteNHW.nex  .\Build\
xcopy    /Q/Y NeSpr*.dat  .\Build\
