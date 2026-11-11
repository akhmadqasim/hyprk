#!/usr/bin/env python3 -I
"""Build themes/icons/apps/<Name>-{1024,512,256,128}.png from the app icons in Assets.car.

Per app the best real source wins: a pre-rendered 1024 px bitmap, else the pre-rendered 512 px
(= 256@2x) bitmap. 512, 256 and 128 are Lanczos-downsampled from it (premultiplied alpha). An app with
no usable rendition keeps its files (upscaled from the 256 px .icns, listed in the log).
macOS 27 also stores the app icons as layers (.iconstack, SVG, gradients) for the Icon Composer
renderer; those are not rendered here, the pre-rendered bitmaps are Apple's own render.

  build-apps.py <os-volume-root> [<appos-volume-root>]      (read-only apfs-fuse mounts, reference/ASSETS.md)
Log: themes/icons/apps-build.log
"""
import os, sys
from PIL import Image

here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
import car as carlib

icons = os.path.dirname(here)
roots = {"os": sys.argv[1], "appos": sys.argv[2] if len(sys.argv) > 2 else None}


def best(path, stem):
    c = carlib.Car(path)
    cand = None
    for fname, attrs, r in c.renditions():
        if fname != stem or r["tag"] != "CELM" or r["layout"] != 12 or r["w"] != r["h"]: continue
        if r["pix"] not in ("ARGB", "GA8 ") or r["comp"] not in (0, 2, 4): continue
        if not ("NSAppearanceNameSystem" in r["name"] or "UIAppearanceAny" in r["name"] or r["name"].startswith("icon_")): continue
        if cand is None or r["w"] > cand["w"]: cand = r
    return cand


def down(im, n):
    if im.size[0] == n: return im
    return im.convert("RGBa").resize((n, n), Image.LANCZOS).convert("RGBA")


log = []
for line in open(os.path.join(icons, "apps-sources.txt")):
    if line.startswith("#") or not line.strip(): continue
    name, app, stem, vol = line.rstrip("\n").split("\t")
    root = roots[vol]
    if not root:
        log.append(f"skip {name}: {vol} volume not given"); continue
    carpath = f"{root}{app}/Contents/Resources/Assets.car"
    r = best(carpath, stem) if os.path.exists(carpath) else None
    im = carlib.decode(r) if r else None
    if im is None:
        log.append(f"upscaled {name}: no pre-rendered bitmap for {stem} in {app}"); continue
    out = f"{icons}/apps/{name}"
    if im.size[0] >= 1024: im.save(f"{out}-1024.png", optimize=True)
    for n in (512, 256, 128):       # 256: AppIconTile picks the smallest file at or above the drawn size
        down(im, n).save(f"{out}-{n}.png", optimize=True)
    log.append(f"real {r['w']} {name} <- {app} :: {r['name'][:48]} ({r['pix'].strip()})")
open(os.path.join(icons, "apps-build.log"), "w").write("\n".join(log) + "\n")
print("\n".join(l for l in log if not l.startswith("real")) or "all real")
print(sum(l.startswith("real") for l in log), "real,", sum(l.startswith("upscaled") for l in log), "upscaled")
