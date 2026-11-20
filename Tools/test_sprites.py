"""The sprite pattern files (Tools/sprite_writer.py, which replaced
SpriteWriter.asm): written from Layer3Sprites/SpriteSheet.SPR, they are the
ones in the project folder and Build, and the boot (load_pattern_files)
uploads them into the sprite pattern memory exactly."""
import math
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


def test_local_chart_stars():
    """The short range chart's stars are sprites from local_chart_first_star (after every fixed sprite) up to 127:
    they once started from 0, so the hyperspace cursor (12-14) took stars, and spr_nextStar was never reset so each
    visit started further up until it ran past 127. Drawn twice from a stale spr_nextStar, the same stars come out"""
    with et.SD() as sd:
        cpu = et.machine(sd, boot="StartAttractMode")
        first = sym["local_chart_first_star"]
        sprites = cpu.page(sym["BankSPRITE"])           # spr_nextStar is in the sprite bank (slot 7)
        nxt = sym["spr_nextStar"] - 0xE000
        seen = []
        for visit in range(2):
            if visit == 0:
                sprites[nxt] = 100                      # stale, from an earlier visit
            et.call(cpu, "SRM_galactic_chart", mmu={6: sym["BankMenuShrCht"]})
            end = sprites[nxt]
            check(first < end <= 128, f"visit {visit}: stars {first} to {end - 1}")
            stars = [n for n in range(first, end) if cpu.spr_attr[n][3] & 0x80]
            check(len(stars) == end - first, f"visit {visit}: {end - first - len(stars)} of the star sprites not visible")
            check(all(not cpu.spr_attr[n][3] & 0x80 for n in range(end, 128)), f"visit {visit}: a sprite after the stars is visible")
            check(cpu.spr_attr[sym["local_hyper_sprite"]][3] & 0x80, f"visit {visit}: the hyperspace cursor isn't visible")
            seen.append([tuple(cpu.spr_attr[n]) for n in range(first, end)])
        check(seen[0] == seen[1], "the second visit drew different stars")
        et.note(f"{len(seen[0])} stars, sprites {first} to {first + len(seen[0]) - 1}")


def test_compass_dots():
    """The sun, planet and station compass dots (UpdateCompassSun / Planet / Station) on one scale: 0 dead ahead,
    +/-12 at 90 degrees off, within the ring (-13 to +12 from its centre) and within 2.5 of 12 * axis / length; the
    sun's once went to 15 (onto the ring's edge), the planet's and station's only to 9"""
    with et.SD() as sd:
        cpu = et.machine(sd, boot="StartAttractMode")
        maths = {0: sym["BankMathsBankedFns"], 6: sym["BankSunData"]}

        def put(page, base, pos):
            p = cpu.page(page)
            for i, c in enumerate(pos):
                v = abs(c) | (0x800000 if c < 0 else 0)
                for k in range(3):
                    p[base - 0xC000 + 3 * i + k] = v >> (8 * k) & 255

        def offsets(pos):
            put(sym["BankSunData"], sym["SBnKxlo"], pos)
            et.call(cpu, "Normalise24IX", mmu=maths, ix=sym["SBnKxlo"])
            et.call(cpu, "UpdateCompassIX", mmu=maths, ix=sym["SBnKxlo"])
            et.call(cpu, "UpdateCompassSun")
            put(sym["BankPlanetData"], sym["P_BnKxlo"], pos)
            et.call(cpu, "UpdateCompassPlanet")
            put(sym["BankSpaceStationData"], sym["UBnKxlo"], pos)
            et.call(cpu, "UpdateCompassStation")
            out = []
            for name, body in (("compass_sun", "Sun"), ("compass_planet", "Planet"), ("compass_station", "Station")):
                a = cpu.spr_attr[sym[name]]
                out.append((a[0] - sym[body + "ScanCenterX"] + 2, sym[body + "ScanCenterY"] - 2 - a[1]))
            return out
        r = et.rnd(38)
        for pos, exp in (((0, 0, 0x40000), (0, 0)), ((0x40000, 0, 1), (12, 0)), ((-0x40000, 0, 1), (-12, 0)),
                         ((0, 0x40000, 1), (0, 12)), ((0, -0x40000, 1), (0, -12))):
            got = offsets(pos)
            check(all(abs(g[0] - exp[0]) <= 1 and abs(g[1] - exp[1]) <= 1 for g in got), f"{pos}: sun, planet, station {got}, expected {exp}")
        for n in range(150):
            big = 1 << r.choice((12, 15, 19, 22))
            pos = [r.randrange(-big, big) for _ in range(3)]
            length = math.sqrt(sum(c * c for c in pos)) or 1
            exp = (12 * pos[0] / length, 12 * pos[1] / length)
            got = offsets(pos)
            check(all(-13 <= x <= 12 and -12 <= y <= 13 for x, y in got), f"{pos}: {got} outside the ring")
            # (the planet's and station's are from 7 bit scaled hi bytes, AequAdivQmul96ABS once lost a carry: 5.8 out)
            check(all(abs(g[0] - exp[0]) < 2.5 and abs(g[1] - exp[1]) < 2.5 for g in got),
                  f"{pos}: sun, planet, station {got}, expected ({exp[0]:.1f}, {exp[1]:.1f})")


def test_safe_zone_indicator():
    """The space station safe zone indicator (sprite safe_zone_sprite, pattern space_station_safe_zone_pattern, at the
    ECM's mirror image bottom right): shown straight after launch (the planet was put 255 units ahead, outside the
    192 unit zone, so a launch began outside it next to the station), hidden on flying out of the zone, shown again on
    flying back in"""
    import test_game_flow as gf
    sd, cpu = gf.game()
    n = sym["safe_zone_sprite"]
    pp = cpu.page(sym["BankPlanetData"])

    def planet_z(sign, hi):
        a = sym["P_BnKzlo"] - 0xC000
        pp[a], pp[a + 1], pp[a + 2] = 0, hi, sign

    def shown():
        a = cpu.spr_attr[n]
        return bool(a[3] & 0x80), a[3] & 0x3F, a[0] | (a[2] & 1) << 8, a[1]

    gf.press(cpu, "c_Pressed_No", 5)
    gf.loops(cpu, 20)
    gf.press(cpu, "c_Pressed_Launch")
    gf.loops(cpu, 40)
    check(et.rd(cpu, "DockedFlag") == sym["StateNormal"], "not in flight")
    check(et.rd(cpu, "SpaceStationSafeZone") == 0, f"not in the safe zone after launch ({et.rd(cpu, 'SpaceStationSafeZone'):02X})")
    vis, pat, x, y = shown()
    check(vis and pat == sym["space_station_safe_zone_pattern"], f"after launch: visible {vis}, pattern {pat}")
    check((x, y) == (sym["sprite_safe_zone_x"], sym["sprite_safe_zone_y"]), f"at {x}, {y}")
    check(x + 16 <= 256 + 64 and x - 32 >= 128 + 32, f"x {x}: not on the right of the scanner")
    for sign, hi, inside in ((5, 0, False), (0, 0x80, True), (0, 0xC0, False), (0, 0x40, True)):
        planet_z(sign, hi)
        gf.loops(cpu, 12)
        zone = et.rd(cpu, "SpaceStationSafeZone")
        check((zone == 0) == inside, f"planet z {sign:02X}{hi:02X}00: SpaceStationSafeZone {zone:02X}")
        check(shown()[0] == inside, f"planet z {sign:02X}{hi:02X}00: indicator {'hidden' if inside else 'shown'}")
    sd.close()


if __name__ == "__main__":
    et.main(globals())
