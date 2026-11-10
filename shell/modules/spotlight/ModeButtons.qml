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
    // Glass radius of button i while it emerges. All four start stacked inside the field's right
    // end, so their circles overlapped each other and the field; overlapping glass regions reach
    // the plugin as one pixel cluster, drawn as one box (about 2 frames of a single rounded
    // rectangle). Each circle now stops `clear` pt short of the field's edge and of the half
    // distance to its neighbour (Region rounding can add up to 1 px per side): the regions never
    // touch, and the plugin's smooth union (spacing 8) still fuses them while they are that close.
    readonly property real clear: 2
    function glassRadius(i) {
        const c = i * (diameter + spacing) - offset(i) + diameter / 2;   // centre; field's right edge at -gap
        const pitch = i > 0 ? c - ((i - 1) * (diameter + spacing) - offset(i - 1) + diameter / 2)
                            : (diameter + spacing) - (offset(1) - offset(0));
        return Math.max(0, Math.min(diameter / 2, c + gap - clear, (pitch - clear) / 2));
    }

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

            readonly property real glassR: buttons.glassRadius(index)
            Glass {
                // below 2 pt the region has no room for its materialize hole (Glass.placeHole)
                visible: b.glassR >= 2
                anchors.centerIn: parent
                width: b.glassR * 2
                height: width
                radius: width / 2
                sx: buttons.originX + b.x + x
                sy: buttons.originY + y
                tint: Theme.glass.tintStrong
                materialize: mat.progress
            }
            Item {
                anchors.fill: parent
                opacity: mat.progress
                scale: b.glassR * 2 / buttons.diameter   // the symbol grows with its circle
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
