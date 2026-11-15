import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs
import qs.components
import qs.HyprK
import qs.services
import "../lib/search.js" as Search
import "../lib/spotlight.js" as SL
import "../lib/spring.js" as SpringLib
import "../lib/appsgrid.js" as AG
import "spotlight"

// Spotlight (Super+Space), macOS 27.2.1 (MAC-ANSWERS.md Q-panels-14..-26): two glass shapes, a 520 x 87 search
// capsule centred at 26.65 % of the screen height (Theme.spotlight.barCentre) and, 10 below it, one panel:
// - results (520 wide, r 37, rows of 62, at most 410 tall) once text is typed;
// - the mode list (520 x 214) once the pointer moves anywhere while the field is empty (MAC-ANSWERS-3.md R3.2b);
// with a resting pointer and an empty field only the bar shows;
// - a mode (Cmd+1..4 or the list): Applications = the Apps panel (844 x 520, AppsPanel.qml, also the Dock's
//   "Apps"), Files = the same panel with file tiles (FilesPanel.qml), Actions / Clipboard = a 520 x 490 list
//   (ModeView.qml).
// No magnifier: the left of the field is empty, or holds the mode glyph; the right holds a mic (no action: hyprk
// has no dictation), the top hit's icon once text is typed, or "..." in a mode. Esc: the first returns to the
// plain "Search or Ask" bar (leaves the mode, clears the query), the second closes.
ShellWindow {
    id: sp

    required property var modelData
    screen: modelData

    readonly property bool shown: Panels.open === "spotlight"
    // MAC-ANSWERS.md "REA 27.2.1" section 4 (SpotlightUIInternal, CASpringAnimation(perceptualDuration:bounce:)),
    // each on one exact spring (components/SpringCurve.qml):
    // - open (FUN_2adea2ff0, FUN_2ade9ef14 flag 0): transform.scale.x AND scale.y 1.12 -> 1 on Spring(0.28,
    //   bounce 0.32) (ratio 0.68), the path the empty bar takes live (PC #67 A4, verify/A/spotlight-open-fit.json:
    //   RMS 0.22-0.30 pt of 487; height fits a 1.12 start, not 0.95; undershoot to 0.994). The other branch of
    //   FUN_2adea2ff0 (x on bounce 0.41, y 0.95 -> 1) is not seen live. Window alpha 0 -> 1 on Spring(0.28, 0.41);
    //   R3.2 (spotlight-light-white-open-close.mov, pts) agrees: width 1.096 1.075 1.054 1.037 1.021 1.010 per frame,
    //   ours 1.091 1.069 1.050 1.033 1.017 1.008 (SPOTLIGHT-27.2.1.md "Round R3.2"). No blur on the open: the edge stays 12-13 pt wide from the first
    //   frame (that clip and spotlight-pill-idle-light.mov), so the decoded contentBlurRadius 25 -> 0 is not drawn;
    // - close (FUN_2adea36c8, FUN_2ade9ef14 flag 1): scale.x 1 -> 1.12 and scale.y 1 -> 0.95 on Spring(0.45, 0.05)
    //   (decoded). The decoded alpha (Spring(0.28, 0.41), 7 frames here) and contentBlurRadius 0 -> 25 (Spring(0.51,
    //   0.05)) are far slower than the Mac draws them: alpha .325 then .051 then gone, edge 20 then 36 pt
    //   (spotlight-light-white-open-close.mov 2.100 / 2.117 s; scaled/more-space-spotlight-close.mov one frame at
    //   .30), so both run on a critically damped 0.045 s spring (.325 / .052 one and two frames in). The blur is a
    //   QML blur of the stage, on only while closing (the plugin glass is not blurred, it dematerializes).
    // Not done: transform.translation.y (its start value is not read). The scale anchor is not read: the search
    // field's centre.
    // The window is kept loaded but unmapped after the shell has started (shell.qml): created on open it showed its
    // first frame ~90 ms after the call. The springs start on the first frame after it maps (alpha 0), else mapping
    // eats their first frames. Reduce motion: no scale (Theme.travel), no blur, the fade stays.
    property real scaleX: 1.12
    property real scaleY: 1.12
    property real alpha: 0
    readonly property var springOpen: SpringLib.fromBounce(0.28, 0.32)
    readonly property var springClose: SpringLib.fromBounce(0.45, 0.05)
    readonly property var springAlpha: SpringLib.fromBounce(0.28, 0.41)
    readonly property var springCloseFade: SpringLib.fromResponse(0.045, 1)
    property real blurRadius: 0
    property bool blurOn: false
    SpringCurve {
        id: animBlur
        freshHold: 0
        firstAt: sp.firstAt
        target: sp; property: "blurRadius"; spring: sp.springCloseFade
    }
    // Every open starts after a swapped frame of the window (firstFrame below), so the springs take no fresh-layer
    // hold: with it a reopen drew the start frame and the first tick at the same scale (mcap 1.112 1.112 1.096, the
    // bar's left glass edge on its centre row). The open's first frame shows the springs 38.7 ms in: the Mac's first
    // visible frame (spotlight-open-fit.json, bounce 0.32 fitted at t0 -0.0387 s, first visible sx 1.0877); the close
    // starts one interval in
    property real firstAt: 0
    SpringCurve { id: animX; target: sp; property: "scaleX"; freshHold: 0; firstAt: sp.firstAt }
    SpringCurve { id: animY; target: sp; property: "scaleY"; settlesGlass: true; freshHold: 0; firstAt: sp.firstAt }   // steps after animX: the glass is re-measured once both moved
    SpringCurve {
        id: animAlpha
        target: sp
        freshHold: 0
        // the open's alpha is 11 ms further in than its scale: the Mac's first frames read .375 .568 .736 .865 .963,
        // the decoded spring at 50.0 / 49.9 / 50.1 ms + k frames (spotlight-light-white-open-close.mov; the scale's
        // first frame stays at 38.7 ms: width within 3.5 pt per frame)
        firstAt: sp.firstAt > 0 ? 0.050 : 0
        property: "alpha"
        spring: sp.springAlpha
        onFinished: if (!sp.shown) sp.gone = true
    }
    property bool gone: false
    // Apps (Spotlight's apps mode here) opened straight in the mode (the Dock's Apps, Go > Applications): it appears
    // in one frame and Escape closes it in one frame (MAC-ANSWERS.md R2; round 17 could not capture this open: no Apps
    // tile on its Dock). Cmd-1 from the open bar grows the panel instead (panelMotion, R17.1). With the Spotlight springs it faded in over 0.10 s and kept a 13 % tail for
    // 0.12 s on close (mcap). The mode is taken at open: SpotlightState forgets it when Spotlight closes.
    property bool appsCut: false
    function animate(open) {
        gone = false;
        firstAt = open ? 0.0387 : 0;
        if (open) appsCut = mode === "apps";
        if (appsCut) {
            animX.snap(1);
            animY.snap(1);
            animAlpha.snap(open ? 1 : 0);
            blurOn = false;
            animBlur.snap(0);
            gone = !open;
            settleGlass(50);
            return;
        }
        blurOn = !open && !A11y.reduceMotion;
        if (!blurOn) animBlur.snap(0);
        else animBlur.go(25);
        animX.spring = open ? springOpen : springClose;
        animY.spring = open ? springOpen : springClose;
        animAlpha.spring = open ? springAlpha : springCloseFade;
        animX.go(open ? 1 : 1.12);
        animY.go(open ? 1 : 0.95);
        animAlpha.go(open ? 1 : 0);
        settleGlass(Math.max(animX.duration, animY.duration, animAlpha.duration) + 50);   // the glass follows the scale
    }
    property bool firstFrame: true
    // the open starts once the window's swaps pause (4 ms without one), not on the first swap: a remapped window swaps its first two frames back to back (2 ms
    // apart), and a run started on the first swap counted the second as its first tick's (HyprK FrameClock built /
    // swaps), so it sent the second tick's glass region before the first tick's frame was committed: the reopen's first
    // frame drew the first tick's content in the second tick's glass (liquidglass trace: 1.069 / .45 twice, content of
    // the first tick; mcap 1.069 1.069 1.046), and a queued second swap restarted the springs (1.090 1.043)
    Timer { id: firstSwapQuiet; interval: 4; onTriggered: { sp.firstFrame = false; if (sp.shown) sp.animate(true); } }
    Connections {
        target: sp.firstFrame ? sp.contentItem.Window.window : null
        function onFrameSwapped() { if (sp.firstFrame) firstSwapQuiet.restart(); }
    }
    visible: shown || !gone
    lingerAs: "spotlight"
    lingering: !shown && !gone
    glassOpacity: alpha
    // while dematerializing it takes no input, so it never eats the next click
    acceptsInput: shown
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-spotlight"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property string query: ""
    property string category: ""            // Applications: the chip picked, shown as a token in the field
    property int selected: 0
    readonly property var calcValue: Search.calc(query)
    // "2+2": no list, the bar grows with a result card (Q-panels-20, -21) until Show Results asks for the list
    property bool showAll: false
    readonly property bool calcCard: mode === "" && calcValue !== null && !showAll
    readonly property string calcText: calcValue !== null ? Search.formatNumber(calcValue) : ""
    onCalcCardChanged: settleGlass(200)
    // browse mode ("" = all results), shared with SpotlightState so global shortcuts and the Dock can open one
    readonly property string mode: SpotlightState.mode
    readonly property var modeInfo: SL.modeInfo(mode)
    readonly property var apps: shown && mode === "" && query.trim() !== "" ? Search.rank(Apps.visibleEntries, query, Theme.spotlight.maxApps) : []
    readonly property var actions: mode === "" && query.trim() !== "" ? SpotlightActions.rank(query, 2) : []
    readonly property bool quickKeyHit: SL.quickKeyAction(SpotlightState.quickKeys, query) !== ""
    readonly property var files: mode === "" ? FileSearch.results.slice(0, 3) : []
    Binding { target: FileSearch; property: "query"; value: sp.mode === "" || sp.mode === "files" ? sp.query : "" }
    // the inline completion: the top hit is an app whose name begins with the query, the caret at its end, the first
    // row selected (r17 spotlight-typed-*.png)
    // In Applications the pill holds the action alone (apps-typed-cal-*.png: "cal" + " — Open", the first hit on its plate)
    readonly property string completionRest: {
        if (input.cursorPosition !== input.text.length || input.selectedText !== "") return "";
        if (mode === "" && selected === 0 && rows.length > 0 && rows[0].kind === "app") return SL.completion(input.text, rows[0].title);
        const it = mode === "apps" ? modePanel.item : null;
        return it && input.text.trim() !== "" && it.apps.length > 0 && it.selected <= 0 ? SL.completion("", "", true) : "";
    }
    // rows: {kind: "calc"|"app"|"action"|"file", ...}; 27.2.1 has no section headers (Q-panels-20)
    readonly property var rows: {
        if (mode !== "" || query.trim() === "" || calcCard) return [];
        const r = [];
        const addActions = () => { for (const a of actions) r.push({ kind: "action", title: a.title, subtitle: a.subtitle || "", action: a }); };
        if (quickKeyHit) addActions();      // a typed quick key puts its action on top
        if (calcValue !== null) r.push({ kind: "calc", title: Search.formatNumber(calcValue), subtitle: query.trim() + " =" });
        // app rows: the name alone (spotlight-light-white-results.png, spotlight-pill-clear-*.mov: "TextEdit",
        // "Terminal", no "Application" line)
        for (const a of apps) r.push({ kind: "app", title: a.name, subtitle: "", entry: a, icon: a.icon });
        if (!quickKeyHit) addActions();
        for (const f of files) r.push({ kind: "file", title: f.name, subtitle: f.dir, file: f });
        return r;
    }

    // the mode list: once the pointer really moves while Spotlight is open and the field is empty, anywhere on the
    // screen, not only over the bar; never without a move (a layer mapped under a resting pointer gets an enter and
    // a motion at that point: components/PointerGate.qml). It stays when the pointer leaves, until text is typed
    // (MAC-ANSWERS-3.md R3.2b: spotlight-pill-idle-*.mov no list with the pointer parked, spotlight-pill-hover-*.mov
    // the list as the pointer starts to move far from the bar, still there 1.5 s after it left). Holding Command
    // does not show it: the decoded commandKeyHintTimer (0.35 s) shows shortcut indicators whose target is not traced
    // (SPOTLIGHT-27.2.1.md 3.1), and no Mac capture shows the list on a Command hold.
    PointerGate { id: hoverGate }
    property bool modeListArmed: false
    function noteMotion(item, x, y): void {
        if (hoverGate.note(item, x, y) && shown && mode === "" && input.text === "") modeListArmed = true;
    }
    readonly property string below: mode === "apps" ? "apps" : mode === "files" ? "files" : mode !== "" ? "list"
        : rows.length > 0 ? "results" : modeListArmed && query === "" ? "modes" : ""
    // the panel's own state: `below`, or "gone" while the emptied results panel collapses into its anchor
    // (Theme.spotlight.panelAnchorY: the mode list grows out of it, the results panel goes back into it when the
    // field is cleared, R3.2b clear clip: its rows go first, then the empty glass shrinks, fades and blurs). Typing
    // over the list, a list mode: the panel changes in one frame, as before (Q-panels-26, MAC-ANSWERS.md R2); Apps from
    // the bar grows and collapses (MAC-ANSWERS-17.md R17.1, panelMotion).
    property string panelKind: ""
    property real goneH: 0
    property bool goneWide: false
    property real panelSx: 1
    property real panelSy: 1
    property real panelAlpha: 1
    property real panelBlur: 0
    SpringCurve { id: pScaleX; target: sp; property: "panelSx"; freshHold: 0 }
    SpringCurve { id: pScaleY; target: sp; property: "panelSy"; freshHold: 0; settlesGlass: true }   // after pScaleX
    SpringCurve { id: pFade; target: sp; property: "panelAlpha"; freshHold: 0; spring: Theme.spotlight.listFadeSpring }
    SpringCurve { id: pBlur; target: sp; property: "panelBlur"; freshHold: 0; onFinished: if (goal === 0) sp.panelLayer = false }
    // the blur's layer, switched on in the handler that starts the motion, before its first frame: switched on by the
    // first blur value (the springs step after the frame's polish) it drew one empty frame (mcap: the collapse's
    // first frame had no panel)
    property bool panelLayer: false
    FrameAnim {
        id: pFadeOut
        target: sp
        property: "panelAlpha"
        to: 0
        duration: Theme.spotlight.collapseFadeMs
        onRunningChanged: if (!running && sp.panelKind === "gone") sp.panelSettle("")
    }
    function panelSettle(kind): void {
        panelKind = kind;
        pFadeOut.stop(); pScaleX.snap(1); pScaleY.snap(1); pFade.snap(1); pBlur.snap(0);
        panelLayer = false;
    }
    function panelMotion(): void {
        const was = panelKind;
        const moving = shown && !A11y.reduceMotion;
        if (below === "modes" && was !== "modes" && shown) {
            panelKind = "modes";
            pFadeOut.stop();
            const s = Theme.spotlight;
            pScaleX.spring = s.listSpring; pScaleY.spring = s.listSpring; pBlur.spring = s.listSpring;
            pFade.spring = s.listFadeSpring; pFade.firstAt = 0;
            pScaleX.firstAt = 0; pScaleY.firstAt = 0;
            panelLayer = moving;
            pScaleX.snap(s.listFromX); pScaleY.snap(s.listFromY); pFade.snap(0); pBlur.snap(moving ? s.panelBlur : 0);
            pScaleX.go(1); pScaleY.go(1); pFade.go(1); pBlur.go(0);
            return;
        }
        // Applications from the bar (MAC-ANSWERS-17.md R17.1, apps-open-close-light.mov): the bar takes the mode in one
        // frame and the Apps panel grows out of the same anchor as the mode list, faster (Theme.spotlight.apps*). Opened
        // straight in the mode (the Dock's Apps, appsCut) it is there in one frame, as before
        if (below === "apps" && was !== "apps" && shown && !appsCut) {
            panelKind = "apps";
            pFadeOut.stop();
            const s = Theme.spotlight;
            pScaleX.spring = s.appsSpring; pScaleY.spring = s.appsSpring; pBlur.spring = s.appsSpring;
            pFade.spring = s.appsFadeSpring; pFade.firstAt = s.appsFadeFirstAt;
            pScaleX.firstAt = s.appsFirstAt; pScaleY.firstAt = s.appsFirstAt;
            panelLayer = moving;
            pScaleX.snap(s.appsFromX); pScaleY.snap(s.appsFromY); pFade.snap(0); pBlur.snap(moving ? s.panelBlur : 0);
            pScaleX.go(1); pScaleY.go(1); pFade.go(1); pBlur.go(0);
            return;
        }
        // the emptied results panel, and the Apps panel on Escape (its grid goes in one frame, then the empty panel
        // collapses: apps-open-close-light.mov 5.083 s, 5.217 .. 5.300 s)
        if (below === "" && (was === "results" || was === "apps") && shown) {
            goneH = panel.height;
            goneWide = was === "apps";
            panelKind = "gone";
            const s = Theme.spotlight;
            pFadeOut.duration = goneWide ? s.appsCollapseFadeMs : s.collapseFadeMs;
            const cs = goneWide ? s.appsCollapseSpring : s.collapseSpring;
            pScaleX.firstAt = 0; pScaleY.firstAt = 0;
            pScaleX.spring = cs; pScaleY.spring = cs; pBlur.spring = cs;
            panelLayer = moving;
            pScaleX.go(goneWide ? s.appsCollapseToX : s.collapseToX); pScaleY.go(goneWide ? s.appsCollapseToY : s.collapseToY);
            pBlur.go(moving ? s.panelBlur : 0);
            pFade.stop(); pFadeOut.from = panelAlpha; pFadeOut.start();
            return;
        }
        if (below === "" && was === "gone") return;
        panelSettle(below);
    }
    onBelowChanged: { panelMotion(); settleGlass(50); }

    function setMode(m) {
        SpotlightState.mode = m;
        category = "";
        input.text = "";
        input.forceActiveFocus();
    }
    // query field keys without a dedicated handler: Super/Ctrl/Alt+1..4 pick a mode; Left/Right move in the Apps
    // grid (they do not cycle modes on the Mac); Backspace on an empty field drops the category token
    function handleKey(event) {
        // Clipboard: Cmd-Delete on an empty field deletes the selected item (the Mac has a per-item delete,
        // com.apple.spotlight.delete.pasteboard.item; its key is not decoded)
        if (mode === "clipboard" && input.text === "" && (event.modifiers & (Qt.MetaModifier | Qt.ControlModifier))
                && (event.key === Qt.Key_Backspace || event.key === Qt.Key_Delete)) {
            modePanel.item.deleteSelected(); event.accepted = true; return;
        }
        // Command alone: Cmd-0 back to all results, Cmd-R / Cmd-Return reveal the file in the Finder, Cmd-, Spotlight
        // settings (SL.commandForKey; Cmd-D / Cmd-L and Cmd-H have no hyprk counterpart yet)
        if ((event.modifiers & (Qt.MetaModifier | Qt.ControlModifier | Qt.AltModifier | Qt.ShiftModifier)) === Qt.MetaModifier) {
            const c = SL.commandForKey(event.key);
            if (c === "clear" && mode !== "") { setMode(""); event.accepted = true; return; }
            if (c === "reveal" && revealSel()) { event.accepted = true; return; }
            if (c === "settings") { SpotlightActions.openPane("spotlight"); Panels.close(); event.accepted = true; return; }
            // Cmd-C with no text selected in the field: the selected result (a file's path) to the clipboard
            if (c === "copy" && input.selectedText === "") {
                const t = SL.copyText(selectedRow());
                if (t !== "") { Quickshell.clipboardText = t; event.accepted = true; return; }
            }
            // Cmd-B web search, Cmd-K Wikipedia: the query in the default browser
            if ((c === "web" || c === "wikipedia") && input.text.trim() !== "") {
                openUrl(c === "web" ? SL.webSearchUrl(input.text) : SL.wikipediaUrl(input.text));
                Panels.close(); event.accepted = true; return;
            }
            // Cmd-Y Quick Look, Cmd-I Get Info: our Finder opens on the file's folder with it selected and Quick Look
            // (--quicklook) or its Get Info (--info) up
            if ((c === "quicklook" || c === "info") && finderSel(c === "info" ? "--info" : "--quicklook")) { event.accepted = true; return; }
        }
        const m = SL.modeForKey(event.key, event.modifiers & Qt.MetaModifier, event.modifiers & Qt.ControlModifier, event.modifiers & Qt.AltModifier);
        if (m !== "") { setMode(m === mode ? "" : m); event.accepted = true; return; }
        if (event.key === Qt.Key_Backspace && input.text === "" && category !== "") { category = ""; event.accepted = true; return; }
        const dir = event.key === Qt.Key_Right ? 1 : event.key === Qt.Key_Left ? -1 : 0;
        if (dir !== 0 && (mode === "apps" || mode === "files") && input.text === "") { modePanel.item.move(dir, 0); event.accepted = true; }
    }
    function moveSel(dir) {
        if (mode === "apps" || mode === "files") modePanel.item.move(0, dir);
        else if (mode !== "") modePanel.item.move(dir);
        else step(dir);
    }
    // the selected result in any mode, as a row ({ kind, title, file, ... })
    function selectedRow() {
        if (mode === "") return rows[selected] || null;
        const it = modePanel.item;
        const x = it && it.items ? it.items[it.selected] : null;
        if (!x) return null;
        return mode === "files" ? { kind: "file", title: x.name, file: x } : x;
    }
    // a URL in the default browser; HYPRK_URL_OPENER replaces xdg-open (tests stub it: never the host's browser)
    function openUrl(url) { Quickshell.execDetached([Quickshell.env("HYPRK_URL_OPENER") || "xdg-open", url]); }
    function finderSel(option): bool {
        const r = selectedRow();
        const args = SL.finderArgs(r && r.kind === "file" ? r.file : null, option);
        if (args.length === 0) return false;
        Apps.runHyprkApp("hyprk-finder", {}, args);
        Panels.close();
        return true;
    }
    // the selected file's folder in the Finder (all results or Files); false when the selection is no file
    function revealSel(): bool {
        const f = mode === "files" && modePanel.item ? modePanel.item.items[modePanel.item.selected]
            : mode === "" && rows[selected] && rows[selected].kind === "file" ? rows[selected].file : null;
        if (!f || !f.path) return false;
        Apps.openFinder(f.isDir ? f.path : f.path.slice(0, f.path.lastIndexOf("/")) || "/");
        Panels.close();
        return true;
    }
    function acceptSel() { if (mode !== "") modePanel.item.accept(); else accept(); }
    function escapeKey() {
        if (mode === "" && input.text === "" && category === "") Panels.close();
        else setMode("");
    }
    function step(dir) { if (rows.length > 0) selected = (selected + dir + rows.length) % rows.length; }

    // the window exists only while open (shell.qml LazyLoader); a query handed over
    // by IPC is taken on creation and whenever a new one arrives
    function takeQuery() {
        if (Panels.spotlightQuery === "") return;
        input.text = Panels.spotlightQuery;
        Panels.spotlightQuery = "";
    }
    function present() {
        if (!firstFrame) animate(true);
        takeQuery();
        input.forceActiveFocus();
        if (selectOnShow) { input.selectAll(); selectOnShow = false; }
        FileSearch.loadRecents();
    }
    Component.onCompleted: { if (shown) present(); else gone = true; }
    // reopened after it went: map again from the start values, empty; the springs start on the window's first swapped
    // frame, as on creation (they started at once and the fresh-layer hold showed the start scale twice, mcap)
    // closed less than 8 minutes ago: the query is still there, selected (SL.keepsQuery)
    property real closedAt: 0
    property bool selectOnShow: false
    function rearm() {
        firstFrame = true;
        firstSwapQuiet.stop();
        animX.snap(1.12);
        animY.snap(1.12);
        animAlpha.snap(0);
        animBlur.snap(0);
        selectOnShow = SL.keepsQuery(closedAt, Date.now());
        if (!selectOnShow) input.text = "";
        category = "";
        selected = 0;
        showAll = false;
        modeListArmed = false;
        hoverGate.reset();
        panelSettle(below);
    }
    onShownChanged: {
        if (!shown) closedAt = Date.now();
        if (shown && gone) rearm();
        shown ? present() : animate(false);       // present(): also reopened while still fading out
    }
    onModeChanged: category = ""
    Connections {
        target: Panels
        function onSpotlightQueryChanged() { sp.takeQuery(); }
        function onSpotlightEmptiedChanged() { input.text = ""; sp.selectOnShow = false; }
    }
    onQueryChanged: { selected = 0; showAll = false; }
    // rows fill in after the query changed (streamed files, late actions): the selection
    // follows its row by key, so Return never opens a row that slid under the index
    function rowKey(r) {
        if (!r) return "";
        return r.kind + ":" + (r.entry ? r.entry.id : r.action ? r.action.id : r.file ? r.file.path : r.title);
    }
    property string selectedKey: ""
    onSelectedChanged: selectedKey = rowKey(rows[selected])
    onRowsChanged: {
        const i = selectedKey ? rows.findIndex(r => rowKey(r) === selectedKey) : -1;
        selected = Math.max(0, i);
    }

    function accept() {
        if (calcCard) { Quickshell.clipboardText = calcText; Panels.close(); return; }
        const row = rows[selected];
        if (!row) return;
        if (row.kind === "action") { SpotlightActions.run(row.action); return; }
        if (row.kind === "app") Apps.launch(row.entry, row.entry.id);
        else if (row.kind === "file") FileSearch.open(row.file);
        else if (row.kind === "calc") Quickshell.clipboardText = row.title;
        Panels.close();
    }

    // a press outside closes. On the menu bar's Spotlight item it is the item's press (SPUISpotlightMenuItem
    // _handleStatusItemPress:, 0x2ade56b60): Spotlight was showing, so the release closes it unless the press was held
    // 1.0 s (the long-press timer, 0x2ade56bcc)
    MouseArea {
        id: outside
        anchors.fill: parent
        // a move anywhere on the screen shows the mode list (noteMotion)
        hoverEnabled: true
        onPositionChanged: mouse => sp.noteMotion(this, mouse.x, mouse.y)
        property bool onItem: false
        function isItem(m) {
            const r = sp.screen ? Panels.spotlightItems[sp.screen.name] : null;
            return !!r && m.y < Theme.menuBar.height && m.x >= r.x && m.x < r.x + r.w;
        }
        onPressed: m => {
            onItem = isItem(m);
            if (onItem) itemHold.restart();
            else Panels.close();
        }
        onReleased: {
            if (onItem && itemHold.running) Panels.close();
            itemHold.stop();
            onItem = false;
        }
        Timer { id: itemHold; interval: 1000 }
    }

    // bar and panel share the open/close scale, around the field's centre
    Item {
        id: stage
        anchors.fill: parent
        opacity: sp.alpha
        // the close's content blur (0 -> 25 pt); MultiEffect's blur reaches blurMax px at blur 1
        // switched on before the close's first frame, not by the first blur value: the springs step after the
        // frame's polish, and an effect created then showed one empty frame (mcap: the bar gone, then back at .22)
        layer.enabled: sp.blurOn
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 64
            blur: Math.min(1, sp.blurRadius * (sp.devicePixelRatio > 0 ? sp.devicePixelRatio : 2) / 64)
        }
        readonly property real barX: Math.round((width - Theme.spotlight.barW) / 2)
        readonly property real barY: Math.round(height * Theme.spotlight.barCentre - Theme.spotlight.barH / 2)
        transform: Scale {
            origin.x: stage.width / 2
            origin.y: stage.barY + Theme.spotlight.barH / 2
            xScale: 1 + Theme.travel(sp.scaleX - 1)
            yScale: 1 + Theme.travel(sp.scaleY - 1)
        }


        // ---------- the search capsule ----------
        Item {
            id: bar
            x: stage.barX
            y: stage.barY
            width: Theme.spotlight.barW
            height: Theme.spotlight.barH
            readonly property real fullHeight: sp.calcCard ? Theme.spotlight.calcBarH : Theme.spotlight.barH
            Glass {
                width: parent.width
                height: bar.fullHeight
                radius: Theme.spotlight.barRadius
                sx: bar.x
                sy: bar.y
                tint: Theme.glass.tintStrong
            }
            // the dark vertical gradient (Q-panels-14)
            Rectangle {
                width: parent.width
                height: bar.fullHeight
                radius: Theme.spotlight.barRadius
                gradient: Gradient {
                    GradientStop { position: 0; color: Theme.spotlight.barTopTint }
                    GradientStop { position: 0.14; color: Theme.spotlight.barUpperTint }
                    GradientStop { position: 0.5; color: Theme.spotlight.barMidTint }
                    GradientStop { position: 0.87; color: Theme.spotlight.barLowerTint }
                    GradientStop { position: 1; color: Theme.spotlight.barBottomTint }
                }
            }
            // the light rim on the top and bottom edges, over the veil (Theme.spotlight.barRim*, shaders/spotrim.frag)
            ShaderEffect {
                width: parent.width
                height: bar.fullHeight
                property size size: Qt.size(width, height)
                property real radius: Theme.spotlight.barRadius
                property point fall: Qt.point(Theme.spotlight.barRimFall, Theme.spotlight.barRimBottomFall)
                property vector3d rimTop: Theme.spotlight.barRimTop
                property vector3d rimBottom: Theme.spotlight.barRimBottom
                fragmentShader: Qt.resolvedUrl("../shaders/spotrim.frag.qsb")
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onPositionChanged: mouse => sp.noteMotion(this, mouse.x, mouse.y)
            }
            Symbol {
                id: modeGlyph
                visible: sp.modeInfo !== null
                x: Theme.spotlight.modeGlyphX
                anchors.verticalCenter: parent.verticalCenter
                name: sp.modeInfo ? sp.modeInfo.symbol : ""
                size: Theme.spotlight.modeGlyph
                color: Theme.spotlight.placeholder
            }
            // a category picked in Applications: a grey token before the query
            Rectangle {
                id: token
                visible: sp.category !== ""
                x: Theme.spotlight.modeTextX
                anchors.verticalCenter: parent.verticalCenter
                width: visible ? tokenText.implicitWidth + 2 * Theme.spotlight.tokenPad : 0
                height: Theme.spotlight.tokenH
                radius: Theme.spotlight.tokenRadius
                color: Theme.spotlight.tokenFill
                Text {
                    id: tokenText
                    anchors.centerIn: parent
                    text: sp.category
                    font: input.font
                    color: Theme.spotlight.text
                }
            }
            // trailing: the mic (no action), the top hit's icon once text is typed, "..." in Applications, Files
            // and Clipboard (its View as Grid / List menu is not built)
            Item {
                id: trailing
                anchors.right: parent.right
                anchors.rightMargin: Theme.spotlight.trailingRight
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28
                Symbol {
                    anchors.right: parent.right
                    anchors.rightMargin: -Theme.spotlight.micBoxPad   // the glyph's box is wider than its ink
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -1.75                // ink 61.5 .. 82.5 of the bar's 87
                    visible: sp.mode === "" && sp.apps.length === 0
                    name: "microphone"                // the outline mic (r17 spotlight-idle-*: ink 14.5 x 21)
                    size: Theme.spotlight.micSize
                    color: Theme.spotlight.placeholder
                }
                AppIcon {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -1.5
                    width: Theme.spotlight.barIcon / Theme.appIcon.body   // the top hit's icon art
                    height: width
                    visible: sp.mode === "" && (sp.apps.length > 0 || sp.calcCard)
                    size: width
                    // the calculator's icon with an answer (Q-panels-21)
                    icon: sp.calcCard ? "accessories-calculator" : sp.apps.length > 0 ? sp.apps[0].icon || "" : ""
                    appId: sp.calcCard ? "org.gnome.Calculator" : sp.apps.length > 0 ? sp.apps[0].id : ""
                }
                Symbol {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spotlight.ellipsisRight - Theme.spotlight.trailingRight
                    anchors.verticalCenter: parent.verticalCenter
                    visible: sp.mode !== "" && sp.mode !== "actions"
                    name: "ellipsis"
                    size: 18
                    color: Theme.spotlight.placeholder
                }
            }
            // the caret's halo, added over the bar (shaders/caretglow.frag); with the caret, never with the completion
            ShaderEffect {
                id: caretGlow
                visible: input.cursorVisible && sp.completionRest === "" && input.selectedText === ""
                readonly property rect cr: input.cursorRectangle
                width: 2 + 12 * Theme.spotlight.caretGlowSigma
                height: 26 + 12 * Theme.spotlight.caretGlowSigma
                x: input.x + cr.x + 1 - width / 2
                y: input.y + cr.y + cr.height / 2 - height / 2
                property size size: Qt.size(width, height)
                property point caret: Qt.point(2, 26)
                property real sigma: Theme.spotlight.caretGlowSigma
                property real gain: Theme.spotlight.caretGlowGain
                fragmentShader: Qt.resolvedUrl("../shaders/caretglow.frag.qsb")
            }
            TextInput {
                id: input
                MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton; cursorShape: Qt.IBeamCursor }   // TextInput sets no I-beam itself
                TextMenu {   // the field editor's right-click menu (HyprK textmenu.js), glass on the plugin (TextMenuHost)
                    id: fieldMenu
                    target: input
                    host: Theme.compositorGlass ? menuHost.item : null
                    glassBackground: Theme.compositorGlass ? menuHost.glass : null
                    subGlassBackground: Theme.compositorGlass ? menuHost.subGlass : null
                    // the menu goes with its panel (judge #15: it stayed on screen and held the keyboard)
                    Connections { target: sp; function onShownChanged() { if (!sp.shown) fieldMenu.dismiss(); } }
                }
                x: sp.category !== "" ? token.x + token.width + 6 : sp.modeInfo ? Theme.spotlight.modeTextX : Theme.spotlight.textX
                width: trailing.x - 12 - x
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: Theme.spotlight.textDY
                font: Typography.font(Theme.spotlight.inputSize)
                color: Theme.spotlight.text
                selectionColor: Theme.color.textSelection   // selectedTextBackgroundColor: follows Appearance > Text highlight colour
                selectedTextColor: Theme.spotlight.text      // the text keeps its colour
                clip: true
                // caret: white, 2 x 26; its halo is caretGlow
                cursorDelegate: Rectangle { width: 2; height: 26; radius: 1; color: Theme.spotlight.text; visible: input.cursorVisible && sp.completionRest === "" }
                onTextChanged: { sp.query = text; if (text !== "") sp.modeListArmed = false; }
                Keys.onEscapePressed: sp.escapeKey()
                Keys.onReturnPressed: sp.acceptSel()
                Keys.onEnterPressed: sp.acceptSel()
                Keys.onDownPressed: sp.moveSel(1)
                Keys.onUpPressed: sp.moveSel(-1)
                Keys.onTabPressed: sp.moveSel(1)
                // the mode keys and the Apps grid's arrows first, then AppKit's text keys (HyprK keybindings.js)
                Keys.onPressed: event => { sp.handleKey(event); if (!event.accepted) KeyBindings.handle(event, input); }

                Text {
                    visible: input.text === "" && sp.category === ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: sp.modeInfo ? sp.modeInfo.placeholder : "Search or Ask"
                    font: input.font
                    color: Theme.spotlight.placeholder
                }
                // the top hit's inline completion (r17 spotlight-typed-*: "calc" + "ulator — Open"): the rest of an app's
                // name the query begins, and what Return does, grey on the completion pill from the end of the typed
                // text; the caret is not drawn then
                Rectangle {
                    visible: sp.completionRest !== ""
                    x: input.contentWidth
                    anchors.verticalCenter: parent.verticalCenter
                    width: appCompletion.implicitWidth + Theme.spotlight.completionPadRight
                    height: Theme.spotlight.completionH
                    radius: Theme.spotlight.completionRadius
                    color: Theme.spotlight.completionFill
                    Text {
                        id: appCompletion
                        anchors.verticalCenter: parent.verticalCenter
                        text: sp.completionRest
                        font: input.font
                        color: Theme.spotlight.completionRestText
                    }
                }
                // the answer inline after the query, on the completion pill (Q-panels-16, -21)
                Rectangle {
                    visible: sp.calcCard
                    x: input.contentWidth + 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: completion.implicitWidth + 8
                    height: completion.implicitHeight + 4
                    radius: Theme.spotlight.completionRadius
                    color: Theme.spotlight.completionFill
                    Text {
                        id: completion
                        anchors.centerIn: parent
                        text: "= " + sp.calcText
                        font: input.font
                        color: Theme.spotlight.completionText
                    }
                }
            }
            // the result card: "2+2 =" 12 regular grey, the answer 16 semibold white, a round copy button
            Rectangle {
                visible: sp.calcCard
                x: Theme.spotlight.calcCardInset
                y: Theme.spotlight.barH
                width: parent.width - 2 * Theme.spotlight.calcCardInset
                height: Theme.spotlight.calcCardH
                radius: height / 2
                color: Theme.spotlight.completionFill
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.3)
                Column {
                    x: 19
                    anchors.verticalCenter: parent.verticalCenter
                    Text { text: sp.query.trim() + " ="; font: Typography.font(12); color: Theme.spotlight.placeholder }
                    Text { text: sp.calcText; font: Typography.font(16, Typography.semibold); color: Theme.spotlight.text }
                }
                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.spotlight.calcCopy
                    height: width
                    radius: width / 2
                    color: Theme.spotlight.tokenFill
                    Symbol { anchors.centerIn: parent; name: "doc.on.doc.fill"; size: 14; color: Theme.spotlight.text }
                    MouseArea { anchors.fill: parent; onClicked: { Quickshell.clipboardText = sp.calcText; Panels.close(); } }
                }
            }
        }

        // "Show Results" under the grown bar: shows the list for the query (Q-panels-21)
        Item {
            id: showResults
            visible: sp.calcCard
            width: Theme.spotlight.showResultsW
            height: Theme.spotlight.showResultsH
            x: Math.round((stage.width - width) / 2)
            y: bar.y + bar.fullHeight + Theme.spotlight.gap
            Glass {
                anchors.fill: parent
                radius: height / 2
                sx: showResults.x
                sy: showResults.y
                tint: Theme.glass.tintStrong
            }
            // the same dark material as the bar's lower half (the capsule reads like it on the Mac shot)
            Rectangle { anchors.fill: parent; radius: height / 2; color: Theme.spotlight.barBottomTint }
            Row {
                anchors.centerIn: parent
                spacing: 8
                // Calculator in front of Finder, 10 pt apart, 16 pt bodies (panels/spotlight-calculator-*.png)
                Item {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 30; height: 20
                    AppIcon { x: 10; width: 20; height: 20; size: 20; icon: "system-file-manager"; appId: "hyprk-finder" }
                    AppIcon { width: 20; height: 20; size: 20; icon: "accessories-calculator"; appId: "org.gnome.Calculator" }
                }
                Text { anchors.verticalCenter: parent.verticalCenter; text: "Show Results"; font: Typography.font(13); color: Theme.spotlight.text }
            }
            MouseArea { anchors.fill: parent; onClicked: sp.showAll = true }
        }

        // ---------- the panel under it ----------
        Item {
            id: panel
            readonly property string kind: sp.panelKind
            visible: kind !== "" && height > 0.5
            readonly property bool wide: kind === "apps" || kind === "files" || (kind === "gone" && sp.goneWide)
            width: wide ? AG.metrics().width : Theme.spotlight.barW
            x: Math.round((stage.width - width) / 2)
            y: bar.y + bar.height + Theme.spotlight.gap
            readonly property real resultsH: Math.min(Theme.spotlight.resultsMax, results.contentHeight + 2 * Theme.spotlight.pillInset)
            // results grow and shrink on a spring (kept from before; the Mac's results motion is not measured)
            Spring { id: grow; target: panel.resultsH; response: Theme.anim.resizeResponse; damping: Theme.anim.resizeDamping; epsilon: 0.3; settlesGlass: true }
            height: kind === "apps" || kind === "files" ? AG.metrics().height
                  : kind === "list" ? Theme.spotlight.listPanelH
                  : kind === "modes" ? Theme.spotlight.modeListH
                  : kind === "results" ? (A11y.reduceMotion ? resultsH : grow.value)
                  : kind === "gone" ? sp.goneH : 0
            clip: true
            // the grow / collapse about the anchor (sp.panelMotion); Reduce motion: no scale, no blur, the fade stays
            transform: Scale {
                origin.x: panel.width / 2
                // the Apps panel grows and collapses about its top edge (Theme.spotlight.appsAnchorY), the lists about a
                // point 20 under it
                origin.y: panel.wide ? Theme.spotlight.appsAnchorY : Theme.spotlight.panelAnchorY
                xScale: 1 + Theme.travel(sp.panelSx - 1)
                yScale: 1 + Theme.travel(sp.panelSy - 1)
            }
            Glass {
                anchors.fill: parent
                radius: panel.wide ? Theme.spotlight.appsRadius : Theme.spotlight.panelRadius
                sx: panel.x
                sy: panel.y
                tint: Theme.glass.tintStrong
                // the plugin's Liquid Glass materialize (plugin/README.md "Motion"): the glass appears and goes with the
                // panel's opacity instead of fading as a layer
                materialize: sp.panelAlpha
            }
            // clicks on the panel never close Spotlight; a move over it counts like one anywhere (noteMotion)
            MouseArea { anchors.fill: parent; hoverEnabled: true; onPositionChanged: mouse => sp.noteMotion(this, mouse.x, mouse.y) }
            Item {
                id: panelBody
                anchors.fill: parent
                opacity: sp.panelAlpha
                layer.enabled: sp.panelLayer
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blurMax: 64
                    blur: Math.min(1, sp.panelBlur * (sp.devicePixelRatio > 0 ? sp.devicePixelRatio : 2) / 64)
                }
                Rectangle {
                    anchors.fill: parent
                    radius: panel.wide ? Theme.spotlight.appsRadius : Theme.spotlight.panelRadius
                    gradient: Gradient {
                        GradientStop { position: 0; color: Theme.spotlight.panelTopVeil }
                        GradientStop { position: 0.11; color: Theme.spotlight.panelUpperVeil }
                        GradientStop { position: 0.5; color: Theme.spotlight.panelMidVeil }
                        GradientStop { position: 1; color: Theme.spotlight.panelBottomVeil }
                    }
                }
                // the light line under the panel's top edge, over the veil (Theme.spotlight.panelRimTop)
                ShaderEffect {
                    anchors.fill: parent
                    property size size: Qt.size(width, height)
                    property real radius: panel.wide ? Theme.spotlight.appsRadius : Theme.spotlight.panelRadius
                    property point fall: Qt.point(Theme.spotlight.rimFall, 0)
                    property vector3d rimTop: Theme.spotlight.panelRimTop
                    property vector3d rimBottom: Qt.vector3d(0, 1, 0)
                    fragmentShader: Qt.resolvedUrl("../shaders/spotrim.frag.qsb")
                }
                ModeList {
                    visible: panel.kind === "modes"
                    width: parent.width
                    height: Theme.spotlight.modeListH
                    onPicked: m => sp.setMode(m)
                }
            }

            ListView {
                id: results
                visible: sp.below === "results"
                x: Theme.spotlight.pillInset
                y: Theme.spotlight.pillInset
                width: parent.width - Theme.spotlight.pillInset - Theme.spotlight.pillRightInset
                height: Theme.spotlight.resultsMax - 2 * Theme.spotlight.pillInset
                interactive: contentHeight > height
                boundsBehavior: Flickable.StopAtBounds        // a mouse wheel stops at the edge; trackpad: RubberBand
                RubberBand { flickable: results }
                model: sp.rows
                currentIndex: sp.selected
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                delegate: ResultRow {
                    required property var modelData
                    required property int index
                    width: results.width
                    selected: index === sp.selected
                    readonly property string k: modelData.kind
                    readonly property var d: k === "action" ? modelData.action : k === "file" ? modelData.file : null
                    title: modelData.title
                    subtitle: modelData.subtitle || ""
                    symbol: k === "calc" ? "equal" : k === "action" ? (d.symbol || "bolt") : "doc"
                    appIcon: k === "app" ? (modelData.icon || "") : k === "action" ? (d.appIcon || "") : ""
                    appId: k === "app" ? modelData.entry.id : k === "action" ? (d.appId || "") : ""
                    themeIcon: k === "file" ? SL.fileIcon(d.path, d.isDir, d.mime) : ""
                    accessory: k === "action" ? SL.quickKeyLabel(SpotlightState.quickKeys, d.id, false) : ""
                    badge: accessory !== ""
                    hint: index === 0 && k === "app" ? "Search " + modelData.title : ""
                    onClicked: { sp.selected = index; sp.accept(); }
                }
            }

            // the results list's scroll knob (Theme.spotlight.scrollKnob), there whenever the list is longer than the panel
            Rectangle {
                readonly property var k: SL.scrollKnob(panel.height, results.contentHeight + 2 * Theme.spotlight.pillInset, results.contentY - results.originY, SL.filesGrid().knobInset)
                visible: sp.below === "results" && panel.kind === "results" && k[1] > 0
                x: panel.width - SL.filesGrid().knobRight - width
                y: k[0]
                width: SL.filesGrid().knobWidth
                height: k[1]
                radius: width / 2
                color: Theme.spotlight.scrollKnob
            }

            Loader {
                id: modePanel
                active: sp.mode !== ""
                width: parent.width
                height: parent.height
                opacity: sp.panelAlpha       // the Apps panel's grow (panelMotion); 1 at rest
                sourceComponent: sp.mode === "apps" ? appsComp : sp.mode === "files" ? filesComp : listComp
            }
            Component {
                id: appsComp
                AppsPanel {
                    query: sp.query
                    category: sp.category
                    onPickCategory: name => { sp.category = name; input.forceActiveFocus(); }
                    onDone: Panels.close()
                }
            }
            Component {
                id: filesComp
                FilesPanel {
                    query: sp.query
                    category: sp.category
                    onPickCategory: name => { sp.category = name; input.forceActiveFocus(); }
                    onDone: Panels.close()
                }
            }
            Component {
                id: listComp
                ModeView {
                    mode: sp.mode
                    query: sp.query
                    onDone: Panels.close()
                    onEditFinished: input.forceActiveFocus()
                    onBack: sp.setMode("")
                }
            }
        }
    }

    // the text field menu's own layer (components/TextMenuHost.qml): the shell menus' glass on the plugin
    TextMenuHost { id: menuHost; screen: modelData; open: fieldMenu.open; armed: Theme.compositorGlass && sp.shown }
}
