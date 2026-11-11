# Liquid Glass interior model, macOS 27.2.1 (26B131). Extends live/verify/C2/glass_model.py with
#   (1) the sidebar's CAChameleonLayer (wallpaper tint, colour blend mode) and
#   (2) the blur: backdrop scale + CA "variable blur" mip pyramid + trilinear lod, with a Gaussian equivalent.
# All colour maths is on display-encoded values 0..1. g = glassBackground filter inputs (keys "inputXxx").
# Sources: QuartzCore default.metallib glass_background_base, variable_blur_downsample_frag;
# CA::OGL::GlassBackgroundFilter::render 0x18debc058; CA::Render::Updater::prepare_layer0 0x18dec68a4 (chameleon);
# SkyLight Payload::average_color 0x182a94d60. Fit data: this folder (sidebar-fit.json, blur-*.json).
import math
import numpy as np
W709 = np.array([.2126, .7152, .0722]); WB = np.array([.2125, .7154, .0721]); WLUM = np.array([.3, .59, .11])
sat = lambda x: np.clip(x, 0, 1)

def ycc(c, black, white, s, fill=None):
    Y = c @ W709; v = black + (white - black) * Y + s * (c - Y)
    if fill is not None and fill[3] > 0: v = v * (1 - fill[3]) + np.array(fill[:3]) * fill[3]
    return v

def face(c, g, s=None, hdr=0.0):
    """c: backdrop behind the glass after blur + blur fill (0..1). s: sharp backdrop sample for the edge bleed
    (defaults to c). Returns the glassBackground output before the display clamp (extended range)."""
    c = np.asarray(c, float); s = c if s is None else np.asarray(s, float)
    M = g['inputFaceColorMatrixMaxLuma']; Ms = g.get('inputFaceColorMatrixMaxLumaSDR', M)
    comp = 1 - min(max(Ms + (M - Ms) * hdr, 0), 1)
    c1 = c
    if comp > 0:
        Y = c @ W709; k = sat(1 - Y * comp); c1 = k * (Y + (1 + 0.3 * (1 - k)) * (c - Y))
    f = ycc(c1, g['inputFaceColorMatrixBlack'], g['inputFaceColorMatrixWhite'], g['inputFaceColorMatrixSaturation'], g.get('inputFaceColorMatrixFillColor'))
    fo = min(max(g.get('inputFaceOpacity', 1), 0), 1); f = c + (f - c) * fo
    bo = min(max(g.get('inputBleedOpacity', 0), 0), 1)
    if bo > 0:
        b = ycc(s, g.get('inputBleedColorMatrixBlack', 0), g.get('inputBleedColorMatrixWhite', 1), g.get('inputBleedColorMatrixSaturation', 1))
        Yf = sat(f @ WB); fac = Yf if g.get('inputBleedDarkenBlend') else 1 - Yf
        f = f + (b - f) * fac ** 4 * bo
    cl = g.get('inputClamp', 0)
    return np.clip(f, -0.75, cl if cl > 0 else 9)

# ---------------------------------------------------------------- (1) sidebar: CAChameleonLayer on top of the backdrop
# Sidebar glass (NSGlassEffectView _variant 17 and 18) has one more layer than regular glass, directly above the
# glassBackground CABackdropLayer and below the rim highlight:
#   CAChameleonLayer, compositingFilter "colorBlendMode", opacity 0.10 (dark) / 0.05 (light), any slider value.
# A CAChameleonLayer is a solid fill with the render context's "chameleon colour"; WindowServer sets it to the
# average wallpaper colour under the window frame (CGXWindow::resolved_chameleon_color -> DesktopEffectsGetAverageColor
# -> Payload::average_color: box mean of the encoded wallpaper over the window rect, each channel quantised to 6 bits).
CHAMELEON_OPACITY = {'dark': 0.10, 'light': 0.05}

def _clip_color(c):
    L = c @ WLUM; n = c.min(); x = c.max()
    if n < 0: c = L + (c - L) * L / (L - n)
    if x > 1: c = L + (c - L) * (1 - L) / (x - L)
    return c

def color_blend(dst, src):
    """PDF / CSS "color" blend: hue and saturation of src, luminosity of dst. Lum = .3 R + .59 G + .11 B."""
    return _clip_color(src + (dst @ WLUM - src @ WLUM))

