"""Traders docking at the space station, and heading for the sun and jumping out (GameEngine/DockingAI.asm, NormalAI.asm),
and the ship movement they showed was broken:

  * ApplyShipSpeed moves a ship along its nose on every axis (AddBCHtoDELsigned used IYL, where ApplyShipSpeed kept the
    speed, so with x's position and movement of opposite signs y and z didn't move, or with bit 7 of the sign byte
    jumped);
  * DockingAI's decisions: no station, the docking flag cleared; in front of the slot and within DockRangeHi, docked
    (the slot freed); behind it, the approach point the station + nose * DockApproachDistance; near, the speed capped
    (DockSpeed, DockTurnSpeed while turning);
  * the NormalAI hooks: heading for the planet with the station there, the docking flag set; at the planet's safe zone
    with no station, heading for the sun instead; at the sun, jumped out (the slot freed);
  * in flight: a trader from behind the station flies round to the slot, slows and docks, never exploding.
"""
import math

import elitetest as et
import nexsim
import test_game_flow as gf
from elitetest import check, sym

UNIV = sym["BankUNIVDATA0"]
FREE = 0xFF
MATHS = sym["BankMathsBankedFns"]


def booted():
    sd = et.SD()
    return sd, et.machine(sd, boot="StartAttractMode")


def sm(v):
    v = int(round(v))
    return abs(v) | (0x800000 if v < 0 else 0)


def unsm(v):
    m = v & 0x7FFFFF
    return -m if v & 0x800000 else m


def bank_wr(cpu, page, name, v, n=1, off=0):
    p = cpu.page(page)
    a = (sym[name] if isinstance(name, str) else name) - 0xC000 + off
    for i in range(n):
        p[a + i] = v >> (8 * i) & 255


def bank_rd(cpu, page, name, n=1, off=0):
    p = cpu.page(page)
    a = (sym[name] if isinstance(name, str) else name) - 0xC000 + off
    return sum(p[a + i] << (8 * i) for i in range(n))


def put_pos(cpu, page, name, pos):
    for i, c in enumerate(pos):
        bank_wr(cpu, page, name, sm(c), 3, 3 * i)


def get_pos(cpu, page, name="UBnKxlo"):
    return [unsm(bank_rd(cpu, page, name, 3, 3 * i)) for i in range(3)]


def put_nose(cpu, page, nose):
    """nosev from a unit vector (96 * 256 = 1.0, lead sign)"""
    for i, c in enumerate(nose):
        v = int(round(abs(c) * 96 * 256))
        bank_wr(cpu, page, "UBnkrotmatNosevX", v | (0x8000 if c < 0 else 0), 2, 2 * i)


def slots(cpu):
    return [et.rd(cpu, sym["UniverseSlotList"] + s) for s in range(sym["UniverseSlotListSize"])]


def setup_slots(cpu, station=True):
    for s in range(sym["UniverseSlotListSize"]):
        et.wr(cpu, sym["UniverseSlotList"] + s, FREE)
        et.wr(cpu, sym["UniverseSlotType"] + s, FREE)
    if station:
        et.wr(cpu, sym["UniverseSlotList"], sym["ShipID_Coriolis"])
        et.wr(cpu, sym["UniverseSlotType"], sym["ShipTypeStation"])
    et.wr(cpu, sym["UniverseSlotList"] + 1, sym["ShipID_Adder"])
    et.wr(cpu, sym["UniverseSlotType"] + 1, sym["ShipTypeNormal"])
    et.wr(cpu, "SelectedUniverseSlot", 1)


def newbits(cpu):
    return bank_rd(cpu, UNIV + 1, "ShipNewBitsAddr")


