"""The game played through on the emulator: start up with the default commander, menus, launch, flight.

The market screen once printed 23 boiler text entries from a table of 22: the 23rd came from the text after it
("Market Data") as row $4D, column $7261, and l2_print_char_at_320 wrote that off screen character at hl = the
column, into main memory, over the compass code; the game crashed as soon as it flew."""
import elitetest as et
import nexsim
from elitetest import check, sym
import test_keys as tk


def game():
    """the game booted to the attract screen with the 50 Hz interrupt"""
    sd = et.SD()
    cpu = et.machine(sd, boot="StartAttractMode")
    nxt = [cpu.t + et.FRAME_T]

    def stepi():
        cpu.step()
        if cpu.t >= nxt[0]:
            nxt[0] += et.FRAME_T
            cpu.interrupt()
    cpu.stepi = stepi
    return sd, cpu


def key(cpu, control):
    et.page_in(cpu, 7, sym["BankKeyboard"])
    return et.rd(cpu, sym["KeyboardMap"] + sym[control], 2) - sym["Keys"]


def loops(cpu, n):
    """n main loops; the stack pointer at each MainLoop"""
    sps = []
    for _ in range(n):
        et.run_until(cpu, lambda: cpu.pc == sym["MainLoop"], "the main loop", limit=200_000_000)
        sps.append(cpu.sp)
        cpu.stepi()
    return sps


def press(cpu, control, n=3):
    tk.press(cpu, key(cpu, control))
    sps = loops(cpu, n)
    tk.release(cpu)
    return sps


def test_market_then_launch_flies():
    """Default commander, the market (7), launch (L): the game then flies (150 loops) with the stack as it was"""
    sd, cpu = game()
    try:
        sps = press(cpu, "c_Pressed_No", 5) + loops(cpu, 20)
        sps += press(cpu, "c_Pressed_MarketPrices") + loops(cpu, 20)
        check(et.rd(cpu, "ScreenIndex") == sym["ScreenMarket"], f"not on the market screen ({et.rd(cpu, 'ScreenIndex')})")
        sps += press(cpu, "c_Pressed_Launch") + loops(cpu, 150)
    except nexsim.Halt as e:
        raise AssertionError(f"crashed: {e}")
    check(et.rd(cpu, "DockedFlag") == sym["StateNormal"], f"not in flight (DockedFlag {et.rd(cpu, 'DockedFlag'):02X})")
    check(len(set(sps)) == 1, f"the stack moved: {sorted(set(sps))[:6]}")
    sd.close()


def test_print_off_the_right_edge_writes_nothing():
    """l2_print_at_320 (320 x 256) with text running past column 319, and at a column of 320 or more, writes nothing
    outside Layer 2 (l2_target_address_320 now returns carry, and the character and blank printers skip the cell)"""
    sd, cpu = game()
    cpu.stepi = cpu.step
    et.call(cpu, "SetScreenA", a=sym["ScreenMarket"])
    l2 = cpu.nextreg.get(0x12, 8) * 2
    msg = sym["TextBuffer"]
    for i, ch in enumerate(b"ABCD EFGH IJKL MNOP\0"):
        et.wr(cpu, msg + i, ch)
    stack = range(sym["TopOfStack"] - 0x40 - 0x4000, sym["TopOfStack"] - 0x4000)     # (page 10 is $4000-$5FFF)

    def outside():
        """every page but Layer 2's, with the stack's bytes blanked"""
        out = {}
        for n, p in cpu.pages.items():
            if l2 <= n < l2 + 10:
                continue
            b = bytearray(p)
            if n == 10:
                for i in stack:
                    b[i] = 0
            out[n] = bytes(b)
        return out
    before = outside()
    for col in (280, 300, 319, 320, 0x7261, 0x0300):
        et.call(cpu, "l2_print_at_320", mmu={7: sym["BankLAYER2"]}, b=97, hl=col, de=msg, c=0xFF)
    after = outside()
    changed = [n for n in before if after.get(n) != before[n]]
    check(not changed, f"pages {changed} written by text off the right edge")
    sd.close()


def test_market_boiler_entries_on_screen():
    """Every entry the market prints (MPM_boiler_count of them) is on the screen: row < 256, column < 320"""
    sd, cpu = game()
    page = cpu.page(sym["BankMenuMarket"])
    n = sym["MPM_boiler_count"]
    check(n == 22, f"MPM_boiler_count {n}")
    for k in range(n):
        a = sym["MPM_boiler_text"] - 0xC000 + 6 * k
        row, col = page[a], page[a + 1] | page[a + 2] << 8
        check(col < 320, f"entry {k}: row {row} column {col}")
    sd.close()


