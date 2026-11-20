"""The missile: its S15.8 range checks, the saturating vector add, the
steering decisions (SeekingLogic, as BBC TACTICS), the 10 second lifespan,
the direct hit and the blast (splash damage).

Runs on the game booted to the attract mode, so the universe banks hold
their code (ResetUniv copies bank A to the other slots at start up).
Universe slot n is page BankUNIVDATA0 + n in slot 6 ($C000).
"""
import elitetest as et
from elitetest import check, sym

MATHS = {0: sym["BankMathsBankedFns"]}
SM24 = 0x7FFFFF
EXPLODING = sym["ShipExploding"]
NO_HIT, HIT_PLAYER = 0xFF, 0xFE


def sm(v):
    return abs(v) | (0x800000 if v < 0 else 0)


def unsm(v):
    m = v & SM24
    return -m if v & 0x800000 else m


def booted():
    sd = et.SD()
    return sd, et.machine(sd, boot="StartAttractMode")


def bank(slot):
    return sym["BankUNIVDATA0"] + slot


def ship_wr(cpu, slot, name, v, n=1):
    """write a universe bank variable of slot (without paging it in)"""
    p = cpu.page(bank(slot))
    a = (sym[name] if isinstance(name, str) else name) - 0xC000
    for i in range(n):
        p[a + i] = v >> (8 * i) & 255


def ship_rd(cpu, slot, name, n=1):
    p = cpu.page(bank(slot))
    a = sym[name] - 0xC000
    return sum(p[a + i] << (8 * i) for i in range(n))


def place(cpu, slot, pos, kind=None, energy=200, flags=0x80):
    """put an object in a universe slot: pos (x, y, z) in 1/256ths"""
    for i, c in enumerate(pos):
        ship_wr(cpu, slot, sym["UBnKxlo"] + 3 * i, sm(c), 3)
    ship_wr(cpu, slot, "UBnKEnergy", energy)
    ship_wr(cpu, slot, "UBnkaiatkecm", flags)
    ship_wr(cpu, slot, "UBnKexplDsp", 0)
    if kind is not None:
        ship_wr(cpu, slot, "ShipTypeAddr", kind)
        et.wr(cpu, sym["UniverseSlotList"] + slot, kind)


def empty_slots(cpu):
    for s in range(sym["UniverseSlotListSize"]):
        et.wr(cpu, sym["UniverseSlotList"] + s, 0xFF)


# --- the range checks ---------------------------------------------------------
def test_MissileVectorAdd():
    """S15.8 add that saturates: same signs past 32767.996 clamp to the
    largest magnitude with the first operand's sign (AHLequBHLplusCDE would
    flip the sign and turn the missile round)"""
    sd, cpu = booted()
    r = et.rnd(11)
    for _ in range(1500):
        x = r.randrange(-SM24, SM24 + 1) >> r.randrange(0, 4)
        y = r.randrange(-SM24, SM24 + 1) >> r.randrange(0, 4)
        bx, cy = sm(x), sm(y)
        et.call(cpu, "MissileVectorAdd", mmu=MATHS, b=bx >> 16, hl=bx & 0xFFFF, c=cy >> 16, de=cy & 0xFFFF)
        got = et.reg(cpu, "a") << 16 | et.reg(cpu, "hl")
        exp = max(-SM24, min(SM24, x + y))
        check(got == sm(exp) or (exp == 0 and got & SM24 == 0),
              f"{x} + {y}: got {unsm(got)} ({got:06X}), expected {exp}")
    sd.close()


