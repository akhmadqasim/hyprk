#!/usr/bin/env python3 -I
"""Build the Dark, Clear and Tinted app icons: themes/icons/apps/<Name>-256-<style>-<mode>.png.

macOS 27.2.1 stores no bitmap for these styles; IconRendering composes them at run time from the icon's layered
source. icr.py is that composition, ported from the framework (render graph, parameters and every address in
reference/ASSETS.md "IconRendering composition"); iconstack.py reads the layers from the app's Assets.car.

Per style (128 pt at 2x: size class large):
  dark-dark     colour mode on the DarkAqua stack: chiclet gradient, group shadows, translucency, glyph highlights
                through the vibrant colour matrix, chiclet highlights, and the outline of the mitigated version
                (what IconServices' stills are: the Settings tiles show it; at the Dock's 66 px it changes nothing).
  tinted-dark   the mitigated version: the ISAppearanceTintable stack baked grey, duotone to the tint, screened over
                the plate 0.1.
  clear-dark    the mitigated version: the lighten / darken / highlights masks over the plate 0.17.
  tinted-light  NOT the port: in the Mac's Dock these two are the masks acting on live glass, which a file cannot
  clear-light   hold, and the port over a fixed plate fits the Dock shot worse than the old rule (TintedLight
                9-15 -> 11-27, ClearLight 3-9 -> 9-14). So they stay as they were, FITTED to the Mac's Dock
                (glass53/...-clear-tinted.png): the flat tintable layers' luminance L mapped linearly from the tile
                to a white point, plus glass.py's fitted rim. tinted-light: tile 0,109,195, ramp -84,83,189 ..
                114,241,255. clear-light: plate 192, white 254, stored as white with alpha = (v - 176) / 79
                (176 = the Mac's dark Dock over white) so the Dock shows through. The shell's tile for Linux
                icons (ui/HyprK/AppIconTile.qml) uses the same colours.
The tint is the Mac's blue (0,122,255), the one its captures were made with.
Apps without a stack (ControlCenter) are legacy icons: the Mac leaves those as they are in Dark and maps their
luminance in Clear / Tinted (WebStorm, Spotify in the same shot); that linear ramp is FITTED too (LEGACY).
256 px only: the shell draws app icons at most 128 pt.

  build-styles.py <os-volume-root> [<appos-volume-root>]       Log: themes/icons/apps-styles.log
"""
import os, sys
import numpy as np
from PIL import Image

here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
import iconstack as IS
import icr

icons = os.path.dirname(here)
SIZE = 256
POINTS, PX_PER_POINT = 128, 2          # the 256 px file is the 128 pt icon at 2x
LUMA = np.array([0.2126, 0.7152, 0.0722])
TINT = np.array([0, 122, 255], np.float32) / 255
OUTLINE = True                          # dark-dark: the mitigated version's outline (see the module doc)
BODY = 824 / 1024                       # the 1024 Icon Composer canvas is the 824 px body of a 1024 icon
CLEAR_BACKDROP = 176                    # the Mac's dark Dock over white, under the ClearLight tile
# FITTED to the Mac's Dock (sRGB 0..255): plate, white point, rim strength and colour; legacy = icons without layers
RIM = dict(angle=-0.54, height=2.80, spread=-0.336, bias=33.19, curvature=0.695, fill=0.979)
DOCK_LIGHT = {
    "tinted-light": dict(plate=(0, 109, 195), black=(-84, 83, 189), white=(114, 241, 255), edge=2.75, edge_col="plate"),
    "clear-light":  dict(plate=(192, 192, 192), white=(254, 254, 254), edge=1.26, edge_col=(255, 255, 255)),
}
LEGACY = dict(DOCK_LIGHT, **{
    "tinted-dark":  dict(plate="dark-tint", white=(24, 131, 246)),
    "clear-dark":   dict(plate=(43, 43, 43), white=(236, 236, 236)),
})


