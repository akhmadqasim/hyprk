// Accessibility state (state/accessibility.json) and what it turns into for Hyprland.
// Pure functions, no QML imports, so node can test them (tests/a11y.test.js).
//
// Split of the state, like macOS keeps it per feature:
//   appearance.json    reduceTransparency, increaseContrast, reduceMotion (the shell's
//                      Theme and services/A11y.qml read these)
//   accessibility.json everything below
// Settings turns both into state/accessibility.lua (luaApply) and evaluates it with
// `hyprctl eval`; the shell (services/A11y.qml) evaluates the same file at login and
// after every Hyprland config reload, so the choices survive restarts.

const filterTypes = ["grayscale", "protanopia", "deuteranopia", "tritanopia", "tint"];
const invertModes = ["smart", "classic"];
const zoomModifiers = ["control", "option", "command"];
const zoomStyles = ["fullscreen", "split", "pip"];

const defaults = {
    // Display
    invertColors: false, invertMode: "smart",
    differentiateWithoutColor: false,
    displayContrast: 0,                 // 0..1, 0 = normal (shader contrast 1..2)
    pointerSize: 1,                     // 1..4 x the theme size (macOS slider Normal..Large)
    colorFilters: false, filterType: "grayscale", filterIntensity: 0.8, tintColor: "#FF8080",
    // Motion (reduceMotion itself is in appearance.json)
    autoplayImages: true, nonBlinkingCursor: false,
    // Zoom
    zoomKeys: false, zoomScroll: false, zoomModifier: "control", zoomStyle: "fullscreen",
    // VoiceOver (Orca) and Read & Speak (speech-dispatcher)
    voiceOver: false,
    speakSelection: false, speakAnnouncements: false, speechRate: 0.5,
    // Hearing
    flashScreen: false, monoAudio: false, preferSdh: false
};
const enums = { filterType: filterTypes, invertMode: invertModes, zoomModifier: zoomModifiers, zoomStyle: zoomStyles };

function clampNum(v, lo, hi, dflt) {
    v = Number(v);
    return isFinite(v) ? Math.min(hi, Math.max(lo, v)) : dflt;
}

