import QtQuick
import qs
import qs.HyprK

// The large lock clock (LOCKSCREEN-27.2.1.md A3, B8): `.SF Soft Numeric` 156 pt, proportional digits, centred
// by the parent; ink = backdrop + lift with a white top line and a dark 1 px rim (LockPlus). On a minute change
// only the changed characters animate: the old one goes and the new one is revealed from the bottom through a
// soft gradient mask (lockreveal.frag), and each slot eases to its new width so the string re-centres.
// Nothing runs between changes.
LockPlus {
    id: clk
    property string text: ""
    property bool animate: true
    readonly property real baselineOffset: fm.ascent

    lift: LockTheme.clockLift
    edge: LockTheme.clockEdge
    edgePx: LockTheme.clockEdgePx
    rim: LockTheme.clockRim
    width: row.width
    height: fm.height

    FontMetrics { id: fm; font: LockTheme.clockFont }

    Row {
        id: row
        Repeater {
            model: clk.text.length
            Item {
                id: slot
                required property int index
                readonly property string ch: clk.text.charAt(index)
                property string now: ""
                property string old: ""
                property real p: 1
                // eases to the new character's width while it is revealed, one value per frame of this window (HyprK
                // FrameEase; it was a Behavior on Qt's timer)
                width: widthEase.value
                height: fm.height
                FrameEase {
                    id: widthEase
                    goal: cur.implicitWidth
                    animate: slot.p < 1
                    duration: LockTheme.minuteRecentre
                    ease: Easing.OutCubic
                }
                onChChanged: {
                    if (now === "" || !clk.animate || LockTheme.reduceMotion) { now = ch; return; }
                    old = now;
                    p = 0;
                    now = ch;
                    reveal.restart();
                }
                Component.onCompleted: now = ch
                FrameAnim { id: reveal; target: slot; property: "p"; from: 0; to: 1; duration: LockTheme.minuteChange }

                Text {
                    id: cur
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: slot.now
                    font: LockTheme.clockFont
                    color: "white"
                    layer.enabled: slot.p < 1
                    layer.effect: ShaderEffect {
                        property real p: slot.p
                        property real soft: LockTheme.minuteSoft
                        property real show: 1
                        fragmentShader: Qt.resolvedUrl("lockreveal.frag.qsb")
                    }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: slot.p < 1
                    text: slot.old
                    font: LockTheme.clockFont
                    color: "white"
                    layer.enabled: visible
                    layer.effect: ShaderEffect {
                        property real p: slot.p
                        property real soft: LockTheme.minuteSoft
                        property real show: 0
                        fragmentShader: Qt.resolvedUrl("lockreveal.frag.qsb")
                    }
                }
            }
        }
    }
}