def test_CheckInCollisionRange():
    """carry iff |ship - missile| < CurrentMissileBlastRange (1/256ths) on
    every axis, positions anywhere in S15.8 (opposite signs past 16384.0, which
    the add can't do, are out of range)"""
    sd, cpu = booted()
    r = et.rnd(12)
    ship, miss = sym["FileBuffer"], sym["FileBuffer"] + 16
    hits = 0
    for n in range(1500):
        rng = r.randrange(1, 256)
        base = [r.randrange(-SM24, SM24 + 1) >> r.randrange(0, 23) for _ in range(3)]
        if n % 3 == 0:              # close: near the range edge on each axis
            off = [r.randrange(-rng - 3, rng + 4) for _ in range(3)]
        else:
            off = [r.randrange(-SM24, SM24 + 1) >> r.randrange(0, 23) for _ in range(3)]
        sp = [max(-SM24, min(SM24, b + o)) for b, o in zip(base, off)]
        for i in range(3):
            et.wr(cpu, ship + 3 * i, sm(sp[i]), 3)
            et.wr(cpu, miss + 3 * i, sm(base[i]), 3)
        et.wr(cpu, "CurrentMissileBlastRange", rng)
        et.call(cpu, "CheckInCollisionRange", mmu=MATHS, ix=ship, iy=miss)
        exp = all(abs(s - b) < rng for s, b in zip(sp, base))
        hits += exp
        check(et.reg(cpu, "carry") == exp, f"ship {sp} missile {base} range {rng}: carry {et.reg(cpu, 'carry')}")
    check(hits > 100, f"only {hits} cases in range")
    sd.close()


def test_player_range_checks():
    """MissileHitUsCheckPos: carry iff |p| < 1.0 on every axis;
    BlastInRangeOfPlayer: carry iff |p| < CurrentMissileBlastRange (1/256ths)"""
    sd, cpu = booted()
    r = et.rnd(13)
    et.page_in(cpu, 6, bank(1))
    for n in range(1500):
        rng = r.randrange(1, 256)
        lim = r.choice((rng + 3, 300, SM24))
        p = [r.randrange(-lim, lim + 1) for _ in range(3)]
        place(cpu, 1, p)
        et.call(cpu, "MissileHitUsCheckPos")
        check(et.reg(cpu, "carry") == all(abs(c) < 256 for c in p), f"hit check at {p}")
        et.wr(cpu, "CurrentMissileBlastRange", rng)
        et.call(cpu, "BlastInRangeOfPlayer")
        check(et.reg(cpu, "carry") == all(abs(c) < rng for c in p), f"blast check at {p}, range {rng}")
    sd.close()


# --- steering -----------------------------------------------------------------------
def dot(v, row):
    """XX12EquTacticsDotHL: each product's high byte, summed lead sign as
    ADDHLDESignBC does (equal and opposite gives 0 with the first's sign)"""
    def add(a, sa, b, sb):
        if sa == sb:
            return a + b, sa
        if a >= b:
            return a - b, sa
        return b - a, sb
    prods = [((vm * (rm & 0x7F)) >> 8, vs ^ (rm & 0x80)) for (vm, vs), rm in zip(v, row)]
    s, ss = add(*prods[0], *prods[1])
    return add(s, ss, *prods[2])


