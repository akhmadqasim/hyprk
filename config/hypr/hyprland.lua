-- hyprk: Hyprland 0.57 (Lua config) tuned to look and behave like macOS 27.
-- Start nested:  /mnt/code/hyprk/scripts/smoke.sh   (or Hyprland --config this file)

-- repo root: $HYPRK_ROOT, else two levels above this file (config/hypr/hyprland.lua)
local function here()
    local ok, info = pcall(debug.getinfo, 1, "S")
    local src = ok and info and info.source or ""
    return src:match("^@(.*)/config/hypr/[^/]+$")
end
local hyprk   = os.getenv("HYPRK_ROOT") or here() or ((os.getenv("HOME") or "") .. "/.local/share/hyprk")
local shell   = hyprk .. "/shell"
local terminal = os.getenv("HYPRK_TERMINAL") or "ghostty"
local sound   = shell .. "/scripts/sound.sh"

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })
-- MacBook Air-like headless output for screenshots: `hyprctl output create headless MBA`
hl.monitor({ output = "MBA", mode = "2560x1664@60", position = "auto", scale = "2" })
-- macOS default scale per display (SPEC.md 14): 4K and up -> 2x, below -> 1x; HYPRK_SCALE_POLICY=off skips it,
-- HYPRK_LOOKS_LIKE=2560x1440 picks a "looks like" size (see config/hypr/scale-policy.lua)
if os.getenv("HYPRK_SCALE_POLICY") ~= "off" then
    local ok, err = pcall(function() dofile(hyprk .. "/config/hypr/scale-policy.lua").install() end)
    if not ok then print("hyprk: scale policy not applied: " .. tostring(err)) end
end

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
-- Qt Quick text: grayscale AA like macOS (default is RGB subpixel, SPEC.md 14)
hl.env("QSG_DISTANCEFIELD_ANTIALIASING", "gray")

hl.on("hyprland.start", function()
    -- the shell: menu bar, dock, notifications, control center, spotlight
    -- (HYPRK_NO_SHELL=1 skips it, for running qs by hand while debugging)
    if os.getenv("HYPRK_NO_SHELL") == "1" then return end
    hl.exec_cmd("env FONTCONFIG_FILE=" .. hyprk .. "/config/fontconfig/fonts.conf qs -p " .. shell)
end)

----------------------------------------------------------------- look ----
hl.config({
    xwayland = { force_zero_scaling = true },   -- X11 apps render at native pixels instead of being upscaled
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
        shadow = {                       -- macOS window shadow is wide and soft; the SPEC 9 r24/a0.6 numbers are
            enabled = true,              --   CoreAnimation values and look like a hard dark band in Hyprland's
            range = 60,                  --   shadow, so this is tuned by eye against reference/screens (2026-11-10)
            render_power = 2,
            offset = "0 18",
            color = 0x47000000,
            color_inactive = 0x2e000000,
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
        disable_xdg_env_checks = true,   -- nested inside GNOME: XDG_CURRENT_DESKTOP is external
        disable_watchdog_warning = true, -- smoke/nested runs start Hyprland directly
    },
    ecosystem = { no_update_news = true, no_donation_nag = true },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        touchpad = { natural_scroll = true },   -- macOS default
    },
    dwindle = { preserve_split = true },
})

