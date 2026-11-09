import QtQuick
import "lib/symbols.js" as Symbols

// Vector glyph from lib/symbols.js. The SVG is drawn opaque and alpha comes from opacity,
// because Qt SVG does not take #AARRGGBB colors.
Image {
    id: root

    property string name
    property real size: 16
    property color color: Theme.color.label
    property color knockColor: "white"

    function hex(c) { return Qt.rgba(c.r, c.g, c.b, 1).toString(); }

    width: size
    height: size
    opacity: color.a
    sourceSize: Qt.size(Math.ceil(size * 2), Math.ceil(size * 2))
    smooth: true
    source: name ? Symbols.url(name, hex(color), hex(knockColor)) : ""
}
