"""Run the regression tests: every Tools/test_*.py, at the same time (one
process each).  Each runs on the regular build, EliteN.nex, unless it has
the line  ELITE_BUILD = "hardware"  (tests of real hardware features), then
on EliteNHW.nex; build.bat makes both (elitetest.py).  Run by build.bat after
assembling; or by hand:

    python Tools/run_tests.py              all of them
    python Tools/run_tests.py maths lines  only test_maths.py and test_lines.py

Prints each file's results as it finishes; the exit code is 1 if any test
failed.  A file on its own: python Tools/test_maths.py [test name...].
"""
import glob
import os
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed

TOOLS = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(TOOLS)
sys.path.insert(0, TOOLS)
import elitetest  # noqa: E402


def run(path):
    t0 = time.time()
    r = subprocess.run([sys.executable, path], capture_output=True, text=True, cwd=ROOT)
    return path, r.returncode, r.stdout + r.stderr, time.time() - t0


def main():
    files = sorted(glob.glob(os.path.join(TOOLS, "test_*.py")))
    want = sys.argv[1:]
    if want:
        files = [f for f in files if os.path.basename(f)[5:-3] in want or os.path.basename(f) in want]
    for name, outputs in elitetest.BUILDS.items():
        for need in outputs:
            if not os.path.exists(need):
                raise SystemExit(f"no {os.path.basename(need)} (the {name} build): build first (build.bat)")
    hw = [os.path.basename(f) for f in files if elitetest.wanted_build(f) == "hardware"]
    if hw:
        print(f"on the hardware build: {', '.join(hw)}", flush=True)
    t0 = time.time()
    failed = []
    with ThreadPoolExecutor(max_workers=max(1, min(len(files), os.cpu_count() or 4))) as ex:
        for fut in as_completed([ex.submit(run, f) for f in files]):
            path, code, out, secs = fut.result()
            print(out.rstrip(), flush=True)
            if code:
                failed.append(os.path.basename(path))
    passed = len(files) - len(failed)
    print(f"tests: {passed} of {len(files)} files passed in {time.time() - t0:.0f}s"
          + (f"; FAILED: {', '.join(sorted(failed))}" if failed else ""))
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