def test_SeekingLogic():
    """Pitch, roll and acceleration from the nose, roof and side dot products
    against the normalised direction to the target, as BBC TACTICS:
    pitch = RAT with the roof dot's sign flipped if |roof| * 2 >= RAT2 or the
    target is behind, else 0 (keeping that sign); roll = RAT with sign
    side xor roof if |side| * 2 >= RAT2, else 0 with the roof sign;
    accelerate 3 if facing it (nose >= CNT2), brake 2 if the nose dot is
    |18| or more but not facing it, else no change.  Needs the banked maths
    in slot 0 (the dot products add with ADDHLDESignBC), as MissileAIV3 has"""
    sd, cpu = booted()
    r = et.rnd(14)
    et.page_in(cpu, 6, bank(1))
    rows = {"nose": "UBnkrotmatNosevX", "roof": "UBnkrotmatRoofvX", "side": "UBnkrotmatSidevX"}
    seen = set()
    for n in range(1500):
        rat, rat2, cnt2 = r.choice(((3, 4, 22), (2, 16, 22), (3, 4, 30)))
        ship_wr(cpu, 1, "UBnKRAT", rat)
        ship_wr(cpu, 1, "UBnKRAT2", rat2)
        ship_wr(cpu, 1, "UBnKCNT2", cnt2)
        v = [(r.randrange(0, 97), r.choice((0, 0x80))) for _ in range(3)]
        for i, (m, s) in enumerate(v):
            a = sym["TacticsVectorX"] + 4 * i
            et.wr(cpu, a, m)
            et.wr(cpu, a + 1, 0)
            et.wr(cpu, a + 2, s)
        mat = {}
        for k, name in rows.items():
            mat[k] = [r.randrange(0, 0x61) | r.choice((0, 0x80)) for _ in range(3)]
            for i, hb in enumerate(mat[k]):
                ship_wr(cpu, 1, sym[name] + 2 * i, hb << 8 | r.randrange(256), 2)
        et.call(cpu, "SeekingLogic", mmu=MATHS)     # (MissileAIV3 has the maths bank in: ADDHLDESignBC)
        nose, nsg = dot(v, mat["nose"])
        roof, rsg = dot(v, mat["roof"])
        side, ssg = dot(v, mat["side"])
        flip = rsg ^ 0x80
        pitch = (rat | flip) if (roof * 2 & 255) >= rat2 or nsg else flip
        roll = ((rat | ssg) ^ rsg) if (side * 2 & 255) >= rat2 else rsg
        if not nsg and nose >= cnt2:
            accel = 3
        else:
            accel = 0xFE if nose >= 18 else 0
        got = (ship_rd(cpu, 1, "UBnKRotZCounter"), ship_rd(cpu, 1, "UBnKRotXCounter"), ship_rd(cpu, 1, "UBnKAccel"))
        check(got == (pitch, roll, accel),
              f"v {v} mat {mat}: dots nose {nose} {nsg:02X} roof {roof} {rsg:02X} side {side} {ssg:02X}; "
              f"pitch/roll/accel got {got[0]:02X} {got[1]:02X} {got[2]:02X}, expected {pitch:02X} {roll:02X} {accel:02X}")
        seen.add((pitch & 0x7F != 0, roll & 0x7F != 0, accel))
    check(len(seen) >= 8, f"only {len(seen)} kinds of decision covered")
    sd.close()


