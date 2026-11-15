#!/usr/bin/env python3
"""Live check: the Finder's QML, as the running binary shows it. finder/build/hyprk-finder holds no QML: it loads
$HYPRK_ROOT/finder/qml/Main.qml (or the checkout's finder/qml, FINDER_QML_DIR) from disk at start, so a QML file newer
than the binary is what a newly started Finder draws, and needs no build (JUDGE-95-25 took it for a stale binary).

Cases, each in a Finder this check starts inside the test session (the session shell's environment) and ends by pid:
  disk     a scratch copy of finder/qml with another window title, given as HYPRK_ROOT: the same binary shows it
  gallery  Gallery view, 1000 x 700 pt, dark, path bar, the first of 8 items selected, against
           screens/27.2.1/finder/gallery/gallery-1000x700-first-jpg-dark.png: the preview's box, the selected
           thumbnail's plate and the strip's thumbnails (the folder holds pictures of the Mac's sizes)
  wheel    hyprk-finder --wheel-test: a wheel notch scrolls every scroll view (its own exit code), in the session
  sheet    the rename sheet, light and dark, 920 x 560 pt with the path bar, against screens/27.2.1/finder/
           sheet-{light,dark}.png: the close light over the veil, the veiled strip, content, sidebar and path bar
  search, menus   search-press.py and toolbar-menus.py on a 936 x 594 Finder of this check's

Session: see livecheck.py. HYPRK_STATE must be the session's scratch state (appearance.json is switched and put back;
wallpaper.json is set aside: the Mac's stills are over the Tahoe wallpaper, the shell's default).

  finder-live.py [disk gallery wheel sheet search menus]      exit 0 = every case passed
"""
import json, os, shutil, subprocess, sys, tempfile, time, zipfile

import numpy as np
from PIL import Image

import livecheck as lc

BIN = os.path.join(lc.ROOT, "finder/build/hyprk-finder")
SHOTS = os.path.join(lc.ROOT, "reference/screens/27.2.1/finder")


def folder(tmp):
    """the Mac's dummy folder (gallery/INDEX.md): 8 items, flat pictures of its sizes"""
    g = os.path.join(tmp, "hyprk-gallery")
    os.makedirs(os.path.join(g, "Projects"))
    for name, size, col in (("Alpine.jpg", (1600, 1067), (70, 110, 160)), ("Bloom.png", (1067, 1600), (200, 90, 140)),
                            ("Coast.jpg", (1600, 1067), (60, 140, 170)), ("Dunes.jpg", (1067, 1600), (210, 170, 110)),
                            ("Brochure.pdf", (612, 792), (255, 255, 255))):
        Image.new("RGB", size, col).save(os.path.join(g, name))
    open(os.path.join(g, "Notes.txt"), "w").write("Notes\n\nA plain text file.\n")
    zipfile.ZipFile(os.path.join(g, "Archive.zip"), "w").writestr("a.txt", "a")
    return g


class Finder:
    def __init__(self, pid, args, **env):
        for c in lc.clients("hyprk-finder"):
            sys.exit("finder-live: close the session's other Finder windows first (pid %d)" % c["pid"])
        self.p = lc.launch(pid, [BIN] + args, **env)
        win = lc.wait_client("hyprk-finder")
        self.win = win[0] if win else None
        if self.win:
            lc.front("address:" + self.win["address"])
            time.sleep(1.2)
            self.win = lc.clients("hyprk-finder")[0]

    def shot(self):
        (x, y), (w, h) = self.win["at"], self.win["size"]
        return lc.grim()[y * 2:(y + h) * 2, x * 2:(x + w) * 2]

    def close(self):
        self.p.terminate()
        try:
            self.p.wait(timeout=5)
        except subprocess.TimeoutExpired:
            self.p.kill()
        end = time.time() + 5
        while lc.clients("hyprk-finder") and time.time() < end:
            time.sleep(0.2)


def set_mode(path, base, mode):
    cfg = json.loads(base)
    cfg["mode"], cfg["dark"] = mode, mode == "dark"
    open(path, "w").write(json.dumps(cfg, indent=2))
    time.sleep(2.0)


def disk_case(pid, tmp, g):
    root = os.path.join(tmp, "root")
    os.makedirs(os.path.join(root, "finder"))
    shutil.copytree(os.path.join(lc.ROOT, "finder/qml"), os.path.join(root, "finder/qml"))
    for d in ("ui", "themes", "shell", "settings", "sounds"):     # what the Finder reads beside its own QML
        os.symlink(os.path.join(lc.ROOT, d), os.path.join(root, d))
    main = os.path.join(root, "finder/qml/Main.qml")
    src = open(main).read()
    if src.count("    title: fm.title\n") != 1:
        return lc.report(False, "disk", "Main.qml has no `title: fm.title` line to change")
    open(main, "w").write(src.replace("    title: fm.title\n", '    title: "qml read from disk"\n'))
    f = Finder(pid, [g], HYPRK_ROOT=root)
    title = f.win["title"] if f.win else "(no window)"
    f.close()
    newer = [n for n in sorted(os.listdir(os.path.join(lc.ROOT, "finder/qml")))
             if n.endswith(".qml") and os.path.getmtime(os.path.join(lc.ROOT, "finder/qml", n)) > os.path.getmtime(BIN)]
    return lc.report(title == "qml read from disk", "disk: the binary draws the QML files it finds at start",
                     f'title "{title}" from a changed copy of Main.qml, no build; {len(newer)} QML files of the checkout are newer than the binary, all loaded')


