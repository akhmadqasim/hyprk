// Reading state/*.json with defaults, and feature/fallback detection.
.pragma library

// Merge JSON text over defaults. Unknown keys are ignored, wrong types fall
// back to the default, invalid JSON returns the defaults unchanged.
function parse(text, defaults) {
    const out = Object.assign({}, defaults);
    let o;
    try {
        o = JSON.parse(text || "");
    } catch (e) {
        return out;
    }
    if (!o || typeof o !== "object" || Array.isArray(o)) return out;
    for (const k in defaults) {
        if (k in o && typeof o[k] === typeof defaults[k] && o[k] !== null) out[k] = o[k];
    }
    return out;
}

// state/dock.json defaults, like a clean macOS account (`defaults read com.apple.dock magnification` = 0):
// magnification is off until the user turns it on in Desktop & Dock. Same values as settings/Parsers.js
// dockDefaults (size and magnifiedSize in pt; the shell uses only their ratio, see magnifyRatio). The recent
// apps section is on by default, like macOS (`show-recents` absent = 1, MAC-ANSWERS.md Q-dock-14).
function dockDefaults() {
    return { autohide: false, magnification: false, size: 48, magnifiedSize: 96, showRecents: true };
}

// Magnified size / tile size from dock.json, 1..8 (Settings clamps both to 16..128 pt).
function magnifyRatio(dock) {
    const r = Number(dock && dock.magnifiedSize) / Number(dock && dock.size);
    return isFinite(r) && r > 0 ? Math.min(8, Math.max(1, r)) : 2;
}

// UPower devices -> true only if a real (non-peripheral) laptop battery is present.
// UPowerDeviceType.Battery == 2 in Quickshell.
function hasBattery(devices) {
    return (devices || []).some(d => d && d.type === 2 && d.isPresent && d.powerSupply);
}

// Bluetooth tile is available only with an adapter.
function hasBluetooth(adapter) {
    return !!adapter;
}

// PipeWire volume is available only when the server is ready and has a sink with audio.
function hasAudio(ready, sink) {
    return !!(ready && sink && sink.audio);
}

// Wi-Fi status: available with a NetworkManager wifi device.
// DeviceType.Wifi == 1 in Quickshell.Networking.
function wifiDevice(devices) {
    return (devices || []).find(d => d && d.type === 1) || null;
}

// Pick the MPRIS player to show: playing first, then any that can be controlled.
// MprisPlaybackState.Playing == 1 in Quickshell.
function pickPlayer(players) {
    const list = (players || []).filter(p => p);
    return list.find(p => p.playbackState === 1) || list.find(p => p.canControl) || null;
}

// Per-app notification rule from state/notifications.json `apps` (keys are
// desktop ids). Tries each candidate key (desktop entry, app name), lowercased
// match too; unknown apps get the macOS defaults.
function notifRule(prefs, keys) {
    const apps = (prefs && prefs.apps && typeof prefs.apps === "object") ? prefs.apps : {};
    const ids = Object.keys(apps);
    for (const k of keys || []) {
        if (!k) continue;
        const key = String(k).replace(/\.desktop$/, "");
        const id = ids.find(i => i === key) || ids.find(i => i.toLowerCase() === key.toLowerCase());
        if (id) {
            const a = apps[id] || {};
            return { allow: a.allow !== false, sounds: a.sounds !== false,
                     style: ["none", "banners", "alerts"].indexOf(a.style) === -1 ? "banners" : a.style };
        }
    }
    return { allow: true, style: "banners", sounds: true };
}

// Lua for Hyprland keyboard repeat (Hyprland 0.57 has no `hyprctl keyword`; use `hyprctl eval`)
function luaInput(input) {
    const rate = Math.round(Math.min(100, Math.max(1, Number(input && input.repeatRate) || 25)));
    const delay = Math.round(Math.min(2000, Math.max(100, Number(input && input.repeatDelay) || 600)));
    return `hl.config({ input = { repeat_rate = ${rate}, repeat_delay = ${delay} } })`;
}
