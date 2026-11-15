// Spotlight browse modes (macOS 26/27: Cmd+1 Apps, Cmd+2 Files, Cmd+3 Actions, Cmd+4 Clipboard),
// file search helpers, actions + quick keys, clipboard history helpers.
// Pure JS (no Qt), unit tested by tests/run.mjs.
.pragma library

// ---------- modes ----------
// symbol: the glyph in the mode list and at the left of the field; placeholder: the field text while the mode is
// active, the mode's name (27.2.1, MAC-ANSWERS.md Q-panels-22, -24). Glyphs on the Mac (r17 spotlight-modelist-*.png):
// the App Store "A", the outline folder ("sf:folder": plain "folder" is the hyprk alias of folder.fill), two stacked
// rounded squares = the private symbol app.2.stack.3d (its .fill is named in SpotlightUIServices 27.2.1, 0x21325b7ac;
// the public square.2.layers.3d has pointed corners, the still has round ones) and two outline documents =
// document.on.document (named in SpotlightUIShared, 0x22f1ba010). Both decoded from CoreGlyphs(Private) 27.2.1 with
// themes/icons/tools/add-sf.py.
const MODES = [
    { id: "apps", title: "Applications", placeholder: "Applications", symbol: "appstore" },
    { id: "files", title: "Files", placeholder: "Files", symbol: "sf:folder" },
    { id: "actions", title: "Actions", placeholder: "Actions", symbol: "app.2.stack.3d" },
    { id: "clipboard", title: "Clipboard", placeholder: "Clipboard", symbol: "document.on.document" },
];
function modes() { return MODES; }
function modeInfo(id) { return MODES.find(m => m.id === id) || null; }

// Cmd+1..4 (Super in hyprk), with Ctrl/Alt+1..4 for nested sessions where the host keeps Super.
// key: Qt key code (Qt.Key_1 = 0x31); returns a mode id or "".
function modeForKey(key, meta, ctrl, alt) {
    if (!(meta || ctrl || alt)) return "";
    const i = key - 0x31;
    return i >= 0 && i < MODES.length ? MODES[i].id : "";
}

// ---------- inline completion ----------
// The top hit completes the query in the field (27.2.1, r17 spotlight-typed-*.png: "calc" then "ulator — Open" on the
// completion pill): the rest of the name when the name begins with what is typed (case ignored), then what Return does.
// "" when the query is empty, ends in a space the name does not have, or the name does not begin with it.
// actionOnly (Applications, apps-typed-cal-*.png: "cal" then " — Open"): the action without the name's rest.
function completion(query, name, actionOnly) {
    if (actionOnly) return " \u2014 Open";
    if (!query || !name || name.length < query.length) return "";
    if (name.slice(0, query.length).toLowerCase() !== query.toLowerCase()) return "";
    return name.slice(query.length) + " \u2014 Open";
}

// ---------- reopening ----------
// The query survives a close for 8 minutes: SearchViewController.startClearTimer, logged as "clearing for 8 min
// timer" (SpotlightUIInternal 27.2.1, 0x2adf66460); MAC-ANSWERS.md R2: "Reopening soon keeps the last query".
// (Holding Command: SearchViewController's commandKeyHintTimer, 0.35 s, 0x2adf7cf18, shows shortcut indicators
// whose target is not traced; no Mac capture shows the mode list on a Command hold, so hyprk shows nothing.)
const KEEP_QUERY_MS = 8 * 60e3;
function keepsQuery(closedAt, now) { return closedAt > 0 && now - closedAt < KEEP_QUERY_MS; }

// Command shortcuts of the bar: KeyboardHandlingBackdropView.KeyboardShortcut (SpotlightUIInternal 27.2.1,
// sub_2adf2fdbc). Only with Command alone (deviceIndependentFlags == 0x100000): key codes 18-21 (1-4) pick a browse
// mode, 29 (0) clears it; characters Return / "\n" and r reveal the selected item, i Get Info, b web search, d and l
// the dictionary result, y Quick Look, k the Wikipedia result, "," Spotlight settings, h Spotlight help.
// key: Qt key code; returns "" when it is not one of them.
function commandForKey(key) {
    switch (key) {
    case 0x30: return "clear";
    case 0x01000004: case 0x01000005: case 0x52: return "reveal";      // Return, Enter, R
    case 0x49: return "info";
    case 0x42: return "web";
    case 0x44: case 0x4c: return "dictionary";
    case 0x59: return "quicklook";
    case 0x4b: return "wikipedia";
    case 0x2c: return "settings";
    case 0x48: return "help";
    case 0x43: return "copy";       // Cmd-C: not in the decoded table (SearchUI's own handler, not traced)
    }
    return "";
}