function normalize(obj) {
    const o = Object.assign({}, defaults, (obj && typeof obj === "object" && !Array.isArray(obj)) ? obj : {});
    for (const k in defaults)
        if (typeof defaults[k] === "boolean") o[k] = !!o[k];
    for (const k in enums)
        if (enums[k].indexOf(o[k]) === -1) o[k] = defaults[k];
    o.displayContrast = clampNum(o.displayContrast, 0, 1, 0);
    o.pointerSize = clampNum(o.pointerSize, 1, 4, 1);
    o.filterIntensity = clampNum(o.filterIntensity, 0, 1, defaults.filterIntensity);
    o.speechRate = clampNum(o.speechRate, 0, 1, defaults.speechRate);
    if (!/^#[0-9a-fA-F]{6}$/.test(String(o.tintColor))) o.tintColor = defaults.tintColor;
    return o;
}

// ---------- screen filter (Display) ----------
// True when Hyprland needs a screen shader at all.
function needsShader(a) {
    return a.invertColors || a.colorFilters || a.displayContrast > 0;
}

function glslFloat(v) {
    const s = String(Math.round(Number(v) * 1000) / 1000);
    return s.indexOf(".") === -1 && s.indexOf("e") === -1 ? s + ".0" : s;
}

// "#RRGGBB" -> "vec3(r, g, b)"
function glslColor(hex) {
    const n = parseInt(String(hex).slice(1), 16);
    return "vec3(" + [n >> 16 & 255, n >> 8 & 255, n & 255].map(c => glslFloat(c / 255)).join(", ") + ")";
}

// The shipped config/hypr/shaders/a11y-filter.frag with its #defines set. The template
// starts with "#version 300 es"; the defines must follow that line.
function shaderSource(template, a) {
    const t = String(template || "");
    const nl = t.indexOf("\n");
    if (nl < 0 || !/^#version/.test(t)) return "";
    const defs = [
        "#define INVERT " + (a.invertColors ? (a.invertMode === "classic" ? 1 : 2) : 0),
        "#define FILTER " + (a.colorFilters ? filterTypes.indexOf(a.filterType) + 1 : 0),
        "#define INTENSITY " + glslFloat(a.filterIntensity),
        "#define TINT " + glslColor(a.tintColor)
    ];
    if (a.displayContrast > 0) defs.push("#define CONTRAST " + glslFloat(1 + a.displayContrast));
    return t.slice(0, nl + 1) + defs.join("\n") + "\n" + t.slice(nl + 1);
}

// ---------- Hyprland ----------
function luaString(s) {
    return '"' + String(s).replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n") + '"';
}
// POSIX single-quoted shell word (for paths inside exec_cmd strings)
function shWord(s) {
    return "'" + String(s).replace(/'/g, "'\\''") + "'";
}

const baseCursorSize = 24;   // config/hypr/hyprland.lua XCURSOR_SIZE / HYPRCURSOR_SIZE
function cursorSize(a) {
    return Math.round(baseCursorSize * a.pointerSize);
}

// Keys this file may bind; all are unbound first so evaluating it again never doubles them.
// SUPER plays Command, ALT plays Option (config/hypr/hyprland.lua).
const zoomBinds = [["SUPER + ALT + 8", "toggle"], ["SUPER + ALT + equal", "in"], ["SUPER + ALT + minus", "out"]];
const scrollMods = { control: "CTRL", option: "ALT", command: "SUPER" };
function scrollBinds(mod) {
    const m = scrollMods[mod];
    return [[m + " + mouse_up", "in"], [m + " + mouse_down", "out"]];   // wheel up zooms in
}
const voiceOverKey = "SUPER + F5";        // macOS: Command-F5
const speakKey = "ALT + Escape";          // macOS Speak selection default: Option-Esc
const allKeys = zoomBinds.concat(...Object.keys(scrollMods).map(scrollBinds)).map(b => b[0]).concat([voiceOverKey, speakKey]);

// Reduce motion: config/hypr/hyprland.lua owns the window/Space animations and exposes
// hyprk_motion(reduce) (macOS swaps zooms and slides for dissolves). hyprctl eval runs
// in the config's Lua state, so the global is visible. Without it (older config),
// reduce falls back to no window geometry animation and cross-faded Spaces.
const motionOn = ['if hyprk_motion then hyprk_motion(false) end'];
const motionOff = ['if hyprk_motion then hyprk_motion(true) else '
    + 'hl.animation({ leaf = "windows", enabled = false }); hl.animation({ leaf = "windowsOut", enabled = false }); '
    + 'hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "macEase", style = "fade" }) end'];
// Increase contrast window borders; bordersNormal mirrors general.col in hyprland.lua.
const bordersNormal = 'hl.config({ general = { col = { active_border = "rgba(0000001f)", inactive_border = "rgba(00000017)" } } })';
const bordersStrong = 'hl.config({ general = { col = { active_border = "rgba(000000a6)", inactive_border = "rgba(00000080)" } } })';

// Lua for `hyprctl eval` (and the shell at login). root = hyprk checkout, stateDir = $HYPRK_STATE (the
// screen filter shader is written there).
// Every line is idempotent: running it twice gives the same state.
function luaApply(a, appearance, root, stateDir) {
    const ap = appearance || {};
    const scripts = root + "/settings/scripts/";
    const exec = (script, arg) => "hl.dsp.exec_cmd(" + luaString(shWord(scripts + script) + (arg ? " " + arg : "")) + ")";
    // No leading "--" comment: hyprctl would read the text as a flag.
    const out = [];

    // Zoom: keyboard shortcuts and scroll gesture (cursor:zoom_factor in a11y-zoom.sh)
    for (const k of allKeys) out.push("hl.unbind(" + luaString(k) + ")");
    if (a.zoomKeys) for (const b of zoomBinds) out.push("hl.bind(" + luaString(b[0]) + ", " + exec("a11y-zoom.sh", b[1]) + ")");
    if (a.zoomScroll) for (const b of scrollBinds(a.zoomModifier)) out.push("hl.bind(" + luaString(b[0]) + ", " + exec("a11y-zoom.sh", b[1]) + ")");

    // VoiceOver (Orca): Command-F5 always toggles it, like macOS
    out.push("hl.bind(" + luaString(voiceOverKey) + ", " + exec("a11y-orca.sh", "toggle") + ")");
    // once per Hyprland session, and only if accessibility.json still says on (the script checks)
    out.push("hl.exec_cmd(" + luaString(shWord(scripts + "a11y-orca.sh") + " restore") + ")");
    // Read & Speak: Speak selection
    if (a.speakSelection) out.push("hl.bind(" + luaString(speakKey) + ", " + exec("a11y-speak.sh", "selection") + ")");

    // Display: pointer size and screen filter
    const size = cursorSize(a);
    out.push("hl.env(\"XCURSOR_SIZE\", \"" + size + "\")", "hl.env(\"HYPRCURSOR_SIZE\", \"" + size + "\")");
    out.push("hl.exec_cmd(" + luaString("hyprctl setcursor \"${HYPRCURSOR_THEME:-hyprk-cursors}\" " + size) + ")");
    // clear first: Hyprland recompiles the shader file only when the option changes
    out.push('hl.config({ decoration = { screen_shader = "" } })');
    if (needsShader(a)) out.push("hl.config({ decoration = { screen_shader = " + luaString(stateDir + "/a11y-screen.frag") + " } })");

    // Motion and contrast
    out.push(...(ap.reduceMotion ? motionOff : motionOn));
    out.push(ap.increaseContrast ? bordersStrong : bordersNormal);
    out.push("-- generated by hyprk Settings > Accessibility from state/accessibility.json and",
             "-- state/appearance.json. Do not edit: the next change rewrites it.");
    return out.join("\n") + "\n";
}

if (typeof module !== "undefined")
    module.exports = { defaults, normalize, filterTypes, needsShader, shaderSource, glslColor, glslFloat,
        luaApply, zoomBinds, voiceOverKey, speakKey };