def chameleon(f, cham, mode='dark', opacity=None):
    """f: glass output (extended range), cham: chameleon colour 0..1. The backdrop is clamped to 0..1 first."""
    op = CHAMELEON_OPACITY[mode] if opacity is None else opacity
    d = sat(np.asarray(f, float)); return d + (color_blend(d, np.asarray(cham, float)) - d) * op

def chameleon_color(wallpaper_rgb_under_window, bits=6):
    """wallpaper pixels (N x 3, encoded 0..1) under the window frame -> the colour WindowServer hands out."""
    m = np.clip(np.asarray(wallpaper_rgb_under_window, float).reshape(-1, 3).mean(0), 0, 1); n = 1 << bits
    return np.minimum(np.trunc(m * n), n - 1) / (n - 1)

def model(c, g, mode='dark', cham=None, s=None):
    """Centre colour (0..255) of glass over a uniform backdrop c (0..255). cham (0..255) only for sidebar glass."""
    f = face(np.array(c, float) / 255, g, None if s is None else np.array(s, float) / 255)
    if cham is not None: return chameleon(f, np.array(cham, float) / 255, mode) * 255
    return np.clip(f, 0, 1) * 255

# ---------------------------------------------------------------- (2) blur
# The backdrop is captured at CABackdropLayer.scale s (box average of 1/s x 1/s screen pixels -> texture T0, read
# back with bilinear filtering). CA builds a mip pyramid with its variable-blur downsampler: level i+1 is level i
# filtered by 13 bilinear taps and decimated by 2:
#   centre .105497; (+-a, 0), (0, +-a) .090186; (+-a, +-a) .077098; (+-b, 0), (0, +-b) .056341; a = 1.960085, b = 3.920676
#   (offsets in texels of level i, measured from the centre of the destination texel).
# The shader reads one trilinear sample at level lod(R), R = 1.6 * radius[pt] * (texels of T0 per pt):
#   lod(R) = max(0, log2(R < 2 ? R / 2 + 1 : R))
# If the smallest blur radius of the backdrop group gives R >= 2, the pyramid is stored from level 1 up (half size)
# and the shader gets R / 2:  level = 1 + lod(R / 2)   (only differs from lod(R) for 2 <= R < 4).
K_W0, K_W1, K_W2, K_W3, K_A, K_B = 0.105497, 0.090186, 0.077098, 0.056341, 1.960085, 3.920676
TAPS_1D = [(0.0, K_W0 + 2 * K_W1 + 2 * K_W3), (K_A, K_W1 + 2 * K_W2), (-K_A, K_W1 + 2 * K_W2), (K_B, K_W3), (-K_B, K_W3)]
TAPS_2D = [(0, 0, K_W0)] + [(x * K_A, y * K_A, K_W1) for x, y in ((1, 0), (-1, 0), (0, 1), (0, -1))] + \
          [(x * K_A, y * K_A, K_W2) for x in (1, -1) for y in (1, -1)] + [(x * K_B, y * K_B, K_W3) for x, y in ((1, 0), (-1, 0), (0, 1), (0, -1))]

def lod(R): return max(0.0, math.log2(R * 0.5 + 1 if R < 2 else R))
def level(radius_pt, scale, px_per_pt=2, half_base=None):
    """Mip level sampled for a filter radius (inputBlurRadius * BlurOpacity, or inputBlurFillBlurRadius)."""
    R = 1.6 * radius_pt * px_per_pt * scale
    if half_base is None: half_base = R > 2.0001      # R == 2 exactly stays plain (measured)
    return 1 + lod(R / 2) if (half_base and R > 2.0001) else lod(R)

def sigma_pt(radius_pt):
    """Gaussian equivalent of the blur, in points: sigma = 2.0 * radius (erf fit of the measured edge response,
    radius >= 3: 1.93 .. 2.04). The DesignLibrary spec radius is 2 * filter radius, so sigma ~ spec radius."""
    return 2.0 * radius_pt

def _bil(M, u):
    x = np.clip(u - 0.5, 0, len(M) - 1); i = np.minimum(np.floor(x).astype(int), len(M) - 2); f = x - i
    return M[i] * (1 - f) + M[i + 1] * f
