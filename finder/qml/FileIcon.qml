import QtQuick
import "lib/files.js" as Files
import "lib/icons.js" as Icons
import "lib/macicons.js" as MacIcons
import HyprK

// Icon for one entry, best first: content thumbnail (images, PDFs, videos with a cached
// thumbnail; generated off the UI thread by image://thumb), app icon (the macOS icon from
// themes/icons/apps when themes/icons/apple-map.txt has one, as the Dock shows it, else the host
// icon theme on a squircle tile), the macOS icon from themes/icons/system, and the drawn SVG
// icon when those PNGs are missing.
Item {
    id: root

    required property var entry
    property real size: 64

    readonly property string kind: Files.iconClass(entry)
    // text: only real text/* types, which is what thumbnails.cpp can render (not json, scripts...)
    readonly property bool wantsThumb: entry.size > 0 && (kind === "image" || kind === "pdf" || kind === "video"
                                                          || (entry.mime || "").indexOf("text/") === 0)
    // share of the box a thumbnail fills; the icon grid passes less because its box includes
    // the macOS PNGs' padding (ref: 68 px thumbnails in a 77 px icon)
    property real thumbScale: 0.94
    property bool thumbFailed: false
    property bool sysFailed: false   // a PNG missing from themes/icons/system -> drawn icon
    onEntryChanged: { thumbFailed = false; sysFailed = false; }
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
            width: root.size * root.thumbScale
            height: root.size * root.thumbScale
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

    // mapped macOS icon of a .desktop app: the same table as the shell's Dock (apple-map.txt)
    readonly property string macApp: root.kind === "app" && typeof startup !== "undefined" && startup.hasAppIcons
                                     ? MacIcons.lookup([entry.appId || "", entry.icon || ""]) : ""

    // .desktop app icon on the macOS 26 tile (HyprK AppIconTile); its body
    // matches the padding of the macOS PNGs used for the other icons. A mapped macOS icon is
    // drawn as it is (it is already a squircle), everything else goes through the host theme.
    AppIconTile {
        id: appIcon
        visible: root.kind === "app" && status === Image.Ready
        anchors.centerIn: parent
        size: root.size
        trusted: root.macApp !== ""
        source: root.macApp !== "" ? "file://" + startup.iconRoot + "/" + MacIcons.file(root.macApp)
              : root.kind === "app" && root.entry.icon ? "image://icon/" + root.entry.icon : ""
    }

    Image {
        id: plain
        visible: !thumbBox.visible && !appIcon.visible
        anchors.fill: parent
        asynchronous: sysSource !== ""   // inline SVG fallbacks load synchronously, no blank frame
        sourceSize: Qt.size(root.px, root.px)
        readonly property string sysSource: root.sysFailed ? "" : Theme.sysIcon(root.sysName, root.px, root.kind === "folder",
                                                                                     root.kind === "folder" && Files.hasTags(root.entry) ? Theme.color.tagColors[root.entry.tags[0]] : "")
        onStatusChanged: if (status === Image.Error && sysSource) root.sysFailed = true
        source: sysSource
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
            size: Math.round(root.size * 0.135)
            weight: Typography.semibold
        }
    }
}