def test_trader_steering():
    """ShipHeadingToUnivBody (non hostile ships) steering to the planet or
    sun, as the missile: TacticsVector = ship - body (saturating), inside the
    safe zone cube (|d| < $C000 on every axis) it stops there (docking / jump,
    nothing yet), else the vector is normalised to 96 and negated (body -
    ship) and ShipSeekingLogic sets pitch 2 with the roof dot's sign flipped
    if |roof| * 2 >= 16, roll 2 with sign side xor roof if |side| * 2 >= 16,
    accelerate 3 if the nose dot >= 22, brake 1 if behind or >= 18, else 0;
    with the body behind (nose dot -ve) it keeps pitching so it turns round"""
    sd, cpu = booted()
    r = et.rnd(15)
    rows = {"nose": "UBnkrotmatNosevX", "roof": "UBnkrotmatRoofvX", "side": "UBnkrotmatSidevX"}
    bodies = {1: (sym["BankPlanetData"], "P_BnKxlo"), 2: (sym["BankSunData"], "SBnKxlo")}
    seen = set()
    stopped = 0
    for n in range(1200):
        which = r.choice((1, 2))
        ship = [r.randrange(-(1 << 20), 1 << 20) >> r.randrange(0, 12) for _ in range(3)]
        big = 1 << r.choice((15, 17, 20, 23))
        body = [r.randrange(-big + 1, big) for _ in range(3)]
        if n % 10 == 0:
            body = [s + r.randrange(-0xBFFF, 0xC000) for s in ship]    # inside the zone
        if n % 25 == 1:
            body = [-(1 << 23) + 1 if s >= 0 else (1 << 23) - 1 for s in ship]   # ship - body saturates
        body = [max(-SM24, min(SM24, c)) for c in body]
        for i, c in enumerate(ship):
            ship_wr(cpu, 1, sym["UBnKxlo"] + 3 * i, sm(c), 3)
        page, name = bodies[which]
        p = cpu.page(page)
        for i, c in enumerate(body):
            for k in range(3):
                p[sym[name] - 0xC000 + 3 * i + k] = sm(c) >> (8 * k) & 255
        mat = {}
        for k, row in rows.items():
            mat[k] = [r.randrange(0, 0x61) | r.choice((0, 0x80)) for _ in range(3)]
            for i, hb in enumerate(mat[k]):
                ship_wr(cpu, 1, sym[row] + 2 * i, hb << 8 | r.randrange(256), 2)
        ship_wr(cpu, 1, "UBnKHeadingToPlanetOrSun", which)
        for v in ("UBnKRotZCounter", "UBnKRotXCounter", "UBnKAccel"):
            ship_wr(cpu, 1, v, 0x55)
        et.page_in(cpu, 6, bank(1))
        et.call(cpu, "ShipHeadingToUnivBody")
        check(cpu.mmu[6] == bank(1), f"slot 6 holds page {cpu.mmu[6]}, not the ship's {bank(1)}")
        d = [max(-SM24, min(SM24, s - b)) for s, b in zip(ship, body)]
        got = (ship_rd(cpu, 1, "UBnKRotZCounter"), ship_rd(cpu, 1, "UBnKRotXCounter"), ship_rd(cpu, 1, "UBnKAccel"))
        if all(abs(c) < 0xC000 for c in d):
            stopped += 1
            check(got == (0x55, 0x55, 0x55), f"ship {ship} body {body}: in the zone but steered {got}")
            continue
        length = sum(c * c for c in d) ** 0.5
        v = []
        for i, c in enumerate(d):
            a = sym["TacticsVectorX"] + 4 * i
            lo, hi, sg = et.rd(cpu, a), et.rd(cpu, a + 1), et.rd(cpu, a + 2)
            exp = 96 * abs(c) / length
            check(hi == 0 and sg & 0x7F == 0 and -2 < exp - lo < 3.5,    # (NormalizeTactics: a little over 1.5 over at worst)
                  f"ship {ship} body {body}: axis {i} = {lo:02X} {hi:02X} {sg:02X}, expected {exp:.1f}")
            if lo:
                check(sg == (0 if c < 0 else 0x80), f"ship {ship} body {body}: axis {i} sign {sg:02X} (not body - ship)")
            v.append((lo, sg))
        nose, nsg = dot(v, mat["nose"])
        roof, rsg = dot(v, mat["roof"])
        side, ssg = dot(v, mat["side"])
        flip = rsg ^ 0x80
        pitch = (2 | flip) if (roof * 2 & 255) >= 16 or nsg else flip
        roll = ((2 | ssg) ^ rsg) if (side * 2 & 255) >= 16 else rsg
        if nsg:
            accel = 0xFF
        else:
            accel = 3 if nose >= 22 else 0xFF if nose >= 18 else 0
        check(got == (pitch, roll, accel),
              f"ship {ship} body {body} mat {mat}: dots nose {nose} {nsg:02X} roof {roof} {rsg:02X} side {side} "
              f"{ssg:02X}; pitch/roll/accel got {got[0]:02X} {got[1]:02X} {got[2]:02X}, "
              f"expected {pitch:02X} {roll:02X} {accel:02X}")
        seen.add((pitch & 0x7F != 0, roll & 0x7F != 0, accel, bool(nsg)))
    check(stopped >= 50, f"only {stopped} cases inside the zone")
    check(len(seen) >= 8, f"only {len(seen)} kinds of decision covered")
    sd.close()


