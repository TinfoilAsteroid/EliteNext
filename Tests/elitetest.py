"""Shared helpers for the emulator tests (Tests/test_*.py).

Each test file runs on its own (python Tests/test_maths.py [test name...]) or
from Tests/run_tests.py, which runs them all at once.  A test is a function
test_NAME() that raises AssertionError (check()) when it fails; main() runs a
file's tests and prints PASS or FAIL for each.

The game runs on Tools/nexsim.py (the Z80N emulator, from ZPolice) from the
built EliteN.nex and its symbols, eliteN.sym (sjasmplus --sym, written by
elitebuild.bat).  The SD card is a temporary folder holding copies of the
files the game reads, so a test never writes to the repository (the boot
saves Default.SAV).

Routines are called directly: call() sets the registers, pages any banks in,
pushes a return address that is never code (RET) and steps until it comes
back.  Banked routines share addresses, so the bank has to be paged in by
the test (mmu={slot: page}) unless the routine pages it in itself.
"""
import glob
import os
import random
import re
import shutil
import sys
import tempfile
import time
import traceback

TESTS = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(TESTS)
NEX = os.path.join(ROOT, "EliteN.nex")
SYMFILE = os.path.join(ROOT, "eliteN.sym")
sys.path.insert(0, os.path.join(ROOT, "Tools"))
import nexsim  # noqa: E402

FRAME_T = 28_000_000 // 50          # T-states per 50 Hz frame at 28 MHz
RET = 0x5BFE                        # return address for call(): the printer buffer, never code
REGS = "BCDEHLFA"                   # nexsim's register order (cpu.r)


def load_sym(path=SYMFILE):
    sym = {}
    if not os.path.exists(path):
        return sym
    for line in open(path):
        m = re.match(r"([\w.]+):\s+EQU\s+0x([0-9A-F]+)", line)
        if m:
            sym[m.group(1)] = int(m.group(2), 16)
    return sym


sym = load_sym()


# --- the machine ------------------------------------------------------------
class SD:
    """A temporary SD card: copies of the files beside EliteN.nex that the
    game reads (sprites, saves)."""

    def __init__(self):
        self.root = tempfile.mkdtemp(prefix="elitetest_")
        for pat in ("*.dat", "*.DAT", "*.SAV", "*.sav"):
            for f in glob.glob(os.path.join(ROOT, pat)):
                shutil.copy(f, self.root)

    def path(self, name):
        return os.path.join(self.root, name)

    def close(self):
        shutil.rmtree(self.root, ignore_errors=True)

    def __enter__(self):
        return self

    def __exit__(self, *a):
        self.close()


def machine(sd, boot=None, interrupts=True):
    """A Next with EliteN.nex loaded, the SD card sd.  boot: a label to run
    the start-up code to (e.g. "StartAttractMode"), with the 50 Hz interrupt
    raised if interrupts.  cpu.stepi steps one instruction."""
    cpu = nexsim.Cpu()
    cpu.esx_root = sd.root
    nexsim.load_nex(cpu, NEX)
    if interrupts:
        nxt = [cpu.t + FRAME_T]

        def stepi():
            cpu.step()
            if cpu.t >= nxt[0]:
                nxt[0] += FRAME_T
                cpu.interrupt()
        cpu.stepi = stepi
    else:
        cpu.stepi = cpu.step
    if boot:
        run_until(cpu, lambda: cpu.pc == sym[boot], boot)
        cpu.stepi = cpu.step            # no interrupts inside call()
    return cpu


def run_until(cpu, cond, what, limit=400_000_000):
    """Step until cond(); fail if it takes over limit T-states."""
    t0 = cpu.t
    while not cond():
        cpu.stepi()
        if cpu.t - t0 > limit:
            raise AssertionError(f"stuck waiting for {what}: pc {cpu.pc:04X}, mmu {cpu.mmu}")


def page_in(cpu, slot, page):
    cpu.set_nextreg(0x50 + slot, page)


