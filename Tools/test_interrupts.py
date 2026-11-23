"""The IM2 interrupt handler (IM2Routine): the 50 Hz counters, the pause,
and that it leaves every register and the paging as it found them."""
import elitetest as et
from elitetest import check, sym

REGNAMES = ("af", "bc", "de", "hl", "ix", "iy")


def booted():
    sd = et.SD()
    return sd, et.machine(sd, boot="StartAttractMode")


def state(cpu):
    return ([et.reg(cpu, r) for r in ("bc", "de", "hl", "ix", "iy")] + [cpu.r[7], cpu.r[6] & 0xFF]
            + list(cpu.alt), list(cpu.mmu))


def test_frame_counter():
    """FrameCounter16 counts each interrupt while GamePaused is 0 and stops
    while it isn't; it wraps from $FFFF to 0; InterruptCounter always counts"""
    sd, cpu = booted()
    for paused, start, exp in ((0, 0, 1), (0, 0x00FF, 0x0100), (0, 0xFFFF, 0), (1, 1234, 1234), (0xFF, 7, 7)):
        et.wr(cpu, "GamePaused", paused)
        et.wr(cpu, "FrameCounter16", start, 2)
        ic = et.rd(cpu, "InterruptCounter")
        et.call(cpu, "IM2Routine")
        check(et.rd(cpu, "FrameCounter16", 2) == exp,
              f"paused {paused:02X}, counter {start:04X}: now {et.rd(cpu, 'FrameCounter16', 2):04X}, expected {exp:04X}")
        check(et.rd(cpu, "InterruptCounter") == (ic + 1) & 255, "InterruptCounter didn't count")
    et.wr(cpu, "GamePaused", 0)
    sd.close()


def test_handler_preserves_state():
    """Every register (main and alternate set, IX, IY) and every MMU slot
    are as they were after the handler, paused or not"""
    sd, cpu = booted()
    r = et.rnd(21)
    for paused in (0, 1, 0):
        et.wr(cpu, "GamePaused", paused)
        et.set_regs(cpu, bc=r.randrange(65536), de=r.randrange(65536), hl=r.randrange(65536),
                    ix=r.randrange(65536), iy=r.randrange(65536), a=r.randrange(256))
        cpu.r[6] = r.randrange(256)
        cpu.alt = [r.randrange(256) for _ in range(8)]
        before = state(cpu)
        et.call(cpu, "IM2Routine")
        check(state(cpu) == before, f"paused {paused}: state changed\n  before {before}\n  after  {state(cpu)}")
    et.wr(cpu, "GamePaused", 0)
    sd.close()


def call_interrupted(cpu, name, k, mmu=None, **regs):
    """call name with interrupts on and the 50 Hz interrupt raised once, after its k-th instruction (if they're on
    then); returns (instructions it took, whether the interrupt was taken)"""
    n = [0]
    taken = [False]

    def stepi():
        cpu.step()
        n[0] += 1
        if n[0] == k:
            taken[0] = cpu.interrupt()
    cpu.iff = 1
    cpu.stepi = stepi
    try:
        et.call(cpu, name, mmu=mmu, **regs)
    finally:
        cpu.stepi = cpu.step
    return n[0], taken[0]


def every_instruction(cpu, name, run, mmu=None):
    """run(k) after an interrupt at each instruction k of name in turn (the handler's own don't count: it takes
    the interrupt once); returns how many places it was taken"""
    total, _ = call_interrupted(cpu, name, 0, mmu)
    taken = 0
    for k in range(1, total + 1):
        taken += run(k)
    return taken


def test_extended_keys_survive_the_interrupt():
    """scan_keyboard reads the extended keys ($B0, $B1) by selecting the register on $243B and reading $253B; the
    handler reads MMU7 the same way. An interrupt between the two (on hardware every few minutes) read MMU7 instead,
    BankKeyboard = %01100101, as EDIT (the system map), BREAK, GRAPH and EXTEND held. With no key down, an interrupt
    at any instruction of the scan leaves every key up"""
    sd, cpu = booted()
    kb = {7: sym["BankKeyboard"]}
    cpu.keys = set()
    cpu.nextreg[0xB0] = cpu.nextreg[0xB1] = 0

    def run(k):
        et.page_in(cpu, 7, sym["BankKeyboard"])
        et.wr(cpu, "Keys", 0, 56)
        _, taken = call_interrupted(cpu, "scan_keyboard", k, kb)
        down = [i for i in range(56) if et.rd(cpu, sym["Keys"] + i)]
        check(not down, f"interrupt after instruction {k}: keys {down} down")
        return taken
    taken = every_instruction(cpu, "scan_keyboard", run, kb)
    check(taken > 100, f"the interrupt was only taken at {taken} places")
    sd.close()


def test_save_mmu6_survives_the_interrupt():
    """the SaveMMU6 routine (main code: the planet and sun tracking, the console distances) saves what's in slot 6
    whatever instruction the interrupt comes after"""
    sd, cpu = booted()
    page = sym["BankMenuSystem"]

    def run(k):
        head = et.rd(cpu, "SaveMMU6QueueHead", 2)
        _, taken = call_interrupted(cpu, "SaveMMU6", k, {6: page})
        check(et.rd(cpu, head) == page, f"interrupt after instruction {k}: saved {et.rd(cpu, head)}, slot 6 {page}")
        et.wr(cpu, "SaveMMU6QueueHead", head, 2)
        return taken
    every_instruction(cpu, "SaveMMU6", run, {6: page})
    sd.close()


def test_flip_survives_the_interrupt():
    """l2_flip_buffers swaps the shown and shadow pages (NR $12, $13) whatever instruction the interrupt comes after,
    and l2_page_shown / l2_page_shadow follow them"""
    sd, cpu = booted()
    l2 = {7: sym["BankLAYER2"]}

    def run(k):
        et.page_in(cpu, 7, sym["BankLAYER2"])
        shown, shadow = et.rd(cpu, "l2_page_shown"), et.rd(cpu, "l2_page_shadow")
        _, taken = call_interrupted(cpu, "l2_flip_buffers", k, l2)
        et.page_in(cpu, 7, sym["BankLAYER2"])
        now = (cpu.nextreg.get(0x12), cpu.nextreg.get(0x13))
        check(now == (shadow, shown), f"interrupt after instruction {k}: NR $12/$13 {now}, expected {(shadow, shown)}")
        check((et.rd(cpu, "l2_page_shown"), et.rd(cpu, "l2_page_shadow")) == now, f"after {k}: the RAM pair is out of step")
        return taken
    et.page_in(cpu, 7, sym["BankLAYER2"])
    check((et.rd(cpu, "l2_page_shown"), et.rd(cpu, "l2_page_shadow")) == (cpu.nextreg.get(0x12), cpu.nextreg.get(0x13)),
          "the RAM pair doesn't match the registers after start up")
    every_instruction(cpu, "l2_flip_buffers", run, l2)
    sd.close()


if __name__ == "__main__":
    et.main(globals())
