import QtQuick
import qs
import "../lib/handshake.js" as Handshake

// One shell window's part of the appearance handshake (Theme.appearanceEpoch): after a light <-> dark switch it tells
// Theme when this window has committed a frame built after the switch (lib/handshake.js), or at once when the window
// is not shown. Sits in every ShellWindow; nothing is connected to the window's frames outside a switch.
Item {
    id: ack
    visible: false
    width: 0; height: 0
    readonly property var win: Window.window
    property int stage: 0
    property int epoch: 0
    // the window still prepares its new content (Background: the new appearance's wallpaper is cut and decoded
    // asynchronously): the answer starts only once it is false. Read one event-loop turn after the switch, so a
    // service that starts its work in its own handler of the same change is seen as busy.
    property bool busy: false
    property bool waiting: false   // registered for this switch, frames not followed yet
    function start() {
        if (!waiting || busy) return;
        waiting = false;
        apply(Handshake.step(0, "begin"));
    }
    onBusyChanged: if (!busy) start()
    function apply(r) {
        stage = r.stage;
        if (r.update && win) win.update();
        if (r.done) Theme.appearanceDone(epoch);
    }
    function drop() { if (stage > 0 || waiting) { stage = 0; waiting = false; Theme.appearanceDone(epoch); } }   // a window that went away has nothing left to show
    Connections {
        target: Theme
        function onAppearanceEpochChanged() {
            ack.stage = 0;
            ack.waiting = false;
            if (!ack.win || !ack.win.visible) return;
            ack.epoch = Theme.appearanceEpoch;
            Theme.appearanceWait();
            ack.waiting = true;
            Qt.callLater(() => ack.start());
        }
    }
    Connections {
        target: ack.win
        enabled: ack.stage > 0 || ack.waiting
        function onAfterAnimating() { ack.apply(Handshake.step(ack.stage, "built")); }
        function onFrameSwapped() { ack.apply(Handshake.step(ack.stage, "swapped")); }
        function onVisibleChanged() { if (!ack.win.visible) ack.drop(); }
    }
    onWinChanged: if (!win) drop()
    Component.onDestruction: drop()
}
