# Apple's Liquid Glass model (macOS 27.2.1), as verified by the Mac (reference/re/MAC-ANSWERS.md "Verification of motion
# and glass claims (PC #67)" B and C, "C2. Remaining glass items"; code in reference/re/27.2.1/decomp/
# DesignLibrary-diffusion-amount.c, QuartzCore-glassBackground-shader.c, QuartzCore-glass-shaders.c).
#
# inputs(material, D, a, dark) gives the glassBackground filter inputs DesignLibrary resolves for a shape whose shortest
# side is D pt at Liquid Glass slider value a (NSGlassTintAmount, 0..1, default 0.5). check_model.py first checks this
# function against every filter dump the Mac took (live/verify/C, C2), so it only stands in for Apple where it equals
# the dumps. The face colour itself is glass_model.py (the Mac's model, imported unchanged).
import math

MATERIALS = ["regular", "menu", "notificationcenter", "clear", "dock", "controlcenter"]
# names in the Mac's dumps
APPLE_NAME = {"regular": "regular", "menu": "regular.menu", "notificationcenter": "notificationCenter", "clear": "clear",
              "dock": "dock", "controlcenter": "controlCenter"}


def clamp(x, lo=0.0, hi=1.0):
    return min(max(x, lo), hi)


def lerp(a, b, t):
    return a + (b - a) * t


def inputs(material, D, a, dark):
    u, t = clamp(2 * a), clamp(2 * a - 1)
    q = clamp((D - 64) / 96)
    s = clamp((D - 64) / 40)
    g = {}
    regular = material in ("regular", "menu", "notificationcenter")
    if regular:
        # RegularBase.Base (0x195f20248)
        g.update(InnerRefractionAmount=max(-0.5 * D, -60), InnerRefractionHeight=min(0.25 * D, 20),
                 OuterRefractionAmount=max(0.25 * D, 16), OuterRefractionHeight=max(0.2 * D, 16), RefractionOpacity=0.6,
                 BlurRadius=5, BlurOpacity0=0.8 * q, BlurOpacity1=0.4 * q, BlurOpacity2=0.5, BlurDistance0=-0.5 * D,
                 BleedOpacity=(0.8 if dark else 0.5) * q, BleedAmount=0.35 * D, BleedHeight=0.35 * D,
                 BleedColorMatrixBlack=0.125 if dark else 0.9, BleedColorMatrixWhite=0.5 if dark else 1,
                 BleedColorMatrixSaturation=1 if dark else 1.2, BleedDarkenBlend=not dark,
                 KeyFillHighlightColorBias=-0.25, KeyFillHighlightSpreadDeg=75 if dark else 106,
                 RingShadowOpacity=0.06)
        if dark:
            g.update(FaceColorMatrixBlack=0.125, FaceColorMatrixWhite=1.125, FaceColorMatrixSaturation=1.3, Fill=[0, 0, 0, 0],
                     BlurFillLightenOpacity=0, BlurFillDarkenOpacity=0.9, MaxLuma=lerp(0.6, 0.35, s))
        else:
            g.update(FaceColorMatrixBlack=0.4, FaceColorMatrixWhite=1.03, FaceColorMatrixSaturation=1.2, Fill=[1, 1, 1, 0.2],
                     BlurFillLightenOpacity=0.9, BlurFillDarkenOpacity=0, MaxLuma=0.94)  # maxLumaSDR (MaxLuma 1)
        g["BlurFillNormalOpacity"] = 0.5
        if material == "menu":
            g.update(ShadowOpacity=0.8 if dark else 0.7, ShadowRadius=24, ShadowOffset=10)
        else:  # dark measured by size; light 0.04 at D <= 64 (dump), 0.4 above (LIVE-27.2.1.md, not in the dumps)
            g.update(ShadowOpacity=0.04 + (0.56 if dark else 0.36) * q, ShadowRadius=4 + 20 * q, ShadowOffset=8)
        # RegularDiffusionAmount (0x195f22ea0)
        if abs(a - 0.5) >= 0.00034526698:
            L, Dk, N = g["BlurFillLightenOpacity"], g["BlurFillDarkenOpacity"], g["BlurFillNormalOpacity"]
            k = g["FaceColorMatrixBlack"] if dark else 1.0
            f = g["Fill"]
            if a >= 0.5:
                g["BlurFillNormalOpacity"] = N * (1 - t) + t
                g["BlurFillLightenOpacity"] = L * (1 - t) + (0.9 if L > 0 else 0) * t
                g["BlurFillDarkenOpacity"] = Dk * (1 - t) + (0.9 if Dk > 0 else 0) * t
                g["Fill"] = [f[i] * (1 - t) + [k, k, k, 0.5][i] * t for i in range(4)]
            else:
                g["BlurFillNormalOpacity"] = N * u
                g["BlurFillLightenOpacity"] = L * (0.75 + 0.25 * u)
                g["BlurFillDarkenOpacity"] = Dk * (0.75 + 0.25 * u)
                g["Fill"] = [[k, k, k, 0][i] * (1 - u) + f[i] * u for i in range(4)]
                if dark:
                    g["MaxLuma"] = lerp(0.6, 0.45, s) * (1 - u) + g["MaxLuma"] * u
        return g

    # ClearSpec recipes
    r0 = {"clear": 0.75, "dock": 1.5, "controlcenter": 4}[material]
    g.update(BleedOpacity=0, ShadowOpacity=0, RingShadowOpacity=0, KeyFillHighlightColorBias=-0.3 if material == "controlcenter" else -0.25,
             KeyFillHighlightSpreadDeg=75, Fill=[0, 0, 0, 0], MaxLuma=1, BlurFillLightenOpacity=0, BlurFillDarkenOpacity=0,
             BlurFillNormalOpacity=0, BlurRadius=r0, BlurDistance0=-100 if material == "controlcenter" else -0.5 * D)
    if material == "clear":
        g.update(InnerRefractionAmount=max(-0.65 * D, -60), InnerRefractionHeight=min(0.36 * D, 20), OuterRefractionAmount=0.2 * D,
                 OuterRefractionHeight=0.125 * D, RefractionOpacity=0, FaceColorMatrixBlack=0.125, FaceColorMatrixWhite=1.08,
                 FaceColorMatrixSaturation=1.06, BlurOpacity0=1, BlurOpacity1=0.5, BlurOpacity2=0.5)
    elif material == "dock":
        g.update(InnerRefractionAmount=-0.18 * D, InnerRefractionHeight=0.08 * D, OuterRefractionAmount=0, OuterRefractionHeight=0,
                 RefractionOpacity=0.2, BlurOpacity0=1, BlurOpacity1=0.5, BlurOpacity2=0.5)
        if dark:
            g.update(FaceColorMatrixBlack=0.05, FaceColorMatrixWhite=0.92, FaceColorMatrixSaturation=1.25, Fill=[0, 0, 0, 0.02], MaxLuma=0.75)
        else:
            g.update(FaceColorMatrixBlack=0.15, FaceColorMatrixWhite=0.9, FaceColorMatrixSaturation=1.25)
    else:
        g.update(InnerRefractionAmount=max(-2 * D, -80), InnerRefractionHeight=min(0.225 * D, 25), OuterRefractionAmount=0.0714 * D,
                 OuterRefractionHeight=0.0357 * D, RefractionOpacity=0.1525, FaceColorMatrixBlack=0.125, FaceColorMatrixWhite=0.8,
                 FaceColorMatrixSaturation=1.2, BlurOpacity0=1, BlurOpacity1=0.1, BlurOpacity2=0.5)
    # ClearDiffusionAmount (0x195efeb9c)
    if a < 0.5:
        g["BlurRadius"] = r0 * 2 * a
    elif a > 0.5:
        g["BlurFillNormalOpacity"] = 2 * (a - 0.5)
    return g


