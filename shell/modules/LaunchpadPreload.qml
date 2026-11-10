import QtQuick
import qs
import qs.components
import qs.services

// The Applications window (ApplicationsWindow.qml) is created on open, so its icons would decode
// then and fill in over the first frames (the 27.2.1 Mac also fills them in over about 0.5 s; ours
// are complete in the first frame). This keeps the first screen of its "All" grid as AppIcons
// alive, never drawn (opacity 0), in the always-mapped wallpaper window of the primary screen: the
// decoded images stay referenced in Qt's pixmap cache (same url and size, so the window's own
// Images find them at once) and the tile shape checks (iconshape.js) are cached before the first
// open. About 2 MB at 2x for 28 icons of 64 pt. (Name kept: Background.qml instantiates it.)
Item {
    id: pre
    required property var screen
    visible: screen === Panels.screen       // the window opens on the focused screen; most often the primary
    opacity: 0
    enabled: false

    Repeater {
        model: pre.visible ? Apps.sortedEntries.slice(0, AppsView.metrics.firstScreen) : []
        AppIcon {
            required property var modelData
            size: AppsView.metrics.iconSize
            icon: modelData.icon
            appId: modelData.id
        }
    }
}
