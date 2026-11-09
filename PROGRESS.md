# hyprk — PROGRESS (single source of truth)

Goal (user /goal 2026-11-10): Hyprland looks 1:1 like macOS 27.2, >=80% similar. Covers the shell AND settings app,
notifications, sounds, etc. User 02:40: "saya izinkan [build from source], ga ada batas tapi kerjakan semampu mu,
ini cuma project pribadi". Work autonomously until 07:00, then report.

## Rules
- Run /simplify then /code-review on code (plugin, shell, settings) before calling a piece done (user 02:50).

## Layout
- reference/  macOS 27.2 reference: metrics (from /mnt/code/liquid-glass-re/SPEC.md), screenshots, assets
- config/     hyprland config
- shell/      own Quickshell shell (menu bar, dock, control center, spotlight, notifications)
- plugin/     own Hyprland glass plugin (C++)
- themes/     GTK/Qt/icons/cursor/fonts
- sounds/     system sounds
- scripts/    launch nested, screenshot, compare
- Dev env: /mnt/code/hypr-dev (Hyprland 0.57.2 + Quickshell in prefix)

## Status
- [done 03:10] RE: SPEC.md has decoded glass shader (QuartzCore default.metallib glass_background_*), 63-field uniforms, refraction bevel, variable blur pyramid, 7-tap aberration, color matrices, 2-lobe rim, gaussian+ring shadow, continuous corner 1.528665, layout metrics (menubar 30, titlebar 32, traffic 14/9/7, window r16, dock 64/52->128, spotlight 640 r28). Missing: per-material numbers (in DesignLibrary Swift), CC grid, menu radius, fonts.
- [done 03:30] dev env: Hyprland 0.57.2 + Quickshell 0.3.2 in /mnt/code/hypr-dev/prefix (source env.sh). Gotchas: config is Lua (hyprland.lua); exit = hyprctl dispatch 'hl.dsp.exit()'; stray Hyprland child after exit needs kill -9 by pid; headless output 2560x1664 works (hyprctl output create headless MBA); gcc15 patch in hypr-dev/patches
- [done 03:25] assets: sounds (288 + wav/oga, sounds/INDEX.md), SF fonts (themes/fonts/named), wallpapers TahoeLight/Dark 6016px, 72 app icons + 257 system icons, 43 cursors (PDF+PNG, no Xcursor yet). See reference/ASSETS.md
- [done 03:10] reference screens: 8 images (desktop, settings-appearance, control center, notification center, finder, spotlight, apps, dock). Missing: mission control, lock, context menu, alert, cmd-tab, more settings panes
- [iter2 running] shell agent: v1 done (desktop ~75% my check). Iter2: neutral dock glass, real windows+shadow, Mission Control, context menus, alert dialog, plugin integration.
- [USER ACTION] 4 stray nested Hyprland pids 573829 574275 576400 577560 (kill denied by classifier) - user to kill -9 in the morning.
- [iter2 running] settings agent: v1 done 82-85% (my check vs ref). Iter2: glass sidebar, icon style clear, window border+shadow, event updates, Notifications/Keyboard/Lock panes.
- [running] themes agent (Sonnet) -> themes/gtk, themes/qt, lockscreen/
- [running 03:35] plugin agent (Opus) -> plugin/ (C++ + GLSL ES, own code)
- [done 03:5x] cursors agent: themes/cursors/theme/ hyprk-cursors (Xcursor 24-96 + hyprcursor, 32 shapes, 125 names), build.py + install.sh + MAPPING.md; hyprcursor load tested via libhyprcursor, not inside Hyprland.
- [todo] Finder running (finder/); later: mission control, cmd-tab, alerts, context menus; final integration + scoring at ~06:00; report 07:00
- 03:06 settings agent: settings/ app runs (quickshell -p settings/ or settings/run.sh), 20 panes, 8 functional, fallbacks in settings/FALLBACKS.md, rules in settings/hyprland-rules.lua (Lua, shell config should dofile it). Appearance vs reference ~80%. Next: nested Hyprland test, dark mode, /simplify + /code-review.
- [03:06] shell agent: Quickshell shell runs in nested Hyprland 0.57.2 (Lua config config/hypr/hyprland.lua). Done: menu bar (Apple menu, bold app name, static app menus, CC/Spotlight/clock, battery+Wi-Fi hidden when absent), Dock (glass, magnification, dots, separator, Downloads+Trash, bounce, macOS icon mapping), banners + Notification Center (grouped, Calendar + analog Clock widgets), Control Center (modular glass tiles, PipeWire/MPRIS/BT/NM with dimmed fallbacks), Spotlight (apps, calculator, files placeholder), Cmd+Tab switcher, Apps panel. Theme.qml holds all metrics; FALLBACKS.md; node tests (65 pass); scripts/smoke.sh. Scores: menu bar 80, dock 75, CC 80, NC 70, banners 70, spotlight 75, apps 65, switcher untested. Next: switcher test, /simplify + /code-review, SPEC.md metrics when filled, font instance check (SF Pro picks).
- [03:10] finder agent: finder/ runs (finder/run.sh [dir|recents:|applications:] [--view ...], C++ Qt launcher + QML, no Quickshell needed; tested offscreen + nested Hyprland). Icons/list/columns/gallery views, path bar, Quick Look (Space: images, text, info), rename (Return), new folder (Ctrl+Shift+N), gio trash, multi-select (ctrl/shift/rubber band), type-to-select, sort menus, Recents (xbel), Applications (.desktop + theme icons), dark mode. Fallbacks in finder/FALLBACKS.md, node tests (18 pass). Icon view vs reference ~85%. Screens: reference/ours/finder-*.png. Tags display only, no drag and drop yet. Hyprland: class hyprk-finder, set HYPRK_BLUR=1 with a blur rule for the glass sidebar.
- 03:13 settings agent: Hyprland-tested (rules in settings/hyprland-rules.lua work: float, 745x640, centered). Sound Effects -> state/sound.json {alertSound, alertVolume, uiSounds, volumeFeedback}, wallpaper -> state/wallpaper.json {path}, dock -> state/dock.json, appearance.json adds mode/accent/iconStyle/glass. /simplify done, /code-review running. Score settings ~82%.
- 03:18 settings agent: DONE. /code-review fixes committed (d79ec01), VPN/Siri/Spotlight panes added. 23 panes, functional: Appearance, Accessibility (reduce transparency), Wallpaper, Sound (+Sound Effects), Displays, Wi-Fi, Bluetooth, Desktop & Dock. Tests: node --test settings/tests/*.test.js (16 pass). Self-score settings 82%. Next (if more time): verify metrics once SPEC.md section 7 is filled; real SF Symbols/pane icons when assets land in themes/icons/settings/.
- [03:17] shell agent: /simplify + /code-review done and fixed (commits bcfaac4, 8f47182). Applied SPEC.md section 7 metrics (menu bar 30, menu item 24, Dock tile 64/128 magnified, Spotlight 640x56 r28, window radius 16). Added sounds (shell/scripts/sound.sh + state/sound.json, SOUNDS.md), cursor theme via config/hypr/start.sh, Focus menu bar item, dark mode + Reduce Transparency verified. Scores: menu bar 82, dock 78, CC 82, NC 72, banners 72, spotlight 75, apps panel 68, switcher 70. Note: 4 stray idle Hyprland children from my first runs (pids 573829 574275 576400 577560) could not be killed (classifier denied kill -9); harmless, ~13 MB each. Next: shared overlay window base, Glass self-positioning, Finder rules hookup.
- [03:18] finder agent: /simplify + /code-review done and fixed (async gio trash, path-based cursor, search-safe selection, column view folder peek). 3 commits in finder/. Score icon view ~85, list ~80, columns ~75, Quick Look ~65 (in-window panel, not a separate window).

- [done 03:25] themes agent: GTK4/libadwaita + GTK3 theme (themes/gtk, light+dark, traffic lights left), Qt qt6ct palette+QSS (themes/qt), hyprlock 0.9.7 built into hypr-dev prefix + macOS lock screen (lockscreen/). Screens in reference/ours/gtk-*, qt-*, lockscreen.png. Polish pass continuing.

## Scores (per surface, 0-100 vs macOS 27.2)
settings-appearance 85 (03:20, orchestrator visual check)
desktop (menu bar+dock) 75 (03:25, orchestrator)

## What-ifs (user 03:20: "jangan lupa, what if? what if?")
- Build of Hyprland 0.57.2 fails -> fall back to apt hyprland 0.53.3 for testing, keep code 0.57-compatible.
- Quickshell build fails -> run QML with Qt `qml` tool; shell needs Quickshell, so retry deps first.
- Disk fills (/ 73G, /mnt/code 29G at 02:37) -> delete ~/Downloads/macos/work/* (re-creatable from IPSW) first, never the IPSW or dyld-27.2.
- PC hangs/suspends -> sleep inhibited until 07:00; on resume read this file and git log.
- Nested Hyprland hangs GNOME -> kill by PID, never `pkill -f Hyprland` broadly; test with timeouts.
- Agent dies mid-task -> its dir state + commits + this Status list tell what's left; respawn with that.
- Auto-compact -> memory goal-hyprmac-overnight.md points here.
- Feature unsupported on user's hardware/software -> designed fallback (see FALLBACKS.md files).
