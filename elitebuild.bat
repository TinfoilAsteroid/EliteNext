rem elitebuild            -> assemble both builds, then run the regression tests (Tools\run_tests.py)
rem elitebuild notest     -> without the tests
rem   EliteN.nex     the regular build (CSpect, which has no DMA+)
rem   EliteNHW.nex   the real hardware build: -DREAL_HARDWARE, DMA+ fill mode for the screen clear and memfill_dma,
rem                  needs core 3.03.00
rem   The tests run on EliteN.nex, but a test file with the line  ELITE_BUILD = "hardware"  runs on EliteNHW.nex
rem   (tests of real hardware features, Tools\elitetest.py); test_hardware.py compares the two.
rem   Both go to .\Build with the sprite files. (elitebuild hardware, the old option, is the same as elitebuild.)
rem Tools\sprite_writer.py writes the sprite pattern files NESpr01-40.dat from Layer3Sprites\SpriteSheet.SPR
rem snasm
rem Snasm  -map -next eliteNext.asm

set TESTS=1
for %%a in (%*) do (
    if /i "%%a"=="notest" set TESTS=0
)

del     eliteN.map
del     eliteN.txt
del     eliteN.nex
del     EliteNHW.txt
del     EliteNHW.nex

del     /Q .\Build\*.*
rmdir   /Q .\Build

python Tools\sprite_writer.py || exit /b 1
sjasmplus --msg=all --color=auto --lst=eliteN.txt --sym=eliteN.sym --sld=eliteN.sld --fullpath eliteNext.asm || exit /b 1
sjasmplus --msg=war -DREAL_HARDWARE --lst=EliteNHW.txt --sym=EliteNHW.sym --sld=EliteNHW.sld --fullpath eliteNext.asm || exit /b 1
if "%TESTS%"=="1" python Tools\run_tests.py || exit /b 1

mkdir   .\Build
xcopy    /Y eliteN.nex  .\Build\ || exit /b 1
xcopy    /Y EliteNHW.nex  .\Build\ || exit /b 1
xcopy    /Q/Y NeSpr*.dat  .\Build\ || exit /b 1
