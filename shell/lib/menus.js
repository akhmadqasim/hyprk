// Static menu definitions. Items: {label, shortcut, action, disabled, icon, checked, submenu:true, items:[...]} or
// {sep:true}. A submenu row opens its `items` (MenuDropdown.qml); a submenu row without items must be disabled.
// Shortcut glyphs use the macOS modifier symbols. `icon` = leading SF Symbol (Q-menubar-17).
// No row is enabled without something behind it: every enabled row has an `action` or a submenu with items.
// Actions are names MenuDropdown.trigger() runs: plain names ("close", "settings", …) and
//   "keys:<MODS>,<key>"  the app's own shortcut, sent to the active window (hl.dsp.send_shortcut)
//   "finder" / "finder:<location>"  a Finder window (at "recents:", "applications:", "home" or "xdg:<XDG dir>")
//   "about-app:<name>", "spotlight:<mode>", "emoji" (Emoji & Symbols, modules/EmojiPicker.qml)
.pragma library

const SEP = { sep: true };

// The images AppKit 27.2.1 gives the Edit menu's three appends (reference/re/27.2.1/MENUS-REA-27.2.1.md "Edit menu
// icons"): AutoFill = +[NSMenuItem _standardAutoFillMenuItem] (0x18aa1103c) sets the private symbol
// "rectangle.and.pencil.and.ellipsis" with _setActionImage: and _setImageVisibility:; Start Dictation and Emoji &
// Symbols get the automatic image of their action from AppKit's table (cstrings 0x1e28a55a0..: startDictation: ->
// "microphone", orderFrontCharacterPalette: -> "emoji.face.grinning"); Q-menubar-17 saw all three drawn. The three
// glyphs are decoded from the 27.2.1 CoreGlyphs / CoreGlyphsPrivate BVG data (themes/icons/sf-symbols/names.json,
// tools/add-sf.py; reference/re/27.2.1/ICONS-REA-27.2.1.md part 1).
const editIcons = { autofill: { icon: "rectangle.and.pencil.and.ellipsis" }, dictation: { icon: "microphone" },
                    emoji: { icon: "emoji.face.grinning" } };

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

// Finder's Sort By and Clean Up By submenus (27.2.1 Finder.app). Sort By = Base.lproj/ArrangeByMenu.nib outlet
// sortByMenu (TArrangeByMenuController): None ⌃⌥⌘0, separator, Snap to Grid, separator, Name ⌃⌥⌘1, Kind ⌃⌥⌘2, [Shared By,
// Last Modified By: shared iCloud items only], Date Last Opened ⌃⌥⌘3, Date Added ⌃⌥⌘4, Date Modified ⌃⌥⌘5, Date Created,
// Size ⌃⌥⌘6, Tags ⌃⌥⌘7. Clean Up By = -[TContextMenu addViewSpecificStuffToMenu:...] 0x10042098c, the six titles of the
// table at 0x100b267a8: N220 Name, N224 Kind, N221 Date Modified, N222 Date Created, N223 Size, N225 Tags. The desktop has
// no icon layout of its own here, so every row is disabled; `keys` = with the nib's key equivalents (menu bar), without
// (context menus: TArrangeByMenuController removeCommandKeyEquivalents)
function sortByRows(keys) {
    const k = c => keys ? "⌃⌥⌘" + c : "";
    return [row("None", k("0")), SEP, row("Snap to Grid", ""), SEP, row("Name", k("1")), row("Kind", k("2")),
            row("Date Last Opened", k("3")), row("Date Added", k("4")), row("Date Modified", k("5")), row("Date Created", ""),
            row("Size", k("6")), row("Tags", k("7"))];
}
function cleanUpByRows() {
    return ["Name", "Kind", "Date Modified", "Date Created", "Size", "Tags"].map(l => row(l, ""));
}

