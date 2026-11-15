#!/usr/bin/env python3
"""Live check: the dark side line of a Notification Center card and of a banner (the Regular glass's dark specular on
the straight part of a side), against the Mac's pixels over a flat backdrop:

  card    reference/screens/27.2.1/nc/stack-dark-{grey,white,black,blue}.png, rows 80..108, columns 18 / 19 and 708 / 709
  banner  reference/screens/27.2.1/panels/shadow-banner-{grey,white}-dark.png, rows 86..110, columns 768 / 769

Each case is the line pixel against the pixel just outside it, left and right. A side is straight only on a card of
three text lines (a two-line card is all corner: the line splits over two pixels there, which read 63-76), so the test
notifications have a two-line body.

Round 18 (MAC-ANSWERS-18.md R18.2, reference/re/27.2.1/live/r18/{banner,nc-card}-{dark,light}-{white,blue}.png): the
same notification as the Mac's (Script Editor, "Test" / "Test": a two-line card, 57 pt), dark and light, over white and
over pure blue (the Mac shows its (0,0,255) wallpaper as (0,0,245)). Such a card has no straight side, so the line is
read on the card's middle row and 3 pt above and below it, left and right, with the pixel outside it; the Mac's values
are read from the stills by the same code.

Session: see livecheck.py, no windows. HYPRK_STATE must be the session's scratch state (the wallpaper
is set through its wallpaper.json to flat pictures written to a temp dir, the appearance through appearance.json; both
files are put back at the end).

  nc-side-line.py [--keep DIR] [--only r18|straight]      exit 0 = every case passed
"""
import json, os, sys, tempfile, time

import numpy as np

import livecheck as lc

# backdrop: (rgb, Mac card outside / line, Mac banner outside / line or None)
CASES = [("grey", (127, 127, 127), ((99.5,) * 3, (44.5,) * 3), ((116.5,) * 3, (50,) * 3)),
         ("white", (255, 255, 255), ((200,) * 3, (70.4,) * 3), ((233.5,) * 3, (71.5,) * 3)),
         ("black", (0, 0, 0), ((0,) * 3, (0,) * 3), None),
         ("blue", (69, 83, 206), ((57, 65, 156), (20, 24, 86)), None)]
TOL = 4          # levels, line pixel
SYM = 3          # levels, the outside pixel left against right
R18 = os.path.join(lc.ROOT, "reference/re/27.2.1/live/r18")
R18_BACKDROPS = (("white", (255, 255, 255)), ("blue", (0, 0, 245)))
R18_TOL = 4      # levels per channel, the line pixel on the middle row
R18_TOL_OFF = 6  # ... 3 pt above and below it (the line leaves the pixel column there)
R18_TOL_OUT = 5  # the pixel outside the line


def side_rows(img, cols, step):
    """the rows of a card's side line: the longest run of rows where the darkest pixel of the column range is over 30
    levels (in any channel) under the pixel 4 px outside it and over 12 under the one 4 px inside; (first, last)"""
    seg = img[:, cols[0]:cols[1]].sum(axis=2)
    x = cols[0] + seg.argmin(axis=1)
    rows = np.arange(len(seg))
    at = lambda dx: img[rows, np.clip(x + dx, 0, img.shape[1] - 1)]
    on = ((at(4 * step) - at(0)).max(axis=1) > 30) & ((at(-4 * step) - at(0)).max(axis=1) > 12)
    best, run, end = 0, 0, 0
    for i, v in enumerate(on):
        run = run + 1 if v else 0
        if run > best:
            best, end = run, i
    if best < 6:
        raise StopIteration
    return end - best + 1, end


def middle(img, lx, rx, y0=0, y1=None):
    """a two-line card's side line: {side: [(outside rgb, line rgb) on the middle row, 6 px above, 6 px below]}; the
    line is the darkest column within the given 20 px ranges on the middle row of the side (rows y0 .. y1), the
    middle row then its darkest row"""
    out = {}
    for side, (x0, x1), step in (("left", lx, -1), ("right", rx, 1)):
        r0, r1 = side_rows(img[y0:y1], (x0, x1), step)
        mid = y0 + (r0 + r1) // 2
        x = x0 + int(img[mid, x0:x1].sum(axis=1).argmin())
        m = mid - 8 + int(img[mid - 8:mid + 9, x].sum(axis=1).argmin())      # the row where the line is darkest
        out[side] = [(tuple(img[r, x + step]), tuple(img[r, x])) for r in (m, m - 6, m + 6)]
    return out


def mac_r18(kind, mode, name):
    from PIL import Image
    a = np.asarray(Image.open(os.path.join(R18, f"{kind}-{mode}-{name}.png")).convert("RGB")).astype(int)
    return middle(a, (70, 90), (758, 778))


