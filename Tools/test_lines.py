"""Line clipping and drawing: l2_draw_6502_line, which draws every ship's
wireframe (DrawLinesLateClipping).  Replaces clipTst.asm.

Lines from -1024 to +1024 on each axis are drawn into the 256x128 view and
checked against a Python reference:
  * a line that misses the view draws nothing and returns carry; one that
    crosses it draws and returns no carry (lines within a pixel of an edge
    may go either way);
  * every pixel is in the view, within a pixel of the true line (across the
    line's major axis), one pixel per step along the major axis, from the
    returned (clipped) end point to the other, and exactly the Bresenham
    (Z-Police's draw_line loop) between those end points;
  * the drawn part covers the true in-view part to within a pixel;
  * nothing is written to rows 128-191 (the console) or the other buffer;
  * horizontal and vertical lines (the DMA span path) are exact.
"""
import elitetest as et
from elitetest import check, sym

COLOUR = 0xBF
W, H = 256, 128


def booted():
    sd = et.SD()
    cpu = et.machine(sd, boot="StartAttractMode")
    et.page_in(cpu, 7, sym["BankLAYER2"])          # (MMUSelectLayer2: L2memMMU is slot 7)
    return sd, cpu


def buffers(cpu):
    """the 6 8K pages (32 rows each) of the shown and the shadow Layer 2"""
    return [[cpu.page(cpu.nextreg.get(reg, 8) * 2 + k) for k in range(6)] for reg in (0x12, 0x13)]


def clear(cpu):
    for buf in buffers(cpu):
        for p in buf:
            p[:] = bytes(8192)


def drawn(cpu):
    """{(x, y)} drawn, which buffer, and any byte written below row 127 or that
    isn't the colour"""
    found = []
    for b, buf in enumerate(buffers(cpu)):
        for k, p in enumerate(buf):
            if any(p):
                for off, v in enumerate(p):
                    if v:
                        found.append((b, off & 255, k * 32 + (off >> 8), v))
    return found


def to16(v):
    return v & 0xFFFF


def s16(v):
    return v - 0x10000 if v & 0x8000 else v


def draw(cpu, p1, p2):
    clear(cpu)
    et.wr(cpu, "line_gfx_colour", COLOUR)
    for name, v in zip(("x1", "y1", "x2", "y2"), (*p1, *p2)):
        et.wr(cpu, name, to16(v), 2)
    et.call(cpu, "l2_draw_6502_line")
    ends = tuple(s16(et.rd(cpu, n, 2)) for n in ("x1", "y1", "x2", "y2"))
    return et.reg(cpu, "carry"), ends, drawn(cpu)


def clip(p1, p2, x0, y0, x1, y1):
    """Liang-Barsky: the part of the segment in [x0, x1] x [y0, y1], or None"""
    (ax, ay), (bx, by) = p1, p2
    dx, dy = bx - ax, by - ay
    t0, t1 = 0.0, 1.0
    for p, q in ((-dx, ax - x0), (dx, x1 - ax), (-dy, ay - y0), (dy, y1 - ay)):
        if p == 0:
            if q < 0:
                return None
        else:
            t = q / p
            if p < 0:
                t0 = max(t0, t)
            else:
                t1 = min(t1, t)
    if t0 > t1:
        return None
    return (ax + t0 * dx, ay + t0 * dy), (ax + t1 * dx, ay + t1 * dy)


def bresenham(x1, y1, x2, y2):
    """the pixels L2LDiagonal draws between clipped end points (x1 <> x2, y1 <> y2): top to bottom, the error
    starting at half the major delta, the minor step taken when it goes below 0"""
    if y2 < y1:
        x1, y1, x2, y2 = x2, y2, x1, y1
    dx, dy, sx = abs(x2 - x1), y2 - y1, 1 if x2 > x1 else -1
    x, y, pts = x1, y1, set()
    if dx > dy:
        err = dx // 2
        for _ in range(dx + 1):
            pts.add((x, y))
            x += sx
            err -= dy
            if err < 0:
                y += 1
                err += dx
    else:
        err = dy // 2
        for _ in range(dy + 1):
            pts.add((x, y))
            y += 1
            err -= dx
            if err < 0:
                x += sx
                err += dy
    return pts


