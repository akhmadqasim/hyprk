#!/usr/bin/env python3
"""Live check: when the system sounds start, against the screen, on the session's own clock (CLOCK_MONOTONIC: mcap's
present times, the trigger stamps and the sound log's appends). Nothing is played and the real sink is never touched:
the session must be an audio stub session with HYPRK_MUTE=1 (smoke.sh's default) and HYPRK_SOUND_LOG set; "the player"
below is the moment shell/scripts/sound.sh would exec pw-play (its log line), and "out" is that plus PLAYER_MS, pw-play's
own start-up into a PipeWire graph (scripts/motion-capture/player-latency.py measures it on a private daemon with a null
sink: median 12 ms; 11 ms was the old estimate).

Cases and the Mac's numbers (reference/re/27.2.1/SOUND-REA-27.2.1.md sections 7, 8; MAC-ANSWERS-10.md R10.2, R10.3):
  key     volume key step (volume-key.sh, the binds' script) with feedback on: level set, menu bar pill, pop, HUD.
          Mac: pill -> pop out 48.7 ms, pop out -> first HUD frame 18.0 ms (volume-pop.mov), pill -> first HUD frame
          66.7; key -> first HUD frame 112-127 ms with a 22-24 ms capture path = about 90-105 (volume-key-hud-timing.mov),
          HUD at 50 % 277-293 ms and at 90 % 440-445 ms after the key (the same clip, mean pixel change against 0.6 s);
          the HUD's hold, appear start -> hide start, 1.000 s (MOTION-AUDIT.md "HUD, Round R3.4": hide spring start -
          appear spring start), read here as the HUD's change passing 2 % on the way in and 98 % on the way out.
          By hand (MAC-ANSWERS-16.md "Hand actions", volume-key-f12-hand-feedback.mov, F12 on the keyboard, one
          take; read with this file's rules): pill in the frame 1 ms after the logged key down (the log is good to
          +-20 ms), pop 60 ms after the pill, first HUD frame 83 ms after the pill and 23 after the pop, 84 after the
          key; 50 % 238 ms and 90 % 418 ms after the key. So each relation has two Mac takes a frame apart
          (pill -> pop 48.7 / 60, pop -> HUD 18 / 23, pill -> HUD 66.7 / 83): a case passes within a frame of either.
          "First HUD frame" is judge #20's rule, over 20 px changed by more than 4 levels, which on volume-pop.mov
          (HUD over the desktop's (11,29,157), 244 levels under white) is a content alpha above 4 / 244; over
          another backdrop the same alpha is 4 x (255 - its darkest channel) / 244 levels (2.1 over grey 127, where
          the plain 4 skipped the HUD's first frame, +3.8 levels at the Mac's first-frame alpha .030)
  shot    the screenshot bind's sound: Mac `Screen Capture.aif` 222 / 247 ms after the key (screenshot-thumbnail.mov)
  poof    Dock menu > Options > Remove from Dock on TextEdit's tile, by a real click. Mac (MAC-ANSWERS-16.md R16.1,
          dock-remove-menu-real-click.mov, a HID-level click, read per frame and per sample): the row blinks (off
          4.533, on 4.600), the menus fade (4.667-4.867), then the Dock starts to move at 4.900 = 367 ms after the
          highlight went off, about 420 ms after the mouse up (logged 4.48, +-20, capture path included);
          `poof item off dock.aif`, cross-correlated with the clip's audio (r .999), has its first sample at
          4.920 s, 20 ms after that frame's time (over 1 % of its peak from 4.926, "4.929" in MAC-ANSWERS-16; what
          the clip holds at 4.895-4.915 is the AAC's pre-echo), 440 ms after the logged mouse up. R10.2 c's AX press
          read +15 ms. The Dock closes the gap over 250 ms (4.900 to the clip's last frame, 5.150, still moving), no
          cloud.
          (menu-blink.py counts the blink and the fade frame by frame.)

Session: see livecheck.py; start it with HYPRK_SOUND_LOG=<file> and export HYPRK_STATE (the scratch state folder: the
key case sets volumeFeedback in its sound.json, the poof case writes dock-items.json; both are put back). Open windows
are moved to workspace 9 for the run and put back (livecheck.Desk): the check sets up its own empty desktop.

  sound-timing.py [key|shot|poof ...] [--runs N] [--player-ms 12]      exit 0 = every case inside its tolerance
"""
import json, os, subprocess, sys, time

