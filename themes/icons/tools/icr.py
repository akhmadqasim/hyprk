#!/usr/bin/env python3 -I
"""IconRendering's composition of an Icon Composer icon, offline (numpy): Dark, Tinted and Clear renditions.

Port of macOS 27.2.1 IconRendering.framework's `IconRenderer` (dyld cache addresses, all listed with what they
compute in reference/ASSETS.md "IconRendering composition"). Every tunable is Apple's: icr-params.json is
`ICRRenderingParameters.default` (emulated from its initialiser). What is ported:
  * chiclet contents: axial gradient over 10 % .. 90 % of the bounds height (0x1cfd72690 / 0x1cfd87710)
  * per group (one baked image + SDF, 0x1cfd6d430): shadow (bake 0x1cfd4589c, draw 0x1cfd740e8), translucency
    gradient (0x1cfd37554), contents (0x1cfd75194 / 0x1cfd75774), shadow overdraw (0x1cfd74eec), highlights and
    darklights on the SDF through the glassHighlight kernel and a vibrant colour matrix (0x1cfd73374 / 0x1cfd35f90)
  * chiclet highlights over the angle around the centre (0x1cfd715e0 / 0x1cfd34fb0), the mitigated outline
    (0x1cfd71b8c / 0x1cfd76bc0)
  * modes (0x1cfd71dfc, 0x1cfd70f98, 0x1cfd69ffc): colour; tinted dark = grey bake, saturation, duotone to the tint,
    screened over the mitigated plate; clear and tinted light = the three masks (lighten / darken / highlights)
    applied to a plate through the lightening / highlights vibrant colour matrices and plusDarker.
NOT Apple's, stated where used: the distance field is computed here (Apple's is RenderBox's distance style; its
source, the group's layers drawn solid, is Apple's), the side of the shadow ring is measured, the blur is a plain
Gaussian with sigma = RenderBox's radius (ASSUMED), grayscale is BT.709 luma (ASSUMED), IconBrightness from the
chiclet's luminance limits (the limits are Apple's, the function was not read), and the paths not ported (see
ASSETS.md: darklight compounding prevention, blurStrength / refraction glass, glow = nil in the defaults).
"""
import json, os
import numpy as np

here = os.path.dirname(os.path.abspath(__file__))
P = json.load(open(os.path.join(here, "icr-params.json")))
LUMA = np.array([0.2126, 0.7152, 0.0722], np.float32)
# BT.709 YCbCr matrices of the vibrant colour matrix (IconRendering __const 0x1cfdbda70 / 0x1cfdbdab0)
RGB2YCC = np.array([[0.2126, 0.7152, 0.0722], [-0.1146, -0.3854, 0.5], [0.5, -0.4542, -0.0458]], np.float32)
YCC2RGB = np.array([[1, 0, 1.5748], [1, -0.1873, -0.4681], [1, 1.8556, 0]], np.float32)


def size_class(points):
    t = P["thresholds"]
    return ("display" if points >= t["minDisplaySize"] else "large" if points >= t["minLargeSize"]
            else "medium" if points >= t["minMediumSize"] else "small")


# ---- geometry ------------------------------------------------------------------------------------------------

def _edt_band(mask, reach):
    """distance (px) from every True pixel to the nearest False pixel centre, exact up to `reach`, clamped beyond"""
    n, m = mask.shape
    big = np.float32(reach + 1)
    # pass 1: distance along rows to the nearest False pixel
    idx = np.arange(m, dtype=np.float32)[None, :]
    left = np.where(~mask, idx, -np.inf); left = np.maximum.accumulate(left, 1)
    right = np.where(~mask, idx, np.inf); right = np.minimum.accumulate(right[:, ::-1], 1)[:, ::-1]
    g = np.minimum(np.minimum(idx - left, right - idx), big).astype(np.float32)
    g2 = g * g
    out = np.full((n, m), big * big, np.float32)
    for dy in range(-reach, reach + 1):
        src = slice(max(0, dy), n + min(0, dy)); dst = slice(max(0, -dy), n + min(0, -dy))
        np.minimum(out[dst], g2[src] + dy * dy, out=out[dst])
    return np.sqrt(out)


