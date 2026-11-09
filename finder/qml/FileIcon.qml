import QtQuick
import "lib/files.js" as Files
import "lib/icons.js" as Icons

// Icon for one entry, best first: content thumbnail (images, PDFs, videos with a cached
// thumbnail; generated off the UI thread by image://thumb), app icon, the macOS icon from
// themes/icons/system, and the drawn SVG icon when those PNGs are missing.
Item {
    id: root

    required property var entry
    property real size: 64

    readonly property string kind: Files.iconClass(entry)
    readonly property bool wantsThumb: (kind === "image" || kind === "pdf" || kind === "video" || kind === "text") && entry.size > 0
    property bool thumbFailed: false
    onEntryChanged: thumbFailed = false
    readonly property bool showThumb: wantsThumb && !thumbFailed && size >= 16

    // macOS PNG for the non-thumbnail case
    readonly property string sysName: kind === "folder" ? (Theme.folderIcons[entry.path] || "GenericFolderIcon")
                                    : kind === "app" ? "GenericApplicationIcon"
                                    : "GenericDocumentIcon"

    // decode at a power of two (>= 2x) so zoom steps reuse cached images and thumbnails
    readonly property int px: Math.pow(2, Math.ceil(Math.log2(Math.max(16, size * 2))))

    width: size
    height: size

    // Thumbnail: fills the icon box, thin border and soft shadow like Finder.
    Item {
        id: thumbBox
        visible: thumb.status === Image.Ready
        anchors.centerIn: parent
        width: thumb.paintedWidth
        height: thumb.paintedHeight

        // matches the corner rounding baked in by thumbnails.cpp (kCornerRatio)
        readonly property real radius: Math.max(width, height) * 0.06
        // soft shadow: two offset rounded layers (no blur effects, they need a GPU layer)
        Rectangle {
            x: -2; y: -1
            width: parent.width + 4; height: parent.height + 4
            radius: parent.radius + 2
            color: Qt.rgba(0, 0, 0, 0.05)
        }
        Rectangle {
            x: -1; y: 0
            width: parent.width + 2; height: parent.height + 2
            radius: parent.radius + 1
            color: Qt.rgba(0, 0, 0, 0.08)
        }
        Image {
            id: thumb
            // Theme.grid.iconSize includes the macOS PNGs' padding; thumbnails fill only the art
            // area inside it (ref: 68 px in a 77 px icon)
            width: root.size * 0.88
            height: root.size * 0.88
            x: (thumbBox.width - width) / 2
            y: (thumbBox.height - height) / 2
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            source: root.showThumb ? "image://thumb/" + encodeURIComponent(root.entry.path) : ""
            sourceSize: Qt.size(root.px, root.px)
            onStatusChanged: if (status === Image.Error) root.thumbFailed = true
        }
        Rectangle {   // hairline frame
            anchors.fill: parent
            color: "transparent"
            radius: thumbBox.radius
            border.width: 0.5
            border.color: Qt.rgba(0, 0, 0, 0.10)
        }
    }

    Image {
        id: appIcon
        visible: root.kind === "app" && status === Image.Ready
        anchors.fill: parent
        anchors.margins: root.size * 0.06
        asynchronous: true
        source: root.kind === "app" && root.entry.icon ? "image://icon/" + root.entry.icon : ""
        sourceSize: Qt.size(root.px, root.px)
    }

    Image {
        id: plain
        visible: !thumbBox.visible && !appIcon.visible
        anchors.fill: parent
        asynchronous: true
        sourceSize: Qt.size(root.px, root.px)
        source: Theme.sysIcon(root.sysName, root.px, root.kind === "folder")
             || (root.kind === "folder"
                 ? Icons.folder(Theme.color.folderBack.toString(), Theme.color.folderFront.toString(), Theme.color.folderTop.toString())
                 : Icons.document(Theme.dark))

        Image {
            anchors.fill: parent
            visible: root.kind === "archive"
            source: visible ? Icons.zipper() : ""
            sourceSize: parent.sourceSize
        }
        TextLabel {
            visible: root.kind !== "folder" && root.kind !== "app" && root.size >= 32
            anchors.horizontalCenter: parent.horizontalCenter
            y: root.size * 0.70
            text: Files.badge(root.entry)
            color: "#8E8E93"
            font.pixelSize: Math.round(root.size * 0.135)
            weight: Font.DemiBold
        }
    }
}
