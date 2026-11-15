#!/usr/bin/env python3
"""Live check: the window lights' colours in dark, on screen, against the Mac's stills converted to sRGB
(MAC-ANSWERS-16.md R16.4: windows/lights-{finder,system-settings}-active-dark-{p3,srgb}.png; ours draws sRGB,
reference/ours/COLOUR-P3-AUDIT.md). Numbers are the mean of the central 11 x 11 px of a disc at 2x:

  active    close (242.3, 91.2, 81.2)  minimise (252.5, 191.2, 5.9)  zoom (35.7, 191.5, 12.7); the same for Finder and
            System Settings. (The file as screencapture wrote it holds Display P3 numbers, 225,99,86 / 243,194,34 /
            93,188,33: those are what earlier notes compared our sRGB pixels with.)
  inactive  one white layer over the window, the same for the three discs: alpha .170 in the centre ((72.7,74.6,75.3)
            over Finder's (35,38,39); lights-inactive-dark.png: (76,76.5,82) over (39,40,47), also .170), .195 two
            rows under the top rim, .15 above the bottom rim. Judged as that alpha, so the bar's own colour drops out.

Needs one hyprk Finder and one hyprk System Settings window that do not overlap (finder/run.sh, settings/run.sh in
the session), scale 2. The session's scratch appearance.json is set to dark and put back.

  lights-colour.py [--keep DIR]      exit 0 = every disc within 6 levels (active) / .02 of the alpha (inactive)
"""
import json, os, sys, time

import numpy as np

import livecheck as lc

MAC = {"close": (242.3, 91.2, 81.2), "minimise": (252.5, 191.2, 5.9), "zoom": (35.7, 191.5, 12.7)}
VEIL = {"centre": 0.170, "top": 0.195, "bottom": 0.150}
X = (26, 49, 72)       # disc centres in the window, pt (the Mac's: 26 / 49 / 72, y 26)
Y = 26


def discs(img, wx, wy):
    out = []
    for cx in X:
        px, py = (wx + cx) * 2, (wy + Y) * 2
        centre = img[py - 5:py + 6, px - 5:px + 6].reshape(-1, 3).mean(axis=0)
        top = img[py - 11:py - 9, px - 2:px + 2].reshape(-1, 3).mean(axis=0)       # rows 3-4 of the 28
        bottom = img[py + 9:py + 11, px - 2:px + 2].reshape(-1, 3).mean(axis=0)    # rows 24-25
        out.append((centre, top, bottom))
    # the bar beside the lights: between the discs, on their centre row
    bg = np.mean([img[(wy + Y) * 2 - 2:(wy + Y) * 2 + 2, (wx + cx) * 2 + 20:(wx + cx) * 2 + 26].reshape(-1, 3).mean(axis=0) for cx in X[:2]], axis=0)
    return out, bg


def main():
    keep = sys.argv[sys.argv.index("--keep") + 1] if "--keep" in sys.argv else ""
    lc.session("lights-colour")
    state = os.environ.get("HYPRK_STATE", "")
    if not state or os.path.realpath(state) == os.path.realpath(os.path.join(lc.ROOT, "state")):
        sys.exit("lights-colour: export the session's scratch HYPRK_STATE (never the repo's state folder)")
    wins = {}
    for cls, name in (("hyprk-finder", "Finder"), ("org.hyprk.Settings", "System Settings")):
        c = lc.clients(cls)
        if len(c) != 1:
            sys.exit(f"lights-colour: needs exactly one {name} window in the session")
        wins[name] = (cls, c[0]["at"], c[0]["size"])
    (ax, ay), (aw, ah) = wins["Finder"][1:]
    (bx, by), (bw, bh) = wins["System Settings"][1:]
    if not (ax + aw <= bx or bx + bw <= ax or ay + ah <= by or by + bh <= ay):
        sys.exit("lights-colour: the two windows overlap")
    path = os.path.join(state, "appearance.json")
    before = open(path).read() if os.path.exists(path) else None
    cfg = json.loads(before) if before else {}
    cfg["mode"], cfg["dark"] = "dark", True
    open(path, "w").write(json.dumps(cfg, indent=2))
    time.sleep(3.0)
    ptr = lc.Pointer()
    fails = 0
    try:
        for name, other in (("Finder", "System Settings"), ("System Settings", "Finder")):
            cls, (wx, wy), (ww, wh) = wins[name]
            lc.front("class:" + cls)
            ptr.move(wx + ww - 60, wy + wh - 40, 40)      # a real click in the content makes it the key window
            ptr.click()
            time.sleep(0.3)
            ptr.move(wx + ww - 60, wy + wh - 20, 40)
            time.sleep(1.0)
            img = lc.grim()
            if keep:
                from PIL import Image
                os.makedirs(keep, exist_ok=True)
                Image.fromarray(img.astype(np.uint8)).save(os.path.join(keep, f"lights-{cls}-active.png"))
            got, _ = discs(img, wx, wy)
            for (k, mac), (centre, _, _) in zip(MAC.items(), got):
                d = float(np.abs(centre - mac).max())
                fails += lc.report(d <= 6, f"{name} active, {k}", f"ours ({centre[0]:.1f}, {centre[1]:.1f}, {centre[2]:.1f}), Mac sRGB {mac} (max {d:.1f})")
            ox, oy = wins[other][1]
            got, bg = discs(img, ox, oy)
            al = lambda c: (c - bg) / (255 - bg)
            cen = np.array([al(g[0]) for g in got])
            top, bot = np.mean([al(g[1]) for g in got]), np.mean([al(g[2]) for g in got])
            grey = np.mean([g[0] for g in got], axis=0)
            ok = np.abs(cen - VEIL["centre"]).max() <= 0.02 and abs(top - VEIL["top"]) <= 0.025 and abs(bot - VEIL["bottom"]) <= 0.025
            fails += lc.report(ok, f"{other} inactive, the three discs",
                               f"({grey[0]:.1f}, {grey[1]:.1f}, {grey[2]:.1f}) over ({bg[0]:.0f}, {bg[1]:.0f}, {bg[2]:.0f}): white at alpha "
                               f"{cen.min():.3f}-{cen.max():.3f} centre, {top:.3f} top, {bot:.3f} bottom (Mac .170 / .195 / .150; (72.7, 74.6, 75.3) over (35, 38, 39))")
    finally:
        ptr.move(640, 400)
        ptr.close()
        if before is None:
            os.remove(path)
        else:
            open(path, "w").write(before)
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
