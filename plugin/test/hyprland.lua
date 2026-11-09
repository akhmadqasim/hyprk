-- Nested test config for the liquidglass plugin (Hyprland 0.57.2, Lua config).
-- Run with plugin/test/run.sh, which sets LG_PLUGIN and LG_TEST_DIR.
local plugin = os.getenv("LG_PLUGIN")
local dir    = os.getenv("LG_TEST_DIR")

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.monitor({ output = "MBA", mode = "2560x1664@60", position = "auto", scale = 2 })

hl.config({
    general = { gaps_in = 5, gaps_out = 20, border_size = 0 },
    decoration = {
        rounding = 16,
        blur = { enabled = true, size = 10, passes = 3, noise = 0.0, contrast = 1.0, brightness = 1.0, vibrancy = 0.2 },
    },
    animations = { enabled = false },
    debug = { disable_logs = false },
    misc = { disable_hyprland_logo = true, disable_splash_rendering = true, disable_hyprland_guiutils_check = true },
    ecosystem = { no_update_news = true, no_donation_nag = true },
})

if plugin and plugin ~= "" then
    hl.plugin.load(plugin)
end

hl.config({ plugin = { liquidglass = {
    namespaces = "lgtest-dock,lgtest-menubar,lgtest-card",
    radii      = "lgtest-menubar:0",
} } })

hl.window_rule({
    name  = "lgtest-foot",
    match = { class = "foot" },
    float = true,
    size  = "820 520",
    move  = "180 120",
})

hl.on("hyprland.start", function ()
    hl.exec_cmd("quickshell -p " .. dir .. "/qs/shell.qml")
end)
