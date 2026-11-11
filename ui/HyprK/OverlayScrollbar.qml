import QtQuick

// Overlay scroll bar, macOS 27.2.1 "Show scroll bars: Automatically" with a trackpad (MAC-ANSWERS.md PC #60
// section 5): no track, only a 6 pt knob, r 3, black a.5 / white a.5. It appears on the first scrolled frame,
// stays 0.6 s after the last scroll, then fades out in 0.15 s. Its length is the flickable's visible share of
// its content (Settings: 625 / 1088.5 of a 567 pt track = 325.5). The knob can be dragged; nothing runs at rest.
// Place it with x / y / height (Settings: 3 pt from the right edge, from 3 below the toolbar to 3 above the bottom).
Item {
    id: sb
    property Flickable flickable
    width: Tokens.scroller.width
    readonly property real _ratio: flickable && flickable.contentHeight > 0 ? Math.min(1, flickable.height / flickable.contentHeight) : 1
    readonly property real _range: flickable ? flickable.contentHeight - flickable.height : 0
    // past an edge (rubber band) the knob shortens by the overshoot share and stays at that edge
    readonly property real _over: !flickable ? 0 : flickable.contentY < 0 ? -flickable.contentY
                                 : Math.max(0, flickable.contentY - Math.max(0, _range))
    visible: opacity > 0 && _ratio < 1
    opacity: 0

    // show now and start the hold timer (the flickable scrolled)
    function poke() { fade.stop(); opacity = 1; hold.restart(); }
    // hide at once (the content was replaced, not scrolled)
    function hide() { fade.stop(); hold.stop(); opacity = 0; }
    Connections {
        target: sb.flickable
        function onContentYChanged() { if (!sb._silent) sb.poke(); }
    }
    property bool _silent: false
    Timer { id: hold; interval: Tokens.scroller.hold; onTriggered: if (!ma.pressed) fade.start() }
    NumberAnimation { id: fade; target: sb; property: "opacity"; to: 0; duration: Tokens.scroller.fade }

    Rectangle {
        id: knob
        objectName: "knob"
        width: parent.width
        height: Math.max(Tokens.scroller.minLength, sb.height * sb._ratio * (1 - Math.min(1, sb._over / Math.max(1, sb.flickable ? sb.flickable.height : 1))))
        y: sb._range > 0 ? (sb.height - height) * Math.max(0, Math.min(1, sb.flickable.contentY / sb._range)) : 0
        radius: width / 2
        color: Tokens.scroller.knob
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        anchors.leftMargin: -4; anchors.rightMargin: -2   // a little easier to hit than 6 pt
        enabled: sb.visible
        preventStealing: true
        property real grab: 0
        function scrollTo(my) {
            const travel = sb.height - knob.height;
            if (travel <= 0) return;
            sb.flickable.contentY = Math.max(0, Math.min(1, (my - grab) / travel)) * sb._range;
        }
        // on the knob: keep the spot it was grabbed at; on the empty strip: centre the knob there
        onPressed: m => { grab = m.y >= knob.y && m.y <= knob.y + knob.height ? m.y - knob.y : knob.height / 2; sb.poke(); scrollTo(m.y); }
        onPositionChanged: m => { if (pressed) scrollTo(m.y); }
        onReleased: hold.restart()
    }
}
