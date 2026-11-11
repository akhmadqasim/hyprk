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
-- runtime state folder: start.sh decides and exports it (config/hypr/state-dir.sh); this default only covers a bare `Hyprland --config`
local state   = os.getenv("HYPRK_STATE") or (hyprk .. "/state")

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
        border_size = 1,                 -- the outer black rim; colours per appearance in hyprk_appearance() below
        resize_on_border = true,
        layout = "dwindle",
    },
    decoration = {
        -- MAC-ANSWERS.md Q-windows-02: 16 pt continuous corner on every window type (it spans 24 pt). Hyprland draws
        -- a superellipse of radius rounding * rounding_power / 2 (WindowPresentation::rounding(), "perceived
        -- roundness"), in logical px times the monitor scale. The fit to the Finder corner is radius 36-39.5 pt,
        -- power 5.05-5.75 (Q-windows-02); `rounding` is an integer, so 14 x 5.39 / 2 = 37.7 pt (RMS 0.004 pt against
        -- the two fits). Edge inset at 2x rows 0/8/16/32: Mac 35/11/4/1 px, this 34/10/4/1 (36 / 5.05 drew a 90.9 pt
        -- radius: 103/48/32/16). Clients that draw their own 16 pt circle stay inside it to 0.27 pt.
        rounding = 14,
        rounding_power = 5.39,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        -- Q-windows-01: pure black, alpha measured at 2/8/16/32 pt below, beside and above a Finder window; AppKit
        -- draws a Gaussian (blur 20 / 8 pt, y 18 / 7, density .40 / .22 light, .70 / .45 dark, active / inactive),
        -- so below the window is ~1.7x darker than beside it at 2 pt. Hyprland has one falloff a * (x / range)^power
        -- for all sides and all states, with the edge at full alpha, so one colour cannot get both (best single fit,
        -- range 52 / power 4 / y 12: side .27 vs .18 at 2 pt). The colour is a gradient over the shadow box, though:
        -- a vertical one (top -> bottom stops, hyprk_appearance() below) gives the band above, the sides and the band
        -- below their own alpha. Fit of range, power, offset and the three alphas per state to the 48 profile points
        -- (window 700 x 533): range 70, power 3, y 4. See reference/ours/windows/SHADOW.md for the on-screen numbers.
        -- With the liquidglass plugin loaded (below) the plugin draws AppKit's shadow instead and this one is off.
        shadow = {
            enabled = true,
            range = 70,
            render_power = 3,
            offset = "0 4",
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
    -- Shrinking frames (unzoom, full screen exit, a resize): when the box is larger than the size the client acked,
    -- Hyprland's default draws the buffer 1:1 and smears its last row and column over the rest. Qt clients with a
    -- fractional-scale viewport (Finder, Settings) take that path (foot does not), so for the first 120-180 ms of an
    -- unzoom the window showed the new layout in a corner with a white L-shaped smear and the sidebar's bottom row
    -- dragged down (mcap, black backdrop, window rect area share vs the R2 unzoom series: Finder rms 0.122 / 38 ms,
    -- Settings 0.058 / 16 ms). Off, the buffer is stretched to the animated frame like any other client:
    -- Finder 0.005-0.007 / 1.7-1.8 ms, Settings 0.007 / 2.0 ms (Mac 267 ms, ours 267 ms).
    render = { expand_undersized_textures = false },
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        touchpad = { natural_scroll = true },   -- macOS default
    },
    dwindle = { preserve_split = true },
})