def check_line(cpu, p1, p2):
    carry, ends, pix = draw(cpu, p1, p2)
    what = f"line {p1} - {p2}"
    sure_in = clip(p1, p2, 1, 1, W - 2, H - 2)
    maybe = clip(p1, p2, -1, -1, W, H)
    if maybe is None:
        check(carry and not pix, f"{what} is outside the view but drew {len(pix)} pixels (carry {carry})")
        return 0
    if sure_in is None and carry:
        check(not pix, f"{what}: carry set but {len(pix)} pixels drawn")
        return 0
    check(not carry and pix, f"{what} crosses the view but drew nothing (carry {carry})")
    bufs = {b for b, _, _, _ in pix}
    check(len(bufs) == 1, f"{what} drew in both Layer 2 buffers")
    check(all(v == COLOUR for *_, v in pix), f"{what} drew a byte that isn't the colour")
    pts = {(x, y) for _, x, y, _ in pix}
    check(all(y < H for _, y in pts), f"{what} drew below row 127 (the console): {sorted(y for _, y in pts if y >= H)[:5]}")
    ex1, ey1, ex2, ey2 = ends
    check(all(0 <= c <= m for c, m in ((ex1, W - 1), (ey1, H - 1), (ex2, W - 1), (ey2, H - 1))),
          f"{what}: clipped end points {ends} outside the view")
    check((ex1, ey1) in pts and (ex2, ey2) in pts, f"{what}: end points {ends} not drawn")
    # one pixel per step along the major axis, between the end points
    (ax, ay), (bx, by) = p1, p2
    dx, dy = bx - ax, by - ay
    xmajor = abs(dx) >= abs(dy)
    n = max(abs(ex2 - ex1), abs(ey2 - ey1)) + 1
    check(len(pts) == n, f"{what}: {len(pts)} pixels between {ends}, expected {n}")
    major = sorted(x if xmajor else y for x, y in pts)
    check(major == list(range(major[0], major[0] + n)), f"{what}: gaps or doubles along the major axis")
    for x, y in pts:                                # within a pixel of the true line, across it
        if xmajor:
            err = abs(y - (ay + dy * (x - ax) / dx))
        else:
            err = abs(x - (ax + dx * (y - ay) / dy))
        check(err <= 1.01, f"{what}: pixel ({x}, {y}) is {err:.2f} off the line")
    if ex1 != ex2 and ey1 != ey2:                   # exactly the Bresenham from the clipped ends
        exp = bresenham(ex1, ey1, ex2, ey2)
        check(pts == exp, f"{what}: drew {len(pts)} pixels, the Bresenham from {ends} has {len(exp)} "
                          f"(missing {sorted(exp - pts)[:4]}, extra {sorted(pts - exp)[:4]})")
    ideal = clip(p1, p2, 0, 0, W - 1, H - 1)        # covers the true in-view part
    if ideal:
        lo, hi = sorted(c[0 if xmajor else 1] for c in ideal)
        check(major[0] <= lo + 1.01 and major[-1] >= hi - 1.01,
              f"{what}: drew {major[0]}..{major[-1]} along the major axis, the view holds {lo:.1f}..{hi:.1f}")
    return len(pts)


def test_random_lines():
    sd, cpu = booted()
    r = et.rnd(31)
    total, drew, missed = 0, 0, 0
    for n in range(400):
        kind = n % 4
        if kind == 0:                               # anywhere in +/-1024
            p1 = (r.randrange(-1024, 1025), r.randrange(-1024, 1025))
            p2 = (r.randrange(-1024, 1025), r.randrange(-1024, 1025))
        elif kind == 1:                             # inside the view
            p1 = (r.randrange(W), r.randrange(H))
            p2 = (r.randrange(W), r.randrange(H))
        elif kind == 2:                             # one end in, one out
            p1 = (r.randrange(W), r.randrange(H))
            p2 = (r.randrange(-1024, 1025), r.randrange(-1024, 1025))
        else:                                       # near the edges
            p1 = (r.randrange(-40, W + 40), r.randrange(-40, H + 40))
            p2 = (r.randrange(-40, W + 40), r.randrange(-40, H + 40))
        if p1 == p2:
            continue
        n_pix = check_line(cpu, p1, p2)
        total += n_pix
        drew, missed = drew + (n_pix > 0), missed + (n_pix == 0)
    check(total > 20000 and drew > 200 and missed > 30,
          f"coverage: {total} pixels, {drew} lines drawn, {missed} rejected")
    et.note(f"{drew} lines drawn ({total} pixels), {missed} rejected")
    sd.close()


