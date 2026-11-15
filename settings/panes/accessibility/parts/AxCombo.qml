import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Effects
import "../../.."
import "../../../HyprK"

// A combo box (Zoom's modifier key, ax-acc-zoom: 150 x 24, its button 23.5 x 17.5 at 122.5, 3): the value in a field
// and a chevron.down button at its end. The button opens the list (MAC-ANSWERS-14.md R14.4, live/settings-r14/
// acc-zoom--combo-dark.png): 158 x 64 for three rows, directly under the field and 4 pt wider on each side; rows 18 pt
// in a 5 pt padding, the text 19.5 pt in, the current row on the accent with white text. A click on a row sends
// `activated` (the caller moves currentIndex), Escape or a press outside closes the list. `model` empty: the field shows `text` and the button only takes the press.
Rectangle {
    id: c
    property string text: model.length > 0 && currentIndex >= 0 ? model[currentIndex] : ""
    property var model: []
    property int currentIndex: 0
    signal activated(int index)
    readonly property bool opened: list.visible
    function open() { if (model.length > 0) list.open(); }
    function close() { list.close(); }
    width: 150; height: 24; radius: 6
    color: Theme.dark ? Qt.rgba(0, 0, 0, 0.3) : "#FFFFFF"   // acc-live-captions-00-dark.png: darker than the card
    border.width: 0.5; border.color: Theme.dark ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(0, 0, 0, 0.12)
    opacity: enabled ? 1 : 0.5
    Text {
        x: 8; anchors.verticalCenter: parent.verticalCenter
        text: c.text
        font: Typography.body
        color: Theme.label
    }
    Rectangle {
        objectName: "comboButton"
        x: 122.5; y: 3; width: 23.5; height: 17.5; radius: 5
        color: Tokens.control.pushFill
        Rectangle { anchors.fill: parent; radius: parent.radius; visible: ma.pressed || list.visible; color: Tokens.control.pressOverlay }
        SfSymbol { anchors.centerIn: parent; name: "chevron.down"; pointSize: 8.5; weight: "regular"; color: Theme.label }
        MouseArea { id: ma; anchors.fill: parent; onPressed: list.visible ? c.close() : c.open() }
    }
    C.Popup {
        id: list
        objectName: "comboList"
        x: -4; y: c.height + 2
        width: c.width + 8; height: 10 + 18 * c.model.length
        padding: 5
        popupType: C.Popup.Item
        enter: null; exit: null
        focus: true                      // Escape reaches the list (a shortcut outside an open popup is blocked)
        closePolicy: C.Popup.CloseOnEscape | C.Popup.CloseOnPressOutsideParent
        background: Item {
            RectangularShadow { anchors.fill: parent; radius: 8; blur: 24; color: Qt.rgba(0, 0, 0, 0.25) }
            Rectangle {
                anchors.fill: parent; radius: 8
                color: Tokens.dark ? Qt.rgba(37 / 255, 38 / 255, 44 / 255, 1) : Qt.rgba(249 / 255, 249 / 255, 249 / 255, 1)
                border.width: 0.5; border.color: Tokens.dark ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.2)
            }
        }
        Column {
            Repeater {
                model: c.model
                Rectangle {
                    required property string modelData
                    required property int index
                    readonly property bool on: index === c.currentIndex
                    objectName: "comboRow" + index
                    width: list.width - 10; height: 18; radius: 5
                    color: on ? Tokens.accent : "transparent"
                    Text {
                        x: 14.5; anchors.verticalCenter: parent.verticalCenter
                        text: modelData; font: Typography.body
                        color: parent.on ? "white" : Theme.label
                    }
                    MouseArea { anchors.fill: parent; onClicked: { c.close(); c.activated(index); } }
                }
            }
        }
    }
}
