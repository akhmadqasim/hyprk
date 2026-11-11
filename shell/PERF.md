# hyprk shell performance

## 2026-11-11 (later): Spotlight kept loaded, unmapped

Same session setup as below. `shell.qml` keeps Spotlight loaded from 2 s after start (the window is unmapped: no
surface, no frames, 0 CPU ticks over 20 s at rest), so an open maps it instead of creating it, and the springs start
at once. Spotlight shortcut (`hyprctl dispatch hl.dsp.global`) to the first visible frame (mcap, alpha > 0.02):
created on open 63-113 ms, loaded 46-60 ms after the first open (111 ms on the first). qs memory after restart, before
any open: anon 140.0 -> 141.8 MB (+1.9 MB), RSS 402 -> 418 MB (shared file pages of the effects plugin). After three
opens both are at anon ~151 MB.

## 2026-11-11: re-measured on the current shell, two fixes

Headless `MBA` output only (2560x1664 @ 2x, `scripts/smoke.sh` with `HYPRK_HEADLESS=1`), liquidglass plugin on, own
`HYPRK_STATE`/`XDG_CACHE_HOME`. qs restarted by hand in the same Hyprland with the environment Hyprland gave it plus
`QSG_RENDER_TIMING=1`; startup = qs exec to `hyprk-dock` and `hyprk-menubar` both in `hyprctl layers` (30 ms poll);
memory from `/proc/<qs>/smaps_rollup` (PSS is deflated by other sessions mapping the same files: trust anon);
idle = `/proc/<pid>/stat` utime+stime over 30 s from t+60 s; frames = `frame rendered` lines of the timing log.

| | before (HEAD 963d95b with the Panels name clash fixed) | after |
|---|---|---|
| startup to Dock + menu bar | 0.94 s (99 ticks) | **0.58 s** (62 ticks) |
| qs CPU in the first 6 s | 1.41 s | 1.05 s |
| RSS / PSS / anon at +60 s | 367 / 225 / 188 MB | **318 / 197 / 139 MB** |
| idle CPU 30 s (qs / Hyprland) | 0 % / 0 % | 0 % / 0 % |
| qs frames at rest | 0 per 30 s | 0 per 30 s |
| Mission Control open, 3 windows, idle 10 s | 601 qs frames, 0.42 + 0.42 CPU-s (qs + Hyprland) | **0 frames, 0 CPU-s** |

- `ui/HyprK/AppIconTile.qml`: the squircle tile is behind a `Loader` (built only for icons that get one) and its outlines
  are shared per process (`iconshape.js` `tilePoints`). Pixels: same as before within the run-to-run noise (a same-code
  pair differs by 2 to 30 isolated 1 px pixels plus the clock areas); with the tile forced off the Apps view differs by
  83,587 px, so the check covers drawn tiles.
- `modules/MissionControl.qml`: one still per window per open (`live: false`, `captureFrame()` on a reopen while loaded).
  Mission Control 1.5 s after opening: 0 px different; after a reopen 13 px (one 1 px column). A window that animates
  while Mission Control is open now shows its frame from the open (the Mac updates it live).

Checked, not changed:
- Overlay / Control Center / Notification Center created on first open (scratch variant): -12 MB anon, -28 MB RSS,
  first map +3 to 10 ms, but the Notification Center photo and the Control Center artwork would decode on that first
  open again (the empty-card frames noted below). Overlay stays eager: a menu must be complete in its first frame.
- Apps preload (2 s after start): holds the first screen of the All view only, 18 MB anon and 0.2 CPU-s (variant without
  it: anon 121 vs 139 MB); kept so the first open is complete.
- At rest with a surface open (10 s): Control Center, menu, Apps, Spotlight 0 frames; Notification Center 1 frame/s
  (analog clock seconds, 0 to 2 ms polish, render 0 ms). Qt Quick redraws the whole window per frame, so only a
  separate surface for the clock could limit it, and that surface would have to follow the slide: not done.
- Control Center now-playing art is decoded at its file size (no `sourceSize`); a smaller decode changes its pixels.

