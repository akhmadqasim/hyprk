import QtQuick
import qs
import qs.components
import qs.services
import qs.HyprK
import "../../lib/spotlight.js" as SL

// The four mode buttons to the right of the Spotlight bar (macOS 26/27: they appear when
// the pointer moves over Spotlight or a mode is active; Cmd+1..4 select them).
// Each is a glass circle; the active one is filled with the accent colour.
// Liquid Glass: they materialize out of the search field's right end and spring to their places,
// so each one fuses with the field (and its neighbours) on the plugin's smooth union on the way
// and then separates; on hide they retract into the field. Pressing one lifts it.
// Reduce motion: a dissolve in place.
Item {
    id: buttons

    property string mode: ""
    property real originX: 0                // screen position of this row, for Glass sampling
    property real originY: 0
    property bool shown: false
    property real gap: 12                   // distance from the field's right edge
    readonly property int diameter: Theme.spotlight.barHeight
    readonly property int spacing: 10
    signal picked(string mode)

    width: SL.modes().length * (diameter + spacing) - spacing
    height: diameter
    visible: mat.active

    Materializer { id: mat; shown: buttons.shown; initial: 0 }
    // at value 0 every button sits just inside the field's right end
    function offset(i) { return A11y.reduceMotion ? 0 : Motion.emergeOffset(i, mat.value, gap + diameter, diameter + spacing); }

    Repeater {
        model: SL.modes()
        delegate: GlassButton {
            id: b
            required property var modelData
            required property int index
            readonly property bool on: buttons.mode === modelData.id
            x: index * (buttons.diameter + buttons.spacing) - buttons.offset(index)
            width: buttons.diameter
            height: width
            interactive: buttons.shown
            hoverable: true
            onClicked: buttons.picked(b.on ? "" : b.modelData.id)

            Glass {
                anchors.fill: parent
                radius: width / 2
                sx: buttons.originX + b.x
                sy: buttons.originY
                tint: Theme.glass.tintStrong
                materialize: mat.progress
            }
            Item {
                anchors.fill: parent
                opacity: mat.progress
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 6
                    radius: width / 2
                    visible: b.on || b.hovered
                    color: b.on ? Theme.color.accent : Theme.spotlight.selection
                }
                Symbol {
                    anchors.centerIn: parent
                    name: b.modelData.symbol
                    size: Theme.spotlight.iconSize
                    color: b.on ? Theme.color.textOnAccent : Theme.color.label
                }
            }
        }
    }
}
