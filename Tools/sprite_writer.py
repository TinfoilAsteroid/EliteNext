"""Writes the sprite pattern files the game loads at start up (replaces
SpriteWriter.asm, which had to be run in CSpect to write them).

load_pattern_files (Layer3Sprites/sprite_load.asm) reads NESpr01.dat ..
NESprNN.dat (NN = its SpriteCount, numbered in decimal), 256 bytes each: one
16x16 sprite pattern, 8 bits a pixel, $E3 transparent.  They are the first
SpriteCount patterns of the sprite editor's sheet, Layer3Sprites/SpriteSheet.SPR
(64 patterns of 256 bytes).

usage: python Tools/sprite_writer.py [--check] [folder ...]
  folder   where to write the files (default: the project folder, where
           CSpect's -mmc=.\\ SD card is; build.bat also copies them to Build)
  --check  write nothing: exit 1 if a folder's files differ from the sheet
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHEET = os.path.join(ROOT, "Layer3Sprites", "SpriteSheet.SPR")
LOADER = os.path.join(ROOT, "Layer3Sprites", "sprite_load.asm")
PATTERN = 256


def sprite_count():
    """SpriteCount from sprite_load.asm, so the files always match what it loads"""
    for line in open(LOADER, encoding="latin-1"):
        m = re.match(r"\s*SpriteCount\s+EQU\s+(\$?[0-9A-Fa-f]+)", line, re.I)
        if m:
            v = m.group(1)
            return int(v[1:], 16) if v.startswith("$") else int(v)
    raise SystemExit(f"no SpriteCount in {LOADER}")


def patterns():
    """[(file name, 256 bytes)] for the files the game loads"""
    data = open(SHEET, "rb").read()
    n = sprite_count()
    if len(data) % PATTERN or len(data) // PATTERN < n:
        raise SystemExit(f"{SHEET}: {len(data)} bytes, not {n} patterns of {PATTERN}")
    return [(f"NESpr{i:02d}.dat", data[(i - 1) * PATTERN:i * PATTERN]) for i in range(1, n + 1)]


def write(folder):
    os.makedirs(folder, exist_ok=True)
    for name, data in patterns():
        path = os.path.join(folder, name)
        if not os.path.exists(path) or open(path, "rb").read() != data:     # (don't touch unchanged files)
            with open(path, "wb") as f:
                f.write(data)


def check(folder):
    bad = [name for name, data in patterns()
           if not os.path.exists(os.path.join(folder, name)) or open(os.path.join(folder, name), "rb").read() != data]
    return bad


def main():
    args = sys.argv[1:]
    checking = "--check" in args
    folders = [a for a in args if a != "--check"] or [ROOT]
    status = 0
    for folder in folders:
        if checking:
            bad = check(folder)
            if bad:
                print(f"{folder}: {len(bad)} sprite files differ from {os.path.basename(SHEET)}: {', '.join(bad[:8])}")
                status = 1
        else:
            write(folder)
            print(f"sprite_writer: {len(patterns())} pattern files in {folder}")
    sys.exit(status)


if __name__ == "__main__":
    main()
