#!/usr/bin/env python3 -I
"""Compare the built app icon styles (build-styles.py) with the Mac's Dock shots, at the Mac's 66 px tiles.

  check-styles.py [<out-dir for side-by-side crops> [<os-volume-root>]]

With the OS volume also the Settings pane tiles (themes/icons/settings, IconServices on 27.2.1, 128 px): Siri and
Spotlight are layered app icons (SiriPreferenceExtension / SpotlightPreferenceExtension.appex Assets.car), built
here with build-styles.render at 128 px and compared per style over the opaque tile (the light Clear / Tinted
files follow the Mac's Dock, which draws them unlike the tiles, so those two are not compared there).

Shots (macOS 27.2.1, 2x, Dock tilesize 33): reference/screens/27.2.1/dock/dock-dark.png (icon style Dark) and
glass53/dock-dark-white-iconstyles-dark-default-clear-tinted.png (rows Dark / Default / ClearLight / TintedLight,
dark Dock over white). The second has no colour profile; its values are the display's (the profile of
dock-dark.png, same Mac): both are converted to sRGB first. Each icon is placed by the best fit of Apple's own
Default bitmap (or the dark one) within +-4 px; rms is over the icon body eroded by 2 px, sRGB 0..255.
Clear icons are composited over the Dock pixels next to the icon, as on the Mac.
"""
import io, os, sys
import numpy as np
from PIL import Image, ImageCms
from numpy.lib.stride_tricks import sliding_window_view

here = os.path.dirname(os.path.abspath(__file__))
icons = os.path.dirname(here)
root = os.path.dirname(os.path.dirname(icons))
shots = f"{root}/reference/screens/27.2.1"
S = 66


def srgb(path, icc_from=None):
    im = Image.open(path)
    icc = im.info.get("icc_profile") or (Image.open(icc_from).info.get("icc_profile") if icc_from else None)
    im = im.convert("RGB")
    if icc:
        im = ImageCms.profileToProfile(im, ImageCms.ImageCmsProfile(io.BytesIO(icc)), ImageCms.createProfile("sRGB"),
                                       renderingIntent=0)
    return np.asarray(im).astype(np.float32) / 255


def small(path):
    p = np.asarray(Image.open(path).convert("RGBa").resize((S, S), Image.LANCZOS)).astype(np.float32) / 255
    return p        # premultiplied


def body(p):
    m = p[..., 3] > 0.995
    mm = np.zeros_like(m); mm[2:-2, 2:-2] = sliding_window_view(m, (5, 5)).all(axis=(2, 3))
    return mm


def place(p, shot, cx, cy, win=4):
    best = None
    for dy in range(-win, win + 1):
        for dx in range(-win, win + 1):
            x0, y0 = cx - S // 2 + dx, cy - S // 2 + dy
            sp = shot[y0:y0 + S, x0:x0 + S]
            m = body(p)
            r = np.sqrt((((p[..., :3] / np.maximum(p[..., 3:4], 1e-6) - sp)[m] * 255) ** 2).mean())
            if best is None or r < best[0]: best = (r, x0, y0)
    return best[1:]


def compare(p, shot, x0, y0, over=False, ref=None):
    sp = shot[y0:y0 + S, x0:x0 + S]
    if over:   # translucent icon over the Dock: the Dock colour just outside the icon
        bg = np.median(shot[y0 + S // 2 - 4:y0 + S // 2 + 4, x0 - 4:x0 - 1].reshape(-1, 3), 0)
        rgb = p[..., :3] + bg * (1 - p[..., 3:4]); m = body(ref)
    else:
        rgb = p[..., :3] / np.maximum(p[..., 3:4], 1e-6); m = body(p)
    d = (rgb - sp)[m] * 255
    return np.sqrt((d ** 2).mean()), d.mean(0), rgb * m[..., None], sp * m[..., None]


if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else None
    dock = srgb(f"{shots}/dock/dock-dark.png")
    sheet = srgb(f"{shots}/glass53/dock-dark-white-iconstyles-dark-default-clear-tinted.png", f"{shots}/dock/dock-dark.png")
    rows = {"default": 59, "dark-dark": 59 - 114, "clear-light": 59 + 114, "tinted-light": 59 + 228}
    cols = {"Finder": 48, "Safari": 188, "Mail": 328, "Notes": 398, "System_Settings": 678}
    tiles = []
    print("Dark style Dock (dock-dark.png):")
    for n, cx in {"Finder": 68, "Mail": 348, "Notes": 418, "System_Settings": 698, "Calculator": 1150}.items():
        p = small(f"{icons}/apps/{n}-256-dark-dark.png")
        x0, y0 = place(p, dock, cx, 76)
        r, mean, a, b = compare(p, dock, x0, y0)
        print(f"  {n:16s} rms {r:5.1f}  mean diff {np.round(mean, 1)}")
        tiles.append(np.concatenate([a, b], 1))
    print("Style sheet (rows of glass53/...-clear-tinted.png):")
    for n, cx in cols.items():
        small_ref = small(f"{icons}/apps/{n}-512.png")
        x0, y0 = place(small_ref, sheet, cx, 173)
        line = [f"  {n:16s}"]
        for style, cy in rows.items():
            p = small_ref if style == "default" else small(f"{icons}/apps/{n}-256-{style}.png")
            r, mean, a, b = compare(p, sheet, x0, y0 + cy - 59, over=style == "clear-light", ref=small_ref)
            line.append(f"{style} {r:5.1f}")
            tiles.append(np.concatenate([a, b], 1))
        print("  ".join(line))
    if len(sys.argv) > 2:
        import importlib.util
        sys.path.insert(0, here)
        spec = importlib.util.spec_from_file_location("bs", f"{here}/build-styles.py")
        bs = importlib.util.module_from_spec(spec); spec.loader.exec_module(bs)
        ext = f"{sys.argv[2]}/System/Library/ExtensionKit/Extensions"
        print("Settings pane tiles (128 px, rms over the opaque tile):")
        for pane, appex, stem in (("siri", "SiriPreferenceExtension", "AppIconSiri"),
                                  ("spotlight", "SpotlightPreferenceExtension", "AppIcon")):
            st = f"{icons}/settings/{pane}@128"
            r = bs.render(bs.IS.Stack(f"{ext}/{appex}.appex/Contents/Resources/Assets.car"), stem,
                          Image.open(f"{st}-default-light.png"), 128)
            line = [f"  {pane:16s}"]
            for style in ("dark-dark", "tinted-dark", "clear-dark"):
                ref = np.asarray(Image.open(f"{st}-{style}.png").convert("RGBA")).astype(np.float32) / 255
                m = ref[..., 3] > 0.995
                line.append(f"{style} {np.sqrt((((r[style][0] - ref[..., :3])[m] * 255) ** 2).mean()):5.1f}")
            print("  ".join(line))
    if out:
        os.makedirs(out, exist_ok=True)
        grid = np.concatenate([np.concatenate(tiles[i:i + 5], 1) for i in range(0, len(tiles), 5)], 0)
        Image.fromarray((np.clip(grid, 0, 1) * 255).round().astype("uint8")).save(f"{out}/styles-vs-mac.png", optimize=True)
