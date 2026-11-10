import QtQuick
import "controls.js" as G

// macOS 27.2.1 push button (MAC-ANSWERS.md Q-settings-15). Flat, not glass: push fill (two layers a.047 + a.03),
// regular 24 r6 with 12 pt side padding (small 20 r5 pad 10, mini 16 r4 pad 8, large 28 capsule pad 14), label
// 13 pt, no minimum width. primary = the default button: accent with white text (a plain button while the window
// is not key). Pressed: an extra black a.098 layer in the mouse-down frame, cleared while the pointer is outside;
// the action fires on release inside. Disabled: the fill at opacity 0.5, label disabledControlTextColor.
// Space clicks it when it has keyboard focus.
Rectangle {
    id: b
    property string text
    property bool primary: false
    property string controlSize: "regular"
    signal clicked()
    readonly property var _m: G.push(controlSize)
    readonly property bool _accent: primary && Tokens.windowActive
    implicitHeight: _m.height
    implicitWidth: label.implicitWidth + 2 * _m.padding
    radius: _m.radius
    readonly property bool down: ma.pressed && ma.containsMouse
    readonly property color _fill: _accent ? Tokens.accent : Tokens.control.pushFill
    color: Qt.alpha(_fill, _fill.a * (enabled ? 1 : Tokens.control.disabledOpacity))
    activeFocusOnTab: true
    Rectangle {
        visible: b.down
        anchors.fill: parent; radius: parent.radius
        color: Tokens.control.pressOverlay
    }
    FocusRing { visible: b.activeFocus }
    Text {
        id: label
        anchors.centerIn: parent
        text: b.text
        font: Typography.control
        color: !b.enabled ? Tokens.control.disabledText : b._accent ? "white" : Tokens.label
    }
    MouseArea { id: ma; anchors.fill: parent; onClicked: b.clicked() }
    Keys.onPressed: e => {
        if (e.key === Qt.Key_Space && !e.isAutoRepeat) { b.clicked(); e.accepted = true; }
    }
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: clicked()
}
