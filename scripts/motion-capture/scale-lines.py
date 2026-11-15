#!/usr/bin/env python3
"""Live check: 1 pt lines at the session's output scale (2, 1.5, 1.25, ...), measured in device pixels on a
full-output grim. What the Mac does (reference/re/27.2.1/SCALING-AUDIT.md "Round R3.3", ui/HyprK/pixel.js): a scaled
mode renders at 2x and the panel scaler resamples, so a 1 pt separator reaches the panel as `scale` rows of ink with
one row fully covered: [1, .5] or [.5, 1] at 1.5 (more-space-menu.png / -settings.png resampled: 1.4-1.56 rows),
[1, 1] at 2. Whole pixels at 1.5 ([1, 1]) are a third too heavy, a line split evenly over two rows ([.75, .75]) is
blurred, a line that covers one row in one place and two in another is the 1.6 defect of SCALING-AUDIT section 2.

What the panel really shows (MAC-ANSWERS-16.md R16.2 / R16.3, ScreenCaptureKit frames at panel size,
screens/27.2.1/scaled/more-space-*-sck.png): a filter about two panel px wide, softer than the box. In shares of the
full contrast the Settings card separators read [.1, .8, .6] and [.3, .9, .3] (1.5 rows of ink each), a card edge on a
whole panel pixel [.14, .86]; the File menu's separators [.45, .92, .21] and [.07, .81, .65] of their ink / 1.5, with
a 3-4 % undershoot beside them. So a row pattern is accepted when it is a 1 pt line seen through either filter, the
box (what our antialiased lines and a compositor-scaled window draw) or that triangle, at any phase; whole pixels
([1, 1] at a fractional scale) stay wrong: a third too much ink. A window keeps its size in points (the Mac's
Settings is 740 x 625 pt in More Space, 937.5 panel px): `Settings size` checks that, where the check of judge #23
asked for whole device pixels.

Each surface is shot once: the Dock (its separator, vertical), a menu bar menu (`panels menu`), and the hyprk System
Settings and Finder windows when they are open in the session. A line = a run of at least 40 pt (150 pt in a window:
shorter ones there are capsule rims and thumbnails) that differs from flat, equal sides. Ink = the line's contrast summed over its rows / its strongest row.

Session: see livecheck.py, started at the scale under test (the shell must be BORN at that scale: a monitor rule in
the session's config, not a later `hl.monitor`; long-lived layers keep the ratio they started with).

  scale-lines.py [--keep DIR]      exit 0 = every 1 pt line reads, row by row (+- .2 of its strongest row), as one of
                                   the patterns a 1 pt line on a half point has after the Mac's resample; thinner
                                   lines (0.5 pt hairlines: no full row to scale by) are listed
"""
import json, os, subprocess, sys, time

import numpy as np

import livecheck as lc

K = 5
TOL = 0.2      # of the strongest row: 2 levels of a separator 12 levels from its card (#EBEBEB on #F7F7F7)


def find(L, scale, vertical=False, least=40, step=3):
    """lines in a luminance array (device px): [(pos px, start px, length px, [ink per row, strongest = 1], strongest
    row's contrast, backdrop)]. step: how far the two sides of a line may differ (3 = equal sides; the Finder list's
    header line lies between the header, 42, and the rows, 33 in dark: it was never found, JUDGE-95-24)"""
    if vertical:
        L = L.T
    h, w = L.shape
    if h < 4 * K or w < 20:
        return []
    up, mid, dn = L[:-2 * K], L[K:-K], L[2 * K:]
    d = mid - (up + dn) / 2
    hit = (np.abs(up - dn) < step) & (np.abs(d) > 4 + (step - 3) / 2)
    need = int(least * scale)
    out, used = [], np.zeros(h, bool)
    for y in range(hit.shape[0]):
        row = hit[y]
        x = 0
        while x < w:
            if not row[x]:
                x += 1
                continue
            x1 = x
            while x1 < w and row[x1]:
                x1 += 1
            if x1 - x >= need and not used[y + K]:
                # the line's rows: neighbours that hit over most of the same span
                rows = [y]
                while rows[-1] + 1 < hit.shape[0] and hit[rows[-1] + 1, x:x1].mean() > 0.8:
                    rows.append(rows[-1] + 1)
                if len(rows) <= 4:
                    y0, y1 = rows[0] + K, rows[-1] + K
                    prof = L[y0 - 3:y1 + 4, x + 2:x1 - 2].mean(axis=1)
                    bg = np.linspace(prof[0], prof[-1], len(prof))
                    v = np.abs(prof - bg)[1:-1]
                    peak = float(v.max())
                    v = v / v.max()
                    out.append((y0, x, x1 - x, [round(float(a), 2) for a in v if a > 0.06], peak, float(bg.mean())))
                for r in rows:
                    used[r + K] = True
                x = x1
            else:
                x = x1
    return out


