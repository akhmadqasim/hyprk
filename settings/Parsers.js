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
function parseWpctlSinks(text) {
    const sinks = [];
    let inAudio = false, inSinks = false;
    for (const raw of String(text || "").split("\n")) {
        if (/^Audio\b/.test(raw)) { inAudio = true; continue; }
        if (/^\S/.test(raw)) { inAudio = false; inSinks = false; continue; }
        if (!inAudio) continue;
        if (/[├└]─\s*(\w+):/.test(raw)) { inSinks = /Sinks:/.test(raw); continue; }
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

// cat /sys/class/power_supply/*/type
function hasBattery(text) {
    return lines(text).some(l => l.trim() === "Battery");
}

// ---------- state files ----------
// appearance.json is shared with the shell, which reads {dark, reduceTransparency}.
// glass: macOS 27 "Liquid Glass" slider, 0 = clear, 1 = tinted.
// iconStyle: macOS 26+ "Icon & widget style" (default | dark | clear | tinted).
const appearanceDefaults = { mode: "light", dark: false, reduceTransparency: false, accent: "multicolor", sidebarIconSize: "medium", glass: 0.5, iconStyle: "default" };
const appearanceModes = ["light", "dark", "auto"];
const iconStyles = ["default", "dark", "clear", "tinted"];

function normalizeAppearance(obj) {
    const src = (obj && typeof obj === "object") ? obj : {};
    const o = Object.assign({}, appearanceDefaults, src);
    // The shell only knows {dark}; derive mode from it when mode is missing or bad.
    if (appearanceModes.indexOf(src.mode) === -1) o.mode = src.dark ? "dark" : "light";
    o.dark = o.mode === "dark";   // "auto" follows light until a sun clock exists
    o.reduceTransparency = !!o.reduceTransparency;
    if (iconStyles.indexOf(o.iconStyle) === -1) o.iconStyle = appearanceDefaults.iconStyle;
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
const soundDefaults = { alertSound: "Tink", alertVolume: 0.75, uiSounds: true, volumeFeedback: false };

function normalizeSound(obj) {
    const o = Object.assign({}, soundDefaults, (obj && typeof obj === "object") ? obj : {});
    if (alertSounds.indexOf(o.alertSound) === -1) o.alertSound = soundDefaults.alertSound;
    const v = Number(o.alertVolume);
    o.alertVolume = isFinite(v) ? Math.min(1, Math.max(0, v)) : soundDefaults.alertVolume;
    o.uiSounds = !!o.uiSounds;
    o.volumeFeedback = !!o.volumeFeedback;
    return o;
}

// "/x/Mac_Blue-dark.png" -> "Mac Blue dark"
function prettyFileName(path) {
    return String(path || "").split("/").pop().replace(/\.[^.]+$/, "").replace(/[-_]/g, " ");
}

// Parse a state file's text; missing or corrupt files give defaults.
function readState(text, normalize) {
    let obj = {};
    try { obj = JSON.parse(text); } catch (e) { obj = {}; }
    return normalize(obj);
}

function writeState(current, patch, normalize) {
    return JSON.stringify(normalize(Object.assign({}, current, patch)), null, 2) + "\n";
}

if (typeof module !== "undefined")
    module.exports = { splitTerse, parseNmcliDevices, wifiDevice, parseNmcliWifi, parseWpctlSinks, parseWpctlVolume,
        parseBluetoothShow, parseBluetoothDevices, parseHyprMonitors, hasBattery,
        normalizeAppearance, normalizeDock, normalizeSound, readState, writeState, prettyFileName,
        appearanceDefaults, dockDefaults, soundDefaults, alertSounds };