def test_safe_zone_and_station():
    """UpdateSafeZone: SpaceStationSafeZone 0 inside the cube |x|, |y|, |z| < $C000 round the planet, $FF outside (it
    was never set); on flying in with slot 0 (kept for the station) free the station is made there, |normal| * 192 from
    the planet's centre towards us with its nose (the slot) towards us, as the docking test wants; not made twice"""
    sd, cpu = booted()
    import math
    MATHS_PLANET = {0: sym["BankMathsBankedFns"], 6: sym["BankPlanetData"]}
    pp = cpu.page(sym["BankPlanetData"])
    st = sym["BankUNIVDATA0"]
    r = et.rnd(16)
    made = 0
    for n in range(40):
        inside = n % 4 != 3
        lim = 0xBFFF if inside else 0x30000
        planet = [r.randrange(-lim, lim) for _ in range(3)]
        planet[2] = abs(planet[2]) or 1                    # ahead of us
        if not inside:
            planet[r.randrange(3)] = r.choice((-1, 1)) * r.randrange(0xC000, 0x40000)
        for i, c in enumerate(planet):
            v = sm(c)
            for k in range(3):
                pp[sym["P_BnKxlo"] - 0xC000 + 3 * i + k] = v >> (8 * k) & 255
        et.call(cpu, "Normalise24IX", mmu=MATHS_PLANET, ix=sym["P_BnKxlo"])
        for slot in range(sym["UniverseSlotListSize"]):
            et.wr(cpu, sym["UniverseSlotList"] + slot, 0xFF)
        et.wr(cpu, "SpaceStationSafeZone", 0xFF)           # coming from outside
        et.call(cpu, "UpdateSafeZone")
        zone = et.rd(cpu, "SpaceStationSafeZone")
        check(zone == (0 if inside else 0xFF), f"{planet}: SpaceStationSafeZone {zone:02X}")
        if not inside:
            check(et.rd(cpu, sym["UniverseSlotList"]) == 0xFF, f"{planet}: a station made outside the zone")
            continue
        made += 1
        check(et.rd(cpu, sym["UniverseSlotList"]) != 0xFF and et.rd(cpu, sym["UniverseSlotType"]) == sym["ShipTypeStation"],
              f"{planet}: slot 0 isn't the station")
        et.call(cpu, "IsSpaceStationPresent")
        check(not et.reg(cpu, "carry"), "IsSpaceStationPresent doesn't find it")
        pos = [unsm(sum(cpu.page(st)[sym["UBnKxlo"] - 0xC000 + 3 * i + k] << (8 * k) for k in range(3))) for i in range(3)]
        length = math.sqrt(sum(c * c for c in planet))
        exp = [c - 192 * 255 * c / length for c in planet]
        check(all(abs(a - b) < 2000 for a, b in zip(pos, exp)), f"{planet}: station at {pos}, expected about {[int(e) for e in exp]}")
        nose = []
        for i in range(3):
            a = sym["UBnkrotmatNosevX"] - 0xC000 + 2 * i
            hi = cpu.page(st)[a + 1]
            nose.append(-(hi & 0x7F) if hi & 0x80 else hi & 0x7F)
        dirn = [-c / length * 96 for c in planet]
        check(all(abs(a - b) < 6 for a, b in zip(nose, dirn)), f"{planet}: station nose {nose}, expected {[int(d) for d in dirn]}")
        et.call(cpu, "UpdateSafeZone")                    # still inside: nothing more
        check(sum(et.rd(cpu, sym["UniverseSlotList"] + k) != 0xFF for k in range(sym["UniverseSlotListSize"])) == 1,
              f"{planet}: a second object made")
    check(made >= 20, f"only {made} cases inside")
    sd.close()


