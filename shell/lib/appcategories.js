.pragma library

// Groups of the Applications window's category bar, from the .desktop Categories.
// Names: the categories of the macOS 26 Apps view ("Productivity & Finance" is in
// reference/screens/macos27-apps-view.png, with Mail, Calendar, Notes, Terminal, Script Editor and
// Time Machine in it); the rest are from memory of macOS 26, not checked on 27.2.1 (Q-dock-26).
// The first group with a matching category wins, so specific categories come before broad ones
// (a TextEditor that is also a Utility is Productivity, like TextEdit on the Mac).
const GROUPS = [
    ["Games", ["Game", "ActionGame", "AdventureGame", "ArcadeGame", "BoardGame", "BlocksGame", "CardGame", "LogicGame", "Simulation", "SportsGame", "StrategyGame"]],
    ["Social", ["InstantMessaging", "Chat", "IRCClient", "VideoConference", "Telephony"]],
    ["Productivity & Finance", ["Office", "Finance", "Email", "Calendar", "ContactManagement", "ProjectManagement",
                                "WordProcessor", "Spreadsheet", "Presentation", "TextEditor", "Development", "IDE",
                                "TerminalEmulator", "Database"]],
    ["Creativity", ["Graphics", "2DGraphics", "3DGraphics", "VectorGraphics", "RasterGraphics", "Photography",
                    "AudioVideoEditing", "Recorder", "Midi", "Mixer", "Sequencer", "Publishing"]],
    ["Entertainment", ["AudioVideo", "Audio", "Video", "Player", "Music", "TV"]],
    ["Information & Reading", ["Education", "Science", "News", "Dictionary", "Literature", "Documentation",
                               "Geography", "Maps", "Viewer", "WebBrowser", "Feed"]],
    ["Utilities", ["Utility", "System", "Settings", "Monitor", "Accessibility", "FileManager", "Archiving",
                   "Calculator", "Security", "FileTools", "Network"]],
];
const OTHER = "Other";

// group names in bar order
function names() {
    return GROUPS.map(g => g[0]).concat([OTHER]);
}

// group of one app from its Categories list
function groupOf(categories) {
    const cats = Array.from(categories || []);
    for (const g of GROUPS)
        if (g[1].some(c => cats.indexOf(c) !== -1)) return g[0];
    return OTHER;
}

// the bar: groups that have at least one of `entries` (objects with `categories`), in bar order
function present(entries) {
    const seen = {};
    for (const e of entries) seen[groupOf(e.categories)] = true;
    return names().filter(n => seen[n]);
}
