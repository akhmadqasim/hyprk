#!/usr/bin/env python3
"""Show the scale macOS 27.2 would pick for each monitor (same rule as config/hypr/scale-policy.lua).

  scripts/scale-policy.py                    # every monitor from `hyprctl monitors -j`
  scripts/scale-policy.py 3840x2160 597x336  # any panel: native pixels, physical mm
  scripts/scale-policy.py --check            # built-in cases
  scripts/scale-policy.py --compare REPORT [OUT=WxHmm ...]   # check a live report() JSON against this mirror

The Lua module is what Hyprland runs; keep decide(), valid_scale() and choices() identical to it.
Evidence: liquid-glass-re SPEC.md section 14 "Display scaling".
"""
import json
import math
import subprocess
import sys


def decide(w, h, mmw=0, mmh=0):
    long_side, short_side = max(w, h), min(w, h)
    diag_mm = math.hypot(mmw, mmh) if mmw > 0 and mmh > 0 else None
    ppi = math.hypot(w, h) / (diag_mm / 25.4) if diag_mm else None
    if long_side >= 3840 and short_side >= 2160:
        hidpi, reason = True, "native >= 3840x2160"
    elif long_side > 3799 and diag_mm and diag_mm < 812.8 and w >= 2048 and h >= 1536 and ppi > 160:
        hidpi, reason = True, 'long side > 3799, < 32", > 160 ppi'
    else:
        hidpi, reason = False, f"{ppi:.0f} ppi, below the HiDPI rule" if ppi else "no HiDPI rule matched"
    scale = 2 if hidpi else 1
    return {"scale": scale, "looks_like": f"{w // scale}x{h // scale}", "ppi": ppi, "diag_mm": diag_mm, "reason": reason}


def valid_scale(w, h, s):
    """Hyprland needs w/s and h/s whole; snap to 1/120 steps (wp_fractional_scale_v1). None if not clean."""
    s = math.floor(s * 120 + 0.5) / 120
    lw, lh = w / s, h / s
    if abs(lw - math.floor(lw + 0.5)) < 0.01 and abs(lh - math.floor(lh + 0.5)) < 0.01:
        return s
    return None


# Framebuffer sizes from CoreDisplay IOGraphicsProperties.plist (SPEC 14.2 step 2), same as the Lua module
FB_WIDTHS = [640, 800, 1024, 1280, 1344, 1600, 1920, 2048]
FB_FIXED = [(1280, 720), (1440, 900), (1680, 1050), (1920, 1080), (1920, 1200), (2560, 1440), (2560, 1600)]
FB_WIDTHS_4K = [2048, 2304, 2560, 3008, 3200, 3360, 3840, 4096, 4608, 5120, 6016, 6400, 6720]