def test_player_missile_launch():
    """IsMissileLockedOn: carry only for a lock ($80 | slot) on an occupied slot ($FF none, $FE targeting, and a lock
    on an emptied slot clears it); it once tested the zero flag of the wrong bits, so firing unlocked launched at slot
    14 / 15. LaunchPlayerMissile (MAINLOOP_LAUNCHMISSILE, back on): a missile in a free slot (1 on) aimed at the
    locked ship, one fewer in the rack, targeting cleared"""
    sd, cpu = booted()
    for slot in range(sym["UniverseSlotListSize"]):
        et.wr(cpu, sym["UniverseSlotList"] + slot, 0xFF)
    et.wr(cpu, sym["UniverseSlotList"] + 3, 0x05)          # something in slot 3
    for flag, locked in ((0xFF, False), (0xFE, False), (0x83, True), (0x84, False)):
        et.wr(cpu, "MissileTargettingFlag", flag)
        et.call(cpu, "IsMissileLockedOn")
        check(bool(et.reg(cpu, "carry")) == locked, f"flag {flag:02X}: carry {et.reg(cpu, 'carry')}")
    check(et.rd(cpu, "MissileTargettingFlag") == 0xFF, "a lock on an empty slot wasn't cleared")
    et.wr(cpu, "NbrMissiles", 2)
    et.wr(cpu, "MissileTargettingFlag", 0x03)               # SetMissileLaunch: launch at slot 3
    et.call(cpu, "LaunchPlayerMissile")
    slots = [et.rd(cpu, sym["UniverseSlotList"] + k) for k in range(sym["UniverseSlotListSize"])]
    new = [k for k, v in enumerate(slots) if v != 0xFF and k != 3]
    check(len(new) == 1 and new[0] >= 1, f"slots {slots}")
    m = new[0]
    check(et.rd(cpu, sym["UniverseSlotType"] + m) == sym["ShipTypeMissile"], f"slot {m} isn't a missile")
    check(ship_rd(cpu, m, "UBnKMissileTarget") == 3, f"missile target {ship_rd(cpu, m, 'UBnKMissileTarget')}")
    check(et.rd(cpu, "NbrMissiles") == 1, "the rack wasn't reduced")
    check(et.rd(cpu, "MissileTargettingFlag") == 0xFF, "targeting not cleared")
    sd.close()


def test_collisions():
    """Collisions back on (were skipped by a DEBUG jp): a ship within 128 on every axis with us at speed 5 or more is
    destroyed and our front shield takes 128 + its energy / 2, the overflow off our energy (ApplyDamage once treated any
    energy over 127 as dead); the same ship 65536 further out on an axis isn't close (the sign bytes were ignored, and
    the closeness test once started with A as UpdateECM left it)"""
    sd, cpu = booted()
    for shield, damage, energy in ((200, 50, 200), (40, 100, 200), (40, 100, 30), (0, 255, 255)):
        et.wr(cpu, "PlayerEnergy", energy)
        et.call(cpu, "ApplyDamage", a=shield, b=damage)
        left = shield - damage
        exp_shield, exp_energy = (left, energy) if left >= 0 else (0, max(0, energy + left))
        check(et.reg(cpu, "a") == exp_shield and et.rd(cpu, "PlayerEnergy") == exp_energy,
              f"shield {shield} energy {energy} hit {damage}: shield {et.reg(cpu, 'a')} energy {et.rd(cpu, 'PlayerEnergy')}")
    for far in (False, True):
        for slot in range(sym["UniverseSlotListSize"]):
            et.wr(cpu, sym["UniverseSlotList"] + slot, 0xFF)
        et.call(cpu, "SpawnShipTypeA", a=sym["ShipID_Viper"])
        slot = next(k for k in range(1, 12) if et.rd(cpu, sym["UniverseSlotList"] + k) != 0xFF)
        place(cpu, slot, (10, 5, 40 if not far else 0x10000 + 40), energy=100)   # (raw units: close is hi 0, lo < 128)
        et.wr(cpu, "DELTA", 10)
        et.wr(cpu, "ForeShield", 200)
        et.wr(cpu, "PlayerEnergy", 255)
        et.wr(cpu, "DockedFlag", sym["StateNormal"])
        et.call(cpu, "UpdateUniverseObjects", mmu=MATHS)
        hit = exploding(cpu, slot)
        check(hit != far, f"{'far' if far else 'close'} ship: exploding {hit}")
        if not far:
            check(et.rd(cpu, "ForeShield") < 200, f"shield {et.rd(cpu, 'ForeShield')} after the collision")
    sd.close()


