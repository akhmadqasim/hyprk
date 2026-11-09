# Issues found while building dist/ (not fixed, other dirs are not mine)

1. Hyprland 0.57.2 segfaults when it exits (`hl.dsp.exit()`), every run, with and without the liquidglass plugin
   (HYPRK_LIQUIDGLASS=0 too). Kernel log: `Hyprland[pid]: segfault at 0 ... in Hyprland[6657d1,...]`; the address
   resolves to `IPC::Socket2::CSocket2::postEvent(SEvent&&)` (null deref, probably an event posted during shutdown).
   Upstream bug, harmless for nested (dist/try-nested.sh cleans up), but in the login session it means "Log Out"
   ends with a crash. Check `journalctl -k | grep segfault`.
2. aquamarine's Wayland backend (nested) ignores the monitor mode/size from the Hyprland config: the window size
   is whatever GNOME gives (1280x720 or about 1920x1050). `hl.monitor{mode=...}` only changes what Hyprland thinks.
   It also has no fractional-scale or keyboard-shortcuts-inhibit support, so on a 150% host screen the nested picture
   is upscaled (soft), and the Super key stays with GNOME. dist/hyprk-dist.lua adds Ctrl+Alt fallbacks (nested only).
3. At 1280x720 the Finder window (finder/run.sh, no height limit) is taller than the screen and overlaps the menu
   bar (reference/ours: grim of a nested session after `finder/run.sh /mnt/code/hyprk`). Needs a max size from the
   output size, or a windowrule that keeps windows inside the reserved area.
4. config/hypr/hyprland.lua sets the monitor rule `output = ""` with scale 1. On the real 4K screens (DP-1, DP-2) the
   login session needs scale 1.5; dist/hyprk-dist.lua appends a rule from `HYPRK_SCALE`. Better to move this into
   config/hypr (e.g. read HYPRK_SCALE there) so there is one place.
5. config/fontconfig/fonts.conf has the absolute path /mnt/code/hyprk/themes/fonts (fine here, breaks if the
   repo moves). dist/lib/env.sh generates its own fontconfig file instead.
6. qt6ct is not installed on the host, so the Qt theme (themes/qt) cannot be shown nested; try-nested.sh prints a hint
   and skips it. Not verified: Kvantum/qt6ct look inside the nested session.
7. Not verified (no input device available to the agent): Super and Ctrl+Alt key delivery from a real keyboard to the
   nested window, clicking in the Dock, Apple menu > Log Out in nested, multi-monitor behaviour (DP-1 + DP-2) of the
   shell, and the whole login session (install-session.sh and hyprk-session were never run, only --dry-run / --print).
8. PROGRESS.md says 4 stray Hyprland pids (573829 574275 576400 577560) are still running; user must kill them.
