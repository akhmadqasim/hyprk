#!/usr/bin/env python3
"""Live check: Spotlight's Files grid, the top hit's tab hint, the scroll knobs, the caret's halo and the mode glyphs
against the Mac's stills (MAC-ANSWERS-17.md R17.3, reference/re/27.2.1/live/r17/spotlight-{mode-files,typed,modelist}-
white-dark.png; SPOTLIGHT-27.2.1.md "Judge #25"). Every Mac number is read here from the still, ours from the screen
with the same code, both in pt of the panel under the bar (2 px per pt).

  files   the panel is 844 wide; five chips 26 tall 20 under its top, the first 20 .. 174.4, fill +12; tiles in 7
          columns (middles 77 + 115 n) with rows at 100, 270 and 395 (the Mac's tiles are blurred: +-4); the grey 124
          scroll knob 6 wide, 3 from the right edge, from 102;
  typed   "Search <App>" and the tab key cap on the top hit: the cap 26.5 x 18 ending 26.5 from the panel's right edge,
          +35 over the row, the text ending 8.5 before it; the results knob (query "e": a list longer than the panel);
  modes   the Actions and Clipboard glyphs' ink boxes and their fill of the box (two stacked rounded squares, two
          outline documents), the caret's halo 1.5 / 3 / 4.5 pt beside it.

Session: see livecheck.py, with HYPRK_STATE exported (the session's own state dir: the check writes its wallpaper.json
there and puts the old one back) and a scratch HOME (the check writes 30 recent files and a recently-used.xbel there,
never in the user's home). The top hit must be an app the session has: --app-query (default "calc").
  spotlight-modes.py [--app-query calc] [--keep DIR]      exit 0 = every case passed
"""
import datetime, json, os, sys, tempfile, time

import numpy as np
from PIL import Image

import livecheck as lc

R17 = os.path.join(lc.ROOT, "reference/re/27.2.1/live/r17")
K = 2
BAR_Y = round(lc.H * 0.2665 - 87 / 2)
PY = BAR_Y + 87 + 10                      # the panel's top, pt


def mac(name, wide):
    """the Mac still's panel as a grey array from the panel's top-left (the crop is the window + 30 pt, the panel 97
    under the window's top) and the bar's rows above it"""
    a = np.asarray(Image.open(os.path.join(R17, name + ".png")).convert("RGB")).astype(float).mean(axis=2)
    ox = 60 + (0 if wide or a.shape[1] > 1500 else 0)
    return a[60 + 97 * K:, ox:], a[60:, 60 + (324 if a.shape[1] > 1500 else 0):]


