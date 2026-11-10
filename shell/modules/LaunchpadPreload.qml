import QtQuick
import qs
import qs.components
import qs.services

// Launchpad is created on open (shell.qml LazyLoader), so its icons used to decode then: the
// first frames showed empty cells or bare tiles that filled in over about 100 ms. This keeps
// the first page's AppIcons alive, never drawn (opacity 0), in the always-mapped wallpaper
// window of the same screen: the decoded images stay referenced in Qt's pixmap cache (same url
// and size, so Launchpad's own Images find them at once) and the tile shape checks
// (iconshape.js) are cached before the first open. About 1.5 MB at 2x for 35 icons of 52 pt.
Item {
    id: pre
    required property var screen
    visible: screen === Panels.screen       // Launchpad opens on the primary screen
    opacity: 0
    enabled: false
    readonly property int count: Theme.launchpad.columns
        * Theme.launchpad.rowsFor(Math.round((screen ? screen.height : 0) * Theme.launchpad.heightFraction))

    Repeater {
        model: pre.visible ? Apps.sortedEntries.slice(0, pre.count) : []
        AppIcon {
            required property var modelData
            size: Theme.launchpad.iconSize
            icon: modelData.icon
            appId: modelData.id
        }
    }
}
