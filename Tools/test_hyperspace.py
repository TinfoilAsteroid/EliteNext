"""The hyperspace countdown (GameEngine/HyperSpaceTimers.asm, Tables/message_queue.asm, Views/Front_View.asm): timed by
FrameCounter16, one second (50 frames) a count, shown from HyperSpaceSeconds down to 1 with the number as it is now,
the jump when it reaches 0; H again cancels it and the text is then cleared; docking stops it; the text is redrawn
every loop."""
import elitetest as et
from elitetest import check, sym
import test_keys as tk

FPS = 50
NOT_FORCED = 0xFF


def booted():
    sd = et.SD()
    return sd, et.machine(sd, boot="StartAttractMode")


def in_flight(cpu, frame=1000):
    et.wr(cpu, "DockedFlag", sym["StateNormal"])
    et.wr(cpu, "ScreenTransitionForced", NOT_FORCED)
    et.wr(cpu, "FrameCounter16", frame, 2)


def counting(cpu):
    return et.rd(cpu, "InnerHyperCount") != 0


def test_seconds_from_the_frame_counter():
    """A count each 50 frames whatever the loop rate (ticks called every frame, or only every 7th), the jump (the
    hyperspace screen forced) after HyperSpaceSeconds seconds, and nothing while FrameCounter16 stands still (paused)"""
    sd, cpu = booted()
    secs = sym["HyperSpaceSeconds"]
    for step in (1, 7):
        start = 1000 if step == 1 else 65536 - 300          # (the second run crosses FrameCounter16's wrap)
        in_flight(cpu, start)
        et.call(cpu, "HyperSpaceStart")
        check(counting(cpu) and et.rd(cpu, "OuterHyperCount") == secs, "HyperSpaceStart")
        seen = {}
        for f in range(start, start + (secs + 2) * FPS, step):
            et.wr(cpu, "FrameCounter16", f & 0xFFFF, 2)
            et.call(cpu, "HyperSpaceTick")
            if et.rd(cpu, "ScreenTransitionForced") != NOT_FORCED:
                break
            seen.setdefault(et.rd(cpu, "OuterHyperCount"), f - start)
        jumped = f - start
        check(et.rd(cpu, "ScreenTransitionForced") == sym["ScreenHyperspace"], f"step {step}: no jump")
        check(secs * FPS <= jumped < secs * FPS + step, f"step {step}: jumped after {jumped} frames, expected {secs * FPS}")
        for n in range(secs - 1, 0, -1):
            first = seen.get(n)
            check(first is not None and (secs - n) * FPS <= first < (secs - n) * FPS + step,
                  f"step {step}: {n} first seen at frame {first}, expected {(secs - n) * FPS}")
        check(not counting(cpu), "still counting after the jump")
    in_flight(cpu, 5000)
    et.call(cpu, "HyperSpaceStart")
    for _ in range(500):                                     # paused: FrameCounter16 doesn't move
        et.call(cpu, "HyperSpaceTick")
    check(et.rd(cpu, "OuterHyperCount") == secs, "counted while the frame counter stood still")
    et.wr(cpu, "DockedFlag", sym["StateHJumping"])           # not in flight (docking, launching): stops
    et.call(cpu, "HyperSpaceTick")
    check(not counting(cpu), "still counting when not in flight")
    sd.close()


def charging(cpu):
    """the countdown's second line as built for printing (nexsim has no ROM, so the font, and Layer 1's text, are blank)"""
    a = sym["Hyp_centeredCharging"]
    out = ""
    while et.rd(cpu, a + len(out)):
        out += chr(et.rd(cpu, a + len(out)))
    return out


def attrs(cpu):
    """the attributes of character rows 12 and 13, the countdown's two lines"""
    return bytes(cpu.page(10)[0x1800 + 12 * 32 + i] for i in range(64))