// Cmd-B / Cmd-K (performWebSearch, openWikipediaResult): the query in the default browser. The engine is the
// Mac's default (Google; Safari's search engine setting is not decoded), Wikipedia's search page for Cmd-K
function webSearchUrl(q) { return "https://www.google.com/search?q=" + encodeURIComponent(String(q || "").trim()); }
function wikipediaUrl(q) { return "https://en.wikipedia.org/wiki/Special:Search?search=" + encodeURIComponent(String(q || "").trim()); }
// our Finder on a file's folder with the file selected and one more option (--quicklook for Cmd-Y, --info for
// Cmd-I); [] for no file or a folder
function finderArgs(file, option) {
    if (!file || !file.path || file.isDir) return [];
    const cut = file.path.lastIndexOf("/");
    return [file.path.slice(0, cut) || "/", "--select", file.path.slice(cut + 1), option];
}
// Cmd-C on a result: a file's path, a calculation's answer, else the row's title
function copyText(row) {
    if (!row) return "";
    if (row.kind === "file" && row.file && row.file.path) return row.file.path;
    if (row.path) return row.path;
    return String(row.title || row.text || row.name || "");
}

// ---------- files ----------
// recently-used.xbel -> [{path, mime, modified}] newest first, file:// only, deduped
function parseXbel(text, limit) {
    const out = [], seen = new Set();
    const re = /<bookmark\s([^>]*)>([\s\S]*?)<\/bookmark>/g;
    let m;
    while ((m = re.exec(String(text || ""))) !== null) {
        const attrs = m[1];
        const href = /href="([^"]*)"/.exec(attrs);
        if (!href || !href[1].startsWith("file://")) continue;
        let path;
        try { path = decodeURIComponent(xmlUnescape(href[1]).slice(7)); } catch (e) { continue; }
        if (seen.has(path)) continue;
        seen.add(path);
        const mod = /(?:visited|modified)="([^"]*)"/.exec(attrs);
        const mime = /mime-type\s+type="([^"]*)"/.exec(m[2]);
        out.push({ path: path, mime: mime ? mime[1] : "", modified: mod ? Date.parse(mod[1]) || 0 : 0 });
    }
    out.sort((a, b) => b.modified - a.modified);
    return out.slice(0, limit || 50);
}
function xmlUnescape(s) {
    return s.replace(/&amp;/g, "&").replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, "\"").replace(/&apos;/g, "'");
}

// a path from a search tool (fd prints directories with a trailing "/") -> row data
function fileRow(line, home) {
    const isDir = line.length > 1 && line.endsWith("/");
    const path = isDir ? line.slice(0, -1) : line;
    const slash = path.lastIndexOf("/");
    let dir = slash > 0 ? path.slice(0, slash) : "/";
    if (home && (dir === home || dir.startsWith(home + "/"))) dir = "~" + dir.slice(home.length);
    return { path: path, name: path.slice(slash + 1), dir: dir, isDir: isDir };
}

