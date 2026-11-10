.pragma library

// Category chips of the Apps panel (Spotlight Applications), from the .desktop Categories.
// Names and chip order: macOS 27.2.1 (live/dock/apps-window.json): Utilities, Developer Tools, Social, Productivity &
// Finance, Entertainment, Creativity, Information & Reading, Travel, Other ("the list depends on the installed
// apps"). Games has no measured place: after Information & Reading. Travel has no freedesktop category: not used.
// Which .desktop category lands in which chip is ours. The first group with a matching category wins, so specific
// categories come before broad ones (a TextEditor that is also a Utility is Productivity, like TextEdit on the Mac).
const ORDER = ["Utilities", "Developer Tools", "Social", "Productivity & Finance", "Entertainment", "Creativity",
               "Information & Reading", "Games"];
const GROUPS = [
    ["Developer Tools", ["Development", "IDE", "Debugger", "RevisionControl", "GUIDesigner", "Profiling"]],
    ["Games", ["Game", "ActionGame", "AdventureGame", "ArcadeGame", "BoardGame", "BlocksGame", "CardGame", "LogicGame", "Simulation", "SportsGame", "StrategyGame"]],
    ["Social", ["InstantMessaging", "Chat", "IRCClient", "VideoConference", "Telephony"]],
    ["Productivity & Finance", ["Office", "Finance", "Email", "Calendar", "ContactManagement", "ProjectManagement",
                                "WordProcessor", "Spreadsheet", "Presentation", "TextEditor",
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

// group names in chip order
function names() {
    return ORDER.concat([OTHER]);
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
