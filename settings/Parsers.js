// Pure parsing and state helpers. No QML imports so node can test them
// (tests/parsers.test.js). Every parser returns a safe value on garbage input.

// nmcli -t escapes ':' and '\' with a backslash.
function splitTerse(line) {
    const out = [];
    let cur = "";
    for (let i = 0; i < line.length; i++) {
        const c = line[i];
        if (c === "\\" && i + 1 < line.length) { cur += line[++i]; continue; }
        if (c === ":") { out.push(cur); cur = ""; continue; }
        cur += c;
    }
    out.push(cur);
    return out;
}

function lines(text) {
    return String(text || "").split("\n").filter(l => l.trim() !== "");
}

// nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device
function parseNmcliDevices(text) {
    return lines(text).map(splitTerse).filter(f => f.length >= 3)
        .map(f => ({ device: f[0], type: f[1], state: f[2], connection: f[3] || "" }));
}

// First wifi device or null ("No Wi-Fi hardware installed").
function wifiDevice(devices) {
    return devices.find(d => d.type === "wifi") || null;
}

// nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list
// Dedupes by SSID (keeps the strongest), drops hidden networks, sorts by signal.
function parseNmcliWifi(text) {
    const best = {};
    for (const f of lines(text).map(splitTerse)) {
        if (f.length < 3 || f[1] === "") continue;
        const n = { ssid: f[1], inUse: f[0] === "*", signal: parseInt(f[2]) || 0, secure: (f[3] || "").trim() !== "" };
        const old = best[n.ssid];
        if (!old || n.inUse || (!old.inUse && n.signal > old.signal)) best[n.ssid] = n;
    }
    return Object.values(best).sort((a, b) => (b.inUse - a.inUse) || (b.signal - a.signal));
}

// wpctl status: the Sinks block inside the Audio section.
function parseWpctlSinks(text) { return parseWpctlNodes(text, "Sinks"); }
function parseWpctlSources(text) { return parseWpctlNodes(text, "Sources"); }
// the Audio section's Sinks or Sources of `wpctl status`
function parseWpctlNodes(text, kind) {
    const sinks = [];
    let inAudio = false, inSinks = false;
    for (const raw of String(text || "").split("\n")) {
        if (/^Audio\b/.test(raw)) { inAudio = true; continue; }
        if (/^\S/.test(raw)) { inAudio = false; inSinks = false; continue; }
        if (!inAudio) continue;
        if (/[├└]─\s*(\w+):/.test(raw)) { inSinks = raw.indexOf(kind + ":") >= 0; continue; }
        if (!inSinks) continue;
        const m = raw.match(/(\*)?\s*(\d+)\.\s+(.+?)\s*(?:\[vol:\s*([\d.]+)(\s+MUTED)?\])?\s*$/);
        if (m) sinks.push({ id: parseInt(m[2]), name: m[3], isDefault: !!m[1], volume: m[4] !== undefined ? parseFloat(m[4]) : 0, muted: !!m[5] });
    }
    return sinks;
}

// wpctl get-volume @DEFAULT_AUDIO_SINK@ -> "Volume: 0.48 [MUTED]"
function parseWpctlVolume(text) {
    const m = String(text || "").match(/Volume:\s*([\d.]+)(.*MUTED)?/);
    return m ? { ok: true, volume: parseFloat(m[1]), muted: !!m[2] } : { ok: false, volume: 0, muted: false };
}

// bluetoothctl show
function parseBluetoothShow(text) {
    const t = String(text || "");
    if (!/^Controller\s/m.test(t)) return { available: false, powered: false, name: "", discoverable: false };
    const field = k => { const m = t.match(new RegExp("^\\s*" + k + ":\\s*(.*)$", "m")); return m ? m[1].trim() : ""; };
    return { available: true, powered: field("Powered") === "yes", name: field("Alias") || field("Name"), discoverable: field("Discoverable") === "yes" };
}

// bluetoothctl devices [Connected]
function parseBluetoothDevices(text) {
    return lines(text).map(l => l.match(/^Device\s+([0-9A-Fa-f:]{17})\s+(.*)$/)).filter(m => m)
        .map(m => ({ mac: m[1], name: m[2].trim() }));
}

