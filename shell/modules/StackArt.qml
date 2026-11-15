import QtQuick
import QtQuick.Shapes
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
//   the Finder slot: a circle and an arrowshape.turn.up.right.fill arrow, drawn vibrant (finderArt below,
//           MOTION-REA Round 6, R6.2)
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
    // the Finder slot's look: "fan" (the "N More in Finder" / "Open in Finder" item of the fan) or "grid" (the grid's
    // "Open in Finder" cell): the Mac draws the two differently (finderArt)
    property string finderLook: "fan"

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
        visible: !root.photo && !root.file.finder
        anchors.centerIn: parent
        size: root.size * (root.docName ? Theme.dock.stack.zipScale : 1)
        loadSize: Math.max(root.size, root.loadSize) * (root.docName ? Theme.dock.stack.zipScale : 1)
        trusted: true
        dpr: root.dpr
        source: root.photo || root.file.finder ? "" : "file://" + Apps.iconDir + "/system/"
                + (root.file.dir ? "GenericFolderIcon-512"
                   : root.docName ? root.docName + "-154" : "GenericDocumentIcon-512") + ".png"
    }
    // The Finder slot, measured on the Mac at 2 px per pt (MOTION-REA-27.2.1.md Round 6, R6.2):
    //   fan (screens/27.2.1/dock/stack-fan-more-dark.png, "5 More in Finder", 64 box): a circle of 56 pt (0.875 of the
    //       box) with a 1 pt white ring at alpha .15 just inside its edge ((59,74,158) over (24,42,137)) and a 1 pt
    //       opaque black rim just outside it ((0,0,1), outer 116 px = 58 pt across both ways). Inside, the Mac shows the
    //       backdrop blurred, not darkened (inside (24,42,137) median, blue 130..144 at the four sides; just outside
    //       (6..43, 22..62, 106..185), mean (22,42,146)): ours draws no fill (no backdrop blur in this layer: the
    //       wallpaper shows through unblurred)
    //   grid (stack-grid-open-dark.png, "Open in Finder" cell, 100 pt icon box = cell 128 - 28, lib/dockstack.js
    //       gridSize): no fill, no black rim, a ring 64 pt across (128 px both ways; 0.64 of the box, inferred to scale
    //       with it), its stroke 2.33 pt (4 px full + one at .67)
    //   the arrow in both: plus-lighter +124 over what is under it: fan arrow (148,166,255) over the fill (24,42,137),
    //       grid arrow (207,222,255) and ring (207,223,255) over the glass (83,97,164) / (99 green): +124 / +125 in red
    //       and green, blue clipped. The arrow is SF arrowshape.turn.up.right.fill, traced from the grid cell (its
    //       subpixel 0.5 coverage outline, simplified to 0.12 pt; the symbol outline is not in themes/icons/sf-symbols
    //       and the OS's CoreGlyphs is not extracted): 32.9 x 27.9 pt in the 64 ring, its box centre (+0.5, -1.4) pt
    //       off the ring centre. The fan's arrow, turned back by the slot's 12 deg, is 28.9 x 24.1 pt = the same
    //       shape at 56 / 64 (28.8 x 24.4).
    // The disc and arrow turn and shrink with the item, as every fan item (R3.1). Seen in stack-fan-more-close-dark.mov
    // and not built: in the close's 3rd and 4th frames the disc's outline reads as a rounded square.
    Item {
        id: finderArt
        visible: !!root.file.finder
        readonly property bool grid: root.finderLook === "grid"
        readonly property real d: root.size * (grid ? 0.64 : 0.875)
        readonly property real k: d / (grid ? 64 : 56)      // pt of the measured art per drawn pt
        anchors.centerIn: parent
        width: d
        height: d
        Rectangle {   // fan: the black rim, 1 pt outside the circle
            visible: !finderArt.grid
            anchors.centerIn: parent
            width: parent.width + 2 * finderArt.k
            height: width
            radius: width / 2
            color: "transparent"
            border.width: finderArt.k
            border.color: "#000000"
        }
        Rectangle {   // fan: the white ring at .15, 1 pt inside the edge
            visible: !finderArt.grid
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.width: finderArt.k
            border.color: Qt.rgba(1, 1, 1, 0.15)
        }
        // plus-lighter +124 (shaders/plustext.frag: only the coverage is used, out = under + 124 x coverage)
        Item {
            anchors.fill: parent
            layer.enabled: finderArt.visible
            layer.smooth: true
            layer.effect: ShaderEffect {
                property real lift: 124 / 255
                fragmentShader: Qt.resolvedUrl("../shaders/plustext.frag.qsb")
            }
            // grid: the ring, a stroked circle (a Rectangle border of 2.33 pt drew 5 px at 2x, the Mac 4.67)
            Shape {
                id: ring
                visible: finderArt.grid
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer
                readonly property real w: 2.33 * finderArt.k
                ShapePath {
                    strokeWidth: ring.w
                    strokeColor: "#FFFFFF"
                    fillColor: "transparent"
                    PathAngleArc {
                        centerX: finderArt.d / 2
                        centerY: finderArt.d / 2
                        radiusX: (finderArt.d - ring.w) / 2
                        radiusY: radiusX
                        startAngle: 0
                        sweepAngle: 360
                    }
                }
            }
            Shape {
                // the traced outline in pt of the 64 ring, origin at the ring centre (y down)
                x: parent.width / 2
                y: parent.height / 2
                scale: finderArt.d / 64
                transformOrigin: Item.TopLeft
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    strokeWidth: -1
                    fillColor: "#FFFFFF"
                    PathSvg {
                        path: "M 1.75 -15.31 L 1 -14.75 L 0.83 -14.25 L 0.75 -7.73 L 0.25 -7.49 L -4.25 -6.95 L -6.25 -6.42 "
                              + "L -7.75 -5.79 L -9.55 -4.75 L -11.29 -3.25 L -12.92 -1.25 L -14.88 2.75 L -15.39 5.25 "
                              + "L -15.96 10.75 L -15.78 11.75 L -15.25 12.43 L -14.25 12.5 L -13.74 12.25 L -11.25 8.58 "
                              + "L -8.75 6.55 L -4.75 5.08 L 0.25 4.67 L 0.78 5.25 L 0.92 11.75 L 1.26 12.25 L 1.75 12.5 "
                              + "L 2.75 12.45 L 4.25 11.38 L 16.54 -0.25 L 16.83 -0.75 L 16.91 -1.75 L 16.4 -2.75 "
                              + "L 3.75 -14.59 L 2.75 -15.22 Z"
                    }
                }
            }
        }
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
