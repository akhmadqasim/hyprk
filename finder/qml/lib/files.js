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

// Get Info's subject: the first selected item, else the folder itself (the Mac's Cmd-I with nothing selected)
function infoTarget(selection, folder) { return selection && selection.length > 0 ? selection[0].path : folder; }

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

// Window title: the folder name, "/" shows as the disk name, the freedesktop trash's files folder (`trash`, when
// given) as "Trash" (its own name is "files").
function title(p, trash) {
    const n = normalize(p);
    if (n === "/") return "Macintosh HD";
    if (trash && n === normalize(trash)) return "Trash";
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

// List view disclosure (Q-finder-15): `expanded` maps a folder path to its raw children; each open folder's
// children follow it, sorted by sortFn, as copies with depth = parent depth + 1 (top level has no depth).
function flattenTree(entries, expanded, sortFn, depth) {
    const d = depth || 0;
    const out = [];
    for (const e of entries) {
        out.push(d ? Object.assign({}, e, { depth: d }) : e);
        const kids = expanded && expanded[e.path];
        if (e.isDir && kids) for (const k of flattenTree(sortFn ? sortFn(kids) : kids, expanded, sortFn, d + 1)) out.push(k);
    }
    return out;
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

function hasTags(entry) { return !!entry.tags && entry.tags.length > 0; }

// Finder's tag dots (Q-finder-14): 10 pt circles, each extra tag 5 pt to the right and behind the previous one,
// with a 0.5 pt ring in `ring`; `gap` pt of space after them. An SVG data URL `width` x 10 pt.
function tagDotsWidth(n, gap) { return n > 0 ? 10 + 5 * (n - 1) + (gap || 0) : 0; }
function tagDotsUrl(tags, colors, ring, gap, top) {
    const n = tags.length, w = tagDotsWidth(n, gap), t = top || 0, h = 10 + Math.ceil(t);
    let c = "";
    for (let i = n - 1; i >= 0; i--)
        c += '<circle cx="' + (5 + 5 * i) + '" cy="' + (5 + t) + '" r="4.75" fill="' + (colors[tags[i]] || colors.Gray)
           + '" stroke="' + ring + '" stroke-width="0.5"/>';
    return "data:image/svg+xml;utf8," + encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" width="' + w
           + '" height="' + h + '" viewBox="0 0 ' + w + ' ' + h + '">' + c + "</svg>");
}

// Name with the tag dots in front, 3 pt before the text, as StyledText. Use it only when hasTags(entry); plain
// names stay PlainText. Runs of spaces are kept with &nbsp;. colors: tag name -> CSS color (unknown: Gray).
// The image hangs from the line top (align="middle" grew the line: tagged labels sat 2.5 pt low, icons-light.png),
// its dots 1.5 pt down: dot rows 278..297 px at 2x like the Mac's, the text on the untagged labels' rows.
function styledName(entry, colors, ring) {
    const tags = entry.tags || [];
    return '<img src="' + tagDotsUrl(tags, colors, ring || "white", 3, 1.5) + '" width="' + tagDotsWidth(tags.length, 3)
         + '" height="12" align="top">' + escapeHtml(entry.name).replace(/ (?= )/g, "&nbsp;");
}

// ---------- layout ----------

// Icon view columns: fixed cells (no stretching), at least one (Q-finder-12).
function gridColumns(width, cell, pad) { return Math.max(1, Math.floor((width - 2 * pad) / cell)); }

// Indices whose hit box meets the rubber band `r` ({x, y, width, height}, content coords). Cells are `cell`
// square from (pad, 0); the hit box is `boxW` wide, centred, from `boxTop` to `boxBottom` in the cell.
function gridHits(r, count, columns, cell, pad, boxW, boxTop, boxBottom) {
    const hits = [];
    const first = Math.max(0, Math.floor((r.y - boxBottom) / cell) * columns);
    const last = Math.min(count, (Math.floor((r.y + r.height - boxTop) / cell) + 1) * columns);
    for (let i = first; i < last; i++) {
        const x = pad + (i % columns) * cell + (cell - boxW) / 2;
        const y = Math.floor(i / columns) * cell;
        if (x < r.x + r.width && x + boxW > r.x && y + boxTop < r.y + r.height && y + boxBottom > r.y)
            hits.push(i);
    }
    return hits;
}

// List view column widths: Name takes what Date Modified, Size and Kind leave (default 338 in a 737 row).
function listColumns(width, pad, date, size, kind) {
    return [Math.max(160, width - 2 * pad - date - size - kind), date, size, kind];
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
    // KB without decimals ("8 KB", "12 KB"), one decimal from MB up ("12.3 MB") (Q-finder-18)
    const s = u === 0 ? String(Math.round(v)) : (Math.round(v * 10) / 10).toFixed(1).replace(/\.0$/, "");
    return s + " " + units[u];
}

const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

function pad2(n) { return n < 10 ? "0" + n : String(n); }

// "Today at 14:03", "Yesterday at 09:12", "3 Nov 2026 at 18:00".
// Preview / inspector form (Q-finder-18): "5 March 2026 at 09:12", "Yesterday, 14:30", "Today, 09:05".
const monthsLong = ["January", "February", "March", "April", "May", "June", "July", "August", "September",
                    "October", "November", "December"];
function formatDateLong(ms, nowMs) {
    const d = new Date(ms), now = new Date(nowMs === undefined ? Date.now() : nowMs);
    const time = pad2(d.getHours()) + ":" + pad2(d.getMinutes());
    const day0 = x => new Date(x.getFullYear(), x.getMonth(), x.getDate()).getTime();
    const diff = Math.round((day0(now) - day0(d)) / 86400000);
    if (diff === 0) return "Today, " + time;
    if (diff === 1) return "Yesterday, " + time;
    return d.getDate() + " " + monthsLong[d.getMonth()] + " " + d.getFullYear() + " at " + time;
}

function formatDate(ms, nowMs) {
    const d = new Date(ms), now = new Date(nowMs === undefined ? Date.now() : nowMs);
    const time = pad2(d.getHours()) + ":" + pad2(d.getMinutes());
    const day0 = x => new Date(x.getFullYear(), x.getMonth(), x.getDate()).getTime();
    const diff = Math.round((day0(now) - day0(d)) / 86400000);
    if (diff === 0) return "Today at " + time;
    if (diff === 1) return "Yesterday at " + time;
    return d.getDate() + " " + months[d.getMonth()] + " " + d.getFullYear() + " at " + time;
}
