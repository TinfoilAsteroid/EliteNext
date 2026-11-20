# Solid hulls: a proposal

Status (2026-11-20): steps 1 to 4 are built, behind `SOLID_HULL` (commented out in eliteNext.asm, so the normal build
is unchanged). The options, all in eliteNext.asm:

| Option | What it does |
|---|---|
| `SOLID_HULL` | Ships with a face table are drawn filled |
| `SOLID_OUTLINES ALL` | Every visible edge is drawn over the fill |
| `SOLID_OUTLINES DECORATION` | Only the visible decoration edges (both faces the same: vents, engines, markings) are drawn over the fill |
| `SOLID_OUTLINES` not defined | No lines over the fill |
| `WIREFRAME_FALLBACK` | A ship whose z is less than `WIREFRAME_DISTANCE` is drawn as wireframe |
| `WIREFRAME_DISTANCE` | An equate, S15.8 (1.0 = 256). Now `256/10` (0.1), to be tuned on real hardware |

Any other `SOLID_OUTLINES` value stops the build.

- Tools/ship_faces.py writes the face tables into Data/ships/*.asm. 34 of 44 models have one; the Missile's has its
  four fins as polygons of their own (fix A, TODO.md), and the two Cobra Mk 3s' nose lines are lone lines (fix C). The
  other 10 stay wireframe: 8 whose faces don't close
  (listed for review in TODO.md, one item a model) and Plate and TestVector,
  which have no faces.
- The face table: DB the number of records, then per record DW a mask (bit f = face f: the polygon is drawn when any of
  those faces faces us), DB n, and n vertex offsets. A face's mask is its own bit; a fin's is the faces its edges are on.
  After the records, the phase 2 polygons (ports: Tools/ship_faces.py PORTS: the Cobra Mk 3 and Mk 3 P engines, the
  Coriolis and Dodo entrances): DB the number, then per port DW mask, DB type (PortEngine dark grey, PortEntrance
  black), n and n vertex offsets, filled after every hull face in table order, so the hull never paints over them.
  Then the lone lines: DB the number, then per line DW a mask (its two faces) and its two vertex offsets.
  SolidHullDraw draws the visible ones over the fill, unless SOLID_OUTLINES ALL has drawn every edge already.
- l2_fill_convex_polygon (Layer2Graphics/l2_fill_polygon.asm) fills a face; a flat face (every point on one row) is
  that row, so a ship a pixel high doesn't vanish.
- SolidHullDraw (Layer2Graphics/l2_solid_hull.asm) is called from ProcessShip after CullV2. It paints the visible faces
  furthest first, each face's depth being its furthest vertex. It falls back to wireframe when a vertex is at or behind
  the camera, or (with WIREFRAME_FALLBACK) when its z is less than WIREFRAME_DISTANCE.
- SortShipsFurthestFirst (GameEngine/UpdateUniverseObjects.asm) draws the ships furthest first (see decision 4).
- The attract screen (Menus/AttractMode.asm) draws its ship through SolidHullDraw too, with the same wireframe fallback.
- Tests: Tools/test_lines.py test_fill_convex_polygon (pixel for pixel), and Tools/test_solid_hull.py, which assembles
  SOLID_HULL builds in a temporary folder. It checks:
  - the face tables are current;
  - every model drawn through ProcessShip in random orientations is solid, uses only its colours, stays in the view and
    covers its wireframe;
  - SOLID_OUTLINES ALL draws every wireframe pixel over the fill;
  - SOLID_OUTLINES DECORATION draws exactly the visible decoration edges;
  - the wireframe falls back behind the camera and at WIREFRAME_DISTANCE;
  - the ships are sorted furthest first.

Still open: decision 2 (the TODO.md items), decision 5 (colours, for later), decision 6 (the distance, on hardware),
the planet and sun in the draw order (decision 4), and the rest of step 5 (DMA+ on hardware, tuning).

The proposal as written follows.

When `SOLID_HULL` is defined, ships should be drawn with filled faces. To start with, each face gets its own test
colour.

## What we have now

**The models** (Data/ships/*.asm, 45 files; BBC Elite format):

- Vertices (6 bytes each): x, y and z with their signs, a visibility distance, and up to four faces (nibbles).
- Edges (4 bytes each): a visibility distance, the two faces on either side, and the two end vertices.
- Face normals (4 bytes each): the sign and visibility byte, then x, y and z.
- The header already has three unused fields for this (ShipModelEquates.asm offsets 27 to 29):
  `ShipSolidFlagOffset` (the flag, $FF in every model, meaning "not supported"), `ShipSolidFillOffset` (a pointer
  to the solid data) and `ShipSolidLenOffset` (its length).

**There are no face polygons.** A face is only a normal plus the edges that name it. To fill a face, its vertex loop
has to be rebuilt.

**I analysed every model** (with a script that reads the .asm files):

| | |
|---|---|
| Faces (counting every normal) | 390 |
| Faces whose edges chain into one closed loop | 357, and all 357 are convex |
| Faces that don't close | 33, in 11 models: Adder, Asp, Cobra Mk 1, Cobra Mk 3 P, Cougar, Iguana, Krait, Logo, Missile, Ophidian and Python_P. The BBC models aren't closed solids: some faces have boundary edges missing, or include "detail" vertices |
| Decoration edges (both faces the same: engine markings, the Cobra's vents) | 0 to 27 per model. These aren't face boundaries; they can be drawn as lines over the fill |
| Largest polygon | 8 vertices (Thargoid) |
| Triangles if every face were split into a fan | 544 |
| Loops wound clockwise about their normal | 179. The tool would reverse those |
| Loops off their own plane by more than 3 units | 26 (rounding in the 8-bit model data). Harmless for 2D filling |

The vertex face nibbles aren't a reliable source: 147 faces have fewer than three vertices that list them, because
BBC Elite only uses those nibbles to decide which vertices are visible.

**The pipeline** (ProcessShip in univ_ship_data.asm):

1. **ProcessNodes:** rotates and projects every vertex to screen x and y (16 bit, so off-screen values are kept) in
   `UBnkNodeArray`. Depth isn't kept: z is scaled and clamped to at least 4, used for the projection, then dropped.
2. **CullV2:** an exact 24-bit backface test per face, written to `UbnkFaceVisArray`.
3. **PrepLines:** collects the edges whose faces are visible.
4. **DrawLinesLateClipping:** draws them with l2_draw_6502_line, clipped to the 256 x 128 view, double buffered.

**Memory left:**

| Bank | Free bytes |
|---|---|
| Universe A (each ship's bank) | 760, or 360 with `SOLID_HULL`'s `UBnkHullSolid` (400) |
| BankLAYER2 (the line and fill code) | 3843 |
| Ship models 1, 2 and 3 | 3353, 3862 and 4956 |
| Main memory | 899 |

## Proposal

### 1. Face data, made offline by a tool (no hand editing)

**A tool,** Tools/ship_faces.py, run by build.bat next to sprite_writer.py:

- **Polygons:** for each model it rebuilds each face's polygon from the edges: it chains the edges that name the face
  into a loop, leaving out decoration edges.
- **Winding:** it orders the loop anticlockwise about the face's normal, so the filler never has to test which way a
  polygon is wound.
- **Faces that don't close:** it falls back to the convex hull of the face's vertices in the face's plane (the vertices
  of its edges, plus the vertices that list it). It reports what it did.
- **Colours:** each face gets a test colour from a table (8 to 16 clearly different colours, by face number).
- **Output:** a data file per model, Data/ships/faces/<Ship>Faces.asm, included next to the model.

**The face table:** one record per face, in the same order as the normals:

```
<Ship>Faces:    DB  count, colour, v0*4, v1*4, ... v(count-1)*4     ; vertex offsets, as the edges store them (x4)
                ...
<Ship>FacesSize equ $ - <Ship>Faces
```

It averages about 6 bytes a face, roughly 80 bytes a ship, and about 4K for all 45, spread over the three model banks,
which have 12K free between them.

**The header:** the three existing fields become the flag ($00 = has faces), the pointer and the length. Copying a ship
into its universe bank copies the faces too, as it copies the edges and normals now, into `UBnkHullSolid` (400 bytes
is enough).

**Why convex polygons rather than triangles:** every closed face is already convex. Filling a convex n-gon walks n
edges; splitting it into triangles walks 3(n - 2) edges, with n - 2 times the per-polygon setup and shared edges walked
twice. A convex polygon filler handles triangles too, so nothing is lost. Splitting into triangles or rectangles would
only pay off with a hardware or DMA+ trapezoid fill, which we don't have.

**Test:** Tools/test_ship_faces.py checks the following for every model:

- each face loop is closed;
- it is wound anticlockwise about its normal;
- it is convex in its plane;
- every vertex number is in range;
- the table matches what the build has.

### 2. Projecting depth

ProjectNodeToEye stores each vertex's scaled z beside x and y, in the unused `UBnkNodeArray2` (40 x 4). It's needed for
two things:

- **Behind the camera:** a face with a vertex at z <= 0 (or at the clamp) can't be filled by projecting, because the
  projected point is meaningless. For a start, such faces are drawn as wireframe; a near-plane clip in 3D could come
  later. The wireframe drawing has the same problem today, but lines hide it better.
- **Ordering faces** (step 4).

### 3. The polygon filler (BankLAYER2, about 1K of code)

`l2_fill_convex_polygon`: the input is a list of up to 8 screen points (16-bit x, y) and a colour; it draws into the
256 x 128 view:

- **Top and bottom:** it finds the polygon's top and bottom vertices, and clips them to rows 0 to 127.
- **Edge walking:** it walks the left chain and the right chain down from the top, with x in 8.8 fixed point stepping
  by dx/dy, one divide per edge. An edge starting above row 0 is stepped down to row 0 first.
- **Spans:** for each row it clips the span to columns 0 to 255 and draws it with the existing span code. That is
  l2_draw_horz_line (by CPU under 10 pixels, by DMA above), or, in the REAL_HARDWARE build, with DMA+ fill.
- **Covering:** spans include their end pixels, so neighbouring faces meet with no gaps between them.

The work buffer is the 8 points plus the edge steppers, under 100 bytes, in BankLAYER2.

**Test:** a test against a Python rasteriser with the same rules (exactly the same pixels), on random convex
polygons including ones partly or wholly off screen. It is the same approach as test_lines.py.

### 4. Drawing order

- **Convex hulls:** backface culling alone is enough, because no two visible faces overlap. Most Elite ships are
  convex: every face is a convex polygon, and the hulls are nearly convex.
- **Non-convex hulls:** these need back-to-front ordering, the painter's algorithm. The Cobra Mk 3's wings, the
  Asp's fins, the Thargoid, the Coriolis slot and decorated faces can all overlap from some angles. The faces are
  sorted by depth (the furthest vertex z of each visible face) with an insertion sort. There are at most 15 faces, so
  this is about 1,000 T.
- **Suggested:** sort only for models the tool marks as non-convex (a flag bit in the header), and leave the rest
  unsorted.

### 5. Wiring it in (univ_ship_data.asm, under `IFDEF SOLID_HULL`)

ProcessShip, after CullV2:

```
IFDEF SOLID_HULL
    if ShipSolidFlag says the model has faces:
        FillVisibleFaces    ; sort if needed, then for each visible face: gather its projected points, fill
        (optionally) draw the decoration edges, and/or the visible edges, as lines over the fill
    else:
        the wireframe as now
ELSE
    the wireframe as now
ENDIF
```

The following stay as they are: dots (far ships), explosions (debris), the planet (already solid), the sun and the
scanner.

### 6. Speed (estimates, to confirm with the emulator)

| | Cost |
|---|---|
| Per face: setup, plus one divide per edge | about 1,500 T |
| Per span (row) by DMA | about 400 T, plus 2 T a pixel |
| Per span by CPU (under 10 pixels) | about 24 T a pixel |

- **A typical ship** (80 x 50 pixels, 4 visible faces, about 120 spans): about 60,000 to 70,000 T. That's about 12% of
  a 50 Hz frame at 28 MHz, compared with roughly 20,000 to 30,000 T for its wireframe.
- **A near ship** filling the view (256 x 128, about 500 spans): about 250,000 T, half a frame. The space station close
  up is the worst case.
- **If it's too slow:** wireframe beyond a distance (the "all faces" distance already exists), DMA+ fill on hardware,
  or skipping very small faces.

### 7. Colours

- **First (as you asked):** a test colour per face from the tool's table.
- **Later:** a colour per face in the model data, and/or flat shading by brightness from the rotated normal's z, which
  CullV2 nearly has already (a palette ramp per colour). The planet's palette set-up shows how.

### 8. Steps, each with its tests

1. Tools/ship_faces.py, the face tables, the header flag and the copy into the universe bank; test_ship_faces.py. With
   `SOLID_HULL` off, nothing changes.
2. l2_fill_convex_polygon and its rasteriser test.
3. z kept per node, and FillVisibleFaces wired in with test colours, convex ordering only. An attract mode run with
   `SOLID_HULL`, rendering every ship through a few orientations, checking no crash and that the fill stays inside
   the view.
4. Faces behind the camera fall back to wireframe; depth sorting for non-convex models.
5. Outlines, colours and shading, DMA+ on hardware, tuning.

Steps 1 and 2 can be done and tested before any change to the drawing.

## Decisions for you

Answered 2026-11-20, except where marked open.

1. **Polygons or triangles: convex polygons.** As built.
2. **Faces that don't close: for review.** Each of the 11 models is a TODO.md item, with each face's open ends and
   branches and a suggested fix. They stay wireframe until then.
3. **Outlines: the `SOLID_OUTLINES` define.** `ALL` draws every visible edge over the fill, `DECORATION` only the
   decoration edges, and not defined draws none. Built and tested.
4. **Ordering: two different orders.** This decision was about the first; the second matters just as much for solid
   ships.
   - **Face order within one ship** (SolidHullDraw). On a convex hull the faces turned towards us never overlap on
     screen, so they can be painted in any order and the picture is the same. On a hull that isn't convex (the Cobra
     Mk 3's wings, the Asp's fins, the Thargoid, the Coriolis slot), two faces turned towards us can overlap. The
     nearer one must then be painted last, so the faces are sorted furthest first. "Non-convex models only" would mark
     those models in the tool and sort only them. "Every model" sorts always, which is what is built now.
     Measured in the emulator, at z 5.0: the sort takes 2,000 to 14,000 T a ship, 0.6% to 1.5% of drawing it (the
     whole draw is 270,000 to 830,000 T, mostly the fill). A convexity flag would save about 1%, and would risk a
     model wrongly marked convex. **Suggested: keep sorting every model.** One limit: a face's depth is its furthest
     vertex. That can still give the wrong order for long faces that overlap, but should be fine for Elite's models.
     Check it by eye.
   - **Ship order across the view** (SortShipsFurthestFirst, built). Wireframe ships can be drawn in any order, but a
     solid ship drawn after a nearer one paints over it. So each frame the visible ships are drawn furthest first:
     dots first, then by z largest first, ships behind the camera last. The depth is the distance along the view's
     own axis. That is z for the front view (and -z for the rear view, when it draws its own ships). For the left and
     right views it is x, not y: y is up, and would be the depth only for an up or down view, which Elite doesn't
     have.
   - **Still open: the planet and the sun.** They are drawn before every ship (MainLoop: SunUpdateAndRender, then
     PlanetUpdateAndRender, then the ships). So a ship behind the planet is drawn over it, and the sun is always
     under the planet. For this to be right they need to go into the same furthest-first order as the ships, with
     their z.
5. **Colours: open, to review later.** Test colours by face number for now.
6. **Wireframe fallback: open, to tune on real hardware.** `WIREFRAME_FALLBACK` turns it on, and `WIREFRAME_DISTANCE`
   (now 0.1) is the cut-off for testing. Measured head-on in the emulator, the smallest ships (Gecko, Viper, Worm)
   already have a vertex behind the camera, and so are wireframe anyway, nearer than z 0.11. Larger ships are
   wireframe nearer than 0.2 to 1.0 (the Coriolis 0.65, the Dragon 1.0). So at 0.1 the fallback makes almost no
   difference. A useful cut-off will be larger: whatever distance the hardware shows the fill of a near ship gets
   too slow.