import numpy as np

import livecheck as lc
from sound_watch import Watch

KEY = os.path.join(lc.ROOT, "shell/scripts/volume-key.sh")
SOUND = os.path.join(lc.ROOT, "shell/scripts/sound.sh")
FRAME = 1000 / 60


def rng(v):
    v = [x for x in v if x is not None]
    return "none" if not v else f"{min(v):.0f}-{max(v):.0f} (mean {sum(v) / len(v):.1f})"


def mean(v):
    v = [x for x in v if x is not None]
    return sum(v) / len(v) if v else None


def key_case(pid, log, runs, player):
    state = os.environ["HYPRK_STATE"]
    sj = os.path.join(state, "sound.json")
    before = open(sj).read() if os.path.exists(sj) else None
    cfg = json.loads(before) if before else {}
    cfg["volumeFeedback"] = True
    open(sj, "w").write(json.dumps(cfg))
    d = os.path.join(os.environ["XDG_RUNTIME_DIR"], "hyprk-volkey-" + os.environ["HYPRLAND_INSTANCE_SIGNATURE"])
    sink = os.path.join(d, "stub-sink")
    kenv = f"HYPRK_AUDIO_STUB=1 HYPRK_MUTE=1 HYPRK_SOUND_LOG='{log}' HYPRK_STATE='{state}'"
    subprocess.run(f"{kenv} '{KEY}' up 16", shell=True)       # a level that is not an end, so the step changes it
    subprocess.run(f"{kenv} '{KEY}' down 16", shell=True)
    rows = []
    prefix = os.path.join(os.path.dirname(log), "sound-timing-key")
    try:
        for i in range(runs):
            lc.ipc(pid, "hud", "hide")
            time.sleep(1.6)
            w = Watch({"level": sink, "player": log}, 2.5)
            m = lc.mcap_start(prefix, (960, 0, 320, 120), 1.9, 2, f"{kenv} '{KEY}' {'down' if i % 2 else 'up'} 16")
            m.wait()
            st = w.done()
            meta = json.load(open(prefix + ".json"))
            t, fr = lc.frames(prefix)
            ch = np.abs(fr - fr[0]).max(axis=3)
            bar = [(c[:34] > 4).sum() > 20 for c in ch]            # the menu bar's rows: the Control Center pill
            # judge #20's rule, over 20 px by more than 4 levels, at the Mac clip's contrast (see the top of this file)
            lift = 4 * (255 - fr[0, 36:].mean(axis=(0, 1)).min()) / 244
            hud = [(c[36:] > lift).sum() > 20 for c in ch]
            amount = np.abs(fr[:, 36:] - fr[0, 36:]).mean(axis=(1, 2, 3))
            end = amount[np.argmin(np.abs(t - 600))]
            first = lambda b: float(t[b.index(True)]) if True in b else None
            at = lambda q: float(t[np.argmax(amount >= q * end)]) if end > 0 else None
            # the hold: in at 2 % of the settled change, out at 98 % (o .02 is 17 ms into either spring)
            full = float(np.median(amount[(t > 600) & (t < 900)])) if ((t > 600) & (t < 900)).any() else 0
            seen = np.nonzero(amount >= 0.02 * full)[0] if full > 0 else []
            gone = [i for i in range(len(t)) if t[i] > 900 and amount[i] <= 0.98 * full] if full > 0 else []
            hold = float(t[gone[0]] - t[seen[0]]) if len(seen) and gone else None
            ms = lambda k: (st[k] - meta["t0_ns"]) / 1e6 if k in st else None
            rows.append(dict(level=ms("level"), player=ms("player"), pill=first(bar), hud=first(hud), h50=at(.5), h90=at(.9), hold=hold))
    finally:
        if before is None:
            os.remove(sj)
        else:
            open(sj, "w").write(before)
        lc.ipc(pid, "hud", "hide")
    col = lambda k: [r[k] for r in rows]
    diff = lambda a, b, off=0: [None if r[a] is None or r[b] is None else r[b] - r[a] + off for r in rows]
    print(f"     key, {runs} runs, ms from the key: level {rng(col('level'))}, player {rng(col('player'))}, pill "
          f"{rng(col('pill'))}, HUD first frame {rng(col('hud'))}, 50 % {rng(col('h50'))}, 90 % {rng(col('h90'))}")
    a, b, c = mean(diff("pill", "player", player)), mean(diff("player", "hud", -player)), mean(diff("pill", "hud"))
    h, h50, h90 = mean(col("hud")), mean(col("h50")), mean(col("h90"))
    if None in (a, b, c, h, h50, h90):
        return lc.report(False, "key", "no pill, pop or HUD seen")
    near = lambda v, lo, hi: lo - FRAME <= v <= hi + FRAME
    fails = lc.report(near(a, 48.7, 60), "pill -> pop out", f"{rng(diff('pill', 'player', player))} ms, Mac 48.7, by hand 60 (player + {player:g})")
    fails += lc.report(near(b, 18.0, 23), "pop out -> first HUD frame", f"{rng(diff('player', 'hud', -player))} ms, Mac 18.0, by hand 23")
    fails += lc.report(near(c, 66.7, 83), "pill -> first HUD frame", f"{rng(diff('pill', 'hud'))} ms, Mac 66.7, by hand 83")
    fails += lc.report(84 - 20 - FRAME <= h <= 127, "key -> first HUD frame", f"{rng(col('hud'))} ms, Mac by hand 84 (key log +-20); 112-127 filmed, about 90-105 without its 22-24 ms capture path")
    fails += lc.report(238 - 20 - FRAME <= h50 <= 293 + FRAME, "key -> HUD at 50 %", f"{rng(col('h50'))} ms, Mac by hand 238, 277-293 filmed")
    fails += lc.report(418 - 20 - FRAME <= h90 <= 445 + FRAME, "key -> HUD at 90 %", f"{rng(col('h90'))} ms, Mac by hand 418, 440-445 filmed")
    hd = mean(col("hold"))
    fails += lc.report(hd is not None and abs(hd - 1000) <= 2 * FRAME, "HUD hold, appear start -> hide start", f"{rng(col('hold'))} ms, Mac 1000")
    return fails


