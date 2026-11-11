import QtQuick

// One tick per frame of the window this item sits in, with the time since the first tick in whole frames.
//
// Why not FrameAnimation or a NumberAnimation: with more than one window exposed (the shell always has several) Qt's
// threaded render loop advances all animations from a GUI-thread timer of int(1000 / 60) = 16 ms, not from the
// window's frames (qsgthreadedrenderloop.cpp startOrStopAnimationTimer, Qt 6.10.2). Ticks 16.0 ms apart against
// frames 16.7 ms apart drift: a tick's value reaches the screen 8 to 24 ms later, and about every 0.4 s two ticks fall
// between two frames, so one value is never drawn (the "lost frame" of mcap's unlock, peek and Mission Control rows).
// QQuickWindow.afterAnimating is emitted on the GUI thread right before each frame of this window is built, so a value
// set there is drawn exactly once, and frame k is on screen k refresh intervals after frame 0. `elapsed` counts
// those intervals (k * 16.7 ms at 60 Hz) and skips the ones the window missed (a tick that comes late, see below).
// Nothing runs while `running` is false.
// `watchdog`: a window that draws no frame (unmapped, on a sleeping output) would hold a motion for ever; with it,
// stalled() is emitted when no tick came for one to two `stallMs`, and the owner jumps to its end. The timer only
// runs with the clock.
Item {
    id: fc
    visible: false
    width: 0
    height: 0
    property bool running: false
    property real elapsed: 0           // ms since the first tick's frame, a multiple of `interval`
    readonly property real interval: 1000 / (Screen.refreshRate > 0 ? Screen.refreshRate : 60)
    signal tick()
    property bool watchdog: false
    property int stallMs: 300
    signal stalled()

    property int frame: 0              // frames since the first tick's
    property int ticks: 0
    property bool ticked: false
    property double phase: 0           // the earliest tick phase of this run (ms), see the tick
    property int swaps: 0              // frames of this window swapped since start()
    property int built: 0              // frames of this window built since start()
    property bool flushOnSwap: false
    readonly property var win: Window.window
    // A window shown less than 150 ms ago (or not yet): the compositor presents a new layer surface from about its
    // third buffer, so the first `freshHold` frames built are never seen. They do not tick: the motion starts with
    // the first frame that reaches the screen (Control Center open, mcap: hold 0 shows .02 .02 .17, hold 1 a lost or
    // repeated value in 3 of 6 opens, hold 2 the same series .06 .17 .31 .45 in 7 of 8).
    // Frames this window already swapped since it was shown count towards that hold: a layer that drew its first
    // frames while its owner waited (Mission Control waits for its window captures with its layer mapped) starts its
    // motion on the next frame (mcap: two frames of e = 0 after the go, the flight 4 frames after the layer mapped)
    property double shownAt: 0
    property bool fresh: false
    property int tick0: 0
    property int freshHold: 2
    property int hold: 0               // frames of this run that do not tick
    property int shownSwaps: 0         // frames swapped since shown, counted up to freshHold
    Connections {
        target: fc.win
        function onVisibleChanged() { if (fc.win.visible) { fc.shownAt = Date.now(); fc.shownSwaps = 0; } }
    }
    Connections {
        target: fc.win
        enabled: fc.shownSwaps < fc.freshHold
        function onFrameSwapped() { fc.shownSwaps++; }
    }
    function flush(): void {
        flushOnSwap = false;
        const root = Window.contentItem;
        if (root) for (const c of root.children) c.ensurePolished();
    }
    function start(): void {
        fresh = !win || !win.visible || Date.now() - shownAt < 150;
        hold = !win || !win.visible ? freshHold : Math.max(0, freshHold - shownSwaps);
        tick0 = ticks;
        ticked = false;
        swaps = 0;
        built = 0;
        flushOnSwap = false;
        frame = 0;
        elapsed = 0;
        running = true;
        if (win) win.update();
    }
    function stop(): void { running = false; }
    onWinChanged: {
        shownAt = Date.now();
        shownSwaps = 0;
        if (running && win) win.update();
    }

    Connections {
        target: fc.win
        enabled: fc.running || fc.flushOnSwap
        function onAfterAnimating() {
            if (!fc.running) return;
            fc.ticks++;
            fc.built++;
            if (fc.fresh && fc.ticks - fc.tick0 <= fc.hold) { fc.win.update(); return; }
            if (fc.ticked) fc.frame++;
            fc.ticked = true;
            // A frame the window missed (a busy GUI or render thread) is stepped over, so the motion keeps its speed
            // and the late frame shows the value of its time. Lateness is read against the earliest phase any tick of
            // this run had (ticks follow the frame callbacks, so that is the screen's grid): a tick 3/4 of an interval
            // or more behind it has lost a frame. Not from the gaps between frameSwapped signals, as before: those
            // reach this thread with a jitter of half an interval, and a gap of 25 ms followed by one of 8 skipped a
            // value although every frame was shown (mcap: menu fade, a value lost in 5 of 8 with no gap on screen).
            const now = Date.now();
            let phase = now - fc.frame * fc.interval;
            if (fc.frame === 0 || phase < fc.phase) fc.phase = phase;
            else if (phase - fc.phase >= 0.75 * fc.interval) {
                fc.frame += Math.floor((phase - fc.phase) / fc.interval + 0.25);
                phase = now - fc.frame * fc.interval;
                if (phase < fc.phase) fc.phase = phase;
            }
            fc.elapsed = fc.frame * fc.interval;
            fc.tick();
            // What the tick changed outside the scene (Quickshell sends a window's blur region and input mask to
            // the surface from its content item's polish, on this thread) has to ride on this frame's commit.
            // Qt polishes before afterAnimating, so left alone it would go one frame late: polish now. But not
            // while the frame before this one is still on its way to the compositor (after idle Qt builds two
            // frames back to back, and from then on a frame is built while the one before waits for its frame
            // callback): then it would ride on that one, so it is sent when that frame has been swapped.
            if (fc.built - 1 - fc.swaps <= 0) fc.flush();
            else fc.flushOnSwap = true;
            if (fc.running) fc.win.update();
        }
        function onFrameSwapped() {
            fc.swaps++;
            if (fc.flushOnSwap && fc.built - 1 - fc.swaps <= 0) fc.flush();
        }
    }
    Timer {
        property int seen: -1
        interval: fc.stallMs
        repeat: true
        running: fc.running && fc.watchdog
        onRunningChanged: seen = -1
        onTriggered: {
            if (fc.ticks === seen && fc.running) fc.stalled();
            seen = fc.ticks;
        }
    }
}
