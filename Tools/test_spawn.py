"""Spawning (GameEngine/SpawnObject.asm, SpawnEvent in GameEngine/MainLoop.asm, SpawnShipTypeA): the game flown for
many main loops with a spawn event every few loops and ships taken away now and then, checking it stays in the main
loop with the stack where it was and the slot list and the universe banks agreeing; and the spawn handlers that the
spawn tables don't reach yet, called directly.

Found with these: SpawnTypeJunkHandler left AF on the stack when there was no room (the ret went to it as an
address), took the room test the wrong way round and counted junk that didn't spawn; SpawnHostileCop with no free
slot made whatever ship was paged in hostile; SpawnTrader was an empty label falling into SelectSpawnTableData;
SpawnShipTypeA cleared the runtime data (UnivInitRuntime) after setting the random roll and pitch, so they were lost;
UnivInitRuntime cleared 256 bytes (ld bc, then djnz on b = 0), not its 103.
"""
import elitetest as et
import nexsim
from elitetest import check, sym
import test_game_flow as gf

UNIV = sym["BankUNIVDATA0"]
NSLOTS = sym["UniverseSlotListSize"]
FREE = 0xFF


def booted():
    sd = et.SD()
    return sd, et.machine(sd, boot="StartAttractMode")


def ship_rd(cpu, slot, name, n=1):
    p = cpu.page(UNIV + slot)
    a = (sym[name] if isinstance(name, str) else name) - 0xC000
    return sum(p[a + i] << (8 * i) for i in range(n))


def slots(cpu):
    return [et.rd(cpu, sym["UniverseSlotList"] + s) for s in range(NSLOTS)]


def types(cpu):
    return [et.rd(cpu, sym["UniverseSlotType"] + s) for s in range(NSLOTS)]


def empty(cpu):
    for s in range(NSLOTS):
        et.wr(cpu, sym["UniverseSlotList"] + s, FREE)
        et.wr(cpu, sym["UniverseSlotType"] + s, FREE)


def fill(cpu, but=()):
    """every ship slot (1 on) taken, except those in but"""
    for s in range(1, NSLOTS):
        if s not in but:
            et.wr(cpu, sym["UniverseSlotList"] + s, sym["ShipID_Viper"])
            et.wr(cpu, sym["UniverseSlotType"] + s, sym["ShipTypeNormal"])


def table(cpu, name, n=8):
    return [et.rd(cpu, sym[name] + i) for i in range(n)]


def spawnable(cpu):
    """every model the spawn tables, the station and the missiles can make"""
    ids = set()
    for t in ("ShipCopTableA", "ShipNonTraderTableA", "ShipPirateTableA", "ShipBodiesTableA", "ShipJunkTableA"):
        ids |= set(table(cpu, t))
    return ids | {sym["ShipID_Missile"], sym["ShipID_Coriolis"], sym["ShipID_Dodo"]}


def bank_problems(cpu, slot):
    """what's wrong with an occupied slot's universe bank: it must say it is that slot, of that model and class"""
    bad = []
    model, kind = slots(cpu)[slot], types(cpu)[slot]
    if ship_rd(cpu, slot, "UBnKSlotNumber") != slot:
        bad.append(f"UBnKSlotNumber {ship_rd(cpu, slot, 'UBnKSlotNumber')}")
    if ship_rd(cpu, slot, "UbnKShipUnivBankNbr") != UNIV + slot:
        bad.append(f"UbnKShipUnivBankNbr {ship_rd(cpu, slot, 'UbnKShipUnivBankNbr')}")
    if ship_rd(cpu, slot, "StartOfUnivN") != ord("A") + slot:
        bad.append(f"StartOfUnivN {ship_rd(cpu, slot, 'StartOfUnivN'):02X}")
    if ship_rd(cpu, slot, "UBnKShipModelId") != model:
        bad.append(f"UBnKShipModelId {ship_rd(cpu, slot, 'UBnKShipModelId')} but the slot list has {model}")
    if ship_rd(cpu, slot, "ShipTypeAddr") != kind:
        bad.append(f"ShipTypeAddr {ship_rd(cpu, slot, 'ShipTypeAddr')} but the slot type is {kind}")
    return bad


