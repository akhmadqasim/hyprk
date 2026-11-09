import QtQuick
import Quickshell.Widgets
import qs
import qs.services

// App icon the macOS 26 way: extracted macOS icons draw as they are; any other
// icon (Linux themes, mixed shapes) is placed on a light squircle plate, like
// Tahoe does for icons that are not in the new format.
Item {
    id: root

    property string icon
    property string appId
    property real size: 48
    readonly property bool plated: !Apps.isMacIcon(icon, appId)

    implicitWidth: size
    implicitHeight: size

    // macOS icon art leaves a margin inside the tile; the plate matches that body
    Rectangle {
        visible: root.plated
        anchors.centerIn: parent
        width: root.size * Theme.appIcon.body
        height: width
        radius: width * Theme.appIcon.radius
        color: Theme.appIcon.plate
        border.width: 1
        border.color: Theme.appIcon.plateEdge
    }
    IconImage {
        anchors.centerIn: parent
        implicitSize: root.plated ? root.size * Theme.appIcon.body * Theme.appIcon.inner : root.size
        source: Apps.iconUrl(root.icon, root.appId)
        asynchronous: true
        mipmap: true
    }
}