-- Light and dark chrome (MAC-ANSWERS.md Q-windows-01, -03), black alpha per state:
--   shadow: alpha above / beside / below (see decoration.shadow), as a 10-stop vertical gradient over the shadow box
--     (top, top, side x6, bottom, bottom: stops are evenly spaced, so the band above and below keeps its own alpha
--     for windows from ~520 pt tall; on smaller ones the ends blend into the side value). The side alpha also ramps
--     to the bottom value over the lowest ~75 pt of the window's sides (Mac: constant to the corner), the cost of
--     the gradient: 2D field rms against the Gaussian model is still .039 -> .031.
--     light active .074 / .19 / .327, inactive .027 / .067 / .122; dark active .132 / .334 / .573, inactive .054 / .143 / .252
--   outer rim: 0.5 pt (1 px at 2x) black dark .93 / .83, light .21 / .19. Hyprland's border is 1 pt (2 px at 2x),
--     so its alpha carries the same ink over 2 px: 1 - (1 - a)^(1/2) = dark .735 / .588, light .111 / .100.
-- Global so the shell can switch it with the appearance (shell/Theme.qml, `hyprctl eval`).
-- GTK apps of the session follow too: config/hypr/start.sh points them (GSETTINGS_BACKEND=keyfile) at this keyfile.
local gtkKeyfile = os.getenv("HYPRK_GTK_KEYFILE")
local function hyprk_gtk(dark)
    if not gtkKeyfile or gtkKeyfile == "" then return end
    local tmp = gtkKeyfile .. ".tmp"
    local f = io.open(tmp, "w")
    if not f then return end
    f:write("# hyprk-managed (config/hypr/hyprland.lua hyprk_gtk)\n",
            "[org/gnome/desktop/wm/preferences]\nbutton-layout='close,minimize,maximize:'\n\n",
            "[org/gnome/desktop/interface]\n",
            "gtk-theme='MacOS27", dark and "-Dark" or "", "'\n",
            "color-scheme='", dark and "prefer-dark" or "prefer-light", "'\n",
            "font-name='SF Pro 10'\nmonospace-font-name='SF Mono 10'\ncursor-theme='hyprk-cursors'\ncursor-size=24\n")
    f:close()
    os.rename(tmp, gtkKeyfile)   -- atomic: GLib's file monitor sees one complete file
end

local function shadowGradient(above, side, below)   -- alphas 0..255, see the comment above
    local function c(a) return string.format("rgba(000000%02x)", a) end
    return { colors = { c(above), c(above), c(side), c(side), c(side), c(side), c(side), c(side), c(below), c(below) }, angle = 90 }
end

function hyprk_appearance(dark)
    local c = dark and { shadow = shadowGradient(0x22, 0x55, 0x92), shadowInactive = shadowGradient(0x0e, 0x24, 0x40),
                         rim = "rgba(000000bb)", rimInactive = "rgba(00000096)" }
                    or { shadow = shadowGradient(0x13, 0x30, 0x53), shadowInactive = shadowGradient(0x07, 0x11, 0x1f),
                         rim = "rgba(0000001c)", rimInactive = "rgba(0000001a)" }
    hl.config({
        general = { col = { active_border = c.rim, inactive_border = c.rimInactive } },
        decoration = { shadow = { color = c.shadow, color_inactive = c.shadowInactive } },
    })
    hyprk_gtk(dark)
end

