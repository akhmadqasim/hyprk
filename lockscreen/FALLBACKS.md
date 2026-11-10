# Lock screen fallbacks

The lock screen is part of the shell: `shell/modules/lock/` (Quickshell `WlSessionLock` + `PamContext`).
hyprlock with `hyprlock.conf` is the fallback when the shell cannot lock.

## Who locks

| Request | Path |
|---|---|
| Ctrl+Cmd+Q (`config/hypr/hyprland.lua`), scripts, hypridle `lock_cmd` | `lockscreen/lock.sh`: `qs ipc --pid <pid> call lock lock` on the hyprk shell that runs on the same Wayland display (a nested session never locks its host). No such shell, or no answer: `hyprk-lock.sh` (hyprlock), `--dark` from `state/appearance.json`. |
| Apple menu, Spotlight "Lock Screen", idle timer (`Prefs.qml`, lock.json) | `Power.lock()` -> the shell lock. Without the lock module: `hyprk-lock.sh`, then `loginctl lock-session`. Only with `HYPRK_ALLOW_POWER=1` (real session), so a nested test session never locks itself after 20 idle minutes. |
| `qs ipc call lock lock` | the shell lock directly (`qs ipc call lock state` prints the phase as JSON). |
| The compositor refuses the lock (no ext-session-lock, another locker active) | the shell runs `hyprk-lock.sh`. Note: `hyprk-lock.sh` exits at once when any hyprlock of this user already runs. |

The shell lock never engages on load or reload, only on one of these requests.

## Shell lock: wanted vs fallback

| Wanted | Fallback |
|---|---|
| Blurred, dimmed wallpaper | Blurred once per wallpaper by `shell/modules/lock/lock-wallpaper.sh` (ImageMagick) into `~/.cache/hyprk/lock-*.png` at a quarter of the screen size, 16 bit, scaled up smoothly; no live blur. No ImageMagick or no file yet: the sharp wallpaper under the stronger solid dim. No wallpaper at all: a plain fill. |
| Glass password field, notification and Now Playing cards | `LockGlass.qml`: face tint, top-lit rim and the regular-glass drop shadow over the already blurred backdrop. Never the compositor plugin (session lock surfaces are not layer surfaces), so the lock looks the same with or without `plugin/`. |
| Reduce Transparency / Increase Contrast | sharp wallpaper under a solid dim, opaque field and cards. |
| Reduce Motion | lock-in and unlock become 150 ms cross-fades with no travel; a wrong password fades the dots instead of shaking. |
| Lock-in from the desktop, unlock revealing the desktop | Hyprland draws nothing under a lock surface, so both run in `hyprk-lock` overlay layer surfaces (`LockOverlay.qml`, no compositor layer animation): "in" fades the lock over the live desktop with the keyboard grabbed, then the session lock engages with the same picture; "out" appears under the lock, the lock is released once every screen has shown a frame, then it animates away and is click-through. If an overlay never maps, a guard locks (or releases) after a short timeout anyway. |
| Touch ID line | none: no fingerprint flow. The line under the field shows "Incorrect password", PAM error text, and after 3 failures the hint (`state/lock.json` `hint`, else a generic text). |
| Caps Lock indicator | read from `hyprctl devices -j` (main keyboard) on lock and on Caps Lock release. |
| Keyboard layout switching | the compositor keymap works as usual on the lock; Ctrl+Space or a click on the input-source item runs `hyprctl switchxkblayout all next`. The item shows only with more than one layout. |
| Notifications on lock | `Notifs` history since the lock, up to 3, text hidden unless Show previews is Always; none when `notifications.json` `whenLocked` is false. |
| Now Playing | the shell's MPRIS pick (`State.pickPlayer`), shown while a player has a track. |
| User picture | `~/.face`, else the AccountsService icon, else initials on a grey disc. Name from GECOS, else `$USER`. |
| PAM | service `login` from `/etc/pam.d` (Ubuntu: `pam_faildelay` makes a wrong password answer after about 2.5 s; the field is read-only meanwhile). |

## hyprlock (fallback): wanted vs fallback