def shot_case(pid, log, runs, player):
    """the bind's own sound command (config/hypr/hyprland.lua `shutter`), run by Hyprland; no screenshot is written"""
    lua = open(os.path.join(lc.ROOT, "config/hypr/hyprland.lua")).read()
    line = next(l for l in lua.splitlines() if l.startswith("local shutter ="))
    wait = next((l for l in lua.splitlines() if l.startswith("local shutterDelay")), "")
    delay = wait.split("=")[1].split("--")[0].strip().strip('"') if wait else ""
    cmd = (f"sleep {delay}; " if delay else "") + f"exec '{SOUND}' screenshot"
    v = []
    for _ in range(runs):
        time.sleep(1.2)
        w = Watch({"player": log}, 2.0)
        t0 = time.monotonic_ns()
        subprocess.run(["hyprctl", "dispatch", 'hl.dsp.exec_cmd("' + cmd.replace('"', '\\"') + '")'], capture_output=True)
        st = w.done()
        v.append((st["player"] - t0) / 1e6 + player if "player" in st else None)
    m = mean(v)
    tail = open(log).read().splitlines()[-1] if os.path.getsize(log) else ""
    ok = m is not None and 222 - FRAME <= m <= 247 + FRAME and "Screen Capture" in tail
    return lc.report(ok, "screenshot sound out after the key", f"{rng(v)} ms ({line.strip()[:40]}..., delay '{delay}'), "
                     f"Mac 222 / 247; file {os.path.basename(tail.split(' vol=')[0]) if tail else 'none'}")


