#!/usr/bin/env python3
"""Traffic lights of macOS 27.2.1 as a small glass-disc model, fitted to the 2x crops
reference/screens/27.2.1/windows/lights-*.png (MAC-ANSWERS Q-windows-08..10).

The Mac's discs are not flat gradients: a lit band at the top, a darker belt above the middle, a caustic glow in the
lower centre, a specular rim (dark appearance: light arcs at top and bottom, plain sides; light appearance: a dark
coloured rim on the sides) and, in light, a soft coloured shadow below. Model, in units of the disc radius R
(u right, v down, rho = |(u, v)|), colours in sRGB bytes, clamped at the end (the crops are sRGB with the P3
colours clipped, so M can be below 0):
  body  = M + (T - M) * clamp((V0 - v) / (V0 + 1)) + (B - M) * clamp((v - V0) / (1 - V0)) * exp(-(u / sg)^2)
  rim   : mix(body, rimC, e(d) * |v / rho|^n)   (axis "v": arcs at top and bottom)
          mix(body, rimC, e(d) * |u / rho|^n)   (axis "u": the sides)
          d = pt inside the edge, e = e0 up to 0.25 pt, e1 at 0.75 pt, 0 from 1.25 pt, linear between
  glow  : glowC with alpha g0 * 0.5 * erfc((|p - (0, GLOW_DY)| - R) / (GLOW_SIGMA * sqrt 2)), under the disc
The same formula is drawn by plugin/src/Titlebar.cpp (per pixel into a texture) and ui/HyprK/shaders/lights.frag.

  lights_model.py fit      fit every state to the crops, print the table and the residuals (rms, max per state)
  lights_model.py emit     print the C++ and QML tables
  lights_model.py check    compare the tables in Titlebar.cpp and TrafficLights.qml with TABLE below
  lights_model.py render OUT.png [scale]   draw all states with TABLE (rows: dark rest/pressed/inactive, light ...)
"""
import itertools
import math
import os
import re
import sys

import numpy as np

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
CROPS = os.path.join(ROOT, "reference", "screens", "27.2.1", "windows")
V0 = -0.35                       # the dark belt, fitted (-0.3..-0.4 over the six rest discs)
GLOW_DY, GLOW_SIGMA = 0.75, 1.0  # pt, fitted on the light rest discs
RADIUS = 7.0                     # pt
PRESS = 16.0 / 14.0              # pressed disc 32 px of 28 (Q-windows-08)
PITCH = 23.0                     # pt between discs (Q-windows-07)

