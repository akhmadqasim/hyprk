// Static menu definitions. Items: {label, shortcut, action, disabled, icon, checked, submenu:true, items:[...]} or
// {sep:true}. A submenu row opens its `items` (MenuDropdown.qml); a submenu row without items must be disabled.
// Shortcut glyphs use the macOS modifier symbols. `icon` = leading SF Symbol (Q-menubar-17).
// No row is enabled without something behind it: every enabled row has an `action` or a submenu with items.
// Actions are names MenuDropdown.trigger() runs: plain names ("close", "settings", …) and
//   "keys:<MODS>,<key>"  the app's own shortcut, sent to the active window (hl.dsp.send_shortcut)
//   "finder" / "finder:<location>"  a Finder window (at "recents:", "applications:", "home" or "xdg:<XDG dir>")
//   "about-app:<name>", "spotlight:<mode>"
.pragma library

const SEP = { sep: true };

// a row that runs `action`, or shows disabled when there is none
function row(label, shortcut, action, extra) {
    const r = { label: label };
    if (shortcut) r.shortcut = shortcut;
    if (action) r.action = action;
    else r.disabled = true;
    return extra ? Object.assign(r, extra) : r;
}
// a submenu row without content: disabled
function sub(label, extra) { return Object.assign({ label: label, submenu: true, disabled: true }, extra || {}); }

// Apple menu (Q-menubar-31, -17): About [laptopcomputer: not in our symbol set], System Settings [gear], App Store
// [appstore]; the Option alternates are not built
function apple(user) {
    return [
        row("About This Computer", "", "about"),
        SEP,
        row("System Settings…", "", "settings", { icon: "gear" }),
        row("App Store", "", null, { icon: "appstore" }),
        SEP,
        sub("Recent Items"),
        SEP,
        row("Force Quit…", "⌥⌘⎋", "forcequit"),
        SEP,
        row("Sleep", "", "sleep"),
        row("Restart…", "", "restart"),
        row("Shut Down…", "", "shutdown"),
        SEP,
        row("Lock Screen", "⌃⌘Q", "lock"),
        row("Log Out " + (user || "") + "…", "⇧⌘Q", "logout"),
    ];
}

