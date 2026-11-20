"""The attract screen (Menus/AttractMode.asm).

  * Every model's universe bank name (StartOfUnivName, copied in with the model) is its name from the ship names
    table. ShipIndexToAddress once used the table's word index as its address, so every name was copied from the
    wrong memory.
  * MANUAL_ATTRACT (a build assembled in a temporary folder, run with the 50 Hz interrupt as the game does): the
    models never cycle by themselves; F shows the next, B the previous, one model a press however long it's held,
    wrapping round all 44; the name is at the top of the HUD (character row 16, centred between the gauges, _ as a
    space, yellow on black).
"""
import os

import elitetest as et
import nexsim
import test_hardware as th
from elitetest import check, sym

NAMES_FILE = os.path.join(et.ROOT, "Data", "ShipIdEquates.asm")


def model_names():
    """{model id: name} from Data/ShipIdEquates.asm (ShipID_<name> EQU <id>)"""
    out = {}
    for line in open(NAMES_FILE, encoding="latin-1"):
        w = line.split()
        if len(w) >= 3 and w[0].startswith("ShipID_") and w[1].upper() == "EQU":
            out[int(w[2])] = w[0][7:]
    return out


def test_universe_names():
    """each model spawned: its StartOfUnivName is its name, space padded to 16"""
    with et.SD() as sd:
        cpu = et.machine(sd, boot="StartAttractMode")
        for model, name in sorted(model_names().items()):
            for s in range(sym["UniverseSlotListSize"]):
                et.wr(cpu, sym["UniverseSlotList"] + s, 0xFF)
            et.call(cpu, "SpawnShipTypeA", a=model)
            slot = next(k for k in range(12) if et.rd(cpu, sym["UniverseSlotList"] + k) != 0xFF)
            page = cpu.page(sym["BankUNIVDATA0"] + slot)
            got = bytes(page[sym["StartOfUnivName"] - 0xC000 + i] for i in range(16)).decode("latin-1")
            check(got == name[:16].ljust(16), f"model {model}: name {got!r}, expected {name!r}")


class Attract:
    """the MANUAL_ATTRACT build in the attract screen's own loop, with the interrupt"""

    def __init__(self, build, sd):
        self.b, self.sym = build, build.sym
        cpu = self.cpu = build.machine(sd, boot="StartAttractMode")
        rom = cpu.page(0xFF)                        # a font that says what was printed: row 0 = the character code
        for c in range(32, 128):
            for k in range(8):
                rom[(self.sym["charactersetaddr"] + 8 * c + k) & 0x1FFF] = c if k == 0 else 0
        nxt = [cpu.t + et.FRAME_T]

        def stepi():
            cpu.step()
            if cpu.t >= nxt[0]:
                nxt[0] += et.FRAME_T
                cpu.interrupt()
        cpu.stepi = stepi
        et.run_until(cpu, lambda: cpu.pc == self.sym["AttractModeMain"], "the attract loop")

    def frames(self, n):
        t = self.cpu.t + n * et.FRAME_T
        try:
            et.run_until(self.cpu, lambda: self.cpu.t >= t, f"{n} frames")
        except nexsim.Halt as e:
            raise AssertionError(f"crashed: {e}")

    def key(self, vk=None):
        """hold the key (Keys index vk), or let go"""
        cpu = self.cpu
        cpu.keys = set()
        if vk is not None:                          # (KeyAddrTab: in the keyboard bank, slot 7 at $E000)
            row = cpu.page(self.sym["BankKeyboard"])[self.sym["KeyAddrTab"] + vk // 5 - 0xE000]
            cpu.keys = {nexsim.KEYROWS[row][vk % 5]}

    def press(self, vk, frames=4):
        self.key(vk)
        self.frames(frames)
        self.key()
        self.frames(3)

    def shown(self):
        """(AttractShipId, universe slot 1's model id, the HUD text at row 16 columns 8-23, their attributes)"""
        cpu, s = self.cpu, self.sym
        model = cpu.page(s["BankUNIVDATA0"] + 1)[s["UBnKShipModelId"] - 0xC000]
        row = s["AttractNameRow"] - 16
        text = "".join(chr(cpu.rd(0x5000 + row * 32 + c) or 63) for c in range(8, 24))
        attrs = {cpu.rd(0x5A00 + row * 32 + c) for c in range(8, 24)}
        return cpu.rd(s["AttractShipId"]), model, text, attrs


def expected(name):
    name = name.replace("_", " ")
    pad = (16 - len(name)) // 2
    return (" " * pad + name).ljust(16)


def test_manual_attract():
    """MANUAL_ATTRACT: no auto cycling; F next and B previous, one a press, wrapping; the name on the HUD"""
    if not os.path.exists(th.SJASM):
        et.note(f"no sjasmplus ({th.SJASM}): skipped")
        return
    b = th.Build(False, defines=("MANUAL_ATTRACT",))
    names = model_names()
    try:
        with et.SD() as sd:
            g = Attract(b, sd)
            yellow = g.sym["L1ColourPaperBlack"] | g.sym["L1ColourInkYellow"]

            def at(model, what):
                sid, univ, text, attrs = g.shown()
                check(sid == model and univ == model, f"{what}: AttractShipId {sid}, universe model {univ}, expected {model}")
                check(text == expected(names[model]), f"{what}: HUD {text!r}, expected {expected(names[model])!r}")
                check(attrs == {yellow}, f"{what}: attributes {sorted(attrs)}")

            g.frames(3)
            at(0, "start")
            g.cpu.wr(g.sym["AttractTimer"], 2)              # (would end the auto cycle's wait at once)
            g.cpu.wr(g.sym["AttractTimer"] + 1, 0)
            g.frames(12)
            at(0, "no key, 12 frames")
            g.press(g.sym["VK_F"], frames=8)                # held for 8 frames: still one step
            at(1, "F")
            g.press(g.sym["VK_F"])
            at(2, "F again")
            for want in (1, 0, len(names) - 1):
                g.press(g.sym["VK_B"])
                at(want, f"B to {want}")
            g.press(g.sym["VK_F"])
            at(0, "F past the last")
            g.cpu.wr(g.sym["AttractShipId"], g.sym["ShipID_Cobra_Mk_1"])
            g.press(g.sym["VK_F"])
            at(g.sym["ShipID_Cobra_Mk_3_P"], "underscores")
            check(g.cpu.rd(g.sym["AttractRequest"]) == 0, "a request left over")
    finally:
        b.close()


if __name__ == "__main__":
    et.main(globals())
