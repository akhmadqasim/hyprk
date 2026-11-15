#!/usr/bin/env python3
"""Live check: the white fill inside the held Control Center Sound lens (dark), against the Mac's two frames:

  static hold   reference/re/27.2.1/live/glass-r9/cc-sound-held-dark.png (MAC-ANSWERS-9.md R9.6: a screenshot of the
                real knob pressed and not moved): the reference of this check
  drag          frame 3 of reference/screens/27.2.1/panels/cc-sound-slider-rest-hover-drag-overdrag-dark-grey127.png
                (a 60 fps video frame of the knob being dragged, the judges' 223-224): printed, not judged. It is 5-10
                levels lighter than the Mac's own static hold; see OPEN-FIXES.md item 19 for the capture that decides
                whether that is the drag or the video

Per column of the fill's rows from the lens's inner left edge to the fill's end (the columns of the lens over the
fill), the mean of the rows; ours is a hold of the knob (pressed, then the pointer moved straight up off the lens so
the cursor is out of the crop, 1 s).

Round 18 (MAC-ANSWERS-18.md R18.3, reference/re/27.2.1/live/r18/cc-sound-{dark-dark,dark-blue,light-white,light-blue}-
{idle,hover,held,drag1,drag2,drag3}.png: lossless stills of the real module, the knob at the fill end): the same six
states of ours over the same flat wallpapers, the pointer on the knob (the session's cursor is hidden for the shots),
the drag at the Mac's 15 pt/s. Judged against the stills, which the same code reads:
  - idle, hover, held: the module's glass and the track beside the knob (the Mac's module is 7 levels lighter while
    hovered and about 3.5 % more while held);
  - hover: the module under the white knob, 8 px down (the knob's shadow);
  - held and the three drag stills: the lens's rim (columns and rows of its line) and the white fill inside it per
    column. The Mac's fill is the same held and dragged (dark: 221.0 held, 220.1 / 220.7 / 220.2 dragged): the 223-224
    of the older video frame was the video.

Session: see livecheck.py, HYPRK_AUDIO_STUB=1 (the real volume is never touched), no window under the Control Center.
Round 18 needs the session's scratch HYPRK_STATE (wallpaper.json and appearance.json are set there and put back) and a
dark appearance for the first case.

  cc-lens-fill.py [--keep FILE.png | --keep DIR] [--only r18|r9]      exit 0 = every case passed
"""
import json, os, subprocess, sys, time

import numpy as np

import livecheck as lc

R96 = os.path.join(lc.ROOT, "reference/re/27.2.1/live/glass-r9/cc-sound-held-dark.png")
DRAG = os.path.join(lc.ROOT, "reference/screens/27.2.1/panels/cc-sound-slider-rest-hover-drag-overdrag-dark-grey127.png")


