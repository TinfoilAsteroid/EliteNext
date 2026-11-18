"""The IM2 interrupt handler (IM2Routine): the 50 Hz counters, the pause,
and that it leaves every register and the paging as it found them."""
import elitetest as et
from elitetest import check

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


if __name__ == "__main__":
    et.main(globals())
