#!/usr/bin/env python3
"""Live check: the Cmd-Tab switcher against the Mac's round 17 captures (MAC-ANSWERS-17.md R17.2,
reference/re/27.2.1/live/r17/cmdtab-*): in light and dark, with 7 apps (Finder and six windows this check opens),

  geometry  the panel's top and left edge and its corner, the selection plate's left and top edge, its corner and its
            fill against the panel, the name's ink rows, extreme level and stem width: each read the same way from
            cmdtab-7apps-{light,dark}.png and from ours (2x, panel 980 x 176 pt at the screen centre in both)
  appear    complete in ONE frame 180 ms after the key, nothing before it (cmdtab-step-cancel-dark.mov)
  step      plate and name on the next icon in one frame, a jump
  cancel    Escape: gone in one frame
  release   fades out ease-in-out over 0.25 s, the Mac's per-frame levels (cmdtab-appear-release-*.mov: fit 0.246 /
            0.242 s, rms 0.3 / 0.5 %)
  quick tap released 60 ms after the key: no panel in any frame (cmdtab-quick-tap-*.mov)

The keys are the shell's global shortcuts (hyprk:switcher, -next, -cancel, -commit), what the compositor's binds send.
Session: see livecheck.py. HYPRK_STATE must be the session's scratch state folder: the mode is switched in its
appearance.json and put back. Needs `foot` for the six windows (parked small in the top left corner, closed at the end).

  cmd-tab.py [--keep DIR]      exit 0 = all pass; --keep saves the two stills (Mac above, ours below)
"""
import json, os, shutil, subprocess, sys, tempfile, time

import numpy as np
from PIL import Image

import livecheck as lc

