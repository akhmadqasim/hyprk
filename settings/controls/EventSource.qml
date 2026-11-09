import QtQuick
import ".."

// Emits `changed` when a system event stream (e.g. `nmcli monitor`) prints
// something, at most every 300 ms. Polls every `pollInterval` ms while the stream
// can't run; a stream that exits is restarted after 5 s. Panes refresh on `changed`.
Item {
    id: es
    property var command: []
    property int pollInterval: 15000
    property bool active: true
    property var filter: null          // RegExp; only matching lines count as events
    property bool _streaming: false
    signal changed()

    // Not restarted per line, so a busy stream still refreshes every 300 ms.
    Timer { id: debounce; interval: 300; onTriggered: es.changed() }
    Timer { id: retry; interval: 5000; onTriggered: es.start() }
    Timer { interval: es.pollInterval; repeat: true; running: es.active && !es._streaming; onTriggered: es.changed() }

    function start() {
        _streaming = Backend.stream(es, command,
            line => { if (es.active && (!es.filter || es.filter.test(line)) && !debounce.running) debounce.start(); },
            code => { es._streaming = false; if (code !== 127) retry.start(); }) !== null;
    }
    Component.onCompleted: if (command.length) start()
}
