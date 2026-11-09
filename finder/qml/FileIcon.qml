import QtQuick
import Finder.Native
import "lib/files.js" as Files
import "lib/icons.js" as Icons

// Icon for one entry: real thumbnail (image file or freedesktop cache), app icon,
// drawn folder, or the generic document as the universal fallback.
Item {
    id: root

    required property var entry
    property real size: 64

    readonly property string kind: Files.iconClass(entry)
    // Image files decode directly; other types use the thumbnail cache when GNOME made one.
    readonly property string thumbSource: {
        if (entry.isDir || kind === "app") return "";
        if (Files.isImage(entry)) return Files.fileUrl(entry.path);
        return FileOps.thumbnail(entry.path);
    }
    property bool thumbFailed: false
    onEntryChanged: thumbFailed = false
    readonly property bool showThumb: thumbSource !== "" && !thumbFailed

    width: size
    height: size

    Image {
        id: thumb
        visible: root.showThumb && status === Image.Ready
        anchors.fill: parent
        anchors.margins: root.size * 0.04
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        cache: true
        source: root.showThumb ? root.thumbSource : ""
        sourceSize: Qt.size(Math.ceil(root.size * 2), Math.ceil(root.size * 2))
        onStatusChanged: if (status === Image.Error) root.thumbFailed = true

        Rectangle {
            x: (parent.width - parent.paintedWidth) / 2 - 1
            y: (parent.height - parent.paintedHeight) / 2 - 1
            width: parent.paintedWidth + 2
            height: parent.paintedHeight + 2
            color: "transparent"
            radius: 3
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.12)
        }
    }

    Image {
        id: appIcon
        visible: root.kind === "app" && status === Image.Ready
        anchors.fill: parent
        anchors.margins: root.size * 0.06
        asynchronous: true
        source: root.kind === "app" && root.entry.icon ? "image://icon/" + root.entry.icon : ""
        sourceSize: Qt.size(Math.ceil(root.size * 2), Math.ceil(root.size * 2))
    }

    // drawn fallback
    Image {
        id: drawn
        visible: !thumb.visible && !appIcon.visible
        anchors.fill: parent
        sourceSize: Qt.size(Math.ceil(root.size * 2), Math.ceil(root.size * 2))
        source: root.kind === "folder"
            ? Icons.folder(Theme.color.folderBack.toString(), Theme.color.folderFront.toString(), Theme.color.folderTop.toString())
            : Icons.document(Theme.dark)

        Image {
            anchors.fill: parent
            visible: root.kind === "archive"
            source: visible ? Icons.zipper() : ""
            sourceSize: parent.sourceSize
        }
        TextLabel {
            visible: root.kind !== "folder" && root.size >= 32
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -root.size * 0.02
            y: root.size * 0.70
            text: Files.badge(root.entry)
            color: "#8E8E93"
            font.pixelSize: Math.round(root.size * 0.135)
            weight: Font.DemiBold
        }
    }
}