# state -> button -> (T, M, B, sg, axis, n, rimC, e0, e1, glowC, g0); written by `fit` (paste its output here)
TABLE = {
    "dark": [
        ((234, 121, 110), (226, 93, 78), (220, 124, 117), 0.6, "v", 2.5, (255, 197, 188), 1.00, 0.45, (0, 0, 0), 0.000),
        ((239, 183, 86), (241, 184, -12), (249, 223, 145), 0.7, "v", 1.5, (255, 244, 114), 1.00, 0.60, (0, 0, 0), 0.000),
        ((129, 200, 112), (78, 185, -6), (133, 197, 137), 0.6, "v", 1.5, (175, 255, 140), 1.00, 0.40, (0, 0, 0), 0.000),
    ],
    "darkPress": [
        ((255, 159, 143), (255, 126, 107), (255, 160, 148), 0.5, "v", 3.0, (255, 253, 244), 0.70, 0.67, (0, 0, 0), 0.000),
        ((255, 245, 117), (255, 247, -7), (255, 277, 154), 0.7, "v", 1.5, (254, 250, 152), 0.80, 0.76, (0, 0, 0), 0.000),
        ((156, 241, 135), (94, 223, -6), (155, 230, 160), 0.6, "v", 1.5, (175, 255, 140), 0.70, 0.67, (0, 0, 0), 0.000),  # no Mac crop of this press (lights-press-zoom-dark.png shows the rest disc): rest x the close / minimise gains
    ],
    "darkInactive": [
        ((81, 82, 88), (78, 79, 85), (67, 68, 74), 1.3, "v", 3.0, (243, 243, 240), 0.60, 0.24, (0, 0, 0), 0.000),
        None,  # as the first
        None,  # as the first
    ],
    "light": [
        ((237, 119, 106), (234, 121, 109), (233, 160, 152), 1.3, "u", 2.5, (167, 24, 10), 1.00, 0.20, (225, 26, 0), 0.140),
        ((241, 186, 82), (244, 195, 79), (250, 224, 109), 1.0, "u", 2.5, (131, 59, 0), 1.00, 0.20, (229, 112, 0), 0.129),
        ((121, 204, 67), (136, 207, 90), (190, 227, 162), 1.3, "u", 2.0, (43, 94, 18), 1.00, 0.25, (52, 154, 0), 0.130),
    ],
    "lightPress": [
        ((255, 157, 140), (255, 162, 146), (255, 207, 196), 1.3, "u", 3.0, (255, 85, 72), 1.00, 0.55, (222, 25, 0), 0.174),
        ((255, 257, 111), (255, 253, 103), (255, 256, 143), 0.8, "u", 3.0, (247, 92, 0), 0.80, 0.16, (222, 116, 0), 0.197),
        ((162, 255, 91), (183, 255, 121), (244, 255, 203), 2.0, "u", 3.0, (76, 178, 44), 1.00, 0.35, (52, 151, 0), 0.177),
    ],
    "lightInactive": [
        ((248, 248, 252), (239, 240, 242), (249, 250, 252), 0.5, "u", 1.5, (51, 50, 59), 0.40, 0.10, (0, 0, 0), 0.000),
        None,  # as the first
        None,  # as the first
    ],
}
# residuals of the fit over the disc and 3 pt around it, sRGB levels (crop vs model at the crop's sub-pixel position):
# dark           0  rms 3.97  max 27  body rms 2.36  (crop disc offset 0.00 0.00 pt, radius +0.00)
# dark           1  rms 6.58  max 44  body rms 6.74  (crop disc offset 0.00 0.00 pt, radius +0.00)
# dark           2  rms 7.34  max 44  body rms 7.35  (crop disc offset 0.00 0.00 pt, radius +0.00)
# darkPress      0  rms 5.83  max 39  body rms 3.18  (crop disc offset 0.00 0.00 pt, radius +0.05)
# darkPress      1  rms 9.39  max 51  body rms 8.24  (crop disc offset 0.00 0.00 pt, radius +0.00)
# darkInactive   0  rms 2.72  max 23  body rms 0.67  (crop disc offset 0.00 0.00 pt, radius +0.00)
# light          0  rms 4.85  max 49  body rms 1.65  (crop disc offset 0.00 0.00 pt, radius +0.00)
# light          1  rms 4.97  max 49  body rms 1.44  (crop disc offset 0.00 0.00 pt, radius +0.00)
# light          2  rms 5.79  max 43  body rms 2.20  (crop disc offset 0.00 0.00 pt, radius +0.00)
# lightPress     0  rms 7.21  max 54  body rms 1.81  (crop disc offset 0.00 0.00 pt, radius +0.05)
# lightPress     1  rms 9.43  max 73  body rms 6.42  (crop disc offset 0.00 0.00 pt, radius +0.05)
# lightPress     2  rms 8.82  max 56  body rms 2.09  (crop disc offset 0.00 0.00 pt, radius +0.05)
# lightInactive  0  rms 2.90  max 19  body rms 1.02  (crop disc offset 0.00 0.00 pt, radius -0.05)


def body(u, v, T, M, B, sg):
    a = np.clip((V0 - v) / (V0 + 1), 0, 1)[..., None]
    b = (np.clip((v - V0) / (1 - V0), 0, 1) * np.exp(-(u / sg) ** 2))[..., None]
    return np.asarray(M, float) + (np.asarray(T, float) - M) * a + (np.asarray(B, float) - M) * b


def rim_e(d, e0, e1):
    return np.where(d <= 0.25, e0, np.where(d <= 0.75, e0 + (e1 - e0) * (d - 0.25) / 0.5, np.clip(e1 * (1.25 - d) / 0.5, 0, None)))


def rim_w(u, v, R, axis, n, e0, e1):
    rho = np.hypot(u, v)
    ang = np.abs((v if axis == "v" else u) / np.maximum(rho, 1e-6)) ** n
    return rim_e(R - R * rho, e0, e1) * ang


_erfc = np.vectorize(math.erfc)


def glow_a(x, y, R, g0):
    return g0 * 0.5 * _erfc((np.hypot(x, y - GLOW_DY) - R) / (GLOW_SIGMA * math.sqrt(2)))