// hyprctl monitors -j
function parseHyprMonitors(text) {
    let arr;
    try { arr = JSON.parse(text); } catch (e) { return []; }
    if (!Array.isArray(arr)) return [];
    return arr.map(m => ({
        name: String(m.name || ""),
        description: String(m.description || m.name || "Display"),
        model: String(m.model || ""),
        width: m.width | 0, height: m.height | 0,
        refreshRate: Math.round((+m.refreshRate || 0) * 100) / 100,
        scale: +m.scale || 1,
        focused: !!m.focused,
        modes: Array.isArray(m.availableModes) ? m.availableModes : []
    }));
}

// hyprctl getoption <name> -j -> {"option": ..., "int": 25, "set": false}
function parseHyprOption(text) {
    try {
        const o = JSON.parse(text);
        for (const k of ["int", "float", "str", "custom"]) if (o[k] !== undefined) return o[k];
    } catch (e) {}
    return null;
}

// Hyprland 0.57 has no `hyprctl keyword`; runtime changes go through `hyprctl eval <lua>`.
function luaString(s) {
    return '"' + String(s).replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n") + '"';
}
function luaMonitor(name, mode, scale) {
    return "hl.monitor({ output = " + luaString(name) + ", mode = " + luaString(mode)
        + ", position = \"auto\", scale = " + Number(scale) + " })";
}
function luaInput(repeatRate, repeatDelay) {
    return "hl.config({ input = { repeat_rate = " + Math.round(repeatRate) + ", repeat_delay = " + Math.round(repeatDelay) + " } })";
}

// cat /sys/class/power_supply/*/type
function hasBattery(text) {
    return lines(text).some(l => l.trim() === "Battery");
}

// ---------- state files ----------
// appearance.json is shared with the shell, which reads {dark, reduceTransparency}.
// glass: macOS 27 "Liquid Glass" slider, 0 = clear, 1 = tinted.
// iconStyle: macOS 26+ "Icon & widget style" (default | dark | clear | tinted). iconStyleVariant: the style's own
// Light / Dark / Auto choice (Clear and Tinted; Dark offers Always = "dark" / Auto), Settings only
// (MAC-ANSWERS.md Q-settings-27, #35: the tiles follow it, not the window mode, unless Auto).
const appearanceDefaults = { mode: "light", dark: false, reduceTransparency: false, increaseContrast: false, reduceMotion: false, accent: "multicolor", sidebarIconSize: "medium", glass: 0.5, iconStyle: "default", iconStyleVariant: "auto", iconTint: "", tintWindowBackground: true, highlight: "" };
const iconStyleVariants = ["light", "dark", "auto"];
const appearanceModes = ["light", "dark", "auto"];
const iconStyles = ["default", "dark", "clear", "tinted"];
// Tinted colour (AppleIconAppearanceTintColor, PC #60 section 3): "" = Automatic (key absent), in the Mac menu's order
const iconTints = ["", "red", "orange", "yellow", "green", "blue", "purple", "pink", "graphite"];
// Sub-choice of an icon style: Dark = Always ("dark") / Auto, Clear and Tinted = Light / Dark / Auto, Default none.
function iconStyleVariantsOf(style) {
    return style === "dark" ? ["dark", "auto"] : style === "clear" || style === "tinted" ? ["light", "dark", "auto"] : [];
}
// The mode carries over when the style changes (PC #60: Tinted + Auto -> Dark kept Auto); from Default, or when the
// old mode is not offered, the first choice (Default -> Clear gave ClearLight).
function iconStyleVariantAfter(fromStyle, fromVariant, toStyle) {
    const offered = iconStyleVariantsOf(toStyle);
    if (!offered.length) return fromVariant;
    return fromStyle !== "default" && offered.indexOf(fromVariant) >= 0 ? fromVariant : offered[0];
}

