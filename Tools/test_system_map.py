"""The system map (Menus/system_map_menu.asm, SystemMapGather in Variables/general_variablesRoutines.asm): the extended
keyboard's EDIT key in flight shows a top down map, x across and z up (ahead up), us at the centre, the sun, planet and
station marked and labelled with their height (+/- integer units), other ships as dots (red if hostile), at a power of 2
scale that fits the sun, planet and station; redrawn twice a second, the old marks erased."""
import elitetest as et
import nexsim
from elitetest import check, sym
import test_game_flow as gf

CX, CY, R = sym["SMapCentreX"], sym["SMapCentreY"], sym["SMapRadius"]
MENU = sym["BankMenuSystem"]


def in_flight():
    sd, cpu = gf.game()
    gf.press(cpu, "c_Pressed_No", 5)
    gf.loops(cpu, 20)
    gf.press(cpu, "c_Pressed_Launch")
    gf.loops(cpu, 40)
    check(et.rd(cpu, "DockedFlag") == sym["StateNormal"], "not in flight")
    return sd, cpu


def pixel(cpu, x, y):
    a = x * 256 + y                                         # (320 x 256: column major)
    return cpu.page(cpu.nextreg.get(0x12, 8) * 2 + a // 8192)[a % 8192]


def sm(v):
    return abs(v) | (0x800000 if v < 0 else 0)


def put(page, addr, pos):
    """pos (x, y, z) in 1/256ths at addr in a bank page"""
    for i, c in enumerate(pos):
        v = sm(c)
        for k in range(3):
            page[addr - 0xC000 + 3 * i + k] = v >> (8 * k) & 255


def objects(cpu):
    out, a = [], sym["SystemMapObjects"]
    while et.rd(cpu, a):
        b = [et.rd(cpu, a + i) for i in range(10)]
        pos = []
        for i in range(3):
            v = b[1 + 3 * i] | b[2 + 3 * i] << 8 | b[3 + 3 * i] << 16
            pos.append(-(v & 0x7FFFFF) if v & 0x800000 else v)
        out.append((b[0], tuple(pos)))
        a += 10
    return out


def refresh(cpu):
    """smap_refresh, logging what it prints: [(row, column, colour, text)]"""
    printed, P, orig = [], sym["l2_print_at_320"], cpu.step

    def step():
        if cpu.pc == P:
            de, s = et.reg(cpu, "de"), ""
            while cpu.rd(de) and len(s) < 40:
                s += chr(cpu.rd(de))
                de += 1
            printed.append((et.reg(cpu, "b"), et.reg(cpu, "hl"), et.reg(cpu, "c"), s))
        orig()
    cpu.stepi = step
    et.call(cpu, "smap_refresh", mmu={6: MENU})
    cpu.stepi = orig
    # l2_print_at_320 calls itself for each next character: keep the first call of each string
    whole = []
    for p in printed:
        if whole and p[0] == whole[-1][0] and p[2] == whole[-1][2] and whole[-1][3].endswith(p[3]) and p[1] > whole[-1][1]:
            continue
        whole.append(p)
    return whole


def test_edit_opens_the_map_in_flight_only():
    """EDIT in flight shows the map (and the game flies on with the stack as it was); docked it does nothing"""
    sd, cpu = gf.game()
    try:
        gf.press(cpu, "c_Pressed_No", 5)
        gf.loops(cpu, 20)
        gf.press(cpu, "c_Pressed_SystemMap")
        check(et.rd(cpu, "ScreenIndex") != sym["ScreenSystemMap"], "the map opened while docked")
        gf.press(cpu, "c_Pressed_Launch")
        gf.loops(cpu, 40)
        sps = gf.press(cpu, "c_Pressed_SystemMap") + gf.loops(cpu, 80)
    except nexsim.Halt as e:
        raise AssertionError(f"crashed: {e}")
    check(et.rd(cpu, "ScreenIndex") == sym["ScreenSystemMap"], f"screen {et.rd(cpu, 'ScreenIndex')}, not the map")
    check(et.rd(cpu, "DockedFlag") == sym["StateNormal"], "not in flight")
    check(len(set(sps)) == 1, f"the stack moved: {sorted(set(sps))}")
    gf.press(cpu, "c_Pressed_Front")
    check(et.rd(cpu, "ScreenIndex") == sym["ScreenFront"], "the front view key doesn't leave the map")
    sd.close()


def test_gather():
    """SystemMapGather: the sun, the planet, then each occupied slot (the station as a station, a hostile ship as hostile,
    an exploding one left out) with their positions; the map's bank paged back into slot 6"""
    sd, cpu = in_flight()
    univ = sym["BankUNIVDATA0"]
    for slot, pos, hostile, exploding in ((3, (5000, -700, 9000), True, False), (5, (-300, 0, -4000), False, False),
                                          (6, (1, 2, 3), False, True)):
        p = cpu.page(univ + slot)
        put(p, sym["UBnKxlo"], pos)
        a = sym["ShipNewBitsAddr"] - 0xC000
        p[a] = (p[a] | sym["ShipIsHostile"]) if hostile else (p[a] & ~sym["ShipIsHostile"] & 255)
        p[sym["UBnKexplDsp"] - 0xC000] = 0x20 if exploding else 0
        et.wr(cpu, sym["UniverseSlotList"] + slot, sym["ShipID_Viper"])
        et.wr(cpu, sym["UniverseSlotType"] + slot, sym["ShipTypeNormal"])
    et.call(cpu, "SystemMapGather", mmu={6: univ})
    check(cpu.mmu[6] == MENU, f"slot 6 holds page {cpu.mmu[6]}, not the map's")
    got = objects(cpu)
    kinds = [k for k, _ in got]
    check(kinds[:3] == [sym["SystemMapKindSun"], sym["SystemMapKindPlanet"], sym["SystemMapKindStation"]], f"kinds {kinds}")
    check((sym["SystemMapKindHostile"], (5000, -700, 9000)) in got, f"the hostile ship: {got}")
    check((sym["SystemMapKindShip"], (-300, 0, -4000)) in got, f"the ship: {got}")
    check(not any(p == (1, 2, 3) for _, p in got), "the exploding ship was gathered")
    sd.close()


def test_marks_labels_and_scale():
    """The sun, planet and station where their x and z put them at the scale (2 ^ smap_shift units a pixel, the
    fewest halvings that fit them in SMapRadius), in their colours, labelled with + / - height; a hostile ship in red,
    one too far out left off; then after the planet moves, its old mark erased and the new one drawn"""
    sd, cpu = in_flight()
    gf.press(cpu, "c_Pressed_SystemMap")
    check(et.rd(cpu, "ScreenIndex") == sym["ScreenSystemMap"], "not on the map")
    pp = cpu.page(sym["BankPlanetData"])
    sp = cpu.page(sym["BankSunData"])
    st = cpu.page(sym["BankUNIVDATA0"])
    put(sp, sym["SBnKxlo"], (-300 * 256, 2000 * 256, 900 * 256))     # the furthest: 900 units -> shift 4 (56 pixels)
    put(pp, sym["P_BnKxlo"], (200 * 256, -45 * 256, -500 * 256))
    put(st, sym["UBnKxlo"], (16 * 256, 0, 32 * 256))
    h = cpu.page(sym["BankUNIVDATA0"] + 2)
    put(h, sym["UBnKxlo"], (-160 * 256, 0, 320 * 256))
    h[sym["ShipNewBitsAddr"] - 0xC000] |= sym["ShipIsHostile"]
    h[sym["UBnKexplDsp"] - 0xC000] = 0
    et.wr(cpu, sym["UniverseSlotList"] + 2, sym["ShipID_Viper"])
    et.wr(cpu, sym["UniverseSlotType"] + 2, sym["ShipTypeNormal"])
    far = cpu.page(sym["BankUNIVDATA0"] + 4)
    put(far, sym["UBnKxlo"], (5000 * 256, 0, 0))
    far[sym["UBnKexplDsp"] - 0xC000] = 0
    et.wr(cpu, sym["UniverseSlotList"] + 4, sym["ShipID_Viper"])
    et.wr(cpu, sym["UniverseSlotType"] + 4, sym["ShipTypeNormal"])
    printed = refresh(cpu)
    shift = cpu.page(MENU)[sym["smap_shift"] - 0xC000]
    check(shift == 4, f"smap_shift {shift}, expected 4 (900 / 16 = 56 <= {R})")
    for name, (x, z), colour in (("sun", (-300, 900), sym["L2ColourYELLOW_1"]), ("planet", (200, -500), sym["L2ColourGREEN_1"]),
                                 ("station", (16, 32), sym["L2ColourCYAN_1"]), ("hostile", (-160, 320), sym["L2ColourRED_1"])):
        px, py = CX + int(x / 16), CY - int(z / 16)
        check(pixel(cpu, px, py) == colour, f"{name}: pixel ({px}, {py}) is {pixel(cpu, px, py):02X}, expected {colour:02X}")
    check(not any(pixel(cpu, x, CY) in (sym["L2ColourWHITE_2"], sym["L2ColourRED_1"]) for x in range(CX + R + 3, 318)),
          "the far ship was drawn")
    texts = [t.strip() for _, _, c, t in printed if c]
    for want in ("SUN +2000", "PLANET -45", "STATION +0", "1 PIXEL = 16 UNITS"):
        check(want in texts, f"'{want}' not printed: {texts}")
    # the planet moves: the old mark goes, the new one appears
    old = (CX + 200 // 16, CY + 500 // 16)
    put(pp, sym["P_BnKxlo"], (-100 * 256, 0, 300 * 256))
    printed = refresh(cpu)
    check(pixel(cpu, *old) != sym["L2ColourGREEN_1"], "the planet's old mark is still there")
    new = (CX - 100 // 16, CY - 300 // 16)
    check(pixel(cpu, *new) == sym["L2ColourGREEN_1"], f"no planet mark at {new}")
    check(any(t.strip() == "PLANET +0" for _, _, c, t in printed if c), "the planet's label not redrawn")
    sd.close()


def test_redrawn_twice_a_second():
    """loop_system_map redraws (SystemMapGather) every SMapRefreshFrames frames of FrameCounter16, not every loop"""
    sd, cpu = in_flight()
    gf.press(cpu, "c_Pressed_SystemMap")
    check(et.rd(cpu, "ScreenIndex") == sym["ScreenSystemMap"], "not on the map")
    G, orig, calls = sym["SystemMapGather"], cpu.step, []

    def step():
        if cpu.pc == G:
            calls.append(et.rd(cpu, "FrameCounter16", 2))
        orig()
    cpu.stepi = step
    et.wr(cpu, "FrameCounter16", 1000, 2)
    cpu.page(MENU)[sym["smap_next_refresh"] - 0xC000:sym["smap_next_refresh"] - 0xC000 + 2] = (1000).to_bytes(2, "little")
    for f in range(1000, 1101):
        et.wr(cpu, "FrameCounter16", f, 2)
        for _ in range(3):
            et.call(cpu, "loop_system_map", mmu={6: MENU})
    step_ = sym["SMapRefreshFrames"]
    check(calls == list(range(1000, 1101, step_)), f"redrawn at {calls}, expected every {step_} frames")
    sd.close()


if __name__ == "__main__":
    et.main(globals())
