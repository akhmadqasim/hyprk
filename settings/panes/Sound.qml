import QtQuick
import ".."
import "../controls"
import "../HyprK"
import "../Parsers.js" as P

// Functional: output device and volume via wpctl (PipeWire); sound effects are
// stored in state/sound.json (the shell plays them) and previewed with pw-play.
Column {
    id: pane
    spacing: Theme.content.sectionGap

    property string status: "loading"     // loading | missing | failed | nodevices | ok
    property var sinks: []
    property var sources: []
    property var vol: P.parseWpctlVolume("")

    function refresh() {
        Backend.run(["wpctl", "status"], (code, out) => {
            status = Backend.status(code);
            if (status !== "ok") return;
            sinks = P.parseWpctlSinks(out);
            sources = P.parseWpctlSources(out);
            status = sinks.length ? "ok" : "nodevices";
        });
        Backend.run(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"], (c, o) => { if (!dragging) vol = P.parseWpctlVolume(o); });
        Backend.run(["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"], (c, o) => { if (!draggingIn) inVol = P.parseWpctlVolume(o); });
    }
    // the default source's volume (the Input tab), sent like the output's: one wpctl at a time, the latest value
    property var inVol: P.parseWpctlVolume("")
    property bool draggingIn: false
    property real _wantIn: -1
    property bool _inBusy: false
    function setInputVolume(v) { _wantIn = v; _sendInput(); }
    function _sendInput() {
        if (_inBusy || _wantIn < 0) return;
        const v = _wantIn;
        _wantIn = -1;
        _inBusy = true;
        Backend.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", v.toFixed(2)], c => { _inBusy = false; _sendInput(); });
    }
    property bool dragging: false
    // One wpctl at a time, always with the latest value, so a fast drag can't
    // end on a stale volume.
    property real _wantVol: -1
    property bool _volBusy: false
    function setVolume(v) { _wantVol = v; _sendVolume(); }
    function _sendVolume() {
        if (_volBusy || _wantVol < 0) return;
        const v = _wantVol;
        _wantVol = -1;
        _volBusy = true;
        Backend.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", v.toFixed(2)], c => {
            _volBusy = false;
            _sendVolume();
        });
    }

    readonly property string soundsDir: Backend.root + "/sounds/wav"
    // A slider's let-go preview plays 30 ms after the last let-go, earlier requests are dropped (Sound.appex:
    // cancelPreviousPerformRequests, then performSelector:afterDelay: 0.03, const 0x10002daa8;
    // reference/re/27.2.1/SOUND-REA-27.2.1.md). volume -1: the alert volume as stored when the timer fires.
    Timer {
        id: letGo
        property string file: ""
        property real volume: 1
        interval: 30
        function play(f, v) { file = f; volume = v; restart(); }
        onTriggered: pane.play(file, volume < 0 ? AppState.sound.alertVolume : volume)
    }
    // `file` in sounds/wav (16-bit copies); the Apple original in sounds/originals plays when present (24-bit, what the
    // shell's scripts/sound.sh plays)
    // volume: the Alert volume slider position; the gain is exp(s - 1), 0 at 0, as the Mac stores it (Sound.appex
    // setAlertSoundVolume: 0x100007f98; the shell's scripts/sound.sh applies the same curve)
    function play(file, volume) {
        volume = volume <= 0 ? 0 : Math.exp(Math.min(1, volume) - 1);
        // a new preview stops the one still playing (Sound.appex stops the alert before it plays the next,
        // reference/re/27.2.1/SOUND-REA-27.2.1.md section 1): the pid file names this pane's last pw-play only
        Backend.run(["sh", "-c", 'o="${1%.wav}"; o="${o%/sounds/wav/*}/sounds/originals/${o#*/sounds/wav/}"; f="$1"; '
                     + 'for e in aiff aif caf; do [ -f "$o.$e" ] && { f="$o.$e"; break; }; done; '
                     + 'p="${XDG_RUNTIME_DIR:-/tmp}/hyprk-settings-preview.pid"; read -r old 2>/dev/null < "$p" && '
                     + 'grep -qa pw-play "/proc/$old/cmdline" 2>/dev/null && kill "$old" 2>/dev/null; echo $$ > "$p"; '
                     + 'exec pw-play --volume "$2" "$f"',
                     "sh", file, volume.toFixed(2)]);
    }
    function setDefault(id) {
        Backend.run(["wpctl", "set-default", String(id)], () => refresh());
    }
    Component.onCompleted: refresh()
    // pw-mon prints whenever a PipeWire object (volume, default sink, devices) changes.
    EventSource { command: ["pw-mon", "-N", "-o", "-a"]; filter: /^\s*(changed|added|removed):/; active: !pane.dragging; onChanged: pane.refresh() }

    // macOS 27.2.1 order (reference/screens/27.2.1/settings/sound-light.png): Alert sound with a play button, Play sound
    // effects through, Alert volume (7 tick dots), three switches; then Output & Input: Output/Input segmented
    // control over the device table, and a card with Output volume and a Mute checkbox under the slider.
    Card {
        title: "Sound Effects"
        FormRow {
            label: "Alert sound"
            implicitHeight: 40   // row heights 40, 39, 39, 38, 38, 37 + separators (sound-light.png)
            Popup {
                objectName: "soundAlert"
                anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                // shown under the 27.2.1 names (Blow is "Breeze"), stored under the file names the shell plays
                model: P.alertSoundMenu.map(n => P.alertSoundTitles[n])
                currentIndex: P.alertSoundMenu.indexOf(AppState.sound.alertSound)
                onActivated: i => {
                    AppState.set("sound", { alertSound: P.alertSoundMenu[i] });
                    pane.play(pane.soundsDir + "/Sounds/" + P.alertSoundMenu[i] + ".wav", AppState.sound.alertVolume);
                }
            }
            Item { // play button after the pop-up: play.circle, ink 33 x 33 px on sound-light.png = 16.5 pt, in the
                // symbol's own box (38 of 32 wide: the ink's right edge 12 pt inside the card, px 1416)
                anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                width: 20.5; height: 16.5
                SfSymbol {
                    anchors.centerIn: parent
                    name: "play.circle"; pointSize: 16.5
                    color: playMa.pressed ? Theme.label : Theme.secondaryLabel
                }
                MouseArea { id: playMa; anchors.fill: parent; anchors.margins: -2; onClicked: pane.play(pane.soundsDir + "/Sounds/" + AppState.sound.alertSound + ".wav", AppState.sound.alertVolume) }
            }
        }
        FormRow {   // no key: the shell plays effects on the default output; kept locally
            label: "Play sound effects through"
            implicitHeight: 40
            // first item: Sound.appex DEFAULT_ALERT_DEVICE
            LocalPopup { objectName: "soundEffectsThrough"; model: ["Selected Sound Output Device"].concat(pane.sinks.map(s => s.name)); separators: pane.sinks.length > 0 ? [0] : [] }   // R13.2: a separator, then the devices
        }
        FormRow {
            label: "Alert volume"
            implicitHeight: 40
            Slider {
                width: 246   // the end images' layout frames span 463.6 .. 709.6 pt on sound-light.png
                tickMarks: 7
                value: AppState.sound.alertVolume
                leftGlyph: "speaker.fill"; rightGlyph: "speaker.wave.3.fill"; rightGlyphSize: 12.7
                onMoved: v => AppState.set("sound", { alertVolume: Math.round(v * 100) / 100 })
                // macOS plays the alert once you let go of the knob, 30 ms later (see letGo)
                onReleased: letGo.play(pane.soundsDir + "/Sounds/" + AppState.sound.alertSound + ".wav", -1)
            }
        }
        FormRow { label: "Play sound on startup"; Switch { checked: AppState.sound.startupSound; onToggled: on => AppState.set("sound", { startupSound: on }) } }   // stored (sound.json); no startup sound exists to play
        FormRow { label: "Play user interface sound effects"; Switch { checked: AppState.sound.uiSounds; onToggled: on => AppState.set("sound", { uiSounds: on }) } }
        FormRow { label: "Play feedback when volume is changed"; Switch { checked: AppState.sound.volumeFeedback; onToggled: on => AppState.set("sound", { volumeFeedback: on }) } }
    }

    Card {
        id: io
        title: "Output & Input"
        property int tab: 0       // 0 Output, 1 Input (view only)
        readonly property var nodes: tab === 0 ? pane.sinks : pane.sources
        Item {
            width: parent.width; height: 11 + 24 + 10   // the table 10 pt under the tabs (px 821 -> 841)
            SegmentedControl {
                x: Theme.content.rowPadding; y: 11
                width: parent.width - 2 * x
                model: ["Output", "Input"]
                currentIndex: io.tab
                onActivated: i => io.tab = i
            }
        }
        // The device table (MAC-ANSWERS-14.md R14.5, live/settings-r14/sound-input-dark.png; the Output tab the same on
        // R3.8b sound-01-light.png): 10 pt under the tabs, the card's whole width. A 28 pt header on a faint fill,
        // "Name" 8.5 pt in and "Type" 10.5 pt into its column (296 pt after the table's start), a hairline, then one
        // 24 pt row per device: the name 10 pt in, the type 12 pt into its column; the default device's row
        // highlighted, every second row striped. No rows without devices.
        Item {
            id: table
            objectName: "soundTable"
            width: parent.width
            height: 28 + 24 * io.nodes.length
            readonly property color faint: Theme.dark ? Qt.rgba(1, 1, 1, 0.046) : Qt.rgba(0, 0, 0, 0.036)
            Rectangle {
                width: parent.width; height: 28
                color: table.faint
                bottomLeftRadius: io.nodes.length === 0 ? Theme.content.cardRadius : 0; bottomRightRadius: bottomLeftRadius
                Text { x: 8.5; anchors.verticalCenter: parent.verticalCenter; text: "Name"; font: Typography.callout; color: Theme.label }
                Text { x: 296 + 10.5; anchors.verticalCenter: parent.verticalCenter; text: "Type"; font: Typography.callout; color: Theme.label }
                Rectangle { visible: io.nodes.length > 0; y: parent.height - height; width: parent.width; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
            }
            Repeater {
                model: io.nodes
                Rectangle {
                    required property var modelData
                    required property int index
                    readonly property var node: modelData
                    objectName: "soundRow" + index
                    y: 28 + 24 * index; width: parent.width; height: 24
                    bottomLeftRadius: index === io.nodes.length - 1 ? Theme.content.cardRadius : 0
                    bottomRightRadius: bottomLeftRadius
                    color: node.isDefault ? (Theme.dark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.098)) : index % 2 ? table.faint : "transparent"
                    Text {
                        x: 10; width: 280; elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                        text: parent.node.name; font: Typography.body; color: Theme.label
                    }
                    Text {
                        x: 296 + 12; anchors.verticalCenter: parent.verticalCenter
                        text: /hdmi|display/i.test(parent.node.name) ? "HDMI" : /bluez|airpod|head/i.test(parent.node.name) ? "Bluetooth" : "Built-in"
                        font: Typography.body; color: Theme.label
                    }
                    MouseArea { anchors.fill: parent; onClicked: pane.setDefault(parent.node.id) }
                }
            }
        }
    }

    Card {
        visible: io.tab === 0
        FormRow {
            label: "Output volume"
            implicitHeight: 62
            alignTop: true
            Item {   // the slider with the Mute checkbox right-aligned under it
                width: 246; height: 45
                Slider {
                    width: 246
                    tickMarks: 7
                    value: pane.vol.volume
                    enabled: pane.status === "ok"
                    leftGlyph: "speaker.fill"; rightGlyph: "speaker.wave.3.fill"; rightGlyphSize: 12.7
                    onMoved: v => { pane.dragging = true; pane.setVolume(v); dragRelease.restart(); }
                    onReleased: if (AppState.sound.volumeFeedback) letGo.play(pane.soundsDir + "/misc/BezelServices-volume.wav", 1)
                    Timer { id: dragRelease; interval: 600; onTriggered: pane.dragging = false }
                }
                Checkbox { // Mute: a checkbox right-aligned under the slider (sound-light.png)
                    x: 230 - width; y: 25
                    text: "Mute"
                    checked: pane.vol.muted
                    enabled: pane.status === "ok"
                    onToggled: on => {
                        pane.vol = Object.assign({}, pane.vol, { muted: on });   // shown at once, refresh() corrects it
                        Backend.run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", on ? "1" : "0"], () => pane.refresh());
                    }
                }
            }
        }
        // 27.2.1 (R3.8b sound-01-light.png, ax-sound-light.jsonl 598.5): Balance, a 246.5 pt slider without the accent fill,
        // tick dots at both ends, "Left" / "Right" under it, the knob at the centre; the row ends the card (Help 20 below
        // at 659.5). Held here (no balance backend; the volume is wpctl's, balance would need per-channel volumes)
        FormRow {
            id: balanceRow
            label: "Balance"
            implicitHeight: 51
            alignTop: true
            property real balance: 0.5
            Item {
                width: 246.5; height: 32
                Slider {
                    y: balanceRow.trackY
                    width: parent.width
                    value: balanceRow.balance
                    tickMarks: 2; leftText: "Left"; rightText: "Right"
                    fillColor: "transparent"
                    onMoved: v => balanceRow.balance = v
                }
            }
            readonly property real trackY: -2   // the track 1 pt above the label's centre (Mac 606.5 against 607.6)
        }
    }

    // The Input tab's own card (R14.5): "Input volume", a 205.5 pt slider between the Mac's two microphone glyphs
    // (settings/assets/r14/mic-*.png, cut from the still), and "Input level", 15 bars 7 x 15 pt, 17 apart, in place of
    // a slider. The volume is the default source's (wpctl). There is no level meter here: the bars stay unlit
    // (settings/FALLBACKS.md).
    Card {
        visible: io.tab === 1
        FormRow {
            label: "Input volume"
            implicitHeight: 38
            Slider {
                objectName: "soundInputVolume"
                width: 246
                tickMarks: 7
                value: pane.inVol.volume
                enabled: pane.status === "ok" && pane.sources.length > 0
                leftIcon: Component { Image { width: 17; height: 16; source: "../assets/r14/mic-low" + (Theme.dark ? "-dark.png" : "-light.png") } }
                rightIcon: Component { Image { width: 17; height: 16; source: "../assets/r14/mic-high" + (Theme.dark ? "-dark.png" : "-light.png") } }
                onMoved: v => { pane.draggingIn = true; pane.setInputVolume(v); inRelease.restart(); }
                Timer { id: inRelease; interval: 600; onTriggered: pane.draggingIn = false }
            }
        }
        FormRow {
            label: "Input level"
            implicitHeight: 38
            Item {   // the last bar ends 17 pt before the card's end (px 1406 of 1440)
                width: bars.width + 7; height: 15
                Row {
                    id: bars
                    objectName: "soundInputLevel"
                    spacing: 10
                    Repeater {
                        model: 15
                        Rectangle { width: 7; height: 15; radius: 3.5; color: Theme.dark ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.1) }
                    }
                }
            }
        }
    }

    PaneFooter { }
}
