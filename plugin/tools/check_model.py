#!/usr/bin/env python3
# Offline check of the plugin's glass against Apple's verified model (macOS 27.2.1), so changes to Material.cpp or
# shaders/liquidglass.frag are measured against Apple instead of judged by eye.
#
#   1. apple_glass.inputs() against every glassBackground filter dump the Mac took (live/verify/C, C2): must be exact.
#   2. The plugin's resolved inputs (lgdump, the C++ resolveMaterial) against apple_glass.inputs() for every material
#      x light/dark x D in {20, 24, 32, 64, 96, 200, 500} x slider a in {0, 0.25, 0.5, 0.75, 1}.
#   3. Face colour: a line-by-line port of the shader's interior (face_ours below, keep it in step with
#      shaders/liquidglass.frag) over the Mac's 17 flat backdrops, against the Mac's measured centre pixels
#      (ramp-shader-model.json) and against glass_model.py (the Mac's model) on the whole grid.
#   4. Rim rows against the Mac's.
#   5. Refraction and blur over 4 pt stripes: a port of the shader's sampling (row_ours below: lens displacement, blur
#      opacity at d + displacement, Apple's lod, the underlay composition; keep it in step with shaders/liquidglass.frag)
#      on Apple's blur pyramid (C3 glass_model.Pyramid1D, the kernel the plugin builds) against the real Control Center
#      tile on the Mac (C2 cc-real-stripes, centre row through the rounded end: interior ripple and lens bands) and
#      against Apple's shader on the Mac's own panel-blurred backdrop; then the port against Apple's model for every
#      material (same backdrop, no underlay).
#   6. The Liquid Glass slider on the real Dock over 4 pt stripes at a = 0, 0.5, 1 (live/verify/C/dock-real.json).
#
#   7. The corner curve: the plugin's sdRoundedBox (lgdump --sdf) against a port of QuartzCore's supercircle_sdf, that
#      port against the top edge of the real Control Center slider tile on the Mac (C2 cc-real-stripes), and the rim rows
#      across that corner (the highlight's lobes on the curve's normal) against the Mac's rows.
#
# Usage: check_model.py --dump <lgdump binary or its JSON output> [--strict] [--port module.py]
#   --strict: exit 1 when step 1 is not exact, a ported input differs, or the face is off by more than the limits below.
import argparse, importlib.util, json, math, os, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
VERIFY = os.path.join(ROOT, "reference", "re", "27.2.1", "live", "verify")
sys.path.insert(0, HERE)
import apple_glass as A  # noqa: E402

import numpy as np  # noqa: E402


