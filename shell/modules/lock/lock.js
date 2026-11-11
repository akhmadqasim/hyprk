// Lock screen logic without Qt: clock and date text, user name, initials, notification filter,
// keyboard state from `hyprctl devices -j`, the password field geometry, the minute change and the
// wrong-password shake curve (reference/re/LOCKSCREEN-27.2.1.md). Tested by shell/tests/run.mjs.
.pragma library

function pad(n) { return n < 10 ? "0" + n : String(n); }

const DAYS3 = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const MONTHS3 = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

// Time separator of the locale ("en_ID.UTF-8" -> "."): the 27.2.1 lock clock reads "09.07" with region
// Indonesia (LOCKSCREEN-27.2.1.md A3). Region ID, Finnish and Danish write ".", everything else ":" (CLDR).
function timeSep(locale) {
    const name = String(locale || "").split(".")[0].split("@")[0];
    const region = name.split("_")[1] || "";
    const lang = name.split("_")[0];
    return region === "ID" || lang === "fi" || lang === "da" ? "." : ":";
}

// Large clock: 24 h with a leading zero ("09.07", measured A3); 12 h without AM/PM ("9:07", not measured on
// the Mac, LOCKSCREEN-27.2.1.md C).
function time(d, use24h, sep) {
    const h = d.getHours(), s = sep || ":";
    return (use24h ? pad(h) : String(h % 12 || 12)) + s + pad(d.getMinutes());
}

// Date line above the clock: "Wed 11 Nov" (day first, measured A2) or "Wed Nov 11" (month first, not measured).
function date(d, monthFirst) {
    const day = DAYS3[d.getDay()], mon = MONTHS3[d.getMonth()];
    return monthFirst ? day + " " + mon + " " + d.getDate() : day + " " + d.getDate() + " " + mon;
}

// Minute change: which characters of `next` differ from `prev` (same index). Only those animate
// (LOCKSCREEN-27.2.1.md B8); a different length (12 h 9:59 -> 10:00) changes every character.
function changed(prev, next) {
    const a = String(prev || ""), b = String(next || "");
    const out = [];
    for (let i = 0; i < b.length; i++) out.push(a.length !== b.length || a[i] !== b[i]);
    return out;
}

// Password field geometry in pt from the capsule's left edge (A5): dots are discs at a 8.25 pitch whose
// first left edge is 15.5 in; the caret sits 12 in when empty and right after the last dot otherwise.
const DOT_START = 15.5, DOT_PITCH = 8.25, CARET_EMPTY = 12, CARET_AFTER = -0.75;
function dotX(i) { return DOT_START + i * DOT_PITCH; }
function caretX(n) { return n > 0 ? DOT_START + n * DOT_PITCH + CARET_AFTER : CARET_EMPTY; }
// how many dots fit before `limit` (the left edge of the arrow ring) with the caret after them
function dotsFit(limit, caretW) {
    return Math.max(1, Math.floor((limit - caretW - DOT_START - CARET_AFTER) / DOT_PITCH));
}

// Full name from a passwd line (GECOS up to the first comma), else the login name.
function fullName(passwdLine, user) {
    const f = String(passwdLine || "").trim().split(":");
    const gecos = (f[4] || "").split(",")[0].trim();
    return gecos || user || "";
}

// "Akhmad Qasim" -> "AQ", "akhmad" -> "A"; first and last word, letters only.
function initials(name) {
    const w = String(name || "").trim().split(/\s+/).filter(x => x);
    if (w.length === 0) return "";
    const first = w[0][0], last = w.length > 1 ? w[w.length - 1][0] : "";
    return (first + last).toUpperCase();
}

// Notifications shown on the lock screen: those that arrived after the lock, newest first, at most
// `max`. previews "unlocked" or "never" hides the body (Settings > Notifications > Show previews).
// rows: plain objects { nid, appName, summary, body, time, ... } in history order (newest first).
function lockNotifs(rows, since, max, prefs) {
    const p = prefs || {};
    if (p.whenLocked === false) return [];
    const hide = p.previews === "unlocked" || p.previews === "never";
    const out = [];
    for (const r of rows || []) {
        if (!r || r.time < since) continue;
        out.push(hide ? Object.assign({}, r, { summary: "", body: "" }) : r);
        if (out.length >= max) break;
    }
    return out;
}

// Main keyboard from `hyprctl devices -j`: { layouts: ["us", "de"], index, name, capsLock }.
// Hyprland marks one keyboard `main`; without that flag the first one counts.
function keyboard(json) {
    let o;
    try { o = typeof json === "string" ? JSON.parse(json) : json; } catch (e) { return null; }
    const kbs = (o && o.keyboards) || [];
    const k = kbs.find(x => x.main) || kbs[0];
    if (!k) return null;
    const layouts = String(k.layout || "").split(",").map(s => s.trim()).filter(s => s);
    return {
        layouts: layouts,
        index: Math.max(0, Math.min(layouts.length - 1, k.active_layout_index || 0)),
        name: k.active_keymap || "",
        capsLock: k.capsLock === true,
    };
}

// Label of the input source item: "ABC" for the plain US layout (the name macOS gives its default Latin
// input source, as on the 27.2.1 lock screen, A7), else the xkb layout code in upper case ("de(neo)" -> "DE").
function layoutLabel(kb) {
    if (!kb || kb.layouts.length === 0) return "";
    const l = kb.layouts[kb.index];
    return l === "us" ? "ABC" : l.replace(/\(.*$/, "").toUpperCase();
}

// Wrong-password shake (LOCKSCREEN-27.2.1.md B2): offset in pt at `t` seconds, 0 outside 0..0.4 s.
// dx = -A sin(2 pi 7.5 t): three cycles, first move to the left; A steps at the half-cycle zero crossings,
// 14 pt before 0.2 s, 8.25 pt to 0.333 s, then 6.75 pt.
const SHAKE_HZ = 7.5, SHAKE_DUR = 0.4;
function shakeAmp(t) { return t < 0.2 ? 14 : t < 1 / 3 ? 8.25 : 6.75; }
function shake(t) {
    if (!(t > 0) || t >= SHAKE_DUR) return 0;
    return -shakeAmp(t) * Math.sin(2 * Math.PI * SHAKE_HZ * t);
}
// The same curve as keyframes for a declarative animation: one {to, ms, out} per quarter cycle, `out` true
// when it runs from 0 to a peak (OutSine) and false from a peak back to 0 (InSine), both exact sine arcs.
function shakeKeys() {
    const q = 1 / (4 * SHAKE_HZ), keys = [];
    let used = 0;
    for (let k = 0; k < 12; k++) {
        const mid = (Math.floor(k / 2) + 0.5) * 2 * q;          // peak time of this half cycle
        const to = k % 2 === 0 ? shake(mid) : 0;
        const end = Math.round((k + 1) * q * 1000);
        keys.push({ to: to, ms: end - used, out: k % 2 === 0 });
        used = end;
    }
    return keys;
}
