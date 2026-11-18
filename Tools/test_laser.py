"""The laser (LaserUpdate, GameEngine/MainLoop.asm): pulses, bursts, rest and beams timed in 50 Hz frames of
FrameCounter16, checked update by update against a Python model, across the counter's wrap, with frames passing 0
(paused) to 12 (past LaserMaxFrames) at a time.  And the basic laser's timeline in frames."""
import elitetest as et
from elitetest import check, sym

READY, ON, OFF, REST = 0, 1, 2, 3
TRUE, FALSE = 0, 0xFF                               # the game's flags (SetMemTrue / SetMemFalse)
MAX_FRAMES = 8


class Model:
    """LaserUpdate in Python"""

    def __init__(self, laser, now, energy, temp):
        self.rate, self.on, self.off, self.rest, self.damage, self.drain, self.heat = laser
        self.state, self.end, self.burst, self.last = READY, 0, 0, now
        self.energy, self.temp = energy, temp
        self.beam, self.hit = 0, 0

    def update(self, now, held):
        dt = min((now - self.last) & 0xFFFF, MAX_FRAMES)
        self.last, self.now, self.hit = now, now, 0
        running = lambda: (now - self.end) & 0x8000                     # noqa: E731

        def set_state(s, frames):
            self.state, self.end = s, (now + frames) & 0xFFFF

        go = None                                   # 'fire' or 'idle'
        if self.state == ON:
            if self.rate == 0:
                go = 'fire' if held else 'rest'
            elif running():
                go = 'fire'
            else:
                self.burst = (self.burst - 1) & 255
                if self.burst == 0:
                    go = 'rest'
                else:
                    set_state(OFF, self.off)
                    go = 'idle'
        elif self.state == OFF:
            go = 'idle' if running() else 'pulse'
        elif self.state == REST:
            if running():
                go = 'idle'
            else:
                self.state = READY
        if self.state == READY and go is None:
            if held:
                self.burst = self.rate
                go = 'pulse'
            else:
                go = 'idle'
        if go == 'pulse':
            set_state(ON, self.on)
            if self.rate:
                self.hit = self.damage
            go = 'fire'
        if go == 'rest':
            set_state(REST, self.rest)
            go = 'idle'
        if go == 'idle':
            self.beam = 0
            for _ in range(dt):
                self.temp = max(0, self.temp - 1)
        else:
            self.beam = 1
            if self.rate == 0:
                self.hit = min(255, self.damage * dt)
            for _ in range(dt):
                self.energy = max(0, self.energy - self.drain)
                self.temp = min(255, self.temp + self.heat)


def setup(cpu, laser, now, energy=200, temp=0):
    rate, on, off, rest, damage, drain, heat = laser
    for name, v in (("CurrLaserType", 0), ("CurrLaserDamage", 0), ("CurrLaserPulseRate", rate),
                    ("CurrLaserPulseOnTime", on), ("CurrLaserPulseOffTime", off), ("CurrLaserPulseRest", rest),
                    ("CurrLaserDamageOutput", damage), ("CurrLaserEnergyDrain", drain), ("CurrLaserHeat", heat),
                    ("PlayerEnergy", energy), ("GunTemperature", temp)):
        et.wr(cpu, name, v)
    et.wr(cpu, "FrameCounter16", now, 2)
    et.call(cpu, "LaserReset")


def update(cpu, now, held):
    et.wr(cpu, "FrameCounter16", now & 0xFFFF, 2)
    et.wr(cpu, "LaserFireHeld", TRUE if held else FALSE)
    et.call(cpu, "LaserUpdate")
    check(et.rd(cpu, "LaserFireHeld") == FALSE, "LaserUpdate didn't clear LaserFireHeld")
    return (et.rd(cpu, "LaserState"), et.rd(cpu, "LaserBeamOn") == TRUE, et.rd(cpu, "LaserHitDamage"),
            et.rd(cpu, "PlayerEnergy"), et.rd(cpu, "GunTemperature"))


LASERS = {                                          # rate, on, off, rest, damage, drain, heat (the LaserStatsTable rows)
    "basic": (2, 5, 32, 64, 3, 16, 2), "pulse": (1, 8, 8, 32, 3, 16, 8), "burst": (3, 6, 6, 58, 3, 5, 2),
    "gatling": (1, 5, 5, 1, 2, 4, 5), "beam rate 1": (1, 1, 0, 0, 3, 3, 16), "beam rate 0": (0, 1, 0, 6, 5, 5, 5),
    "mining": (1, 32, 48, 96, 3, 2, 2),
}


def test_against_the_model():
    sd = et.SD()
    cpu = et.machine(sd, boot="StartAttractMode")
    r = et.rnd(51)
    for name, laser in LASERS.items():
        for start in (0, 0xFFC0, 1000):             # (0xFFC0: the counter wraps during the run)
            setup(cpu, laser, start)
            m = Model(laser, start, 200, 0)
            now, held = start, False
            for step in range(300):
                now += r.choice((0, 1, 1, 1, 1, 2, 3, 12))
                if r.random() < 0.08:
                    held = not held
                got = update(cpu, now, held)
                m.update(now & 0xFFFF, held)
                exp = (m.state, bool(m.beam), m.hit, m.energy, m.temp)
                check(got == exp, f"{name} from {start:04X}, update {step} at {now & 0xFFFF:04X} held {held}: "
                                  f"(state, on, hit, energy, temp) {got}, expected {exp}")
    sd.close()


def test_basic_laser_timeline():
    """Fire held, one update a frame: 5 frames on, 32 off, 5 on, 64 rest, then the next burst; damage once a
    pulse, as it starts"""
    sd = et.SD()
    cpu = et.machine(sd, boot="StartAttractMode")
    setup(cpu, LASERS["basic"], 0)
    on, hits = [], []
    for f in range(0, 120):
        state, beam, hit, *_ = update(cpu, f, True)
        on.append(beam)
        if hit:
            hits.append(f)
    exp = [f < 5 or 37 <= f < 42 or 106 <= f < 111 for f in range(120)]
    check(on == exp, f"on frames {[f for f, b in enumerate(on) if b]}")
    check(hits == [0, 37, 106], f"hits at frames {hits}")
    sd.close()


if __name__ == "__main__":
    et.main(globals())
