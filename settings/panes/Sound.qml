import QtQuick
import ".."
import "../controls"
import "../Parsers.js" as P

// Functional via wpctl (PipeWire): output device and volume.
Column {
    id: pane
    spacing: Theme.content.sectionGap

    property string status: "loading"     // loading | unsupported | nodevices | ok
    property var sinks: []
    property var vol: P.parseWpctlVolume("")
    property string note: ""

    function refresh() {
        Backend.run(["wpctl", "status"], (code, out) => {
            if (code !== 0) { status = "unsupported"; return; }
            sinks = P.parseWpctlSinks(out);
            status = sinks.length ? "ok" : "nodevices";
            Backend.run(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"], (c, o) => { if (!dragging) vol = P.parseWpctlVolume(o); });
        });
    }
    property bool dragging: false
    function setVolume(v) {
        Backend.run(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", v.toFixed(2)], c => { if (c !== 0) note = "The volume could not be changed."; });
    }
    function setDefault(id) {
        Backend.run(["wpctl", "set-default", String(id)], c => { note = c === 0 ? "" : "That output device could not be selected."; refresh(); });
    }
    Component.onCompleted: refresh()
    Timer { interval: 3000; running: pane.status !== "unsupported"; repeat: true; onTriggered: pane.refresh() }

    Card {
        FormRow { label: "Alert sound"; MacPopup { model: ["Boop", "Breeze", "Bubble", "Crystal", "Funky", "Heroine", "Jump", "Mezzo", "Pebble", "Pluck", "Pong", "Sonar", "Sonumi", "Submerge"]; currentIndex: 1 } }
        FormRow { label: "Play sound on startup"; MacSwitch { checked: true } }
        FormRow { label: "Play user interface sound effects"; MacSwitch { checked: true } }
        FormRow { label: "Play feedback when volume is changed"; MacSwitch { checked: false } }
    }

    Card {
        title: "Output & Input"
        FormRow {
            label: "Output volume"
            MacSlider {
                width: 230
                value: pane.vol.volume
                enabled_: pane.status === "ok"
                leftGlyph: "volume_mute"; rightGlyph: "volume_up"
                onMoved: v => { pane.dragging = true; pane.setVolume(v); dragRelease.restart(); }
                Timer { id: dragRelease; interval: 600; onTriggered: pane.dragging = false }
            }
        }
        FormRow {
            label: "Mute"
            MacSwitch {
                checked: pane.vol.muted
                enabled_: pane.status === "ok"
                onToggled: on => Backend.run(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", on ? "1" : "0"], () => pane.refresh())
            }
        }
    }

    InlineNote {
        text: pane.status === "unsupported" ? "PipeWire (wpctl) is not available, so sound devices can't be shown."
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

    Row { anchors.right: parent.right; HelpButton {} }
}
