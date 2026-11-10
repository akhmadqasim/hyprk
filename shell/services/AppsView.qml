pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// The "Applications" window (Dock "Apps", Cmd+A / F4). On macOS 27.2.1 Apps is an ordinary window
// titled "Applications" with a category bar and an icon grid, not a full-screen Launchpad
// (MAC-ANSWERS.md R2): it appears in one frame and Escape closes it in one frame. Here it is a
// FloatingWindow of the shell (modules/ApplicationsWindow.qml), created only while open, so the
// compositor moves it like any app window and nothing of it exists while it is closed.
Singleton {
    id: root

    property bool open: false
    // class of the window: the shell's AppId (shell.qml pragma)
    readonly property string appId: "org.hyprk.Shell"
    function show() { open = true; }
    function close() { open = false; }
    function toggle() { open = !open; }

    // Layout of the window. No 27.2.1 measurement yet (Q-dock-23..26): all guessed unless noted.
    readonly property QtObject metrics: QtObject {
        readonly property int width: 760
        readonly property int height: 560
        readonly property int minWidth: 480
        readonly property int minHeight: 360
        readonly property int toolbarHeight: 52      // macOS 27 toolbar window, as Settings and Finder (52 pt)
        readonly property int lightsX: 19            // as Settings (measured there)
        readonly property int titleGap: 24           // zoom light to title
        readonly property real titleSize: 15         // Finder's title (17.5 ref px at 1.14x)
        readonly property int searchWidth: 200
        readonly property int searchHeight: 36       // toolbar platter height (Tokens.toolbar, 27.2.1)
        readonly property int rightPad: 8            // last toolbar item to the window edge (27.2.1 Finder)
        readonly property int barHeight: 36          // category bar under the toolbar
        readonly property int pillHeight: 28
        readonly property int pillPadding: 12
        readonly property int pillSpacing: 4
        readonly property real pillText: 13
        readonly property int gridTop: 8
        readonly property int sidePad: 20
        readonly property int cellWidth: 102
        readonly property int cellHeight: 104
        readonly property int iconSize: 64
        readonly property int labelGap: 6
        readonly property real labelSize: 12
        // first screen of the "All" grid, decoded ahead (LaunchpadPreload.qml)
        readonly property int columns: Math.floor((width - sidePad * 2) / cellWidth)
        readonly property int firstScreen: columns * Math.ceil((height - toolbarHeight - barHeight - gridTop) / cellHeight)
    }

    // Hyprland binds: hl.dsp.global("hyprk:apps")
    GlobalShortcut { appid: "hyprk"; name: "apps"; description: "Applications"; onPressed: root.toggle() }

    // `qs -p shell ipc call apps toggle`
    IpcHandler {
        target: "apps"
        function toggle(): void { root.toggle(); }
        function open(): void { root.show(); }   // not "show": the qs ipc CLI takes that word itself
        function close(): void { root.close(); }
        function isOpen(): bool { return root.open; }
    }
}
