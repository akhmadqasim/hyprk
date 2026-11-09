import QtQuick
import Quickshell
import Quickshell.Wayland
import qs
import qs.services
import "../lib/menus.js" as Menus

// Desktop wallpaper on the background layer. The same image (blurred) is
// the backdrop of every glass surface, so both stay in sync.
PanelWindow {
    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    color: Theme.dark ? "#1c1c1e" : "#3a6fb0"
    WlrLayershell.namespace: "hyprk-wallpaper"
    WlrLayershell.layer: WlrLayer.Background

    // desktop right-click: Finder desktop menu
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: m => Panels.openContext(Menus.desktop(), m.x, m.y, false)
    }

    Image {
        z: -1
        anchors.fill: parent
        source: Wallpaper.wallpaper ? "file://" + Wallpaper.wallpaper : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
    }
}