def fill(c):
    """c: grey crop whose left columns are the fill outside the lens. Returns (per column means over the fill's rows,
    box mean, the fill left of the lens)"""
    left = c[:, :3].mean(axis=1)
    rows = np.nonzero(left > 240)[0]                        # (240: a light module under the pointer reads up to 203)
    r0, r1 = rows.min(), rows.max()
    row = c[(r0 + r1) // 2]
    lx = int(np.nonzero(row < 200)[0][0])                   # the rim
    ins = lx + int(np.nonzero(row[lx:] > 200)[0][0])        # first column inside
    # the fill's end: the first step down of over 10 levels (the fill falls by 3 a column at most; behind it the
    # track through the lens, 80 in dark and 185 over a white wallpaper)
    end = ins + 1 + int(np.nonzero(np.diff(row[ins:]) < -10)[0][0])
    box = c[r0:r1 + 1, ins:end]
    return box.mean(axis=0), float(box.mean()), float(c[r0 + 1:r1, :max(1, lx - 2)].mean())


R18 = os.path.join(lc.ROOT, "reference/re/27.2.1/live/r18")
R18_COMBOS = (("dark", "dark", (30, 30, 32)), ("dark", "blue", (0, 0, 245)), ("light", "white", (255, 255, 255)),
              ("light", "blue", (0, 0, 245)))
R18_STATES = ("idle", "hover", "held", "drag1", "drag2", "drag3")
SOUND_Y = 468      # pt, the Sound slider's centre row on the 1280 x 832 screen


class FinePointer(lc.Pointer):
    """lc.Pointer in quarter points (vptr's coordinates are whole numbers of its layout box: a box 4 x the screen),
    for a drag as smooth as the Mac's: 1 pt steps every 66 ms jerk the elastic lens"""

    def __init__(self):
        self.p = subprocess.Popen([lc.VPTR, str(4 * lc.W), str(4 * lc.H)], stdin=subprocess.PIPE, text=True,
                                  stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        time.sleep(0.3)

    def move(self, x, y, ms=0):
        self.send(f"{4 * x:.0f} {4 * y:.0f} {ms}")


def fill_end(crop):
    """the fill's end on the slider's centre row (row 80 of a 520 x 160 crop): the last white px left of column 400"""
    row = crop[80].sum(axis=1) / 3.0
    return 100 + int(np.argmax(row[100:400] <= 250)) - 1


def r18_read(shots):
    """shots: {state: 520 x 160 x 3 crop, the slider's centre on row 80}. Returns the numbers the cases compare"""
    kx = fill_end(shots["idle"])
    out = {"kx": kx}
    for st in ("idle", "hover", "held"):
        out[st] = (tuple(shots[st][30, kx + 80]), tuple(shots[st][80, kx + 150]))        # module, track
    h = shots["hover"].sum(axis=2) / 3.0
    bot = 40 + int(np.nonzero(h[40:120, kx] > 245)[0].max())
    out["knob"] = (40 + int(np.nonzero(h[40:120, kx] > 245)[0].min()), bot)
    out["shadow"] = h[bot + 1:bot + 9, kx] - h[30, kx + 80]                             # under the knob, less the module
    for st in ("held", "drag1", "drag2", "drag3"):
        g = shots[st].sum(axis=2) / 3.0
        row = g[80]
        lx = 150 + int(np.nonzero(row[150:] < 200)[0][0])
        rx = lx + 35 + int(row[lx + 35:lx + 62].argmin())
        col = g[:, (lx + rx) // 2]
        top, bottom = 30 + int(col[30:75].argmin()), 85 + int(col[85:125].argmin())
        cols, _, _ = fill(g[60:100, lx - 25:lx + 70])
        out[st + "-lens"] = (lx - kx if st == "held" else 0, rx - lx, top, bottom, cols)
    return out


def r18(pid, keep):
    from PIL import Image
    state = os.environ.get("HYPRK_STATE", "")
    if not state or os.path.realpath(state) == os.path.realpath(os.path.join(lc.ROOT, "state")) \
            or f"HYPRK_STATE={state}".encode() not in lc.environ(pid):
        sys.exit("cc-lens-fill: export the session's scratch HYPRK_STATE (round 18 sets the wallpaper and the appearance there)")
    import tempfile
    tmp = tempfile.mkdtemp(prefix="cc-lens-")
    files = {n: os.path.join(state, n + ".json") for n in ("wallpaper", "appearance")}
    before = {n: open(f).read() if os.path.exists(f) else None for n, f in files.items()}
    hide = lambda on: subprocess.run(["hyprctl", "eval", "hl.config({cursor={invisible=%s}})" % ("true" if on else "false")],
                                     capture_output=True)
    fails = 0
    ptr = FinePointer()
    try:
        hide(True)
        todo, again = list(R18_COMBOS), set()
        for mode, name, rgb in todo:
            cfg = json.loads(before["appearance"]) if before["appearance"] else {}
            cfg["mode"], cfg["dark"] = mode, mode == "dark"
            open(files["appearance"], "w").write(json.dumps(cfg, indent=2))
            path = os.path.join(tmp, name + ".png")
            Image.new("RGB", (2560, 1664), rgb).save(path)
            json.dump({"path": path}, open(files["wallpaper"], "w"))
            stub_volume("0.500000 0\n")                     # the drag of the combination before moved it
            time.sleep(3.4)
            lc.ipc(pid, "panels", "close")
            lc.ipc(pid, "panels", "toggle", "cc")
            time.sleep(1.5)
            ptr.move(1100, SOUND_Y + 92)
            ptr.move(1100, SOUND_Y + 60, 60)                 # idle: 60 pt below the slider, off the module
            time.sleep(0.8)
            full = lc.grim()
            row = full[SOUND_Y * 2].sum(axis=1) / 3.0
            run = np.nonzero(row[2000:2400] > 250)[0]
            if len(run) < 20:
                fails += lc.report(False, f"r18 {mode} over {name}", "no Sound slider fill on its row")
                lc.ipc(pid, "panels", "close")
                continue
            run = max(np.split(run, np.nonzero(np.diff(run) > 1)[0] + 1), key=len)      # the fill, not the glyphs beside it
            end = 2000 + int(run.max())                      # the fill's end, px; the Mac's crop has it at column 220
            x0, kx = end - 220, (end + 1) // 2
            if x0 + 520 > full.shape[1]:
                fails += lc.report(False, f"r18 {mode} over {name}", f"the stub's volume is too high for the crop (fill end at {end / 2:.0f} pt)")
                lc.ipc(pid, "panels", "close")
                continue
            crop = lambda: lc.grim()[SOUND_Y * 2 - 80:SOUND_Y * 2 + 80, x0:x0 + 520]
            shots = {"idle": full[SOUND_Y * 2 - 80:SOUND_Y * 2 + 80, x0:x0 + 520]}
            ptr.move(kx, SOUND_Y + 20, 60)
            ptr.move(kx, SOUND_Y, 80)
            time.sleep(0.8)
            shots["hover"] = crop()
            ptr.down()
            time.sleep(1.0)
            shots["held"] = crop()
            t0 = time.time()
            for i in range(1, 241):                          # 15 pt/s, as the Mac's: vptr waits 16 ms after each step
                ptr.move(kx + i / 4, SOUND_Y, 16)
            for st, at in (("drag1", 1.0), ("drag2", 1.6), ("drag3", 2.2)):
                time.sleep(max(0, at - (time.time() - t0)))
                shots[st] = crop()
            time.sleep(max(0, 4.6 - (time.time() - t0)))     # the drag has ended
            for i in range(60, -1, -4):
                ptr.move(kx + i, SOUND_Y, 20)
            time.sleep(1.0)
            ptr.up()
            time.sleep(0.4)
            ptr.move(900, 700)
            lc.ipc(pid, "panels", "close")
            time.sleep(3.0)                                  # the stub sink's file catches up with the drag (Audio.qml)
            if keep and os.path.isdir(keep):
                for st, im in shots.items():
                    Image.fromarray(im.astype(np.uint8)).save(os.path.join(keep, f"cc-sound-{mode}-{name}-{st}.png"))
            mac = r18_read({st: np.asarray(Image.open(os.path.join(R18, f"cc-sound-{mode}-{name}-{st}.png")).convert("RGB")).astype(int)
                            for st in R18_STATES})
            try:
                ours = r18_read(shots)
            except (IndexError, ValueError):
                # one more take of this combination: a shot taken while the wallpaper was still changing reads no lens
                # (seen once in four runs)
                if name + mode not in again:
                    again.add(name + mode)
                    todo.append((mode, name, rgb))
                    continue
                fails += lc.report(False, f"r18 {mode} over {name}", "knob or lens not found")
                continue
            tag = f"r18 {mode} over {name}"
            f3 = lambda c: "/".join(str(int(v)) for v in c) if max(c) - min(c) > 2 else str(int(c[0]))
            for st, tol in (("idle", 2), ("hover", 2), ("held", 6 if name == "white" else 3)):
                d = max(np.abs(np.array(ours[st][i]) - mac[st][i]).max() for i in (0, 1))
                fails += lc.report(d <= tol, f"{tag}: {st} module / track", f"{f3(ours[st][0])} / {f3(ours[st][1])} (Mac {f3(mac[st][0])} / {f3(mac[st][1])})")
            d = float(np.abs(ours["shadow"] - mac["shadow"]).max())
            fails += lc.report(d <= 3 and ours["knob"] == mac["knob"], f"{tag}: hover knob",
                               f"rows {ours['knob'][0]}..{ours['knob'][1]} (Mac {mac['knob'][0]}..{mac['knob'][1]}); under it "
                               + " ".join(f"{v:+.0f}" for v in ours["shadow"]) + " (Mac " + " ".join(f"{v:+.0f}" for v in mac["shadow"]) + ")")
            means = {}
            for st in ("held", "drag1", "drag2", "drag3"):
                (ol, ow, ot, ob, oc), (ml, mw, mt, mb, mc) = ours[st + "-lens"], mac[st + "-lens"]
                # from each one's lightest column (the first whole pixel inside the rim) to 3 before the shorter one's
                # end. The lens lies on another part of a pixel in every still, the Mac's too (its own four read 220.1
                # to 221.4), and the fill falls 2.5 levels a pixel: ours is read at the shift within a pixel that fits
                # the Mac's columns best (where the lens is, is the rim's case)
                oc, mc = oc[int(oc[:4].argmax()):], mc[int(mc[:4].argmax()):]
                n = min(len(oc), len(mc)) - 3
                m = mc[:n]
                o = min((np.interp(np.arange(n) + sh, np.arange(len(oc)), oc) for sh in np.linspace(-1, 1, 21)),
                        key=lambda v: float(np.mean((v - m) ** 2)))
                rms = float(np.sqrt(np.mean((o - m) ** 2)))
                means[st] = (float(o.mean()), float(m.mean()))
                geo = abs(ow - mw) <= 1 and abs(ot - mt) <= 1 and abs(ob - mb) <= 1 and abs(ol - ml) <= 1
                fails += lc.report(geo and rms <= 2 and abs(o.mean() - m.mean()) <= 1.5, f"{tag}: {st} lens",
                                   f"rim {ow} px wide, rows {ot}..{ob} (Mac {mw}, {mt}..{mb}); fill inside mean {o.mean():.1f} "
                                   f"against {m.mean():.1f}, rms {rms:.1f}")
            od = np.mean([means[s][0] for s in ("drag1", "drag2", "drag3")]) - means["held"][0]
            md = np.mean([means[s][1] for s in ("drag1", "drag2", "drag3")]) - means["held"][1]
            fails += lc.report(abs(od - md) <= 1.5, f"{tag}: fill, drag against hold",
                               f"the three drag stills {od:+.1f} against the hold (Mac {md:+.1f})")
    finally:
        ptr.up()
        ptr.move(900, 700)
        ptr.close()
        hide(False)
        lc.ipc(pid, "panels", "close")
        for n, f in files.items():
            if before[n] is None:
                if os.path.exists(f):
                    os.remove(f)
            else:
                open(f, "w").write(before[n])
        for f in os.listdir(tmp):
            os.remove(os.path.join(tmp, f))
        os.rmdir(tmp)
        time.sleep(3.0)
    return fails


def stub_sink():
    return os.path.join(os.environ["XDG_RUNTIME_DIR"], "hyprk-volkey-" + os.environ["HYPRLAND_INSTANCE_SIGNATURE"], "stub-sink")


def stub_volume(text):
    """the stub sink's level, written as volume-key.sh writes it (a rename; Audio.qml follows the file). The cases
    need the knob in the middle of the track: after another check had left the stub near an end, the lens was not
    found (JUDGE-95-25: the r18 cases failed in the first run and passed in the next two)"""
    f = stub_sink()
    os.makedirs(os.path.dirname(f), exist_ok=True)
    open(f + ".tmp", "w").write(text)
    os.replace(f + ".tmp", f)
    time.sleep(0.6)


def main():
    from PIL import Image
    keep = sys.argv[sys.argv.index("--keep") + 1] if "--keep" in sys.argv else None
    only = sys.argv[sys.argv.index("--only") + 1] if "--only" in sys.argv else ""
    pid = lc.session("cc-lens-fill", ("HYPRK_AUDIO_STUB=1",))
    level = open(stub_sink()).read() if os.path.exists(stub_sink()) else "0.500000 0\n"
    try:
        return run(pid, keep, only)
    finally:
        stub_volume(level)


def run(pid, keep, only):
    from PIL import Image
    stub_volume("0.500000 0\n")
    fails18 = 0 if only == "r9" else r18(pid, keep)
    if only == "r18":
        return fails18
    stub_volume("0.500000 0\n")
    # the static hold's still is dark over grey 127: set here, not left to the session (over another wallpaper the
    # fill reads 2.6 lower and the case failed)
    state = os.environ.get("HYPRK_STATE", "")
    if not state or os.path.realpath(state) == os.path.realpath(os.path.join(lc.ROOT, "state")):
        sys.exit("cc-lens-fill: export the session's scratch HYPRK_STATE")
    import tempfile
    files = {n: os.path.join(state, n + ".json") for n in ("wallpaper", "appearance")}
    before = {n: open(f).read() if os.path.exists(f) else None for n, f in files.items()}
    grey = tempfile.mkdtemp(prefix="cc-lens-")
    Image.new("RGB", (2560, 1664), (127, 127, 127)).save(os.path.join(grey, "grey.png"))
    cfg = json.loads(before["appearance"]) if before["appearance"] else {}
    cfg["mode"], cfg["dark"] = "dark", True
    open(files["appearance"], "w").write(json.dumps(cfg, indent=2))
    json.dump({"path": os.path.join(grey, "grey.png")}, open(files["wallpaper"], "w"))
    time.sleep(4.0)
    try:
        return hold(pid, keep, fails18)
    finally:
        for n, f in files.items():
            if before[n] is None:
                os.path.exists(f) and os.remove(f)
            else:
                open(f, "w").write(before[n])
        os.remove(os.path.join(grey, "grey.png"))
        os.rmdir(grey)
        time.sleep(2.0)


def hold(pid, keep, fails18):
    from PIL import Image
    mac = np.asarray(Image.open(R96).convert("L")).astype(int)[40:110, 170:240]
    drag = np.asarray(Image.open(DRAG).convert("L")).astype(int)[320:400, 130:220]
    mcol, mmean, mout = fill(mac)
    dcol, dmean, _ = fill(drag)
    if lc.ipc(pid, "panels", "current") != "cc":
        lc.ipc(pid, "panels", "close")
        lc.ipc(pid, "panels", "toggle", "cc")
        time.sleep(1.5)
    ptr = lc.Pointer()
    try:
        ptr.move(1090, 468)
        ptr.move(1100, 468, 80)
        time.sleep(0.4)
        ptr.down()
        time.sleep(0.5)
        ptr.move(1100, 400, 80)
        time.sleep(0.5)
        img = lc.grim()
    finally:
        ptr.up()
        time.sleep(0.3)
        ptr.move(640, 700)
        ptr.close()
        lc.ipc(pid, "panels", "close")
    if keep and not os.path.isdir(keep):
        Image.fromarray(img[890:970, 2150:2260].astype(np.uint8)).save(keep)
    try:
        ocol, omean, oout = fill(img[890:970, 2170:2260].sum(axis=2) / 3.0)
    except (IndexError, ValueError):
        return (lc.report(False, "held lens", "no lens over the fill at (1100, 468) pt") or 1) + fails18
    # the columns well inside: from the 2nd inside column to 3 before the fill's end (the end falls on another part of
    # a pixel in each capture)
    n = min(len(ocol), len(mcol), len(dcol)) - 3
    m, d = mcol[1:n], dcol[1:n]
    # ours at the shift within a pixel that fits the Mac's columns best, as the round 18 cases read it: the fill falls
    # 2.5 levels a pixel and the lens lies on another part of a pixel by where the knob stood (218.3 to 221.0 for one
    # and the same lens: the case failed or passed with the stub's volume)
    o = min((np.interp(np.arange(1, n) + sh, np.arange(len(ocol)), ocol) for sh in np.linspace(-1, 1, 21)),
            key=lambda v: float(np.mean((v - m) ** 2)))
    rms = float(np.sqrt(np.mean((o - m) ** 2)))
    fails = lc.report(rms <= 3 and abs(o.mean() - m.mean()) <= 2.5, "fill inside the held lens, static hold",
                      f"columns {' '.join(f'{v:.0f}' for v in o)}; Mac {' '.join(f'{v:.0f}' for v in m)}: "
                      f"mean {o.mean():.1f} against {m.mean():.1f}, rms {rms:.1f}; whole box {omean:.1f} / {mmean:.1f}; "
                      f"fill left of the lens {oout:.0f} / {mout:.0f}")
    print(f"note the Mac's drag frame (video): columns {' '.join(f'{v:.0f}' for v in d)}, mean {d.mean():.1f}, whole box {dmean:.1f} "
          f"(ours {o.mean() - d.mean():+.1f}; the Mac's static hold {m.mean() - d.mean():+.1f})")
    return fails + fails18


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
