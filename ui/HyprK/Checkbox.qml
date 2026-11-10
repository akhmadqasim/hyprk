import QtQuick
import QtQuick.Shapes

// macOS checkbox (NSButton switch type, DesignLibrary `Checkbox`): rounded box, accent fill with a
// white tick when checked, a white dash when mixed, optional label to the right (clicking the label
// toggles too, like AppKit). Highlight on mouse-down, cleared while the pointer is outside, action on
// release inside (NSButton tracking, as Button). Space toggles when it has keyboard focus.
// Controlled: it shows `checked` / `mixed` and emits toggled(value); the caller owns the state.
// A click on a mixed box asks for true (AppKit's mixed -> on).
// Sizes and colours: Tokens.control.checkbox* (guessed, no macOS 27 source, SPEC 10.8).
// Motion: the fill tints and the tick wipes in left to right on Tokens.motion.checkResponse (guessed).
// Press highlight switches in the mouse-down frame (no source for the checkbox; SPEC 10.5 finds no press
// animation on push buttons either). Reduce Motion: no wipe, the tick and fill change at once.
Item {
    id: cb
    property bool checked: false
    property bool mixed: false
    property string text: ""
    property bool reduceMotion: Tokens.reduceMotion
    readonly property bool pressed: ma.pressed && ma.containsMouse
    signal toggled(bool value)

    implicitWidth: box.width + (text !== "" ? Tokens.control.checkboxGap + label.implicitWidth : 0)
    implicitHeight: Math.max(box.height, text !== "" ? label.implicitHeight : 0)
    opacity: enabled ? 1 : Tokens.control.disabledOpacity
    activeFocusOnTab: true

    function toggle() { if (enabled) toggled(mixed ? true : !checked); }

    readonly property bool _on: checked || mixed
    // the dash keeps showing while a mixed box wipes out to unchecked
    property bool _dash: mixed
    onMixedChanged: if (mixed) _dash = true; else if (checked) _dash = false
    onCheckedChanged: if (checked && !mixed) _dash = false
    Spring {
        id: mark
        target: cb._on ? 1 : 0
        response: Tokens.motion.checkResponse
        damping: Tokens.motion.checkDamping
        epsilon: 0.002
        instant: cb.reduceMotion
    }
    readonly property real _a: Math.max(0, Math.min(1, mark.value))

    Rectangle { // keyboard focus ring (SPEC 10.6 opacity; width guessed; the ring's scale-in is not drawn)
        visible: cb.activeFocus
        anchors.fill: box
        anchors.margins: -Tokens.control.focusRingWidth
        radius: box.radius + Tokens.control.focusRingWidth
        color: "transparent"
        border.width: Tokens.control.focusRingWidth
        border.color: Qt.rgba(Tokens.accent.r, Tokens.accent.g, Tokens.accent.b, Tokens.control.focusRingOpacity)
    }
    Rectangle {
        id: box
        width: Tokens.control.checkboxSize
        height: width
        anchors.verticalCenter: parent.verticalCenter
        radius: Tokens.control.checkboxRadius
        readonly property color onColor: cb.pressed ? Qt.darker(Tokens.accent, 1.15) : Tokens.accent   // Button primary press
        readonly property color offColor: cb.pressed ? Tokens.control.checkboxOffPressed : Tokens.control.checkboxOff
        color: Qt.tint(offColor, Qt.rgba(onColor.r, onColor.g, onColor.b, cb._a))
        border.width: 1
        border.color: Qt.rgba(Tokens.control.checkboxBorder.r, Tokens.control.checkboxBorder.g,
                              Tokens.control.checkboxBorder.b, Tokens.control.checkboxBorder.a * (1 - cb._a))

        Item { // wipes the mark in from the left
            id: wipe
            objectName: "wipe"
            width: box.width * cb._a
            height: box.height
            clip: true
            Shape {
                id: markShape
                width: box.width; height: box.height
                preferredRendererType: Shape.CurveRenderer
                readonly property real u: box.width / 14   // path drawn on a 14-unit box
                ShapePath {
                    strokeColor: Tokens.control.checkMark
                    strokeWidth: Tokens.control.checkStroke
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin
                    PathPolyline {
                        readonly property real u: markShape.u
                        path: cb._dash ? [Qt.point(3.75 * u, 7 * u), Qt.point(10.25 * u, 7 * u)]
                                       : [Qt.point(3.5 * u, 7.4 * u), Qt.point(6 * u, 9.9 * u), Qt.point(10.5 * u, 4.3 * u)]
                    }
                }
            }
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
        color: Tokens.label
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

    Accessible.role: Accessible.CheckBox
    Accessible.name: text
    Accessible.checkable: true
    Accessible.checked: checked
    Accessible.checkStateMixed: mixed
    Accessible.onToggleAction: toggle()
    Accessible.onPressAction: toggle()
}