def backdrop_scale(material, g):
    """GlassMaterialProvider.BackdropScalePerceptualEstimator (RegularBase recipes only; ClearSpec stays 0.5)"""
    if material not in ("regular", "menu", "notificationcenter"):
        return 0.5
    r = g["BlurRadius"] * g["BlurOpacity0"]
    fills = g["BlurFillLightenOpacity"] > 0 or g["BlurFillDarkenOpacity"] > 0 or g["BlurFillNormalOpacity"] > 0
    rf, N, F = (8 if fills else 0), g["BlurFillNormalOpacity"], g["Fill"][3]
    for sc in (0.125, 0.25, 0.5):
        if (1 - F) * (N * math.exp(-math.pi ** 2 * rf ** 2 * sc ** 2 / 4) + (1 - N) * math.exp(-math.pi ** 2 * r ** 2 * sc ** 2 / 4)) <= 0.05:
            return sc
    return 0.5


# dump keys (input prefix dropped) -> keys of inputs()
def from_dump(x):
    g = dict(x)
    g["Fill"] = g.get("FaceColorMatrixFillColor", [0, 0, 0, 0])
    g["MaxLuma"] = g.get("FaceColorMatrixMaxLumaSDR", g.get("FaceColorMatrixMaxLuma", 1))
    if "KeyFillHighlightSpreadSDR" in g:
        g["KeyFillHighlightSpreadDeg"] = math.degrees(g["KeyFillHighlightSpreadSDR"])
    if isinstance(g.get("ShadowOffset"), list):
        g["ShadowOffset"] = g["ShadowOffset"][1]
    return g
