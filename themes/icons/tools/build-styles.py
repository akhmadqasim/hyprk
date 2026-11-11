#!/usr/bin/env python3 -I
"""Build the Dark, Clear and Tinted app icons: themes/icons/apps/<Name>-256-<style>-<mode>.png.

macOS 27.2.1 stores no bitmap for these styles; IconRendering composes them at run time from the icon's
layered source (iconstack.py). What is Apple's and what is fitted:
  * layers, fills, the DarkAqua stack: Apple's car data (iconstack.py, dmp2.py).
  * the specular edge of the chiclet: Apple's glassHighlight kernel (glass.py, from IconRendering's
    default.metallib), lit from above and below; its inputs are FITTED to the chiclet that is identical on all
    21 symbol panes of the Mac-rendered Settings tiles (themes/icons/settings, per style): RIM below.
  * the style rule, read off those tiles and the Mac's Dock: the tintable layers' luminance L is mapped LINEARLY
    from the plate colour (L = 0, black art disappears into the tile) to a white point (L = 1), with the layer
    coverage as alpha. Fitted on Siri + Spotlight (the two panes that are layered app icons) with free end points,
    the L = 0 end lands on the plate within 1-3 levels in all four styles (tinted light 0,128,255 vs plate
    0,122,249; tinted dark 26 vs 25; clear light 128 vs 125; clear dark 45 vs 43), so it is set to the plate.
  * the dark tinted plate: a grey 25 base plus the accent times a vertical contour gradient 0.15 at the top to 0
    at the bottom; 0.15 / 0 are IconRendering's ContourGradients darkTintStartBrightness / darkTintEndBrightness
    (ICRRenderingParameters.default, once-initialiser at 0x1cfd87b8c in the 27.2.1 dyld cache, struct offsets
    0x318 / 0x320), the base and accent are read off the tiles.
Per style:
  dark-dark     DarkAqua stack as it is (its own dark chiclet; systemDarkGradient in the parameters is
                31/255 -> 15/255, the tile plates measure 31 -> 15) + the white specular edge.
  tinted-light  tile and ramp fitted to the Mac's TintedLight DOCK (glass53/...-clear-tinted.png): tile 0,109,195,
                ramp -84,83,189 (L = 0) .. 114,241,255 (L = 1). The Dock draws tinted icons unlike IconServices'
                Settings tiles (chiclet 0,122,249 there) and does not take black art to the tile: with the tiles'
                rule (black = tile) Safari goes 11.9 -> 28.5 on the Dock, so the Dock's own fit stays. Edge in the
                tile colour.
  clear-light   the tiles' rule (black = plate) with the Mac's ClearLight Dock values (plate 192, white 254),
                stored as white with alpha so the Dock shows through like the Mac's glass tile:
                alpha = (v - 176) / 79, 176 = the Mac's dark Dock over white.
  tinted-dark   no Mac Dock shot exists: the Settings tiles' TintedDark (plate above, white 24,131,246).
  clear-dark    no Mac Dock shot exists: the Settings tiles' ClearDark (opaque plate 43, white 236; the tiles are
                IconServices' opaque "simulated glass" rendering, not see-through).
Apps without a stack (ControlCenter) are legacy icons: the Mac leaves those as they are in Dark and maps
their luminance in Clear / Tinted (WebStorm, Spotify in the same shot); the same is done here with a = 1 and
no glass edge. Not reproduced (not decoded): per-layer glass (translucency, blur, layer shadows, specular on the
glyph layers) and IconRendering's own highlight inputs. 256 px only: the shell draws app icons at most 128 pt.

  build-styles.py <os-volume-root> [<appos-volume-root>]       Log: themes/icons/apps-styles.log
"""
import os, sys
import numpy as np
from PIL import Image

here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
import iconstack as IS
import glass

icons = os.path.dirname(here)
SIZE = 256
BODY = 824 / 1024          # the 1024 Icon Composer canvas is the 824 px body of a 1024 icon
LUMA = np.array([0.2126, 0.7152, 0.0722])
# glassHighlight inputs fitted on the Settings tile plates at 128 px (height in px at 128, scales with the icon):
# plate rms 4.0-9.3 without the edge -> 1.4-3.0 with it, over the five styles
RIM = dict(angle=-0.54, height=2.80, spread=-0.336, bias=33.19, curvature=0.695, fill=0.979)
# per style (sRGB 0..255): plate, white point, edge strength and colour ("plate" = in the plate's colour)
STYLES = {
    "dark-dark":    dict(edge=1.18, edge_col=(255, 255, 255)),
    "tinted-light": dict(plate=(0, 109, 195), black=(-84, 83, 189), white=(114, 241, 255), edge=2.75, edge_col="plate"),
    "clear-light":  dict(plate=(192, 192, 192), white=(254, 254, 254), edge=1.26, edge_col=(255, 255, 255), backdrop=176),
    "tinted-dark":  dict(plate="dark-tint", white=(24, 131, 246), edge=2.62, edge_col=(0, 122, 249)),
    "clear-dark":   dict(plate=(43, 43, 43), white=(236, 236, 236), edge=1.01, edge_col=(255, 255, 255)),
}
DARK_TINT = dict(base=25, accent=(0, 122, 249), start=0.15, end=0.0)   # start / end: ContourGradients (code)
_edge_cache = {}


def down(prem, n):
    """premultiplied float NxN -> premultiplied float n x n (Lanczos)"""
    im = Image.fromarray((np.clip(prem, 0, 1) * 255).round().astype("uint8"), "RGBa").resize((n, n), Image.LANCZOS)
    return np.asarray(im).astype(np.float32) / 255


