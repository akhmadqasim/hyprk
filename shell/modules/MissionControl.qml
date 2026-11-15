import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import qs
import qs.components
import qs.HyprK
import qs.services
import "../lib/spring.js" as SpringLib
import "../lib/state.js" as State
import "../lib/expose.js" as Expose

// Mission Control (Super+Up): live thumbnails of the windows on the current Space laid out
// without overlap, the Spaces bar at the top. Click a window to focus it, a Space to switch,
// empty space or Esc to close.
// macOS 27.2.1 (MAC-ANSWERS.md R2 and Q-dock-27): the windows move and scale from where they are into the
// layout and back, the wallpaper is NOT dimmed or blurred, the menu bar and the desktop widgets go away, the
// Dock stays visible, and the Spaces bar shows the Desktops as small labelled pills with "+" at the right.
// Motion (WindowManager.framework preferences, "REA 27.2.1" section 5): one critically damped spring, response
// 0.25 s, for enter and exit (ExposeSpring*); the Spaces bar leaves on its own one, response 0.125 s
// (SpacesBarExitSpringResponse). Each is one exact NumberAnimation (components/SpringCurve.qml).
// How: this layer draws the plain wallpaper over everything but the Dock's band (Panels.dockZones) and the thumbnails,
// which start exactly over the real windows, fly to their places. The wallpaper is opaque over the windows for the
// whole flight (it reaches 1 in the first 6 % of `e` and leaves in the last 6 %), so only the geometry moves, as the
// Mac's windows do; only the menu bar strip (with its top dimming) fades with `e`. Fading all of it with `e` cross-faded
// the real windows with the wallpaper under the flying thumbnails: the screen ran ahead of the spring early and lagged
// it at the end, so the code's 0.25 response measured too slow and had been stretched to fit (MOTION-MEASURED.md).
// Reduce motion: the same springs within 0.15 s as a dissolve, no flight.
ShellWindow {
    id: mc

    required property var modelData
    screen: modelData

    readonly property bool shown: Panels.open === "mission"

    // Numbers that are ours (no Theme.qml tokens yet; Q-dock-27..31 will answer the guessed ones)
    readonly property QtObject m: QtObject {
        // Exit: ExposeSpringResponse 0.25 (the code value) with the Mac track's start velocity (exitKick) measures like
        // the R2 exit series with the wallpaper opaque over the windows (one Finder window, mcap: 2-98 % 267 ms vs 267,
        // rms 0.009-0.011 / 3-5 ms). Enter: the R2 enter series (333 ms) is slower than 0.25 (250 ms on screen); 0.33
        // measures 333-336 ms. The share-of-change metric depends on the windows (2 overlapping windows run long, 4 small
        // ones short), MOTION-MEASURED.md session 7
        readonly property var expose: SpringLib.fromResponse(0.33, 1)
        readonly property var exposeExit: SpringLib.fromResponse(0.25, 1)
        // Start velocity of the exit: none. Measured on the window positions themselves (MOTION-REA-27.2.1.md Round 4,
        // R4.2: reference/screens/27.2.1/live/mc-exit-4-windows.mov, 4 windows, the back one clicked): Window 4's top-left
        // corner and Window 1's bottom edge follow the decoded (1.0, 0.25) spring from rest, .07 .21 .35 .50 .63 .71 .79
        // .85 per 60 Hz frame, rms .008 / .010; with the old kick of 10 the first frames would be .18 .35. The 0.21 first
        // frame of the R2 series was the share-of-change metric, not the windows' way
        readonly property real exitKick: 0
        // the wallpaper reaches full opacity over the windows within this share of `e` (and leaves within it on exit)
        readonly property real coverEnd: 0.06
        // the wallpaper's top dimming under the menu bar (Background.qml topDim) reaches this far; the menu bar's band
        // fades with `e`, the dimming below it is redrawn over the cover (stripDim)
        readonly property int stripHeight: 100
        // the Spaces bar's way out (MAC-ANSWERS-10.md R10.1, mc-exit-menubar-flat-grey.mov over a flat wallpaper): it
        // slides up solid, its bottom edge 68 -> 53 42 32 24 16 11 7 4 2 0 pt per 60 Hz frame (about 150 ms, the largest
        // step first). No spring from rest starts like that (the windows' 0.25: 64 55 44 35 ...; the decoded
        // SpacesBarExitSpringResponse 0.125: 55 35 20 ...), so the measured track is played as it is. (Until R10.1 the
        // windows' spring, fitted on mc-exit-esc.mov's .22 .38 .53 .66 .78 .89 .94 .97 at rms .043: the same track.)
        // R11.7: that clip's display mode (1440x932) has a 68 pt bar (mc-spaces-bar-collapsed-1440x932-dark-top.png, rows
        // 0..135; the clip's last still frame has the edge at row 136), so the track is a share of 68, not 69, played
        // over this bar's height
        readonly property var barExit: SpringLib.fromTrack([68, 53, 42, 32, 24, 16, 11, 7, 4, 2, 0].map(v => 1 - v / 68), 1 / 60)
        // collapsed Spaces bar (Q-dock-31, mission-control.json spaces_bar, dock/mc-{dark,light}.png): a band 74 pt
        // tall over the menu bar zone (R11.7 mc-spaces-bar-collapsed-1710x1107-dark-top.png: rows 0..147 at 2x = 74 pt
        // at the default mode, the notch inset 33.5 + 40; 68 = 28 + 40 at 1440x932. Our menu bar is the default mode's), name pills 24 pt tall (r 12) centred on y 53.5 with a +35 / 255 fill, "+" a
        // 20 pt glyph, grey 229, 16 pt from the right edge, centre y 37
        // the picked window's key look: from this share of the way back (pickLook)
        readonly property real pickLookAt: 0.13
        readonly property int barHeight: 74
        // Expanded (the pointer has entered the bar) the Mac's bar is inset + 132 (R11.7: 160 pt at 1440x932, 166 at
        // the default mode, the Space's frame from inset + 10). MAC-ANSWERS-18.md R18.1
        // (live/r18/mc-spaces-bar-expand-dark.mov, measured per frame): +92 pt on WindowManager's decoded critically
        // damped (1.0, 0.38) spring (MOTION-REA "Spring chosen"; fitted free: response 0.3775, ratio 1), which starts
        // 71 ms after the pointer entered and stays expanded when the pointer leaves. The window tops stay 39.5 pt
        // under the bar's edge in every frame: rms 0.22 pt over the 28 frames (the bar's own edge runs one frame
        // ahead in two of them and repeats in the third: 86.5 95.5 95.5 against 77.5 86 95.5, rms 2.6 pt with those).
        // The windows: the layout again with the bar 92 pt taller (the top row down 92 pt at its size, a window
        // lower down stays), each on the same spring.
        readonly property int barExpand: 92
        readonly property var barGrow: SpringLib.fromResponse(0.38, 1)
        readonly property int growDelay: 72          // + one frame to the first moved one (Mac: 71 ms to the spring's start)
        // expanded content (mc-spaces-bar-expanded-dark.png, 1440x932 mode + the 6 pt of the default mode's inset):
        // the Space 92 pt tall at the screen's aspect (141 x 92) inside a 3 pt accent ring (current Space; outer
        // radius 7.5) from y 38 (+6), its name 11 pt centred on y 145.25 (+6), "+" centred on y 91.5 (rest 34, so
        // +57.5). Space and name ride down 95.5 pt with the bar (the ring's bottom 58.5 68.5 78.5 86.5 ... 135.5
        // against the edge 86 95.5 104.5 113 ... 160) and fade in with it (ring blue 53 85 127 144 165 of 165); the
        // pill's fill is gone in the first frame after the pointer enters, its name fades out on the way
        readonly property real spaceTop: 44
        readonly property real spaceHeight: 92
        readonly property real spaceRing: 3
        readonly property real spaceRingRadius: 7.5
        readonly property real spaceNameSize: 11
        readonly property real spaceNameCentre: 151.25
        readonly property real spaceRide: 95.5
        readonly property real plusRide: 57.5
        readonly property int pillHeight: 24
        readonly property real pillCentre: 53.5
        readonly property real pillPadding: 11.5      // "Desktop" in a 75 pt pill
        readonly property int pillSpacing: 6
        readonly property real labelSize: 13
        readonly property color pill: Qt.rgba(1, 1, 1, 35 / 255)
        readonly property color pillHover: Qt.rgba(1, 1, 1, 18 / 255)   // ours: no hover seen on the Mac
        readonly property int plusSize: 20
        readonly property real plusCentre: 37
        readonly property color plusColor: Qt.rgba(229 / 255, 229 / 255, 229 / 255, 1)
        readonly property int plusInset: 16          // from the right screen edge
        // The band is a blur + tint material, no rim (Q-dock-27). Only the wallpaper is ever behind it (the windows
        // sit below y 108), so it is the pre-blurred wallpaper (Wallpaper.blurredUrl, sigma about 44 pt; a gaussian of
        // 32-48 pt fits the Mac band best) through a tint fitted on the two Mac shots over Tahoe (rms 4.4-5.6 of
        // 255; other wallpapers inferred). Below it a 1 pt line at x0.74 and a shadow from x0.80 to x0.94 over 25 pt
        // (column at x 300 of mc-light.png: 138 149 152 156 160 165 169 172 174 for wallpaper 186)
        readonly property real bandContrast: Theme.dark ? -0.10 : -0.25
        readonly property real bandBrightness: Theme.dark ? -0.015 : 0.05
        readonly property real bandSaturation: Theme.dark ? 0 : 0.95
        readonly property real bandLine: 0.26
        readonly property real bandShadowTop: 0.20
        readonly property real bandShadowEnd: 0.06
        readonly property int bandShadowHeight: 25
        readonly property int bandShadowTail: 11      // the rest fades out below (not separable from the wallpaper on the Mac shots)
        readonly property int gateMs: 150            // longest wait for the first window captures
        // window layout: lib/expose.js, decoded from WindowManager 27.2.1. Its inputs: the Spaces bar height (73.5
        // reproduces the Mac's captured frames, mission-control.json) and the Dock's thickness (the Dock's band here)
        readonly property real layoutBar: 73.5
        // the plugin's title bar on windows that have one (plugin README titlebar_height; asked at open)
        readonly property int titleBar: 32
        // wallpaper layer colour when no image is set (Background.qml)
        readonly property color empty: Theme.dark ? "#1c1c1e" : "#3a6fb0"
    }

    // 0 = everything in place, 1 = Mission Control
    property real e: 0
    FrameSpring { id: anim; target: mc; property: "e"; spring: mc.m.expose }
    // Spaces bar: in with the windows, out on its own spring
    property real bar: 0
    FrameSpring { id: barAnim; target: mc; property: "bar"; spring: mc.m.expose }
    function go() {
        anim.spring = shown ? m.expose : m.exposeExit;
        anim.kick = shown ? 0 : m.exitKick;
        anim.go(shown ? 1 : 0);
        barAnim.spring = shown ? m.expose : m.barExit;
        barAnim.go(shown ? 1 : 0);
    }
    readonly property real travel: A11y.reduceMotion ? 0 : 1 - e         // 1 = at the real window rect
    // hover ring and title only once the windows fly: shown while the captures were awaited, the title capsule appeared
    // over the real window 3-4 frames before anything moved (.27 of the screen's change before the flight, mcap)
    readonly property bool hoverable: shown && !pending && e > 0 && !picking
    // by value, not anim.running: the window must not blink off between `shown` turning false and the
    // exit animation starting
    visible: shown || e > 0
    lingerAs: "mission"
    lingering: !shown && e > 0
    acceptsInput: shown               // no input while closing
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    // the Dock's band stays uncovered and clickable
    readonly property int dockZone: (screen && Panels.dockZones[screen.name]) || 0
    inputMask: Region { x: 0; y: 0; width: mc.width; height: mc.height - mc.dockZone }
    namespace: "hyprk-mission"
    WlrLayershell.layer: WlrLayer.Overlay
    // The keyboard is taken only once the wallpaper covers the windows: taken at open, the focused window went to its
    // inactive look (grey lights, grey selection) for the 4-5 frames before the flight while the
    // thumbnails still waited for their captures (judge #5, B-mc-enter-inactive-flash-1.6.png). On the Mac the focused
    // window keeps its active look in Mission Control (screens/27.2.1/dock/mc-light.png: te-small.txt in colour)
    WlrLayershell.keyboardFocus: shown && cover >= 1 ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    // A picked window is focused again once the layer has dropped the keyboard: Hyprland refuses a window focus while
    // an exclusive layer holds the keys (FocusState rawWindowFocus) and on that commit refocuses its last window, so the
    // focus sent with the click was lost and the window active before Mission Control came back (follow_mouse 1 hid
    // this by focusing the window under the pointer). Two frames of this window after the exit starts (pickFrame).
    property var pickedWindow: null
    property int pickSwaps: 0
    // the picked window's bar in the active look (lights in colour), drawn from the plugin's description: from the first
    // frame after the click, so it shows in the exit's second frame as on the Mac (mc-exit-4-windows.mov: coloured at
    // 33 ms; ours waited for the focus (2 swaps) and the 50 ms re-capture: 105 ms, MOTION-REA Round 5). The window's own
    // content still waits for its re-capture (reshot)
    // By the flight, not by counting frames after the click: on the Mac the lights change in the flight's second frame
    // (mc-exit-4-windows.mov: 2.983 s ring gone, 3.000 s the windows .07 of the way, 3.017 s .20 and the lights), so
    // the look turns when the way is past the first step of the (1.0, 0.25) spring (.067; the second is .205).
    // Counted in swaps or afterAnimating signals it came a frame early in a third of the runs (a swap of a frame
    // begun before the click; two afterAnimating in the frame the layer gives up the keyboard; mc-pick.py)
    readonly property bool pickLook: !shown && flyTop !== null && e < 1 - m.pickLookAt
    // the picked window's thumbnail flies back on top of the others from the exit's first frame, as on the Mac (its
    // stack index is the one from the open: Settings picked under footA flew under it and popped on top when the layer
    // went, judge #10). Kept until the layer goes or reopens.
    property var flyTop: null
    function focusPicked() {
        const t = pickedWindow;
        pickedWindow = null;
        if (t) { Apps.focusWindow(t); refocused(t); }
    }
    // Apps that draw their own title bar (Finder, Settings: no plugin bar to redraw here) take the key look at the
    // click, not when the focus reaches them 2 swaps later: a socket2 event `custom>>hyprk-pick,<address>` (Hyprland's
    // hl.dsp.event, Actions::event) that the app reads as "this window is about to be key" (finder/src/hypr.cpp
    // Hypr::picked, settings/shell.qml win.picked; Finder redraws 8 ms after it, render-loop log). Its thumbnail is live
    // from the click (view.live), and the window key at the open gets a new still at the click too (picked): the layer's
    // keyboard grab greyed the client, and the refocus around the exit redraws it. Mac: both change 2 frames after the
    // first exit frame (mc-exit-4-windows.mov f181); MOTION-REA Round 6 R6.1 and Round J24 (where the old "+4 frames:
    // a copy without ignore_damage waits" is corrected: the copy is made at the next monitor frame either way)
    property var keyAtOpen: null   // the key window when Mission Control opened: its still is in the key look
    // ... and its key look is asked for ahead of the click, while the pointer rests on its thumbnail (cell keyStill).
    // After the click it cannot be on screen in time: Finder commits the look 5-11 ms after hyprk-pick (WAYLAND_DEBUG),
    // the capture is copied at the compositor's next frame and drawn by this layer a frame after that, so the lights
    // coloured 1-2 frames after the first exit frame when the click fell late in a refresh and 4-5 when early
    // (scripts/motion-capture/mc-pick.py; Settings commits sooner: 1-3). So hyprk-pick goes out at the hover (the
    // real window is under the cover; hyprk-pick with no window takes it back when the pointer leaves or Mission
    // Control closes without a pick), a still of the window in that look is taken 100 ms later, and the still is shown
    // from the frame the plugin's bars change (pickLook): the Mac's 2 frames after the first exit frame
    // (mc-exit-4-windows.mov, frames at 2.983 / 3.017 s). A click sooner than the still falls back to the live view
    property var hoverHint: null
    function hintHover(win) {
        hoverHint = win;
        const a = win ? addressOf(win) : "";
        Hyprland.dispatch('hl.dsp.event("hyprk-pick,' + (/^0x[0-9a-fA-F]+$/.test(a) ? a : "0x0") + '")');
    }
    signal picked()
    function hintPick(win) {
        const a = win ? addressOf(win) : "";
        if (/^0x[0-9a-fA-F]+$/.test(a)) Hyprland.dispatch('hl.dsp.event("hyprk-pick,' + a + '")');
        picked();
    }
    // the picked window's thumbnail is a still from the open, in its look then (inactive unless it was focused): it
    // took its active look only when the layer went, a step in the exit's last frame (.038 of the screen > 20 levels,
    // dark, mcap). On the Mac the picked window looks active while it flies back. Its still is taken again once the
    // client has had a frame to redraw for the focus sent above (one window, early in the flight)
    signal refocused(var win)
    Connections {
        target: pickProbe.Window.window   // the QQuickWindow (QsWindow.window has no frameSwapped)
        enabled: mc.pickedWindow !== null
        // one step per frame of this window that was begun after the last step: a swap counts only after an
        // afterAnimating. Counted on every swap, the first after a click was now and then of a frame begun before it;
        // counted on afterAnimating alone, two of them came in one frame when the layer gave up the keyboard
        // (logged): either way the steps below came a frame early in some runs (mc-pick.py: key look +1..+3)
        function onAfterAnimating() { mc.pickBegun = true; }
        function onFrameSwapped() { if (mc.pickBegun) { mc.pickBegun = false; mc.pickFrame(); } }
        function onVisibleChanged() { if (!pickProbe.Window.window.visible) mc.focusPicked(); }
    }
    Item { id: pickProbe }
    // A click on a thumbnail: the hover ring and the title go in the next frame and nothing moves in it; the windows
    // and the Spaces bar start one frame later (mc-exit-4-windows.mov: the frame at 2.983 s has the ring gone and every
    // window in place, rows 0..135 unchanged; the flight's .07 step is the frame at 3.000 s, the lights change at
    // 3.017 s). `picking` is that one frame; the timer is for a click that changes no pixel (no swap would come)
    property bool picking: false
    property bool pickBegun: false
    function pick(win) {
        pickSwaps = 0; pickBegun = false; pickedWindow = win; flyTop = win; hintPick(win);
        picking = true;
        pickHold.restart();
        pickProbe.Window.window.update();
    }
    function pickFrame() {
        if (pickedWindow === null) return;
        if (picking) { leaveForPick(); return; }
        if (++pickSwaps >= 2) focusPicked();
    }
    function leaveForPick() {
        if (!picking) return;
        pickHold.stop();
        picking = false;
        pickSwaps = 0;
        const w = pickedWindow;
        Panels.close();
        Apps.focusWindow(w);
    }
    Timer { id: pickHold; interval: 50; onTriggered: mc.leaveForPick() }
    // a Dock activation while open (Apps.leaveMission): its window is picked as a thumbnail click would pick it
    Connections {
        target: Apps
        function onMissionPick(win) {
            if (!mc.shown || !win || mc.windows.indexOf(win) === -1) return;
            mc.pickSwaps = 0; mc.pickBegun = false; mc.pickedWindow = win; mc.flyTop = win; mc.hintPick(win);
        }
    }

    // frozen while closing, so the windows fly back to where they were. Ordered top to bottom, then
    // left to right by where they are, so each fills the nearest cell (short flights).
    property var windows: []
    Binding on windows { value: mc.byPosition(Hyprland.toplevels.values.filter(t => t.workspace && t.workspace === Hyprland.focusedWorkspace)); when: mc.shown; restoreMode: Binding.RestoreNone }
    property var spaces: []
    Binding on spaces { value: Hyprland.workspaces.values.filter(w => w.id > 0).sort((a, b) => a.id - b.id); when: mc.shown; restoreMode: Binding.RestoreNone }

    // Asked once per open on the compositor's request socket, in one batch; the reply is in before the thumbnails'
    // first captures.
    // `stack` (address -> index, higher is on top): Hyprland lists its clients bottom to top (a raise moves a window to
    // the end; focusing one does not raise it, so focusHistoryID is not the stacking order: a Settings window over a
    // focused Finder flew back under it and jumped on top when the layer went, a 6 % step, mcap).
    // `bars` (address -> true): windows that carry the liquidglass plugin's title bar, a decoration above the window
    // box that a window capture does not contain (judge #4: terminals and GTK windows lost their title bar and
    // lights in the thumbnails). Such a window's thumbnail gets the bar's strip cut from a still of the screen.
    property var stack: ({})
    property var bars: ({})
    // address -> the bar as the plugin draws it (`hyprctl liquidglass bars`, plugin/src/Titlebar.cpp describe()): its
    // fill, text and lights per state, title and layout. A window capture holds the client only, and the screen still
    // has a bar only where nothing covers it: the thumbnails of covered or partly off-screen windows draw it from this
    // (judge #5: 2 of 3 inactive terminals had no title bar in Mission Control)
    property var barLooks: ({})
    property bool asked: false          // the reply is in
    Socket {
        id: stackQuery
        path: Quickshell.env("XDG_RUNTIME_DIR") + "/hypr/" + Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") + "/.socket.sock"
        property string reply: ""
        property var addresses: []
        parser: SplitParser { splitMarker: ""; onRead: data => stackQuery.reply += data }
        onConnectionStateChanged: {
            if (connected) {
                reply = "";
                // the toplevel's own address: a new window's lastIpcObject is still empty here
                addresses = mc.windows.map(t => mc.addressOf(t)).filter(a => a);
                write("[[BATCH]]j/clients;" + addresses.map(a => "/decorations address:" + a).join(";") + ";/liquidglass bars");
                flush();
            } else if (reply !== "") {
                try {
                    const parts = reply.split(/\n\n\n+/), s = {}, b = {};
                    JSON.parse(parts[0]).forEach((c, i) => s[c.address] = i);
                    // a window has a bar when the plugin describes one (`liquidglass bars` lists only bars that are
                    // drawn: height > 0 and the window decorated). The decoration alone is attached to every window,
                    // also to those that draw their own title bar (Settings, the Finder), whose thumbnail then had a
                    // 32 pt strip of wallpaper glass above it (judge #5). Without that command (an older plugin) the
                    // decoration decides, as before.
                    let looks = null;
                    try {
                        const l = JSON.parse(parts[addresses.length + 1] || "");
                        if (Array.isArray(l)) { looks = {}; l.forEach(d => looks[d.address] = d); }
                    } catch (err) {}
                    addresses.forEach((a, i) => {
                        if ((parts[i + 1] || "").includes("liquidglass-titlebar\t") && (!looks || looks[a])) b[a] = true;
                    });
                    looks = looks || {};
                    mc.stack = s;
                    mc.barLooks = looks;
                    mc.bars = b;
                } catch (err) {}
                reply = "";
                mc.asked = true;
                mc.relayout();
                mc.maybeGo();
            }
        }
    }

    function addressOf(t) {
        const o = t.lastIpcObject;
        if (o && o.address) return o.address;
        return t.address ? (String(t.address).startsWith("0x") ? t.address : "0x" + t.address) : "";
    }
    function centreOf(t) {
        const o = t.lastIpcObject;
        return o && o.at && o.size ? { x: o.at[0] + o.size[0] / 2, y: o.at[1] + o.size[1] / 2 } : { x: 0, y: 0 };
    }
    // rows of `cols` by centre y, each row by centre x
    function byPosition(list) {
        const n = list.length, cols = Math.max(1, Math.ceil(Math.sqrt(n)));
        const sorted = list.slice().sort((a, b) => centreOf(a).y - centreOf(b).y);
        const out = [];
        for (let i = 0; i < n; i += cols)
            out.push(...sorted.slice(i, i + cols).sort((a, b) => centreOf(a).x - centreOf(b).x));
        return out;
    }

    // the window exists only while open (shell.qml LazyLoader)
    // The motion starts once every thumbnail has its first frame (at most m.gateMs) and the window has presented a
    // frame with them: until then the thumbnails sit, invisible, exactly over their windows. Started earlier, a capture
    // that comes in late would pop up away from its window, and the first frame of the flight paid the thumbnails'
    // first upload (a repeated or late first frame, mcap).
    property bool pending: false
    function present() {
        Hyprland.refreshToplevels();
        asked = false;
        flyTop = null;
        spacesBar.collapse();
        stackQuery.connected = true;
        // on creation the still is taken when its source is set (ScreencopyView::createContext); asking then warned
        // "Cannot capture frame, as no recording context is ready" (judge #9)
        if (completed && e === 0 && still.captureSource) still.captureFrame();
        keys.forceActiveFocus();
        pending = true;
        gate.restart();
        maybeGo();
    }
    function maybeGo() {
        if (!pending || !asked || thumbs.count < windows.length) return;
        if (anyBar && !still.hasContent) return;
        if (!wallReady) return;
        for (let i = 0; i < thumbs.count; i++) {
            const c = thumbs.itemAt(i);
            if (c && !c.ready) return;
        }
        pending = false;
        gate.stop();
        armed = true;
    }
    property bool armed: false
    Connections {
        target: keys.Window.window   // the QQuickWindow (Quickshell's window object has no frameSwapped)
        function onFrameSwapped() {
            if (!mc.armed) return;
            mc.armed = false;
            if (mc.shown) mc.go();
        }
    }
    Timer { id: gate; interval: mc.m.gateMs; onTriggered: { mc.pending = false; mc.armed = true; } }
    // onShownChanged also fires while the bindings are set up on creation: present() once, when complete
    property bool completed: false
    Component.onCompleted: { present(); completed = true; }
    onShownChanged: {
        if (shown) { picking = false; pickHold.stop(); keyAtOpen = Hyprland.activeToplevel; }
        else if (hoverHint !== null && pickedWindow === null) hintHover(null);   // closed without a pick
        if (!shown) hoverHint = null;
        if (completed) shown ? present() : go();
    }

    // ---------- layout (lib/expose.js): one uniform scale, the windows near where they are ----------
    readonly property var area: Expose.usableArea({ x: 0, y: 0, w: width, h: height }, dockZone, m.layoutBar)
    // ... and with the Spaces bar expanded (R18.1): the same layout under a bar m.barExpand taller
    readonly property var areaExpanded: Expose.usableArea({ x: 0, y: 0, w: width, h: height }, dockZone, m.layoutBar + m.barExpand)
    function clientRect(t) {
        const o = t.lastIpcObject;
        if (!o || !o.at || !o.size || !screen) return null;
        return Qt.rect(o.at[0] - screen.x, o.at[1] - screen.y, o.size[0], o.size[1]);
    }
    // the plugin title bar's strip above the window, when the screen still shows all of it: on the screen below the
    // menu bar and above the Dock's band, with no window stacked higher over it
    // the strip where the bar is, seen or not (the thumbnail draws it when the still cannot give it, barLooks)
    function barStrip(t) {
        const o = t.lastIpcObject, c = clientRect(t);
        if (!c || !bars[o.address]) return null;
        const d = barLooks[o.address], h = d && d.height > 0 ? d.height : m.titleBar;
        return Qt.rect(c.x, c.y - h, c.width, h);
    }
    function barRect(t) {
        const o = t.lastIpcObject, c = clientRect(t), b = barStrip(t);
        if (!b) return null;
        if (b.x < 0 || b.x + b.width > width || b.y < Theme.menuBar.height || c.y > height - dockZone) return null;
        const z = stack[o.address];
        for (const u of windows) {
            const uo = u.lastIpcObject, r = u === t ? null : clientRect(u);
            if (!r || !(stack[uo.address] > z)) continue;
            const top = r.y - (bars[uo.address] ? m.titleBar : 0);
            if (r.x < b.x + b.width && b.x < r.x + r.width && top < b.y + b.height && b.y < r.y + r.height) return null;
        }
        return b;
    }
    // the whole window as it is on screen: the client box plus its title bar strip
    function fullRect(t) {
        const c = clientRect(t), b = c ? barStrip(t) : null;
        return b ? Qt.rect(c.x, b.y, c.width, c.height + b.height) : c;
    }
    readonly property bool anyBar: windows.some(t => t.lastIpcObject && bars[t.lastIpcObject.address])
    // where each window goes, and the scale; taken before the fly-in is under way (IPC data and the title bar reply
    // arrive asynchronously) and kept while closing so the windows fly back from where they are
    property var frames: []
    property var framesExpanded: []
    property real layoutScale: 1
    // Laid out before the fly-in, and again while open when a window opens or closes (judge #11: after a window
    // appeared in Mission Control the frames, still the old count, were indexed by the new list and a thumbnail was
    // covered). The thumbnails take their new frames without a motion (no Mac data on this). Not while closing: the
    // windows fly back from the frames they have.
    function relayout() {
        if (e >= 0.05 && !shown) return;
        const rects = windows.map(t => fullRect(t));
        if (rects.some(r => !r)) return;
        const out = Expose.layout(rects.map(r => ({ x: r.x, y: r.y, w: r.width, h: r.height })), area);
        framesExpanded = Expose.layout(rects.map(r => ({ x: r.x, y: r.y, w: r.width, h: r.height })), areaExpanded).frames;
        frames = out.frames;
        layoutScale = out.scale;
    }
    // a window that opens while open has no IPC data (its rect) until the toplevels are asked again, and no place in
    // `stack` (it flew back under the others and popped on top in the exit's last frame, .14 of the screen > 20 levels)
    onWindowsChanged: {
        if (shown && e >= 0.05) { Hyprland.refreshToplevels(); stackQuery.connected = true; }
        relayout();
    }
    onAreaChanged: relayout()

    // a still of the screen for the title bar strips, taken while this layer is still clear
    ScreencopyView {
        id: still
        visible: false
        width: mc.width
        height: mc.height
        constraintSize: Qt.size(mc.width, mc.height)
        // asked at open with the window list, not once the reply says a window has a bar: the reply and the still then
        // come in together (Settings and 3 terminals: the flight waited 23 ms more, one frame, for the still)
        captureSource: mc.windows.length > 0 ? mc.screen : null
        live: false
        onHasContentChanged: mc.maybeGo()
    }

    // The Dock's band: the wallpaper too, so a real window that reaches into the band is covered there like everywhere
    // else (it showed beside the Dock). The plugin draws the Dock over this layer while it is mapped (`draw_over`), so
    // the Dock's glass refracts this band and the thumbnails flying past, the same picture as the real windows when the
    // layer goes (with the band cut out of the Dock's glass, it refracted the wallpaper, then the windows: a step in
    // the exit's last frame, dark 14.17 levels, mcap).
    readonly property var dockRect: (screen && Panels.dockRects[screen.name]) || null
    Item {
        id: dockBand
        y: mc.height - mc.dockZone
        width: mc.width
        height: mc.dockZone
        visible: mc.dockZone > 0 && mc.dockRect !== null && mc.cover > 0
        opacity: mc.cover
        clip: true
        Rectangle { anchors.fill: parent; color: mc.m.empty }
        Image {
            y: -parent.y
            width: mc.width
            height: mc.height
            source: Wallpaper.urlFor(mc.screen)
            sourceSize: Wallpaper.pixelSizeOf(mc.screen)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
        }
    }
    Item {
        id: keys
        focus: true
        Keys.onEscapePressed: Panels.close()
    }

    // the plain wallpaper, as the wallpaper layer draws it (Background.qml), over everything below but the Dock: the
    // top strip fades with `e`, the rest is opaque while anything flies (Reduce Motion: all of it fades, a dissolve)
    readonly property real cover: A11y.reduceMotion ? e : Math.min(1, e / m.coverEnd)
    // the cover's picture is decoded (asynchronous; the desktop's pixmap is shared, but the first frame after creation
    // drew the cover's plain colour alone: the first frame of the flight was the wallpaper under a 21 % blue veil,
    // .86 of the screen changed for one frame, mcap). The flight waits for it like for the captures (gate at most)
    property int wallsReady: 0
    readonly property bool wallReady: !Wallpaper.urlFor(screen) || wallsReady >= 2
    onWallReadyChanged: maybeGo()
    Repeater {
        // the strip that fades with `e` is the menu bar's own band only: below it real windows start, and a strip down
        // to stripHeight uncovered them at their end place while their thumbnails still flew (a ghost of each window in
        // the top 100 pt through the exit, both exits, mcap; the Mac shows none: MOTION-REA Round 5). The desktop's top
        // dimming under the bar (Background.qml topDim) is drawn over the cover below instead (stripDim)
        model: [{ y: 0, h: Theme.menuBar.height, strip: true },
                { y: Theme.menuBar.height, h: mc.height - mc.dockZone - Theme.menuBar.height, strip: false }]
        delegate: Rectangle {
            required property var modelData
            y: modelData.y
            width: mc.width
            height: Math.max(0, modelData.h)
            clip: true
            color: Wallpaper.urlFor(mc.screen) ? "transparent" : mc.m.empty   // under a picture it only showed alone
            // on the way out the menu bar's band shows the desktop at once where the Spaces bar has left (R10.1: "the menu
            // bar's own background appears only in the rows the bar has left", no fade); the menu bar itself is above
            // this window then (MenuBar.qml mcLeaving)
            opacity: modelData.strip ? (mc.shown || A11y.reduceMotion ? mc.e : 0) : mc.cover
            Image {
                y: -parent.y
                onStatusChanged: if (status === Image.Ready) mc.wallsReady++
                width: mc.width
                height: mc.height
                source: Wallpaper.urlFor(mc.screen)
                // the desktop's decoded pixmap and texture (Background.qml: same url and sourceSize, cached): no decode
                sourceSize: Wallpaper.pixelSizeOf(mc.screen)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
            }
        }
    }
    // the desktop's top dimming (Background.qml topDim: the wallpaper pushed away from the bar's text colour, strength
    // 0 by 100 pt) between the menu bar and stripHeight, over the opaque cover, showing as the desktop shows: (1 - e).
    // So the band looks as when the strip uncovered the desktop, without uncovering the windows. Reduce Motion: the
    // whole cover dissolves, nothing to draw
    Item {
        id: stripDim
        y: Theme.menuBar.height
        width: mc.width
        height: Math.max(0, mc.m.stripHeight - Theme.menuBar.height)
        clip: true
        opacity: (1 - mc.e) * mc.cover
        visible: !A11y.reduceMotion && opacity > 0 && dimWall.status === Image.Ready
        Image {
            id: dimWall
            width: mc.width
            height: mc.height
            source: Wallpaper.urlFor(mc.screen)
            sourceSize: Wallpaper.pixelSizeOf(mc.screen)    // the desktop's decoded pixmap (cached, shared)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
        }
        ShaderEffectSource {
            id: dimSrc
            sourceItem: dimWall
            sourceRect: Qt.rect(0, 0, mc.width, mc.m.stripHeight)
            hideSource: true          // drawn only through the shader
            visible: false
        }
        ShaderEffect {
            y: -stripDim.y
            width: mc.width
            height: mc.m.stripHeight
            property var src: dimSrc
            property real lightText: Theme.menuBarLight ? 0 : 1
            property real heightPt: height
            fragmentShader: Qt.resolvedUrl("../shaders/topdim.frag.qsb")
        }
    }
    MouseArea { width: parent.width; height: parent.height - mc.dockZone; onClicked: Panels.close() }

    // Spaces bar. Collapsed (27.2.1): a labelled pill per Desktop, the current one filled, "+" at the
    // right. The pointer entering it expands it for as long as Mission Control stays open (R18.1, mc.m.barExpand):
    // each Desktop as a small copy of the screen with its name under it, the windows below making room.
    Item {
        id: spacesBar
        width: parent.width
        height: mc.m.barHeight + grow * mc.m.barExpand
        y: -(A11y.reduceMotion ? 0 : 1 - mc.bar) * height
        // on the way out it slides away opaque (mc-exit-esc.mov: the "Desktop" pill keeps its ink up to the top edge)
        opacity: mc.shown || A11y.reduceMotion ? mc.bar : mc.bar > 0.002 ? 1 : 0
        // latched: the Mac's bar stays expanded after the pointer has left it
        property bool expanded: false
        property real grow: 0
        FrameSpring { id: growAnim; target: spacesBar; property: "grow"; spring: mc.m.barGrow }
        Timer { id: growWait; interval: mc.m.growDelay; onTriggered: growAnim.go(1) }
        function collapse() { growWait.stop(); expanded = false; growAnim.snap(0); }
        readonly property bool entered: barHover.hovered && mc.hoverable
        onEnteredChanged: if (entered && !expanded) { expanded = true; growWait.restart(); }
        HoverHandler { id: barHover }

        // the band: blurred wallpaper through the tint, a darker line under it and its shadow on the wallpaper
        Item {
            anchors.fill: parent
            clip: true
            Rectangle { anchors.fill: parent; color: mc.m.empty }
            Image {
                y: spacesBar.y < 0 ? -spacesBar.y : 0      // the picture stays in place while the band slides in
                width: mc.width
                height: mc.height
                source: Theme.solidMaterial ? Wallpaper.urlFor(mc.screen) : Wallpaper.blurredUrl
                sourceSize: Theme.solidMaterial ? Wallpaper.pixelSizeOf(mc.screen) : undefined
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                layer.enabled: true
                layer.effect: MultiEffect {
                    contrast: mc.m.bandContrast
                    brightness: mc.m.bandBrightness
                    saturation: mc.m.bandSaturation
                }
            }
        }
        Rectangle { y: parent.height; width: parent.width; height: 1; color: Qt.rgba(0, 0, 0, mc.m.bandLine) }
        Rectangle {
            y: parent.height + 1
            width: parent.width
            height: mc.m.bandShadowHeight + mc.m.bandShadowTail
            gradient: Gradient {
                GradientStop { position: 0; color: Qt.rgba(0, 0, 0, mc.m.bandShadowTop) }
                GradientStop { position: mc.m.bandShadowHeight / (mc.m.bandShadowHeight + mc.m.bandShadowTail); color: Qt.rgba(0, 0, 0, mc.m.bandShadowEnd) }
                GradientStop { position: 1; color: "transparent" }
            }
        }

        Row {
            id: pills
            anchors.horizontalCenter: parent.horizontalCenter
            y: mc.m.pillCentre - mc.m.pillHeight / 2
            spacing: mc.m.pillSpacing
            // the name rides down with the Space and is gone by .8 of the way (R18.1: both names in the frames up
            // to 2.267 s, the small one alone from 2.283 s)
            transform: Translate { y: spacesBar.grow * mc.m.spaceRide }
            opacity: Math.max(0, 1 - spacesBar.grow * 1.25)
            visible: opacity > 0
            Repeater {
                model: mc.spaces
                delegate: Rectangle {
                    id: pill
                    required property var modelData
                    required property int index
                    readonly property bool current: modelData === Hyprland.focusedWorkspace
                    width: label.implicitWidth + mc.m.pillPadding * 2
                    height: mc.m.pillHeight
                    radius: height / 2
                    color: spacesBar.expanded ? "transparent" : current ? mc.m.pill : pm.containsMouse ? mc.m.pillHover : "transparent"
                    Text {
                        id: label
                        anchors.centerIn: parent
                        text: State.spaceName(pill.index, mc.spaces.length)
                        font: Typography.font(mc.m.labelSize, pill.current ? Typography.semibold : Typography.medium)
                        color: Theme.mission.text
                    }
                    MouseArea {
                        id: pm
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: mc.openSpace(pill.modelData)
                    }
                }
            }
        }

        Row {
            id: expandedRow
            anchors.horizontalCenter: parent.horizontalCenter
            y: -(1 - spacesBar.grow) * mc.m.spaceRide
            spacing: Theme.mission.spaceSpacing
            opacity: spacesBar.grow
            visible: opacity > 0
            Repeater {
                model: spacesBar.expanded ? mc.spaces : []
                delegate: Item {
                    id: sp
                    required property var modelData
                    required property int index
                    readonly property bool current: modelData === Hyprland.focusedWorkspace
                    readonly property real k: mc.m.spaceHeight / Math.max(1, mc.height)
                    width: Math.round(mc.width * k) + 2 * mc.m.spaceRing
                    height: mc.m.spaceNameCentre + 10

                    // the ring around the current Space
                    Rectangle {
                        y: mc.m.spaceTop
                        width: parent.width
                        height: mc.m.spaceHeight + 2 * mc.m.spaceRing
                        radius: mc.m.spaceRingRadius
                        color: "transparent"
                        border.width: sp.current ? mc.m.spaceRing : 0
                        border.color: Theme.color.accent
                    }
                    ClippingRectangle {
                        x: mc.m.spaceRing
                        y: mc.m.spaceTop + mc.m.spaceRing
                        width: parent.width - 2 * mc.m.spaceRing
                        height: mc.m.spaceHeight
                        radius: mc.m.spaceRingRadius - mc.m.spaceRing
                        color: mc.m.empty
                        Image {
                            anchors.fill: parent
                            source: Wallpaper.url
                            sourceSize.width: Wallpaper.thumbWidth
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }
                        // the current Space's windows where they really are (the Mac's Space is a copy of the
                        // desktop without the menu bar and the Dock)
                        Repeater {
                            model: sp.current ? thumbs.count : 0
                            delegate: ShaderEffectSource {
                                required property int index
                                readonly property Item cell: thumbs.itemAt(index)
                                readonly property var real: cell ? cell.real : null
                                visible: real !== null
                                z: cell ? cell.z : 0
                                x: real ? real.x * sp.k : 0
                                y: real ? real.y * sp.k : 0
                                width: real ? real.width * sp.k : 0
                                height: real ? real.height * sp.k : 0
                                sourceItem: cell ? cell.picture : null
                                textureSize: Qt.size(Math.max(1, Math.ceil(width * 2)), Math.max(1, Math.ceil(height * 2)))
                                smooth: true
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: mc.openSpace(sp.modelData)
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: mc.m.spaceNameCentre - height / 2
                        text: State.spaceName(sp.index, mc.spaces.length)
                        font: Typography.font(mc.m.spaceNameSize, Typography.medium)
                        color: Theme.mission.text
                    }
                }
            }
        }

        // "+": a new empty Desktop (Hyprland makes it current; macOS adds it without switching)
        Item {
            anchors.right: parent.right
            anchors.rightMargin: mc.m.plusInset
            y: mc.m.plusCentre + spacesBar.grow * mc.m.plusRide - height / 2
            width: mc.m.plusSize
            height: width
            opacity: plus.containsMouse ? 1 : 0.9
            Rectangle { anchors.centerIn: parent; width: 17; height: 1.5; radius: 0.75; color: mc.m.plusColor }
            Rectangle { anchors.centerIn: parent; width: 1.5; height: 17; radius: 0.75; color: mc.m.plusColor }
            MouseArea {
                id: plus
                anchors.fill: parent
                anchors.margins: -6
                hoverEnabled: true
                onClicked: Hyprland.dispatch('hl.dsp.focus({ workspace = "emptynm" })')
            }
        }
    }
    function openSpace(ws) {
        Panels.close();
        ws.activate();
    }

    // windows. They fly under the Dock, as the Mac's windows always are (Q-dock-27: the Dock stays visible in Mission
    // Control): the plugin draws the Dock over this layer while it is mapped (`draw_over`), so the Dock's icons stay over
    // a window flying back into the Dock's band (judge #10) and its glass refracts the thumbnail.
    Item {
        id: flight
        width: mc.width
        height: mc.height
        Repeater {
            id: thumbs
            model: mc.windows
            delegate: Item {
                id: cell
                required property var modelData
                required property int index
                // stacked like the real windows (mc.stack; most recently focused on top until it is in), so where windows
                // overlap the thumbnails land in the same order and nothing changes when the layer goes
                z: {
                    if (mc.flyTop === modelData) return 1e6;
                    const o = modelData.lastIpcObject;
                    if (o && mc.stack[o.address] !== undefined) return mc.stack[o.address];
                    return -1000 - (o && o.focusHistoryID !== undefined ? o.focusHistoryID : 0);
                }
                // where the layout puts the whole window (title bar strip included)
                // (between the collapsed and the expanded Spaces bar's layout by the bar's growth, R18.1)
                readonly property var frame: Expose.between(mc.frames[index] || null, mc.framesExpanded[index] || null, spacesBar.grow)
                // the thumbnail's picture, for the Space's small copy in the expanded bar
                readonly property Item picture: pictureItem
                x: frame ? frame.x : 0
                y: frame ? frame.y : 0
                width: frame ? frame.w : 0
                height: frame ? frame.h : 0

                // where the window really is, with its title bar strip (screen-local); the thumbnail starts and ends
                // there. Taken only before the fly-in is under way (IPC data arrives asynchronously: no jump).
                readonly property var ipcRect: mc.bars && mc.stack ? mc.fullRect(cell.modelData) : null
                readonly property var ipcBar: mc.bars && mc.stack && mc.barLooks ? mc.barStrip(cell.modelData) : null
                property var real: null
                property var bar: null          // the bar's strip on the screen (any window with the plugin's bar)
                property bool barSeen: false    // ... and the screen still shows all of it
                property var look: null         // ... as the plugin draws it
                // the picked window once its still is taken again in the active look: its bar is then drawn from the
                // plugin's description in the active look too (the screen still's strip is the look at open)
                property bool repicked: false
                // its bar in the active look: re-captured, or the picked one from the first frame after the click
                readonly property bool barActive: repicked || (mc.pickLook && mc.flyTop === cell.modelData && !mc.shown)
                // ... and every other window's bar inactive in that same frame (the Mac's key window before the pick
                // greys its lights in the frame the picked one colours them, mc-exit-4-windows.mov f181)
                readonly property bool barInactive: mc.pickLook && !mc.shown && mc.flyTop !== null && mc.flyTop !== cell.modelData
                readonly property bool barRelook: barActive || barInactive
                function takeRect() {
                    if (mc.e >= 0.05 && !mc.shown) return;
                    real = mc.fullRect(cell.modelData);
                    bar = mc.barStrip(cell.modelData);
                    barSeen = mc.barRect(cell.modelData) !== null;
                    const o = cell.modelData.lastIpcObject;
                    look = o && mc.barLooks[o.address] || null;
                    mc.relayout();
                }
                onIpcRectChanged: takeRect()
                onIpcBarChanged: takeRect()
                readonly property real fly: real && width > 0 ? mc.travel : 0
                // its capture is in (or there is nothing to fly from)
                readonly property bool ready: view.hasContent || !real
                onReadyChanged: mc.maybeGo()
                Component.onCompleted: { takeRect(); mc.maybeGo(); }
                // the bar strip's height in the thumbnail
                readonly property real barHeight: bar && real ? bar.height * width / real.width : 0
                Item {
                    id: thumb
                    anchors.fill: parent
                    // While the captures of this open are awaited the thumbnail is drawn at an opacity too low to change a
                    // pixel (the real window shows through): its textures are uploaded before the flight, and a stale
                    // picture from the last open neither shows nor gets into the screen still.
                    opacity: mc.pending ? 0.002 : cell.real && !A11y.reduceMotion ? 1 : mc.e
                    transform: [
                        Scale {
                            xScale: 1 + cell.fly * (cell.real ? cell.real.width / thumb.width - 1 : 0)
                            yScale: 1 + cell.fly * (cell.real ? cell.real.height / thumb.height - 1 : 0)
                        },
                        Translate {
                            x: cell.fly * (cell.real ? cell.real.x - cell.x : 0)
                            y: cell.fly * (cell.real ? cell.real.y - cell.y : 0)
                        }
                    ]
                    // window shadow: it takes over from the real window's own shadow as the wallpaper covers that
                    // (mc.cover), so the window keeps a shadow through the flight; radius and offset as the glass
                    // shadow, guessed for here
                    RectangularShadow {
                        anchors.fill: parent
                        radius: Theme.mission.thumbRadius
                        blur: Theme.glass.shadowRadius
                        offset.y: Theme.glass.shadowYOffset
                        color: Theme.glass.shadow
                        opacity: mc.cover
                    }
                    ClippingRectangle {
                        id: pictureItem
                        anchors.fill: parent
                        radius: Theme.mission.thumbRadius
                        color: "transparent"
                        // the plugin title bar's strip, cut from the screen still
                        ShaderEffectSource {
                            visible: cell.bar !== null && cell.barSeen && still.hasContent && !(cell.barRelook && cell.look)
                            width: parent.width
                            height: cell.barHeight
                            sourceItem: visible ? still : null
                            sourceRect: cell.bar ? cell.bar : Qt.rect(0, 0, 0, 0)
                        }
                        // the bar drawn from the plugin's description where the still has none: its fill, the lights in
                        // the window's state at open (active only for the focused one, as mc-light.png) and the title, laid out
                        // in points and scaled with the thumbnail
                        Rectangle {
                            readonly property bool active: cell.look ? (cell.look.active || cell.barActive) && !cell.barInactive : false
                            readonly property var st: cell.look ? cell.look.look[active ? "active" : "inactive"] : null
                            visible: cell.bar !== null && st !== null && (!(cell.barSeen && still.hasContent) || cell.barRelook)
                            width: parent.width
                            height: cell.barHeight
                            color: st ? st.fill : "transparent"
                            Item {
                                width: cell.bar ? cell.bar.width : 0
                                height: cell.bar ? cell.bar.height : 0
                                scale: cell.real && cell.real.width > 0 ? cell.width / cell.real.width : 1
                                transformOrigin: Item.TopLeft
                                TrafficLights {
                                    x: cell.look ? cell.look.inset : 0
                                    anchors.verticalCenter: parent.verticalCenter
                                    enabled: false
                                    active: parent.parent.active
                                    dark: parent.parent.st ? parent.parent.st.dark : false
                                }
                                Text {
                                    x: cell.look ? cell.look.titleX : 0
                                    width: Math.max(0, parent.width - x - 8)
                                    anchors.verticalCenter: parent.verticalCenter
                                    elide: Text.ElideRight
                                    text: cell.look ? cell.look.title : ""
                                    font: Typography.font(cell.look ? cell.look.fontSize : 13, Typography.bold)
                                    color: parent.parent.st ? parent.parent.st.text : "transparent"
                                }
                            }
                        }
                        ScreencopyView {
                            id: view
                            y: cell.barHeight
                            captureSource: cell.modelData.wayland
                            // one still per open, not a live feed: live, every window was captured and redrawn at 60 fps
                            // for as long as Mission Control stayed open (reference/PERF-2026-11-10.md item 2). The still
                            // is taken when the source is set (creation, on open) and again on a reopen while still loaded
                            // ... except the picked window of an app that draws its own title bar, live through the exit
                            // from the click
                            // (with the hover's still of the key look in hand, keyStill below, only from the frame that
                            // still shows: the client has had the look since the hover, and a live frame of it came
                            // back one frame sooner than the Mac's change in half the runs, mc-pick.py)
                            live: !mc.shown && cell.bar === null && mc.flyTop === cell.modelData && (mc.pickLook || !keyStill.hasContent)
                            // the window that was key at the open: its still has the key look, the client went inactive
                            // when the layer took the keyboard; a new still greys it in the frame the picked one colours
                            // (mc-exit-4-windows.mov f181, Window 4)
                            Connections { target: mc; function onPicked() { if (cell.bar === null && mc.keyAtOpen === cell.modelData && mc.flyTop !== cell.modelData) view.captureFrame(); } }
                            Connections { target: mc; function onShownChanged() { if (mc.shown) { cell.repicked = false; view.captureFrame(); } } }
                            Connections { target: mc; function onRefocused(win) { if (win === cell.modelData) reshot.restart(); } }
                            Timer { id: reshot; interval: 50; onTriggered: { view.captureFrame(); cell.repicked = true; } }
                            // No second still on exit (one was taken in the tail for the windows' active look): the capture
                            // held qs's frames there, a 0.96 plateau for 2-4 frames (mcap); the look changes when the layer goes
                            constraintSize: Qt.size(cell.width, Math.max(1, cell.height - cell.barHeight))
                        }
                        // an app that draws its own title bar, in its key look: asked for while the pointer rests on the
                        // thumbnail, shown over the live view from the frame the plugin's bars change (mc.hoverHint)
                        ScreencopyView {
                            id: keyStill
                            y: cell.barHeight
                            captureSource: cell.keyWanted ? cell.modelData.wayland : null
                            live: false
                            visible: mc.pickLook && !mc.shown && mc.flyTop === cell.modelData
                            constraintSize: view.constraintSize
                        }
                        // fallback while no frame is available: app icon on a plain card
                        Rectangle {
                            anchors.fill: parent
                            // not while the first captures are awaited: the card flashed over the window for a frame (mcap)
                            visible: !view.hasContent && !mc.pending && mc.e > 0
                            color: Theme.glass.solid
                            IconImage {
                                anchors.centerIn: parent
                                implicitSize: Theme.mission.placeholderIcon
                                source: Apps.iconUrl(Apps.appIdOf(cell.modelData), Apps.appIdOf(cell.modelData), Theme.iconLook)
                            }
                        }
                    }
                    // hover: an accent ring 4.5 pt wide, 1 pt outside the window frame, no scale (Q-dock-30); only while
                    // open (on exit it went away only when the layer unmapped, a pop after the windows landed, mcap)
                    Rectangle {
                        visible: wma.containsMouse && mc.hoverable
                        anchors.fill: parent
                        anchors.margins: -5.5
                        radius: Theme.mission.thumbRadius + 5.5
                        color: "transparent"
                        border.width: 4.5
                        border.color: Theme.color.accent
                    }
                }
                // title on hover, centred on the window (Q-dock-29)
                Rectangle {
                    visible: wma.containsMouse && mc.hoverable
                    anchors.centerIn: parent
                    width: Math.min(cell.width, title.implicitWidth + Theme.mission.titlePadding * 2)
                    height: Theme.mission.titleHeight
                    radius: height / 2
                    color: Theme.mission.titleFill
                    Text {
                        id: title
                        anchors.centerIn: parent
                        width: Math.min(implicitWidth, cell.width - Theme.mission.titlePadding * 2)
                        elide: Text.ElideRight
                        text: cell.modelData.title
                        font: Typography.font(Theme.font.missionTitle, Typography.bold)
                        color: Theme.mission.titleText
                    }
                }
                // mc.hoverHint: the window's key look while the pointer is on its thumbnail, and a still of it
                property bool keyWanted: false
                readonly property bool hinted: wma.containsMouse && mc.hoverable && cell.bar === null
                onHintedChanged: {
                    if (hinted) { mc.hintHover(cell.modelData); keyShot.restart(); }
                    else if (mc.shown && mc.pickedWindow === null) { keyShot.stop(); keyWanted = false; if (mc.hoverHint === cell.modelData) mc.hintHover(null); }
                    else keyShot.stop();
                }
                Timer { id: keyShot; interval: 100; onTriggered: cell.keyWanted = true }
                Connections { target: mc; function onShownChanged() { if (mc.shown) cell.keyWanted = false; } }
                MouseArea {
                    id: wma
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: if (!mc.picking && mc.shown) mc.pick(cell.modelData)
                }
            }
        }
    }
}
