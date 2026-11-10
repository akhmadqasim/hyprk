import QtQuick
import ".."

// Slider with accent fill and a capsule knob (Liquid Glass lens while dragged). value in [from, to].
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
    property bool reduceMotion: AppState.appearance.reduceMotion === true
    // Knob is a Liquid Glass lens while held (GlassKnob), springs back to solid on release.
    property real _held: _dragging ? 1 : 0
    Behavior on _held {
        NumberAnimation {
            // press: swell with a small overshoot; release: stay glass while moving, settle solid
            duration: s.reduceMotion ? 120 : (s._dragging ? 260 : 440)
            easing.type: s.reduceMotion ? Easing.OutQuad : (s._dragging ? Easing.OutBack : Easing.InOutCubic)
            easing.overshoot: 1.6
        }
    }
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

        readonly property real knobCx: Theme.control.sliderKnobW / 2 + s._frac * usable
        Item { // what the glass knob refracts
            id: trackLayer
            anchors.fill: parent
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width; height: Theme.control.sliderTrack; radius: height / 2
                color: Theme.switchOff
            }
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: track.knobCx; height: Theme.control.sliderTrack; radius: height / 2
                color: Theme.accent
            }
        }
        GlassKnob {
            source: trackLayer
            restW: Theme.control.sliderKnobW; restH: Theme.control.sliderKnobH
            grow: 1.4; growH: 0.45
            mag: 1.6
            glass: s._held
            reduceMotion: s.reduceMotion
            cx: track.knobCx
            cy: track.height / 2
        }
        MouseArea {
            anchors.fill: parent
            enabled: s.enabled_
            function upd(mx) {
                const f = Math.max(0, Math.min(1, (mx - Theme.control.sliderKnobW / 2) / track.usable));
                s._dragValue = s.from + f * (s.to - s.from);
                s.moved(s._dragValue);
            }
            preventStealing: true
            onPressed: m => { s._dragging = true; upd(m.x); }
            onPositionChanged: m => { if (pressed) upd(m.x); }
            onReleased: { s._dragging = false; s.released(); }
            onCanceled: s._dragging = false
        }
    }
}
