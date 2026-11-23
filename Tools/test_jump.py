"""A hyperspace jump end to end on the emulator: the default commander, a target picked while docked, the launch, H
in flight, the countdown, the hyperspace screen, and the arrival (WeHaveCompletedHJump, GameEngine/MainLoop.asm):

  * the launch leaves us where we were, fuel as it was, the target still picked;
  * the jump goes through DockedFlag StateHJumping, StateHEntering, StateCompletedHJump to StateNormal and the
    hyperspace screen to the front view;
  * then: the present system is the target, the fuel less the distance, the system seeds the target's, the slot
    list empty, the ship reset (stopped, energy and shields full), the fugitive status halved, a new market;
  * the sun and planet from the target's seeds (CreateSun, CreatePlanet, as BBC Elite's SOLAR): the planet ahead
    (z sign (y seed & 3) + 3, x and y sign half that), the sun behind (z sign (x seed & 7) | $81);
  * flying into the planet's safe zone then makes the space station in slot 0.
"""
import math

import elitetest as et
import nexsim
import test_game_flow as gf
from elitetest import check, sym

FREE = 0xFF


def galaxy(cpu):
    """the current galaxy's systems: (x, y, the 6 seed bytes) from galaxy_data (8 bytes each, y at +1, x at +3)"""
    page = cpu.page(et.rd(cpu, "Galaxy"))
    base = sym["galaxy_data"] - 0xE000
    return [(page[base + 8 * i + 3], page[base + 8 * i + 1], bytes(page[base + 8 * i:base + 8 * i + 6]))
            for i in range(256)]


def distance(a, b):
    """galaxy_find_distance: 4 * isqrt(dx^2 + (dy / 2)^2), in 0.1 light years"""
    dx, dy = abs(a[0] - b[0]), abs(a[1] - b[1]) >> 1
    return 4 * math.isqrt(dx * dx + dy * dy)


def present(cpu):
    return et.rd(cpu, "PresentSystemX"), et.rd(cpu, sym["PresentSystemX"] + 1)


def pick_target(cpu):
    """the furthest system (not this one) in reach of the fuel, for a distance well above 0"""
    here, fuel = present(cpu), et.rd(cpu, "Fuel")
    systems = galaxy(cpu)
    reach = [s for s in systems if (s[0], s[1]) != here and 0 < distance(here, s) <= fuel]
    check(reach, f"no system within {fuel} of {here}")
    return max(reach, key=lambda s: distance(here, s))


def sign_bytes(cpu, page, names):
    return [cpu.page(sym[page])[sym[n] - 0xC000] for n in names]


def market(cpu):
    return bytes(cpu.page(sym["BankStockTable"])[i] for i in range(0x200))


