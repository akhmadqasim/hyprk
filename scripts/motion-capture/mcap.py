#!/usr/bin/env python3
"""Analyse mcap captures (see mcap.c) and compare them with the Mac's per-frame tracks.

  mcap.py METRIC PREFIX [--thr N] [--sub x,y,w,h]   prints "t_ms value" per captured frame
    METRIC alpha    least-squares blend a with frame = first + a * (last - first)  (fades, cross-fades)
           changed  share of samples that differ from the first frame by > thr, over the same share of the last
                    frame (the Mac's "covered share" for slides, "share of the total pixel change")
           remain   share of samples that still differ from the last frame by > thr, over the first frame's
                    (the Mac reconciliation-42 genie metric)
           col      for the brightest/most changed column per frame: x position (in logical px of the region)
                    of the leading edge of changed samples (for slides)
  t is from the trigger (t0) to the frame's presentation time. --sub restricts to a sub-rectangle (logical
  px inside the region). Library use: load(), metric(), fit_shift() for rms against a Mac series.
"""
import json
import sys

import numpy as np


def load(prefix):
    meta = json.load(open(prefix + ".json"))
    csv = np.loadtxt(prefix + ".csv", delimiter=",", skiprows=1, ndmin=2)
    n = meta["frames"]
    raw = np.fromfile(prefix + ".raw", dtype=np.uint8)
    frames = raw[: n * meta["h"] * meta["w"] * 3].reshape(n, meta["h"], meta["w"], 3).astype(np.float32)
    t = (csv[:, 1] - meta["t0_ns"]) / 1e6
    return meta, t, frames


def sub(meta, frames, rect):
    if not rect:
        return frames
    x, y, w, h = rect
    k = 2 / meta["step"]   # samples per logical px (2x output)
    return frames[:, int(y * k):int((y + h) * k), int(x * k):int((x + w) * k)]


def metric(name, frames, thr=12.0):
    f0, f1 = frames[0], frames[-1]
    if name == "alpha":
        d = (f1 - f0).ravel()
        den = float(d @ d) or 1.0
        return np.array([float((f - f0).ravel() @ d) / den for f in frames])
    if name == "changed":
        ch = [(np.abs(f - f0).max(axis=2) > thr).mean() for f in frames]
        return np.array(ch) / (ch[-1] or 1.0)
    if name == "remain":
        r = [(np.abs(f - f1).max(axis=2) > thr).mean() for f in frames]
        return np.array(r) / (r[0] or 1.0)
    if name == "col":
        out = []
        for f in frames:
            c = (np.abs(f - f0).max(axis=2) > thr).mean(axis=0)
            idx = np.nonzero(c > 0.5)[0]
            out.append(idx.min() if len(idx) else len(c))
        return np.array(out, dtype=float)
    raise SystemExit("unknown metric " + name)


def fit_shift(t, y, mac, step=16.667, lo=-60.0, hi=60.0):
    """Best time shift s (ms) so that y(t) ~ mac((t - s)/step); returns (rms, s, n). mac[0] is at s."""
    mt = np.arange(len(mac)) * step
    best = (9.0, 0.0, 0)
    for s in np.arange(lo, hi + 0.01, 0.5):
        tt = t - s
        m = (tt >= 0) & (tt <= mt[-1])
        if m.sum() < 3:
            continue
        r = float(np.sqrt(np.mean((y[m] - np.interp(tt[m], mt, mac)) ** 2)))
        if r < best[0]:
            best = (r, float(s), int(m.sum()))
    return best


def main():
    a = sys.argv[1:]
    if len(a) < 2:
        print(__doc__)
        return
    thr, rect = 12.0, None
    if "--thr" in a:
        thr = float(a[a.index("--thr") + 1])
    if "--sub" in a:
        rect = [float(v) for v in a[a.index("--sub") + 1].split(",")]
    meta, t, frames = load(a[1])
    y = metric(a[0], sub(meta, frames, rect), thr)
    for ti, yi in zip(t, y):
        print(f"{ti:8.2f} {yi:.4f}")


if __name__ == "__main__":
    main()
