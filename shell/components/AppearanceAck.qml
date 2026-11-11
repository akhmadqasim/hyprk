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
    function apply(r) {
        stage = r.stage;
        if (r.update && win) win.update();
        if (r.done) Theme.appearanceDone(epoch);
    }
    function drop() { if (stage > 0) { stage = 0; Theme.appearanceDone(epoch); } }   // a window that went away has nothing left to show
    Connections {
        target: Theme
        function onAppearanceEpochChanged() {
            ack.stage = 0;
            if (!ack.win || !ack.win.visible) return;
            ack.epoch = Theme.appearanceEpoch;
            Theme.appearanceWait();
            ack.apply(Handshake.step(0, "begin"));
        }
    }
    Connections {
        target: ack.win
        enabled: ack.stage > 0
        function onAfterAnimating() { ack.apply(Handshake.step(ack.stage, "built")); }
        function onFrameSwapped() { ack.apply(Handshake.step(ack.stage, "swapped")); }
        function onVisibleChanged() { if (!ack.win.visible) ack.drop(); }
    }
    onWinChanged: if (!win) drop()
    Component.onDestruction: drop()
}
