// Menu bar clock in macOS format, following the time locale like macOS:
// en_US "Tue Nov 10  4:34 AM", 24h day-first locales "Tue 10 Nov  04:34".
.pragma library

const DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

function pad(n) { return n < 10 ? "0" + n : String(n); }

// Locales that use a 12-hour clock (language_REGION, POSIX names without encoding)
const TWELVE_HOUR = ["en_US", "en_CA", "en_AU", "en_NZ", "en_PH", "en_IN", "es_US", "es_MX", "hi_IN",
                     "ar_SA", "ar_EG", "ko_KR", "zh_TW", "bn_BD", "ur_PK"];
// Locales that write the month before the day
const MONTH_FIRST = ["en_US", "en_CA", "en_PH", "es_US", "zh_TW", "ko_KR"];

// clock style for a locale string like "en_US.UTF-8"; unknown or C/POSIX -> 24h, day first
function styleFor(locale) {
    const name = String(locale || "").split(".")[0].split("@")[0];
    return { use24h: TWELVE_HOUR.indexOf(name) === -1, monthFirst: MONTH_FIRST.indexOf(name) !== -1 };
}

// opts: { use24h (default true), monthFirst (default false), seconds (default false) }
function format(d, opts) {
    const o = opts || {};
    const h24 = o.use24h !== false;
    let h = d.getHours();
    let suffix = "";
    if (!h24) {
        suffix = h < 12 ? " AM" : " PM";
        h = h % 12 || 12;
    }
    const time = (h24 ? pad(h) : String(h)) + ":" + pad(d.getMinutes()) + (o.seconds ? ":" + pad(d.getSeconds()) : "") + suffix;
    const date = o.monthFirst ? MONTHS[d.getMonth()] + " " + d.getDate() : d.getDate() + " " + MONTHS[d.getMonth()];
    return DAYS[d.getDay()] + " " + date + "  " + time;
}

// Notification timestamps: "now", "5m ago", "2h ago", then weekday.
function relative(then, now) {
    const s = Math.max(0, Math.floor((now - then) / 1000));
    if (s < 60) return "now";
    if (s < 3600) return Math.floor(s / 60) + "m ago";
    if (s < 86400) return Math.floor(s / 3600) + "h ago";
    return DAYS[new Date(then).getDay()];
}
