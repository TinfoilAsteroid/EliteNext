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


def test_AequAdivQmul96ABS():
    """A = A / D * 96 (unsigned, A < D else 96), the compass's TIS2: 0 to 2 under for every A < D. The 9 bit
    remainder's carry was once dropped, so with D over 128 it could be anything (67 / 137 gave 1, not 46)"""
    sd, cpu = machine()
    for d in range(1, 256):
        for a in sorted({0, 1, d - 1, d, d // 2, d // 3} | set(range(0, d, 9))):
            et.call(cpu, "AequAdivQmul96ABS", a=a, d=d)
            got = et.reg(cpu, "a")
            exp = 96 if a >= d else 96 * a / d
            check(got == 96 if a >= d else 0 <= exp - got < 2, f"{a} / {d} * 96: got {got}, expected {exp:.2f}")
    sd.close()


def test_asm_sqrt():
    """HL = floor(sqrt(DE)), exhaustive over 16 bits in steps"""
    sd, cpu = machine()
    for de in list(range(0, 1024)) + list(range(1024, 65536, 37)) + [65535, 65025, 65024]:
        et.call(cpu, "asm_sqrt", de=de)
        check(et.reg(cpu, "hl") == math.isqrt(de), f"sqrt {de}: got {et.reg(cpu, 'hl')}, expected {math.isqrt(de)}")
    sd.close()


def test_mul24():
    """mul24: BCDE.HL = BH.L * CD.E unsigned (B, C 7 bit), the full 9
    multiply path and the leading zero ones (BH = 0, CD = 0, B = C = 0); the
    carries into bytes 4 and 5 were once doubled rather than added.
    mul24Signed: lead sign, DE.H = the S15.8 product with D's bit 7 the sign"""
    sd, cpu = machine()
    r = et.rnd(8)
    shapes = (lambda: r.randrange(1 << 23), lambda: r.randrange(256), lambda: r.randrange(1 << 16),
              lambda: r.randrange(256) << 16, lambda: 0x7FFFFF, lambda: 0)
    for n in range(3000):
        x, y = r.choice(shapes)(), r.choice(shapes)()
        et.call(cpu, "mul24", b=x >> 16, hl=x, c=y >> 16, de=y)
        got = et.reg(cpu, "bc") << 32 | et.reg(cpu, "de") << 16 | et.reg(cpu, "hl")
        check(got == x * y, f"mul24 {x:06X} * {y:06X}: got {got:012X}, expected {x * y:012X}")
    for n in range(1500):
        x = r.randrange(1, 128) * r.choice((-1, 1))                 # as ApplyMyRollAndPitchIX: alpha / 256
        y = r.choice(shapes)() * r.choice((-1, 1)) >> r.randrange(0, 8)
        if n % 3 == 0:
            x = r.randrange(-(1 << 20), 1 << 20)
        exp = abs(x) * abs(y) >> 8
        if exp > 0x7FFFFF or not y or abs(y) > 0x7FFFFF:
            continue
        bx, cy = sm(x, 24), sm(y, 24)
        et.call(cpu, "mul24Signed", b=bx >> 16, hl=bx, c=cy >> 16, de=cy)
        got = et.reg(cpu, "de") << 8 | et.reg(cpu, "h")
        check(got == sm(exp if (x < 0) == (y < 0) else -exp, 24) or (exp == 0 and got & 0x7FFFFF == 0),
              f"mul24Signed {x} * {y}: got {unsm(got, 24)} ({got:06X}), expected {exp}")
    sd.close()


def test_mul16():
    """mul16: DE.HL = DE * HL, all 16 bits (mul24's 8.8 x 8.8 path)"""
    sd, cpu = machine()
    r = et.rnd(9)
    for x, y in [(0xFFFF, 0xFFFF), (0x8000, 0x8000), (0, 0x1234)] + \
                [(r.randrange(65536), r.randrange(65536)) for _ in range(2000)]:
        et.call(cpu, "mul16", hl=x, de=y)
        got = et.reg(cpu, "de") << 16 | et.reg(cpu, "hl")
        check(got == x * y, f"mul16 {x:04X} * {y:04X}: got {got:08X}, expected {x * y:08X}")
    sd.close()


def test_UnivDistanceToTarget():
    """carry set when TacticsVector (ship - body, S15.8 lo, hi, sign per
    axis) is inside the station safe zone cube: every sign byte 0 or $80,
    every hi byte < $C0"""
    sd, cpu = machine()
    r = et.rnd(10)
    for n in range(1500):
        v = [r.choice((r.randrange(0xC000), r.randrange(0xB800, 0xC800), r.randrange(1 << 23)))
             * r.choice((-1, 1)) for _ in range(3)]
        for i, c in enumerate(v):
            et.wr_s158(cpu, sym["TacticsVectorX"] + 4 * i, c)   # (3 bytes then a pad byte)
        et.call(cpu, "UnivDistanceToTarget", mmu=MATHS)
        exp = all(abs(c) < 0xC000 for c in v)
        check(et.reg(cpu, "carry") == exp, f"{[hex(c) for c in v]}: carry {et.reg(cpu, 'carry')}")
    sd.close()


def test_XX12ProcessOneRow():
    """XX12ProcessOneRow (XX12EquNodeDotOrientation's rows): HL, sign A =
    sum over x, y, z of |scaled| * |row| / 256 each truncated, signed by
    scaled sign xor row sign (|scaled| < 256 as the nodes are, |row| < 128)"""
    sd, cpu = machine()
    r = et.rnd(11)
    row = sym["UbnkTransInvRow0x0"]
    for n in range(1500):
        xs = [r.randrange(-255, 256) for _ in range(3)]
        ms = [r.randrange(-127, 128) for _ in range(3)]
        for i, (x, m) in enumerate(zip(xs, ms)):
            et.wr(cpu, sym[("UBnkXScaled", "UBnkYScaled", "UBnkZScaled")[i]], sm(x, 16), 2)
            et.wr(cpu, row + 2 * i, abs(m))
            et.wr(cpu, row + 2 * i + 1, 0x80 if m < 0 else 0)
        et.call(cpu, "XX12ProcessOneRow", mmu=MATHS, hl=row)   # (ADDHLDESignBC is banked)
        exp = sum((abs(x) * abs(m) >> 8) * (-1 if (x < 0) != (m < 0) else 1) for x, m in zip(xs, ms))
        a, hl = et.reg(cpu, "a"), et.reg(cpu, "hl")
        got = -hl if a & 0x80 else hl
        check(got == exp, f"{xs} . {ms}: got {got} (sign {a:02X} {hl:04X}), expected {exp}")
    sd.close()


def test_s78_multiplies():
    """The S7.8 multiplies in MathsFPS78/asm_multiply_S78.asm:
    HLequDEmulHL      HL = DE * HL (16 bit result)
    HLeqyHLmulAdiv256 HL = HL * A / 256, the 6502 shift and add (0 to 6 low)
    HLequHLmulDEu     H.L = H.L * D.E, bits 8-23 of the product (H once came
                      back as bits 8-15 too)
    (AequAmulQdiv256u is now the AequAmulCdiv256u macro, used inline)"""
    sd, cpu = machine()
    r = et.rnd(5)
    for _ in range(800):
        de, hl = r.randrange(0, 256), r.randrange(0, 256)
        if r.random() < 0.5:
            de, hl = r.randrange(0, 4096), r.randrange(0, 16)
        et.call(cpu, "HLequDEmulHL", de=de, hl=hl)
        check(et.reg(cpu, "hl") == de * hl & 0xFFFF, f"HLequDEmulHL {de} * {hl}: got {et.reg(cpu, 'hl')}")
    for _ in range(800):
        hl, a = r.randrange(65536), r.randrange(256)
        et.call(cpu, "HLeqyHLmulAdiv256", hl=hl, a=a)
        got, exp = et.reg(cpu, "hl"), hl * a >> 8
        check(0 <= exp - got <= 6, f"HLeqyHLmulAdiv256 {hl} * {a} / 256: got {got}, expected {exp}")
    for n in range(1500):
        hl, de = r.randrange(65536), r.randrange(65536)
        if n % 2:
            hl, de = r.randrange(256), r.randrange(128)  # as XX12EquNodeDotOrientation: D = 0, |x| < 256
        et.call(cpu, "HLequHLmulDEu", hl=hl, de=de)
        got, exp = et.reg(cpu, "hl"), (hl * de >> 8) & 0xFFFF
        check(got == exp, f"HLequHLmulDEu {hl:04X} * {de:04X}: got {got:04X}, expected {exp:04X}")
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
