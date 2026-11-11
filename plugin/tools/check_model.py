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
GRID_D = [20, 24, 32, 64, 96, 200, 500]
GRID_A = [0, 0.25, 0.5, 0.75, 1]
# inputs the plugin ports (the blur kernel and backdrop scale are the plugin's own, see plugin/README.md)
PORTED = ["InnerRefractionAmount", "InnerRefractionHeight", "OuterRefractionAmount", "OuterRefractionHeight", "RefractionOpacity",
          "BlurFillLightenOpacity", "BlurFillDarkenOpacity", "BlurFillNormalOpacity", "BackdropScale",
          "FaceColorMatrixBlack", "FaceColorMatrixWhite", "FaceColorMatrixSaturation", "Fill", "MaxLuma",
          "BleedOpacity", "BleedAmount", "BleedHeight", "BleedColorMatrixBlack", "BleedColorMatrixWhite", "BleedColorMatrixSaturation",
          "BleedDarkenBlend", "KeyFillHighlightColorBias", "KeyFillHighlightSpreadDeg", "ShadowOpacity", "ShadowRadius", "ShadowOffset",
          "RingShadowOpacity", "BlurRadiusRel"]
# measured on the real surfaces, so the plugin follows them instead of the AppKit probe (reasons in Material.cpp)
DEVIATIONS = {("dock", "InnerRefractionAmount"): "real Dock end caps fit Regular's geometry (MAC-ANSWERS PC #67 B notes)",
              ("dock", "InnerRefractionHeight"): "same",
              ("notificationcenter", "MaxLuma"): "real NC reads the column's D (minimumDistanceOfLargestArea), Mac PC #62 pixels"}
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
        v = k[0] + (k[1] - k[0]) * Y + k[2] * (dst - Y)
        out.append(float(np.clip(dst + m * (v - dst), 0, 1).mean() * 255))
    return out


# (label, material, dark, D, body colour, Mac rows from the edge): MAC-ANSWERS PC #67 B 1 (highlight layer alone over
# black), PC #62 1a (NC card top, dark, over black), Glass checks / Q-dock (Dock top rim over black, first px)
RIM_CASES = [("regular highlight alone over black", "regular", True, 64, [0, 0, 0], [56, 33, 11, 8, 6, 5, 4]),
             ("NC card top, dark, over black", "notificationcenter", True, 64, [35, 35, 35], [68, 53, 35]),
             ("Dock top, light, over black", "dock", False, 64, [38, 38, 38], [116]),
             ("Dock top, dark, over black", "dock", True, 64, [12, 12, 12], [104])]


def face_apple(c255, g):
    gi = {"inputFaceColorMatrixMaxLuma": g["MaxLuma"], "inputFaceColorMatrixBlack": g["FaceColorMatrixBlack"],
          "inputFaceColorMatrixWhite": g["FaceColorMatrixWhite"], "inputFaceColorMatrixSaturation": g["FaceColorMatrixSaturation"],
          "inputFaceColorMatrixFillColor": g["Fill"], "inputBleedOpacity": g["BleedOpacity"],
          "inputBleedColorMatrixBlack": g.get("BleedColorMatrixBlack", 0), "inputBleedColorMatrixWhite": g.get("BleedColorMatrixWhite", 1),
          "inputBleedColorMatrixSaturation": g.get("BleedColorMatrixSaturation", 1), "inputBleedDarkenBlend": g.get("BleedDarkenBlend", False)}
    return GM.model(c255, gi)


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
                    ref = A.inputs(mat, D, a, dark)
                    ref["BlurRadiusRel"] = ref["BlurRadius"] / A.inputs(mat, D, 0.5, dark)["BlurRadius"]
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
                    g = A.inputs(mat, D, a, dark)
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
    print("    (notificationcenter differs by its max luma deviation, see 2.)" if ("notificationcenter", "MaxLuma") in DEVIATIONS else "")

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
    if args.strict and (not ok or param_bad or face_bad or grid_bad or rim_bad):
        print("\nFAIL: reference %s, %d inputs differ, face off vs Mac: %s, vs model: %s, rim: %s" % ("ok" if ok else "differs", param_bad, face_bad, grid_bad, rim_bad))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