def runs(mask):
    out, x = [], 0
    while x < len(mask):
        if mask[x]:
            x1 = x
            while x1 < len(mask) and mask[x1]:
                x1 += 1
            if x1 - x >= 8:
                out.append((x / 2, x1 / 2))
            x = x1
        x += 1
    return out


def gallery_measure(img):
    """pt: the preview picture's box, and the thumbnails' x runs in the strip (the first is the selection plate)"""
    area = img[120:1190, 330:1500].max(axis=2) > 100
    ys, xs = np.nonzero(area)
    box = ((xs.min() + 330) / 2, (ys.min() + 120) / 2, (xs.max() + 331) / 2, (ys.max() + 121) / 2)
    band = img[1215:1345, 322:1500].max(axis=2)
    cols = runs((band > 58).sum(axis=0) > 30)
    rows = runs((band[:, :120] > 58).sum(axis=1) > 30)
    return box, [(a + 161, b + 161) for a, b in cols], [(a + 607.5, b + 607.5) for a, b in rows]


def gallery_case(pid, g, path, base):
    set_mode(path, base, "dark")
    f = Finder(pid, [g, "--view", "gallery", "--size", "1000x700", "--pathbar", "--select", "Alpine.jpg"])
    if not f.win or f.win["size"] != [1000, 700]:
        f.close()
        return lc.report(False, "gallery", "no 1000 x 700 Finder window")
    ours = f.shot()
    f.close()
    mac = np.asarray(Image.open(os.path.join(SHOTS, "gallery/gallery-1000x700-first-jpg-dark.png")).convert("RGB")).astype(int)
    (bo, co, ro), (bm, cm, rm) = gallery_measure(ours), gallery_measure(mac)
    fmt = lambda v: " ".join(f"{a:.1f}" for a in v)
    d = max(abs(a - b) for a, b in zip(bo, bm))
    fails = lc.report(d <= 1.5, "gallery: the preview's box", f"ours {fmt(bo)} / Mac {fmt(bm)} pt (max {d:.1f})")
    ok = len(co) == len(cm) == 8 and len(ro) >= 1 and len(rm) >= 1
    dp = max(abs(co[0][0] - cm[0][0]), abs(co[0][1] - cm[0][1]), abs(ro[0][0] - rm[0][0]), abs(ro[0][1] - rm[0][1])) if ok else 99
    fails += lc.report(ok and dp <= 1.5, "gallery: the selected thumbnail's plate",
                       (f"x {fmt(co[0])} y {fmt(ro[0])} / Mac x {fmt(cm[0])} y {fmt(rm[0])} pt (max {dp:.1f})" if ok else f"{len(co)} / {len(cm)} thumbnails found"))
    dc = max(abs((a[0] + a[1]) - (b[0] + b[1])) / 2 for a, b in zip(co, cm)) if ok else 99
    fails += lc.report(ok and dc <= 1.5, "gallery: the strip's 8 thumbnails",
                       ("centres " + fmt([(a + b) / 2 for a, b in co]) + " / Mac " + fmt([(a + b) / 2 for a, b in cm]) + f" pt (max {dc:.1f})") if ok else "not 8 thumbnails")
    # the inspector's material, both modes (JUDGE-95-23: light base (241,241,244) against (235,237,239))
    box = lambda im, y, x: im[y:y + 8, x:x + 8, :3].reshape(-1, 3).mean(axis=0)
    spots = ((130, 1700), (700, 1750), (1150, 1750), (900, 1540))
    for mode in ("dark", "light"):
        if mode == "light":
            set_mode(path, base, "light")
            f = Finder(pid, [g, "--view", "gallery", "--size", "1000x700", "--pathbar", "--select", "Alpine.jpg"])
            ours = f.shot()
            f.close()
            mac = np.asarray(Image.open(os.path.join(SHOTS, "gallery/gallery-1000x700-first-jpg-light.png")).convert("RGB")).astype(int)
        di = max(float(np.abs(box(ours, y, x) - box(mac, y, x)).max()) for y, x in spots)
        fails += lc.report(di <= 4, f"gallery: the inspector's material, {mode}",
                           "; ".join(" ".join(f"{v:.0f}" for v in box(ours, y, x)) + " / Mac " + " ".join(f"{v:.0f}" for v in box(mac, y, x)) for y, x in spots) + f" (max {di:.1f})")
    return fails


