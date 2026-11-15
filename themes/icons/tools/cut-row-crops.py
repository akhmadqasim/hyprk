#!/usr/bin/env python3
"""Row tiles cut from the Mac's own rows (macOS 27.2.1, MAC-ANSWERS-14.md R14.3).

reference/re/27.2.1/live/settings-r14/icon-<pane>-<row>-{dark,light}.png are 80 x 80 px crops (40 x 40 pt at 2x) of
the left end of a row. The tile in them: Privacy & Security 40 x 40 px at 12,20; Focus 52 x 52 px at 18,14 (measured
on all 39 light crops). This cuts the tile with its shadow, 4 px (Privacy) or 6 px (Focus) around it, and takes the
card's colour out: the tile's shape comes from the light crop (the dark tile on the #F7F7F7 card), what lies outside
it is kept as a black shadow of the strength the crop shows.

The Mac was on the Dark "Icon & widget style", so these are that style's tiles (settings/FALLBACKS.md).

Output: themes/icons/settings/crops/<id>-<light|dark>.png. Run from the repository root:
    python3 themes/icons/tools/cut-row-crops.py
"""
import os
import sys
from collections import deque

from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
SRC = os.path.join(ROOT, "reference/re/27.2.1/live/settings-r14")
OUT = os.path.join(ROOT, "themes/icons/settings/crops")

# id -> (pane, the crop's row name)
ROWS = {
    "privacy-fulldisk": ("privacyAndSecurity", "full-disk-access"),
    "privacy-passkeys": ("privacyAndSecurity", "passkeys-access-for-web-browsers"),
    "privacy-appmanagement": ("privacyAndSecurity", "app-management"),
    "privacy-automation": ("privacyAndSecurity", "automation"),
    "privacy-bluetooth": ("privacyAndSecurity", "bluetooth"),
    "privacy-developertools": ("privacyAndSecurity", "developer-tools"),
    "privacy-devicecontrol": ("privacyAndSecurity", "device-control-and-data-access"),
    "privacy-focus": ("privacyAndSecurity", "focus"),
    "privacy-inputmonitoring": ("privacyAndSecurity", "input-monitoring"),
    "privacy-localnetwork": ("privacyAndSecurity", "local-network"),
    "privacy-motion": ("privacyAndSecurity", "motion-fitness"),
    "privacy-remotedesktop": ("privacyAndSecurity", "remote-desktop"),
    "privacy-speech": ("privacyAndSecurity", "speech-recognition"),
    "privacy-sensitive": ("privacyAndSecurity", "sensitive-content-warning"),
    "privacy-blocked": ("privacyAndSecurity", "blocked-contacts"),
    "privacy-analytics": ("privacyAndSecurity", "analytics-improvements"),
    "privacy-advertising": ("privacyAndSecurity", "apple-advertising"),
    "privacy-aireport": ("privacyAndSecurity", "apple-intelligence-report"),
    "privacy-filevault": ("privacyAndSecurity", "filevault"),
    "privacy-accessories": ("privacyAndSecurity", "accessories"),
    "privacy-background": ("privacyAndSecurity", "background-security-improvements"),
    "focus-dnd": ("focus", "do-not-disturb"),
    "focus-driving": ("focus", "driving"),
    "focus-mindfulness": ("focus", "mindfulness"),
    "focus-reduce": ("focus", "reduce-interruptions"),
    "focus-sleep": ("focus", "sleep"),
    "focus-work": ("focus", "work"),
}
# pane -> the cut (left, top, size) in the 80 px crop
BOX = {"privacyAndSecurity": (8, 16, 48), "focus": (12, 8, 64)}


def lum(p):
    return (p[0] * 299 + p[1] * 587 + p[2] * 114) / 1000


def outside(light):
    """Pixels of the light cut that belong to the card: reached from the border over bright pixels."""
    w, h = light.size
    px = light.load()
    seen = [[False] * w for _ in range(h)]
    q = deque()
    for x in range(w):
        q.append((x, 0)); q.append((x, h - 1))
    for y in range(h):
        q.append((0, y)); q.append((w - 1, y))
    while q:
        x, y = q.popleft()
        if x < 0 or y < 0 or x >= w or y >= h or seen[y][x] or lum(px[x, y]) < 200:
            continue
        seen[y][x] = True
        q.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))
    return seen


def cut(pane, row):
    left, top, size = BOX[pane]
    box = (left, top, left + size, top + size)
    light = Image.open(os.path.join(SRC, f"icon-{pane}-{row}-light.png")).convert("RGB").crop(box)
    dark = Image.open(os.path.join(SRC, f"icon-{pane}-{row}-dark.png")).convert("RGB").crop(box)
    out = outside(light)
    lp = light.load()
    res = {}
    for name, im in (("light", light), ("dark", dark)):
        px = im.load()
        bg = px[0, 0]
        img = Image.new("RGBA", (size, size))
        o = img.load()
        for y in range(size):
            for x in range(size):
                p = px[x, y]
                if out[y][x]:
                    a = max(0.0, min(1.0, 1 - lum(p) / lum(bg)))      # the tile's shadow on the card
                    o[x, y] = (0, 0, 0, round(a * 255))
                    continue
                edge = any(0 <= x + dx < size and 0 <= y + dy < size and out[y + dy][x + dx]
                           for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))
                a = 1.0
                if edge:                                             # coverage, read on the light card
                    a = max(0.05, min(1.0, (247 - lum(lp[x, y])) / (247 - 30)))
                c = tuple(max(0, min(255, round((p[i] - (1 - a) * bg[i]) / a))) for i in range(3))
                o[x, y] = c + (round(a * 255),)
        res[name] = img
    return res


def main():
    os.makedirs(OUT, exist_ok=True)
    for ident, (pane, row) in ROWS.items():
        for name, img in cut(pane, row).items():
            img.save(os.path.join(OUT, f"{ident}-{name}.png"), optimize=True)
    print(len(ROWS), "tiles ->", os.path.relpath(OUT, ROOT))


if __name__ == "__main__":
    sys.exit(main())