def r18(pid, tmp, keep, backdrop, appearance):
    """the round 18 cases; returns the number of failed ones"""
    from PIL import Image
    fails = 0
    try:
        for mode in ("dark", "light"):
            appearance(mode)
            for name, rgb in R18_BACKDROPS:
                backdrop("r18-" + name, rgb)
                lc.ipc(pid, "notifs", "clear")
                time.sleep(0.5)
                lc.ipc(pid, "notifs", "testApp", "Script Editor", "Test", "Test")
                time.sleep(2.0)
                shots = {"banner": lc.grim()}
                time.sleep(6.0)             # the banner leaves
                lc.ipc(pid, "panels", "toggle", "nc")
                time.sleep(2.5)
                shots["nc-card"] = lc.grim()
                lc.ipc(pid, "panels", "close")
                time.sleep(0.8)
                for kind, img in shots.items():
                    if keep:
                        Image.fromarray(img[0:500, 1700:2560].astype(np.uint8)).save(os.path.join(tmp, f"r18-{kind}-{mode}-{name}.png"))
                    mac = mac_r18(kind, mode, name)
                    try:
                        # the card: 16 pt from the right screen edge, 344 pt wide; under the menu bar (banner) or the
                        # panel's header (card)
                        ours = middle(img, (2560 - 32 - 689 - 12, 2560 - 32 - 689 + 8), (2560 - 32 - 9, 2560 - 32 + 11),
                                      *((60, 260) if kind == "banner" else (150, 300)))
                    except StopIteration:
                        fails += lc.report(False, f"r18 {kind} {mode} over {name}", "no card found")
                        continue
                    ok, notes = True, []
                    for side in ("left", "right"):
                        for i, tol in enumerate((R18_TOL, R18_TOL_OFF, R18_TOL_OFF)):
                            (oo, ol), (mo, ml) = ours[side][i], mac[side][i]
                            ok = ok and np.abs(np.array(ol) - ml).max() <= tol and np.abs(np.array(oo) - mo).max() <= R18_TOL_OUT
                        (oo, ol), (mo, ml) = ours[side][0], mac[side][0]
                        notes.append(f"{side} {fmt(oo)} -> {fmt(ol)} (Mac {fmt(mo)} -> {fmt(ml)}), 3 pt off the middle "
                                     f"{fmt(ours[side][1][1])} {fmt(ours[side][2][1])} ({fmt(mac[side][1][1])} {fmt(mac[side][2][1])})")
                    fails += lc.report(ok, f"r18 {kind} {mode} over {name}", "; ".join(notes))
    finally:
        lc.ipc(pid, "panels", "close")
        lc.ipc(pid, "notifs", "clear")
    return fails


def side(img, rows, x0, x1, left):
    """(outside rgb, line rgb, x) of a straight side: the darkest column between x0 and x1 over the rows"""
    band = img[rows[0]:rows[1], x0:x1].mean(axis=0)
    lum = band.sum(axis=1)
    # the line is the column with the largest drop against the column outside it
    d = (lum[:-1] - lum[1:]) if left else (lum[1:] - lum[:-1])
    i = int(d.argmax()) + (1 if left else 0)
    out = band[i - 1] if left else band[i + 1]
    return tuple(out), tuple(band[i]), x0 + i


def straight(img, x, y0, y1):
    """the longest run of rows where column x keeps within 2 levels of its minimum"""
    col = img[y0:y1, x].mean(axis=1)
    ok = col <= col.min() + 2
    best = run = 0
    end = 0
    for i, v in enumerate(ok):
        run = run + 1 if v else 0
        if run > best:
            best, end = run, i + 1
    return y0 + end - best, y0 + end


def fmt(c):
    c = [float(v) for v in c]
    return "/".join(f"{v:.0f}" for v in c) if max(c) - min(c) > 1.5 else f"{np.mean(c):.0f}"


