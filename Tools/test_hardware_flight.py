"""Flight on the real hardware build (DMA+ fill mode for the screen clears), watching the double buffering. On a Next
the flip once read the page registers back (GetNextReg) and an interrupt between the select and the read gave it
MMU7's bank instead: a frame of noise on screen, or from then on drawing into that bank, flickering. The game launched
and flown for 500 main loops in the front view; on every one:

  * varL2_BUFFER_MODE is on (8): drawing goes to the shadow page;
  * Layer 2 is never mapped for writes to the page on screen (NR $12: $123B write enable, bit 3 clear);
  * exactly one flip (NR $12 written once);
  * NR $12 and $13 are the two pages, different, and l2_page_shown / l2_page_shadow match them.
"""
import collections

import elitetest as et
import nexsim
import test_game_flow as gf
from elitetest import check, sym

ELITE_BUILD = "hardware"
LOOPS = 500


def l2var(cpu, name):
    return cpu.page(sym["BankLAYER2"])[sym[name] - sym["LAYER2Addr"]]


def test_double_buffered_flight():
    check(et.BUILD == "hardware", f"running on the {et.BUILD} build")
    sd, cpu = gf.game()
    views = range(sym["ScreenFront"], sym["ScreenRight"] + 1)
    pages = {sym["LAYER2_SCREEN_BANK1"], sym["LAYER2_SHADOW_BANK1"]}
    flips = [0]
    visible = collections.Counter()
    port_out, set_nextreg = cpu.port_out, cpu.set_nextreg

    def watch_port(port, v):
        if port == 0x123B and not v & 0x10 and v & 1 and not v & 8 and cpu.rd(sym["ScreenIndex"]) in views:
            visible[cpu.pc] += 1
        return port_out(port, v)

    def watch_nextreg(reg, val):
        if reg == 0x12:
            flips[0] += 1
        return set_nextreg(reg, val)
    try:
        gf.press(cpu, "c_Pressed_No", 5)
        gf.loops(cpu, 20)
        gf.press(cpu, "c_Pressed_Launch")
        gf.loops(cpu, 60)                                   # the launch tunnel done
        cpu.port_out, cpu.set_nextreg = watch_port, watch_nextreg
        et.run_until(cpu, lambda: cpu.pc == sym["MainLoop"], "the main loop", limit=200_000_000)
        cpu.stepi()
        for n in range(LOOPS):
            flips[0] = 0
            et.run_until(cpu, lambda: cpu.pc == sym["MainLoop"], f"the main loop (loop {n})", limit=200_000_000)
            si = cpu.rd(sym["ScreenIndex"])
            check(si == sym["ScreenFront"], f"loop {n}: on screen {si}, not the front view")
            check(et.rd(cpu, "DockedFlag") == sym["StateNormal"], f"loop {n}: out of flight")
            check(l2var(cpu, "varL2_BUFFER_MODE") == 8, f"loop {n}: double buffering off")
            check(not visible, f"loop {n}: Layer 2 mapped for writes to the page on screen at {sorted(visible)}")
            check(flips[0] == 1, f"loop {n}: {flips[0]} flips")
            regs = (cpu.nextreg.get(0x12), cpu.nextreg.get(0x13))
            check(set(regs) == pages, f"loop {n}: NR $12/$13 {regs}")
            ram = (l2var(cpu, "l2_page_shown"), l2var(cpu, "l2_page_shadow"))
            check(ram == regs, f"loop {n}: l2_page_shown/shadow {ram}, NR $12/$13 {regs}")
            for a in ("ForeShield", "AftShield", "PlayerEnergy"):     # keep us alive
                et.wr(cpu, a, 0xFF)
            cpu.stepi()
    except nexsim.Halt as e:
        raise AssertionError(f"crashed: {e}")
    finally:
        sd.close()


if __name__ == "__main__":
    et.main(globals())