def sdf(alpha, up=4, reach=10):
    """coverage (HxW, 0..1) -> signed distance in px (positive inside) and the unit outward normal (x right, y
    down). The contour is the 0.5 level of the coverage, upsampled `up` times; exact within `reach` px."""
    from PIL import Image
    n, m = alpha.shape
    big = np.asarray(Image.fromarray((np.clip(alpha, 0, 1) * 255).round().astype("uint8"))
                     .resize((m * up, n * up), Image.BILINEAR)) >= 128
    r = reach * up
    din = _edt_band(big, r); dout = _edt_band(~big, r)
    d = np.where(big, din - 0.5, -(dout - 0.5)) / up
    d = d.reshape(n, up, m, up).mean((1, 3))
    gy, gx = np.gradient(d)
    k = np.maximum(np.hypot(gx, gy), 1e-6)
    return d.astype(np.float32), np.stack([-gx / k, -gy / k], -1).astype(np.float32)


def gauss(img, sigma):
    """Gaussian blur of HxW or HxWxC (zero outside)"""
    if sigma <= 0.05: return img
    r = int(np.ceil(3 * sigma)); x = np.arange(-r, r + 1, dtype=np.float32)
    k = np.exp(-x * x / (2 * sigma * sigma)); k /= k.sum()
    a = np.moveaxis(img, -1, 0) if img.ndim == 3 else img[None]
    pad = np.pad(a, ((0, 0), (r, r), (r, r)))
    tmp = sum(k[i] * pad[:, :, i:i + a.shape[2]] for i in range(2 * r + 1))
    out = sum(k[i] * tmp[:, i:i + a.shape[1], :] for i in range(2 * r + 1))
    return np.moveaxis(out, 0, -1) if img.ndim == 3 else out[0]


def shift(img, dy):
    """translate by dy px down (bilinear, zero fill)"""
    f = int(np.floor(dy)); t = dy - f
    def s(k):
        out = np.zeros_like(img)
        if k >= 0: out[k:] = img[:img.shape[0] - k] if k else img
        else: out[:k] = img[-k:]
        return out
    return s(f) * (1 - t) + s(f + 1) * t


# ---- highlights ----------------------------------------------------------------------------------------------

def lights(setname, sc, pixel_unit, glyph, intensity=1.0):
    """a HighlightsSet -> its resolved lights (0x1cfd59270 + 0x1cfd7603c); distances in canvas units"""
    H = P["highlights"]; s = H[setname]
    hc = H["glyphHighlightCurvature" if glyph else "chicletHighlightCurvature"][sc]
    dc = H["glyphDarklightCurvature" if glyph else "chicletDarklightCurvature"][sc]
    fill = lambda v, key: s[key] if v == "matchKey" else v
    items = [(s["keySharp"], 0.0, hc, False), (s["keyDiffuse"], 0.0, 1.0, False),
             (fill(s["fillSharp"], "keySharp"), np.pi, hc, False), (fill(s["fillDiffuse"], "keyDiffuse"), np.pi, 1.0, False),
             (s["dark"], np.pi / 2, dc, True), (s["dark"], -np.pi / 2, dc, True), (s["rim"], 0.0, hc, False)]
    out = []
    for h, ang, curv, dark in items:
        if not isinstance(h, dict): continue
        op = intensity * h["opacity"][sc]
        if op <= 0: continue
        height = max(h["minDistancePixels"][sc] * pixel_unit, h["distance"][sc])
        inset = h["inset"][sc] if h["minInsetPixels"] is None else max(h["minInsetPixels"][sc] * pixel_unit, h["inset"][sc])
        blend = h["blendModeOverride"] or ("plusLighter" if h["brightness"] >= 0.5 else "plusDarker")
        out.append(dict(opacity=op, angle=ang, spread=h["spread"][sc], bias=h["bias"], height=height, inset=inset,
                        curvature=curv, brightness=h["brightness"], blend=blend, dark=dark,
                        outset=(h["outsetOpacity"] or {}).get(sc)))
    return out


