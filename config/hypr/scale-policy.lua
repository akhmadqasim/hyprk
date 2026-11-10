-- hyprk: pick the monitor scale the way macOS 27.2 does (CoreDisplay + MonitorPanel, recovered with REA,
-- evidence in /mnt/code/liquid-glass-re/SPEC.md section 14 "Display scaling").
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
-- choice here maps to a fractional Hyprland scale (native_w / looks_w, e.g. 1.5) at the native mode instead.
-- Smaller 1x sizes (1600x900 on a 1080p panel) are scaled framebuffers on macOS too (SPEC 14.2 step 4), so
-- they also become a Hyprland scale at the native mode, not a lower EDID mode.
--
-- Use from hyprland.lua (after the static hl.monitor rules):
--   local scale = dofile(hyprk .. "/config/hypr/scale-policy.lua")
--   scale.install()            -- applies to every monitor now and on hotplug
-- From Settings > Displays (hyprctl eval, same Lua state):
--   dofile(".../scale-policy.lua").report("/tmp/file.json")   -- decisions + choices per monitor as JSON
--   dofile(".../scale-policy.lua").set("DP-1", "2560x1440")    -- apply a looks-like size now ("" = Default)
-- Choice per output, saved by Settings: state/displays.json  { "looksLike": { "DP-1": "2560x1440" } }
-- Overrides (env, for testing or user choice; env wins over state/displays.json):
--   HYPRK_SCALE_POLICY=off            leave monitors alone
--   HYPRK_LOOKS_LIKE=2560x1440        pick a macOS "More Space" style size (all monitors)
--   HYPRK_LOOKS_LIKE_<OUTPUT>=WxH     same for one output, e.g. HYPRK_LOOKS_LIKE_DP_1=2560x1440
--   HYPRK_PHYS_MM_<OUTPUT>=WxH        physical size in mm when the EDID has none (headless, some TVs)
--   HYPRK_NATIVE_<OUTPUT>=WxH         native mode when the output has no mode list (headless test outputs)
-- scripts/scale-policy.py mirrors decide(), valid_scale() and choices(); keep them identical.

local M = {}

local INCH = 25.4

-- repo root: $HYPRK_ROOT, else two levels above this file (config/hypr/scale-policy.lua)
local function root()
    local env = os.getenv("HYPRK_ROOT")
    if env and env ~= "" then return env end
    local ok, info = pcall(debug.getinfo, 1, "S")
    local src = ok and info and info.source or ""
    return src:match("^@(.*)/config/hypr/[^/]+$") or ((os.getenv("HOME") or "") .. "/.local/share/hyprk")
end
M.state_path = root() .. "/state/displays.json"

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

local function parse_size(v)
    if type(v) ~= "string" then return nil end
    local a, b = v:match("^(%d+)x(%d+)$")
    if a then return tonumber(a), tonumber(b) end
    return nil
end

local function env_size(name) return parse_size(os.getenv(name)) end

local function env_key(output) return (output:gsub("[^%w]", "_")):upper() end

-- Hyprland only accepts scales where width/scale and height/scale come out whole (or close to it);
-- snap to 1/120 steps like wp_fractional_scale_v1 and check both axes.
local function valid_scale(w, h, s)
    s = math.floor(s * 120 + 0.5) / 120
    local lw, lh = w / s, h / s
    if math.abs(lw - math.floor(lw + 0.5)) < 0.01 and math.abs(lh - math.floor(lh + 0.5)) < 0.01 then return s end
    return nil
end
M.valid_scale = valid_scale

-- Framebuffer sizes macOS installs (SPEC 14.2 step 2, CoreDisplay IOGraphicsProperties.plist, dump in
-- liquid-glass-re notes/display/IOGraphicsProperties-scale-resolutions.txt). A bare width keeps the native aspect.
local FB_WIDTHS = { 640, 800, 1024, 1280, 1344, 1600, 1920, 2048 }                    -- scale-resolutions
local FB_FIXED = { {1280, 720}, {1440, 900}, {1680, 1050}, {1920, 1080}, {1920, 1200}, {2560, 1440}, {2560, 1600} }
-- scale-resolutions-4k adds these (native >= 3840 in either axis). SPEC 14.4 lists the 2x copies of exactly
-- 2048..6720 as what a 27" 4K offers (looks like 1024x576 .. 3360x1890), so the HiDPI list uses those.
local FB_WIDTHS_4K = { 2048, 2304, 2560, 3008, 3200, 3360, 3840, 4096, 4608, 5120, 6016, 6400, 6720 }

