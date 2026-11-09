-- hyprk System Settings window rules (Hyprland 0.57 Lua config).
-- The shell config sources this file: dofile("/mnt/code/hyprk/settings/hyprland-rules.lua")
-- shell.qml sets app id org.hyprk.Settings (//@ pragma AppId). The `qml` tool
-- fallback (main.qml) has no fixed app id, so it is matched by title.
-- Size and rounding mirror settings/Theme.qml (window.width/height/radius).

local settings = {
    float       = true,
    center      = true,
    size        = "745 640",
    min_size    = "680 420",
    rounding    = 26,        -- Theme.window.radius; the app also draws it client-side
    border_size = 0,         -- macOS windows have no colored border
    -- keep blur and shadow on: the sidebar is translucent like macOS vibrancy
}

hl.window_rule(setmetatable({ name = "hyprk-settings",       match = { class = "^(org\\.hyprk\\.Settings)$" } }, { __index = settings }))
hl.window_rule(setmetatable({ name = "hyprk-settings-qmltool", match = { class = "^(qml|org\\.qt-project\\.qml)$", title = "^(System Settings)$" } }, { __index = settings }))
