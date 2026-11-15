// Sidebar registry. group starts a new block; file is panes/<file>.qml.
// "battery" and "energy" are swapped by hasBattery (macOS shows one of them).
// needs: the hardware a pane belongs to (Parsers.parseHardware keys); without it the pane is not listed (the user's
// choice of 2026-11-15, settings/FALLBACKS.md "Absent hardware").
const panes = [
    { id: "wifi", title: "Wi‑Fi", tint: "blue", file: "WiFi", group: 1, needs: "wifi" },
    { id: "bluetooth", title: "Bluetooth", tint: "blue", file: "Bluetooth", group: 1, needs: "bluetooth" },
    { id: "network", title: "Network", tint: "blue", file: "Network", group: 1 },
    { id: "vpn", title: "VPN", tint: "blue", file: "VPN", group: 1 },
    { id: "battery", title: "Battery", tint: "green", file: "Energy", group: 1, needsBattery: true },
    { id: "energy", title: "Energy", tint: "orange", file: "Energy", group: 1, needsBattery: false },
    { id: "general", title: "General", tint: "gray", file: "General", group: 2 },
    { id: "accessibility", title: "Accessibility", tint: "blue", file: "Accessibility", group: 2 },
    { id: "appearance", title: "Appearance", tint: "black", file: "Appearance", group: 2 },
    { id: "dock", title: "Desktop & Dock", tint: "black", file: "Dock", group: 2 },
    { id: "displays", title: "Displays", tint: "blue", file: "Displays", group: 2 },
    // 27.2.1 names this pane Menu Bar and lists it after Displays (settings/desktop-dock-light.png); id kept for links
    { id: "controlcenter", title: "Menu Bar", tint: "gray", file: "ControlCenter", group: 2 },
    // No "Apple Intelligence & Siri" pane (27.2.1 lists it here): hyprk has none of its features, and the user chose on
    // 2026-11-14 to hide it rather than show disabled Mac rows. panes/Siri.qml stays unused.
    { id: "spotlight", title: "Spotlight", tint: "gray", file: "Spotlight", group: 2 },
    { id: "wallpaper", title: "Wallpaper", tint: "teal", file: "Wallpaper", group: 2 },
    { id: "notifications", title: "Notifications", tint: "red", file: "Notifications", group: 3 },
    { id: "sound", title: "Sound", tint: "pink", file: "Sound", group: 3 },
    { id: "focus", title: "Focus", tint: "indigo", file: "Focus", group: 3 },
    { id: "lockscreen", title: "Lock Screen", tint: "black", file: "LockScreen", group: 4 },
    { id: "privacy", title: "Privacy & Security", tint: "blue", file: "Privacy", group: 4 },
    { id: "keyboard", title: "Keyboard", tint: "gray", file: "Keyboard", group: 5 },
    { id: "mouse", title: "Mouse", tint: "gray", file: "Mouse", group: 5, needs: "mouse" },
    { id: "trackpad", title: "Trackpad", tint: "gray", file: "Trackpad", group: 5, needs: "trackpad" }
];

// Every pane has its real macOS 27.2.1 icon, themes/icons/settings/<id>@<64|128>-<default|dark|clear|tinted>-<light|dark>.png (one set per icon style), rendered by
// IconServices on the Mac (reference/re/MAC-ANSWERS.md R3b); tint above is the fallback tile.
// Row icons: the 24 pt tile of a row (48 px only), built by themes/icons/tools/build-graphic.py from the symbol and
// colours of Apple's graphic icon configurations (themes/icons/settings/graphic.json, sizes [48]).
const rowIcons = ["general-about", "general-about-laptop", "general-softwareupdate", "general-storage", "general-airdrop",
    "general-loginitems", "general-language", "general-datetime", "general-sharing", "general-timemachine", "general-transfer",
    "general-startupdisk", "privacy-location", "privacy-microphone", "privacy-camera", "privacy-screenrecording", "privacy-files",
    "display", "menubar-nowplaying", "menubar-clock", "network-ethernet", "network-firewall", "ax-voiceover", "ax-zoom",
    "ax-hovertext", "ax-motion", "ax-readspeak", "ax-audiodesc", "ax-voicecontrol", "ax-pointer", "ax-switchcontrol",
    "ax-hearingdevices", "ax-audio", "ax-captions", "ax-livecaptions", "ax-namerecognition", "ax-livespeech", "ax-personalvoice",
    "ax-vocalshortcuts", "ax-shortcut", "bluetooth-headphones"];
// Pane icons of panes hyprk does not have (yet): same files as a pane's
const extraIcons = ["screentime", "touchid", "users", "gamecenter", "icloud", "internetaccounts", "wallet", "printers", "siri"];
// Row tiles cut from the Mac's own rows (MAC-ANSWERS-14.md R14.3; themes/icons/tools/cut-row-crops.py):
// themes/icons/settings/crops/<id>-<light|dark>.png, the tile at 2x with its shadow. One look only, the Mac's (it was
// on the Dark icon style): id -> [the file's px, the tile's px in it].
const cropIcons = {
    "privacy-fulldisk": [48, 40], "privacy-passkeys": [48, 40], "privacy-appmanagement": [48, 40], "privacy-automation": [48, 40],
    "privacy-bluetooth": [48, 40], "privacy-developertools": [48, 40], "privacy-devicecontrol": [48, 40], "privacy-focus": [48, 40],
    "privacy-inputmonitoring": [48, 40], "privacy-localnetwork": [48, 40], "privacy-motion": [48, 40], "privacy-remotedesktop": [48, 40],
    "privacy-speech": [48, 40], "privacy-sensitive": [48, 40], "privacy-blocked": [48, 40], "privacy-analytics": [48, 40],
    "privacy-advertising": [48, 40], "privacy-aireport": [48, 40], "privacy-filevault": [48, 40], "privacy-accessories": [48, 40],
    "privacy-background": [48, 40],
    "focus-dnd": [64, 52], "focus-driving": [64, 52], "focus-mindfulness": [64, 52], "focus-reduce": [64, 52], "focus-sleep": [64, 52],
    "focus-work": [64, 52]
};
function isCropIcon(id) { return cropIcons[id] !== undefined; }
// the drawn art's size over the tile's
function cropScale(id) { return cropIcons[id][0] / cropIcons[id][1]; }
function isRowIcon(id) { return rowIcons.indexOf(id) !== -1; }
function hasRealIcon(id) { return isRowIcon(id) || isCropIcon(id) || extraIcons.indexOf(id) !== -1 || panes.some(p => p.id === id); }
// the file's px for an icon drawn artPx device pixels wide
function iconPx(id, artPx) { return isRowIcon(id) ? 48 : artPx > 64 ? 128 : 64; }

// hw: Parsers.parseHardware's object; left out = every pane's hardware is there
function visible(hasBattery, query, hw) {
    const q = String(query || "").toLowerCase();
    return panes.filter(p => (p.needsBattery === undefined || p.needsBattery === hasBattery)
        && (!p.needs || !hw || hw[p.needs] !== false)
        && (q === "" || p.title.toLowerCase().indexOf(q) !== -1));
}
