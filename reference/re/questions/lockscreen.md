# Questions for the Mac: lockscreen
Scope: lock, unlock, wrong password, sleep and display-off, saver to lock, login window, accessibility. pt at 2x, light and dark if different. H=lockscreen/hyprlock.conf P=shell/services/Prefs.qml
hyprlock cannot do glass, shake, fly-out unlock, notifications or widgets; ask anyway, we pick the fallback.

Q-lockscreen-01 Wallpaper treatment
now: blur 2 passes/6, brightness .84, contrast .95, vibrancy .25 (H:29-39, guessed)
ask: Same picture as desktop? Blur radius pt, dim or tint pixel delta, saturation, light and dark.

Q-lockscreen-02 Clock face
now: SF Pro Rounded 124 bold, white a0.95, flat (H:54-63; screenshot says macOS is heavier)
ask: Font, size, wght, tracking, digit height, colour, alpha, flat or glass/vibrant, light and dark.

Q-lockscreen-03 Clock position
now: top offset 118, centred (H:62, guessed)
ask: AX frame of the time and bbox of digits, centred? Notch Air and external display; with and without widgets.

Q-lockscreen-04 Clock format
now: 24 h "%-H:%M", no AM/PM (H:56, guessed)
ask: 12 h and 24 h look: AM/PM shown, leading zero. Does it follow the system setting?

Q-lockscreen-05 Date line
now: "Tuesday, November 10", 24 w500 a0.92, 92 from top (H:44-48, guessed)
ask: Exact format, font, size, weight, colour, bbox, gap to the clock. Order in other locales.

Q-lockscreen-06 Avatar
now: 96 circle, 132 above bottom, soft shadow (H:66-79, guessed)
ask: Diameter, AX frame, border, shadow, distance from screen bottom. Initials avatar when no photo?

Q-lockscreen-07 User name
now: SF Pro 17 regular a0.95, 96 above bottom (H:82-91, guessed)
ask: Font, size, weight, colour, y, gap to avatar and to the field, shadow.

Q-lockscreen-08 Password field frame
now: 210x36, radius full, 40 above bottom (H:94-102,114, guessed)
ask: AX frame, corner radius, bottom offset, gap to name. Does the layout change with Touch ID or a hint?

Q-lockscreen-09 Field material
now: white a0.36 fill, 1px a0.40 line, no backdrop blur (H:103-104, guessed)
ask: Glass (backdrop layer)? Pixel inside and outside the field over light and dark wallpaper, border colour, specular.

Q-lockscreen-10 Placeholder
now: "Enter Password" 14pt a0.85 (H:111, guessed)
ask: Exact text with and without Touch ID, font, size, colour, alignment. Is the field shown at once or after a key or click? Return arrow button?

Q-lockscreen-11 Typed dots and caret
now: dots 26% of height, spacing .35, no caret (H:99-101, guessed)
ask: Dot diameter, spacing, colour, limit and scrolling, caret blink, caps-lock indicator look and position (H:109 orange).

Q-lockscreen-12 Wrong password
now: red field a0.55, text "Incorrect password", no shake (H:108,112, guessed)
ask: 60 fps: shake amplitude pt, count, duration, curve; red tint? text? is the field cleared, how long until typing again.

Q-lockscreen-13 Hint and lockout
now: missing
ask: After how many failures a password hint shows, its text, position and style. Lockout or delay message after many failures.

Q-lockscreen-14 Touch ID line
now: missing (FALLBACKS.md:153)
ask: Text ("Touch ID or Enter Password"?), font, size, position, colour, how it changes on failed touch.

Q-lockscreen-15 Bottom buttons
now: missing
ask: Cancel, Switch User, Sleep, Restart, Shut Down: which show on lock and on login window, labels, style, frames, material.

Q-lockscreen-16 Status items top right
now: Wi-Fi + battery 28px at x-58/-20, y-11, no percent (H:119-142, S; guessed)
ask: Right-to-left list on lock (battery, Wi-Fi, keyboard layout, Bluetooth, Focus?), AX frames, glyph size, colour, right margin.

Q-lockscreen-17 Keyboard layout item
now: missing
ask: Only with more than one input source? Look, text or flag, position, popup on click.

Q-lockscreen-18 Lock-in motion
now: fade in 0.4 s ease, nothing else (H:19-23, guessed)
ask: 60 fps from Ctrl+Cmd+Q: wallpaper blur ramp, clock and field appearing (fade, scale, offset), menu bar and Dock fate, durations, curves.

Q-lockscreen-19 Unlock motion
now: fade out 0.3 s ease (H:24, guessed)
ask: 60 fps after correct password and after Touch ID: what moves where (field, avatar, clock), blur removal, desktop reveal, durations, curves.

Q-lockscreen-20 Notifications on lock
now: missing; whenLocked=true only a setting (P:20)
ask: Banner position, size, grouping, glass, preview hiding rule ("when unlocked"), how many stack, tap or swipe behaviour.

Q-lockscreen-21 Now Playing
now: missing
ask: Widget position, size, artwork, controls, material, when it appears and hides, light and dark.

Q-lockscreen-22 Widgets
now: missing; largeClock "lock" in P:21
ask: Does 27.2.1 have lock screen widgets? If so: area, sizes, how the clock moves, Edit entry, "Show large clock" values.

Q-lockscreen-23 Lock settings
now: saver 1200 s, display off 600 s, password after 0 (P:21,55-62, guessed)
ask: defaults read for saver and sleep timeouts, require password delay options and default, lock message option, text and position.

Q-lockscreen-24 Saver to lock
now: lock fires straight from idle, no saver (P:60-62)
ask: 60 fps: saver running, key press, then lock screen: crossfade time, what shows first, is the field visible at once, password prompt delay.

Q-lockscreen-25 Display off and wake
now: instant DPMS off at 600 s (P:55-58, guessed)
ask: Dim step before off (when, level), fade to black duration, wake to lock fade-in, lid close and open, first frame on wake.

Q-lockscreen-26 Login window
now: none, only a lock screen
ask: Screenshot after reboot: wallpaper, clock?, user list or one avatar, field, buttons, menu bar, FileVault screen. What differs from lock.

Q-lockscreen-27 Reduce Transparency
now: ignored (none)
ask: Lock screen with it on: wallpaper blur, field material, notification glass, status items, pixel values.

Q-lockscreen-28 Reduce Motion
now: ignored (none)
ask: Lock-in, unlock and wrong password with it on: replaced by crossfade? durations, does the shake stay.

Q-lockscreen-29 Larger text and contrast
now: fixed sizes (H)
ask: With larger text or Increase Contrast: do clock, date, name, field and placeholder change in size or colour?

Q-lockscreen-30 Several displays
now: one config for every monitor (H:30 monitor empty)
ask: Lock on external display: clock, field, avatar on both or only one, wallpaper per display, which gets keyboard focus.

Q-lockscreen-31 Light and dark
now: one look; only the wallpaper file differs (hyprk-lock.sh)
ask: Does appearance change clock tint, field, dim or blur on the lock screen? Dynamic wallpaper: which frame shows?

Q-lockscreen-32 Cursor
now: hidden always (H:14, guessed)
ask: Is the pointer visible on lock? Hidden until the mouse moves? Shape over the field.

Q-lockscreen-33 Lock triggers
now: Ctrl+Cmd+Q, Apple menu, Spotlight, idle all lock at once (hyprland.lua:225, P:62)
ask: Lock Screen vs Sleep vs lid close: which show a lock screen, which delay it, is the animation the same for each?
