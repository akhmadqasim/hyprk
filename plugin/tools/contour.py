#!/usr/bin/env python3
"""Top edge of a glass shape on a screenshot against the plugin's corner curve (QuartzCore supercircle_sdf, the port in
check_model.py), at any output scale.

  contour.py SHOT.png --box X,Y,W,H --r R --scale S [--span A,B] [--method peak|profile|cover] [--rows] [--name NAME]

box and r are the shape's, in logical px, as `hyprctl liquidglass trace NS FILE` prints them; S is the output scale (the
shot is in physical px). Works over a flat backdrop (the rim's first row must be the brightest of its column).
Three readings of the sub-pixel edge per column:
  peak     check_model.py step 7's reading of the Mac crop: the brightest row near the top minus the coverage of the row
           above it, coverage = (value - backdrop) / (rim - backdrop), the rim's value from the flat middle. Default, so
           the numbers compare with the Mac fits (slider 0.16, 2x2 0.12, banner 0.11, Dock 0.09 px). It takes a first row
           that is 60..90 % covered for a whole one (it is already the brightest), and a first row under 60 % puts the
           "first rim row" one row lower: at a fractional scale that is most of the corner's shallow end.
  profile  k + 1 - c: k the first row brighter than the backdrop, c its coverage. The shader draws coverage x rim(depth of
           the pixel centre, not below 0) + (1 - coverage) x backdrop and the rim falls linearly over its first rows, so
           with the two first rows of the flat middle (r1 half a px deep, r2 one px deeper)
             value = c (r1 + (1 - c)(r1 - r2)) + (1 - c) backdrop  for c >= 0.5,  c (r1 + (r1 - r2) / 2) + (1 - c) backdrop
           below, solved for c. Right on the shallow end (use --span 0.88,1.92); in the steep part both readings come out
           low, because the highlight's lobes dim the rim where the normal leaves the vertical (223 -> 175 at 17 degrees).
  cover    for a shot taken with `highlight = 0, shadow_scale = 0, ring_scale = 0` over a flat backdrop that differs from
           the glass body (white): then a pixel is coverage x body + (1 - coverage) x backdrop and nothing else, and the
           edge is the first fully covered row minus the summed coverage of the rows above it. No rim model, right at
           any slope and at any sub-pixel position of the box (banner top 70.4 px at 1.6: first row 60 % covered).
The model's edge is where the SDF crosses 0 on that column's centre.
Columns: A..B x r from each end (default 0.45,1.92: 11..46 pt on the r 24 slider tile, the span step 7 uses on the Mac's
crop). Prints rms / max |diff| in px for the left and the right end and the offset in the flat middle; --rows prints the
columns.
"""
import argparse
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from check_model import supercircle  # noqa: E402


def coverage(v, bg, r1, r2):
    """c with value = c rim(c) + (1 - c) bg (see the header); monotonic in c, bisection"""
    f = lambda c: c * (r1 + (1 - max(c, 0.5)) * (r1 - r2)) + (1 - c) * bg
    lo, hi = 0.0, 1.0
    if v >= f(1.0):
        return 1.0
    for _ in range(40):
        c = (lo + hi) / 2
        lo, hi = (c, hi) if f(c) < v else (lo, c)
    return (lo + hi) / 2


def screen_edge(img, cols, top, bg_rows, rim, method="peak"):
    r1, r2 = rim
    out = []
    for x in cols:
        col = img[:, x]
        bg = float(np.median(col[bg_rows[0]:bg_rows[1]]))
        lo = int(np.floor(top)) - 2
        if method == "cover":
            body = float(np.median(col[lo + 18:lo + 24]))
            c = np.clip((col[lo - 2:lo + 18] - bg) / (body - bg if abs(body - bg) > 1 else 1.0), 0, 1)
            full = np.nonzero(c >= 0.98)[0]
            out.append(np.nan if not len(full) else lo - 2 + full[0] - c[:full[0]].sum())
            continue
        if method == "peak":
            k = lo + int(np.argmax(col[lo:lo + 14]))
            out.append(k - min(max((col[k - 1] - bg) / max(r1 - bg, 1.0), 0.0), 1.0))
            continue
        hit = np.nonzero(col[lo:lo + 20] - bg > 0.05 * (r1 - bg))[0]
        if not len(hit):
            out.append(np.nan)
            continue
        k = lo + int(hit[0])
        out.append(k + 1 - coverage(col[k], bg, r1, r2))
    return np.array(out)


