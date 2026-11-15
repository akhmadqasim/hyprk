#!/usr/bin/env python3
"""Live check: a real pointer drag onto each end of the Control Center Display and Sound sliders bounces that end's
glyph (SF Symbols .bounce by layer, INTERACTIVE-GLASS-REA.md 8), slow and as a fast slam.

Run inside a HEADLESS test session started with
  HYPRK_AUDIO_STUB=1 HYPRK_STATUS_STUB=1 HYPRK_BRIGHTNESS_STUB=1 HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh out.png
and its printed WAYLAND_DISPLAY / HYPRLAND_INSTANCE_SIGNATURE exported (1280x832 logical at scale 2). The stubs keep
the real volume and backlight untouched; the script refuses a shell without them. It drives the pointer with
scripts/vptr and reads the glyph per frame with mcap: the ink's height (bright pixels in the glyph's columns clear of
the knob's lens) has to rise to 1.15x or more of its height at rest and fall to 0.95x or less after that.

  slider-glyphs.py [--keep DIR] [--only NAME]     exit 0 = every case passed
"""
import json, os, subprocess, sys, tempfile, time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
MCAP = os.path.join(HERE, "build", "mcap")
# the user's own cache, also when the caller runs with the session's scratch HOME; VPTR=path overrides
VPTR = os.environ.get("VPTR") or os.path.join(__import__("pwd").getpwuid(os.getuid()).pw_dir, ".cache/hyprk/vptr")
DROP = 45          # the held pointer is moved this far below the track, clear of the glyphs

# Control Center on the 1280x832 output (grid module rows; shell Theme.cc): track x0..x1 and y, the glyphs' centres
# and the columns (pt, from the glyph centre) read for the ink: clear of the held lens at that end
SLIDERS = {
    "display": {"y": 392, "x0": 1011, "x1": 1228, "low": 996.5, "high": 1241.5, "lowCols": (-12, 4), "highCols": (-4, 12)},
    "sound": {"y": 468, "x0": 1011, "x1": 1191, "low": 996.5, "high": 1204.0, "lowCols": (-7, 3.5), "highCols": (-4, 13)},
}


def shell_pid():
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
    for p in subprocess.run(["pgrep", "-x", "qs"], capture_output=True, text=True).stdout.split():
        try:
            env = open(f"/proc/{p}/environ", "rb").read().split(b"\0")
        except OSError:
            continue
        if f"HYPRLAND_INSTANCE_SIGNATURE={sig}".encode() in env:
            need = [b"HYPRK_HEADLESS=1", b"HYPRK_BRIGHTNESS_STUB=1"]
            if all(n in env for n in need) and (b"HYPRK_AUDIO_STUB=1" in env or b"HYPRK_STATUS_STUB=1" in env):
                return p
            sys.exit("slider-glyphs: this session's shell has no HYPRK_HEADLESS / audio / brightness stub: not driven")
    sys.exit("slider-glyphs: no shell found for HYPRLAND_INSTANCE_SIGNATURE")


def ipc(pid, *a):
    return subprocess.run(["qs", "ipc", "--pid", pid, "call", *a], capture_output=True, text=True).stdout.strip()