-- macOS motion. Values from the binaries: liquid-glass-re/SPEC.md 9.9.4 (SwiftUI) and 11 (windows).
--   Window open: complete in one frame, no scale, no fade (MAC-ANSWERS.md R2 (27.2.1): Finder, TextEdit,
--     Safari, Terminal), so windowsIn is off. (The binaries' ScaleUpAndIn 0.5 s spring is not what 27.2.1 shows.)
--   Window close: a fade of about 0.1 s, alpha per frame 1, 0.71, 0.44, 0.27, 0.16, 0.09, 0.05, 0.03 (TextEdit),
--     i.e. x0.6 per 60 Hz frame, exp(-t / 33 ms) (MAC-ANSWERS.md R2 (27.2.1)). winClose is that decay as a
--     bezier; plugin-motion (Close.cpp) sets the window's alpha to the TextEdit frames counted from the first
--     frame drawn after the close (the bezier, started at the close, showed 0.11-0.16 in that frame depending on
--     the phase), so fadeOut only has to last the 8 frames (0.14 s); it adds the slight blur too.
--     Scale 1 -> 0.98 (ScaleDownAndOut) is kept: too small to resolve in the recording.
--     Safari closes in one frame on the Mac; hyprk does not special-case browsers.
--   Zoom / frame changes (windowsMove): MAC-ANSWERS.md R2 (27.2.1) Window > Zoom 0.33 s ease-in-out, share per frame
--     0.01 0.01 0.03 0.05 0.07 0.10 0.14 0.20 0.26 0.33 0.41 0.49 0.58 0.69 0.79 0.87 0.93 0.98 1.0: bezier "zoom"
--     over 0.29 s (RMS 0.006). Unzoom, full screen enter (0.4 s) and full screen exit (AppKit's window curve
--     (0.25, 0, 0, 1) over the Dock's 0.5 s, REA in reference/ours/motion/MOTION-PLUGIN.md) do not fit one
--     windowsMove leaf: plugin-motion (FrameMotion) plays them on these same animations
--     (plugin:hyprkmotion:frames = 0 leaves them on the zoom curve). With
--     windowsMove off (Reduce Motion) none of them animate.
--   Window dim (fadeDim): off. With windowsIn off, Hyprland showed a new window dimmed to about 50 % and faded
--     the dim out over 0.3 s (seen frame by frame in a test session); macOS never dims windows.
--   App menus (fadePopups): open in one frame, fade out in about 0.2 s ease-out, like the measured menu bar menus.
--   global: the fallback for leaves set nowhere else (zoomFactor, monitorAdded); not measured, kept at 0.2 s so
--     nothing silently takes the old 0.5 s.
--   Spaces: Dock's spring was not recovered (SPEC 11.6) and the Spaces switch is not measured on 27.2.1 yet;
--     the SwiftUI default spring (0.5, 1.0) stays.
--   Reduce Motion: no window open/close animation at all, Spaces cross-fade (SPEC 11.2).
-- Hyprland speed unit is 100 ms (speed 5 = 0.5 s); springs run in real time and ignore speed.
hl.curve("swiftui",   { type = "spring", mass = 1, stiffness = 158, damping = 25 })   -- (2pi/0.5)^2, 4pi/0.5
hl.curve("macEase",   { type = "bezier", points = { {0.25, 0.1}, {0.25, 1} } })
hl.curve("macOut",    { type = "bezier", points = { {0.2, 0.9}, {0.3, 1} } })
hl.curve("easeInOut", { type = "bezier", points = { {0.42, 0}, {0.58, 1} } })   -- SwiftUI legacy / NSAnimation default
hl.curve("zoom",      { type = "bezier", points = { {0.6, 0.1}, {0.7, 0.8} } })     -- Window > Zoom on 27.2.1
hl.curve("winClose",  { type = "bezier", points = { {0.3, 0.9}, {0.6, 0.9} } })          -- alpha x0.6 per frame over 0.12 s

hl.animation({ leaf = "global",      enabled = true, speed = 2,   bezier = "macEase" })
hl.animation({ leaf = "fade",        enabled = true, speed = 3,   bezier = "macEase" })
hl.animation({ leaf = "layersIn",    enabled = true, speed = 3.5, bezier = "macOut",  style = "fade" })
hl.animation({ leaf = "layersOut",   enabled = true, speed = 2.5, bezier = "macEase", style = "fade" })
hl.animation({ leaf = "border",      enabled = false })
hl.animation({ leaf = "fadeDim",     enabled = false })
hl.animation({ leaf = "fadePopupsIn",  enabled = false })
hl.animation({ leaf = "fadePopupsOut", enabled = true, speed = 2, bezier = "macOut" })

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
        hl.animation({ leaf = "windowsIn",   enabled = false })   -- macOS windows appear complete in one frame
        hl.animation({ leaf = "windowsOut",  enabled = true, speed = 1.2, bezier = "winClose", style = "popin 98%" })
        hl.animation({ leaf = "fadeIn",      enabled = false })   -- macOS windows appear at full alpha
        hl.animation({ leaf = "fadeOut",     enabled = true, speed = 1.4, bezier = "winClose" })   -- 0.14 s: covers the 8 Mac frames plugin-motion plays
        hl.animation({ leaf = "workspaces",  enabled = true, speed = 5, spring = "swiftui", style = "slide" })
    end
    hl.animation({ leaf = "windowsMove", enabled = not reduce, speed = 2.9, bezier = "zoom" })   -- Zoom 0.29 to 0.33 s
end
do  -- start from the saved setting so the first frame is already right
    local f = io.open(state .. "/appearance.json", "r")
    local txt = f and f:read("a") or ""
    if f then f:close() end
    hyprk_motion(txt:match('"reduceMotion"%s*:%s*true') ~= nil)
    hyprk_appearance(txt:match('"dark"%s*:%s*true') ~= nil)
end

------------------------------------------------------- liquid glass ----
-- shell layers that carry glass (namespaces hyprk-<name>), shared by the plugin and the blur rule
-- (no menubar: the 27.2.1 bar has no glass or blur of its own, see reference/re/MENUBAR-REA-27.2.1.md;
-- its menus are glass in hyprk-overlay)
local glassLayers = { "dock", "overlay", "controlcenter", "notifications", "notificationcenter", "spotlight", "switcher", "hud" }
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
            namespaces = "hyprk-" .. table.concat(glassLayers, ",hyprk-"),
            -- recipes per layer: the plugin's own `materials` default (plugin/src/Config.cpp) plus the
            -- volume/brightness HUD on the Control Center recipe (SystemBannerUI _Glass.controlCenter, no subvariant:
            -- MAC-ANSWERS.md "REA 27.2.1" section 1) and Cmd-Tab on the Dock's (pixel-identical on 27.2.1,
            -- MAC-ANSWERS.md Q-dock-19); keep the rest in sync with Config.cpp
            materials = "hyprk-dock:dock,hyprk-controlcenter:controlcenter,hyprk-overlay:menu,"
                     .. "hyprk-spotlight:spotlight,hyprk-hud:controlcenter,hyprk-switcher:dock,"
                     -- banners and Notification Center cards: _Glass.notificationCenter (MAC-ANSWERS PC #62)
                     .. "hyprk-notifications:notificationcenter,hyprk-notificationcenter:notificationcenter",
            -- Cmd-Tab selection tile (shell/modules/Switcher.qml): plus-darker in light, plus-lighter in dark (Q-dock-20/21);
            -- Dock running dots (shell/modules/Dock.qml): plus-darker -128 / plus-lighter +125 (Q-dock-07)
            fill_layers = "hyprk-switcher-fill:darker,hyprk-switcher-fill-dark:lighter,"
                       .. "hyprk-dock-dots:darker:128,hyprk-dock-dots-dark:lighter:125",
            -- the Dock dots are circles (4.1 pt, Q-dock-07): their 4 pt square regions get this radius (clamped to 2)
            radii = "hyprk-dock-dots:2.05,hyprk-dock-dots-dark:2.05",
        } } })
    end)
    if ok then
        hl.env("HYPRK_GLASS", "plugin")
        -- AppKit's window shadow from the plugin (plugin/src/WindowShadow.cpp: the Gaussian of the frame, blur 20 / 8 pt,
        -- y 18 / 7, density .40 / .22 light, .70 / .45 dark), Hyprland's off; without the plugin the gradient above stays.
        -- window_rim: the 1 pt white rim inside every window, alpha .10 (.08 dark inactive) (MAC-ANSWERS Q-windows-03)
        hl.config({ plugin = { liquidglass = { window_shadow = 1, window_rim = 1 } }, decoration = { shadow = { enabled = false } } })
    else print("hyprk: liquidglass not loaded: " .. tostring(err)) end
