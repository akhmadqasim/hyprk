#!/usr/bin/env python3
"""Live check: what a clicked menu item does before its menu goes, frame by frame (mcap, 60 Hz): the row's highlight
blinks off and on, then the menu fades, then (for the Dock's Remove from Dock) the tile is removed.

The Mac (60 fps clips read by pts; "frame 0" = the first frame with the highlight off):
  AppKit's menus  off 4 frames, on 3, the first fading frame is the 7th and shows the fade 1.9 frames in; the fade is
                  CA default over 232-236 ms (Q-menubar-24, R3.5: controls/popup-menu-open-close-{light,dark}.mov,
                  MOTION-AUDIT.md "Settings pop-up button menu")
  the Dock's menu off 4 frames (4.533-4.600 s), on 4 (4.600-4.667), the first fading frame is the 8th and shows the
                  fade 1.6-1.7 frames in; row blue per frame 224.2 207.1 189.6 170.6 159.1 147.2 139.0 131.6 127.5
                  124.5 120.5 118.6 118.2 between 239.15 and 118.2 = CA default over 242 ms (rms .0056; over our 236
                  .0076): the same fade as AppKit's. The fade's last changing frame is the 20th (4.867), the Dock's
                  first moving frame the 22nd (4.900, 367 ms after frame 0) and the poof's first sample falls in it
                  (MAC-ANSWERS-16.md R16.1, sound/dock-remove-menu-real-click.mov, a HID-level click; mouse up to
                  frame 0 about 53 ms on the logged clock, +-20, capture path included)

Cases (each a real vptr click, `--runs N` times, default 3):
  desktop   the desktop's context menu > New Folder (an AppKit menu; the folder is made on the SESSION's Desktop, which
            must be a scratch HOME, and removed again)
  dock      TextEdit's Dock tile > Options > Remove from Dock (the scratch dock-items.json is put back)

Session: see livecheck.py; export HYPRK_STATE (the scratch state folder, never the repo's).

  menu-blink.py [desktop|dock ...] [--runs N]      exit 0 = every run inside one frame of the Mac's counts
"""
import json, os, sys, time

import numpy as np

import livecheck as lc

FRAME = 1000 / 60
# the Mac's fade as progress per frame from its first fading frame (R16.1, the row's blue)
MAC_FADE = [(239.15 - b) / (239.15 - 118.2) for b in (224.2, 207.1, 189.6, 170.6, 159.1, 147.2, 139.0, 131.6, 127.5, 124.5, 120.5, 118.6, 118.2)]
# AppKit's menus: CA default over 236 ms seen 1.9 frames in at the first fading frame (R3.5: .153 .310 .471 .607 .714)
MAC_FADE_APPKIT = [0.154, 0.306, 0.463, 0.598, 0.706, 0.789, 0.854, 0.904, 0.940, 0.967, 0.985, 0.996, 1.0]
MAC = {"desktop": dict(off=4, on=3, fade0=7, fade=MAC_FADE_APPKIT), "dock": dict(off=4, on=4, fade0=8, gone=20, removal=22, fade=MAC_FADE)}


