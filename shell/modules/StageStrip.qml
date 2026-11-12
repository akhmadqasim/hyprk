import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs
import qs.components
import qs.services
import "../lib/stage.js" as Stage
import "../lib/spring.js" as SpringLib

// Stage Manager's strip (macOS 27.2.1 WindowManager; numbers from lib/stage.js): the recent apps as piles of their
// windows down the left edge, under the windows (the Bottom layer). A click on a pile brings its app to the stage.
// Exists only while Stage Manager is on (shell.qml LazyLoader). Pictures: one still per window, taken when the pile
// appears or the window joins it (no live feed). The perspective tilt of the Mac's piles is not decoded
// (PileRotation 75 and PilePerspectiveDistance -1750 feed the transition code 0x10030abfc, the resting angle is not
// traced): the piles are drawn in the code's flat style (StageManagerStripComponent.PerspectiveStyle.flat).
ShellWindow {
    id: strip
    required property var modelData
    screen: modelData

    readonly property var sp: Stage.prefs()
    readonly property real dockZone: (screen && Panels.dockZones[screen.name]) || 0
    // the Stage Manager available frame: below the menu bar, above the Dock (screen-local pt)
    readonly property real displayW: screen ? screen.width : 0
    readonly property var avail: ({ x: 0, y: Theme.menuBar.height, w: displayW, h: height - Theme.menuBar.height - dockZone })
    readonly property var rows: Stage.rowCount(avail.h, height)
    readonly property real pileMaxW: Stage.pileMaxWidth(displayW, height)
    // the strip's own width: the widest pile, its edge inset and the hover growth (ours: room for the 16 pt grow)
    readonly property real stripW: sp.edgeInset + pileMaxW * (1 + sp.hoverScaleDistance / Math.max(1, rows.itemHeight)) + sp.edgeInset

    // ---------- piles ----------
    // each pile: its app, up to 3 parked windows (most recent in front), its size and place. `extra`: windows about to
    // be parked (the slots of a switch before it is committed)
    function pilesFor(m, extra) {
        const hist = t => { const o = t.lastIpcObject; return o && o.focusHistoryID !== undefined ? o.focusHistoryID : 1e9; };
        const out = [];
        for (const k of Stage.visible(m, rows.rows)) {
            const wins = (StageManager.byApp[k] || []).filter(t => StageManager.isParked(t) || (extra || []).indexOf(t) >= 0)
                .sort((a, b) => hist(a) - hist(b)).slice(0, sp.pileMaximumWindowCount);
            const sized = wins.map(t => {
                const o = t.lastIpcObject, w = o && o.size ? o.size[0] : 800, h = o && o.size ? o.size[1] : 600;
                const s = Stage.windowScale(w, h, rows.scale, displayW, height);
                return { t: t, w: w * s, h: h * s };
            });
            const pw = sized.reduce((a, s) => Math.max(a, s.w), 0), ph = sized.reduce((a, s) => Math.max(a, s.h), 0);
            out.push({ key: k, wins: sized, w: pw, h: ph || rows.itemHeight });
        }
        const at = Stage.stripLayout(avail, out.map(p => p.h));
        out.forEach((p, i) => { p.x = at[i].x; p.y = at[i].y; });
        return out;
    }
    // the windows flying into the strip count as parked (they are off the stage, not yet on special:stage): without
    // them their pile had no size during the flight and the piles below moved 24 pt and back (judge #8b)
    readonly property var flyingOut: flights.filter(x => !x.landing).map(x => x.t)
    readonly property var pilesNow: pilesFor(StageManager.model, flyingOut)
    // a new array only when a pile really changed: the Repeater makes every pile again on a new array, and a new pile
    // stands empty until its stills are taken (a frame or more)
    property var piles: []
    property string pilesSig: ""
    onPilesNowChanged: {
        const sig = JSON.stringify(pilesNow.map(p => [p.key, p.x, p.y, p.w, p.h, p.wins.map(w => [StageManager.addressOf(w.t), w.w, w.h])]));
        if (sig !== pilesSig) { pilesSig = sig; piles = pilesNow; }
    }
    function pileOf(k) { return piles.find(p => p.key === k) || null; }

    // ---------- hiding ----------
    // the right edge of the strip's content, for the occlusion test
    readonly property real contentRight: piles.reduce((a, p) => Math.max(a, p.x + p.w), sp.edgeInset)
    // a stage window covers the strip by more than the threshold (AutoHideWhenOccluded); AutoHide hides it always
    property int geometryTick: 0
    readonly property bool occluded: {
        geometryTick;
        for (const t of StageManager.onStageOf(StageManager.model.stage)) {
            const o = t.lastIpcObject;
            if (o && o.at && Stage.occludes({ x: o.at[0] - (screen ? screen.x : 0) }, contentRight)) return true;
        }
        return false;
    }
    readonly property bool fullscreen: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.hasFullscreen : false
    property bool revealed: false
    readonly property bool hidden: fullscreen || (!revealed && piles.length > 0 && StageManager.model.stage !== "" && (StageManager.prefs.autoHide || occluded))
    property real shown: 1
    FrameSpring { id: showAnim; target: strip; property: "shown"; spring: strip.flightSpring }
    onHiddenChanged: showAnim.go(hidden ? 0 : 1)
    Connections {
        target: Hyprland
        function onRawEvent(event: HyprlandEvent): void {
            if (["openwindow", "closewindow", "movewindowv2", "activewindowv2", "changefloatingmode", "fullscreen"].indexOf(event.name) >= 0) refresh.restart();
        }
    }
    // the window list is asked again once per burst of events (positions are only in `hyprctl clients`)
    Timer { id: refresh; interval: 30; onTriggered: { Hyprland.refreshToplevels(); strip.geometryTick++; } }

    anchors { top: true; left: true; bottom: true }
    implicitWidth: stripW
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-stage-strip"
    color: "transparent"
    // revealed over a window: above the windows (shouldPresentStripAboveStage), else under them
    WlrLayershell.layer: revealed ? WlrLayer.Top : WlrLayer.Bottom
    inputMask: Region { item: column }

    // the edge where a pointer that rests reveals the hidden strip (AutoHideDelay 0.15 s = the prolonged edge-enter
    // delay, 0x1002e0944)
    Item {
        id: column
        x: -(1 - strip.shown) * (strip.contentRight + strip.sp.edgeInset)
        width: strip.stripW
        height: strip.height
        HoverHandler {
            id: stripHover
            onHoveredChanged: if (!hovered && strip.revealed) strip.revealed = false
        }
        Repeater {
            model: strip.piles
            delegate: Pile {}
        }
    }

    // ---------- one pile ----------
    component Pile: Item {
        id: pile
        required property var modelData
        x: modelData.x
        y: modelData.y
        width: modelData.w
        height: modelData.h
        visible: strip.landingKeys.indexOf(modelData.key) < 0
        readonly property string state_: pm.pressed ? "press" : pm.containsMouse ? "hover" : ""
        scale: Stage.interactionScale(height, state_)
        Behavior on scale { NumberAnimation { duration: 120 } }   // ours: the hover motion is not decoded
        transformOrigin: Item.Left
        Repeater {
            model: pile.modelData.wins.slice().reverse()
            delegate: Item {
                id: thumb
                required property var modelData
                required property int index
                readonly property int depth: pile.modelData.wins.length - 1 - index
                width: modelData.w
                height: modelData.h
                visible: view.hasContent      // no grey card while the still is taken
                RectangularShadow {
                    anchors.fill: parent
                    radius: strip.sp.cornerRadius
                    blur: Theme.glass.shadowRadius / 2
                    offset.y: Theme.glass.shadowYOffset / 2
                    color: Theme.glass.shadow
                }
                ClippingRectangle {
                    anchors.fill: parent
                    radius: strip.sp.cornerRadius
                    color: Theme.glass.solid
                    ScreencopyView {
                        id: view
                        anchors.fill: parent
                        captureSource: thumb.modelData.t.wayland
                        live: false
                        constraintSize: Qt.size(width, height)
                        onHasContentChanged: if (hasContent) strip.thumbIn(thumb.modelData.t, 1)
                        Component.onDestruction: if (hasContent) strip.thumbIn(thumb.modelData.t, -1)
                    }
                    // the windows behind the front one: 10 % darker per step (LeftStripStackDepthStepValue 0.1,
                    // 0x1002bc880; inferred: what the value darkens is not traced)
                    Rectangle { anchors.fill: parent; color: "black"; opacity: Math.min(1, strip.sp.stackDepthStep * thumb.depth) }
                }
            }
        }
        IconImage {
            readonly property var r: Stage.iconRect({ x: 0, y: 0, w: pile.width, h: pile.height })
            x: r.x; y: r.y
            implicitSize: r.w
            source: Apps.iconUrl(Apps.entryFor(pile.modelData.key) ? Apps.entryFor(pile.modelData.key).icon : pile.modelData.key, pile.modelData.key, Theme.iconLook)
        }
        MouseArea {
            id: pm
            anchors.fill: parent
            hoverEnabled: true
            onClicked: StageManager.bring(pile.modelData.key)
        }
    }

    // ---------- flights ----------
    // No spring of the strip / stage transition is decoded (StageManagerStripStageStandardTransitionInternalModifier
    // stores none in its fields): the windows fly on WindowManager's own window-flight spring, ExposeSpring (damping
    // 1.0, response 0.25, WindowManager.framework 0x1d2a7adc0 / 0x1d2a7ade8), the nearest decoded one
    readonly property var flightSpring: SpringLib.fromResponse(0.25, 1)
    property bool flying: false
    property bool preparing: false
    property var flights: []         // [{ t, from: rect, to: rect, landing: bool }]
    property var landingKeys: []     // the piles the windows leaving the stage fly into (shown once they land)
    property var request: null       // { m, out, inc } waiting for the flight's pictures
    property int ready: 0
    property real f: 0
    Component.onCompleted: { StageManager.animator = true; pilesNowChanged(); }
    Component.onDestruction: {
        StageManager.animator = false;
        // never leave a window off the screen or parked mid-flight
        if (flying) {
            StageManager.park(flights.filter(x => !x.landing).map(x => ({ t: x.t, at: x.at })));
            StageManager.land(flights.filter(x => x.landing).map(x => x.t));
        }
    }
    FrameSpring {
        id: flightAnim
        target: strip; property: "f"; spring: strip.flightSpring
        onFinished: {
            StageManager.land(strip.flights.filter(x => x.landing).map(x => x.t));
            StageManager.park(strip.flights.filter(x => !x.landing).map(x => ({ t: x.t, at: x.at })));
            strip.landingKeys = [];
            settle.restart();
        }
    }
    // the pictures stay over the windows that came back while Hyprland fades them in (WINDOW_ALPHA_MOVE_FROM_WORKSPACE,
    // about 140 ms measured; ours)
    Timer { id: settle; interval: 160; onTriggered: { strip.settling = true; settleCap.restart(); strip.endFlight(false); } }
    // ... and over the piles they landed in until the pile's own still is in (judge #8b: the new pile stood empty, or
    // black, for 130-430 ms after the flight); at most 1 s more (ours)
    Timer { id: settleCap; interval: 1000; onTriggered: strip.endFlight(true) }
    property bool settling: false
    property var thumbsIn: ({})          // window address -> pile stills of it that have content
    function thumbIn(t, n) {
        const a = StageManager.addressOf(t);
        thumbsIn[a] = (thumbsIn[a] || 0) + n;
        if (settling) endFlight(false);
    }
    function endFlight(force) {
        if (!force && flights.some(x => !x.landing && !(thumbsIn[StageManager.addressOf(x.t)] > 0))) return;
        settling = false;
        settleCap.stop();
        flying = false;
        flights = [];
    }
    Connections {
        target: StageManager
        function onSwitchRequested(m, outgoing, incoming) {
            if (strip.settling) strip.endFlight(true);
            if (strip.flying || strip.preparing) { StageManager.commit(m, outgoing, false); StageManager.land(incoming); return; }
            const sx = strip.screen ? strip.screen.x : 0, sy = strip.screen ? strip.screen.y : 0;
            const real = t => { const o = t.lastIpcObject; return o && o.at && o.size ? { x: o.at[0] - sx, y: o.at[1] - sy, w: o.size[0], h: o.size[1] } : null; };
            const offStrip = { x: -strip.pileMaxW, y: strip.height / 2, w: strip.pileMaxW, h: strip.rows.itemHeight };
            const slotIn = (t, piles) => {
                const p = piles.find(q => q.key === StageManager.keyOf(t));
                const w = p ? p.wins.find(x => x.t === t) : null;
                return w ? { x: p.x, y: p.y, w: w.w, h: w.h } : offStrip;
            };
            const after = strip.pilesFor(m, outgoing);
            const fl = [];
            for (const t of incoming) { const r = real(t); if (r) fl.push({ t: t, from: slotIn(t, strip.piles), to: r, landing: true }); }
            for (const t of outgoing) {
                const r = real(t), o = t.lastIpcObject;
                if (r) fl.push({ t: t, from: r, to: slotIn(t, after), landing: false, at: o.at.slice() });
            }
            strip.request = { m: m, out: outgoing, inc: incoming };
            strip.landingKeys = outgoing.map(t => StageManager.keyOf(t));
            strip.ready = 0;
            strip.flights = fl;
            strip.preparing = true;
            flightGate.restart();
            if (fl.length === 0) strip.launch();
        }
    }
    // the flight starts once every picture is in (at most 400 ms, ours: the flight layer is created for it and its first
    // pictures took 150-250 ms): the windows
    // leave the stage then, under their pictures
    Timer { id: flightGate; interval: 400; onTriggered: strip.launch() }
    // ... and the flight layer has shown them over the windows (one swap after the last one came in): parked
    // before that, a window was gone for a frame and its own fade showed
    // two swaps: the first can be of a frame begun before the last picture came in, and then the window left the stage
    // before Hyprland showed its picture (an empty stage frame, 1 of 3 pile clicks at 34 ms)
    property int armed: 0
    onReadyChanged: if (preparing && ready >= flights.length && armed === 0) armed = 2
    function launch() {
        if (!preparing) return;
        // flying before preparing ends: the flight layer's loader (active: flying || preparing) must not drop for a
        // moment, or the layer and its pictures were made again and the stage stood empty for 1-2 frames
        if (flights.length > 0) { flightAnim.snap(0); flying = true; }
        preparing = false;
        flightGate.stop();
        armed = 0;
        const r = request;
        request = null;
        StageManager.commit(r.m, r.out, flights.length > 0);
        if (flights.length === 0) { StageManager.land(r.inc); landingKeys = []; return; }
        flightAnim.go(1);
    }
    LazyLoader {
        active: strip.flying || strip.preparing
        PanelWindow {
            screen: strip.screen
            anchors { top: true; left: true; right: true; bottom: true }
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            // exempt from Hyprland's layer fade by hyprland.lua's hyprk-no-anim rule (a faded layer showed the wallpaper
            // through the flight for 0.1 s)
            WlrLayershell.namespace: "hyprk-stage-flight"
            mask: Region {}
            Item {
                id: flightRoot
                Connections {
                    target: flightRoot.Window.window
                    function onFrameSwapped() {
                        if (strip.armed <= 0) return;
                        if (--strip.armed === 0) strip.launch();
                        else flightRoot.Window.window.update();   // nothing else changes: ask for the second frame
                    }
                }
            }
            Repeater {
                model: strip.flights
                delegate: ClippingRectangle {
                    id: flyer
                    required property var modelData
                    readonly property real e: strip.flying ? strip.f : 0
                    property bool pictured: false
                    visible: pictured
                    // a fixed size moved by transforms, as Mission Control's thumbnails: a resized ScreencopyView
                    // takes a new picture, and the window has left the stage by then (it came out see-through)
                    x: modelData.from.x
                    y: modelData.from.y
                    width: modelData.from.w
                    height: modelData.from.h
                    transform: [
                        Scale { xScale: 1 + flyer.e * (flyer.modelData.to.w / flyer.modelData.from.w - 1); yScale: 1 + flyer.e * (flyer.modelData.to.h / flyer.modelData.from.h - 1) },
                        Translate { x: flyer.e * (flyer.modelData.to.x - flyer.modelData.from.x); y: flyer.e * (flyer.modelData.to.y - flyer.modelData.from.y) }
                    ]
                    radius: strip.sp.cornerRadius / Math.max(0.01, 1 + flyer.e * (flyer.modelData.to.w / flyer.modelData.from.w - 1))
                    color: Theme.glass.solid
                    ScreencopyView {
                        id: fv
                        anchors.fill: parent
                        captureSource: flyer.modelData.t.wayland
                        live: false
                        onHasContentChanged: if (hasContent && !flyer.pictured) { flyer.pictured = true; frozen.scheduleUpdate(); strip.ready++; }
                    }
                    // the first picture, kept: the window leaving the stage changes its geometry, the view takes a new
                    // picture and has none for a frame (judge #8b: the outgoing window missing at 34 ms, an empty stage)
                    ShaderEffectSource {
                        id: frozen
                        anchors.fill: parent
                        sourceItem: fv
                        hideSource: true
                        live: false
                    }
                }
            }
        }
    }

    // the left edge, while the strip is hidden: a pointer resting there 0.15 s reveals it
    LazyLoader {
        active: strip.hidden && !strip.fullscreen
        PanelWindow {
            screen: strip.screen
            anchors { top: true; left: true; bottom: true }
            implicitWidth: 1
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "hyprk-stage-edge"
            HoverHandler { id: edge; onHoveredChanged: hovered ? edgeTimer.restart() : edgeTimer.stop() }
            Timer { id: edgeTimer; interval: strip.sp.autoHideDelay * 1000; onTriggered: strip.revealed = true }
        }
    }
}