def poof_case(pid, log, runs, player):
    state = os.environ["HYPRK_STATE"]
    path = os.path.join(state, "dock-items.json")
    before = open(path).read() if os.path.exists(path) else '{"removed":[],"downloads":{}}'
    open(path, "w").write('{"removed":[],"downloads":{}}')
    time.sleep(1.5)
    ptr = lc.Pointer()
    prefix = os.path.join(os.path.dirname(log), "sound-timing-poof")
    try:
        tx = lc.dock_remove_ready(ptr)
        if tx is None:
            return lc.report(False, "poof", "TextEdit's tile not found in the Dock")
        w = Watch({"player": log}, 3.0)
        m = lc.mcap_start(prefix, (360, 560, 560, 272), 1.5, 2)
        time.sleep(0.5)
        t0 = time.monotonic_ns()
        ptr.click()
        m.wait()
        st = w.done()
        meta = json.load(open(prefix + ".json"))
        t, fr = lc.frames(prefix)
        t = t + (meta["t0_ns"] - t0) / 1e6             # ms from the click
        pre = fr[t < 0][-1]
        # the removal's first frame: the Dock's rows (y 786..832 pt, under the menus' shadow) start to move. Before it
        # the menu blinks the chosen row and fades out (R16.1)
        dock = fr[:, 226:, :, :]
        ch = np.array([(np.abs(f - pre[226:]).max(axis=2) > 4).sum() for f in dock])
        seen = np.nonzero((t > 0) & (ch > 20))[0]
        if not len(seen) or "player" not in st:
            return lc.report(False, "poof", f"Dock motion {'seen' if len(seen) else 'not seen'}, sound {'logged' if 'player' in st else 'not logged'}")
        first = float(t[seen[0]])
        snd = (st["player"] - t0) / 1e6 + player
        step = np.array([0] + [(np.abs(dock[i] - dock[i - 1]).max(axis=2) > 6).sum() for i in range(1, len(dock))])
        moving = np.nonzero(step > 20)[0]
        settle = float(t[moving[-1]]) - first if len(moving) else 0.0
        # a cloud would be drawn above the removed tile: after the menus are gone, nothing may differ from the end there
        gone = t > first + 250
        above = fr[gone][:, 60:190, int(tx - 360 - 40):int(tx - 360 + 40), :]
        cloud = int(max((np.abs(a - above[-1]).max(axis=2) > 12).sum() for a in above)) if gone.any() else -1
        tail = open(log).read().splitlines()[-1]
        fails = lc.report(367 - FRAME <= first <= 420 + 20, "click -> the Dock starts to move",
                          f"{first:.0f} ms (Mac 367 after the highlight went off, about 420 after the mouse up; the item runs after the menu's fade)")
        fails += lc.report(20 - FRAME <= snd - first <= 29 + FRAME and "poof item off dock" in tail, "poof against the removal's first frame",
                           f"click -> sound out {snd:.0f} ms: {snd - first:+.0f} ms (Mac: first sample +20, over 1 % of the peak +26..29; 440 ms after the logged up)")
        fails += lc.report(abs(settle - 250) <= 2 * FRAME, "Dock closes the gap", f"last moving frame {settle:.0f} ms after the first (Mac 250, cosine ease in-out)")
        fails += lc.report(cloud == 0, "no poof cloud", f"{cloud} px changing above the tile after the menu is gone (Mac: none)")
        left = json.load(open(path)).get("removed", [])
        fails += lc.report(len(left) == 1, "item removed", f"dock-items.json removed = {left}")
        return fails
    finally:
        ptr.move(640, 400)
        ptr.close()
        open(path, "w").write(before)
        for ext in (".raw", ".csv", ".json"):
            if os.path.exists(prefix + ext):
                os.remove(prefix + ext)


def main():
    args = sys.argv[1:]
    runs = int(args[args.index("--runs") + 1]) if "--runs" in args else 10
    player = float(args[args.index("--player-ms") + 1]) if "--player-ms" in args else 12.0
    cases = [a for a in args if a in ("key", "shot", "poof")] or ["key", "shot", "poof"]
    pid = lc.session("sound-timing", need=("HYPRK_MUTE=1",))
    env = lc.environ(pid)
    if b"HYPRK_AUDIO_STUB=1" not in env and b"HYPRK_STATUS_STUB=1" not in env:
        sys.exit("sound-timing: this session's shell has no audio stub: not driven")
    log = next((e[len(b"HYPRK_SOUND_LOG="):].decode() for e in env if e.startswith(b"HYPRK_SOUND_LOG=")), "")
    state = os.environ.get("HYPRK_STATE", "")
    if not log:
        sys.exit("sound-timing: start the session with HYPRK_SOUND_LOG=<file>")
    if not state or os.path.realpath(state) == os.path.realpath(os.path.join(lc.ROOT, "state")):
        sys.exit("sound-timing: export the session's scratch HYPRK_STATE (never the repo's state folder)")
    if not os.path.exists(log):
        open(log, "a").close()
    fails = 0
    desk = lc.Desk()            # an empty desktop: the HUD and the Dock are read against the wallpaper, not a window
    try:
        for c in cases:
            fails += {"key": key_case, "shot": shot_case, "poof": poof_case}[c](pid, log, runs, player)
    finally:
        desk.restore()
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
