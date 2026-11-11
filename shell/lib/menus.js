// Static menu definitions. Items: {label, shortcut, action, disabled, submenu:true, items:[...]} or {sep:true}.
// A submenu row opens its `items` (MenuDropdown.qml); a submenu row without items shows the chevron only.
// Shortcut glyphs use the macOS modifier symbols.
.pragma library

const SEP = { sep: true };

function apple(user) {
    return [
        { label: "About This Computer", action: "about" },
        SEP,
        { label: "System Settings…", action: "settings" },
        { label: "App Store…", disabled: true },
        SEP,
        { label: "Recent Items", submenu: true, disabled: true },
        SEP,
        { label: "Force Quit…", shortcut: "⌥⌘⎋", action: "forcequit" },
        SEP,
        { label: "Sleep", action: "sleep" },
        { label: "Restart…", action: "restart" },
        { label: "Shut Down…", action: "shutdown" },
        SEP,
        { label: "Lock Screen", shortcut: "⌃⌘Q", action: "lock" },
        { label: "Log Out " + (user || "") + "…", shortcut: "⇧⌘Q", action: "logout" },
    ];
}

const common = {
    "Edit": [
        { label: "Undo", shortcut: "⌘Z" }, { label: "Redo", shortcut: "⇧⌘Z" }, SEP,
        { label: "Cut", shortcut: "⌘X" }, { label: "Copy", shortcut: "⌘C" }, { label: "Paste", shortcut: "⌘V" },
        { label: "Select All", shortcut: "⌘A" }, SEP,
        { label: "AutoFill", submenu: true }, { label: "Start Dictation…", disabled: true }, { label: "Emoji & Symbols", shortcut: "fn E" },
    ],
    "View": [
        { label: "Show Tab Bar", disabled: true }, { label: "Show All Tabs", disabled: true }, SEP,
        { label: "Show Sidebar", shortcut: "⌃⌘S" }, SEP, { label: "Enter Full Screen", shortcut: "fn F", action: "fullscreen" },
    ],
    "Window": [
        { label: "Minimize", shortcut: "⌘M" }, { label: "Zoom", action: "zoom" }, { label: "Fill", shortcut: "fn⌃F" },
        { label: "Center", shortcut: "fn⌃C" }, SEP, { label: "Move & Resize", submenu: true }, SEP,
        { label: "Bring All to Front" },
    ],
    "Help": [{ label: "Search", disabled: true }, SEP, { label: "Help", shortcut: "⌘?" }],
};

function fileMenu(newLabel) {
    return [
        { label: newLabel || "New Window", shortcut: "⌘N" }, { label: "Open…", shortcut: "⌘O" }, SEP,
        { label: "Close Window", shortcut: "⌘W", action: "close" },
    ];
}

const finder = {
    titles: ["File", "Edit", "View", "Go", "Window", "Help"],
    extra: {
        "File": [{ label: "New Finder Window", shortcut: "⌘N" }, { label: "New Folder", shortcut: "⇧⌘N" },
                 { label: "Open", shortcut: "⌘O" }, SEP, { label: "Close Window", shortcut: "⌘W", action: "close" }, SEP,
                 { label: "Get Info", shortcut: "⌘I" }, SEP, { label: "Find", shortcut: "⌘F", action: "spotlight" }],
        "Go": [{ label: "Back", shortcut: "⌘[" }, { label: "Forward", shortcut: "⌘]" }, SEP,
               { label: "Recents", shortcut: "⇧⌘F" }, { label: "Documents", shortcut: "⇧⌘O" }, { label: "Desktop", shortcut: "⇧⌘D" },
               { label: "Downloads", shortcut: "⌥⌘L" }, { label: "Home", shortcut: "⇧⌘H" }, { label: "Applications", shortcut: "⇧⌘A", action: "apps" }],
    },
};