def test_ship_speed_moves_every_axis():
    """ApplyShipSpeed: each axis moves by speed * 4 * |nose hi| / 256 in the nose's direction, whatever the signs of the
    position (it fails on the old code: the x step's AddBCHtoDELsigned overwrote the speed kept in IYL)"""
    sd, cpu = booted()
    r = et.rnd(80)
    page = UNIV + 1
    for n in range(200):
        pos = [r.randrange(-0x20000, 0x20000) for _ in range(3)]
        nose = [r.uniform(-1, 1) for _ in range(3)]
        length = math.sqrt(sum(c * c for c in nose)) or 1
        nose = [c / length for c in nose]
        speed = r.randrange(1, 40)
        put_pos(cpu, page, "UBnKxlo", pos)
        put_nose(cpu, page, nose)
        bank_wr(cpu, page, "UBnKSpeed", speed)
        cpu.iy = r.randrange(65536)
        et.call(cpu, "ApplyShipSpeed", mmu={0: MATHS, 6: page})
        got = get_pos(cpu, page)
        for i in range(3):
            hi = bank_rd(cpu, page, "UBnkrotmatNosevX", 1, 2 * i + 1)
            step = (speed * 4 * (hi & 0x7F)) >> 8
            exp = pos[i] + (-step if hi & 0x80 else step)
            check(got[i] == exp, f"{pos} nose {[round(c, 2) for c in nose]} speed {speed}: axis {i} {got[i]}, expected {exp}")
    sd.close()


def docking_ai(cpu):
    et.call(cpu, "DockingAI", mmu={0: MATHS, 6: UNIV + 1})


def place(cpu, ship, station=(0, 0, 0), nose=(0, 0, 1), speed=20, ship_nose=(0, 0, -1)):
    put_pos(cpu, UNIV, "UBnKxlo", station)
    put_nose(cpu, UNIV, nose)
    put_pos(cpu, UNIV + 1, "UBnKxlo", ship)
    put_nose(cpu, UNIV + 1, ship_nose)
    bank_wr(cpu, UNIV + 1, "UBnKSpeed", speed)
    bank_wr(cpu, UNIV + 1, "UBnKAccel", 0)
    bank_wr(cpu, UNIV + 1, "ShipNewBitsAddr", sym["ShipIsTrader"] | sym["ShipIsDocking"])


def test_docking_decisions():
    """DockingAI from where the ship is: docked in front of the slot within DockRangeHi; not docked further out or
    beside the station; the approach point behind; the speed capped near; the flag cleared with no station"""
    sd, cpu = booted()
    r = et.rnd(81)
    rng = sym["DockRangeHi"] * 256
    for n in range(60):
        st = [r.randrange(-0x8000, 0x8000) for _ in range(3)]
        nose = [r.uniform(-1, 1) for _ in range(3)]
        ln = math.sqrt(sum(c * c for c in nose))
        nose = [c / ln for c in nose]
        # in front, close: docked
        setup_slots(cpu)
        d = r.randrange(80, rng - 60)
        place(cpu, [s + c * d for s, c in zip(st, nose)], st, nose)
        docking_ai(cpu)
        check(slots(cpu)[1] == FREE, f"station {st} nose {[round(c, 2) for c in nose]}: {d} in front, not docked")
        # in front but further out: steered, slowed, still there
        setup_slots(cpu)
        d = r.randrange(rng + 300, sym["DockSlowHi"] * 256 - 300)
        place(cpu, [s + c * d for s, c in zip(st, nose)], st, nose, speed=30,
              ship_nose=[-c for c in nose])                                 # pointing at the station
        docking_ai(cpu)
        check(slots(cpu)[1] != FREE, f"{d} in front: docked too far out")
        speed = bank_rd(cpu, UNIV + 1, "UBnKSpeed")
        check(speed == sym["DockSpeed"], f"{d} in front, nose on the station: speed {speed}, expected DockSpeed")
        # in front, pointing away: the turning speed
        setup_slots(cpu)
        place(cpu, [s + c * d for s, c in zip(st, nose)], st, nose, speed=30, ship_nose=nose)
        docking_ai(cpu)
        speed = bank_rd(cpu, UNIV + 1, "UBnKSpeed")
        check(speed == sym["DockTurnSpeed"], f"{d} in front, nose away: speed {speed}, expected DockTurnSpeed")
        # behind, close: not docked, the approach point
        setup_slots(cpu)
        d = r.randrange(80, rng - 60)
        place(cpu, [s - c * d for s, c in zip(st, nose)], st, nose)
        docking_ai(cpu)
        check(slots(cpu)[1] != FREE, f"{d} behind the station: docked")
        target = [unsm(sum(et.rd(cpu, sym["DockTargetPos"] + 3 * i + k) << (8 * k) for k in range(3))) for i in range(3)]
        hi = [bank_rd(cpu, UNIV, "UBnkrotmatNosevX", 1, 2 * i + 1) for i in range(3)]
        exp = [s + (-1 if h & 0x80 else 1) * (h & 0x7F) * sym["DockApproachDistance"] for s, h in zip(st, hi)]
        check(target == exp, f"approach point {target}, expected {exp}")
    # no station: the flag cleared, the slot kept
    setup_slots(cpu, station=False)
    place(cpu, (0, 0, 100))
    docking_ai(cpu)
    check(not newbits(cpu) & sym["ShipIsDocking"], "docking flag kept with no station")
    check(slots(cpu)[1] != FREE, "docked with no station")
    sd.close()