def test_inside_lines_are_unclipped():
    """A line wholly in the view keeps its end points"""
    sd, cpu = booted()
    r = et.rnd(32)
    for _ in range(100):
        p1, p2 = (r.randrange(W), r.randrange(H)), (r.randrange(W), r.randrange(H))
        carry, ends, pix = draw(cpu, p1, p2)
        check(not carry and set(ends[:2] + ends[2:]) <= set(p1 + p2) and {ends[:2], ends[2:]} == {p1, p2},
              f"{p1} - {p2} came back as {ends}")
    sd.close()


def test_horizontal_and_vertical():
    """Exact spans, clamped to the view, including the DMA path (20 or more)"""
    sd, cpu = booted()
    r = et.rnd(33)
    for _ in range(120):
        horizontal = r.random() < 0.5
        if horizontal:
            y = r.randrange(-20, H + 20)
            xa, xb = r.randrange(-600, 600), r.randrange(-600, 600)
            carry, ends, pix = draw(cpu, (xa, y), (xb, y))
            lo, hi = max(0, min(xa, xb)), min(W - 1, max(xa, xb))
            exp = {(x, y) for x in range(lo, hi + 1)} if 0 <= y < H and lo <= hi else set()
        else:
            x = r.randrange(-20, W + 20)
            ya, yb = r.randrange(-300, 300), r.randrange(-300, 300)
            carry, ends, pix = draw(cpu, (x, ya), (x, yb))
            lo, hi = max(0, min(ya, yb)), min(H - 1, max(ya, yb))
            exp = {(x, y) for y in range(lo, hi + 1)} if 0 <= x < W and lo <= hi else set()
        got = {(px, py) for _, px, py, _ in pix}
        check(got == exp, f"{'horizontal' if horizontal else 'vertical'} line {ends}: drew {len(got)} pixels, expected {len(exp)} "
                          f"(missing {sorted(exp - got)[:4]}, extra {sorted(got - exp)[:4]})")
        check(bool(carry) == (not exp), f"carry {carry} with {len(exp)} pixels to draw")
    for x, y in ((0, 0), (255, 127), (17, 99), (-1, 5), (5, 128)):
        carry, ends, pix = draw(cpu, (x, y), (x, y))
        exp = {(x, y)} if 0 <= x < W and 0 <= y < H else set()
        check({(px, py) for _, px, py, _ in pix} == exp, f"single point ({x}, {y})")
    sd.close()


def test_draw_diagonal():
    """l2_draw_diagonal (the launch tunnel, hyperspace lightning, l2_draw_any_line): unclipped on the full 256 x 192
    screen, exactly the L2LDiagonal Bresenham, in the colour passed in A (it once drew in line_gfx_colour, 4-connected,
    with up to 70% extra pixels and often a missing end), line_gfx_colour left as it was"""
    sd, cpu = booted()
    r = et.rnd(34)
    for n in range(300):
        x0, x1 = r.randrange(256), r.randrange(256)
        y0, y1 = r.randrange(192), r.randrange(192)
        if x0 == x1 or y0 == y1:
            continue
        clear(cpu)
        et.wr(cpu, "line_gfx_colour", 0x11)
        colour = r.choice((0x80, 0xCC, 0xFF, 0x1C))
        et.call(cpu, "l2_draw_diagonal", b=y0, c=x0, d=y1, e=x1, a=colour)
        pix = drawn(cpu)
        got = {(x, y) for _, x, y, _ in pix}
        exp = bresenham(x0, y0, x1, y1)
        check(got == exp, f"({x0}, {y0}) to ({x1}, {y1}): {len(got)} pixels, expected {len(exp)} "
                          f"(missing {sorted(exp - got)[:4]}, extra {sorted(got - exp)[:4]})")
        check(all(v == colour for *_, v in pix), f"({x0}, {y0}) to ({x1}, {y1}): not all colour {colour:02X}")
        check(et.rd(cpu, "line_gfx_colour") == 0x11, "line_gfx_colour changed")
    sd.close()