def ours(img, wide):
    g = img.astype(float).mean(axis=2)
    w = 844 if wide else 520
    x0 = (lc.W - w) // 2
    return g[PY * K:, x0 * K:], g[BAR_Y * K:, (lc.W - 520) // 2 * K:]


def chip_box(p):
    """the first chip: (top, bottom, left, right, lift) from the steps on a column 40 pt in and the row through its middle"""
    col = p[:60 * K, 40 * K]
    d = np.diff(col)
    top = int(np.argmax(d[20:] > 5)) + 21
    bot = top + int(np.argmax(d[top + 4:] < -5)) + 5
    row = p[(top + bot) // 2, :200 * K]
    lvl = np.median(row[30 * K:60 * K])
    base = np.median(p[(top - 8):(top - 2), 30 * K:160 * K])
    on = np.nonzero(row > (lvl + base) / 2)[0]
    run = on[on > 12 * K]
    left = run[0]
    right = left
    while right + 1 < len(row) and (row[right + 1] > (lvl + base) / 2 or row[right + 3] > (lvl + base) / 2):
        right += 1
    return top / K, bot / K, left / K, (right + 1) / K, lvl - base


def chips_count(p, top, bot, lift):
    """(number of chips, right edge of the last one): runs over 60 pt of a row 4 pt into the chips that is lighter
    than the row 3 pt above them, column by column"""
    d = p[int((top + 4) * K), :844 * K] - p[int((top - 3) * K), :844 * K]
    on = np.concatenate(([False], d > lift / 2, [False]))
    a, b = np.nonzero(on[1:] & ~on[:-1])[0], np.nonzero(~on[1:] & on[:-1])[0]
    runs = [(x, y) for x, y in zip(a, b) if y - x > 60 * K]
    return len(runs), (runs[-1][1] / K if runs else 0)


def knob(p, w, y1=300):
    """the grey 124 knob near the right edge: (left, right, top) in pt, or None"""
    reg = p[:y1 * K, (w - 14) * K:w * K]
    on = np.abs(reg - 124) <= 2
    rows = np.nonzero(on.sum(axis=1) >= 6)[0]
    cols = np.nonzero(on.sum(axis=0) >= 20)[0]
    if not len(rows) or not len(cols):
        return None
    return w - 14 + cols[0] / K, w - 14 + (cols[-1] + 1) / K, rows[0] / K


def tiles(p, y0, y1):
    """middles of the bright or dark blobs along a band of rows (the tiles of one row), pt"""
    v = np.abs(p[y0 * K:y1 * K, :844 * K] - np.median(p[y0 * K:y1 * K, :844 * K])).mean(axis=0)
    v = np.convolve(v, np.ones(24) / 24, mode="same")
    out = []
    for n in range(7):
        c = 77 + 115 * n
        seg = v[(c - 50) * K:(c + 50) * K]
        if seg.max() > 3:
            w = np.clip(seg - seg.max() / 2, 0, None)
            out.append(c - 50 + float((np.arange(len(seg)) * w).sum() / w.sum()) / K)
    return out


def rows_of(p, cx):
    """middles of the tiles down one column, pt"""
    # against the gap between this column and the next (the panel's own gradient and what shows through it cancel)
    v = np.abs(p[60 * K:470 * K, (cx - 20) * K:(cx + 20) * K].mean(axis=1) - p[60 * K:470 * K, (cx + 52) * K:(cx + 62) * K].mean(axis=1))
    v = np.convolve(v, np.ones(16) / 16, mode="same")
    out = []
    for c in (100, 270, 395):
        seg = v[(c - 60 - 32) * K:(c - 60 + 32) * K]
        on = np.nonzero(seg > seg.max() / 5)[0]                 # the middle of the tile's extent (a fifth of its level: icon art is not even)
        out.append(c - 32 + (on[0] + on[-1] + 1) / 2 / K if seg.max() > 2 else None)
    return out


def hint(p):
    """the tab cap (left, right, top, bottom, lift) and the hint text's right edge and lift, on the first row"""
    reg = p[26 * K:60 * K, 360 * K:510 * K]
    base = np.median(reg)
    cap = np.abs(reg - (base + 35)) <= 4
    rows = np.nonzero(cap.sum(axis=1) > 30)[0]
    if not len(rows):
        return None
    mid = cap[rows[0] + 4]                        # a row of the cap above the "tab" ink
    cols = np.nonzero(mid)[0]
    run = [cols[-1]]
    for c in cols[::-1][1:]:
        if run[-1] - c > 2:
            break
        run.append(c)
    left, right = 360 + run[-1] / K, 360 + (run[0] + 1) / K
    lift = np.median(reg[rows[0] + 2:rows[0] + 6, run[-1] + 6:run[0] - 6]) - base
    txt = reg[:, :run[-1] - 6]
    ink = np.nonzero((txt > base + 20).any(axis=0))[0]
    return left, right, 26 + rows[0] / K, 26 + (rows[-1] + 1) / K, lift, (360 + (ink[-1] + 1) / K) if len(ink) else None, txt.max() - base


def glyph(p, row):
    """ink box (w, h) in pt and the ink's share of the box for the mode list glyph of that row (0-based)"""
    cy = 11 + 48 * row + 24
    reg = p[(cy - 20) * K:(cy + 20) * K, 24 * K:66 * K]
    base = np.median(reg)
    on = reg > base + 60
    ys, xs = np.nonzero(on.any(axis=1))[0], np.nonzero(on.any(axis=0))[0]
    if not len(ys):
        return 0, 0, 0
    box = on[ys[0]:ys[-1] + 1, xs[0]:xs[-1] + 1]
    return (xs[-1] - xs[0] + 1) / K, (ys[-1] - ys[0] + 1) / K, float(box.mean())


def halo(bar):
    """levels added 1.5 / 3 / 4.5 pt left of the caret at its middle, against the bar 20 pt further left"""
    reg = bar[30 * K:56 * K, 20 * K:80 * K]
    cols = np.nonzero((reg > 240).sum(axis=0) > 30)[0]
    if not len(cols):
        return None
    cx = 20 * K + cols[0]
    y = 43 * K
    ref = bar[y - 2:y + 3, cx - 15 * K].mean()
    return [float(bar[y - 2:y + 3, cx - d].mean() - ref) for d in (3, 6, 9)]


def recents(home):
    """30 recent files of five kinds in the scratch HOME (never the user's)"""
    real = os.path.realpath(os.path.expanduser("~" + os.environ.get("USER", "")))
    if os.path.realpath(home) == real or not home.startswith(("/tmp/", os.environ.get("XDG_RUNTIME_DIR", "/nonexistent") + "/")):
        sys.exit("spotlight-modes: the session's HOME must be a scratch directory under /tmp or XDG_RUNTIME_DIR")
    d = os.path.join(home, "Documents")
    os.makedirs(d, exist_ok=True)
    os.makedirs(os.path.join(home, ".local/share"), exist_ok=True)
    kinds = [("Report %d.pdf", "application/pdf"), ("Notes %d.txt", "text/plain"), ("Photo %d.png", "image/png"),
             ("Song %d.mp3", "audio/mpeg"), ("Budget %d.xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")]
    rows = []
    for i in range(30):
        n, m = kinds[i % len(kinds)]
        p = os.path.join(d, n % i)
        if not os.path.exists(p):
            if m == "image/png":
                Image.new("RGB", (160, 120), (230, 230, 235)).save(p)
            else:
                open(p, "w").write("x")
        t = (datetime.datetime(2026, 11, 15, 12) - datetime.timedelta(minutes=i)).strftime("%Y-%m-%dT%H:%M:%SZ")
        rows.append(f'<bookmark href="file://{p.replace(" ", "%20")}" modified="{t}" visited="{t}"><info><metadata owner="http://freedesktop.org">'
                    f'<mime:mime-type type="{m}"/></metadata></info></bookmark>')
    open(os.path.join(home, ".local/share/recently-used.xbel"), "w").write(
        '<?xml version="1.0" encoding="UTF-8"?>\n<xbel version="1.0" xmlns:mime="http://www.freedesktop.org/standards/shared-mime-info">\n'
        + "\n".join(rows) + "\n</xbel>\n")


def main():
    args = sys.argv[1:]
    app_query = args[args.index("--app-query") + 1] if "--app-query" in args else "calc"
    keep = args[args.index("--keep") + 1] if "--keep" in args else None
    pid = lc.session("spotlight-modes")
    state = os.environ.get("HYPRK_STATE", "")
    if not state or not os.path.isdir(state) or os.path.realpath(state) == os.path.realpath(os.path.join(lc.ROOT, "state")):
        sys.exit("spotlight-modes: export the test session's HYPRK_STATE (never the user's state/)")
    home = next((e.decode()[5:] for e in lc.environ(pid) if e.startswith(b"HOME=")), "")
    recents(home)
    tmp = keep or tempfile.mkdtemp(prefix="spotlight-modes-")
    os.makedirs(tmp, exist_ok=True)
    wj = os.path.join(state, "wallpaper.json")
    old = open(wj).read() if os.path.exists(wj) else None
    wall = os.path.join(tmp, "dark30.png")
    Image.new("RGB", (2560, 1664), (30, 31, 30)).save(wall)      # the r17 "white-dark" backdrop
    open(wj, "w").write(json.dumps({"path": wall}))
    time.sleep(2.5)
    fails = 0
    ptr = None

    def close():
        if lc.ipc(pid, "panels", "current"):
            lc.ipc(pid, "panels", "close")
            time.sleep(0.7)

    def shot(tag):
        img = lc.grim()
        if keep:
            Image.fromarray(img.astype(np.uint8)).save(os.path.join(tmp, tag + ".png"))
        return img

    try:
        # ---- Files ----
        close()
        lc.ipc(pid, "spotlight", "empty")
        time.sleep(1.0)
        lc.ipc(pid, "spotlightmode", "set", "files")
        time.sleep(2.0)
        o, _ = ours(shot("files"), True)
        m, _ = mac("spotlight-mode-files-white-dark", True)
        try:
            co, cm = chip_box(o), chip_box(m)
            (no, eo), (nm, em) = chips_count(o, co[0], co[1], co[4]), chips_count(m, cm[0], cm[1], cm[4])
            # the panel's width: the chips run from 20 pt inside its left edge to 20 inside its right one
            fails += lc.report(abs(eo - em) <= 2 and eo > 800, "files: panel width",
                               f"{eo + 20:.0f} pt: the last chip ends at {eo:.1f} (Mac {em + 20:.0f}, {em:.1f}; the list was 520)")
            ok = all(abs(a - b) <= 1 for a, b in zip(co[:4], cm[:4])) and abs(co[4] - cm[4]) <= 4 and no == nm
            fails += lc.report(ok, "files: chips", f"{no} chips, the first {co[2]:.1f} .. {co[3]:.1f} x {co[0]:.1f} .. {co[1]:.1f}, +{co[4]:.0f} "
                               f"(Mac {nm}, {cm[2]:.1f} .. {cm[3]:.1f} x {cm[0]:.1f} .. {cm[1]:.1f}, +{cm[4]:.0f})")
        except (IndexError, ValueError):
            fails += lc.report(False, "files: chips", "no chip found 20 pt under the panel's top")
        to, tm = tiles(o, 75, 125), tiles(m, 75, 125)
        ok = len(to) == 7 and len(tm) == 7 and max(abs(a - b) for a, b in zip(to, tm)) <= 4
        fails += lc.report(ok, "files: columns", "tile middles " + " ".join(f"{x:.0f}" for x in to) + " (Mac " + " ".join(f"{x:.0f}" for x in tm) + ")")
        mw, _ = mac("spotlight-mode-files-wallpaper-dark", True)       # light tiles on a dark panel: the clearer still
        ro, rm = rows_of(o, 77), rows_of(mw, 77)
        ok = None not in ro and None not in rm and max(abs(a - b) for a, b in zip(ro, rm)) <= 6
        fails += lc.report(ok, "files: rows", "row middles " + " ".join("-" if x is None else f"{x:.0f}" for x in ro)
                           + " (Mac " + " ".join("-" if x is None else f"{x:.0f}" for x in rm) + "; its tiles are blurred)")
        ko = knob(o, 844)
        # the knob shows 1 pt beside the Mac's blur in that still
        col = mw[:300 * K, 840 * K]
        kt = int(np.argmax(np.abs(col - 124) <= 1)) / K
        fails += lc.report(ko is not None and abs(ko[0] - 835) <= 1 and abs(ko[1] - 841) <= 1 and abs(ko[2] - kt) <= 2, "files: scroll knob",
                           (f"x {ko[0]:.1f} .. {ko[1]:.1f} from y {ko[2]:.1f}" if ko else "none") + f" (Mac: grey 124 to x 841, from y {kt:.1f})")
        # ---- typed: the hint on the top hit ----
        close()
        lc.ipc(pid, "spotlight", "search", app_query)
        time.sleep(1.8)
        o, _ = ours(shot("typed"), False)
        m, _ = mac("spotlight-typed-white-dark", False)
        ho, hm = hint(o), hint(m)
        if ho is None:
            fails += lc.report(False, "typed: tab hint", f"no key cap on the first row (is the top hit of \"{app_query}\" an app?)")
        else:
            ok = abs(ho[1] - hm[1]) <= 1 and abs((ho[3] - ho[2]) - (hm[3] - hm[2])) <= 1 and abs(ho[2] - hm[2]) <= 1 \
                and abs((ho[1] - ho[0]) - (hm[1] - hm[0])) <= 1.5 and abs(ho[4] - hm[4]) <= 5
            fails += lc.report(ok, "typed: tab key cap", f"{ho[0]:.1f} .. {ho[1]:.1f} x {ho[2]:.1f} .. {ho[3]:.1f}, +{ho[4]:.0f} "
                               f"(Mac {hm[0]:.1f} .. {hm[1]:.1f} x {hm[2]:.1f} .. {hm[3]:.1f}, +{hm[4]:.0f})")
            ok = ho[5] is not None and abs(ho[5] - hm[5]) <= 1.5 and abs(ho[6] - hm[6]) <= 12
            fails += lc.report(ok, "typed: hint text", f"ends at {ho[5]}, +{ho[6]:.0f} (Mac {hm[5]}, +{hm[6]:.0f}: \"Search Calculator\", SF 11)")
        close()
        lc.ipc(pid, "spotlight", "search", "e")
        time.sleep(2.2)
        o, _ = ours(shot("results"), False)
        ko, km = knob(o, 520), knob(m, 520)
        fails += lc.report(ko is not None and all(abs(a - b) <= 1 for a, b in zip(ko, km)), "typed: scroll knob",
                           (f"x {ko[0]:.1f} .. {ko[1]:.1f} from y {ko[2]:.1f}" if ko else "none (is the list of \"e\" longer than the panel?)")
                           + f" (Mac {km[0]:.1f} .. {km[1]:.1f} from {km[2]:.1f})")
        # ---- mode list: glyphs, caret ----
        close()
        lc.ipc(pid, "spotlight", "empty")
        time.sleep(1.0)
        ptr = lc.Pointer()
        ptr.move(900, 700)
        time.sleep(0.1)
        ptr.move(930, 720, 10)
        time.sleep(1.6)
        o, ob = ours(shot("modes"), False)
        m, mb = mac("spotlight-modelist-white-dark", False)
        for row, name in ((2, "Actions"), (3, "Clipboard")):
            go, gm = glyph(o, row), glyph(m, row)
            ok = abs(go[0] - gm[0]) <= 1.5 and abs(go[1] - gm[1]) <= 1.5 and abs(go[2] - gm[2]) <= 0.08
            fails += lc.report(ok, f"modes: {name} glyph", f"ink {go[0]:.1f} x {go[1]:.1f} pt, {go[2]:.2f} of its box (Mac {gm[0]:.1f} x {gm[1]:.1f}, {gm[2]:.2f})")
        ho, hm = halo(ob), halo(mb)
        ok = ho is not None and hm is not None and max(abs(a - b) for a, b in zip(ho, hm)) <= 14
        fails += lc.report(ok, "modes: caret halo", ("+" + " +".join(f"{x:.0f}" for x in ho) if ho else "no caret found")
                           + " at 1.5 / 3 / 4.5 pt beside the caret (Mac +" + " +".join(f"{x:.0f}" for x in hm or []) + ")")
    finally:
        close()
        if ptr:
            ptr.close()
        if old is None:
            os.remove(wj)
        else:
            open(wj, "w").write(old)
        if not keep:
            try:
                os.remove(wall)
                os.rmdir(tmp)
            except OSError:
                pass
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
