"""Shared helpers of the live checks in this folder (dock-resize.py, toolbar-menus.py, volume-key-hud.py, mc-exit.py,
sound-timing.py, menu-blink.py, lights-colour.py, scale-lines.py, sheet-depth.py, dock-plate-sync.py, mc-pick.py,
nc-side-line.py, cc-lens-fill.py, spotlight-edge.py, apps-view.py, cmd-tab.py, mc-bar.py, dock-drag-off.py,
finder-live.py; player-latency.py
needs no session,
search-press.py, style-tiles.py, slider-glyphs.py keeps its own copy).

Every check runs inside a HEADLESS test session started with
  HOME=<scratch>/home HYPRK_AUDIO_STUB=1 HYPRK_STATUS_STUB=1 HYPRK_BRIGHTNESS_STUB=1 HYPRK_STATE=<scratch state> \
    HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh out.png
with its printed WAYLAND_DISPLAY / HYPRLAND_INSTANCE_SIGNATURE (and HYPRK_STATE) exported: 1280x832 logical at scale 2.
The pointer is scripts/vptr (real motion and buttons), frames are mcap's (build.sh) or grim's. A check refuses the
host display and a shell that is not a headless one, prints one line per case ("ok" / "FAIL") and exits 0 when all pass.
"""
import json, os, pwd, subprocess, sys, time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
MCAP = os.path.join(HERE, "build", "mcap")
# the user's own cache, also when the caller runs with the session's scratch HOME; VPTR=path overrides
VPTR = os.environ.get("VPTR") or os.path.join(pwd.getpwuid(os.getuid()).pw_dir, ".cache/hyprk/vptr")
W, H = 1280, 832


def environ(pid):
    try:
        return open(f"/proc/{pid}/environ", "rb").read().split(b"\0")
    except OSError:
        return []


def session(name, need=()):
    """the test session's shell pid; exits unless this is a headless session (and has the stubs in `need`)"""
    if os.environ.get("WAYLAND_DISPLAY", "wayland-0") in ("", "wayland-0"):
        sys.exit(f"{name}: export the test session's WAYLAND_DISPLAY (never the host's)")
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
    for p in subprocess.run(["pgrep", "-x", "qs"], capture_output=True, text=True).stdout.split():
        env = environ(p)
        if f"HYPRLAND_INSTANCE_SIGNATURE={sig}".encode() in env and any(e.startswith(b"HYPRK_ROOT=") for e in env) \
                and not any(e.startswith(b"HYPRK_SETTINGS_PANE=") for e in env) and b"shell" in open(f"/proc/{p}/cmdline", "rb").read():
            miss = [n for n in ("HYPRK_HEADLESS=1",) + tuple(need) if n.encode() not in env]
            if miss:
                sys.exit(f"{name}: this session's shell has no {' / '.join(miss)}: not driven")
            return p
    sys.exit(f"{name}: no shell found for HYPRLAND_INSTANCE_SIGNATURE")


def ipc(pid, *a):
    return subprocess.run(["qs", "ipc", "--pid", str(pid), "call", *a], capture_output=True, text=True).stdout.strip()


def clients(cls=None):
    out = json.loads(subprocess.run(["hyprctl", "clients", "-j"], capture_output=True, text=True).stdout or "[]")
    return [c for c in out if cls is None or c["class"] == cls]


def key(name, window, mods=""):
    """a key press sent to a window by the compositor (Hyprland send_shortcut), e.g. key("Escape", "class:hyprk-finder")"""
    subprocess.run(["hyprctl", "dispatch", f'hl.dsp.send_shortcut({{mods="{mods}", key="{name}", window="{window}"}})'],
                   capture_output=True)


def front(window):
    """focuses a window and brings it to the top, e.g. front("class:hyprk-finder")"""
    for d in (f'hl.dsp.focus({{window="{window}"}})', f'hl.dsp.window.alter_zorder({{mode="top", window="{window}"}})'):
        subprocess.run(["hyprctl", "dispatch", d], capture_output=True)
    time.sleep(0.5)


def launch(pid, argv, **extra):
    """starts a program inside the test session with the session shell's own environment (/proc/<shell>/environ:
    its WAYLAND_DISPLAY, bus, scratch HOME, FONTCONFIG_FILE, XDG_DATA_DIRS, QT_QPA_PLATFORM), so an app draws with the
    session's fonts and emoji and never lands on the host display. Returns the Popen: the caller kills it by pid.
    From a shell:  livecheck.py run finder/run.sh ~   |   livecheck.py run settings/run.sh"""
    env = {}
    for e in environ(pid):
        k, _, v = e.decode(errors="replace").partition("=")
        if k:
            env[k] = v
    if env.get("WAYLAND_DISPLAY", "wayland-0") in ("", "wayland-0") or "HYPRK_HEADLESS" not in env:
        sys.exit("livecheck: the shell's environment is not a headless test session's: nothing started")
    env.update({k: str(v) for k, v in extra.items()})
    return subprocess.Popen(argv, env=env, cwd=ROOT, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                            stderr=subprocess.DEVNULL, start_new_session=True)


def wait_client(cls, n=1, seconds=15):
    """waits until n windows of that class are mapped; returns them (fewer when the time runs out)"""
    end = time.time() + seconds
    while time.time() < end:
        c = [w for w in clients(cls) if w.get("mapped", True)]
        if len(c) >= n:
            return c
        time.sleep(0.2)
    return clients(cls)


