"""The sprite pattern files (Tools/sprite_writer.py, which replaced
SpriteWriter.asm): written from Layer3Sprites/SpriteSheet.SPR, they are the
ones in the project folder and Build, and the boot (load_pattern_files)
uploads them into the sprite pattern memory exactly."""
import os

import elitetest as et
import sprite_writer
from elitetest import check, sym


def test_files_match_the_sheet():
    """The NESprNN.dat files beside EliteN.nex (and in Build, when there) are the sheet's
    (run Tools/sprite_writer.py, or build.bat, if not)"""
    pats = sprite_writer.patterns()
    check(len(pats) == sym["SpriteCount"], f"{len(pats)} files, the game loads SpriteCount = {sym['SpriteCount']}")
    for folder in (et.ROOT, os.path.join(et.ROOT, "Build")):
        # (build.bat empties Build first and copies the files in after the tests: check it only if they're there)
        if folder == et.ROOT or (os.path.isdir(folder) and any(n.upper().startswith("NESPR") for n in os.listdir(folder))):
            bad = sprite_writer.check(folder)
            check(not bad, f"{folder}: {', '.join(bad[:8])} differ from the sprite sheet")


def test_boot_uploads_the_patterns():
    """After the start up, sprite pattern memory holds the sheet's first
    SpriteCount patterns, in order"""
    with et.SD() as sd:
        cpu = et.machine(sd, boot="StartAttractMode")
        want = b"".join(data for _, data in sprite_writer.patterns())
        got = bytes(cpu.spr_pat[:len(want)])
        bad = [i // 256 + 1 for i in range(0, len(want), 256) if got[i:i + 256] != want[i:i + 256]]
        check(not bad, f"patterns {bad[:10]} aren't the sheet's after the boot")


if __name__ == "__main__":
    et.main(globals())
