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
    property string leftText: ""      // small end labels ("Slow" / "Fast") instead of glyphs
    property string rightText: ""
    signal moved(real value)
    signal released()
    implicitWidth: 220
    implicitHeight: Theme.control.sliderKnobH + 4
    opacity: enabled_ ? 1 : 0.4

    // While dragging, show the drag position without assigning `value`
    // (that would break the caller's binding to external state).
    property bool _dragging: false
    property real _dragValue: 0
    readonly property real _shown: _dragging ? _dragValue : value
    readonly property real _frac: to > from ? Math.max(0, Math.min(1, (_shown - from) / (to - from))) : 0

    Text {
        id: lg; visible: text !== ""
        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
        text: s.leftGlyph || s.leftText
        font.family: s.leftGlyph ? Theme.fontGlyph : Theme.fontText
        font.pixelSize: s.leftGlyph ? 15 : Theme.font.small
        color: Theme.secondaryLabel
    }
    Text {
        id: rg; visible: text !== ""
        anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
        text: s.rightGlyph || s.rightText
        font.family: s.rightGlyph ? Theme.fontGlyph : Theme.fontText
        font.pixelSize: s.rightGlyph ? 18 : Theme.font.small
        color: Theme.secondaryLabel
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
                s._dragValue = s.from + f * (s.to - s.from);
                s.moved(s._dragValue);
            }
            onPressed: m => { s._dragging = true; upd(m.x); }
            onPositionChanged: m => { if (pressed) upd(m.x); }
            onReleased: { s._dragging = false; s.released(); }
            onCanceled: s._dragging = false
        }
    }
}