class Pointer:
    def __init__(self):
        self.p = subprocess.Popen([VPTR, "1280", "832"], stdin=subprocess.PIPE, text=True,
                                  stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    def send(self, line):
        self.p.stdin.write(line + "\n")
        self.p.stdin.flush()

    def close(self):
        self.p.stdin.close()
        self.p.wait(timeout=5)


def knob_x(s, value):   # the fill end; the knob stays half a knob inside the track (Slider fillToEnds)
    return min(s["x1"] - 8, max(s["x0"] + 8, s["x0"] + value * (s["x1"] - s["x0"])))


def drag_lines(s, start, end, steps, step_ms):
    """press on the knob at `start`, go to 20 pt past `end` in `steps` moves (the pointer dropping below the track)"""
    xa = knob_x(s, start)
    xb = s["x0"] - 20 if end == 0 else s["x1"] + 20
    out = [f"{xa:.0f} {s['y']} 0", "sleep 0.35", "d", "sleep 0.25"]
    for i in range(1, steps + 1):
        out.append(f"{xa + (xb - xa) * i / steps:.0f} {s['y'] + DROP} {step_ms}")
    return out, steps * step_ms / 1000


def run_case(ptr, prefix, s, end, start, steps, step_ms):
    cx = s["low"] if end == 0 else s["high"]
    region = (int(cx - 16), s["y"] - 16, 32, 32)
    lines, dur = drag_lines(s, start, end, steps, step_ms)
    cap = subprocess.Popen([MCAP, "-o", prefix, "-g", ",".join(map(str, region)), "-k", "1", "-t", f"{0.6 + dur + 1.3:.2f}",
                            "--", "true"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    time.sleep(0.15)
    for l in lines:
        if l.startswith("sleep"):
            time.sleep(float(l.split()[1]))
        else:
            ptr.send(l)
    cap.wait(timeout=20)
    ptr.send("u")
    time.sleep(0.5)
    meta = json.load(open(prefix + ".json"))
    n, w, h = meta["frames"], meta["w"], meta["h"]
    fr = np.fromfile(prefix + ".raw", dtype=np.uint8)[: n * h * w * 3].reshape(n, h, w, 3)
    k = w / region[2]
    c0, c1 = s["lowCols"] if end == 0 else s["highCols"]
    a, b = int((cx + c0 - region[0]) * k), int((cx + c1 - region[0]) * k)
    hs = []
    for f in fr:
        rows = np.nonzero((f[:, a:b].min(axis=2) > 160).sum(axis=1) >= 1)[0]
        hs.append(int(rows.max() - rows.min() + 1) if len(rows) else 0)
    return np.array(hs), fr


def judge(hs):
    rest = float(np.median(hs[-8:]))   # held at the end, the bounce over
    if rest <= 0:
        return False, "no glyph in the region"
    r = hs / rest
    ip = int(r.argmax())
    it = ip + int(r[ip:].argmin())
    ok = r[ip] >= 1.15 and r[it] <= 0.95 and abs(r[0] - 1) <= 0.08
    return ok, f"rest {rest:.0f} px, before x{r[0]:.2f}, peak x{r[ip]:.2f} (frame {ip}), trough x{r[it]:.2f} ({(it - ip) / 60:.2f} s later)"


def main():
    keep = sys.argv[sys.argv.index("--keep") + 1] if "--keep" in sys.argv else None
    only = sys.argv[sys.argv.index("--only") + 1] if "--only" in sys.argv else None
    if os.environ.get("WAYLAND_DISPLAY", "wayland-0") in ("", "wayland-0"):
        sys.exit("slider-glyphs: export the test session's WAYLAND_DISPLAY (never the host's)")
    pid = shell_pid()
    if ipc(pid, "panels", "current") != "cc":
        ipc(pid, "panels", "toggle", "cc")
        time.sleep(1.5)
    tmp = keep or tempfile.mkdtemp(prefix="slider-glyphs-")
    os.makedirs(tmp, exist_ok=True)
    ptr = Pointer()
    time.sleep(0.3)
    fails = 0
    try:
        for name, s in SLIDERS.items():
            # from the middle: slow to 0, slam to 1 from 0, slow from 1 back... each case starts where the last ended
            cases = [("low-slow", 0, None, 40, 16), ("high-slam", 1, 0, 2, 16), ("low-slam", 0, 1, 2, 16), ("high-slow", 1, 0, 40, 16)]
            for label, end, start, steps, ms in cases:
                case = f"{name}-{label}"
                if only and only != case and only != name:
                    continue
                if start is None:   # a known start: click the track's middle
                    ptr.send(f"{knob_x(s, 0.5):.0f} {s['y']} 0"); time.sleep(0.3); ptr.send("b"); time.sleep(0.6)
                    start = 0.5
                hs, _ = run_case(ptr, os.path.join(tmp, case), s, end, start, steps, ms)
                ok, note = judge(hs)
                fails += not ok
                print(("ok   " if ok else "FAIL ") + case + ": " + note)
                if not keep:
                    for ext in (".raw", ".csv", ".json"):
                        os.remove(os.path.join(tmp, case) + ext)
    finally:
        ptr.send("640 600 0")
        ptr.close()
        if not keep:
            os.rmdir(tmp)
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()
