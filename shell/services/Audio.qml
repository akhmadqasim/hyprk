pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../lib/state.js" as State

// Default output volume via PipeWire. `available` is false without PipeWire
// or a sink, and the Sound slider is shown disabled.
Singleton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool available: State.hasAudio(Pipewire.ready, sink)
    readonly property real volume: available ? sink.audio.volume : 0
    readonly property bool muted: available ? sink.audio.muted : false

    function setVolume(v) {
        if (!available) return;
        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(1, v));
        Sounds.volumeChanged();
    }

    // output devices (Control Center's Sound module); choosing one makes it the preferred default sink, PipeWire's
    // session manager then moves the default to it
    readonly property var outputs: State.outputSinks(Pipewire.nodes.values)
    function setOutput(node) {
        if (node) Pipewire.preferredDefaultAudioSink = node;
    }
    function name(node) { return State.deviceName(node); }

    PwObjectTracker { objects: root.sink ? [root.sink] : [] }
}
