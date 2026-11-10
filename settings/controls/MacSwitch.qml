import QtQuick
import ".."

// macOS 26/27 switch: accent capsule when on, white knob that turns into a Liquid Glass
// lens while held or moving (GlassKnob). Click toggles; the knob can also be dragged
// across, and lands on the nearer end on release with a small spring.
// One value drives everything: `_along` (0 off .. 1 on) moves the knob and blends the
// track colour; the knob is glass while held (`_held`) and while travelling.
Item {
    id: sw
    property bool checked: false
    property bool enabled_: true
    property bool reduceMotion: AppState.appearance.reduceMotion === true
    signal toggled(bool checked)
    implicitWidth: Theme.control.switchWidth
    implicitHeight: Theme.control.switchHeight
    opacity: enabled_ ? 1 : 0.4

    property real _along: checked ? 1 : 0
    Behavior on _along {
        enabled: !ma.dragging
        NumberAnimation {
            duration: sw.reduceMotion ? 150 : 460
            easing.type: sw.reduceMotion ? Easing.OutQuad : Easing.OutBack
            easing.overshoot: 1.4
        }
    }
    property real _held: 0
    Behavior on _held {
        NumberAnimation {
            // press: swell with a small overshoot; release: stay glass while moving, settle solid
            duration: sw.reduceMotion ? 120 : (ma.pressed ? 260 : 440)
            easing.type: sw.reduceMotion ? Easing.OutQuad : (ma.pressed ? Easing.OutBack : Easing.InOutCubic)
            easing.overshoot: 1.6
        }
    }
    readonly property real _a: Math.max(0, Math.min(1, _along))
    readonly property real _glass: Math.max(_held, Math.sin(Math.PI * _a))
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
        grow: 1.55; growH: 0.32
        glass: sw._glass
        // the spring's overshoot past an end flattens the knob against it instead of moving it
        squash: sw.reduceMotion ? 0 : Math.max(0, sw._along - 1, -sw._along) * 2
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
        function restore() { sw._along = Qt.binding(() => sw.checked ? 1 : 0); }
        onPressed: m => { pressX = m.x; dragging = false; sw._held = 1; }
        onPositionChanged: m => {
            if (!dragging && Math.abs(m.x - pressX) > 3) dragging = true;
            if (dragging) // knob centre follows the pointer
                sw._along = Math.max(0, Math.min(1, (m.x - 4 - sw.height / 2) / sw._range));
        }
        onReleased: {
            const v = dragging ? sw._along > 0.5 : !sw.checked;
            dragging = false;
            sw._held = 0;
            sw._along = v ? 1 : 0;      // animates from where the knob is
            if (v !== sw.checked) { sw.checked = v; sw.toggled(v); }
            restore();
        }
        onCanceled: { dragging = false; sw._held = 0; restore(); }
    }
}
