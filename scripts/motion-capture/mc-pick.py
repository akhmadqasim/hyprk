#!/usr/bin/env python3
"""Live check: a Mission Control click exit, against reference/screens/27.2.1/live/mc-exit-4-windows.mov (frames at
2.983 / 3.000 / 3.017 s; MOTION-REA-27.2.1.md R5.2, R6.1, Round J24):

  - the first changed frame hides the hover ring and moves nothing; the flight starts in the next;
  - the picked window has its key look 2 frames after the first changed frame;
  - the window that was key greys in that frame (one frame sooner passes).

Session: see livecheck.py. Needs one hyprk-finder window and one org.hyprk.Settings window, both floating, each with
its close light in view (dark or light mode). Runs both directions: Finder picked with Settings key, Settings picked
with Finder key; the pointer rests 0.5 s on the thumbnail before the click. Per frame (mcap of the top 620 pt) the red
close lights are found (R > 200, G 60..130, B < 130, with the yellow light beside them) and given to the window whose
flight path (tile -> real place) they lie on.

  mc-pick.py [--runs N] [--keep DIR]      exit 0 = every case passed
"""
import os, sys, tempfile, time

import numpy as np

import livecheck as lc

MAC = 2          # frames from the first exit frame to the picked window's coloured lights
CLS = {"finder": "hyprk-finder", "settings": "org.hyprk.Settings"}


def reds(img):
    """centres (x, y in pt at the frame's sampling, pixel count) of the red close lights of an h x w x 3 frame: a red
    cluster of 40 px or more with the yellow light on its row 8..26 px to the right (tags, swatches and the small
    lights of the Appearance tiles are not)"""
    m = (img[:, :, 0] > 200) & (img[:, :, 1] > 60) & (img[:, :, 1] < 130) & (img[:, :, 2] < 130)
    yel = (img[:, :, 0] > 200) & (img[:, :, 1] > 160) & (img[:, :, 2] < 110)
    ys, xs = np.nonzero(m)
    out, left = [], np.ones(len(xs), bool)
    while left.any():
        i = int(np.argmax(left))
        near = left & (np.abs(xs - xs[i]) < 10) & (np.abs(ys - ys[i]) < 10)
        left &= ~near
        if near.sum() < 40:
            continue
        cx, cy = float(xs[near].mean()), float(ys[near].mean())
        x0, y0 = int(cx), int(cy)
        if yel[max(0, y0 - 2):y0 + 3, x0 + 8:x0 + 27].sum() >= 10:
            out.append((cx, cy, int(near.sum())))
    return out


def seg_dist(p, a, b):
    p, a, b = np.array(p, float), np.array(a, float), np.array(b, float)
    d = b - a
    u = 0.0 if not d.any() else float(np.clip(np.dot(p - a, d) / np.dot(d, d), 0, 1))
    return float(np.linalg.norm(p - (a + u * d)))


def light_of(pid, who):
    """the close light's centre (pt) of window `who` at its real place and on its Mission Control tile, taken with
    that window key (its lights in colour)"""
    lc.front("class:" + CLS[who])
    time.sleep(0.4)
    real = min(reds(lc.grim()[::2, ::2]), key=lambda c: c[1], default=None)
    lc.ipc(pid, "panels", "toggle", "mission")
    time.sleep(1.5)
    tile = min(reds(lc.grim()[::2, ::2]), key=lambda c: c[1], default=None)
    lc.ipc(pid, "panels", "close")
    time.sleep(1.0)
    return real, tile


