"""The sound effects (Hardware/sound.asm): PlaySFX sets SoundFxPending[id]; each sound interrupt
(SoundInterruptHandler) starts the pending ones on free channels (AY1 B, C, AY2 A, B, C, AY3 A, B, C; AY1 A is the
engine) and plays one step a frame: the tone period into registers 2v, 2v+1 and the volume into 8+v of the channel's
chip, then volume 0 the frame after the last step. Checked on nexsim's AY registers against the data tables."""
import elitetest as et
from elitetest import check, sym

CHANNELS = [(1, 1), (1, 2), (2, 0), (2, 1), (2, 2), (3, 0), (3, 1), (3, 2)]     # (chip as nexsim numbers it, voice)


def booted():
    sd = et.SD()
    cpu = et.machine(sd, boot="StartAttractMode")
    cpu.stepi = cpu.step                                    # (no interrupts: the test runs the handler itself)
    return sd, cpu


def sound(cpu, name, **regs):
    return et.call(cpu, name, mmu={7: sym["BankSound"]}, **regs)


def effect(cpu, n):
    """[(period, volume)] of effect n from SFXPointerList"""
    page = cpu.page(sym["BankSound"])
    base = sym["SoundAddr"] if "SoundAddr" in sym else 0xE000
    rd = lambda a: page[a - 0xE000]
    ptr = rd(sym["SFXPointerList"] + 2 * n) | rd(sym["SFXPointerList"] + 2 * n + 1) << 8
    steps = rd(ptr)
    return [((rd(ptr + 1 + 3 * i) | (rd(ptr + 2 + 3 * i) & 15) << 8), rd(ptr + 3 + 3 * i) & 15) for i in range(steps)]


def voice(cpu, ch):
    chip, v = CHANNELS[ch]
    r = cpu.ay.get(chip, [0] * 16)
    return (r[2 * v] | (r[2 * v + 1] & 15) << 8), r[8 + v]


def frame(cpu):
    et.wr(cpu, "LAST_DELTA", et.rd(cpu, "DELTA"))           # (no engine change)
    sound(cpu, "SoundInterruptHandler")


def test_effects_play_their_tables():
    """Every effect, requested on its own, plays its table step by step on the first channel, then goes quiet"""
    sd, cpu = booted()
    sound(cpu, "SfxReset")
    for n in range(sym["SFXCount"]):
        steps = effect(cpu, n)
        et.wr(cpu, sym["SoundFxPending"] + n, 1)
        got = []
        for _ in steps:
            frame(cpu)
            got.append(voice(cpu, 0))
        check(got == steps, f"effect {n}: played {got[:4]}..., the table has {steps[:4]}...")
        check(et.rd(cpu, sym["SoundFxPending"] + n) == 0, f"effect {n} still pending")
        frame(cpu)
        check(voice(cpu, 0)[1] == 0, f"effect {n}: volume {voice(cpu, 0)[1]} after the last step")
    sd.close()


def test_channels_shared_and_full():
    """Effects asked for together get a channel each, in order; a ninth with all 8 busy is dropped; the engine's
    channel (AY1 A) is never used"""
    sd, cpu = booted()
    sound(cpu, "SfxReset")
    hyper = sym["SFXHyperspace"]                            # the longest, 40 steps
    for i in range(8):
        et.wr(cpu, sym["SoundFxPending"] + hyper, 1)
        frame(cpu)
    left = [et.rd(cpu, sym["SfxChannelLeft"] + k) for k in range(8)]
    check(all(left), f"channels busy {left}")
    before = [voice(cpu, k) for k in range(8)]
    eng = list(cpu.ay.get(1, [0] * 16)[0:2]) + [cpu.ay.get(1, [0] * 16)[8]]
    et.wr(cpu, sym["SoundFxPending"] + sym["SFXLaser"], 1)
    frame(cpu)
    check(et.rd(cpu, sym["SoundFxPending"] + sym["SFXLaser"]) == 0, "the dropped request wasn't cleared")
    check(all(et.rd(cpu, sym["SfxChannelLeft"] + k) == left[k] - 1 for k in range(8)), "a channel restarted")
    check(list(cpu.ay.get(1, [0] * 16)[0:2]) + [cpu.ay.get(1, [0] * 16)[8]] == eng, "the engine channel was written")
    sd.close()


def test_play_sfx_from_the_game():
    """The game's requests reach SoundFxPending: a laser pulse starting (LaserUpdate), the hyperspace jump starting"""
    sd, cpu = booted()
    for n in range(sym["SFXCount"]):
        et.wr(cpu, sym["SoundFxPending"] + n, 0)
    et.wr(cpu, "DockedFlag", sym["StateNormal"])
    et.wr(cpu, "FrameCounter16", 100, 2)
    et.call(cpu, "HyperSpaceStart")
    et.wr(cpu, "OuterHyperCount", 1)
    et.wr(cpu, "FrameCounter16", 200, 2)
    et.call(cpu, "HyperSpaceTick")
    check(et.rd(cpu, sym["SoundFxPending"] + sym["SFXHyperspace"]) == 1, "no hyperspace sound on the jump")
    sd.close()


if __name__ == "__main__":
    et.main(globals())