def passes(ls):
    """lights with equal constraints share one pass (0x1cfd765d4)"""
    out = []
    keys = ("height", "curvature", "blend", "dark", "bias", "brightness", "opacity", "outset", "inset")
    for l in ls:
        key = tuple(l[k] for k in keys)
        for p in out:
            if p["key"] == key: p["lights"].append(l); break
        else: out.append(dict({k: l[k] for k in keys}, key=key, lights=[l]))
    return out


def schlick(t, b):
    """the gradient map of a highlight pass / the kernel's bias: t / ((1/b - 2)(1 - t) + 1)"""
    return t / np.maximum((1 / b - 2) * (1 - t) + 1, 1e-6)


def lobe(cosang, spread):
    if abs(spread / (2 * np.pi) - 0.5) < 1e-6: return np.ones_like(cosang)
    c = np.cos(spread)
    return np.clip((cosang - c) / max(1 - c, 1e-6), 0, 1)


def band(d, height, inset):
    """the kernel's edge falloff parameter and band coverage for a distance field d (px)"""
    dd = d - inset
    gy, gx = np.gradient(dd)
    w = np.clip(np.abs(gx) + np.abs(gy), 2.0 ** -10, 2) * 0.833
    cov = np.clip((height - dd) / w + 0.5, 0, 1) * np.clip(dd / w + 0.5, 0, 1)
    return np.clip(dd / max(height, 1e-6), 0, 1), cov


def chiclet_pass(p, d, phi, unit):
    """alpha of one highlight pass on the chiclet (0x1cfd34fb0): lights unioned over the angle phi around the centre"""
    a = np.zeros_like(d)
    for l in p["lights"]:
        v = lobe(np.cos(phi - (l["angle"] - np.pi / 2)), l["spread"]); a = v + (1 - v) * a
    t, cov = band(d, p["height"] * unit, p["inset"] * unit)
    return schlick(np.clip(a * (1 - p["curvature"] * t), 0, 1), p["bias"]) * cov


def glyph_light(l, d, nrm, unit, outside):
    """the glassHighlight kernel for one light on a group's SDF (0x1cfd35f90) -> mask 0..1 (before opacity)"""
    h = l["height"] * unit; inset = l["inset"] * unit
    if outside: inset = inset - h
    t, cov = band(d, h, inset)
    k = np.clip((h - 1) * 0.5, 0, 1); f = k * k * (3 - 2 * k) * l["curvature"]
    L = (np.sin(l["angle"]), -np.cos(l["angle"]))            # image coordinates, y down: angle 0 = from the top
    v = lobe(nrm[..., 0] * L[0] + nrm[..., 1] * L[1], l["spread"]) * (1 - f * t)
    return schlick(np.clip(v, 0, 1), l["bias"]) * cov


def vcm(rgb, v, clamp=None):
    """the vibrant colour matrix: Y' = black + (white - black) Y, chroma x saturation (BT.709 YCbCr)"""
    ycc = rgb @ RGB2YCC.T
    ycc[..., 0] = v["black"] + (v["white"] - v["black"]) * ycc[..., 0]
    ycc[..., 1:] *= v["saturation"]
    out = ycc @ YCC2RGB.T
    return np.clip(out, 0, clamp) if clamp else out


# ---- blending (premultiplied source over an opaque backdrop rgb) ----------------------------------------------

