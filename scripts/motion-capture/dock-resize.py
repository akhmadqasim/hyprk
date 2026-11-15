#!/usr/bin/env python3
"""Live check: the Dock's separator resizes the Dock (Dock.app _handleResizeDockEvent, shell/lib/dock.js resizeTile):
hover shows the resize up-down cursor, a held drag of N pt up makes the tile N pt larger while it is held (the
cursor stays), and the release writes `size` to $HYPRK_STATE/dock.json. JUDGE-95-23 claim 2 (nothing happened).

Session: see livecheck.py. HYPRK_STATE must be the session's scratch state folder (the file is written there and put
back at the end); the script refuses the repo's own state folder.

  dock-resize.py [TRAVEL]      pt of upward travel, default 26; exit 0 = every case passed
"""
import json, os, sys, time

import numpy as np

import livecheck as lc


def separator(img):
    """(x in pt, line height in pt) of the rightmost separator line: a 1 pt (2 px) column brighter than both sides"""
    lum = img.sum(axis=2)
    band = lum[1560:1600]
    hit = [(band[:, x] - band[:, x - 3]).min() > 25 and (band[:, x] - band[:, x + 4]).min() > 25
           for x in range(lum.shape[1] - 8)]
    xs = [x for x in range(8, len(hit) - 2) if hit[x] and hit[x + 1] and not hit[x - 1] and not hit[x + 2]]
    if not xs:
        return None, 0
    x = xs[-1]
    line = (lum[:, x] - lum[:, x - 3] > 25) & (lum[:, x] - lum[:, x + 4] > 25)
    y0 = y1 = 1580
    while y0 > 0 and line[y0 - 1]:
        y0 -= 1
    while y1 < len(line) - 1 and line[y1 + 1]:
        y1 += 1
    return x / 2 + 0.5, (y1 - y0 + 1) / 2


def cursor_centred(ptr, x, y):
    """True when the drawn cursor is centred on the pointer (the resize cursor: hot spot in its middle; the arrow's is
    its tip, so its picture lies right of and below the pointer). Two shots, the pointer 40 pt apart on one row: what
    differs within 16 pt of the first position is the cursor's picture"""
    a = lc.grim(True)
    ptr.move(x + 40, y)
    time.sleep(0.3)
    b = lc.grim(True)
    ptr.move(x, y)
    time.sleep(0.2)
    x0, y0 = int((x - 16) * 2), int((y - 16) * 2)
    ys, xs = np.nonzero(np.abs(a - b)[y0:y0 + 64, x0:x0 + 64].sum(axis=2) > 40)
    if len(xs) < 20:
        return False, "no cursor drawn"
    cx, cy = (xs.min() + xs.max()) / 4 - 16, (ys.min() + ys.max()) / 4 - 16
    return abs(cx) < 3 and abs(cy) < 4, f"cursor box centre {cx:+.1f}, {cy:+.1f} pt from the pointer"


def main():
    travel = int(sys.argv[1]) if len(sys.argv) > 1 else 26
    pid = lc.session("dock-resize")
    state = os.environ.get("HYPRK_STATE", "")
    if not state or os.path.realpath(state) == os.path.realpath(os.path.join(lc.ROOT, "state")):
        sys.exit("dock-resize: export the session's scratch HYPRK_STATE (never the repo's state folder)")
    path = os.path.join(state, "dock.json")
    before = open(path).read() if os.path.exists(path) else None
    open(path, "w").write('{\n  "size": 64\n}\n')
    time.sleep(1.2)
    ptr = lc.Pointer()
    fails = 0
    try:
        ptr.move(640, 400)
        time.sleep(0.4)
        x, h0 = separator(lc.grim())
        if x is None:
            sys.exit("dock-resize: no separator found in the Dock")
        y = 832 - 8 - (h0 + 12) / 2            # the bar's middle
        for dx in (-12, -4, -1, 0):            # real motion onto the line
            ptr.move(x + dx, y, 40)
        time.sleep(0.5)
        ok, note = cursor_centred(ptr, x, y)
        fails += lc.report(ok, "hover cursor", note + " (resize up-down wanted)")
        ptr.down()
        time.sleep(0.2)
        for i in range(1, 8):
            ptr.move(x, y - travel * i / 7, 30)
        time.sleep(0.6)
        _, h1 = separator(lc.grim())
        ok, note = cursor_centred(ptr, x, y - travel)
        fails += lc.report(ok, "drag cursor", note)
        ptr.up()
        time.sleep(0.8)
        _, h2 = separator(lc.grim())
        size = json.load(open(path)).get("size")
        fails += lc.report(h1 > h0 + travel * 0.6, "held", f"separator line {h0:g} -> {h1:g} pt while held ({travel} pt up)")
        fails += lc.report(size == 64 + travel and h2 == h1, "release",
                           f"dock.json size {size} (wanted {64 + travel}), line {h2:g} pt after the release")
    finally:
        ptr.move(640, 400)
        ptr.close()
        if before is None:
            open(path, "w").write('{\n  "size": 64\n}\n')
        else:
            open(path, "w").write(before)
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()