-- Every "looks like" size System Settings would list for this panel, after the MonitorPanel trim (SPEC 14.5:
-- same aspect as native within 0.01, 1x modes larger than native dropped, 1x modes with a 2x twin dropped),
-- then kept only when it maps to a clean Hyprland scale (valid_scale). That last filter is ours: macOS also
-- offers e.g. 1504x846 and 3008x1692 on 4K, which have no exact Hyprland scale.
-- Returns a list sorted by width: { w, h, scale, default = bool }.
function M.choices(w, h, mmw, mmh)
    local d = M.decide(w, h, mmw, mmh)
    local aspect = w / h
    local seen, out = {}, {}
    local function add(lw, lh)
        if lw < 640 or lh < 1 then return end                                  -- SPEC 14.5: modes < 640 px dropped
        if math.abs(lw / lh - aspect) > 0.01 then return end                    -- SPEC 14.5 aspect rule
        local key = lw .. "x" .. lh
        if seen[key] then return end
        local s = valid_scale(w, h, w / lw)
        if not s or math.floor(w / s + 0.5) ~= lw or math.floor(h / s + 0.5) ~= lh then return end
        seen[key] = true
        out[#out + 1] = { w = lw, h = lh, scale = s, default = (lw == d.looks_w and lh == d.looks_h) }
    end
    if d.hidpi then
        -- 2x copies: looks like = framebuffer / 2 (SPEC 14.2 step 5); the native timing's copy is the Default
        local list = math.max(w, h) >= 3840 and FB_WIDTHS_4K or { 1600, 1920, 2048 }
        for _, fw in ipairs(list) do
            local fh = h * fw // w
            if math.max(fw, fh) >= 1440 and math.min(fw, fh) >= 900 and fh % 2 == 0 and fw % 2 == 0 then
                add(fw // 2, fh // 2)
            end
        end
        add(w // 2, h // 2)
        -- the 1x native mode stays (no 2x twin) unless the panel is >= DisplayDPICutoff 300 ppi (SPEC 14.4/14.5)
        if not d.ppi or d.ppi < 300 then add(w, h) end
    else
        for _, fw in ipairs(FB_WIDTHS) do add(fw, h * fw // w) end
        for _, f in ipairs(FB_FIXED) do add(f[1], f[2]) end
        add(w, h)
        -- larger than native is dropped for 1x lists (SPEC 14.5)
        local kept = {}
        for _, c in ipairs(out) do if c.w <= w and c.h <= h then kept[#kept + 1] = c end end
        out = kept
    end
    table.sort(out, function(a, b) return a.w < b.w end)
    return out
end

-- Saved choices from Settings: { [output] = "WxH" }. Missing or corrupt file = no choices.
-- Only the flat "looksLike" object is read, so a pattern scan is enough (no JSON library in Hyprland's Lua).
function M.read_state(path)
    local f = io.open(path or M.state_path, "r")
    if not f then return {} end
    local text = f:read("a") or ""
    f:close()
    local block = text:match('"looksLike"%s*:%s*(%b{})')
    local t = {}
    if block then
        for k, v in block:gmatch('"([^"\\]+)"%s*:%s*"(%d+x%d+)"') do t[k] = v end
    end
    return t
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
-- saved = this output's looks-like choice ("WxH", "" = Default); nil reads state/displays.json.
-- Precedence: HYPRK_LOOKS_LIKE_<OUTPUT>, HYPRK_LOOKS_LIKE, saved choice, macOS default.
function M.for_monitor(mon, saved)
    local key = env_key(mon.name)
    local w, h, mode = native_mode(mon, key)
    local mmw, mmh = mon.physical_width, mon.physical_height
    local ow, oh = env_size("HYPRK_PHYS_MM_" .. key)
    if ow then mmw, mmh = ow, oh end
    local d = M.decide(w, h, mmw, mmh)
    d.default_w, d.default_h = d.looks_w, d.looks_h
    d.source = "default"
    local lw, lh, src
    lw, lh = env_size("HYPRK_LOOKS_LIKE_" .. key)
    if lw then src = "HYPRK_LOOKS_LIKE_" .. key
    else
        lw, lh = env_size("HYPRK_LOOKS_LIKE")
        if lw then src = "HYPRK_LOOKS_LIKE"
        else
            if saved == nil then saved = M.read_state()[mon.name] end
            lw, lh = parse_size(saved)
            if lw then src = "saved" end
        end
    end
    if lw and lw > 0 then
        local s = valid_scale(w, h, w / lw)
        if s then
            d.scale, d.looks_w, d.looks_h = s, math.floor(w / s + 0.5), math.floor(h / s + 0.5)
            d.reason = d.reason .. "; looks-like " .. (src == "saved" and "choice" or src)
            d.source = src == "saved" and "saved" or "env"
            d.env = src ~= "saved" and src or nil
        else
            d.reason = d.reason .. string.format("; looks-like %dx%d ignored (no clean scale)", lw, lh)
        end
    end
    d.native_w, d.native_h, d.mode, d.mm_w, d.mm_h = w, h, mode, mmw, mmh
    return d
end

local function is_virtual(name)
    return name == "MBA" or name:match("^HEADLESS") ~= nil or name:match("^WAYLAND%-") ~= nil or name:match("^X11%-") ~= nil
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

-- virtual outputs have no EDID size and keep their own rules (MBA screenshot output, nested windows),
-- unless a test sets HYPRK_NATIVE_<OUTPUT> for them
local function skipped(mon)
    if mon.name == "FALLBACK" then return true end   -- Hyprland's internal placeholder output
    return is_virtual(mon.name) and not os.getenv("HYPRK_NATIVE_" .. env_key(mon.name))
end

function M.apply(mon, saved)
    if skipped(mon) then return nil end
    local d = M.for_monitor(mon, saved)
    if applied[mon.name] == d.scale and math.abs((mon.scale or 0) - d.scale) < 0.001 then return d end
    applied[mon.name] = d.scale
    hl.monitor({ output = mon.name, mode = d.mode, position = "auto", scale = tostring(d.scale) })
    log(string.format("hyprk scale-policy: %s %dx%d %sx%s mm -> scale %s (looks like %dx%d, %s)",
        mon.name, d.native_w, d.native_h, tostring(d.mm_w), tostring(d.mm_h), tostring(d.scale), d.looks_w, d.looks_h,
        d.reason))
    return d
end

local function off() return os.getenv("HYPRK_SCALE_POLICY") == "off" end

function M.install()
    if off() then return end
    for _, mon in ipairs(hl.get_monitors() or {}) do M.apply(mon) end
    hl.on("monitor.added", function(mon) M.apply(mon) end)
end

-- Settings > Displays: apply a looks-like choice to one output now. size "WxH", or "" for the macOS default.
-- Settings saves the same choice to state/displays.json for the next start; env overrides still win.
function M.set(output, size)
    if off() then return false end
    for _, mon in ipairs(hl.get_monitors() or {}) do
        if mon.name == output then return M.apply(mon, size or "") ~= nil end
    end
    return false
end

-- tiny JSON writer for report() (strings, numbers, booleans, arrays, objects)
local function json(v)
    local t = type(v)
    if t == "string" then
        return '"' .. v:gsub('[%c"\\]', function(c) return string.format("\\u%04x", c:byte()) end) .. '"'
    elseif t == "number" then
        if v ~= v or v == math.huge or v == -math.huge then return "null" end
        return math.type(v) == "integer" and tostring(v) or string.format("%.6g", v)
    elseif t == "boolean" then return tostring(v)
    elseif t == "table" then
        local parts = {}
        if #v > 0 or next(v) == nil then
            for _, x in ipairs(v) do parts[#parts + 1] = json(x) end
            return "[" .. table.concat(parts, ",") .. "]"
        end
        for k, x in pairs(v) do parts[#parts + 1] = json(tostring(k)) .. ":" .. json(x) end
        return "{" .. table.concat(parts, ",") .. "}"
    end
    return "null"
end
M.json = json

-- Settings > Displays: what this module decides for every monitor, written as JSON to `path`:
-- { policy = "on"|"off", outputs = [ { name, virtual, hidpi, native = {w,h}, looks = {w,h}, default = {w,h},
--   scale, source = "default"|"saved"|"env", env, choices = [ {w,h,scale,default} ] } ] }
function M.report(path)
    local outs = {}
    local saved = M.read_state()
    for _, mon in ipairs(hl.get_monitors() or {}) do
        if mon.name ~= "FALLBACK" then
            local d = M.for_monitor(mon, saved[mon.name] or "")
            if off() and (mon.scale or 0) > 0 then   -- nothing applied: report what Hyprland runs now
                d.looks_w, d.looks_h = math.floor(mon.width / mon.scale + 0.5), math.floor(mon.height / mon.scale + 0.5)
            end
            outs[#outs + 1] = {
                name = mon.name, virtual = skipped(mon), hidpi = d.hidpi, scale = d.scale,
                native = { d.native_w, d.native_h }, looks = { d.looks_w, d.looks_h },
                default = { d.default_w, d.default_h }, source = d.source, env = d.env or "",
                choices = M.choices(d.native_w, d.native_h, d.mm_w, d.mm_h),
            }
        end
    end
    local f = io.open(path, "w")
    if not f then return false end
    f:write(json({ policy = off() and "off" or "on", outputs = outs }), "\n")
    f:close()
    return true
end

return M