def set_regs(cpu, **regs):
    """a=, b=, ..., bc=, de=, hl=, ix=, iy=, sp=, carry=True/False"""
    for k, v in regs.items():
        if k == "carry":
            cpu.r[6] = (cpu.r[6] & ~1) | (1 if v else 0)
        elif k in ("ix", "iy", "sp"):
            setattr(cpu, k, v & 0xFFFF)
        elif k in ("bc", "de", "hl", "af"):
            cpu.r[REGS.index(k[0].upper())] = v >> 8 & 255
            cpu.r[REGS.index(k[1].upper())] = v & 255
        else:
            cpu.r[REGS.index(k.upper())] = v & 255


def reg(cpu, name):
    if name in ("ix", "iy", "sp", "pc"):
        return getattr(cpu, name)
    if name == "carry":
        return cpu.r[6] & 1
    if len(name) == 2:
        return cpu.r[REGS.index(name[0].upper())] << 8 | cpu.r[REGS.index(name[1].upper())]
    return cpu.r[REGS.index(name.upper())]


def call(cpu, name, mmu=None, limit=50_000_000, **regs):
    """Call the routine at sym[name] (or an address); return the T-states it
    took.  mmu: {slot: page} paged in first."""
    for slot, page in (mmu or {}).items():
        page_in(cpu, slot, page)
    set_regs(cpu, **regs)
    if "sp" not in regs:
        cpu.sp = sym["TopOfStack"]
    cpu.push(RET)
    cpu.pc = sym[name] if isinstance(name, str) else name
    t0 = cpu.t
    while cpu.pc != RET:
        cpu.stepi()
        if cpu.t - t0 > limit:
            raise AssertionError(f"{name} didn't return: pc {cpu.pc:04X}")
    return cpu.t - t0


# --- memory and number formats ----------------------------------------------
def rd(cpu, a, n=1):
    """n bytes little endian at a (or sym name)"""
    a = sym[a] if isinstance(a, str) else a
    return sum(cpu.rd((a + i) & 0xFFFF) << (8 * i) for i in range(n))


def wr(cpu, a, v, n=1):
    a = sym[a] if isinstance(a, str) else a
    for i in range(n):
        cpu.wr((a + i) & 0xFFFF, v >> (8 * i) & 255)


def s158(v):
    """S15.8 lead sign (sign byte bit 7, 23 bit magnitude) from a signed
    integer in 1/256ths: (lo, hi, sign) as a 24 bit int, lo first"""
    m = abs(v)
    assert m < 1 << 23
    return m | (0x800000 if v < 0 else 0)


def from_s158(b):
    m = b & 0x7FFFFF
    return -m if b & 0x800000 else m


def wr_s158(cpu, a, v):
    wr(cpu, a, s158(v), 3)


def rd_s158(cpu, a):
    return from_s158(rd(cpu, a, 3))


def rnd(seed):
    """A seeded random generator, so a failure can be repeated"""
    return random.Random(seed)


# --- reporting ----------------------------------------------------------------
def check(cond, msg):
    if not cond:
        raise AssertionError(msg)


def note(msg):
    """A line of detail under the test's PASS or FAIL."""
    print("      " + msg, flush=True)


def main(module_globals):
    """Run the file's test_* functions (or those named on the command line).
    Exit code 1 if any fails."""
    tests = [(k, v) for k, v in module_globals.items() if k.startswith("test_") and callable(v)]
    want = [a for a in sys.argv[1:] if not a.startswith("-")]
    if want:
        tests = [(k, v) for k, v in tests if k in want or k[5:] in want]
    file = os.path.basename(module_globals.get("__file__", "?"))
    if not sym:
        print(f"FAIL {file}: no {os.path.basename(SYMFILE)}, build first (elitebuild.bat)")
        sys.exit(1)
    bad = 0
    for name, fn in tests:
        t0 = time.time()
        try:
            fn()
            print(f"PASS {file} {name} ({time.time() - t0:.1f}s)", flush=True)
        except AssertionError as e:
            bad += 1
            print(f"FAIL {file} {name}: {e}", flush=True)
        except Exception:
            bad += 1
            print(f"FAIL {file} {name}: error", flush=True)
            traceback.print_exc(file=sys.stdout)
    sys.exit(1 if bad else 0)