// Text highlight colour, "" = Automatic (AppleHighlightColor absent: follows the accent). The pop-up's order is
// AppKit's highlight keys -1, 4, 5, 6, 0, 1, 2, 3, 8 (reference/re/27.2.1/live/accent-colors.json highlightKeys);
// "Choose Color..." (key -2, the custom colour softened per appearance) is not offered: no colour panel here.
const highlightNames = ["", "blue", "purple", "pink", "red", "orange", "yellow", "green", "graphite"];

// ---------- Appearance > Auto ----------
// macOS 27.2.1 without Location Services (SkyLight SLSAppearanceThemeForEnvironment 0x182a3516c, 27.2.1 dyld cache):
// readlink("/etc/localtime") minus the zoneinfo prefix is the time zone name, GEOCity gives that zone's city and its
// latitude / longitude ("time zone based location"), and the theme is light while -[GEOAlmanac isDayLight]
// (0x1a991fd54) holds: the sun's altitude at that place is at or above the almanac's altitude, -3 degrees
// (calculateAstronomicalTimeForLocation:time: 0x1a991dd24 passes -3.0). No clock times, no network.
// Here the zone's coordinates come from tzdata's zone1970.tab (the zone's principal city, like GEOCity) and the sun's
// altitude from the NOAA solar position formulas (Apple's geo_getSunPosition was not ported: within 0.1 degree,
// under half a minute at the -3 degree crossing outside the polar regions).
const autoSunAltitude = -3;

// zone1970.tab / zone.tab text and a zone name -> { lat, lon } in degrees, or null. Coordinates are ISO 6709:
// +-DDMM+-DDDMM or +-DDMMSS+-DDDMMSS.
function zoneCoords(tabText, zone) {
    for (const line of String(tabText || "").split("\n")) {
        if (line[0] === "#") continue;
        const f = line.split("\t");
        if (f.length < 3 || f[2] !== zone) continue;
        const m = /^([+-])(\d{2})(\d{2})(\d{2})?([+-])(\d{3})(\d{2})(\d{2})?$/.exec(f[1]);
        if (!m) return null;
        const deg = (sign, d, mi, sec) => (sign === "-" ? -1 : 1) * (Number(d) + Number(mi) / 60 + Number(sec || 0) / 3600);
        return { lat: deg(m[1], m[2], m[3], m[4]), lon: deg(m[5], m[6], m[7], m[8]) };
    }
    return null;
}
// "/usr/share/zoneinfo/Asia/Jakarta" (the target of /etc/localtime) or "Asia/Jakarta" (/etc/timezone) -> "Asia/Jakarta"
function zoneName(link) {
    const m = /^(?:.*zoneinfo\/(?:posix\/|right\/)?)?([A-Za-z_]+(?:\/[A-Za-z0-9_+-]+)+)\s*$/.exec(String(link || ""));
    return m ? m[1] : "";
}
// The sun's altitude in degrees at `ms` (Unix time) seen from lat / lon (degrees, east positive). NOAA.
function sunAltitude(ms, lat, lon) {
    const rad = Math.PI / 180;
    const T = (ms / 86400000 + 2440587.5 - 2451545) / 36525;             // Julian centuries from J2000
    const L0 = (280.46646 + T * (36000.76983 + T * 0.0003032)) % 360;      // mean longitude
    const M = 357.52911 + T * (35999.05029 - 0.0001537 * T);               // mean anomaly
    const e = 0.016708634 - T * (0.000042037 + 0.0000001267 * T);
    const C = Math.sin(M * rad) * (1.914602 - T * (0.004817 + 0.000014 * T))
            + Math.sin(2 * M * rad) * (0.019993 - 0.000101 * T) + Math.sin(3 * M * rad) * 0.000289;
    const omega = 125.04 - 1934.136 * T;
    const lambda = L0 + C - 0.00569 - 0.00478 * Math.sin(omega * rad);    // apparent longitude
    const eps = 23 + (26 + (21.448 - T * (46.815 + T * (0.00059 - T * 0.001813))) / 60) / 60 + 0.00256 * Math.cos(omega * rad);
    const decl = Math.asin(Math.sin(eps * rad) * Math.sin(lambda * rad));
    const y = Math.tan(eps * rad / 2) ** 2;
    const eot = 4 / rad * (y * Math.sin(2 * L0 * rad) - 2 * e * Math.sin(M * rad) + 4 * e * y * Math.sin(M * rad) * Math.cos(2 * L0 * rad)
              - 0.5 * y * y * Math.sin(4 * L0 * rad) - 1.25 * e * e * Math.sin(2 * M * rad));   // minutes
    const utcMin = (ms / 60000) % 1440;
    const hourAngle = ((utcMin + eot + 4 * lon) / 4 - 180) * rad;         // true solar time -> hour angle
    return Math.asin(Math.sin(lat * rad) * Math.sin(decl) + Math.cos(lat * rad) * Math.cos(decl) * Math.cos(hourAngle)) / rad;
}
// Auto's answer at `ms`: dark while the sun is below -3 degrees.
function autoDark(ms, lat, lon) { return sunAltitude(ms, lat, lon) < autoSunAltitude; }
// The next time (Unix ms) Auto's answer changes after `ms`, or 0 when it does not within two days (polar day or night).
function nextAutoFlip(ms, lat, lon) {
    const now = autoDark(ms, lat, lon);
    const step = 5 * 60000;
    for (let t = ms + step; t <= ms + 48 * 3600000; t += step) {
        if (autoDark(t, lat, lon) === now) continue;
        let lo = t - step, hi = t;                                          // bisect to a second
        while (hi - lo > 1000) { const mid = (lo + hi) / 2; if (autoDark(mid, lat, lon) === now) lo = mid; else hi = mid; }
        return Math.ceil(hi);
    }
    return 0;
}