def render(p, R, x, y, bg, px):
    """x, y: pt from the disc centre (arrays); px: pt per device pixel; returns sRGB bytes over bg"""
    T, M, B, sg, axis, n, rimC, e0, e1, glowC, g0 = p
    u, v = x / R, y / R
    col = body(u, v, T, M, B, sg)
    w = rim_w(u, v, R, axis, n, e0, e1)[..., None]
    col = np.clip(col * (1 - w) + np.asarray(rimC, float) * w, 0, 255)
    cov = np.clip((R - np.hypot(x, y)) / px + 0.5, 0, 1)[..., None]
    out = np.asarray(bg, float) * np.ones_like(col)
    if g0 > 0:
        ga = glow_a(x, y, R, g0)[..., None]
        out = out * (1 - ga) + np.asarray(glowC, float) * ga
    return out * (1 - cov) + col * cov


# ---------------------------------------------------------------------------------------------------- fitting
STATES = {  # name -> (crop per button, pressed?, glyph drawn?)
    "dark": (["lights-rest-dark.png"] * 3, False, False),
    "darkPress": (["lights-press-close-dark.png", "lights-press-min-dark.png", "lights-press-zoom-dark.png"], True, True),
    "darkInactive": (["lights-inactive-dark.png"] * 3, False, False),
    "light": (["lights-rest-light.png"] * 3, False, False),
    "lightPress": (["lights-press-close-light.png", "lights-press-min-light.png", "lights-press-zoom-light.png"], True, True),
    "lightInactive": (["lights-inactive-light.png"] * 3, False, False),
}


def load(name):
    from PIL import Image
    return np.array(Image.open(os.path.join(CROPS, name)).convert("RGB")).astype(float)


def grid(img, btn, half=20):
    cx, cy = 31.5 + 2 * PITCH * btn, 31.5   # px in the 2x crop: disc centre 16,16 pt
    ys, xs = np.mgrid[int(cy - half) + 1:int(cy + half) + 1, int(cx - half) + 1:int(cx + half) + 1]
    return (xs - cx) / 2.0, (ys - cy) / 2.0, img[ys, xs]


def censored(X, y):
    c = np.linalg.lstsq(X, y, rcond=None)[0]
    lo, hi = y <= 1, y >= 254
    if lo.sum() > 3 or hi.sum() > 3:
        for _ in range(200):
            pr = X @ c
            yy = y.copy()
            yy[lo] = np.minimum(pr[lo], 0)
            yy[hi] = np.maximum(pr[hi], 255)
            c = np.linalg.lstsq(X, yy, rcond=None)[0]
    return c


