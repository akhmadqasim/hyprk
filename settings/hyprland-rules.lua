-- hyprk System Settings window rules (Hyprland 0.57 Lua config).
-- The shell config sources this file: dofile(HYPRK_ROOT .. "/settings/hyprland-rules.lua")
-- shell.qml sets app id org.hyprk.Settings (//@ pragma AppId). The `qml` tool
-- fallback (main.qml) is matched by its title instead.
-- Size and rounding mirror settings/Theme.qml (window.width/height/radius).

local function settingsRule(name, match)
    hl.window_rule({
        name        = name,
        match       = match,
        float       = true,
        center      = true,
        size        = "745 630",
        min_size    = "680 420",
        rounding       = 26,   -- Theme.window.radius; the app also draws it client-side
        rounding_power = 2,    -- circular, to match the client-drawn corner exactly
        -- macOS thin dark contour (SPEC.md 7.1: border_size 1, black 10-20 %)
        border_size    = 1,
        border_color   = "rgba(0000002e) rgba(0000001f)",   -- active, inactive
        -- blur stays on: the translucent sidebar is the glass. The drop shadow is
        -- decoration.shadow in config/hypr (range/colour can't be set per window).
    })
end

settingsRule("hyprk-settings", { class = "^(org\\.hyprk\\.Settings)$" })
settingsRule("hyprk-settings-qmltool", { title = "^(System Settings)$", class = "^(qml|org\\.qt-project\\.qml)$" })
