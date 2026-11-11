import QtQuick
import "lib/files.js" as Files

// Finder's tag dots for a list or column row (Q-finder-14/15): 10 pt circles, each extra tag 5 pt further and
// behind the previous, with a 0.5 pt ring.
Image {
    property var tags: []
    property color ring: "white"
    visible: tags.length > 0
    width: Files.tagDotsWidth(tags.length)
    height: 10
    sourceSize: Qt.size(2 * width, 2 * height)
    source: visible ? Files.tagDotsUrl(tags, Theme.color.tagDotColors, ring.toString(), 0) : ""
}
