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
        // the Mac's exit track starts at 0.21 in its first frame, which a spring from rest cannot do (S-shaped start):
        // a critically damped spring fits it with a start velocity of 10 x the distance per second
        readonly property real exitKick: 10
        // the wallpaper reaches full opacity over the windows within this share of `e` (and leaves within it on exit)
        readonly property real coverEnd: 0.06
        // the strip that fades with `e`: the menu bar and the wallpaper's top dimming under it (Background.qml topDim)
        readonly property int stripHeight: 100
        readonly property var barExit: SpringLib.fromResponse(0.125, 1)    // SpacesBarExitSpringResponse
        // collapsed Spaces bar (Q-dock-31, mission-control.json spaces_bar, dock/mc-{dark,light}.png): a band 74 pt
        // tall over the menu bar zone, name pills 24 pt tall (r 12) centred on y 53.5 with a +35 / 255 fill, "+" a
        // 20 pt glyph, grey 229, 16 pt from the right edge, centre y 37
        readonly property int barHeight: 74
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
        readonly property int expandMs: 250          // bar grows into thumbnails on hover, guessed
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
    readonly property bool hoverable: shown && !pending && e > 0
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
    // this by focusing the window under the pointer). Two swaps: the first can be of a frame begun before the click.
    property var pickedWindow: null
    property int pickSwaps: 0
    // the picked window's thumbnail flies back on top of the others from the exit's first frame, as on the Mac (its
    // stack index is the one from the open: Settings picked under footA flew under it and popped on top when the layer
    // went, judge #10). Kept until the layer goes or reopens.
    property var flyTop: null
    function focusPicked() {
        const t = pickedWindow;
        pickedWindow = null;
        if (t) { Apps.focusWindow(t); refocused(t); }
    }
    // the picked window's thumbnail is a still from the open, in its look then (inactive unless it was focused): it
    // took its active look only when the layer went, a step in the exit's last frame (.038 of the screen > 20 levels,
    // dark, mcap). On the Mac the picked window looks active while it flies back. Its still is taken again once the
    // client has had a frame to redraw for the focus sent above (one window, early in the flight)
    signal refocused(var win)
    Connections {
        target: pickProbe.Window.window   // the QQuickWindow (QsWindow.window has no frameSwapped)
        enabled: mc.pickedWindow !== null
        function onFrameSwapped() { if (++mc.pickSwaps >= 2) mc.focusPicked(); }
        function onVisibleChanged() { if (!pickProbe.Window.window.visible) mc.focusPicked(); }
    }
    Item { id: pickProbe }

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
    onShownChanged: if (completed) shown ? present() : go()

    // ---------- layout (lib/expose.js): one uniform scale, the windows near where they are ----------
    readonly property var area: Expose.usableArea({ x: 0, y: 0, w: width, h: height }, dockZone, m.layoutBar)
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
    property real layoutScale: 1
    function relayout() {
        if (e >= 0.05) return;
        const rects = windows.map(t => fullRect(t));
        if (rects.some(r => !r)) return;
        const out = Expose.layout(rects.map(r => ({ x: r.x, y: r.y, w: r.width, h: r.height })), area);
        frames = out.frames;
        layoutScale = out.scale;
    }
    onWindowsChanged: relayout()
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
        model: [{ y: 0, h: mc.m.stripHeight, strip: true },
                { y: mc.m.stripHeight, h: mc.height - mc.dockZone - mc.m.stripHeight, strip: false }]
        delegate: Rectangle {
            required property var modelData
            y: modelData.y
            width: mc.width
            height: Math.max(0, modelData.h)
            clip: true
            color: Wallpaper.urlFor(mc.screen) ? "transparent" : mc.m.empty   // under a picture it only showed alone
            opacity: modelData.strip ? mc.e : mc.cover
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
    MouseArea { width: parent.width; height: parent.height - mc.dockZone; onClicked: Panels.close() }

    // Spaces bar. Collapsed (27.2.1): a labelled pill per Desktop, the current one filled, "+" at the
    // right. Pointing at it expands it to wallpaper thumbnails with the names under them (macOS
    // behaviour; the expanded look is the earlier hyprk one, not checked against 27.2.1).
    Item {
        id: spacesBar
        width: parent.width
        height: expanded ? Theme.mission.spacesTop + expandedRow.height + Theme.mission.spaceLabelGap : mc.m.barHeight
        y: -(A11y.reduceMotion ? 0 : 1 - mc.bar) * mc.m.barHeight
        opacity: mc.bar
        readonly property bool expanded: barHover.hovered && mc.shown
        readonly property real grow: growEase.value
        FrameEase { id: growEase; goal: spacesBar.expanded ? 1 : 0; duration: Theme.ms(mc.m.expandMs); ease: Easing.OutCubic }
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
            opacity: 1 - spacesBar.grow
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
                    color: current ? mc.m.pill : pm.containsMouse ? mc.m.pillHover : "transparent"
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
            y: Theme.mission.spacesTop
            spacing: Theme.mission.spaceSpacing
            opacity: spacesBar.grow
            visible: opacity > 0
            Repeater {
                model: spacesBar.expanded || spacesBar.grow > 0 ? mc.spaces : []
                delegate: Column {
                    id: sp
                    required property var modelData
                    required property int index
                    readonly property bool current: modelData === Hyprland.focusedWorkspace
                    spacing: Theme.mission.spaceLabelGap

                    ClippingRectangle {
                        width: Theme.mission.spaceThumbWidth
                        height: width * mc.height / Math.max(1, mc.width)
                        radius: Theme.mission.spaceRadius
                        color: Theme.glass.solid
                        border.width: sp.current ? Theme.mission.hoverBorder : 0
                        border.color: Theme.mission.text
                        scale: hoverEase.value
                        FrameEase { id: hoverEase; goal: spm.containsMouse ? Theme.mission.hoverScale : 1; duration: Theme.anim.fast }
                        Image {
                            anchors.fill: parent
                            source: Wallpaper.url
                            sourceSize.width: Wallpaper.thumbWidth
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }
                        MouseArea {
                            id: spm
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: mc.openSpace(sp.modelData)
                        }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: State.spaceName(sp.index, mc.spaces.length)
                        font: Typography.font(Theme.mission.labelSize, sp.current ? Typography.semibold : Typography.regular)
                        color: Theme.mission.text
                    }
                }
            }
        }

        // "+": a new empty Desktop (Hyprland makes it current; macOS adds it without switching)
        Item {
            anchors.right: parent.right
            anchors.rightMargin: mc.m.plusInset
            y: mc.m.plusCentre - height / 2
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
                readonly property var frame: mc.frames[index] || null
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
                function takeRect() {
                    if (mc.e >= 0.05) return;
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
                        anchors.fill: parent
                        radius: Theme.mission.thumbRadius
                        color: "transparent"
                        // the plugin title bar's strip, cut from the screen still
                        ShaderEffectSource {
                            visible: cell.bar !== null && cell.barSeen && still.hasContent && !(cell.repicked && cell.look)
                            width: parent.width
                            height: cell.barHeight
                            sourceItem: visible ? still : null
                            sourceRect: cell.bar ? cell.bar : Qt.rect(0, 0, 0, 0)
                        }
                        // the bar drawn from the plugin's description where the still has none: its fill, the lights in
                        // the window's state at open (active only for the focused one, as mc-light.png) and the title, laid out
                        // in points and scaled with the thumbnail
                        Rectangle {
                            readonly property bool active: cell.look ? cell.look.active || cell.repicked : false
                            readonly property var st: cell.look ? cell.look.look[active ? "active" : "inactive"] : null
                            visible: cell.bar !== null && st !== null && (!(cell.barSeen && still.hasContent) || cell.repicked)
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
                            live: false
                            Connections { target: mc; function onShownChanged() { if (mc.shown) { cell.repicked = false; view.captureFrame(); } } }
                            Connections { target: mc; function onRefocused(win) { if (win === cell.modelData) reshot.restart(); } }
                            Timer { id: reshot; interval: 50; onTriggered: { view.captureFrame(); cell.repicked = true; } }
                            // No second still on exit (one was taken in the tail for the windows' active look): the capture
                            // held qs's frames there, a 0.96 plateau for 2-4 frames (mcap); the look changes when the layer goes
                            constraintSize: Qt.size(cell.width, Math.max(1, cell.height - cell.barHeight))
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
                MouseArea {
                    id: wma
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: { mc.pickSwaps = 0; mc.pickedWindow = cell.modelData; mc.flyTop = cell.modelData; Panels.close(); Apps.focusWindow(cell.modelData); }
                }
            }
        }
    }
}
