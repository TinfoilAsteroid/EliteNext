"""Line clipping and drawing: l2_draw_6502_line, which draws every ship's
wireframe (DrawLinesLateClipping).  Replaces clipTst.asm.

Lines from -1024 to +1024 on each axis are drawn into the 256x128 view and
checked against a Python reference:
  * a line that misses the view draws nothing and returns carry; one that
    crosses it draws and returns no carry (lines within a pixel of an edge
    may go either way);
  * every pixel is in the view, within a pixel of the true line (across the
    line's major axis), one pixel per step along the major axis, from the
    returned (clipped) end point to the other;
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


if __name__ == "__main__":
    et.main(globals())
