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


if __name__ == "__main__":
    et.main(globals())
