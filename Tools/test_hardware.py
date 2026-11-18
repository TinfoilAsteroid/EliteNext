"""The real hardware build (-DREAL_HARDWARE: DMA+ fill mode for the screen
clear and memfill_dma, Documentation/ZXNDDMA.md), assembled in a temporary
folder and run on nexsim's DMA+ model beside the normal (CSpect) build:

  * the boot leaves Layer 2 byte for byte as the normal build does;
  * l2_cls and memfill_dma fill exactly the same bytes, nothing either side;
  * the hardware build's fills really are DMA+ fill mode (no reads), and
    fill mode is off again afterwards (DMA+ settings stay until $C3, so a
    flag left on would turn the next copy into a fill);
  * the times are reported (nexsim's DMA timing is an estimate: a fill byte
    costs half a read and write; the hardware is what counts).
"""
import os
import shutil
import subprocess
import tempfile

import elitetest as et
import nexsim
from elitetest import check

SJASM = shutil.which("sjasmplus") or r"C:\CSpect\sjasmplus.exe"
COLOUR_TRANSPARENT = 0xE3


class Build:
    """a build's .nex and symbols, in a temporary folder"""

    def __init__(self, hardware):
        self.tmp = tempfile.mkdtemp(prefix="elitehw_")
        root = et.ROOT.replace("\\", "/")
        args = [SJASM, "--nologo", "--msg=war", f"-I{root}", f"--sym={self.tmp}/build.sym"]
        if hardware:
            args.append("-DREAL_HARDWARE")
        r = subprocess.run(args + [f"{root}/eliteNext.asm"], cwd=self.tmp, capture_output=True, text=True,
                           errors="replace")
        self.nex = os.path.join(self.tmp, "EliteNHW.nex" if hardware else "EliteN.nex")
        check(r.returncode == 0 and os.path.exists(self.nex),
              f"the {'hardware' if hardware else 'normal'} build failed:\n" + (r.stdout + r.stderr)[-2000:])
        self.sym = et.load_sym(os.path.join(self.tmp, "build.sym"))

    def machine(self, sd, boot=None):
        old_nex, old_sym = et.NEX, dict(et.sym)
        et.NEX = self.nex
        et.sym.clear()
        et.sym.update(self.sym)
        try:
            cpu = et.machine(sd)                    # (booted below, once the DMA is watched)
        finally:
            et.NEX = old_nex
            et.sym.clear()
            et.sym.update(old_sym)
        cpu.sym = self.sym
        runs = cpu.dma_runs = []                    # (DMA+ flags, bytes) of each transfer
        orig = cpu.dma_run

        def run():
            b0 = cpu.dma_bytes
            orig()
            runs.append((cpu.dma["ddma"], cpu.dma_bytes - b0))
        cpu.dma_run = run
        if boot:
            et.run_until(cpu, lambda: cpu.pc == self.sym[boot], boot)
            cpu.stepi = cpu.step                    # no interrupts inside call()
        return cpu

    def close(self):
        shutil.rmtree(self.tmp, ignore_errors=True)


def call(cpu, name, **regs):
    old = dict(et.sym)
    et.sym.clear()
    et.sym.update(cpu.sym)
    try:
        return et.call(cpu, name, **regs)
    finally:
        et.sym.clear()
        et.sym.update(old)


def layer2(cpu):
    return b"".join(bytes(cpu.page(cpu.nextreg.get(reg, 8) * 2 + k)) for reg in (0x12, 0x13) for k in range(6))


def builds():
    if not os.path.exists(SJASM):
        return None
    return Build(False), Build(True)


def test_boot_screens_match():
    """Booted to the attract mode, Layer 2 (both buffers) is the same"""
    b = builds()
    if not b:
        et.note(f"no sjasmplus ({SJASM}): skipped")
        return
    try:
        shots = []
        for build in b:
            with et.SD() as sd:
                cpu = build.machine(sd, boot="StartAttractMode")
                shots.append(layer2(cpu))
                if build is b[1]:
                    check(any(f & nexsim.DDMA_FILL for f, _ in cpu.dma_runs), "the hardware build never used fill mode")
        diff = sum(x != y for x, y in zip(*shots))
        check(diff == 0, f"Layer 2 differs in {diff} bytes after the boot")
    finally:
        for build in b:
            build.close()


def test_fills_match_and_are_faster():
    """l2_cls and memfill_dma: the same bytes; the hardware build in fill
    mode, and fill mode off again after each"""
    b = builds()
    if not b:
        et.note(f"no sjasmplus ({SJASM}): skipped")
        return
    try:
        results, times = [], []
        for build in b:
            with et.SD() as sd:
                cpu = build.machine(sd, boot="StartAttractMode")
                et.page_in(cpu, 7, build.sym["BankLAYER2"])
                for p in range(0, 12):                      # scribble on Layer 2 first
                    page = cpu.page(cpu.nextreg.get(0x12, 8) * 2 + p % 6) if p < 6 else \
                        cpu.page(cpu.nextreg.get(0x13, 8) * 2 + p % 6)
                    page[:] = bytes((i * 7 + p) & 255 for i in range(8192))
                cpu.dma_runs.clear()
                t_cls = call(cpu, "l2_cls")
                cls_runs = list(cpu.dma_runs)
                after_cls = layer2(cpu)
                buf = build.sym["FileBuffer"]               # 512 bytes of main memory
                for i in range(-8, 520):
                    cpu.wr(buf + i, 0x55)
                cpu.dma_runs.clear()
                t_fill = call(cpu, "memfill_dma", hl=buf + 3, de=500, a=0xA7)
                fill_runs = list(cpu.dma_runs)
                mem = bytes(cpu.rd(buf + i) for i in range(-8, 520))
                results.append((after_cls, mem))
                times.append((t_cls, t_fill))
                hw = build is b[1]
                for what, runs in (("l2_cls", cls_runs), ("memfill_dma", fill_runs)):
                    check(runs, f"{what} ran no DMA transfer")
                    fills = [f & nexsim.DDMA_FILL for f, _ in runs]
                    check(all(fills) if hw else not any(fills),
                          f"{what}: DMA+ fill mode {'not ' if hw else ''}used in the {'hardware' if hw else 'normal'} build")
                check(cpu.dma["ddma"] == 0, f"DMA+ flags left at {cpu.dma['ddma']:02X} after the fills")
        check(results[0][0] == results[1][0], "l2_cls filled Layer 2 differently")
        check(results[0][1] == results[1][1], "memfill_dma filled memory differently")
        exp = bytes([0x55] * 11 + [0xA7] * 500 + [0x55] * 17)
        check(results[1][1] == exp, "memfill_dma didn't fill exactly HL..HL+DE-1")
        check(all(v == COLOUR_TRANSPARENT for v in results[1][0][:6 * 8192]), "l2_cls left the shown screen not clear")
        (n_cls, n_fill), (h_cls, h_fill) = times
        et.note(f"l2_cls: {n_cls:,} T normal, {h_cls:,} T hardware ({100 * (h_cls - n_cls) / n_cls:+.0f}%)")
        et.note(f"memfill_dma 500 bytes: {n_fill:,} T normal, {h_fill:,} T hardware "
                f"({100 * (h_fill - n_fill) / n_fill:+.0f}%)   (nexsim's estimate)")
        check(h_cls < n_cls, "the hardware clear wasn't faster")
    finally:
        for build in b:
            build.close()


if __name__ == "__main__":
    et.main(globals())