# --- lifespan, hits and the blast ---------------------------------------------
def missile(cpu, slot, pos, hostile=True, launch=0, now=0):
    """a live missile in slot, heading +z, the BBC missile settings"""
    place(cpu, slot, pos, kind=sym["ShipTypeMissile"], flags=0x80)
    ship_wr(cpu, slot, "ShipNewBitsAddr", sym["ShipIsHostile"] if hostile else 0)
    ship_wr(cpu, slot, "UBnKMissileBlastRange", 51)          # 0.2
    ship_wr(cpu, slot, "UBnKMissileBlastDamage", 150)
    ship_wr(cpu, slot, "UBnKMissileDetonateDamage", 150)
    ship_wr(cpu, slot, "UBnKMissileLaunchFrame", launch, 2)
    ship_wr(cpu, slot, "UBnKRAT", 3)
    ship_wr(cpu, slot, "UBnKRAT2", 4)
    ship_wr(cpu, slot, "UBnKCNT2", 22)
    for name, hb in (("UBnkrotmatSidevX", (0x60, 0, 0)), ("UBnkrotmatRoofvX", (0, 0x60, 0)),
                     ("UBnkrotmatNosevX", (0, 0, 0x60))):
        for i, h in enumerate(hb):
            ship_wr(cpu, slot, sym[name] + 2 * i, h << 8, 2)
    et.wr(cpu, "FrameCounter16", now, 2)
    et.wr(cpu, "SelectedUniverseSlot", slot)
    et.wr(cpu, "ECMCountDown", 0)
    et.page_in(cpu, 6, bank(slot))


def exploding(cpu, slot):
    return bool(ship_rd(cpu, slot, "UBnkaiatkecm") & EXPLODING)


def shields(cpu):
    return et.rd(cpu, "ForeShield"), et.rd(cpu, "AftShield")


def test_lifespan():
    """A missile self destructs once FrameCounter16 is 500 frames (10 s) past
    its launch frame, across the counter's wrap; not at 499"""
    sd, cpu = booted()
    for launch, elapsed in ((0, 499), (0, 500), (0xFF00, 499), (0xFF00, 500), (100, 2000), (100, 1)):
        empty_slots(cpu)
        missile(cpu, 0, (0, 0, 40 * 256), launch=launch, now=(launch + elapsed) & 0xFFFF)
        et.call(cpu, "MissileAIV3")
        check(exploding(cpu, 0) == (elapsed >= 500), f"launched {launch:04X}, {elapsed} frames: exploding {exploding(cpu, 0)}")
        if elapsed >= 500:
            check(et.rd(cpu, "MissileDirectHitSlot") == NO_HIT, "a lifespan detonation is not a direct hit")
    sd.close()


def test_direct_hit_on_player():
    """A hostile missile within 1.0 of us explodes, damages the shield on its
    side once, and the blast skips us (MissileDirectHitSlot = $FE)"""
    sd, cpu = booted()
    for z, side in ((40, 0), (-40, 1)):
        empty_slots(cpu)
        missile(cpu, 0, (30, -20, z))
        et.wr(cpu, "ForeShield", 255)
        et.wr(cpu, "AftShield", 255)
        et.call(cpu, "MissileAIV3")
        check(exploding(cpu, 0), "the missile didn't explode")
        check(et.rd(cpu, "MissileDirectHitSlot") == HIT_PLAYER, f"direct hit slot {et.rd(cpu, 'MissileDirectHitSlot'):02X}")
        exp = [255, 255]
        exp[side] = 255 - 150
        check(list(shields(cpu)) == exp, f"z {z}: shields {shields(cpu)}, expected {exp} (hit once, on that side)")
    sd.close()