// ---------- Finder (reference/re/27.2.1/live/menubar/finder-menus-ax.txt, Q-menubar-17, -31) ----------
// The dump is Finder frontmost on the desktop with no window: that is our state when no window has focus (`win`
// false). With a hyprk Finder window focused (`win` true) the rows the Finder has a shortcut for send it.
// f(label, shortcut, desktopAction, windowAction, extra): null = disabled in that state
function finderMenus(win) {
    const f = (label, shortcut, desk, inWin, extra) => row(label, shortcut, win ? inWin : desk, extra);
    const go = (label, shortcut, loc, keys) => f(label, shortcut, "finder:" + loc, "keys:" + keys);
    return {
        "File": [
            f("New Finder Window", "⌘N", "finder", "finder"),
            f("New Folder", "⇧⌘N", "desktop-new-folder", "keys:CTRL SHIFT,n"),
            f("New Folder with Selection", "⌃⌘N"),
            f("New Smart Folder", ""),
            f("New Tab", "⌘T", null, "keys:CTRL,t"),
            f("Open", "⌘O", null, "keys:CTRL,o"),
            sub("Open With"),
            f("Close Window", "⌘W", null, "close"),
            SEP,
            f("Get Info", "⌘I"),
            f("Rename", ""),
            f("Compress", ""),
            f("Duplicate", "⌘D"),
            f("Make Alias", "⌃⌘A"),
            f("Quick Look", "⌘Y", null, "keys:CTRL,y"),
            SEP,
            f("Share…", "", null, null, { icon: "square.and.arrow.up" }),
            f("Manage Shared Folder…", "", null, null, { icon: "person.2" }),
            SEP,
            f("Show Original", "⌘R"),
            f("Add to Sidebar", "⌃⌘T"),
            SEP,
            f("Move to Trash", "⌘⌫", null, null, { icon: "trash" }),
            f("Eject", "⌘E", null, null, { icon: "sf:eject" }),
            SEP,
            f("Tags…", "", null, null, { icon: "tag" }),
            f("Customize Folder…", "", null, null, { icon: "tag" }),
            SEP,
            f("Print", "⌘P", null, null, { icon: "printer" }),
        ],
        "Edit": [
            f("Undo", "⌘Z"),
            f("Redo", "⇧⌘Z"),
            SEP,
            f("Cut", "⌘X"),
            f("Copy", "⌘C"),
            f("Paste", "⌘V"),
            f("Select All", "⌘A", null, "keys:CTRL,a"),
            SEP,
            f("Show Clipboard", "", "spotlight:clipboard", "spotlight:clipboard"),
            SEP,
            f("Search", "⌘F", "spotlight", "keys:CTRL,f", { icon: "magnifyingglass" }),
            SEP,
            sub("AutoFill"),
            f("Start Dictation", ""),
            f("Emoji & Symbols", ""),
        ],
        "View": [
            f("as Icons", "⌘1", null, "keys:CTRL,1", { icon: "square.grid.2x2" }),
            f("as List", "⌘2", null, "keys:CTRL,2", { icon: "list.bullet" }),
            f("as Columns", "⌘3", null, "keys:CTRL,3", { icon: "rectangle.split.3x1" }),
            f("as Gallery", "⌘4", null, "keys:CTRL,4", { icon: "squares.below.rectangle" }),
            SEP,
            f("Use Stacks", "⌃⌘0"),
            sub("Sort By"),
            f("Clean Up", ""),
            sub("Clean Up By"),
            SEP,
            f("Show Tab Bar", "⇧⌘T"),
            f("Show All Tabs", "⇧⌘\\"),
            SEP,
            f("Hide Sidebar", "⌃⌘S"),
            f("Hide Preview", "⇧⌘P"),
            SEP,
            f("Hide Toolbar", "⌥⌘T"),
            f("Show Path Bar", "⌥⌘P", null, "keys:CTRL ALT,p"),
            f("Show Status Bar", "⌘/"),
            SEP,
            f("Customize Toolbar…", ""),
            SEP,
            f("Show View Options", "⌘J"),
            f("Show Preview Options", ""),
            SEP,
            f("Enter Full Screen", "fn F", null, "fullscreen"),
        ],
        "Go": [
            f("Back", "⌘[", null, "keys:CTRL,bracketleft"),
            f("Forward", "⌘]", null, "keys:CTRL,bracketright"),
            f("Enclosing Folder", "⌘↑"),
            SEP,
            go("Recents", "⇧⌘F", "recents:", "CTRL SHIFT,f"),
            go("Documents", "⇧⌘O", "xdg:DOCUMENTS", "CTRL SHIFT,o"),
            go("Desktop", "⇧⌘D", "xdg:DESKTOP", "CTRL SHIFT,d"),
            go("Downloads", "⌥⌘L", "xdg:DOWNLOAD", "CTRL ALT,l"),
            go("Home", "⇧⌘H", "home", "CTRL SHIFT,h"),
            f("Computer", "⇧⌘C"),
            f("AirDrop", "⇧⌘R"),
            f("Network", "⇧⌘K"),
            f("iCloud Drive", "⇧⌘I"),
            f("Shared", "⇧⌘S"),
            go("Applications", "⇧⌘A", "applications:", "CTRL SHIFT,a"),
            f("Utilities", "⇧⌘U"),
            SEP,
            sub("Recent Folders"),
            SEP,
            f("Go to Folder…", "⇧⌘G"),
            f("Connect to Server…", "⌘K"),
        ],
        "Window": windowMenu(win, true),
        "Help": [row("Search", ""), row("Mac User Guide", ""), row("Tips for Your Mac", "")],
    };
}

// Window menu: the Finder's rows (finder-menus-ax.txt) or the short list of other apps
function windowMenu(win, finder) {
    const w = (label, shortcut, action) => row(label, shortcut, win ? action : null);
    const top = [
        w("Minimize", "⌘M", "minimize"),
        w("Zoom", "", "zoom"),
        w("Fill", "fn⌃F", "zoom"),
        w("Center", "fn⌃C", "center"),
        SEP,
        sub("Move & Resize"),
    ];
    if (!finder) return top.concat([SEP, row("Bring All to Front", "")]);
    return top.concat([
        sub("Full-Screen Tile"),
        SEP,
        row("Bring All to Front", ""),
        row("Cycle Through Windows", "⌘`", "cycle"),
        row("Remove Window from Set", ""),
        SEP,
        row("Show Previous Tab", "⌃⇧⇥"),
        row("Show Next Tab", "⌃⇥"),
        row("Move Tab to New Window", ""),
        row("Merge All Windows", ""),
        SEP,
        row("Show Progress Window", ""),
    ]);
}

