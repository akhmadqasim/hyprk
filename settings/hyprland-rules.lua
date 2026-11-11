-- hyprk System Settings window rules (Hyprland 0.57 Lua config).
-- The shell config sources this file: dofile(HYPRK_ROOT .. "/settings/hyprland-rules.lua")
-- shell.qml sets app id org.hyprk.Settings (//@ pragma AppId). The `qml` tool
-- fallback (main.qml) is matched by its title instead.
-- Size mirrors settings/Theme.qml (window.width/height).

local function settingsRule(name, match)
    hl.window_rule({
        name        = name,
        match       = match,
        float       = true,
        center      = true,
        size        = "740 625",   -- the Mac's window (MAC-ANSWERS Q-settings-03); 745 x 630 put the content on half points
        min_size    = "740 470",   -- Theme.window.minWidth / minHeight: the width is fixed
        -- corner, rim and shadow: the global window chrome in config/hypr/hyprland.lua (MAC-ANSWERS.md
        -- Q-windows-01..03); the app's own 16 pt corner lies inside the compositor's.
        -- blur stays on: the translucent sidebar is the glass.
    })
end

settingsRule("hyprk-settings", { class = "^(org\\.hyprk\\.Settings)$" })
settingsRule("hyprk-settings-qmltool", { title = "^(System Settings)$", class = "^(qml|org\\.qt-project\\.qml)$" })
