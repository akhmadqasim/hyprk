import QtQuick
import "../../.."
import "../../../HyprK"

// The strip under a list with its Add / Delete / Options… buttons (ax-acc-subtitles-and-captioning: 24 tall, Add 9.5 pt
// ink 7.5 in, Delete 32.5 in; Switch Control adds Options… 56.5 in). glyphs: [{ name, on }]
Rectangle {
    id: bar
    property var glyphs: []
    signal activated(int index)
    width: parent ? parent.width : 0
    height: 24
    // acc-subtitles-and-captioning-00-*.png: 240 on the 247 card, 48 on 37; the line over it 229 / 58
    color: Theme.dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.03)
    Rectangle { width: parent.width; height: 1; color: Theme.dark ? Qt.rgba(1, 1, 1, 0.096) : Qt.rgba(0, 0, 0, 0.073) }
    Repeater {
        model: bar.glyphs
        Item {
            required property var modelData
            required property int index
            x: 25 * index; width: 25; height: bar.height
            SfSymbol {
                anchors.centerIn: parent
                name: modelData.name; pointSize: modelData.name === "ellipsis.circle" ? 11.5 : 11.7
                color: modelData.on ? Theme.secondaryLabel : Tokens.control.disabledText
            }
            Rectangle { visible: index > 0; y: 5; width: 1; height: bar.height - 10; color: Theme.separator }
            MouseArea { anchors.fill: parent; enabled: modelData.on; onClicked: bar.activated(index) }
        }
    }
}