def fit_one(img, btn, pressed, glyph, dark):
    x, y, I = grid(img, btn)
    bg = img[2, 100] if not dark else img[40, 100]
    bg = np.array([np.median(img[50:62, 4 * 20:4 * 20 + 6, c]) for c in range(3)])
    R = RADIUS * (PRESS if pressed else 1)
    u, v = x / R, y / R
    rho = np.hypot(u, v)
    hole = glyph & (np.abs(x) < 4.4) & (np.abs(y) < 4.4)
    # 1. body
    inner = (rho * R < R - 1.3) & ~hole
    best = None
    for sg in (0.5, 0.6, 0.7, 0.8, 1.0, 1.3, 2.0, 4.0):
        a = np.clip((V0 - v[inner]) / (V0 + 1), 0, 1)
        b = np.clip((v[inner] - V0) / (1 - V0), 0, 1) * np.exp(-(u[inner] / sg) ** 2)
        X = np.stack([np.ones_like(a), a, b], 1)
        c = np.stack([censored(X, I[inner][:, ch]) for ch in range(3)], 1)
        r = np.sqrt(((np.clip(X @ c, 0, 255) - I[inner]) ** 2).mean())
        if best is None or r < best[0] - 0.02:
            best = (r, sg, c)
    _, sg, c = best
    M, T, B = c[0], c[0] + c[1], c[0] + c[2]
    bod = body(u, v, T, M, B, sg)
    # 2. rim: full-coverage pixels within 1.25 pt of the edge
    ring = (rho * R <= R - 0.25) & (rho * R > R - 1.3) & ~hole
    d = R - R * rho
    bestr = None
    for axis, n in itertools.product("vu", (1.5, 2.0, 2.5, 3.0)):
        ang = np.abs((v if axis == "v" else u) / np.maximum(rho, 1e-6)) ** n
        k0 = np.where(d <= 0.25, 1, np.where(d <= 0.75, 1 - (d - 0.25) / 0.5, 0)) * ang   # weight of e0
        k1 = np.where(d <= 0.25, 0, np.where(d <= 0.75, (d - 0.25) / 0.5, np.clip((1.25 - d) / 0.5, 0, None))) * ang
        # I - body = (e0 k0 + e1 k1) (C - body): linear in (e0 C), e0, (e1 C), e1 per channel jointly; solve by
        # scanning e1 / e0 and C from least squares with e0 fixed, then scale so the strongest pixel has e0 <= 1
        for ratio in np.arange(0, 1.01, 0.05):
            w = (k0 + ratio * k1)[ring]
            for e0 in (0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0):
                ww = (e0 * w)[:, None]
                # C per channel: minimise |body (1 - ww) + C ww - I|
                num = (ww * (I[ring] - bod[ring] * (1 - ww))).sum(0)
                C = np.clip(num / np.maximum((ww * ww).sum(0), 1e-9), 0, 255)
                pred = np.clip(bod[ring] * (1 - ww) + C * ww, 0, 255)
                r = np.sqrt(((pred - I[ring]) ** 2).mean())
                if bestr is None or r < bestr[0] - 0.05:
                    bestr = (r, axis, n, C, e0, e0 * ratio)
    _, axis, n, rimC, e0, e1 = bestr
    # 3. glow: pixels outside the disc (beyond the antialiased edge)
    out = (rho * R > R + 0.6) & (rho * R < R + 3.2)
    if pressed:   # the neighbours are 23 pt away: keep clear of them
        out &= np.abs(x) < R + 3
    a1 = glow_a(x, y, R, 1.0)[out]
    K = np.array([(a1 * (bg[ch] - I[out][:, ch])).sum() / (a1 * a1).sum() for ch in range(3)])   # g0 (bg - C)
    if np.abs(K).max() < 3.0:
        glowC, g0 = np.zeros(3), 0.0
    elif K.max() > -K.min():   # darkens: the most absorbed channel is 0
        g0 = float((K / np.maximum(bg, 1)).max())
        glowC = np.clip(bg - K / g0, 0, 255)
    else:                      # lightens: the brightest channel is 255
        g0 = float((-K / np.maximum(255 - bg, 1)).max())
        glowC = np.clip(bg - K / g0, 0, 255)
    p = (T, M, B, sg, axis, n, rimC, e0, e1, glowC, g0)
    m = ~hole & (rho * R < R + 3.2)
    if pressed:
        m &= np.abs(x) < R + 3
    # residual with the crop's sub-pixel disc position and size (the antialiased edge row is sensitive to 0.1 px)
    best = None
    for dx, dy, dr in itertools.product((-0.15, -0.1, -0.05, 0, 0.05, 0.1, 0.15), (-0.15, -0.1, -0.05, 0, 0.05, 0.1, 0.15), (-0.1, -0.05, 0, 0.05, 0.1)):
        pred = render(p, R + dr, x - dx, y - dy, bg, 0.5)
        r = float(np.sqrt((((pred - I)[m]) ** 2).mean()))
        if best is None or r < best[0]:
            best = (r, float(np.abs((pred - I)[m]).max()), (dx, dy, dr), pred)
    return p, best[0], best[1], float(np.sqrt(((best[3] - I)[inner] ** 2).mean())), best[2], (I, best[3], m)


def fmt_py(p):
    T, M, B, sg, axis, n, rimC, e0, e1, glowC, g0 = p
    t = lambda c: "(%d, %d, %d)" % tuple(int(round(float(z))) for z in c)
    return "(%s, %s, %s, %.1f, \"%s\", %.1f, %s, %.2f, %.2f, %s, %.3f)" % (t(T), t(M), t(B), sg, axis, n, t(rimC), e0, e1, t(glowC), g0)


def cmd_fit(sheet=None):
    print("TABLE = {")
    res, tiles = [], []
    for name, (crops, pressed, glyph) in STATES.items():
        dark = name.startswith("dark")
        print('    "%s": [' % name)
        for b in range(3):
            if "Inactive" in name and b:
                print("        None,  # as the first")
                continue
            p, rms, mx, rin, off, (I, pred, m) = fit_one(load(crops[b]), b, pressed, glyph, dark)
            res.append((name, b, rms, mx, rin, off[0], off[1], off[2]))
            tiles.append(np.hstack([I, pred]))
            print("        %s," % fmt_py(p))
        print("    ],")
    print("}")
    for r in res:
        print("# %-14s %d  rms %.2f  max %.0f  body rms %.2f  (crop disc offset %.2f %.2f pt, radius %+.2f)" % r)
    if sheet:
        from PIL import Image
        im = Image.fromarray(np.clip(np.vstack(tiles), 0, 255).astype(np.uint8))
        im.resize((im.width * 6, im.height * 6), Image.NEAREST).save(sheet)