def blend(dst, src, a, mode):
    """dst HxWx3 opaque, src HxWx3 premultiplied by a (HxW)"""
    a3 = a[..., None]
    if mode == "normal": return src + dst * (1 - a3)
    if mode == "multiply": return dst * (1 - a3) + dst * src
    if mode == "screen": return dst + src - dst * src
    if mode == "plusLighter": return np.minimum(dst + src, 1)        # shouldClampPlusLBlending
    if mode == "plusDarker": return np.maximum(dst + src - a3, 0)
    un = src / np.maximum(a3, 1e-6)
    if mode == "darken": r = np.minimum(dst, un)
    elif mode == "lighten": r = np.maximum(dst, un)
    elif mode == "overlay": r = np.where(dst <= 0.5, 2 * dst * un, 1 - 2 * (1 - dst) * (1 - un))
    elif mode == "hardLight": r = np.where(un <= 0.5, 2 * dst * un, 1 - 2 * (1 - dst) * (1 - un))
    elif mode == "softLight": r = (1 - 2 * un) * dst * dst + 2 * un * dst
    elif mode == "colorDodge": r = np.minimum(1, dst / np.maximum(1 - un, 1e-6))
    elif mode == "colorBurn": r = 1 - np.minimum(1, (1 - dst) / np.maximum(un, 1e-6))
    elif mode == "difference": r = np.abs(dst - un)
    elif mode == "exclusion": r = dst + un - 2 * dst * un
    else: r = un                                                     # hue / saturation / color / luminosity: not ported
    return dst * (1 - a3) + r * a3


# ---- the renderer --------------------------------------------------------------------------------------------

def gradient(stops, n, y0, h):
    """chiclet gradient: stops [(location, rgb)] along 10 % .. 90 % of the bounds height -> n x 3"""
    t = np.clip(((np.arange(n) + 0.5 - y0) / h - 0.1) / 0.8, 0, 1)
    locs = [s[0] for s in stops]; cols = np.array([s[1] for s in stops], np.float32)
    return np.stack([np.interp(t, locs, cols[:, c]) for c in range(3)], -1).astype(np.float32)


def brightness(stops):
    """IconBrightness of a chiclet fill (limits are ICRRenderingParameters'; the rule itself is assumed)"""
    lum = [float(np.dot(c, LUMA)) for _, c in stops]
    H = P["highlights"]
    if max(lum) <= H["maxDimChicletLuminance"]: return "dim"
    if min(lum) >= H["minBrightChicletLuminance"]: return "bright"
    return "normal"


class Icon:
    """the render input: chiclet coverage (canvas x canvas px), chiclet gradient stops or None, and the groups:
    dict(img = premultiplied RGBA float, opacity, blend, specular, translucency, shadowStyle, shadowOpacity,
    specularPlacement)"""
    def __init__(self, cov, stops, groups):
        if isinstance(stops, str):                                   # Icon.Fill.system
            stops = [(x["location"], x["color"][:3]) for x in
                     P["fills"]["systemDarkGradient" if stops == "system-dark" else "systemLightGradient"]]
        self.cov = cov.astype(np.float32); self.n = cov.shape[0]; self.stops = stops; self.groups = groups
        ys = np.nonzero(cov.max(1) > 0.5)[0]; xs = np.nonzero(cov.max(0) > 0.5)[0]
        self.y0, self.h = float(ys[0]), float(ys[-1] + 1 - ys[0])
        self.centre = ((xs[0] + xs[-1] + 1) / 2, (ys[0] + ys[-1] + 1) / 2)
        self.unit = self.h / 1024.0                                  # px per canvas unit
        self.d, _ = sdf(self.cov)
        yy, xx = np.mgrid[0:self.n, 0:self.n] + 0.5
        self.phi = np.arctan2(yy - self.centre[1], xx - self.centre[0]).astype(np.float32)
        for g in groups:
            a = g["img"][..., 3]
            # the SDF's source is the group's layers drawn solid (0x1cfd45064), not the baked picture's alpha
            a = g["shape"] if g.get("shape") is not None else a / max(float(a.max()), 1e-6)
            g["d"], g["nrm"] = sdf(a)
            ys = np.nonzero(a.max(1) > 1 / 255)[0]
            g["frame"] = (float(ys[0]), float(ys[-1] + 1)) if len(ys) else (0.0, float(self.n))


