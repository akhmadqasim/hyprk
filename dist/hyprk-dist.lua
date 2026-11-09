-- hyprk dist: the normal hyprk config plus a monitor override that depends on how it is started.
--   HYPRK_OUTPUT  output to configure ("" = all)
--   HYPRK_MODE    "preferred" or e.g. "3840x2160@60"
--   HYPRK_SCALE   "1" (nested: aquamarine has no fractional scale) or "1.5" (login session on a 4K screen)
local root = os.getenv("HYPRK_ROOT") or "/mnt/code/hyprk"
dofile(root .. "/config/hypr/hyprland.lua")
hl.monitor({
    output   = os.getenv("HYPRK_OUTPUT") or "",
    mode     = os.getenv("HYPRK_MODE") or "preferred",
    position = "auto",
    scale    = os.getenv("HYPRK_SCALE") or "1",
})
-- we start Hyprland through config/hypr/start.sh, not start-hyprland: hide that warning
hl.config({ misc = { disable_watchdog_warning = true } })
-- macOS title bar (traffic lights on the left) from the liquidglass plugin for windows that draw no bar themselves:
-- "auto" = clients that bound xdg-decoration (Ghostty with window-decoration=server, foot, Qt apps).
-- Ghostty's class is listed too, in case a Ghostty build does not bind xdg-decoration.
hl.config({ plugin = { liquidglass = { titlebar = "auto", titlebar_classes = "^com\\.mitchellh\\.ghostty$" } } })

-- Nested only: GNOME keeps the Super key for itself, so the Super binds may never reach the nested window.
-- Same actions on Ctrl+Alt (GNOME does not use these). Nothing changes in the login session.
if os.getenv("HYPRK_NESTED") == "1" then
    local m = "CTRL + ALT"
    local terminal = os.getenv("HYPRK_TERMINAL") or "ghostty"
    hl.bind(m .. " + S",      hl.dsp.global("hyprk:spotlight"))
    hl.bind(m .. " + W",      hl.dsp.global("hyprk:switcher"))
    hl.bind(m .. " + A",      hl.dsp.global("hyprk:launchpad"))
    hl.bind(m .. " + N",      hl.dsp.global("hyprk:notificationcenter"))
    hl.bind(m .. " + C",      hl.dsp.global("hyprk:controlcenter"))
    hl.bind(m .. " + M",      hl.dsp.global("hyprk:missioncontrol"))
    hl.bind(m .. " + Return", hl.dsp.exec_cmd(terminal))
    hl.bind(m .. " + Q",      hl.dsp.exit())
end
