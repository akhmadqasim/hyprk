import QtQuick
import ".."

// macOS 26/27 switch: accent capsule when on, white knob that turns into a Liquid Glass
// lens (GlassKnob) from the mouse-down frame until it has landed. Click toggles on release;
// the knob can also be dragged across and lands on the nearer end.
// Motion values: Theme.motion (SPEC "Controls motion").
Item {
    id: sw
    property bool checked: false
    property bool enabled_: true
    property bool reduceMotion: AppState.appearance.reduceMotion === true
    signal toggled(bool checked)
    implicitWidth: Theme.control.switchWidth
    implicitHeight: Theme.control.switchHeight
    opacity: enabled_ ? 1 : 0.4

    // knob position, 0 off .. 1 on (may overshoot while it lands)
    Spring {
        id: along
        target: sw.checked ? 1 : 0
        response: sw.reduceMotion ? Theme.motion.reducedResponse : Theme.motion.switchResponse
        dampingFraction: sw.reduceMotion ? 1 : Theme.motion.switchDamping
        instant: ma.dragging
    }
    // lens amount: up on mouse-down, held while the knob travels
    Spring {
        id: lift
        // Reduce Motion keeps the lens but not the growth (GlassKnob.reduceMotion)
        target: ma.pressed || Math.abs(along.target - along.value) > 0.04 ? 1 : 0
        response: Theme.motion.lensResponse
        dampingFraction: ma.pressed ? Theme.motion.lensDamping : 1
    }
    readonly property real _a: Math.max(0, Math.min(1, along.value))
    readonly property real _range: width - height

    Item {
        id: trackLayer
        anchors.fill: parent
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Qt.tint(Theme.switchOff, Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, sw._a))
        }
    }
    GlassKnob {
        source: trackLayer
        restW: sw.height - 4; restH: sw.height - 4
        grow: Theme.motion.switchLift; growH: Theme.motion.switchLift - 1
        glass: lift.value
        // overshoot past an end flattens the knob against it instead of moving it
        squash: Math.max(0, along.value - 1, -along.value) * 2
        reduceMotion: sw.reduceMotion
        cx: sw.height / 2 + sw._a * sw._range
        cy: sw.height / 2
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        anchors.margins: -4
        enabled: sw.enabled_
        preventStealing: true
        property bool dragging: false
        property real pressX: 0
        property real grabOffset: 0     // pointer minus knob centre at mouse-down
        onPressed: m => {
            pressX = m.x;
            grabOffset = m.x - 4 - (sw.height / 2 + sw._a * sw._range);
            dragging = false;
        }
        onPositionChanged: m => {
            if (!dragging && Math.abs(m.x - pressX) > Theme.motion.dragThreshold) dragging = true;
            if (dragging) // the knob keeps the spot it was grabbed at
                along.target = Math.max(0, Math.min(1, (m.x - 4 - grabOffset - sw.height / 2) / sw._range));
        }
        onReleased: {
            const v = dragging ? along.value > 0.5 : !sw.checked;
            dragging = false;           // spring on: lands from where the knob is
            if (v !== sw.checked) { sw.checked = v; sw.toggled(v); }
            along.target = Qt.binding(() => sw.checked ? 1 : 0);
        }
        onCanceled: { dragging = false; along.target = Qt.binding(() => sw.checked ? 1 : 0); }
    }
}