REF = os.path.join(lc.ROOT, "reference/re/27.2.1/live/r17/cmdtab-7apps-%s.png")
MAC_AT = (460, 156)                     # the 7-app panel's corner in the Mac's still, px (band 0,300 of 1440 x 932 pt)
PW, PH = 1960, 352                      # 980 x 176 pt
OUR_AT = ((lc.W * 2 - PW) // 2, (lc.H * 2 - PH) // 2)
APPS = ("TextEdit", "Calculator", "Notebook", "Chess", "Books", "Clock")   # names with an ascender (d, l, b, h, k) and no descender
M = 40                                  # margin around the panel in the crops, px
SHOW_MS, SHOW_TOL = 180, 34        # two 60 Hz frames: the Mac's time is to one frame, ours lands within about a frame and a half of its mean (QML timer and refresh phase)
# the Mac's release, share of the panel left per 60 Hz frame (dark clip; the light one is the same curve)
MAC_FADE = [97.8, 92.7, 86.3, 78.4, 68.0, 56.9, 45.4, 33.8, 23.8, 14.7, 8.5, 3.4, 1.0, 0.0]


def crop(img, at):
    return img[at[1] - M:at[1] + PH + M, at[0] - M:at[0] + PW + M]


def first_step(v, d=25):
    """index of the first sample more than d levels from the first one"""
    for i, x in enumerate(v):
        if abs(int(x) - int(v[0])) > d:
            return i
    return -1


def steepest(v):
    return int(np.abs(np.diff(v)).argmax())


def measure(a, mode, sel=1):
    """structure of a panel crop (px, 2 per pt): see the module text"""
    g = a.sum(axis=2) // 3
    cx = M + 48 + sel * 268             # the selected 128 pt cell's left edge
    row = g[M + 176, cx - 10:cx + 40]
    out = {
        "panel top": steepest(g[M - 6:M + 10, M + 980]) - 5,
        "panel left": steepest(g[M + 176, M - 6:M + 10]) - 5,
        "panel corner": steepest(np.array([g[M + i, M + i] for i in range(60)])),
        "plate left": first_step(row) - 10,
        "plate top": first_step(g[M + 38:M + 88, cx + 128]) - 10,
        "plate corner": first_step(np.array([g[M + 48 + i, cx + i] for i in range(50)])),
        "plate fill": int(row[22]) - int(row[4]),
    }
    t = g[M + 300:M + 348, cx + 40:cx + 216].astype(float)
    ink = t < 70 if mode == "light" else t > 215
    ys = np.where(ink.any(axis=1))[0]
    if len(ys):
        out["name top"], out["name bottom"] = int(ys[0]) + 300, int(ys[-1]) + 300
        out["name level"] = int(t.min() if mode == "light" else t.max())
        # stems: coverage summed over each run of ink on the rows of the x-height's middle, the median run
        bg = np.median(t, axis=1, keepdims=True)
        cov = np.clip((bg - t) / (bg - out["name level"]), 0, 1)
        runs = []
        for y in range(int(ys[0]) + 9, int(ys[0]) + 15):
            s = 0.0
            for c in list(cov[y]) + [0]:
                if c > 0.15:
                    s += c
                elif s:
                    runs.append(s)
                    s = 0.0
        out["name stem"] = round(float(np.median(runs)), 1) if runs else 0
    return out


TOL = {"plate fill": 6, "name level": 12, "name stem": 0.5}


def share(fr, before, full):
    """how much of the change from `before` to `full` each frame shows, 0..1"""
    d = (full - before).astype(float)
    mask = np.abs(d).sum(axis=2) > 40
    den = (d[mask] ** 2).sum()
    if den == 0:
        return None
    return [float(((f - before)[mask] * d[mask]).sum() / den) for f in fr]


def bez(x, x1=0.42, y1=0.0, x2=0.58, y2=1.0):
    lo, hi = 0.0, 1.0
    for _ in range(30):
        t = (lo + hi) / 2
        if 3 * (1 - t) ** 2 * t * x1 + 3 * (1 - t) * t * t * x2 + t ** 3 < x:
            lo = t
        else:
            hi = t
    t = (lo + hi) / 2
    return 3 * (1 - t) ** 2 * t * y1 + 3 * (1 - t) * t * t * y2 + t ** 3


def dispatch(name):
    subprocess.run(["hyprctl", "dispatch", f'hl.dsp.global("hyprk:{name}")'], capture_output=True)


def is_open():
    return "hyprk-switcher" in subprocess.run(["hyprctl", "layers"], capture_output=True, text=True).stdout


def main():
    keep = sys.argv[sys.argv.index("--keep") + 1] if "--keep" in sys.argv else ""
    lc.session("cmd-tab")
    state = os.environ.get("HYPRK_STATE", "")
    if not state or os.path.realpath(state) == os.path.realpath(os.path.join(lc.ROOT, "state")):
        sys.exit("cmd-tab: export the session's scratch HYPRK_STATE (never the repo's state folder)")
    if not shutil.which("foot"):
        sys.exit("cmd-tab: needs foot for the six test windows")
    if [c for c in lc.clients() if c["class"] not in ("", "hyprk-finder")]:
        sys.exit("cmd-tab: close the session's windows first (the check opens its own six)")
    if keep:
        os.makedirs(keep, exist_ok=True)
    tmp = tempfile.mkdtemp(prefix="cmd-tab-")
    path = os.path.join(state, "appearance.json")
    before_cfg = open(path).read() if os.path.exists(path) else None
    procs, fails = [], 0
    region = (OUR_AT[0] // 2 - 10, OUR_AT[1] // 2 - 10, PW // 2 + 20, PH // 2 + 20)
    cmd = lambda *names: "; ".join(f"hyprctl dispatch 'hl.dsp.global(\"hyprk:{n}\")'" if not n.startswith("sleep") else n for n in names)

    def cap(name, seconds, trigger):
        prefix = os.path.join(tmp, name)
        lc.mcap_start(prefix, region, seconds, 2, trigger).wait(timeout=30)
        return lc.frames(prefix)

    try:
        for i, a in enumerate(APPS):
            procs.append(subprocess.Popen(["foot", f"--app-id={a}", "-T", a, "sleep", "100000"],
                                          stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, start_new_session=True))
            for _ in range(50):
                if lc.clients(a):
                    break
                time.sleep(0.1)
            w = f'window="class:{a}"'
            # small, in the top left corner: clear of the panel, so its glass is over the wallpaper as in the Mac's stills
            for d in (f"hl.dsp.window.resize({{x=160, y=90, exact=true, {w}}})", f"hl.dsp.window.move({{x={20 + 12 * i}, y={50 + 8 * i}, {w}}})"):
                subprocess.run(["hyprctl", "dispatch", d], capture_output=True)
        time.sleep(1.0)
        for mode in ("light", "dark"):
            cfg = json.loads(before_cfg) if before_cfg else {}
            cfg["mode"], cfg["dark"] = mode, mode == "dark"
            open(path, "w").write(json.dumps(cfg, indent=2))
            time.sleep(3.0)

            # appear: one frame, SHOW_MS after the key
            t, fr = cap("appear", 0.7, cmd("switcher"))
            s = share(fr, fr[0], fr[-1])
            if s is None or not is_open():
                fails += lc.report(False, f"{mode}: appear", "no panel")
                continue
            part = [f"{v:.2f}" for v in s if 0.03 < v < 0.97]
            at = next(t[i] for i, v in enumerate(s) if v >= 0.97)
            fails += lc.report(not part and abs(at - SHOW_MS) <= SHOW_TOL, f"{mode}: appear",
                               f"complete at {at:.0f} ms (Mac {SHOW_MS}), frames in between: {' '.join(part) or 'none'}")

            # geometry, on a still of the open panel (the second app selected, as in the Mac's)
            time.sleep(0.4)
            ours = crop(lc.grim(), OUR_AT)
            mac = crop(np.asarray(Image.open(REF % mode).convert("RGB")).astype(int), MAC_AT)
            if keep:
                Image.fromarray(np.concatenate([mac, ours], axis=0).astype(np.uint8)).save(
                    os.path.join(keep, f"cmd-tab-{mode}-mac-above-ours-below.png"))
            mo, mm = measure(ours, mode), measure(mac, mode)
            bad = [k for k in mm if k not in mo or abs(mo[k] - mm[k]) > TOL.get(k, 1)]
            fails += lc.report(not bad, f"{mode}: geometry",
                               ", ".join(f"{k} {mo.get(k, '-')}/{mm[k]}" for k in mm) + " (ours/Mac, px at 2x; fill and level in levels)"
                               + (f"; off: {', '.join(bad)}" if bad else ""))

            # step: a jump
            t, fr = cap("step", 0.4, cmd("switcher-next"))
            s = share(fr, fr[0], fr[-1])
            part = [f"{v:.2f}" for v in (s or []) if 0.03 < v < 0.97]
            fails += lc.report(s is not None and not part, f"{mode}: step",
                               "no change" if s is None else f"on the next icon at {next(t[i] for i, v in enumerate(s) if v >= 0.97):.0f} ms, frames in between: {' '.join(part) or 'none'}")

            # cancel: gone in one frame
            t, fr = cap("cancel", 0.5, cmd("switcher-cancel"))
            s = share(fr, fr[0], fr[-1])
            part = [f"{v:.2f}" for v in (s or []) if 0.03 < v < 0.97]
            fails += lc.report(s is not None and not part and not is_open(), f"{mode}: cancel",
                               "no change" if s is None else f"gone at {next(t[i] for i, v in enumerate(s) if v >= 0.97):.0f} ms, frames in between: {' '.join(part) or 'none'}")

            # release: the Mac's fade
            time.sleep(0.5)
            dispatch("switcher")
            time.sleep(0.8)
            t, fr = cap("release", 0.7, cmd("switcher-commit"))
            s = share(fr, fr[0], fr[-1])
            if s is None:
                fails += lc.report(False, f"{mode}: release", "no change")
            else:
                left = [100 * (1 - v) for v in s]
                i0 = next(i for i, v in enumerate(left) if v < 99.5) - 1      # the last full frame
                best = None
                for dur in np.arange(0.15, 0.40, 0.002):
                    for ph in np.arange(0, 0.017, 0.002):
                        e = [(100 * (1 - bez(min(1.0, max(0.0, ((t[i] - t[i0]) / 1000 - ph) / dur)))) - left[i]) ** 2
                             for i in range(i0, len(left))]
                        r = (sum(e) / len(e)) ** 0.5
                        if best is None or r < best[0]:
                            best = (r, dur)
                # against the Mac's frames: ours read at the Mac's frame times, the phase free (our first frame of the fade is not the Mac's)
                def at_ms(ms):
                    return float(np.interp(ms, t[i0:] - t[i0], left[i0:]))
                vs = min((sum((at_ms(ph + (k + 1) * 1000 / 60) - m) ** 2 for k, m in enumerate(MAC_FADE)) / len(MAC_FADE)) ** 0.5
                         for ph in np.arange(-34, 34.1, 1))
                fails += lc.report(abs(best[1] - 0.246) <= 0.02 and best[0] < 3 and vs < 4, f"{mode}: release",
                                   f"ease-in-out over {best[1]:.3f} s (Mac 0.246 / 0.242), rms {best[0]:.1f} %; against the Mac's frames rms {vs:.1f} %; "
                                   + " ".join(f"{v:.0f}" for v in left[i0 + 1:i0 + 15]))

            # quick tap: released before the panel is due
            time.sleep(0.6)
            t, fr = cap("tap", 0.6, cmd("switcher", "sleep 0.06", "switcher-commit"))
            d = max(float(np.abs(f - fr[0]).max()) for f in fr)
            fails += lc.report(d <= 6 and not is_open(), f"{mode}: quick tap", f"largest change in the panel's area {d:.0f} levels (Mac: no changed frame)")
            time.sleep(0.5)
    finally:
        if is_open():
            dispatch("switcher-cancel")
        if before_cfg is None:
            os.path.exists(path) and os.remove(path)
        else:
            open(path, "w").write(before_cfg)
        for p in procs:
            p.terminate()
        shutil.rmtree(tmp, ignore_errors=True)
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
