import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.Mpris
import qs
import qs.components
import qs.services
import qs.HyprK
import "../lib/state.js" as State

// Control Center, macOS 26/27 layout: no panel, separate clear-glass modules
// on a 2-column grid. Missing hardware or services dim the module and show
// "Not Available" instead of breaking the layout.
Item {
    id: cc

    property real originX: 0
    property real originY: 0

    readonly property int colW: Theme.cc.columnWidth
    readonly property int rowH: Theme.cc.tileHeight
    readonly property int gap: Theme.cc.gap
    function colX(c) { return c * (colW + gap); }
    function rowY(r) { return r * (rowH + gap); }

    width: Theme.cc.width
    height: rowY(6) - gap

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
        onActivated: Theme.dark = !Theme.dark
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
        title: "Focus"
        on: Notifs.dnd
        onAccent: Theme.color.indigo
        subtitle: on ? "Do Not Disturb" : ""
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
        available: Audio.available
        leftSymbol: "speaker.fill"
        rightSymbol: "speaker.wave.3.fill"
        value: Audio.muted ? 0 : Audio.volume
        onMoved: v => Audio.setVolume(v)
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
        Text {
            id: capTitle
            x: Theme.cc.textX
            width: parent.width - x - Theme.cc.textRight
            anchors.baseline: parent.top
            anchors.baselineOffset: cap.subtitle !== "" ? Theme.cc.titleBaseline : (parent.height + capTitle.font.pixelSize * 0.7) / 2
            text: cap.title
            elide: Text.ElideRight
            font: Typography.font(Theme.font.ccTileTitle, Typography.semibold)
            color: Theme.cc.title
        }
        PlusText {
            x: Theme.cc.textX
            width: capTitle.width
            visible: text !== ""
            anchors.baseline: parent.top
            anchors.baselineOffset: Theme.cc.subtitleBaseline
            text: cap.subtitle
        }
        interactive: available
        onClicked: toggled()
    }

    component Round: Module {
        id: rb
        property string symbol
        property bool on: false
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
            color: rb.on ? Theme.cc.toggleOnIcon : Theme.cc.toggleOffIcon
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
    // pressing turns it into a clear lens about 24 x 20 within about 3 frames (HyprK Knob: the lens is drawn as a
    // rim, the track is not magnified through it). A click springs the fill to the point (about 0.2 s), a drag
    // follows 1:1; past an end the track and fill stretch up to about 5 pt and spring back in 0.13 s on release.
    // The module itself does not move. Not built: the hover chevron (no sub-panels) and Sound's AirPlay button.
    component SliderModule: Module {
        id: sm
        property string title
        property bool available: true
        property string leftSymbol
        property string rightSymbol
        property real value: 0
        signal moved(real v)
        // shown fill: springs to a clicked point, follows 1:1 while dragging (Reduce motion: instant)
        property bool dragging: false
        Spring { id: shownValue; target: sm.value; response: Theme.anim.sliderJumpResponse }
        readonly property real shown: dragging || A11y.reduceMotion ? sm.value : shownValue.value
        property real over: 0                    // stretch past an end in pt (< 0 = the left end)
        Behavior on over {
            enabled: !trackMa.pressed && !A11y.reduceMotion
            NumberAnimation { duration: Theme.cc.overdragBackMs; easing.type: Easing.OutCubic }
        }

        width: cc.width
        height: cc.rowH
        radius: Theme.cc.sliderRadius
        interactive: false                       // the track below takes the input
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
            x: parent.width - Theme.cc.glyphRight - width / 2
            y: Theme.cc.trackY - height / 2
            name: sm.rightSymbol
            surface: "ccSlider"
            size: 18
            color: Theme.cc.text
        }
        Item {
            id: track
            x: Theme.cc.trackX
            width: parent.width - Theme.cc.trackX - Theme.cc.trackRight
            y: Theme.cc.trackY - height / 2
            height: Theme.cc.trackHeight
            readonly property real fillW: width * Math.max(0, Math.min(1, sm.shown))
            // track: plus-lighter T + 20 (shaders/plusfill.frag), stretched past an end
            ShaderEffect {
                x: Math.min(0, sm.over)
                width: parent.width + Math.abs(sm.over)
                height: parent.height
                property vector4d fill: Qt.vector4d(Theme.cc.trackLift, Theme.cc.trackLift, Theme.cc.trackLift, 0)
                property size sizePt: Qt.size(width, height)
                property real radius: height / 2
                property real dpr: Screen.devicePixelRatio
                fragmentShader: Qt.resolvedUrl("../shaders/plusfill.frag.qsb")
            }
            Rectangle {
                x: Math.min(0, sm.over)
                width: track.fillW + Math.abs(sm.over)
                height: parent.height
                radius: height / 2
                color: Theme.cc.sliderFillColor
            }
            Knob {
                visible: hover.hovered || trackMa.pressed
                restW: Theme.cc.knobW
                restH: Theme.cc.knobH
                grow: Theme.cc.lensGrow
                cx: Math.max(restW / 2, track.fillW + Math.max(0, sm.over) - restW / 2)
                cy: track.height / 2
                lift: trackMa.pressed ? 1 : 0
                Behavior on lift { NumberAnimation { duration: Theme.cc.lensMs } }
            }
            MouseArea {
                id: trackMa
                anchors.fill: parent
                anchors.topMargin: -10
                anchors.bottomMargin: -10
                enabled: sm.available
                // the fill end runs half a knob ahead of the pointer; past an end: a damped stretch
                function update(mx) {
                    const v = (mx + Theme.cc.knobW / 2) / track.width, c = Math.max(0, Math.min(1, v));
                    const past = (v - c) * track.width;
                    sm.over = Math.sign(past) * Theme.cc.overdrag * (1 - Math.exp(-Math.abs(past) / 30));
                    sm.moved(c);
                }
                onPressedChanged: {
                    if (!pressed) {
                        sm.over = 0;
                        if (sm.dragging) shownValue.snap();   // a click keeps springing to its point
                        sm.dragging = false;
                    }
                }
                onPressed: m => update(m.x)
                onPositionChanged: m => { if (pressed) { sm.dragging = true; update(m.x); } }
            }
        }
    }
}
