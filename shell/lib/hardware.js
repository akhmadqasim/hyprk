.pragma library

// Hardware-bound items (Wi-Fi, Bluetooth, AirDrop, battery) and the display brightness backends: pure logic for
// services/Hardware.qml and services/Brightness.qml. Unit tested (node shell/tests/run.mjs).

// ---------- which hardware is there ----------
// HYPRK_HW (tests): "wifi=0,bluetooth=1" decides an item whatever the machine has. Names: wifi, bluetooth, battery.
function overrides(env) {
    const o = {};
    for (const part of String(env || "").split(",")) {
        const m = /^\s*([a-z]+)\s*=\s*([01])\s*$/.exec(part);
        if (m) o[m[1]] = m[2] === "1";
    }
    return o;
}
function present(name, detected, ov) {
    return ov && ov[name] !== undefined ? ov[name] : !!detected;
}
// AirDrop needs both radios, as on the Mac (Wi-Fi for the transfer, Bluetooth to find people)
function hasAirdrop(wifi, bluetooth) {
    return !!wifi && !!bluetooth;
}

// Control Center's grid without the modules whose hardware is absent (the user's choice of 2026-11-15: hide, never
// show an "off" tile for hardware that is not there). Cells are { c: column 0|1, r: row, span: columns }; null = not
// drawn. With all three the Mac's layout. With fewer the modules under them move up and nothing leaves a hole:
//   3: [Wi-Fi | Now Playing] [Bluetooth | Now Playing] [AirDrop | Stage, Mirroring] [Dark, Display | Focus]
//   2: [a | Now Playing] [b | Now Playing] [Dark, Display | Stage, Mirroring] [Focus, both columns]
//   1: [a | Now Playing] [Dark, Display | Now Playing] [Focus | Stage, Mirroring]
//   0: [Dark, Display | Now Playing] [Stage, Mirroring | Now Playing] [Focus, both columns]
// `rows` is the grid's rows above the two sliders. These layouts are not on a Mac shot (no Mac lacks the radios).
function ccLayout(h) {
    const names = ["wifi", "bluetooth", "airdrop"].filter(n => h && h[n]);
    const l = { wifi: null, bluetooth: null, airdrop: null, nowPlaying: { c: 1, r: 0, span: 1 } };
    names.forEach((n, i) => l[n] = { c: 0, r: i, span: 1 });
    const n = names.length;
    if (n === 3) {
        l.stage = { c: 1, r: 2, span: 1 }; l.dark = { c: 0, r: 3, span: 1 }; l.focus = { c: 1, r: 3, span: 1 }; l.rows = 4;
    } else if (n === 2) {
        l.dark = { c: 0, r: 2, span: 1 }; l.stage = { c: 1, r: 2, span: 1 }; l.focus = { c: 0, r: 3, span: 2 }; l.rows = 4;
    } else if (n === 1) {
        l.dark = { c: 0, r: 1, span: 1 }; l.focus = { c: 0, r: 2, span: 1 }; l.stage = { c: 1, r: 2, span: 1 }; l.rows = 3;
    } else {
        l.dark = { c: 0, r: 0, span: 1 }; l.stage = { c: 0, r: 1, span: 1 }; l.focus = { c: 0, r: 2, span: 2 }; l.rows = 3;
    }
    return l;
}

// ---------- brightness ----------
// scripts/brightness.sh probe prints one line per backend it can drive:
//   "backlight <current> <max>"      a backlight class device (brightnessctl)
//   "ddc <i2c bus> <current> <max>"  an external monitor that answers DDC/CI VCP 10 (ddcutil)
// -> { mode: "backlight" | "ddc" | "", value: 0..1, ddc: [{ bus, max }] }. A backlight wins. With several DDC
// monitors the value is the first one's; a set goes to all of them.
function parseProbe(text) {
    const r = { mode: "", value: 1, ddc: [] };
    for (const line of String(text || "").split("\n")) {
        const f = line.trim().split(/\s+/);
        if (f[0] === "backlight" && f.length >= 3 && +f[2] > 0 && r.mode !== "backlight") {
            r.mode = "backlight"; r.value = clamp01(+f[1] / +f[2]); r.ddc = [];
        } else if (f[0] === "ddc" && f.length >= 4 && /^\d+$/.test(f[1]) && +f[3] > 0 && r.mode !== "backlight") {
            if (r.mode === "") { r.mode = "ddc"; r.value = clamp01(+f[2] / +f[3]); }
            r.ddc.push({ bus: +f[1], max: +f[3] });
        }
    }
    return r;
}
function clamp01(v) { return isFinite(v) ? Math.max(0, Math.min(1, v)) : 0; }
// what set() keeps: never fully off (a backlight at 0 is a black screen), 4 decimals so both processes compare equal
function level(v) { return Math.round(Math.max(0.01, Math.min(1, isFinite(v) ? v : 1)) * 10000) / 10000; }
// a brightness key: one step of 1/n on the grid of n steps (16, Option+Shift 64), as the Mac's keys
function stepLevel(v, dir, n) {
    const k = Math.round(clamp01(v) * n) + (dir > 0 ? 1 : -1);
    return level(Math.max(0, Math.min(n, k)) / n);
}
// $HYPRK_STATE/brightness.json, shared with Settings > Displays: { value, available, source, probe }.
// value null = none in the file; probe = a counter Settings raises to ask for a new look at the hardware.
function parseState(text) {
    let o = null;
    try { o = JSON.parse(text); } catch (e) { o = null; }
    if (!o || typeof o !== "object") o = {};
    return { value: typeof o.value === "number" && isFinite(o.value) ? o.value : null, available: o.available === true,
             source: typeof o.source === "string" ? o.source : "", probe: typeof o.probe === "number" ? o.probe : 0 };
}
function sameState(a, b) {
    return !!a && !!b && a.value === b.value && a.available === b.available && a.source === b.source && a.probe === b.probe;
}
