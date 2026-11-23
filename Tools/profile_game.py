"""Per routine T-state profile of the game in flight, on the emulator (Tools/nexsim.py's Profiler).

The game is booted, launched and given ships: spawn events (EventCounter) until --ships ship slots are taken,
each ship then moved ahead of us (z $600 to $1800, within the view) so it's drawn, not just a dot far off. Then
--loops main loops are flown (shields and energy kept up) and every instruction's T-states counted at its address,
by 8K page so banked code that shares addresses is kept apart. The labels come from build.bat's SLD files
(eliteN.sld / EliteNHW.sld): each address counts to the nearest label at or below it in its page, local labels
(Routine.local) folded into their routine.

  self      T-states in the routine's own instructions, per 50 Hz frame, and its share of the frame (560,000 T at
            28 MHz); DMA time counts to the instruction that started the transfer
  incl      from each call until its return, callees included, interrupts not (they're "(interrupt)")
  calls     CALL / RST to the routine per frame (a jp to it isn't counted), and incl T per call

usage: python Tools/profile_game.py [--loops N] [--ships N] [--top N] [--build regular|hardware] [--sort self|incl]
                                    [--no-ahead] [--seed N] [--lines ROUTINE ...]
  --lines ROUTINE   also each source line of ROUTINE by T-states (repeatable)
"""
import argparse
import bisect
import collections
import os
import sys
import time