def place(prem1024, size=None):
    """1024 canvas (premultiplied) -> size x size icon cell with the canvas as its body"""
    size = size or SIZE
    b = round(size * BODY); o = (size - b) // 2
    out = np.zeros((size, size, 4), np.float32)
    out[o:o + b, o:o + b] = down(prem1024, b)
    return out


def shape(default, size=None):
    """Apple's Default bitmap at size: (alpha incl. drop shadow, body coverage)"""
    size = size or SIZE
    a = np.asarray(default.convert("RGBa").resize((size, size), Image.LANCZOS)).astype(np.float32)[..., 3] / 255
    shadow = np.percentile(a[a < 0.5], 99) if (a < 0.5).any() else 0     # the shadow halo's peak alpha
    return a, np.clip((a - shadow) / (1 - shadow), 0, 1)


def edge(cov):
    """the chiclet's specular edge intensity (glass.rim) for this body coverage; cached per shape"""
    key = (cov.shape, (np.round(cov * 8).astype(np.uint8)).tobytes())
    if key not in _edge_cache:
        d, nrm = glass.sdf(cov)
        _edge_cache[key] = glass.rim(d, nrm, dict(RIM, height=RIM["height"] * cov.shape[0] / 128)) * (cov > 0)
    return _edge_cache[key]


def plate(spec, cov):
    """the style's chiclet colour per pixel (straight sRGB 0..1)"""
    n = cov.shape[0]
    if spec["plate"] == "dark-tint":
        ys = np.nonzero(cov.max(1) > 0.5)[0]
        ty = np.clip((np.arange(n) + 0.5 - ys[0]) / (ys[-1] + 1 - ys[0]), 0, 1)
        t = DARK_TINT["start"] + (DARK_TINT["end"] - DARK_TINT["start"]) * ty
        p = DARK_TINT["base"] / 255 + np.array(DARK_TINT["accent"]) / 255 * t[:, None]
        return np.broadcast_to(p[:, None, :], (n, n, 3)).astype(np.float32)
    return np.broadcast_to(np.array(spec["plate"], np.float32) / 255, (n, n, 3))


def styled_tile(L, cover, spec, cov, glassy=True):
    """plate + art mapped linearly from the plate (L = 0) to the white point (L = 1) + the specular edge"""
    p = plate(spec, cov)
    g0 = np.array(spec["black"], np.float32) / 255 if "black" in spec else p
    g = np.clip(g0 + L[..., None] * (np.array(spec["white"], np.float32) / 255 - g0), 0, 1)
    rgb = p * (1 - cover[..., None]) + g * cover[..., None]
    if not glassy: return np.clip(rgb, 0, 1)
    col = p if spec["edge_col"] == "plate" else np.array(spec["edge_col"], np.float32) / 255
    return np.clip(rgb + spec["edge"] * edge(cov)[..., None] * col, 0, 1)


def save(rgb, alpha, path):
    """straight rgb + alpha -> 8-bit RGBA PNG"""
    arr = np.dstack([np.clip(rgb, 0, 1), np.clip(alpha, 0, 1)])
    Image.fromarray((arr * 255).round().astype("uint8"), "RGBA").save(path, optimize=True)


def render(stack, stem, default, size=None):
    """{style-mode: (straight rgb, alpha)} for one icon; stack None (or without this stem) = legacy icon"""
    size = size or SIZE
    alpha, cov = shape(default, size)
    out = {}
    layered = stack is not None and stack.has_stack(stem)
    if layered:
        d = place(IS.flat(stack.tree(stem, "dark")), size)
        rgb = d[..., :3] / np.maximum(d[..., 3:4], 1e-6) * (cov / np.maximum(alpha, 1e-6))[..., None]
        sp = STYLES["dark-dark"]
        out["dark-dark"] = (np.clip(rgb + sp["edge"] * edge(cov)[..., None] * np.array(sp["edge_col"]) / 255, 0, 1), alpha)
        lay = place(IS.flat(stack.tree(stem, "tintable"), layers_only=True), size)
        cover = lay[..., 3]
        L = (lay[..., :3] / np.maximum(cover[..., None], 1e-6)) @ LUMA
    else:   # legacy icon: Dark leaves it as it is, Clear / Tinted map its luminance
        px = np.asarray(default.convert("RGBA").resize((size, size), Image.LANCZOS)).astype(np.float32) / 255
        out["dark-dark"] = (px[..., :3], px[..., 3])
        cover, L, cov, alpha = np.ones((size, size), np.float32), px[..., :3] @ LUMA, px[..., 3], px[..., 3]
    for name in ("tinted-light", "tinted-dark", "clear-dark"):
        out[name] = (styled_tile(L, cover, STYLES[name], cov, layered), cov)
    sp = STYLES["clear-light"]
    v = styled_tile(L, cover, sp, cov, layered)[..., 0]
    a = np.clip((v - sp["backdrop"] / 255) / (1 - sp["backdrop"] / 255), 0, 1)
    out["clear-light"] = (np.ones(v.shape + (3,), np.float32), a * cov)
    return out


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
        for style, (rgb, a) in render(stack, stem, Image.open(f"{icons}/apps/{name}-512.png")).items():
            save(rgb, a, f"{icons}/apps/{name}-{SIZE}-{style}.png")
        log.append(f"{'stack' if stack is not None and stack.has_stack(stem) else 'legacy'} {name} <- {stem}")
    open(os.path.join(icons, "apps-styles.log"), "w").write("\n".join(log) + "\n")
    print(sum(l.startswith("stack") for l in log), "from stacks,", sum(l.startswith("legacy") for l in log), "legacy,",
          sum(l.startswith("skip") for l in log), "skipped")


if __name__ == "__main__":
    main()
