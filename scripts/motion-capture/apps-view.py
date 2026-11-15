#!/usr/bin/env python3
"""Live check: the Apps view, Spotlight's Applications mode (MAC-ANSWERS-17.md R17.1, reference/re/27.2.1/live/r17/
apps-rest-*.png, apps-typed-cal-*.png, apps-open-close-light.mov; SPOTLIGHT-27.2.1.md "Round 17").

  rest    the 844 x 520 panel 10 pt under the 520 x 87 bar, which stays where it is; chips 26 tall 20 under the
          panel's top, the separator 168 under it from x 20 (apps-rest-*: 117..143 and 265 of the window);
  open    from the bar (Cmd-1): the panel grows about its top edge. One measure for both sides (`series`): the fill's
          level in a band 50..64 pt under the panel's top (between the chips and the icons), the width at half of that
          level and the bottom edge at half level, per frame from the first changed one. The Mac's
          (apps-open-close-light.mov from 2.917 s; `apps-view.py --mac` prints them from the clip): level .46 .62 .74
          .76 .83 .88 .92 .97 1, width .45 .62 .76 .78 .84 .88 .93 of the settled one, bottom .48 .66 .72 .72 .86
          .92 .97. Ours is compared at each frame's own time (the Mac's series interpolated), so a frame the session
          dropped does not fail the case; a capture with a dropped or repeated frame is taken again (up to 4 times,
          after one warm-up open);
  typed   a query drops the chips (the grid starts 20 under the top) and the field shows " — Open" on the completion
          pill (apps-typed-cal-*);
  close   leaving the mode (Escape): the grid goes in one frame, the empty panel shrinks into its top edge: level
          .95 .89 .79 .70 .60 .44 .38 .24 .13 .07 .02, width .90 .80 .67 .54 .43 .31 (the Mac from 5.217 s), the bar stays.

Session: see livecheck.py (a flat or any wallpaper; the plugin loaded). The mode is set over IPC (spotlightmode set),
as the keys would. The wallpaper must differ from the panel by more than 6 levels in the band (flat grey 127, white
and the default picture all do).   apps-view.py [--keep DIR] | --mac      exit 0 = every case passed
"""
import os, subprocess, sys, tempfile, time

import numpy as np

import livecheck as lc

BAR_W, BAR_H, GAP, W, H = 520, 87, 10, 844, 520
# the Mac's series, 60 fps from the first changed frame (apps-view.py --mac)
MAC_OPEN = {"level": [.46, .62, .74, .76, .83, .88, .92, .97, 1.0, 1.0], "width": [.45, .62, .76, .78, .84, .88, .93, 1.0],
            "bottom": [.48, .66, .72, .72, .86, .92, .97, 1.0]}
MAC_CLOSE = {"level": [.95, .89, .79, .70, .60, .44, .38, .24, .13, .07, .02], "width": [.90, .80, .67, .54, .43, .31]}


def series(g, x0, y0, k, opening):
    """g: grey frames (n, h, w) holding the panel with its top-left at (x0, y0) pt, k px per pt; the first and the
    last frames are the two rest states. Returns (index of the first changed frame, level, width, bottom) per frame,
    each a share of the settled panel's: the change of every pixel as a share of its whole change, so a picture
    behind the panel and what the panel holds cancel."""
    a0, a1 = g[:3].mean(axis=0), g[-5:].mean(axis=0)
    base, fin = (a0, a1) if opening else (a1, a0)
    den = fin - base
    ok = np.abs(den) > 6

    def share(i, ya, yb, xa, xb, axis=None, plain=False):
        sl = (slice(int((y0 + ya) * k), int((y0 + yb) * k)), slice(int((x0 + xa) * k), int((x0 + xb) * k)))
        m = ok[sl]
        if plain and m.any():
            m = m & (np.abs(fin[sl] - np.median(fin[sl][m])) < 5)       # fill only: no chip, icon or name
        num, dn = ((g[i] - base)[sl] * np.sign(den[sl]) * m), (np.abs(den[sl]) * m)
        if axis is None:
            return num.sum() / dn.sum() if dn.sum() > 0 else np.nan
        dn = dn.sum(axis=axis)
        return np.where(dn > 20, num.sum(axis=axis) / np.maximum(dn, 1), np.nan)

    n = len(g)
    level = np.array([share(i, 50, 64, W / 2 - 150, W / 2 + 150, plain=True) for i in range(n)])
    width, bottom = np.zeros(n), np.zeros(n)
    for i in range(n):
        r = share(i, 50, 64, -30, W + 30, axis=0)
        c = np.nanmean(r[int((30 + W / 2 - 50) * k):int((30 + W / 2 + 50) * k)])
        on = np.nonzero(r > 0.5 * c)[0] if c > 0.05 else []
        width[i] = (on[-1] - on[0]) / k if len(on) else 0
        r = share(i, 0, H + 30, W / 2 - 150, W / 2 + 150, axis=1)
        c = np.nanmax(r) if np.isfinite(r).any() else 0
        on = np.nonzero(r > 0.5 * c)[0] if c > 0.05 else []
        bottom[i] = on[-1] / k if len(on) else 0
    rest = level[-5:].mean() if opening else level[:3].mean()
    moved = np.abs(level - (0 if opening else 1)) > 0.03
    i0 = int(np.argmax(moved))
    wr, br = (width[-5:].mean(), bottom[-5:].mean()) if opening else (width[:3].mean(), bottom[:3].mean())
    return i0, level, width / max(wr, 1), bottom / max(br, 1)