Measured 2026-11-10 in a nested Hyprland 0.57.2 with a headless 3840x2160 output at scale 1.5
(the target: 4K monitor at 150%), liquidglass plugin on, Finder/Settings windows closed, shell idle.
Tool: `/proc/<pid>/stat` (utime+stime over 60 s), `/proc/<pid>/status` (RSS), `/proc/<pid>/smaps` (PSS),
`voluntary_ctxt_switches` summed over threads for wakeups.

| | before (iter 6) | after (iter 7) |
|---|---|---|
| idle CPU, 4K + 720p outputs | 0.03 % | 0.03 % |
| RSS, 4K + 720p outputs | 351 MB (anon 168) | 314 MB (anon 132, PSS 184) |
| RSS, 4K output only | 315 MB (anon 146) | **270 MB (anon 101, PSS 154)** |
| idle CPU, 4K only | | **0.02-0.03 %** |
| wakeups, 4K only | | main thread 0/s, all 43 threads 12/s |

Targets: idle CPU < 1 % (met). RSS < 250 MB: the private part is 101 MB anon and the
proportional total is 154 MB; plain RSS is 270 MB because it counts shared pages several times
(libLLVM 45 MB and libgallium 15 MB from Mesa, shared with every GL app, and SF Pro mapped 7 times
by Qt's font engines = 35 MB RSS for one 7.8 MB file). A bare one-window Quickshell already has
168 MB RSS / 37 MB anon on this machine.

## What changed

- **No QApplication** (`//@ pragma UseQApplication` removed): the shell uses no QtWidgets, so the
  GTK3 platform theme and widget stack are no longer loaded (-45 MB RSS with the next item).
- **Wallpaper decoded at the output's pixel size** since 2026-11-11 (`Background.qml` `sourceSize`, `wallpaper.sh` cuts it
  to that size): the logical-size decode was upscaled on a 2x output, so the glass sampled a softer backdrop than the Mac's
  (CC gap over 4 pt stripes 26 levels, Mac 32; now 31). Cost on the MBA output (2560x1664@2, default wallpaper): +8.3 MB
  anon / +8.4 MB RSS at rest. One decoded copy: Mission Control's backdrop shares it (same url and sourceSize, cached).
- **On-demand surfaces** (`shell.qml` `LazyLoader`): Spotlight (with its Apps panel, `spotlight/AppsPanel.qml`),
  Cmd+Tab switcher and Mission Control (and their delegates, icon textures and live window captures) exist only while open.
  Their open logic also runs on creation (`opened()`); Spotlight's IPC moved to `Panels`.
- **Hidden content not built**: Spotlight (and its Apps grid, which builds only the visible rows and one more) and the
  switcher are freed when they close.
  The Photos widget's picture (640 px wide, about 1 MB) stays decoded: loading it on open showed an
  empty black card for the first 50 to 80 ms of the Notification Center slide-in.

## Already event-driven (checked, no change needed)

- Menu bar clock: `SystemClock.Minutes`. Notification time labels: one minute clock, enabled only
  while banners or Notification Center are visible. The analog clock's seconds clock runs only while
  Notification Center is open.
- No `Timer` repeats while idle: the glass settle timer runs ~0.5 s after a panel/banner change, the
  Dock bounce stops after 6 s, banner timers run only while a banner is up, the volume-pop debounce
  is one-shot.
- `Process` calls are one-shot (wallpaper/blur cache, brightness probe, Photos lookup, appearance
  sync); state files use inotify (`FileView.watchChanges`), idle uses `IdleMonitor` (ext-idle-notify).
- Mission Control live captures and the Spaces thumbnails exist only while it is open.

## 4K at 150 %

Menu bar 30 pt = 45 px, Dock icons from the 512 px macOS icon PNGs (crisp at 1.5), Control Center
tiles 64 pt = 96 px; screenshots in `reference/ours/shell-4k-*.png`. Control Center label contrast
at 4K (plugin controlcenter recipe): 7.3:1 light, 10.7:1 dark.
