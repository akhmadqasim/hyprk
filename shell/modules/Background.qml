import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.services
import "../lib/menus.js" as Menus

// Desktop wallpaper on the background layer. The same image (blurred) is
// the backdrop of every glass surface, so both stay in sync.
ShellWindow {
    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    color: Theme.dark ? "#1c1c1e" : "#3a6fb0"
    namespace: "hyprk-wallpaper"
    WlrLayershell.layer: WlrLayer.Background

    // desktop right-click: Finder desktop menu
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: m => Panels.openContext(Menus.desktop(), m.x, m.y, false, screen)
    }

    Image {
        z: -1
        anchors.fill: parent
        source: Wallpaper.url
        // decoded at the logical size: the wallpaper is soft, and at 4K/1.5 the full
        // pixel size costs ~18 MB more for no visible gain (PERF.md)
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
    }
}
