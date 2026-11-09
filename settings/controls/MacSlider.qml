import QtQuick
import ".."

// Slider with accent fill and a capsule knob. value in [from, to].
Item {
    id: s
    property real from: 0
    property real to: 1
    property real value: 0
    property bool enabled_: true
    property string leftGlyph: ""
    property string rightGlyph: ""
    signal moved(real value)
    signal released()
    implicitWidth: 220
    implicitHeight: Theme.control.sliderKnobH + 4
    opacity: enabled_ ? 1 : 0.4

    readonly property real _frac: to > from ? Math.max(0, Math.min(1, (value - from) / (to - from))) : 0

    Text {
        id: lg; visible: s.leftGlyph !== ""
        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
        text: s.leftGlyph; font.family: Theme.fontGlyph; font.pixelSize: 15; color: Theme.secondaryLabel
    }
    Text {
        id: rg; visible: s.rightGlyph !== ""
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        text: s.rightGlyph; font.family: Theme.fontGlyph; font.pixelSize: 18; color: Theme.secondaryLabel
    }
    Item {
        id: track
        anchors.left: lg.visible ? lg.right : parent.left
        anchors.right: rg.visible ? rg.left : parent.right
        anchors.leftMargin: lg.visible ? 8 : 0
        anchors.rightMargin: rg.visible ? 8 : 0
        height: parent.height
        readonly property real usable: width - Theme.control.sliderKnobW

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width; height: Theme.control.sliderTrack; radius: height / 2
            color: Theme.switchOff
        }
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: knob.x + knob.width / 2; height: Theme.control.sliderTrack; radius: height / 2
            color: Theme.accent
        }
        Rectangle {
            id: knob
            width: Theme.control.sliderKnobW; height: Theme.control.sliderKnobH; radius: height / 2
            anchors.verticalCenter: parent.verticalCenter
            x: s._frac * track.usable
            color: Theme.knob
            border.color: Qt.rgba(0, 0, 0, 0.08)
            Rectangle { z: -1; anchors.fill: parent; anchors.topMargin: 1; anchors.bottomMargin: -1; radius: parent.radius; color: Qt.rgba(0, 0, 0, 0.16) }
        }
        MouseArea {
            anchors.fill: parent
            enabled: s.enabled_
            function upd(mx) {
                const f = Math.max(0, Math.min(1, (mx - Theme.control.sliderKnobW / 2) / track.usable));
                s.value = s.from + f * (s.to - s.from);
                s.moved(s.value);
            }
            onPressed: m => upd(m.x)
            onPositionChanged: m => { if (pressed) upd(m.x); }
            onReleased: s.released()
        }
    }
}
