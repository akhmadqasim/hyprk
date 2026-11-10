// Static menu definitions. Items: {label, shortcut, action, disabled, submenu:true} or {sep:true}.
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
