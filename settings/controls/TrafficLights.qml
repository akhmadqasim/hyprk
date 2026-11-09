import QtQuick
import ".."

// Close / minimize / zoom. Glyphs appear when hovering the group, like macOS.
Row {
    id: tl
    property bool active: true
    signal closeClicked()
    signal minimizeClicked()
    signal zoomClicked()
    spacing: Theme.lights.spacing

    HoverHandler { id: hover }

    Repeater {
        model: [
            { c: Theme.lights.close, g: "close", s: "closeClicked" },
            { c: Theme.lights.minimize, g: "remove", s: "minimizeClicked" },
            { c: Theme.lights.zoom, g: "open_in_full", s: "zoomClicked" }
        ]
        Rectangle {
            required property var modelData
            width: Theme.lights.size; height: width; radius: width / 2
            color: tl.active || hover.hovered ? modelData.c : Theme.lights.inactive
            border.color: Theme.lights.border; border.width: 0.5
            Text {
                anchors.centerIn: parent
                visible: hover.hovered
                text: modelData.g; font.family: Theme.fontGlyph
                font.pixelSize: modelData.g === "open_in_full" ? parent.width * 0.6 : parent.width * 0.75
                color: Theme.lights.glyph
            }
            MouseArea { anchors.fill: parent; onClicked: tl[modelData.s]() }
        }
    }
}
