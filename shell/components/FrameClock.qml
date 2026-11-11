import QtQuick

// One tick per frame of the window this item sits in, with the time since the first tick in whole frames.
//
// Why not FrameAnimation or a NumberAnimation: with more than one window exposed (the shell always has several) Qt's
// threaded render loop advances all animations from a GUI-thread timer of int(1000 / 60) = 16 ms, not from the
// window's frames (qsgthreadedrenderloop.cpp startOrStopAnimationTimer, Qt 6.10.2). Ticks 16.0 ms apart against
// frames 16.7 ms apart drift: a tick's value reaches the screen 8 to 24 ms later, and about every 0.4 s two ticks fall
// between two frames, so one value is never drawn (the "lost frame" of mcap's unlock, peek and Mission Control rows).
// QQuickWindow.afterAnimating is emitted on the GUI thread right before each frame of this window is built, so a value
// set there is in that very frame, and frame k is on screen k refresh intervals after frame 0. `elapsed` counts
// those intervals (k * 16.7 ms at 60 Hz), read against the wall clock only to notice a frame that was never built.
// Nothing runs while `running` is false.
Item {
    id: fc
    property bool running: false
    property real elapsed: 0           // ms since the first tick's frame, a multiple of `interval`
    readonly property real interval: 1000 / (Screen.refreshRate > 0 ? Screen.refreshRate : 60)
    signal tick()

    property double last: 0
    readonly property var win: Window.window
    function start(): void {
        last = 0;
        elapsed = 0;
        running = true;
        if (win) win.update();
    }
    function stop(): void { running = false; }
    onWinChanged: if (running && win) win.update()

    Connections {
        target: fc.win
        enabled: fc.running
        function onAfterAnimating() {
            const now = Date.now();
            if (fc.last > 0) fc.elapsed += Math.max(1, Math.round((now - fc.last) / fc.interval)) * fc.interval;
            fc.last = now;
            fc.tick();
            if (fc.running) fc.win.update();
        }
    }
}