function normalizeAppearance(obj) {
    const src = (obj && typeof obj === "object") ? obj : {};
    const o = Object.assign({}, appearanceDefaults, src);
    // The shell only knows {dark}; derive mode from it when mode is missing or bad.
    if (appearanceModes.indexOf(src.mode) === -1) o.mode = src.dark ? "dark" : "light";
    // Auto: `dark` is the sun's answer, kept as stored here and set by whoever runs the clock (AppState: autoDark)
    o.dark = o.mode === "auto" ? src.dark === true : o.mode === "dark";
    if (highlightNames.indexOf(o.highlight) === -1) o.highlight = "";
    o.reduceTransparency = !!o.reduceTransparency;
    o.increaseContrast = !!o.increaseContrast;   // Accessibility > Display
    o.reduceMotion = !!o.reduceMotion;           // Accessibility > Motion
    o.tintWindowBackground = o.tintWindowBackground !== false;   // Windows > Tint window background (Mac default on)
    if (iconStyles.indexOf(o.iconStyle) === -1) o.iconStyle = appearanceDefaults.iconStyle;
    if (iconStyleVariants.indexOf(o.iconStyleVariant) === -1) o.iconStyleVariant = appearanceDefaults.iconStyleVariant;
    if (iconTints.indexOf(o.iconTint) === -1) o.iconTint = "";
    o.glass = isFinite(Number(o.glass)) ? Math.min(1, Math.max(0, Number(o.glass))) : appearanceDefaults.glass;
    return o;
}

const dockDefaults = { size: 48, magnification: false, magnifiedSize: 96, position: "bottom", autohide: false, minimizeEffect: "genie", showRecents: true };
const dockPositions = ["left", "bottom", "right"];

function clamp(v, lo, hi, dflt) {
    v = Number(v);
    return isFinite(v) ? Math.min(hi, Math.max(lo, Math.round(v))) : dflt;
}

function normalizeDock(obj) {
    const o = Object.assign({}, dockDefaults, (obj && typeof obj === "object") ? obj : {});
    o.size = clamp(o.size, 16, 128, dockDefaults.size);
    o.magnifiedSize = clamp(o.magnifiedSize, o.size, 128, Math.max(o.size, dockDefaults.magnifiedSize));
    if (dockPositions.indexOf(o.position) === -1) o.position = dockDefaults.position;
    o.magnification = !!o.magnification;
    o.autohide = !!o.autohide;
    o.showRecents = !!o.showRecents;
    return o;
}

