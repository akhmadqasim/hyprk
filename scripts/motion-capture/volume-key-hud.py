#!/usr/bin/env python3
"""Live check: every volume key step shows the HUD, as the Mac does (ControlCenter.framework volume step
0x20a595dac: HUDActionDelegate.showVolume on every step, SOUND-REA-27.2.1.md section 2): steps that change the
level, steps at full and at zero, and a step that lands on the level a test call (qs ipc hud volume) left on the HUD
(JUDGE-95-23 claim 3c: no HUD on such steps).

Session: see livecheck.py; it must be an audio stub session (HYPRK_AUDIO_STUB=1 or HYPRK_STATUS_STUB=1): the steps go
through shell/scripts/volume-key.sh, the script Hyprland's volume key binds run, with this session's environment, and
change only the stub sink's file. The real volume is never touched: the script refuses a shell without the stub.

  volume-key-hud.py      exit 0 = every step showed the HUD
"""
import json, os, subprocess, sys, time

import livecheck as lc

KEY = os.path.join(lc.ROOT, "shell/scripts/volume-key.sh")


def main():
    pid = lc.session("volume-key-hud")
    env = lc.environ(pid)
    if b"HYPRK_AUDIO_STUB=1" not in env and b"HYPRK_STATUS_STUB=1" not in env:
        sys.exit("volume-key-hud: this session's shell has no audio stub: not driven")
    kenv = dict(os.environ, HYPRK_AUDIO_STUB="1", HYPRK_MUTE="1")
    d = os.path.join(os.environ["XDG_RUNTIME_DIR"], "hyprk-volkey-" + os.environ["HYPRLAND_INSTANCE_SIGNATURE"])

    def sink():
        try:
            return float(open(os.path.join(d, "stub-sink")).read().split()[0])
        except (OSError, ValueError, IndexError):
            return 0.5

    def step(direction, case):
        lc.ipc(pid, "hud", "hide")
        time.sleep(0.25)
        before = sink()
        subprocess.run([KEY, direction, "16"], env=kenv)
        time.sleep(0.4)
        st = json.loads(lc.ipc(pid, "hud", "state") or "{}")
        after = sink()
        ok = st.get("shown") is True and abs(st.get("volume", -1) - after) < 1e-6
        return lc.report(ok, case, f"{direction}: sink {before:g} -> {after:g}, HUD shown {st.get('shown')} at {st.get('volume')}")

    if lc.ipc(pid, "panels", "current") == "cc":
        lc.ipc(pid, "panels", "close")
    fails = 0
    while sink() < 1:                      # to full, quietly
        subprocess.run([KEY, "up", "16"], env=kenv)
    time.sleep(1.5)
    fails += step("up", "at full (level stays)")
    fails += step("down", "level change")
    fails += step("down", "level change")
    fails += step("up", "level change")
    # the test entry leaves 14/16 on the HUD while the sink is at 15/16: the step down lands on that level
    lc.ipc(pid, "hud", "volume", "0.875")
    time.sleep(1.5)
    fails += step("down", "onto the level a test call left on the HUD")
    lc.ipc(pid, "hud", "volume", "1")
    time.sleep(1.5)
    fails += step("up", "after a test call, level change")
    while sink() > 0:
        subprocess.run([KEY, "down", "16"], env=kenv)
    time.sleep(1.5)
    fails += step("down", "at zero (level stays)")
    fails += step("up", "from zero")
    lc.ipc(pid, "hud", "hide")
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
