-- hyprk Finder window rules (Hyprland 0.57 Lua config). config/hypr/hyprland.lua runs this file with dofile()
-- before its catch-all rules.
--
-- Quick Look (finder/qml/QuickLook.qml): a window of its own, as on 27.2.1 (MAC-ANSWERS.md Q-finder-26: a separate
-- floating panel, layer 3, centred). The client covers the screen with a transparent window and draws the panel, its
-- window shadow and its zoom itself: the panel opens at 0.79 scale in the middle and closes into the file's icon, which
-- lies in another window, so the drawn area must be free to leave the panel's rect. Clicks outside the panel pass
-- through (the window's input region is the panel). Hence: no compositor shadow, border, rounding, blur or open/close
-- animation on this window; it floats above the other windows (pin) and never takes the keyboard, so Finder stays the
-- key window and keeps Space / Esc / the arrows (Quick Look follows the selection).
-- Size: the whole monitor is meant ("monitor_w monitor_h", "move 0 0"), but the catch-all `macos-float` rule that runs
-- after this file caps every window at monitor_w-40 x monitor_h-130 (and then shifts a clamped window off the screen),
-- so until that rule leaves this window alone it asks for exactly that cap, centred; the panel fits inside it.
hl.window_rule({
    name         = "hyprk-finder-quicklook",
    match        = { class = "^(hyprk-finder)$", title = "^(Quick Look)$" },
    float        = true,
    pin          = true,
    center       = true,
    size         = "monitor_w-40 monitor_h-130",
    no_focus     = true,
    no_anim      = true,
    no_shadow    = true,
    no_blur      = true,
    no_dim       = true,
    rounding     = 0,
    border_size  = 0,
})
