import QtQuick
import HyprK
import "lib/files.js" as Files

// The action bar under the gallery's info pane and the column view's preview (27.2.1 gallery-*.png,
// columns-*.png): 70 pt high in the content background, buttons at a 76 pt pitch around the middle, glyph centre
// 24 pt and an 11 pt label centre 48 pt from the top, grey (153,153,155) / (142,142,145) dark, 129 light. An image
// has Rotate Left, Markup and More\u2026, a PDF Markup and More...; other types were not captured: More... only.
// The column view draws a hairline above it, the gallery pane none. Only More... does something here (the item's
// context menu): Rotate Left and Markup have no tool behind them.
Item {
    id: root
    property var entry: null
    property bool line: false
    signal more(point pos)

    height: 70
    readonly property var actions: !entry ? []
        : Files.isImage(entry) ? [{ icon: "rotate.left", text: "Rotate Left" }, { icon: "markup", text: "Markup" }, { icon: "ellipsis", text: "More\u2026" }]
        : Files.iconClass(entry) === "pdf" ? [{ icon: "markup", text: "Markup" }, { icon: "ellipsis", text: "More\u2026" }]
        : [{ icon: "ellipsis", text: "More\u2026" }]
    // the gallery sets both to R9.3's single grey, (128) light / (142,143,145) dark, glyph and label alike
    property color ink: Theme.dark ? Qt.rgba(153 / 255, 153 / 255, 155 / 255, 1) : Qt.rgba(129 / 255, 129 / 255, 129 / 255, 1)
    property color text: Theme.dark ? Qt.rgba(142 / 255, 142 / 255, 145 / 255, 1) : Qt.rgba(129 / 255, 129 / 255, 129 / 255, 1)

    Rectangle { anchors.fill: parent; color: Theme.color.window }
    Rectangle { visible: root.line; width: parent.width; height: Pixel.stroke(0.5, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.color.pathBarLine }
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        Repeater {
            model: root.actions
            Item {
                id: button
                required property var modelData
                width: 76
                height: root.height
                // More...: the ellipsis in a ring (the glyph table has no ellipsis.circle), 14 pt like the others
                Rectangle {
                    visible: button.modelData.icon === "ellipsis"
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 24 - 7
                    width: 14; height: 14; radius: 7
                    color: "transparent"
                    border.width: 1
                    border.color: root.ink
                }
                Symbol {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 24 - height / 2
                    size: button.modelData.icon === "ellipsis" ? 9 : 16
                    name: button.modelData.icon
                    color: root.ink
                }
                TextLabel {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 48 - height / 2
                    text: button.modelData.text
                    color: root.text
                    size: Theme.font.small
                }
                TapHandler {
                    enabled: button.modelData.icon === "ellipsis"
                    onTapped: root.more(button.mapToItem(null, button.width / 2, 24))
                }
            }
        }
    }
}
