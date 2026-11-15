#!/usr/bin/env python3
"""Live check: a Dock tile dragged off by the pointer and dropped under "Remove" (shell/modules/Dock.qml dragDrop).
Mac (MAC-ANSWERS-16.md "Hand actions", screens/27.2.1/sound/dock-drag-off-hand.mov, a trackpad drag by hand, read
per frame and per sample): release logged 6.074 s (+-20 ms); the icon and its "Remove" label fade in place, linear,
first fading frame 6.100 s, gone at 6.350 s (250 ms; amount left .98 .91 .87 .78 .72 .64 .57 .47 .42 .35 .29 .21 .18
.12 .08 0); `poof item off dock.aif` cross-correlated with the clip's audio (r .999) starts at 6.128 s, 28 ms after
the first fading frame (the menu's removal: 20 ms after the Dock's first moving frame, sound-timing.py poof); no
cloud, no fly-back; the Dock closed the gap during the drag.

Session: see livecheck.py, started with HYPRK_SOUND_LOG=<file> (HYPRK_MUTE=1: nothing is played), HYPRK_STATE the
scratch state folder (dock-items.json is written and put back). The Dock keeps the pointer outside its window only
while a window has the keyboard focus, so the check starts a Finder window of its own when the desktop is empty and
ends it by pid.

  dock-drag-off.py [--runs N] [--player-ms 12]      exit 0 = every case passed
"""
import json, os, sys, time

import numpy as np

import livecheck as lc

FRAME = 1000 / 60
MAC = [.98, .91, .87, .78, .72, .64, .57, .47, .42, .35, .29, .21, .18, .12, .08, 0]


def one(pid, log, path, ptr, prefix, player):
    open(path, "w").write('{"removed":[],"downloads":{}}')
    time.sleep(1.5)
    tx = lc.dock_tile(ptr)
    if tx is None:
        return None, "TextEdit's tile not found in the Dock"
    for dx in (-12, -5, 0):
        ptr.move(tx + dx, 786, 40)
    time.sleep(0.4)
    ptr.down()
    time.sleep(0.15)
    for y in range(780, 648, -6):               # 135 pt up, as the Mac's take
        ptr.move(tx, y, 16)
        time.sleep(0.02)
    ptr.move(tx, 651, 16)
    time.sleep(1.3)                             # "Remove" shows 0.25 s after the pointer left the Dock
    from sound_watch import Watch
    w = Watch({"player": log}, 3.0)
    m = lc.mcap_start(prefix, (tx - 60, 590, 120, 110), 1.2, 1)
    time.sleep(0.4)
    t0 = time.monotonic_ns()
    ptr.up()
    m.wait()
    st = w.done()
    meta = json.load(open(prefix + ".json"))
    t, fr = lc.frames(prefix)
    t = t + (meta["t0_ns"] - t0) / 1e6
    held, end = fr[t < 0][-1], fr[-1]
    # the amount left is read on the icon's rows (from 30 pt under the region's top): the bubble above it is glass,
    # whose blur of a window behind it does not fade with it (a step at the end over text; not on the Mac's clip,
    # which has the wallpaper there)
    icon = slice(60, None)
    full = np.abs(held[icon] - end[icon]).sum()
    left = np.array([np.abs(f[icon] - end[icon]).sum() / full if full else 0 for f in fr])
    shown = int((np.abs(held - end).max(axis=2) > 12).sum())
    fading = np.nonzero((t > 0) & (left < 0.995))[0]
    gone = np.nonzero((t > 0) & (left < 0.01))[0]
    if shown < 400 or not len(fading) or not len(gone) or "player" not in st:
        return None, f"icon and bubble {shown} px, fade {'seen' if len(fading) else 'not seen'}, sound {'logged' if 'player' in st else 'not logged'}"
    first, last = float(t[fading[0]]), float(t[gone[0]])
    snd = (st["player"] - t0) / 1e6 + player
    # against the Mac's amounts: ours at the Mac's frame times after the first fading frame
    ours = np.interp(first + FRAME * np.arange(len(MAC)), t, left)
    rms = float(np.sqrt(((ours - np.array(MAC)) ** 2).mean()))
    removed = json.load(open(path)).get("removed", [])
    return dict(first=first, last=last - first, snd=snd - first, rms=rms, removed=removed), ""


def main():
    args = sys.argv[1:]
    runs = int(args[args.index("--runs") + 1]) if "--runs" in args else 3
    player = float(args[args.index("--player-ms") + 1]) if "--player-ms" in args else 12.0
    pid = lc.session("dock-drag-off", need=("HYPRK_MUTE=1",))
    env = lc.environ(pid)
    log = next((e[len(b"HYPRK_SOUND_LOG="):].decode() for e in env if e.startswith(b"HYPRK_SOUND_LOG=")), "")
    state = os.environ.get("HYPRK_STATE", "")
    if not log:
        sys.exit("dock-drag-off: start the session with HYPRK_SOUND_LOG=<file>")
    if not state or os.path.realpath(state) == os.path.realpath(os.path.join(lc.ROOT, "state")):
        sys.exit("dock-drag-off: export the session's scratch HYPRK_STATE (never the repo's state folder)")
    if not os.path.exists(log):
        open(log, "a").close()
    path = os.path.join(state, "dock-items.json")
    before = open(path).read() if os.path.exists(path) else None
    own = None
    if not lc.clients():
        own = lc.launch(pid, [os.path.join(lc.ROOT, "finder/run.sh"), os.path.expanduser("~")])
        lc.wait_client("hyprk-finder")
        time.sleep(1.5)
    win = lc.clients()
    if win:
        lc.front("address:" + win[0]["address"])
    ptr = lc.Pointer()
    prefix = os.path.join(os.path.dirname(log), "dock-drag-off")
    rows, why = [], ""
    try:
        for _ in range(runs):
            r, why = one(pid, log, path, ptr, prefix, player)
            ptr.move(640, 400)
            time.sleep(0.8)
            if r is None:
                break
            rows.append(r)
    finally:
        ptr.up()
        ptr.move(640, 400)
        ptr.close()
        if before is None:
            os.path.exists(path) and os.remove(path)
        else:
            open(path, "w").write(before)
        for ext in (".raw", ".csv", ".json"):
            if os.path.exists(prefix + ext):
                os.remove(prefix + ext)
        if own is not None:
            own.terminate()
    if len(rows) < runs:
        return lc.report(False, "drag off", why)
    col = lambda k: [r[k] for r in rows]
    rng = lambda v: f"{min(v):.0f}..{max(v):.0f} (mean {sum(v) / len(v):.1f})"
    m = lambda k: sum(col(k)) / len(rows)
    fails = lc.report(m("first") <= 26 + 20 + FRAME, "release -> first fading frame", f"{rng(col('first'))} ms (Mac 26 after the logged release, +-20)")
    fails += lc.report(abs(m("last") - 250) <= FRAME, "icon and Remove fade in place", f"gone {rng(col('last'))} ms after the first fading frame (Mac 250)")
    fails += lc.report(max(col("rms")) <= 0.06, "the fade is the Mac's linear one", f"rms {max(col('rms')):.3f} of the amount left against the Mac's 16 frames")
    fails += lc.report(20 - FRAME / 2 <= m("snd") <= 28 + FRAME, "poof against the first fading frame", f"{rng(col('snd'))} ms (Mac +28; the menu's removal +20)")
    fails += lc.report(all(len(r) == 1 for r in col("removed")), "item removed", f"dock-items.json removed = {rows[-1]['removed']}")
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