def read(t, fr, patch, dock=None, body=None):
    """t ms from the click, fr frames; patch (x0, y0, x1, y1) capture px inside the clicked row, clear of its text;
    body: a strip of plain menu, whose fade is reported next to the row's ("fade_body").
    Returns frame counts from the first frame with the highlight off."""
    x0, y0, x1, y1 = patch
    v = fr[:, y0:y1, x0:x1, :].reshape(len(fr), -1, 3).mean(axis=1)
    hi, end = v[t < 0][-1], v[-1]
    span = np.linalg.norm(hi - end)
    d = np.linalg.norm(v - hi, axis=1) / span         # 0 = highlighted as before the click, 1 = the menu gone
    after = np.nonzero(t >= 0)[0]
    changed = [i for i in after if d[i] > 0.02]
    if not changed:
        return None
    f0 = changed[0]
    back = next((i for i in range(f0, min(f0 + 12, len(d))) if d[i] < 0.02), None)
    if back is None:                                  # no blink: the fade starts at once
        on0 = fade0 = f0
    else:
        on0 = k = back
        while k < len(d) and d[k] < 0.015:            # on again, at full strength
            k += 1
        fade0 = k
    fade = [float(x) for x in d[fade0:fade0 + len(MAC_FADE)]]
    gone = next((i for i in range(fade0, len(d)) if d[i] > 0.996), len(d) - 1)
    out = dict(lag=float(t[f0]), step=float(np.median(np.diff(t[f0:f0 + 20]))), off=on0 - f0, on=fade0 - on0, fade0=fade0 - f0,
               fade=fade, gone=gone - f0)
    if body is not None:
        x0, y0, x1, y1 = body
        w = fr[:, y0:y1, x0:x1, :].reshape(len(fr), -1, 3).mean(axis=1)
        e = np.linalg.norm(w - w[t < 0][-1], axis=1) / max(1e-6, np.linalg.norm(w[t < 0][-1] - w[-1]))
        out["fade_body"] = [float(x) for x in e[fade0:fade0 + len(MAC_FADE)]]
    if dock is not None:
        a, b = dock
        pre = fr[t < 0][-1][a:b]
        ch = np.array([(np.abs(f[a:b] - pre).max(axis=2) > 4).sum() for f in fr])
        seen = [i for i in after if ch[i] > 20]
        out["removal"] = seen[0] - f0 if seen else None
        out["removal_ms"] = float(t[seen[0]]) if seen else None
    return out


def capture(prefix, region, seconds, ptr):
    m = lc.mcap_start(prefix, region, seconds, 2)
    time.sleep(0.5)
    t0 = time.monotonic_ns()
    ptr.click()
    m.wait()
    meta = json.load(open(prefix + ".json"))
    t, fr = lc.frames(prefix)
    return t + (meta["t0_ns"] - t0) / 1e6, fr


def judge(name, rows):
    mac = MAC[name]
    fails = 0
    rows = [r for r in rows if r]
    if not rows:
        return lc.report(False, name, "no blink seen")
    col = lambda k: [r.get(k) for r in rows]
    for k, label in (("off", "highlight off"), ("on", "highlight on again"), ("fade0", "first fading frame"),
                     ("gone", "menu gone"), ("removal", "Dock's first moving frame")):
        if k not in mac:
            continue
        v = col(k)
        fails += lc.report(None not in v and abs(np.median(v) - mac[k]) <= 1 and max(abs(x - mac[k]) for x in v) <= 2, f"{name}: {label}",
                           f"frames {[int(x) if x is not None else None for x in v]}, Mac {mac[k]}" + (" (counted from the first frame with the highlight off)" if k != "off" and k != "on" else ""))
    if name == "dock":
        v = col("parent")
        fails += lc.report(all(x is not None and abs(x - f) <= 1 for x, f in zip(v, col("fade0"))), "dock: the parent menu fades with the submenu",
                           f"parent's first fading frame {v}, submenu's {[int(x) for x in col('fade0')]} (Mac: both in the same frame)")
    # the plain menu beside the row carries the fade's time (its glass and text go together); the chosen row's own
    # colour is listed: its highlight fades over glass that is still there, so its path bends towards the glass colour
    for key, label, limit in (("fade_body", "the fade against the Mac's 13 frames, plain menu", 0.05), ("fade", "the chosen row's colour over the same frames", None)):
        rms = [float(np.sqrt(np.mean((np.array(r[key]) - mac["fade"]) ** 2))) for r in rows if len(r.get(key, [])) == len(mac["fade"])]
        note = "rms " + " ".join(f"{x:.3f}" for x in rms) + "; ours " + " ".join(f"{x:.2f}" for x in rows[0].get(key, [])) + "; Mac " + " ".join(f"{x:.2f}" for x in mac["fade"])
        if limit is None:
            print(f"     {name}: {label}: {note}")
        else:
            fails += lc.report(bool(rms) and max(rms) <= limit, f"{name}: {label}", note)
    print(f"     {name}: click -> highlight off {min(col('lag')):.0f}-{max(col('lag')):.0f} ms, frame {np.mean(col('step')):.1f} ms"
          + (f", click -> Dock moves {min(col('removal_ms')):.0f}-{max(col('removal_ms')):.0f} ms (Mac: frame 22 = 367 ms after the off, about 420 after the mouse up)"
             if name == "dock" and None not in col("removal_ms") else ""))
    return fails


