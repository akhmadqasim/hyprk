#!/usr/bin/env python3
"""Live check: Mission Control's exit (MAC-ANSWERS-10.md R10.1, mc-exit-menubar-flat-grey.mov; MOTION-REA-27.2.1.md
"Mission Control exit"): the menu bar's titles are drawn ABOVE the Spaces bar from the first exit frame and fade in
on the Mac's track while the bar slides up on its own track.

Session: see livecheck.py. Opens Mission Control (qs ipc panels toggle mission), captures the top 90 pt per frame with
mcap while it closes and reads, per frame, the Spaces bar's bottom edge (columns clear of titles and Spaces) and the
alpha of the menu titles' ink over what is behind them.

  mc-exit.py [--keep DIR]      exit 0 = every case passed
"""
import os, sys, tempfile, time

import numpy as np

import livecheck as lc

# the Mac's tracks per 60 Hz frame (MOTION-REA-27.2.1.md, R10.1 / R11.7): bar edge as a share of its height, title alpha
BAR = [.78, .62, .47, .35, .24, .16, .10, .06, .03, 0]
TITLE = [.23, .42, .58, .72, .80, .86, .90, .90, .93, .94, .97, .98]


def rms(ours, mac):
    n = min(len(ours), len(mac))
    return float(np.sqrt(np.mean((np.array(ours[:n]) - np.array(mac[:n])) ** 2)))


def main():
    keep = sys.argv[sys.argv.index("--keep") + 1] if "--keep" in sys.argv else None
    pid = lc.session("mc-exit")
    tmp = keep or tempfile.mkdtemp(prefix="mc-exit-")
    os.makedirs(tmp, exist_ok=True)
    if lc.ipc(pid, "panels", "current") != "mission":
        lc.ipc(pid, "panels", "toggle", "mission")
    time.sleep(1.5)
    prefix = os.path.join(tmp, "exit")
    lc.mcap_start(prefix, (0, 0, lc.W, 90), 0.7, 2, f"qs ipc --pid {pid} call panels toggle mission").wait(timeout=20)
    t, fr = lc.frames(prefix, keep=bool(keep))
    if not keep:
        os.rmdir(tmp)
    lum = fr.sum(axis=3) / 3.0
    first, last = lum[0], lum[-1]
    # the bar's bottom edge: the largest brightness drop down the rows of columns 430..560 (no title, no Space; the bar
    # is lighter than the desktop under it)
    def edge(f):
        col = f[:, 430:560].mean(axis=1)
        drop = col[:-2] - col[2:]
        r = int(drop.argmax())
        return r + 1 if drop[r] > 4 else 0
    full = edge(first)
    edges = [edge(f) for f in lum]
    # the titles: ink of the final frame's menu titles (x 14..390, y 6..28); alpha = (pixel - behind) / (255 - behind)
    # with "behind" from the same rows at x 400..430
    box = (slice(6, 28), slice(14, 390))
    mask = last[box] > 150
    def alpha(f):
        behind = f[6:28, 400:430].mean(axis=1, keepdims=True)
        return float((((f[box] - behind) / (255 - behind))[mask]).mean())
    a1 = alpha(last)
    alphas = [alpha(f) / a1 for f in lum]
    start = next((i for i, e in enumerate(edges) if e < full - 2), None)
    fails = 0
    if full < 40 or start is None:
        return lc.report(False, "spaces bar", f"no bar seen leaving (height {full} pt)") or 1
    bar = [e / full for e in edges[start:start + len(BAR)]]
    tit = alphas[start:start + len(TITLE)]
    fails += lc.report(alphas[start] > 0.1 and edges[start] > 34, "titles above the bar",
                       f"first exit frame: bar edge {edges[start]} of {full} pt, title alpha {alphas[start]:.2f} (Mac .23), before {alphas[max(0, start - 1)]:.2f}")
    fails += lc.report(rms(bar, BAR) < 0.05, "bar track", "edge share " + " ".join(f"{v:.2f}" for v in bar) + f", rms {rms(bar, BAR):.3f} against the Mac's")
    fails += lc.report(rms(tit, TITLE) < 0.06, "title track", "alpha " + " ".join(f"{v:.2f}" for v in tit) + f", rms {rms(tit, TITLE):.3f} against the Mac's")
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
