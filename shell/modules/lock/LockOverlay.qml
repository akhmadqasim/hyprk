import QtQuick
import Quickshell
import Quickshell.Wayland
import "lock.js" as L

// Layer surface per screen for the two transitions the session lock cannot show itself (Hyprland
// stops drawing the desktop under a lock surface). Both follow the Mac's per-frame tracks (LOCKSCREEN-27.2.1.md B1,
// B3; LockTheme): one linear clock `t` in Mac ms, every layer read from its track. Opacity only, nothing moves.
//   "in"  maps transparent, and once that first frame is on screen (so the frame that builds the scene is not one
//         of the animation's) fades the lock picture in over the live desktop, keyboard grabbed, then
//         Lock.engage(): the menu bar strip, the rest of the wallpaper (Dock, windows), the dim, the clock group and
//         the avatar group each on their own track
//   "out" appears with the full lock picture while the lock is still up, tells Lock it is on screen (the lock is
//         released under it), then the avatar, line and status items go at once and the rest follows its
//         track back to the desktop; click-through, no keyboard.
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
    property real t: LockTheme.trackStart          // Mac ms since the first changed frame
    property bool userGone: false
    // "in": every layer is drawn from the first (still unchanged) frame at an opacity too low to change a pixel, so
    // the frame that builds the clock's glyphs and ink layers is not one of the fade's (it held a frame: mcap)
    function warm(v: real): real { return Math.max(v, LockTheme.warmOpacity); }

    LockContent {
        anchors.fill: parent
        primary: Lock.isMain(w.screen)
        output: w.screen
        interactive: false
        wall: w.entering ? w.warm(L.track(LockTheme.inWall, w.t)) : 1 - L.track(LockTheme.outWall, w.t)
        bar: w.entering ? w.warm(L.track(LockTheme.inBar, w.t)) : 1 - L.track(LockTheme.outBar, w.t)
        dim: w.entering ? w.warm(L.track(LockTheme.inDim, w.t)) : 1 - L.track(LockTheme.outDim, w.t)
        ui: w.entering ? w.warm(L.track(LockTheme.inUi, w.t)) : 1 - L.track(LockTheme.outUi, w.t)
        date: w.entering ? w.warm(L.track(LockTheme.inDate, w.t)) : 1 - L.track(LockTheme.outDate, w.t)
        field: w.entering ? w.warm(L.track(LockTheme.inField, w.t)) : 1 - L.track(LockTheme.outField, w.t)
        user: w.entering ? w.warm(L.track(LockTheme.inUser, w.t)) : w.userGone ? 0 : 1
        caret: w.entering
    }

    // `t` runs on the wall clock, read every frame: Qt's threaded render loop steps animations one vsync per frame,
    // so frames held at the start (the GUI thread stalls 50-280 ms after the session lock goes in about a third of
    // unlocks) delayed the rest of the track to the end (clock 95 % at +236 or later vs the Mac's +220, mcap). Now
    // the frame after a held one shows the Mac's value for its time. A frame is shown about `frameLead` after the
    // GUI computes it.
    property double startedAt: 0
    property real from: 0
    property real to: 0
    property int duration: 1
    function run(a: real, b: real, ms: int): void {
        from = a; to = b; duration = Math.max(1, ms);
        startedAt = Date.now();
        t = a;
        clock.start();
    }
    FrameAnimation {
        id: clock
        onTriggered: {
            w.t = Math.min(w.to, w.from + (Date.now() - w.startedAt + LockTheme.frameLead) * (w.to - w.from) / w.duration);
            if (w.t < w.to) return;
            stop();
            if (w.entering) Lock.engage();
            else Lock.finish();
        }
    }
    function reveal(): void {
        userGone = true;
        run(0, LockTheme.outEnd, LockTheme.unlockOut);
    }
    // Start the fade ("in") or tell Lock ("out") once a frame of this window is on screen. A frame swap after a scene sync that started after the request holds the full picture (render-thread
    // signals arrive queued).
    property int frameState: 0          // 0 idle, 1 waiting for a sync, 2 waiting for its swap
    Item { id: probe; readonly property var qw: Window.window }   // the QQuickWindow behind this PanelWindow
    Connections {
        target: probe.qw
        enabled: w.frameState > 0
        function onAfterSynchronizing() { if (w.frameState === 1) w.frameState = 2; }
        function onFrameSwapped() {
            if (w.frameState !== 2) return;
            w.frameState = 0;
            if (w.entering) w.run(LockTheme.trackStart, LockTheme.inEnd, LockTheme.lockIn);
            else Lock.overlayReady();
        }
    }
    Connections {
        target: Lock
        enabled: w.mode === "out"
        // started at once: waiting for a frame of ours after the release showed the bare desktop for one frame in 3 of
        // 12 unlocks (mcap); started here the first frame is held once instead
        function onReleasedChanged() { if (Lock.released) w.reveal(); }
    }
    Component.onCompleted: Qt.callLater(() => { w.frameState = 1; if (probe.qw) probe.qw.update(); })
}