def ramp(L, cover, sp, cov=None):
    """the fitted Dock rule: plate, art mapped linearly from the plate (or `black`) to the white point, fitted rim"""
    if sp["plate"] == "dark-tint":      # legacy icons only: grey 25 + the tint x (0.15 at the top -> 0 at the bottom)
        ys = np.nonzero(cover.max(1) > 0.5)[0]; n = cover.shape[0]
        t = 0.15 * (1 - np.clip((np.arange(n) + 0.5 - ys[0]) / (ys[-1] + 1 - ys[0]), 0, 1))
        p = np.broadcast_to((25 / 255 + np.array([0, 122, 249], np.float32) / 255 * t[:, None])[:, None, :], (n, n, 3))
    else: p = np.array(sp["plate"], np.float32) / 255
    g0 = np.array(sp["black"], np.float32) / 255 if "black" in sp else p
    g = np.clip(g0 + L[..., None] * (np.array(sp["white"], np.float32) / 255 - g0), 0, 1)
    rgb = p * (1 - cover[..., None]) + g * cover[..., None]
    if cov is None or "edge" not in sp: return np.clip(rgb, 0, 1)
    import glass
    d, nrm = glass.sdf(cov)
    e = glass.rim(d, nrm, dict(RIM, height=RIM["height"] * cov.shape[0] / 128)) * (cov > 0)
    col = p if sp["edge_col"] == "plate" else np.array(sp["edge_col"], np.float32) / 255
    return np.clip(rgb + sp["edge"] * e[..., None] * col, 0, 1)


def place(prem1024, size):
    """1024 canvas (premultiplied) -> size x size icon cell with the canvas as its body"""
    b = round(size * BODY); o = (size - b) // 2
    out = np.zeros((size, size, 4), np.float32)
    im = Image.fromarray((np.clip(prem1024, 0, 1) * 255).round().astype("uint8"), "RGBa").resize((b, b), Image.LANCZOS)
    out[o:o + b, o:o + b] = np.asarray(im).astype(np.float32) / 255
    return out


def shape(default, size=None):
    """Apple's Default bitmap at size: (alpha incl. drop shadow, body coverage)"""
    size = size or SIZE
    a = np.asarray(default.convert("RGBa").resize((size, size), Image.LANCZOS)).astype(np.float32)[..., 3] / 255
    shadow = np.percentile(a[a < 0.5], 99) if (a < 0.5).any() else 0     # the shadow halo's peak alpha
    return a, np.clip((a - shadow) / (1 - shadow), 0, 1)


def body(cov):
    """the chiclet's square inside the cell: (y0, y1), x the same"""
    ys = np.nonzero(cov.max(1) > 0.5)[0]
    return int(ys[0]), int(ys[-1]) + 1


def icon_for(stack, stem, which, cov):
    """icr.Icon of one appearance's stack, rendered at the body's pixel size"""
    y0, y1 = body(cov)
    fill, groups = IS.groups(stack.tree(stem, which), y1 - y0)
    return icr.Icon(cov[y0:y1, y0:y1], IS.fill_stops(fill), groups)


def clear_alpha(v):
    return np.clip((v - CLEAR_BACKDROP / 255) / (1 - CLEAR_BACKDROP / 255), 0, 1)