-- macOS motion. Values from the binaries: liquid-glass-re/SPEC.md 9.9.4 (SwiftUI) and 11 (windows).
--   Window open = AppKit ScaleUpAndIn (Solarium): 0.5 s, scale 0.98 -> 1 on a CASpringAnimation
--     (perceptual 0.3, bounce ~0.27, initialVelocity 11.5), NO fade. Hyprland springs start at rest,
--     so the curve is a bezier fitted to the sampled spring (max error 0.013, overshoot 1.046 at 40%).
--   Window close = ScaleDownAndOut: 0.25 s, scale 1 -> 0.98, alpha 1 -> 0 on a critically damped
--     spring (perceptual 0.1812, v0 13) = strong ease-out (bezier fit, max error 0.013).
--   Zoom / frame changes: NSWindow animationResizeTime caps at 0.35 s; NSAnimation default easeInOut.
--   Spaces: Dock's spring was not recovered (SPEC 11.6); SwiftUI default spring (0.5, 1.0) stays.
--   Reduce Motion: no window open/close animation at all, Spaces cross-fade (SPEC 11.2).
-- Hyprland speed unit is 100 ms (speed 5 = 0.5 s); springs run in real time and ignore speed.
hl.curve("swiftui",   { type = "spring", mass = 1, stiffness = 158, damping = 25 })   -- (2pi/0.5)^2, 4pi/0.5
hl.curve("macEase",   { type = "bezier", points = { {0.25, 0.1}, {0.25, 1} } })
hl.curve("macOut",    { type = "bezier", points = { {0.2, 0.9}, {0.3, 1} } })
hl.curve("easeInOut", { type = "bezier", points = { {0.42, 0}, {0.58, 1} } })   -- SwiftUI legacy / NSAnimation default
hl.curve("winOpen",   { type = "bezier", points = { {0.275, 1.475}, {0.225, 0.95} } })  -- ScaleUpAndIn spring
hl.curve("winClose",  { type = "bezier", points = { {0.312, 1.25}, {0.5, 0.912} } })    -- ScaleDownAndOut spring

hl.animation({ leaf = "global",      enabled = true, speed = 5,   bezier = "macEase" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3,   bezier = "macEase" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 3.5, bezier = "macOut",  style = "fade" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 2.5, bezier = "macEase", style = "fade" })
hl.animation({ leaf = "border",      enabled = false })

-- Global so Settings > Accessibility (state/accessibility.lua via `hyprctl eval`, same Lua state)
-- can switch it: hyprk_motion(true) = Reduce Motion.
function hyprk_motion(reduce)
    if reduce then
        hl.animation({ leaf = "windowsIn",   enabled = false })
        hl.animation({ leaf = "windowsOut",  enabled = false })
        hl.animation({ leaf = "fadeIn",      enabled = false })
        hl.animation({ leaf = "fadeOut",     enabled = false })
        hl.animation({ leaf = "workspaces",  enabled = true, speed = 4, bezier = "easeInOut", style = "fade" })
    else
        hl.animation({ leaf = "windowsIn",   enabled = true, speed = 5,   bezier = "winOpen",  style = "popin 98%" })
        hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2.5, bezier = "winClose", style = "popin 98%" })
        hl.animation({ leaf = "fadeIn",      enabled = false })   -- macOS windows appear at full alpha
        hl.animation({ leaf = "fadeOut",     enabled = true, speed = 2.5, bezier = "winClose" })
        hl.animation({ leaf = "workspaces",  enabled = true, speed = 5, spring = "swiftui", style = "slide" })
    end
    hl.animation({ leaf = "windowsMove", enabled = not reduce, speed = 3.5, bezier = "easeInOut" })   -- zoom cap 0.35 s
end
do  -- start from the saved setting so the first frame is already right
    local f = io.open(hyprk .. "/state/appearance.json", "r")
    local txt = f and f:read("a") or ""
    if f then f:close() end
    hyprk_motion(txt:match('"reduceMotion"%s*:%s*true') ~= nil)
end

------------------------------------------------------- liquid glass ----
-- shell layers that carry glass (namespaces hyprk-<name>), shared by the plugin and the blur rule
-- (no menubar: the macOS 26+ menu bar is transparent; its menus live in hyprk-overlay)
local glassLayers = { "dock", "overlay", "controlcenter", "notifications", "spotlight", "switcher", "launchpad" }
-- Own compositor plugin (plugin/, see plugin/README.md). When it loads, the shell
-- sends its glass shapes as ext-background-effect regions (HYPRK_GLASS=plugin) and the
-- plugin draws Liquid Glass behind them. Without it the shell's QML glass is used.
-- On by default; HYPRK_LIQUIDGLASS=0 forces the QML glass.
local glassSo = hyprk .. "/plugin/build/libliquidglass.so"
local h = io.open(glassSo, "r")
if h then h:close() end
hl.env("HYPRK_GLASS", "qml")     -- reset an inherited value; set to "plugin" only after a good load
if h and os.getenv("HYPRK_LIQUIDGLASS") ~= "0" then
    local ok, err = pcall(function()
        hl.plugin.load(glassSo)
        hl.config({ plugin = { liquidglass = {
            -- menubar too: only its pressed title/status pills send glass regions
            namespaces = "hyprk-menubar,hyprk-" .. table.concat(glassLayers, ",hyprk-"),
            -- recipes per layer: the plugin's own `materials` default (plugin/src/Config.cpp)
            -- already maps dock, controlcenter, spotlight, overlay (menu) and menubar (menu)
        } } })
    end)
    if ok then hl.env("HYPRK_GLASS", "plugin") else print("hyprk: liquidglass not loaded: " .. tostring(err)) end
