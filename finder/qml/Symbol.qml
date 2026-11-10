import QtQuick
import "lib/symbols.js" as Symbols
import "lib/sf.js" as SF

// SF Symbol glyph: the real outline rendered on macOS 27.2.1 (themes/icons/sf-symbols, via lib/sf.js),
// tinted to `color`; the hand-drawn glyphs in lib/symbols.js only for names without an SVG.
// Drawn opaque with alpha from opacity, because Qt SVG does not take #AARRGGBB colors.
// Rasterised once per name, colour and size (Image cache), never per frame.
Item {
    id: root

    property string name
    property real size: 16                           // layout box, size x size
    property color color: Theme.color.label
    property color knockColor: "white"               // hand-drawn fallback only
    property real pointSize: Symbols.pointSize(name, size)
    property string weight: "regular"                // the 27.2.1 Finder toolbar glyphs match regular

    readonly property string key: Symbols.sfKey(name, weight)
    readonly property var box: key ? SF.layout(key, pointSize, size, false) : null

    function hex(c) { return Qt.rgba(c.r, c.g, c.b, 1).toString(); }

    implicitWidth: size
    implicitHeight: size
    width: size
    height: size

    Image {
        x: root.box ? root.box.x : 0
        y: root.box ? root.box.y : 0
        width: root.box ? root.box.w : root.size
        height: root.box ? root.box.h : root.size
        opacity: root.color.a
        // device pixels: Qt applies the devicePixelRatio itself only to URLs ending in "svg"
        sourceSize: Qt.size(Math.ceil(width * Screen.devicePixelRatio), Math.ceil(height * Screen.devicePixelRatio))
        smooth: true
        source: !root.name ? "" : root.box ? SF.url(root.key, root.hex(root.color), root.box.vb)
                                           : Symbols.url(root.name, root.hex(root.color), root.hex(root.knockColor))
    }
}