# --- the handlers, called directly ------------------------------------------------------------------------------
def test_junk_handler():
    """SpawnTypeJunkHandler: spawns while JunkCount is under the limit (3 in the safe zone, 5 outside) and counts it;
    at the limit, or with no free slot, returns carry set with nothing spawned or counted, and the stack as it was"""
    sd, cpu = booted()
    asteroid = sym["ShipID_Asteroid"]
    for zone, limit in ((0, 3), (0xFF, 5)):
        for count in range(limit + 2):
            for full in (False, True):
                empty(cpu)
                if full:
                    fill(cpu)
                et.wr(cpu, "SpaceStationSafeZone", zone)
                et.wr(cpu, "JunkCount", count)
                sp = sym["TopOfStack"]
                et.call(cpu, "SpawnTypeJunkHandler", a=asteroid, sp=sp)
                what = f"zone {zone:02X}, JunkCount {count}, {'full' if full else 'free slots'}"
                check(cpu.sp == sp, f"{what}: the stack moved by {sp - cpu.sp}")
                made = [s for s in range(1, NSLOTS) if slots(cpu)[s] == asteroid] if not full else []
                should = count < limit and not full
                check(bool(made) == should, f"{what}: spawned {made}")
                check(et.reg(cpu, "carry") == (not should), f"{what}: carry {et.reg(cpu, 'carry')}")
                check(et.rd(cpu, "JunkCount") == count + should, f"{what}: JunkCount {et.rd(cpu, 'JunkCount')}")
    sd.close()


def test_hostile_cop():
    """SpawnHostileCop: a hostile Viper in a free slot; with no free slot nothing, and the ship paged in stays as it was
    (it was made hostile)"""
    sd, cpu = booted()
    hostile = sym["ShipIsHostile"]
    empty(cpu)
    et.call(cpu, "SpawnHostileCop")
    made = [s for s in range(NSLOTS) if slots(cpu)[s] != FREE]
    check(made == [1] and slots(cpu)[1] == sym["ShipID_Viper"], f"slots {slots(cpu)}")
    check(not et.reg(cpu, "carry"), "carry set on a spawn")
    check(ship_rd(cpu, 1, "ShipNewBitsAddr") & hostile, "the Viper isn't hostile")
    fill(cpu)
    p = cpu.page(UNIV + 3)
    a = sym["ShipNewBitsAddr"] - 0xC000
    p[a] &= ~hostile & 255
    et.call(cpu, "SpawnHostileCop", mmu={6: UNIV + 3})                  # another ship paged in
    check(et.reg(cpu, "carry"), "no carry with no free slot")
    check(not p[a] & hostile, "the ship paged in was made hostile")
    sd.close()


def test_trader():
    """SpawnTrader: a ship from the trader table (it was an empty label running into SelectSpawnTableData), with its AI on;
    carry and nothing with no free slot"""
    sd, cpu = booted()
    traders = set(table(cpu, "ShipNonTraderTableA"))
    seen = set()
    for _ in range(40):
        empty(cpu)
        et.call(cpu, "SpawnTrader")
        check(not et.reg(cpu, "carry"), "carry set on a spawn")
        made = [s for s in range(NSLOTS) if slots(cpu)[s] != FREE]
        check(made == [1] and slots(cpu)[1] in traders, f"slots {slots(cpu)}")
        check(not bank_problems(cpu, 1), f"slot 1: {bank_problems(cpu, 1)}")
        check(ship_rd(cpu, 1, "UBnkaiatkecm") & sym["ShipAIEnabled"], "AI off")
        seen.add(slots(cpu)[1])
    check(len(seen) >= 3, f"only {seen} spawned")
    fill(cpu)
    et.call(cpu, "SpawnTrader")
    check(et.reg(cpu, "carry"), "no carry with no free slot")
    sd.close()


