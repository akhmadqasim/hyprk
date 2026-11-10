# Issues found while building dist/ (not fixed, other dirs are not mine)

1. Hyprland 0.57.2 segfaults when it exits (`hl.dsp.exit()`), every run, with and without the liquidglass plugin
   (HYPRK_LIQUIDGLASS=0 too). Kernel log: `Hyprland[pid]: segfault at 0 ... in Hyprland[6657d1,...]`; the address
   resolves to `IPC::Socket2::CSocket2::postEvent(SEvent&&)` (null deref, probably an event posted during shutdown).
   Upstream bug, harmless for nested (dist/try-nested.sh cleans up), but in the login session it means "Log Out"
   ends with a crash. Check `journalctl -k | grep segfault`.
2. aquamarine's Wayland backend (nested) ignores the monitor mode/size from the Hyprland config: GNOME lets the
   client pick, so the window opens at 1280x720 logical; resize it with the mouse. Fixed 2026-11-10: upstream
   aquamarine 0.16.0 rendered that 1280x720 at buffer scale 1, so GNOME upscaled it 1.5-2x (soft text).
   hypr-dev/patches/aquamarine-0.16.0-wayland-hidpi.patch adds wp_fractional_scale_v1 + wp_viewporter (and
   wl_surface.preferred_buffer_scale): the buffer is logical size x host scale (2560x1440 at 200%), the cursor too,
   and try-nested.sh sets HYPRK_SCALE to the GNOME primary monitor scale. Crops: reference/ours/nested-hidpi-*.png
   (top: before, simulated 2x bilinear upscale of the old buffer; bottom: after). No keyboard-shortcuts-inhibit
   yet, so the Super key stays with GNOME. dist/hyprk-dist.lua adds Ctrl+Alt fallbacks (nested only).
3. At 1280x720 the Finder window (finder/run.sh, no height limit) is taller than the screen and overlaps the menu
   bar (reference/ours: grim of a nested session after `finder/run.sh /mnt/code/hyprk`). Needs a max size from the
   output size, or a windowrule that keeps windows inside the reserved area.
4. config/hypr/hyprland.lua sets the monitor rule `output = ""` with scale 1. On the real 4K screens (DP-1, DP-2) the
   login session needs scale 1.5; dist/hyprk-dist.lua appends a rule from `HYPRK_SCALE`. Better to move this into
   config/hypr (e.g. read HYPRK_SCALE there) so there is one place.
5. config/fontconfig/fonts.conf has the absolute path /mnt/code/hyprk/themes/fonts (fine here, breaks if the
   repo moves). dist/lib/env.sh generates its own fontconfig file instead.
6. themes/gtk/DIST-NOTES.md: `GTK_USE_PORTAL=0` does NOT stop GTK 4 from reading button-layout/theme from the host
   portal (verified: Gtk.Settings still returned the host values). `GDK_DEBUG=no-portals` does; dist/lib/env.sh sets it.
   Add it to DIST-NOTES.md. With it, a plain libadwaita window shows traffic lights on the left (reference/ours/dist-try-adw.png).
7. Ghostty 1.3-dev hard-codes its CSD buttons on the right. Fixed by `window-decoration = server` plus the plugin title bar,
   but Ghostty does not bind xdg-decoration in this build, so `titlebar = "auto"` gave it no bar; dist/hyprk-dist.lua adds
   its class to `titlebar_classes`. Works (reference/ours/dist-try-ghostty.png, foot and qt6ct also checked,
   dist-try-qt.png). Cosmetic: under the bar the terminal's own rounded top corners are still visible (Ghostty keeps its
   rounded content); the bar could cover or the plugin could square the client's top edge.
   Also: qt6ct is installed now but Kvantum is not; try-nested.sh uses plain qt6ct+QSS. Qt look is not verified nested.
8. Not verified (no input device available to the agent): Super and Ctrl+Alt key delivery from a real keyboard to the
   nested window, clicking in the Dock, Apple menu > Log Out in nested, multi-monitor behaviour (DP-1 + DP-2) of the
   shell, and the whole login session (install-session.sh and hyprk-session were never run, only --dry-run / --print).
9. PROGRESS.md says 4 stray Hyprland pids (573829 574275 576400 577560) are still running; user must kill them.
10. Lock in the login session: shell/services/Power.qml calls `hyprlock -c <repo>/lockscreen/hyprlock.conf` directly.
   dist/bin/hyprlock is a PATH shim (session only) that turns that call into lockscreen/hyprk-lock.sh. Cleaner: let
   Power.qml call hyprk-lock.sh itself, then the shim can go. Shim tested with a fake hyprlock only, not a real lock.