class Desk:
    """an empty desktop for a check that reads the Dock, the menu bar or the HUD against the wallpaper: every window
    on the active workspace is moved to workspace 9 without following it, and put back by restore()"""

    def __init__(self):
        mon = json.loads(subprocess.run(["hyprctl", "monitors", "-j"], capture_output=True, text=True).stdout or "[]")
        cur = next((m["activeWorkspace"]["id"] for m in mon if m.get("name") == "MBA"), 1)
        self.moved = [(c["address"], c["workspace"]["id"]) for c in clients() if c["workspace"]["id"] == cur]
        for a, _ in self.moved:
            self.send(a, 9)
        if self.moved:
            time.sleep(0.8)

    @staticmethod
    def send(addr, ws):
        subprocess.run(["hyprctl", "dispatch", f'hl.dsp.window.move({{workspace={ws}, follow=false, window="address:{addr}"}})'],
                       capture_output=True)

    def restore(self):
        for a, ws in self.moved:
            self.send(a, ws)
        if self.moved:
            time.sleep(0.5)


class Pointer:
    """scripts/vptr: move(x, y) in logical px, down(), up(), click()"""

    def __init__(self):
        self.p = subprocess.Popen([VPTR, str(W), str(H)], stdin=subprocess.PIPE, text=True,
                                  stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        time.sleep(0.3)

    def send(self, line):
        self.p.stdin.write(line + "\n")
        self.p.stdin.flush()

    def move(self, x, y, ms=0):
        self.send(f"{x:.0f} {y:.0f} {ms}")

    def down(self):
        self.send("d")

    def up(self):
        self.send("u")

    def click(self):
        self.send("b")

    def close(self):
        self.p.stdin.close()
        self.p.wait(timeout=5)


def dock_tile(ptr):
    """TextEdit's tile in the Dock: its centre x in pt, or None. The widest near-white run on the Dock's icon row"""
    ptr.move(640, 400)
    time.sleep(0.5)
    img = grim().sum(axis=2)
    row = img[1568] > 3 * 225
    runs, x = [], 0
    while x < len(row):
        if row[x]:
            x1 = x
            while x1 < len(row) and row[x1]:
                x1 += 1
            runs.append((x1 - x, (x + x1) / 4))
            x = x1
        x += 1
    return max(runs)[1] if runs else None


def dock_remove_ready(ptr):
    """opens the Dock menu of TextEdit's tile and its Options submenu with real pointer motion and a right click,
    and parks the pointer on Remove from Dock, the submenu's first row (tx + 153, 677). Returns tx, the tile's centre
    x in pt, or None when the tile is not found. The next ptr.click() removes the tile."""
    tx = dock_tile(ptr)
    if tx is None:
        return None
    for dx in (-17, -7, 0):
        ptr.move(tx + dx, 784, 40)
    time.sleep(0.4)
    ptr.send("r")
    time.sleep(1.0)
    for dx in (3, 9, 13):                       # Options, the menu's first row
        ptr.move(tx + dx, 677, 40)
    time.sleep(0.9)
    for dx in (143, 149, 153):                  # Remove from Dock, the submenu's first row
        ptr.move(tx + dx, 677, 40)
    time.sleep(0.6)
    return tx


def grim(cursor=False):
    """the MBA output as an int array, 2 samples per logical px"""
    from PIL import Image
    import io
    out = subprocess.run(["grim", "-o", "MBA"] + (["-c"] if cursor else []) + ["-t", "ppm", "-"], capture_output=True).stdout
    return np.asarray(Image.open(io.BytesIO(out)).convert("RGB")).astype(int)


def mcap_start(prefix, region, seconds, step=1, trigger="true"):
    """starts a per-frame capture of region (x, y, w, h logical px); wait on the returned process, then frames()"""
    if not os.path.exists(MCAP):
        sys.exit("livecheck: build mcap first (scripts/motion-capture/build.sh)")
    return subprocess.Popen([MCAP, "-o", prefix, "-g", ",".join(str(int(v)) for v in region), "-k", str(step),
                             "-t", f"{seconds:.2f}", "--", trigger], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def frames(prefix, keep=False):
    """(t in ms from the trigger, frames n x h x w x 3 int)"""
    meta = json.load(open(prefix + ".json"))
    n, w, h = meta["frames"], meta["w"], meta["h"]
    fr = np.fromfile(prefix + ".raw", dtype=np.uint8)[: n * h * w * 3].reshape(n, h, w, 3).astype(int)
    csv = np.loadtxt(prefix + ".csv", delimiter=",", skiprows=1, ndmin=2)
    t = (csv[:, 1] - meta["t0_ns"]) / 1e6
    if not keep:
        for ext in (".raw", ".csv", ".json"):
            os.remove(prefix + ext)
    return t, fr


def main():
    """livecheck.py run <program> [args]: starts it inside the exported test session (see launch), prints its pid"""
    if len(sys.argv) < 3 or sys.argv[1] != "run":
        sys.exit("usage: livecheck.py run <program> [args]   (inside an exported headless test session)")
    p = launch(session("livecheck"), sys.argv[2:])
    print(p.pid)


def report(ok, case, note):
    print(("ok   " if ok else "FAIL ") + case + ": " + note)
    return 0 if ok else 1


if __name__ == "__main__":
    main()