// other apps: the common rows send the app's Linux shortcut (Ctrl for ⌘)
const common = {
    "Edit": [
        row("Undo", "⌘Z", "keys:CTRL,z"), row("Redo", "⇧⌘Z", "keys:CTRL SHIFT,z"), SEP,
        row("Cut", "⌘X", "keys:CTRL,x"), row("Copy", "⌘C", "keys:CTRL,c"), row("Paste", "⌘V", "keys:CTRL,v"),
        row("Select All", "⌘A", "keys:CTRL,a"), SEP,
        sub("AutoFill"), row("Start Dictation", ""), row("Emoji & Symbols", ""),
    ],
    "View": [
        row("Show Tab Bar", ""), row("Show All Tabs", ""), SEP,
        row("Show Sidebar", "⌃⌘S"), SEP, row("Enter Full Screen", "fn F", "fullscreen"),
    ],
    "Window": windowMenu(true, false),
    "Help": [row("Search", ""), SEP, row("Help", "⌘?")],
};

// File menu of other apps; open = false: no Open… action (terminals)
function fileMenu(newLabel, newKeys, open) {
    return [
        row(newLabel || "New Window", "⌘N", "keys:" + (newKeys || "CTRL,n")), row("Open…", "⌘O", open === false ? null : "keys:CTRL,o"), SEP,
        row("Close Window", "⌘W", "close"),
    ];
}
const shell = fileMenu("New Window", "CTRL SHIFT,n", false);

// app id (lowercased, last segment) -> titles + overrides
const apps = {
    "firefox": { titles: ["File", "Edit", "View", "History", "Bookmarks", "Tools", "Window", "Help"],
                 extra: { "File": fileMenu("New Tab", "CTRL,t"), "History": [row("Show All History", "⇧⌘H", "keys:CTRL SHIFT,h")],
                          "Bookmarks": [row("Bookmark Current Tab…", "⌘D", "keys:CTRL,d")], "Tools": [row("Downloads", "⌘J", "keys:CTRL SHIFT,y")] } },
    "ghostty": { titles: ["File", "Edit", "View", "Window", "Help"], extra: { "File": shell } },
    "terminal": { titles: ["Shell", "Edit", "View", "Window", "Help"], extra: { "Shell": shell } },
    "kitty": { titles: ["Shell", "Edit", "View", "Window", "Help"], extra: { "Shell": shell } },
    "texteditor": { titles: ["File", "Edit", "Format", "View", "Window", "Help"], extra: { "File": fileMenu("New"), "Format": [sub("Font"), sub("Text")] } },
    "settings": { titles: ["Edit", "View", "Window", "Help"], extra: {} },
};
const finderTitles = ["File", "Edit", "View", "Go", "Window", "Help"];

// Finder desktop right-click menu, as on 27.2.1 with Use Stacks off (screens/27.2.1/menubar/context-light.png shows
// it with stacks on: Group Stacks By instead of Sort By and the Clean Up rows). No Ask Siri header (no Siri) and no
// Paste Item (the clipboard holds no file items here).
function desktop() {
    return [
        row("New Folder", "", "desktop-new-folder"), SEP,
        row("Get Info", ""), SEP,
        row("Change Wallpaper…", "", "settings"),
        row("Edit Widgets…", "", "widgets"), SEP,
        row("Use Stacks", ""),
        sub("Sort By"),
        row("Clean Up", ""),
        sub("Clean Up By"),
        row("Show View Options", ""),
    ];
}

// the bold app-name menu. Finder (Q-menubar-31): About | Settings… | Empty Trash… | Services | Hide, Hide Others, Show All
function appMenu(name, appId) {
    if (isFinder(appId))
        return [
            row("About Finder", "", "about-app:Finder"), SEP,
            // with a Finder window: its Ctrl+, (the Action menu's settings rows); with none Settings, Hide Finder and
            // Hide Others stay disabled, as the Mac's AX dump shows them with no window, and Show All stays enabled
            row("Settings…", "⌘,", appId ? "keys:CTRL,comma" : null), SEP,
            row("Empty Trash…", "⇧⌘⌫", "empty-trash"), SEP,
            sub("Services"), SEP,
            row("Hide Finder", "⌘H", appId ? "hide-app" : null), row("Hide Others", "⌥⌘H", appId ? "hide-others" : null),
            row("Show All", "", "show-all"),
        ];
    return [
        row("About " + name, "", "about-app:" + name), SEP,
        row("Settings…", "⌘,"), SEP,
        row("Hide " + name, "⌘H", "hide-app"), row("Hide Others", "⌥⌘H", "hide-others"), row("Show All", "", "show-all"), SEP,
        row("Quit " + name, "⌘Q", "quit-app"),
    ];
}

function appKey(appId) { return String(appId || "").toLowerCase().split(".").pop(); }
// the desktop (no app) and the hyprk Finder get the Finder's menus
function isFinder(appId) { return !appId || appKey(appId) === "hyprk-finder"; }

// menu bar title index -> items: 0 Apple, 1 app name, 2.. app menus
function forIndex(index, appId, appName, user) {
    if (index === 0) return apple(user);
    if (index === 1) return appMenu(appName, appId);
    const m = forApp(appId)[index - 2];
    return m ? m.items : [];
}

