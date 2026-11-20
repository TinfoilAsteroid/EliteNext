"""Solid ships (SOLID_HULL, Documentation/SolidHulls.md):

  * the face tables in Data/ships/*.asm are what Tools/ship_faces.py makes from the edges now (a model edited without
    re-running the tool would be filled with the old faces);
  * a SOLID_HULL build, assembled in a temporary folder: every model with a face table, spawned and turned through
    random orientations at a few distances, is drawn through ProcessShip (as in flight). Each draw returns, is solid
    (no wireframe), uses only that model's 4 test colours, stays in the view (rows 0-127 of the shadow buffer), and
    covers the same ground as its wireframe (drawn after, with the face table switched off): the fill's bounding box is
    inside the wireframe's (1 pixel either way for rounding) and nearly every wireframe pixel is on or next to the fill;
  * a model with no face table is drawn as wireframe;
  * a vertex at or behind the camera falls back to wireframe.
"""
import math
import os
import subprocess
import sys

import elitetest as et
import nexsim
import test_hardware as th
from elitetest import check

ONE = 0x6000                                    # 1.0 in the rotation matrix (sign magnitude, bit 15 the sign)
VIEW_ROWS = 128
CLEAR = bytes([th.COLOUR_TRANSPARENT]) * 8192


def sm16(v):
    return (abs(v) & 0x7FFF) | (0x8000 if v < 0 else 0)


def sm24(v):
    return (abs(v) & 0x7FFFFF) | (0x800000 if v < 0 else 0)


