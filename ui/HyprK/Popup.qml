import QtQuick
import QtQuick.Controls.Basic as C

// Pop-up button as System Settings draws it (MAC-ANSWERS.md Q-settings-19, -20): the value in 13 pt, then the
// up/down chevron in a 24 pt push-fill circle. Pressed: an extra black a.098 layer; disabled: the fill at 0.5.
// The menu: rows 24, padding 5, radius 12, at least the button's width, the checked item placed over the
// button, accent highlight pill (inset 5, radius 6) with white text, checkmark column at the left. It opens at
// once and fades out in 0.2 s. (The live menu is regular glass; drawn flat here.)
// Controlled: it shows `currentIndex` and emits activated(index); the caller owns the state.
Item {
    id: pop
    property var model: []          // array of strings
    property var dots: []           // optional colour per item ("" = none): a 12 pt dot before the item's text
    property int currentIndex: 0
    signal activated(int index)
    implicitHeight: Tokens.control.popupChevron
    implicitWidth: label.implicitWidth + Tokens.control.popupChevron + 8

    Text {
        id: label
        anchors.right: chev.left; anchors.rightMargin: 7; anchors.verticalCenter: parent.verticalCenter
        text: pop.model.length > pop.currentIndex && pop.currentIndex >= 0 ? pop.model[pop.currentIndex] : ""
        font: Typography.control
        color: pop.enabled ? Tokens.label : Tokens.control.disabledText
    }
    Rectangle { // round chevron button
        id: chev
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        width: Tokens.control.popupChevron; height: width; radius: width / 2
        color: Qt.alpha(Tokens.control.pushFill, Tokens.control.pushFill.a * (pop.enabled ? 1 : Tokens.control.disabledOpacity))
        Rectangle {
            visible: ma.pressed || menu.visible
            anchors.fill: parent; radius: parent.radius
            color: Tokens.control.pressOverlay
        }
        SfSymbol {   // semibold, 10.25 pt: ink 15 x 21 px on appearance-{light,dark}.png, alpha rms 0.039 (10.0 and 10.5: 0.063)
            anchors.centerIn: parent; anchors.alignWhenCentered: false
            name: "chevron.up.chevron.down"; weight: "semibold"; pointSize: 10.25
            color: pop.enabled ? Tokens.label : Tokens.control.disabledText
        }
    }
    // NSPopUpButton: the menu opens on mouse-down; press-drag-release picks the item under
    // the pointer, a plain click leaves the menu open.
    property int _dragIndex: -1
    MouseArea {
        id: ma; anchors.fill: parent; hoverEnabled: true
        property point pressAt
        property bool moved: false
        function itemAt(m) {
            const p = mapToItem(col, m.x, m.y);
            return p.x >= 0 && p.x < col.width && p.y >= 0 && p.y < col.height ? Math.floor(p.y / Tokens.control.menuItemHeight) : -1;
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
            if (i >= 0 && i !== pop.currentIndex) pop.activated(i);
            menu.close();                       // released on an item or outside the menu
        }
    }

    C.Popup {
        id: menu
        y: -pop.currentIndex * Tokens.control.menuItemHeight - Tokens.control.menuPadding
        x: pop.width - width
        padding: Tokens.control.menuPadding
        width: Math.max(pop.width, col.implicitWidth + 2 * Tokens.control.menuPadding)
        exit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 } }
        enter: Transition { NumberAnimation { property: "opacity"; to: 1; duration: 0 } }
        background: Rectangle {
            radius: Tokens.control.menuRadius; color: Tokens.control.menuFill
            border.color: Tokens.control.menuStroke
        }
        Column {
            id: col
            Repeater {
                model: pop.model
                Rectangle {
                    required property int index
                    required property string modelData
                    width: menu.width - 2 * Tokens.control.menuPadding; height: Tokens.control.menuItemHeight
                    radius: Tokens.control.menuHighlightRadius
                    readonly property color dot: pop.dots.length > index && pop.dots[index] ? pop.dots[index] : "transparent"
                    implicitWidth: t.implicitWidth + 44 + (pop.dots.length ? 18 : 0)
                    readonly property bool hot: pop._dragIndex >= 0 ? pop._dragIndex === index : im.containsMouse
                    color: hot ? Tokens.accent : "transparent"
                    SfSymbol {   // popup-menu-open-{light,dark}.png: semibold, 10.7 pt (alpha rms 0.076), ink 8.5 pt into the
                        x: 8.5; y: (parent.height - height) / 2 + 0.5   // highlight, 8.1 .. 17.0 pt down
                        visible: index === pop.currentIndex
                        name: "checkmark"; weight: "semibold"; pointSize: 10.7
                        color: parent.hot ? "white" : Tokens.label
                    }
                    Rectangle {
                        visible: pop.dots.length > 0
                        x: 26; anchors.verticalCenter: parent.verticalCenter
                        width: 12; height: 12; radius: 6; color: parent.dot
                    }
                    Text {
                        id: t
                        x: pop.dots.length ? 44 : 26; anchors.verticalCenter: parent.verticalCenter
                        text: modelData; font: Typography.menu
                        color: parent.hot ? "white" : Tokens.label
                    }
                    MouseArea {
                        id: im; anchors.fill: parent; hoverEnabled: true
                        onClicked: { if (index !== pop.currentIndex) pop.activated(index); menu.close(); }
                    }
                }
            }
        }
    }
}