def test_heading_hooks():
    """ShipHeadingToUnivBody: heading for the planet with the station there sets the docking flag; at the planet's safe
    zone with no station the ship heads for the sun (UBnKHeadingToPlanetOrSun 2); at the sun it jumps out (slot freed)"""
    sd, cpu = booted()
    mmu = {0: MATHS, 6: UNIV + 1}
    # station there
    setup_slots(cpu)
    place(cpu, (0, 0, 0x30000), station=(0, 0, 0x10000))
    bank_wr(cpu, UNIV + 1, "ShipNewBitsAddr", sym["ShipIsTrader"])
    bank_wr(cpu, UNIV + 1, "UBnKHeadingToPlanetOrSun", 1)
    et.call(cpu, "ShipHeadingToUnivBody", mmu=mmu)
    check(newbits(cpu) & sym["ShipIsDocking"], "heading for the planet with the station there: no docking flag")
    # no station, at the planet
    setup_slots(cpu, station=False)
    put_pos(cpu, sym["BankPlanetData"], "P_BnKxlo", (0, 0, 0x20000))
    put_pos(cpu, UNIV + 1, "UBnKxlo", (0x1000, 0, 0x20000 - 0x4000))
    bank_wr(cpu, UNIV + 1, "ShipNewBitsAddr", sym["ShipIsTrader"])
    bank_wr(cpu, UNIV + 1, "UBnKHeadingToPlanetOrSun", 1)
    et.call(cpu, "ShipHeadingToUnivBody", mmu=mmu)
    check(bank_rd(cpu, UNIV + 1, "UBnKHeadingToPlanetOrSun") == 2, "at the planet with no station: not heading for the sun")
    check(slots(cpu)[1] != FREE, "at the planet: left the slot list")
    # at the sun
    put_pos(cpu, sym["BankSunData"], "SBnKxlo", (0, 0x10000, -0x30000))
    put_pos(cpu, UNIV + 1, "UBnKxlo", (0, 0x10000 + 0x2000, -0x30000 + 0x3000))
    et.call(cpu, "ShipHeadingToUnivBody", mmu=mmu)
    check(slots(cpu)[1] == FREE, "at the sun: didn't jump out")
    # far from the sun: still there
    setup_slots(cpu, station=False)
    bank_wr(cpu, UNIV + 1, "UBnKHeadingToPlanetOrSun", 2)
    put_pos(cpu, UNIV + 1, "UBnKxlo", (0, 0, 0x20000))
    et.call(cpu, "ShipHeadingToUnivBody", mmu=mmu)
    check(slots(cpu)[1] != FREE, "far from the sun: jumped out")
    sd.close()