def test_launch_clear_of_the_station():
    """Launching puts the station StationLaunchDistance straight behind us: outside the range where it counts as close
    (StationCollisionRange, then a collision or docking) by StationLaunchMargin; the planet StationSafeZoneRange less
    that ahead, so we start in the safe zone. Then 100 loops of flight with no collision (shields and energy as they
    were) and no docking"""
    sd, cpu = game()
    press(cpu, "c_Pressed_No", 5)
    loops(cpu, 20)
    press(cpu, "c_Pressed_Launch", 1)
    for _ in range(60):
        if et.rd(cpu, "DockedFlag") == sym["StateNormal"]:
            break
        loops(cpu, 1)
    check(et.rd(cpu, "DockedFlag") == sym["StateNormal"], "not in flight")
    dist = sym["StationLaunchDistance"]
    check(dist == sym["StationCollisionRange"] + sym["StationLaunchMargin"] and 0 < sym["StationLaunchMargin"] <= 0x40,
          f"StationLaunchDistance {dist:X}")
    st = cpu.page(sym["BankUNIVDATA0"])

    def pos(page, base):
        return [page[base - 0xC000 + 3 * i] | page[base - 0xC000 + 3 * i + 1] << 8 | page[base - 0xC000 + 3 * i + 2] << 16
                for i in range(3)]
    check(et.rd(cpu, sym["UniverseSlotType"]) == sym["ShipTypeStation"], "slot 0 isn't the station")
    x, y, z = pos(st, sym["UBnKxlo"])
    check((x & 0x7FFFFF, y & 0x7FFFFF) == (0, 0) and z == 0x800000 | dist, f"station at {x:06X} {y:06X} {z:06X}")
    px, py, pz = pos(cpu.page(sym["BankPlanetData"]), sym["P_BnKxlo"])
    check((px, py, pz) == (0, 0, sym["StationSafeZoneRange"] - dist), f"planet at {px:06X} {py:06X} {pz:06X}")
    loops(cpu, 2)                                            # (UpdateSafeZone runs in the next loops in flight)
    check(et.rd(cpu, "SpaceStationSafeZone") == 0, "not in the safe zone")
    before = [et.rd(cpu, a) for a in ("ForeShield", "AftShield", "PlayerEnergy")]
    loops(cpu, 100)
    after = [et.rd(cpu, a) for a in ("ForeShield", "AftShield", "PlayerEnergy")]
    check(all(a >= b for a, b in zip(after, before)), f"shields and energy {before} -> {after}: a collision")
    check(et.rd(cpu, "DockedFlag") == sym["StateNormal"], f"left flight (DockedFlag {et.rd(cpu, 'DockedFlag'):02X})")
    sd.close()


def test_status_equipment_and_missiles():
    """The status screen: each fitted item by its own name (STAT_buffer_list once looked the name up by its count down,
    so ECM and fuel scoops came out as military lasers), in equipment order; the missile type and count filled in
    (the labels were printed with no values)"""
    sd = et.SD()
    cpu = et.machine(sd, boot="StartAttractMode")
    bank = sym["BankMenuStatus"]
    page = cpu.page(bank)

    def text(addr, n=20):
        return bytes(page[addr - 0xC000:addr - 0xC000 + n]).split(bytes(1))[0].decode()
    names = {}
    for e, name in (("EQ_ECM", "ECM System"), ("EQ_FUEL_SCOOPS", "Fuel Scoops"), ("EQ_GAL_DRIVE", "Galactic Hyperdrive"),
                    ("EQ_FRONT_PULSE", None)):
        if e in sym:
            names[sym[e]] = name
    for i in range(sym["EQ_ITEM_COUNT"]):
        et.wr(cpu, sym["EquipmentFitted"] + i, 0)
    for idx in names:
        et.wr(cpu, sym["EquipmentFitted"] + idx, 0xFF)
    et.call(cpu, "STAT_buffer_list", mmu={6: bank})
    got = [text(sym["txt_equipment_01"] + k * sym["txt_equipment_len"]) for k in range(len(names) + 1)]
    want = []
    for idx in sorted(names):
        a = et.rd(cpu, sym["EquipNameIndex"] + 2 * idx, 2)          # (the names are in main memory)
        s = ""
        while et.rd(cpu, a):
            s += chr(et.rd(cpu, a))
            a += 1
        check(names[idx] is None or s == names[idx], f"item {idx} is named {s!r} in EquipNameIndex")
        want.append(s)
    check(got == want + [""], f"listed {got}, expected {want}")
    for n, mtype in ((3, "Missile"), (0, "None")):
        et.wr(cpu, "NbrMissiles", n)
        et.call(cpu, "draw_STAT_maintext", mmu={6: bank})
        check(text(sym["txt_stat_missle_count_val"]) == str(n), f"{n} missiles: count {text(sym['txt_stat_missle_count_val'])!r}")
        check(text(sym["txt_stat_missle_type_val"]) == mtype, f"{n} missiles: type {text(sym['txt_stat_missle_type_val'])!r}")
    sd.close()


if __name__ == "__main__":
    et.main(globals())
