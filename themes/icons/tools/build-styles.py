#!/usr/bin/env python3 -I
"""Build the Dark, Clear and Tinted app icons: themes/icons/apps/<Name>-256-<style>-<mode>.png.

macOS 27.2.1 stores no bitmap for these styles; IconRendering composes them at run time from the icon's
layered source (iconstack.py). Here, per app in apps-sources.txt:
  dark-dark     flat render of the stack's DarkAqua appearance (Apple's layers, fills and dark background),
                in the shape and drop shadow of Apple's Default bitmap. No Liquid Glass pass.
                vs the Mac's Dark-style Dock (dock-dark.png, 66 px tiles): rms 6.4-14.9 on 5 apps.
  tinted-light  tile + layers of the ISAppearanceTintable stack mapped by their luminance L:
                out = tile * (1 - a) + g(L) * a, a = layer coverage. tile and g are FITTED to the Mac's
                TintedLight Dock (glass53/dock-...-clear-tinted.png, Finder/Mail/Notes/Settings, multicolour
                accent = blue); IconRendering's own tint maths was not decoded.
  clear-light   the same with the ClearLight fit, stored as white with alpha so the backdrop shows
                through like the Mac's glass tile: alpha = (v - 176) / 79, 176 = the Mac's dark Dock over white
                behind that shot.
Apps without a stack (ControlCenter) are legacy icons: the Mac leaves those as they are in Dark and maps
their luminance in Clear / Tinted (WebStorm, Spotify in the same shot); the same is done here with a = 1.
TintedDark / ClearDark were not captured on the Mac for app icons, so they are not built (the lookup uses
the light ones). 256 px only: the largest the shell draws an app icon is 128 pt (Dock magnified, Cmd-Tab).

  build-styles.py <os-volume-root> [<appos-volume-root>]       Log: themes/icons/apps-styles.log
"""
import os, sys
import numpy as np
from PIL import Image

here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
import iconstack as IS

icons = os.path.dirname(here)
SIZE = 256
BODY = 824 / 1024          # the 1024 Icon Composer canvas is the 824 px body of a 1024 icon
LUMA = np.array([0.2126, 0.7152, 0.0722])
# fitted on the Mac shot (sRGB 0..255): tile colour, glyph colour g(L) = g0 + L * (g1 - g0), clipped
TINTED = dict(tile=(0, 109, 195), g0=(-84, 83, 189), g1=(114, 241, 255))
CLEAR = dict(tile=(192, 192, 192), g0=(182, 182, 182), g1=(254, 254, 254), backdrop=176)


def down(prem, n):
    """premultiplied float NxN -> premultiplied float n x n (Lanczos)"""
    im = Image.fromarray((np.clip(prem, 0, 1) * 255).round().astype("uint8"), "RGBa").resize((n, n), Image.LANCZOS)
    return np.asarray(im).astype(np.float32) / 255


def place(prem1024):
    """1024 canvas (premultiplied) -> SIZE x SIZE icon cell with the canvas as its body"""
    b = round(SIZE * BODY); o = (SIZE - b) // 2
    out = np.zeros((SIZE, SIZE, 4), np.float32)
    out[o:o + b, o:o + b] = down(prem1024, b)
    return out


def shape(default):
    """Apple's Default bitmap at SIZE: (alpha incl. drop shadow, body coverage)"""
    a = np.asarray(default.convert("RGBa").resize((SIZE, SIZE), Image.LANCZOS)).astype(np.float32)[..., 3] / 255
    shadow = np.percentile(a[a < 0.5], 99) if (a < 0.5).any() else 0     # the shadow halo's peak alpha
    return a, np.clip((a - shadow) / (1 - shadow), 0, 1)


def styled_tile(L, cover, spec, cov):
    t = np.array(spec["tile"], np.float32) / 255
    g = np.clip((np.array(spec["g0"]) + L[..., None] * (np.array(spec["g1"]) - np.array(spec["g0"]))) / 255, 0, 1)
    return t * (1 - cover[..., None]) + g * cover[..., None]


def save(rgb, alpha, path):
    """straight rgb + alpha -> 8-bit RGBA PNG"""
    arr = np.dstack([np.clip(rgb, 0, 1), np.clip(alpha, 0, 1)])
    Image.fromarray((arr * 255).round().astype("uint8"), "RGBA").save(path, optimize=True)


def build(name, stack, stem, default, log):
    alpha, cov = shape(default)
    out = f"{icons}/apps/{name}-{SIZE}"
    tree = stack.tree(stem, "dark") if stack and stack.has_stack(stem) else None
    if tree is not None:
        d = place(IS.flat(tree))
        rgb = d[..., :3] / np.maximum(d[..., 3:4], 1e-6)
        save(rgb * (cov / np.maximum(alpha, 1e-6))[..., None], alpha, f"{out}-dark-dark.png")
        lay = place(IS.flat(stack.tree(stem, "tintable"), layers_only=True))
        cover = lay[..., 3]
        L = (lay[..., :3] / np.maximum(cover[..., None], 1e-6)) @ LUMA
        kind = "stack"
    else:   # legacy icon: Dark leaves it as it is, Clear / Tinted map its luminance
        px = np.asarray(default.convert("RGBA").resize((SIZE, SIZE), Image.LANCZOS)).astype(np.float32) / 255
        save(px[..., :3], px[..., 3], f"{out}-dark-dark.png")
        cover, L, cov, alpha = np.ones((SIZE, SIZE), np.float32), px[..., :3] @ LUMA, px[..., 3], px[..., 3]
        kind = "legacy"
    tinted = styled_tile(L, cover, TINTED, cov)
    save(tinted, cov, f"{out}-tinted-light.png")
    v = styled_tile(L, cover, CLEAR, cov)[..., 0]
    a = np.clip((v - CLEAR["backdrop"] / 255) / (1 - CLEAR["backdrop"] / 255), 0, 1)
    save(np.ones_like(tinted), a * cov, f"{out}-clear-light.png")
    log.append(f"{kind} {name} <- {stem}")


def main():
    roots = {"os": sys.argv[1], "appos": sys.argv[2] if len(sys.argv) > 2 else None}
    log = []
    for line in open(os.path.join(icons, "apps-sources.txt")):
        if line.startswith("#") or not line.strip(): continue
        name, app, stem, vol = line.rstrip("\n").split("\t")
        if not roots[vol]:
            log.append(f"skip {name}: {vol} volume not given"); continue
        car = f"{roots[vol]}{app}/Contents/Resources/Assets.car"
        stack = IS.Stack(car) if os.path.exists(car) else None
        build(name, stack, stem, Image.open(f"{icons}/apps/{name}-512.png"), log)
    open(os.path.join(icons, "apps-styles.log"), "w").write("\n".join(log) + "\n")
    print(sum(l.startswith("stack") for l in log), "from stacks,", sum(l.startswith("legacy") for l in log), "legacy,",
          sum(l.startswith("skip") for l in log), "skipped")


if __name__ == "__main__":
    main()