def test_jump_end_to_end():
    sd, cpu = gf.game()
    try:
        gf.press(cpu, "c_Pressed_No", 5)                    # the default commander, docked
        gf.loops(cpu, 20)
        home, fuel = present(cpu), et.rd(cpu, "Fuel")
        target = pick_target(cpu)
        dist = distance(home, target)
        # picked on the chart while docked: the chart sets TargetSystemX and works out Distance
        et.wr(cpu, "TargetSystemX", target[0])
        et.wr(cpu, sym["TargetSystemX"] + 1, target[1])
        et.wr(cpu, "Distance", dist, 2)
        gf.press(cpu, "c_Pressed_Launch")
        gf.loops(cpu, 60)
        check(et.rd(cpu, "DockedFlag") == sym["StateNormal"], "not in flight after the launch")
        check(present(cpu) == home, f"the launch moved us from {home} to {present(cpu)}")
        check(et.rd(cpu, "Fuel") == fuel, f"the launch used fuel: {fuel} to {et.rd(cpu, 'Fuel')}")
        check((et.rd(cpu, "TargetSystemX"), et.rd(cpu, sym["TargetSystemX"] + 1)) == target[:2],
              "the launch lost the target")

        fugitive = 0x40
        et.wr(cpu, "FugitiveInnocentStatus", fugitive)
        et.wr(cpu, "DELTA", 20)                             # flying: the arrival stops us
        for a in ("ForeShield", "AftShield", "PlayerEnergy"):
            et.wr(cpu, a, 0x80)
        before_market = market(cpu)
        gf.press(cpu, "c_Pressed_Hyperspace", 1)
        check(et.rd(cpu, "InnerHyperCount") != 0, f"H didn't start the countdown (target {target[:2]}, fuel {fuel}, "
              f"distance {dist})")
        et.wr(cpu, "OuterHyperCount", 2)                    # (the countdown itself: test_hyperspace.py)
        states, screens = [], []
        for n in range(600):
            gf.loops(cpu, 1)
            st, sc = et.rd(cpu, "DockedFlag"), et.rd(cpu, "ScreenIndex")
            if st == sym["StateNormal"] and sym["StateHJumping"] not in states:
                for a in ("ForeShield", "AftShield", "PlayerEnergy"):
                    et.wr(cpu, a, 0x80)                     # (a ship about mustn't end the test before the jump)
            if not states or states[-1] != st:
                states.append(st)
            if not screens or screens[-1] != sc:
                screens.append(sc)
            if st == sym["StateNormal"] and sym["StateHJumping"] in states:
                break
        want = [sym[s] for s in ("StateNormal", "StateHJumping", "StateHEntering", "StateCompletedHJump", "StateNormal")]
        check(states == want, f"DockedFlag went {[hex(s) for s in states]}, expected {[hex(s) for s in want]}")
        gf.loops(cpu, 2)                                    # the front view drawn
        if screens[-1] != et.rd(cpu, "ScreenIndex"):
            screens.append(et.rd(cpu, "ScreenIndex"))
        check(screens[-1] == sym["ScreenFront"] and sym["ScreenHyperspace"] in screens,
              f"screens {screens}: expected the hyperspace screen, then the front view ({sym['ScreenFront']})")
        check(et.rd(cpu, "ScreenIndex") == sym["ScreenFront"], f"screen {et.rd(cpu, 'ScreenIndex')} after the jump")

        check(present(cpu) == target[:2], f"present system {present(cpu)}, the target was {target[:2]}")
        check(et.rd(cpu, "Fuel") == fuel - dist, f"fuel {et.rd(cpu, 'Fuel')}, expected {fuel} - {dist}")
        seeds = bytes(et.rd(cpu, sym["SystemSeed"] + i) for i in range(6))
        check(seeds == target[2], f"system seeds {seeds.hex()}, the target's {target[2].hex()}")
        slots = [et.rd(cpu, sym["UniverseSlotList"] + s) for s in range(sym["UniverseSlotListSize"])]
        check(all(s == FREE for s in slots), f"slots after the jump {slots}")
        check(et.rd(cpu, "DELTA") == 0, f"speed {et.rd(cpu, 'DELTA')} after the jump")
        for a in ("ForeShield", "AftShield", "PlayerEnergy"):
            check(et.rd(cpu, a) == 0xFF, f"{a} {et.rd(cpu, a):02X} after the jump")
        check(et.rd(cpu, "FugitiveInnocentStatus") == fugitive >> 1, "fugitive status not halved")
        check(market(cpu) != before_market, "the market wasn't regenerated")

        y, x = target[2][1], target[2][3]
        zs = (y & 3) + 3
        planet = sign_bytes(cpu, "BankPlanetData", ("P_BnKxsgn", "P_BnKysgn", "P_BnKzsgn"))
        check(planet == [zs >> 1, zs >> 1, zs], f"planet sign bytes {planet}, expected {[zs >> 1, zs >> 1, zs]}")
        sun = sign_bytes(cpu, "BankSunData", ("SBnKxsgn", "SBnKysgn", "SBnKzsgn"))
        s5 = target[2][5] & 3
        check(sun == [s5, s5, (x & 7) | 0x81], f"sun sign bytes {[hex(v) for v in sun]}, expected "
              f"{[hex(v) for v in (s5, s5, (x & 7) | 0x81)]} (behind us)")

        # fly into the safe zone: the planet moved to $8000 ahead (as test_missile's safe zone test)
        pp = cpu.page(sym["BankPlanetData"])
        for i, c in enumerate((0, 0, 0x8000)):
            for k in range(3):
                pp[sym["P_BnKxlo"] - 0xC000 + 3 * i + k] = c >> (8 * k) & 255
        for _ in range(5):
            gf.loops(cpu, 1)
            if et.rd(cpu, "SpaceStationSafeZone") == 0 and et.rd(cpu, sym["UniverseSlotType"]) == sym["ShipTypeStation"]:
                break
        check(et.rd(cpu, "SpaceStationSafeZone") == 0, "not in the safe zone")
        check(et.rd(cpu, sym["UniverseSlotType"]) == sym["ShipTypeStation"], "no station in slot 0 in the safe zone")
    except nexsim.Halt as e:
        raise AssertionError(f"crashed: {e}")
    finally:
        sd.close()


if __name__ == "__main__":
    et.main(globals())