// app id (lowercased, last segment) -> titles + overrides
const apps = {
    "firefox": { titles: ["File", "Edit", "View", "History", "Bookmarks", "Tools", "Window", "Help"],
                 extra: { "File": fileMenu("New Tab"), "History": [{ label: "Show All History", shortcut: "⇧⌘H" }],
                          "Bookmarks": [{ label: "Bookmark Current Tab…", shortcut: "⌘D" }], "Tools": [{ label: "Downloads", shortcut: "⌘J" }] } },
    "ghostty": { titles: ["File", "Edit", "View", "Window", "Help"], extra: { "File": fileMenu("New Window") } },
    "terminal": { titles: ["Shell", "Edit", "View", "Window", "Help"], extra: { "Shell": fileMenu("New Window") } },
    "kitty": { titles: ["Shell", "Edit", "View", "Window", "Help"], extra: { "Shell": fileMenu("New Window") } },
    "texteditor": { titles: ["File", "Edit", "Format", "View", "Window", "Help"], extra: { "File": fileMenu("New"), "Format": [{ label: "Font", submenu: true }, { label: "Text", submenu: true }] } },
    "settings": { titles: ["Edit", "View", "Window", "Help"], extra: {} },
};

// Finder desktop right-click menu. Actions are names handled by MenuDropdown.
function desktop() {
    return [
        { label: "New Folder", action: "desktop-new-folder" }, SEP,
        { label: "Get Info", disabled: true }, SEP,
        { label: "Change Wallpaper…", action: "settings" },
        { label: "Edit Widgets…", action: "widgets" }, SEP,
        { label: "Use Stacks", disabled: true },
        { label: "Sort By", submenu: true, disabled: true },
        { label: "Clean Up", disabled: true },
        { label: "Clean Up By", submenu: true, disabled: true },
        { label: "Show View Options", disabled: true },
    ];
}

// the bold app-name menu
function appMenu(name) {
    return [
        { label: "About " + name }, SEP,
        { label: "Settings…", shortcut: "⌘," }, SEP,
        { label: "Hide " + name, shortcut: "⌘H" }, { label: "Hide Others", shortcut: "⌥⌘H" }, SEP,
        { label: "Quit " + name, shortcut: "⌘Q", action: "close" },
    ];
}

// menu bar title index -> items: 0 Apple, 1 app name, 2.. app menus
function forIndex(index, appId, appName, user) {
    if (index === 0) return apple(user);
    if (index === 1) return appMenu(appName);
    const m = forApp(appId)[index - 2];
    return m ? m.items : [];
}

function forApp(appId) {
    const key = String(appId || "").toLowerCase().split(".").pop();
    const spec = apps[key] || (appId ? { titles: ["File", "Edit", "View", "Window", "Help"], extra: { "File": fileMenu() } } : finder);
    return spec.titles.map(t => ({ title: t, items: (spec.extra && spec.extra[t]) || common[t] || [] }));
}

// ---------- keyboard and submenu geometry (MenuDropdown.qml, MAC-ANSWERS.md Q-menubar-23, -25) ----------

function selectable(it) { return !!it && !it.sep && !it.disabled; }

// next selectable row from `from` in direction dir (+1 Down, -1 Up), no wrap: stays put at either end.
// Nothing selected (from < 0): Down picks the first selectable row, Up the last.
function step(items, from, dir) {
    if (from < 0) {
        if (dir > 0) { for (let i = 0; i < items.length; i++) if (selectable(items[i])) return i; }
        else { for (let i = items.length - 1; i >= 0; i--) if (selectable(items[i])) return i; }
        return -1;
    }
    for (let i = from + dir; i >= 0 && i < items.length; i += dir) if (selectable(items[i])) return i;
    return from;
}

// a submenu row that has something to open
function opens(it) { return selectable(it) && it.submenu === true && Array.isArray(it.items) && it.items.length > 0; }

// top of row i inside the row list (rows `row` pt, separators `sep` pt)
function rowTop(items, i, row, sep) {
    let y = 0;
    for (let k = 0; k < i && k < items.length; k++) y += items[k].sep ? sep : row;
    return y;
}

// Submenu frame in the parent's coordinate space (all in pt): x = parent right edge - overlap, y = row top - pad, so
// its first row lines up with the parent row (Q-menubar-23). Not measured on the Mac, kept simple: when it does not
// fit on the right it opens on the left with the same overlap; at the bottom it is shifted up to `margin` above the edge.
// m: { menuX, menuY, menuW, rowTop, subW, subH, areaW, areaH, overlap, pad, margin }
function submenuFrame(m) {
    let x = m.menuX + m.menuW - m.overlap;
    if (x + m.subW > m.areaW - m.margin) x = m.menuX - m.subW + m.overlap;
    let y = m.menuY + m.rowTop - m.pad;
    y = Math.max(0, Math.min(y, m.areaH - m.margin - m.subH));
    return { x: x, y: y };
}