SHADOW_RING = "inside"       # side of the edge the bake's ring lies on; MEASURED (Cmd-Tab shot: inside 9.4, outside 9.6), sign of the SDF not read


def _shadow(g, icon, sc, kind):
    """the baked shadow image of a group (0x1cfd4589c), premultiplied RGBA; kind 'vibrant' | 'neutral'.
    The display list: scale, colour multiply (vibrantBrightness) or alpha multiply (black), translate by the offset,
    blur filter, then a clip layer = the group's SDF filled by 0x1cfd39594 with inset -ringWidth, then the group.
    0x1cfd39594 is an alpha threshold between the edge (SDF value 0.5) and the inset contour: a RING ringWidth wide
    along the edge, not the grown shape. The filters work on the whole list, so the ring cut of the group is
    blurred; the translate moves the ring with the picture."""
    S = P["shadow"]; u = icon.unit
    img = g["img"]
    if kind == "vibrant": src = np.concatenate([img[..., :3] * S["vibrantBrightness"], img[..., 3:]], -1)
    else: src = np.concatenate([np.zeros_like(img[..., :3]), img[..., 3:]], -1)
    if S["ringWidth"] is not None:
        w = S["ringWidth"][sc] * u
        d = -g["d"] if SHADOW_RING == "outside" else g["d"]
        src = src * (np.clip(d + 0.5, 0, 1) * np.clip(w - d + 0.5, 0, 1))[..., None]
    src = shift(src, S["offsetY"] * u)
    return gauss(src, P["blurStrengthMax"] * min(max(S["radius"][sc], 0), 1) * u)


def _translucency(g, icon, sc):
    T = P["glyphTranslucency"]; t = T["strength"][sc] * g["translucency"]
    if t <= 0: return 1.0
    y0, y1 = g["frame"]
    v = np.clip((np.arange(icon.n) + 0.5 - y0) / max(y1 - y0, 1e-6), 0, 1)
    v = np.round(v * 16) / 16 * 0 + v                                # 17 linear stops of m^2 (3 - 2m): piecewise linear
    k = np.arange(17) / 16.0
    m = T["upperOpacity"] + ((1 - (1 - T["lowerOpacity"]) * t) - T["upperOpacity"]) * k
    return np.interp(v, k, m * m * (3 - 2 * m)).astype(np.float32)[:, None]


def _shadow_kind(style, colour_mode):
    """0x1cfd740e8 / 0x1cfd40bc8: ShadowStyle automatic 0, none 1, vibrant 2, neutral 3"""
    if style == 1: return None
    if colour_mode: return "neutral" if style == 3 else "vibrant"
    return "neutral"


def _inside(g, colour_mode, bright):
    """darklights inside the group? (0x1cfd73424): SpecularPlacement automatic 0, inside 1, outside 2"""
    p = g.get("specularPlacement", 0)
    return p == 1 or (p == 0 and colour_mode and bright == "bright")