def test_spawn_keeps_roll_and_pitch():
    """SpawnShipTypeA: the random roll and pitch UnivSetSpawnPosition sets ($6F or more, either way) survive (the runtime
    clear came after and wiped them), and UnivInitRuntime clears only its own block (it cleared 256 bytes)"""
    sd, cpu = booted()
    size = sym["UBnKRuntimeSize"]
    check(size < 256, f"UBnKRuntimeSize {size}")
    after = sym["UBnKStartOfRuntimeData"] + size - 0xC000
    for n in range(20):
        empty(cpu)
        p = cpu.page(UNIV + 1)
        for i in range(after, 0x2000 if after + 200 > 0x2000 else after + 200):
            p[i] = 0xA5
        et.call(cpu, "SpawnShipTypeA", a=sym["ShipID_Sidewinder"])
        check(not et.reg(cpu, "carry") and slots(cpu)[1] == sym["ShipID_Sidewinder"], f"not spawned: {slots(cpu)}")
        for name in ("UBnKRotXCounter", "UBnKRotZCounter"):
            v = ship_rd(cpu, 1, name)
            check(v & 0x7F >= 0x6F, f"{name} {v:02X}")
        mark = [p[after + i] for i in range(153)]
        check(all(b == 0xA5 for b in mark), f"UnivInitRuntime wrote past its block: {[hex(b) for b in mark[:16]]}...")
    sd.close()


# --- the soak ---------------------------------------------------------------------------------------------------
def test_soak():
    """The game launched and flown for 1000 main loops, a spawn event forced every 4 loops (EventCounter) and a ship
    taken away (its slot freed) every 7: the game stays in flight in the main loop, the stack pointer at MainLoop
    never moves, slot 0 holds only the station, every spawned model is one the tables can make, and every occupied
    slot's universe bank says it is that slot, model and class"""
    sd, cpu = gf.game()
    r = et.rnd(77)
    try:
        gf.press(cpu, "c_Pressed_No", 5)
        gf.loops(cpu, 20)
        gf.press(cpu, "c_Pressed_Launch")
        gf.loops(cpu, 60)                                    # the launch tunnel done
        check(et.rd(cpu, "DockedFlag") == sym["StateNormal"], f"not in flight (DockedFlag {et.rd(cpu, 'DockedFlag'):02X})")
        ok = spawnable(cpu)
        sp0 = None
        spawned = {}
        freed = 0
        before = slots(cpu)
        for n in range(1000):
            et.run_until(cpu, lambda: cpu.pc == sym["MainLoop"], f"the main loop (loop {n})", limit=200_000_000)
            if sp0 is None:
                sp0 = cpu.sp
            check(cpu.sp == sp0, f"loop {n}: the stack pointer {cpu.sp:04X}, was {sp0:04X}")
            check(et.rd(cpu, "DockedFlag") == sym["StateNormal"], f"loop {n}: out of flight (DockedFlag {et.rd(cpu, 'DockedFlag'):02X})")
            now = slots(cpu)
            ty = types(cpu)
            check(now[0] == FREE or ty[0] == sym["ShipTypeStation"], f"loop {n}: slot 0 is {now[0]} class {ty[0]}")
            for s in range(NSLOTS):
                check((now[s] == FREE) == (ty[s] == FREE), f"loop {n}: slot {s} model {now[s]} class {ty[s]}")
                if now[s] == FREE:
                    continue
                check(now[s] in ok, f"loop {n}: slot {s} holds model {now[s]:02X}, not one the tables make")
                bad = bank_problems(cpu, s)
                check(not bad, f"loop {n}: slot {s}: {bad}")
                if before[s] != now[s]:
                    spawned[now[s]] = spawned.get(now[s], 0) + 1
            for a in ("ForeShield", "AftShield", "PlayerEnergy"):     # keep us alive
                et.wr(cpu, a, 0xFF)
            if n % 4 == 0:
                et.wr(cpu, "EventCounter", 1)                # the spawn event this loop
            if n % 7 == 0:
                taken = [s for s in range(1, NSLOTS) if now[s] != FREE]
                if taken:
                    s = r.choice(taken)
                    et.wr(cpu, sym["UniverseSlotList"] + s, FREE)
                    et.wr(cpu, sym["UniverseSlotType"] + s, FREE)
                    freed += 1
            before = slots(cpu)
            cpu.stepi()
    except nexsim.Halt as e:
        raise AssertionError(f"crashed: {e}")
    total = sum(spawned.values())
    et.note(f"{total} spawns of {len(spawned)} models, {freed} slots freed, slots at the end {slots(cpu)}")
    check(total >= 100, f"only {total} spawns")
    check(len(spawned) >= 5, f"only models {sorted(spawned)}")
    sd.close()


if __name__ == "__main__":
    et.main(globals())
