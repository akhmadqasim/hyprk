-- hyprk System Settings window rules (Hyprland 0.57 Lua config).
-- The shell config sources this file: dofile("/mnt/code/hyprk/settings/hyprland-rules.lua")
-- shell.qml sets app id org.hyprk.Settings (//@ pragma AppId). The `qml` tool
-- fallback (main.qml) is matched by its title instead.
-- Size and rounding mirror settings/Theme.qml (window.width/height/radius).

local function settingsRule(name, match)
    hl.window_rule({
        name        = name,
        match       = match,
        float       = true,
        center      = true,
        size        = "745 640",
        min_size    = "680 420",
        rounding    = 26,    -- Theme.window.radius; the app also draws it client-side
        border_size = 0,     -- macOS windows have no colored border
        -- blur and shadow stay on: the sidebar is translucent like macOS vibrancy
    })
end

settingsRule("hyprk-settings", { class = "^(org\\.hyprk\\.Settings)$" })
settingsRule("hyprk-settings-qmltool", { title = "^(System Settings)$", class = "^(qml|org\\.qt-project\\.qml)$" })
