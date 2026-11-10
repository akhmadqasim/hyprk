import QtQuick

// Tells when this item's window has put on screen a frame that holds every change made before
// arm(): presented() fires on the first frame swap (= wl_surface commit) after a scene sync that
// started after arm(). Render-thread signals reach QML as queued events, so a sync event delivered
// after the event that arm() posts was synced after the change (an earlier one would be stale).
// Used to change two layer surfaces in order (MenuBar pill after the Overlay's dropdown).
Item {
    id: fp
    signal presented()
    readonly property var win: Window.window
    property int _state: 0          // 0 idle, 1 waiting for a sync, 2 waiting for its swap
    function arm() {
        _state = 0;
        Qt.callLater(() => { fp._state = 1; if (fp.win) fp.win.update(); });
    }
    Connections {
        target: fp.win
        function onAfterSynchronizing() { if (fp._state === 1) fp._state = 2; }
        function onFrameSwapped() { if (fp._state === 2) { fp._state = 0; fp.presented(); } }
    }
}
