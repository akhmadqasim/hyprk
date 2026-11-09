// Pure helpers for the Finder UI: paths, sorting, naming, formatting.
// No QML types here so tests/run.mjs can load this file in node.
.pragma library

// ---------- paths ----------

function normalize(p) {
    if (!p) return "/";
    const out = [];
    for (const part of p.split("/")) {
        if (part === "" || part === ".") continue;
        if (part === "..") out.pop();
        else out.push(part);
    }
    return "/" + out.join("/");
}

function parentPath(p) {
    const n = normalize(p);
    if (n === "/") return "/";
    return n.slice(0, n.lastIndexOf("/")) || "/";
}

function joinPath(dir, name) {
    return normalize(dir + "/" + name);
}

function baseName(p) {
    const n = normalize(p);
    return n === "/" ? "/" : n.slice(n.lastIndexOf("/") + 1);
}

// file:// URL with each segment percent-encoded ("#" or "%" in names would break a raw URL).
function fileUrl(p) {
    return "file://" + normalize(p).split("/").map(encodeURIComponent).join("/");
}

// Path bar segments from the root: [{name, path}, ...]. The root shows as rootName.
function segments(p, rootName) {
    const n = normalize(p);
    const out = [{ name: rootName || "/", path: "/" }];
    if (n === "/") return out;
    let acc = "";
    for (const part of n.slice(1).split("/")) {
        acc += "/" + part;
        out.push({ name: part, path: acc });
    }
    return out;
}

// Window title: the folder name, "/" shows as the disk name.
function title(p) {
    const n = normalize(p);
    if (n === "/") return "Macintosh HD";
    return baseName(n);
}

// ---------- sorting ----------

// Finder-style natural order: case-insensitive, digit runs compared by value ("File 2" < "File 10").
function naturalCompare(a, b) {
    const ax = String(a).toLowerCase(), bx = String(b).toLowerCase();
    let i = 0, j = 0;
    while (i < ax.length && j < bx.length) {
        const ca = ax.charCodeAt(i), cb = bx.charCodeAt(j);
        const da = ca >= 48 && ca <= 57, db = cb >= 48 && cb <= 57;
        if (da && db) {
            let ie = i, je = j;
            while (ie < ax.length && ax.charCodeAt(ie) >= 48 && ax.charCodeAt(ie) <= 57) ie++;
            while (je < bx.length && bx.charCodeAt(je) >= 48 && bx.charCodeAt(je) <= 57) je++;
            const na = ax.slice(i, ie).replace(/^0+/, ""), nb = bx.slice(j, je).replace(/^0+/, "");
            if (na.length !== nb.length) return na.length - nb.length;
            if (na !== nb) return na < nb ? -1 : 1;
            i = ie; j = je;
            continue;
        }
        if (ca !== cb) return ca - cb;
        i++; j++;
    }
    const rest = (ax.length - i) - (bx.length - j);
    if (rest !== 0) return rest;
    return a < b ? -1 : a > b ? 1 : 0; // stable tie-break on original case
}

// key: name | modified | size | kind. Non-name keys fall back to name order on ties.
function sortEntries(entries, key, ascending, foldersFirst) {
    const dir = ascending === false ? -1 : 1;
    const byName = (x, y) => naturalCompare(x.name, y.name);
    const cmp = {
        name: byName,
        modified: (x, y) => (x.modified - y.modified) || byName(x, y),
        size: (x, y) => (x.size - y.size) || byName(x, y),
        kind: (x, y) => naturalCompare(x.kind || "", y.kind || "") || byName(x, y),
    }[key] || byName;
    return entries.slice().sort((x, y) => {
        if (foldersFirst && x.isDir !== y.isDir) return x.isDir ? -1 : 1;
        return dir * cmp(x, y);
    });
}

function filterEntries(entries, query) {
    const q = (query || "").trim().toLowerCase();
    if (!q) return entries;
    return entries.filter(e => e.name.toLowerCase().indexOf(q) !== -1);
}

// ---------- names ----------

// {base, ext} where ext excludes the dot. Dotfiles and folders have no extension.
function splitName(name, isDir) {
    const dot = name.lastIndexOf(".");
    if (isDir || dot <= 0 || dot === name.length - 1) return { base: name, ext: "" };
    return { base: name.slice(0, dot), ext: name.slice(dot + 1) };
}

