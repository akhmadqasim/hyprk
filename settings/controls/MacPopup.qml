import QtQuick
import QtQuick.Controls.Basic as C
import ".."

// Pop-up button: current value plus an up/down chevron; opens a menu
// with a checkmark on the current item.
Item {
    id: pop
    property var model: []          // array of strings
    property int currentIndex: 0
    property bool enabled_: true
    signal activated(int index)
    implicitHeight: Theme.control.popupHeight
    implicitWidth: label.implicitWidth + Theme.control.popupChevron + 8
    opacity: enabled_ ? 1 : 0.4

    Text {
        id: label
        anchors.right: chev.left; anchors.rightMargin: 7; anchors.verticalCenter: parent.verticalCenter
        text: pop.model.length > pop.currentIndex && pop.currentIndex >= 0 ? pop.model[pop.currentIndex] : ""
        font.family: Theme.fontText; font.pixelSize: Theme.font.body
        color: Theme.label
    }
    Rectangle { // ref: round chevron button
        id: chev
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        width: Theme.control.popupChevron; height: width; radius: width / 2
        color: ma.pressed || menu.visible ? Theme.controlFillPressed : Theme.controlFill
        Text {
            anchors.centerIn: parent
            text: "unfold_more"; font.family: Theme.fontGlyph; font.pixelSize: 15
            color: Theme.label
        }
    }
    // NSPopUpButton: the menu opens on mouse-down; press-drag-release picks the item under
    // the pointer, a plain click leaves the menu open.
    property int _dragIndex: -1
    MouseArea {
        id: ma; anchors.fill: parent; hoverEnabled: true; enabled: pop.enabled_
        property point pressAt
        property bool moved: false
        function itemAt(m) {
            const p = mapToItem(col, m.x, m.y);
            return p.x >= 0 && p.x < col.width && p.y >= 0 && p.y < col.height ? Math.floor(p.y / 24) : -1;
        }
        onPressed: m => { pressAt = Qt.point(m.x, m.y); moved = false; pop._dragIndex = -1; menu.open(); }
        onPositionChanged: m => {
            if (!pressed) return;
            if (Math.abs(m.x - pressAt.x) + Math.abs(m.y - pressAt.y) > 3) moved = true;
            if (moved) pop._dragIndex = itemAt(m);
        }
        onReleased: m => {
            const i = moved ? itemAt(m) : -1;
            pop._dragIndex = -1;
            if (!moved) return;                 // a plain click leaves the menu open
            if (i >= 0 && i !== pop.currentIndex) { pop.currentIndex = i; pop.activated(i); }
            menu.close();                       // released on an item or outside the menu
        }
    }

    C.Popup {
        id: menu
        y: -pop.currentIndex * 24 - 5
        x: pop.width - width
        padding: 5
        width: Math.max(pop.width + 20, col.implicitWidth + 10)
        background: Rectangle {
            radius: 10; color: Theme.menuFill
            border.color: Theme.dark ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.10)
        }
        Column {
            id: col
            Repeater {
                model: pop.model
                Rectangle {
                    required property int index
                    required property string modelData
                    width: menu.width - 10; height: 24; radius: 5
                    implicitWidth: t.implicitWidth + 44
                    readonly property bool hot: pop._dragIndex >= 0 ? pop._dragIndex === index : im.containsMouse
                    color: hot ? Theme.accent : "transparent"
                    Text {
                        x: 6; anchors.verticalCenter: parent.verticalCenter
                        visible: index === pop.currentIndex
                        text: "check"; font.family: Theme.fontGlyph; font.pixelSize: 14
                        color: parent.hot ? "white" : Theme.label
                    }
                    Text {
                        id: t
                        x: 26; anchors.verticalCenter: parent.verticalCenter
                        text: modelData; font.family: Theme.fontText; font.pixelSize: Theme.font.body
                        color: parent.hot ? "white" : Theme.label
                    }
                    MouseArea {
                        id: im; anchors.fill: parent; hoverEnabled: true
                        onClicked: { pop.currentIndex = index; pop.activated(index); menu.close(); }
                    }
                }
            }
        }
    }
}
