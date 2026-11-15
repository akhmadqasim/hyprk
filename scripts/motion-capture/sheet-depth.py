#!/usr/bin/env python3
"""Live check: depth of a System Settings sheet against the Mac's stills (JUDGE-95-23 Settings defects 1 and 2):
the sheet's shadow over the dimmed pane (right of, under and above the sheet) and the window's lights above the dim
(close greyed out, minimise and zoom in colour). Menu Bar > Clock Options…, light and dark, each compared pixel for
pixel with reference/re/27.2.1/live/settings-r13/dest-controlCenter--clock-options-{light,dark}.png (740 x 625 pt
window at 2x, the same crop of ours).

Session: see livecheck.py, with a hyprk System Settings window open at its default size (`livecheck.py run
settings/run.sh`: the session's environment and scratch HOME). The check uses the shell's default wallpaper (the
Mac's): a wallpaper.json in the state folder is set aside for the run, the window's tint follows the wallpaper. HYPRK_STATE must be the session's scratch state
folder: the mode is switched in its appearance.json and put back.

  sheet-depth.py [--keep DIR]      exit 0 = every profile within TOL levels of the Mac's; --keep saves the two crops
"""
import json, os, sys, time

import numpy as np
from PIL import Image

import livecheck as lc

REF = os.path.join(lc.ROOT, "reference/re/27.2.1/live/settings-r13/dest-controlCenter--clock-options-%s.png")
SHEET = (135, 52, 470, 533)          # the sheet in the window, pt (R13, AX: 470 x 533 at y 52)
TOL = 4


def profiles(img):
    """grey levels outside the sheet, every 2 pt, 2 x 2 pt means: right of it (row y 300), under it and above it (x 500)"""
    g = img[:, :, :3].mean(axis=2)
    x0, y0, w, h = SHEET
    box = lambda x, y: float(g[int(y * 2):int(y * 2) + 4, int(x * 2):int(x * 2) + 4].mean())
    return {"right": [box(x0 + w + 1 + d, 300) for d in range(0, 32, 4)],
            "under": [box(500, y0 + h + 1 + d) for d in range(0, 36, 4)],
            "above": [box(500, y0 - 3 - d) for d in range(0, 28, 4)]}


def lights(img):
    """mean colour of each light's middle (close, minimise, zoom: 14 pt discs at x 26 / 49 / 72, y 26 pt in ours; the
    discs are found by their rows, so a 1 pt offset does not matter)"""
    out = []
    for cx in (26, 49, 72):
        a = img[int(26 * 2) - 6:int(26 * 2) + 6, int(cx * 2) - 6:int(cx * 2) + 6, :3]
        out.append(tuple(int(round(v)) for v in a.reshape(-1, 3).mean(axis=0)))
    return out


