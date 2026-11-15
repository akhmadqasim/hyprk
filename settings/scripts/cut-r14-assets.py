#!/usr/bin/env python3
"""Glyphs and pictures of macOS 27.2.1 that are in no symbol or icon set of the repo, cut from the round 14 stills
(reference/re/27.2.1/live/settings-r14, MAC-ANSWERS-14.md R14.4, R14.5) into settings/assets/r14/.

Grey glyphs (the microphone with its level dots at both ends of Sound > Input volume, the two waves at the ends of
the voice sheet's Pitch slider, the Colours panel's eyedropper) become a mask: white (-dark) or black (-light) with
the alpha the glyph has over the card on the dark still. The Colours panel's five mode pictures keep their colours;
the panel's own fill around them is taken out.

Run from the repository root: python3 settings/scripts/cut-r14-assets.py
"""
import os
from collections import deque

from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SRC = os.path.join(ROOT, "reference/re/27.2.1/live/settings-r14")
OUT = os.path.join(ROOT, "settings/assets/r14")

MASKS = {   # name: (still, box in px)
    "mic-low": ("sound-input-dark.png", (926, 1085, 960, 1117)),
    "mic-high": ("sound-input-dark.png", (1387, 1085, 1421, 1117)),
    "pitch-low": ("acc-read-speak--voice-info-dark.png", (1020, 486, 1060, 514)),
    "pitch-high": ("acc-read-speak--voice-info-dark.png", (1400, 486, 1440, 514)),
    "eyedropper": ("acc-display--colour-well-dark.png", (50, 1248, 92, 1288)),
}
PICTURES = {   # the Colours panel's toolbar, 48 px each
    "colors-wheel": (66, 562, 114, 610),
    "colors-sliders": (154, 562, 202, 610),
    "colors-palettes": (242, 562, 290, 610),
    "colors-image": (330, 562, 378, 610),
    "colors-pencils": (418, 562, 466, 610),
}


def lum(p):
    return (p[0] * 299 + p[1] * 587 + p[2] * 114) / 1000


def mask(still, box):
    im = Image.open(os.path.join(SRC, still)).convert("RGB").crop(box)
    px = im.load()
    w, h = im.size
    bg = lum(px[0, 0])
    res = {}
    for name, ink, k in (("dark", (255, 255, 255), 1.0), ("light", (0, 0, 0), 0.5 / 0.55)):
        out = Image.new("RGBA", (w, h))
        o = out.load()
        for y in range(h):
            for x in range(w):
                a = max(0.0, min(1.0, (lum(px[x, y]) - bg) / (255 - bg))) * k
                o[x, y] = ink + (round(a * 255) if a > 0.02 else 0,)
        res[name] = out
    return res


def picture(box):
    im = Image.open(os.path.join(SRC, "acc-display--colour-well-dark.png")).convert("RGB").crop(box)
    px = im.load()
    w, h = im.size
    bg = px[0, 0]
    seen = [[False] * w for _ in range(h)]
    q = deque([(x, y) for x in range(w) for y in (0, h - 1)] + [(x, y) for y in range(h) for x in (0, w - 1)])
    while q:
        x, y = q.popleft()
        if x < 0 or y < 0 or x >= w or y >= h or seen[y][x] or sum(abs(px[x, y][i] - bg[i]) for i in range(3)) > 36:
            continue
        seen[y][x] = True
        q.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))
    out = Image.new("RGBA", (w, h))
    o = out.load()
    for y in range(h):
        for x in range(w):
            o[x, y] = px[x, y] + (0 if seen[y][x] else 255,)
    return out


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, (still, box) in MASKS.items():
        for mode, img in mask(still, box).items():
            img.save(os.path.join(OUT, f"{name}-{mode}.png"), optimize=True)
    for name, box in PICTURES.items():
        picture(box).save(os.path.join(OUT, f"{name}.png"), optimize=True)
    print(len(MASKS) * 2 + len(PICTURES), "files ->", os.path.relpath(OUT, ROOT))


if __name__ == "__main__":
    main()
