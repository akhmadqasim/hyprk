pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import "../lib/state.js" as State

// Default output volume via PipeWire. `available` is false without PipeWire
// or a sink, and the Sound slider is shown disabled.
Singleton {
    id: root

    // HYPRK_AUDIO_STUB=1 or HYPRK_STATUS_STUB=1 (headless test sessions only): a made-up sink kept in memory and in the
    // volume key folder's "stub-sink" file (lib/state.js parseStubSink), shared with scripts/volume-key.sh, so the
    // Control Center Sound slider, the volume keys and the HUD can be tested without touching the machine's real
    // PipeWire volume. Nothing here then reads or writes a PipeWire node.
    readonly property bool stub: Quickshell.env("HYPRK_AUDIO_STUB") === "1" || Quickshell.env("HYPRK_STATUS_STUB") === "1"
    property real stubVolume: 0.5
    property bool stubMuted: false
    // two made-up outputs (names made up): the built-in speakers and headphones, to fill the Sound module's list
    readonly property var stubOutputs: [
        { description: "Speakers", properties: { "device.form-factor": "internal" } },
        { description: "Headphones", properties: { "device.form-factor": "headphone", "device.description": "Headphones" } }
    ]
    property int stubSelected: 0

    readonly property var sink: stub ? null : Pipewire.defaultAudioSink
    // the selected output (Control Center's Sound module): the default sink, or the stub's chosen made-up output
    readonly property var current: stub ? stubOutputs[stubSelected] : sink
    readonly property bool available: stub || State.hasAudio(Pipewire.ready, sink)
    readonly property real volume: stub ? stubVolume : available ? sink.audio.volume : 0
    readonly property bool muted: stub ? stubMuted : available ? sink.audio.muted : false

    function setVolume(v) {
        if (!available) return;
        if (stub) {
            stubMuted = false;
            stubVolume = Math.max(0, Math.min(1, v));
            stubFile.setText(State.formatStubSink(stubVolume, stubMuted));
            return;
        }
        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(1, v));
    }

    // output devices (Control Center's Sound module); choosing one makes it the preferred default sink, PipeWire's
    // session manager then moves the default to it
    readonly property var outputs: stub ? stubOutputs : State.outputSinks(Pipewire.nodes.values)
    function setOutput(node) {
        if (stub) { const i = stubOutputs.indexOf(node); if (i >= 0) stubSelected = i; return; }
        if (node) Pipewire.preferredDefaultAudioSink = node;
    }
    function name(node) { return State.deviceName(node); }
    // the device's kind as a glyph (lib/state.js deviceSymbol); a node's properties are there while it is tracked
    readonly property bool laptop: UPower.displayDevice.isLaptopBattery
    function symbol(node) { return State.deviceSymbol(node ? node.properties : null, laptop); }

    PwObjectTracker { objects: root.stub ? [] : (root.sink ? [root.sink] : []).concat(root.outputs) }

    // the stub's file: volume-key.sh writes it (rename), the slider through setVolume; the folder is made first
    readonly property string stubDir: State.volkeyDir(Quickshell.env("HYPRK_VOLKEY_DIR"), Quickshell.env("XDG_RUNTIME_DIR"),
                                                      Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE"))
    property bool stubDirMade: false
    Process {
        running: root.stub && !root.stubDirMade
        command: ["mkdir", "-p", root.stubDir]
        onExited: root.stubDirMade = true
    }
    FileView {
        id: stubFile
        path: root.stub && root.stubDirMade ? root.stubDir + "/stub-sink" : ""
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            const t = text();
            if (t.trim() === "") return;
            const s = State.parseStubSink(t);
            root.stubVolume = s.volume;
            root.stubMuted = s.muted;
        }
    }
}