def _down(M):
    u = 2 * np.arange(len(M) // 2) + 1.0
    return sum(w * _bil(M, u + o) for o, w in TAPS_1D)

class Pyramid1D:
    """1-D slice (pattern constant along the other axis). screen: px values; phi: px offset of the T0 grid."""
    def __init__(self, screen, scale, phi=0, nlev=8):
        q = int(round(1 / scale)); pad = (-phi) % q; self.q = q
        scr = np.concatenate([np.full(pad + q * 256, screen[0]), screen, np.full(q * 257, screen[-1])])
        n = len(scr) // q; self.T = [scr[:n * q].reshape(n, q).mean(1)]
        for _ in range(nlev): self.T.append(_down(self.T[-1]))
        self.u0 = (np.arange(len(screen)) + 0.5 + pad + q * 256) / q
    def sample(self, lev, shift_texels=0.0):
        l0 = min(int(math.floor(lev)), len(self.T) - 2); f = lev - l0; u = self.u0 + shift_texels
        a = _bil(self.T[l0], u / 2 ** l0)
        return a if f <= 0 else a * (1 - f) + f * _bil(self.T[l0 + 1], u / 2 ** (l0 + 1))

def blur_opacity(g, d):
    """BlurOpacity0..3 interpolated over BlurDistance0..3; d = signed distance (negative inside)."""
    D = [g['inputBlurDistance%d' % i] for i in range(4)]; O = [g['inputBlurOpacity%d' % i] for i in range(4)]
    op = O[0]
    for i in range(3):
        den = D[i + 1] - D[i]
        t = (1.0 if d >= D[i + 1] else 0.0) if den == 0 else min(max((d - D[i]) / den, 0), 1)
        op += (O[i + 1] - O[i]) * t
    return op

def backdrop_1d(screen, g, scale, depth, px_per_pt=2, phi=0, half_base=False):
    """Grey backdrop as the face sees it along a line at a given depth (pt) far from the refracting rim.
    Returns (c, s): c = blur then blur fill (input of the face), s = the edge-bleed sample, which is blurred with
    radius 0.5 * inputBleedBlurRadius (DesignLibrary sets inputBleedBlurRadius = BleedAmount = 0.35 * D when the
    bleed is on). half_base: see level(); stock recipes fit with False (their smallest blur stop gives R < 2)."""
    P = Pyramid1D(np.asarray(screen, float), scale, phi)
    r = g['inputBlurRadius'] * blur_opacity(g, -depth)
    rf = g.get('inputBlurFillBlurRadius', 0)
    N, dk, lt = (min(max(g.get(k, 0), 0), 1) for k in ('inputBlurFillNormalOpacity', 'inputBlurFillDarkenOpacity', 'inputBlurFillLightenOpacity'))
    if lt + dk > 1: lt, dk = lt / (lt + dk), dk / (lt + dk)
    top = len(P.T) - 1.01
    c = P.sample(min(level(r, scale, px_per_pt, half_base), top))
    if N > 0 or dk > 0 or lt > 0:
        Lf = level(rf, scale, px_per_pt, half_base)
        # two taps at -+ L/4 texels of the stored base level (L = the shader's own lod), diagonal; here along x, in T0 texels
        hb = half_base and 1.6 * rf * px_per_pt * scale > 2.0001
        off = (Lf - 1 if hb else Lf) * 0.25 * (2 if hb else 1)
        B = 0.5 * (P.sample(Lf, -off) + P.sample(Lf, off))
        m = lt * np.maximum(c, B) + dk * np.minimum(c, B) + (1 - lt - dk) * c
        c = m + (B - m) * N
    rb = 0.5 * g.get('inputBleedBlurRadius', 100.0) if g.get('inputBleedOpacity', 1) > 0 else 0.0   # get_glass_filter_bleed_blur_radius 0x18de1a408
    return c, P.sample(min(level(rb, scale, px_per_pt, half_base), top))

def profile_1d(screen, g, scale, depth, mode='dark', cham=None, **kw):
    """Display values 0..255 (N x 3) of grey glass along a line over a 1-D grey scene (screen 0..1)."""
    c, s = backdrop_1d(screen, g, scale, depth, **kw)
    out = np.array([face(np.array([v] * 3), g, np.array([w] * 3)) for v, w in zip(c, s)])
    out = np.array([chameleon(o, np.array(cham, float) / 255, mode) for o in out]) if cham is not None else np.clip(out, 0, 1)
    return out * 255