| Wanted | Fallback |
|---|---|
| SF Pro Rounded / SF Pro for the clock, date, name | `$FONT` / `$FONT_ROUNDED` at the top of `hyprlock.conf`. Pango/fontconfig falls back to the next installed sans (Inter, Cantarell, Noto Sans) when the family is missing. Fonts come from `themes/fonts` via `config/fontconfig/fonts.conf`; put `FONTCONFIG_FILE` in the environment of the process that starts hyprlock. |
| Bold clock/date | pango markup `<span font_weight='700'>` in the label text (hyprlock has no weight option); the variable SF Pro / SF Pro Rounded picks the matching instance. Without SF the fallback font gets bold synthesised. |
| Wallpaper | `state/wallpaper.json` path (the desktop wallpaper), else TahoeLight (TahoeDark with `--dark`), chosen when install.sh runs. `hyprk-lock.sh` redoes it at every lock. |
| Status icons (Wi-Fi, battery) | `scripts/status-icon.sh` reads /sys (wireless link, BAT0). Desktop without Wi-Fi/battery: empty icon. Icons are PNGs drawn by `assets/gen-status-icons.py`. |
| Blurred wallpaper | hyprlock's own blur (`blur_passes`, `blur_size`). If the GPU/driver cannot do it, set `blur_passes = 0` and the picture is just dimmed (`brightness`). If no wallpaper file exists hyprlock draws a solid colour: add `color = rgba(30, 30, 30, 1.0)` to the `background` block. |
| Glass password pill (backdrop blur behind the field) | hyprlock cannot blur behind a widget, so the pill is a 32% white fill with a 40% white hairline (`inner_color`/`outer_color`). Clock and date have no shadow (macOS has none). |
| Touch ID line | none (no fingerprint reader flow in hyprlock). |
| User picture | `~/.face`, else the AccountsService icon, else a round initials avatar (`scripts/initials-avatar.py`, needs python3-pil and an SF/DejaVu font), else `assets/avatar-default.png`. Rounded by hyprlock (`rounding = -1`). |
| Full name | GECOS field from `getent passwd`, else `$USER`. |
| Lock animations | hyprlock `animations` block (fade in/out); macOS' zoom/slide-up unlock is not reproducible. |

## If the lock client dies (recovery)

A crash of the shell (or hyprlock) while locked does not unlock: Hyprland 0.57 keeps the session locked and,
after `misc:lockdead_screen_delay` (1 s), shows its "the lockscreen app died" screen. A new lock is refused
unless `misc:allow_session_lock_restore` is on (off by default). Two ways back, both tested in a headless
session (kill -9 of the shell while locked):

1. From another TTY (Ctrl+Alt+F3, log in), or over SSH as the same user:
   `hyprctl --instance 0 eval 'hl.clear_crashed_lockscreen()'` (`hyprctl instances` lists the numbers).
   It unlocks only when no lock client is alive, as the lockdead screen says.
2. Lock again with a working client, then unlock with the password:
   `hyprctl --instance 0 eval 'hl.config({ misc = { allow_session_lock_restore = true } })'`, start the shell
   (`qs -p <repo>/shell`, or `hyprk-lock.sh` for hyprlock) and run `lockscreen/lock.sh`.

Reloads: file watching is off while the lock is up, so saving a file in `shell/` does not reload the shell
under the lock (the change loads at the next save after unlock). A forced reload (`Quickshell.reload`) keeps
the lock: the lock state and the password screen are `PersistentProperties` restored before the new
`WlSessionLock` takes the old lock object over (tested; Quickshell logs a harmless "Session lock object was
destroyed without unlocking" for the old object). `Lock.qml`'s first two children must stay first for this.

## Testing without your password

Never lock your real or nested session. Use your own headless session and the PAM test double:

    eval "$(lockscreen/tools/lock-test-env.sh /path/to/scratch/pam)"   # HYPRK_LOCK_TEST=1 HYPRK_LOCK_PAMDIR=...
    HYPRK_HEADLESS=1 HYPRK_KEEP=1 scripts/smoke.sh /path/to/out.png
    lockscreen/tools/build-vkbd.sh /path/to/vkbd                       # virtual keyboard
    export WAYLAND_DISPLAY=<test socket> HYPRLAND_INSTANCE_SIGNATURE=<test instance>
    qs ipc --pid <test shell pid> call lock lock            # or: printf 'C q\n' | /path/to/vkbd (Ctrl+Cmd+Q)
    printf 't wrong\nk Return\n' | /path/to/vkbd            # the double says no: the field shakes
    printf 't hyprk-test-pass\nk Return\n' | /path/to/vkbd  # the double says yes: unlock

Without `HYPRK_LOCK_PAMDIR` the same session checks against the real `/etc/pam.d/login`: that is how the
wrong-password path is tested for real. It cannot unlock without the password, so end that test with
recovery 1 above.