// Apple menu (Q-menubar-31, -17; labels: AppKit.framework/Resources/Menus.loctable "About This Mac",
// "System Settings...", "App Store", "Recent Items", "Force Quit...", "Sleep", "Restart...", "Shut Down...", "Lock Screen",
// "Log Out %@..."; AppKit builds this menu, not the app): About [laptopcomputer, decoded from CoreGlyphs], System
// Settings [gear], App Store [appstore]; the Option alternates are not built
function apple(user) {
    return [
        row("About This Mac", "", "about", { icon: "laptopcomputer" }),
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
            // AppKit's three appends with their 27.2.1 images (editIcons, top of this file)
            sub("AutoFill", editIcons.autofill),
            f("Start Dictation", "", null, null, editIcons.dictation),
            f("Emoji & Symbols", "", "emoji", "emoji", editIcons.emoji),
        ],
        "View": [
            f("as Icons", "⌘1", null, "keys:CTRL,1", { icon: "square.grid.2x2" }),
            f("as List", "⌘2", null, "keys:CTRL,2", { icon: "list.bullet" }),
            f("as Columns", "⌘3", null, "keys:CTRL,3", { icon: "rectangle.split.3x1" }),
            f("as Gallery", "⌘4", null, "keys:CTRL,4", { icon: "squares.below.rectangle" }),
            SEP,
            f("Use Stacks", "⌃⌘0"),
            { label: "Sort By", submenu: true, items: sortByRows(true) },
            f("Clean Up", ""),
            { label: "Clean Up By", submenu: true, items: cleanUpByRows() },
            SEP,
            f("Show Tab Bar", "⇧⌘T"),
            f("Show All Tabs", "⇧⌘\\"),
            SEP,
            f("Hide Sidebar", "⌃⌘S"),
            f("Hide Preview", "⇧⌘P", null, "keys:CTRL SHIFT,p"),
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

// Window menu: the rows AppKit puts in every app's Window menu (labels: AppKit.framework/Resources/
// MenuCommands.loctable "Minimize", "Zoom", "Fill", "Center", "Move & Resize", "Full Screen Tile", "Bring All to Front",
// "Cycle Through Windows", "Remove Window from Set", "Show Previous Tab", "Show Next Tab", "Move Tab to New Window",
// "Merge All Windows"), in the order and with the keys of the Finder's Window menu (finder-menus-ax.txt); the Finder
// adds Show Progress Window. The open-window list after it: windowList (forIndex adds it).
function windowMenu(win, finder) {
    const w = (label, shortcut, action) => row(label, shortcut, win ? action : null);
    return [
        w("Minimize", "⌘M", "minimize"),
        w("Zoom", "", "zoom"),
        w("Fill", "fn⌃F", "zoom"),
        w("Center", "fn⌃C", "center"),
        SEP,
        sub("Move & Resize"),
        sub("Full Screen Tile"),
        SEP,
        row("Bring All to Front", ""),
        row("Cycle Through Windows", "⌘`", "cycle"),
        row("Remove Window from Set", ""),
        SEP,
        row("Show Previous Tab", "⌃⇧⇥"),
        row("Show Next Tab", "⌃⇥"),
        row("Move Tab to New Window", ""),
        row("Merge All Windows", ""),
    ].concat(finder ? [SEP, row("Show Progress Window", "")] : []);
}

// other apps: the rows AppKit gives every app (the app's own rows are not known here), sending the app's Linux
// shortcut (Ctrl for ⌘). Edit: the standard rows, then the three AppKit appends (finder-menus-ax.txt Edit tail). View:
// AppKit's tab and full-screen rows (MenuCommands.loctable "Show Tab Bar", "Show All Tabs", "Enter Full Screen", keys as
// in the Finder's View menu). Help: the search field row and "<App> Help" (helpMenu(), the app template's row).
const common = {
    "Edit": [
        row("Undo", "⌘Z", "keys:CTRL,z"), row("Redo", "⇧⌘Z", "keys:CTRL SHIFT,z"), SEP,
        row("Cut", "⌘X", "keys:CTRL,x"), row("Copy", "⌘C", "keys:CTRL,c"), row("Paste", "⌘V", "keys:CTRL,v"),
        row("Select All", "⌘A", "keys:CTRL,a"), SEP,
        sub("AutoFill", editIcons.autofill), row("Start Dictation", "", null, editIcons.dictation),
        row("Emoji & Symbols", "", "emoji", editIcons.emoji),
    ],
    "View": [
        row("Show Tab Bar", "⇧⌘T"), row("Show All Tabs", "⇧⌘\\"), SEP,
        row("Enter Full Screen", "fn F", "fullscreen"),
    ],
    "Window": windowMenu(true, false),
};
// Help of other apps: AppKit's search field (drawn as a plain row, disabled) and the app's "<App> Help ⌘?" (no help
// book here: disabled)
function helpMenu(name) { return [row("Search", ""), row((name || "App") + " Help", "⌘?")]; }

// System Settings (27.2.1 System Settings.app, SettingsApp/SettingsAppCommands.swift, decoded with Ghidra 12.1.4:
// FUN_10002bca8 is the Commands body). View: CommandGroup(before: .toolbar) FUN_10002cf84 = Back ⌘[ (label 0x10002df80),
// Forward ⌘] (0x10002e170), Divider, Search ⌘F with Image(systemName: "magnifyingglass") (0x10002e46c / 0x10002e650),
// Divider; CommandGroup(after: .toolbar) FUN_10002e704 adds the pane list (not built here). Back, Forward and Search act
// in our Settings window through its own Ctrl shortcuts; with no Settings window focused they stay disabled.
function settingsView() {
    return [
        row("Back", "⌘[", "keys:CTRL,bracketleft"),
        row("Forward", "⌘]", "keys:CTRL,bracketright"), SEP,
        row("Search", "⌘F", "keys:CTRL,f", { icon: "magnifyingglass" }),
    ];
}
// Help: AppKit's search field, then CommandGroup(after: .help) HelpMenu FUN_100066b04: "Mac User Guide" with
// Image(systemName: "book.pages") (0x1000676a8 / 0x10006798c; decoded from CoreGlyphs), Divider,
// "User Manual", "macOS Support", "<model> Specifications" (0x100067f60), "Hardware Support" (0x100068504). They open
// Apple web pages: disabled here.
function settingsHelp() {
    return [row("Search", ""), row("Mac User Guide", "", null, { icon: "book.pages" }), SEP, row("User Manual", ""), row("macOS Support", ""),
            row("Mac Specifications", ""), row("Hardware Support", "")];
}

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
    "settings": { titles: ["Edit", "View", "Window", "Help"], extra: { "View": settingsView(), "Help": settingsHelp() } },
};
const finderTitles = ["File", "Edit", "View", "Go", "Window", "Help"];

// Finder desktop right-click menu, as on 27.2.1 with Use Stacks off (screens/27.2.1/menubar/context-light.png shows
// it with stacks on: Group Stacks By instead of Sort By and the Clean Up rows). No Ask Siri header (no Siri) and no
// Paste Item (the clipboard holds no file items here).
function desktop() {
    return [
        row("New Folder", "", "desktop-new-folder"), SEP,
        // no separator between Get Info and Change Wallpaper… (context-{light,dark}.png)
        row("Get Info", ""),
        row("Change Wallpaper…", "", "settings"),
        row("Edit Widgets…", "", "widgets"), SEP,
        row("Use Stacks", ""),
        { label: "Sort By", submenu: true, items: sortByRows(false) },
        row("Clean Up", ""),
        { label: "Clean Up By", submenu: true, items: cleanUpByRows() },
        row("Show View Options", ""),
    ];
}

// the bold app-name menu. Finder (Q-menubar-31): About | Settings… | Empty Trash… | Services | Hide, Hide Others, Show All
function appMenu(name, appId) {
    if (isFinder(appId))
        return [
            row("About Finder", "", "about-app:Finder"), SEP,
            // Settings…: our Finder has no settings window, so the row stays disabled (FALLBACKS.md). With no Finder
            // window Hide Finder and Hide Others are disabled, as the Mac's AX dump shows them, and Show All stays enabled
            row("Settings…", "⌘,"), SEP,
            row("Empty Trash…", "⇧⌘⌫", "empty-trash"), SEP,
            sub("Services"), SEP,
            row("Hide Finder", "⌘H", appId ? "hide-app" : null), row("Hide Others", "⌥⌘H", appId ? "hide-others" : null),
            row("Show All", "", "show-all"),
        ];
    // other apps: the app template's rows (Finder's app menu without its Empty Trash, plus Quit): About, Settings…,
    // Services ▸ (AppKit fills it; none here), Hide, Hide Others, Show All, Quit. System Settings replaces the Settings
    // group with nothing (CommandGroup(replacing: .appSettings), FUN_10002bca8; its only row is Apple-internal).
    const settings = appKey(appId) === "settings" ? [] : [row("Settings…", "⌘,"), SEP];
    return [
        row("About " + name, "", "about-app:" + name), SEP,
    ].concat(settings, [
        sub("Services"), SEP,
        row("Hide " + name, "⌘H", "hide-app"), row("Hide Others", "⌥⌘H", "hide-others"), row("Show All", "", "show-all"), SEP,
        row("Quit " + name, "⌘Q", "quit-app"),
    ]);
}

function appKey(appId) { return String(appId || "").toLowerCase().split(".").pop(); }
// the desktop (no app) and the hyprk Finder get the Finder's menus
function isFinder(appId) { return !appId || appKey(appId) === "hyprk-finder"; }

// menu bar title index -> items: 0 Apple, 1 app name, 2.. app menus. windows: the app's windows for the Window menu's
// list (windowList)
function forIndex(index, appId, appName, user, windows) {
    if (index === 0) return apple(user);
    if (index === 1) return appMenu(appName, appId);
    const m = forApp(appId, appName)[index - 2];
    if (!m) return [];
    return m.title === "Window" ? m.items.concat(windowList(windows)) : m.items;
}

// The Window menu's tail: AppKit lists the app's windows after a separator, one row per window titled as the window
// (-[NSApplication(NSWindowsMenu_Private) _addWindowsMenu:enabled:] 0x18a558ab0, one entry per window from
// -[NSWindow(NSWindow_Theme) _createWindowsMenuEntryWithTitle:enabled:] 0x18a5590b0, a tabbed window's tabs as their
// own rows), with a mark on the key window (checkmark) and on a minimised one (NSMenuItemDiamond: the AX dump's
// "◆ Applications", finder-menus-ax.txt) or one with unsaved changes (NSMenuItemBullet: not known here). Choosing a
// row brings that window forward. wins: [{ title, key, minimized, action }]
function windowList(wins) {
    const list = (wins || []).filter(w => w);
    if (list.length === 0) return [];
    return [SEP].concat(list.map(w => {
        const r = { label: w.title || "Untitled" };   // "Untitled" for a window with no title: GUESS
        if (w.action) r.action = w.action; else r.disabled = true;
        if (w.key) r.checked = true;
        else if (w.minimized) r.checked = "diamond";
        return r;
    }));
}

function forApp(appId, appName) {
    if (isFinder(appId)) {
        const m = finderMenus(!!appId);
        return finderTitles.map(t => ({ title: t, items: m[t] }));
    }
    const spec = apps[appKey(appId)] || { titles: ["File", "Edit", "View", "Window", "Help"], extra: { "File": fileMenu() } };
    const help = helpMenu(appName);
    return spec.titles.map(t => ({ title: t, items: (spec.extra && spec.extra[t]) || (t === "Help" ? help : common[t]) || [] }));
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

// What every row keeps after its label's advance, in pt. AppKit reserves the submenu column for the whole menu, as it
// does the key column: once any row has a submenu, every row ends `sub` before the edge, not only the chevron rows;
// otherwise a row ends `plain` before it. 48 fits three Mac menus with a submenu row (label advances from SF Pro 13):
// desktop menu 198.5 wide with "Change Wallpaper…" (longest, no submenu) ending 48.4 before the edge
// (menubar/context-dark.png: ink 419 px, edge 518 px, the ellipsis' right bearing 1.1 pt); Dock menus Notes 111
// ("Options ▸" longest) and Calculator 174 ("Show All Windows" longest, an "Options ▸" row) (live/dock/dock-menus.json)
function rowEnd(items, plain, sub) {
    for (const it of items || []) if (it && !it.sep && it.submenu) return sub;
    return plain;
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