def test_horz_line_spans_and_single_pixels():
    """l2_draw_horz_line (b = row, c = column, d = length, e = colour): exactly d pixels, the short ones (under 10, by
    CPU) clipped at column 255, the long ones by DMA; and the single pixel paths of it, l2_draw_horz_line_to,
    l2_draw_vert_line and l2_draw_any_line plot in the colour passed in, not line_gfx_colour"""
    sd, cpu = booted()
    r = et.rnd(35)
    for n in range(300):
        row, col, ln = r.randrange(192), r.randrange(256), r.choice((r.randrange(1, 12), r.randrange(10, 120)))
        if ln >= 10 and col + ln > 256:
            continue                        # (the DMA path isn't clipped: callers keep inside the row)
        clear(cpu)
        et.wr(cpu, "line_gfx_colour", 0x11)
        et.call(cpu, "l2_draw_horz_line", b=row, c=col, d=ln, e=0xCC)
        pix = drawn(cpu)
        exp = {(x, row) for x in range(col, min(col + ln, 256))}
        check({(x, y) for _, x, y, _ in pix} == exp, f"row {row} col {col} length {ln}: {len(pix)} pixels, expected {len(exp)}")
        check(all(v == 0xCC for *_, v in pix), f"row {row} col {col} length {ln}: colour")
    for name, regs in (("l2_draw_horz_line", dict(d=1, e=0xCC)), ("l2_draw_horz_line_to", dict(d=40, e=0xCC)),
                       ("l2_draw_vert_line", dict(d=1, e=0xCC)), ("l2_draw_any_line", dict(d=70, e=40, a=0xCC))):
        clear(cpu)
        et.wr(cpu, "line_gfx_colour", 0x11)
        et.call(cpu, name, b=70, c=40, **regs)
        pix = drawn(cpu)
        check([(x, y, v) for _, x, y, v in pix] == [(40, 70, 0xCC)], f"{name} single pixel: {pix}")
    sd.close()


def l2_320_pages(cpu):
    return [cpu.page(cpu.nextreg.get(0x12, 8) * 2 + k) for k in range(10)]


def drawn_320(cpu):
    """{(x, y)} set in the 320 x 256 Layer 2 (column major: x * 256 + y)"""
    return {((k * 8192 + o) >> 8, (k * 8192 + o) & 255) for k, p in enumerate(l2_320_pages(cpu)) for o, v in enumerate(p) if v}


def test_320_lines():
    """The menus' 320 x 256 lines: l2_draw_horz_line_320 (b = row, hl = column, de = length) and
    l2_draw_vert_line_320 (e = length) draw exactly the length (the horizontal one once drew one more, the callers
    allowed for it) clipped at column 319 / row 255 (the horizontal once wrapped to column 0, the vertical spilled into
    the next column)"""
    sd, cpu = booted()
    r = et.rnd(36)
    for n in range(250):
        row, col = r.randrange(256), r.randrange(320)
        for p in l2_320_pages(cpu):
            p[:] = bytes(8192)
        if n % 2:
            ln = r.choice((1, 2, r.randrange(1, 340)))
            et.call(cpu, "l2_draw_horz_line_320", b=row, hl=col, de=ln, c=0xC0)
            exp = {(x, row) for x in range(col, min(col + ln, 320))}
        else:
            ln = r.choice((1, 2, r.randrange(1, 256)))
            et.call(cpu, "l2_draw_vert_line_320", b=row, hl=col, e=ln, c=0xC0)
            exp = {(col, y) for y in range(row, min(row + ln, 256))}
        got = drawn_320(cpu)
        check(got == exp, f"{'horizontal' if n % 2 else 'vertical'} row {row} col {col} length {ln}: {len(got)} pixels, "
                          f"expected {len(exp)} (extra {sorted(got - exp)[:3]}, missing {sorted(exp - got)[:3]})")
    sd.close()


def test_draw_any_line():
    """l2_draw_any_line (the planet's lines): horizontal, vertical, diagonal and single points on the full 256 x 192
    screen, both ends drawn, in the colour passed in A (horizontal and vertical lines once came out as one pixel:
    its same row / same column tests were the wrong way round)"""
    sd, cpu = booted()
    r = et.rnd(37)
    for n in range(300):
        x0, y0 = r.randrange(256), r.randrange(192)
        kind = n % 4
        x1 = x0 if kind in (1, 3) else r.randrange(256)
        y1 = y0 if kind in (0, 3) else r.randrange(192)
        clear(cpu)
        et.wr(cpu, "line_gfx_colour", 0x11)
        et.call(cpu, "l2_draw_any_line", b=y0, c=x0, d=y1, e=x1, a=0xCC)
        pix = drawn(cpu)
        got = {(x, y) for _, x, y, _ in pix}
        if y0 == y1:
            exp = {(x, y0) for x in range(min(x0, x1), max(x0, x1) + 1)}
            if len(exp) == 256:
                exp.discard((255, y0))      # (0 to 255 is drawn as 255 pixels: 256 doesn't fit the length)
        elif x0 == x1:
            exp = {(x0, y) for y in range(min(y0, y1), max(y0, y1) + 1)}
        else:
            exp = bresenham(x0, y0, x1, y1)
        check(got == exp, f"({x0}, {y0}) to ({x1}, {y1}): {len(got)} pixels, expected {len(exp)} "
                          f"(missing {sorted(exp - got)[:4]}, extra {sorted(got - exp)[:4]})")
        check(all(v == 0xCC for *_, v in pix), f"({x0}, {y0}) to ({x1}, {y1}): colour")
    sd.close()