def render_colour(icon, sc, pixel_unit, mode="color", px_per_point=2.0, mitigated=False, steps=None):
    """colour mode (or the grey picture of tinted dark when mode == 'tinted'): opaque rgb over the chiclet"""
    n = icon.n; S = P["shadow"]
    colour = mode == "color"
    stops = icon.stops if colour else [(0.0, [P["contourGradients"]["darkTintStartBrightness"]] * 3),
                                       (1.0, [P["contourGradients"]["darkTintEndBrightness"]] * 3)]
    bright = brightness(stops) if colour else "normal"
    rgb = np.repeat(gradient(stops, n, icon.y0, icon.h)[:, None, :], n, 1)
    gset = {"normal": "glyphsDefault", "bright": "glyphsBright", "dim": "glyphsDim"}[bright] if colour else "glyphsScreened"
    cset = {"normal": "chicletDefault", "bright": "chicletBright", "dim": "chicletDim"}[bright] if colour else "chicletScreened"
    H = P["highlights"]
    for g in icon.groups:
        if g["opacity"] <= 0: continue
        img = g["img"]
        if not colour:                                              # grey bake (addGrayscaleFilterWithAmount: 1)
            img = np.concatenate([np.repeat((img[..., :3] @ LUMA)[..., None], 3, -1), img[..., 3:]], -1)
        kind = _shadow_kind(g.get("shadowStyle", 0), colour)
        sh = None
        if kind and g.get("shadowOpacity", 0) > 0:
            sh = _shadow(dict(g, img=img), icon, sc, kind)
            k = g["opacity"] * g["shadowOpacity"] * (S["vibrantOpacity"] if kind == "vibrant" else S["neutralOpacity"])[sc]
            bm = S["blendModeForVibrantOnDim"] if (kind == "vibrant" and bright == "dim") else S["blendMode"]
            rgb = blend(rgb, sh[..., :3] * k, sh[..., 3] * k, bm)
        tr = _translucency(g, icon, sc)
        c = img * np.asarray(tr)[..., None] * g["opacity"]             # (n, 1, 1): the gradient runs down the rows
        rgb = blend(rgb, c[..., :3], c[..., 3], g.get("blend", "normal"))
        if sh is not None and S["drawOverContent"] and g.get("blend", "normal") == "normal" and g["translucency"] > 0:
            amt = min(max(g["translucency"] / S["translucencyForMaxOverdraw"], 0), 1) * \
                (S["maxNeutralOverdrawOpacity"] if g.get("shadowStyle", 0) == 3 else S["maxVibrantOverdrawOpacity"])[sc]
            k = g["opacity"] * g["shadowOpacity"] * (S["vibrantOpacity"] if kind == "vibrant" else S["neutralOpacity"])[sc]
            # still inside the translucency clip (clipLayerWithAlpha: of 0x1cfd74eec stays set for the overdraw)
            clip = img[..., 3] * np.asarray(tr) * g["opacity"] * amt
            rgb = blend(rgb, sh[..., :3] * (k * clip)[..., None], sh[..., 3] * k * clip, S["overdrawBlendMode"])
        if g.get("specular"):
            inside = _inside(g, colour, bright)
            for p in passes(lights(gset, sc, pixel_unit, True)):
                for l in p["lights"]:
                    out = l["dark"] and l["outset"] is not None and not inside
                    m = glyph_light(l, g["d"], g["nrm"], icon.unit, out) * (l["outset"] if out else l["opacity"]) * g["opacity"]
                    v = H["glyphDarklightVCM" if l["dark"] else "glyphHighlightVCM"]
                    rgb = rgb + np.clip(m, 0, 1)[..., None] * (np.clip(vcm(rgb, v), 0, 1) - rgb)
    for p in passes(lights(cset, sc, pixel_unit, False)):
        a = chiclet_pass(p, icon.d, icon.phi, icon.unit) * p["opacity"]
        rgb = blend(rgb, p["brightness"] * a[..., None] * np.ones(3, np.float32), a, p["blend"])
    if mitigated and colour and P["outlines"]["useDynamicOpacity"]:
        rgb = outline(rgb, icon.d, sc, px_per_point, bright == "bright")
    return np.clip(rgb, 0, 1)


def outline(rgb, d, sc, px_per_point, bright):
    """the mitigated colour-mode outline (0x1cfd76bc0): a gradient map of the backdrop's luminance inside the stroke"""
    o = P["outlines"]; w = o["lineWidth"][sc] * px_per_point
    cov = np.clip(d + 0.5, 0, 1) * np.clip(w - d + 0.5, 0, 1)
    L = np.clip(rgb @ LUMA, 0, 1)
    rd = o["luminanceRangeOnDim"]; rb = max(1 - o["luminanceRangeOnBright"], rd)
    aw = (o["lineOpacityOnDim"][sc] * np.clip(1 - L / rd, 0, 1) * cov)[..., None]
    ab = ((o["lineOpacityOnBright"][sc] if bright else 0.0) * np.clip((L - rb) / max(1 - rb, 1e-6), 0, 1) * cov)[..., None]
    return (rgb * (1 - aw) + aw) * (1 - ab)


