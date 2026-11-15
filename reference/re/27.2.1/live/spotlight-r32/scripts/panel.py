#!/usr/bin/env python3
"""Per-frame shape of the panel under the Spotlight bar (frames fNNN.png, NNN = pts in 1/60 s; or any sorted list).

usage: panel2.py DIR BARBOTTOM_PX [BG_FRAME] [REF_FRAME] [--rate 60] [--k 2]
Darkness d = background frame - frame (grey). Search area: rows below BARBOTTOM_PX + 4.
Per frame: peak = 95th percentile of d in the area; extent = where d > 0.5 * peak on the row / column through the
darkness centroid (x0 x1 y0 y1, pt); mass = sum(d) / sum(d_ref) (alpha x coverage); edge = left-edge 10-90 % width on
the centre row (pt, blur proxy); level = mean d inside the central 50 % of the extent / ref's (the fill level, alpha).
"""
import glob
import os
import sys

import numpy as np
from PIL import Image


def load(p):
    return np.asarray(Image.open(p).convert("RGB"), dtype=np.float32).mean(axis=2)


def num(p):
    b = os.path.basename(p)
    return int("".join(c for c in b if c.isdigit()))


args = [a for a in sys.argv[1:] if not a.startswith("--")]
opts = dict(a[2:].split("=") for a in sys.argv[1:] if a.startswith("--"))
rate = float(opts.get("rate", 60))
k = float(opts.get("k", 2))
d = args[0]
bb = int(args[1])
files = sorted(glob.glob(os.path.join(d, "*.png")), key=num)
bg = load(os.path.join(d, args[2]) if len(args) > 2 else files[0])
ref = load(os.path.join(d, args[3]) if len(args) > 3 else files[-1])
y_off = bb + 4
dref = (np.abs(bg - ref) if "abs" in opts else np.clip(bg - ref, 0, None))[y_off:]
mref = dref.sum()


def shape(dd):
    peak = np.percentile(dd, 99.5)
    if peak < 6:
        return None
    m = dd > 0.5 * peak
    ys, xs = np.nonzero(m)
    if len(xs) < 50:
        return None
    cy = int(np.median(ys))
    cx = int(np.median(xs))
    row = dd[cy]
    rx = np.nonzero(row > 0.5 * peak)[0]
    col = dd[:, cx]
    ry = np.nonzero(col > 0.5 * peak)[0]
    x0, x1, y0, y1 = rx[0], rx[-1], ry[0], ry[-1]
    plateau = row[(x0 + x1) // 2 - 30:(x0 + x1) // 2 + 30].mean()
    seg = row[max(0, x0 - 100):(x0 + x1) // 2]
    edge = (np.argmax(seg > 0.9 * plateau) - np.argmax(seg > 0.1 * plateau)) / k
    w4, h4 = (x1 - x0) // 4, (y1 - y0) // 4
    lvl = dd[y0 + h4:y1 - h4, x0 + w4:x1 - w4].mean()
    return x0, x1, y0, y1, edge, lvl, peak


rs = shape(dref)
print(f"# ref: x {rs[0] / k:.1f}..{rs[1] / k:.1f} y {(rs[2] + y_off) / k:.1f}..{(rs[3] + y_off) / k:.1f} pt, level {rs[5]:.1f}")
print("#  t      x0     x1      w      y0     y1      h   mass  level  edge  peak")
for p in files:
    t = num(p) / rate
    dd = (np.abs(bg - load(p)) if "abs" in opts else np.clip(bg - load(p), 0, None))[y_off:]
    s = shape(dd)
    mass = dd.sum() / mref
    if s is None:
        print(f"{t:6.3f}  -  mass {mass:.3f}")
        continue
    x0, x1, y0, y1, edge, lvl, peak = s
    print(f"{t:6.3f} {x0 / k:6.1f} {x1 / k:6.1f} {(x1 - x0) / k:6.1f} {(y0 + y_off) / k:6.1f} {(y1 + y_off) / k:6.1f}"
          f" {(y1 - y0) / k:6.1f} {mass:6.3f} {lvl / rs[5]:6.3f} {edge:5.1f} {peak:5.1f}")