def test_blast():
    """MissileBlast: blast damage to us and every ship within 0.2 on every
    axis; not to stations, exploding ships, empty slots, the ship hit
    directly, or anything further; a ship whose energy runs out explodes.
    The missile's bank is paged back in, IX and IY kept"""
    sd, cpu = booted()
    empty_slots(cpu)
    m = (1000, -2000, 3000)
    missile(cpu, 0, m, hostile=False)
    ship_wr(cpu, 0, "UBnkaiatkecm", 0x80 | EXPLODING)      # (as UnivExplodeShip leaves it)
    near = lambda dx, dy, dz: (m[0] + dx, m[1] + dy, m[2] + dz)   # noqa: E731
    place(cpu, 1, near(50, -50, 50), kind=3, energy=200)            # in range: 200 - 150
    place(cpu, 2, near(51, 0, 0), kind=3, energy=200)               # 51/256 = 0.2: out
    place(cpu, 3, near(10, 10, 10), kind=sym["ShipTypeStation"], energy=200)
    place(cpu, 4, near(0, 0, -50), kind=3, energy=100)              # killed
    place(cpu, 5, near(5, 5, 5), kind=3, energy=200)                # hit directly: skipped
    place(cpu, 6, near(1, 1, 1), kind=3, energy=200, flags=0x80 | EXPLODING)
    place(cpu, 7, near(2, 2, 2), energy=200)                        # empty slot
    et.wr(cpu, sym["UniverseSlotList"] + 7, 0xFF)
    place(cpu, 8, (-m[0], m[1], m[2]), kind=3, energy=200)          # far
    et.wr(cpu, "MissileDirectHitSlot", 5)
    et.wr(cpu, "ForeShield", 255)
    et.wr(cpu, "AftShield", 255)
    et.call(cpu, "MissileBlast", ix=0x1234, iy=0x5678)
    energy = {s: ship_rd(cpu, s, "UBnKEnergy") for s in range(1, 9)}
    check(energy[1] == 50, f"slot 1 (in range) energy {energy[1]}, expected 50")
    for s in (2, 3, 5, 6, 7, 8):
        check(energy[s] == 200, f"slot {s} energy {energy[s]}, expected 200 (untouched)")
    check(exploding(cpu, 4) and not exploding(cpu, 1), "slot 4 should explode, slot 1 survive")
    check(shields(cpu) == (255, 255), f"we are 3.7 away but the shields are {shields(cpu)}")
    check(cpu.mmu[6] == bank(0), f"slot 6 holds page {cpu.mmu[6]}, not the missile's {bank(0)}")
    check((cpu.ix, cpu.iy) == (0x1234, 0x5678), f"ix {cpu.ix:04X} iy {cpu.iy:04X} not kept")

    # we are in the blast unless we were the direct hit
    for direct, exp in ((NO_HIT, (105, 255)), (HIT_PLAYER, (255, 255))):
        empty_slots(cpu)
        missile(cpu, 0, (20, 20, 20))
        et.wr(cpu, "MissileDirectHitSlot", direct)
        et.wr(cpu, "ForeShield", 255)
        et.wr(cpu, "AftShield", 255)
        et.call(cpu, "MissileBlast")
        check(shields(cpu) == exp, f"direct hit slot {direct:02X}: shields {shields(cpu)}, expected {exp}")
    sd.close()


def test_direct_hit_on_ship():
    """A friendly missile within 1.0 of its target damages it directly
    (detonate damage), then the blast skips it; a station only turns hostile"""
    sd, cpu = booted()
    for kind, energy, exp_energy in ((3, 200, 50), (sym["ShipTypeStation"], 200, 200)):
        empty_slots(cpu)
        missile(cpu, 0, (5000, 0, 5000), hostile=False)
        ship_wr(cpu, 0, "UBnKMissileTarget", 2)
        place(cpu, 2, (5000 + 100, 50, 5000 - 100), kind=kind, energy=energy)
        ship_wr(cpu, 2, "ShipNewBitsAddr", 0)
        et.page_in(cpu, 6, bank(0))
        et.call(cpu, "MissileAIV3")
        check(exploding(cpu, 0), "the missile didn't explode")
        check(et.rd(cpu, "MissileDirectHitSlot") == 2, f"direct hit slot {et.rd(cpu, 'MissileDirectHitSlot'):02X}")
        check(ship_rd(cpu, 2, "UBnKEnergy") == exp_energy,
              f"target type {kind}: energy {ship_rd(cpu, 2, 'UBnKEnergy')}, expected {exp_energy} (damaged once)")
        if kind == sym["ShipTypeStation"]:
            check(ship_rd(cpu, 2, "ShipNewBitsAddr") & sym["ShipIsHostile"], "the station wasn't angered")
    sd.close()


if __name__ == "__main__":
    et.main(globals())
