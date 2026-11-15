#!/usr/bin/env python3
"""Live check: Mission Control's Spaces bar expanding when the pointer enters it (MAC-ANSWERS-18.md R18.1,
reference/re/27.2.1/live/r18/mc-spaces-bar-expand-dark.mov; MOTION-REA-27.2.1.md "Round R18.1"):

  - the bar grows by 92 pt (Mac 68 -> 160 at 1440x932; ours 74 -> 166, the default mode's inset) on the decoded
    critically damped (1.0, 0.38) spring, the first moved frame about 85 ms after the pointer entered;
  - the window thumbnails below keep their distance to the bar's edge in every frame (Mac: 39.5 pt) and their size;
  - the bar stays expanded after the pointer has left it.

Session: see livecheck.py, no windows (the check opens two foot windows and closes them). Per frame (mcap, the left
160 pt, 2 samples per pt) the bar's bottom edge is read on columns left of the windows (the bar's 1 pt line) and the top
of the left window's thumbnail on columns through it.

  mc-bar.py [--runs N] [--keep DIR]      exit 0 = every case passed
"""
import os, shutil, subprocess, sys, tempfile, time

import numpy as np

import livecheck as lc

# the Mac's track per 60 Hz frame from the first moved one (2.117 s): the top row's top edge less 39.5 pt, as a share
# of the 92 pt (the bar's own edge is one frame ahead in frames 2 and 3 and repeats in the 4th: 86.5 95.5 95.5)
MAC = [(v - 68) / 92 for v in (70.5, 77.5, 86, 95.5, 104.5, 113, 120.5, 127.5, 133, 138, 142, 145.5, 148, 150.5, 152.5,
                               154, 155, 156, 157, 157.5, 158, 158.5, 158.5, 159)]
GROW = 92        # pt
FIRST_MS = 85    # the Mac's first moved frame after the pointer entered (2.03 s -> 2.117 s)
APPS = ("mcbar-a", "mcbar-b")


def edge(f):
    """the bar's bottom edge in pt: the 1 pt line under it, the darkest step down the wallpaper columns (x 3..9 pt)"""
    col = f[:, 6:18].mean(axis=1)
    d = col[:-2] - col[2:]
    r = int(d[40:].argmax()) + 40
    return (r + 2) / 2.0


def win_top(f, e):
    """the top of the left thumbnail in pt: the first row under the bar's shadow where the window's columns leave the
    wallpaper's by more than 30 levels"""
    a, b = f[:, 160:300].mean(axis=1), f[:, 6:18].mean(axis=1)
    for r in range(int(e * 2) + 20, len(a)):
        if abs(a[r] - b[r]) > 30:
            return r / 2.0
    return None


def run(pid, ptr, tmp, keep, n):
    ptr.move(640, 700)
    lc.ipc(pid, "panels", "toggle", "mission")
    time.sleep(1.5)
    ptr.move(640, 130)
    ptr.move(640, 120, 40)
    time.sleep(0.5)
    prefix = os.path.join(tmp, f"bar-{n}")
    fifo = os.path.join(tmp, "enter")
    if not os.path.exists(fifo):
        os.mkfifo(fifo)
    cap = lc.mcap_start(prefix, (0, 0, 160, 330), 1.0, 1, f"echo go > {fifo}")
    with open(fifo) as f:
        f.read()
    ptr.move(640, 60)
    ptr.move(640, 40)
    cap.wait(timeout=20)
    t, fr = lc.frames(prefix, keep=bool(keep))
    lum = fr.sum(axis=3) / 3.0
    edges = [edge(f) for f in lum]
    tops = [win_top(f, e) for f, e in zip(lum, edges)]
    # the pointer leaves: the bar stays
    ptr.move(640, 300)
    ptr.move(640, 500, 60)
    time.sleep(1.5)
    after = edge(lc.grim()[0:660, 0:320].sum(axis=2) / 3.0)
    lc.ipc(pid, "panels", "close")
    time.sleep(1.0)
    return t, edges, tops, after


