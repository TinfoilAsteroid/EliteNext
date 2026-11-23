"""The T-state profiler (nexsim.Profiler) and Tools/profile_game.py's labels:

  * self T-states add up to exactly what the call took;
  * a CALL is counted at its target and its inclusive time runs to its RET (HLequHLmulDEu calls fixedS78_mulu once);
  * an interrupt in the middle goes to the handler's time, not the routine's inclusive time, and back;
  * the labels from the SLD: main memory, a banked routine by its page (PolyEdge in BankLAYER2), local labels
    folded into their routine, and a ship slot's universe bank labelled as bank 0's (they hold copies of its code).
"""
import os
import subprocess
import sys

import elitetest as et
import nexsim
from elitetest import check, sym


def booted():
    sd = et.SD()
    return sd, et.machine(sd, boot="StartAttractMode")


def key(cpu, name):
    a = sym[name]
    return cpu.mmu[a >> 13] << 16 | a


def test_self_time_adds_up():
    """profiling HLequHLmulDEu: the self T-states sum to the call's T-states, one call of fixedS78_mulu, and its
    inclusive time is the whole call less HLequHLmulDEu's own instructions"""
    sd, cpu = booted()
    prof = nexsim.Profiler(cpu)
    t = et.call(cpu, "HLequHLmulDEu", hl=0x1234, de=0x0567)
    prof.detach()
    check(sum(prof.self_t.values()) == t, f"self T {sum(prof.self_t.values())}, the call took {t}")
    k = key(cpu, "fixedS78_mulu")
    check(prof.calls == {k: 1}, f"calls {prof.calls}")
    own = sum(v for a, v in prof.self_t.items() if (a & 0xFFFF) < sym["fixedS78_mulu"])
    exp = t - own + 17                              # from the start of the CALL (17 T) to its RET
    check(prof.incl_t.get(k) == exp, f"fixedS78_mulu inclusive {prof.incl_t.get(k)}, expected {exp} (the whole call "
          f"less HLequHLmulDEu's own {own} T, but with its CALL)")
    check(prof.frames == [], f"frames left: {prof.frames}")
    sd.close()


def test_interrupt_kept_apart():
    """an interrupt inside fixedS78_mulu: its time is the handler's (ints, int_t), fixedS78_mulu's inclusive time
    the same as without it"""
    sd, cpu = booted()
    prof = nexsim.Profiler(cpu)
    et.call(cpu, "HLequHLmulDEu", hl=0x1234, de=0x0567)
    plain = prof.incl_t[key(cpu, "fixedS78_mulu")]
    prof.detach()
    prof = nexsim.Profiler(cpu)
    n = [0]

    def stepi():
        cpu.step()
        n[0] += 1
        if n[0] == 6:
            check(cpu.interrupt(), "the interrupt wasn't taken")
    cpu.iff = 1
    cpu.stepi = stepi
    t = et.call(cpu, "HLequHLmulDEu", hl=0x1234, de=0x0567)
    cpu.stepi = cpu.step
    prof.detach()
    check(prof.ints == 1 and prof.int_t > 0, f"ints {prof.ints}, int_t {prof.int_t}")
    check(prof.incl_t[key(cpu, "fixedS78_mulu")] == plain,
          f"fixedS78_mulu inclusive {prof.incl_t[key(cpu, 'fixedS78_mulu')]} with the interrupt, {plain} without")
    check(sum(prof.self_t.values()) + 19 == t, "the self T-states and the interrupt's 19 T acceptance aren't the call")
    sd.close()


def test_labels():
    """profile_game.py's Labels from the SLD build.bat writes"""
    path = os.path.join(et.ROOT, {"regular": "eliteN.sld", "hardware": "EliteNHW.sld"}[et.BUILD])
    check(os.path.exists(path), f"no {os.path.basename(path)}: build first (build.bat)")
    import profile_game as pr
    univ = sym["BankUNIVDATA0"]
    lab = pr.Labels(path, {univ + 1: univ})
    main = sym["fixedS78_mulu"]
    check(lab.routine(5 << 16 | main + 2) == "fixedS78_mulu" or lab.routine(4 << 16 | main + 2) == "fixedS78_mulu",
          f"main memory: {lab.routine(5 << 16 | main + 2)}")
    l2 = sym["BankLAYER2"]
    check(lab.routine(l2 << 16 | sym["PolyEdge"] + 1) == "PolyEdge", f"BankLAYER2: {lab.routine(l2 << 16 | sym['PolyEdge'] + 1)}")
    local = [n for n in sym if n.startswith("PolyEdge.")]
    check(local and lab.routine(l2 << 16 | sym[local[0]]) == "PolyEdge", f"local label {local[:1]}")
    cull = sym["CullV2"]
    check(lab.routine(univ << 16 | cull) == "CullV2" and lab.routine((univ + 1) << 16 | cull) == "CullV2",
          f"universe banks: {lab.routine(univ << 16 | cull)}, {lab.routine((univ + 1) << 16 | cull)}")
    check(lab.line(l2 << 16 | sym["PolyEdge"]) is not None, "no source line for PolyEdge")


def test_profile_runs():
    """Tools/profile_game.py, 3 main loops: runs, and names the polygon fill among the routines"""
    r = subprocess.run([sys.executable, "-W", "ignore", os.path.join(et.TOOLS, "profile_game.py"), "--loops", "3",
                        "--top", "60", "--build", et.BUILD], capture_output=True, text=True, cwd=et.ROOT)
    check(r.returncode == 0, f"exit {r.returncode}:\n{(r.stdout + r.stderr)[-1500:]}")
    check("main loops in flight" in r.stdout and "l2_fill_convex_polygon" in r.stdout, r.stdout[-1500:])


if __name__ == "__main__":
    et.main(globals())
