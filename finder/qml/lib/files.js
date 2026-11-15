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

// Returns "" when newName is acceptable, else a user-facing message: Finder's own (LocalizableMerged.strings RN5,
// RN31, NE74, RN17). The empty-name line has no Mac string (what Finder does was not checked).
// existing: names already in the folder; original: the item's current name.
function validateName(newName, existing, original) {
    if (newName === original) return "";
    if (newName.trim() === "") return "Please enter a name.";
    if (newName === "." || newName === "..") return "The name “" + newName + "” can’t be used because it’s reserved by the system.";
    if (newName.indexOf("/") !== -1 || newName.indexOf("\0") !== -1) return "The name “" + newName + "” can’t be used.";
    if (utf8Length(newName) > 255) return "The name “" + newName + "” can’t be used because it’s too long.";
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

// ---------- macOS 27.2.1 document icons (reference/re/27.2.1/ICONS-REA-27.2.1.md part 2) ----------
// IconServices composes a document icon at run time (-[ISDocumentRecipe layerTreeForSize:scale:] 0x1975ef824): the
// page, the type's symbol or background, the extension text, the page fold. themes/icons/tools/build-docs.py builds
// the art without the text (icons/doc-<kind>@<pt>pt.png); docText() places the text the way IconServices does.
// Kinds: the ISDocumentIconConfiguration.ISSymbolName of the type (or of the first type it conforms to with icons) in
// CoreTypes.bundle's Info.plist; "txtfill" = public.text's UTTypeIconBackgroundName txt-fill. Linux has MIME types,
// not UTIs: the extension picks the type where the Mac declares one, the MIME top level otherwise (every Mac audio,
// movie and image type conforms to public.audio / public.movie / public.image). "txt", "zip" and "pdf" are the Mac's
// own renders (live/finder/icons-rendered), text included.
const docByExt = {
    txt: "txt", text: "txt", zip: "zip", pdf: "pdf",
    docx: "justify", xlsx: "table", csv: "table", pptx: "chart", html: "code", htm: "code",
};
function macDocKind(entry) {
    if (entry.isDir) return "";
    const m = entry.mime || "", ext = splitName(entry.name || "", false).ext.toLowerCase();
    if (m === "application/x-desktop") return "";
    if (docByExt[ext]) return docByExt[ext];
    if (m.indexOf("audio/") === 0) return "audio";
    if (m.indexOf("video/") === 0) return "video";
    if (m.indexOf("image/") === 0) return "image";
    if (isText(entry)) return "txtfill";
    return "";
}
// the art holds its own text (the Mac's renders)
function macDocHasText(kind) { return kind === "txt" || kind === "zip" || kind === "pdf"; }

// ISHintedRect / ISHintedFloat (-[ISHintedRect hintedRectForSize:options:] 0x1975f9fd4, options 5): the first entry
// >= s, linear from the one before, scaled by s / edge outside the table; rects rounded to 0.5, floats not
function hinted(table, s, half) {
    const keys = Object.keys(table).map(Number).sort((a, b) => a - b);
    const at = k => [].concat(table[k]);
    let r;
    if (s <= keys[0]) r = at(keys[0]).map(v => v * s / keys[0]);
    else if (s >= keys[keys.length - 1]) r = at(keys[keys.length - 1]).map(v => v * s / keys[keys.length - 1]);
    else {
        const i = keys.findIndex(k => k >= s), a = keys[i - 1], b = keys[i], f = (s - a) / (b - a);
        r = at(a).map((v, j) => v + (at(b)[j] - v) * f);
    }
    return half ? r.map(v => Math.round(v * 2) / 2) : r;
}
// the macOS branch of ISDocumentRecipe's tables (points; x, y from the bottom of the paper rect)
const docPaper = { 16: [3, 1, 10, 14], 32: [5, 2, 22, 28], 128: [23, 9, 82, 110], 256: [46, 18, 166, 220], 512: [92, 37, 327, 438] };
const docTextRect = { 32: [1, 1, 20, 1], 128: [9, 8, 64, 17], 256: [16, 17, 132, 33], 512: [33, 31, 261, 60] };
const docTextFont = { 128: 16.5, 256: 33, 512: 60 };
// The extension text of a document icon `s` pt big: null at 32 pt and below (the recipe adds no text layer), else
// { x, w: the text rect from the icon's left, baseline: from the icon's top, size: font pt }. The text is the system
// font, regular (CTFontCreateUIFontForLanguage kCTFontUIFontSystem), centred on the rect, its glyph bottom on the
// rect's bottom, scaled to w - 6 when wider (-[IFGraphicsContext drawText:fontName:fontSize:inRect:] 0x19753d5d0);
// colour CUIDesignLibrary 17, measured 182 grey on the Mac's renders (Theme / the caller)
function docText(s) {
    if (s <= 32) return null;
    const p = hinted(docPaper, s, true), t = hinted(docTextRect, s, true);
    return { x: p[0] + t[0], w: t[2], baseline: s - (p[1] + t[1]), size: hinted(docTextFont, s, false)[0] };
}
// the text: UTTypeIconText, else the file's own extension, uppercased (-[ISRecordResourceProvider
// _findTextResourceWithIconDictionary:] 0x1975cd2c4)
function docTextFor(entry) { return splitName(entry.name || "", !!entry.isDir).ext.toUpperCase(); }

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

// Sidebar right-click menu (Finder 27.2.1, -[TContextMenu configureForSidebar:...] 0x1004204cc builds context 8 from the
// command table FUN_10081f3f0 at 0x100c15450: the rows whose context mask has bit 8, in table order; separators are
// table rows too and _setCondensesSeparators: drops leading, trailing and doubled ones). The context-8 rows: Open
// (titled "Open in New Tab" in a browser window: N151.1, the ⌥ alternate "Open in New Window" N151.3 not built), Open
// With, Screen Share, Show in Enclosing Folder (N162), Show "x" (file providers), Download Now, Remove Download, —,
// Eject "x" (N57), —, Erase / Format, —, Encrypt "x"…, Remove from Sidebar (N169.2), Delete Tag "x" (TG16_V2), backups,
// —, Get Info (N165), Manage Storage…, Back Up Now, Change Wallpaper…, Edit Widgets…, Rename "x" (cmdRenameInSidebar:
// N169.6), Add to Dock (N169.13), search slices, —, Share (N166), Manage Shared…, —, tags, —, plug-ins. Which rows
// stay for which kind of item is Finder's validation (hidden when invalid: TContextMenuItem showMeAnyway); it was not
// decoded per kind, so the per-kind lists below are GUESS from what each command applies to. No icons: none of these
// rows has the table's image flag (+0x2c). The tag colour row is left out as in the item menu (Main.qml contextMenu).
// kind: "folder" (a Favorites folder), "virtual" (Recents, Shared, iCloud Drive, AirDrop), "trash",
// "volume", "tag"; opens: the row goes somewhere (Open in New Tab), real: a folder on disk (Show in Enclosing Folder,
// Get Info; Applications is the virtual "applications:" here). Rows: { text, id, enabled } or { separator: true }.
// ids: newtab enclosing info.
function sidebarMenu(kind, name, opens, real) {
    const sep = { separator: true };
    const row = (text, id, enabled) => ({ text: text, id: id || "", enabled: !!enabled });
    const q = "“" + name + "”";
    const tab = row("Open in New Tab", "newtab", opens);
    if (kind === "tag")
        return [tab, sep, row("Remove from Sidebar"), row("Delete Tag " + q), sep, row("Rename " + q)];
    if (kind === "volume")
        return [tab, sep, row("Eject " + q), sep, row("Get Info", "info", real), row("Rename " + q)];
    if (kind === "trash")
        return [tab];
    if (kind === "virtual")
        return [tab, sep, row("Remove from Sidebar")];
    // Favorites folder: the system folders cannot be renamed, so no Rename row (validateRenameInSidebar: GUESS)
    return [tab, row("Show in Enclosing Folder", "enclosing", real), sep, row("Remove from Sidebar"), sep,
            row("Get Info", "info", real), row("Add to Dock"), sep, row("Share")];
}

// ---- gallery (MAC-ANSWERS-9 R9.2-R9.3) ----
// The strip's new contentX after the selection moves to `index`: it jumps (no animation) by the least amount that
// keeps the selected plate `margin` pt inside the visible strip (`view` pt wide), clamped to [minX, maxX]. Plates
// start at content x index * pitch (the ListView's leftMargin holds the 5 pt inset). Mac clip, 316 pt strip: steps
// 46, 59, 56 pt going right; going left nothing until the plate nears the left edge.
function galleryScroll(contentX, index, view, minX, maxX, pitch, plate, margin) {
    const left = index * pitch, right = left + plate;
    let x = contentX;
    if (right + margin > x + view) x = right + margin - view;
    if (left - margin < x) x = left - margin;
    return Math.max(minX, Math.min(Math.max(minX, maxX), x));
}
// "Show More" sits on the Information row for images and PDFs; a folder or a text file has none (R9.2)
function galleryShowMore(entry) {
    if (!entry || entry.isDir) return false;
    return isImage(entry) || iconClass(entry) === "pdf";
}
// The Dimensions row value, "1600×1067"; "" without a size
function formatDimensions(w, h) { return w > 0 && h > 0 ? w + "×" + h : ""; }
