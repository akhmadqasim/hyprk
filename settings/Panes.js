// Sidebar registry. group starts a new block; file is panes/<file>.qml.
// "battery" and "energy" are swapped by hasBattery (macOS shows one of them).
const panes = [
    { id: "wifi", title: "Wi‑Fi", glyph: "wifi", tint: "blue", file: "WiFi", group: 1 },
    { id: "bluetooth", title: "Bluetooth", glyph: "bluetooth", tint: "blue", file: "Bluetooth", group: 1 },
    { id: "network", title: "Network", glyph: "language", tint: "blue", file: "Network", group: 1 },
    { id: "vpn", title: "VPN", glyph: "vpn_lock", tint: "blue", file: "VPN", group: 1 },
    { id: "battery", title: "Battery", glyph: "battery_full", tint: "green", file: "Energy", group: 1, needsBattery: true },
    { id: "energy", title: "Energy", glyph: "lightbulb", tint: "orange", file: "Energy", group: 1, needsBattery: false },
    { id: "general", title: "General", glyph: "settings", tint: "gray", file: "General", group: 2 },
    { id: "accessibility", title: "Accessibility", glyph: "accessibility_new", tint: "blue", file: "Accessibility", group: 2 },
    { id: "appearance", title: "Appearance", glyph: "contrast", tint: "black", file: "Appearance", group: 2 },
    { id: "controlcenter", title: "Control Center", glyph: "toggle_on", tint: "gray", file: "ControlCenter", group: 2 },
    { id: "dock", title: "Desktop & Dock", glyph: "call_to_action", tint: "black", file: "Dock", group: 2 },
    { id: "displays", title: "Displays", glyph: "light_mode", tint: "blue", file: "Displays", group: 2 },
    { id: "siri", title: "Siri", glyph: "graphic_eq", tint: "purple", file: "Siri", group: 2 },
    { id: "spotlight", title: "Spotlight", glyph: "search", tint: "gray", file: "Spotlight", group: 2 },
    { id: "wallpaper", title: "Wallpaper", glyph: "filter_vintage", tint: "teal", file: "Wallpaper", group: 2 },
    { id: "notifications", title: "Notifications", glyph: "notifications", tint: "red", file: "Notifications", group: 3 },
    { id: "sound", title: "Sound", glyph: "volume_up", tint: "pink", file: "Sound", group: 3 },
    { id: "focus", title: "Focus", glyph: "dark_mode", tint: "indigo", file: "Focus", group: 3 },
    { id: "lockscreen", title: "Lock Screen", glyph: "lock", tint: "black", file: "LockScreen", group: 4 },
    { id: "privacy", title: "Privacy & Security", glyph: "back_hand", tint: "blue", file: "Privacy", group: 4 },
    { id: "keyboard", title: "Keyboard", glyph: "keyboard", tint: "gray", file: "Keyboard", group: 5 },
    { id: "mouse", title: "Mouse", glyph: "mouse", tint: "gray", file: "Mouse", group: 5 },
    { id: "trackpad", title: "Trackpad", glyph: "crop_landscape", tint: "gray", file: "Trackpad", group: 5 }
];

// Every pane has its real macOS 27.2.1 icon, themes/icons/settings/<id>@<64|128>-<default|dark|clear|tinted>-<light|dark>.png (one set per icon style), rendered by
// IconServices on the Mac (reference/re/MAC-ANSWERS.md R3b); glyph and tint above are the fallback tile.
function hasRealIcon(id) { return panes.some(p => p.id === id); }

function visible(hasBattery, query) {
    const q = String(query || "").toLowerCase();
    return panes.filter(p => (p.needsBattery === undefined || p.needsBattery === hasBattery)
        && (q === "" || p.title.toLowerCase().indexOf(q) !== -1));
}
