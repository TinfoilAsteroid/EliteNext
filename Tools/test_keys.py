"""The keyboard: scan_keyboard's key states for every key of the 8x5 matrix
(port $FE) and the Next's 16 extended keys (NextRegs $B0, $B1), and the
game controls through KeyboardMap.  Replaces keyTst.asm.

Key states: 0 up, 1 pressed this scan, 2 held.  Keys[] index: matrix row r
(in KeyAddrTab order) bit b is r * 5 + b; extended key j is 40 + j, j = 0 for
bit 7 of $B0 through j = 15 for bit 0 of $B1.
"""
import elitetest as et
import nexsim
from elitetest import check, sym

NKEYS = 56


def booted():
    sd = et.SD()
    cpu = et.machine(sd, boot="StartAttractMode")
    et.page_in(cpu, 7, sym["BankKeyboard"])
    return sd, cpu


def press(cpu, index):
    """hold the key at Keys[index] (only that one)"""
    cpu.keys = set()
    cpu.nextreg[0xB0] = cpu.nextreg[0xB1] = 0
    if index < 40:
        row = et.rd(cpu, sym["KeyAddrTab"] + index // 5)
        cpu.keys = {nexsim.KEYROWS[row][index % 5]}
    elif index is not None:
        j = index - 40
        cpu.nextreg[0xB0 + j // 8] = 0x80 >> (j % 8)


def release(cpu):
    cpu.keys = set()
    cpu.nextreg[0xB0] = cpu.nextreg[0xB1] = 0


def states(cpu):
    return [et.rd(cpu, sym["Keys"] + i) for i in range(NKEYS)]


def scan(cpu):
    et.call(cpu, "scan_keyboard")
    return states(cpu)


def test_init_clears_every_key():
    sd, cpu = booted()
    for i in range(NKEYS):
        et.wr(cpu, sym["Keys"] + i, 2)
    et.call(cpu, "init_keyboard")
    check(states(cpu) == [0] * NKEYS, f"init_keyboard left {states(cpu)}")
    sd.close()


def test_every_key():
    """each key alone: 1 on the first scan, 2 while held, 0 once let go;
    no other key changes, and the raw port readings are left alone"""
    sd, cpu = booted()
    et.call(cpu, "init_keyboard")
    for i in range(NKEYS):
        press(cpu, i)
        for want in (1, 2, 2):
            got = scan(cpu)
            exp = [0] * NKEYS
            exp[i] = want
            check(got == exp, f"key {i}: states {[(k, v) for k, v in enumerate(got) if v]}, expected {i}: {want}")
        raw = [et.rd(cpu, sym["RawKeys"] + k) for k in range(8)]
        row = None if i >= 40 else i // 5
        exp_raw = [0xFF & ~(1 << (i % 5)) if k == row else 0xFF for k in range(8)]
        check([v | 0xE0 for v in raw] == exp_raw, f"key {i}: raw rows {[f'{v:02X}' for v in raw]}")
        release(cpu)
        check(scan(cpu) == [0] * NKEYS, f"key {i} still down after letting go")
    sd.close()


def test_two_keys():
    """CAPS SHIFT with each other matrix key"""
    sd, cpu = booted()
    et.call(cpu, "init_keyboard")
    caps = nexsim.KEYROWS[0xFE][0]
    for i in range(1, 40):
        row = et.rd(cpu, sym["KeyAddrTab"] + i // 5)
        cpu.keys = {caps, nexsim.KEYROWS[row][i % 5]}
        got = scan(cpu)
        check(got[0] >= 1 and got[i] >= 1 and sum(1 for v in got if v) == 2, f"caps + key {i}: {got}")
        release(cpu)
        scan(cpu)
    sd.close()


def test_controls():
    """Every game control in KeyboardMap points at a key state, and pressing
    that key makes is_key_pressed true (z), then is_key_held true (nz)"""
    sd, cpu = booted()
    et.call(cpu, "init_keyboard")
    controls = [v for k, v in sym.items() if k.startswith("c_Pressed_")]
    check(len(controls) > 40, f"only {len(controls)} c_Pressed_ controls found")
    for c in sorted(set(controls)):
        addr = et.rd(cpu, sym["KeyboardMap"] + c, 2)
        index = addr - sym["Keys"]
        check(0 <= index < NKEYS, f"control {c // 2} maps to {addr:04X}, outside Keys")
        press(cpu, index)
        scan(cpu)
        et.call(cpu, "is_key_pressed", a=c)
        check(cpu.r[6] & 0x40, f"control {c // 2} (key {index}) not pressed after the first scan")
        scan(cpu)
        et.call(cpu, "is_key_held", a=c)
        check(not cpu.r[6] & 0x40, f"control {c // 2} (key {index}) not held after the second scan")
        release(cpu)
        scan(cpu)
    sd.close()


def test_chart_cursor_pacing():
    """ChartCursorDue (both charts' cursors): a move the first loop a cursor key is down, then one every
    ChartCursorFrames frames of FrameCounter16 however often it's called; a new press after letting go moves at once"""
    sd, cpu = booted()
    step = sym["ChartCursorFrames"]
    check(step == 5, f"ChartCursorFrames {step}, expected 5 (1/10 second)")
    et.wr(cpu, "CursorKeysPressed", 0)
    et.wr(cpu, "FrameCounter16", 1000, 2)
    et.call(cpu, "ChartCursorDue")
    check(not et.reg(cpu, "carry"), "a move with no key down")
    et.wr(cpu, "CursorKeysPressed", 0x80)
    moves = []
    for f in range(1000, 1031):
        et.wr(cpu, "FrameCounter16", f, 2)
        for _ in range(3):                                   # (called 3 times a frame: a fast menu loop)
            et.call(cpu, "ChartCursorDue")
            if et.reg(cpu, "carry"):
                check(et.reg(cpu, "a") == 0x80, "a isn't CursorKeysPressed")
                moves.append(f)
    check(moves == list(range(1000, 1031, step)), f"moves at {moves}")
    et.wr(cpu, "CursorKeysPressed", 0)
    et.call(cpu, "ChartCursorDue")
    et.wr(cpu, "CursorKeysPressed", 0x40)
    et.wr(cpu, "FrameCounter16", 1032, 2)
    et.call(cpu, "ChartCursorDue")
    check(et.reg(cpu, "carry"), "a new press didn't move at once")
    sd.close()


def test_chart_cursor_q_up_a_down():
    """On the galactic and local charts Q moves the cursor up and A down, whatever screen came before. The charts
    didn't set MenuIdMax (BBC QQ11), so MovementKeyTest read either the climb / dive pair or the cursor keys depending
    on the last screen, and the local chart's up / down handlers were the wrong way round: Q could move it down"""
    sd, cpu = booted()
    for screen, var, bank in (("ScreenGalactic", "TargetSystemX", "BankMenuGalCht"), ("ScreenLocal", "SRM_cursor_y", "BankMenuShrCht")):
        for before in (3, 0x20):                            # (InitMainLoop's 3, the equip screen's $20)
            et.wr(cpu, "MenuIdMax", before)
            et.call(cpu, "SetScreenA", a=sym[screen])
            for key, step in ((sym["VK_Q"], -1), (sym["VK_A"], 1)):
                if var == "TargetSystemX":
                    addr = sym["TargetSystemX"] + 1         # the galaxy y
                    et.wr(cpu, addr, 100)
                    page = None
                else:
                    page = cpu.page(sym[bank])
                    addr = sym["SRM_cursor_y"] - 0xC000
                    page[addr] = 100
                et.page_in(cpu, 7, sym["BankKeyboard"])
                press(cpu, key)
                scan(cpu)
                et.call(cpu, "MovementKeyTest")
                release(cpu)
                et.wr(cpu, "ChartCursorNext", 0, 2)          # a move due now
                et.wr(cpu, "FrameCounter16", 10, 2)
                et.wr(cpu, "TextInputMode", 0xFF)           # (false)
                routine = "GCM_cursors" if var == "TargetSystemX" else "SRM_cursors"
                et.call(cpu, routine, mmu={6: sym[bank]})
                y = et.rd(cpu, addr) if page is None else page[addr]
                check(y == 100 + step, f"{screen} after MenuIdMax {before:02X}: key {key} moved y to {y}, expected {100 + step}")
    sd.close()


def test_chart_cursor_limits():
    """Both charts with two cursor keys held, one axis at its limit: that axis stays, the other moves, and the stack is
    as it was. ChartCursorKeys now calls the handlers; each handler pushed AF, and at a limit the galactic chart's
    gc_BoundsLimit returned with it still pushed (the ret went to the pushed AF as an address), while the local chart's
    srm_BoundsLimit cleared A so the other key held was ignored"""
    sd, cpu = booted()
    up, down, left, right = 0x80, 0x40, 0x20, 0x10
    gal = ("GCM_cursors", "BankMenuGalCht", sym["TargetSystemX"], sym["TargetSystemX"] + 1, False)
    loc = ("SRM_cursors", "BankMenuShrCht", sym["SRM_cursor_x"], sym["SRM_cursor_y"], True)
    cases = [   # (chart, keys, x, y, expected x, expected y)
        (gal, up | left, 100, 1, 99, 1), (gal, down | right, 100, 255, 101, 255),
        (gal, up | left, 1, 100, 1, 99), (gal, down | right, 254, 100, 254, 101),
        (gal, up | right, 100, 100, 101, 99), (gal, down | left, 1, 255, 1, 255),
        (loc, up | left, 100, 8, 99, 8), (loc, down | right, 100, 168, 101, 168),
        (loc, up | left, 64, 100, 64, 99), (loc, down | right, 224, 100, 224, 101),
        (loc, down | left, 100, 100, 99, 101), (loc, up | right, 224, 8, 224, 8)]
    for (routine, bank, ax, ay, banked), keys, x, y, ex, ey in cases:
        page = cpu.page(sym[bank])

        def w(a, v):
            if banked:
                page[a - 0xC000] = v
            else:
                et.wr(cpu, a, v)

        def r(a):
            return page[a - 0xC000] if banked else et.rd(cpu, a)
        w(ax, x)
        w(ay, y)
        et.wr(cpu, "CursorKeysPressed", keys)
        et.wr(cpu, "ChartCursorNext", 0, 2)                  # a move due now
        et.wr(cpu, "FrameCounter16", 10, 2)
        et.wr(cpu, "TextInputMode", 0xFF)                   # (false)
        sp = sym["TopOfStack"]
        et.call(cpu, routine, mmu={6: sym[bank]}, sp=sp)
        what = f"{routine} keys {keys:02X} from ({x}, {y})"
        check(cpu.sp == sp, f"{what}: the stack moved by {sp - cpu.sp}")
        check((r(ax), r(ay)) == (ex, ey), f"{what}: at ({r(ax)}, {r(ay)}), expected ({ex}, {ey})")
    sd.close()


if __name__ == "__main__":
    et.main(globals())
