-- hyprk: pick the monitor scale the way macOS 27.2 does (CoreDisplay + MonitorPanel, recovered with REA,
-- evidence in /mnt/code/liquid-glass-re/SPEC.md section 10 "Display scaling").
--
-- macOS rule (generic external display, no Apple override plist):
--   * native mode >= 3840x2160 (either orientation)               -> HiDPI, default "looks like" native/2
--     (CoreDisplay build_mode_list_if_needed 0x1845994fc: w >= 0xf00 && h >= 0x870)
--   * native long side > 3799, diagonal < 812.8 mm (32"), native >= 2048x1536 and diagonal PPI > 160
--                                                                  -> HiDPI as well (isDisplayDeviceHIDPI 0x18459a568)
--   * everything else                                              -> 1x at native, no HiDPI modes shown
-- The default HiDPI mode is the 2x copy of the native timing, so 4K = looks like 1920x1080 at scale 2.
-- macOS never defaults to a fractional scale. "More Space" modes (e.g. looks like 2560x1440 on 4K) render at
-- 2x of the looks-like size and the display scaler downsamples; Hyprland has no such path, so a looks-like
-- override here maps to a fractional Hyprland scale (native_w / looks_w, e.g. 1.5) instead.
--
-- Use from hyprland.lua (after the static hl.monitor rules):
--   local scale = dofile(hyprk .. "/config/hypr/scale-policy.lua")
--   scale.install()            -- applies to every monitor now and on hotplug
-- Overrides (env, for testing or user choice):
--   HYPRK_SCALE_POLICY=off            leave monitors alone
--   HYPRK_LOOKS_LIKE=2560x1440        pick a macOS "More Space" style size (all monitors)
--   HYPRK_LOOKS_LIKE_<OUTPUT>=WxH     same for one output, e.g. HYPRK_LOOKS_LIKE_DP_1=2560x1440
--   HYPRK_PHYS_MM_<OUTPUT>=WxH        physical size in mm when the EDID has none (headless, some TVs)
--   HYPRK_NATIVE_<OUTPUT>=WxH         native mode when the output has no mode list (headless test outputs)

local M = {}

local INCH = 25.4

-- Pure decision. w, h = native pixels; mmw, mmh = physical size in mm (0 or nil = unknown).
-- Returns { hidpi = bool, scale = number, looks_w, looks_h, ppi, reason }.
function M.decide(w, h, mmw, mmh)
    local long, short = math.max(w, h), math.min(w, h)
    local diag_mm, ppi = nil, nil
    if mmw and mmh and mmw > 0 and mmh > 0 then
        diag_mm = math.sqrt(mmw * mmw + mmh * mmh)
        ppi = math.sqrt(w * w + h * h) / (diag_mm / INCH)
    end
    local hidpi, reason
    if long >= 3840 and short >= 2160 then
        -- the 4K test is on pixels only, the panel size does not matter (a 32" 4K is HiDPI too)
        hidpi, reason = true, "native >= 3840x2160"
    elseif long > 3799 and diag_mm and diag_mm < 812.8 and w >= 2048 and h >= 1536 and ppi > 160 then
        hidpi, reason = true, "long side > 3799, < 32\", > 160 ppi"
    else
        hidpi, reason = false, ppi and string.format("%.0f ppi, below the HiDPI rule", ppi) or "no HiDPI rule matched"
    end
    local scale = hidpi and 2 or 1
    return { hidpi = hidpi, scale = scale, looks_w = w // scale, looks_h = h // scale, ppi = ppi, reason = reason }
end

local function env_size(name)
    local v = os.getenv(name)
    if not v then return nil end
    local a, b = v:match("^(%d+)x(%d+)$")
    if a then return tonumber(a), tonumber(b) end
    return nil
end

local function env_key(output) return (output:gsub("[^%w]", "_")):upper() end

-- Hyprland only accepts scales where width/scale and height/scale come out whole (or close to it);
-- snap to 1/120 steps like wp_fractional_scale_v1 and check both axes.
local function valid_scale(w, h, s)
    s = math.floor(s * 120 + 0.5) / 120
    local lw, lh = w / s, h / s
    if math.abs(lw - math.floor(lw + 0.5)) < 0.01 and math.abs(lh - math.floor(lh + 0.5)) < 0.01 then return s end
    return nil
end

-- Native mode = the EDID preferred mode (macOS uses the driver's default timing), else the current one
-- (headless outputs have no mode list). Second result: the mode string for hl.monitor.
local function native_mode(mon, key)
    local nw, nh = env_size("HYPRK_NATIVE_" .. key)
    if nw then return nw, nh, string.format("%dx%d@60", nw, nh) end
    local ok, modes = pcall(function() return mon.available_modes end)
    if ok and modes then
        for _, m in ipairs(modes) do
            if m.preferred then return m.width, m.height, "preferred" end
        end
    end
    local cur = mon.mode or {}
    local w, h = cur.width or mon.width, cur.height or mon.height
    return w, h, string.format("%dx%d@%.3f", w, h, cur.refresh_rate or mon.refresh_rate or 60)
end

-- Decision for a Hyprland monitor object (hl.get_monitors() entry or monitor.added argument).
function M.for_monitor(mon)
    local key = env_key(mon.name)
    local w, h, mode = native_mode(mon, key)
    local mmw, mmh = mon.physical_width, mon.physical_height
    local ow, oh = env_size("HYPRK_PHYS_MM_" .. key)
    if ow then mmw, mmh = ow, oh end
    local d = M.decide(w, h, mmw, mmh)
    local lw, lh = env_size("HYPRK_LOOKS_LIKE_" .. key)
    if not lw then lw, lh = env_size("HYPRK_LOOKS_LIKE") end
    if lw and lw > 0 then
        local s = valid_scale(w, h, w / lw)
        if s then
            d.scale, d.looks_w, d.looks_h = s, math.floor(w / s + 0.5), math.floor(h / s + 0.5)
            d.reason = d.reason .. "; looks-like override"
        else
            d.reason = d.reason .. string.format("; looks-like %dx%d ignored (no clean scale)", lw, lh)
        end
    end
    d.native_w, d.native_h, d.mode, d.mm_w, d.mm_h = w, h, mode, mmw, mmh
    return d
end

local applied = {}

-- HYPRK_SCALE_LOG=/path appends one line per decision (Hyprland keeps stdout quiet after config load)
local function log(line)
    print(line)
    local path = os.getenv("HYPRK_SCALE_LOG")
    if not path then return end
    local f = io.open(path, "a")
    if f then f:write(line, "\n"); f:close() end
end

function M.apply(mon)
    if mon.name == "FALLBACK" then return nil end   -- Hyprland's internal placeholder output
    local d = M.for_monitor(mon)
    if applied[mon.name] == d.scale and math.abs((mon.scale or 0) - d.scale) < 0.001 then return d end
    applied[mon.name] = d.scale
    hl.monitor({ output = mon.name, mode = d.mode, position = "auto", scale = tostring(d.scale) })
    log(string.format("hyprk scale-policy: %s %dx%d %sx%s mm -> scale %s (looks like %dx%d, %s)",
        mon.name, d.native_w, d.native_h, tostring(d.mm_w), tostring(d.mm_h), tostring(d.scale), d.looks_w, d.looks_h,
        d.reason))
    return d
end

function M.install()
    if os.getenv("HYPRK_SCALE_POLICY") == "off" then return end
    for _, mon in ipairs(hl.get_monitors() or {}) do M.apply(mon) end
    hl.on("monitor.added", function(mon) M.apply(mon) end)
end

return M
