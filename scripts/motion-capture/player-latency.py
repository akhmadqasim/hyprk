#!/usr/bin/env python3
"""Output latency of the sound player: from the exec of `pw-play --volume 1 <file>` (what shell/scripts/sound.sh does
last) to the file's first sample in a sink's input, measured on a PRIVATE PipeWire: its own daemon and WirePlumber in a
scratch runtime dir, one null sink, every hardware monitor off. The machine's PipeWire, its sinks and their volume are
never connected to or touched, and nothing is audible.

The clock is CLOCK_MONOTONIC: the exec's stamp, and the arrival of the null sink's monitor through `pw-record --raw -`
at a 64-frame quantum (1.3 ms at 48 kHz; the chunk that carries the first sample over -50 dBFS, minus the frames after
that sample, minus the file's own lead-in). A real device adds its own period and hardware delay after this point; that part is the sink's, not
hyprk's (the Mac's counterpart, key to sound in the output mix: SOUND-REA-27.2.1.md section 7).

  player-latency.py SCRATCH_DIR [--runs N] [--file sounds/...]     prints the latencies; exit 0 when the median is
                                                                   within one 60 Hz frame of the 12 ms the timing
                                                                   checks add (sound-timing.py --player-ms)
"""
import os, select, shutil, signal, subprocess, sys, time

import numpy as np

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NULL = """context.properties = { default.clock.rate = 48000 default.clock.quantum = 64 default.clock.min-quantum = 64 default.clock.max-quantum = 64 }
context.objects = [
  { factory = adapter
    args = { factory.name = support.null-audio-sink node.name = hyprk-null media.class = Audio/Sink audio.position = [ FL FR ] priority.session = 2000 priority.driver = 2000 }
  }
]
"""
NOHW = """wireplumber.profiles = { main = { monitor.alsa = disabled monitor.alsa-midi = disabled monitor.bluez = disabled monitor.bluez-midi = disabled monitor.libcamera = disabled monitor.v4l2 = disabled hardware.audio = disabled hardware.bluetooth = disabled hardware.video-capture = disabled } }
"""


def main():
    args = sys.argv[1:]
    if not args or args[0].startswith("-"):
        sys.exit(__doc__)
    base = os.path.join(os.path.abspath(args[0]), "player-latency")
    runs = int(args[args.index("--runs") + 1]) if "--runs" in args else 10
    snd = args[args.index("--file") + 1] if "--file" in args else "sounds/originals/misc/BezelServices-volume.aiff"
    snd = snd if os.path.isabs(snd) else os.path.join(ROOT, snd)
    for tool in ("pipewire", "wireplumber", "pw-play", "pw-record", "ffmpeg"):
        if not shutil.which(tool):
            sys.exit(f"player-latency: {tool} not found")
    # the file's own lead-in: its first sample over -50 dBFS (poof item off dock.aif starts 12 ms into the file)
    pcm = subprocess.run(["ffmpeg", "-v", "error", "-i", snd, "-f", "s16le", "-ac", "2", "-ar", "48000", "-"], capture_output=True).stdout
    lead = np.nonzero(np.abs(np.frombuffer(pcm[: len(pcm) // 4 * 4], dtype="<i2").reshape(-1, 2).astype(int)).max(axis=1) > 32768 * 10 ** (-50 / 20))[0]
    if not len(lead):
        sys.exit("player-latency: the file is silent")
    lead = lead[0] / 48
    if os.path.exists(base):
        sys.exit(f"player-latency: {base} exists (an older run's folder?): remove it first")
    for d in ("rt", "home", "cfg/pipewire/pipewire.conf.d", "cfg/wireplumber/wireplumber.conf.d"):
        os.makedirs(os.path.join(base, d), mode=0o700)
    open(os.path.join(base, "cfg/pipewire/pipewire.conf.d/10-null.conf"), "w").write(NULL)
    open(os.path.join(base, "cfg/wireplumber/wireplumber.conf.d/10-nohw.conf"), "w").write(NOHW)
    env = {k: v for k, v in os.environ.items() if k not in ("DBUS_SESSION_BUS_ADDRESS", "WAYLAND_DISPLAY", "PIPEWIRE_REMOTE", "PULSE_SERVER")}
    env.update(XDG_RUNTIME_DIR=os.path.join(base, "rt"), HOME=os.path.join(base, "home"), XDG_CONFIG_HOME=os.path.join(base, "cfg"),
               XDG_STATE_HOME=os.path.join(base, "home/state"), PIPEWIRE_RUNTIME_DIR=os.path.join(base, "rt"))
    procs = []
    quiet = dict(stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, env=env)
    out = []
    try:
        procs.append(subprocess.Popen(["pipewire"], **quiet))
        time.sleep(1.0)
        procs.append(subprocess.Popen(["wireplumber"], **quiet))
        time.sleep(2.0)
        nodes = subprocess.run(["pw-cli", "ls", "Node"], capture_output=True, text=True, env=env).stdout
        if "hyprk-null" not in nodes or "alsa" in nodes:
            sys.exit("player-latency: the private graph is not the null sink alone: not measured")
        rec = subprocess.Popen(["pw-record", "--target", "hyprk-null", "-P", "{ stream.capture.sink = true }", "--rate", "48000",
                                "--channels", "2", "--format", "s16", "--latency", "64", "--raw", "-"],
                               stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, env=env, bufsize=0)
        procs.append(rec)
        fd = rec.stdout.fileno()
        os.set_blocking(fd, False)

        def drain(until, want_onset):
            """reads the monitor until `until` (monotonic s); the monotonic ns of the first sample over -50 dBFS"""
            while time.monotonic() < until:
                if not select.select([fd], [], [], 0.05)[0]:
                    continue
                now = time.monotonic_ns()
                data = os.read(fd, 1 << 16)
                if not want_onset or len(data) < 4:
                    continue
                s = np.abs(np.frombuffer(data[: len(data) // 4 * 4], dtype="<i2").reshape(-1, 2).astype(int)).max(axis=1)
                hit = np.nonzero(s > 32768 * 10 ** (-50 / 20))[0]
                if len(hit):
                    return now - int((len(s) - hit[0]) / 48000 * 1e9)
            return None

        drain(time.monotonic() + 1.5, False)
        for _ in range(runs):
            drain(time.monotonic() + 0.7, False)
            t0 = time.monotonic_ns()
            p = subprocess.Popen(["pw-play", "--volume", "1", snd], **quiet)
            on = drain(time.monotonic() + 1.5, True)
            p.wait(timeout=5)
            out.append(None if on is None else (on - t0) / 1e6 - lead)
    finally:
        for p in reversed(procs):                     # only the processes this script started, by their pids
            p.send_signal(signal.SIGTERM)
        for p in procs:
            try:
                p.wait(timeout=3)
            except subprocess.TimeoutExpired:
                p.kill()
        shutil.rmtree(base, ignore_errors=True)
    got = [v for v in out if v is not None]
    if not got:
        print("FAIL player latency: no sample reached the null sink")
        return 1
    mean, med = sum(got) / len(got), float(np.median(got))
    ok = abs(med - 12) <= 1000 / 60
    print(("ok   " if ok else "FAIL ") + f"player latency (exec of pw-play -> the file's sample 0 in the sink's input, private PipeWire, null sink, "
          f"quantum 64): {min(got):.1f}-{max(got):.1f} ms, median {med:.1f}, mean {mean:.1f}, {len(got)} of {runs} runs ({os.path.basename(snd)})")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