function forApp(appId) {
    if (isFinder(appId)) {
        const m = finderMenus(!!appId);
        return finderTitles.map(t => ({ title: t, items: m[t] }));
    }
    const spec = apps[appKey(appId)] || { titles: ["File", "Edit", "View", "Window", "Help"], extra: { "File": fileMenu() } };
    return spec.titles.map(t => ({ title: t, items: (spec.extra && spec.extra[t]) || common[t] || [] }));
}

// "keys:CTRL SHIFT,n" -> { mods: "CTRL SHIFT", key: "n" }; null for other actions
function keysOf(action) {
    const m = /^keys:([^,]*),(.+)$/.exec(typeof action === "string" ? action : "");
    return m ? { mods: m[1], key: m[2] } : null;
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

// type-to-select (Q-menubar-25: "z" -> Zoom In, "s" -> Sort By): the first selectable row whose label starts with the
// typed character, any case; -1 when none does
function typeSelect(items, ch) {
    const c = String(ch || "").toLocaleLowerCase();
    if (c.length !== 1 || c.trim() === "") return -1;
    for (let i = 0; i < items.length; i++)
        if (selectable(items[i]) && String(items[i].label || "").toLocaleLowerCase().startsWith(c)) return i;
    return -1;
}

// a submenu row that has something to open
function opens(it) { return selectable(it) && it.submenu === true && Array.isArray(it.items) && it.items.length > 0; }

// top of row i inside the row list (rows `row` pt, separators `sep` pt)
function rowTop(items, i, row, sep) {
    let y = 0;
    for (let k = 0; k < i && k < items.length; k++) y += items[k].sep ? sep : row;
    return y;
}

// Press, drag, release (MAC-ANSWERS.md Q-menubar-24): the row under y (from the top of the row list), -1 over a
// separator or past either end
function rowAt(items, y, row, sep) {
    if (!(y >= 0)) return -1;
    let top = 0;
    for (let i = 0; i < items.length; i++) {
        top += items[i].sep ? sep : row;
        if (y < top) return items[i].sep ? -1 : i;
    }
    return -1;
}
// what the button going up over row i does: "run" an enabled row, "open" a submenu row that has items (as a click),
// "" on a disabled row, a submenu row without items, a separator or outside the rows (the menu stays open)
function releaseOn(items, i) {
    const it = i >= 0 ? items[i] : null;
    if (!selectable(it)) return "";
    if (it.submenu) return opens(it) ? "open" : "";
    return "run";
}

// Moving towards an open submenu (AppKit 27.2.1, -[NSMenuTrackingSession _trackMovedDraggedEventHandler:] 0x18a9af79c
// with _beginPredictiveTrackingAtPoint: 0x18a9b0488): when the pointer leaves the submenu's row, that point is the apex.
// A later point p keeps the submenu (the row under p is not taken) while it lies in the cone from the apex to the
// submenu's near edge, its top and bottom corners widened by 15 degrees each (atan2 x 180 / pi), and p is past the apex
// towards the submenu. Window coordinates, y down (AppKit's y up gives the same test). sub = { x, y, width, height }.
const CONE_DEG = 15;
function towardSubmenu(apex, p, sub) {
    const deg = (dy, dx) => Math.atan2(dy, dx) * 180 / Math.PI;
    const top = sub.y, bottom = sub.y + sub.height;
    // the near vertical edge: the submenu's right edge when it starts left of p, else its left edge
    const edge = sub.x < p.x ? sub.x + sub.width : sub.x;
    if (edge >= p.x) {                       // submenu to the right: p must be right of the apex
        if (!(p.x > apex.x)) return false;
        const a = deg(p.y - apex.y, p.x - apex.x);
        return a >= deg(top - apex.y, edge - apex.x) - CONE_DEG && a <= deg(bottom - apex.y, edge - apex.x) + CONE_DEG;
    }
    if (!(p.x < apex.x)) return false;       // submenu to the left
    const a = deg(apex.y - p.y, apex.x - p.x);
    return a <= deg(apex.y - top, apex.x - edge) + CONE_DEG && a >= deg(apex.y - bottom, apex.x - edge) - CONE_DEG;
}
// how long it may last (same function): a one-shot 0.5 s timer from the first point in the cone ends it
// (CFRunLoopTimer, _cancelPredictiveTracking); resting on one row (moves of 3 pt or less, |dx| + |dy|) for 0.4 s ends
// it; 1.0 s after the row under the pointer last changed ends it
function predictTimes() { return { ms: 500, restMs: 400, restPt: 3, rowMs: 1000 }; }

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