def load_module(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


GM = load_module(os.path.join(VERIFY, "C2", "glass_model.py"), "glass_model")
GM3 = load_module(os.path.join(VERIFY, "C3", "glass_model.py"), "glass_model_c3")  # + the blur pyramid
GRID_D = [20, 24, 32, 64, 96, 200, 500]
GRID_A = [0, 0.25, 0.5, 0.75, 1]
# inputs the plugin ports
PORTED = ["InnerRefractionAmount", "InnerRefractionHeight", "OuterRefractionAmount", "OuterRefractionHeight", "RefractionOpacity",
          "BlurFillLightenOpacity", "BlurFillDarkenOpacity", "BlurFillNormalOpacity", "BackdropScale",
          "FaceColorMatrixBlack", "FaceColorMatrixWhite", "FaceColorMatrixSaturation", "Fill", "MaxLuma",
          "BleedOpacity", "BleedAmount", "BleedHeight", "BleedColorMatrixBlack", "BleedColorMatrixWhite", "BleedColorMatrixSaturation",
          "BleedDarkenBlend", "KeyFillHighlightColorBias", "KeyFillHighlightSpreadDeg", "ShadowOpacity", "ShadowRadius", "ShadowOffset",
          "RingShadowOpacity", "BlurRadius", "BlurOpacity0", "BlurOpacity1", "BlurOpacity2", "BlurDistance0"]
# measured on the real surfaces, so the plugin follows them instead of the AppKit probe (reasons in Material.cpp)
DEVIATIONS = {("notificationcenter", "ShadowOpacity"): "fitted to the PC #62 gaps between cards (181 dark / 189 light over white)"}
W709 = np.array([.2126, .7152, .0722])
WB = np.array([.2125, .7154, .0721])


def vec(v, key=""):
    if key == "Fill":  # premultiplied: the colour of a 0-alpha fill does not matter
        return np.array([v[0] * v[3], v[1] * v[3], v[2] * v[3], v[3]], float)
    return np.array(v if isinstance(v, list) else [v], float)


# ---- 1. apple_glass.inputs() against the dumps
def check_reference():
    rows = []  # (label, key, apple dump, reference)
    var = json.load(open(os.path.join(VERIFY, "C", "tint-params-by-variant.json")))["data"]
    size = json.load(open(os.path.join(VERIFY, "C", "tint-params-by-size.json")))["data"]
    ramp = json.load(open(os.path.join(VERIFY, "C2", "ramp-shader-model.json")))["data"]
    inv = {v: k for k, v in A.APPLE_NAME.items()}
    samples = []
    for mode, by_a in var.items():
        for a, items in by_a.items():
            for x in items:
                if x["name"] in inv:
                    samples.append((inv[x["name"]], min(x["sizePt"]), float(a), mode == "dark", x["glass"]))
    for name, by_a in size.items():
        for a, items in by_a.items():
            for x in items:
                samples.append((inv[x["name"]], min(x["sizePt"]), float(a), True, x["glass"]))
    ramp_d = {"regular": 64, "regular96": 96, "regular200": 200, "regular500": 500, "menu200": 200, "notificationCenter": 64,
              "clear": 64, "dock": 64, "controlCenter": 64}
    ramp_m = {"regular": "regular", "regular96": "regular", "regular200": "regular", "regular500": "regular", "menu200": "menu",
              "notificationCenter": "notificationcenter", "clear": "clear", "dock": "dock", "controlCenter": "controlcenter"}
    for k, v in ramp.items():
        mode, name, a = k.split()
        if name in ramp_m:
            samples.append((ramp_m[name], ramp_d[name], float(a[2:]), mode == "dark", v["inputs"]))
    worst = {}
    for mk, v in ramp.items():
        mode, name, a = mk.split()
        if name in ramp_m:
            ref = A.inputs(ramp_m[name], ramp_d[name], float(a[2:]), mode == "dark")
            e = abs(A.backdrop_scale(ramp_m[name], ref) - v["backdropScale"])
            if e > worst.get("BackdropScale", (0,))[0]:
                worst["BackdropScale"] = (e, ramp_m[name], ramp_d[name], a, mode == "dark")
    for mat, D, a, dark, dump in samples:
        ref, got = A.inputs(mat, D, a, dark), A.from_dump(dump)
        for key, rv in ref.items():
            if key not in got or (key.startswith("BlurOpacity") and not got.get("BlurRadius")):
                continue  # blur opacities of a 0 radius are not resolved
            e = float(np.abs(vec(rv, key) - vec(got[key], key)).max())
            if e > worst.get(key, (0,))[0]:
                worst[key] = (e, mat, D, a, dark)
    bad = {k: v for k, v in worst.items() if v[0] > 1e-3}
    print("1. apple_glass.inputs() vs %d Mac filter dumps: %s" % (len(samples), "exact (all keys within 1e-3)" if not bad else "DIFFERS"))
    for k, v in sorted(bad.items()):
        print("   %-28s max %.4g at %s D %s a %s %s" % (k, v[0], v[1], v[2], v[3], "dark" if v[4] else "light"))
    return not bad


# ---- 3. face colour
def face_ours(c, P):
    """Interior colour of shaders/liquidglass.frag over a flat backdrop c (0..1), mat = 1, linear light off.
    Keep in step with the shader (face block, edge bleed); over a flat backdrop refraction, blur and blur fill are identity."""
    c = np.array(c, float)
    M = P["MaxLuma"]
    col = c
    if M < 1:  # luminance limit with the chroma boost
        Y = c @ W709
        k = min(max(1 - Y * (1 - M), 0), 1)
        col = k * Y + k * (1 + 0.3 * (1 - k)) * (c - Y)
    Y1 = col @ W709
    f = P["FaceColorMatrixBlack"] + (P["FaceColorMatrixWhite"] - P["FaceColorMatrixBlack"]) * Y1 + P["FaceColorMatrixSaturation"] * (col - Y1)
    fa = P["Fill"][3]
    f = f * (1 - fa) + np.array(P["Fill"][:3]) * fa
    if P["BleedOpacity"] > 0:  # edge bleed over the whole interior, weight g^4
        Yb = c @ W709
        b = P["BleedColorMatrixBlack"] + (P["BleedColorMatrixWhite"] - P["BleedColorMatrixBlack"]) * Yb + P["BleedColorMatrixSaturation"] * (c - Yb)
        Yf = min(max(f @ WB, 0), 1)
        g = Yf if P["BleedDarkenBlend"] else 1 - Yf
        f = f + (b - f) * g ** 4 * P["BleedOpacity"]
    return np.clip(f, 0, 1)


def schlick(v, amount):
    return 0.0 if amount <= 0 else v / ((1 / amount - 2) * (1 - v) + 1)


def rim_rows(dst, P, n, px_per_pt=2):
    """Top rows of a flat body dst (0..1, the face colour) under the key/fill highlight (shaders/liquidglass.frag rim
    block, part 2): spec 1 pt, 1 - 0.75 depth; diffuse 8 pt linear at 0.65 x the spread; mix toward keyYcc(dst)."""
    out = []
    for i in range(n):
        depth = (i + 0.5) / px_per_pt  # pixel centre, pt
        cs, cd = math.cos(math.radians(P["KeySpreadDeg"])), math.cos(math.radians(0.65 * P["KeySpreadDeg"]))
        lk, ld = (1 - cs) / (1 - cs), (1 - cd) / (1 - cd)  # top edge: n . dir = 1
        spec = (1 - 0.75 * depth if depth < 1 else 0) * lk
        diff = max(0.0, 1 - depth / 8) * ld
        m = P["KeyScale"] * (schlick(spec, P["KeyAmount"]) + schlick(diff, P["DiffuseAmount"]))
        k = P["KeyYcc"]
        Y = dst @ W709
        v = np.clip(k[0] + (k[1] - k[0]) * Y + k[2] * (dst - Y), -0.75, 1)  # clamped before the mix (PC #67 B2 4b)
        out.append(float(np.clip(dst + m * (v - dst), 0, 1).mean() * 255))
    return out


# (label, material, dark, D, body colour, Mac rows from the edge): MAC-ANSWERS PC #67 B 1 (highlight layer alone over
# black), PC #62 1a (NC card top, dark, over black), Glass checks / Q-dock (Dock top rim over black, first px)
RIM_CASES = [("regular highlight alone over black", "regular", True, 64, [0, 0, 0], [56, 33, 11, 8, 6, 5, 4]),
             ("NC card top, dark, over black", "notificationcenter", True, 64, [35, 35, 35], [68, 53, 35]),
             ("Dock top, light, over black", "dock", False, 64, [38, 38, 38], [116]),
             ("Dock top, dark, over black", "dock", True, 64, [12, 12, 12], [104]),
             # real Control Center module top rim, dark (PC #67 B2 4b), D 64 (140 x 64 module)
             ("CC module top, over grey (body 110)", "controlcenter", True, 64, [110, 110, 110], [233, 180, 134, 128, 124, 121]),
             ("CC module top, over white (body 187)", "controlcenter", True, 64, [187, 187, 187], [255, 247, 208, 202]),
             ("CC module top, over black (body 32)", "controlcenter", True, 64, [32, 32, 32], [123, 84, 50, 45])]


def face_apple(c255, g):
    gi = {"inputFaceColorMatrixMaxLuma": g["MaxLuma"], "inputFaceColorMatrixBlack": g["FaceColorMatrixBlack"],
          "inputFaceColorMatrixWhite": g["FaceColorMatrixWhite"], "inputFaceColorMatrixSaturation": g["FaceColorMatrixSaturation"],
          "inputFaceColorMatrixFillColor": g["Fill"], "inputBleedOpacity": g["BleedOpacity"],
          "inputBleedColorMatrixBlack": g.get("BleedColorMatrixBlack", 0), "inputBleedColorMatrixWhite": g.get("BleedColorMatrixWhite", 1),
          "inputBleedColorMatrixSaturation": g.get("BleedColorMatrixSaturation", 1), "inputBleedDarkenBlend": g.get("BleedDarkenBlend", False)}
    return GM.model(c255, gi)


# ---- 5. refraction and blur over stripes
def lens(depth, h):
    t = min(max(depth / max(h, 1e-9), 0.0), 1.0)
    return 1 - math.sqrt(max((2 - t) * t, 0.0))


def apple_lod(R):
    return max(0.0, math.log2(R * 0.5 + 1 if R < 2 else R))


def blur_opacity(de, g):
    """BlurOpacity0..3 over BlurDistance0, -1, 0, 0 at de = d + displacement (pt, < 0 inside); 1 outside"""
    if de >= 0:
        return 1.0
    d0, o = g["BlurDistance0"], [g["BlurOpacity0"], g["BlurOpacity1"], g["BlurOpacity2"]]
    r1 = min(max((de - d0) / (-1 - d0), 0), 1) if d0 < -1 else 1.0
    r2 = min(max((de + 1) / 1, 0), 1)
    return o[0] + (o[1] - o[0]) * r1 + (o[2] - o[1]) * r2


def pyr_at(P, lev, x_px):
    """one trilinear read of the pyramid at screen px x_px (fractional) and level lev (levels of the scaled backdrop)"""
    l0 = min(int(math.floor(lev)), len(P.T) - 2)
    f = lev - l0
    u = P.u0[0] + (x_px - 0.5) / P.q
    a = GM3._bil(P.T[l0], np.array([u / 2 ** l0]))[0]
    return a if f <= 0 else a * (1 - f) + f * GM3._bil(P.T[l0 + 1], np.array([u / 2 ** (l0 + 1)]))[0]


def row_ours(screen, P, edge_px, n_px, under=0.0, ppp=2):
    """shaders/liquidglass.frag along the inward normal from a left edge at screen px edge_px (normal -x), 1-D grey screen
    0..1: refracted read at x - n m, blur radius BlurRadius x opacity(d - |m|), level lod(1.6 r texels/pt) composed with
    the underlay (4^L - 1 adds), then the face. From depth 1 pt on (the outer layer and the rim are not in it)."""
    s = P["BackdropScale"]
    pyr = GM3.Pyramid1D(np.asarray(screen, float), s)
    k = 1.6 * ppp * s
    out = []
    for i in range(n_px):
        depth = (i + 0.5) / ppp
        m = P["InnerRefractionAmount"] * lens(depth, P["InnerRefractionHeight"])  # < 0: read further inside
        r = P["BlurRadius"] * blur_opacity(-depth + m, P)
        L = apple_lod(k * r)
        if under > 0:
            L = 0.5 * math.log2(4 ** L + 4 ** apple_lod(k * under) - 1)
        v = pyr_at(pyr, L, edge_px + i + 0.5 - m * ppp)
        out.append(face_ours(np.array([v, v, v]), P)[0] * 255)
    return np.array(out)


def row_apple(screen, g, edge_px, n_px, ppp=2):
    """Apple's glass_background_base on the same line (glass_model C3 pyramid, lod(op x BlurRadius)) and face"""
    s = A.backdrop_scale(g["_material"], g)
    pyr = GM3.Pyramid1D(np.asarray(screen, float), s)
    out = []
    for i in range(n_px):
        depth = (i + 0.5) / ppp
        o = g["InnerRefractionAmount"] * lens(depth, g["InnerRefractionHeight"])
        lev = GM3.level(g["BlurRadius"] * blur_opacity(-depth + o, g), s, ppp, False)
        v = pyr_at(pyr, lev, edge_px + i + 0.5 - o * ppp)
        out.append(face_apple([v * 255] * 3, g)[0])
    return np.array(out)


def config_underlay(ns="hyprk-controlcenter", key="underlay_blur"):
    """the `underlay_blur` (or `panel_blur`) default of src/Config.cpp for a namespace"""
    import re
    txt = open(os.path.join(HERE, "..", "src", "Config.cpp")).read()
    m = re.search(r'K\("%s"\),\s*"([^"]*)"' % key, txt)
    for part in (m.group(1).split(",") if m else []):
        k, _, v = part.partition(":")
        if k.strip() == ns:
            return float(v)
    return 0.0


def panel_const(name):
    """a constexpr double of src/GlassElement.cpp (the panel blur's ramp)"""
    import re
    txt = open(os.path.join(HERE, "..", "src", "GlassElement.cpp")).read()
    return float(re.search(r"\b%s = ([0-9.]+)" % name, txt).group(1))


def stripes_check(ours):
    from PIL import Image
    print("\n5. refraction and blur over 4 pt black/white stripes (2x px)")
    bad = []
    mac = np.asarray(Image.open(os.path.join(ROOT, "reference", "screens", "27.2.1", "verify", "C2", "cc-real-stripes-a0.5071146.png")).convert("L"), float)
    # the real Display tile (292 x 64 pt): left edge at crop px 7.5 (the dark specular line is px 7), centre row 70
    edge, row, n = 7.5, 70, 100
    gap = mac[2] / 255  # the panel's blurred, dimmed stripes above the tile = what the tile samples on the Mac
    x = np.arange(len(gap))
    raw = np.where(((x - 3) // 8) % 2 == 0, 0.0, 0.898)  # hyprk's backdrop there: the sharp stripes under the panel's dim
    under = config_underlay()
    panel = config_underlay(key="panel_blur")
    if panel > 0:
        # the plugin draws the panel blur first (GlassElement::drawPanel): one trilinear read of its full-resolution pyramid
        # (level 0 = the screen, level 1 = the 2x2 box = Apple's scale-0.5 base) at lod(1.6 r px/pt), r ramping with the
        # depth inside the panel box (the tiles' box grown by PANEL_OUT): 0 at its edge, PANEL_KNEE_OPACITY x at PANEL_KNEE,
        # full from PANEL_RAMP (constants read from GlassElement.cpp). The crop's tile is the column's left tile, so the
        # box edge is PANEL_OUT left of it and both rows ramp horizontally; the tiles sample that row
        out, ramp, knee, knee_op = (panel_const(k) for k in ("PANEL_OUT", "PANEL_RAMP", "PANEL_KNEE", "PANEL_KNEE_OPACITY"))
        def panel_row(screen):
            pyr = GM3.Pyramid1D(screen, 0.5)
            levels = [screen] + [pyr.sample(l) for l in range(8)]  # full-resolution levels 0..8
            depth = out + (x + 0.5 - edge) / 2
            f = np.interp(depth, [0, knee, ramp], [0, knee_op, 1])
            L = np.array([apple_lod(1.6 * panel * fi * 2) for fi in f])
            l0 = np.minimum(np.floor(L).astype(int), len(levels) - 2)
            stack = np.array(levels)
            return stack[l0, x] * (1 - (L - l0)) + stack[l0 + 1, x] * (L - l0)
        # the gap row's stripes sit 1 px right of the tile row's model (phase 4, best fit of the row)
        gp = panel_row(np.where(((x - 4) // 8) % 2 == 0, 0.0, 0.898)) * 255 - mac[2]
        raw = panel_row(raw)
        r_g, r_e = float(np.sqrt((gp[100:500] ** 2).mean())), float(np.sqrt((gp[:140] ** 2).mean()))
        print("    CC panel blur (radius %.2f pt, ramp %g / %g @ %g / %g pt): gap row between the tiles pp %.1f (Mac %.1f), rms %.2f "
              "levels; where it leaves the tile column (140 px) rms %.2f" % (panel, out, knee, knee_op, ramp, np.ptp(raw[100:500] * 255),
                                                                           np.ptp(mac[2][100:500]), r_g, r_e))
        if r_g > 1.0:
            bad.append("CC panel blur")
        if r_e > 5.0:  # 1-D model of the ramp, 4.35; on screen 2.27 (REFRACTION.md "Rounded-end ripple")
            bad.append("CC panel blur ramp")
    P = ours[("controlcenter", True, 64, 0.5)]
    g = dict(A.inputs("controlcenter", 64, 0.5, True), _material="controlcenter")
    o, a, m = row_ours(raw, P, edge, n, under), row_apple(gap, g, edge, n), mac[row, 8:8 + n]
    sl = slice(2, n)  # from depth 1 pt
    e_o, e_a = o[sl] - m[sl], a[sl] - m[sl]
    r_o, r_a = float(np.sqrt((e_o ** 2).mean())), float(np.sqrt((e_a ** 2).mean()))
    def ext(v):  # turning points of the 3-tap smoothed row (px from the edge), the lens bands and the stripes behind them
        sg, out, last = np.sign(np.diff(np.round(v[:62]))), [], 0
        for i in range(2, len(sg)):
            if sg[i] != 0:
                if last != 0 and sg[i] != last:
                    out.append(i)
                last = sg[i]
        return out
    print("    CC tile rounded end, centre row, depth 1..50 pt: ours (underlay %.2f pt, tiles over the panel blur) rms %.2f, Apple's shader on the Mac's panel blur rms %.2f (levels)" % (under, r_o, r_a))
    print("      Mac   %s" % " ".join("%.0f" % v for v in m[2:42]))
    print("      ours  %s" % " ".join("%.0f" % v for v in o[2:42]))
    print("      Apple %s" % " ".join("%.0f" % v for v in a[2:42]))
    print("      lens band extrema (px from the edge): Mac %s, ours %s" % (ext(m), ext(o)))
    if r_o > 2.5 or r_o > r_a + 1.0:
        bad.append("CC rounded end")
    # ripple of the rounded end, depth 2..28 pt (the lens reads up to 80 pt inside, within the panel ramp)
    d = slice(4, 56)
    print("    CC tile rounded end, depth 2..28 pt: peak to peak ours %.1f (%.0f..%.0f), Mac %.1f (%.0f..%.0f)" % (
        np.ptp(o[d]), o[d].min(), o[d].max(), np.ptp(m[d]), m[d].min(), m[d].max()))
    if abs(np.ptp(o[d]) - np.ptp(m[d])) > 2.5:
        bad.append("CC rounded-end ripple")
    # interior contrast 15 pt below the top edge (C2 cc-real.json: 7.9 peak to peak at a = 0.507): a row there reads at
    # depth 15 without lateral displacement (the normal is vertical), so its blur level is that of depth 15
    k = 1.6 * 2 * P["BackdropScale"]
    mm = P["InnerRefractionAmount"] * lens(15, P["InnerRefractionHeight"])
    L = apple_lod(k * P["BlurRadius"] * blur_opacity(-15 + mm, P))
    if under > 0:
        L = 0.5 * math.log2(4 ** L + 4 ** apple_lod(k * under) - 1)
    pyr = GM3.Pyramid1D(raw, P["BackdropScale"])
    v = np.array([face_ours(np.array([t] * 3), P)[0] * 255 for t in pyr.sample(L)[100:400]])
    pp = float(v.max() - v.min())
    print("    CC tile 15 pt below the top edge: ours %.1f levels peak to peak, Mac 7.9" % pp)
    if abs(pp - 7.9) > 1.5:
        bad.append("CC interior contrast")
    # every material: the port against Apple's shader on the same raw stripes (no underlay), from depth 1 pt
    stripes = np.where((x // 8) % 2 == 0, 0.0, 1.0)
    for mat, D, dark in (("controlcenter", 64, True), ("dock", 64, True), ("clear", 64, True), ("regular", 64, True), ("regular", 200, False),
                         ("menu", 200, True), ("notificationcenter", 64, True)):
        P = ours[(mat, dark, D, 0.5)]
        g = dict(A.inputs(mat, A.size_d(mat, D), 0.5, dark), _material=mat)
        o, a = row_ours(stripes, P, 100.5, 120), row_apple(stripes, g, 100.5, 120)
        e = float(np.abs(o[2:] - a[2:]).max())
        print("    %-19s D %3d %-5s ours vs Apple over stripes, max |diff| %.2f levels" % (mat, D, "dark" if dark else "light", e))
        if e > 1.0:
            bad.append(mat)
    return bad


def slider_check(ours):
    """6. The Liquid Glass slider on the real Dock (MAC-ANSWERS Verify C 2, live/verify/C/dock-real.json: the Dock
    relaunched at NSGlassTintAmount 0 / 0.507 / 1 over 4 pt stripes, std along x and mean of the body): ClearDiffusionAmount
    scales the blur radius by 2a below 0.5 and adds a radius-8 blur fill with normal opacity 2a - 1 above. The port: the
    face sample of row_ours 8.5 pt inside the edge and the shader's blur fill block (two taps at -+ L / 4 texels of
    its level; keep in step with shaders/liquidglass.frag)."""
    print("\n6. Liquid Glass slider, Dock dark over 4 pt stripes: std along x / mean of the body (2x px)")
    real = json.load(open(os.path.join(VERIFY, "C", "dock-real.json")))
    x = np.arange(1200)
    stripes = np.where((x // 8) % 2 == 0, 0.0, 1.0)
    bad = []
    for a, key in ((0, "d0"), (0.5, "dbase"), (1, "d1")):
        P = ours[("dock", True, 64, a)]
        s = P["BackdropScale"]
        pyr = GM3.Pyramid1D(stripes, s)
        k = 1.6 * 2 * s
        # the Dock's free body is the band between its edge and the icons: 8.5 pt inside the top edge (the stripes run
        # along the normal there, so the lens only moves the blur opacity's depth)
        depth = 8.5
        m = P["InnerRefractionAmount"] * lens(depth, P["InnerRefractionHeight"])
        L = apple_lod(k * P["BlurRadius"] * blur_opacity(-depth + m, P))
        li, dk, nm = P["BlurFillLightenOpacity"], P["BlurFillDarkenOpacity"], P["BlurFillNormalOpacity"]
        Lf = apple_lod(k * 8.0)
        o = 0.25 * Lf / s
        out = []
        for px in range(400, 496):   # 6 stripe periods
            v = pyr_at(pyr, L, px + 0.5)
            if li + dk + nm > 0:
                bf = 0.5 * (pyr_at(pyr, Lf, px + 0.5 - o) + pyr_at(pyr, Lf, px + 0.5 + o))
                f = dk * min(v, bf) + li * max(v, bf) + (1 - li - dk) * v
                v = f + (bf - f) * nm
            out.append(face_ours(np.array([v, v, v]), P)[0] * 255)
        out = np.array(out)
        m = real[key]["stripes"]
        print("    a %-4s ours std %5.1f mean %5.1f | Mac std %5.1f mean %5.1f%s" % (a, out.std(), out.mean(), m["stdx"], m["mean"][0], "  (Mac at 0.507)" if a == 0.5 else ""))
        if abs(out.std() - m["stdx"]) > 4.0 or abs(out.mean() - m["mean"][0]) > 6.0:
            bad.append("dock slider a %s" % a)
    print("    over flat colours the Dock does not change with the slider (Mac 177 / 109 / 17 at all three): inputs in step 2")
    return bad


# ---- 7. corner curve
SC_K = 1.528665


def supercircle(px, py, hx, hy, R):
    """CA::OGL::Metal::ShaderUtils::supercircle_sdf of QuartzCore 27.2.1 (reference/re/27.2.1/decomp/
    QuartzCore-metallib-glass_background_sdf_all_lpf.ll) with compute_sdf_with_mode's cap for a continuous radius:
    distance and the y part of the normal. Keep in step with sdBoxN in shaders/liquidglass.frag."""
    ax, ay = np.abs(np.asarray(px, float)), np.abs(np.asarray(py, float))
    E = R * SC_K
    cx, cy = (min(max((SC_K - h / R) / (SC_K - 1), 0), 1) for h in (hx, hy))
    m = E + (R - E) * max(cx, cy)
    qx, qy = ax - hx + m, ay - hy + m
    tx, ty = np.maximum((ax - hx + E) / E, 0), np.maximum((ay - hy + E) / E, 0)
    ln, mx = np.hypot(tx, ty), np.maximum(tx, ty)
    x = np.where(mx > 0, np.clip(np.minimum(tx, ty) / np.where(mx > 0, mx, 1), 0, 1), 0)
    pol = 0.268531 + x * (1.26803 + x * (-3.64122 + x * (3.15601 - 0.926054 * x)))
    fc = ln + 1 - 1 / (1 - x * x * np.clip(ln, 0, 1) * pol)
    fr = np.hypot(np.maximum(tx * SC_K - (SC_K - 1), 0), np.maximum(ty * SC_K - (SC_K - 1), 0)) / SC_K + (1 - 1 / SC_K)
    sg = np.where(ty > tx, 1.0, -1.0)
    w = np.clip(0.5 - sg + sg * x, 0, 1)
    f57, f58 = fc + (fr - fc) * cx, fc + (fr - fc) * cy
    gx, gy = np.maximum(qx, 0), np.maximum(qy, 0)
    gl = np.hypot(gx, gy)
    ny = np.where(gl > 0, gy / np.where(gl > 0, gl, 1), np.where(qx > qy, 0.0, 1.0))
    return np.minimum(np.maximum(qx, qy), 0) + E * (f57 + (f58 - f57) * w - 1), ny


def lp_box(px, py, hx, hy, R, p):
    qx, qy = np.abs(px) - hx + R, np.abs(py) - hy + R
    mx, my = np.maximum(qx, 0), np.maximum(qy, 0)
    return (mx ** p + my ** p) ** (1 / p) + np.minimum(np.maximum(qx, qy), 0) - R


def corner_check(ours, dump):
    from PIL import Image
    bad = []
    print("\n7. corner curve (QuartzCore supercircle_sdf: the corner spans 1.528665 r) and the rim rows across it")
    if not dump.endswith(".json"):
        rows = np.array(json.loads(subprocess.run([dump, "--sdf"], capture_output=True, text=True, check=True).stdout))
        e = 0.0
        for hx, hy, R in {tuple(r[:3]) for r in rows}:
            sel = rows[(rows[:, 0] == hx) & (rows[:, 1] == hy) & (rows[:, 2] == R)]
            e = max(e, float(np.abs(supercircle(sel[:, 3], sel[:, 4], hx, hy, R)[0] - sel[:, 5]).max()))
        print("    plugin sdRoundedBox vs the port, %d points on 6 shapes: max |diff| %.2g pt" % (len(rows), e))
        if e > 1e-4:
            bad.append("sdf port")
    # the real slider tile (292 x 64 pt, continuous r 24, MAC-ANSWERS Q-panels-05) in the C2 crop: left edge at px 8, top at 12
    mac = np.asarray(Image.open(os.path.join(ROOT, "reference", "screens", "27.2.1", "verify", "C2", "cc-real-stripes-a0.5071146.png")).convert("L"), float)
    HX, HY, R, XE, TOP = 146, 32, 24, 8.0, 12.0
    xs = np.arange(30, 100)

    def mac_edge(cols):  # sub-pixel top edge: the peak rim row minus the coverage of the row above it
        out = []
        for x in cols:
            k = int(np.argmax(mac[5:24, x])) + 5
            out.append(k - min(max((mac[k - 1, x] - mac[3, x]) / (236.0 - mac[3, x]), 0), 1))
        return np.array(out)

    def model_edge(fn, cols, xe):
        ys = np.linspace(TOP - 1, TOP + 30, 3101)
        out = []
        for x in cols:
            d = fn(np.full_like(ys, (x + 0.5 - xe) / 2 - HX), (ys - TOP) / 2 - HY)
            out.append(ys[np.argmax(d < 0)])
        return np.array(out)

    apple = lambda x, y: supercircle(x, y, HX, HY, R)[0]
    res = {}
    for name, fn in (("Apple's curve", apple), ("Lp 2.6, extent r (the old corner)", lambda x, y: lp_box(x, y, HX, HY, R, 2.6)), ("circle", lambda x, y: lp_box(x, y, HX, HY, R, 2.0))):
        l = mac_edge(xs) - model_edge(fn, xs, XE)
        r = mac_edge(595 - xs) - model_edge(fn, xs, 596 - 2 * 2 * HX - XE)  # mirrored: the crop is 596 px wide
        res[name] = (float(np.sqrt((l ** 2).mean())), float(np.sqrt((r ** 2).mean())))
        print("    Mac tile top edge 11..46 pt from its end vs %-34s rms %.2f / %.2f px (left / right)" % (name, *res[name]))
    if max(res["Apple's curve"]) > 0.3:
        bad.append("corner contour")
    # rim rows 0..5 px below the tile top across both corners (crop x 40..556): body 109, the gap row beside the tile
    # under the pixel coverage, the highlight of step 4 with its lobes on the curve's normal
    P = ours.get(("controlcenter", True, 64, 0.5))
    X, Y = np.meshgrid(np.arange(40, 556), np.arange(12, 18))
    d, ny = supercircle((X + 0.5 - XE) / 2 - HX, (Y + 0.5 - TOP) / 2 - HY, HX, HY, R)
    depth = np.maximum(-d, 0)
    cs, cd = math.cos(math.radians(P["KeySpreadDeg"])), math.cos(math.radians(0.65 * P["KeySpreadDeg"]))
    spec = np.where(depth < 1, 1 - 0.75 * depth, 0) * np.clip((ny - cs) / (1 - cs), 0, 1)
    diff = np.maximum(0, 1 - depth / 8) * np.clip((ny - cd) / (1 - cd), 0, 1)
    sch = lambda v, a: v / ((1 / a - 2) * (1 - v) + 1)
    mk = P["KeyScale"] * (sch(spec, P["KeyAmount"]) + sch(diff, P["DiffuseAmount"]))
    b, k = 109 / 255, P["KeyYcc"]
    ins = np.clip(b + mk * (np.clip(k[0] + (k[1] - k[0]) * b, -0.75, 1) - b), 0, 1) * 255
    cov = np.clip(0.5 - d * 2, 0, 1)
    v = cov * ins + (1 - cov) * mac[5:6, 40:556]
    ref = mac[12:18, 40:556]
    pp = lambda a: " ".join("%.0f" % (r.max() - r.min()) for r in a)
    rms = float(np.sqrt(((v - ref) ** 2).mean()))
    print("    rim rows 0..5 px across the corners, peak to peak: ours %s, Mac %s; rms %.1f levels" % (pp(v), pp(ref), rms))
    if rms > 5 or any(abs((a.max() - a.min()) - (r.max() - r.min())) > 12 for a, r in zip(v, ref)):
        bad.append("corner rim rows")
    return bad


def load_dump(arg):
    txt = open(arg).read() if arg.endswith(".json") else subprocess.run([arg], capture_output=True, text=True, check=True).stdout
    return {(e["material"], e["dark"], e["D"], e["a"]): e["inputs"] for e in json.loads(txt)}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dump", required=True)
    ap.add_argument("--strict", action="store_true")
    ap.add_argument("--port", help="module with face_ours(c, P) replacing the built-in port (e.g. an older shader)")
    args = ap.parse_args()
    face = load_module(args.port, "port").face_ours if args.port else face_ours
    ok = check_reference()
    ours = load_dump(args.dump)

    # 2. inputs
    print("\n2. plugin inputs vs Apple, %d materials x light/dark x D %s x a %s (max |diff|, where it is largest)" % (len(A.MATERIALS), GRID_D, GRID_A))
    param_bad = 0
    for mat in A.MATERIALS:
        worst = {}
        for dark in (False, True):
            for D in GRID_D:
                for a in GRID_A:
                    Dm = A.size_d(mat, D)
                    ref = A.inputs(mat, Dm, a, dark)
                    ref["BackdropScale"] = A.backdrop_scale(mat, ref)
                    got = ours.get((mat, dark, D, a))
                    if got is None:
                        continue
                    for key in PORTED:
                        if key not in ref or key not in got:
                            continue
                        e = float(np.abs(vec(ref[key], key) - vec(got[key], key)).max())
                        if e > worst.get(key, (0,))[0]:
                            worst[key] = (e, D, a, dark, ref[key], got[key])
        dev = {k: v for k, v in worst.items() if v[0] > 1e-3 and (mat, k) in DEVIATIONS}
        bad = {k: v for k, v in worst.items() if v[0] > 1e-3 and (mat, k) not in DEVIATIONS}
        param_bad += len(bad)
        print("  %-19s %s" % (mat, "all %d ported inputs equal" % len(PORTED) if not bad else "%d inputs differ:" % len(bad)))
        for k, (e, D, a, dark, rv, gv) in sorted(bad.items()):
            fmt = lambda v: "[%s]" % ", ".join("%.4g" % x for x in v) if isinstance(v, list) else "%.4g" % v
            print("     %-27s %.4g  (D %s a %s %s: Apple %s, ours %s)" % (k, e, D, a, "dark" if dark else "light", fmt(rv), fmt(gv)))
        for k, (e, D, a, dark, rv, gv) in sorted(dev.items()):
            print("     deviation %-17s %.4g  (%s)" % (k, e, DEVIATIONS[(mat, k)]))

    # 3. face
    ramp = json.load(open(os.path.join(VERIFY, "C2", "ramp-shader-model.json")))["data"]
    backdrops = [p["backdrop"] for p in next(iter(ramp.values()))["points"]]
    ramp_m = {"regular": ("regular", 64), "regular96": ("regular", 96), "regular200": ("regular", 200), "regular500": ("regular", 500),
              "menu200": ("menu", 200), "notificationCenter": ("notificationcenter", 64), "clear": ("clear", 64), "dock": ("dock", 64),
              "controlCenter": ("controlcenter", 64)}
    print("\n3a. face vs the Mac's measured centre pixels (17 flat backdrops, a = 0 / 0.5 / 1), rms / max in levels of 255")
    print("    %-26s %-16s %-16s %s" % ("probe", "ours", "Apple model", "(glass_model.py with the dumped inputs)"))
    face_bad = []
    by_mat = {}
    for k, v in ramp.items():
        mode, name, a = k.split()
        if name not in ramp_m:
            continue
        mat, D = ramp_m[name]
        dark, a = mode == "dark", float(a[2:])
        if mat in A.SIZE:  # the probe was automatic (its own D); ours resolves at the size class, checked in 3b
            continue
        P = ours.get((mat, dark, D, a))
        if P is None:
            continue
        meas = np.array([p["measured"] for p in v["points"]])
        e_ours = np.array([face(np.array(p["backdrop"]) / 255, P) * 255 for p in v["points"]]) - meas
        e_mod = np.array([p["model"] for p in v["points"]]) - meas
        r = (float(np.sqrt((e_ours ** 2).mean())), float(np.abs(e_ours).max()))
        by_mat.setdefault(mat, []).append(e_ours)
        print("    %-5s %-20s %5.2f / %5.2f    %5.2f / %5.2f" % (mode, "%s a=%g" % (name, a), r[0], r[1], float(np.sqrt((e_mod ** 2).mean())), float(np.abs(e_mod).max())))
        if r[1] > float(np.abs(e_mod).max()) + 1.0 and (mat, "MaxLuma") not in DEVIATIONS:
            face_bad.append(k)
    print("\n3b. face vs glass_model.py on the grid (Apple inputs), per material over D x a x light/dark x 17 backdrops: rms / max")
    grid_bad = []
    for mat in A.MATERIALS:
        errs = []
        worst = (-1, None)
        for dark in (False, True):
            for D in GRID_D:
                for a in GRID_A:
                    P = ours.get((mat, dark, D, a))
                    if P is None:
                        continue
                    g = A.inputs(mat, A.size_d(mat, D), a, dark)
                    for bd in backdrops:
                        e = face(np.array(bd) / 255, P) * 255 - face_apple(bd, g)
                        errs.append(e)
                        m = float(np.abs(e).max())
                        if m > worst[0]:
                            worst = (m, (D, a, "dark" if dark else "light", bd))
        errs = np.array(errs)
        rms, mx = float(np.sqrt((errs ** 2).mean())), float(np.abs(errs).max())
        print("    %-19s %6.2f / %6.2f   worst at D %s a %s %s backdrop %s" % (mat, rms, mx, *worst[1]))
        if mx > 1.0 and (mat, "MaxLuma") not in DEVIATIONS:
            grid_bad.append(mat)
    print("    (size-class materials %s: 3a skipped, the probe was automatic)" % ", ".join(sorted(A.SIZE)))

    # 4. rim: the key/fill highlight mask of the shader (port of rimRows below) against the Mac's rows, 2x display
    print("4. rim rows from the edge inward (2x), ours vs Mac")
    rim_bad = []
    for label, mat, dark, D, dst, mac in RIM_CASES:
        P = ours.get((mat, dark, D, 0.5))
        if P is None:
            continue
        rows = rim_rows(np.array(dst, float) / 255, P, len(mac))
        e = max(abs(r - m) for r, m in zip(rows, mac))
        print("    %-44s ours %-26s Mac %-24s max %.1f" % (label, " ".join("%.0f" % x for x in rows), " ".join(str(x) for x in mac), e))
        if e > 2.0:
            rim_bad.append(label)
    stripe_bad = stripes_check(ours) + slider_check(ours) + corner_check(ours, args.dump)
    if args.strict and (not ok or param_bad or face_bad or grid_bad or rim_bad or stripe_bad):
        print("\nFAIL: reference %s, %d inputs differ, face off vs Mac: %s, vs model: %s, rim: %s, stripes: %s" % ("ok" if ok else "differs", param_bad, face_bad, grid_bad, rim_bad, stripe_bad))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