def parse_args(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--loops", type=int, default=300, help="main loops to profile (default 300)")
    ap.add_argument("--ships", type=int, default=6, help="ships to have about (default 6)")
    ap.add_argument("--top", type=int, default=40, help="routines to list (default 40)")
    ap.add_argument("--build", choices=("regular", "hardware"), default="regular")
    ap.add_argument("--sort", choices=("self", "incl"), default="self")
    ap.add_argument("--no-ahead", action="store_true", help="leave the ships where they spawn")
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--lines", action="append", default=[], metavar="ROUTINE")
    return ap.parse_args(argv)


args = parse_args() if __name__ == "__main__" else parse_args([])   # (imported, e.g. by test_profile.py: defaults)
if __name__ == "__main__":
    os.environ["ELITE_BUILD"] = args.build  # (before elitetest picks the build)

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import elitetest as et                      # noqa: E402
import nexsim                               # noqa: E402
import test_game_flow as gf                 # noqa: E402
from elitetest import sym                   # noqa: E402

SLD = {"regular": "eliteN.sld", "hardware": "EliteNHW.sld"}[args.build]
FRAME_T = et.FRAME_T
FREE = 0xFF


# --- symbols ---------------------------------------------------------------------------------------------------
class Labels:
    """the SLD's labels (type F) by page, and its source lines (type T) by page and address. alias: pages that hold a
    copy of another's code ({copy: original}), labelled as the original"""

    def __init__(self, path, alias=None):
        self.alias = alias or {}
        self.by_page = collections.defaultdict(list)
        self.lines = {}
        with open(path, encoding="latin-1") as f:
            for row in f:
                p = row.rstrip("\r\n").split("|")
                if len(p) < 8 or p[6] not in "FT" or not p[6]:
                    continue
                try:
                    page, addr = int(p[4]), int(p[5])
                except ValueError:
                    continue
                if page < 0:
                    continue
                if p[6] == "F":
                    self.by_page[page].append((addr, p[7]))
                else:
                    self.lines.setdefault((page, addr), (p[0], int(p[1].split(":")[0])))
        self.addrs = {}
        for page, lst in self.by_page.items():
            lst.sort()
            self.addrs[page] = [a for a, _ in lst]

    def label(self, key):
        """the full label at or below a page << 16 | address key, and its address"""
        page, addr = self.page(key), key & 0xFFFF
        a = self.addrs.get(page)
        if a:
            i = bisect.bisect_right(a, addr) - 1
            if i >= 0:
                return self.by_page[page][i][1], self.by_page[page][i][0]
        return f"?{page}:{addr:04X}", addr

    def page(self, key):
        return self.alias.get(key >> 16, key >> 16)

    def routine(self, key):
        name, _ = self.label(key)
        return name.split(".")[0]

    def line(self, key):
        """the source line (file, line) of the instruction at key, or None"""
        return self.lines.get((self.page(key), key & 0xFFFF))


def page_names():
    """page number -> Bank name, for the report"""
    out = {}
    for k, v in sym.items():
        if k.startswith("Bank") and isinstance(v, int) and v < 224:
            out.setdefault(v, k)
    return out


# --- the run -----------------------------------------------------------------------------------------------------
def universe_wr(cpu, slot, name, v, n=1):
    """write a universe bank variable (a name or an address in slot 6) of a ship slot without paging it in"""
    p = cpu.page(sym["BankUNIVDATA0"] + slot)
    a = (sym[name] if isinstance(name, str) else name) - 0xC000
    for i in range(n):
        p[a + i] = v >> (8 * i) & 255


def sm24(v):
    return abs(v) | (0x800000 if v < 0 else 0)


def occupied(cpu):
    return [s for s in range(1, sym["UniverseSlotListSize"]) if et.rd(cpu, sym["UniverseSlotList"] + s) != FREE
            and et.rd(cpu, sym["UniverseSlotType"] + s) != sym["ShipTypeStation"]]


def keep_alive(cpu):
    for a in ("ForeShield", "AftShield", "PlayerEnergy"):
        et.wr(cpu, a, 0xFF)


def setup(cpu):
    """launched, ships about; returns the occupied slots"""
    gf.press(cpu, "c_Pressed_No", 5)
    gf.loops(cpu, 20)
    gf.press(cpu, "c_Pressed_Launch")
    gf.loops(cpu, 60)                                   # the launch tunnel done
    if et.rd(cpu, "DockedFlag") != sym["StateNormal"]:
        raise SystemExit(f"not in flight after the launch (DockedFlag {et.rd(cpu, 'DockedFlag'):02X})")
    for _ in range(400):
        if len(occupied(cpu)) >= args.ships:
            break
        et.wr(cpu, "EventCounter", 1)                   # a spawn event this loop
        keep_alive(cpu)
        gf.loops(cpu, 1)
    ships = occupied(cpu)
    if not args.no_ahead:
        r = et.rnd(args.seed)
        for s in ships:
            z = r.randrange(0x600, 0x1800)
            for i, c in enumerate((r.randrange(-z // 6, z // 6), r.randrange(-z // 8, z // 8), z)):
                universe_wr(cpu, s, sym["UBnKxlo"] + 3 * i, sm24(c), 3)     # x, y, z: lo, hi, sign
    return ships


def run():
    sd, cpu = gf.game()
    try:
        ships = setup(cpu)
        models = [et.rd(cpu, sym["UniverseSlotList"] + s) for s in ships]
        et.run_until(cpu, lambda: cpu.pc == sym["MainLoop"], "the main loop", limit=200_000_000)
        prof = nexsim.Profiler(cpu)
        t0, wall = cpu.t, time.time()
        ships_seen = []
        for n in range(args.loops):
            cpu.stepi()
            et.run_until(cpu, lambda: cpu.pc == sym["MainLoop"], f"the main loop (loop {n})", limit=200_000_000)
            keep_alive(cpu)
            ships_seen.append(len(occupied(cpu)))
        prof.detach()
        return prof, cpu.t - t0, time.time() - wall, ships, models, ships_seen, cpu
    except nexsim.Halt as e:
        raise SystemExit(f"crashed: {e}")
    finally:
        sd.close()


# --- the report --------------------------------------------------------------------------------------------------
def report(prof, total_t, wall, ships, models, ships_seen, cpu):
    univ = sym["BankUNIVDATA0"]                             # each ship slot's universe bank: a copy of bank 0's code
    labels = Labels(os.path.join(et.ROOT, SLD), {univ + s: univ for s in range(1, sym["UniverseSlotListSize"] + 1)})
    banks = page_names()
    frames = total_t / FRAME_T
    self_r, incl_r, calls_r, page_r = collections.Counter(), collections.Counter(), collections.Counter(), {}
    for key, t in prof.self_t.items():
        r = labels.routine(key)
        self_r[r] += t
        page_r.setdefault(r, labels.page(key))
    for key, t in prof.incl_t.items():
        incl_r[labels.routine(key)] += t
    for key, n in prof.calls.items():
        calls_r[labels.routine(key)] += n
    incl_r["(interrupt)"] = prof.int_t
    calls_r["(interrupt)"] = prof.ints
    self_total = sum(self_r.values())

    print(f"{args.build} build, {args.loops} main loops in flight: {total_t:,} T = {frames:.1f} frames of "
          f"{FRAME_T:,} T, {total_t / args.loops:,.0f} T a main loop ({50 * FRAME_T * args.loops / total_t:.1f} main loops "
          f"a second)")
    print(f"ships: {len(ships)} at the start (models {models}), {min(ships_seen)} to {max(ships_seen)} during; "
          f"{'moved ahead' if not args.no_ahead else 'where they spawned'}. "
          f"{prof.steps:,} instructions in {wall:.0f}s")
    print(f"interrupts: {prof.ints} taking {prof.int_t / frames:,.0f} T a frame ({100 * prof.int_t / total_t:.1f}%)")
    print()
    rows = (self_r if args.sort == "self" else incl_r).most_common(args.top)
    print(f"{'routine':34} {'bank':18} {'self T/frame':>12} {'%':>6} {'incl T/frame':>13} {'%':>6} "
          f"{'calls/frame':>11} {'incl T/call':>11}")
    for name, _ in rows:
        s, i, c = self_r.get(name, 0), incl_r.get(name, 0), calls_r.get(name, 0)
        page = page_r.get(name)
        bank = "main" if page in (4, 5, 10, 11) else "BankUNIVDATA0-12" if page == univ else             banks.get(page, f"page {page}") if page is not None else ""
        if c:
            called = f"{i / frames:13,.0f} {100 * i / total_t:6.2f} {c / frames:11.2f} {i / c:11,.0f}"
        else:                                           # only reached by a jp or falling in
            called = f"{'-':>13} {'':6} {'-':>11} {'-':>11}"
        print(f"{name[:34]:34} {bank[:18]:18} {s / frames:12,.0f} {100 * s / total_t:6.2f} {called}")
    shown = sum(self_r.get(n, 0) for n, _ in rows)
    print(f"{'(the rest)':34} {'':18} {(self_total - shown) / frames:12,.0f} {100 * (self_total - shown) / total_t:6.2f}")

    for want in args.lines:
        keys = [k for k in prof.self_t if labels.routine(k) == want]
        if not keys:
            print(f"\n{want}: no instructions run")
            continue
        by_line = collections.Counter()
        for k in keys:
            ln = labels.line(k) or ("?", k & 0xFFFF)
            by_line[ln] += prof.self_t[k]
        tot = sum(by_line.values())
        print(f"\n{want}: {tot / frames:,.0f} T a frame, by source line")
        src_cache = {}
        for (f, ln), t in sorted(by_line.items(), key=lambda kv: (kv[0][0], kv[0][1])):
            if f not in src_cache:
                try:
                    src_cache[f] = open(os.path.join(et.ROOT, f), encoding="latin-1").read().splitlines()
                except OSError:
                    src_cache[f] = []
            text = src_cache[f][ln - 1].strip() if 0 < ln <= len(src_cache[f]) else ""
            print(f"  {f}:{ln:<5} {t / frames:10,.0f} {100 * t / tot:5.1f}%  {text[:90]}")


if __name__ == "__main__":
    if not os.path.exists(os.path.join(et.ROOT, SLD)):
        raise SystemExit(f"no {SLD}: build first (build.bat)")
    report(*run())