// freedesktop icon name for a file (theme lookup; the row falls back to a doc glyph)
const EXT_ICONS = {
    pdf: "application-pdf", png: "image-x-generic", jpg: "image-x-generic", jpeg: "image-x-generic", gif: "image-x-generic",
    webp: "image-x-generic", svg: "image-svg+xml", heic: "image-x-generic", mp3: "audio-x-generic", flac: "audio-x-generic",
    ogg: "audio-x-generic", wav: "audio-x-generic", mp4: "video-x-generic", mkv: "video-x-generic", webm: "video-x-generic",
    mov: "video-x-generic", zip: "package-x-generic", gz: "package-x-generic", xz: "package-x-generic", tar: "package-x-generic",
    txt: "text-x-generic", md: "text-x-generic", json: "text-x-generic", doc: "x-office-document", docx: "x-office-document",
    odt: "x-office-document", xls: "x-office-spreadsheet", xlsx: "x-office-spreadsheet", ods: "x-office-spreadsheet",
    ppt: "x-office-presentation", pptx: "x-office-presentation", odp: "x-office-presentation", html: "text-html",
    sh: "text-x-script", py: "text-x-script", js: "text-x-script", deb: "package-x-generic",
};
function fileIcon(path, isDir, mime) {
    if (isDir) return "folder";
    // media and text: the generic icon (themes rarely have video-webm etc.), else the exact type
    const major = mime ? mime.split("/")[0] : "";
    if (["image", "audio", "video", "text"].indexOf(major) !== -1) return major + "-x-generic";
    if (mime) return mime.replace("/", "-");
    const dot = path.lastIndexOf(".");
    const ext = dot > path.lastIndexOf("/") ? path.slice(dot + 1).toLowerCase() : "";
    return EXT_ICONS[ext] || "text-x-generic";
}

// ---------- Files grid (Cmd-2) ----------
// The Files mode is the Apps panel's 844 x 520 grid (MAC-ANSWERS-17.md R17.3, r17 spotlight-mode-files-*.png; pt,
// panel-local, read off the 2x stills, the tiles are blurred there so +-2):
//   chips: 5 capsules 26 tall at y 20, x 20 .. 824, gap 8, all one width (154.4), fill +12, text SF 15 plus-lighter +125;
//   7 columns, centres 77 + 115 n (as Apps); a first row of files with icon centres at y 100 (icon box 60 from 70);
//   the header "Recents" at x 20, middle y 211; then rows with icon centres at 270, 395, 520 (pitch 125: the names
//   take two lines); the scroll knob 6 wide, 3 from the right edge, from y 102 (the grid scrolls under the chips).
// A query or a chip drops the chips, the first row and the header (as Apps does; not in the Mac's captures).
const FILES = {
    chips: 5, chipTop: 20, chipHeight: 26, chipGap: 8, inset: 20,
    topRow: 70, headerCY: 211, gridTop: 240, rowPitch: 125, plainTop: 20, labelLines: 2,
    viewTop: 62, knobInset: 40.5, knobWidth: 6, knobRight: 3,
};
function filesGrid() { return FILES; }
function filesChipWidth(panelWidth) { return (panelWidth - 2 * FILES.inset - (FILES.chips - 1) * FILES.chipGap) / FILES.chips; }

// what a Files chip filters by: the file's kind, from its MIME type ("" = no chip). The Mac's chips mix kinds (PDF,
// Music) and the apps that open the recent files (Preview, Microsoft Word, TextEdit); which it picks is not decoded,
// here they are the kinds of the recent files, most frequent first
function fileKind(isDir, mime) {
    if (isDir) return "Folders";
    const m = String(mime || "");
    if (m === "application/pdf") return "PDF";
    const major = m.split("/")[0];
    if (major === "image") return "Images";
    if (major === "audio") return "Music";
    if (major === "video") return "Movies";
    if (major === "text") return "Text";
    if (/zip|x-tar|x-7z|x-xz|gzip|x-rar|x-bzip/.test(m)) return "Archives";
    if (/presentation|powerpoint/.test(m)) return "Presentations";
    if (/spreadsheet|excel/.test(m)) return "Spreadsheets";
    if (/wordprocessing|msword|opendocument\.text|rtf/.test(m)) return "Documents";
    return "";
}
function fileChips(files, n) {
    const count = {}, order = [];
    for (const f of files || []) {
        const k = fileKind(f.isDir, f.mime);
        if (!k) continue;
        if (!(k in count)) { count[k] = 0; order.push(k); }
        count[k]++;
    }
    return order.map((k, i) => [k, i]).sort((a, b) => count[b[0]] - count[a[0]] || a[1] - b[1]).slice(0, n).map(x => x[0]);
}

