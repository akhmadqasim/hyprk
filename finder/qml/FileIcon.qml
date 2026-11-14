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
    readonly property bool isText: (entry.mime || "").indexOf("text/") === 0
    // 27.2.1 (Q-finder-31, live/finder/icons-live): a text file is a Quick Look thumbnail at 64 pt (txt-thumb) but the
    // lined text-document icon in the 16 pt list (txt@16pt-list); below 32 pt, and wherever there is no thumbnail
    // (an empty file, a failed render), it takes the NSWorkspace render (icons-rendered/doc-txt@16..77pt, light = dark
    // byte for byte), copied to icons/, never the blank generic page
    readonly property bool smallText: isText && size < 32
    readonly property bool wantsThumb: entry.size > 0 && (kind === "image" || kind === "pdf" || kind === "video"
                                                          || (isText && !smallText))
    readonly property int textIconPt: [16, 18, 32, 48, 64, 77].find(s => size <= s) || 77
    // a ZIP archive is the Mac's own icon too (icons-rendered/doc-zip@16..77pt, light = dark byte for byte, Q-finder-31):
    // the page with its zipper and "ZIP". It was the blank generic page with a drawn zipper and a text badge. Other
    // archive types (tar, 7z ...) have no Mac render in reference/ and keep the drawn one
    readonly property bool zipIcon: docKind === "zip"
    // the 27.2.1 document icon for this type (Files.macDocKind; the plain icon only shows while there is no
    // thumbnail): the Mac's renders for .txt, .zip and .pdf (icons-rendered doc-txt / doc-zip / doc-pdf@16..77pt),
    // IconServices' composition rebuilt by themes/icons/tools/build-docs.py for docx, xlsx / csv, pptx, html, audio,
    // video, images and other text (reference/re/27.2.1/ICONS-REA-27.2.1.md part 2); "" = the generic page
    readonly property string docKind: Files.macDocKind(entry)
    readonly property string macDoc: docKind !== "" ? "doc-" + docKind : ""
    // the extension text over the composed pages (their art leaves it out: IconServices takes it from each file)
    readonly property var docText: macDoc !== "" && !Files.macDocHasText(docKind) ? Files.docText(size) : null
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
    // Every icon is drawn by HyprK AppIconTile (trusted: no tile, the art as it is): its shader resamples the texture
    // in one Lanczos pass on the device pixel grid, where a plain Image blurs whatever is not drawn 1:1 (a 128 px
    // folder at 102 px on a 1.6 output kept 0.4-0.6 of a Lanczos downscale's detail).
    // The window's real device pixel ratio (main.cpp; Screen.devicePixelRatio is 2 on a 1.6 output)
    readonly property real dpr: typeof windowInfo !== "undefined" && windowInfo && windowInfo.dpr > 0 ? windowInfo.dpr : Screen.devicePixelRatio
    // texture size for a themes/icons/system icon (128 and 512 px files): the 128 px file when it is drawn 1:1 or
    // at 2/3 and less, else the 512 halved to 256 up to 256 px, else the 512 (the rule of AppIconTile's app icons)
    // and halved while it is 4x the drawn size or more (16 pt list rows: 64 px). The provider returns exactly this
    // size (the "@px" of the id), whatever sourceSize Qt asks for
    readonly property int sysPx: {
        const exact = size * dpr;
        let px = Math.abs(128 - exact) < 0.5 || 128 >= 1.5 * exact ? 128 : exact <= 256.5 ? 256 : 512;
        while (px >= 4 * exact && px > 16) px /= 2;
        return px;
    }

    // AppIconTile draws its art with a ShaderEffect, which the software scene graph (QT_QPA_PLATFORM=offscreen, the
    // --shot renders) does not run: there the same sources go through a plain Image, so the shots show the icons
    readonly property bool software: GraphicsInfo.api === GraphicsInfo.Software

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
        AppIconTile {
            id: thumb
            size: root.size * root.thumbScale
            x: (thumbBox.width - width) / 2
            y: (thumbBox.height - height) / 2
            trusted: true
            source: root.showThumb ? "image://thumb/" + encodeURIComponent(root.entry.path) : ""
            decodeSize: root.px
            onStatusChanged: if (status === Image.Error) root.thumbFailed = true
        }
        Image {
            anchors.fill: thumb
            visible: root.software
            source: visible ? thumb.source : ""
            sourceSize: Qt.size(root.px, root.px)
            fillMode: Image.PreserveAspectFit
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
        dpr: root.dpr
        trusted: root.macApp !== ""
        // Icon & widget style (appearance.json iconStyle / iconStyleVariant): the icon's own rendition
        source: root.macApp !== "" ? "file://" + startup.iconRoot + "/"
                                       + MacIcons.styled(root.macApp, Theme.appearance.iconStyle, Theme.appearance.iconStyleVariant, Theme.dark)
              : root.kind === "app" && root.entry.icon ? "image://icon/" + root.entry.icon : ""
    }

    AppIconTile {
        id: plain
        visible: !thumbBox.visible && !appIcon.visible
        anchors.fill: parent
        size: root.size
        trusted: true
        dpr: root.dpr
        // a system icon at the size picked above; the text icon and the drawn SVG fallbacks at the drawn size
        decodeSize: sysSource !== "" && root.macDoc === "" ? Math.ceil(root.size) : 0
        readonly property string sysSource: root.sysFailed ? "" : Theme.sysIcon(root.sysName, root.sysPx,
                                                                                     root.kind === "folder" && Files.hasTags(root.entry) ? Theme.color.tagFolderColors[root.entry.tags[0]] : "")
        onStatusChanged: if (status === Image.Error && sysSource) root.sysFailed = true
        source: root.macDoc !== "" ? Qt.resolvedUrl("icons/" + root.macDoc + "@" + root.textIconPt + "pt.png")
             : sysSource
             || (root.kind === "folder"
                 ? Icons.folder(Theme.color.folderBack.toString(), Theme.color.folderFront.toString(), Theme.color.folderTop.toString())
                 : Icons.document(Theme.dark))

        Image {
            anchors.fill: parent
            visible: root.software
            source: visible ? plain.source : ""
            fillMode: Image.PreserveAspectFit
        }
        Image {
            anchors.fill: parent
            visible: root.kind === "archive" && !root.zipIcon
            source: visible ? Icons.zipper() : ""
            sourceSize: Qt.size(root.px, root.px)
        }
        // the extension on a composed page: the system font, regular, centred on the text rect, glyph bottom on its
        // bottom, scaled to the rect width - 6 when wider (Files.docText); ink 182 grey, measured on the Mac's renders
        // (CUIDesignLibrary colour 17, the same in light and dark)
        TextLabel {
            id: docLabel
            visible: root.docText !== null && text !== ""
            readonly property real fit: root.docText && implicitWidth + 6 > root.docText.w ? (root.docText.w - 6) / implicitWidth : 1
            x: root.docText ? root.docText.x + (root.docText.w - implicitWidth) / 2 : 0
            y: root.docText ? root.docText.baseline - baselineOffset : 0
            scale: fit
            transformOrigin: Item.Bottom
            text: Files.docTextFor(root.entry)
            color: Qt.rgba(182 / 255, 182 / 255, 182 / 255, 1)
            size: root.docText ? root.docText.size : 10
            weight: Typography.regular
        }
        // the generic page (no Mac render of it in reference/): the older drawn badge
        TextLabel {
            visible: root.kind !== "folder" && root.kind !== "app" && root.size >= 32 && root.macDoc === ""
            anchors.horizontalCenter: parent.horizontalCenter
            y: root.size * 0.70
            text: Files.badge(root.entry)
            color: "#8E8E93"
            size: Math.round(root.size * 0.135)
            weight: Typography.semibold
        }
    }
}
