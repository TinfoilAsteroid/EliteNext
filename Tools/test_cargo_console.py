"""Cargo scooping (CanWeScoopCargoD / AddCargoTypeD, Variables/general_variablesRoutines.asm) and the console's missile
indicators (UpdateConsole .DrawMissiles, Views/ConsoleDrawing.asm).

Scooping once: added the cargo to CargoTonnes + the bay size (A, as the room check left it) rather than its own type,
so it wrote past the 17 byte array; summed only every other row of the hold (dec b with djnz); said full only when the
total was exactly the bay size; let gold / platinum / gem stones in only when 200 were already held; and never updated
CargoRunningLoad, the tonnes held that the market shows and buys against. The console with 4 missiles returned before
drawing the energy bars, and with 3 hid the third missile."""
import elitetest as et
from elitetest import check, sym
import test_game_flow as gf

NTYPES = 18                                                  # CargoTonnes (17) and AlienItemsTonnes after it


def booted():
    sd = et.SD()
    return sd, et.machine(sd, boot="StartAttractMode")


def hold(cpu, counts, bay=20, running=0):
    for i in range(NTYPES):
        et.wr(cpu, sym["CargoTonnes"] + i, counts.get(i, 0))
    et.wr(cpu, "CargoBaySize", bay)
    et.wr(cpu, "CargoRunningLoad", running)


def can_scoop(cpu, kind):
    et.call(cpu, "CanWeScoopCargoD", d=kind, a=0x55)
    return not et.reg(cpu, "carry")


def test_room_in_the_hold():
    """Tonnes: room while the total of every tonne row (food to minerals, alien items) is under the bay size, wherever
    the cargo is; kg / g items (gold, platinum, gem stones): room while under 200 of that item, whatever the hold"""
    sd, cpu = booted()
    gold, minerals, alien = sym["GoldIndex"], sym["MineralsIndex"], sym["AlienItemsIndex"]
    for row in list(range(minerals + 1)) + [alien]:            # 19 in one row, then 20
        hold(cpu, {row: 19})
        check(can_scoop(cpu, 0), f"19 in row {row} of a 20 bay: no room")
        hold(cpu, {row: 20})
        check(not can_scoop(cpu, 0), f"20 in row {row} of a 20 bay: room")
        hold(cpu, {row: 25})
        check(not can_scoop(cpu, 0), f"25 in row {row} of a 20 bay: room")
    hold(cpu, {1: 7, 2: 6, 9: 6})                               # 19 spread over rows
    check(can_scoop(cpu, 3), "19 over three rows: no room")
    hold(cpu, {1: 7, 2: 7, 9: 6})
    check(not can_scoop(cpu, 3), "20 over three rows: room")
    for kg in (gold, gold + 1, gold + 2):
        hold(cpu, {kg: 199, 1: 20})                             # (a full tonnes hold doesn't matter)
        check(can_scoop(cpu, kg), f"199 of item {kg}: no room")
        hold(cpu, {kg: 200})
        check(not can_scoop(cpu, kg), f"200 of item {kg}: room")
        hold(cpu, {kg: 0})
        check(can_scoop(cpu, kg), f"none of item {kg}: no room")
    sd.close()


def test_scooped_cargo_goes_to_its_row():
    """AddCargoTypeD: one more of that type, nothing else in the hold or after it changed; CargoRunningLoad up by one for
    tonnes (and alien items), not for kg / g"""
    sd, cpu = booted()
    for kind in range(NTYPES):
        hold(cpu, {}, bay=70, running=5)
        after = [et.rd(cpu, sym["CargoTonnes"] + NTYPES + i) for i in range(80)]
        et.call(cpu, "CanWeScoopCargoD", d=kind)                # (as the scoop code does, leaving A as it does)
        et.call(cpu, "AddCargoTypeD", d=kind, a=et.reg(cpu, "a"))
        got = [et.rd(cpu, sym["CargoTonnes"] + i) for i in range(NTYPES)]
        check(got == [1 if i == kind else 0 for i in range(NTYPES)], f"type {kind}: hold {got}")
        check([et.rd(cpu, sym["CargoTonnes"] + NTYPES + i) for i in range(80)] == after, f"type {kind}: wrote past the hold")
        tonnes = kind <= sym["MineralsIndex"] or kind == sym["AlienItemsIndex"]
        check(et.rd(cpu, "CargoRunningLoad") == 5 + tonnes, f"type {kind}: CargoRunningLoad {et.rd(cpu, 'CargoRunningLoad')}")
    sd.close()


def test_missile_indicators_and_energy_bars():
    """In flight with 0 to 4 missiles: exactly that many missile indicators shown, and the energy bars drawn every time"""
    sd, cpu = gf.game()
    gf.press(cpu, "c_Pressed_No", 5)
    gf.loops(cpu, 20)
    gf.press(cpu, "c_Pressed_Launch")
    gf.loops(cpu, 40)
    bars = {sym[n] for n in ("Draw1EnergyBar", "Draw2EnergyBars", "Draw3EnergyBars", "Draw4EnergyBars")}
    orig, hits = cpu.stepi, []

    def step():
        if cpu.pc in bars:
            hits.append(cpu.pc)
        orig()
    cpu.stepi = step
    for n in range(5):
        et.wr(cpu, "NbrMissiles", n)
        et.wr(cpu, "MissileTargettingFlag", sym["StageMissileNotTargeting"])
        hits.clear()
        gf.loops(cpu, 12)                                       # (UpdateConsole runs on console refresh loops)
        shown = [bool(cpu.spr_attr[sym[f"missile_sprite{k}"]][3] & 0x80) for k in range(1, 5)]
        check(shown == [k < n for k in range(4)], f"{n} missiles: indicators shown {shown}")
        check(hits, f"{n} missiles: no energy bars drawn")
    sd.close()


if __name__ == "__main__":
    et.main(globals())
