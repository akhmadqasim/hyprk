#!/usr/bin/env python3
"""Live check: the Dock's glass plate (drawn by the compositor plugin) stays under its icons (drawn by the shell) in
every frame while the Dock is resized by its separator. JUDGE-95-23 claim 2 saw one frame with the plate about 94 pt
above the icons (`judge-95-23/09-dock-separator-drag-glass-plate-detached-ours.png`): two layers of one object drawn
from different frames.

Per frame (mcap, every compositor frame of the drag): the plate's top edge (the first row that differs from the
backdrop over most of the Dock's width, away from its corners) and the icons' top (the first row of the first tile's
picture). In step, the icons' top is iconTop + artInset under the plate's (lib/dock.js metrics: 10 + T x 100 / 1024 pt
at T >= 64, T = the plate's height - 20), so the distance grows from 16 pt at 64 to 19 at 90; the check is how far it
leaves that in any frame. (Until JUDGE-95-24 the plate's top was read 6 pt from its left end, inside the corner: the
corner's radius grows with the tile, so an in-step Dock read 3-4 pt "behind". The plugin's own trace, `hyprctl
liquidglass trace hyprk-dock FILE`, shows the plate's box 1 pt per frame with the pointer.)

Session: see livecheck.py, over a FLAT wallpaper (one colour: wallpaper.json in the scratch state folder pointing at a
plain picture). HYPRK_STATE must be the session's scratch state folder (dock.json is written and put back).

  dock-plate-sync.py [TRAVEL]      pt of upward travel, default 26; exit 0 = never more than 1.5 pt off (frames are
                                   read at 1 px per pt; one frame of lag at the drag's 1 pt per frame is 1 pt of
                                   plate and 1 of icon in opposite senses)
"""
import json, os, sys, time

import numpy as np

import livecheck as lc

REGION = (200, 600, 880, 232)        # wide enough for the Dock at the end of the drag (about 730 pt at tile 90)


def tops(fr):
    """(plate top, icons top) in pt from the region's top, None when not found; fr: h x w x 3 at 1 px per pt"""
    bg = fr[:, 4:12].mean(axis=1)                                   # the backdrop, left of the Dock
    diff = np.abs(fr - bg[:, None, :]).max(axis=2)
    cols = np.nonzero((diff[-40:-20] > 6).all(axis=0))[0]           # the Dock's columns, through its lower part
    if len(cols) < 100:
        return None, None
    x0 = cols[0]
    plate = np.nonzero((diff[:, x0 + 48:cols[-1] - 48] > 3).mean(axis=1) > 0.6)[0]   # the plate's top, clear of its corners
    icon = np.nonzero((diff[:, x0 + 20:x0 + 60] > 60).sum(axis=1) > 20)[0]   # the first tile's picture (Finder)
    return (float(plate[0]) if len(plate) else None), (float(icon[0]) if len(icon) else None)


def main():
    travel = int(sys.argv[1]) if len(sys.argv) > 1 else 26
    lc.session("dock-plate-sync")
    state = os.environ.get("HYPRK_STATE", "")
    if not state or os.path.realpath(state) == os.path.realpath(os.path.join(lc.ROOT, "state")):
        sys.exit("dock-plate-sync: export the session's scratch HYPRK_STATE (never the repo's state folder)")
    img = lc.grim()
    if np.ptp(img[300:1100:8, 8:400:16].reshape(-1, 3), axis=0).max() > 2:
        sys.exit("dock-plate-sync: the wallpaper is not flat: not measured")
    path = os.path.join(state, "dock.json")
    before = open(path).read() if os.path.exists(path) else None
    open(path, "w").write('{\n  "size": 64\n}\n')
    # dark, where dock-resize.py's separator finder works (a line brighter than the plate); put back at the end
    apath = os.path.join(state, "appearance.json")
    abefore = open(apath).read() if os.path.exists(apath) else None
    cfg = json.loads(abefore) if abefore else {}
    cfg["mode"], cfg["dark"] = "dark", True
    open(apath, "w").write(json.dumps(cfg, indent=2))
    time.sleep(3.0)
    if np.ptp(lc.grim()[300:1100:8, 8:400:16].reshape(-1, 3), axis=0).max() > 2:
        sys.exit("dock-plate-sync: the wallpaper is not flat in dark: not measured")
    import importlib
    sep = importlib.import_module("dock-resize").separator
    ptr = lc.Pointer()
    prefix = os.path.join(os.environ.get("TMPDIR", "/tmp"), "dock-plate-sync")
    try:
        ptr.move(640, 400)
        time.sleep(0.4)
        x, h0 = sep(lc.grim())
        if x is None:
            sys.exit("dock-plate-sync: no separator found in the Dock")
        y = 832 - 8 - (h0 + 12) / 2
        for dx in (-12, -4, -1, 0):
            ptr.move(x + dx, y, 40)
        time.sleep(0.5)
        m = lc.mcap_start(prefix, REGION, 2.2, 2)
        time.sleep(0.4)
        ptr.down()
        time.sleep(0.15)
        for i in range(1, travel + 1):
            ptr.move(x, y - i, 16)
        time.sleep(0.3)
        for i in range(travel, -1, -2):
            ptr.move(x, y - i, 16)
        time.sleep(0.2)
        ptr.up()
        m.wait()
        t, fr = lc.frames(prefix)
        gap, tall = [], []
        for f in fr:
            p, i = tops(f)
            if p is not None and i is not None:
                gap.append(i - p)
                tall.append(REGION[3] - p)
        if len(gap) < 30:
            return lc.report(False, "plate under the icons", f"Dock found in {len(gap)} of {len(fr)} frames")
        if os.environ.get("PLATE_DUMP"):
            print(" ".join(f"{REGION[3] - a:.0f}/{g:.0f}" for a, g in zip(tall, gap)))
            print("t " + " ".join(f"{a:.0f}" for a in t))
        gap, tall = np.array(gap), np.array(tall)
        want = 10 + (tall - 5 - 20) * 100 / 1024                     # lib/dock.js metrics: iconTop + artInset, bottomGap 5
        rest = float(np.median(gap[:5]))
        off = gap - (want + rest - float(np.median(want[:5])))       # the picture's own top inside the art, from the rest frames
        worst = float(np.abs(off).max())
        moved = max(tall) - min(tall)
        fails = lc.report(moved >= travel - 4, "the Dock resized in the capture", f"plate top moved {moved:.0f} pt over {len(gap)} frames")
        fails += lc.report(worst <= 1.5, "plate under the icons in every frame",
                           f"icons' top - plate's top: {rest:.0f} pt at rest, {gap.min():.0f}..{gap.max():.0f} over the drag; against the tile's own {want.min():.1f}..{want.max():.1f}: "
                           f"{off.min():+.1f}..{off.max():+.1f} pt (worst {worst:.1f}; judge #23: one frame about 94)")
        return fails
    finally:
        ptr.up()
        ptr.move(640, 400)
        ptr.close()
        time.sleep(0.5)
        if abefore is not None:
            open(apath, "w").write(abefore)
        if before is None:
            os.remove(path)
        else:
            open(path, "w").write(before)
        for ext in (".raw", ".csv", ".json"):
            if os.path.exists(prefix + ext):
                os.remove(prefix + ext)


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
