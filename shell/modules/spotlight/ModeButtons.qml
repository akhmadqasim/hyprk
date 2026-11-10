import QtQuick
import qs
import qs.components
import "../../lib/spotlight.js" as SL

// The four mode buttons to the right of the Spotlight bar (macOS 26/27: they appear when
// the pointer moves over Spotlight or a mode is active; Cmd+1..4 select them).
// Each is a glass circle; the active one is filled with the accent colour.
Row {
    id: buttons

    property string mode: ""
    property real originX: 0                // screen position of this row, for Glass sampling
    property real originY: 0
    property real reveal: 0                 // 0 hidden .. 1 shown
    readonly property int diameter: Theme.spotlight.barHeight
    signal picked(string mode)

    spacing: 10
    opacity: reveal
    visible: reveal > 0

    Repeater {
        model: SL.modes()
        delegate: Item {
            id: b
            required property var modelData
            required property int index
            readonly property bool on: buttons.mode === modelData.id
            width: buttons.diameter
            height: width

            Glass {
                anchors.fill: parent
                radius: width / 2
                sx: buttons.originX + b.x
                sy: buttons.originY
                tint: Theme.glass.tintStrong
            }
            Rectangle {
                anchors.fill: parent
                anchors.margins: 6
                radius: width / 2
                visible: b.on || hover.containsMouse
                color: b.on ? Theme.color.accent : Theme.spotlight.selection
            }
            Symbol {
                anchors.centerIn: parent
                name: b.modelData.symbol
                size: Theme.spotlight.iconSize
                color: b.on ? Theme.color.textOnAccent : Theme.color.label
            }
            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                onClicked: buttons.picked(b.on ? "" : b.modelData.id)
            }
        }
    }
}
