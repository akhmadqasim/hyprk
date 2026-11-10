#!/usr/bin/env python3
"""Show the scale macOS 27.2 would pick for each monitor (same rule as config/hypr/scale-policy.lua).

  scripts/scale-policy.py                    # every monitor from `hyprctl monitors -j`
  scripts/scale-policy.py 3840x2160 597x336  # any panel: native pixels, physical mm
  scripts/scale-policy.py --check            # built-in cases

The Lua module is what Hyprland runs; keep the two rules identical. Evidence: liquid-glass-re SPEC.md section 10.
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


def size(text):
    a, b = text.lower().split("x")
    return int(a), int(b)


def show(name, w, h, mmw, mmh):
    d = decide(w, h, mmw, mmh)
    diag = f'{d["diag_mm"] / 25.4:.1f}"' if d["diag_mm"] else "?"
    print(f"{name:10} {w}x{h} {mmw}x{mmh} mm ({diag}) -> scale {d['scale']}, looks like {d['looks_like']} ({d['reason']})")


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


def main(argv):
    if argv[:1] == ["--check"]:
        bad = [c for c in CASES if decide(*c[:4])["scale"] != c[4]]
        for c in CASES:
            show("case", *c[:4])
        print("FAIL" if bad else "ok", bad or "")
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
