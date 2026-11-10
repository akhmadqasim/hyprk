import QtQuick
import QtQuick.Shapes
import qs
import qs.HyprK
import "lock.js" as L

// Glass capsule with placeholder, typed dots, caret, Caps Lock glyph and return arrow.
// Shows Lock.buffer; keys are handled by the lock surface (Lock.key). Shakes on a wrong password.
Item {
    id: f
    property bool interactive: false

    width: LockTheme.fieldWidth
    height: LockTheme.fieldHeight

    readonly property int typed: Lock.buffer.length
    // dots of a wrong password stay while the field shakes, then fade (Reduce Motion: they only fade)
    property int ghost: 0
    property real ghostOpacity: 0
    property real shakeT: 0
    readonly property real offset: L.shake(shakeT, LockTheme.shakeAmplitude, LockTheme.shakeCycles, LockTheme.shakeDecay)
    readonly property int shown: typed > 0 ? typed : ghost
    readonly property real arrowRoom: LockTheme.arrowSize + 8
    readonly property int fit: Math.max(1, Math.floor((width - 2 * LockTheme.fieldPadding - arrowRoom) / (LockTheme.dotSize + LockTheme.dotSpacing)))

    Connections {
        target: Lock
        enabled: f.interactive
        function onFailTickChanged() {
            f.ghost = Lock.failedDots;
            f.ghostOpacity = 1;
            fail.restart();
        }
        function onActivityChanged() { f.wake(); }
    }
    SequentialAnimation {
        id: fail
        NumberAnimation {
            target: f; property: "shakeT"; from: 0; to: 1
            duration: LockTheme.reduceMotion ? 0 : LockTheme.shakeDuration
        }
        NumberAnimation { target: f; property: "ghostOpacity"; to: 0; duration: LockTheme.failFade }
        ScriptAction { script: { f.shakeT = 0; f.ghost = 0; } }
    }

    // caret: blinks for caretBlinkFor ms after the last key or show, then stays on (no idle redraws)
    property bool caretOn: true
    function wake() { caretOn = true; blinking.restart(); blinkStop.restart(); }
    Timer { id: blinking; interval: LockTheme.caretBlink; repeat: true; onTriggered: f.caretOn = !f.caretOn }
    Timer { id: blinkStop; interval: LockTheme.caretBlinkFor; onTriggered: { blinking.stop(); f.caretOn = true; } }
    Component.onCompleted: if (interactive) wake()

    Item {
        id: face
        width: f.width
        height: f.height
        x: f.offset

        LockGlass { anchors.fill: parent }

        Text {
            anchors.centerIn: parent
            visible: f.shown === 0
            text: LockTheme.placeholder
            font: Typography.font(LockTheme.placeholderSize)
            color: LockTheme.placeholderColor
        }

        // typed dots, centred; only the last ones that fit
        Row {
            id: dots
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -f.arrowRoom / 2 + LockTheme.fieldPadding / 2
            spacing: LockTheme.dotSpacing
            opacity: f.typed > 0 ? 1 : f.ghostOpacity
            visible: f.shown > 0
            Repeater {
                model: Math.min(f.shown, f.fit)
                Rectangle {
                    width: LockTheme.dotSize
                    height: LockTheme.dotSize
                    radius: width / 2
                    color: LockTheme.dotColor
                }
            }
        }

        Rectangle {
            visible: f.interactive && !Lock.busy && f.caretOn && (f.typed > 0 || f.ghost === 0)
            width: LockTheme.caretWidth
            height: LockTheme.caretHeight
            radius: 1
            color: LockTheme.dotColor
            anchors.verticalCenter: parent.verticalCenter
            x: f.typed > 0 ? dots.x + dots.width + LockTheme.dotSpacing : LockTheme.fieldPadding
        }

        // Caps Lock: the ⇪ glyph at the right, left of the arrow
        Text {
            visible: Lock.capsLock
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: arrow.left
            anchors.rightMargin: 4
            text: "⇪"
            font: Typography.font(LockTheme.capsSize)
            color: LockTheme.placeholderColor
        }

        // return arrow in a disc
        Item {
            id: arrow
            width: LockTheme.arrowSize
            height: LockTheme.arrowSize
            anchors.right: parent.right
            anchors.rightMargin: (parent.height - height) / 2
            anchors.verticalCenter: parent.verticalCenter
            visible: f.typed > 0
            opacity: Lock.busy ? 0.45 : 1
            Rectangle { anchors.fill: parent; radius: width / 2; color: "transparent"; border.width: 1.5; border.color: LockTheme.arrowFill }
            Shape {
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer
                ShapePath {
                    strokeColor: LockTheme.arrowFill
                    strokeWidth: 1.6
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    joinStyle: ShapePath.RoundJoin
                    readonly property real s: LockTheme.arrowSize
                    startX: s * 0.28; startY: s * 0.5
                    PathLine { x: arrowPath.s * 0.72; y: arrowPath.s * 0.5 }
                    PathMove { x: arrowPath.s * 0.52; y: arrowPath.s * 0.31 }
                    PathLine { x: arrowPath.s * 0.72; y: arrowPath.s * 0.5 }
                    PathLine { x: arrowPath.s * 0.52; y: arrowPath.s * 0.69 }
                    id: arrowPath
                }
            }
            MouseArea { anchors.fill: parent; anchors.margins: -4; enabled: f.interactive; onClicked: Lock.submit() }
        }
    }
}
