import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.Mpris
import qs
import qs.components
import qs.HyprK
import qs.services
import "../lib/state.js" as State

// Control Center, macOS 26/27 layout: no panel, separate clear-glass modules
// on a 2-column grid. Missing hardware or services dim the module and show
// "Not Available" instead of breaking the layout.
Item {
    id: cc

    property real originX: 0
    property real originY: 0
    // 1 = the grid shown, 0 = a module panel in its place (ControlCenterWindow.morph): the grid's glass materializes
    // out on it
    property real gridShown: 1
    signal moduleRequested(string name)

    readonly property int colW: Theme.cc.columnWidth
    readonly property int rowH: Theme.cc.tileHeight
    readonly property int gap: Theme.cc.gap
    function colX(c) { return c * (colW + gap); }
    function rowY(r) { return r * (rowH + gap); }

    width: Theme.cc.width
    height: rowY(6) - gap + Theme.cc.editGap + Theme.cc.editH

    readonly property var wifiDev: State.wifiDevice(Networking.devices.values)
    readonly property var wifiNet: wifiDev ? wifiDev.networks.values.find(n => n.connected) || null : null
    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property var player: State.pickPlayer(Mpris.players.values)
    property bool airdrop: false

    // ---------- connectivity ----------
    Capsule {
        x: cc.colX(0); y: cc.rowY(0)
        symbol: "wifi"
        title: "Wi-Fi"
        available: cc.wifiDev !== null
        on: available && Networking.wifiEnabled
        subtitle: !on ? "Off" : cc.wifiNet ? cc.wifiNet.name : "Not Connected"
        onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
    }
    Capsule {
        x: cc.colX(0); y: cc.rowY(1)
        symbol: "bluetooth"
        title: "Bluetooth"
        available: State.hasBluetooth(cc.btAdapter)
        on: available && cc.btAdapter.enabled
        subtitle: on ? "On" : "Off"
        onToggled: cc.btAdapter.enabled = !cc.btAdapter.enabled
    }
    Capsule {
        x: cc.colX(0); y: cc.rowY(2)
        symbol: "airdrop"
        title: "AirDrop"
        on: cc.airdrop                       // placeholder, no backend yet
        subtitle: on ? "Contacts Only" : "Off"
        onToggled: cc.airdrop = !cc.airdrop
    }

    // ---------- now playing (2x2) ----------
    Module {
        id: np
        x: cc.colX(1); y: cc.rowY(0)
        width: cc.colW
        height: cc.rowH * 2 + cc.gap
        radius: Theme.cc.tileRadius
        interactive: false                       // only its media buttons take clicks

        // 27.2.1 idle tile (Q-panels-11): art placeholder, "Not Playing" at y 72, three 30 pt buttons at y 96
        ClippingRectangle {
            x: Theme.cc.npArtXY
            y: Theme.cc.npArtXY
            width: Theme.cc.npArt
            height: Theme.cc.npArt
            radius: Theme.cc.npArtRadius
            color: Theme.cc.npArtFill
            Image {
                anchors.fill: parent
                visible: source != ""
                source: cc.player ? cc.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
            }
        }
        Column {
            x: Theme.cc.npArtXY
            y: Theme.cc.npTitleY
            width: parent.width - x * 2
            Text {
                width: parent.width
                text: cc.player ? (cc.player.trackTitle || cc.player.identity) : "Not Playing"
                elide: Text.ElideRight
                font: Typography.font(Theme.font.ccTileTitle, Typography.semibold)
                color: Theme.cc.text
            }
            PlusText {
                width: parent.width
                visible: text !== ""
                text: cc.player ? cc.player.trackArtist : ""
            }
        }
        Row {
            id: controls
            x: Theme.cc.npButtonsX
            y: Theme.cc.npButtonsY
            spacing: Theme.cc.npButtonPitch - Theme.cc.npButton
            opacity: cc.player ? 1 : 0.55
            MediaButton { symbol: "backward"; onActivated: if (cc.player && cc.player.canGoPrevious) cc.player.previous() }
            MediaButton {
                symbol: cc.player && cc.player.isPlaying ? "pause" : "play"
                big: true
                onActivated: if (cc.player && cc.player.canTogglePlaying) cc.player.togglePlaying()
            }
            MediaButton { symbol: "forward"; onActivated: if (cc.player && cc.player.canGoNext) cc.player.next() }
        }
    }

    // ---------- round buttons ----------
    Round { x: cc.colX(1); y: cc.rowY(2); symbol: "sidebar.squares.leading"; enabled: false }               // Stage Manager placeholder
    Round { x: cc.colX(1) + cc.colW - cc.rowH; y: cc.rowY(2); symbol: "screen.mirror"; enabled: false }  // Screen Mirroring placeholder
    Round {
        x: cc.colX(0); y: cc.rowY(3)
        symbol: "appearance.darkmode"
        // on in dark: the whole disc opaque white with a black glyph (MAC-ANSWERS Control Center section 1, Q-panels-01)
        on: Theme.dark
        onIcon: "#000000"
        onActivated: Theme.setAppearance(!Theme.dark)
    }
    Round {
        x: cc.colX(0) + cc.colW - cc.rowH; y: cc.rowY(3)
        symbol: "display"
        on: Theme.reduceTransparency
        onActivated: Theme.reduceTransparency = !Theme.reduceTransparency
    }
    Capsule {
        x: cc.colX(1); y: cc.rowY(3)
        symbol: "moon"
        // on (Q-panels-02): the mode's name becomes the title, "On" the subtitle, the moon in the mode's colour
        title: on ? "Do Not Disturb" : "Focus"
        on: Notifs.dnd
        onAccent: Theme.cc.focusOnIcon
        subtitle: on ? "On" : ""
        onToggled: Notifs.dnd = !Notifs.dnd
    }

    // ---------- sliders ----------
    SliderModule {
        y: cc.rowY(4)
        title: "Display"
        available: Brightness.available
        leftSymbol: "sun.min.fill"
        rightSymbol: "sun.max.fill"
        value: Brightness.available ? Brightness.value : 1
        onMoved: v => Brightness.set(v)
    }
    SliderModule {
        y: cc.rowY(5)
        title: "Sound"
        trailingRoom: Theme.cc.outputRoom
        available: Audio.available
        // the AirPlay-audio output button opens the Sound module (CcSoundPanel) in the grid's place
        Rectangle {
            x: parent.width - Theme.cc.outputButtonRight - width / 2
            y: Theme.cc.trackY - height / 2
            width: Theme.cc.outputButton
            height: width
            radius: width / 2
            color: Theme.spotlight.tokenFill
            Symbol { anchors.centerIn: parent; name: "airplayaudio"; surface: "ccOutput"; size: 16; color: Theme.cc.text }
            MouseArea { anchors.fill: parent; enabled: cc.gridShown === 1; onClicked: cc.moduleRequested("sound") }
        }
        leftSymbol: "speaker.fill"
        rightSymbol: "speaker.wave.3.fill"
        value: Audio.muted ? 0 : Audio.volume
        onMoved: v => Audio.setVolume(v)
        onSliderReleased: mods => Sounds.volumeReleased(mods)
    }

    // ---------- building blocks ----------
    // Each module is its own glass. Open and close are a fade of the whole window (ControlCenterWindow,
    // MAC-ANSWERS.md R2 (27.2.1): no scale), so the modules never move or grow and neighbours never touch
    // (the hidden-scale clamp of 56df7cd is gone with the scale).
    // Interactive glass: pressing lifts it by a couple of points on a bouncy spring, a drag past a
    // slider end stretches it (squish); the plugin lights the glass around the pointer.
    // Reduce motion: none of it.
    component Module: GlassButton {
        id: m
        property real radius: Theme.cc.tileRadius
        Glass {
            id: glass
            anchors.fill: parent
            radius: m.radius
            sx: cc.originX + m.x
            sy: cc.originY + m.y
            tint: Theme.cc.tileTint
            solidColor: Theme.cc.tileSolid
            pluginLift: Theme.cc.pluginLift
            shadow: false
            materialize: cc.gridShown
        }
    }

    component Capsule: Module {
        id: cap
        property string symbol
        property string title
        property string subtitle
        property bool on: false
        property bool available: true
        property color onAccent: Theme.cc.toggleOnIcon
        signal toggled()

        width: cc.colW
        height: cc.rowH
        // unavailable looks like "off" (macOS shows Wi-Fi off, not a dead tile); taps do nothing

        // circle 36 at x 14, text from x 56, title / subtitle baselines 27.5 / 44 (Q-panels-07); a title alone
        // is centred (not measured)
        Rectangle {
            id: circle
            x: Theme.cc.circleX
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.cc.circle
            height: width
            radius: width / 2
            color: cap.on ? Theme.cc.toggleOnBg : Theme.cc.capsuleOffBg
            Behavior on color { ColorAnimation { duration: Theme.anim.fast } }
            Symbol {
                anchors.centerIn: parent
                name: cap.symbol
                surface: "ccToggle"
                size: Theme.cc.circle * Theme.cc.circleGlyph
                color: cap.on ? cap.onAccent : Theme.cc.capsuleOffIcon
            }
        }
        // title and subtitle wrap to two lines at most; three lines in all sit on Theme.cc.threeLineBaselines
        readonly property bool _three: capTitle.lineCount + (cap.subtitle !== "" ? capSub.lineCount : 0) >= 3
        readonly property var _b: Theme.cc.threeLineBaselines
        Text {
            id: capTitle
            x: Theme.cc.textX
            width: parent.width - x - Theme.cc.textRight
            anchors.baseline: parent.top
            anchors.baselineOffset: cap._three ? cap._b[0]
                                  : cap.subtitle !== "" ? Theme.cc.titleBaseline : (parent.height + capTitle.font.pixelSize * 0.7) / 2
            text: cap.title
            wrapMode: Text.Wrap
            maximumLineCount: 2
            lineHeightMode: Text.FixedHeight
            lineHeight: cap._b[1] - cap._b[0]
            elide: Text.ElideRight
            font: Typography.font(Theme.font.ccTileTitle, Typography.semibold)
            color: Theme.cc.title
        }
        PlusText {
            id: capSub
            x: Theme.cc.textX
            width: capTitle.width
            visible: text !== ""
            anchors.baseline: parent.top
            anchors.baselineOffset: !cap._three ? Theme.cc.subtitleBaseline : capTitle.lineCount > 1 ? cap._b[2] : cap._b[1]
            text: cap.subtitle
            wrapMode: Text.Wrap
            maximumLineCount: 2
            lineHeightMode: Text.FixedHeight
            lineHeight: cap._b[2] - cap._b[1]
        }
        interactive: available
        onClicked: toggled()
    }

    component Round: Module {
        id: rb
        property string symbol
        property bool on: false
        property color onIcon: Theme.cc.toggleOnIcon   // the glyph on the white disc: the accent (Stage Manager), black for Dark Mode
        signal activated()
        width: cc.rowH
        height: cc.rowH
        radius: cc.rowH / 2
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: Theme.cc.toggleOnBg
            visible: rb.on
        }
        Symbol {
            anchors.centerIn: parent
            name: rb.symbol
            surface: "ccRound"
            opacity: rb.enabled ? 1 : Theme.color.disabledOpacity
            size: Theme.cc.buttonGlyph
            color: rb.on ? rb.onIcon : Theme.cc.toggleOffIcon
        }
        onClicked: activated()
    }

    component MediaButton: Item {
        id: mb
        property string symbol
        property bool big: false
        signal activated()
        width: Theme.cc.npButton
        height: width
        Symbol { anchors.centerIn: parent; name: mb.symbol; surface: mb.big ? "ccPlay" : "ccMedia"; size: parent.width; color: Theme.cc.text }
        MouseArea { anchors.fill: parent; onClicked: mb.activated() }
    }

    // subtitle: SF 11 regular, plus-lighter T + 140 over the tile (MAC-ANSWERS.md "Glass checks (#53)")
    component PlusText: Text {
        elide: Text.ElideRight
        font: Typography.font(Theme.font.ccTileSub)
        color: "#FFFFFF"                     // only its coverage is used
        layer.enabled: visible
        layer.effect: ShaderEffect {
            property real lift: Theme.cc.subtitleLift
            fragmentShader: Qt.resolvedUrl("../shaders/plustext.frag.qsb")
        }
    }

    // 27.2.1 slider module (MAC-ANSWERS.md Q-panels-08, -09): 292 x 64, r 24. No knob at rest; hovering the
    // module shows a white 18 x 14 knob whose right edge is the fill end (the fill runs 9 pt ahead of the pointer);
    // pressing turns it into a clear lens about 24 x 20 centred on the fill end within about 3 frames (drawn: a grey
    // wash, a dark rim, a light top edge, a shadow and a thicker fill band; no live refraction). A click springs the
    // fill to the point (about 0.2 s), a drag
    // follows 1:1; past an end the track and fill stretch up to about 5 pt and spring back in 0.13 s on release.
    // The module itself does not move. Not built: the hover chevron (no sub-panels) and Sound's AirPlay button.
    // "Edit Controls" (the Mac's edit mode is not built: present, opens nothing)
    Glass {
        id: editControls
        width: Theme.cc.editW
        height: Theme.cc.editH
        radius: height / 2
        x: Math.round((cc.width - width) / 2)
        y: cc.rowY(6) - cc.gap + Theme.cc.editGap
        sx: cc.originX + x
        sy: cc.originY + y
        tint: Theme.cc.tileTint
        solidColor: Theme.cc.tileSolid
        materialize: cc.gridShown
        Text {
            anchors.centerIn: parent
            text: "Edit Controls"
            font: Typography.font(12)     // size not measured: 12 by eye against the 24 pt capsule
            color: Theme.cc.text
        }
    }

    component SliderModule: Module {
        id: sm
        property real trailingRoom: 0     // room at the right end for a button (Sound's output button)
        property string title
        property bool available: true
        property string leftSymbol
        property string rightSymbol
        property real value: 0
        signal moved(real v)
        signal sliderReleased(int modifiers)   // let go after a change: the modifiers at that moment

        width: cc.width
        height: cc.rowH
        radius: Theme.cc.sliderRadius
        interactive: false                       // the slider below takes the input
        HoverHandler { id: hover; enabled: sm.available }

        Text {
            x: Theme.cc.sliderTitleX
            anchors.baseline: parent.top
            anchors.baselineOffset: Theme.cc.sliderTitleBaseline
            text: sm.title
            font: Typography.font(Theme.font.ccTileTitle, Typography.semibold)
            color: Theme.cc.text
        }
        Symbol {
            x: Theme.cc.glyphLeft - width / 2
            y: Theme.cc.trackY - height / 2
            name: sm.leftSymbol
            surface: "ccSlider"
            size: 18
            color: Theme.cc.text
        }
        Symbol {
            x: parent.width - Theme.cc.glyphRight - sm.trailingRoom - width / 2
            y: Theme.cc.trackY - height / 2
            name: sm.rightSymbol
            surface: "ccSlider"
            size: 18
            color: Theme.cc.text
        }
        ControlCenterSlider {
            x: Theme.cc.trackX
            width: parent.width - Theme.cc.trackX - Theme.cc.trackRight - sm.trailingRoom
            y: Theme.cc.trackY - height / 2
            enabled: sm.available
            knobShown: hover.hovered
            value: sm.value
            onMoved: v => sm.moved(v)
            onReleased: sm.sliderReleased(releaseModifiers)
        }
    }

}