def choices(w, h, mmw=0, mmh=0):
    """Looks-like sizes Settings > Displays offers (Lua M.choices): [(w, h, scale, is_default)] by width."""
    d = decide(w, h, mmw, mmh)
    dw, dh = (int(x) for x in d["looks_like"].split("x"))
    aspect = w / h
    out = {}

    def add(lw, lh):
        if lw < 640 or lh < 1 or abs(lw / lh - aspect) > 0.01 or (lw, lh) in out:
            return
        s = valid_scale(w, h, w / lw)
        if s is None or math.floor(w / s + 0.5) != lw or math.floor(h / s + 0.5) != lh:
            return
        out[(lw, lh)] = (lw, lh, s, (lw, lh) == (dw, dh))

    if d["scale"] == 2:
        for fw in FB_WIDTHS_4K if max(w, h) >= 3840 else [1600, 1920, 2048]:
            fh = h * fw // w
            if max(fw, fh) >= 1440 and min(fw, fh) >= 900 and fh % 2 == 0 and fw % 2 == 0:
                add(fw // 2, fh // 2)
        add(w // 2, h // 2)
        if d["ppi"] is None or d["ppi"] < 300:
            add(w, h)
    else:
        for fw in FB_WIDTHS:
            add(fw, h * fw // w)
        for fw, fh in FB_FIXED:
            add(fw, fh)
        add(w, h)
        out = {k: v for k, v in out.items() if v[0] <= w and v[1] <= h}
    return sorted(out.values(), key=lambda c: c[0])


def size(text):
    a, b = text.lower().split("x")
    return int(a), int(b)


def show(name, w, h, mmw, mmh):
    d = decide(w, h, mmw, mmh)
    diag = f'{d["diag_mm"] / 25.4:.1f}"' if d["diag_mm"] else "?"
    print(f"{name:10} {w}x{h} {mmw}x{mmh} mm ({diag}) -> scale {d['scale']}, looks like {d['looks_like']} ({d['reason']})")
    print(" " * 11 + "choices: " + ", ".join(f"{c[0]}x{c[1]}{'*' if c[3] else ''}" for c in choices(w, h, mmw, mmh)))


CASES = [  # (w, h, mm w, mm h, expected scale)
    (3840, 2160, 597, 336, 2),   # 27" 4K
    (1920, 1080, 598, 336, 1),   # 27" 1080p
    (2560, 1440, 597, 336, 1),   # 27" 1440p (109 ppi)
    (3840, 2160, 698, 393, 2),   # 32" 4K: the 4K rule ignores size
    (5120, 2880, 597, 336, 2),   # 27" 5K
    (3440, 1440, 800, 335, 1),   # 34" ultrawide
    (3840, 1600, 880, 367, 1),   # 38" ultrawide, 110 ppi
    (2160, 3840, 336, 597, 2),   # 27" 4K portrait
]


# (w, h, mm w, mm h, expected looks-like sizes, * = Default). Source per case in the comment.
CHOICE_CASES = [
    # SPEC 14.4 list for 27" 4K minus the sizes without a clean Hyprland scale (1504x846, 1680x945, 3008x1692,
    # 3360x1890), plus the 1x native mode (163 ppi < DisplayDPICutoff 300)
    (3840, 2160, 597, 336, "1024x576 1152x648 1280x720 1600x900 1920x1080* 2048x1152 2304x1296 2560x1440 3200x1800 3840x2160"),
    # 27" 5K: same framebuffer list (SPEC 14.2), default 2560x1440 (SPEC 14.4 table); 1152 and 2304 wide have no
    # clean scale on 5120, 1920x1080 does (8/3)
    (5120, 2880, 597, 336, "1024x576 1280x720 1600x900 1920x1080 2048x1152 2560x1440* 3200x1800 5120x2880"),
    # 27" 1080p: 1x list from scale-resolutions <= native (SPEC 14.2/14.5); 1344x756 has no clean scale
    (1920, 1080, 598, 336, "640x360 800x450 1024x576 1280x720 1600x900 1920x1080*"),
    # 27" 1440p, 1x
    (2560, 1440, 597, 336, "640x360 800x450 1024x576 1280x720 1600x900 1920x1080 2048x1152 2560x1440*"),
    # 16:10 1x panel: the fixed 1440x900 entry joins the native-aspect widths (1680x1050 has no clean scale)
    (1920, 1200, 518, 324, "640x400 800x500 1024x640 1280x800 1440x900 1600x1000 1920x1200*"),
    # 34" ultrawide (21:9): no scale-resolutions width keeps a clean scale, only native
    (3440, 1440, 800, 335, "3440x1440*"),
]


def main(argv):
    if argv[:1] == ["--check"]:
        bad = [c for c in CASES if decide(*c[:4])["scale"] != c[4]]
        for c in CASES:
            show("case", *c[:4])
        for c in CHOICE_CASES:
            got = " ".join(f"{x[0]}x{x[1]}{'*' if x[3] else ''}" for x in choices(*c[:4]))
            if got != c[4]:
                bad.append((c[:4], "choices", got))
        for w, h, s in [(3840, 2160, 1.5), (3840, 2160, 3840 / 1152), (1920, 1080, 1.25)]:
            if valid_scale(w, h, s) is None:
                bad.append((w, h, s, "valid_scale"))
        if valid_scale(3840, 2160, 3840 / 1504) is not None:
            bad.append((3840, 2160, "1504 should have no clean scale"))
        print("FAIL" if bad else "ok", bad or "")
        return 1 if bad else 0
    if argv[:1] == ["--compare"]:
        # report() JSON from Lua, e.g. hyprctl eval 'dofile("<root>/config/hypr/scale-policy.lua").report("/tmp/r.json")';
        # outputs without an EDID size take OUT=WxH (mm) like HYPRK_PHYS_MM_<OUT>
        with open(argv[1]) as f:
            rep = json.load(f)
        mm = dict(a.split("=") for a in argv[2:])
        bad = 0
        for o in rep["outputs"]:
            if o["virtual"]:
                print(o["name"], "virtual, skipped")
                continue
            w, h = o["native"]
            mmw, mmh = size(mm[o["name"]]) if o["name"] in mm else (0, 0)
            want = [[c[0], c[1], round(c[2], 4), c[3]] for c in choices(w, h, mmw, mmh)]
            got = [[c["w"], c["h"], round(c["scale"], 4), c["default"]] for c in o["choices"]]
            bad += want != got
            print(o["name"], "same" if want == got else f"DIFF lua={got} py={want}")
        return 1 if bad else 0
    if len(argv) >= 1:
        w, h = size(argv[0])
        mmw, mmh = size(argv[1]) if len(argv) > 1 else (0, 0)
        show("panel", w, h, mmw, mmh)
        return 0
    mons = json.loads(subprocess.run(["hyprctl", "monitors", "-j"], capture_output=True, text=True, check=True).stdout)
    for m in mons:
        # native = preferred mode isn't in monitors -j; the current mode is the best we have here
        show(m["name"], m["width"], m["height"], m.get("physicalWidth", 0), m.get("physicalHeight", 0))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
