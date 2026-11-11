#!/usr/bin/env python3 -I
"""The FITTED rim of the two light Dock styles (build-styles.py DOCK_LIGHT); everything else is icr.py.

`highlight` is Apple's `glassHighlight` kernel (IconRendering default.metallib), kept here with the inputs that
were fitted to the Mac's Settings tile plates before IconRendering's own values were decoded (RIM in
build-styles.py). The decoded values and the composition around the kernel are in icr.py and
reference/ASSETS.md; TintedLight / ClearLight still use this fit because their Dock look is live glass, which the
port does not reproduce (build-styles.py says why).

    t    = saturate(d / height)
    w    = clamp(fwidth(d), 2^-10, 2) * 0.833
    k    = clamp((height - 1) / 2, 0, 1);  f = k^2 (3 - 2k) * curvature
    fall = mix(1, 1 - t, f)
    band = saturate((height - d) / w + 0.5) * saturate(d / w + 0.5)
    l    = saturate((dot(light, n) - spread) / max(1 - spread, 2^-10)) * fall
    out  = colour * band * l / max(1 + (1 - l) * bias, 2^-10)
"""
import numpy as np
from PIL import Image


def sdf(cov, up=4, reach=0.08):
    """body coverage (HxW, 0..1) -> signed distance in px (positive inside), and the unit outward normal.
    Exact (to the 1/up px contour) within reach * size of the edge, clamped beyond (the highlight band is
    narrower than that)."""
    n = cov.shape[0]
    big = np.asarray(Image.fromarray((np.clip(cov, 0, 1) * 255).astype("uint8")).resize((n * up, n * up), Image.BICUBIC)) / 255.0
    inside = big >= 0.5
    edge = inside & ~(np.roll(inside, 1, 0) & np.roll(inside, -1, 0) & np.roll(inside, 1, 1) & np.roll(inside, -1, 1))
    ey, ex = np.nonzero(edge)
    pts = (np.stack([ey, ex], 1) + 0.5) / up
    r = max(2, int(np.ceil(reach * n)))
    m = cov >= 0.5
    near = (m != np.roll(m, 1, 0)) | (m != np.roll(m, 1, 1))
    for _ in range(r):
        near = near | np.roll(near, 1, 0) | np.roll(near, -1, 0) | np.roll(near, 1, 1) | np.roll(near, -1, 1)
    d = np.full((n, n), float(r), np.float32)
    qy, qx = np.nonzero(near)
    q = np.stack([qy, qx], 1) + 0.5
    for i in range(0, len(q), 2048):
        dd = np.sqrt(((q[i:i + 2048, None, :] - pts[None, :, :]) ** 2).sum(-1)).min(1)
        d[qy[i:i + 2048], qx[i:i + 2048]] = np.minimum(dd, r)
    d = np.where(cov >= 0.5, d, -d)
    gy, gx = np.gradient(d)
    norm = np.maximum(np.hypot(gx, gy), 1e-6)
    return d, np.stack([-gx / norm, -gy / norm], -1)       # outward normal (x right, y down)


def highlight(d, normal, light, height, spread, bias, curvature, inset=0.0):
    """Apple's glassHighlight (see the module doc) -> HxW intensity; light = unit 2D direction (x right, y down)"""
    d = d - inset
    t = np.clip(d / height, 0, 1)
    gy, gx = np.gradient(d)
    w = np.clip(np.abs(gx) + np.abs(gy), 2 ** -10, 2) * 0.833
    k = np.clip((height - 1) * 0.5, 0, 1)
    f = k * k * (3 - 2 * k) * curvature
    fall = 1 + ((1 - t) - 1) * f
    band = np.clip((height - d) / w + 0.5, 0, 1) * np.clip(d / w + 0.5, 0, 1)
    dl = normal[..., 0] * light[0] + normal[..., 1] * light[1]
    l = np.clip((dl - spread) / max(1 - spread, 2 ** -10), 0, 1) * fall
    return band * l / np.maximum(1 + (1 - l) * bias, 2 ** -10)


def rim(d, normal, p):
    """the chiclet's specular edge: a key light from above and its mirror from below (both seen on every
    Apple chiclet, top stronger), parameters p (fitted, build-styles.py RIM)"""
    a = np.radians(p["angle"])
    key = highlight(d, normal, (np.sin(a), -np.cos(a)), p["height"], p["spread"], p["bias"], p["curvature"])
    fill = highlight(d, normal, (-np.sin(a), np.cos(a)), p["height"], p["spread"], p["bias"], p["curvature"])
    return key + p["fill"] * fill
