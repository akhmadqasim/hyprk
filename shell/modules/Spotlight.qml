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
// capsule at 22.7 % of the screen height and, 10 below it, one panel:
// - results (520 wide, r 37, rows of 62, at most 410 tall) once text is typed;
// - the mode list (520 x 214) that unfolds while the field is empty and the pointer has entered the bar;
// - a mode (Cmd+1..4 or the list): Applications = the Apps panel (844 x 520, AppsPanel.qml, also the Dock's
//   "Apps"), Files / Actions / Clipboard = a 520 x 490 list (ModeView.qml).
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
    //   FUN_2adea2ff0 (x on bounce 0.41, y 0.95 -> 1) is not seen live. Window alpha 0 -> 1 on Spring(0.28, 0.41)
    //   (REA, not re-measured);
    // - close (FUN_2adea36c8, FUN_2ade9ef14 flag 1): scale.x 1 -> 1.12 and scale.y 1 -> 0.95 on Spring(0.45, 0.05),
    //   alpha 1 -> 0 on Spring(0.28, 0.41). The window is unloaded when the alpha first reaches 0 (0.12 s); it
    //   would only swing back to 0.01 after that.
    //   The close also blurs the content, contentBlurRadius 0 -> 25 pt on Spring(0.51, 0.05) (FUN_2ade9ef14 flag 1):
    //   a QML blur of the stage, on only while closing (the plugin glass is not blurred, it dematerializes).
    // Not done: the open's contentBlurRadius 25 -> 0 (the open matches the Mac's scale track without it, and a
    // full-screen layer for its 0.5 s spring), and transform.translation.y (its start value is not read). The scale
    // anchor is not read: the search field's centre.
    // The window is kept loaded but unmapped after the shell has started (shell.qml): created on open it showed its
    // first frame ~90 ms after the call. The springs start on the first frame after it maps (alpha 0), else mapping
    // eats their first frames. Reduce motion: no scale (Theme.travel), no blur, the fade stays.
    property real scaleX: 1.12
    property real scaleY: 1.12
    property real alpha: 0
    readonly property var springOpen: SpringLib.fromBounce(0.28, 0.32)
    readonly property var springClose: SpringLib.fromBounce(0.45, 0.05)
    readonly property var springAlpha: SpringLib.fromBounce(0.28, 0.41)
    property real blurRadius: 0
    property bool blurOn: false
    readonly property var springBlur: SpringLib.fromBounce(0.51, 0.05)
    SpringCurve {
        id: animBlur
        target: sp; property: "blurRadius"; spring: sp.springBlur
        onFinished: if (goal === 0) sp.openBlur = false
    }
    // The open's content blur 25 -> 0 (REA section 4: the same blurRadius spring as the close, reversed). The bar's
    // content is drawn once into a texture of the bar's own size and that is blurred (stage below), not the
    // full-screen stage layer the close uses; the texture goes when the blur has landed or the content changes.
    property bool openBlur: false
    function dropOpenBlur(): void { if (openBlur && query !== "") { openBlur = false; animBlur.snap(0); } }
    SpringCurve { id: animX; target: sp; property: "scaleX" }
    SpringCurve { id: animY; target: sp; property: "scaleY"; settlesGlass: true }   // steps after animX: the glass is re-measured once both moved
    SpringCurve {
        id: animAlpha
        target: sp
        property: "alpha"
        spring: sp.springAlpha
        onFinished: if (!sp.shown) sp.gone = true
    }
    property bool gone: false
    // Apps (Spotlight's apps mode here) is an ordinary window on 27.2.1: it appears in one frame and Escape closes it
    // in one frame (MAC-ANSWERS.md R2). With the Spotlight springs it faded in over 0.10 s and kept a 13 % tail for
    // 0.12 s on close (mcap). The mode is taken at open: SpotlightState forgets it when Spotlight closes.
    property bool appsCut: false
    function animate(open) {
        gone = false;
        if (open) appsCut = mode === "apps";
        if (appsCut) {
            animX.snap(1);
            animY.snap(1);
            animAlpha.snap(open ? 1 : 0);
            blurOn = false;
            openBlur = false;
            animBlur.snap(0);
            gone = !open;
            settleGlass(50);
            return;
        }
        blurOn = !open && !A11y.reduceMotion;
        openBlur = open && !A11y.reduceMotion;
        if (openBlur) { animBlur.snap(25); animBlur.go(0); }
        else if (!blurOn) animBlur.snap(0);
        else animBlur.go(25);
        animX.spring = open ? springOpen : springClose;
        animY.spring = open ? springOpen : springClose;
        animAlpha.cutAt = open ? 0 : SpringLib.firstCrossing(springAlpha, 0, 0.001);
        animX.go(open ? 1 : 1.12);
        animY.go(open ? 1 : 0.95);
        animAlpha.go(open ? 1 : 0);
        settleGlass(Math.max(animX.duration, animY.duration, animAlpha.duration) + 50);   // the glass follows the scale
    }
    property bool firstFrame: true
    Connections {
        target: sp.firstFrame ? sp.contentItem.Window.window : null
        function onFrameSwapped() { sp.firstFrame = false; if (sp.shown) sp.animate(true); }
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
    // rows: {kind: "calc"|"app"|"action"|"file", ...}; 27.2.1 has no section headers (Q-panels-20)
    readonly property var rows: {
        if (mode !== "" || query.trim() === "" || calcCard) return [];
        const r = [];
        const addActions = () => { for (const a of actions) r.push({ kind: "action", title: a.title, subtitle: a.subtitle || "", action: a }); };
        if (quickKeyHit) addActions();      // a typed quick key puts its action on top
        if (calcValue !== null) r.push({ kind: "calc", title: Search.formatNumber(calcValue), subtitle: query.trim() + " =" });
        for (const a of apps) r.push({ kind: "app", title: a.name, subtitle: "Application", entry: a, icon: a.icon });
        if (!quickKeyHit) addActions();
        for (const f of files) r.push({ kind: "file", title: f.name, subtitle: f.dir, file: f });
        return r;
    }

    // the mode list: once the pointer really moved into the bar while the field is empty (components/
    // PointerGate.qml: the layer maps under a resting pointer); it stays after the pointer leaves. Holding Command
    // (or Ctrl) alone for 0.35 s shows it too, while the key is held (SL.HINT_HOLD_MS, commandKeyHintTimer)
    PointerGate { id: hoverGate }
    property bool modeListArmed: false
    property bool hintHeld: false
    Timer { id: hintHold; interval: SL.HINT_HOLD_MS; onTriggered: sp.hintHeld = sp.mode === "" && input.text === "" }
    function hintKey(event, down) {
        if (event.isAutoRepeat) return;
        if (down && SL.isHintKey(event.key)) { hintHold.restart(); return; }
        hintHold.stop();
        hintHeld = false;
    }
    readonly property string below: mode === "apps" ? "apps" : mode !== "" ? "list"
        : rows.length > 0 ? "results" : (modeListArmed || hintHeld) && query === "" ? "modes" : ""
    // unfolds downward in about 0.18 s, ease-in-out (Q-panels-26); gone at once when text is typed
    // one value per frame of this window (HyprK FrameEase), the glass re-measured with each
    readonly property real unfold: unfoldEase.value
    FrameEase {
        id: unfoldEase
        goal: sp.below === "modes" ? 1 : 0
        // read when the goal changes: query and mode change before `below` does
        animate: sp.query === "" && sp.mode === "" && !A11y.reduceMotion
        duration: Theme.spotlight.unfoldMs
        ease: Easing.InOutSine
        settlesGlass: true
    }
    onBelowChanged: settleGlass(50)

    function setMode(m) {
        SpotlightState.mode = m;
        category = "";
        input.text = "";
        input.forceActiveFocus();
    }
    // query field keys without a dedicated handler: Super/Ctrl/Alt+1..4 pick a mode; Left/Right move in the Apps
    // grid (they do not cycle modes on the Mac); Backspace on an empty field drops the category token
    function handleKey(event) {
        hintKey(event, true);
        // Clipboard: Cmd-Delete on an empty field deletes the selected item (the Mac has a per-item delete,
        // com.apple.spotlight.delete.pasteboard.item; its key is not decoded)
        if (mode === "clipboard" && input.text === "" && (event.modifiers & (Qt.MetaModifier | Qt.ControlModifier))
                && (event.key === Qt.Key_Backspace || event.key === Qt.Key_Delete)) {
            modePanel.item.deleteSelected(); event.accepted = true; return;
        }
        // Command alone: Cmd-0 back to all results, Cmd-R / Cmd-Return reveal the file in the Finder, Cmd-, Spotlight
        // settings (SL.commandForKey; the other commands of the Mac's table have no hyprk counterpart yet)
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
            // Cmd-Y Quick Look: our Finder opens on the file's folder with it selected and Quick Look up (--quicklook)
            if (c === "quicklook" && quickLookSel()) { event.accepted = true; return; }
        }
        const m = SL.modeForKey(event.key, event.modifiers & Qt.MetaModifier, event.modifiers & Qt.ControlModifier, event.modifiers & Qt.AltModifier);
        if (m !== "") { setMode(m === mode ? "" : m); event.accepted = true; return; }
        if (event.key === Qt.Key_Backspace && input.text === "" && category !== "") { category = ""; event.accepted = true; return; }
        const dir = event.key === Qt.Key_Right ? 1 : event.key === Qt.Key_Left ? -1 : 0;
        if (dir !== 0 && mode === "apps" && input.text === "") { modePanel.item.move(dir, 0); event.accepted = true; }
    }
    function moveSel(dir) {
        if (mode === "apps") modePanel.item.move(0, dir);
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
    function quickLookSel(): bool {
        const r = selectedRow();
        const f = r && r.kind === "file" ? r.file : null;
        if (!f || !f.path || f.isDir) return false;
        const cut = f.path.lastIndexOf("/");
        Apps.runHyprkApp("hyprk-finder", {}, [f.path.slice(0, cut) || "/", "--select", f.path.slice(cut + 1), "--quicklook"]);
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
    // reopened after it went: map again from the start values, empty; the springs start at once (mapping a loaded
    // window takes about a frame, waiting for its first frame as on creation cost 2 more, mcap)
    // closed less than 8 minutes ago: the query is still there, selected (SL.keepsQuery)
    property real closedAt: 0
    property bool selectOnShow: false
    function rearm() {
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
        hintHeld = false;
        hoverGate.reset();
    }
    onShownChanged: {
        if (!shown) { closedAt = Date.now(); hintHold.stop(); hintHeld = false; }
        if (shown && gone) rearm();
        shown ? present() : animate(false);       // present(): also reopened while still fading out
    }
    onModeChanged: category = ""
    Connections {
        target: Panels
        function onSpotlightQueryChanged() { sp.takeQuery(); }
    }
    onQueryChanged: { selected = 0; showAll = false; dropOpenBlur(); }
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
            blur: Math.min(1, sp.blurRadius * (sp.screen ? sp.screen.devicePixelRatio : 2) / 64)
        }
        readonly property real barX: Math.round((width - Theme.spotlight.barW) / 2)
        readonly property real barY: Math.round(height * Theme.spotlight.barTop)
        transform: Scale {
            origin.x: stage.width / 2
            origin.y: stage.barY + Theme.spotlight.barH / 2
            xScale: 1 + Theme.travel(sp.scaleX - 1)
            yScale: 1 + Theme.travel(sp.scaleY - 1)
        }

        // the open blur: the bar as one still texture (device pixels, 32 pt of room for the blur), blurred
        ShaderEffectSource {
            id: barStill
            readonly property real pad: 32
            x: bar.x - pad
            y: bar.y - pad
            width: bar.width + 2 * pad
            height: bar.fullHeight + 2 * pad
            visible: false
            sourceItem: sp.openBlur ? bar : null
            sourceRect: Qt.rect(-pad, -pad, width, height)
            live: false
            onSourceItemChanged: if (sourceItem) scheduleUpdate()
            hideSource: sp.openBlur
        }
        MultiEffect {
            visible: sp.openBlur
            x: barStill.x
            y: barStill.y
            width: barStill.width
            height: barStill.height
            source: barStill
            autoPaddingEnabled: false
            blurEnabled: true
            blurMax: 64
            blur: Math.min(1, sp.blurRadius * (sp.screen ? sp.screen.devicePixelRatio : 2) / 64)
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
                    GradientStop { position: 0.5; color: Theme.spotlight.barMidTint }
                    GradientStop { position: 1; color: Theme.spotlight.barBottomTint }
                }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onPositionChanged: mouse => { if (hoverGate.note(this, mouse.x, mouse.y) && sp.mode === "" && input.text === "") sp.modeListArmed = true; }
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
                    anchors.verticalCenter: parent.verticalCenter
                    visible: sp.mode === "" && sp.apps.length === 0
                    name: "mic.fill"
                    size: Theme.spotlight.micSize
                    color: Theme.spotlight.placeholder
                }
                AppIcon {
                    anchors.centerIn: parent
                    width: 28 / Theme.appIcon.body       // the top hit's icon art is about 28
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
            TextInput {
                id: input
                MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton; cursorShape: Qt.IBeamCursor }   // TextInput sets no I-beam itself
                x: sp.category !== "" ? token.x + token.width + 6 : sp.modeInfo ? Theme.spotlight.modeTextX : Theme.spotlight.textX
                width: trailing.x - 12 - x
                anchors.verticalCenter: parent.verticalCenter
                font: Typography.font(Theme.spotlight.inputSize)
                color: Theme.spotlight.text
                selectionColor: Theme.color.textSelection   // selectedTextBackgroundColor: follows Appearance > Text highlight colour
                selectedTextColor: Theme.spotlight.text      // the text keeps its colour
                clip: true
                // caret: white, 2 x 26 (its soft multicolour halo is not drawn)
                cursorDelegate: Rectangle { width: 2; height: 26; radius: 1; color: Theme.spotlight.text; visible: input.cursorVisible }
                onTextChanged: { sp.query = text; if (text !== "") sp.modeListArmed = false; }
                Keys.onEscapePressed: sp.escapeKey()
                Keys.onReturnPressed: sp.acceptSel()
                Keys.onEnterPressed: sp.acceptSel()
                Keys.onDownPressed: sp.moveSel(1)
                Keys.onUpPressed: sp.moveSel(-1)
                Keys.onTabPressed: sp.moveSel(1)
                // the mode keys and the Apps grid's arrows first, then AppKit's text keys (HyprK keybindings.js)
                Keys.onPressed: event => { sp.handleKey(event); if (!event.accepted) KeyBindings.handle(event, input); }
                Keys.onReleased: event => sp.hintKey(event, false)

                Text {
                    visible: input.text === "" && sp.category === ""
                    anchors.verticalCenter: parent.verticalCenter
                    text: sp.modeInfo ? sp.modeInfo.placeholder : "Search or Ask"
                    font: input.font
                    color: Theme.spotlight.placeholder
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
            visible: sp.below !== "" && height > 0.5
            readonly property bool wide: sp.below === "apps"
            width: wide ? AG.metrics().width : Theme.spotlight.barW
            x: Math.round((stage.width - width) / 2)
            y: bar.y + bar.height + Theme.spotlight.gap
            readonly property real resultsH: Math.min(Theme.spotlight.resultsMax, results.contentHeight + 2 * Theme.spotlight.pillInset)
            // results grow and shrink on a spring (kept from before; the Mac's results motion is not measured)
            Spring { id: grow; target: panel.resultsH; response: Theme.anim.resizeResponse; damping: Theme.anim.resizeDamping; epsilon: 0.3; settlesGlass: true }
            height: sp.below === "apps" ? AG.metrics().height
                  : sp.below === "list" ? Theme.spotlight.listPanelH
                  : sp.below === "modes" ? Theme.spotlight.modeListH * sp.unfold
                  : sp.below === "results" ? (A11y.reduceMotion ? resultsH : grow.value) : 0
            clip: true
            Glass {
                anchors.fill: parent
                radius: panel.wide ? Theme.spotlight.appsRadius : Theme.spotlight.panelRadius
                sx: panel.x
                sy: panel.y
                tint: Theme.glass.tintStrong
            }
            Rectangle {
                width: parent.width
                height: sp.below === "modes" ? Theme.spotlight.modeListH : parent.height
                radius: panel.wide ? Theme.spotlight.appsRadius : Theme.spotlight.panelRadius
                gradient: Gradient {
                    GradientStop { position: 0; color: Theme.spotlight.panelTopVeil }
                    GradientStop { position: 1; color: Theme.spotlight.panelBottomVeil }
                }
            }
            MouseArea { anchors.fill: parent }   // clicks on the panel never close Spotlight

            ModeList {
                visible: sp.below === "modes"
                width: parent.width
                height: Theme.spotlight.modeListH
                onPicked: m => sp.setMode(m)
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
                    onClicked: { sp.selected = index; sp.accept(); }
                }
            }

            Loader {
                id: modePanel
                active: sp.mode !== ""
                width: parent.width
                height: parent.height
                sourceComponent: sp.mode === "apps" ? appsComp : listComp
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
}
