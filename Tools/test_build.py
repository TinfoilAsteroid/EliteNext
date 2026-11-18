"""The build: eliteNext.asm assembled afresh in a temporary folder (so the
repository's outputs aren't touched).  Replaces macroTst.asm, which checked
sjasmplus's macro and LUA handling: the game's own macros (the clipping
macros in asm_linedraw.asm among them) are all assembled here.

  * no errors or warnings;
  * no DISPLAY "TODO ..." messages: those live in TODO.md now;
  * the non-banked code ends below the IM2 vector table ($B000);
  * the result is byte for byte the EliteN.nex the other tests run on, so
    they test the current sources (rebuild if this fails).
"""
import os
import re
import shutil
import subprocess
import tempfile

import elitetest as et
from elitetest import check

SJASM = shutil.which("sjasmplus") or r"C:\CSpect\sjasmplus.exe"


def build():
    tmp = tempfile.mkdtemp(prefix="elitebuild_")
    try:
        root = et.ROOT.replace("\\", "/")             # (sjasmplus warns about \ in file names)
        r = subprocess.run([SJASM, "--nologo", "--msg=war", f"-I{root}", f"{root}/eliteNext.asm"],
                           cwd=tmp, capture_output=True, text=True, errors="replace")
        nex = os.path.join(tmp, "EliteN.nex")
        data = open(nex, "rb").read() if os.path.exists(nex) else None
        return r.returncode, r.stdout + r.stderr, data
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def test_build():
    if not os.path.exists(SJASM):
        et.note(f"no sjasmplus ({SJASM}): skipped")
        return
    code, out, nex = build()
    problems = [l for l in out.splitlines() if re.search(r"\b(error|warning)\b", l, re.I)]
    check(code == 0 and nex, f"the build failed (exit {code}):\n" + "\n".join(problems[:20] or out.splitlines()[-20:]))
    check(not problems, "errors or warnings:\n" + "\n".join(problems[:20]))
    todos = [l for l in out.splitlines() if re.match(r">\s*(TODO|TO DO)\b", l, re.I)]
    check(not todos, f"{len(todos)} DISPLAY TODO messages (put them in TODO.md):\n" + "\n".join(todos[:10]))
    m = re.search(r"Main Non Banked Code Ends at 0x([0-9A-F]+)", out)
    check(m and int(m.group(1), 16) < 0xB000, f"non-banked code ends at {m.group(1) if m else '?'}, past $B000")
    et.note(f"non-banked code ends at ${m.group(1)}, {0xB000 - int(m.group(1), 16)} bytes below the vector table")
    with open(et.NEX, "rb") as f:
        check(f.read() == nex, "EliteN.nex isn't what the sources build: rebuild (elitebuild.bat) and test again")


if __name__ == "__main__":
    et.main(globals())