def test_text_shows_the_count_now_and_clears():
    """HyperSpaceMessage shows the seconds left now (not the last second's), without leading zeros, every loop, yellow
    on black; once stopped it clears the two lines (black on black) and HyperTextOnScreen"""
    sd, cpu = booted()
    in_flight(cpu)
    et.call(cpu, "HyperSpaceStart")
    yellow = sym["L1ColourPaperBlack"] | sym["L1ColourInkYellow"]
    for n in (11, 10, 7, 1):
        et.wr(cpu, "OuterHyperCount", n)
        et.call(cpu, "HyperSpaceMessage")
        check(charging(cpu).strip() == f"Charging:{n:3d}", f"{n}: shows '{charging(cpu)}'")
        check(attrs(cpu) == bytes([yellow] * 64), f"{n}: attributes {attrs(cpu)[:4].hex()}")
    check(et.rd(cpu, "HyperTextOnScreen"), "HyperTextOnScreen not set")
    et.call(cpu, "HyperSpaceCancel")
    et.call(cpu, "HyperSpaceMessage")
    check(attrs(cpu) == bytes(64), f"attributes {attrs(cpu)[:4].hex()} after stopping, not black on black")
    check(not et.rd(cpu, "HyperTextOnScreen"), "HyperTextOnScreen still set")
    sd.close()


def test_h_cancels():
    """In the front view H during the countdown cancels it (it once went to a label that did nothing); H with no
    target (the present system) doesn't start one"""
    sd, cpu = booted()
    in_flight(cpu)
    et.page_in(cpu, 7, sym["BankKeyboard"])
    h = et.rd(cpu, sym["KeyboardMap"] + sym["c_Pressed_Hyperspace"], 2) - sym["Keys"]

    def press_h():
        et.page_in(cpu, 7, sym["BankKeyboard"])
        tk.press(cpu, h)
        tk.scan(cpu)
        et.call(cpu, "input_front_view", mmu={6: sym["BankFrontView"]})
        tk.release(cpu)
        et.page_in(cpu, 7, sym["BankKeyboard"])
        tk.scan(cpu)
    et.call(cpu, "HyperSpaceStart")
    press_h()
    check(not counting(cpu), "H didn't cancel the countdown")
    et.wr(cpu, "TargetSystemX", et.rd(cpu, "PresentSystemX", 2), 2)
    press_h()
    check(not counting(cpu), "H with the present system as the target started a countdown")
    sd.close()


def test_jump_animation_timing():
    """hyperspace_Lightning (the lightning and the growing hole, once a main loop while jumping): timed by
    FrameCounter16 from draw_hyperspace's start, HyperJumpFrames (22, twice the ~11 frames it took going by loops) long
    however many loops a frame; the hole's radius 2 + 62 * frames / HyperJumpFrames, a step of 2 to 3 every frame (it
    was 2 a loop, so 6 a frame at 3 loops a frame); the lightning drawn once a frame"""
    sd, cpu = booted()
    frames = sym["HyperJumpFrames"]
    check(frames == 22, f"HyperJumpFrames {frames}")
    et.wr(cpu, "HyperJumpStart", 1000, 2)
    et.wr(cpu, "HyperLastFrame", 999, 2)
    mm = {6: sym["BankFrontView"]}
    radii = []
    for f in range(1000, 1000 + frames + 2):
        et.wr(cpu, "FrameCounter16", f, 2)
        for loop in range(3):                                # 3 loops a frame
            et.call(cpu, "hyperspace_Lightning", mmu=mm)
            running = et.reg(cpu, "carry")
            check(bool(running) == (f - 1000 < frames), f"frame {f - 1000}: carry {running}")
            if running:
                check(et.rd(cpu, "HyperLastFrame", 2) == f, f"frame {f - 1000}: lightning not drawn this frame")
                if loop == 0:
                    radii.append(et.rd(cpu, "HyperCircle"))
    exp = [2 + (n * sym["HyperRadiusStep"] >> 8) for n in range(frames)]
    check(radii == exp, f"radii {radii}, expected {exp}")
    steps = [b - a for a, b in zip(radii, radii[1:])]
    check(all(2 <= d <= 3 for d in steps) and radii[-1] >= 60, f"steps {steps}, last radius {radii[-1]}")
    sd.close()


if __name__ == "__main__":
    et.main(globals())
