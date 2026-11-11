import QtQuick
import qs
import qs.components
import qs.HyprK
import qs.services

// Control Center's Sound module (macOS 27.2.1): opened from the round output button at the right end of the grid's
// Sound row, it takes the grid's place (MAC-ANSWERS.md Q-panels-12: one glass panel of the tiles' family, 308 wide,
// 6 below the menu bar, 8 from the right edge, continuous r 16; Sound 258 tall with four devices). Contents and
// places measured on the Mac's Sound module (photo 2026-11-11 23.11.22, 2.003 px/pt, panel 301..918 x 80..597 px):
// title "Sound" 13 bold, ink from 15 pt, baseline 25.5; slider row centre 46.2 with speaker.fill ink 16.9..25.5, a
// 6 pt track 34.4..263.6 (Q-panels-12: 230) with the white 20 x 16 knob always shown, speaker.wave.3.fill ink
// 270.6..290.6; separators at 64.6 and after the last device (+5.5); "Output" 13 bold, baseline 84.9, white at about
// .74 of the device names (JPEG); device rows 32 tall from 92 (Q-panels-12: 298 wide, hovered capsule +21 over grey),
// a 26 pt disc from x 14.5 (selected: white with the accent glyph; else white .25, as the grid's off circles, white
// glyph), the name from x 49.4, 13 regular; "Sound Settings…" baseline 20.2 under the last separator, the panel
// ends 32.6 under it. The device glyph is the device's kind (Audio.symbol, lib/state.js deviceSymbol: the computer for
// built-in outputs, the TV, HiFi speaker, headphones, HomePod, Apple TV and AirPods Pro glyphs where PipeWire tells
// the kind, else speaker.wave.2.fill).
Item {
    id: p
    property real originX: 0
    property real originY: 0
    property real materialize: 1
    signal settingsRequested()

    readonly property var outputs: Audio.outputs
    width: Theme.cc.modulePanelWidth
    height: Theme.cc.soundRowsTop + Theme.cc.soundRowPitch * outputs.length + Theme.cc.soundSeparatorGap
            + Theme.cc.soundFooterHeight

    Glass {
        anchors.fill: parent
        radius: Theme.cc.modulePanelRadius
        sx: p.originX
        sy: p.originY
        tint: Theme.cc.tileTint
        solidColor: Theme.cc.tileSolid
        materialize: p.materialize
    }

    Text {
        x: Theme.cc.modulePanelInset
        anchors.baseline: parent.top
        anchors.baselineOffset: Theme.cc.soundTitleBaseline
        text: "Sound"
        font: Typography.font(Theme.font.ccModuleTitle, Typography.bold)
        color: Theme.cc.text
    }
    Symbol {   // ink centres 21.2 and 280.6 on the Mac; the grid's glyph size
        x: Theme.cc.soundGlyphLeft - width / 2
        y: Theme.cc.soundSliderY - height / 2
        name: "speaker.fill"; surface: "ccSlider"; size: 18
        color: Theme.cc.text
    }
    Symbol {
        x: Theme.cc.soundGlyphRight - width / 2
        y: Theme.cc.soundSliderY - height / 2
        name: "speaker.wave.3.fill"; surface: "ccSlider"; size: 18
        color: Theme.cc.text
    }
    ControlCenterSlider {
        id: slider
        x: Theme.cc.soundTrackX
        width: Theme.cc.soundTrackW
        y: Theme.cc.soundSliderY - height / 2
        trackHeight: Theme.cc.soundTrackHeight
        knobWidth: Theme.cc.soundKnobW      // the Settings knob, always shown (Q-panels-12, the photo: 20 x 16)
        knobHeight: Theme.cc.soundKnobH
        lensWidth: knobWidth * Tokens.motion.sliderLift
        lensHeight: knobHeight * Tokens.motion.sliderLift
        knobShown: true
        enabled: Audio.available
        value: Audio.muted ? 0 : Audio.volume
        onMoved: v => Audio.setVolume(v)
        onReleased: Sounds.volumeReleased(releaseModifiers)
    }
    Separator { y: Theme.cc.soundSeparator1 }
    Text {
        x: Theme.cc.modulePanelInset
        anchors.baseline: parent.top
        anchors.baselineOffset: Theme.cc.soundHeaderBaseline
        text: "Output"
        font: Typography.font(Theme.font.ccModuleTitle, Typography.bold)
        color: Theme.cc.moduleHeader
    }
    Repeater {
        model: p.outputs
        Row_ {
            required property var modelData
            required property int index
            y: Theme.cc.soundRowsTop + index * Theme.cc.soundRowPitch
            label: Audio.name(modelData)
            symbol: Audio.symbol(modelData)
            selected: modelData === Audio.sink
            onActivated: Audio.setOutput(modelData)
        }
    }
    Separator { y: Theme.cc.soundRowsTop + Theme.cc.soundRowPitch * p.outputs.length + Theme.cc.soundSeparatorGap }
    Row_ {
        y: Theme.cc.soundRowsTop + Theme.cc.soundRowPitch * p.outputs.length + Theme.cc.soundSeparatorGap
           + Theme.cc.soundFooterBaseline - Theme.cc.soundRowPitch / 2 - Theme.cc.soundTextDrop
        label: "Sound Settings…"
        disc: false
        onActivated: p.settingsRequested()
    }

    component Separator: Rectangle {
        x: Theme.cc.modulePanelInset
        width: p.width - 2 * Theme.cc.modulePanelInset
        height: 1
        color: Theme.cc.moduleSeparator
    }
    // a device row (or the footer link): hover capsule, disc, name
    component Row_: Item {
        id: r
        property string label
        property string symbol: "speaker.wave.2.fill"
        property bool selected: false
        property bool disc: true
        signal activated()
        x: Theme.cc.soundRowInset
        width: p.width - 2 * Theme.cc.soundRowInset
        height: Theme.cc.soundRowPitch
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Theme.cc.moduleRowHover
            visible: ma.containsMouse
        }
        Rectangle {
            id: d
            visible: r.disc
            x: Theme.cc.soundDiscX - Theme.cc.soundRowInset
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.cc.soundDisc; height: width; radius: width / 2
            color: r.selected ? Theme.cc.toggleOnBg : Theme.cc.capsuleOffBg
            Symbol {
                anchors.centerIn: parent
                name: r.symbol; size: 18; pointSize: Theme.cc.soundDeviceGlyph
                color: r.selected ? Theme.cc.toggleOnIcon : Theme.cc.toggleOffIcon
            }
        }
        Text {
            x: (r.disc ? Theme.cc.soundTextX : Theme.cc.modulePanelInset) - Theme.cc.soundRowInset
            width: parent.width - x - 8
            anchors.baseline: parent.verticalCenter
            anchors.baselineOffset: Theme.cc.soundTextDrop
            text: r.label
            elide: Text.ElideRight
            font: Typography.font(Theme.font.ccModuleRow)
            color: Theme.cc.text
        }
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            onClicked: r.activated()
        }
    }
}