def against(t, ours, mac, n=8):
    """rms and largest difference of our first n frames against the Mac's series taken at our frames' own times"""
    tm = np.arange(len(mac)) * 1000 / 60
    t = np.asarray(t[:n]) - t[0]
    d = np.asarray(ours[:n]) - np.interp(t, tm, mac)
    d = d[t <= tm[-1] + 1]
    return float(np.sqrt((d ** 2).mean())), float(np.abs(d).max())


def mac_series():
    """prints the Mac's series from apps-open-close-light.mov (region 130,250 940x682 pt, the window at 174,295, the
    panel 97 under its top: its top-left at 44,142 of the clip)"""
    f = os.path.join(lc.ROOT, "reference/re/27.2.1/live/r17/apps-open-close-light.mov")
    ts = [float(x.split(":")[1]) for x in subprocess.run(["ffmpeg", "-v", "info", "-i", f, "-vf", "showinfo", "-f", "null", "-"],
                                                          capture_output=True, text=True).stderr.split() if x.startswith("pts_time:")]
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", f, "-vsync", "passthrough", "-f", "rawvideo", "-pix_fmt", "gray", "-"], capture_output=True).stdout
    fr = np.frombuffer(raw, np.uint8).reshape(-1, 1364, 1880).astype(float)
    for name, a, b, opening in (("open", 2.85, 3.5, True), ("close", 5.15, 5.6, False)):
        i, j = next(n for n, t in enumerate(ts) if t >= a), next(n for n, t in enumerate(ts) if t >= b)
        i0, lv, w, bt = series(fr[i:j], 44, 142, 2, opening)
        print(f"{name}: first changed frame {ts[i + i0]:.3f} s")
        for nm, v in (("level", lv), ("width", w), ("bottom", bt)):
            print(f"  {nm:6s} " + " ".join(f"{x:.2f}" for x in v[i0:i0 + 11]))