def call_in_game(cpu, name):
    """call name at the top of the main loop with the game's stack and paging left as they were"""
    et.run_until(cpu, lambda: cpu.pc == sym["MainLoop"], "the main loop")
    pc, sp, mmu, stepi = cpu.pc, cpu.sp, list(cpu.mmu), cpu.stepi
    cpu.stepi = cpu.step
    try:
        et.call(cpu, name, sp=sp - 0x80)
    finally:
        cpu.stepi = stepi
        for s, m in enumerate(mmu):
            et.page_in(cpu, s, m)
        cpu.pc, cpu.sp = pc, sp


def test_trader_docks_in_flight():
    """launched (the station behind us), a trader spawned 5000 behind the station: it flies round to the front of the
    slot, slows down and docks within 1500 main loops, never exploding; it leaves the slot list from in front of the
    slot and within DockRangeHi"""
    sd, cpu = gf.game()
    try:
        gf.press(cpu, "c_Pressed_No", 5)
        gf.loops(cpu, 20)
        gf.press(cpu, "c_Pressed_Launch")
        gf.loops(cpu, 60)
        check(et.rd(cpu, sym["UniverseSlotType"]) == sym["ShipTypeStation"], "no station after the launch")
        for s in range(1, sym["UniverseSlotListSize"]):
            et.wr(cpu, sym["UniverseSlotList"] + s, FREE)
            et.wr(cpu, sym["UniverseSlotType"] + s, FREE)
        call_in_game(cpu, "SpawnTrader")
        check(slots(cpu)[1] != FREE, "no trader spawned")
        st = get_pos(cpu, UNIV)
        hi = [bank_rd(cpu, UNIV, "UBnkrotmatNosevX", 1, 2 * i + 1) for i in range(3)]
        nose = [(-1 if h & 0x80 else 1) * (h & 0x7F) / 96 for h in hi]
        put_pos(cpu, UNIV + 1, "UBnKxlo", [int(s - c * 5000 + (1500 if i == 1 else 0)) for i, (s, c) in enumerate(zip(st, nose))])
        bits = newbits(cpu)
        bank_wr(cpu, UNIV + 1, "ShipNewBitsAddr", (bits | sym["ShipIsTrader"]) & ~sym["ShipIsHostile"] & 0xFF)
        bank_wr(cpu, UNIV + 1, "UBnKHeadingToPlanetOrSun", 1)
        bank_wr(cpu, UNIV + 1, "UBnKSpeed", 15)
        last = None
        for n in range(1500):
            gf.loops(cpu, 1)
            for a in ("ForeShield", "AftShield", "PlayerEnergy"):
                et.wr(cpu, a, 0xFF)
            for s in range(2, sym["UniverseSlotListSize"]):                 # no spawns in the way
                et.wr(cpu, sym["UniverseSlotList"] + s, FREE)
                et.wr(cpu, sym["UniverseSlotType"] + s, FREE)
            if slots(cpu)[1] == FREE:
                break
            check(not bank_rd(cpu, UNIV + 1, "UBnKexplDsp") & 0xA0, f"loop {n}: the trader is exploding")
            last = [a - b for a, b in zip(get_pos(cpu, UNIV + 1), get_pos(cpu, UNIV))]
        check(slots(cpu)[1] == FREE, f"not docked after 1500 loops: at {last} from the station")
        dist = math.sqrt(sum(c * c for c in last))
        front = sum(c * k for c, k in zip(last, nose)) / dist
        et.note(f"docked after {n} loops, {dist:.0f} from the station, {front:+.2f} along its nose")
        check(max(abs(c) for c in last) < sym["DockRangeHi"] * 256 + 200, f"docked at {last}, too far out")
        check(front > 0.6, f"docked at {last}: not in front of the slot ({front:+.2f})")
    except nexsim.Halt as e:
        raise AssertionError(f"crashed: {e}")
    finally:
        sd.close()


if __name__ == "__main__":
    et.main(globals())
