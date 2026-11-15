#!/usr/bin/env python3
"""Live check: Spotlight's rims against the Mac's rows (MAC-ANSWERS-17.md R17.3 / R17.5, reference/re/27.2.1/live/r17/
spotlight-{modelist,typed,idle}-*.png and spotlight-list-top-edge-step-dark.png; SPOTLIGHT-27.2.1.md "Round 17").

The panel's first rows are the plugin's outer refraction (0.4 D outward along the ovalized normal, seeing the bar above
it) under the shell's light line (shaders/spotrim.frag). Read at 2x on 5 px columns, dark, over a flat white and a flat
grey 127 wallpaper and over a black / white step 124 pt right of the middle:
  mode list (D 214, the sample lands in the bar's dark top): first row 100 at the middle, 90 at 200 pt, second row 119;
  results (D 410, the sample lands above the bar): 165 / 152, second row 142; over grey the mode list 85 / 73;
  the bar's bottom row 167 at the middle, 158 at 150 pt; its top rows 57 / 34;
  step: the list's first row shows the step about 25 pt nearer the middle than the rows under it.

Session: see livecheck.py, with HYPRK_STATE exported (the session's own state dir: the check writes its wallpaper.json
there and puts the old one back), the plugin loaded, a query that fills the results panel (default "e").
  spotlight-edge.py [--query e] [--keep DIR]      exit 0 = every case passed
"""
import json, os, sys, tempfile, time

import numpy as np
from PIL import Image

import livecheck as lc

TOL = 7
CX = 1280                      # the bar's middle, px (1280 x 832 pt at 2x)


def flat(path, left, right=None, at=1280):
    a = np.zeros((1664, 2560, 3), np.uint8)
    a[:, :at] = left
    a[:, at:] = left if right is None else right
    Image.fromarray(a).save(path)


def v(img, y, dx):
    x = CX + 2 * dx
    return float(img[y, x - 2:x + 3].mean())


def edges(img):
    """the bar's first row, its last row and the list's first row (px) on the middle column: the bar is the dark
    capsule 87 pt tall, the list starts 10 pt under it"""
    col = img[:, CX - 2:CX + 3].mean(axis=(1, 2))
    y0 = int(832 * 2 * 0.2665) - 87
    top = y0 + int(np.argmax(np.abs(np.diff(col[y0 - 12:y0 + 12])))) - 11
    return top, top + 173, top + 194