def run(pid, ptr, pick, other, paths, tmp, keep, n):
    """one click exit: `other` key, `pick` clicked. Returns (frames to pick coloured, frames to other grey, ms)"""
    lc.front("class:" + CLS[other])
    ptr.move(640, 780)
    time.sleep(0.3)
    lc.ipc(pid, "panels", "toggle", "mission")
    time.sleep(1.5)
    tx, ty = paths[pick][1][0] + 60, paths[pick][1][1] + 60      # inside the tile, clear of the lights
    ptr.move(tx - 6, ty - 6)
    ptr.move(tx, ty, 60)
    time.sleep(0.5)
    prefix = os.path.join(tmp, f"pick-{pick}-{n}")
    # the click is the trigger: vptr reads "b" from a fifo so the click lands at mcap's t0
    fifo = os.path.join(tmp, "click")
    if not os.path.exists(fifo):
        os.mkfifo(fifo)
    cap = lc.mcap_start(prefix, (0, 0, lc.W, 620), 0.6, 2, f"echo go > {fifo}")
    with open(fifo) as f:
        f.read()
    ptr.click()
    cap.wait(timeout=20)
    t, fr = lc.frames(prefix, keep=bool(keep))
    time.sleep(0.8)
    base = fr[1]
    moved = [int((np.abs(f - base).sum(axis=2) > 60).sum()) for f in fr]
    first = next((i for i, v in enumerate(moved) if i > 1 and v > 200), None)
    if first is None:
        return None
    col = grey = None
    for i in range(first, len(fr)):
        mine = theirs = False
        for c in reds(fr[i]):
            dp = seg_dist(c[:2], paths[pick][1][:2], paths[pick][0][:2])
            do = seg_dist(c[:2], paths[other][1][:2], paths[other][0][:2])
            if min(dp, do) > 14:
                continue
            if dp < do:
                mine = True
            else:
                theirs = True
        if mine and col is None:
            col = i - first
        if not theirs and grey is None:
            grey = i - first
        if col is not None and grey is not None:
            break
    return col, grey, (t[first + col] - t[first]) if col is not None else None, t[first], moved[first], moved[first + 1] if first + 1 < len(moved) else 0


def main():
    keep = sys.argv[sys.argv.index("--keep") + 1] if "--keep" in sys.argv else None
    runs = int(sys.argv[sys.argv.index("--runs") + 1]) if "--runs" in sys.argv else 3
    pid = lc.session("mc-pick")
    for who, cls in CLS.items():
        if len(lc.clients(cls)) != 1:
            sys.exit(f"mc-pick: needs exactly one {cls} window")
    tmp = keep or tempfile.mkdtemp(prefix="mc-pick-")
    os.makedirs(tmp, exist_ok=True)
    if lc.ipc(pid, "panels", "current"):
        lc.ipc(pid, "panels", "close")
        time.sleep(1.0)
    ptr = lc.Pointer()
    ptr.move(640, 780)
    paths = {who: light_of(pid, who) for who in CLS}
    fails = 0
    try:
        for who in CLS:
            if paths[who][0] is None or paths[who][1] is None:
                return lc.report(False, who, "close light not found at its place or on its tile") or 1
        for pick, other in (("finder", "settings"), ("settings", "finder")):
            got = []
            for n in range(runs):
                r = run(pid, ptr, pick, other, paths, tmp, keep, n)
                got.append(r)
            ok = all(r is not None and r[0] == MAC and r[1] is not None and 0 <= r[0] - r[1] <= 1 for r in got)
            # the first changed frame is the ring going (a few thousand px), the flight starts in the next
            hold = all(r is not None and r[5] > 4 * r[4] for r in got)
            note = ", ".join("no exit seen" if r is None else f"coloured +{r[0]} frames ({r[2]:.0f} ms; exit {r[3]:.0f} ms after the click), {other} grey +{r[1]}" if r[0] is not None else f"never coloured, {other} grey +{r[1]}" for r in got)
            fails += lc.report(ok, f"{pick} picked, {other} key", note + f" (Mac +{MAC}, the old key window grey in the same frame)")
            fails += lc.report(hold, f"{pick} picked: nothing moves in the first changed frame",
                               ", ".join("-" if r is None else f"{r[4]} then {r[5]} px changed" for r in got) + " (Mac 11862 then 95702 at half size)")
    finally:
        ptr.close()
        fifo = os.path.join(tmp, "click")
        if os.path.exists(fifo):
            os.remove(fifo)
        if not keep:
            try:
                os.rmdir(tmp)
            except OSError:
                pass
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
