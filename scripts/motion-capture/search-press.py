#!/usr/bin/env python3
"""Live check: the Finder toolbar's Search button while held (MAC-ANSWERS-11.md R11.5, controls/finder-search-button-*;
MOTION-REA-27.2.1.md "Finder toolbar Search button"): in the press frame the disc and its glyph grow from 37 to 40 pt
(light; dark reads 36 to 39, see "held size" below) about the centre and the disc takes the held colour (light 255, dark a neutral 58-59), with no frames in between;
a release inside the button, however long it was held, opens the search field.

Session: see livecheck.py. Needs one hyprk-finder window with the search field closed (the script brings it to the front).
A real press and release with scripts/vptr; the release opens the search field, which the script closes again
(a click in the field, Escape through Hyprland's send_shortcut).

  search-press.py [--keep DIR]      exit 0 = every case passed
"""
import os, sys, tempfile, time

import numpy as np

import livecheck as lc

def diameter(f, k):
    """the disc's height in pt (its top edge on the centre column, doubled: the glyph and the pointer's picture are
    lower) and its colour 15 pt above the centre"""
    h, w = f.shape[:2]
    col = f[:h // 2, w // 2 - 1:w // 2 + 1].mean(axis=(1, 2))
    a = int(7.5 * k)                                       # the toolbar strip above the capsule: the region starts 4 pt
    out = col[int(5.5 * k):a].mean()                       # above the window, the capsule 11.5 pt under its top
    rows = np.nonzero(np.abs(col[a:] - out) > 8)[0]
    top = a + rows.min() if len(rows) else h // 2
    return 2 * (h / 2 - top) / k, f[int(h / 2 - 15 * k), w // 2].astype(float)


def main():
    keep = sys.argv[sys.argv.index("--keep") + 1] if "--keep" in sys.argv else None
    lc.session("search-press")
    wins = lc.clients("hyprk-finder")
    if len(wins) != 1:
        sys.exit("search-press: needs exactly one hyprk-finder window")
    (wx, wy), (ww, wh) = wins[0]["at"], wins[0]["size"]
    cx, cy = wx + ww - 26, wy + 26                          # the Search disc's centre (Theme.toolbar)
    tmp = keep or tempfile.mkdtemp(prefix="search-press-")
    os.makedirs(tmp, exist_ok=True)
    prefix = os.path.join(tmp, "press")
    lc.front("class:hyprk-finder")
    ptr = lc.Pointer()
    try:
        ptr.move(cx - 60, cy + 120)
        time.sleep(0.3)
        ptr.click()                                         # the window in front (its content, no file there)
        time.sleep(0.5)
        for dx in (-30, -12, -3, 0):
            ptr.move(cx + dx, cy, 30)
        time.sleep(0.5)
        cap = lc.mcap_start(prefix, (cx - 30, cy - 30, 60, 60), 1.5, 1)
        time.sleep(0.4)
        ptr.down()
        time.sleep(0.5)
        ptr.up()
        cap.wait(timeout=20)
        time.sleep(0.4)
        ptr.move(cx - 80, cy)                               # the release opened the search field: Escape in it closes it
        time.sleep(0.2)
        ptr.click()
        time.sleep(0.3)
        lc.key("Escape", "class:hyprk-finder")
        time.sleep(0.4)
        ptr.move(cx - 60, cy + 120)
        time.sleep(0.2)
        ptr.click()
    finally:
        ptr.close()
    t, fr = lc.frames(prefix, keep=bool(keep))
    if not keep:
        os.rmdir(tmp)
    k = fr.shape[2] / 60
    d = np.array([diameter(f, k)[0] for f in fr])
    col = np.array([diameter(f, k)[1] for f in fr])
    lum = col.mean(axis=1)
    rest_d, rest_l = float(np.median(d[:8])), float(np.median(lum[:8]))
    if not 34 < rest_d < 39:
        return lc.report(False, "search disc", f"no 36-37 pt disc at rest (read {rest_d:.1f} pt): is the search field open?") or 1
    ch = np.abs(lum - rest_l) > 4
    if not ch.any():
        return lc.report(False, "press", "the disc never changed") or 1
    i0 = int(np.argmax(ch))                                 # the press frame
    held = slice(i0, i0 + 12)
    dark = rest_l < 128
    want = 58.5 if dark else 255
    hl, hd = float(np.median(lum[held])), float(np.median(d[held]))
    fails = 0
    fails += lc.report(abs(lum[i0] - hl) <= 2 and abs(d[i0] - hd) <= 0.5, "press frame",
                       f"frame {i0}: disc {rest_d:.1f} -> {d[i0]:.1f} pt, level {rest_l:.0f} -> {lum[i0]:.0f}; held {hd:.1f} pt, {hl:.0f} (one frame, nothing between)")
    # the Mac's stills read by diameter()'s own rule (the centre column's rows more than 8 levels off the strip):
    # light rows 15..88 -> 12..91 of the 104 px crop (37 -> 40 pt), dark 16..87 -> 13..90 (36 -> 39 pt: the dark
    # capsule's outer rim row is the strip's own level). JUDGE-95-24 held ours in dark against the light figure
    m0, m1 = (36, 39) if dark else (37, 40)
    fails += lc.report(abs(rest_d - m0) <= 0.5 and abs(hd - m1) <= 0.5, "held size",
                       f"{rest_d:.1f} -> {hd:.1f} pt, x{hd / rest_d:.3f} (Mac {'dark' if dark else 'light'} stills {m0} -> {m1} pt: x{m1 / m0:.3f})")
    fails += lc.report(abs(hl - want) <= 8, "held colour", f"{tuple(int(v) for v in np.median(col[held], axis=0))} ({'dark' if dark else 'light'}; Mac {want:g})")
    # the release (0.5 s after the press: a held button still acts, as AppKit's): the field opens, its focus ring
    # stands above the capsule's top edge
    opened = np.nonzero(d[i0 + 3:] > hd + 2)[0]
    ms = float(t[i0 + 3 + opened[0]] - t[i0]) if len(opened) else -1
    fails += lc.report(ms > 0, "release", f"the search field opened {ms:.0f} ms after the press frame (held 500 ms)" if ms > 0
                       else "the release after a 0.5 s hold did not open the search field")
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