def main():
    keep = sys.argv[sys.argv.index("--keep") + 1] if "--keep" in sys.argv else None
    only = sys.argv[sys.argv.index("--only") + 1] if "--only" in sys.argv else ""
    pid = lc.session("nc-side-line")
    state = os.environ.get("HYPRK_STATE", "")
    if not state or os.path.realpath(state) == os.path.realpath(os.path.join(lc.ROOT, "state")) \
            or f"HYPRK_STATE={state}".encode() not in lc.environ(pid):
        sys.exit("nc-side-line: export the session's scratch HYPRK_STATE (the wallpaper is set there)")
    if lc.clients():
        sys.exit("nc-side-line: close the session's windows first (the card must lie over the wallpaper)")
    from PIL import Image
    tmp = keep or tempfile.mkdtemp(prefix="nc-side-")
    os.makedirs(tmp, exist_ok=True)
    wp = os.path.join(state, "wallpaper.json")
    before = open(wp).read() if os.path.exists(wp) else None
    fails = 0
    geo = None

    def backdrop(name, rgb):
        path = os.path.join(tmp, name + ".png")
        Image.new("RGB", (2560, 1664), rgb).save(path)
        json.dump({"path": path}, open(wp, "w"))
        time.sleep(2.5)

    ap = os.path.join(state, "appearance.json")
    ap_before = open(ap).read() if os.path.exists(ap) else None

    def appearance(mode):
        cfg = json.loads(ap_before) if ap_before else {}
        cfg["mode"], cfg["dark"] = mode, mode == "dark"
        open(ap, "w").write(json.dumps(cfg, indent=2))
        time.sleep(3.0)

    def post():
        for i in (1, 2, 3):
            lc.ipc(pid, "notifs", "testApp", "Script Editor", f"hyprk test {i}", f"body line one {i}\nbody line two")
            time.sleep(0.25)

    try:
        if lc.ipc(pid, "panels", "current"):
            lc.ipc(pid, "panels", "close")
        lc.ipc(pid, "notifs", "clear")
        if only != "straight":
            fails += r18(pid, tmp, keep, backdrop, appearance)
        appearance("dark")
        for name, rgb, card, banner in ([] if only == "r18" else CASES):
            backdrop(name, rgb)
            if banner:
                lc.ipc(pid, "notifs", "clear")
                time.sleep(0.5)
                lc.ipc(pid, "notifs", "testApp", "Script Editor", "hyprk test", "body line one\nbody line two")
                time.sleep(2.0)
                img = lc.grim()
                # the banner: top right, under the menu bar; its right side between x 1240 and 1278 pt
                o, l, x = side(img, (150, 190), 2480, 2556, False)
                y0, y1 = straight(img, x, 80, 330)
                o, l, x = side(img, (y0 + 2, y1 - 2), 2480, 2556, False)
                ok = y1 - y0 >= 8 and abs(np.mean(l) - np.mean(banner[1])) <= TOL
                fails += lc.report(ok, f"banner over {name}", f"right side, {y1 - y0} straight px: outside {fmt(o)} -> line {fmt(l)} "
                                   f"(Mac {fmt(banner[0])} -> {fmt(banner[1])})")
                time.sleep(5.5)             # the banner leaves
            lc.ipc(pid, "notifs", "clear")
            time.sleep(0.4)
            post()
            time.sleep(7.0)
            lc.ipc(pid, "panels", "toggle", "nc")
            time.sleep(2.5)
            img = lc.grim()
            if keep:
                Image.fromarray(img[0:700, 1700:2560].astype(np.uint8)).save(os.path.join(tmp, f"nc-{name}.png"))
            if name == "black" and geo:
                # no line to find over black (0 -> 0): the columns and rows of the grey case
                y0, y1, lx, rx = geo
                band = img[y0 + 2:y1 - 2].mean(axis=0)
                lo, ll, ro, rl = tuple(band[lx - 1]), tuple(band[lx]), tuple(band[rx + 1]), tuple(band[rx])
            else:
                ro, rl, rx = side(img, (220, 240), 2500, 2556, False)
                y0, y1 = straight(img, rx, 150, 330)
                ro, rl, rx = side(img, (y0 + 2, y1 - 2), 2500, 2556, False)
                lo, ll, lx = side(img, (y0 + 2, y1 - 2), 1800, 1880, True)
                if name == "grey":
                    geo = (y0, y1, lx, rx)
            lc.ipc(pid, "panels", "close")
            time.sleep(0.8)
            err = max(np.abs(np.array(ll) - card[1]).max(), np.abs(np.array(rl) - card[1]).max())
            sym = abs(np.mean(lo) - np.mean(ro))
            ok = y1 - y0 >= 8 and err <= TOL and sym <= SYM
            if name == "blue":
                # the panel's dim leaves this backdrop 10 levels lighter in blue than the Mac's still (166 against 156,
                # OPEN-FIXES): the line is judged as a share of the pixel outside it, per channel
                share = lambda o, l: np.array(l) / np.maximum(np.array(o), 1)
                err = max(np.abs(share(lo, ll) - share(*card)).max(), np.abs(share(ro, rl) - share(*card)).max())
                ok = y1 - y0 >= 8 and err <= 0.03 and sym <= SYM
            fails += lc.report(ok, f"card over {name}", f"{y1 - y0} straight px: left {fmt(lo)} -> {fmt(ll)}, right {fmt(ro)} -> {fmt(rl)} "
                               f"(Mac {fmt(card[0])} -> {fmt(card[1])} both sides)")
    finally:
        lc.ipc(pid, "panels", "close")
        lc.ipc(pid, "notifs", "clear")
        for path, was in ((wp, before), (ap, ap_before)):
            if was is None:
                os.remove(path)
            else:
                open(path, "w").write(was)
        if not keep:
            for f in os.listdir(tmp):
                os.remove(os.path.join(tmp, f))
            os.rmdir(tmp)
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