def duotone(grey_rgb, tint, saturation=0.0):
    """tinted dark (0x1cfd71dfc + 0x1cfdab484): saturation filter, then C' = black + (tint - black) C"""
    L = (grey_rgb @ LUMA)[..., None]
    c = L + (grey_rgb - L) * saturation
    return c * np.asarray(tint, np.float32)


def render_masks(icon, sc, pixel_unit):
    """clear mode: the lighten / darken / highlights masks (HxWx3, 0..1) of 0x1cfd71dfc's colour matrix"""
    n = icon.n; S = P["shadow"]; C = P["clearMode"]
    M = np.zeros((n, n, 3), np.float32); M[..., 1] = 1.0               # the chiclet is pure green
    for g in icon.groups:
        if g["opacity"] <= 0: continue
        grey = g["img"][..., :3] @ LUMA; a = g["img"][..., 3]
        sh = None
        if _shadow_kind(g.get("shadowStyle", 0), False) and g.get("shadowOpacity", 0) > 0:
            sh = _shadow(dict(g, img=np.dstack([grey] * 3 + [a])), icon, sc, "neutral")
            k = g["opacity"] * g["shadowOpacity"] * S["neutralOpacity"][sc]
            M = M * (1 - sh[..., 3:] * k)                              # multiply with black
        tr = _translucency(g, icon, sc)
        ca = a * tr * g["opacity"]; cg = grey * tr * g["opacity"]
        src = np.stack([C["contentLighteningStrength"] * cg,
                        C["contentDarkeningStrength"] * cg + (1 - C["contentDarkeningStrength"]) * ca, np.zeros_like(ca)], -1)
        M = blend(M, src, ca, g.get("blend", "normal"))
        if sh is not None and S["drawOverContent"] and g.get("blend", "normal") == "normal" and g["translucency"] > 0:
            amt = min(max(g["translucency"] / S["translucencyForMaxOverdraw"], 0), 1) * \
                (S["maxNeutralOverdrawOpacity"] if g.get("shadowStyle", 0) == 3 else S["maxVibrantOverdrawOpacity"])[sc]
            M = M * (1 - sh[..., 3:] * (k * a * np.asarray(tr) * g["opacity"] * amt)[..., None])
        if g.get("specular"):
            inside = _inside(g, False, "normal"); H = P["highlights"]
            for p in passes(lights("glyphsClear", sc, pixel_unit, True)):
                for l in p["lights"]:
                    out = l["dark"] and l["outset"] is not None and not inside
                    m = np.clip(glyph_light(l, g["d"], g["nrm"], icon.unit, out) * (l["outset"] if out else l["opacity"])
                                * g["opacity"] * H["glyphDarklightNonVCMScale" if l["dark"] else "glyphHighlightNonVCMScale"], 0, 1)
                    if l["dark"]: M[..., 1] *= 1 - m                   # multiply with (1, 0, 1)
                    else: M[..., 0] = M[..., 0] + m - M[..., 0] * m    # screen with (1, 0, 0)
    for p in passes(lights("chicletClear", sc, pixel_unit, False)):
        if p["dark"]: continue                                        # leaveChicletDarklightsToSystem
        M[..., 2] = np.minimum(M[..., 2] + chiclet_pass(p, icon.d, icon.phi, icon.unit) * p["opacity"], 1)
    M = np.clip(M, 0, 1)
    return np.stack([C["totalLighteningStrength"] * M[..., 0], C["totalDarkeningStrength"] * (1 - M[..., 1]),
                     C["totalHighlightsStrength"] * M[..., 2]], -1)


