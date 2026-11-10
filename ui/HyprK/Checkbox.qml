import QtQuick
import QtQuick.Shapes
import "controls.js" as G

// macOS 27.2.1 checkbox and radio button (MAC-ANSWERS.md Q-settings-21). Flat, not glass.
// Checkbox: a rounded box (16 r5.5; small 14 r4.5, mini 12 r3.5, large 18 r6.5), black/white a.098 when off, the
// accent stack with a white tick (10 x 9.5 in 16) when on, a white 6.5 x 2 bar when mixed. radio: true draws a
// circle with a white 5 pt dot (mini 4) and only ever asks for true. Label 13 pt, 6 pt after the box; clicking the
// label toggles too. Pressed: an extra black a.098 layer in the mouse-down frame, cleared while the pointer is
// outside; the action fires on release inside. The state changes at once (no animation in the 120 Hz samples).
// Disabled: the box at opacity 0.5, tick black a.26 / white a.25. Window not key: grey box, label-coloured tick.
// Space toggles when it has keyboard focus (ring around the box only).
// Controlled: it shows `checked` / `mixed` and emits toggled(value); the caller owns the state.
// A click on a mixed box asks for true (AppKit's mixed -> on).
Item {
    id: cb
    property bool checked: false
    property bool mixed: false
    property bool radio: false
    property string text: ""
    property string controlSize: "regular"
    readonly property bool pressed: ma.pressed && ma.containsMouse
    signal toggled(bool value)
    readonly property var _m: G.checkbox(controlSize)

    implicitWidth: box.width + (text !== "" ? Tokens.control.checkboxGap + label.implicitWidth : 0)
    implicitHeight: Math.max(box.height, text !== "" ? label.implicitHeight : 0)
    activeFocusOnTab: true

    function toggle() { if (enabled) toggled(radio || mixed ? true : !checked); }

    readonly property bool _on: checked || (mixed && !radio)
    readonly property color _mark: !enabled ? Tokens.control.disabledText : Tokens.windowActive ? "#FFFFFF" : Tokens.label

    Rectangle {
        id: box
        objectName: "box"
        width: cb._m.size
        height: width
        anchors.verticalCenter: parent.verticalCenter
        radius: cb.radio ? width / 2 : cb._m.radius
        readonly property color fill: cb._on ? Tokens.control.checkboxOn : Tokens.control.trackOff
        color: Qt.alpha(fill, fill.a * (cb.enabled ? 1 : Tokens.control.disabledOpacity))
        Rectangle {
            visible: cb.pressed
            anchors.fill: parent; radius: parent.radius
            color: Tokens.control.pressOverlay
        }
        FocusRing { visible: cb.activeFocus }

        readonly property real u: width / 16   // marks are drawn on a 16-unit box
        Shape {
            objectName: "tick"
            visible: !cb.radio && cb.checked && !cb.mixed
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            ShapePath {
                strokeColor: cb._mark
                strokeWidth: 2 * box.u
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                PathPolyline {
                    path: [Qt.point(4.2 * box.u, 8.7 * box.u), Qt.point(6.9 * box.u, 11.5 * box.u), Qt.point(11.8 * box.u, 4.3 * box.u)]
                }
            }
        }
        Rectangle { // mixed: 6.5 x 2 r1
            objectName: "dash"
            visible: !cb.radio && cb.mixed
            x: 4.75 * box.u; y: 7 * box.u
            width: 6.5 * box.u; height: 2 * box.u; radius: height / 2
            color: cb._mark
        }
        Rectangle { // radio dot
            objectName: "dot"
            visible: cb.radio && cb.checked
            anchors.centerIn: parent
            width: cb._m.dot; height: width; radius: width / 2
            color: cb._mark
        }
    }
    Text {
        id: label
        visible: cb.text !== ""
        anchors.left: box.right
        anchors.leftMargin: Tokens.control.checkboxGap
        anchors.verticalCenter: parent.verticalCenter
        text: cb.text
        font: Typography.control
        color: cb.enabled ? Tokens.label : Tokens.control.disabledText
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        anchors.margins: -2
        onClicked: cb.toggle()   // no focus on click: macOS shows the ring only for keyboard focus
    }
    Keys.onPressed: e => {
        if (e.key === Qt.Key_Space && !e.isAutoRepeat) { cb.toggle(); e.accepted = true; }
    }

    Accessible.role: radio ? Accessible.RadioButton : Accessible.CheckBox
    Accessible.name: text
    Accessible.checkable: true
    Accessible.checked: checked
    Accessible.checkStateMixed: mixed
    Accessible.onToggleAction: toggle()
    Accessible.onPressAction: toggle()
}
