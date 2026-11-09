-- hyprk-managed
-- PROPOSAL, NOT TESTED: macOS style title bar with traffic lights for windows WITHOUT client-side decorations (Qt, X11, foot...).
-- Needs the hyprbars plugin from hyprwm/hyprland-plugins, tag v0.57.0 (matches Hyprland 0.57.x). It is NOT built in
-- /mnt/code/hypr-dev yet (building third-party plugin code needs your OK). Build and load it like the glass plugin:
--     hl.plugin.load("/path/to/hyprbars.so")
-- then add this file's content to the Hyprland config. Option names follow the hyprbars README; in the Lua config they live under
-- `plugin.hyprbars` (check `hyprctl` / the hyprbars README of the tag you build if one of them is rejected).
--
-- GTK/libadwaita apps already draw their own traffic lights (themes/gtk), so exclude them from the bar:

hl.config({
    plugin = {
        hyprbars = {
            bar_height = 32,                       -- SPEC.md section 7: regular title bar 32
            bar_color = 0xFFF6F6F6,                -- light; dark: 0xFF2A2A2A
            bar_blur = false,
            bar_part_of_window = true,
            bar_precedence_over_border = true,
            bar_title_enabled = true,
            bar_text_font = "SF Pro",
            bar_text_size = 13,
            bar_text_align = "center",
            bar_buttons_alignment = "left",
            bar_padding = 14,                      -- distance of the first light from the window edge
            bar_button_padding = 9,                -- SPEC.md: spacing between lights 9
        },
    },
})

-- traffic lights: colour, size, icon (empty = plain disc), command. hyprbars' own syntax is
--   hyprbars-button = <bg color>, <size>, <icon>, <on-click command>
-- close / minimise (Hyprland has no minimise: move to the special workspace) / maximise (fullscreen toggle without bars)
--   hyprbars-button = rgb(ff5f57), 14, , hyprctl dispatch 'hl.dsp.window.close()'
--   hyprbars-button = rgb(febc2e), 14, , hyprctl dispatch 'hl.dsp.window.move({ workspace = "special:minimized" })'
--   hyprbars-button = rgb(28c840), 14, , hyprctl dispatch 'hl.dsp.window.fullscreen()'
-- (in Lua configs the button list is registered with the plugin's own call, see its README; the three lines above are the values to use)

-- no bar for apps that already draw their own header bar (GTK 4 / libadwaita, GTK 3 with CSD, the hyprk Finder and Settings):
hl.window_rule({ match = { class = "^(org\\.gnome\\..*|com\\.mitchellh\\.ghostty|dev\\.hyprk\\..*)$" }, plugin_hyprbars_nobar = true })
