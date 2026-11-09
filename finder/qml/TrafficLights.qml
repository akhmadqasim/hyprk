import QtQuick

// Close / minimize / zoom. Glyphs appear on hover over the group, like macOS.
Row {
    id: root

    required property var window
    property bool active: true
    spacing: Theme.lights.spacing

    HoverHandler { id: hover }

    Repeater {
        model: [
            { glyph: "xmark", color: Theme.color.close, act: () => root.window.close() },
            { glyph: "minus", color: Theme.color.minimize, act: () => root.window.showMinimized() },
            { glyph: "zoom", color: Theme.color.zoom,
              act: () => root.window.visibility === Window.Maximized ? root.window.showNormal() : root.window.showMaximized() }
        ]

        Rectangle {
            id: light
            required property var modelData
            width: Theme.lights.size
            height: width
            radius: width / 2
            color: root.active || hover.hovered ? modelData.color : Theme.color.lightInactive
            border.width: 0.5
            border.color: Theme.color.lightRim

            Rectangle {   // pressed darkening
                anchors.fill: parent
                radius: parent.radius
                color: "black"
                opacity: tap.pressed ? 0.18 : 0
            }
            Symbol {
                anchors.centerIn: parent
                visible: hover.hovered
                name: light.modelData.glyph
                size: parent.width * 0.62
                color: Theme.color.lightGlyph
            }
            TapHandler {
                id: tap
                onTapped: light.modelData.act()
            }
        }
    }
}
