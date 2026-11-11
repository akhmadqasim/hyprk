import QtQuick
import QtQuick.Controls.Basic as C

// Pop-up button as System Settings draws it (MAC-ANSWERS.md Q-settings-19, -20; appearance-, sound-, displays-light.png):
// a 24 pt frame with nothing drawn at rest but the value in 13 pt and the up/down chevron in a 20 pt push-fill circle
// 3.5 pt from the right edge; the text ends 12 pt before the circle and starts 12 pt in (133 pt wide for "Automatic"
// with its dot: 12 + 16 + 8 + text + 12 + 20 + 3.5). Pressed: an extra black a.098 layer; disabled: the fill at 0.5.
// A dot (`dots`) is 16 pt in the button, 8 pt before the text, and 12 pt in the menu.
// The menu: rows 24, padding 5, radius 12, as wide as the button and 16 pt to its left (popup-menu-open-light.png: the
// menu spans 30.5 .. 127.5 pt where the button's circle ends at 138.75), the checked item placed over the button,
// accent highlight pill (inset 5, radius 6) with white text, checkmark column at the left. It opens at once and
// fades out in 0.2 s. (The live menu is regular glass; drawn flat here.)
// Controlled: it shows `currentIndex` and emits activated(index); the caller owns the state.
Item {
    id: pop
    property var model: []          // array of strings
    property var dots: []           // optional paint per item: "" = none, a colour, or gradient stops left to right
                                    // as [[position, colour], ...] (up to four; Automatic's NSMulticolorHighlight)
    property int currentIndex: 0
    signal activated(int index)
    readonly property var _dot: dots.length > currentIndex && currentIndex >= 0 ? dots[currentIndex] : ""
    readonly property bool _hasDot: Array.isArray(_dot) || (_dot !== "" && _dot !== undefined)
    implicitHeight: Tokens.control.popupHeight
    implicitWidth: 12 + (_hasDot ? 24 : 0) + label.implicitWidth + 12 + Tokens.control.popupChevron + 3.5

    component Dot: Rectangle {
        property var paint: ""
        readonly property bool many: Array.isArray(paint)
        function stop(i) { return many ? paint[Math.min(i, paint.length - 1)] : [i / 3, "transparent"]; }
        radius: width / 2
        color: many || !paint ? "transparent" : paint
        gradient: many ? grad : null
        Rectangle {   // light: the outer half point is about 5 % darker (appearance-light.png: 206,144,162 against
            visible: !Tokens.dark   // 217,156,173 inside); dark has no rim
            anchors.fill: parent; radius: parent.radius; color: "transparent"
            border.width: 0.5; border.color: Qt.rgba(0, 0, 0, 0.055)
        }
        Gradient {
            id: grad
            orientation: Gradient.Horizontal
            GradientStop { position: stop(0)[0]; color: stop(0)[1] }
            GradientStop { position: stop(1)[0]; color: stop(1)[1] }
            GradientStop { position: stop(2)[0]; color: stop(2)[1] }
            GradientStop { position: stop(3)[0]; color: stop(3)[1] }
        }
    }

    Dot {
        objectName: "dot"
        visible: pop._hasDot
        anchors.right: label.left; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter
        width: 16; height: 16
        paint: pop._dot
    }
    Text {
        id: label
        anchors.right: chev.left; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
        text: pop.model.length > pop.currentIndex && pop.currentIndex >= 0 ? pop.model[pop.currentIndex] : ""
        font: Typography.control
        color: pop.enabled ? Tokens.label : Tokens.control.disabledText
    }
    Rectangle { // round chevron button
        id: chev
        anchors.right: parent.right; anchors.rightMargin: 3.5; anchors.verticalCenter: parent.verticalCenter
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
        x: -16
        padding: Tokens.control.menuPadding
        width: Math.max(pop.width, col.widest + 2 * Tokens.control.menuPadding)
        exit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200 } }
        enter: Transition { NumberAnimation { property: "opacity"; to: 1; duration: 0 } }
        background: Rectangle {
            radius: Tokens.control.menuRadius; color: Tokens.control.menuFill
            border.color: Tokens.control.menuStroke
        }
        Column {
            id: col
            // the widest row's own need (a Column's implicitWidth follows the rows' width, which follows the menu's)
            readonly property real widest: { let w = 0; for (let i = 0; i < children.length; i++) w = Math.max(w, children[i].need || 0); return w; }
            Repeater {
                model: pop.model
                Rectangle {
                    required property int index
                    required property string modelData
                    width: menu.width - 2 * Tokens.control.menuPadding; height: Tokens.control.menuItemHeight
                    radius: Tokens.control.menuHighlightRadius
                    readonly property real need: t.x + t.implicitWidth + 12
                    readonly property bool hot: pop._dragIndex >= 0 ? pop._dragIndex === index : im.containsMouse
                    color: hot ? Tokens.accent : "transparent"
                    SfSymbol {   // popup-menu-open-{light,dark}.png: semibold, 10.7 pt (alpha rms 0.076), ink 8.5 pt into the
                        x: 8.5; y: (parent.height - height) / 2 + 0.5   // highlight, 8.1 .. 17.0 pt down
                        visible: index === pop.currentIndex
                        name: "checkmark"; weight: "semibold"; pointSize: 10.7
                        color: parent.hot ? "white" : Tokens.label
                    }
                    Dot {
                        visible: pop.dots.length > 0
                        x: 25; anchors.verticalCenter: parent.verticalCenter
                        width: 12; height: 12
                        paint: pop.dots.length > index ? pop.dots[index] : ""
                    }
                    Text {
                        id: t
                        // the text's ink starts 26.0 pt into the highlight on popup-menu-open-{light,dark}.png
                        x: pop.dots.length ? 43 : 25; anchors.verticalCenter: parent.verticalCenter
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