def test_equip_screen_320_and_hyperspace_256():
    """The equip ship screen (Delete, was C) is a 320 x 256 single buffered menu like the charts: border, title, the
    list from the equipment tables (in main memory: in their own slot 7 bank the galaxy's code was read instead), the
    selected row in $BC and the rest in $FF, the highlight following the cursor. The hyperspace screen switches Layer 2
    back to 256 x 192 when a countdown ends on a 320 x 256 chart. (nexsim has no ROM font: the test gives it solid blocks
    so a printed character's cell shows its colour)"""
    sd, cpu = booted()
    et.page_in(cpu, 7, sym["BankKeyboard"])
    check(et.rd(cpu, sym["KeyboardMap"] + sym["c_Pressed_Equip"], 2) == sym["Keys"] + sym["VK_DELETE"], "equip isn't on Delete")
    rom = cpu.page(0xFF)
    for c in range(32, 128):
        for k in range(8):
            rom[(sym["charactersetaddr"] + 8 * c + k) & 0x1FFF] = 0xFF
    pages = l2_320_pages(cpu)

    def px(x, y):
        a = x * 256 + y
        return l2_320_pages(cpu)[a >> 13][a & 0x1FFF]
    for chart in ("ScreenGalactic", "ScreenLocal"):
        et.call(cpu, "SetScreenA", a=sym[chart])
        et.call(cpu, "SetScreenA", a=sym["ScreenEquip"])
        mode = (cpu.nextreg.get(0x70, 0) >> 4) & 3
        check(mode == 1 and et.rd(cpu, "varL2_BUFFER_MODE") == 0, f"equip after {chart}: mode {mode}, buffer mode {et.rd(cpu, 'varL2_BUFFER_MODE')}")
        top = sym["eqshp_ListTop"]
        check(px(9, top + 2) == sym["eqshp_HighColour"], f"row 0 colour {px(9, top + 2):02X}")
        check(px(9, top + 10) == sym["eqshp_TextColour"], f"row 1 colour {px(9, top + 10):02X}")
        check(px(9, 4) == sym["eqshp_TextColour"] and px(9, sym["eqshp_CashRow"] + 2) == sym["eqshp_TextColour"], "title or cash missing")
        check(px(1, 100) != 0xE3, "no border")
    page = cpu.page(sym["BankMenuEquipS"])
    rows = []
    for r in range(4):
        a = sym["eqship_display_buffer"] - 0xC000 + r * sym["eqship_buffer_row_len"]
        rows.append(bytes(page[a:a + 20]).split(b"")[0].strip().decode("latin-1"))
    check(rows == ["Fuel", "Missile", "Large Cargo Bay", "E.C.M. System"], f"equip list {rows}")
    et.call(cpu, "eqshp_DownPressed", mmu={6: sym["BankMenuEquipS"]})
    top = sym["eqshp_ListTop"]
    check(px(9, top + 2) == sym["eqshp_TextColour"] and px(9, top + 10) == sym["eqshp_HighColour"],
          f"after down: rows {px(9, top + 2):02X} {px(9, top + 10):02X}")
    for chart in ("ScreenGalactic", "ScreenLocal"):
        et.call(cpu, "SetScreenA", a=sym[chart])
        et.call(cpu, "SetScreenA", a=sym["ScreenHyperspace"])
        mode = (cpu.nextreg.get(0x70, 0) >> 4) & 3
        check(mode == 0 and cpu.l2clip == [0, 255, 0, 192], f"hyperspace after {chart}: mode {mode}, clip {cpu.l2clip}")
    sd.close()

