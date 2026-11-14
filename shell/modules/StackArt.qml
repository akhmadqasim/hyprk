import QtQuick
import qs
import qs.HyprK
import qs.services

// One item of the Downloads stack drawn in its box (`size` x `size`): on the Dock tile's pile (Dock.qml) and in the
// stack's fan and grid (DockStack.qml). `file`: {path, dir, image, zip} or {finder: true} for the "Open in Finder" /
// "N More in Finder" slot.
//   a picture: its own thumbnail, fitted to Theme.dock.stack.photoFit of the box (dock-dark.png)
//   a .zip, .pdf or plain text file (`doc`): the Mac's page for that type (NSWorkspace renders doc-zip / doc-pdf /
//           doc-txt@77pt, 154 px, light = dark, Q-finder-31; the three pages have the same 100 x 132 px face), its
//           face Theme.dock.stack.zipScale of the box (dock-dark.png, measured on the ZIP). 154 px is all the Mac
//           sent: sharp up to 77 pt boxes
//   a folder / anything else: the macOS folder / generic document icon filling the box
//   the Finder slot: the Finder icon (guessed: the Mac's art for that slot was not captured)
//   other document types (Dock.qml docArt): IconServices' page for the type rebuilt by themes/icons/tools/build-docs.py
//           (154 px, no text), the extension drawn over it as the recipe places it (ICONS-REA-27.2.1.md part 2)
// Not done: the generic page, and Quick Look thumbnails of documents (the Mac's stack may show a PDF's first page
// instead of the PDF icon: not captured).
Item {
    id: root

    property var file: ({})
    property real size: 64
    // the largest size this item is drawn at (the Dock's magnified tile): the textures load once at that size and
    // only scale, so magnification does not reload (and blank) them every frame
    property real loadSize: size
    property real dpr: 1

    width: size
    height: size

    // a picture Qt cannot decode (judge #15: a blank cell) falls back to the image document page, as IconServices
    // draws an image file without a thumbnail (ImageDocument, ICONS-REA-27.2.1.md)
    readonly property bool photo: !!root.file.image && thumb.status !== Image.Error
    readonly property string docName: root.file.doc || (root.file.image ? "ImageDocument" : "")
    Image {
        id: thumb
        visible: root.photo
        anchors.centerIn: parent
        width: root.size * Theme.dock.stack.photoFit
        height: width
        fillMode: Image.PreserveAspectFit
        source: root.file.image ? "file://" + root.file.path : ""
        readonly property real loadWidth: Math.max(root.size, root.loadSize) * Theme.dock.stack.photoFit
        sourceSize: Qt.size(Math.ceil(loadWidth * root.dpr), Math.ceil(loadWidth * root.dpr))
        asynchronous: true
        cache: false
        smooth: true
    }
    AppIconTile {
        id: page
        visible: !root.photo
        anchors.centerIn: parent
        size: root.size * (root.docName ? Theme.dock.stack.zipScale : 1)
        loadSize: Math.max(root.size, root.loadSize) * (root.docName ? Theme.dock.stack.zipScale : 1)
        trusted: true
        dpr: root.dpr
        source: root.photo ? "" : "file://" + Apps.iconDir + "/system/"
                + (root.file.finder ? "FinderIcon-512" : root.file.dir ? "GenericFolderIcon-512"
                   : root.docName ? root.docName + "-154" : "GenericDocumentIcon-512") + ".png"
    }
    // the extension on a composed page, in the 77 pt art's own points scaled to the drawn page: finder/qml/lib/files.js
    // docText(77) = text rect x 18.5, w 40.5, baseline 67 from the top, 9.926 pt system font regular, ink 182 grey
    // (measured on the Mac's renders), scaled to w - 6 when wider
    Item {
        readonly property bool composed: !!root.docName && root.docName !== "ZipDocument" && root.docName !== "PdfDocument"
                                         && root.docName !== "TextDocument" && !!root.file.ext
        visible: composed && page.visible
        anchors.centerIn: page
        width: page.size
        height: page.size
        readonly property real k: page.size / 77
        Text {
            id: ext
            text: parent.composed ? root.file.ext : ""
            // the box is 0 for a moment while the fan builds its items: a 0 pixel size makes QFont warn (x7..8 per fan
            // open, judge-95-16), so the size waits for a real box (the text is not drawn at size 0 anyway)
            font: Typography.font(parent.k > 0 ? 9.92578125 * parent.k : 1, Typography.regular)
            color: Qt.rgba(182 / 255, 182 / 255, 182 / 255, 1)
            readonly property real fit: implicitWidth + 6 * parent.k > 40.5 * parent.k ? (40.5 - 6) * parent.k / implicitWidth : 1
            x: (18.5 + 40.5 / 2) * parent.k - implicitWidth / 2
            y: 67 * parent.k - baselineOffset
            scale: fit
            transformOrigin: Item.Bottom
        }
    }
}