def main():
    keep = sys.argv[sys.argv.index("--keep") + 1] if "--keep" in sys.argv else ""
    lc.session("sheet-depth")
    state = os.environ.get("HYPRK_STATE", "")
    if not state or os.path.realpath(state) == os.path.realpath(os.path.join(lc.ROOT, "state")):
        sys.exit("sheet-depth: export the session's scratch HYPRK_STATE (never the repo's state folder)")
    win = [c for c in lc.clients("org.hyprk.Settings") if c["size"] == [740, 625]]
    if not win:
        sys.exit("sheet-depth: no 740 x 625 hyprk System Settings window in the session")
    wx, wy = win[0]["at"]
    app = win[0]["pid"]
    if keep:
        os.makedirs(keep, exist_ok=True)
    path = os.path.join(state, "appearance.json")
    had = os.path.exists(path)
    before = open(path).read() if had else "{}"
    # The Mac's stills are over the Tahoe wallpaper and the window takes its tint from the wallpaper: the bar under
    # close is (35,37,52) there, and neutral over a grey one (JUDGE-95-25 read close (78,78,78) over a flat grey 127
    # wallpaper, which is right for that wallpaper). So the session's wallpaper.json is set aside for the run: the
    # shell's default picture is the Mac's
    wp = os.path.join(state, "wallpaper.json")
    wp_before = open(wp).read() if os.path.exists(wp) else None
    if wp_before is not None:
        os.remove(wp)
        time.sleep(2.0)
    ptr = lc.Pointer()
    fails = 0
    try:
        lc.front("class:org.hyprk.Settings")
        for mode in ("light", "dark"):
            cfg = json.loads(before)
            cfg["mode"], cfg["dark"] = mode, mode == "dark"
            open(path, "w").write(json.dumps(cfg, indent=2))
            time.sleep(3.0)
            # sidebar: Menu Bar (again: a reload of the app goes back to its first pane). The row is found by its
            # name: the rows above it depend on the machine (no Wi-Fi row without a Wi-Fi device: 32 pt higher,
            # JUDGE-95-24 opened Spotlight with the fixed y 538)
            row = lc.ipc(app, "settings", "row", "Menu Bar").split()
            if len(row) != 2:
                sys.exit("sheet-depth: the Settings sidebar lists no Menu Bar row")
            rx, ry = wx + int(row[0]), wy + int(row[1])
            for dx in (-10, -4, 0):
                ptr.move(rx + dx, ry, 40)
            ptr.click()
            time.sleep(1.2)
            for dx in (-10, -4, 0):                   # Clock Options…
                ptr.move(wx + 650 + dx, wy + 391, 40)
            ptr.click()
            ptr.move(wx + 700, wy + 600, 40)          # off the sheet, off the lights
            time.sleep(1.2)
            ours = lc.grim()[wy * 2:(wy + 625) * 2, wx * 2:(wx + 740) * 2]
            mac = np.asarray(Image.open(REF % mode).convert("RGB")).astype(int)
            if keep:
                Image.fromarray(np.concatenate([mac, ours], axis=1).astype(np.uint8)).save(
                    os.path.join(keep, f"sheet-clock-options-{mode}-mac-left-ours-right.png"))
            po, pm = profiles(ours), profiles(mac)
            for k in ("right", "under", "above"):
                d = max(abs(a - b) for a, b in zip(po[k], pm[k]))
                fails += lc.report(d <= TOL, f"{mode}: shadow {k} of the sheet",
                                   "ours " + " ".join(f"{v:.0f}" for v in po[k]) + " / Mac " + " ".join(f"{v:.0f}" for v in pm[k]) + f" (max {d:.1f})")
            # the Mac: close turns grey, minimise and zoom keep the window's own colours (dest-controlCenter-dark.png
            # against the sheet's still: (244,192,0) (243,194,45) / (88,187,2) (98,189,46) in both). How far our lights'
            # colours are from this still's is LIGHTS-REA's matter (its fit is to windows/lights-*.png), printed only
            lo, lm = lights(ours), lights(mac)
            dc = max(abs(a - b) for a, b in zip(lo[0], lm[0]))
            colour = all(max(o) - min(o) > 60 and int(np.argmax(o)) == int(np.argmax(m)) for o, m in zip(lo[1:], lm[1:]))
            fails += lc.report(dc <= 8 and colour, f"{mode}: lights above the dim",
                               f"close {lo[0]} / Mac {lm[0]} (max {dc}); minimise, zoom in colour {lo[1:]} / Mac {lm[1:]}")
            # the veiled window keeps its colour: toolbar, pane and card, 10 x 4 px means (dark: the wallpaper's tint
            # stays under the sheet and the veil is (20,22,24.5); light is neutral)
            spots = {"toolbar": (20, 1000), "pane": (600, 1440), "card": (300, 1380)}
            box = lambda im, y, x: im[y:y + 4, x:x + 10, :3].reshape(-1, 3).mean(axis=0)
            dv = max(float(np.abs(box(ours, y, x) - box(mac, y, x)).max()) for y, x in spots.values())
            fails += lc.report(dv <= 2, f"{mode}: the veiled window's colour",
                               "; ".join(f"{n} " + " ".join(f"{v:.0f}" for v in box(ours, y, x)) + " / Mac " + " ".join(f"{v:.0f}" for v in box(mac, y, x))
                                         for n, (y, x) in spots.items()) + f" (max {dv:.1f})")
            lc.key("Escape", "class:org.hyprk.Settings")
            time.sleep(0.8)
    finally:
        if had:
            open(path, "w").write(before)
        else:
            os.remove(path)
        if wp_before is not None:
            open(wp, "w").write(wp_before)
        ptr.close()
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