def model_edge(cols, x0, top, hx, hy, r, scale):
    ys = np.linspace(top - 1, top + 30, 6201)
    out = []
    for x in cols:
        d = supercircle(np.full_like(ys, (x + 0.5 - x0) / scale - hx), (ys - top) / scale - hy, hx, hy, r)[0]
        out.append(ys[np.argmax(d < 0)])
    return np.array(out)


def read(shot, box, r, scale, span=(0.45, 1.92), method="peak"):
    from PIL import Image
    img = np.asarray(Image.open(shot).convert("L"), float)
    x, y, w, h = box
    x0, top, hx, hy = x * scale, y * scale, w / 2, h / 2
    mid = int(round((x + w / 2) * scale))
    bg_rows = (int(np.floor(top)) - 7, int(np.floor(top)) - 3)
    # the rim's first fully covered row in the flat middle
    k = int(np.floor(top)) - 2 + int(np.argmax(img[int(np.floor(top)) - 2:int(np.floor(top)) + 12, mid]))
    rim = (float(img[k, mid]), float(img[k + 1, mid]))
    a, b = (int(np.ceil(x0 + span[0] * r * scale)), int(np.floor(x0 + min(span[1] * r, w / 2) * scale)))
    left = np.arange(a, b)
    x1 = (x + w) * scale
    right = np.arange(int(np.ceil(x1 - min(span[1] * r, w / 2) * scale)), int(np.floor(x1 - span[0] * r * scale)))
    res = {}
    for name, cols in (("left", left), ("right", right)):
        s, m = screen_edge(img, cols, top, bg_rows, rim, method), model_edge(cols, x0, top, hx, hy, r, scale)
        res[name] = (cols, s, m)
    midc = np.arange(mid - 4, mid + 5)
    off = float((screen_edge(img, midc, top, bg_rows, rim, method) - top).mean())
    return res, off, rim


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("shot")
    ap.add_argument("--box", required=True)
    ap.add_argument("--r", type=float, required=True)
    ap.add_argument("--scale", type=float, default=2.0)
    ap.add_argument("--span", default="0.45,1.92")
    ap.add_argument("--rows", action="store_true")
    ap.add_argument("--name", default="")
    ap.add_argument("--method", default="peak", choices=("peak", "profile", "cover"))
    a = ap.parse_args()
    box = [float(v) for v in a.box.split(",")]
    res, off, rim = read(a.shot, box, a.r, a.scale, tuple(float(v) for v in a.span.split(",")), a.method)
    line = []
    for name in ("left", "right"):
        cols, s, m = res[name]
        d = (s - m)[~np.isnan(s)]
        line.append("%s rms %.2f max %.2f (n %d)" % (name, float(np.sqrt((d ** 2).mean())), float(np.abs(d).max()), len(d)))
        if a.rows:
            end = box[0] * a.scale if name == "left" else (box[0] + box[2]) * a.scale
            for x, sv, mv in zip(cols, s, m):
                print("  %s x %d (%.1f pt from the end) screen %.2f model %.2f diff %+.2f" % (name, x, abs(x + 0.5 - end) / a.scale, sv, mv, sv - mv))
    print("%-12s scale %.2f r %.1f top edge vs the curve, px: %s; flat middle %+.2f px, rim %.0f" % (a.name, a.scale, a.r, "; ".join(line), off, rim[0]))


if __name__ == "__main__":
    main()
