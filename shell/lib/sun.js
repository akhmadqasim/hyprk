.pragma library
// Appearance > Auto for the shell: the same rule and the same code as Settings (settings/Parsers.js "Appearance >
// Auto", decoded from SkyLight / GeoServices 27.2.1: the theme is light while the sun at the time zone's city is at
// or above -3 degrees). A copy, because the shell cannot import files outside its root; shell/tests/run.mjs checks
// that both give the same answers.
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