end
-- Window motion Hyprland cannot express (plugin-motion/): the Dock genie on minimize/restore.
-- Minimize stays "move to special:minimized"; the plugin plays the genie first.
local motionSo = hyprk .. "/plugin-motion/build/libhyprkmotion.so"
local hm = io.open(motionSo, "r")
if hm then
    hm:close()
    local ok, err = pcall(hl.plugin.load, motionSo)
    if not ok then print("hyprk: hyprkmotion not loaded: " .. tostring(err))
    -- Dock.app 27.2.1 `genie-speed` default 0.5 s, the same for minimise and restore and for every window size and
    -- distance (MAC-ANSWERS.md "REA 27.2.1" section 4 and Reconciliation (#42) a: the Mac's 0.22 s was a cut-off
    -- tail; re-measured 0.40 to 0.48 s visible, ease-in-out fit T 0.50 s)
    -- fullscreen_top: on the notched Air a full-screen window sits below the 34 pt bar strip, which stays black
    -- (MAC-ANSWERS Q-menubar-33); the MBA headless output models that Air. Other outputs keep true full screen
    -- (`hyprctl eval 'hl.config({ plugin = { hyprkmotion = { fullscreen_top = "" } } })'` for it on MBA too)
    else hl.config({ plugin = { hyprkmotion = { genie_duration = 0.5, fullscreen_top = "MBA:34" } } }) end
end

---------------------------------------------------------- layer rules ----
-- Real compositor blur behind the shell's glass surfaces. The shell already
-- draws a blurred-wallpaper material; this adds blur of the windows behind.
-- ignore_alpha keeps fully transparent parts (shadows, click catchers) unblurred.
-- Namespaces (set in shell/modules/*.qml via WlrLayershell.namespace):
--   hyprk-menubar hyprk-dock hyprk-overlay hyprk-controlcenter hyprk-notifications hyprk-notificationcenter
--   hyprk-spotlight hyprk-switcher hyprk-mission hyprk-hud hyprk-wallpaper
hl.layer_rule({
    name = "hyprk-glass-blur",
    match = { namespace = "^hyprk-(" .. table.concat(glassLayers, "|") .. ")$" },
    blur = true,
    ignore_alpha = 0.35,
})
hl.layer_rule({
    -- the shell animates these itself
    name = "hyprk-no-anim",
    match = { namespace = "^hyprk-(overlay|controlcenter|spotlight|switcher|switcher-fill|switcher-fill-dark|mission|notifications|notificationcenter|dock|dock-dots|dock-dots-dark|menubar|wallpaper|hud)$" },
    no_anim = true,
})

------------------------------------------------------------- binds ----
-- SUPER plays the role of Command.
local cmd = "SUPER"
hl.bind(cmd .. " + space",   hl.dsp.global("hyprk:spotlight"))
-- Cmd-Tab: the switcher takes no keyboard focus, so the windows stay active under it as on the Mac (shell/services/
-- Panels.qml switcherSubmap): Cmd+Tab enters the submap "hyprk-switcher" and opens it; inside, the keys reach the shell as
-- global shortcuts and releasing Cmd switches. The shell resets the submap when the switcher closes.
hl.bind(cmd .. " + Tab", function()
    hl.dispatch(hl.dsp.submap("hyprk-switcher"))
    hl.dispatch(hl.dsp.global("hyprk:switcher"))
end)
hl.define_submap("hyprk-switcher", function()
    for _, k in ipairs({ "Tab", "grave", "Right" }) do hl.bind(cmd .. " + " .. k, hl.dsp.global("hyprk:switcher-next"), { repeating = true }) end
    for _, k in ipairs({ "SHIFT + Tab", "Left" }) do hl.bind(cmd .. " + " .. k, hl.dsp.global("hyprk:switcher-prev"), { repeating = true }) end
    hl.bind(cmd .. " + Home",   hl.dsp.global("hyprk:switcher-first"))
    hl.bind(cmd .. " + End",    hl.dsp.global("hyprk:switcher-last"))
    hl.bind(cmd .. " + Return", hl.dsp.global("hyprk:switcher-commit"))
    hl.bind(cmd .. " + Escape", hl.dsp.global("hyprk:switcher-cancel"))
end)
-- Cmd let go switches. Hyprland 0.57 matches a release against the submap the key went down in (the default one, Cmd
-- comes before Tab) and always counts the trigger's own modifier ("SUPER + Super_L"); transparent keeps the bind from
-- being shadowed by the Tab binds pressed meanwhile, non_consuming lets the client see the release. A release bind sends
-- a global shortcut as "released", which the shell does not act on, so the commit goes out from a timer, outside the
-- bind, as press + release. With the switcher closed the shell ignores it (Switcher.qml listens only while shown).
for _, k in ipairs({ "Super_L", "Super_R" }) do
    hl.bind(cmd .. " + " .. k, function()
        hl.timer(function() hl.dispatch(hl.dsp.global("hyprk:switcher-commit")) end, { timeout = 1, type = "oneshot" })
    end, { release = true, transparent = true, non_consuming = true, submap_universal = true })
end
hl.bind(cmd .. " + F4",      hl.dsp.global("hyprk:apps"))   -- Apps: Spotlight's Applications mode (shell/services/AppsView.qml)
hl.bind(cmd .. " + A",       hl.dsp.global("hyprk:apps"))
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
-- Lock Screen like macOS (Ctrl+Cmd+Q): the shell's lock screen, hyprlock when the shell is not running
-- (lockscreen/lock.sh, lockscreen/FALLBACKS.md). Its fade layers animate themselves.
hl.bind("CTRL + " .. cmd .. " + Q", hl.dsp.exec_cmd(hyprk .. "/lockscreen/lock.sh"))
hl.layer_rule({ name = "hyprk-lock", match = { namespace = "^hyprk-lock$" }, no_anim = true })
hl.bind(cmd .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(cmd .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
for i = 1, 9 do
    hl.bind("CTRL + " .. i, hl.dsp.focus({ workspace = i }))          -- macOS: Ctrl+N switches Spaces
    hl.bind("CTRL + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind("CTRL + left",  hl.dsp.focus({ workspace = "e-1" }))
hl.bind("CTRL + right", hl.dsp.focus({ workspace = "e+1" }))
-- volume and brightness keys as on macOS 27.2.1 (reference/re/MAC-ANSWERS.md HUD): one press = 1/16,
-- Option+Shift (here Alt+Shift) = 1/64, clamped to 0..100 %. The shell's HUD follows the change
-- (shell/services/Hud.qml). Volume keys unmute and play the macOS volume pop (state/sound.json volumeFeedback).
-- brightnessctl takes whole percents only, so brightness steps in raw units of max/16 (max/64);
-- -n1 keeps the backlight on at the bottom.
local function volumeKey(dir, n)
    return hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ " .. 1 / n .. dir .. " && " .. sound .. " volume")
end
local function brightnessKey(dir, n)
    return hl.dsp.exec_cmd("brightnessctl -q -n1 set $(( ($(brightnessctl max) + " .. math.floor(n / 2) .. ") / " .. n .. " ))" .. dir)
end
for _, k in ipairs({ { "", 16 }, { "ALT + SHIFT + ", 64 } }) do
    hl.bind(k[1] .. "XF86AudioRaiseVolume",  volumeKey("+", k[2]),     { locked = true, repeating = true })
    hl.bind(k[1] .. "XF86AudioLowerVolume",  volumeKey("-", k[2]),     { locked = true, repeating = true })
    hl.bind(k[1] .. "XF86MonBrightnessUp",   brightnessKey("+", k[2]), { locked = true, repeating = true })
    hl.bind(k[1] .. "XF86MonBrightnessDown", brightnessKey("-", k[2]), { locked = true, repeating = true })
end
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

-- screenshots like macOS: Cmd+Shift+3 full screen, Cmd+Shift+4 area (needs slurp), shutter sound
-- xdg-user-dir knows localized folders; mkdir so a fresh home works
local shotFile = '"$(d=$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures"); mkdir -p "$d"; echo "$d")/Screenshot $(date "+%Y-%m-%d at %H.%M.%S").png"'
hl.bind(cmd .. " + SHIFT + 3", hl.dsp.exec_cmd("grim " .. shotFile .. " && " .. sound .. " screenshot"))
hl.bind(cmd .. " + SHIFT + 4", hl.dsp.exec_cmd("command -v slurp >/dev/null && grim -g \"$(slurp)\" " .. shotFile .. " && " .. sound .. " screenshot"))
hl.bind("Print",               hl.dsp.exec_cmd("grim " .. shotFile .. " && " .. sound .. " screenshot"))

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

------------------------------------------------------------ windows ----
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })
-- macOS has no tiling: every window floats, opens centered
hl.window_rule({ name = "macos-float", match = { class = ".*" }, float = true })
-- max_size keeps big windows inside the work area (below the 30pt menu bar, above the ~84pt Dock zone);
-- new_float_force_onscreen = 2 (default) then fits them fully. It clamps the window the moment the rule applies, so a
-- later rule's larger max_size cannot undo it: Finder's Quick Look (a transparent window over the whole monitor,
-- finder/hyprland-rules.lua) is left out by its title.
hl.window_rule({ name = "macos-max-size", match = { class = ".*", title = "negative:^(Quick Look)$" }, max_size = "monitor_w-40 monitor_h-130" })
-- rules shipped by the other hyprk apps (optional), after the catch-all rules above so an app's own rule wins (a later
-- rule sets the same property last)
for _, f in ipairs({ hyprk .. "/settings/hyprland-rules.lua", hyprk .. "/finder/hyprland-rules.lua",
                     state .. "/accessibility.lua" }) do   -- Settings > Accessibility choices, also without the shell
    local h = io.open(f, "r")
    if h then h:close(); dofile(f) end
end