// sound.json, shared with the shell: alertSound is a name in sounds/wav/Sounds/<name>.wav.
const alertSounds = ["Basso", "Blow", "Bottle", "Frog", "Funk", "Glass", "Hero", "Morse", "Ping", "Pop", "Purr", "Sosumi", "Submarine", "Tink"];
// the names 27.2.1 shows for those files (Sound.appex AlertSounds.loctable, en): the files kept their old names, so
// the Mac's "Breeze" (settings/sound-light.png) is Blow.aiff
const alertSoundTitles = { Basso: "Mezzo", Blow: "Breeze", Bottle: "Pebble", Frog: "Jump", Funk: "Funky", Glass: "Crystal",
                           Hero: "Heroine", Morse: "Pong", Ping: "Sonar", Pop: "Bubble", Purr: "Pluck", Sosumi: "Sonumi",
                           Submarine: "Submerge", Tink: "Boop" };
// the pop-up's order: by shown name (the Mac's order is not captured)
const alertSoundMenu = alertSounds.slice().sort((a, b) => alertSoundTitles[a].localeCompare(alertSoundTitles[b]));
// startupSound: the Mac row "Play sound on startup" (a firmware chime there); stored only: hyprk has no startup sound
const soundDefaults = { alertSound: "Tink", alertVolume: 0.75, uiSounds: true, volumeFeedback: false, startupSound: true };

function normalizeSound(obj) {
    const o = Object.assign({}, soundDefaults, (obj && typeof obj === "object") ? obj : {});
    if (alertSounds.indexOf(o.alertSound) === -1) o.alertSound = soundDefaults.alertSound;
    const v = Number(o.alertVolume);
    o.alertVolume = isFinite(v) ? Math.min(1, Math.max(0, v)) : soundDefaults.alertVolume;
    o.uiSounds = !!o.uiSounds;
    o.volumeFeedback = !!o.volumeFeedback;
    o.startupSound = o.startupSound !== false;
    return o;
}

// lock.json, read by the shell / hypridle glue. Seconds; 0 = never.
const lockDefaults = { screenSaverAfter: 1200, displayOffAfter: 600, requirePasswordAfter: 0, largeClock: "lock" };
function normalizeLock(obj) {
    const o = Object.assign({}, lockDefaults, (obj && typeof obj === "object") ? obj : {});
    for (const k of ["screenSaverAfter", "displayOffAfter", "requirePasswordAfter"])
        o[k] = clamp(o[k], 0, 86400, lockDefaults[k]);
    if (["screensaver", "lock", "never"].indexOf(o.largeClock) === -1) o.largeClock = lockDefaults.largeClock;
    return o;
}

// input.json: keyboard repeat applied with `hyprctl eval` (see luaInput); the
// shell config can re-apply it at startup.
const inputDefaults = { repeatRate: 25, repeatDelay: 600 };
function normalizeInput(obj) {
    const o = Object.assign({}, inputDefaults, (obj && typeof obj === "object") ? obj : {});
    o.repeatRate = clamp(o.repeatRate, 1, 100, inputDefaults.repeatRate);
    o.repeatDelay = clamp(o.repeatDelay, 100, 2000, inputDefaults.repeatDelay);
    return o;
}

// notifications.json, read by the shell. apps: { "<desktop id>": { allow, style, sounds } }
const notifStyles = ["none", "banners", "alerts"];
const notifAppDefaults = { allow: true, style: "banners", sounds: true };
const notificationsDefaults = { previews: "unlocked", summarize: false, whenSleeping: false, whenLocked: true, whenMirroring: false, apps: {} };
function normalizeNotifications(obj) {
    const o = Object.assign({}, notificationsDefaults, (obj && typeof obj === "object") ? obj : {});
    if (["always", "unlocked", "never"].indexOf(o.previews) === -1) o.previews = notificationsDefaults.previews;
    for (const k of ["summarize", "whenSleeping", "whenLocked", "whenMirroring"]) o[k] = !!o[k];
    const apps = {};
    if (o.apps && typeof o.apps === "object")
        for (const id in o.apps) {
            const a = o.apps[id] || {};
            apps[id] = { allow: a.allow !== false, sounds: a.sounds !== false,
                         style: notifStyles.indexOf(a.style) === -1 ? notifAppDefaults.style : a.style };
        }
    o.apps = apps;
    return o;
}