end
-- Window motion Hyprland cannot express (plugin-motion/): the Dock genie on minimize/restore.
-- Minimize stays "move to special:minimized"; the plugin plays the genie first.
local motionSo = hyprk .. "/plugin-motion/build/libhyprkmotion.so"
local hm = io.open(motionSo, "r")
if hm then
    hm:close()
    local ok, err = pcall(hl.plugin.load, motionSo)
    if not ok then print("hyprk: hyprkmotion not loaded: " .. tostring(err)) end
end

---------------------------------------------------------- layer rules ----
-- Real compositor blur behind the shell's glass surfaces. The shell already
-- draws a blurred-wallpaper material; this adds blur of the windows behind.
-- ignore_alpha keeps fully transparent parts (shadows, click catchers) unblurred.
-- Namespaces (set in shell/modules/*.qml via WlrLayershell.namespace):
--   hyprk-menubar hyprk-dock hyprk-overlay hyprk-controlcenter hyprk-notifications
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
    match = { namespace = "^hyprk-(overlay|controlcenter|spotlight|switcher|launchpad|mission|notifications|dock|menubar|wallpaper)$" },
    no_anim = true,
})

------------------------------------------------------------- binds ----
-- SUPER plays the role of Command.
local cmd = "SUPER"
hl.bind(cmd .. " + space",   hl.dsp.global("hyprk:spotlight"))
hl.bind(cmd .. " + Tab",     hl.dsp.global("hyprk:switcher"))
hl.bind(cmd .. " + F4",      hl.dsp.global("hyprk:launchpad"))
hl.bind(cmd .. " + A",       hl.dsp.global("hyprk:launchpad"))
hl.bind(cmd .. " + N",       hl.dsp.global("hyprk:notificationcenter"))
hl.bind(cmd .. " + SHIFT + C", hl.dsp.global("hyprk:controlcenter"))
hl.bind(cmd .. " + Up",      hl.dsp.global("hyprk:missioncontrol"))   -- macOS: Ctrl+Up
hl.bind(cmd .. " + F3",      hl.dsp.global("hyprk:missioncontrol"))   -- plain F3/Ctrl+Up stay with apps
hl.bind(cmd .. " + Q",       hl.dsp.window.close())
hl.bind(cmd .. " + W",       hl.dsp.window.close())
hl.bind(cmd .. " + M",       hl.dsp.window.float({ action = "toggle" }))
hl.bind(cmd .. " + CTRL + F", hl.dsp.window.fullscreen())
hl.bind(cmd .. " + Return",  hl.dsp.exec_cmd(terminal))
hl.bind(cmd .. " + SHIFT + Escape", hl.dsp.exit())
-- Lock Screen like macOS (Ctrl+Cmd+Q). Appearance from state/appearance.json.
hl.bind("CTRL + " .. cmd .. " + Q", hl.dsp.exec_cmd(
    "d=$(jq -r 'if .dark then \"--dark\" else \"\" end' " .. hyprk .. "/state/appearance.json 2>/dev/null); " ..
    hyprk .. "/lockscreen/hyprk-lock.sh $d"))
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
for _, f in ipairs({ hyprk .. "/settings/hyprland-rules.lua", hyprk .. "/finder/hyprland-rules.lua",
                     hyprk .. "/state/accessibility.lua" }) do   -- Settings > Accessibility choices, also without the shell
    local h = io.open(f, "r")
    if h then h:close(); dofile(f) end
end
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })
-- macOS has no tiling: every window floats, opens centered
-- max_size keeps big windows inside the work area (below the 30pt menu bar, above the
-- ~84pt Dock zone); new_float_force_onscreen = 2 (default) then fits them fully.
hl.window_rule({ name = "macos-float", match = { class = ".*" }, float = true, max_size = "monitor_w-40 monitor_h-130" })