def wheel_case(pid, g):
    p = lc.launch(pid, [BIN, g, "--wheel-test"])
    try:
        rc = p.wait(timeout=40)
    except subprocess.TimeoutExpired:
        p.kill()
        rc = -1
    return lc.report(rc == 0, "wheel: a wheel notch scrolls every scroll view", f"hyprk-finder --wheel-test exit {rc}")


def sheet_case(pid, g, path, base):
    spots = {"strip": (16, 840), "content": (900, 1600), "sidebar": (840, 280), "path bar": (1090, 1780)}
    box = lambda im, y, x: im[y:y + 10, x:x + 10, :3].reshape(-1, 3).mean(axis=0)
    fmt = lambda v: " ".join(f"{a:.0f}" for a in v)
    fails = 0
    for mode in ("light", "dark"):
        set_mode(path, base, mode)
        f = Finder(pid, [g, "--view", "icons", "--size", "920x560", "--pathbar", "--panel", "sheet"])
        if not f.win or f.win["size"] != [920, 560]:
            f.close()
            return fails + lc.report(False, f"{mode}: sheet", "no 920 x 560 Finder window")
        ptr = lc.Pointer()
        ptr.move(f.win["at"][0] + 880, f.win["at"][1] + 500)      # off the strip, off the lights
        time.sleep(0.8)
        ptr.close()
        ours = f.shot()
        f.close()
        mac = np.asarray(Image.open(os.path.join(SHOTS, f"sheet-{mode}.png")).convert("RGB")).astype(int)
        co, cm = box(ours, 46, 46), box(mac, 46, 46)
        d = float(np.abs(co - cm).max())
        fails += lc.report(d <= 3, f"{mode}: close under the sheet", f"({fmt(co)}) / Mac ({fmt(cm)}) (max {d:.1f})")
        dv = max(float(np.abs(box(ours, y, x) - box(mac, y, x)).max()) for y, x in spots.values())
        fails += lc.report(dv <= 2, f"{mode}: the veiled window's colour",
                           "; ".join(f"{n} {fmt(box(ours, y, x))} / Mac {fmt(box(mac, y, x))}" for n, (y, x) in spots.items()) + f" (max {dv:.1f})")
    return fails


def script_case(pid, g, name):
    f = Finder(pid, [g, "--view", "icons", "--size", "936x594"])
    r = subprocess.run([sys.executable, os.path.join(lc.HERE, name)], capture_output=True, text=True)
    f.close()
    lines = [l for l in r.stdout.splitlines() if l.startswith(("ok", "FAIL"))]
    print("\n".join(lines) if lines else (r.stdout + r.stderr).strip()[-300:])
    return 0 if r.returncode == 0 else 1


def main():
    cases = [a for a in sys.argv[1:] if a in ("disk", "gallery", "wheel", "sheet", "search", "menus")] \
        or ["disk", "gallery", "wheel", "sheet", "search", "menus"]
    pid = lc.session("finder-live")
    state = os.environ.get("HYPRK_STATE", "")
    if not state or os.path.realpath(state) == os.path.realpath(os.path.join(lc.ROOT, "state")):
        sys.exit("finder-live: export the session's scratch HYPRK_STATE (never the repo's state folder)")
    if not os.path.exists(BIN):
        sys.exit("finder-live: build the Finder first (finder/run.sh --build-only)")
    home = next((e[5:].decode() for e in lc.environ(pid) if e.startswith(b"HOME=")), "")
    path, wp = os.path.join(state, "appearance.json"), os.path.join(state, "wallpaper.json")
    had = os.path.exists(path)
    base = open(path).read() if had else "{}"
    wp_before = open(wp).read() if os.path.exists(wp) else None
    if wp_before is not None:
        os.remove(wp)
    tmp = tempfile.mkdtemp(prefix="finder-live-", dir=home if os.path.isdir(home) else None)
    desk = lc.Desk()
    fails = 0
    try:
        g = folder(tmp)
        for c in cases:
            if c == "disk":
                fails += disk_case(pid, tmp, g)
            elif c == "gallery":
                fails += gallery_case(pid, g, path, base)
            elif c == "wheel":
                fails += wheel_case(pid, g)
            elif c == "sheet":
                fails += sheet_case(pid, g, path, base)
            elif c == "search":
                set_mode(path, base, "dark")
                fails += script_case(pid, g, "search-press.py")
            elif c == "menus":
                fails += script_case(pid, g, "toolbar-menus.py")
    finally:
        if had:
            open(path, "w").write(base)
        else:
            os.path.exists(path) and os.remove(path)
        if wp_before is not None:
            open(wp, "w").write(wp_before)
        desk.restore()
        shutil.rmtree(tmp, ignore_errors=True)
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