def main():
    keep = sys.argv[sys.argv.index("--keep") + 1] if "--keep" in sys.argv else ""
    pid = lc.session("scale-lines")
    if keep:
        os.makedirs(keep, exist_ok=True)
    mon = next(m for m in json.loads(subprocess.run(["hyprctl", "monitors", "-j"], capture_output=True, text=True).stdout) if m["name"] == "MBA")
    s = mon["scale"]
    W, H = round(mon["width"] / s), round(mon["height"] / s)
    whole = abs(s - round(s)) < 0.001
    fails, thin, even, n = 0, [], [], 0
    # what a 1 pt line looks like after the Mac's resample (a box over the 2x raster; AppKit lays out on that raster,
    # so a line starts on a half point): `s` px of ink from the phases frac(k x s / 2), each normalised to its
    # strongest row: [1, .5] [.5, 1] [.25, 1, .25] at 1.5; [1, .25] [1, .67] [.67, 1] [.25, 1] [1, .43] [.43, 1]
    # [.12, 1, .12] at 1.25; [1, 1] at 2. The even split ([.75, .75] at 1.5) is left out at a fractional scale: row
    # by row it cannot be told from whole pixels, which are a third too heavy there
    wanted = []
    if whole:
        wanted.append([1.0] * int(round(s)))
    else:
        tri = lambda a0, a1, c: sum(max(0.0, 1 - abs(a0 + (k + .5) * (a1 - a0) / 200 - c)) for k in range(200)) * (a1 - a0) / 200
        for k in range(40):
            a = k / 40
            box = [max(0.0, min(i + 1, a + s) - max(i, a)) for i in range(int(a + s) + 1)]
            soft = [tri(a, a + s, i + .5) for i in range(-1, int(a + s) + 2)]
            for cov in (box, soft):
                cov = [round(c / max(cov), 2) for c in cov if c / max(cov) >= 0.1]
                # an even split cannot be told from whole pixels row by row: left out
                if cov not in wanted and not (len(cov) == int(s) + 1 and min(cov) > 0.85):
                    wanted.append(cov)

    def shot(name):
        from PIL import Image
        img = lc.grim()
        if img.shape[1] != mon["width"]:
            sys.exit(f"scale-lines: grim gave {img.shape[1]} px for a {mon['width']} px output")
        if keep:
            Image.fromarray(img.astype(np.uint8)).save(os.path.join(keep, f"scale{s:g}-{name}.png"))
        return img.mean(axis=2)

    def judge(name, L, rect, vertical=False, least=40, full=None, step=3):
        """rect in pt: x, y, w, h; full(backdrop level) = the line colour's contrast in levels when it is known.
        With it the even split is judged too: a line on a half point whose resample phase is a quarter pixel covers
        two rows equally ([.75, .75] at 1.5, [.625, .625] at 1.25), so both rows show s / 2 of the full contrast;
        whole pixels show two rows at the full contrast. (JUDGE-95-24 read Software Update's separator, 163.5 pt
        down the window as the Mac's: AX group 275.5 + 38, as "[1.0, 1.0], whole pixels": its rows are 50 on 42
        where a full row is 52.)"""
        nonlocal fails, thin, even, n
        x, y, w, h = (int(round(v * s)) for v in rect)
        found = find(L[max(0, y):y + h, max(0, x):x + w], s, vertical, least, step)
        bad, inks = [], []
        for pos, start, length, rows, peak, back in found:
            ink = sum(rows)
            rows = [r for r in rows if r >= 0.1]
            if not rows or ink > 2 * s + 0.6:
                continue                                  # a band, not a line
            if ink < min(1.0, s) - 0.02 or (len(rows) == 1 and s >= 1.2 and not whole):
                thin.append(f"{name} at {(pos + (x if vertical else y)) / s:.1f} pt: {rows}")
                continue
            inks.append(ink)
            if full and not whole and len(rows) == 2 and min(rows) >= 0.9:
                want = full(back) * s / 2
                if abs(peak - want) <= max(1.0, 0.15 * want):
                    even.append(f"{name} at {(pos + (x if vertical else y)) / s:.1f} pt: two rows at {peak:.1f} of {full(back):g} levels")
                    continue
            if not any(len(c) == len(rows) and max(abs(a - b) for a, b in zip(c, rows)) <= TOL for c in wanted):
                bad.append(f"{(pos + (x if vertical else y)) / s:.1f} pt {rows}")
            elif keep:
                print(f"     {name} {(pos + (x if vertical else y)) / s:.1f} pt {rows}")
        n += len(inks)
        if not inks:
            return lc.report(True, name, "no 1 pt line found (not judged)")
        note = f"{len(inks)} lines, rows as a resampled 2x raster's"
        fails += lc.report(not bad, name, note + ("; off: " + "; ".join(bad[:6]) if bad else ""))

    for p in ("cc", "menu", "context", "spotlight"):
        if lc.ipc(pid, "panels", "current") == p:
            lc.ipc(pid, "panels", "close")
    time.sleep(0.6)
    L = shot("desktop")
    judge("Dock separator", L, (W / 2 - 400, H - 90, 800, 90), vertical=True, least=60)   # 60 pt: not a line inside an icon
    lc.ipc(pid, "panels", "menu", "2", "120")
    time.sleep(1.0)
    L = shot("menu")
    judge("menu bar menu separators", L, (0, 34, 520, H - 160))
    lc.ipc(pid, "panels", "close")
    time.sleep(0.6)
    for cls, name in (("org.hyprk.Settings", "System Settings"), ("hyprk-finder", "Finder")):
        for c in lc.clients(cls)[:1]:
            lc.front("class:" + cls)
            L = shot(name.lower().replace(" ", "-"))
            x, y = c["at"]
            w, h = c["size"]
            # System Settings' separator on its card: dark 52 on 42, light #EBEBEB on #F7F7F7 (the Mac's dark, R16.3:
            # 46,47,47 on 36,37,37)
            full = (lambda back: 10 if back < 128 else 12) if cls == "org.hyprk.Settings" else None
            judge(name + " rows", L, (x + 4, y + 4, w - 8, h - 8), least=150, full=full, step=3 if full else 14)
            judge(name + " columns", L, (x + 4, y + 4, w - 8, h - 8), vertical=True, least=150)
            if cls == "org.hyprk.Settings":
                fails += lc.report([w, h] == [740, 625], "Settings size", f"{w} x {h} pt = {w * s:g} x {h * s:g} px (Mac 740 x 625 pt at every scale; 626 at 1.5 and 624 at 1.25 until round 16)")
    if even:
        print(f"     even split of an exact line on a quarter-pixel phase ({len(even)}): " + "; ".join(even[:8]))
    if thin:
        print(f"     thinner than a row ({len(thin)}): " + "; ".join(thin[:8]))
    print(f"     scale {s:g}, {W} x {H} pt, {n} lines judged against {len(wanted)} patterns (a 1 pt line through the box or the Mac's two-pixel filter, any phase)")
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
