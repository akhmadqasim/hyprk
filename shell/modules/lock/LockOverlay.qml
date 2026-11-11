import QtQuick
import Quickshell
import Quickshell.Wayland

// Layer surface per screen for the two transitions the session lock cannot show itself (Hyprland
// stops drawing the desktop under a lock surface), timed as on 27.2.1 (LOCKSCREEN-27.2.1.md B1, B3; LockTheme):
//   "in"  fades the lock picture in over the live desktop, keyboard grabbed, then Lock.engage(): the wallpaper
//         covers the menu bar in 100 ms and the rest (Dock, windows) in 190 ms, the dim comes up in 230 ms, the
//         clock, date, field, avatar and status items fade in over 250 ms; nothing moves
//   "out" appears with the full lock picture while the lock is still up, tells Lock it is on screen (the
//         lock is released under it), then the avatar, line and status items go at once, the clock, date and
//         field fade (ease-in), the wallpaper uncovers the Dock and windows from +89 ms and the menu bar from
//         +111 ms, and the dim lifts; click-through, no keyboard.
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

    readonly property bool entering: mode === "in"
    property real wall: entering ? 0 : 1
    property real bar: entering ? 0 : 1
    property real dim: entering ? 0 : 1
    property real ui: entering ? 0 : 1
    property real user: entering ? 0 : 1

    LockContent {
        anchors.fill: parent
        primary: Lock.isMain(w.screen)
        interactive: false
        wall: w.wall
        bar: w.bar
        dim: w.dim
        ui: w.ui
        user: w.entering ? w.ui : w.user
    }

    ParallelAnimation {
        id: fadeIn
        NumberAnimation { target: w; property: "bar"; to: 1; duration: LockTheme.inBar; easing.type: Easing.InOutQuad }
        NumberAnimation {
            target: w; property: "wall"; to: 1; duration: LockTheme.inWall
            easing.type: Easing.BezierSpline; easing.bezierCurve: LockTheme.cssEase
        }
        NumberAnimation { target: w; property: "dim"; to: 1; duration: LockTheme.inDim }
        SequentialAnimation {
            PauseAnimation { duration: LockTheme.inUiDelay }
            NumberAnimation { target: w; property: "ui"; to: 1; duration: LockTheme.inUi; easing.type: Easing.OutQuad }
        }
        onFinished: Lock.engage()
    }
    ParallelAnimation {
        id: reveal
        PropertyAction { target: w; property: "user"; value: 0 }
        NumberAnimation {
            target: w; property: "ui"; from: LockTheme.outUiFrom; to: 0; duration: LockTheme.outUi
            easing.type: Easing.BezierSpline; easing.bezierCurve: LockTheme.outUiCurve
        }
        SequentialAnimation {
            PauseAnimation { duration: LockTheme.outWallDelay }
            NumberAnimation { target: w; property: "wall"; to: 0; duration: LockTheme.outWall; easing.type: Easing.InQuad }
        }
        SequentialAnimation {
            PauseAnimation { duration: LockTheme.outBarDelay }
            NumberAnimation { target: w; property: "bar"; to: 0; duration: LockTheme.outBar; easing.type: Easing.InOutQuad }
        }
        NumberAnimation { target: w; property: "dim"; to: 0; duration: LockTheme.outDim; easing.type: Easing.OutQuad }
        onFinished: Lock.finish()
    }
    // "out": tell Lock once a frame of this window is on screen. A frame swap after a scene sync that
    // started after the window was created holds the full picture (render-thread signals arrive queued).
    property int frameState: 0          // 0 idle, 1 waiting for a sync, 2 waiting for its swap
    Item { id: probe; readonly property var qw: Window.window }   // the QQuickWindow behind this PanelWindow
    Connections {
        target: probe.qw
        enabled: w.frameState > 0
        function onAfterSynchronizing() { if (w.frameState === 1) w.frameState = 2; }
        function onFrameSwapped() { if (w.frameState === 2) { w.frameState = 0; Lock.overlayReady(); } }
    }
    Connections {
        target: Lock
        enabled: w.mode === "out"
        function onReleasedChanged() { if (Lock.released) reveal.start(); }
    }
    Component.onCompleted: {
        if (mode === "in") fadeIn.start();
        else Qt.callLater(() => { w.frameState = 1; if (probe.qw) probe.qw.update(); });
    }
}
