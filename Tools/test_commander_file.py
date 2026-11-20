"""Commander save and load through esxDOS (FileSave / FileLoad, in
Hardware/drive_access.asm): the file the game writes at start up, a round
trip, and the error paths returning cleanly.  Replaces Tools/testwrite.asm.

The SD card is a temporary folder (elitetest.SD), so the repository's
Default.SAV is never touched.  The file routines need the ROM paged into
slots 0 and 1 (MMUSelectROMS) for rst $08; the game only saves at start up,
where it is.
"""
import os

import elitetest as et
from elitetest import check, sym

F_OPEN, F_WRITE = 0x9A, 0x9E
ROMS = {0: 0xFF, 1: 0xFF}           # rst $08 reaches esxDOS only with the ROM in slots 0 and 1 (MMUSelectROMS),
                                    # as the start up has it when it calls saveCommander


def booted():
    sd = et.SD()
    for f in os.listdir(sd.root):                   # start from no save at all
        if f.lower().endswith(".sav"):
            os.remove(sd.path(f))
    cpu = et.machine(sd, boot="StartAttractMode")
    et.page_in(cpu, 7, sym["BankCommander"])        # (CommanderMMU is slot 7)
    return sd, cpu


def save_name(cpu):
    a, s = sym["defaultSaveName"], ""
    while cpu.rd(a):
        s += chr(cpu.rd(a))
        a += 1
    return s


def saved_block(cpu):
    return bytes(cpu.rd(sym["SaveCommanderHeader"] + i) for i in range(sym["SaveSize"]))


def failing(cpu, fn_bad, code=5):
    """make esxDOS call fn_bad fail with carry and A = code"""
    orig = cpu.esx_call

    def esx():
        ret = cpu.rd16(cpu.sp)
        if cpu.rd(ret) == fn_bad:
            cpu.sp = (cpu.sp + 2) & 0xFFFF
            cpu.pc = (ret + 1) & 0xFFFF
            cpu.r[6] |= 1
            cpu.r[7] = code
            return
        orig()
    cpu.esx_call = esx


def test_start_up_save():
    """The start up (defaultCommander, saveCommander) writes the save file,
    SaveSize bytes, as the block in memory"""
    sd, cpu = booted()
    path = sd.path(save_name(cpu))
    check(os.path.exists(path), f"no {save_name(cpu)} written ({os.listdir(sd.root)})")
    data = open(path, "rb").read()
    check(len(data) == sym["SaveSize"], f"{len(data)} bytes, expected SaveSize {sym['SaveSize']}")
    check(data == saved_block(cpu), "the file isn't the save block in memory")
    sd.close()


def test_round_trip():
    """Save, change the commander, load: cash, fuel and name come back"""
    sd, cpu = booted()
    et.wr(cpu, "Cash", 1234567, 4)
    et.wr(cpu, "Fuel", 33)
    for i, ch in enumerate(b"TESTER\0\0"):
        cpu.wr(sym["CommanderName"] + i, ch)
    et.call(cpu, "saveCommander", mmu=ROMS)
    data = open(sd.path(save_name(cpu)), "rb").read()
    check(data == saved_block(cpu), "the file isn't the save block")
    et.wr(cpu, "Cash", 1, 4)
    et.wr(cpu, "Fuel", 2)
    for i, ch in enumerate(b"OTHER\0\0\0"):
        cpu.wr(sym["CommanderName"] + i, ch)
    et.call(cpu, "loadCommander", mmu=ROMS)
    name = bytes(cpu.rd(sym["CommanderName"] + i) for i in range(6))
    check(et.rd(cpu, "Cash", 4) == 1234567, f"cash {et.rd(cpu, 'Cash', 4)} after loading")
    check(et.rd(cpu, "Fuel") == 33, f"fuel {et.rd(cpu, 'Fuel')} after loading")
    check(name == b"TESTER", f"name {name} after loading")
    sd.close()


def test_errors_return_cleanly():
    """FileSave and FileLoad come back to their caller with carry set when the
    open or the write fails, or the file is missing (the stack balanced:
    call() fails if they return anywhere else)"""
    sd, cpu = booted()
    name = sym["defaultSaveName"]
    os.remove(sd.path(save_name(cpu)))
    et.call(cpu, "FileLoad", mmu=ROMS, hl=name, ix=sym["SaveCommanderHeader"], bc=sym["SaveSize"])
    check(et.reg(cpu, "carry"), "loading a missing file didn't return carry")
    for fn in (F_OPEN, F_WRITE):
        sd2, cpu2 = booted()
        failing(cpu2, fn)
        et.call(cpu2, "FileSave", mmu=ROMS, hl=name, ix=sym["SaveCommanderHeader"], bc=sym["SaveSize"])
        check(et.reg(cpu2, "carry"), f"FileSave with esxDOS call {fn:02X} failing didn't return carry")
        sd2.close()
    sd.close()


def test_load_commander_keeps_on_error():
    """loadCommander (the Load Commander Y answer, which once did nothing): carry clear and the commander loaded from a
    good save; with no save, carry set and the commander left as it was (FileLoad now sets carry on every error)"""
    sd, cpu = booted()
    et.wr(cpu, "Cash", 7654321, 4)
    et.call(cpu, "saveCommander", mmu=ROMS)
    et.wr(cpu, "Cash", 5, 4)
    et.call(cpu, "loadCommander", mmu=ROMS)
    check(not et.reg(cpu, "carry") and et.rd(cpu, "Cash", 4) == 7654321, "a good save didn't load")
    import os
    os.remove(sd.path(save_name(cpu)))
    et.wr(cpu, "Cash", 99, 4)
    et.call(cpu, "loadCommander", mmu=ROMS)
    check(et.reg(cpu, "carry"), "no carry with no save")
    check(et.rd(cpu, "Cash", 4) == 99, f"cash {et.rd(cpu, 'Cash', 4)}: the commander changed with no save")
    sd.close()


if __name__ == "__main__":
    et.main(globals())
