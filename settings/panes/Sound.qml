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
    property var vol: P.parseWpctlVolume("")
    property string note: ""

    function refresh() {
        Backend.run(["wpctl", "status"], (code, out) => {
            status = Backend.status(code);
            if (status !== "ok") return;
            sinks = P.parseWpctlSinks(out);
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
    function play(file, volume) {
        Backend.run(["pw-play", "--volume", volume.toFixed(2), file], c => {
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

    Card {
        title: "Sound Effects"
        FormRow {
            label: "Alert sound"
            Popup {
                model: P.alertSounds
                currentIndex: P.alertSounds.indexOf(AppState.sound.alertSound)
                onActivated: i => {
                    AppState.set("sound", { alertSound: P.alertSounds[i] });
                    pane.play(pane.soundsDir + "/Sounds/" + P.alertSounds[i] + ".wav", AppState.sound.alertVolume);
                }
            }
        }
        FormRow {
            label: "Alert volume"
            Slider {
                width: 230
                value: AppState.sound.alertVolume
                leftGlyph: "volume_mute"; rightGlyph: "volume_up"
                onMoved: v => AppState.set("sound", { alertVolume: Math.round(v * 100) / 100 })
                // macOS plays the alert once you let go of the knob
                onReleased: pane.play(pane.soundsDir + "/Sounds/" + AppState.sound.alertSound + ".wav", AppState.sound.alertVolume)
            }
        }
        FormRow { label: "Play sound on startup"; LocalSwitch { checked: true } }
        FormRow { label: "Play user interface sound effects"; Switch { checked: AppState.sound.uiSounds; onToggled: on => AppState.set("sound", { uiSounds: on }) } }
        FormRow { label: "Play feedback when volume is changed"; Switch { checked: AppState.sound.volumeFeedback; onToggled: on => AppState.set("sound", { volumeFeedback: on }) } }
    }

    InlineNote { text: pane.effectsNote }

    Card {
        title: "Output & Input"
        FormRow {
            label: "Output volume"
            Slider {
                width: 230
                value: pane.vol.volume
                enabled: pane.status === "ok"
                leftGlyph: "volume_mute"; rightGlyph: "volume_up"
                onMoved: v => { pane.dragging = true; pane.setVolume(v); dragRelease.restart(); }
                onReleased: if (AppState.sound.volumeFeedback) pane.play(pane.soundsDir + "/misc/BezelServices-volume.wav", 1)
                Timer { id: dragRelease; interval: 600; onTriggered: pane.dragging = false }
            }
        }
        FormRow {
            label: "Mute"
            Switch {
                checked: pane.vol.muted
                enabled: pane.status === "ok"
                onToggled: on => {
                    pane.vol = Object.assign({}, pane.vol, { muted: on });   // shown at once, refresh() corrects it
                    Backend.run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", on ? "1" : "0"], () => pane.refresh());
                }
            }
        }
    }

    InlineNote {
        text: pane.status === "missing" || pane.status === "failed" ? Backend.statusNote(pane.status, "PipeWire (wpctl)", "sound devices")
            : pane.status === "nodevices" ? "No output devices found." : pane.note
    }

    Card {
        visible: pane.status === "ok"
        title: "Output"
        Repeater {
            model: pane.sinks
            FormRow {
                required property var modelData
                glyph: /hdmi|display/i.test(modelData.name) ? "tv" : /bluez|airpod|head/i.test(modelData.name) ? "headphones" : "speaker"
                tint: Theme.tile.gray
                label: modelData.name
                onClicked: pane.setDefault(modelData.id)
                Text { visible: modelData.isDefault; text: "check"; font.family: Theme.fontGlyph; font.pixelSize: 18; color: Theme.accent }
            }
        }
    }

    PaneFooter { }
}