def table():
    out = {}
    for name, rows in TABLE.items():
        out[name] = [r if r is not None else rows[0] for r in rows]
    return out


ORDER = ["rest", "press", "inactive"]
KEYS = {"light": ["light", "lightPress", "lightInactive"], "dark": ["dark", "darkPress", "darkInactive"]}
CPP = os.path.join(ROOT, "plugin", "src", "Titlebar.cpp")
QML = os.path.join(ROOT, "ui", "HyprK", "TrafficLights.qml")


def flat(r):
    T, M, B, sg, axis, n, rimC, e0, e1, glowC, g0 = r
    return [*T, *M, *B, sg, 0 if axis == "v" else 1, n, *rimC, e0, e1, *glowC, g0]


def num(x):
    return ("%g" % x)


def emit_cpp():
    t = table()
    out = ["    // generated: plugin/tools/lights_model.py emit (check: lights_model.py check)",
           "    static constexpr SLightGlass GLASS[2][3][3] = {"]
    for mode in ("light", "dark"):
        out.append("        {")
        for k in KEYS[mode]:
            out.append("            {" + ", ".join("{" + ", ".join(num(x) for x in flat(r)) + "}" for r in t[k]) + "},")
        out.append("        },")
    out.append("    };")
    return "\n".join(out)


def emit_qml():
    t = table()
    out = ["    // generated: plugin/tools/lights_model.py emit (check: lights_model.py check)",
           "    readonly property var glass: ({"]
    for mode in ("light", "dark"):
        out.append("        %s: [" % mode)
        for k in KEYS[mode]:
            out.append("            [" + ", ".join("[" + ", ".join(num(x) for x in flat(r)) + "]" for r in t[k]) + "],")
        out.append("        ],")
    out.append("    })")
    return "\n".join(out)


def cmd_check():
    bad = 0
    for path, text in ((CPP, emit_cpp()), (QML, emit_qml())):
        if text not in open(path).read():
            print("lights_model: table in %s differs from TABLE (run emit and paste)" % os.path.relpath(path, ROOT))
            bad = 1
    for name, v in (("V0", V0), ("GLOW_DY", GLOW_DY), ("GLOW_SIGMA", GLOW_SIGMA)):
        for path in (CPP, os.path.join(ROOT, "ui", "HyprK", "shaders", "lights.frag")):
            if not re.search(r"\b%s\s*=\s*%s\b" % (name, re.escape(num(v))), open(path).read()):
                print("lights_model: %s = %s not found in %s" % (name, num(v), os.path.relpath(path, ROOT)))
                bad = 1
    print("lights_model: tables and constants %s" % ("DIFFER" if bad else "match"))
    return bad


def cmd_render(out, scale):
    from PIL import Image
    t = table()
    px = 1.0 / scale
    rows = []
    for mode, bg in (("dark", (40, 40, 46)), ("light", (255, 255, 255))):
        for si, k in enumerate(KEYS[mode]):
            n = int(round(90 * scale))
            h = int(round(32 * scale))
            ys, xs = np.mgrid[0:h, 0:n]
            img = np.ones((h, n, 3)) * np.array(bg, float)
            for b in range(3):
                R = RADIUS * (PRESS if si == 1 else 1)
                x = (xs + 0.5) * px - (16 + PITCH * b)
                y = (ys + 0.5) * px - 16
                m = np.hypot(x, y) < R + 4
                img[m] = render(t[k][b], R, x[m], y[m], bg, px)
            rows.append(img)
    Image.fromarray(np.clip(np.vstack(rows), 0, 255).round().astype(np.uint8)).save(out)


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "emit":
        print(emit_cpp())
        print(emit_qml())
        sys.exit(0)
    if cmd == "check":
        sys.exit(cmd_check())
    if cmd == "render":
        cmd_render(sys.argv[2], float(sys.argv[3]) if len(sys.argv) > 3 else 2.0)
        sys.exit(0)
    if cmd == "fit":
        cmd_fit(sys.argv[2] if len(sys.argv) > 2 else None)
    else:
        sys.exit(__doc__)