def render(stack, stem, default, size=None, points=POINTS, px_per_point=PX_PER_POINT):
    """{style-mode: (straight rgb, alpha)} for one icon; stack None (or without this stem) = legacy icon"""
    size = size or SIZE
    alpha, cov = shape(default, size)
    out = {}
    if stack is not None and stack.has_stack(stem):
        y0, y1 = body(cov)
        def cell(rgb):       # the body's picture in the cell, its edge colours repeated outwards (no dark fringe)
            return np.pad(rgb, ((y0, size - y1), (y0, size - y1), (0, 0)), mode="edge")
        dark = icon_for(stack, stem, "dark", cov)
        rgb = cell(icr.render(dark, "color", "dark", points, px_per_point, mitigated=OUTLINE))
        out["dark-dark"] = (rgb * (cov / np.maximum(alpha, 1e-6))[..., None], alpha)     # Apple's drop shadow stays black
        tin = icon_for(stack, stem, "tintable", cov)
        out["tinted-dark"] = (cell(icr.render(tin, "tinted", "dark", points, px_per_point, tint=TINT)), cov)
        out["clear-dark"] = (cell(icr.render(tin, "clear", "dark", points, px_per_point)), cov)
        flat = IS.Stack(stack.path)          # the fitted rule was made on clipped sRGB fills
        lay = place(IS.flat(flat.tree(stem, "tintable"), layers_only=True), size)
        cover = lay[..., 3]
        L = (lay[..., :3] / np.maximum(cover[..., None], 1e-6)) @ LUMA
        out["tinted-light"] = (ramp(L, cover, DOCK_LIGHT["tinted-light"], cov), cov)
        v = ramp(L, cover, DOCK_LIGHT["clear-light"], cov)[..., 0]
        out["clear-light"] = (np.ones(v.shape + (3,), np.float32), clear_alpha(v) * cov)
        return out
    # legacy icon: Dark leaves it as it is, Clear / Tinted map its luminance (fitted ramp)
    px = np.asarray(default.convert("RGBA").resize((size, size), Image.LANCZOS)).astype(np.float32) / 255
    out["dark-dark"] = (px[..., :3], px[..., 3])
    L = px[..., :3] @ LUMA
    for name, sp in LEGACY.items():
        rgb = ramp(L, np.where(px[..., 3] > 0, 1.0, 0.0).astype(np.float32) if sp["plate"] == "dark-tint" else np.ones_like(L),
                   dict(sp, edge=None) if False else {k: v for k, v in sp.items() if k not in ("edge", "edge_col")})
        if name == "clear-light": out[name] = (np.ones_like(rgb), clear_alpha(rgb[..., 0]) * px[..., 3])
        else: out[name] = (rgb, px[..., 3])
    return out


def save(rgb, alpha, path):
    """straight rgb + alpha -> 8-bit RGBA PNG, written to a temp name and renamed (running shells hot-reload)"""
    arr = np.dstack([np.clip(rgb, 0, 1), np.clip(alpha, 0, 1)])
    Image.fromarray((arr * 255).round().astype("uint8"), "RGBA").save(path + ".tmp", "PNG", optimize=True)
    os.replace(path + ".tmp", path)


def main():
    roots = {"os": sys.argv[1], "appos": sys.argv[2] if len(sys.argv) > 2 else None}
    only = set(sys.argv[3].split(",")) if len(sys.argv) > 3 else None
    log = []
    for line in open(os.path.join(icons, "apps-sources.txt")):
        if line.startswith("#") or not line.strip(): continue
        name, app, stem, vol = line.rstrip("\n").split("\t")
        if only and name not in only: continue
        if not roots[vol]:
            log.append(f"skip {name}: {vol} volume not given"); continue
        car = f"{roots[vol]}{app}/Contents/Resources/Assets.car"
        stack = IS.Stack(car, extended=True) if os.path.exists(car) else None
        for style, (rgb, a) in render(stack, stem, Image.open(f"{icons}/apps/{name}-512.png")).items():
            save(rgb, a, f"{icons}/apps/{name}-{SIZE}-{style}.png")
        log.append(f"{'stack' if stack is not None and stack.has_stack(stem) else 'legacy'} {name} <- {stem}")
        print(log[-1], flush=True)
    if not only: open(os.path.join(icons, "apps-styles.log"), "w").write("\n".join(log) + "\n")
    print(sum(l.startswith("stack") for l in log), "from stacks,", sum(l.startswith("legacy") for l in log), "legacy,",
          sum(l.startswith("skip") for l in log), "skipped")


if __name__ == "__main__":
    main()