// the overlay scroll knob of a list or grid: [y, length] in a track from `inset` to `view - inset` (r17
// spotlight-typed-*.png: 136 pt long from 40.5 in the 410 results panel), at least 26 long
function scrollKnob(view, content, offset, inset) {
    const track = view - 2 * inset;
    if (!(content > view) || track <= 0) return [0, 0];
    const len = Math.max(26, track * view / content);
    const at = Math.max(0, Math.min(1, offset / (content - view)));
    return [inset + (track - len) * at, len];
}

// a streamed line still belongs to the current query (lines of a killed search may arrive late)
function matchesQuery(path, query) {
    const q = String(query || "").trim().toLowerCase();
    if (!q) return false;
    const p = path.endsWith("/") ? path.slice(0, -1) : path;
    return p.slice(p.lastIndexOf("/") + 1).toLowerCase().includes(q);
}

// argv for the first available search tool. Hidden folders and caches are skipped (macOS
// Spotlight does not index ~/Library caches either). Results arrive one path per line.
function searchCommand(tool, query, home, limit) {
    const q = String(query).trim();
    const n = String(limit || 40);
    const skip = ["node_modules", ".cache", ".git", "target", "snap"];
    if (tool === "plocate" || tool === "locate")
        // whole-system database, file names only (-b): keep paths under $HOME, drop hidden and
        // skipped folders, stop after limit (head closes the pipe, which ends the search)
        return ["sh", "-c", `${tool} -b -i -- "$1" | awk -v h="$2/" 'index($0, h) == 1' | grep -v -E '/\\.|/(${skip.join("|")})/' | head -n "$3"`, "sh", q, home, n];
    if (tool === "fd" || tool === "fdfind")
        return [tool, "--ignore-case", "--fixed-strings", "--max-results", n, "--color", "never"]
            .concat(...skip.map(s => ["--exclude", s])).concat(["--", q, home]);
    // find: name match only, no hidden dirs, first `limit` hits
    return ["sh", "-c", `find "$2" -name '.*' -prune -o \\( -iname "*$1*" -printf '%p%y\\n' \\) 2>/dev/null | sed 's/d$/\\//; s/[a-z]$//' | head -n "$3"`,
            "sh", q.replace(/[*?[\]\\]/g, "\\$&"), home, n];
}

// recents first (filtered by the query), then search hits, no duplicates
function mergeFiles(recents, hits, query, limit) {
    const q = String(query || "").trim().toLowerCase();
    const out = [], seen = new Set();
    const add = r => { if (!seen.has(r.path)) { seen.add(r.path); out.push(r); } };
    for (const r of recents) if (!q || r.name.toLowerCase().includes(q)) add(r);
    for (const h of hits) add(h);
    return out.slice(0, limit || 50);
}

// ---------- actions + quick keys ----------
// quick key: 1-6 lowercase letters/digits (macOS uses short strings like "sm" for Send Message)
function normQuickKey(s) {
    const k = String(s || "").trim().toLowerCase();
    return /^[a-z0-9]{1,6}$/.test(k) ? k : "";
}
// quick keys: {actionId: key}; an exact quick key beats everything, then a key prefix,
// then the name score. score(entry, q) comes from search.js.
function rankActions(actions, query, quickKeys, score, limit) {
    const q = String(query || "").trim().toLowerCase();
    const keys = quickKeys || {};
    if (!q) return actions.slice(0, limit || actions.length);
    const out = [];
    for (const a of actions) {
        const k = keys[a.id] || "";
        let s = k && k === q ? 2000 : k && q.length > 0 && k.startsWith(q) ? 900 : 0;
        s = Math.max(s, score({ name: a.title, keywords: a.keywords || [], genericName: a.subtitle || "", id: a.id }, q));
        if (s > 0) out.push({ a: a, s: s });
    }
    out.sort((x, y) => y.s - x.s || x.a.title.localeCompare(y.a.title));
    return out.slice(0, limit || 50).map(r => r.a);
}
// action id whose quick key is exactly `query` (all-results mode puts it first)
function quickKeyAction(quickKeys, query) {
    const q = String(query || "").trim().toLowerCase();
    for (const id in quickKeys || {}) if (q && quickKeys[id] === q) return id;
    return "";
}
// badge text for an action row: its key in capitals, "Add Quick Keys" offered on the selected row
function quickKeyLabel(quickKeys, id, selected) {
    const k = (quickKeys || {})[id];
    return k ? k.toUpperCase() : selected ? "Add Quick Keys" : "";
}
// set / clear a key; a key moves away from any other action that had it
function setQuickKey(quickKeys, id, key) {
    const k = normQuickKey(key);
    const out = {};
    for (const a in quickKeys || {}) if (a !== id && quickKeys[a] !== k) out[a] = quickKeys[a];
    if (k) out[id] = k;
    return out;
}

