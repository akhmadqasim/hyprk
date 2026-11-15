import QtQuick
import "../../.."
import "../../../HyprK"

// A colour well as the Display pane draws it: a 48 x 24 capsule, the colour inside a light rim (acc-display-01-*.png).
// A click sends `clicked` (the Mac opens the Colors panel, R14.4); `active`: the panel is open for this well, drawn
// with the accent ring of live/settings-r14/acc-display--colour-well-dark.png.
Rectangle {
    id: w
    property color value: "#FFFFFF"
    property bool active: false
    signal clicked()
    width: 48; height: 24; radius: 12
    color: active ? Tokens.accent : Theme.dark ? Qt.rgba(1, 1, 1, 0.25) : "#FFFFFF"
    border.width: 0.5; border.color: Qt.rgba(0, 0, 0, 0.15)
    Rectangle { anchors.fill: parent; anchors.margins: 3; radius: height / 2; color: parent.value
                border.width: 0.5; border.color: Qt.rgba(0, 0, 0, 0.1) }
    MouseArea { anchors.fill: parent; onClicked: w.clicked() }
}
