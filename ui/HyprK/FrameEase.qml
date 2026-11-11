import QtQuick

// `value` follows `goal` over `duration` on `ease` / `curve`, one value per frame (FrameAnim): what
// `Behavior on x { NumberAnimation {} }` does, for a value drawn in a shell window. A change of the goal in flight
// starts again from the current value, as a Behavior does. animate: false jumps. The goal is followed once the
// change's other bindings have settled (`animate` may hang on the same change), still before the next frame.
FrameAnim {
    id: e
    property real goal: 0
    property bool animate: true
    property bool _ready: false
    Component.onCompleted: {
        value = goal;
        _ready = true;
    }
    function _follow(): void {
        if (value === goal && !running) return;
        stop();
        if (!animate || !(duration > 0)) { value = goal; return; }
        from = value;
        to = goal;
        start();
    }
    onGoalChanged: if (_ready) Qt.callLater(_follow)
}
