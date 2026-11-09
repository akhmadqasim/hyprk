-- hyprk: Hyprland 0.57 (Lua config) tuned to look and behave like macOS 27.
-- Start nested:  /mnt/code/hyprk/scripts/smoke.sh   (or Hyprland --config this file)

local hyprk   = os.getenv("HYPRK_ROOT") or "/mnt/code/hyprk"
local shell   = hyprk .. "/shell"
local terminal = os.getenv("HYPRK_TERMINAL") or "ghostty"
local sound   = shell .. "/scripts/sound.sh"

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })
-- MacBook Air-like headless output for screenshots: `hyprctl output create headless MBA`
hl.monitor({ output = "MBA", mode = "2560x1664@60", position = "auto", scale = "2" })

-- macOS cursors (themes/cursors, Xcursor + hyprcursor). Size is in logical px,
-- so 24 renders at 48 px on the scale-2 MBA output.
local cursors = hyprk .. "/themes/cursors/theme"
-- start.sh already exports these for Hyprland itself; repeat them for apps it launches
local xcp = os.getenv("XCURSOR_PATH") or "/usr/share/icons"
if not xcp:find(cursors, 1, true) then xcp = cursors .. ":" .. xcp end   -- no growth on reload
hl.env("XCURSOR_PATH", xcp)
hl.env("XCURSOR_THEME", "hyprk-cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "hyprk-cursors")
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
        border_size = 1,                 -- macOS: thin dark contour (SPEC.md 7.1 ring shadow), not a colored border
        col = {
            active_border   = "rgba(0000001f)",
            inactive_border = "rgba(00000017)",
        },
        resize_on_border = true,
        layout = "dwindle",
    },
    decoration = {
        rounding = 16,                   -- SPEC.md 7: titled window corner radius 16 pt
        rounding_power = 2.8,            -- SPEC.md 7.1: continuous corner guess
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {                       -- glass-defaults.json macWindowShadow: active r24 (0,10) a0.6, inactive r16 (0,4) a0.45
            enabled = true,
            range = 40,                  -- Hyprland spread ~ 1.6x Apple's Gaussian radius 24
            render_power = 3,            -- closer to a Gaussian falloff than 2
            offset = "0 10",
            color = 0x73000000,          -- 0.45: Apple's 0.6 is a Gaussian peak, Hyprland's ramp is fuller
            color_inactive = 0x4d000000, -- 0.30 (inactive 0.45 scaled the same way)
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

------------------------------------------------------- liquid glass ----
-- shell layers that carry glass (namespaces hyprk-<name>), shared by the plugin and the blur rule
-- (no menubar: the macOS 26+ menu bar is transparent; its menus live in hyprk-overlay)
local glassLayers = { "dock", "overlay", "notifications", "spotlight", "switcher", "launchpad" }
-- Own compositor plugin (plugin/, see plugin/README.md). When it loads, the shell
-- sends its glass shapes as ext-background-effect regions (HYPRK_GLASS=plugin) and the
-- plugin draws Liquid Glass behind them. Without it the shell's QML glass is used.
-- On by default; HYPRK_LIQUIDGLASS=0 forces the QML glass.
local glassSo = hyprk .. "/plugin/build/libliquidglass.so"
local h = io.open(glassSo, "r")
if h and os.getenv("HYPRK_LIQUIDGLASS") ~= "0" then
    h:close()
    local ok, err = pcall(function()
        hl.plugin.load(glassSo)
        hl.config({ plugin = { liquidglass = {
            namespaces = "hyprk-" .. table.concat(glassLayers, ",hyprk-"),
            -- macOS 27 Dock/CC look: light near-neutral frost (by eye vs reference/screens)
            tint_light = 0xFFFFFF4D,
            saturation = 1.15,
            brightness_light = 1.08,
        } } })
    end)
    if ok then hl.env("HYPRK_GLASS", "plugin") else print("hyprk: liquidglass not loaded: " .. tostring(err)) end
end

---------------------------------------------------------- layer rules ----
-- Real compositor blur behind the shell's glass surfaces. The shell already
-- draws a blurred-wallpaper material; this adds blur of the windows behind.
-- ignore_alpha keeps fully transparent parts (shadows, click catchers) unblurred.
-- Namespaces (set in shell/modules/*.qml via WlrLayershell.namespace):
--   hyprk-menubar hyprk-dock hyprk-overlay hyprk-notifications
--   hyprk-spotlight hyprk-switcher hyprk-launchpad hyprk-wallpaper
hl.layer_rule({
    name = "hyprk-glass-blur",
    match = { namespace = "^hyprk-(" .. table.concat(glassLayers, "|") .. ")$" },
    blur = true,
    ignore_alpha = 0.35,
})
hl.layer_rule({
    -- the shell animates these itself
    name = "hyprk-no-anim",
    match = { namespace = "^hyprk-(overlay|spotlight|switcher|launchpad|mission|notifications|dock|menubar|wallpaper)$" },
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
hl.bind(cmd .. " + Up",      hl.dsp.global("hyprk:missioncontrol"))   -- macOS: Ctrl+Up
hl.bind("CTRL + Up",         hl.dsp.global("hyprk:missioncontrol"))
hl.bind("F3",                hl.dsp.global("hyprk:missioncontrol"))
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
-- volume keys play the macOS volume pop (honors state/sound.json volumeFeedback)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 6%+ && " .. sound .. " volume"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 6%- && " .. sound .. " volume"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set 6%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 6%-"), { locked = true, repeating = true })

-- screenshots like macOS: Cmd+Shift+3 full screen, Cmd+Shift+4 area (needs slurp), shutter sound
-- xdg-user-dir knows localized folders; mkdir so a fresh home works
local shotFile = '"$(d=$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures"); mkdir -p "$d"; echo "$d")/Screenshot $(date "+%Y-%m-%d at %H.%M.%S").png"'
hl.bind(cmd .. " + SHIFT + 3", hl.dsp.exec_cmd("grim " .. shotFile .. " && " .. sound .. " screenshot"))
hl.bind(cmd .. " + SHIFT + 4", hl.dsp.exec_cmd("command -v slurp >/dev/null && grim -g \"$(slurp)\" " .. shotFile .. " && " .. sound .. " screenshot"))
hl.bind("Print",               hl.dsp.exec_cmd("grim " .. shotFile .. " && " .. sound .. " screenshot"))

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

------------------------------------------------------------ windows ----
-- rules shipped by the other hyprk apps (optional)
for _, f in ipairs({ hyprk .. "/settings/hyprland-rules.lua", hyprk .. "/finder/hyprland-rules.lua" }) do
    local h = io.open(f, "r")
    if h then h:close(); dofile(f) end
end
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })
-- macOS has no tiling: every window floats, opens centered
hl.window_rule({ name = "macos-float", match = { class = ".*" }, float = true, center = true })