// ---------- clipboard history ----------
// macOS 26.1 retention choices; "off" = history disabled (the default until the user turns it on)
const RETENTION = {
    "30m": { ms: 30 * 60e3, label: "30 Minutes" },
    "8h": { ms: 8 * 3600e3, label: "8 Hours" },
    "7d": { ms: 7 * 86400e3, label: "7 Days" },
};
function retentionMs(r) { return RETENTION[r] ? RETENTION[r].ms : 0; }
function retentionLabel(r) { return RETENTION[r] ? RETENTION[r].label : "Off"; }
// a line from scripts/clipboard.sh: "<path>\t<mime>\t<preview>"; file name is <ms>_<hash>.<ext>
// cliphist: "<id>\t<preview>"
function parseClipLine(line, cliphist) {
    const parts = String(line).split("\t");
    if (cliphist) {
        if (parts.length < 2 || !/^\d+$/.test(parts[0])) return null;
        const preview = parts.slice(1).join(" ");
        const bin = /^\[\[ binary data .* (png|jpe?g|gif|webp|bmp) /.exec(preview);
        return { id: parts[0], mime: bin ? "image/" + bin[1] : "text/plain", text: bin ? "" : preview, ts: 0, file: "" };
    }
    if (parts.length < 2) return null;
    const file = parts[0];
    const name = file.slice(file.lastIndexOf("/") + 1);
    const m = /^(\d+)_([0-9a-f]+)\./.exec(name);
    if (!m) return null;
    return { id: m[2], file: file, mime: parts[1], ts: parseInt(m[1]), text: parts.slice(2).join("\t") };
}
// add a new item on top, an identical one moves up (same hash)
function addClip(items, item, cap) {
    const out = [item].concat(items.filter(i => i.id !== item.id));
    return out.slice(0, cap || 200);
}
// items still inside the retention window (ts 0 = unknown, kept)
function pruneClips(items, now, ms) {
    if (!ms) return items;
    return items.filter(i => !i.ts || now - i.ts <= ms);
}
// when the oldest dated item expires (ms epoch), 0 = nothing to expire
function nextExpiry(items, ms) {
    let oldest = 0;
    for (const i of items) if (i.ts && (!oldest || i.ts < oldest)) oldest = i.ts;
    return ms && oldest ? oldest + ms : 0;
}
function filterClips(items, query) {
    const q = String(query || "").trim().toLowerCase();
    if (!q) return items;
    return items.filter(i => (i.text || "").toLowerCase().includes(q) || (q === "image" && i.mime.startsWith("image/")));
}
function clipTitle(item) {
    if (item.mime.startsWith("image/")) return "Image";
    const t = String(item.text || "").replace(/\s+/g, " ").trim();
    return t.length > 120 ? t.slice(0, 120) + "…" : t || "Empty Text";
}
// a Clipboard row's second line: "Text · Copied yesterday" (MAC-ANSWERS.md Q-panels-25, the Mac's own wording for a
// day-old text; the other ages reuse relTime, lower-cased)
function clipSubtitle(item, now) {
    const kind = String(item.mime || "").startsWith("image/") ? "Image" : "Text";
    const r = relTime(item.ts, now);
    return r ? kind + " · Copied " + r.charAt(0).toLowerCase() + r.slice(1) : kind;
}
// "Just now", "5 min ago", "3 hr ago", "Yesterday", "4 days ago"
function relTime(ts, now) {
    if (!ts) return "";
    const s = Math.max(0, (now - ts) / 1000);
    if (s < 60) return "Just now";
    if (s < 3600) return Math.floor(s / 60) + " min ago";
    if (s < 86400) return Math.floor(s / 3600) + " hr ago";
    if (s < 172800) return "Yesterday";
    return Math.floor(s / 86400) + " days ago";
}
