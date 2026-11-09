-- hyprk: Hyprland 0.57 (Lua config) tuned to look and behave like macOS 27.
-- Start nested:  /mnt/code/hyprk/scripts/smoke.sh   (or Hyprland --config this file)

local hyprk   = os.getenv("HYPRK_ROOT") or "/mnt/code/hyprk"
local shell   = hyprk .. "/shell"
local terminal = os.getenv("HYPRK_TERMINAL") or "ghostty"

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })
-- MacBook Air-like headless output for screenshots: `hyprctl output create headless MBA`
hl.monitor({ output = "MBA", mode = "2560x1664@60", position = "auto", scale = "2" })

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland")

hl.on("hyprland.start", function()
    -- the shell: menu bar, dock, notifications, control center, spotlight
    -- (HYPRK_NO_SHELL=1 skips it, for running qs by hand while debugging)
    if os.getenv("HYPRK_NO_SHELL") == "1" then return end
    hl.exec_cmd("env FONTCONFIG_FILE=" .. hyprk .. "/config/fontconfig/fonts.conf qs -p " .. shell)
end)

----------------------------------------------------------------- look ----
hl.config({
    general = {
        gaps_in = 6,
        gaps_out = 10,
        border_size = 0,                 -- macOS windows have no colored border
        resize_on_border = true,
        layout = "dwindle",
    },
    decoration = {
        rounding = 16,                   -- macOS 26+ window corner radius, TODO verify vs SPEC.md
        rounding_power = 3,              -- squircle-ish (continuous corners)
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 40,
            render_power = 2,
            offset = "0 12",
            color = 0x55000000,
            color_inactive = 0x30000000,
        },
        blur = {
            enabled = true,
            size = 12,
            passes = 3,
            noise = 0.02,
            contrast = 1.0,
            brightness = 1.0,
            vibrancy = 0.35,
            popups = true,
        },
    },
    animations = { enabled = true },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        disable_hyprland_guiutils_check = true,
    },
    ecosystem = { no_update_news = true, no_donation_nag = true },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        touchpad = { natural_scroll = true },   -- macOS default
    },
    dwindle = { preserve_split = true },
})

-- macOS-like motion: spring window open, quick fades, genie-less minimize
hl.curve("macSpring", { type = "spring", mass = 1, stiffness = 300, damping = 30 })
hl.curve("macEase",   { type = "bezier", points = { {0.25, 0.1}, {0.25, 1} } })
hl.curve("macOut",    { type = "bezier", points = { {0.2, 0.9}, {0.3, 1} } })

hl.animation({ leaf = "global",      enabled = true, speed = 6,   bezier = "macEase" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3.5, spring = "macSpring", style = "popin 90%" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2.5, bezier = "macEase",   style = "popin 90%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4,   spring = "macSpring" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3,   bezier = "macEase" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 2.5, bezier = "macOut", style = "fade" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 2,   bezier = "macEase", style = "fade" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 4,   bezier = "macOut",  style = "slide" })
hl.animation({ leaf = "border",      enabled = false })

---------------------------------------------------------- layer rules ----
-- Real compositor blur behind the shell's glass surfaces. The shell already
-- draws a blurred-wallpaper material; this adds blur of the windows behind.
-- ignore_alpha keeps fully transparent parts (shadows, click catchers) unblurred.
-- Namespaces (set in shell/modules/*.qml via WlrLayershell.namespace):
--   hyprk-menubar hyprk-dock hyprk-overlay hyprk-notifications
--   hyprk-spotlight hyprk-switcher hyprk-launchpad hyprk-wallpaper
hl.layer_rule({
    name = "hyprk-glass-blur",
    match = { namespace = "^hyprk-(dock|overlay|notifications|spotlight|switcher)$" },
    blur = true,
    ignore_alpha = 0.35,
})
hl.layer_rule({
    name = "hyprk-menubar-blur",
    match = { namespace = "^hyprk-menubar$" },
    blur = true,
    ignore_alpha = 0.01,
})
hl.layer_rule({
    -- the shell animates these itself
    name = "hyprk-no-anim",
    match = { namespace = "^hyprk-(overlay|spotlight|switcher|launchpad|notifications|dock|menubar|wallpaper)$" },
    no_anim = true,
})

------------------------------------------------------------- binds ----
-- SUPER plays the role of Command.
local cmd = "SUPER"
hl.bind(cmd .. " + space",   hl.dsp.global("hyprk:spotlight"))
hl.bind(cmd .. " + Tab",     hl.dsp.global("hyprk:switcher"))
hl.bind("F4",                hl.dsp.global("hyprk:launchpad"))
hl.bind(cmd .. " + A",       hl.dsp.global("hyprk:launchpad"))
hl.bind(cmd .. " + N",       hl.dsp.global("hyprk:notificationcenter"))
hl.bind(cmd .. " + SHIFT + C", hl.dsp.global("hyprk:controlcenter"))
hl.bind(cmd .. " + Q",       hl.dsp.window.close())
hl.bind(cmd .. " + W",       hl.dsp.window.close())
hl.bind(cmd .. " + M",       hl.dsp.window.float({ action = "toggle" }))
hl.bind(cmd .. " + CTRL + F", hl.dsp.window.fullscreen())
hl.bind(cmd .. " + Return",  hl.dsp.exec_cmd(terminal))
hl.bind(cmd .. " + SHIFT + Escape", hl.dsp.exit())
hl.bind(cmd .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(cmd .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
for i = 1, 9 do
    hl.bind("CTRL + " .. i, hl.dsp.focus({ workspace = i }))          -- macOS: Ctrl+N switches Spaces
    hl.bind("CTRL + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind("CTRL + left",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind("CTRL + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 6%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 6%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set 6%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 6%-"), { locked = true, repeating = true })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

------------------------------------------------------------ windows ----
-- rules shipped by the other hyprk apps (optional)
for _, f in ipairs({ hyprk .. "/settings/hyprland-rules.lua", hyprk .. "/finder/hyprland-rules.lua" }) do
    local h = io.open(f, "r")
    if h then h:close(); dofile(f) end
end
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })
