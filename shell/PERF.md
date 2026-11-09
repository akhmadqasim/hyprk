# hyprk shell performance

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
- **Wallpaper decoded at logical size** (`Background.qml` `sourceSize`): the wallpaper is soft; at
  4K/1.5 the pixel-size decode cost ~18 MB more.
- **On-demand surfaces** (`shell.qml` `LazyLoader`): Spotlight, Cmd+Tab switcher, Apps and Mission
  Control windows (and their delegates, icon textures and live window captures) exist only while open.
  Their open logic also runs on creation (`opened()`); Spotlight's IPC moved to `Panels`.
- **Hidden content not built**: Apps grid and switcher models are empty while closed, the Photos
  widget loads its picture only while Notification Center is open.

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