// scripts/notify-apps.sh: "<desktop id>\t<Name>\t<Icon>" per line
function parseDesktopApps(text) {
    const seen = {};
    return lines(text).map(l => l.split("\t")).filter(f => f.length >= 2 && f[0] && f[1])
        .filter(f => !seen[f[0]] && (seen[f[0]] = true))
        .map(f => ({ id: f[0], name: f[1], icon: f[2] || "" }))
        .sort((a, b) => a.name.localeCompare(b.name));
}

// Display name from /etc/passwd for the account whose home dir is `home`: the GECOS
// full name, else the login name, else the home folder's name.
function gecosName(passwd, home) {
    for (const l of lines(passwd)) {
        const f = l.split(":");
        if (f.length >= 6 && f[5] === home) return (f[4] || "").split(",")[0].trim() || f[0];
    }
    return String(home).split("/").pop();
}

// "/x/Mac_Blue-dark.png" -> "Mac Blue dark", "DefaultAerial.png" -> "Default Aerial"
function prettyFileName(path) {
    return String(path || "").split("/").pop().replace(/\.[^.]+$/, "").replace(/[-_]/g, " ").replace(/([a-z])([A-Z])/g, "$1 $2");
}

// ---------- Displays: "Looks like" picker ----------
// displays.json, read by config/hypr/scale-policy.lua at Hyprland start and on hotplug:
// { looksLike: { "<output>": "WxH" } }. An output without an entry uses the macOS default.
const displaysDefaults = { looksLike: {} };
function normalizeDisplays(obj) {
    const o = Object.assign({}, displaysDefaults, (obj && typeof obj === "object") ? obj : {});
    const map = {};
    if (o.looksLike && typeof o.looksLike === "object")
        for (const k in o.looksLike) {
            const v = o.looksLike[k];
            if (k && !/["\\]/.test(k) && typeof v === "string" && /^\d+x\d+$/.test(v)) map[k] = v;
        }
    o.looksLike = map;
    return o;
}

// scale-policy.lua report() JSON -> { policy: "on"|"off", outputs: [...] }; anything else -> null.
function parseScaleReport(text) {
    let r;
    try { r = JSON.parse(text); } catch (e) { return null; }
    if (!r || typeof r !== "object" || !Array.isArray(r.outputs)) return null;
    const pair = a => Array.isArray(a) && a.length === 2 ? [a[0] | 0, a[1] | 0] : [0, 0];
    return {
        policy: r.policy === "off" ? "off" : "on",
        outputs: r.outputs.filter(o => o && typeof o.name === "string").map(o => ({
            name: o.name, virtual: !!o.virtual, hidpi: !!o.hidpi, scale: +o.scale || 1,
            native: pair(o.native), looks: pair(o.looks), def: pair(o.default),
            source: ["saved", "env"].indexOf(o.source) === -1 ? "default" : o.source,
            env: typeof o.env === "string" ? o.env : "",
            choices: (Array.isArray(o.choices) ? o.choices : [])
                .filter(c => c && c.w > 0 && c.h > 0)
                .map(c => ({ w: c.w | 0, h: c.h | 0, scale: +c.scale || 1, isDefault: !!c.default }))
        }))
    };
}

// "1920 × 1080", the way System Settings writes sizes
function sizeText(w, h) { return w + " \u00d7 " + h; }
function sizeKey(c) { return c.w + "x" + c.h; }

// The row of 5 scaled choices macOS shows for a HiDPI display, "Larger Text" (smallest looks-like size,
// biggest text) to "More Space". MonitorPanel bucketizeDisplayModes picks them, but its rule is not decoded
// (SPEC 14.5), so this is guessed: keep the smallest, the Default and the largest, then fill the widest gap
// with its middle choice until there are 5. choices are sorted by width (scale-policy.lua M.choices).
function looksLikeChiclets(choices) {
    const n = choices.length;
    if (!n) return [];
    let d = choices.findIndex(c => c.isDefault);
    const idx = [0, n - 1];
    if (d > 0 && d < n - 1) idx.push(d);
    idx.sort((a, b) => a - b);
    while (idx.length < Math.min(5, n)) {
        let gi = 0;
        for (let i = 1; i < idx.length - 1; i++) if (idx[i + 1] - idx[i] > idx[gi + 1] - idx[gi]) gi = i;
        if (idx[gi + 1] - idx[gi] < 2) break;
        idx.splice(gi + 1, 0, Math.round((idx[gi] + idx[gi + 1]) / 2));
    }
    return idx.filter((v, i) => idx.indexOf(v) === i).map((i, k, all) => Object.assign({}, choices[i], {
        label: choices[i].isDefault ? "Default" : k === 0 ? "Larger Text" : k === all.length - 1 ? "More Space" : ""
    }));
}

// Why the picker can't be used for this output ("" = it can). report = parseScaleReport result.
function looksLikeBlock(report, out) {
    if (!report) return "Display sizes come from hyprk's scale policy, which Hyprland could not run here.";
    if (report.policy === "off") return "Display scaling is turned off for this session (HYPRK_SCALE_POLICY=off).";
    if (!out) return "This display is not known to Hyprland yet.";
    if (out.virtual) return "This is a virtual display. Its size is set by its own rule.";
    if (out.source === "env") return "Set by " + out.env + " for this session.";
    if (!out.choices.length) return "No other sizes are available for this display.";
    return "";
}

// The selected looks-like key: the saved choice when it is one of the choices, else what Hyprland runs.
function looksLikeSelected(out, saved) {
    if (!out) return "";
    if (out.source !== "env" && saved && out.choices.some(c => sizeKey(c) === saved)) return saved;
    return out.looks[0] + "x" + out.looks[1];
}

// hyprctl eval snippets for config/hypr/scale-policy.lua
function luaScalePolicy(root) { return "dofile(" + luaString(root + "/config/hypr/scale-policy.lua") + ")"; }
function luaScaleSet(root, output, size) {
    return luaScalePolicy(root) + ".set(" + luaString(output) + ", " + luaString(size || "") + ")";
}
function luaScaleReport(root, path) { return luaScalePolicy(root) + ".report(" + luaString(path) + ")"; }

// A state file's text with unsaved local changes on top; missing or corrupt files
// give defaults. Unknown keys in the file are kept.
function mergeState(text, patch, normalize) {
    let obj = {};
    try { obj = JSON.parse(text); } catch (e) { obj = {}; }
    if (!obj || typeof obj !== "object") obj = {};
    return normalize(Object.assign({}, obj, patch || {}));
}

// "WxH@R" for hl.monitor from a parseHyprMonitors entry
function monitorMode(m) {
    return m.width + "x" + m.height + "@" + m.refreshRate;
}

if (typeof module !== "undefined")
    module.exports = { splitTerse, parseNmcliDevices, wifiDevice, parseNmcliWifi, parseWpctlSinks, parseWpctlSources, parseWpctlVolume,
        parseBluetoothShow, parseBluetoothDevices, parseHyprMonitors, hasBattery,
        parseHyprOption, luaString, luaMonitor, luaInput,
        normalizeAppearance, normalizeDock, normalizeSound, mergeState, monitorMode, prettyFileName,
        gecosName, normalizeLock, normalizeInput, normalizeNotifications, parseDesktopApps,
        appearanceDefaults, iconTints, highlightNames, zoneCoords, zoneName, sunAltitude, autoDark, nextAutoFlip, iconStyleVariantsOf, iconStyleVariantAfter, dockDefaults, soundDefaults, alertSounds, alertSoundTitles, alertSoundMenu,
        displaysDefaults, normalizeDisplays, parseScaleReport, sizeText, sizeKey, looksLikeChiclets, looksLikeBlock,
        looksLikeSelected, luaScalePolicy, luaScaleSet, luaScaleReport, lockDefaults, inputDefaults, notificationsDefaults, notifAppDefaults };