def rotation(r):
    """a random orthonormal matrix (rows: side, roof, nose), from a random unit quaternion"""
    q = [r.gauss(0, 1) for _ in range(4)]
    n = math.sqrt(sum(c * c for c in q))
    w, x, y, z = (c / n for c in q)
    return [[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
            [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
            [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]]


class Game:
    """the SOLID_HULL build booted to the attract mode"""

    def __init__(self, build, sd):
        self.b = build
        self.sym = build.sym
        self.cpu = build.machine(sd, boot="StartAttractMode")
        self.cpu.stepi = self.watch
        self.hits = set()
        self.watched = {self.sym[n]: n for n in ("l2_fill_convex_polygon", "PrepLines", "SolidHullDraw.LoneLines")
                        if n in self.sym}
        self.ll80 = self.sym["LL80"]
        self.edges = []                             # the edge numbers PrepLines put in the line array

    def watch(self):
        pc = self.cpu.pc
        n = self.watched.get(pc)
        if n:
            self.hits.add(n)
        if pc == self.ll80:
            self.edges.append(self.rd("PLEDGECTR"))
        self.cpu.step()

    def call(self, name, **regs):
        return th.call(self.cpu, name, **regs)

    def rd(self, name, n=1):
        return sum(self.cpu.rd(self.sym[name] + i) << 8 * i for i in range(n))

    def wr(self, name, v, n=1):
        for i in range(n):
            self.cpu.wr(self.sym[name] + i, v >> 8 * i & 255)

    def spawn(self, model):
        """the model in a free slot, its universe bank in slot 6; the slot"""
        for s in range(self.sym["UniverseSlotListSize"]):
            self.cpu.wr(self.sym["UniverseSlotList"] + s, 0xFF)
        self.call("SpawnShipTypeA", a=model)
        slot = next(k for k in range(12) if self.cpu.rd(self.sym["UniverseSlotList"] + k) != 0xFF)
        et.page_in(self.cpu, 6, self.sym["BankUNIVDATA0"] + slot)
        return slot

    def pose(self, pos, mat):
        for i, c in enumerate(pos):
            self.wr_at(self.sym["UBnKxlo"] + 3 * i, sm24(c), 3)
        names = ("UBnkrotmatSidevX", "UBnkrotmatRoofvX", "UBnkrotmatNosevX")
        for row, name in zip(mat, names):
            for i, c in enumerate(row):
                self.wr_at(self.sym[name] + 2 * i, sm16(round(c * ONE)), 2)
        self.wr("UBnkaiatkecm", 0x80)               # alive, not exploding
        self.wr("UBnKexplDsp", 0)

    def wr_at(self, a, v, n):
        for i in range(n):
            self.cpu.wr(a + i, v >> 8 * i & 255)

    def draw(self, solid=True):
        """ProcessShip (the face table on, or switched off for the wireframe): {(x, y): colour}, rows drawn below the
        view, and what it called"""
        if not solid:
            self.wr("ShipSolidFlagAddr", 1)
        et.page_in(self.cpu, 7, self.sym["BankLAYER2"])
        for buf in buffers(self.cpu):                   # (cleared as l2_cls does, to the transparent colour, which
            for p in buf:                               # no ship colour is: black is $00, a station's entrance)
                p[:] = CLEAR
        self.hits = set()
        self.edges = []
        self.call("ProcessShip", mmu={0: self.sym["BankMathsBankedFns"], 7: self.sym["BankLAYER2"]})
        pix, below = {}, 0
        for b, buf in enumerate(buffers(self.cpu)):
            for k, p in enumerate(buf):
                if bytes(p) != CLEAR:
                    for off, v in enumerate(p):
                        if v != th.COLOUR_TRANSPARENT:
                            y = k * 32 + (off >> 8)
                            if y >= VIEW_ROWS:
                                below += 1
                            pix[(off & 255, y)] = v
        if not solid:
            self.wr("ShipSolidFlagAddr", 0)
        return pix, below, set(self.hits)

    def colours(self, model):
        base = self.sym["SolidColours"] + (model & 7) * 4
        return {self.cpu.rd(base + i) for i in range(4)}


def buffers(cpu):
    return [[cpu.page(cpu.nextreg.get(reg, 8) * 2 + k) for k in range(6)] for reg in (0x12, 0x13)]


def bbox(pts):
    xs, ys = [x for x, _ in pts], [y for _, y in pts]
    return min(xs), min(ys), max(xs), max(ys)


def near(p, pix):
    x, y = p
    return any((x + dx, y + dy) in pix for dx in (-1, 0, 1) for dy in (-1, 0, 1))


def models():
    """(name, has a face table) for every Data/ships model"""
    out = []
    for f in sorted(os.listdir(os.path.join(et.ROOT, "Data", "ships"))):
        if f.endswith(".asm"):
            text = open(os.path.join(et.ROOT, "Data", "ships", f), encoding="latin-1").read()
            out.append((f[:-4], f"{f[:-4]}Faces:" in text))
    return out


def test_face_tables_current():
    """ship_faces.py --check: every face table is what the tool makes from the model's edges now"""
    r = subprocess.run([sys.executable, os.path.join(et.ROOT, "Tools", "ship_faces.py"), "--check"], cwd=et.ROOT,
                       capture_output=True, text=True)
    check(r.returncode == 0, "face tables out of date (run python Tools/ship_faces.py):\n" + (r.stdout + r.stderr)[-1500:])


def decoration(g, edge):
    """both of the edge's face numbers the same (the ship's universe bank in slot 6)"""
    b = g.cpu.rd(g.sym["UBnkHullEdges"] + 4 * edge + 1)
    return b >> 4 == b & 15


def table_records(g, a, count):
    """count records (DW mask, DB n, n vertices x4) at a: [(mask, [vertices])], and the address after them"""
    out = []
    for _ in range(count):
        n = g.cpu.rd(a + 2)
        out.append((g.cpu.rd(a) | g.cpu.rd(a + 1) << 8, [g.cpu.rd(a + 3 + k) // 4 for k in range(n)]))
        a += 3 + n
    return out, a


def ports(g):
    """the ship's face table's phase 2 polygons (Tools/ship_faces.py PORTS): [(mask, type, [vertices])], and the
    address of the lone lines after them (its universe bank in slot 6)"""
    a = g.sym["UBnkHullSolid"]
    _, a = table_records(g, a + 1, g.cpu.rd(a))
    out, count, a = [], g.cpu.rd(a), a + 1
    for _ in range(count):
        n = g.cpu.rd(a + 3)
        out.append((g.cpu.rd(a) | g.cpu.rd(a + 1) << 8, g.cpu.rd(a + 2), [g.cpu.rd(a + 4 + k) // 4 for k in range(n)]))
        a += 4 + n
    return out, a


def port_colours(g):
    """[engine colour, entrance colour] (SolidPortColours, in the Layer 2 bank)"""
    page = g.cpu.page(g.sym["BankLAYER2"])
    return [page[g.sym["SolidPortColours"] + g.sym[t] - 0xE000] for t in ("PortEngine", "PortEntrance")]


def lone_lines(g):
    """the ship's face table's lone lines (Tools/ship_faces.py LONE_LINES): [(mask, v0, v1)] (its universe bank in slot
    6; walks the table as SolidHullDraw does)"""
    _, a = ports(g)
    out = []
    for k in range(g.cpu.rd(a)):
        p = a + 1 + 4 * k
        out.append((g.cpu.rd(p) | g.cpu.rd(p + 1) << 8, g.cpu.rd(p + 2) // 4, g.cpu.rd(p + 3) // 4))
    return out


def solid_build(*defines):
    """a SOLID_HULL build with defines (th.Build leaves out any eliteNext.asm defines already)"""
    if not os.path.exists(th.SJASM):
        return None
    return th.Build(False, defines=("SOLID_HULL",) + defines)


def solid_models(g):
    return [(name, g.sym[f"ShipID_{name}"]) for name, faces in models() if faces and f"ShipID_{name}" in g.sym]


def poses(r, n):
    """n (position, matrix): random orientations, near the middle of the view, at 3 distances"""
    out = []
    for k in range(n):
        z = (0x500, 0x900, 0x1800)[k % 3]
        out.append(((r.randrange(-z // 6, z // 6), r.randrange(-z // 8, z // 8), z), rotation(r)))
    return out


def test_every_model_draws_solid():
    """every model with a face table, 12 random orientations at 3 distances: solid, its colours, in the view, the
    wireframe's ground; the models without one: wireframe"""
    b = solid_build()
    if not b:
        et.note(f"no sjasmplus ({th.SJASM}): skipped")
        return
    r = et.rnd(50)
    try:
        with et.SD() as sd:
            g = Game(b, sd)
            for name, faces in models():
                model = g.sym.get(f"ShipID_{name}")
                if model is None:
                    continue
                g.spawn(model)
                solid_n, worst = 0, 1.0
                for n in range(36 if faces else 3):
                    z = (0x500, 0x900, 0x1800)[n % 3]
                    pos = (r.randrange(-z // 4, z // 4), r.randrange(-z // 6, z // 6), z)
                    mat = rotation(r)
                    g.pose(pos, mat)
                    try:
                        pix, below, hits = g.draw()
                    except nexsim.Halt as e:
                        raise AssertionError(f"{name} {pos}: crashed: {e}")
                    what = f"{name} at {pos}"
                    check(below == 0, f"{what}: {below} pixels below the view")
                    if not faces:
                        check("l2_fill_convex_polygon" not in hits, f"{what}: filled, with no face table")
                        continue
                    if not hits - {"SolidHullDraw.LoneLines"}:
                        check(len(pix) <= 1, f"{what}: {len(pix)} pixels drawn with neither fill nor lines")
                        continue                                    # (a dot, or off screen)
                    check("PrepLines" not in hits and "l2_fill_convex_polygon" in hits, f"{what}: not drawn solid ({hits})")
                    solid_n += 1
                    bad = set(pix.values()) - g.colours(model) - ({g.rd("line_gfx_colour")} if lone_lines(g) else set()) \
                        - (set(port_colours(g)) if ports(g)[0] else set())
                    check(not bad, f"{what}: colours {sorted(bad)} aren't the model's")
                    g.pose(pos, mat)
                    wire, _, _ = g.draw(solid=False)
                    if not wire:
                        continue
                    check(pix, f"{what}: the fill drew nothing, the wireframe {len(wire)} pixels at {bbox(wire)}")
                    sx0, sy0, sx1, sy1 = bbox(pix)
                    wx0, wy0, wx1, wy1 = bbox(wire)
                    check(sx0 >= wx0 - 1 and sy0 >= wy0 - 1 and sx1 <= wx1 + 1 and sy1 <= wy1 + 1,
                          f"{what}: fill {sx0, sy0, sx1, sy1} outside the wireframe {wx0, wy0, wx1, wy1}")
                    cover = sum(near(p, pix) for p in wire) / len(wire)
                    worst = min(worst, cover)
                    check(cover >= 0.9, f"{what}: only {cover:.0%} of the wireframe's pixels are on the fill")
                if faces:
                    check(solid_n >= 6, f"{name}: only {solid_n} of 36 drawn solid")      # (small ones: dots when far)
                    et.note(f"{name}: {solid_n} solid, wireframe on the fill >= {worst:.0%}")
    finally:
        b.close()


def test_behind_the_camera_is_wireframe():
    """a ship straddling the camera (a vertex at z < 5) is drawn as wireframe, not filled"""
    b = solid_build()
    if not b:
        et.note(f"no sjasmplus ({th.SJASM}): skipped")
        return
    try:
        with et.SD() as sd:
            g = Game(b, sd)
            g.spawn(g.sym["ShipID_Coriolis"])
            ident = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
            for z in (0x10, 0x30, 0x60):
                g.pose((0, 0, z), ident)
                pix, below, hits = g.draw()
                check(hits == {"PrepLines"}, f"Coriolis at z {z:#x}: not the wireframe across the camera ({hits})")
                check(below == 0, f"Coriolis at z {z:#x}: {below} pixels below the view")
    finally:
        b.close()


def test_outlines_all():
    """SOLID_OUTLINES ALL: filled, then every pixel of the wireframe drawn over it in the line colour"""
    b = solid_build("SOLID_OUTLINES=ALL")
    if not b:
        et.note(f"no sjasmplus ({th.SJASM}): skipped")
        return
    r = et.rnd(51)
    try:
        with et.SD() as sd:
            g = Game(b, sd)
            drawn = 0
            for name, model in solid_models(g):
                g.spawn(model)
                for pos, mat in poses(r, 6):
                    g.pose(pos, mat)
                    pix, below, hits = g.draw()
                    what = f"{name} at {pos}"
                    check(below == 0, f"{what}: {below} pixels below the view")
                    if "l2_fill_convex_polygon" not in hits:
                        continue                            # (a dot)
                    check("PrepLines" in hits, f"{what}: no outlines")
                    line = g.rd("line_gfx_colour")
                    g.pose(pos, mat)
                    wire, _, _ = g.draw(solid=False)
                    missing = [p for p in wire if pix.get(p) != line]
                    check(not missing, f"{what}: {len(missing)} of {len(wire)} wireframe pixels not drawn over the fill")
                    bad = set(pix.values()) - g.colours(model) - {line} - set(port_colours(g))
                    check(not bad, f"{what}: colours {sorted(bad)}")
                    drawn += 1
            check(drawn > 60, f"only {drawn} solid draws")
    finally:
        b.close()


def test_outlines_decoration():
    """SOLID_OUTLINES DECORATION: over the fill, exactly the decoration edges (both faces the same) of those PrepLines
    finds visible; an ordinary PrepLines (the wireframe, e.g. a model with no face table) still gets every edge"""
    b = solid_build("SOLID_OUTLINES=DECORATION")
    if not b:
        et.note(f"no sjasmplus ({th.SJASM}): skipped")
        return
    r = et.rnd(52)
    try:
        with et.SD() as sd:
            g = Game(b, sd)
            with_deco = 0
            for name, model in solid_models(g):
                g.spawn(model)
                for pos, mat in poses(r, 6):
                    g.pose(pos, mat)
                    pix, below, hits = g.draw()
                    if "l2_fill_convex_polygon" not in hits:
                        continue
                    what = f"{name} at {pos}"
                    deco = list(g.edges)
                    g.edges = []
                    g.call("PrepLines")                     # the same nodes, every visible edge
                    every = list(g.edges)
                    exp = [e for e in every if decoration(g, e)]
                    check(deco == exp, f"{what}: decoration lines {deco}, expected {exp} (of {every})")
                    check(len(every) > len(deco), f"{what}: PrepLines found only {every}")
                    with_deco += bool(deco)
            check(with_deco > 30, f"decoration edges drawn in only {with_deco} draws")
    finally:
        b.close()


def test_wireframe_fallback():
    """WIREFRAME_FALLBACK: z below WIREFRAME_DISTANCE (here 6.0, -DWIREFRAME_DISTANCE=0x600) is wireframe, from it
    solid; z of 256.0 or more (the sign byte's magnitude) is far enough whatever the low 16 bits. The default build
    uses eliteNext.asm's WIREFRAME_DISTANCE equate"""
    b = solid_build("WIREFRAME_FALLBACK", "WIREFRAME_DISTANCE=0x600")
    d = solid_build("WIREFRAME_FALLBACK")
    if not b:
        et.note(f"no sjasmplus ({th.SJASM}): skipped")
        return
    try:
        import re                                           # the default: eliteNext.asm's equate (being tuned)
        src = open(os.path.join(et.ROOT, "eliteNext.asm"), encoding="latin-1").read()
        num, den = re.search(r"^WIREFRAME_DISTANCE\s+equ\s+(\d+)\s*(?:/\s*(\d+))?", src, re.M).groups()
        exp = int(num) // int(den or 1)
        check(d.sym["WIREFRAME_DISTANCE"] == exp, f"default WIREFRAME_DISTANCE {d.sym['WIREFRAME_DISTANCE']}, eliteNext.asm {exp}")
        ident = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
        with et.SD() as sd:
            g = Game(b, sd)
            for name in ("Sidewinder", "Viper", "Coriolis"):
                g.spawn(g.sym[f"ShipID_{name}"])
                for z, solid in ((0x5FF, False), (0x600, True), (0x900, True)):
                    g.pose((0, 0, z), ident)
                    pix, _, hits = g.draw()
                    got = "l2_fill_convex_polygon" in hits
                    check(got == solid and ("PrepLines" in hits) != solid,
                          f"{name} at z {z:#x}: {'solid' if got else 'wireframe'} ({hits})")
            g.pose((0, 0, 0x900), ident)                    # (the nodes, in front of the camera)
            g.draw()
            for zsgn, solid in ((0x00, False), (0x01, True), (0x80, False)):   # z lo, hi = $0010: under the distance
                g.wr("UBnKzlo", 0x0010, 2)
                g.wr("UBnKzsgn", zsgn)
                g.call("SolidHullDraw", mmu={7: g.sym["BankLAYER2"]})
                check(et.reg(g.cpu, "carry") == solid, f"z sign byte {zsgn:02X}, z $0010: carry {et.reg(g.cpu, 'carry')}")
    finally:
        b.close()
        d.close()


def test_lone_lines():
    """The Cobra Mk 3 and Mk 3 P (Tools/ship_faces.py LONE_LINES): solid, with the nose line 20-21 as a lone line. With
    no SOLID_OUTLINES it's drawn over the fill exactly when the wireframe draws that edge, its pixels exactly the
    wireframe's for it, in the line colour; with SOLID_OUTLINES DECORATION too; with ALL it isn't drawn twice"""
    r = et.rnd(54)
    for outlines in ((), ("SOLID_OUTLINES=DECORATION",), ("SOLID_OUTLINES=ALL",)):
        b = solid_build(*outlines)
        if not b:
            et.note(f"no sjasmplus ({th.SJASM}): skipped")
            return
        try:
            with et.SD() as sd:
                g = Game(b, sd)
                shown = 0
                for name in ("CobraMk3", "Cobra_Mk_3_P"):
                    g.spawn(g.sym[f"ShipID_{name}"])
                    lines = lone_lines(g)
                    check([(a, b_) for _, a, b_ in lines] == [(20, 21)], f"{name}: lone lines {lines}")
                    gun = next(e for e in range(g.cpu.rd(g.sym["EdgeCountAddr"]))
                               if {g.cpu.rd(g.sym["UBnkHullEdges"] + 4 * e + k) // 4 for k in (2, 3)} == {20, 21})
                    every = outlines == ("SOLID_OUTLINES=ALL",)
                    for pos, mat in poses(r, 24):
                        g.pose(pos, mat)
                        pix, below, hits = g.draw()
                        if "l2_fill_convex_polygon" not in hits:
                            continue
                        what = f"{name} {outlines} at {pos}"
                        check(("SolidHullDraw.LoneLines" in hits) != every, f"{what}: lone line pass {hits}")
                        line = g.rd("line_gfx_colour")
                        lone_n = g.rd("UbnkLineArrayLen")       # (the lone pass runs last and counts from 0)
                        g.pose(pos, mat)
                        wire, _, _ = g.draw(solid=False)
                        seen = gun in g.edges                   # (the wireframe's PrepLines took the nose line)
                        if every:
                            continue
                        check(lone_n == seen, f"{what}: {lone_n} lone lines drawn, the wireframe shows the nose line {seen}")
                        pix_lines = {p for p, v in pix.items() if v == line}
                        check(pix_lines <= set(wire), f"{what}: {len(pix_lines - set(wire))} line pixels not on the wireframe")
                        if not outlines:                        # (no other lines: any line pixels are the nose line's)
                            check(bool(pix_lines) == seen, f"{what}: {len(pix_lines)} line pixels, nose line seen {seen}")
                            shown += seen
                if not outlines:
                    check(shown > 5, f"the nose line shown in only {shown} draws")
        finally:
            b.close()


def test_phase2_ports():
    """Phase 2 polygons (Tools/ship_faces.py PORTS): the Cobra Mk 3's and Mk 3 P's engine ports (the back face's
    decoration loops 12-13-18-19, 14-15-16-17, 22-23-24, 25-26-27) in the engine colour, the Coriolis's and Dodo's
    entrance (face 0's loop) in black. Each is filled after the hull, exactly its pixels (by l2_fill_convex_polygon's
    rules, from the projected points) less any line drawn after, when its face faces us; none when it doesn't"""
    from test_lines import fill_model
    b = solid_build()
    if not b:
        et.note(f"no sjasmplus ({th.SJASM}): skipped")
        return
    engine = [[12, 13, 18, 19], [14, 15, 16, 17], [22, 23, 24], [25, 26, 27]]
    want = {"CobraMk3": ("PortEngine", 9, engine), "Cobra_Mk_3_P": ("PortEngine", 9, engine),
            "Coriolis": ("PortEntrance", 0, None), "Dodo": ("PortEntrance", 0, None)}
    r = et.rnd(55)
    try:
        with et.SD() as sd:
            g = Game(b, sd)
            engine_c, entrance_c = port_colours(g)
            check(engine_c == 0x49 and entrance_c == 0x00, f"port colours {engine_c:02X}, {entrance_c:02X}")
            for name, (kind, face, loops) in want.items():
                g.spawn(g.sym[f"ShipID_{name}"])
                got_ports, _ = ports(g)
                check(got_ports and all(m == 1 << face and t == g.sym[kind] for m, t, _ in got_ports),
                      f"{name}: ports {got_ports}")
                if loops:
                    check(sorted(sorted(v) for _, _, v in got_ports) == loops, f"{name}: port loops {got_ports}")
                colour = engine_c if kind == "PortEngine" else entrance_c
                seen = hidden = 0
                for n in range(36):
                    z = (0x500, 0x900, 0xC00)[n % 3]
                    mat = (rotation(r), [[1, 0, 0], [0, 1, 0], [0, 0, 1]], [[-1, 0, 0], [0, 1, 0], [0, 0, -1]])[n % 3]
                    g.pose((r.randrange(-z // 8, z // 8), r.randrange(-z // 10, z // 10), z), mat)
                    pix, below, hits = g.draw()
                    if "l2_fill_convex_polygon" not in hits:
                        continue
                    vis = g.cpu.rd(g.sym["UbnkFaceVisArray"] + face) != 0
                    exp = set()
                    if vis:
                        for _, _, verts in got_ports:
                            pts = []
                            for v in verts:
                                a = g.sym["UBnkNodeArray"] + 4 * v
                                x, y = g.cpu.rd(a) | g.cpu.rd(a + 1) << 8, g.cpu.rd(a + 2) | g.cpu.rd(a + 3) << 8
                                pts.append((x - 0x10000 if x & 0x8000 else x, y - 0x10000 if y & 0x8000 else y))
                            exp |= fill_model(pts)
                    line = g.rd("line_gfx_colour")
                    exp -= {p for p, v in pix.items() if v == line}         # (lines are drawn after)
                    got = {p for p, v in pix.items() if v == colour}
                    check(got == exp, f"{name} pose {n} (face {face} {'facing' if vis else 'away'}): {len(got)} port "
                          f"pixels, expected {len(exp)} (extra {sorted(got - exp)[:3]}, missing {sorted(exp - got)[:3]})")
                    seen += bool(got)
                    hidden += not vis
                check(seen > 5 and hidden > 3, f"{name}: ports seen in {seen} draws, face {face} away in {hidden}")
    finally:
        b.close()


def test_attract_screen_solid():
    """The attract screen (Menus/AttractMode.asm, AttractModeUpdate's 3 steps a frame): a ship with a face table is
    filled every frame, in its model's colours plus the box round the view, and stays in the view; one without is
    wireframe"""
    b = solid_build()
    if not b:
        et.note(f"no sjasmplus ({th.SJASM}): skipped")
        return
    try:
        with et.SD() as sd:
            g = Game(b, sd)
            g.call("AttractModeInit")
            for want in (True, False):                      # a ship with a face table, then one without
                for pick in range(100):                     # (SelectARandomShip: a random ship each time, or with
                    et.page_in(g.cpu, 6, g.sym["BankUNIVDATA0"] + 1)        # MANUAL_ATTRACT the AttractShipId one)
                    if (g.cpu.rd(g.sym["ShipSolidFlagAddr"]) == 0) == want:
                        break
                    if "AttractShipId" in g.sym:
                        g.cpu.wr(g.sym["AttractShipId"], pick % g.sym["ShipTotalModelCount"])
                    g.call("SelectARandomShip")
                else:
                    raise AssertionError(f"SelectARandomShip never gave a ship {'with' if want else 'without'} a face table")
                model = g.cpu.rd(g.sym["UBnKShipModelId"])
                for frame in range(12):
                    g.hits = set()
                    for step in range(3):
                        g.call("AttractModeUpdate")
                    filled = "l2_fill_convex_polygon" in g.hits
                    check(filled == want and ("PrepLines" in g.hits) != want,
                          f"model {model} (face table {want}), frame {frame}: {g.hits}")
                if want:
                    solid_model, shown = model, [bytes(g.cpu.page(g.cpu.nextreg.get(0x12, 8) * 2 + k)) for k in range(6)]
            model = solid_model
            colours, below = {}, 0
            for k, p in enumerate(shown):
                for off, v in enumerate(p):
                    if v not in (0, th.COLOUR_TRANSPARENT):         # (l2_cls clears to the transparent colour)
                        colours[v] = colours.get(v, 0) + 1
                        if v != 0xC0:                               # (the box round the view ends on row 128)
                            below += k * 32 + (off >> 8) >= VIEW_ROWS
            fill = sum(n for c, n in colours.items() if c in g.colours(model))
            check(fill > 20, f"only {fill} filled pixels on the attract screen ({colours})")
            check(set(colours) <= g.colours(model) | {0xC0}, f"colours {sorted(set(colours))}")
            check(below == 0, f"{below} pixels below the view")
    finally:
        b.close()


def test_ships_sorted_furthest_first():
    """SortShipsFurthestFirst (GameEngine/UpdateUniverseObjects.asm): every active slot once, dots first, then by z / 256
    (16 bits of the 24 bit z) largest first, ships behind (z negative) last"""
    b = solid_build()
    if not b:
        et.note(f"no sjasmplus ({th.SJASM}): skipped")
        return
    r = et.rnd(53)
    try:
        with et.SD() as sd:
            g = Game(b, sd)
            size = g.sym["UniverseSlotListSize"]
            dot = g.sym["ShipIsDot"]
            for n in range(150):
                for s in range(size):
                    g.cpu.wr(g.sym["UniverseSlotList"] + s, 0xFF)
                keys = {}
                for s in r.sample(range(size), r.randrange(0, size + 1)):
                    g.cpu.wr(g.sym["UniverseSlotList"] + s, g.sym["ShipTypeNormal"])
                    et.page_in(g.cpu, 6, g.sym["BankUNIVDATA0"] + s)
                    z = r.choice((r.randrange(-0x7FFFFF, 0), r.randrange(0, 0x7FFFFF) >> r.randrange(0, 20)))
                    is_dot = r.random() < 0.2
                    g.wr("UBnKzlo", sm24(z), 3)
                    g.wr("UBnkaiatkecm", 0x80 | (dot if is_dot else 0))
                    keys[s] = 0xFFFF if is_dot else 0 if z < 0 else (abs(z) >> 8) & 0xFFFF
                g.call("SortShipsFurthestFirst", mmu={0: g.sym["BankMathsBankedFns"]})
                count = g.rd("ShipDrawCount")
                order = [g.cpu.rd(g.sym["ShipDrawOrder"] + i) for i in range(count)]
                check(sorted(order) == sorted(keys), f"slots {sorted(keys)}: order {order}")
                got = [keys[s] for s in order]
                check(got == sorted(got, reverse=True), f"keys in draw order {[hex(k) for k in got]}")
    finally:
        b.close()


if __name__ == "__main__":
    et.main(globals())
