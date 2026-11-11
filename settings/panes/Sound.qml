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
    property string note: ""

    function refresh() {
        Backend.run(["wpctl", "status"], (code, out) => {
            status = Backend.status(code);
            if (status !== "ok") return;
            sinks = P.parseWpctlSinks(out);
            sources = P.parseWpctlSources(out);
            status = sinks.length ? "ok" : "nodevices";
        });
        Backend.run(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"], (c, o) => { if (!dragging) vol = P.parseWpctlVolume(o); });
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
            if (c !== 0) note = "The volume could not be changed.";
            _sendVolume();
        });
    }

    readonly property string soundsDir: Backend.root + "/sounds/wav"
    property string effectsNote: ""
    // `file` in sounds/wav (16-bit copies); the Apple original in sounds/originals plays when present (24-bit, what the
    // shell's scripts/sound.sh plays)
    function play(file, volume) {
        Backend.run(["sh", "-c", 'o="${1%.wav}"; o="${o%/sounds/wav/*}/sounds/originals/${o#*/sounds/wav/}"; f="$1"; '
                     + 'for e in aiff aif caf; do [ -f "$o.$e" ] && { f="$o.$e"; break; }; done; exec pw-play --volume "$2" "$f"',
                     "sh", file, volume.toFixed(2)], c => {
            effectsNote = c === 127 ? "Sound previews need pw-play (PipeWire tools)."
                        : c !== 0 ? "That sound could not be played." : "";
        });
    }
    function setDefault(id) {
        Backend.run(["wpctl", "set-default", String(id)], c => { note = c === 0 ? "" : "That output device could not be selected."; refresh(); });
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
            LocalPopup { model: ["Selected sound output device"].concat(pane.sinks.map(s => s.name)) }
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
                // macOS plays the alert once you let go of the knob
                onReleased: pane.play(pane.soundsDir + "/Sounds/" + AppState.sound.alertSound + ".wav", AppState.sound.alertVolume)
            }
        }
        FormRow { label: "Play sound on startup"; Switch { checked: AppState.sound.startupSound; onToggled: on => AppState.set("sound", { startupSound: on }) } }   // stored (sound.json); no startup sound exists to play
        FormRow { label: "Play user interface sound effects"; Switch { checked: AppState.sound.uiSounds; onToggled: on => AppState.set("sound", { uiSounds: on }) } }
        FormRow { label: "Play feedback when volume is changed"; Switch { checked: AppState.sound.volumeFeedback; onToggled: on => AppState.set("sound", { volumeFeedback: on }) } }
    }

    InlineNote { text: pane.effectsNote }

    Card {
        id: io
        title: "Output & Input"
        property int tab: 0       // 0 Output, 1 Input (view only)
        readonly property var nodes: tab === 0 ? pane.sinks : pane.sources
        Item {
            width: parent.width; height: 11 + 24 + 14
            SegmentedControl {
                x: Theme.content.rowPadding; y: 11
                width: parent.width - 2 * x
                model: ["Output", "Input"]
                currentIndex: io.tab
                onActivated: i => io.tab = i
            }
        }
        Item { // device table: Name / Type header and 24 pt rows, alternate rows striped, the default selected
            width: parent.width
            height: 24 * (1 + Math.max(4, io.nodes.length))
            clip: true
            Row {
                x: Theme.content.rowPadding; height: 24
                Text { width: 298; anchors.verticalCenter: parent.verticalCenter; text: "Name"; font: Typography.callout; color: Theme.label }
                Text { anchors.verticalCenter: parent.verticalCenter; text: "Type"; font: Typography.callout; color: Theme.label }
            }
            Repeater {
                model: Math.max(4, io.nodes.length)
                Rectangle {
                    required property int index
                    readonly property var node: index < io.nodes.length ? io.nodes[index] : null
                    y: 24 * (index + 1); width: parent.width; height: 24
                    bottomLeftRadius: index === Math.max(4, io.nodes.length) - 1 ? Theme.content.cardRadius : 0
                    bottomRightRadius: bottomLeftRadius
                    color: node && node.isDefault ? Theme.controlFill : index % 2 ? Qt.alpha(Theme.controlFill, Theme.controlFill.a * 0.4) : "transparent"
                    Text {
                        x: Theme.content.rowPadding; width: 290; elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                        text: parent.node ? parent.node.name : ""; font: Typography.body; color: Theme.label
                    }
                    Text {
                        x: Theme.content.rowPadding + 298; anchors.verticalCenter: parent.verticalCenter
                        text: !parent.node ? "" : /hdmi|display/i.test(parent.node.name) ? "HDMI" : /bluez|airpod|head/i.test(parent.node.name) ? "Bluetooth" : "Built-in"
                        font: Typography.body; color: Theme.label
                    }
                    MouseArea { anchors.fill: parent; enabled: parent.node !== null; onClicked: pane.setDefault(parent.node.id) }
                }
            }
        }
    }

    Card {
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
                    onReleased: if (AppState.sound.volumeFeedback) pane.play(pane.soundsDir + "/misc/BezelServices-volume.wav", 1)
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
    }

    InlineNote {
        text: pane.status === "missing" || pane.status === "failed" ? Backend.statusNote(pane.status, "PipeWire (wpctl)", "sound devices")
            : pane.status === "nodevices" ? "No output devices found." : pane.note
    }

    PaneFooter { }
}
