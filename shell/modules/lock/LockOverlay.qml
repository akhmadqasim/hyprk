import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.components

// Layer surface per screen for the two transitions the session lock cannot show itself (Hyprland
// stops drawing the desktop under a lock surface):
//   "in"  fades the lock picture in over the live desktop, keyboard grabbed, then Lock.engage()
//   "out" appears with the full lock picture while the lock is still up, tells Lock it is on screen
//         (the lock is released under it), then the clock rises, the user group drops and the
//         backdrop fades, revealing the desktop; click-through, no keyboard.
// Namespace hyprk-lock has no compositor layer animation (hyprland.lua), so the first frame is exact.
PanelWindow {
    id: w
    required property var modelData
    property string mode: "in"

    screen: modelData
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "hyprk-lock"
    WlrLayershell.keyboardFocus: mode === "in" ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    mask: mode === "out" ? noInput : null
    Region { id: noInput }

    property real shown: mode === "in" ? 0 : 1
    property real leave: 0

    LockContent {
        anchors.fill: parent
        primary: Lock.isMain(w.screen)
        interactive: false
        backdrop: w.shown * (1 - w.leave)
        ui: w.shown
        leave: w.leave
    }

    NumberAnimation {
        id: fadeIn
        target: w; property: "shown"; from: 0; to: 1
        duration: LockTheme.lockIn
        easing.type: Easing.BezierSpline; easing.bezierCurve: LockTheme.ease
        onFinished: Lock.engage()
    }
    NumberAnimation {
        id: reveal
        target: w; property: "leave"; from: 0; to: 1
        duration: LockTheme.unlockOut
        easing.type: Easing.BezierSpline; easing.bezierCurve: LockTheme.ease
        onFinished: Lock.finish()
    }
    FramePresented {
        id: presented
        onPresented: Lock.overlayReady()
    }
    Connections {
        target: Lock
        enabled: w.mode === "out"
        function onReleasedChanged() { if (Lock.released) reveal.start(); }
    }
    Component.onCompleted: {
        if (mode === "in") fadeIn.start();
        else presented.arm();
    }
}