def fill_model(pts):
    """l2_fill_convex_polygon's pixels in Python: each edge's rows clipped to 0-127, x(y) = xa + sign * floor((y - ya) *
    |dx| / dy), each row from its smallest to its largest x, clipped to 0-255"""
    ys = [y for x, y in pts]
    if max(ys) < 0 or min(ys) > 127:
        return set()
    if min(ys) == max(ys):                                  # flat: the row from the smallest to the largest x
        xs = [x for x, y in pts]
        return {(x, ys[0]) for x in range(max(min(xs), 0), min(max(xs), 255) + 1)}
    top, bot = max(min(ys), 0), min(max(ys), 127)
    left, right = {}, {}
    n = len(pts)
    for i in range(n):
        (xa, ya), (xb, yb) = pts[i], pts[(i + 1) % n]
        if ya == yb:
            continue
        if ya > yb:
            xa, ya, xb, yb = xb, yb, xa, ya
        if yb < top or ya > bot:
            continue
        ys_, ye = max(ya, top), min(yb, bot)
        dy, s, adx = yb - ya, (1 if xb >= xa else -1), abs(xb - xa)
        q, r = divmod(adx, dy)
        k = ys_ - ya
        x, err = xa + s * (k * adx // dy), (k * adx) % dy
        for y in range(ys_, ye + 1):
            left[y] = min(left.get(y, 32767), x)
            right[y] = max(right.get(y, -32768), x)
            err += r
            step = q
            if err >= dy:
                err -= dy
                step += 1
            x += s * step
    out = set()
    for y in range(top, bot + 1):
        if y not in left or right[y] < 0 or left[y] > 255:
            continue
        for x in range(max(left[y], 0), min(right[y], 255) + 1):
            out.add((x, y))
    return out


def convex(r, n, cx, cy, rad):
    import math
    angles = sorted(r.uniform(0, 2 * math.pi) for _ in range(n))
    if r.random() < 0.5:
        angles = angles[::-1]                               # either winding
    return [(int(cx + rad * math.cos(a) * r.uniform(0.6, 1.4)), int(cy + rad * math.sin(a))) for a in angles]


def test_fill_convex_polygon():
    """l2_fill_convex_polygon (solid ships, Layer2Graphics/l2_fill_polygon.asm): exactly the model's pixels in the
    colour given, nothing outside rows 0-127 or the other buffer, for random convex polygons of 3 to 8 points either way
    round, on and partly or wholly off screen (out to +-16000), and thin and degenerate ones"""
    import math
    sd, cpu = booted()
    r = et.rnd(40)
    pts_addr = sym["TextBuffer"]
    cases = [[(10, 10), (60, 10), (35, 50)], [(0, 0), (255, 0), (255, 127), (0, 127)], [(-50, -50), (400, -50), (400, 300), (-50, 300)],
             [(100, 20), (101, 20), (101, 90)], [(5, 5), (5, 5), (5, 5)], [(-16000, 60), (16000, 50), (16000, 70)],
             [(50, -16000), (60, 16000), (70, 16000)], [(300, 10), (400, 10), (350, 50)], [(10, 200), (50, 200), (30, 250)],
             [(10, 50), (40, 50), (25, 50)], [(-20, 60), (300, 60), (100, 60), (5, 60)], [(0, 0), (255, 0), (30, 0)],
             [(-90, 127), (-10, 127), (-50, 127)], [(260, 3), (900, 3), (300, 3)], [(70, -1), (90, -1), (80, -1)]]
    for n in range(400):
        rad = r.choice((5, 20, 60, 150, 600, 4000))
        cases.append(convex(r, r.randrange(3, 9), r.randrange(-200, 460), r.randrange(-150, 280), rad))
    for pts in cases:
        clear(cpu)
        for i, (x, y) in enumerate(pts):
            et.wr(cpu, pts_addr + 4 * i, x & 0xFFFF, 2)
            et.wr(cpu, pts_addr + 4 * i + 2, y & 0xFFFF, 2)
        et.call(cpu, "l2_fill_convex_polygon", ix=pts_addr, b=len(pts), a=0x5A)
        pix = drawn(cpu)
        got = {(x, y) for _, x, y, _ in pix}
        exp = fill_model(pts)
        check(got == exp, f"{pts}: {len(got)} pixels, expected {len(exp)} (extra {sorted(got - exp)[:4]}, missing {sorted(exp - got)[:4]})")
        check(all(v == 0x5A for *_, v in pix), f"{pts}: colour")
    sd.close()


if __name__ == "__main__":
    et.main(globals())
