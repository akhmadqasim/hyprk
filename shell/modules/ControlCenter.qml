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

        ClippingRectangle {
            x: Theme.cc.tilePadding + 4
            y: Theme.cc.tilePadding + 4
            width: Theme.cc.artSize
            height: Theme.cc.artSize
            radius: Theme.cc.artRadius
            color: Theme.cc.toggleOffBg
            Image {
                anchors.fill: parent
                visible: source != ""
                source: cc.player ? cc.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
            }
        }
        Column {
            x: Theme.cc.tilePadding + 4
            width: parent.width - x * 2
            anchors.bottom: controls.top
            anchors.bottomMargin: 6
            Text {
                width: parent.width
                text: cc.player ? (cc.player.trackTitle || cc.player.identity) : "Not Playing"
                elide: Text.ElideRight
                font.family: Theme.fontText
                font.pixelSize: Theme.font.ccTitle
                font.weight: Theme.font.semibold
                color: Theme.cc.text
            }
            Text {
                width: parent.width
                visible: text !== ""
                text: cc.player ? cc.player.trackArtist : ""
                elide: Text.ElideRight
                font.family: Theme.fontText
                font.pixelSize: Theme.font.ccSub
                color: Theme.cc.subtext
            }
        }
        Row {
            id: controls
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.cc.tilePadding + 4
            spacing: 14
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
    Round { x: cc.colX(1); y: cc.rowY(2); symbol: "square.grid"; enabled: false }               // Stage Manager placeholder
    Round { x: cc.colX(1) + cc.colW - cc.rowH; y: cc.rowY(2); symbol: "screen.mirror"; enabled: false }  // Screen Mirroring placeholder
    Round {
        x: cc.colX(0); y: cc.rowY(3)
        symbol: Theme.dark ? "moon" : "sun"
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
        leftSymbol: "sun"
        rightSymbol: "sun"
        value: Brightness.available ? Brightness.value : 1
        onMoved: v => Brightness.set(v)
    }
    SliderModule {
        y: cc.rowY(5)
        title: "Sound"
        available: Audio.available
        leftSymbol: "speaker"
        rightSymbol: "speaker"
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

        Rectangle {
            id: circle
            x: (cc.rowH - width) / 2
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.cc.toggleSize
            height: width
            radius: width / 2
            color: cap.on ? Theme.cc.toggleOnBg : Theme.cc.capsuleOffBg
            Behavior on color { ColorAnimation { duration: Theme.anim.fast } }
            Symbol {
                anchors.centerIn: parent
                name: cap.symbol
                size: Theme.cc.toggleSize * Theme.cc.toggleGlyph
                color: cap.on ? cap.onAccent : Theme.cc.capsuleOffIcon
            }
        }
        Column {
            anchors.left: circle.right
            anchors.leftMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            Text {
                width: parent.width
                text: cap.title
                elide: Text.ElideRight
                font.family: Theme.fontText
                font.pixelSize: Theme.font.ccTitle
                font.weight: Theme.font.semibold
                color: Theme.cc.text
            }
            Text {
                width: parent.width
                visible: text !== ""
                text: cap.subtitle
                elide: Text.ElideRight
                font.family: Theme.fontText
                font.pixelSize: Theme.font.ccSub
                color: Theme.cc.subtext
            }
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
        width: big ? 26 : 22
        height: width
        Symbol { anchors.centerIn: parent; name: mb.symbol; size: parent.width; color: Theme.cc.text }
        MouseArea { anchors.fill: parent; anchors.margins: -4; onClicked: mb.activated() }
    }

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

        width: cc.width
        height: cc.rowH
        interactive: false                       // the track below takes the input
        pressed: trackMa.pressed
        // the fill stays readable when disabled (the value is still shown)

        Text {
            x: Theme.cc.sliderInset
            y: 9
            text: sm.title
            font.family: Theme.fontText
            font.pixelSize: Theme.font.ccTitle
            font.weight: Theme.font.semibold
            color: Theme.cc.text
        }
        Symbol {
            id: ls
            x: Theme.cc.sliderInset
            anchors.verticalCenter: track.verticalCenter
            name: sm.leftSymbol
            size: 13
            color: Theme.cc.text
        }
        Symbol {
            id: rs
            anchors.right: parent.right
            anchors.rightMargin: Theme.cc.sliderInset
            anchors.verticalCenter: track.verticalCenter
            name: sm.rightSymbol
            size: 18
            color: Theme.cc.text
        }
        Item {
            id: track
            anchors.left: ls.right
            anchors.leftMargin: 8
            anchors.right: rs.left
            anchors.rightMargin: 8
            y: parent.height - 19
            height: Theme.cc.sliderTrack
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Theme.cc.sliderTrackColor
            }
            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, sm.shown))
                height: parent.height
                radius: height / 2
                color: Theme.cc.sliderFillColor
            }
            MouseArea {
                id: trackMa
                anchors.fill: parent
                anchors.topMargin: -10
                anchors.bottomMargin: -10
                enabled: sm.available
                // dragging past an end stretches the module like a rubber band
                function update(mx) {
                    const v = mx / track.width, c = Math.max(0, Math.min(1, v));
                    sm.stretch = Math.max(-1, Math.min(1, (v - c) * 2));
                    sm.moved(c);
                }
                onPressedChanged: {
                    if (!pressed) {
                        sm.stretch = 0;
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
