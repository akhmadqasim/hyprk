// Lock screen logic without Qt: clock and date text, user name, initials, notification filter,
// keyboard state from `hyprctl devices -j`, and the wrong-password shake curve.
// Tested by shell/tests/run.mjs.
.pragma library

const DAYS = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
const MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September",
                "October", "November", "December"];

function pad(n) { return n < 10 ? "0" + n : String(n); }

// Large clock: "4:24" with a 12-hour locale (no AM/PM), "16:24" / "9:05" with 24 hours.
// Guessed from hyprlock.conf, waiting for Q-lockscreen-04.
function time(d, use24h) {
    const h = d.getHours();
    return (use24h ? String(h) : String(h % 12 || 12)) + ":" + pad(d.getMinutes());
}

// Date line: "Tuesday, November 10" (month first) or "Tuesday 10 November". Waiting for Q-lockscreen-05.
function date(d, monthFirst) {
    return monthFirst ? DAYS[d.getDay()] + ", " + MONTHS[d.getMonth()] + " " + d.getDate()
                      : DAYS[d.getDay()] + " " + d.getDate() + " " + MONTHS[d.getMonth()];
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

// Short label for the input source item: the xkb layout code, upper case ("us" -> "US", "de(neo)" -> "DE").
function layoutLabel(kb) {
    if (!kb || kb.layouts.length === 0) return "";
    return kb.layouts[kb.index].replace(/\(.*$/, "").toUpperCase();
}

// Wrong-password shake: horizontal offset at progress t (0..1) for amplitude `amp`, `cycles` full
// swings and a decay exponent; starts and ends at 0. Guessed curve, waiting for Q-lockscreen-12.
function shake(t, amp, cycles, decay) {
    if (t <= 0 || t >= 1) return 0;
    return amp * Math.sin(2 * Math.PI * cycles * t) * Math.pow(1 - t, decay);
}