// Returns "" when newName is acceptable, else a user-facing message.
// existing: names already in the folder; original: the item's current name.
function validateName(newName, existing, original) {
    if (newName === original) return "";
    if (newName.trim() === "") return "Please enter a name.";
    if (newName === "." || newName === "..") return "The name “" + newName + "” is reserved.";
    if (newName.indexOf("/") !== -1) return "Names can’t contain “/”.";
    if (newName.indexOf("\0") !== -1) return "Names can’t contain a null character.";
    if (utf8Length(newName) > 255) return "The name is too long.";
    const lower = newName.toLowerCase();
    for (const n of existing || []) {
        if (n === original) continue;
        if (n === newName) return "The name “" + newName + "” is already taken. Please choose a different name.";
        if (n.toLowerCase() === lower && original.toLowerCase() !== lower)
            return "The name “" + newName + "” is already taken. Please choose a different name.";
    }
    return "";
}

// UTF-8 byte length without TextEncoder (not available in QML's JS engine).
function utf8Length(s) {
    let n = 0;
    for (const ch of s) {
        const c = ch.codePointAt(0);
        n += c < 0x80 ? 1 : c < 0x800 ? 2 : c < 0x10000 ? 3 : 4;
    }
    return n;
}

// ---------- icons ----------

const imageExt = ["png", "jpg", "jpeg", "gif", "webp", "bmp", "svg", "ico", "tif", "tiff", "avif"];

function isImage(entry) {
    if (entry.isDir) return false;
    if ((entry.mime || "").indexOf("image/") === 0) return true;
    return imageExt.indexOf(splitName(entry.name).ext.toLowerCase()) !== -1;
}

function isText(entry) {
    if (entry.isDir) return false;
    const m = entry.mime || "";
    return m.indexOf("text/") === 0 || /json|xml|javascript|x-shellscript|toml|yaml|x-desktop/.test(m);
}

// Which drawn icon to use when there is no thumbnail.
function iconClass(entry) {
    if (entry.isDir) return "folder";
    const m = entry.mime || "";
    if (m === "application/x-desktop") return "app";
    if (m.indexOf("image/") === 0) return "image";
    if (m.indexOf("video/") === 0) return "video";
    if (m.indexOf("audio/") === 0) return "audio";
    if (m === "application/pdf") return "pdf";
    if (/zip|tar|compressed|x-7z|x-rar|x-xz|gzip|bzip/.test(m)) return "archive";
    if (isText(entry)) return "text";
    return "document";
}

// Short uppercase badge printed on the generic document icon ("ZIP", "PDF").
function badge(entry) {
    const ext = splitName(entry.name, entry.isDir).ext;
    return ext.length > 0 && ext.length <= 4 ? ext.toUpperCase() : "";
}

// ---------- tags ----------

function escapeHtml(s) {
    return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

// Name as StyledText with Finder's colored tag dots in front ("● ● name").
// colors: tag name -> CSS color; unknown tags use colors.Gray.
function styledName(entry, colors) {
    let dots = "";
    for (const t of entry.tags || [])
        dots += '<font color="' + (colors[t] || colors.Gray) + '">\u25CF</font>';
    return (dots ? dots + " " : "") + escapeHtml(entry.name);
}

// ---------- formatting ----------

// Finder uses decimal units.
function formatSize(bytes, isDir) {
    if (isDir || bytes < 0) return "--";
    if (bytes === 0) return "Zero bytes";
    if (bytes < 1000) return bytes + (bytes === 1 ? " byte" : " bytes");
    const units = ["KB", "MB", "GB", "TB"];
    let v = bytes, u = -1;
    do { v /= 1000; u++; } while (v >= 999.5 && u < units.length - 1);
    const s = v < 10 ? (Math.round(v * 10) / 10).toFixed(1).replace(/\.0$/, "") : String(Math.round(v));
    return s + " " + units[u];
}

const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

function pad2(n) { return n < 10 ? "0" + n : String(n); }

// "Today at 14:03", "Yesterday at 09:12", "3 Nov 2026 at 18:00".
function formatDate(ms, nowMs) {
    const d = new Date(ms), now = new Date(nowMs === undefined ? Date.now() : nowMs);
    const time = pad2(d.getHours()) + ":" + pad2(d.getMinutes());
    const day0 = x => new Date(x.getFullYear(), x.getMonth(), x.getDate()).getTime();
    const diff = Math.round((day0(now) - day0(d)) / 86400000);
    if (diff === 0) return "Today at " + time;
    if (diff === 1) return "Yesterday at " + time;
    return d.getDate() + " " + months[d.getMonth()] + " " + d.getFullYear() + " at " + time;
}