def main():
    args = sys.argv[1:]
    query = args[args.index("--query") + 1] if "--query" in args else "e"
    keep = args[args.index("--keep") + 1] if "--keep" in args else None
    pid = lc.session("spotlight-edge")
    state = os.environ.get("HYPRK_STATE", "")
    if not state or not os.path.isdir(state) or os.path.realpath(state) == os.path.realpath(os.path.join(lc.ROOT, "state")):
        sys.exit("spotlight-edge: export the test session's HYPRK_STATE (never the user's state/)")
    tmp = keep or tempfile.mkdtemp(prefix="spotlight-edge-")
    os.makedirs(tmp, exist_ok=True)
    wj = os.path.join(state, "wallpaper.json")
    old = open(wj).read() if os.path.exists(wj) else None
    walls = {"white": (255, None), "grey": (127, None), "step": (0, 255)}
    for n, (l, r) in walls.items():
        flat(os.path.join(tmp, n + ".png"), l, r, 1280 + 248)
    ptr = lc.Pointer()
    fails = 0

    def shoot(wall, state_):
        open(wj, "w").write(json.dumps({"path": os.path.join(tmp, wall + ".png")}))
        time.sleep(1.8)
        if lc.ipc(pid, "panels", "current"):
            lc.ipc(pid, "panels", "close")
            time.sleep(0.7)
        if state_ == "modes":
            lc.ipc(pid, "spotlight", "empty")
            time.sleep(1.0)
            ptr.move(900, 700)
            time.sleep(0.1)
            ptr.move(930, 720, 10)
            time.sleep(1.5)
        else:
            lc.ipc(pid, "spotlight", "search", query)
            time.sleep(1.8)
        img = lc.grim()
        if keep:
            Image.fromarray(img.astype(np.uint8)).save(os.path.join(tmp, f"shot-{wall}-{state_}.png"))
        return img

    def case(name, got, want, tol=TOL):
        ok = all(abs(g - w) <= tol for g, w in zip(got, want))
        return lc.report(ok, name, "ours " + " ".join(f"{g:.0f}" for g in got) + " | Mac " + " ".join(f"{w:g}" for w in want))

    try:
        lc.ipc(pid, "theme", "setDark", "true")
        time.sleep(1.8)
        ptr.move(1000, 760)
        img = shoot("white", "modes")
        bt, bb, lt = edges(img)
        fails += case("mode list over white: row 1 middle / 100 / 200 pt, row 2, row 3",
                      [v(img, lt, 0), v(img, lt, 100), v(img, lt, 200), v(img, lt + 1, 0), v(img, lt + 2, 0)], [100, 94, 90, 119, 123])
        fails += case("bar over white: bottom rows -2 / -1 / 0, row 0 at 100 / 150 pt",
                      [v(img, bb - 2, 0), v(img, bb - 1, 0), v(img, bb, 0), v(img, bb, 100), v(img, bb, 150)], [134, 149, 167, 161, 158])
        fails += case("bar over white: top rows 1 / 2 / 3, row 1 at 100 / 150 pt",
                      [v(img, bt, 0), v(img, bt + 1, 0), v(img, bt + 2, 0), v(img, bt, 100), v(img, bt, 150)], [57, 34, 13, 49, 43])
        img = shoot("white", "results")
        bt, bb, lt = edges(img)
        full = v(img, lt + 2 * 300, 0) < 235        # the panel still there 300 pt down: a full (410 pt) results list
        fails += lc.report(full, "results panel", "the query fills the panel (D 410)" if full else f"the query {query!r} gives a short list: pass --query")
        fails += case("results over white: row 1 middle / 100 / 200 pt, row 2, row 3",
                      [v(img, lt, 0), v(img, lt, 100), v(img, lt, 200), v(img, lt + 1, 0), v(img, lt + 2, 0)], [165, 159, 152, 142, 123])
        img = shoot("grey", "modes")
        bt, bb, lt = edges(img)
        fails += case("mode list over grey 127: row 1 middle / 200 pt, row 2; bar bottom row middle / 150 pt",
                      [v(img, lt, 0), v(img, lt, 200), v(img, lt + 1, 0), v(img, bb, 0), v(img, bb, 150)], [85, 73, 83, 118, 105])
        img = shoot("step", "results")
        bt, bb, lt = edges(img)
        # Mac (spotlight-list-top-edge-step-dark.png, middle px 592, step +124 pt): row 1 at 0 / 94 / 114 / 124 / 154 pt
        fails += case("results over the step: row 1 at 0 / 94 / 114 / 124 / 154 pt from the middle",
                      [v(img, lt, d) for d in (0, 94, 114, 124, 154)], [68, 92, 136, 142, 155])
        # the first row's step lies nearer the middle than the interior's: half way up at 94-114 pt, rows under it at 124+
        lead = v(img, lt, 114) - v(img, lt + 6, 114)
        fails += lc.report(lead > 60, "the step in row 1 leads the rows under it", f"at 114 pt: row 1 {v(img, lt, 114):.0f}, row 7 {v(img, lt + 6, 114):.0f} (Mac 136 / 31)")
    finally:
        if lc.ipc(pid, "panels", "current"):
            lc.ipc(pid, "panels", "close")
        ptr.close()
        if old is None:
            os.remove(wj)
        else:
            open(wj, "w").write(old)
        if not keep:
            for n in walls:
                os.remove(os.path.join(tmp, n + ".png"))
            os.rmdir(tmp)
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