def main():
    keep = sys.argv[sys.argv.index("--keep") + 1] if "--keep" in sys.argv else None
    runs = int(sys.argv[sys.argv.index("--runs") + 1]) if "--runs" in sys.argv else 3
    pid = lc.session("mc-bar")
    if not shutil.which("foot"):
        sys.exit("mc-bar: needs foot for the two test windows")
    if lc.clients():
        sys.exit("mc-bar: close the session's windows first (the check opens its own two)")
    tmp = keep or tempfile.mkdtemp(prefix="mc-bar-")
    os.makedirs(tmp, exist_ok=True)
    if lc.ipc(pid, "panels", "current"):
        lc.ipc(pid, "panels", "close")
        time.sleep(1.0)
    procs, fails = [], 0
    ptr = lc.Pointer()
    try:
        for a, (x, y, w, h) in zip(APPS, ((40, 60, 520, 300), (640, 260, 500, 420))):
            procs.append(subprocess.Popen(["foot", f"--app-id={a}", "-T", a, "sleep", "100000"],
                                          stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True))
            for _ in range(50):
                if lc.clients(a):
                    break
                time.sleep(0.1)
            wn = f'window="class:{a}"'
            for d in (f"hl.dsp.window.resize({{x={w}, y={h}, exact=true, {wn}}})", f"hl.dsp.window.move({{x={x}, y={y}, {wn}}})"):
                subprocess.run(["hyprctl", "dispatch", d], capture_output=True)
        time.sleep(1.0)
        for n in range(runs):
            t, edges, tops, after = run(pid, ptr, tmp, keep, n)
            rest = edges[0]
            first = next((i for i, e in enumerate(edges) if e > rest + 1), None)
            if first is None or tops[0] is None:
                fails += lc.report(False, f"run {n + 1}", f"the bar did not move (edge {rest:.1f} pt, window top {tops[0]})")
                continue
            end = edges[-1]
            share = [(e - rest) / GROW for e in edges[first:first + len(MAC)]]
            k = min(len(share), len(MAC))
            rms = float(np.sqrt(np.mean((np.array(share[:k]) - np.array(MAC[:k])) ** 2)))
            step = float(np.median(np.diff(t[first:first + k])))
            fails += lc.report(abs(end - rest - GROW) <= 1 and abs(rest - 74) <= 1, f"run {n + 1}: height",
                               f"{rest:.1f} -> {end:.1f} pt (Mac 68 -> 160: +92; ours from 74)")
            fails += lc.report(rms * GROW <= 2.0 and abs(step - 16.7) < 1, f"run {n + 1}: track",
                               "edge " + " ".join(f"{e:.1f}" for e in edges[first:first + 14]) + f" ...; rms {rms * GROW:.2f} pt "
                               f"against the Mac's frames ({step:.1f} ms per frame)")
            fails += lc.report(abs(t[first] - FIRST_MS) <= 25, f"run {n + 1}: start",
                               f"first moved frame {t[first]:.0f} ms after the pointer entered (Mac about {FIRST_MS})")
            gaps = [tp - e for tp, e in zip(tops, edges) if tp is not None]
            dev = max(abs(g - gaps[0]) for g in gaps)
            moved = tops[-1] - tops[0]
            fails += lc.report(len(gaps) == len(edges) and dev <= 1.5 and abs(moved - GROW) <= 1, f"run {n + 1}: windows make room",
                               f"top row {tops[0]:.1f} -> {tops[-1]:.1f} pt (+{moved:.1f}), {gaps[0]:.1f} pt under the edge, "
                               f"at most {dev:.1f} off on the way (Mac 39.5 in every frame)")
            fails += lc.report(abs(after - end) <= 0.5, f"run {n + 1}: stays expanded",
                               f"edge {after:.1f} pt 1.5 s after the pointer left the bar")
    finally:
        if lc.ipc(pid, "panels", "current") == "mission":
            lc.ipc(pid, "panels", "close")
        ptr.move(640, 700)
        ptr.close()
        for p in procs:
            p.terminate()
        for p in procs:
            try:
                p.wait(timeout=5)
            except subprocess.TimeoutExpired:
                p.kill()
        if not keep:
            shutil.rmtree(tmp, ignore_errors=True)
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