def apply_masks(plate, masks, tone=None):
    """the three layer passes of 0x1cfd69ffc over a plate (HxWx3 or rgb): lighten, darken, highlights"""
    C = P["clearMode"]
    x = np.broadcast_to(np.asarray(plate, np.float32), masks.shape).copy()
    def lighten(x):
        if C["lighteningUsesVCM"]:
            return x + masks[..., :1] * (vcm(x, C["lighteningVCM"], C["lighteningVCM"]["headroom"] or 1.0) - x)
        return np.minimum(x + masks[..., :1], 1)
    def darken(x): return np.maximum(x - masks[..., 1:2], 0)
    x = darken(lighten(x)) if C["passOrder"] == 0 else lighten(darken(x))
    x = x + masks[..., 2:3] * (vcm(x, C["highlightsVCM"], C["highlightsVCM"]["headroom"] or 1.0) - x)
    return sdr(x, SDR_TONE if tone is None else tone)


# FITTED, not decoded: the vibrant colour matrices push the clear-mode picture up to their headroom (1.2) and
# RenderBox brings that back into an SDR image. Its curve was not read; in the Mac's Settings tiles eight flat
# regions (clear light / dark plate, white symbol, Spotlight's magnifier and lens) all sit on L' = L / (1 + c L) in
# linear light with c = 0.27 (rms 0.8 / 255; without it 13.2).
SDR_TONE = 0.27


def _lin(c): return np.where(c <= 0.04045, c / 12.92, ((np.maximum(c, 0) + 0.055) / 1.055) ** 2.4)
def _enc(l): return np.where(l <= 0.0031308, l * 12.92, 1.055 * np.maximum(l, 0) ** (1 / 2.4) - 0.055)


def sdr(x, tone=SDR_TONE, per_channel=False):
    l = _lin(np.clip(x, 0, None))
    y = l if per_channel else (l @ LUMA)[..., None]
    return np.clip(_enc(l / (1 + tone * y)), 0, 1).astype(np.float32)


def mitigated_plate(mode, appearance, tint=None, saturation=1.0):
    """the plate colour of the mitigated version (0x1cfd87564)"""
    if mode == "clear": return np.array(P["mitigatedChicletDarkClear" if appearance == "dark" else "mitigatedChicletLightClear"][:3], np.float32)
    base = np.array(P["mitigatedChicletDarkTint" if appearance == "dark" else "mitigatedChicletLightTint"][:3], np.float32)
    f = P["mitigatedChicletDarkTintFactor" if appearance == "dark" else "mitigatedChicletLightTintFactor"] * saturation
    return base * (1 - f) + np.asarray(tint, np.float32) * f


def render(icon, mode, appearance, points, px_per_point, tint=None, saturation=1.0, plate=None, mitigated=True,
           supersample=1):
    """straight rgb (HxWx3) of the rendition inside the chiclet. mode 'color' | 'tinted' | 'clear', appearance
    'light' | 'dark'. plate overrides the mitigated plate colour (the live glass the Dock puts under the icon).
    supersample k: the icon is given at k times the device resolution (px_per_point is the device's); the pixel
    based parameters (minDistancePixels, the outline width) stay device pixels, the caller scales the result down."""
    sc = size_class(points); pixel_unit = supersample / icon.unit; px_per_point = px_per_point * supersample
    if mode == "color":
        return render_colour(icon, sc, pixel_unit, "color", px_per_point, mitigated)
    if mode == "tinted" and appearance == "dark":
        pic = duotone(render_colour(icon, sc, pixel_unit, "tinted", px_per_point), tint, 0.0)
        p = mitigated_plate(mode, appearance, tint, saturation) if plate is None else np.asarray(plate, np.float32)
        return np.clip(p + pic - p * pic, 0, 1)                       # RBBlendMode screen
    p = mitigated_plate(mode, appearance, tint, saturation) if plate is None else np.asarray(plate, np.float32)
    return apply_masks(np.clip(p, 0, 1), render_masks(icon, sc, pixel_unit))
