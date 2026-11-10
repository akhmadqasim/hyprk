import QtQuick
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
    property real loadSize: size
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
    // Plain Image, not IconImage: IconImage reloads the file whenever its size changes, so the
    // magnifying Dock reloaded (and blanked) every icon on every frame. The image is loaded once
    // at loadSize and scaled; set loadSize to the largest size the icon is drawn at.
    Image {
        readonly property real k: root.plated ? Theme.appIcon.body * Theme.appIcon.inner : 1
        readonly property int loadPx: Math.ceil(root.loadSize * k)
        anchors.centerIn: parent
        width: root.size * k
        height: width
        sourceSize: Qt.size(loadPx, loadPx)
        fillMode: Image.PreserveAspectFit
        source: Apps.iconUrl(root.icon, root.appId)
        asynchronous: true
        smooth: true
        mipmap: true
    }
}
