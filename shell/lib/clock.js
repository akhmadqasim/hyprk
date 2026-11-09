// Menu bar clock in macOS format: "Tue 10 Nov  02:55" (24h, en locale names).
.pragma library

const DAYS = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
const MONTHS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

function pad(n) { return n < 10 ? "0" + n : String(n); }

// opts: { use24h (default true), seconds (default false) }
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
    return DAYS[d.getDay()] + " " + d.getDate() + " " + MONTHS[d.getMonth()] + "  " + time;
}

// Notification timestamps: "now", "5m ago", "2h ago", then weekday.
function relative(then, now) {
    const s = Math.max(0, Math.floor((now - then) / 1000));
    if (s < 60) return "now";
    if (s < 3600) return Math.floor(s / 60) + "m ago";
    if (s < 86400) return Math.floor(s / 3600) + "h ago";
    return DAYS[new Date(then).getDay()];
}