def desktop_case(pid, scratch, runs, ptr):
    home = next((e[5:].decode() for e in lc.environ(pid) if e.startswith(b"HOME=")), "")
    if not home or os.path.realpath(home) == os.path.realpath(os.path.expanduser("~" + os.environ.get("USER", ""))):
        return lc.report(False, "desktop", "the session's HOME is not a scratch folder: New Folder not clicked")
    rows = []
    x, y = 300, 200
    prefix = os.path.join(scratch, "menu-blink-desktop")
    for _ in range(runs):
        ptr.move(640, 420)
        time.sleep(0.4)
        lc.ipc(pid, "panels", "desktopMenu", str(x), str(y))
        time.sleep(0.7)
        # New Folder, the first row: the menu's top is y - 5, its padding 5, the row 24 pt; the pointer comes in over
        # three moves so the row is entered, not jumped to
        ry = y + 12
        for dx in (30, 44, 50):
            ptr.move(x + dx, ry, 40)
        time.sleep(0.5)
        t, fr = capture(prefix, (x - 20, y - 20, 300, 300), 1.2, ptr)
        # a patch right of the label, inside the selection (capture px at step 2 = pt)
        px = 20 + 150
        py = ry - (y - 20)
        rows.append(read(t, fr, (px, py - 5, px + 40, py + 5), body=(px, py + 14, px + 40, py + 17)))
        time.sleep(0.6)
        lc.ipc(pid, "panels", "close")
        time.sleep(0.8)
    desk = os.path.join(home, "Desktop")
    for n in os.listdir(desk) if os.path.isdir(desk) else []:
        if n.startswith("untitled folder") and not os.listdir(os.path.join(desk, n)):
            os.rmdir(os.path.join(desk, n))
    return judge("desktop", rows)


def dock_case(pid, scratch, runs, ptr):
    path = os.path.join(os.environ["HYPRK_STATE"], "dock-items.json")
    empty = '{"removed":[],"downloads":{}}'
    before = open(path).read() if os.path.exists(path) else empty
    prefix = os.path.join(scratch, "menu-blink-dock")
    rows = []
    try:
        for _ in range(runs):
            open(path, "w").write(empty)
            time.sleep(1.5)
            tx = lc.dock_remove_ready(ptr)
            if tx is None:
                return lc.report(False, "dock", "TextEdit's tile not found in the Dock")
            t, fr = capture(prefix, (360, 560, 560, 272), 1.5, ptr)
            # the submenu's first row, right of its label ("Remove from Dock" ends about 115 pt into the row)
            # the submenu's first row, the 3 pt above its label (the row is 24 pt, its text fills the middle); the
            # same strip of the parent's Options row for the two menus' fades against each other
            px = int(tx + 153 - 360)
            r = read(t, fr, (px - 66, 107, px + 54, 110), dock=(226, 272), body=(px - 66, 131, px + 54, 134))
            if r:
                par = fr[:, 107:110, px - 176:px - 86, :].reshape(len(fr), -1, 3).mean(axis=1)
                moved = np.nonzero((t >= 0) & (np.abs(par - par[t < 0][-1]).max(axis=1) > 2))[0]
                r["parent"] = int(moved[0]) - int(np.nonzero(t >= r["lag"] - 1)[0][0]) if len(moved) else None
            rows.append(r)
            ptr.move(640, 400)
            time.sleep(0.8)
    finally:
        open(path, "w").write(before)
    return judge("dock", rows)


def main():
    args = sys.argv[1:]
    runs = int(args[args.index("--runs") + 1]) if "--runs" in args else 3
    cases = [a for a in args if a in ("desktop", "dock")] or ["desktop", "dock"]
    pid = lc.session("menu-blink")
    state = os.environ.get("HYPRK_STATE", "")
    if not state or os.path.realpath(state) == os.path.realpath(os.path.join(lc.ROOT, "state")):
        sys.exit("menu-blink: export the session's scratch HYPRK_STATE (never the repo's state folder)")
    scratch = os.path.join(state, "run")
    os.makedirs(scratch, exist_ok=True)
    ptr = lc.Pointer()
    fails = 0
    try:
        for c in cases:
            fails += {"desktop": desktop_case, "dock": dock_case}[c](pid, scratch, runs, ptr)
    finally:
        ptr.move(640, 400)
        ptr.close()
        lc.ipc(pid, "panels", "close")
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
