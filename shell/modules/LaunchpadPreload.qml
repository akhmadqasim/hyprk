import QtQuick
import qs
import qs.components
import qs.services
import "../lib/appsgrid.js" as AG

// The Apps panel (Spotlight Applications, modules/spotlight/AppsPanel.qml) is created on open, so its icons would
// decode then and fill in over the first frames (the 27.2.1 Mac also fills them in over about 0.5 s; ours are
// complete in the first frame). This keeps the first screen of its "All" view (the suggestions row and the visible
// A-Z rows, lib/appsgrid.js firstScreen) as AppIcons alive, never drawn (opacity 0), in the always-mapped wallpaper
// window of the primary screen: the decoded images stay referenced in Qt's pixmap cache (same url and size, so the
// panel's own Images find them at once) and the tile shape checks (iconshape.js) are cached before the first open.
// It starts 2 s after the shell, off the startup path (reference/PERF-2026-11-10.md item 4). The suggestions
// change with use, so they may still decode on open. (Name kept: Background.qml instantiates it.)
Item {
    id: pre
    required property var screen
    visible: screen === Panels.screen       // the panel opens on the primary screen
    opacity: 0
    enabled: false

    property bool started: false
    Timer { running: pre.visible && !pre.started; interval: 2000; onTriggered: pre.started = true }

    Repeater {
        model: pre.visible && pre.started ? Apps.sortedEntries.slice(0, AG.firstScreen() - AG.metrics().columns) : []
        AppIcon {
            required property var modelData
            size: AG.metrics().icon / Theme.appIcon.body   // AppsPanel's tile around the 60 pt art
            icon: modelData.icon
            appId: modelData.id
        }
    }
}
