"""The maths routines, called directly with random and edge case inputs and
checked against Python models.

Number formats (lead sign, not two's complement):
  S15.8  3 bytes lo, hi, sign: sign byte bit 7 the sign, bits 0-6 and hi the
         15 bit integer, lo the fraction (positions, AHLequBHLplusCDE)
  S7.8   2 bytes, h bit 7 the sign (HLequHLplusDE)
  S7     1 byte, bit 7 the sign (normalised vectors)
Overflow is not detected by the adds: cases that would overflow are left out
here and covered by the saturating wrappers in test_missile.py.
"""
import math

import elitetest as et
from elitetest import check, sym

MATHS = {0: sym["BankMathsBankedFns"]}          # the banked maths functions live in slot 0
SM24 = 0x7FFFFF


def sm(v, bits):
    """lead sign value of a signed int: magnitude | sign bit"""
    return abs(v) | ((1 << (bits - 1)) if v < 0 else 0)


def unsm(v, bits):
    m = v & ((1 << (bits - 1)) - 1)
    return -m if v >> (bits - 1) & 1 else m


def machine():
    sd = et.SD()
    return sd, et.machine(sd)


def test_AHLequBHLplusCDE():
    """AHL = BHL + CDE, S15.8; the result is never -0"""
    sd, cpu = machine()
    r = et.rnd(1)
    cases = [(0, 0), (1, -1), (-1, 1), (0x7FFFFF // 2, 0x7FFFFF // 2), (-5, -7), (0x10000, -0x10000),
             (0x123456, -0x123457), (-0x100, 0x100)]
    cases += [(r.randrange(-SM24, SM24 + 1) >> r.randrange(0, 22), r.randrange(-SM24, SM24 + 1) >> r.randrange(0, 22))
              for _ in range(1500)]
    for x, y in cases:
        if abs(x + y) > SM24:
            continue                        # same sign overflow: not detected (see MissileVectorAdd)
        bx, cy = sm(x, 24), sm(y, 24)
        et.call(cpu, "AHLequBHLplusCDE", mmu=MATHS, b=bx >> 16, hl=bx & 0xFFFF, c=cy >> 16, de=cy & 0xFFFF)
        got = et.reg(cpu, "a") << 16 | et.reg(cpu, "hl")
        check(got == sm(x + y, 24), f"{x} + {y}: got {unsm(got, 24)} ({got:06X}), expected {x + y}")
    sd.close()


def test_AddBCHtoDELsigned():
    """DEL = DEL + BCH, S15.8 (d, b the sign bytes; e, c hi; l, h lo)"""
    sd, cpu = machine()
    r = et.rnd(2)
    cases = [(0, 0), (5, -5), (-0x8000, 0x7FFF), (0x400000, -1)]
    cases += [(r.randrange(-SM24, SM24 + 1) >> r.randrange(0, 22), r.randrange(-SM24, SM24 + 1) >> r.randrange(0, 22))
              for _ in range(1500)]
    for x, y in cases:
        if abs(x + y) > SM24:
            continue
        dx, by = sm(x, 24), sm(y, 24)
        et.call(cpu, "AddBCHtoDELsigned", mmu=MATHS, d=dx >> 16, e=dx >> 8, l=dx, b=by >> 16, c=by >> 8, h=by)
        got = et.reg(cpu, "d") << 16 | et.reg(cpu, "e") << 8 | et.reg(cpu, "l")
        exp = x + y
        check(unsm(got, 24) == exp and (exp != 0 or got == 0),
              f"{x} + {y}: got {unsm(got, 24)} ({got:06X}), expected {exp}")
    sd.close()


def test_HLequHLplusDE():
    """HL = HL + DE, S7.8; never -0"""
    sd, cpu = machine()
    r = et.rnd(3)
    for _ in range(1500):
        x, y = r.randrange(-0x7FFF, 0x8000), r.randrange(-0x7FFF, 0x8000)
        if abs(x + y) > 0x7FFF:
            continue
        et.call(cpu, "HLequHLplusDE", mmu=MATHS, hl=sm(x, 16), de=sm(y, 16))
        got = et.reg(cpu, "hl")
        check(got == sm(x + y, 16), f"{x} + {y}: got {unsm(got, 16)} ({got:04X}), expected {x + y}")
    sd.close()


def test_ADDHLDESignBC():
    """AHL = BHL + CDE with 16 bit magnitudes and sign bytes B, C (sign only);
    a zero result may come back as -0"""
    sd, cpu = machine()
    r = et.rnd(4)
    for _ in range(1500):
        x, y = r.randrange(-0xFFFF, 0x10000), r.randrange(-0xFFFF, 0x10000)
        if abs(x + y) > 0xFFFF:
            continue
        et.call(cpu, "ADDHLDESignBC", mmu=MATHS, b=0x80 if x < 0 else 0, hl=abs(x),
                c=0x80 if y < 0 else 0, de=abs(y))
        a, hl = et.reg(cpu, "a"), et.reg(cpu, "hl")
        got = -hl if a & 0x80 else hl
        check(got == x + y and a & 0x7F == 0, f"{x} + {y}: got sign {a:02X} {hl:04X}, expected {x + y}")
    sd.close()


def test_AequAdivDmul967Bit():
    """A = A / D * 96 (S7 A, unsigned D, |A| <= D as normalising uses it):
    up to 2 under 96 |A| / D for D < 128; for D >= 128 (A and D halved first)
    up to 3 under or 1 over,
    sign kept.  D = 128 once returned 0 (the 'sla a : ret z' divide by 0 test)"""
    sd, cpu = machine()
    for d in range(1, 256):
        for am in sorted({0, 1, d // 3, d // 2, min(d, 127)} | set(range(0, min(d, 127) + 1, 7))):
            for sign in (0, 0x80):
                et.call(cpu, "AequAdivDmul967Bit", a=am | sign, d=d)
                got = et.reg(cpu, "a")
                exp = 96 if am >= d else 96 * am / d
                lo, hi = (0, 2) if d < 128 else (-1, 3)     # (D >= 128 halves A and D first: up to 0.7 over)
                check(lo < exp - (got & 0x7F) < hi or exp == got & 0x7F,
                      f"{am} / {d} * 96: got {got & 0x7F}, expected {exp:.2f}")
                if got & 0x7F:
                    check(got & 0x80 == sign, f"{am} / {d} * 96: sign {got & 0x80:02X}, expected {sign:02X}")
    et.call(cpu, "AequAdivDmul967Bit", a=64, d=128)
    check(et.reg(cpu, "a") == 48, f"64 / 128 * 96 gave {et.reg(cpu, 'a')} (the D = 128 bug)")
    sd.close()


def test_asm_sqrt():
    """HL = floor(sqrt(DE)), exhaustive over 16 bits in steps"""
    sd, cpu = machine()
    for de in list(range(0, 1024)) + list(range(1024, 65536, 37)) + [65535, 65025, 65024]:
        et.call(cpu, "asm_sqrt", de=de)
        check(et.reg(cpu, "hl") == math.isqrt(de), f"sqrt {de}: got {et.reg(cpu, 'hl')}, expected {math.isqrt(de)}")
    sd.close()


def test_s78_multiplies():
    """The S7.8 multiplies in MathsFPS78/asm_multiply_S78.asm:
    HLequDEmulHL      HL = DE * HL (16 bit result)
    AequAmulQdiv256u  A = A * Q / 256
    HLeqyHLmulAdiv256 HL = HL * A / 256, the 6502 shift and add (0 to 6 low)
    HLequHLmulDEu     only H is right: H = bits 8-15 of HL * DE, which is what
                      XX12EquNodeDotOrientation (its only caller) uses"""
    sd, cpu = machine()
    r = et.rnd(5)
    for _ in range(800):
        de, hl = r.randrange(0, 256), r.randrange(0, 256)
        if r.random() < 0.5:
            de, hl = r.randrange(0, 4096), r.randrange(0, 16)
        et.call(cpu, "HLequDEmulHL", de=de, hl=hl)
        check(et.reg(cpu, "hl") == de * hl & 0xFFFF, f"HLequDEmulHL {de} * {hl}: got {et.reg(cpu, 'hl')}")
    for _ in range(800):
        a, q = r.randrange(256), r.randrange(256)
        et.wr(cpu, "varQ", q)
        et.call(cpu, "AequAmulQdiv256u", a=a)
        check(et.reg(cpu, "a") == a * q >> 8, f"AequAmulQdiv256u {a} * {q}: got {et.reg(cpu, 'a')}")
    for _ in range(800):
        hl, a = r.randrange(65536), r.randrange(256)
        et.call(cpu, "HLeqyHLmulAdiv256", hl=hl, a=a)
        got, exp = et.reg(cpu, "hl"), hl * a >> 8
        check(0 <= exp - got <= 6, f"HLeqyHLmulAdiv256 {hl} * {a} / 256: got {got}, expected {exp}")
    for _ in range(800):
        hl, e = r.randrange(256), r.randrange(128)      # as XX12EquNodeDotOrientation: D = 0, |x| < 256
        et.call(cpu, "HLequHLmulDEu", hl=hl, de=e)
        check(et.reg(cpu, "h") == (hl * e >> 8) & 255, f"HLequHLmulDEu {hl} * {e}: H {et.reg(cpu, 'h')}")
    sd.close()


def test_NormalizeTactics():
    """TacticsVector (S15.8 per axis) scaled to a unit vector of length 96 in
    S7: each component up to 3.5 under or 1.5 over 96 v / |v|, the sign kept,
    hi bytes 0 and the sign bytes sign only.  (Worst seen: 3.1 under, as the
    7 bit scale, the divide's halving and its 3/8 step all truncate; the
    length is rounded down, so the largest can come out 1 over.)  Covers
    vectors that use the sign byte's integer bits (the 24 bit pre-scale)"""
    sd, cpu = machine()
    r = et.rnd(6)
    for n in range(600):
        big = 1 << r.choice((9, 12, 16, 20, 22))
        v = [r.randrange(-big, big) for _ in range(3)]
        if max(abs(c) for c in v) < 256:
            v[r.randrange(3)] = r.choice((-1, 1)) * r.randrange(256, big + 256)  # as used: |d| >= 1.0 on an axis
        for i, c in enumerate(v):
            et.wr_s158(cpu, sym["TacticsVectorX"] + 4 * i, c)   # (3 bytes then a pad byte)
        et.call(cpu, "NormalizeTactics", mmu=MATHS)
        length = math.sqrt(sum(c * c for c in v))
        for i, c in enumerate(v):
            a = sym["TacticsVectorX"] + 4 * i
            lo, hi, sg = et.rd(cpu, a), et.rd(cpu, a + 1), et.rd(cpu, a + 2)
            exp = 96 * abs(c) / length
            check(hi == 0 and sg & 0x7F == 0, f"{v}: axis {i} bytes {lo:02X} {hi:02X} {sg:02X}")
            check(-1.5 < exp - lo < 3.5, f"{v}: axis {i} = {lo}, expected {exp:.1f}")
            if lo:
                check((sg & 0x80) == (0x80 if c < 0 else 0), f"{v}: axis {i} sign {sg:02X}")
    sd.close()


def test_ShiftTacticsAxis24Right():
    """Halves an S15.8 magnitude in place, keeping the sign"""
    sd, cpu = machine()
    r = et.rnd(7)
    a = sym["TacticsVectorX"]
    for _ in range(500):
        v = r.randrange(-SM24, SM24 + 1)
        et.wr_s158(cpu, a, v)
        et.call(cpu, "ShiftTacticsAxis24Right", mmu=MATHS, hl=a + 2)
        got = et.rd(cpu, a, 3)
        exp = sm(abs(v) >> 1, 24) | (0x800000 if v < 0 else 0)
        check(got == exp, f"{v} / 2: got {got:06X}, expected {exp:06X}")
    sd.close()


if __name__ == "__main__":
    et.main(globals())