def main():
    keep = sys.argv[sys.argv.index("--keep") + 1] if "--keep" in sys.argv else None
    pid = lc.session("apps-view")
    tmp = keep or tempfile.mkdtemp(prefix="apps-view-")
    os.makedirs(tmp, exist_ok=True)
    bar_y = round(lc.H * 0.2665 - BAR_H / 2)
    px, py = (lc.W - W) // 2, bar_y + BAR_H + GAP
    fails = 0

    def close():
        if lc.ipc(pid, "panels", "current"):
            lc.ipc(pid, "panels", "close")
            time.sleep(0.7)

    def motion(tag, opening):
        """the panel's frames while the mode is set (opening) or left, as series(); a capture with a repeated or a
        late frame in the motion is taken again"""
        prefix = os.path.join(tmp, tag)
        for attempt in range(4):
            close()
            lc.ipc(pid, "spotlight", "empty")
            time.sleep(1.0)
            if not opening:
                lc.ipc(pid, "spotlightmode", "set", "apps")
                time.sleep(1.0)
            cap = lc.mcap_start(prefix, (px - 30, py - 20, W + 60, H + 60), 1.0, 1)
            time.sleep(0.3)
            lc.ipc(pid, "spotlightmode", "set", "apps" if opening else "")
            cap.wait(timeout=30)
            t, fr = lc.frames(prefix, keep=bool(keep))
            i0, lv, w, bt = series(fr.mean(axis=3), 30, 20, 2, opening)
            seg = slice(i0, i0 + 8)
            late = np.diff(t[i0 - 1:i0 + 8]).max() > 25 if i0 > 0 else True
            same = np.any(np.abs(np.diff(lv[seg])) < 0.004) and (lv[i0 + 6] < 0.97 if opening else lv[i0 + 6] > 0.03)
            if not late and not same:
                break
        return t[i0:], lv[i0:], w[i0:], bt[i0:], attempt, late or same

    try:
        close()
        lc.ipc(pid, "spotlight", "empty")
        time.sleep(1.2)
        before = lc.grim().mean(axis=2)
        # ---- open: the bar takes the mode, the panel grows ----
        lc.ipc(pid, "spotlightmode", "set", "apps")          # warm-up: the grid's first load takes frames
        time.sleep(1.2)
        t, lv, w, bt, again, rough = motion("open", True)
        if not np.isfinite(lv[:8]).all():
            fails += lc.report(False, "open", "the band 50..64 pt under the panel's top never changed by more than 6 levels: no panel, or a wallpaper of the panel's own level there")
            return fails
        note = (f"; {again} capture(s) retaken" if again else "") + ("; the last one still has a repeated or late frame" if rough else "")
        rms, worst = against(t, lv, MAC_OPEN["level"])
        fails += lc.report(rms <= 0.08 and worst <= 0.16, "open: the panel's level",
                           " ".join(f"{x:.2f}" for x in lv[:9]) + f" (Mac .46 .62 .74 .76 .83 .88 .92 .97 1); rms {rms:.3f}, worst {worst:.2f} at our frames' times" + note)
        rms, worst = against(t, w, MAC_OPEN["width"], 7)
        fails += lc.report(rms <= 0.08 and worst <= 0.16, "open: width",
                           " ".join(f"{x:.2f}" for x in w[:8]) + f" of the settled one (Mac .45 .62 .76 .78 .84 .88 .93); rms {rms:.3f}, worst {worst:.2f}")
        # the first frame already fills the band under the chips and is about half as tall as the panel (the bottom
        # edge of later frames is not read here: our icons are sharp where the Mac's clip has them blurred)
        fails += lc.report(lv[0] >= 0.35 and 0.3 <= bt[0] <= 0.7, "open: grows about its top edge",
                           f"first frame: level {lv[0]:.2f} in the band 50..64 pt under the top, bottom edge at {bt[0]:.2f} of the height (Mac .46, .48; about a point 20 pt down it was .24 and 108 of 520 pt)")
        settled = np.nonzero(np.abs(lv - 1) > 0.04)[0]
        ms = float(t[settled[-1] + 1] - t[0]) if len(settled) and settled[-1] + 1 < len(t) else 0.0
        fails += lc.report(80 <= ms <= 190, "open: settled", f"the level is within 4 % {ms:.0f} ms after the first frame (Mac 117 ms: 3.033 s; its lower rows 167 ms)")
        lc.ipc(pid, "spotlightmode", "set", "apps")
        time.sleep(1.2)
        time.sleep(0.5)
        # ---- rest ----
        img = lc.grim()
        lum = img.mean(axis=2)
        k = 2
        bar_same = np.abs(lum[bar_y * k - 4:(bar_y + 12) * k, (lc.W // 2 - 200) * k:(lc.W // 2 - 100) * k]
                          - before[bar_y * k - 4:(bar_y + 12) * k, (lc.W // 2 - 200) * k:(lc.W // 2 - 100) * k]).max()
        fails += lc.report(bar_same <= 3, "rest: the bar stays", f"its top edge rows differ by {bar_same:.0f} levels from the plain bar's (the r17 shots' 54 pt rise is a dragged window kept on screen: the default one stays, Q-panels-25)")
        col = lum[py * k:(py + 60) * k, (px + 60) * k]                       # through the first chip, 60 pt in
        step = np.diff(col)
        top = int(np.argmax(step[30:] > 4)) + 31                             # the chip's fill is +10 over the panel
        bot = int(np.nonzero(step < -4)[0][-1]) + 1                          # the last fall: its bottom (the text falls inside)
        fails += lc.report(abs(top / k - 20) <= 1 and abs((bot - top) / k - 26) <= 1, "rest: chips",
                           f"first chip from {top / k:.1f} to {bot / k:.1f} pt under the panel's top (Mac 20 .. 46)")
        sep = lum[(py + 160) * k:(py + 176) * k, (px + 400) * k]
        sy = 160 + int(np.argmax(sep - np.median(sep))) / k
        fails += lc.report(abs(sy - 168) <= 1 and sep.max() - np.median(sep) > 15, "rest: separator",
                           f"at {sy:.1f} pt, +{sep.max() - np.median(sep):.0f} levels (Mac 168, +35)")
        # ---- typed ----
        lc.ipc(pid, "spotlight", "search", "cal")
        time.sleep(1.0)
        img2 = lc.grim().mean(axis=2)
        chip_gone = np.abs(np.diff(img2[py * k:(py + 60) * k, (px + 300) * k])).max() if True else 0
        row = img2[(bar_y + BAR_H // 2 - 2) * k, (lc.W // 2 - BAR_W // 2 + 60) * k:(lc.W // 2 + 100) * k]
        pill = np.sum(np.abs(row - np.median(row)) > 8) / k                  # ink + pill along the field's middle row
        fails += lc.report(pill > 60, "typed: completion", f"{pill:.0f} pt of text and pill on the field's middle row (\"cal\" + \" — Open\", Mac about 105)")
        sep2 = img2[(py + 160) * k:(py + 176) * k, (px + 600) * k]
        fails += lc.report(sep2.max() - np.median(sep2) < 10, "typed: no chips, no separator", f"separator row +{sep2.max() - np.median(sep2):.0f} levels")
        lc.ipc(pid, "spotlight", "empty")                                    # the field cleared: the whole grid again
        time.sleep(0.8)
        # ---- close: back to the bar ----
        t, lv, w, bt, again, rough = motion("close", False)
        note = (f"; {again} capture(s) retaken" if again else "") + ("; the last one still has a repeated or late frame" if rough else "")
        rms, worst = against(t, lv, MAC_CLOSE["level"], 10)
        fails += lc.report(rms <= 0.08 and worst <= 0.16, "close: the panel's level",
                           " ".join(f"{x:.2f}" for x in lv[:10]) + f" (Mac .95 .89 .79 .70 .60 .44 .38 .24 .13 .07 .02); rms {rms:.3f}, worst {worst:.2f}" + note)
        rms, worst = against(t, w, MAC_CLOSE["width"], 6)
        fails += lc.report(rms <= 0.08 and worst <= 0.16, "close: width", " ".join(f"{x:.2f}" for x in w[:6]) + f" (Mac .90 .80 .67 .54 .43 .31); rms {rms:.3f}, worst {worst:.2f}")
        gone = np.nonzero(lv < 0.04)[0]
        ms = float(t[gone[0]] - t[0]) if len(gone) else -1
        fails += lc.report(120 <= ms <= 210, "close: gone", f"under 4 % {ms:.0f} ms after the first frame (Mac 167 ms: 5.217 .. 5.383 s)")
        time.sleep(0.4)
        now = lc.grim().mean(axis=2)
        still = lum[bar_y * k + 20:(bar_y + BAR_H) * k - 20:8, (lc.W // 2 + 60) * k:(lc.W // 2 + 180) * k:8]
        now_ = now[bar_y * k + 20:(bar_y + BAR_H) * k - 20:8, (lc.W // 2 + 60) * k:(lc.W // 2 + 180) * k:8]
        fails += lc.report(lc.ipc(pid, "panels", "current") == "spotlight" and np.abs(still - now_).max() < 12, "close: the bar stays", "Spotlight still open with the plain bar")
    finally:
        close()
        if not keep:
            try:
                os.rmdir(tmp)
            except OSError:
                pass
    return fails


if __name__ == "__main__":
    if "--mac" in sys.argv:
        mac_series()
        sys.exit(0)
    sys.exit(1 if main() else 0)
