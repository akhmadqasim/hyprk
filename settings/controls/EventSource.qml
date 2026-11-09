import QtQuick
import ".."

// Emits `changed` when a system event stream (e.g. `nmcli monitor`) prints
// something, debounced. Falls back to polling every `pollInterval` ms when the
// stream can't run or stops. Panes refresh on `changed`.
Item {
    id: es
    property var command: []
    property int pollInterval: 15000
    property bool active: true
    property var filter: null          // RegExp; only matching lines count as events
    property bool _streaming: false
    signal changed()

    Timer { id: debounce; interval: 300; onTriggered: es.changed() }
    Timer { interval: es.pollInterval; repeat: true; running: es.active && !es._streaming; onTriggered: es.changed() }

    Component.onCompleted: {
        if (!command.length) return;
        _streaming = Backend.stream(es, command, line => { if (es.active && (!es.filter || es.filter.test(line))) debounce.restart(); }, () => es._streaming = false) !== null;
    }
}
